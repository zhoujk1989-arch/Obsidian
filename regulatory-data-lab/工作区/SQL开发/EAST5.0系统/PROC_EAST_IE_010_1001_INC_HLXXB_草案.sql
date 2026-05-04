/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
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
- T_10_2, T_1_1

目标表：
- IE_010_1001_INC：汇率信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 国家外汇管理局公布汇率的主要币种，填报各主要外币与人民币的折算汇率。其他货币对人民币的折算汇率，以当天美元兑人民币的基准汇率与同一天国际外汇市场其他货币兑美元汇率套算确定。机构可只填报常见的外币信息，但至少应包含其它表中填报使用过的所有外币。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1418 行） 主表：【汇率利率】 内关联：【机构关系】 关联条件：【机构关系】【上级管理机构ID】等于0 左关联：【机构信息】 关联条件：【机构关系】【机构ID】关联【机构信息】【机构ID】 过滤条件：汇率ID截取第七位到最后时间点等于当月

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
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
        src.K020002 AS HLRQ,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；取机构信息的银行机构名称 */
        s1.A010005 AS YHJGMC,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 备注：汇率利率.备注 -> T_10_2.K020010；直接映射 */
        src.K020010 AS BBZ,
        /* 采集日期：汇率利率.采集日期 -> T_10_2.K020009；直接映射:yyyy-mm-dd转为yyyymmdd */
        CONCAT(CAST(YEAR(src.K020009) AS VARCHAR(4)), LPAD(CAST(MONTH(src.K020009) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.K020009) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 外币币种：汇率利率.外币币种 -> T_10_2.K020003；直接映射 */
        src.K020003 AS WBBZ,
        /* 外币数量：待确认来源字段：. */
        NULL AS WBSL,
        /* 内部机构号：汇率利率.机构ID -> T_10_2.K020001；取机构信息的内部机构号 */
        src.K020001 AS NBJGH,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；取机构信息的金融许可证号 */
        s1.A010003 AS JRXKZH,
        /* 本币币种：汇率利率.本币币种 -> T_10_2.K020004；赋值'CNY' */
        src.K020004 AS BBBZ,
        /* 折本币数量：汇率利率.中间价 -> T_10_2.K020005；直接映射 */
        CAST(NULLIF(TRIM(src.K020005), '') AS DECIMAL(20,2)) AS ZBBSL
    FROM T_10_2 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《058_汇率信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
