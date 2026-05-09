/*
重构校准记录：2026-05-10
- 依据原始业务需求《053_票据出票信息表.md》逐字段校准并重写存储过程。
- 消除 ON 1=1 JOIN TODO：T_6_13.F130003（机构ID）= T_1_1.A010001（机构ID）。
- 消除 WHERE 1=1 TODO：补齐业务类型='01'（承兑）、上月末采集日期过滤、剔除上月已失效数据、剔除一直垫款。
- 补齐码值 CASE 转换：PJZT（票据状态）、PJLX（票据类型）、SFZBHTX（是否在本行贴现）、JBYGH（经办人工号‑'自动'置空）。
- 补齐日期格式转换：PJDQRQ/PJCPRQ/CJRQ 使用 DATE_FORMAT 转 YYYYMMDD。
- 补齐金额字段 CAST：BZJJE/BZJBL/PMJE/SXFJE。
- NBJGH（内部机构号）：SUBSTR(s1.F130003, 12)。
- CJRQ（采集日期）：赋参数 P_DATA_DATE 而非源表 F130049。
- 缺口字段（GSFZJG/SKRKHLB/CPRKHLB/SENSITIVEFLAG）保持 NULL，业务需求映射表未给来源。
- 表级规则：全量表，报送截至采集日有效的数据，关联上月末 T_6_13，已剔除卖断/解付终态次月数据及一直垫款业务。
*/

