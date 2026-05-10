/*
重构校准状态：已完成，可执行验证。
审计记录：sql/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md

业务目标：
- 依据原始业务需求《046_信贷资产转让表.md》生成 EAST5.0 信贷资产转让表（IE_007_703）GBase 存储过程。

目标系统：
- EAST5.0系统。

源表：
- T_6_23（信贷资产转让协议）：主表，字段映射主要来源
- T_7_9（信贷资产转让）：左关联，取对手行名（JYDSKHHMC），含去重+窗口排序逻辑
- T_1_1（机构信息）：左关联，取金融许可证号（JRXKZH）

目标表：
- IE_007_703：信贷资产转让表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 业务范围包含直接转让债权、信贷资产证券化、信贷资产收益权转让、通过其他方式转让等，以及对应的信贷资产转入业务。
- 行内机构间的转让需报送。票据的买卖、买入返售、卖出回购不在本表填报。
- 含已核销贷款，本金按实际填写0即可。终结的转让合同在报送最后状态后不再报送。

表级规则摘要（Excel第1084行）：
- 主表：T_6_23（信贷资产转让协议），采集日期=跑批日期
- 左关联 T_7_9（信贷资产转让）：对(协议ID,资产转让方向,对方户名,核心交易日期)去重后，按(协议ID,资产转让方向)分组，核心交易日期升序，取 rn=1
  - 关联条件：T_6_23.协议ID = T_7_9.协议ID, T_6_23.资产转让方向 = T_7_9.资产转让方向, T_7_9.采集日期<=跑批日期
- 左关联 T_1_1（机构信息）：机构ID从第12位截取关联，采集日期=跑批日期
- 左关联 T_6_23（上月末状态）：采集日期=跑批日期上月末，按协议ID+资产转让方向关联
- 过滤条件：主表采集日期=跑批日期，且(优先取上月末协议状态,关联不上时置'') IN ('01','02','')
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_007_703_XDZCZRB;

CREATE PROCEDURE PROC_EAST_IE_007_703_XDZCZRB(
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

    -- 全量表：删除同一采集日期的历史数据
    DELETE FROM IE_007_703
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_007_703 (
        NBJGH,
        ZRHTH,
        ZRJKRZZH,
        JYDSMC,
        ZRDKBJZE,
        JRXKZH,
        ZCZRFS,
        GSFZJG,
        BZJBL,
        ZRHTDQRQ,
        CJRQ,
        ZRHTZT,
        ZRJYPT,
        SENSITIVEFLAG,
        JYDSYZFJE,
        ZRHTQSRQ,
        JYDSKHLB,
        BBZ,
        SFZYDZXDJ,
        BZJBZ,
        JYDSZRRQ,
        ZRZJ,
        ZRDKLXZE,
        BZ,
        JYDSKHHMC,
        JYDSZZZH,
        ZRJKRZMC,
        ZCZRFX,
        BZJJE
    )
    SELECT
        /* 内部机构号 NBJGH：T_6_23.F230002（机构ID）从第12位开始截取 */
        SUBSTR(TRIM(s1.F230002), 12) AS NBJGH,

        /* 转让合同号 ZRHTH：T_6_23.F230001（协议ID）直接映射 */
        s1.F230001 AS ZRHTH,

        /* 转让价款入账账号 ZRJKRZZH：T_6_23.F230008 直接映射 */
        s1.F230008 AS ZRJKRZZH,

        /* 交易对手名称 JYDSMC：T_6_23.F230004 直接映射 */
        s1.F230004 AS JYDSMC,

        /* 转让贷款本金总额 ZRDKBJZE：T_6_23.F230016（转让涉及业务本金总额）CAST */
        CAST(NULLIF(TRIM(s1.F230016), '') AS DECIMAL(20,2)) AS ZRDKBJZE,

        /* 金融许可证号 JRXKZH：T_1_1.A010003，通过 SUBSTR(机构ID,12) 左关联获取 */
        org.A010003 AS JRXKZH,

        /*
         * 资产转让方式 ZCZRFS：T_6_23.F230025（资产转让方式）
         * 码值映射：01→直接转让，02→信贷资产证券化，03→其他-信贷资产收益权转让，00-自定义→其他-自定义，ELSE→原值
         */
        CASE
            WHEN TRIM(s1.F230025) = '01' THEN '直接转让'
            WHEN TRIM(s1.F230025) = '02' THEN '信贷资产证券化'
            WHEN TRIM(s1.F230025) = '03' THEN '其他-信贷资产收益权转让'
            WHEN LEFT(TRIM(s1.F230025), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(s1.F230025), 4))
            ELSE s1.F230025
        END AS ZCZRFS,

        /* 归属分支机构 GSFZJG：业务需求未提供来源，置 NULL */
        NULL AS GSFZJG,

        /* 保证金比例 BZJBL：T_6_23.F230021 CAST */
        CAST(NULLIF(TRIM(s1.F230021), '') AS DECIMAL(20,2)) AS BZJBL,

        /*
         * 转让合同到期日期 ZRHTDQRQ：T_6_23.F230012（到期日期）
         * DATE → VARCHAR(8) YYYYMMDD
         */
        CASE WHEN s1.F230012 IS NOT NULL
            THEN CONCAT(CAST(YEAR(s1.F230012) AS VARCHAR(4)),
                        LPAD(CAST(MONTH(s1.F230012) AS VARCHAR(2)), 2, '0'),
                        LPAD(CAST(DAY(s1.F230012) AS VARCHAR(2)), 2, '0'))
        END AS ZRHTDQRQ,

        /* 采集日期 CJRQ：直接赋参数 P_DATA_DATE */
        P_DATA_DATE AS CJRQ,

        /*
         * 转让合同状态 ZRHTZT：T_6_23.F230029（协议状态）
         * 码值映射：01→有效，02→未生效，03→其他-中止，04→终结，05→撤销，06→其他-无效，00-自定义→其他-自定义，ELSE→原值
         */
        CASE
            WHEN TRIM(s1.F230029) = '01' THEN '有效'
            WHEN TRIM(s1.F230029) = '02' THEN '未生效'
            WHEN TRIM(s1.F230029) = '03' THEN '其他-中止'
            WHEN TRIM(s1.F230029) = '04' THEN '终结'
            WHEN TRIM(s1.F230029) = '05' THEN '撤销'
            WHEN TRIM(s1.F230029) = '06' THEN '其他-无效'
            WHEN LEFT(TRIM(s1.F230029), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(s1.F230029), 4))
            ELSE s1.F230029
        END AS ZRHTZT,

        /*
         * 转让交易平台 ZRJYPT：T_6_23.F230022（转让交易平台）
         * 码值映射：01→银登中心，02→证券交易所，03→银行间市场，00自定义→其他-自定义，ELSE→原值
         */
        CASE
            WHEN TRIM(s1.F230022) = '01' THEN '银登中心'
            WHEN TRIM(s1.F230022) = '02' THEN '证券交易所'
            WHEN TRIM(s1.F230022) = '03' THEN '银行间市场'
            WHEN LEFT(TRIM(s1.F230022), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(s1.F230022), 4))
            ELSE s1.F230022
        END AS ZRJYPT,

        /* 涉密标志 SENSITIVEFLAG：业务需求未提供来源，置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 交易对手已支付金额 JYDSYZFJE：T_6_23.F230007 CAST */
        CAST(NULLIF(TRIM(s1.F230007), '') AS DECIMAL(20,2)) AS JYDSYZFJE,

        /*
         * 转让合同起始日期 ZRHTQSRQ：T_6_23.F230011（生效日期）
         * DATE → VARCHAR(8) YYYYMMDD
         */
        CASE WHEN s1.F230011 IS NOT NULL
            THEN CONCAT(CAST(YEAR(s1.F230011) AS VARCHAR(4)),
                        LPAD(CAST(MONTH(s1.F230011) AS VARCHAR(2)), 2, '0'),
                        LPAD(CAST(DAY(s1.F230011) AS VARCHAR(2)), 2, '0'))
        END AS ZRHTQSRQ,

        /* 交易对手客户类别 JYDSKHLB：业务需求未提供来源，置 NULL */
        NULL AS JYDSKHLB,

        /* 备注 BBZ：T_6_23.F230031 直接映射 */
        s1.F230031 AS BBZ,

        /*
         * 是否在银登中心登记 SFZYDZXDJ：T_6_23.F230023（在银登中心登记标识）
         * 码值映射：1→是，0→否，ELSE→原值
         */
        CASE
            WHEN TRIM(s1.F230023) = '1' THEN '是'
            WHEN TRIM(s1.F230023) = '0' THEN '否'
            ELSE s1.F230023
        END AS SFZYDZXDJ,

        /* 保证金币种 BZJBZ：T_6_23.F230020 直接映射 */
        s1.F230020 AS BZJBZ,

        /*
         * 交易对手转账日期 JYDSZRRQ：T_6_23.F230033
         * DATE → VARCHAR(8) YYYYMMDD
         */
        CASE WHEN s1.F230033 IS NOT NULL
            THEN CONCAT(CAST(YEAR(s1.F230033) AS VARCHAR(4)),
                        LPAD(CAST(MONTH(s1.F230033) AS VARCHAR(2)), 2, '0'),
                        LPAD(CAST(DAY(s1.F230033) AS VARCHAR(2)), 2, '0'))
        END AS JYDSZRRQ,

        /* 转让总价 ZRZJ：T_6_23.F230014（协议金额）CAST */
        CAST(NULLIF(TRIM(s1.F230014), '') AS DECIMAL(20,2)) AS ZRZJ,

        /* 转让贷款利息总额 ZRDKLXZE：T_6_23.F230017 CAST */
        CAST(NULLIF(TRIM(s1.F230017), '') AS DECIMAL(20,2)) AS ZRDKLXZE,

        /* 币种 BZ：T_6_23.F230013（协议币种）直接映射 */
        s1.F230013 AS BZ,

        /*
         * 交易对手开户行名称 JYDSKHHMC：T_7_9.G090015（对方行名）
         * 加工逻辑：对(协议ID,资产转让方向,对方户名,核心交易日期)去重后，
         * 按(协议ID,资产转让方向)分组，核心交易日期升序，取第1条
         */
        src.G090015 AS JYDSKHHMC,

        /* 交易对手账号 JYDSZZZH：T_6_23.F230005 直接映射 */
        s1.F230005 AS JYDSZZZH,

        /* 转让价款入账账户名称 ZRJKRZMC：T_6_23.F230009 直接映射 */
        s1.F230009 AS ZRJKRZMC,

        /*
         * 资产转让方向 ZCZRFX：T_6_23.F230024（资产转让方向）
         * 码值映射：01→转入，02→转出，ELSE→原值
         */
        CASE
            WHEN TRIM(s1.F230024) = '01' THEN '转入'
            WHEN TRIM(s1.F230024) = '02' THEN '转出'
            ELSE s1.F230024
        END AS ZCZRFX,

        /* 保证金金额 BZJJE：T_6_23.F230019 CAST */
        CAST(NULLIF(TRIM(s1.F230019), '') AS DECIMAL(20,2)) AS BZJJE

    FROM T_6_23 s1  /* 主表：信贷资产转让协议 */

    /*
     * 左关联 T_7_9（信贷资产转让）：取交易对手开户行名称(JYDSKHHMC)
     * 对(协议ID,资产转让方向,对方户名,核心交易日期)去重后，
     * 按(协议ID,资产转让方向)分组，核心交易日期升序，取 rn=1
     * 关联条件：协议ID匹配 + 资产转让方向匹配
     * T_7_9.采集日期 <= 跑批日期
     */
    LEFT JOIN (
        SELECT G090001, G090005, G090015, G090010,
               ROW_NUMBER() OVER (
                   PARTITION BY G090001, G090005
                   ORDER BY G090010 ASC
               ) AS rn
        FROM (
            SELECT DISTINCT
                G090001,  /* 协议ID */
                G090005,  /* 资产转让方向 */
                G090013,  /* 对方户名（去重维度） */
                G090010,  /* 核心交易日期（去重维度，排序键） */
                G090015   /* 对方行名（目标字段） */
            FROM T_7_9
            WHERE G090018 <= V_DATA_DATE  /* 采集日期 <= 跑批日期 */
        ) t
    ) src ON s1.F230001 = src.G090001        /* T_6_23.协议ID = T_7_9.协议ID */
         AND s1.F230024 = src.G090005        /* T_6_23.资产转让方向 = T_7_9.资产转让方向 */
         AND src.rn = 1                      /* 取排序第1条 */

    /*
     * 左关联 T_1_1（机构信息）：取金融许可证号(JRXKZH)
     * 关联条件：T_6_23.机构ID(SUBSTR(12)) = T_1_1.机构ID(SUBSTR(12))
     * T_1_1.采集日期 = 跑批日期
     */
    LEFT JOIN T_1_1 org
        ON SUBSTR(TRIM(s1.F230002), 12) = SUBSTR(TRIM(org.A010001), 12)
       AND org.A010020 = V_DATA_DATE

    /*
     * 左关联 T_6_23（上月末状态）：用于终态纳入过滤
     * 关联条件：上月末采集日期 + 协议ID + 资产转让方向
     * 取上月末的协议状态，判断是否在上月有效或未生效
     */
    LEFT JOIN T_6_23 last_month
        ON last_month.F230032 = DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH)
       AND last_month.F230001 = s1.F230001
       AND last_month.F230024 = s1.F230024

    /*
     * 过滤条件：
     * 1. 主表采集日期 = 跑批日期（当月数据）
     * 2. 上月末协议状态 IN ('01'有效, '02'未生效, ''不存在)
     *    → 即：上月有效/未生效的继续报送，或本月新增（上月不存在）的报送
     */
    WHERE s1.F230032 = V_DATA_DATE
      AND COALESCE(last_month.F230029, '') IN ('01', '02', '');

    COMMIT;
END;
