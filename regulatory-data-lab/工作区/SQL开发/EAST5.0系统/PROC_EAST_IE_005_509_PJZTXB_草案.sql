/*
业务目标：
- 依据原始业务需求《036_票据转贴现表.md》生成 EAST5.0 票据转贴现表（IE_005_509）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/036_票据转贴现表.md
- 原始材料/表结构/EAST5.0系统/IE_005_509-票据转贴现表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_14-票据转贴现协议-DDL-2026-04-27.sql

源表：
- T_1_1（机构信息）
- T_6_14（票据转贴现协议）

目标表：
- IE_005_509：票据转贴现表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送本行发生的转贴现买断、转贴现卖断、质押式回购正回购、质押式回购逆回购、买断式回购正回购、买断式回购逆回购、再贴现等业务的明细信息。票据状态为"卖断"、"解付"或"核销"的数据，在报送票据最后状态的次月可不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 864 行） 取日期在当月且剔除上月状态为失效的数据

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 码值转换、日期格式转换、备注处理、终态纳入规则已按业务需求文档实现，但 SQL 草案尚未在 GBase 环境执行验证。
- `SENSITIVEFLAG`（涉密标志）和 `GSFZJG`（归属分支机构）在 DDL 中存在但业务需求映射表未给来源，SQL 中置 NULL，符合审计处置原则。
- 表级规则"剔除上月状态为失效的数据"仅按采集日期过滤代理，终态纳入规则待需求方确认。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_509_PJZTXB;

CREATE PROCEDURE PROC_EAST_IE_005_509_PJZTXB(
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

    DELETE FROM IE_005_509
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_509 (
        BBZ,
        YHJGMC,
        ZTXLX,
        SENSITIVEFLAG,
        JRXKZH,
        NBJGH,
        XDHTH,
        PJHM,
        PJLX,
        PMJE,
        CPRMC,
        TXRMC,
        TXRQ,
        JYFX,
        ZTXRQ,
        ZTXJE,
        ZTXLL,
        HGLV,
        JYDSMC,
        PJZT,
        CJRQ,
        GSFZJG,
        XDJJH,
        BZ,
        PJCPRQ,
        PJDQRQ,
        CDRMC,
        ZTXLB,
        ZTXJXTS,
        HGRQ,
        HGJE,
        HGLX,
        JYDSHH
    )
    SELECT
        /* 01 备注：票据转贴现协议.备注 -> T_6_14.F140034；直接映射，截断至 600 字符 */
        LEFT(s1.F140034, 600) AS BBZ,

        /* 02 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；LEFT JOIN enrich */
        s1_org.A010005 AS YHJGMC,

        /* 03 转贴现利息：票据转贴现协议.转贴现利息 -> T_6_14.F140021；CAST DECIMAL(20,2) */
        CAST(NULLIF(TRIM(s1.F140021), '') AS DECIMAL(20,2)) AS ZTXLX,

        /* 04 涉密标志：DDL 存在，业务需求映射表未给来源，置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 05 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；LEFT JOIN enrich */
        s1_org.A010003 AS JRXKZH,

        /* 06 内部机构号：票据转贴现协议.机构ID -> T_6_14.F140002；SUBSTR(机构ID, 12) */
        SUBSTR(s1.F140002, 12) AS NBJGH,

        /* 07 信贷合同号：票据转贴现协议.协议ID -> T_6_14.F140001；直接映射 */
        s1.F140001 AS XDHTH,

        /* 08 票据号码：票据转贴现协议.票据号码 -> T_6_14.F140003；直接映射 */
        s1.F140003 AS PJHM,

        /* 09 票据类型：票据转贴现协议.票据类型 -> T_6_14.F140004；码值转换 */
        CASE
            WHEN TRIM(s1.F140004) = '01' THEN '银行承兑汇票'
            WHEN TRIM(s1.F140004) = '02' THEN '商业承兑汇票'
            WHEN TRIM(s1.F140004) = '03' THEN '财务公司承兑汇票'
            ELSE ''
        END AS PJLX,

        /* 10 票面金额：票据转贴现协议.票面金额 -> T_6_14.F140006；CAST DECIMAL(20,2) */
        CAST(NULLIF(TRIM(s1.F140006), '') AS DECIMAL(20,2)) AS PMJE,

        /* 11 出票人名称：票据转贴现协议.出票人名称 -> T_6_14.F140009；直接映射 */
        s1.F140009 AS CPRMC,

        /* 12 贴现人名称：票据转贴现协议.贴现人名称 -> T_6_14.F140011；直接映射 */
        s1.F140011 AS TXRMC,

        /* 13 贴现日期：票据转贴现协议.贴现日期 -> T_6_14.F140012；DATE → YYYYMMDD */
        CASE
            WHEN s1.F140012 IS NOT NULL THEN REPLACE(CAST(s1.F140012 AS CHAR), '-', '')
            ELSE NULL
        END AS TXRQ,

        /* 14 交易方向：票据转贴现协议.交易方向 -> T_6_14.F140013；码值转换 */
        CASE
            WHEN TRIM(s1.F140013) = '01' THEN '买入'
            WHEN TRIM(s1.F140013) = '02' THEN '卖出'
            ELSE ''
        END AS JYFX,

        /* 15 转贴现日期：票据转贴现协议.转贴现日期 -> T_6_14.F140017；DATE → YYYYMMDD */
        CASE
            WHEN s1.F140017 IS NOT NULL THEN REPLACE(CAST(s1.F140017 AS CHAR), '-', '')
            ELSE NULL
        END AS ZTXRQ,

        /* 16 转贴现金额：票据转贴现协议.转贴现金额 -> T_6_14.F140018；CAST DECIMAL(20,2) */
        CAST(NULLIF(TRIM(s1.F140018), '') AS DECIMAL(20,2)) AS ZTXJE,

        /* 17 转贴现利率：票据转贴现协议.转贴现利率 -> T_6_14.F140020；CAST DECIMAL(20,6) */
        CAST(NULLIF(TRIM(s1.F140020), '') AS DECIMAL(20,6)) AS ZTXLL,

        /* 18 回购利率：票据转贴现协议.回购利率 -> T_6_14.F140024；CAST DECIMAL(20,6) */
        CAST(NULLIF(TRIM(s1.F140024), '') AS DECIMAL(20,6)) AS HGLV,

        /* 19 交易对手名称：票据转贴现协议.交易对手名称 -> T_6_14.F140026；直接映射 */
        s1.F140026 AS JYDSMC,

        /* 20 票据状态：票据转贴现协议.票据状态 -> T_6_14.F140033；码值转换 */
        CASE
            WHEN TRIM(s1.F140033) = '01' THEN '正常'
            WHEN TRIM(s1.F140033) = '02' THEN '卖断'
            WHEN TRIM(s1.F140033) = '03' THEN '解付'
            WHEN TRIM(s1.F140033) = '04' THEN '垫款'
            WHEN TRIM(s1.F140033) = '05' THEN '核销'
            WHEN s1.F140033 LIKE '00-%' THEN CONCAT('其他-', REPLACE(s1.F140033, '00-', ''))
            ELSE s1.F140033
        END AS PJZT,

        /* 21 采集日期：票据转贴现协议.采集日期 -> T_6_14.F140035；DATE → YYYYMMDD */
        CASE
            WHEN s1.F140035 IS NOT NULL THEN REPLACE(CAST(s1.F140035 AS CHAR), '-', '')
            ELSE NULL
        END AS CJRQ,

        /* 22 归属分支机构：DDL 存在，业务需求映射表未给来源，置 NULL */
        NULL AS GSFZJG,

        /* 23 信贷借据号：票据转贴现协议.借据ID -> T_6_14.F140037；直接映射 */
        s1.F140037 AS XDJJH,

        /* 24 币种：票据转贴现协议.协议币种 -> T_6_14.F140005；直接映射 */
        s1.F140005 AS BZ,

        /* 25 票据出票日期：票据转贴现协议.票据签发日期 -> T_6_14.F140007；DATE → YYYYMMDD */
        CASE
            WHEN s1.F140007 IS NOT NULL THEN REPLACE(CAST(s1.F140007 AS CHAR), '-', '')
            ELSE NULL
        END AS PJCPRQ,

        /* 26 票据到期日期：票据转贴现协议.票据到期日期 -> T_6_14.F140008；DATE → YYYYMMDD */
        CASE
            WHEN s1.F140008 IS NOT NULL THEN REPLACE(CAST(s1.F140008 AS CHAR), '-', '')
            ELSE NULL
        END AS PJDQRQ,

        /* 27 承兑人名称：票据转贴现协议.承兑人名称 -> T_6_14.F140010；直接映射 */
        s1.F140010 AS CDRMC,

        /* 28 转贴现类别：票据转贴现协议.转贴现类型 -> T_6_14.F140014；码值转换 */
        CASE
            WHEN TRIM(s1.F140014) = '01' THEN '转贴现买断'
            WHEN TRIM(s1.F140014) = '02' THEN '转贴现卖断'
            WHEN TRIM(s1.F140014) = '03' THEN '质押式回购正回购'
            WHEN TRIM(s1.F140014) = '04' THEN '质押式回购逆回购'
            WHEN TRIM(s1.F140014) = '05' THEN '买断式回购正回购'
            WHEN TRIM(s1.F140014) = '06' THEN '买断式回购逆回购'
            WHEN TRIM(s1.F140014) = '07' THEN '再贴现'
            ELSE ''
        END AS ZTXLB,

        /* 29 转贴现计息天数：票据转贴现协议.转贴现计息天数 -> T_6_14.F140019；直接映射 */
        CAST(NULLIF(TRIM(s1.F140019), '') AS INT) AS ZTXJXTS,

        /* 30 回购日期：票据转贴现协议.回购日期 -> T_6_14.F140022；DATE → YYYYMMDD */
        CASE
            WHEN s1.F140022 IS NOT NULL THEN REPLACE(CAST(s1.F140022 AS CHAR), '-', '')
            ELSE NULL
        END AS HGRQ,

        /* 31 回购金额：票据转贴现协议.回购金额 -> T_6_14.F140023；CAST DECIMAL(20,2) */
        CAST(NULLIF(TRIM(s1.F140023), '') AS DECIMAL(20,2)) AS HGJE,

        /* 32 回购利息：票据转贴现协议.回购利息 -> T_6_14.F140025；CAST DECIMAL(20,2) */
        CAST(NULLIF(TRIM(s1.F140025), '') AS DECIMAL(20,2)) AS HGLX,

        /* 33 交易对手行号：票据转贴现协议.交易对手账号行号 -> T_6_14.F140027；直接映射 */
        s1.F140027 AS JYDSHH

    FROM T_6_14 s1
    LEFT JOIN T_1_1 s1_org
           ON SUBSTR(TRIM(s1.F140002), 12) = TRIM(s1_org.A010001)
    WHERE s1.F140035 = V_DATA_DATE
      /* TODO: 表级规则要求"剔除上月状态为失效的数据"，终态纳入和排除条件待需求方确认；
         当前仅按采集日期过滤当月数据。 */;

    COMMIT;

END;
CALL PROC_EAST_IE_005_509_PJZTXB('20260430');
