/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《039_垫款登记表.md》生成 EAST5.0 垫款登记表（IE_005_512）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/039_垫款登记表.md
- 原始材料/表结构/EAST5.0系统/IE_005_512-垫款登记表-DDL-2026-04-28.sql

源表：
- T_8_3, T_1_1

目标表：
- IE_005_512：垫款登记表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 填报信用证、承兑汇票、保函、贵金属租赁等业务产生的各项垫款信息，相关业务定义参照1104报表《各项垫款情况表》。垫款状态为“结清”、“转让”、“核销”的，在报送最后状态的次月可不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 951 行） 取日期在当月且通过信贷借据号关联生成对公信贷业务借据表来筛选范围

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_512_DKDJB;

CREATE PROCEDURE PROC_EAST_IE_005_512_DKDJB(
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

    DELETE FROM IE_005_512
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_512 (
        DKYE,
        KHLB,
        CJRQ,
        GSFZJG,
        SENSITIVEFLAG,
        NBJGH,
        XDHTH,
        DKLX,
        BZ,
        JRXKZH,
        YHJGMC,
        XDJJH,
        YHTBH,
        DKJE,
        KHTYBH,
        DKRQ,
        DKZT,
        BBZ,
        KHMC
    )
    SELECT
        /* 垫款余额：垫款状态.垫款余额 -> T_8_3.H030009；直接映射 */
        CAST(NULLIF(TRIM(src.H030009), '') AS DECIMAL(20,2)) AS DKYE,
        /* 客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS KHLB,
        /* 采集日期：垫款状态.采集日期 -> T_8_3.H030013；格式转换：格式转为'YYYYMMDD'。 */
        CONCAT(CAST(YEAR(src.H030013) AS VARCHAR(4)), LPAD(CAST(MONTH(src.H030013) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.H030013) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 内部机构号：垫款状态.机构ID -> T_8_3.H030003；加工规则：从【垫款状态】.【机构ID】第12位开始截取。 */
        SUBSTR(TRIM(src.H030003), 12) AS NBJGH,
        /* 信贷合同号：垫款状态.协议ID -> T_8_3.H030001；直接映射 */
        src.H030001 AS XDHTH,
        /* 垫款类型：垫款状态.垫款类型 -> T_8_3.H030007；代码转化： 若为'01'[承兑汇票]，则赋值为'1.1承兑汇票'； 若为'02'[融资性保函]，则赋值为'1.2融资性保函'； 若为'03'[其他等同于贷款的授信业务]，则赋值为'1.3其他等同于贷款的授信业务' 若为'04'[非融资性保函]，则赋值为'2.1非融资性保函'； 若为'05'[其他与交易相关的或有项目]，则赋值为'2.2其他与交易相关的或有项目'； 若为'06'[跟单信用证]，则赋值为'3.1跟单信用证'； 若为'07'[...；转换规则需人工补齐 CASE 分支 */
        src.H030007 AS DKLX,
        /* 币种：垫款状态.币种 -> T_8_3.H030006；直接映射 */
        src.H030006 AS BZ,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工规则：用【垫款状态】.【机构ID】关联【机构信息】.【机构ID】，取【机构信息】.【金融许可证号】 */
        s1.A010003 AS JRXKZH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；加工规则：用【垫款状态】.【机构ID】关联【机构信息】.【机构ID】，取【机构信息】.【银行机构名称】 */
        s1.A010005 AS YHJGMC,
        /* 信贷借据号：垫款状态.借据ID -> T_8_3.H030004；直接映射 */
        src.H030004 AS XDJJH,
        /* 原合同编号：垫款状态.原协议ID -> T_8_3.H030005；直接映射 */
        src.H030005 AS YHTBH,
        /* 垫款金额：垫款状态.垫款金额 -> T_8_3.H030008；直接映射 */
        CAST(NULLIF(TRIM(src.H030008), '') AS DECIMAL(20,2)) AS DKJE,
        /* 客户统一编号：垫款状态.客户ID -> T_8_3.H030002；直接映射 */
        src.H030002 AS KHTYBH,
        /* 垫款日期：垫款状态.垫款日期 -> T_8_3.H030010；格式转换：转字符格式'YYYYMMDD'，若取不到或为空，则赋默认值99991231。 */
        CASE WHEN src.H030010 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.H030010) AS VARCHAR(4)), LPAD(CAST(MONTH(src.H030010) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.H030010) AS VARCHAR(2)), 2, '0')) END AS DKRQ,
        /* 垫款状态：垫款状态.垫款状态 -> T_8_3.H030011；代码转化： 若为'01'[未结清]，则赋值为'未结清'； 若为'02'[已结清]，则赋值为'已结清'； 若为'03'[转让]，则赋值为'转让'； 若为'04'[核销]，则赋值为'核销'； 若为'00-XX'，则赋值为'其他-XX'。 XX为银行自定义；转换规则需人工补齐 CASE 分支 */
        src.H030011 AS DKZT,
        /* 备注：垫款状态.备注 -> T_8_3.H030012；提取一表通《表8.3垫款状态》备注，以“;”拼接。 */
        src.H030012 AS BBZ,
        /* 客户名称：待确认来源字段：EAST对公客户信息表.客户名称 */
        NULL AS KHMC
    FROM T_8_3 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《039_垫款登记表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
