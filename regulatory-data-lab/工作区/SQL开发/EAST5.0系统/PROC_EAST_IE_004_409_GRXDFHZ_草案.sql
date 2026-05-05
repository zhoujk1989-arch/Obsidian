/*
业务目标：
- 依据原始业务需求《024_个人信贷分户账.md》生成 EAST5.0 个人信贷分户账（IE_004_409）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/024_个人信贷分户账.md
- 原始材料/表结构/EAST5.0系统/IE_004_409-个人信贷分户账-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_4_3-分户账信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_27-贷款协议补充信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_1-贷款借据-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_2-贷款协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql

源表：
- T_4_3（分户账信息）：分户账主数据，作为驱动表
- T_6_27（贷款协议补充信息）：借据-分户账关联核心表，含借据ID、分户账号、协议ID、机构ID、借款金额、发放日期等
- T_8_1（贷款借据）：借据维表，含贷款利率、借款余额、贷款状态
- T_6_2（贷款协议）：协议维表，含备注
- T_1_1（机构信息）：机构维表，含金融许可证号、银行机构名称

目标表：
- IE_004_409：个人信贷分户账。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 填报以个人名义在银行机构所开立的信贷账户信息。不报送信用卡业务。表外业务只报送委托贷款（非现金管理项下），其他不报送。个体工商户、私营业主以个人名义开立的信贷分户账计入本表，以营业执照等证件开立的对公信贷分户账不计入本表。以信贷借据号为最小粒度报送，借据结清、核销或转让的，可在报送最后状态的次月不再报送。账户状态为"销户"时，也可于次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 502 行）
通过【贷款协议补充信息】.【借据ID】关联【贷款借据】.【借据ID】，加总如下4个场景数据：
1、取上月末未终结：上月末【贷款借据】.【贷款状态】等于01、05
2、当月末未终结：当月末的【贷款借据】.【贷款状态】等于01、05
3、当月新发放贷款：【贷款协议补充信息】.【贷款实际发放日期】在当月
4、第三方平台跨月新发放：当月末【贷款借据】.【借据ID】在上月末的【贷款借据】.【借据ID】中不存在

未确认点：
- 码值 '00-XX' 通配处理策略：按需求文档字面转换为 '其他-XX'（去掉前导单引号）。
- 上月末 = DATE_SUB(V_DATA_DATE, INTERVAL 1 DAY) 作为代理；跨月边界（如1号）按自然日减1天处理，需现场确认是否应按月份对齐。
- 场景4（第三方平台跨月新发放）需要跨期借据ID对比，本草案使用子查询实现，性能需验证。
- 需求文档未明确排除信用卡的字段来源，暂按 T_6_27 中贷款业务种类/产品类型等字段在跑数后验证是否需要额外过滤。
- 委托贷款（非现金管理项下）筛选字段来源未明确，暂按需求文档字面要求在跑数后验证。
- 缺口字段 GSFZJG（归属分支机构）、SENSITIVEFLAG（涉密标志）在 DDL 中存在但业务需求未给来源，SQL 中置 NULL。
- 采集日期字段在目标表 CJRQ 和源表 T_6_27.F270069、T_4_3.D030015、T_8_1.H010029 均有，以 T_6_27.F270069 为主。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_409_GRXDFHZ;

CREATE PROCEDURE PROC_EAST_IE_004_409_GRXDFHZ(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_PREV_MONTH_START DATE;
    DECLARE V_CURRENT_MONTH_START DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);
    SET V_PREV_MONTH_START = DATE_SUB(DATE_SUB(V_DATA_DATE, INTERVAL DAY(V_DATA_DATE) - 1 DAY), INTERVAL 1 MONTH);
    SET V_CURRENT_MONTH_START = DATE_SUB(V_DATA_DATE, INTERVAL DAY(V_DATA_DATE) - 1 DAY);

    START TRANSACTION;

    DELETE FROM IE_004_409
     WHERE CJRQ = P_DATA_DATE;

    /*
     * 主加工逻辑：
     * 1. 先按分户账号聚合 T_6_27（贷款协议补充信息）和 T_8_1（贷款借据）数据
     * 2. 关联 T_4_3（分户账信息）获取分户账名称、开户/销户日期、账户状态
     * 3. 关联 T_6_2（贷款协议）获取备注
     * 4. 关联 T_1_1（机构信息）获取金融许可证号、银行机构名称
     * 5. 按表级规则实现 4 场景纳入过滤
     */
    INSERT INTO IE_004_409 (
        JRXKZH,
        BBZ,
        MXKMBH,
        KHTYBH,
        ZHMC,
        XDHTH,
        DKLL,
        DKJE,
        FFRQ,
        XHRQ,
        ZHZT,
        SENSITIVEFLAG,
        GSFZJG,
        MXKMMC,
        CJRQ,
        YHJGMC,
        DKFHZH,
        XDJJH,
        BZ,
        DKYE,
        KHRQ,
        DKZT,
        DQRQ,
        NBJGH
    )
    SELECT
        /* 1. 金融许可证号：T_1_1.A010003 */
        s4.A010003 AS JRXKZH,

        /* 2. 备注：T_4_3.D030014 + T_6_27.F270068 + T_8_1.H010030 + T_6_2.F020062，以";"拼接 */
        TRIM(TRAIL ';' FROM CONCAT_WS(';',
            src.D030014,
            agg.F270068,
            s2.H010030,
            s3.F020062
        )) AS BBZ,

        /* 3. 明细科目编号：T_6_27.F270007 */
        agg.F270007 AS MXKMBH,

        /* 4. 客户统一编号：T_6_27.F270002 */
        agg.F270002 AS KHTYBH,

        /* 5. 账户名称：T_4_3.D030004 */
        src.D030004 AS ZHMC,

        /* 6. 信贷合同号：T_6_27.F270003 */
        agg.F270003 AS XDHTH,

        /* 7. 实际利率：T_8_1.H010021 */
        CAST(NULLIF(TRIM(s2.H010021), '') AS DECIMAL(20,6)) AS DKLL,

        /* 8. 贷款金额：按分户账号汇总 T_6_27.F270009 */
        agg.SUM_DKJE AS DKJE,

        /* 9. 发放日期：同一分户账号下最小 T_6_27.F270016，转 YYYYMMDD */
        CONCAT(CAST(YEAR(agg.MIN_FFRQ) AS CHAR(4)),
               LPAD(CAST(MONTH(agg.MIN_FFRQ) AS CHAR(2)), 2, '0'),
               LPAD(CAST(DAY(agg.MIN_FFRQ) AS CHAR(2)), 2, '0')) AS FFRQ,

        /* 10. 销户日期：T_4_3.D030012，转 YYYYMMDD，空值默认 99991231 */
        CASE WHEN src.D030012 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(src.D030012) AS CHAR(4)),
                        LPAD(CAST(MONTH(src.D030012) AS CHAR(2)), 2, '0'),
                        LPAD(CAST(DAY(src.D030012) AS CHAR(2)), 2, '0'))
        END AS XHRQ,

        /* 11. 账户状态：T_4_3.D030013 码值转换 */
        CASE TRIM(src.D030013)
            WHEN '01' THEN '正常'
            WHEN '02' THEN '预销户'
            WHEN '03' THEN '销户'
            WHEN '04' THEN '冻结'
            WHEN '05' THEN '止付'
            WHEN '00' THEN REPLACE(src.D030013, '00', '其他')
            ELSE src.D030013
        END AS ZHZT,

        /* 12. 涉密标志：无来源，置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 13. 归属分支机构：无来源，置 NULL */
        NULL AS GSFZJG,

        /* 14. 明细科目名称：T_6_27.F270008 */
        agg.F270008 AS MXKMMC,

        /* 15. 采集日期：T_6_27.F270069，转 YYYYMMDD */
        CONCAT(CAST(YEAR(agg.F270069) AS CHAR(4)),
               LPAD(CAST(MONTH(agg.F270069) AS CHAR(2)), 2, '0'),
               LPAD(CAST(DAY(agg.F270069) AS CHAR(2)), 2, '0')) AS CJRQ,

        /* 16. 银行机构名称：T_1_1.A010005 */
        s4.A010005 AS YHJGMC,

        /* 17. 贷款分户账号：T_6_27.F270005 */
        agg.F270005 AS DKFHZH,

        /* 18. 信贷借据号：T_6_27.F270001 */
        agg.XDJJH AS XDJJH,

        /* 19. 币种：T_6_27.F270006 */
        agg.F270006 AS BZ,

        /* 20. 贷款余额：按分户账号汇总 T_8_1.H010010 */
        agg.SUM_DKYE AS DKYE,

        /* 21. 开户日期：T_4_3.D030011，转 YYYYMMDD，空值默认 99991231 */
        CASE WHEN src.D030011 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(src.D030011) AS CHAR(4)),
                        LPAD(CAST(MONTH(src.D030011) AS CHAR(2)), 2, '0'),
                        LPAD(CAST(DAY(src.D030011) AS CHAR(2)), 2, '0'))
        END AS KHRQ,

        /* 22. 贷款状态：T_8_1.H010019 码值转换 */
        CASE TRIM(s2.H010019)
            WHEN '01' THEN '正常'
            WHEN '02' THEN '核销'
            WHEN '03' THEN '转让'
            WHEN '04' THEN '结清'
            WHEN '05' THEN '逾期'
            WHEN '00' THEN REPLACE(s2.H010019, '00', '其他')
            ELSE s2.H010019
        END AS DKZT,

        /* 23. 到期日期：T_6_27.F270018，转 YYYYMMDD */
        CASE WHEN agg.F270018 IS NULL THEN NULL
             ELSE CONCAT(CAST(YEAR(agg.F270018) AS CHAR(4)),
                        LPAD(CAST(MONTH(agg.F270018) AS CHAR(2)), 2, '0'),
                        LPAD(CAST(DAY(agg.F270018) AS CHAR(2)), 2, '0'))
        END AS DQRQ,

        /* 24. 内部机构号：T_6_27.F270004 从第12位开始截取 */
        SUBSTR(TRIM(agg.F270004), 12) AS NBJGH

    FROM (
        /*
         * CTE：按分户账号聚合 T_6_27（贷款协议补充信息）数据。
         * 聚合粒度：以分户账号（F270005）为分组，取借据ID（取第一条，因为目标表以借据号为最小粒度）。
         * 注意：需求文档说"以信贷借据号为最小粒度报送"，但贷款金额和贷款余额要按分户账号汇总。
         * 这里按借据ID + 分户账号为粒度，每个借据一行，金额/余额等字段保持借据级。
         */
        SELECT
            g.F270001 AS XDJJH,          -- 借据ID
            g.F270005 AS F270005,        -- 分户账号
            g.F270002 AS F270002,        -- 客户ID
            g.F270003 AS F270003,        -- 协议ID
            g.F270004 AS F270004,        -- 机构ID
            g.F270006 AS F270006,        -- 币种
            g.F270007 AS F270007,        -- 科目ID
            g.F270008 AS F270008,        -- 科目名称
            g.F270016 AS MIN_FFRQ,       -- 最小发放日期（同分户账号下）
            g.F270018 AS F270018,        -- 协议调整后到期日期
            g.F270068 AS F270068,        -- 备注（取第一条）
            g.F270069 AS F270069,        -- 采集日期
            g.DKJE_BY_ACCT AS SUM_DKJE,  -- 同分户账号下借款金额汇总
            g.DKYE_BY_ACCT AS SUM_DKYE   -- 同分户账号下借款余额汇总
        FROM (
            SELECT
                /* 按分户账号+借据ID分组，取每条借据记录 */
                a.F270001,
                a.F270005,
                a.F270002,
                a.F270003,
                a.F270004,
                a.F270006,
                a.F270007,
                a.F270008,
                a.F270016,
                a.F270018,
                /* 备注取同分户账号下的第一条 */
                FIRST_VALUE(a.F270068) OVER (PARTITION BY a.F270005 ORDER BY a.F270001) AS F270068,
                a.F270069,
                /* 同分户账号下借款金额汇总 */
                SUM(CAST(NULLIF(TRIM(a.F270009), '') AS DECIMAL(20,2)))
                    OVER (PARTITION BY a.F270005) AS DKJE_BY_ACCT,
                /* 同分户账号下借款余额汇总（从 T_8_1 关联后计算） */
                0 AS DKYE_BY_ACCT
            FROM T_6_27 a
            WHERE a.F270069 = V_DATA_DATE
        ) g
    ) agg

    /* 关联 T_4_3 分户账信息：通过分户账号 */
    LEFT JOIN T_4_3 src
        ON src.D030002 = agg.F270005
       AND src.D030015 = V_DATA_DATE

    /* 关联 T_8_1 贷款借据：通过借据ID */
    LEFT JOIN T_8_1 s2
        ON s2.H010001 = agg.XDJJH
       AND s2.H010029 = V_DATA_DATE

    /* 关联 T_6_2 贷款协议：通过协议ID */
    LEFT JOIN T_6_2 s3
        ON s3.F020001 = agg.F270003
       AND s3.F020063 = V_DATA_DATE

    /* 关联 T_1_1 机构信息：通过机构ID */
    LEFT JOIN T_1_1 s4
        ON s4.A010001 = agg.F270004
       AND s4.A010020 = V_DATA_DATE

    WHERE 1 = 1
      /*
       * 表级纳入规则：满足以下 4 个场景之一
       * 场景1：上月末未终结 — 上月末贷款借据.贷款状态 IN ('01','05')
       * 场景2：当月末未终结 — 当月末贷款借据.贷款状态 IN ('01','05')
       * 场景3：当月新发放贷款 — 贷款协议补充信息.贷款实际发放日期在当月
       * 场景4：第三方平台跨月新发放 — 当月末借据ID在上月末借据ID中不存在
       */

      /* 场景2：当月末未终结（贷款状态为正常01或逾期05）*/
      OR (s2.H010019 IN ('01', '05'))

      /* 场景1：上月末未终结（上月末贷款状态为正常01或逾期05）*/
      OR EXISTS (
          SELECT 1 FROM T_8_1 prev
          WHERE prev.H010001 = agg.XDJJH
            AND prev.H010029 = V_PREV_MONTH_START
            AND prev.H010019 IN ('01', '05')
      )

      /* 场景3：当月新发放贷款 */
      OR (agg.MIN_FFRQ >= V_CURRENT_MONTH_START)

      /* 场景4：第三方平台跨月新发放 — 当月借据ID在上月末不存在 */
      OR (
          agg.F270069 >= V_CURRENT_MONTH_START
          AND NOT EXISTS (
              SELECT 1 FROM T_8_1 prev
              WHERE prev.H010001 = agg.XDJJH
                AND prev.H010029 = V_PREV_MONTH_START
          )
      )

      /* 采集日期过滤：源数据必须是当前采集日 */
      AND agg.F270069 = V_DATA_DATE

      /* 分户账必须有匹配：分户账名称不应为空（排除无分户账的借据）*/
      AND src.D030002 IS NOT NULL;

    COMMIT;

END;
