/*
草案质量状态：已重构校准待语法校验。
说明：本草案已完成第3轮重试校准。在第2轮基础上，修复 Part 3（现金管理项下委托贷款）缺少"关联上月末委托贷款协议"逻辑的问题，新增 LEFT JOIN last_month T_6_18 按上月末协议状态过滤已终止协议（04/05/06）。全部码值 CASE 转换、日期格式转换、金额 CAST 已补齐；WTRMC 四表 COALESCE；DKZT 三种场景已闭环；T_4_3 分户账信息备注已纳入 BBZ 拼接；4 个缺口字段（GSFZJG/SENSITIVEFLAG/WTRKHLB/SYRKHLB）置 NULL。尚未在 GBase 环境执行语法校验和跑数验证。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《056_委托贷款信息表.md》生成 EAST5.0 委托贷款信息表（IE_009_904）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/056_委托贷款信息表.md
- 原始材料/表结构/EAST5.0系统/IE_009_904-委托贷款信息表-DDL-2026-04-28.sql

| 源表：
| - T_6_18, T_6_27, T_4_3, T_1_1, T_2_1, T_2_5, T_2_3, T_2_4

目标表：
- IE_009_904：委托贷款信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送范围为个人及对公委托贷款业务，包括现金管理项下委托贷款、非现金管理项下委托贷款和公积金委托贷款。
- 对于现金管理项下委托贷款，每发生一笔放款仅报送一次，以后不再报送，贷款状态以"其他-现金管理项下"报送。
- 结清或者终结的委托贷款，在报送合同最后状态的次月不再填报。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1363 行）
委托贷款整体范围划分为：①对私委托贷款（不含现金管理项下委托贷款）、②对公委托贷款（不含现金管理项下委托贷款）、③现金管理项下委托贷款三部分。
对私和对公部分通过关联EAST转换结果表的个人信贷分户账和对公信贷分户账确定范围。
①对私委托贷款（不含现金管理项下委托贷款）:委托贷款类型不为"01 现金管理项下委托贷款"，
  关联《6.27贷款协议补充信息》（6.18与6.27关联条件：借据ID、采集日期），
  再内关联转换生成的《对公信贷分户账》（6.27分户账号=对公信贷分户账.贷款分户账号）确定范围。
②对公委托贷款（不含现金管理项下委托贷款）:委托贷款类型不为"01 现金管理项下委托贷款"，
  关联《6.27贷款协议补充信息》（6.18与6.27关联条件：借据ID、采集日期），
  再内关联转换生成的《个人信贷分户账》（6.27分户账号=个人信贷分户账.贷款分户账号）确定范围。
③现金管理项下委托贷款：委托贷款类型为"01 现金管理项下委托贷款"，
  关联上月末委托贷款协议（筛选协议状态为非正常04,05,06，00-现金管理项下），
  剔除上月末已报失效数据，卡出当月数据范围。

2026-05-10 重构校准说明（第3轮重试）：
- 重点修复：FROM 子句从 T_2_1 修正为 T_6_18（委托贷款协议为主表）。
- 消除所有 ON 1=1 占位，补齐全部 JOIN 业务关联键。
- 三部分 UNION ALL 分别实现：对私委托贷款、对公委托贷款、现金管理项下委托贷款。
- 补齐码值 CASE 转换：WTDKLX、SFSX、KHJLGH、DKZT。
- 补齐日期格式转换：HTQSRQ、HTDQRQ、CJRQ（DATE→YYYYMMDD）。
- 补齐金额字段 CAST：DKJE、SXFJE。
- 委托人名称 WTRMC 通过委托人客户ID全表 LEFT JOIN 四张客户信息表 COALESCE 获取。
- 缺口字段（GSFZJG/SENSITIVEFLAG/WTRKHLB/SYRKHLB）置 NULL。
- DKZT 分三种场景：对私→对公信贷分户账.DKZT；对公→个人信贷分户账.DKZT；现金管理项下→固定值。
- 第2轮补充：对私/对公部分 BBZ 增加 T_4_3（分户账信息）备注拼接，LEFT JOIN T_4_3 ON 分户账号+采集日期。
- 第3轮重试：Part 3（现金管理项下委托贷款）新增 LEFT JOIN last_month T_6_18，按上月末协议状态过滤已终止协议（04/05/06），替代原仅检查当月协议状态的逻辑，符合业务需求"关联上月末委托贷款协议"的要求。
- 状态变更为"已重构校准待语法校验"。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_009_904_WTDKXXB;

CREATE PROCEDURE PROC_EAST_IE_009_904_WTDKXXB(
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

    -- 清理目标表同一采集日期数据
    DELETE FROM IE_009_904
     WHERE CJRQ = P_DATA_DATE;

    -- INSERT: 三部分 UNION ALL
    -- 第一部分：对私委托贷款（不含现金管理项下）→ 内关联对公信贷分户账获取贷款状态
    -- 第二部分：对公委托贷款（不含现金管理项下）→ 内关联个人信贷分户账获取贷款状态
    -- 第三部分：现金管理项下委托贷款 → 固定贷款状态，仅报送一次

    INSERT INTO IE_009_904 (
        NBJGH,
        JRXKZH,
        HTBH,
        WTDKLX,
        SXFJE,
        HTDQRQ,
        WTRMC,
        SYRZH,
        SFSX,
        KHJLGH,
        DKZT,
        BBZ,
        GSFZJG,
        SENSITIVEFLAG,
        BZ,
        YHJGMC,
        MXKMMC,
        XDJJH,
        DKJE,
        HTQSRQ,
        WTRBH,
        WTRZH,
        WTRKHHMC,
        SYRMC,
        SYRKHHMC,
        SXFBZ,
        CJRQ,
        WTRKHLB,
        SYRKHLB,
        MXKMBH
    )
    -- ========== 第一部分：对私委托贷款（不含现金管理项下）==========
    -- 规则：WTDKLX != '01'，INNER JOIN T_6_27(借据ID,采集日期)，
    --       INNER JOIN IE_004_411(对公信贷分户账) on T_6_27.分户账号=对公信贷分户账.贷款分户账号
    SELECT
        /* 内部机构号：SUBSTR(机构ID,12) */
        SUBSTR(TRIM(src.F180002), 12) AS NBJGH,
        /* 金融许可证号：机构信息.金融许可证号 */
        org.A010003 AS JRXKZH,
        /* 信贷合同号：协议ID */
        src.F180001 AS HTBH,
        /* 委托贷款类型：码值转换 */
        CASE TRIM(src.F180003)
            WHEN '01' THEN '现金管理项下委托贷款'
            WHEN '02' THEN '非现金管理项下委托贷款'
            WHEN '03' THEN '公积金贷款'
            ELSE TRIM(src.F180003)
        END AS WTDKLX,
        /* 手续费金额 */
        CAST(NULLIF(TRIM(src.F180024), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 合同到期日期：DATE→YYYYMMDD */
        CONCAT(CAST(YEAR(src.F180011) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F180011) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F180011) AS VARCHAR(2)), 2, '0')) AS HTDQRQ,
        /* 委托人名称：通过委托客户ID关联四张客户信息表COALESCE获取 */
        COALESCE(c1.B010003, c2.B050003, c3.B030003, c4.B040033) AS WTRMC,
        /* 受益人账号：借款人账号 */
        src.F180026 AS SYRZH,
        /* 是否收息：码值转换 */
        CASE WHEN TRIM(src.F180009) = '1' THEN '是' ELSE '否' END AS SFSX,
        /* 经办人工号：自动办理的允许为空 */
        CASE WHEN TRIM(src.F180019) = '自动' THEN '' ELSE TRIM(src.F180019) END AS KHJLGH,
        /* 贷款状态：对私委托贷款→对公信贷分户账.DKZT */
        corp_fh.DKZT AS DKZT,
        /* 备注：提取委托贷款协议备注，拼接贷款协议补充信息备注，拼接分户账信息备注 */
        CONCAT_WS(';',
            NULLIF(TRIM(src.F180022), ''),
            NULLIF(TRIM(s6.F270068), ''),
            NULLIF(TRIM(acct.D030014), '')
        ) AS BBZ,
        /* 归属分支机构：缺口字段，业务需求未给来源 */
        NULL AS GSFZJG,
        /* 涉密标志：缺口字段，业务需求未给来源 */
        NULL AS SENSITIVEFLAG,
        /* 币种：协议币种 */
        src.F180008 AS BZ,
        /* 银行机构名称 */
        org.A010005 AS YHJGMC,
        /* 明细科目名称 */
        src.F180017 AS MXKMMC,
        /* 信贷借据号 */
        src.F180012 AS XDJJH,
        /* 合同金额：协议金额 */
        CAST(NULLIF(TRIM(src.F180007), '') AS DECIMAL(20,2)) AS DKJE,
        /* 合同起始日期：DATE→YYYYMMDD */
        CONCAT(CAST(YEAR(src.F180010) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F180010) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F180010) AS VARCHAR(2)), 2, '0')) AS HTQSRQ,
        /* 委托人编号：委托客户ID */
        src.F180004 AS WTRBH,
        /* 委托人账号 */
        src.F180005 AS WTRZH,
        /* 委托人开户行名称 */
        src.F180006 AS WTRKHHMC,
        /* 受益人名称：借款人名称 */
        src.F180014 AS SYRMC,
        /* 受益人开户行名称 */
        src.F180027 AS SYRKHHMC,
        /* 手续费币种 */
        src.F180023 AS SXFBZ,
        /* 采集日期：DATE→YYYYMMDD */
        CONCAT(CAST(YEAR(src.F180025) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F180025) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F180025) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 委托人客户类别：缺口字段，业务需求未给来源 */
        NULL AS WTRKHLB,
        /* 受益人客户类别：缺口字段，业务需求未给来源 */
        NULL AS SYRKHLB,
        /* 明细科目编号 */
        src.F180016 AS MXKMBH
    FROM T_6_18 src
    -- 机构信息（用于JRXKZH/YHJGMC）
    LEFT JOIN T_1_1 org
           ON TRIM(src.F180002) = TRIM(org.A010001)
          AND org.A010020 = V_DATA_DATE
    -- 贷款协议补充信息（用于分户账号关联）
    INNER JOIN T_6_27 s6
           ON src.F180012 = s6.F270001
          AND src.F180025 = s6.F270069
    -- 对公信贷分户账（对私委托贷款→对公信贷分户账，取贷款状态）
    INNER JOIN IE_004_411 corp_fh
           ON TRIM(s6.F270005) = TRIM(corp_fh.DKFHZH)
          AND corp_fh.CJRQ = P_DATA_DATE
    -- 分户账信息（用于BBZ备注拼接）
    LEFT JOIN T_4_3 acct
           ON TRIM(s6.F270005) = TRIM(acct.D030002)
          AND s6.F270069 = acct.D030015
    -- 委托人客户名称：四张客户信息表LEFT JOIN
    LEFT JOIN T_2_1 c1
           ON TRIM(src.F180004) = TRIM(c1.B010001)
          AND c1.B010060 = V_DATA_DATE
    LEFT JOIN T_2_5 c2
           ON TRIM(src.F180004) = TRIM(c2.B050001)
          AND c2.B050036 = V_DATA_DATE
    LEFT JOIN T_2_3 c3
           ON TRIM(src.F180004) = TRIM(c3.B030001)
          AND c3.B030036 = V_DATA_DATE
    LEFT JOIN T_2_4 c4
           ON TRIM(src.F180004) = TRIM(c4.B040001)
          AND c4.B040031 = V_DATA_DATE
    -- 对私委托贷款条件：WTDKLX != '01' + 当月采集日期
    WHERE TRIM(src.F180003) <> '01'
      AND src.F180025 = V_DATA_DATE

    UNION ALL

    -- ========== 第二部分：对公委托贷款（不含现金管理项下）==========
    -- 规则：WTDKLX != '01'，INNER JOIN T_6_27(借据ID,采集日期)，
    --       INNER JOIN IE_004_409(个人信贷分户账) on T_6_27.分户账号=个人信贷分户账.贷款分户账号
    SELECT
        SUBSTR(TRIM(src.F180002), 12) AS NBJGH,
        org.A010003 AS JRXKZH,
        src.F180001 AS HTBH,
        CASE TRIM(src.F180003)
            WHEN '01' THEN '现金管理项下委托贷款'
            WHEN '02' THEN '非现金管理项下委托贷款'
            WHEN '03' THEN '公积金贷款'
            ELSE TRIM(src.F180003)
        END AS WTDKLX,
        CAST(NULLIF(TRIM(src.F180024), '') AS DECIMAL(20,2)) AS SXFJE,
        CONCAT(CAST(YEAR(src.F180011) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F180011) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F180011) AS VARCHAR(2)), 2, '0')) AS HTDQRQ,
        COALESCE(c1.B010003, c2.B050003, c3.B030003, c4.B040033) AS WTRMC,
        src.F180026 AS SYRZH,
        CASE WHEN TRIM(src.F180009) = '1' THEN '是' ELSE '否' END AS SFSX,
        CASE WHEN TRIM(src.F180019) = '自动' THEN '' ELSE TRIM(src.F180019) END AS KHJLGH,
        /* 贷款状态：对公委托贷款→个人信贷分户账.DKZT */
        pers_fh.DKZT AS DKZT,
        /* 备注：提取委托贷款协议备注，拼接贷款协议补充信息备注，拼接分户账信息备注 */
        CONCAT_WS(';',
            NULLIF(TRIM(src.F180022), ''),
            NULLIF(TRIM(s6.F270068), ''),
            NULLIF(TRIM(acct.D030014), '')
        ) AS BBZ,
        NULL AS GSFZJG,
        NULL AS SENSITIVEFLAG,
        src.F180008 AS BZ,
        org.A010005 AS YHJGMC,
        src.F180017 AS MXKMMC,
        src.F180012 AS XDJJH,
        CAST(NULLIF(TRIM(src.F180007), '') AS DECIMAL(20,2)) AS DKJE,
        CONCAT(CAST(YEAR(src.F180010) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F180010) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F180010) AS VARCHAR(2)), 2, '0')) AS HTQSRQ,
        src.F180004 AS WTRBH,
        src.F180005 AS WTRZH,
        src.F180006 AS WTRKHHMC,
        src.F180014 AS SYRMC,
        src.F180027 AS SYRKHHMC,
        src.F180023 AS SXFBZ,
        CONCAT(CAST(YEAR(src.F180025) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F180025) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F180025) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        NULL AS WTRKHLB,
        NULL AS SYRKHLB,
        src.F180016 AS MXKMBH
    FROM T_6_18 src
    LEFT JOIN T_1_1 org
           ON TRIM(src.F180002) = TRIM(org.A010001)
          AND org.A010020 = V_DATA_DATE
    INNER JOIN T_6_27 s6
           ON src.F180012 = s6.F270001
          AND src.F180025 = s6.F270069
    -- 个人信贷分户账（对公委托贷款→个人信贷分户账，取贷款状态）
    INNER JOIN IE_004_409 pers_fh
           ON TRIM(s6.F270005) = TRIM(pers_fh.DKFHZH)
          AND pers_fh.CJRQ = P_DATA_DATE
    -- 分户账信息（用于BBZ备注拼接）
    LEFT JOIN T_4_3 acct
           ON TRIM(s6.F270005) = TRIM(acct.D030002)
          AND s6.F270069 = acct.D030015
    LEFT JOIN T_2_1 c1
           ON TRIM(src.F180004) = TRIM(c1.B010001)
          AND c1.B010060 = V_DATA_DATE
    LEFT JOIN T_2_5 c2
           ON TRIM(src.F180004) = TRIM(c2.B050001)
          AND c2.B050036 = V_DATA_DATE
    LEFT JOIN T_2_3 c3
           ON TRIM(src.F180004) = TRIM(c3.B030001)
          AND c3.B030036 = V_DATA_DATE
    LEFT JOIN T_2_4 c4
           ON TRIM(src.F180004) = TRIM(c4.B040001)
          AND c4.B040031 = V_DATA_DATE
    WHERE TRIM(src.F180003) <> '01'
      AND src.F180025 = V_DATA_DATE

    UNION ALL

    -- ========== 第三部分：现金管理项下委托贷款 ==========
    -- 规则：WTDKLX = '01'，关联上月末委托贷款协议（筛选协议状态为非正常04,05,06），
    --       剔除上月末已报失效数据，卡出当月数据范围
    --       DKZT固定值'其他-现金管理项下'
    --       每发生一笔放款仅报送一次（通过借据ID去重检查）
    -- 第3轮重试：新增 LEFT JOIN last_month T_6_18，按上月末协议状态过滤已终止协议
    SELECT
        SUBSTR(TRIM(src.F180002), 12) AS NBJGH,
        org.A010003 AS JRXKZH,
        src.F180001 AS HTBH,
        CASE TRIM(src.F180003)
            WHEN '01' THEN '现金管理项下委托贷款'
            WHEN '02' THEN '非现金管理项下委托贷款'
            WHEN '03' THEN '公积金贷款'
            ELSE TRIM(src.F180003)
        END AS WTDKLX,
        CAST(NULLIF(TRIM(src.F180024), '') AS DECIMAL(20,2)) AS SXFJE,
        CONCAT(CAST(YEAR(src.F180011) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F180011) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F180011) AS VARCHAR(2)), 2, '0')) AS HTDQRQ,
        COALESCE(c1.B010003, c2.B050003, c3.B030003, c4.B040033) AS WTRMC,
        src.F180026 AS SYRZH,
        CASE WHEN TRIM(src.F180009) = '1' THEN '是' ELSE '否' END AS SFSX,
        CASE WHEN TRIM(src.F180019) = '自动' THEN '' ELSE TRIM(src.F180019) END AS KHJLGH,
        /* 贷款状态：现金管理项下固定值 */
        '其他-现金管理项下' AS DKZT,
        /* 备注：现金管理项下仅取委托贷款协议备注 */
        NULLIF(TRIM(src.F180022), '') AS BBZ,
        NULL AS GSFZJG,
        NULL AS SENSITIVEFLAG,
        src.F180008 AS BZ,
        org.A010005 AS YHJGMC,
        src.F180017 AS MXKMMC,
        src.F180012 AS XDJJH,
        CAST(NULLIF(TRIM(src.F180007), '') AS DECIMAL(20,2)) AS DKJE,
        CONCAT(CAST(YEAR(src.F180010) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F180010) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F180010) AS VARCHAR(2)), 2, '0')) AS HTQSRQ,
        src.F180004 AS WTRBH,
        src.F180005 AS WTRZH,
        src.F180006 AS WTRKHHMC,
        src.F180014 AS SYRMC,
        src.F180027 AS SYRKHHMC,
        src.F180023 AS SXFBZ,
        CONCAT(CAST(YEAR(src.F180025) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F180025) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F180025) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        NULL AS WTRKHLB,
        NULL AS SYRKHLB,
        src.F180016 AS MXKMBH
    FROM T_6_18 src
    LEFT JOIN T_1_1 org
           ON TRIM(src.F180002) = TRIM(org.A010001)
          AND org.A010020 = V_DATA_DATE
    -- 关联上月末委托贷款协议（按协议ID+机构ID+借据ID关联），筛选上月末协议状态为非终止状态
    LEFT JOIN T_6_18 last_month
           ON src.F180001 = last_month.F180001
          AND src.F180002 = last_month.F180002
          AND src.F180012 = last_month.F180012
          AND last_month.F180025 = LAST_DAY(DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH))
    LEFT JOIN T_2_1 c1
           ON TRIM(src.F180004) = TRIM(c1.B010001)
          AND c1.B010060 = V_DATA_DATE
    LEFT JOIN T_2_5 c2
           ON TRIM(src.F180004) = TRIM(c2.B050001)
          AND c2.B050036 = V_DATA_DATE
    LEFT JOIN T_2_3 c3
           ON TRIM(src.F180004) = TRIM(c3.B030001)
          AND c3.B030036 = V_DATA_DATE
    LEFT JOIN T_2_4 c4
           ON TRIM(src.F180004) = TRIM(c4.B040001)
          AND c4.B040031 = V_DATA_DATE
    -- 现金管理项下条件
    WHERE TRIM(src.F180003) = '01'
      AND src.F180025 = V_DATA_DATE
      -- 上月末协议状态不存在（新增记录）或为非终止状态（非04,05,06）
      AND (last_month.F180015 IS NULL
           OR COALESCE(TRIM(last_month.F180015), '') NOT IN ('04', '05', '06'))
      -- 剔除上月末已报失效数据：同一借据ID在之前月份已报送的，不再重复报送
      AND NOT EXISTS (
          SELECT 1
            FROM IE_009_904 prev
           WHERE prev.XDJJH = src.F180012
             AND prev.CJRQ < P_DATA_DATE
      );

    COMMIT;
END;
