/*
业务目标：
- 依据原始业务需求《019_个人存款分户账明细记录.md》生成 EAST5.0 个人存款分户账明细记录（IE_004_404_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/019_个人存款分户账明细记录.md
- 原始材料/表结构/一表通系统/T_7_1-客户存款账户交易-DDL-2026-04-27.sql
- 原始材料/表结构/EAST5.0系统/IE_004_403-个人存款分户账-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_402-内部科目对照表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_001_101-机构信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_201-个人基础信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_404_INC-个人存款分户账明细记录-DDL-2026-04-28.sql

源表：
- T_7_1：客户存款账户交易，主表。
- IE_004_403：EAST 个人存款分户账，内关联，用于限定个人存款账户并补账户名称。
- IE_001_101：EAST 机构信息表，左关联，用于金融许可证号和银行机构名称。
- IE_004_402：EAST 内部科目对照表，左关联，用于明细科目名称。
- IE_002_201：EAST 个人基础信息表，左关联，用于证件类别和证件号码。

目标表：
- IE_004_404_INC：个人存款分户账明细记录。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量表按采集日期重跑；先删除目标表同一采集日期数据，再插入采集日期等于跑批日的交易记录。

关键口径：
- 客户存款账户交易必须内关联 `IE_004_403`，按分户账号、币种、转换后的钞汇类别匹配，确保只报个人存款账户交易。
- 机构、内部科目和个人基础信息均使用 EAST 当期结果表补充。
- 交易类型、借贷标志、冲补抹、现转标志、交易渠道按业务需求码值转换。

未确认点：
- 业务需求要求“上一采集日至采集日期间新增”，当前源表仅提供采集日期字段，本草案按 `T_7_1.G010032 = P_DATA_DATE` 实现；如有交易入库时间或上一批次参数，应补充增量边界。
- 需求要求排除查询交易，但业务需求未给出查询交易码值；当前未额外排除，待补查询码值后增加过滤。
- 目标 DDL 字段 DFKHLB、DBRKHLB、GSFZJG、SENSITIVEFLAG 在本业务需求未给出来源，保留 NULL。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_404_INC_GRCKFHZMX;

CREATE PROCEDURE PROC_EAST_IE_004_404_INC_GRCKFHZMX(
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

    DELETE FROM IE_004_404_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_404_INC (
        JYLX,
        SENSITIVEFLAG,
        YHJGMC,
        ZHMC,
        GRCKZH,
        JYJDBZ,
        HXJYSJ,
        DFKHLB,
        DFXM,
        DBRXM,
        DBRZJHM,
        JYGYH,
        CJRQ,
        JRXKZH,
        YWBLJGH,
        DFHM,
        MXKMBH,
        MXKMMC,
        KHTYBH,
        ZJLB,
        ZJHM,
        WBZH,
        HXJYRQ,
        BZ,
        JYJE,
        ZHYE,
        DFZH,
        DFXH,
        ZY,
        FY,
        CBMBZ,
        XZBZ,
        JYQD,
        IPDZ,
        MACDZ,
        DBRZJLB,
        SQGYH,
        BBZ,
        DBRKHLB,
        JYXLH,
        NBJGH,
        GSFZJG
    )
    SELECT
        /* 交易类型 */
        CASE
            WHEN src.G010010 = '01' THEN '转账'
            WHEN src.G010010 = '02' THEN '取现'
            WHEN src.G010010 = '03' THEN '存现'
            WHEN src.G010010 = '04' THEN '消费'
            WHEN src.G010010 = '05' THEN '代发'
            WHEN src.G010010 = '06' THEN '代扣'
            WHEN src.G010010 = '07' THEN '代缴'
            WHEN src.G010010 = '08' THEN '结息'
            WHEN src.G010010 = '09' THEN '批量交易'
            WHEN src.G010010 = '10' THEN '贷款发放'
            WHEN src.G010010 = '11' THEN '贷款还本'
            WHEN src.G010010 = '12' THEN '贷款还息'
            WHEN src.G010010 = '13' THEN '银证业务'
            WHEN src.G010010 = '14' THEN '投资理财'
            WHEN src.G010010 LIKE '00%' THEN REPLACE(src.G010010, '00', '其他')
            ELSE src.G010010
        END AS JYLX,
        /* 涉密标志：业务需求未提供来源 */
        NULL AS SENSITIVEFLAG,
        /* 银行机构名称 */
        org.YHJGMC AS YHJGMC,
        /* 账户名称 */
        acct.ZHMC AS ZHMC,
        /* 个人存款账号 */
        src.G010002 AS GRCKZH,
        /* 交易借贷标志 */
        CASE
            WHEN src.G010014 = '01' THEN '借'
            WHEN src.G010014 = '02' THEN '贷'
            ELSE src.G010014
        END AS JYJDBZ,
        /* 核心交易时间：HH:MM:SS 转 HHMMSS */
        REPLACE(CAST(src.G010006 AS VARCHAR(8)), ':', '') AS HXJYSJ,
        /* 对方客户类别：业务需求未提供来源 */
        NULL AS DFKHLB,
        /* 对方行名 */
        src.G010018 AS DFXM,
        /* 代办人姓名 */
        src.G010026 AS DBRXM,
        /* 代办人证件号码 */
        src.G010028 AS DBRZJHM,
        /* 交易柜员号：“自动”转空 */
        CASE WHEN src.G010029 = '自动' THEN NULL ELSE src.G010029 END AS JYGYH,
        /* 采集日期 */
        P_DATA_DATE AS CJRQ,
        /* 金融许可证号 */
        org.JRXKZH AS JRXKZH,
        /* 业务办理机构号 */
        SUBSTR(TRIM(src.G010004), 12) AS YWBLJGH,
        /* 对方户名 */
        src.G010016 AS DFHM,
        /* 明细科目编号 */
        src.G010011 AS MXKMBH,
        /* 明细科目名称 */
        subj.KJKMMC AS MXKMMC,
        /* 客户统一编号 */
        src.G010003 AS KHTYBH,
        /* 证件类别 */
        per.ZJLB AS ZJLB,
        /* 证件号码 */
        per.ZJHM AS ZJHM,
        /* 外部账号 */
        src.G010025 AS WBZH,
        /* 核心交易日期 */
        CASE WHEN src.G010005 IS NULL THEN NULL ELSE CONCAT(CAST(YEAR(src.G010005) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G010005) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G010005) AS VARCHAR(2)), 2, '0')) END AS HXJYRQ,
        /* 币种 */
        src.G010009 AS BZ,
        /* 交易金额 */
        CAST(NULLIF(TRIM(src.G010007), '') AS DECIMAL(20,2)) AS JYJE,
        /* 账户余额 */
        CAST(NULLIF(TRIM(src.G010008), '') AS DECIMAL(20,2)) AS ZHYE,
        /* 对方账号 */
        src.G010015 AS DFZH,
        /* 对方行号 */
        src.G010017 AS DFXH,
        /* 摘要 */
        src.G010019 AS ZY,
        /* 附言 */
        src.G010031 AS FY,
        /* 冲补抹标志 */
        CASE
            WHEN src.G010020 = '01' THEN '正常'
            WHEN src.G010020 = '02' THEN '冲补抹'
            ELSE src.G010020
        END AS CBMBZ,
        /* 现转标志 */
        CASE
            WHEN src.G010013 = '01' THEN '现'
            WHEN src.G010013 = '02' THEN '转'
            ELSE src.G010013
        END AS XZBZ,
        /* 交易渠道 */
        CASE
            WHEN src.G010021 = '01' THEN '柜面'
            WHEN src.G010021 = '02' THEN 'ATM'
            WHEN src.G010021 = '03' THEN 'VTM'
            WHEN src.G010021 = '04' THEN 'POS'
            WHEN src.G010021 = '05' THEN '网银'
            WHEN src.G010021 = '06' THEN '手机银行'
            WHEN src.G010021 LIKE '07%' THEN REPLACE(src.G010021, '07', '第三方支付')
            WHEN src.G010021 = '08' THEN '银联交易'
            WHEN src.G010021 LIKE '00%' THEN REPLACE(src.G010021, '00', '其他')
            ELSE src.G010021
        END AS JYQD,
        /* IP地址 */
        src.G010023 AS IPDZ,
        /* MAC地址 */
        src.G010024 AS MACDZ,
        /* 代办人证件类别 */
        src.G010027 AS DBRZJLB,
        /* 授权柜员号：“自动”转空 */
        CASE WHEN src.G010030 = '自动' THEN NULL ELSE src.G010030 END AS SQGYH,
        /* 备注 */
        src.G010034 AS BBZ,
        /* 代办人客户类别：业务需求未提供来源 */
        NULL AS DBRKHLB,
        /* 交易序列号 */
        src.G010001 AS JYXLH,
        /* 内部机构号 */
        SUBSTR(TRIM(src.G010035), 12) AS NBJGH,
        /* 归属分支机构：业务需求未提供来源 */
        NULL AS GSFZJG
    FROM T_7_1 src
    INNER JOIN IE_004_403 acct
            ON src.G010002 = acct.GRCKZH
           AND src.G010009 = acct.BZ
           AND CASE
                   WHEN src.G010009 = 'CNY' THEN '人民币'
                   WHEN src.G010033 = '01' THEN '钞'
                   WHEN src.G010033 = '02' THEN '汇'
                   WHEN src.G010033 = '03' THEN '可钞可汇'
                   WHEN src.G010033 LIKE '00%' THEN REPLACE(src.G010033, '00', '其他')
                   ELSE src.G010033
               END = acct.CHLB
           AND acct.CJRQ = P_DATA_DATE
    LEFT JOIN IE_001_101 org
           ON SUBSTR(TRIM(src.G010035), 12) = org.NBJGH
          AND org.CJRQ = P_DATA_DATE
    LEFT JOIN IE_004_402 subj
           ON src.G010011 = subj.KJKMBH
          AND subj.CJRQ = P_DATA_DATE
    LEFT JOIN IE_002_201 per
           ON src.G010003 = per.KHTYBH
          AND per.CJRQ = P_DATA_DATE
    WHERE src.G010032 = V_DATA_DATE;

    COMMIT;
END;
