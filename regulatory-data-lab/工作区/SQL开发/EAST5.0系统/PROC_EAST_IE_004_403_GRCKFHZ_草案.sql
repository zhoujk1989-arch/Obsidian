/*
业务目标：
- 依据原始业务需求《018_个人存款分户账.md》生成 EAST5.0 个人存款分户账（IE_004_403）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/018_个人存款分户账.md
- 原始材料/表结构/一表通系统/T_6_1-存款协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_4_3-分户账信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_14-存款状态-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_4_2-科目信息-DDL-2026-04-27.sql
- 原始材料/表结构/EAST5.0系统/IE_004_403-个人存款分户账-DDL-2026-04-28.sql

源表：
- T_6_1：存款协议，主表。
- T_4_3：分户账信息，内关联，限定个人分户账类型 `02`。
- T_8_14：存款状态，左关联，取余额、账户状态、上次动户日期。
- T_1_1：机构信息，左关联。
- T_4_2：科目信息，左关联。

目标表：
- IE_004_403：个人存款分户账。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 全量截面重跑；先删除目标表同一采集日期数据，再插入采集日有效或当月销户的个人存款账户。

关键口径：
- 存款协议与分户账信息按分户账号、币种、钞汇类别内关联，且分户账类型为 `02`。
- 账户状态不为销户，或账户状态为销户且销户日期在采集当月的记录纳入。
- 存款状态按协议ID、分户账号、币种、钞汇类别左关联。

未确认点：
- 目标 DDL 字段 ZHLB、GSFZJG、SENSITIVEFLAG 在本业务需求未给出来源，保留 NULL，待补充来源后再加工。
- 账户状态“销户”的现场码值如不为 `03`/`03-销户`/`销户`，需补充码值后调整过滤。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_403_GRCKFHZ;

CREATE PROCEDURE PROC_EAST_IE_004_403_GRCKFHZ(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_MON_START DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);
    SET V_MON_START = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-01') AS DATE);

    START TRANSACTION;

    DELETE FROM IE_004_403
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_403 (
        CJRQ,
        ZHZT,
        SCDHRQ,
        BZ,
        BZJZHBZ,
        GRCKZH,
        KHTYBH,
        MXKMMC,
        MXKMBH,
        NBJGH,
        JRXKZH,
        GSFZJG,
        XHRQ,
        KHGYH,
        KHRQ,
        GRCKZHLX,
        ZHMC,
        YHJGMC,
        CHLB,
        CKYE,
        ZHLB,
        LL,
        SENSITIVEFLAG,
        BBZ
    )
    SELECT
        /* 采集日期：跑批参数 */
        P_DATA_DATE AS CJRQ,
        /* 账户状态 */
        CASE
            WHEN COALESCE(st.H140014, acct.D030013) = '01' THEN '正常'
            WHEN COALESCE(st.H140014, acct.D030013) = '02' THEN '预销户'
            WHEN COALESCE(st.H140014, acct.D030013) = '03' THEN '销户'
            WHEN COALESCE(st.H140014, acct.D030013) = '04' THEN '冻结'
            WHEN COALESCE(st.H140014, acct.D030013) = '05' THEN '止付'
            WHEN COALESCE(st.H140014, acct.D030013) LIKE '00%' THEN REPLACE(COALESCE(st.H140014, acct.D030013), '00', '其他')
            ELSE COALESCE(st.H140014, acct.D030013)
        END AS ZHZT,
        /* 上次动户日期：空值转 99991231 */
        CASE WHEN st.H140016 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(st.H140016) AS VARCHAR(4)), LPAD(CAST(MONTH(st.H140016) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(st.H140016) AS VARCHAR(2)), 2, '0')) END AS SCDHRQ,
        /* 币种：协议币种 */
        src.F010022 AS BZ,
        /* 保证金账户标志 */
        CASE WHEN src.F010016 = '1' THEN '是' ELSE '否' END AS BZJZHBZ,
        /* 个人存款账号 */
        src.F010007 AS GRCKZH,
        /* 客户统一编号 */
        src.F010003 AS KHTYBH,
        /* 明细科目名称 */
        subj.D020003 AS MXKMMC,
        /* 明细科目编号 */
        src.F010005 AS MXKMBH,
        /* 内部机构号 */
        SUBSTR(TRIM(src.F010002), 12) AS NBJGH,
        /* 金融许可证号 */
        org.A010003 AS JRXKZH,
        /* 归属分支机构：业务需求未提供来源 */
        NULL AS GSFZJG,
        /* 销户日期：空值转 99991231 */
        CASE WHEN src.F010024 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.F010024) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F010024) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F010024) AS VARCHAR(2)), 2, '0')) END AS XHRQ,
        /* 开户柜员号：“自动”转空 */
        CASE WHEN src.F010028 = '自动' THEN NULL ELSE src.F010028 END AS KHGYH,
        /* 开户日期：空值转 99991231 */
        CASE WHEN src.F010019 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.F010019) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F010019) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F010019) AS VARCHAR(2)), 2, '0')) END AS KHRQ,
        /* 个人存款账户类型 */
        CASE
            WHEN src.F010048 = '09' THEN '个人活期存款'
            WHEN src.F010048 = '10' THEN '个人定期存款'
            WHEN src.F010048 = '11' THEN '定活两便存款'
            WHEN src.F010048 = '12' THEN '个人通知存款'
            WHEN src.F010048 = '13' THEN '个人协议存款'
            WHEN src.F010048 = '14' THEN '个人协定存款'
            WHEN src.F010048 = '15' THEN '个人保证金存款'
            WHEN src.F010048 = '16' THEN '个人结构性存款（不含保本理财）'
            WHEN src.F010048 = '17' THEN '个人其他存款'
            ELSE src.F010048
        END AS GRCKZHLX,
        /* 账户名称 */
        acct.D030004 AS ZHMC,
        /* 银行机构名称 */
        org.A010005 AS YHJGMC,
        /* 钞汇类别 */
        CASE
            WHEN src.F010022 = 'CNY' THEN '人民币'
            WHEN src.F010023 = '01' THEN '钞'
            WHEN src.F010023 = '02' THEN '汇'
            WHEN src.F010023 = '03' THEN '可钞可汇'
            WHEN src.F010023 LIKE '00%' THEN REPLACE(src.F010023, '00', '其他')
            ELSE src.F010023
        END AS CHLB,
        /* 存款余额 */
        CAST(NULLIF(TRIM(st.H140013), '') AS DECIMAL(20,2)) AS CKYE,
        /* 账户类别：业务需求未提供来源 */
        NULL AS ZHLB,
        /* 利率 */
        CAST(NULLIF(TRIM(src.F010017), '') AS DECIMAL(20,6)) AS LL,
        /* 涉密标志：业务需求未提供来源 */
        NULL AS SENSITIVEFLAG,
        /* 备注：多来源备注拼接 */
        CONCAT_WS(';', NULLIF(src.F010032, ''), NULLIF(st.H140021, ''), NULLIF(acct.D030014, ''), NULLIF(org.A010026, ''), NULLIF(subj.D020010, '')) AS BBZ
    FROM T_6_1 src
    INNER JOIN T_4_3 acct
            ON src.F010007 = acct.D030002
           AND src.F010022 = acct.D030009
           AND src.F010023 = acct.D030016
           AND acct.D030005 = '02'
           AND acct.D030015 = V_DATA_DATE
    LEFT JOIN T_8_14 st
           ON src.F010001 = st.H140018
          AND src.F010007 = st.H140001
          AND src.F010022 = st.H140004
          AND src.F010023 = st.H140017
          AND st.H140015 = V_DATA_DATE
    LEFT JOIN T_1_1 org
           ON src.F010002 = org.A010001
          AND org.A010020 = V_DATA_DATE
    LEFT JOIN T_4_2 subj
           ON src.F010002 = subj.D020002
          AND src.F010005 = subj.D020001
          AND subj.D020011 = V_DATA_DATE
    WHERE src.F010035 = V_DATA_DATE
      AND (
          acct.D030013 IS NULL
          OR acct.D030013 NOT IN ('03', '03-销户', '销户')
          OR (
              acct.D030013 IN ('03', '03-销户', '销户')
              AND acct.D030012 IS NOT NULL
              AND YEAR(acct.D030012) = YEAR(V_DATA_DATE)
              AND MONTH(acct.D030012) = MONTH(V_DATA_DATE)
          )
      );

    COMMIT;
END;
