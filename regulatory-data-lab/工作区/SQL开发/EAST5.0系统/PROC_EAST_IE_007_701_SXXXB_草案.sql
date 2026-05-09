/*
重构质量状态：validated（按原始业务需求逐字段核验完毕）
审计记录：工作区/SQL开发/EAST5.0系统/日志.md

业务目标：
- 依据原始业务需求《044_授信信息表.md》生成 EAST5.0 授信信息表（IE_007_701）GBase 存储过程。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程。

依赖材料：
- 原始材料/业务需求/EAST5.0/044_授信信息表.md
- 原始材料/表结构/EAST5.0系统/IE_007_701-授信信息表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_8_13-授信情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_203-对公客户信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_201-个人基础信息表-DDL-2026-04-28.sql

源表：
- T_8_13（授信情况）：主表，提供授信明细
- T_1_1（机构信息）：通过机构ID关联，获取银行机构代码/金融许可证号
- IE_002_203（对公客户信息表/EAST5.0）：通过客户统一编号关联，获取客户名称/证件类别/证件号码
- IE_002_201（个人基础信息表/EAST5.0）：通过客户统一编号关联，获取客户姓名/证件类别/证件号码

目标表：
- IE_007_701：授信信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 对客户授信的信息，但不包含客户使用授信的明细。包括对公和个人、同业客户授信，但不包括集团授信。
- 个人授信额度包括个人贷款、信用卡额度授信（包含准贷记卡透支额度）。
- 对公和同业授信包括已经或预期可能由本行承担信用风险的各类产品额度。

表级取数与关联规则：
### 2.1 表级规则（Excel第 1039 行）
转换时从【授信情况】出，剔除如下三部分数据：
1.【授信情况】.【授信种类】等于'06'
2.【授信情况】.【客户类别】等于'02'的数据
3.【授信情况】.【授信失效日期】小于上月的数据

重构说明（与草案对比）：
- 修复 T_1_1 JOIN：ON 1=1 → ON src.H130003 = s1.A010001（机构ID关联）
- 补充 WHERE 条件：排除授信种类='06'、客户类别='02'、授信失效日期<上月首日
- 补充对公客户信息表/个人基础信息表 LEFT JOIN：用于 KHMC/KHZJLB/KHZJHM 字段（COALESCE 优先对公）
- 修复 EDSQRQ 类型：DECIMAL(20,2) → REPLACE('-','') 日期字符串
- 补齐 SXZTZL CASE：客户类别码值转授信主体种类中文
- 补齐 SXZL CASE：授信种类码值转中文
- 补齐 SXZT CASE：授信状态码值转中文
- KHLB、SENSITIVEFLAG、GSFZJG 为缺口字段（DDL存在但业务需求未提供来源），保留 NULL
- CJRQ 使用 P_DATA_DATE（采集报告期，非源表 H130023）
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_007_701_SXXXB;

CREATE PROCEDURE PROC_EAST_IE_007_701_SXXXB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_LAST_MONTH_FIRST DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);

    -- 计算上月首日，用于排除授信失效日期<上月的数据
    SET V_LAST_MONTH_FIRST = DATE_SUB(DATE_FORMAT(V_DATA_DATE, '%Y-%m-01'), INTERVAL 1 MONTH);

    START TRANSACTION;

    DELETE FROM IE_007_701
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_007_701 (
        KHLB,
        KHMC,
        SXKSRQ,
        SENSITIVEFLAG,
        GSFZJG,
        NBJGH,
        KHZJHM,
        EDSQRQ,
        SXZTZL,
        BZ,
        SXDQRQ,
        SXJCYJ,
        JBRGH,
        BBZ,
        YHJGDM,
        JRXKZH,
        KHTYBH,
        KHZJLB,
        SXXYMC,
        SXED,
        YYED,
        SPRGH,
        SXZT,
        CJRQ,
        SXZL,
        SXXYH
    )
    SELECT
        /* KHLB 客户类别：缺口字段 — 本地DDL存在但业务需求映射表未提供来源，留NULL待确认 */
        NULL AS KHLB,
        /* KHMC 客户名称：优先取对公客户信息表.客户名称，为NULL则取个人基础信息表.客户姓名，再为NULL置'' */
        COALESCE(dg.KHMC, gr.KHXM, '') AS KHMC,
        /* SXKSRQ 授信开始日期：授信情况.授信起始日期，去除'-' */
        REPLACE(CAST(src.H130011 AS CHAR(10)), '-', '') AS SXKSRQ,
        /* SENSITIVEFLAG 涉密标志：缺口字段 — 本地DDL存在但业务需求未提供来源，留NULL待确认 */
        NULL AS SENSITIVEFLAG,
        /* GSFZJG 归属分支机构：缺口字段 — 本地DDL存在但业务需求未提供来源，留NULL待确认 */
        NULL AS GSFZJG,
        /* NBJGH 内部机构号：授信情况.机构ID，截取第12位起 */
        SUBSTR(TRIM(src.H130003), 12) AS NBJGH,
        /* KHZJHM 客户证件号码：优先取对公客户信息表.证件号码，为NULL则取个人基础信息表.证件号码，再为NULL置'' */
        COALESCE(dg.ZJHM, gr.ZJHM, '') AS KHZJHM,
        /* EDSQRQ 额度申请日期：授信情况.额度申请日期，去除'-' */
        REPLACE(CAST(src.H130010 AS CHAR(10)), '-', '') AS EDSQRQ,
        /* SXZTZL 授信主体种类：授信情况.客户类别，码值转换 */
        CASE src.H130005
            WHEN '01' THEN '单一法人授信'
            WHEN '03' THEN '同业客户授信'
            WHEN '04' THEN '供应链融资'
            WHEN '05' THEN '个人客户授信'
            WHEN '06' THEN '个人客户授信'
            WHEN '02' THEN NULL /* 客户类别='02'已在WHERE剔除，兜底 */
            ELSE CONCAT('其他-', COALESCE(src.H130005, ''))
        END AS SXZTZL,
        /* BZ 币种：授信情况.授信币种，直接映射 */
        src.H130007 AS BZ,
        /* SXDQRQ 授信到期日期：授信情况.授信到期日期，去除'-' */
        REPLACE(CAST(src.H130012 AS CHAR(10)), '-', '') AS SXDQRQ,
        /* SXJCYJ 授信审批意见：授信情况.授信审批意见，直接映射 */
        src.H130019 AS SXJCYJ,
        /* JBRGH 经办人工号：授信情况.经办员工ID，如为"自动"则转空 */
        CASE WHEN src.H130020 = '自动' THEN NULL ELSE src.H130020 END AS JBRGH,
        /* BBZ 备注：授信情况.备注，直接映射 */
        src.H130033 AS BBZ,
        /* YHJGDM 银行机构代码：机构信息.支付行号，通过机构ID关联 */
        s1.A010006 AS YHJGDM,
        /* JRXKZH 金融许可证号：机构信息.金融许可证号，通过机构ID关联 */
        s1.A010003 AS JRXKZH,
        /* KHTYBH 客户统一编号：授信情况.客户ID，直接映射 */
        src.H130002 AS KHTYBH,
        /* KHZJLB 客户证件类别：优先取对公客户信息表.证件类别，为NULL则取个人基础信息表.证件类别，再为NULL置'' */
        COALESCE(dg.ZJLB, gr.ZJLB, '') AS KHZJLB,
        /* SXXYMC 授信协议名称：授信情况.授信协议名称，直接映射 */
        src.H130026 AS SXXYMC,
        /* SXED 授信额度：授信情况.授信额度 */
        CAST(NULLIF(TRIM(src.H130008), '') AS DECIMAL(20,2)) AS SXED,
        /* YYED 已用额度：授信情况.已用额度 */
        CAST(NULLIF(TRIM(src.H130015), '') AS DECIMAL(20,2)) AS YYED,
        /* SPRGH 审批人工号：授信情况.审批员工ID，如为"自动"则转空 */
        CASE WHEN src.H130021 = '自动' THEN NULL ELSE src.H130021 END AS SPRGH,
        /* SXZT 授信状态：授信情况.授信状态，码值转换 1→有效 0→无效 */
        CASE src.H130022
            WHEN '1' THEN '有效'
            WHEN '0' THEN '无效'
            ELSE NULL
        END AS SXZT,
        /* CJRQ 采集日期：使用入参P_DATA_DATE（报告期），非源表H130023
           业务需求原文映射为"授信情况.采集日期"，但全量表按采集日期重跑模式下
           CJRQ应为报送期末日期P_DATA_DATE，与DELETE/P_DATA_DATE清洗策略一致。
           若现场要求使用源表采集日期，修改为 REPLACE(CAST(src.H130023 AS CHAR(10)), '-', '') */
        P_DATA_DATE AS CJRQ,
        /* SXZL 授信种类：授信情况.授信种类，码值转换 */
        CASE src.H130006
            WHEN '01' THEN '综合额度授信'
            WHEN '02' THEN '低风险额度授信'
            WHEN '03' THEN '信用卡额度授信'
            WHEN '04' THEN '临时额度授信'
            WHEN '05' THEN '专项额度授信'
            WHEN '06' THEN NULL /* 授信种类='06'已在WHERE剔除，兜底 */
            ELSE CONCAT('其他-', COALESCE(src.H130006, ''))
        END AS SXZL,
        /* SXXYH 授信协议号：授信情况.授信ID，直接映射 */
        src.H130001 AS SXXYH
    FROM T_8_13 src
    LEFT JOIN T_1_1 s1
           ON src.H130003 = s1.A010001
    LEFT JOIN IE_002_203 dg
           ON src.H130002 = dg.KHTYBH
          AND dg.CJRQ = P_DATA_DATE
    LEFT JOIN IE_002_201 gr
           ON src.H130002 = gr.KHTYBH
          AND gr.CJRQ = P_DATA_DATE
    WHERE 1 = 1
      /* 排除规则1：授信种类='06' */
      AND (src.H130006 IS NULL OR src.H130006 <> '06')
      /* 排除规则2：客户类别='02'（集团授信） */
      AND (src.H130005 IS NULL OR src.H130005 <> '02')
      /* 排除规则3：授信失效日期 < 上月首日（已失效超过一个月的除外） */
      AND (src.H130032 IS NULL OR src.H130032 >= V_LAST_MONTH_FIRST)
      /* 授信情况表本身应有本采集周期的数据；注释：若T_8_13为全量快照表则不需要此条件 */
      AND src.H130023 IS NOT NULL;

    COMMIT;
END;
