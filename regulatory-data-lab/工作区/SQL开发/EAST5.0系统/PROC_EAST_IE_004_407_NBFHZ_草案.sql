/*
业务目标：
- 依据原始业务需求《022_内部分户账.md》生成 EAST5.0 内部分户账（IE_004_407）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/022_内部分户账.md
- 原始材料/表结构/EAST5.0系统/IE_004_407-内部分户账-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_4_3-分户账信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_4_2-科目信息-DDL-2026-04-27.sql

源表：
- T_4_3（分户账信息）：主源表，提供 18 个字段。
- T_1_1（机构信息）：左关联，提供金融许可证号、银行机构名称。
- T_4_2（科目信息）：左关联，提供明细科目名称。

目标表：
- IE_004_407：内部分户账。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 根据会计核算科目，除单列账之外的科目原则上都归入内部账采集；单列账报送至信用卡、对公/个人等分户账中；资本账户需要报送。以内部分户账号为最小颗粒报送，如账户注销或终结，在报送该账户最终状态后的次月可不再报送。交易与核算分离的机构，应根据总账科目中划分出对应内部分户账性质的科目，自定义内部分户账号进行报送。

表级取数与关联规则（依据《022_内部分户账.md》第 2.1 节）：
- 主表：【分户账信息】(T_4_3)
- 左关联：【机构信息】(T_1_1)，关联条件：T_4_3.机构ID 从第12位截取 = T_1_1.内部机构号(A010002)
- 左关联：【科目信息】(T_4_2)，关联条件：T_4_3.科目ID(D030008) = T_4_2.科目ID(D020001)
- 过滤条件：
  1) 分户账类型(D030005) = '03'
  2) 账户状态(D030013) != '03'(销户) OR (账户状态 = '03' AND 销户日期(D030012) 在采集当月)

采集日期过滤：
- T_4_3.D030015（采集日期）= V_DATA_DATE，确保只取当采集日数据。

终态纳入规则：
- 账户状态 != '03'(销户)：正常纳入。
- 账户状态 = '03'(销户) 且 销户日期(D030012) 在采集当月：纳入。
- 账户状态 = '03'(销户) 且 销户日期不在采集当月：排除。

未确认点：
- GSFZJG（归属分支机构）和 SENSITIVEFLAG（涉密标志）为本地 DDL 字段，业务需求映射表未给来源，SQL 中置 NULL，符合审计处置原则。
- 利率字段来源为 T_4_3.D030017（内部账利率），原始数据格式 20n(6)，目标 DDL 类型为 DECIMAL(20,6)。
- 余额字段（D030018/D030019）原始格式为 varchar(255)，存储前需 CAST 为 DECIMAL(20,2)。
- 码值转换（账户状态、计息方式、计息标志、借贷标志）按业务需求文档第 3 节逐项 CASE 实现。
- 备注（BBZ）拼接三表备注，以英文分号 ';' 分隔。
- 本草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_407_NBFHZ;

CREATE PROCEDURE PROC_EAST_IE_004_407_NBFHZ(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_MONTH_START DATE;
    DECLARE V_MONTH_END DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);
    SET V_MONTH_START = DATE_FORMAT(V_DATA_DATE, '%Y-%m-01');
    SET V_MONTH_END = LAST_DAY(V_DATA_DATE);

    START TRANSACTION;

    -- 清理区：删除目标表同一采集日期数据，保证重跑幂等
    DELETE FROM IE_004_407
     WHERE CJRQ = P_DATA_DATE;

    -- 主加工区：从 T_4_3 分户账信息取数，左关联 T_1_1 机构信息和 T_4_2 科目信息
    INSERT INTO IE_004_407 (
        BBZ,
        GSFZJG,
        JXFS,
        JXBZ,
        JDBZ,
        NBFHZZH,
        MXKMBH,
        NBJGH,
        ZHMC,
        BZ,
        DFYE,
        MXKMMC,
        YHJGMC,
        JRXKZH,
        JFYE,
        SENSITIVEFLAG,
        CJRQ,
        ZHZT,
        KHRQ,
        LL,
        XHRQ
    )
    SELECT
        /* BBZ 备注：拼接 T_4_3.备注(D030014)、T_1_1.备注(A020026)、T_4_2.备注(D02010)，非空时以英文分号 ';' 分隔 */
        CONCAT_WS(
            ';',
            src.D030014,
            s1.A010026,
            s2.D020010
        ) AS BBZ,

        /* GSFZJG 归属分支机构：本地 DDL 存在，业务需求映射表未给来源，置 NULL */
        NULL AS GSFZJG,

        /* JXFS 计息方式：T_4_3.D030007 码值转换 */
        CASE TRIM(src.D030007)
            WHEN '01' THEN '按月结息'
            WHEN '02' THEN '按季结息'
            WHEN '03' THEN '按半年结息'
            WHEN '04' THEN '按年结息'
            WHEN '05' THEN '不定期结息'
            WHEN '06' THEN '不记利息'
            WHEN '07' THEN '利随本清'
            WHEN '00' THEN CONCAT('其他-', IFNULL(TRIM(SUBSTR(src.D030007, 3)), ''))
            ELSE src.D030007
        END AS JXFS,

        /* JXBZ 计息标志：T_4_3.D030006 码值转换，1-是，0-否 */
        CASE TRIM(src.D030006)
            WHEN '1' THEN '是'
            WHEN '0' THEN '否'
            ELSE ''
        END AS JXBZ,

        /* JDBZ 借贷标志：T_4_3.D030010 码值转换，01-借，02-贷，03-借贷并列 */
        CASE TRIM(src.D030010)
            WHEN '01' THEN '借'
            WHEN '02' THEN '贷'
            WHEN '03' THEN '借贷并列'
            ELSE ''
        END AS JDBZ,

        /* NBFHZZH 内部分户账账号：T_4_3.D030002 直接映射 */
        src.D030002 AS NBFHZZH,

        /* MXKMBH 明细科目编号：T_4_3.D030008 直接映射 */
        src.D030008 AS MXKMBH,

        /* NBJGH 内部机构号：T_4_3.D030001 从第12位开始截取 */
        SUBSTR(TRIM(src.D030001), 12) AS NBJGH,

        /* ZHMC 账户名称：T_4_3.D030004 直接映射 */
        src.D030004 AS ZHMC,

        /* BZ 币种：T_4_3.D030009 直接映射 */
        src.D030009 AS BZ,

        /* DFYE 贷方余额：T_4_3.D030019 CAST 为 DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.D030019), '') AS DECIMAL(20,2)) AS DFYE,

        /* MXKMMC 明细科目名称：T_4_2.D020003 科目名称 */
        s2.D020003 AS MXKMMC,

        /* YHJGMC 银行机构名称：T_1_1.A010005 */
        s1.A010005 AS YHJGMC,

        /* JRXKZH 金融许可证号：T_1_1.A010003 */
        s1.A010003 AS JRXKZH,

        /* JFYE 借方余额：T_4_3.D030018 CAST 为 DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.D030018), '') AS DECIMAL(20,2)) AS JFYE,

        /* SENSITIVEFLAG 涉密标志：本地 DDL 存在，业务需求映射表未给来源，置 NULL */
        NULL AS SENSITIVEFLAG,

        /* CJRQ 采集日期：参数 P_DATA_DATE */
        P_DATA_DATE AS CJRQ,

        /* ZHZT 账户状态：T_4_3.D030013 码值转换，01-正常，02-预销户，03-销户，04-冻结，05-止付 */
        CASE TRIM(src.D030013)
            WHEN '01' THEN '正常'
            WHEN '02' THEN '预销户'
            WHEN '03' THEN '销户'
            WHEN '04' THEN '冻结'
            WHEN '05' THEN '止付'
            WHEN '00' THEN CONCAT('其他-', IFNULL(TRIM(SUBSTR(src.D030013, 3)), ''))
            ELSE src.D030013
        END AS ZHZT,

        /* KHRQ 开户日期：T_4_3.D030011 格式由 YYYY-MM-DD 转 YYYYMMDD，空值转 '99991231' */
        CASE
            WHEN src.D030011 IS NULL OR TRIM(src.D030011) = '' THEN '99991231'
            ELSE REPLACE(DATE_FORMAT(src.D030011, '%Y%m%d'), '-', '')
        END AS KHRQ,

        /* LL 利率：T_4_3.D030017（内部账利率）CAST 为 DECIMAL(20,6) */
        CAST(NULLIF(TRIM(src.D030017), '') AS DECIMAL(20,6)) AS LL,

        /* XHRQ 销户日期：T_4_3.D030012 格式由 YYYY-MM-DD 转 YYYYMMDD，空值转 '99991231' */
        CASE
            WHEN src.D030012 IS NULL OR TRIM(src.D030012) = '' THEN '99991231'
            ELSE REPLACE(DATE_FORMAT(src.D030012, '%Y%m%d'), '-', '')
        END AS XHRQ

    FROM T_4_3 src
    LEFT JOIN T_1_1 s1
           ON SUBSTR(TRIM(src.D030001), 12) = TRIM(s1.A010002)
           AND s1.A010020 = V_DATA_DATE
    LEFT JOIN T_4_2 s2
           ON src.D030008 = s2.D020001
           AND s2.D020011 = V_DATA_DATE
    WHERE 1 = 1
      /* 分户账类型必须为 '03'（内部分户账） */
      AND TRIM(src.D030005) = '03'
      /* 采集日期过滤：只取当采集日数据 */
      AND src.D030015 = V_DATA_DATE
      /* 账户状态过滤：
       * 1) 账户状态 != '03'(销户)：正常纳入
       * 2) 账户状态 = '03'(销户) 且 销户日期在采集当月：纳入终态数据
       * 3) 账户状态 = '03'(销户) 且 销户日期不在采集当月：排除
       */
      AND (
          TRIM(src.D030013) != '03'
          OR (
              TRIM(src.D030013) = '03'
              AND src.D030012 >= V_MONTH_START
              AND src.D030012 <= V_MONTH_END
          )
      );

    COMMIT;

END;

CALL PROC_EAST_IE_004_407_NBFHZ('20260501');
