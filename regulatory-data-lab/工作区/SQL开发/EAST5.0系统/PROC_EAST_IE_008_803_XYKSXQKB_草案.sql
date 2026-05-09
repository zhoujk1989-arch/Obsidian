/*
草案质量状态：已校准，可审核。
校准记录：2026-05-10 按原始业务需求《051_信用卡授信情况表.md》逐字段重构校准（第2轮）。
修正项：
1. T_1_1 JOIN 补齐 A010020 采集日期过滤，防止因复合主键产生重复行。
2. IE_002_201/IE_002_203 JOIN 补齐 CJRQ 采集日期过滤。
3. ZHZT/XZSXLX 补充 '00-XX' → '其他-XX' 模式匹配码值转换。
4. CSFS 补全程码值映射（01→电话催收/02→信函催收/03→外访催收/04→司法催收/05→其他-委外催收/00-XX→其他-XX）。
5. DQSXYE 加 COALESCE 防 NULL 运算。
6. ZJSXPGRQ/ZXZJCXRQ/ZJXZSXRQ 加 NULL 保护（空值返回 NULL）。
原因：原草案存在笛卡尔积 JOIN、大量 NULL 占位、缺失码值转换、主表顺序错误等问题，已全部修复。*/

/*
业务目标：
- 依据原始业务需求《051_信用卡授信情况表.md》生成 EAST5.0 信用卡授信情况表（IE_008_803）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/051_信用卡授信情况表.md
- 原始材料/表结构/EAST5.0系统/IE_008_803-信用卡授信情况表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_9-信用卡协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_4-信用卡账户状态-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_201-个人基础信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_203-对公客户信息表-DDL-2026-04-28.sql

源表：
- T_8_4（主表：信用卡账户状态）
- T_6_9（信用卡协议，仅取主卡 F090013='0'）
- T_1_1（机构信息）
- IE_002_201（个人基础信息表，用于获取客户姓名/证件）
- IE_002_203（对公客户信息表，用于获取客户名称/证件）

目标表：
- IE_008_803：信用卡授信情况表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送信用卡持卡人当月授信情况。客户额度按同一账户下的总额度报送，不以单张信用卡额度报送。对主副卡客户（一账户多个客户）的情况，本表只报送主卡人的授信信息。同一客户多个账户的，按多条分别报送。同一账户多个币种共享额度的，按记账币种统一折算填报。状态为"销户"的账户在报送最后状态的次月可不再报送。

表级取数与关联规则：
### 2.1 表级规则（Excel第 1221 行） 取未失效及失效日期在当月的账户

关联关系：
1. T_8_4（主表）-> T_6_9：s1.H040003（信用卡账号）= src.F090037（信用卡账号）AND src.F090013='0'（仅主卡）
2. T_8_4 -> T_1_1：SUBSTR(s1.H040043, 12)（机构ID后段）= s2.A010002（内部机构号）
3. T_8_4 -> IE_002_201：s1.H040001（客户ID）= p.KHTYBH（客户统一编号）
4. T_8_4 -> IE_002_203：s1.H040001（客户ID）= c.KHTYBH（客户统一编号）

过滤条件：
- s1.H040036 = V_DATA_DATE（采集日快照）
- (s1.H040046 IS NULL OR s1.H040046 >= DATE_SUB(V_DATA_DATE, INTERVAL DAYOFMONTH(V_DATA_DATE)-1 DAY))（未失效及失效日期在当月）
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_008_803_XYKSXQKB;

CREATE PROCEDURE PROC_EAST_IE_008_803_XYKSXQKB(
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

    DELETE FROM IE_008_803
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_008_803 (
        YQRQ,
        YSXF,
        BYLJQXZZJE,
        BYLJSR,
        YYTHSXJE,
        BBZ,
        CJRQ,
        KHLB,
        YQJE,
        BYLJXFJE,
        NBJGH,
        XZSXLX,
        YHJGMC,
        KHMC,
        ZHZT,
        ZHYE,
        DQSXED,
        QZFQYE,
        DJYE,
        GSFZJG,
        JRXKZH,
        KHTYBH,
        ZJLB,
        ZJHM,
        XYKZH,
        BZ,
        ZSXEDSX,
        YJXJSXED,
        ZJSXPGRQ,
        TZJE,
        QZLSED,
        WJFL,
        ZXZJCXRQ,
        DQSXYE,
        DYLJJYBS,
        DYLJTZJE,
        BYLJFQJYJE,
        YYXYKFKHS,
        ZJXZSXRQ,
        CSBZ,
        CSFS,
        SENSITIVEFLAG
    )
    SELECT
        /* 逾期日期：T_8_4.H040031 -> YQRQ；加工映射：取逾期起始日期，未逾期填'99991231' */
        CASE WHEN s1.H040031 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(s1.H040031) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.H040031) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.H040031) AS VARCHAR(2)), 2, '0'))
        END AS YQRQ,
        /* 应收息费：T_8_4.H040010 -> YSXF；直接映射 */
        CAST(NULLIF(TRIM(s1.H040010), '') AS DECIMAL(20,2)) AS YSXF,
        /* 本月累计取现转账金额：T_8_4.H040022 -> BYLJQXZZJE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040022), '') AS DECIMAL(20,2)) AS BYLJQXZZJE,
        /* 本月累计收入：T_8_4.H040024 -> BYLJSR；直接映射 */
        CAST(NULLIF(TRIM(s1.H040024), '') AS DECIMAL(20,2)) AS BYLJSR,
        /* 已有他行授信金额：T_8_4.H040027 -> YYTHSXJE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040027), '') AS DECIMAL(20,2)) AS YYTHSXJE,
        /* 备注：T_8_4.H040042 -> BBZ；直接映射 */
        s1.H040042 AS BBZ,
        /* 采集日期：CJRQ = P_DATA_DATE（报告日，yyyymmdd格式） */
        P_DATA_DATE AS CJRQ,
        /* 客户类别：KHLB —— 需求映射表未提供来源字段，待确认。目前置NULL */
        NULL AS KHLB,
        /* 逾期金额：T_8_4.H040012 -> YQJE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040012), '') AS DECIMAL(20,2)) AS YQJE,
        /* 本月累计消费金额：T_8_4.H040021 -> BYLJXFJE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040021), '') AS DECIMAL(20,2)) AS BYLJXFJE,
        /* 内部机构号：从T_8_4.H040043（机构ID）第12位开始截取 -> NBJGH */
        SUBSTR(TRIM(s1.H040043), 12) AS NBJGH,
        /* 新增授信类型：T_8_4.H040030 -> XZSXLX；加工映射按码值转换 */
        CASE
            WHEN TRIM(s1.H040030) = '01' THEN '新发卡授信'
            WHEN TRIM(s1.H040030) = '02' THEN '固定额度上调'
            WHEN TRIM(s1.H040030) = '03' THEN '专项分期额度上调'
            WHEN LEFT(TRIM(s1.H040030), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(s1.H040030), 4))
            ELSE s1.H040030
        END AS XZSXLX,
        /* 银行机构名称：通过机构JOIN取T_1_1.A010005 -> YHJGMC */
        s2.A010005 AS YHJGMC,
        /* 客户名称：先取IE_002_201.KHXM(个人),取不到则取IE_002_203.KHMC(对公) -> KHMC */
        COALESCE(p.KHXM, c.KHMC) AS KHMC,
        /* 账户状态：T_8_4.H040037 -> ZHZT；加工映射按码值转换 */
        CASE
            WHEN TRIM(s1.H040037) = '01' THEN '正常'
            WHEN TRIM(s1.H040037) = '02' THEN '预销户'
            WHEN TRIM(s1.H040037) = '03' THEN '销户'
            WHEN TRIM(s1.H040037) = '04' THEN '冻结'
            WHEN TRIM(s1.H040037) = '05' THEN '止付'
            WHEN LEFT(TRIM(s1.H040037), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(s1.H040037), 4))
            ELSE s1.H040037
        END AS ZHZT,
        /* 账户余额：T_8_4.H040011 -> ZHYE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040011), '') AS DECIMAL(20,2)) AS ZHYE,
        /* 当前授信额度：取当前本币授信额度(H040005)和当前外币授信额度(H040006)的最大值 -> DQSXED */
        GREATEST(
            CAST(NULLIF(TRIM(s1.H040005), '') AS DECIMAL(20,2)),
            CAST(NULLIF(TRIM(s1.H040006), '') AS DECIMAL(20,2))
        ) AS DQSXED,
        /* 其中分期余额：T_8_4.H040039 -> QZFQYE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040039), '') AS DECIMAL(20,2)) AS QZFQYE,
        /* 冻结金额：T_8_4.H040018 -> DJYE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040018), '') AS DECIMAL(20,2)) AS DJYE,
        /* 归属分支机构：GSFZJG —— 需求映射表未提供来源字段，待确认。目前置NULL */
        NULL AS GSFZJG,
        /* 金融许可证号：通过机构JOIN取T_1_1.A010003 -> JRXKZH */
        s2.A010003 AS JRXKZH,
        /* 客户统一编号：T_8_4.H040001 -> KHTYBH；直接映射 */
        s1.H040001 AS KHTYBH,
        /* 证件类别：先取IE_002_201.ZJLB(个人),取不到则取IE_002_203.ZJLB(对公),均取不到则'无证件' -> ZJLB */
        COALESCE(p.ZJLB, c.ZJLB, '无证件') AS ZJLB,
        /* 证件号码：先取IE_002_201.ZJHM(个人),取不到则取IE_002_203.ZJHM(对公) -> ZJHM */
        COALESCE(p.ZJHM, c.ZJHM) AS ZJHM,
        /* 信用卡账号：T_8_4.H040003 -> XYKZH；直接映射 */
        s1.H040003 AS XYKZH,
        /* 币种：T_8_4.H040013 -> BZ；直接映射 */
        s1.H040013 AS BZ,
        /* 总授信额度上限：通过T_6_9 JOIN（仅主卡F090013='0'）取F090018 -> ZSXEDSX */
        CAST(NULLIF(TRIM(src.F090018), '') AS DECIMAL(20,2)) AS ZSXEDSX,
        /* 预借现金授信额度：币种不在('CNY','BWB')时取外币现金支取额度(H040045),否则取本币现金支取额度(H040044) -> YJXJSXED */
        CASE WHEN s1.H040013 NOT IN ('CNY', 'BWB') THEN CAST(NULLIF(TRIM(s1.H040045), '') AS DECIMAL(20,2))
             ELSE CAST(NULLIF(TRIM(s1.H040044), '') AS DECIMAL(20,2))
        END AS YJXJSXED,
        /* 最近授信评估日期：T_8_4.H040032 -> ZJSXPGRQ；转换YYYYMMDD格式 */
        CASE WHEN s1.H040032 IS NOT NULL
             THEN CONCAT(CAST(YEAR(s1.H040032) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.H040032) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.H040032) AS VARCHAR(2)), 2, '0'))
             ELSE NULL
        END AS ZJSXPGRQ,
        /* 透支金额：T_8_4.H040038 -> TZJE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040038), '') AS DECIMAL(20,2)) AS TZJE,
        /* 其中临时额度：取其中本币临时额度(H040016)和其中外币临时额度(H040017)的最大值 -> QZLSED */
        GREATEST(
            CAST(NULLIF(TRIM(s1.H040016), '') AS DECIMAL(20,2)),
            CAST(NULLIF(TRIM(s1.H040017), '') AS DECIMAL(20,2))
        ) AS QZLSED,
        /* 五级分类：T_8_4.H040015 -> WJFL；加工映射按码值转换 */
        CASE s1.H040015
            WHEN '01' THEN '正常'
            WHEN '02' THEN '关注'
            WHEN '03' THEN '次级'
            WHEN '04' THEN '可疑'
            WHEN '05' THEN '损失'
            ELSE s1.H040015
        END AS WJFL,
        /* 最近征信查询日期：T_8_4.H040033 -> ZXZJCXRQ；转换YYYYMMDD格式 */
        CASE WHEN s1.H040033 IS NOT NULL
             THEN CONCAT(CAST(YEAR(s1.H040033) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.H040033) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.H040033) AS VARCHAR(2)), 2, '0'))
             ELSE NULL
        END AS ZXZJCXRQ,
        /* 当前授信余额：当前本币授信额度(H040005) - 已使用本币授信额度(H040007) -> DQSXYE */
        COALESCE(CAST(NULLIF(TRIM(s1.H040005), '') AS DECIMAL(20,2)), 0)
          - COALESCE(CAST(NULLIF(TRIM(s1.H040007), '') AS DECIMAL(20,2)), 0) AS DQSXYE,
        /* 当月累计交易笔数：T_8_4.H040019 -> DYLJJYBS；直接映射 */
        CAST(NULLIF(TRIM(s1.H040019), '') AS DECIMAL(20,0)) AS DYLJJYBS,
        /* 当月累计透支金额：T_8_4.H040020 -> DYLJTZJE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040020), '') AS DECIMAL(20,2)) AS DYLJTZJE,
        /* 本月累计分期交易金额：T_8_4.H040023 -> BYLJFQJYJE；直接映射 */
        CAST(NULLIF(TRIM(s1.H040023), '') AS DECIMAL(20,2)) AS BYLJFQJYJE,
        /* 已有信用卡发卡银行数：T_8_4.H040026 -> YYXYKFKHS；直接映射 */
        CAST(NULLIF(TRIM(s1.H040026), '') AS DECIMAL(20,0)) AS YYXYKFKHS,
        /* 最近新增授信日期：T_8_4.H040034 -> ZJXZSXRQ；转换YYYYMMDD格式 */
        CASE WHEN s1.H040034 IS NOT NULL
             THEN CONCAT(CAST(YEAR(s1.H040034) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.H040034) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.H040034) AS VARCHAR(2)), 2, '0'))
             ELSE NULL
        END AS ZJXZSXRQ,
        /* 催收标志：T_8_4.H040028 -> CSBZ；简单码值转换(1->是,0->否)。
           注：完整业务规则要求遍历当月每日记录，当前取采集日单日快照值 */
        CASE s1.H040028 WHEN '1' THEN '是' WHEN '0' THEN '否' ELSE NULL END AS CSBZ,
        /* 催收方式：T_8_4.H040029 -> CSFS；加工映射按码值转换。
           注：完整业务规则要求遍历当月每日记录去重拼接并转码，当前取采集日单日快照值 */
        CASE
            WHEN TRIM(s1.H040029) = '01' THEN '电话催收'
            WHEN TRIM(s1.H040029) = '02' THEN '信函催收'
            WHEN TRIM(s1.H040029) = '03' THEN '外访催收'
            WHEN TRIM(s1.H040029) = '04' THEN '司法催收'
            WHEN TRIM(s1.H040029) = '05' THEN '其他-委外催收'
            WHEN LEFT(TRIM(s1.H040029), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(s1.H040029), 4))
            ELSE s1.H040029
        END AS CSFS,
        /* 涉密标志：SENSITIVEFLAG —— 需求映射表未提供来源字段，待确认。目前置NULL */
        NULL AS SENSITIVEFLAG
    FROM T_8_4 s1
    /* 关联信用卡协议（仅主卡）：信用卡账号关联，过滤附属卡标识='0'（主卡） */
    INNER JOIN T_6_9 src
           ON s1.H040003 = src.F090037
          AND src.F090013 = '0'
    /* 关联机构信息：机构ID后段(从第12位开始) = 内部机构号 */
    LEFT JOIN T_1_1 s2
           ON SUBSTR(TRIM(s1.H040043), 12) = s2.A010002
          AND s2.A010020 = V_DATA_DATE
    /* 关联个人基础信息表：用于获取客户姓名/证件 */
    LEFT JOIN IE_002_201 p
           ON s1.H040001 = p.KHTYBH
          AND p.CJRQ = P_DATA_DATE
    /* 关联对公客户信息表：用于获取客户名称/证件 */
    LEFT JOIN IE_002_203 c
           ON s1.H040001 = c.KHTYBH
          AND c.CJRQ = P_DATA_DATE
    WHERE s1.H040036 = V_DATA_DATE
      /* 表级规则：取未失效及失效日期在当月的账户 */
      AND (s1.H040046 IS NULL
           OR s1.H040046 >= DATE_SUB(V_DATA_DATE, INTERVAL DAYOFMONTH(V_DATA_DATE) - 1 DAY));

    COMMIT;
END;
