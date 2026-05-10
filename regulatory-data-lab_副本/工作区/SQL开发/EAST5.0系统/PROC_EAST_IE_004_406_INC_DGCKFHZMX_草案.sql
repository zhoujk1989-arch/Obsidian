/*
业务目标：
- 依据原始业务需求《021_对公存款分户账明细记录.md》生成 EAST5.0 对公存款分户账明细记录（IE_004_406_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/021_对公存款分户账明细记录.md
- 原始材料/表结构/EAST5.0系统/IE_004_406_INC-对公存款分户账明细记录-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_405-对公存款分户账-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_001_101-机构信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_402-内部科目对照表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_7_1-客户存款账户交易-DDL-2026-04-27.sql

源表：
- T_7_1：客户存款账户交易，主表。
- IE_004_405：EAST 对公存款分户账，内关联，用于限定对公存款账户并补账户名称、涉密标志、归属分支机构。
- IE_001_101：EAST 机构信息表，左关联，用于金融许可证号和银行机构名称。
- IE_004_402：EAST 内部科目对照表，左关联，用于明细科目名称。

目标表：
- IE_004_406_INC：对公存款分户账明细记录。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量表按采集日期重跑；先删除目标表同一采集日期数据，再插入采集日期等于跑批日的交易记录。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 除计息、扣利息税外，所有影响对公存款账户余额变动的交易信息，包括结息交易，不包括查询交易。

关键口径：
- 客户存款账户交易必须内关联 IE_004_405，按分户账号、币种、转换后的钞汇类别匹配，确保只报对公存款账户交易。
- 机构、内部科目使用 EAST 当期结果表补充。
- 交易类型、借贷标志、冲补抹、现转标志、交易渠道按业务需求码值转换。
- 核心交易日期格式由 YYYY-MM-DD 转换为 YYYYMMDD。
- 核心交易时间格式由 HH:MM:SS 转换为 HHMMSS。
- 交易金额、账户余额由字符串转换为 DECIMAL(20,2)。

未确认点：
- 业务需求要求排除查询交易，但业务需求未给出查询交易码值；当前未额外排除，待补查询码值后增加过滤。
- 业务需求要求排除计息、扣利息税交易，但一表通交易类型码值中无单独计息/利息税码值（结息为'08'，业务需求明确包含），当前未额外排除，待确认。
- 目标 DDL 字段 DFKHLB（对方客户类别）在本业务需求未给出来源，保留 NULL。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_406_INC_DGCKFHZMX;

CREATE PROCEDURE PROC_EAST_IE_004_406_INC_DGCKFHZMX(
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

    DELETE FROM IE_004_406_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_406_INC (
        JYXLH,
        JRXKZH,
        NBJGH,
        YWBLJGH,
        YHJGMC,
        MXKMBH,
        MXKMMC,
        KHTYBH,
        ZHMC,
        DGCKZH,
        WBZH,
        JYLX,
        JYJDBZ,
        HXJYRQ,
        HXJYSJ,
        BZ,
        JYJE,
        ZHYE,
        DFZH,
        DFHM,
        DFXH,
        DFXM,
        ZY,
        FY,
        CBMBZ,
        XZBZ,
        JYQD,
        IPDZ,
        MACDZ,
        JYGYH,
        SQGYH,
        BBZ,
        CJRQ,
        SENSITIVEFLAG,
        GSFZJG,
        DFKHLB
    )
    SELECT
        /* 1. 交易序列号：直接映射 */
        src.G010001 AS JYXLH,
        /* 2. 金融许可证号：EAST.机构信息表 */
        org.JRXKZH AS JRXKZH,
        /* 3. 内部机构号：SUBSTR(入账机构ID, 12) */
        SUBSTR(TRIM(src.G010035), 12) AS NBJGH,
        /* 4. 业务办理机构号：SUBSTR(交易机构ID, 12) */
        SUBSTR(TRIM(src.G010004), 12) AS YWBLJGH,
        /* 5. 银行机构名称：EAST.机构信息表 */
        org.YHJGMC AS YHJGMC,
        /* 6. 明细科目编号：COALESCE(科目ID, 对公存款分户账.明细科目编号) */
        COALESCE(src.G010011, acct.MXKMBH) AS MXKMBH,
        /* 7. 明细科目名称：EAST.内部科目对照表 */
        subj.KJKMMC AS MXKMMC,
        /* 8. 客户统一编号：直接映射 */
        src.G010003 AS KHTYBH,
        /* 9. 账户名称：EAST.对公存款分户账 */
        acct.ZHMC AS ZHMC,
        /* 10. 对公存款账号：直接映射 */
        src.G010002 AS DGCKZH,
        /* 11. 外部账号：直接映射 */
        src.G010025 AS WBZH,
        /* 12. 交易类型：码值转换（依据业务需求第12条） */
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
            WHEN src.G010010 = '00' THEN '其他'
            WHEN src.G010010 LIKE '00%' THEN CONCAT('其他-', SUBSTR(src.G010010, 3))
            ELSE NULL
        END AS JYLX,
        /* 13. 交易借贷标志：码值转换（依据业务需求第13条） */
        CASE
            WHEN src.G010014 = '01' THEN '借'
            WHEN src.G010014 = '02' THEN '贷'
            ELSE NULL
        END AS JYJDBZ,
        /* 14. 核心交易日期：YYYY-MM-DD -> YYYYMMDD（依据业务需求第14条） */
        TO_CHAR(src.G010005, 'YYYYMMDD') AS HXJYRQ,
        /* 15. 核心交易时间：HH:MM:SS -> HHMMSS（依据业务需求第15条） */
        CASE WHEN src.G010006 IS NULL THEN NULL
             ELSE REPLACE(CAST(src.G010006 AS VARCHAR(8)), ':', '')
        END AS HXJYSJ,
        /* 16. 币种：直接映射（依据业务需求第16条） */
        src.G010009 AS BZ,
        /* 17. 交易金额：DECIMAL(20,2)（依据业务需求第17条） */
        CAST(NULLIF(TRIM(src.G010007), '') AS DECIMAL(20,2)) AS JYJE,
        /* 18. 账户余额：DECIMAL(20,2)（依据业务需求第18条） */
        CAST(NULLIF(TRIM(src.G010008), '') AS DECIMAL(20,2)) AS ZHYE,
        /* 19. 对方账号：直接映射（依据业务需求第19条） */
        src.G010015 AS DFZH,
        /* 20. 对方户名：直接映射（依据业务需求第20条） */
        src.G010016 AS DFHM,
        /* 21. 对方行号：直接映射（依据业务需求第21条） */
        src.G010017 AS DFXH,
        /* 22. 对方行名：直接映射（依据业务需求第22条） */
        src.G010018 AS DFXM,
        /* 23. 摘要：直接映射（依据业务需求第23条） */
        src.G010019 AS ZY,
        /* 24. 附言：直接映射（依据业务需求第24条） */
        src.G010031 AS FY,
        /* 25. 冲补抹标志：码值转换（依据业务需求第25条） */
        CASE
            WHEN src.G010020 = '01' THEN '正常'
            WHEN src.G010020 = '02' THEN '冲补抹'
            ELSE ''
        END AS CBMBZ,
        /* 26. 现转标志：码值转换（依据业务需求第26条） */
        CASE
            WHEN src.G010013 = '01' THEN '现'
            WHEN src.G010013 = '02' THEN '转'
            ELSE ''
        END AS XZBZ,
        /* 27. 交易渠道：码值转换（依据业务需求第27条） */
        CASE
            WHEN src.G010021 = '01' THEN '柜面'
            WHEN src.G010021 = '02' THEN 'ATM'
            WHEN src.G010021 = '03' THEN 'VTM'
            WHEN src.G010021 = '04' THEN 'POS'
            WHEN src.G010021 = '05' THEN '网银'
            WHEN src.G010021 = '06' THEN '手机银行'
            WHEN src.G010021 = '07' THEN '第三方支付'
            WHEN src.G010021 LIKE '07%' THEN CONCAT('第三方支付-', SUBSTR(src.G010021, 3))
            WHEN src.G010021 = '08' THEN '银联交易'
            WHEN src.G010021 = '00' THEN '其他'
            WHEN src.G010021 LIKE '00%' THEN CONCAT('其他-', SUBSTR(src.G010021, 3))
            ELSE NULL
        END AS JYQD,
        /* 28. IP地址：直接映射（依据业务需求第28条） */
        src.G010023 AS IPDZ,
        /* 29. MAC地址：直接映射（依据业务需求第29条） */
        src.G010024 AS MACDZ,
        /* 30. 交易柜员号：'自动' -> ''（依据业务需求第30条） */
        CASE WHEN src.G010029 = '自动' THEN '' ELSE src.G010029 END AS JYGYH,
        /* 31. 授权柜员号：'自动' -> ''（依据业务需求第31条） */
        CASE WHEN src.G010030 = '自动' THEN '' ELSE src.G010030 END AS SQGYH,
        /* 32. 备注：直接映射（依据业务需求第32条） */
        src.G010034 AS BBZ,
        /* 33. 采集日期：参数（依据业务需求第33条） */
        P_DATA_DATE AS CJRQ,
        /* 涉密标志：业务需求未提供来源，置NULL */
        NULL AS SENSITIVEFLAG,
        /* 归属分支机构：业务需求未提供来源，置NULL */
        NULL AS GSFZJG,
        /* 对方客户类别：业务需求未给来源，固定 NULL（DDL存在，业务需求未给来源） */
        NULL AS DFKHLB
    FROM T_7_1 src
    /* 内关联：EAST.对公存款分户账，限定对公账户并补账户名称、涉密标志、归属分支机构 */
    INNER JOIN IE_004_405 acct
            ON src.G010002 = acct.DGCKZH
           AND src.G010009 = acct.BZ
           AND CASE
                   WHEN src.G010009 = 'CNY' THEN '人民币'
                   WHEN src.G010033 = '01' THEN '钞'
                   WHEN src.G010033 = '02' THEN '汇'
                   WHEN src.G010033 = '03' THEN '可钞可汇'
                   ELSE src.G010033
               END = acct.CHLB
           AND acct.CJRQ = P_DATA_DATE
    /* 左关联：EAST.机构信息表，获取金融许可证号和银行机构名称 */
    LEFT JOIN IE_001_101 org
            ON SUBSTR(TRIM(src.G010035), 12) = org.NBJGH
           AND org.CJRQ = P_DATA_DATE
    /* 左关联：EAST.内部科目对照表，获取明细科目名称 */
    LEFT JOIN IE_004_402 subj
            ON src.G010011 = subj.KJKMBH
           AND subj.CJRQ = P_DATA_DATE
    WHERE src.G010032 = V_DATA_DATE;

    COMMIT;
END;
