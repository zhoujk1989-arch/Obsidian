/*
草案质量状态：合格（2026-05-10 重构校准）。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md

2026-05-10 重构校准要点：
1. 补齐 T_1_2（机构关系）INNER JOIN，关联条件：T_10_2.K020001 = T_1_2.A020001 AND T_1_2.A020002 = '0'（上级管理机构ID等于0）
2. 修正 T_1_1 LEFT JOIN：从 `ON 1 = 1` 改为 `ON T_1_2.A020001 = T_1_1.A010001`
3. 补齐 WHERE 过滤：SUBSTR(src.K020002, 7, 6) = LEFT(P_DATA_DATE, 6)（汇率ID截取第七位到最后时间点等于当月）
4. HLRQ：从 raw K020002 改为 SUBSTR(K020002, 7, 8)（第7位开始截取8位）
5. WBSL：从 NULL 改为 CAST(100 AS DECIMAL(20,6))（业务需求要求赋值'100',100外币折合多少本币）
6. NBJGH：从 K020001 改为 T_1_1.A010002（取机构信息的内部机构号）
7. BBBZ：从 K020004 改为常量 'CNY'（业务需求要求赋值'CNY'）
8. ZBBSL：CAST 精度从 DECIMAL(20,2) 修正为 DECIMAL(20,6)（与目标 DDL 一致）
9. CJRQ：从 K020009 格式转换改为 P_DATA_DATE 参数赋值（标准模式）
*/

/*
业务目标：
- 依据原始业务需求《058_汇率信息表.md》生成 EAST5.0 汇率信息表（IE_010_1001_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/058_汇率信息表.md
- 原始材料/表结构/EAST5.0系统/IE_010_1001_INC-汇率信息表-DDL-2026-04-28.sql

源表：
- T_10_2（汇率利率）：主表，提供汇率ID、外币币种、本币币种、中间价、备注、采集日期等
- T_1_2（机构关系）：内关联，过滤上级管理机构ID等于0的机构
- T_1_1（机构信息）：左关联，补充银行机构名称、内部机构号、金融许可证号

目标表：
- IE_010_1001_INC：汇率信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 国家外汇管理局公布汇率的主要币种，填报各主要外币与人民币的折算汇率。其他货币对人民币的折算汇率，以当天美元兑人民币的基准汇率与同一天国际外汇市场其他货币兑美元汇率套算确定。机构可只填报常见的外币信息，但至少应包含其它表中填报使用过的所有外币。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1418 行） 主表：【汇率利率】 内关联：【机构关系】 关联条件：【机构关系】【上级管理机构ID】等于0 左关联：【机构信息】 关联条件：【机构关系】【机构ID】关联【机构信息】【机构ID】 过滤条件：汇率ID截取第七位到最后时间点等于当月

2026-05-10 重构校准确认：
- 内关联（INNER JOIN）：T_1_2（机构关系），关联条件：ON src.K020001 = rel.A020001 AND rel.A020002 = '0'
- 左关联（LEFT JOIN）：T_1_1（机构信息），关联条件：ON rel.A020001 = s1.A010001
- 过滤条件：SUBSTR(src.K020002, 7, 6) = LEFT(P_DATA_DATE, 6)
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_010_1001_INC_HLXXB;

CREATE PROCEDURE PROC_EAST_IE_010_1001_INC_HLXXB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);

    START TRANSACTION;

    DELETE FROM IE_010_1001_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_010_1001_INC (
        HLRQ,
        YHJGMC,
        SENSITIVEFLAG,
        GSFZJG,
        BBZ,
        CJRQ,
        WBBZ,
        WBSL,
        NBJGH,
        JRXKZH,
        BBBZ,
        ZBBSL
    )
    SELECT
        /* 汇率日期：汇率利率.汇率ID -> T_10_2.K020002；加工映射：第7位开始截取8位 */
        SUBSTR(src.K020002, 7, 8) AS HLRQ,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005 */
        s1.A010005 AS YHJGMC,
        /* 涉密标志：DDL存在但业务需求映射表未给来源，暂置NULL */
        NULL AS SENSITIVEFLAG,
        /* 归属分支机构：DDL存在但业务需求映射表未给来源，暂置NULL */
        NULL AS GSFZJG,
        /* 备注：汇率利率.备注 -> T_10_2.K020010；直接映射 */
        src.K020010 AS BBZ,
        /* 采集日期：按标准模式赋参数值 */
        P_DATA_DATE AS CJRQ,
        /* 外币币种：汇率利率.外币币种 -> T_10_2.K020003；直接映射 */
        src.K020003 AS WBBZ,
        /* 外币数量：业务需求要求赋值'100'（100外币折合多少本币） */
        CAST(100 AS DECIMAL(20,6)) AS WBSL,
        /* 内部机构号：机构信息.内部机构号 -> T_1_1.A010002 */
        s1.A010002 AS NBJGH,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003 */
        s1.A010003 AS JRXKZH,
        /* 本币币种：业务需求要求赋值'CNY' */
        'CNY' AS BBBZ,
        /* 折本币数量：汇率利率.中间价 -> T_10_2.K020005；直接映射 */
        CAST(NULLIF(TRIM(src.K020005), '') AS DECIMAL(20,6)) AS ZBBSL
    FROM T_10_2 src
    /* 内关联：机构关系，上级管理机构ID等于0（仅取顶层机构） */
    INNER JOIN T_1_2 rel
           ON src.K020001 = rel.A020001
          AND rel.A020002 = '0'
    /* 左关联：机构信息，补充银行机构名称、内部机构号、金融许可证号 */
    LEFT JOIN T_1_1 s1
           ON rel.A020001 = s1.A010001
    /* 过滤条件：汇率ID截取第七位到最后时间点等于当月 */
    WHERE SUBSTR(src.K020002, 7, 6) = LEFT(P_DATA_DATE, 6);

    COMMIT;
END;