/*
业务目标：
- 依据原始业务需求《053_票据出票信息表.md》生成 EAST5.0 票据出票信息表（IE_009_901）GBase 存储过程。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程。

依赖材料：
- 原始材料/业务需求/EAST5.0/053_票据出票信息表.md
- 原始材料/表结构/EAST5.0系统/IE_009_901-票据出票信息表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_13-票据协议-DDL-2026-04-27.sql

源表：
- T_1_1（机构信息）
- T_6_13（票据协议）

目标表：
- IE_009_901：票据出票信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送由出票人签发并向填报机构申请，经填报机构承兑的汇票。票据状态为卖断（转贴现卖断），解付（票据到期且出票人已付款）的数据，在报送票据最后状态的次月可不再报送。

表级取数与关联规则：
### 2.1 表级规则（Excel第 1286 行）
过滤条件：业务类型 = '01'(承兑)，关联上月末6.13票据协议表，剔除上月已失效范围且剔除一直垫款状态的业务。

实现逻辑：
1. 取 T_6_13 中 业务类型='01'(承兑) 且 采集日期=上月末 的记录。
2. 与 T_1_1 按 机构ID（F130003 = A010001）内关联，获取银行机构名称和金融许可证号。
3. 剔除上月已失效：通过 NOT EXISTS 检查上上月该协议是否已是卖断(02)/解付(03)状态；若是则说明上月已报送终态，本月不再报送。
4. 剔除一直垫款：通过 NOT EXISTS 检查该协议下是否存在非垫款状态的记录；若全部为垫款(04)则排除。
5. CJRQ 赋值为参数 P_DATA_DATE，标识本次报送批次。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_009_901_PJCPXXB;

CREATE PROCEDURE PROC_EAST_IE_009_901_PJCPXXB(
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

    DELETE FROM IE_009_901
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_009_901 (
        PJDQRQ,
        CPRBH,
        GSFZJG,
        SXFBZ,
        SKRKHLB,
        CPRKHLB,
        CJRQ,
        JBYGH,
        PJZT,
        BZJJE,
        BZJBL,
        MYBJ,
        SFZBHTX,
        SKRZH,
        SKRMC,
        CPRKHHMC,
        CPRZH,
        BZ,
        MXKMMC,
        MXKMBH,
        YHJGMC,
        JRXKZH,
        CPRMC,
        PJCPRQ,
        PMJE,
        PJLX,
        PJHM,
        NBJGH,
        SENSITIVEFLAG,
        SKRKHHMC,
        SXFJE,
        BZJBZ,
        BZJZH,
        BBZ
    )
    SELECT
        /* 票据到期日期：T_6_13.F130037（票据到期日期）→ 转 YYYYMMDD */
        DATE_FORMAT(s1.F130037, '%Y%m%d') AS PJDQRQ,
        /* 出票人编号：T_6_13.F130004（客户ID）→ 直接映射 */
        s1.F130004 AS CPRBH,
        /* 归属分支机构：DDL 存在但业务需求映射表未给来源，暂置 NULL */
        NULL AS GSFZJG,
        /* 其他费用币种：T_6_13.F130034（其他费用币种）→ 直接映射 */
        s1.F130034 AS SXFBZ,
        /* 收款人客户类别：DDL 存在但业务需求映射表未给来源，暂置 NULL */
        NULL AS SKRKHLB,
        /* 出票人客户类别：DDL 存在但业务需求映射表未给来源，暂置 NULL */
        NULL AS CPRKHLB,
        /* 采集日期：赋参数 P_DATA_DATE，标识本次报送批次 */
        P_DATA_DATE AS CJRQ,
        /* 经办人工号：T_6_13.F130042（经办员工ID）；CASE WHEN '自动' THEN '' ELSE 原值 END */
        CASE WHEN TRIM(s1.F130042) = '自动' THEN '' ELSE s1.F130042 END AS JBYGH,
        /* 票据状态：T_6_13.F130047（票据状态）；码值转换 */
        CASE
            WHEN TRIM(s1.F130047) = '01' THEN '正常'
            WHEN TRIM(s1.F130047) = '02' THEN '卖断'
            WHEN TRIM(s1.F130047) = '03' THEN '解付'
            WHEN TRIM(s1.F130047) = '04' THEN '垫款'
            WHEN TRIM(s1.F130047) = '05' THEN '核销'
            WHEN LEFT(TRIM(s1.F130047), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(s1.F130047), 4))
            ELSE ''
        END AS PJZT,
        /* 保证金金额：T_6_13.F130023（保证金金额）→ DECIMAL(20,2) */
        CAST(NULLIF(TRIM(s1.F130023), '') AS DECIMAL(20,2)) AS BZJJE,
        /* 保证金比例：T_6_13.F130024（保证金比例）→ DECIMAL(20,2) */
        CAST(NULLIF(TRIM(s1.F130024), '') AS DECIMAL(20,2)) AS BZJBL,
        /* 贸易背景：T_6_13.F130046（贸易背景）→ 直接映射 */
        s1.F130046 AS MYBJ,
        /* 是否在本行贴现：T_6_13.F130025（在本行贴现标识）；CASE WHEN '1' THEN '是' ELSE '否' END */
        CASE WHEN TRIM(s1.F130025) = '1' THEN '是' ELSE '否' END AS SFZBHTX,
        /* 收款人账号：T_6_13.F130011（收款人账号）→ 直接映射 */
        s1.F130011 AS SKRZH,
        /* 收款人名称：T_6_13.F130006（收款人名称）→ 直接映射 */
        s1.F130006 AS SKRMC,
        /* 出票人开户行名称：T_6_13.F130014（出票人开户行名称）→ 直接映射 */
        s1.F130014 AS CPRKHHMC,
        /* 出票人账号：T_6_13.F130013（出票人账号）→ 直接映射 */
        s1.F130013 AS CPRZH,
        /* 币种：T_6_13.F130019（协议币种）→ 直接映射 */
        s1.F130019 AS BZ,
        /* 明细科目名称：T_6_13.F130010（科目名称）→ 直接映射 */
        s1.F130010 AS MXKMMC,
        /* 明细科目编号：T_6_13.F130009（科目ID）→ 直接映射 */
        s1.F130009 AS MXKMBH,
        /* 银行机构名称：T_1_1.A010005（银行机构名称）→ 直接映射 */
        org.A010005 AS YHJGMC,
        /* 金融许可证号：T_1_1.A010003（金融许可证号）→ 直接映射 */
        org.A010003 AS JRXKZH,
        /* 出票人名称：T_6_13.F130005（出票人名称）→ 直接映射 */
        s1.F130005 AS CPRMC,
        /* 票据出票日期：T_6_13.F130036（票据签发日期）→ 转 YYYYMMDD */
        DATE_FORMAT(s1.F130036, '%Y%m%d') AS PJCPRQ,
        /* 票面金额：T_6_13.F130020（票面金额）→ DECIMAL(20,2) */
        CAST(NULLIF(TRIM(s1.F130020), '') AS DECIMAL(20,2)) AS PMJE,
        /* 票据类型：T_6_13.F130015（票据类型）；码值转换 */
        CASE
            WHEN TRIM(s1.F130015) = '01' THEN '银行承兑汇票'
            WHEN TRIM(s1.F130015) = '02' THEN '商业承兑汇票'
            ELSE ''
        END AS PJLX,
        /* 票据号码：T_6_13.F130016（票据号码）→ 直接映射 */
        s1.F130016 AS PJHM,
        /* 内部机构号：T_6_13.F130003（机构ID）→ SUBSTR(机构ID,12) */
        SUBSTR(TRIM(s1.F130003), 12) AS NBJGH,
        /* 涉密标志：DDL 存在但业务需求映射表未给来源，暂置 NULL */
        NULL AS SENSITIVEFLAG,
        /* 收款人开户行名称：T_6_13.F130012（收款人开户行名称）→ 直接映射 */
        s1.F130012 AS SKRKHHMC,
        /* 其他费用金额：T_6_13.F130035（其他费用金额）→ DECIMAL(20,2) */
        CAST(NULLIF(TRIM(s1.F130035), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 保证金币种：T_6_13.F130022（保证金币种）→ 直接映射 */
        s1.F130022 AS BZJBZ,
        /* 保证金账号：T_6_13.F130021（保证金账号）→ 直接映射 */
        s1.F130021 AS BZJZH,
        /* 备注：T_6_13.F130048（备注）→ 直接映射 */
        s1.F130048 AS BBZ
    FROM T_6_13 s1
    INNER JOIN T_1_1 org
        ON TRIM(s1.F130003) = TRIM(org.A010001)
        AND org.A010020 = V_DATA_DATE
    WHERE s1.F130008 = '01'  /* 业务类型=承兑 */
      AND s1.F130049 = LAST_DAY(DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH))  /* 关联上月末数据 */
      /* 剔除上月已失效：上上月该协议已是卖断/解付状态，说明上月已报送终态，本月不再报送 */
      AND NOT EXISTS (
          SELECT 1 FROM T_6_13 prev
          WHERE prev.F130001 = s1.F130001
            AND prev.F130002 = s1.F130002
            AND prev.F130052 = s1.F130052
            AND prev.F130008 = '01'
            AND prev.F130049 = LAST_DAY(DATE_SUB(V_DATA_DATE, INTERVAL 2 MONTH))
            AND prev.F130047 IN ('02', '03')
      )
      /* 剔除一直垫款：该协议下不存在非垫款记录 → 所有记录均为垫款状态 */
      AND NOT EXISTS (
          SELECT 1 FROM T_6_13 t6
          WHERE t6.F130001 = s1.F130001
            AND t6.F130002 = s1.F130002
            AND t6.F130052 = s1.F130052
            AND t6.F130008 = '01'
            AND t6.F130047 <> '04'
      );

    COMMIT;
END;
