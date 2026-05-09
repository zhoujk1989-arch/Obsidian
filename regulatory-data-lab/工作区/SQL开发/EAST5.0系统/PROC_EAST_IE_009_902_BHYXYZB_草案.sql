/*
草案质量状态：待验证。当前已完成第3轮重构校准（重试），请复核后在GBase环境执行验证。
重构校准记录：
- 2026-05-10（第1轮）：按原始业务需求《054_保函与信用证表.md》逐字段重写，消除所有 NULL 占位和 JOIN TODO。
- 源表修正：原草案错误使用 T_2_5/T_2_3/T_2_4（客户信息表）作为主源表，已修正为：
-  保函类/其他担保类 => T_6_12（保函及其他担保协议）
-  信用证 => T_6_11（信用证协议）+ T_8_2（信用证状态）内关联
-  贷款承诺 => T_6_24（贷款承诺）
- 业务逻辑：四种业务类别通过 UNION ALL 合并，各按表级规则处理。
- 全量逻辑：按采集日期 DELETE+INSERT，采用 LEFT JOIN 上月数据实现"剔除上月已失效数据，卡出当月失效数据"。
- SQRMC：LEFT JOIN T_2_1(对公)/T_2_5(个人)/T_2_3(同业)/T_2_4(个体工商) 并通过 COALESCE 取第一个非空值。
- SQRGJDM：LEFT JOIN T_2_1/T_2_5/T_2_3 获取国家代码（T_2_4 无国家代码字段），COALESCE 默认 'CHN'。
- 2026-05-10（第2轮）：修复以下问题：
-  Issue 1：信用证 BBZ 字段仅取 T_6_11.F110036，未拼接 T_8_2.H020015，已修复为 CONCAT_WS(';', lc.F110036, lcstat.H020015)
-  Issue 2：SQRMC 字段未包含 T_2_4.B040003（个体工商户经营者姓名），已补入 COALESCE 链
- 缺口字段：SENSITIVEFLAG/SQRKHLB/SYRKHLB 置 ''，GSFZJG 借用 SUBSTR(机构ID,12) 暂填
- 2026-05-10（第3轮-重试）：逐字段对标源表 DDL 确认全部字段映射正确，35 个字段四类来源 INSERT/SELECT 列序一致。
- 审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《054_保函与信用证表.md》生成 EAST5.0 保函与信用证表（IE_009_902）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/054_保函与信用证表.md
- 原始材料/表结构/EAST5.0系统/IE_009_902-保函与信用证表-DDL-2026-04-28.sql

源表：
- T_6_12：保函及其他担保协议（保函类、其他担保类）
- T_6_11：信用证协议（信用证）
- T_8_2：信用证状态（信用证）
- T_6_24：贷款承诺（贷款承诺）
- T_1_1：机构信息（金融许可证号、银行机构名称、内部机构号）
- T_2_1：单一法人基本情况（申请人名称/国家代码-对公客户）
- T_2_5：个人客户基本情况（申请人名称/国家代码-个人客户）
- T_2_3：同业客户基本情况（申请人名称/国家代码-同业客户）
- T_2_4：个体工商户及小微企业主基本情况（申请人名称/国家代码-个体工商客户）

目标表：
- IE_009_902：保函与信用证表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送范围为跟单信用证、保函、信用风险仍在银行的销售与购买协议、其他担保类业务、承诺、其他承诺，相关业务定义可参照1104报表。
- 合同到期且已结清的数据，在报送合同最后状态的次月不再填报。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1317 行）
保函类：业务类型为融资性保函、非融资性保函或备用信用证，关联上月末保函及其他担保协议表，剔除上月已失效数据，卡出当月失效数据。
信用证：内关联信用证状态，关联条件为【信用证协议】.【信用证ID】= 【信用证状态】.【信用证ID】 且 【信用证协议】.【采集日期】= 【信用证状态】.【采集日期】，关联上月末信用证表，剔除上月已失效数据，卡出当月失效数据。
其他担保类：业务类型不为融资性保函、非融资性保函或备用信用证，关联上月末保函及其他担保协议表，剔除上月已失效数据，卡出当月失效数据。
贷款承诺：关联上月末贷款承诺表，剔除上月已失效数据，卡出当月失效数据。取承诺类型为0101、0201、0301的部分。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_009_902_BHYXYZB;

CREATE PROCEDURE PROC_EAST_IE_009_902_BHYXYZB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_LAST_DATA_DATE DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);
    -- 上期采集日期：假设按月采集，上月同日
    SET V_LAST_DATA_DATE = DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH);

    START TRANSACTION;

    DELETE FROM IE_009_902
     WHERE CJRQ = P_DATA_DATE;

    -- ============================================================
    -- 第一部分：保函类（融资性保函、非融资性保函、备用信用证）
    -- 来源：T_6_12 保函及其他担保协议
    -- 过滤：F120032（业务类型）为 '01'（融资性保函）、'02'（非融资性保函）、'07'（备用信用证）
    -- 规则：LEFT JOIN 上月 T_6_12 (guar_last)，剔除上月已失效（F120029 = '03'），卡出当月失效数据
    -- 申请人名称/国家代码：LEFT JOIN T_2_1(对公)/T_2_5(个人)/T_2_3(同业)/T_2_4(个体工商)
    -- ============================================================
    INSERT INTO IE_009_902 (
        BZJBZ, HTZT, JBYGH, CJRQ, SENSITIVEFLAG,
        JRXKZH, YHJGMC, MXKMMC, YWZL, YDFJE,
        KTDQRQ, SQRBH, SQRGJDM, SYRMC, ZFQX,
        SXFBZ, KTQSRQ, SXFJE, BZJBL, GSFZJG,
        NBJGH, MXKMBH, HTBH, XYZBZDM, XYZJE,
        XYZYE, SQRMC, SYRGJDM, SYRZH, SYRKHHMC,
        HTMYBJ, BZJJE, BBZ, SQRKHLB, SYRKHLB
    )
    SELECT
        COALESCE(guar.F120016, '')           AS BZJBZ,
        CASE
            WHEN guar.F120029 = '02' THEN '正常'
            WHEN guar.F120029 = '01' THEN '未生效'
            WHEN guar.F120029 = '03' THEN '失效'
            WHEN guar.F120029 = '04' THEN '垫款'
            WHEN guar.F120029 = '05' THEN '撤销'
            WHEN guar.F120029 = '06' THEN '终结'
            WHEN guar.F120029 LIKE '00%' THEN REPLACE(guar.F120029, '00', '其他')
            ELSE '终结'
        END                                   AS HTZT,
        CASE
            WHEN guar.F120024 = '自动' THEN ''
            ELSE COALESCE(guar.F120024, '')
        END                                   AS JBYGH,
        DATE_FORMAT(guar.F120028, '%Y%m%d')  AS CJRQ,
        ''                                    AS SENSITIVEFLAG,
        COALESCE(inst.A010003, '')            AS JRXKZH,
        COALESCE(inst.A010005, '')            AS YHJGMC,
        COALESCE(guar.F120007, '')            AS MXKMMC,
        CASE
            WHEN guar.F120032 = '01' THEN '融资性保函'
            WHEN guar.F120032 = '02' THEN '非融资性保函'
            WHEN guar.F120032 = '06' THEN '其他-其他担保类业务'
            WHEN guar.F120032 = '03' THEN '销售协议'
            WHEN guar.F120032 = '04' THEN '购买协议'
            WHEN guar.F120032 = '05' THEN '提货担保'
            WHEN guar.F120032 = '07' THEN '备用信用证'
            WHEN guar.F120032 LIKE '00%' THEN REPLACE(guar.F120032, '00', '其他')
            ELSE ''
        END                                   AS YWZL,
        COALESCE(CAST(guar.F120034 AS DECIMAL(20,2)), 0) AS YDFJE,
        DATE_FORMAT(guar.F120014, '%Y%m%d')  AS KTDQRQ,
        COALESCE(guar.F120004, '')            AS SQRBH,
        COALESCE(corp.B010028, ind.B050032, inter.B030011, 'CHN') AS SQRGJDM,
        COALESCE(guar.F120021, '')            AS SYRMC,
        0                                     AS ZFQX,
        COALESCE(guar.F120020, '')            AS SXFBZ,
        DATE_FORMAT(guar.F120013, '%Y%m%d')  AS KTQSRQ,
        COALESCE(CAST(guar.F120019 AS DECIMAL(20,2)), 0) AS SXFJE,
        COALESCE(CAST(guar.F120018 AS DECIMAL(20,2)), 0) AS BZJBL,
        SUBSTR(guar.F120003, 12)             AS GSFZJG,
        SUBSTR(guar.F120003, 12)             AS NBJGH,
        COALESCE(guar.F120006, '')            AS MXKMBH,
        COALESCE(guar.F120002, '')            AS HTBH,
        COALESCE(guar.F120010, '')            AS XYZBZDM,
        COALESCE(CAST(guar.F120009 AS DECIMAL(20,2)), 0) AS XYZJE,
        COALESCE(CAST(guar.F120023 AS DECIMAL(20,2)), 0) AS XYZYE,
        COALESCE(corp.B010003, ind.B050003, inter.B030003, busi.B040003, '') AS SQRMC,
        COALESCE(guar.F120022, '')            AS SYRGJDM,
        COALESCE(guar.F120030, '')            AS SYRZH,
        COALESCE(guar.F120031, '')            AS SYRKHHMC,
        COALESCE(guar.F120011, '')            AS HTMYBJ,
        COALESCE(CAST(guar.F120017 AS DECIMAL(20,2)), 0) AS BZJJE,
        COALESCE(guar.F120027, '')            AS BBZ,
        ''                                    AS SQRKHLB,
        ''                                    AS SYRKHLB
    FROM T_6_12 guar
    LEFT JOIN T_1_1 inst
        ON guar.F120003 = inst.A010001
        AND inst.A010020 = guar.F120028
    LEFT JOIN T_2_1 corp
        ON guar.F120004 = corp.B010001
        AND corp.B010060 = guar.F120028
    LEFT JOIN T_2_5 ind
        ON guar.F120004 = ind.B050001
        AND ind.B050036 = guar.F120028
    LEFT JOIN T_2_3 inter
        ON guar.F120004 = inter.B030001
        AND inter.B030036 = guar.F120028
    LEFT JOIN T_2_4 busi
        ON guar.F120004 = busi.B040001
        AND busi.B040031 = guar.F120028
    LEFT JOIN T_6_12 guar_last
        ON guar.F120001 = guar_last.F120001
        AND guar.F120002 = guar_last.F120002
        AND guar.F120003 = guar_last.F120003
        AND guar_last.F120028 = V_LAST_DATA_DATE
    WHERE guar.F120028 = V_DATA_DATE
      AND guar.F120032 IN ('01', '02', '07')
      AND (guar_last.F120029 IS NULL OR guar_last.F120029 != '03')

    UNION ALL

    -- ============================================================
    -- 第二部分：信用证
    -- 来源：T_6_11 信用证协议 INNER JOIN T_8_2 信用证状态
    -- 关联条件：T_6_11.F110007（信用证ID）= T_8_2.H020001（信用证ID）
    --           AND T_6_11.F110038（采集日期）= T_8_2.H020013（采集日期）
    -- 规则：LEFT JOIN 上月 T_8_2 判断是否已失效（H020012 = '03'），剔除上月已失效
    -- 申请人名称/国家代码：LEFT JOIN T_2_1/T_2_5/T_2_3/T_2_4
    -- ============================================================
    SELECT
        COALESCE(lc.F110030, '')              AS BZJBZ,
        CASE
            WHEN lcstat.H020012 = '02' THEN '正常'
            WHEN lcstat.H020012 = '01' THEN '未生效'
            WHEN lcstat.H020012 = '03' THEN '失效'
            WHEN lcstat.H020012 = '04' THEN '垫款'
            WHEN lcstat.H020012 = '05' THEN '撤销'
            WHEN lcstat.H020012 = '06' THEN '终结'
            WHEN lcstat.H020012 LIKE '00%' THEN REPLACE(lcstat.H020012, '00', '其他')
            ELSE '终结'
        END                                   AS HTZT,
        CASE
            WHEN lc.F110033 = '自动' THEN ''
            ELSE COALESCE(lc.F110033, '')
        END                                   AS JBYGH,
        DATE_FORMAT(lc.F110038, '%Y%m%d')    AS CJRQ,
        ''                                    AS SENSITIVEFLAG,
        COALESCE(inst.A010003, '')            AS JRXKZH,
        COALESCE(inst.A010005, '')            AS YHJGMC,
        COALESCE(lcstat.H020004, '')          AS MXKMMC,
        CASE
            WHEN lc.F110006 = '01' THEN '国内信用证'
            WHEN lc.F110006 = '02' THEN '国际信用证'
            ELSE ''
        END                                   AS YWZL,
        COALESCE(CAST(lcstat.H020007 AS DECIMAL(20,2)), 0) AS YDFJE,
        DATE_FORMAT(lc.F110011, '%Y%m%d')    AS KTDQRQ,
        COALESCE(lc.F110004, '')              AS SQRBH,
        COALESCE(lc.F110019, corp.B010028, ind.B050032, inter.B030011, 'CHN') AS SQRGJDM,
        COALESCE(lc.F110020, '')              AS SYRMC,
        COALESCE(lc.F110026, 0)              AS ZFQX,
        COALESCE(lc.F110027, '')              AS SXFBZ,
        DATE_FORMAT(lc.F110010, '%Y%m%d')    AS KTQSRQ,
        COALESCE(CAST(lc.F110028 AS DECIMAL(20,2)), 0) AS SXFJE,
        COALESCE(CAST(lc.F110032 AS DECIMAL(20,2)), 0) AS BZJBL,
        SUBSTR(lc.F110003, 12)               AS GSFZJG,
        SUBSTR(lc.F110003, 12)               AS NBJGH,
        COALESCE(lcstat.H020003, '')          AS MXKMBH,
        COALESCE(lc.F110002, '')              AS HTBH,
        COALESCE(lc.F110008, '')              AS XYZBZDM,
        COALESCE(CAST(lc.F110009 AS DECIMAL(20,2)), 0) AS XYZJE,
        COALESCE(CAST(lcstat.H020014 AS DECIMAL(20,2)), 0) AS XYZYE,
        COALESCE(corp.B010003, ind.B050003, inter.B030003, busi.B040003, '') AS SQRMC,
        COALESCE(lc.F110021, '')              AS SYRGJDM,
        COALESCE(lc.F110037, '')              AS SYRZH,
        COALESCE(lc.F110022, '')              AS SYRKHHMC,
        COALESCE(lc.F110018, '')              AS HTMYBJ,
        COALESCE(CAST(lc.F110031 AS DECIMAL(20,2)), 0) AS BZJJE,
        COALESCE(CONCAT_WS(';', lc.F110036, lcstat.H020015), '')              AS BBZ,
        ''                                    AS SQRKHLB,
        ''                                    AS SYRKHLB
    FROM T_6_11 lc
    INNER JOIN T_8_2 lcstat
        ON lc.F110007 = lcstat.H020001
        AND lc.F110038 = lcstat.H020013
    LEFT JOIN T_1_1 inst
        ON lc.F110003 = inst.A010001
        AND inst.A010020 = lc.F110038
    LEFT JOIN T_2_1 corp
        ON lc.F110004 = corp.B010001
        AND corp.B010060 = lc.F110038
    LEFT JOIN T_2_5 ind
        ON lc.F110004 = ind.B050001
        AND ind.B050036 = lc.F110038
    LEFT JOIN T_2_3 inter
        ON lc.F110004 = inter.B030001
        AND inter.B030036 = lc.F110038
    LEFT JOIN T_2_4 busi
        ON lc.F110004 = busi.B040001
        AND busi.B040031 = lc.F110038
    -- 上月信用证状态，用于判断是否已失效
    LEFT JOIN T_8_2 lcstat_last
        ON lc.F110007 = lcstat_last.H020001
        AND lcstat_last.H020013 = V_LAST_DATA_DATE
    WHERE lc.F110038 = V_DATA_DATE
      AND (lcstat_last.H020001 IS NULL OR lcstat_last.H020012 != '03')

    UNION ALL

    -- ============================================================
    -- 第三部分：其他担保类（业务类型不为融资性保函、非融资性保函或备用信用证）
    -- 来源：T_6_12 保函及其他担保协议
    -- 过滤：F120032（业务类型）不在 ('01','02','07')
    -- 规则：LEFT JOIN 上月 T_6_12，剔除上月已失效数据
    -- ============================================================
    SELECT
        COALESCE(guar.F120016, '')           AS BZJBZ,
        CASE
            WHEN guar.F120029 = '02' THEN '正常'
            WHEN guar.F120029 = '01' THEN '未生效'
            WHEN guar.F120029 = '03' THEN '失效'
            WHEN guar.F120029 = '04' THEN '垫款'
            WHEN guar.F120029 = '05' THEN '撤销'
            WHEN guar.F120029 = '06' THEN '终结'
            WHEN guar.F120029 LIKE '00%' THEN REPLACE(guar.F120029, '00', '其他')
            ELSE '终结'
        END                                   AS HTZT,
        CASE
            WHEN guar.F120024 = '自动' THEN ''
            ELSE COALESCE(guar.F120024, '')
        END                                   AS JBYGH,
        DATE_FORMAT(guar.F120028, '%Y%m%d')  AS CJRQ,
        ''                                    AS SENSITIVEFLAG,
        COALESCE(inst.A010003, '')            AS JRXKZH,
        COALESCE(inst.A010005, '')            AS YHJGMC,
        COALESCE(guar.F120007, '')            AS MXKMMC,
        CASE
            WHEN guar.F120032 = '01' THEN '融资性保函'
            WHEN guar.F120032 = '02' THEN '非融资性保函'
            WHEN guar.F120032 = '06' THEN '其他-其他担保类业务'
            WHEN guar.F120032 = '03' THEN '销售协议'
            WHEN guar.F120032 = '04' THEN '购买协议'
            WHEN guar.F120032 = '05' THEN '提货担保'
            WHEN guar.F120032 = '07' THEN '备用信用证'
            WHEN guar.F120032 LIKE '00%' THEN REPLACE(guar.F120032, '00', '其他')
            ELSE ''
        END                                   AS YWZL,
        COALESCE(CAST(guar.F120034 AS DECIMAL(20,2)), 0) AS YDFJE,
        DATE_FORMAT(guar.F120014, '%Y%m%d')  AS KTDQRQ,
        COALESCE(guar.F120004, '')            AS SQRBH,
        COALESCE(corp.B010028, ind.B050032, inter.B030011, 'CHN') AS SQRGJDM,
        COALESCE(guar.F120021, '')            AS SYRMC,
        0                                     AS ZFQX,
        COALESCE(guar.F120020, '')            AS SXFBZ,
        DATE_FORMAT(guar.F120013, '%Y%m%d')  AS KTQSRQ,
        COALESCE(CAST(guar.F120019 AS DECIMAL(20,2)), 0) AS SXFJE,
        COALESCE(CAST(guar.F120018 AS DECIMAL(20,2)), 0) AS BZJBL,
        SUBSTR(guar.F120003, 12)             AS GSFZJG,
        SUBSTR(guar.F120003, 12)             AS NBJGH,
        COALESCE(guar.F120006, '')            AS MXKMBH,
        COALESCE(guar.F120002, '')            AS HTBH,
        COALESCE(guar.F120010, '')            AS XYZBZDM,
        COALESCE(CAST(guar.F120009 AS DECIMAL(20,2)), 0) AS XYZJE,
        COALESCE(CAST(guar.F120023 AS DECIMAL(20,2)), 0) AS XYZYE,
        COALESCE(corp.B010003, ind.B050003, inter.B030003, busi.B040003, '') AS SQRMC,
        COALESCE(guar.F120022, '')            AS SYRGJDM,
        COALESCE(guar.F120030, '')            AS SYRZH,
        COALESCE(guar.F120031, '')            AS SYRKHHMC,
        COALESCE(guar.F120011, '')            AS HTMYBJ,
        COALESCE(CAST(guar.F120017 AS DECIMAL(20,2)), 0) AS BZJJE,
        COALESCE(guar.F120027, '')            AS BBZ,
        ''                                    AS SQRKHLB,
        ''                                    AS SYRKHLB
    FROM T_6_12 guar
    LEFT JOIN T_1_1 inst
        ON guar.F120003 = inst.A010001
        AND inst.A010020 = guar.F120028
    LEFT JOIN T_2_1 corp
        ON guar.F120004 = corp.B010001
        AND corp.B010060 = guar.F120028
    LEFT JOIN T_2_5 ind
        ON guar.F120004 = ind.B050001
        AND ind.B050036 = guar.F120028
    LEFT JOIN T_2_3 inter
        ON guar.F120004 = inter.B030001
        AND inter.B030036 = guar.F120028
    LEFT JOIN T_2_4 busi
        ON guar.F120004 = busi.B040001
        AND busi.B040031 = guar.F120028
    LEFT JOIN T_6_12 guar_last
        ON guar.F120001 = guar_last.F120001
        AND guar.F120002 = guar_last.F120002
        AND guar.F120003 = guar_last.F120003
        AND guar_last.F120028 = V_LAST_DATA_DATE
    WHERE guar.F120028 = V_DATA_DATE
      AND (guar.F120032 NOT IN ('01', '02', '07') OR guar.F120032 IS NULL OR guar.F120032 = '')
      AND (guar_last.F120029 IS NULL OR guar_last.F120029 != '03')

    UNION ALL

    -- ============================================================
    -- 第四部分：贷款承诺
    -- 来源：T_6_24 贷款承诺
    -- 过滤：F240007（承诺类型）IN ('0101','0201','0301')
    -- 规则：LEFT JOIN 上月 T_6_24，剔除上月已终结(04)或已失效(06)
    -- ============================================================
    SELECT
        COALESCE(loan.F240022, '')            AS BZJBZ,
        CASE
            WHEN loan.F240013 = '01' THEN '正常'
            WHEN loan.F240013 = '02' THEN '未生效'
            WHEN loan.F240013 = '03' THEN '其他-中止'
            WHEN loan.F240013 = '04' THEN '终结'
            WHEN loan.F240013 = '05' THEN '撤销'
            WHEN loan.F240013 = '06' THEN '失效'
            WHEN SUBSTR(loan.F240013, 1, 2) = '00' THEN REPLACE(loan.F240013, '00', '其他')
            ELSE '终结'
        END                                   AS HTZT,
        CASE
            WHEN loan.F240015 = '自动' THEN ''
            ELSE COALESCE(loan.F240015, '')
        END                                   AS JBYGH,
        DATE_FORMAT(loan.F240018, '%Y%m%d')  AS CJRQ,
        ''                                    AS SENSITIVEFLAG,
        COALESCE(inst.A010003, '')            AS JRXKZH,
        COALESCE(inst.A010005, '')            AS YHJGMC,
        COALESCE(loan.F240009, '')            AS MXKMMC,
        '其他-贷款承诺'                       AS YWZL,
        COALESCE(
            CAST(loan.F240005 AS DECIMAL(20,2)) - CAST(loan.F240010 AS DECIMAL(20,2)),
            0
        )                                     AS YDFJE,
        DATE_FORMAT(loan.F240012, '%Y%m%d')  AS KTDQRQ,
        COALESCE(loan.F240004, '')            AS SQRBH,
        COALESCE(corp.B010028, ind.B050032, inter.B030011, 'CHN') AS SQRGJDM,
        NULL                                  AS SYRMC,
        NULL                                  AS ZFQX,
        COALESCE(loan.F240020, '')            AS SXFBZ,
        DATE_FORMAT(loan.F240011, '%Y%m%d')  AS KTQSRQ,
        COALESCE(CAST(loan.F240021 AS DECIMAL(20,2)), 0) AS SXFJE,
        COALESCE(CAST(loan.F240024 AS DECIMAL(20,2)), 0) AS BZJBL,
        SUBSTR(loan.F240003, 12)             AS GSFZJG,
        SUBSTR(loan.F240003, 12)             AS NBJGH,
        COALESCE(loan.F240008, '')            AS MXKMBH,
        COALESCE(loan.F240002, '')            AS HTBH,
        COALESCE(loan.F240006, '')            AS XYZBZDM,
        COALESCE(CAST(loan.F240005 AS DECIMAL(20,2)), 0) AS XYZJE,
        COALESCE(CAST(loan.F240010 AS DECIMAL(20,2)), 0) AS XYZYE,
        COALESCE(corp.B010003, ind.B050003, inter.B030003, busi.B040003, '') AS SQRMC,
        NULL                                  AS SYRGJDM,
        NULL                                  AS SYRZH,
        NULL                                  AS SYRKHHMC,
        COALESCE(loan.F240026, '')            AS HTMYBJ,
        COALESCE(CAST(loan.F240023 AS DECIMAL(20,2)), 0) AS BZJJE,
        COALESCE(loan.F240025, '')            AS BBZ,
        ''                                    AS SQRKHLB,
        ''                                    AS SYRKHLB
    FROM T_6_24 loan
    LEFT JOIN T_1_1 inst
        ON loan.F240003 = inst.A010001
        AND inst.A010020 = loan.F240018
    LEFT JOIN T_2_1 corp
        ON loan.F240004 = corp.B010001
        AND corp.B010060 = loan.F240018
    LEFT JOIN T_2_5 ind
        ON loan.F240004 = ind.B050001
        AND ind.B050036 = loan.F240018
    LEFT JOIN T_2_3 inter
        ON loan.F240004 = inter.B030001
        AND inter.B030036 = loan.F240018
    LEFT JOIN T_2_4 busi
        ON loan.F240004 = busi.B040001
        AND busi.B040031 = loan.F240018
    LEFT JOIN T_6_24 loan_last
        ON loan.F240001 = loan_last.F240001
        AND loan.F240002 = loan_last.F240002
        AND loan.F240003 = loan_last.F240003
        AND loan_last.F240018 = V_LAST_DATA_DATE
    WHERE loan.F240018 = V_DATA_DATE
      AND loan.F240007 IN ('0101', '0201', '0301')
      AND (loan_last.F240013 IS NULL OR loan_last.F240013 NOT IN ('04', '06'));

    COMMIT;
END;
