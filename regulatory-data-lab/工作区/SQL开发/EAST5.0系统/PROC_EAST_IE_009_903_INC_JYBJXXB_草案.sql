/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《055_交易背景信息表.md》生成 EAST5.0 交易背景信息表（IE_009_903_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/055_交易背景信息表.md
- 原始材料/表结构/EAST5.0系统/IE_009_903_INC-交易背景信息表-DDL-2026-04-28.sql

源表：
- T_9_4, T_6_11, T_6_13, T_6_10, T_1_1

目标表：
- IE_009_903_INC：交易背景信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 填报承兑汇票、保函、信用证、保理融资等业务为审查交易背景真实性收集的发票、仓单、提单等信息，以能采尽采的原则，每月报送新收集的单据信息。报送范围：本行开出的票据（同《票据出票信息表》），本行开立的保函和信用证（同《保函与信用证表》），保理融资业务（同《贸易融资业务表》），其中非基于企业间贸易的保函可以不报送，业务尚未收集发票的暂时不报送。非本行开立的票据、保函、信用证的单据信息如未收集发票信息的可以不报送。同一票据或合同下对应的多个单据，以单据编号为最小粒度逐条报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1349 行） 主表：【商业单据】T1 过滤条件：采集日期 = 报告日 内关联子查询：（ select 【协议与单据对应关系】所有字段 from 【协议与单据对应关系】 T1 left join 【贷款协议】 DK on T1.协议ID = DK.协议ID and T1.采集日期 = DK.采集日期 and DK.贷款协议起始日期 在本月 left join 【协议与单据对应关系】LST 上月末 协议ID、单据ID on T1.协议ID = LST.协议ID and T1.单据ID = LST.单据ID where T1.采集日期 = 报告日 且 （DK.协议ID非空 或 LST.协议ID为空） /*本月生效合同 或 上月未报送过* / ）T11 关联条件：T1.单据ID = TT1.单据ID 且 T1.协议ID = TT1.协议ID 且 T1.采集日期 = TT1.采集日期 且 TT1.业务种类 in （'03','08','09','10','00'） /*限制为保理融资、承兑汇票、保函、信用证、其他业务* /

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_009_903_INC_JYBJXXB;

CREATE PROCEDURE PROC_EAST_IE_009_903_INC_JYBJXXB(
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

    DELETE FROM IE_009_903_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_009_903_INC (
        DJBH,
        DJBZ,
        YWZL,
        NBJGH,
        SENSITIVEFLAG,
        JRXKZH,
        YHJGMC,
        DJJE,
        BBZ,
        CJRQ,
        GSFZJG,
        PJHHTH,
        DJZL,
        BZ,
        HTJE
    )
    SELECT
        /* 单据编号：商业单据.单据ID -> T_9_4.J040001；直接映射 */
        src.J040001 AS DJBH,
        /* 单据币种：商业单据.商业单据币种 -> T_9_4.J040004；直接映射 */
        src.J040004 AS DJBZ,
        /* 业务种类：待确认来源字段：协议与单据对应关系.业务种类 */
        NULL AS YWZL,
        /* 内部机构号：商业单据.机构ID -> T_9_4.J040002；加工映射：SUBSTR(机构ID,12) */
        src.J040002 AS NBJGH,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        s4.A010003 AS JRXKZH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        s4.A010005 AS YHJGMC,
        /* 单据金额：商业单据.商业单据金额 -> T_9_4.J040005；直接映射 */
        CAST(NULLIF(TRIM(src.J040005), '') AS DECIMAL(20,2)) AS DJJE,
        /* 备注：待确认来源字段：商业单据<br>协议与单据对应关系<br>贷款协议<br>票据协议<br>信用证协议<br>保函与其他协议<br>贸易融资协议.商业单据：备注<br>协议与单据对应关系：备注<br>票据协议：备注<br>信用证协议：备注<br>保函与其他协议：备注<br>贸易融资协议：备注 */
        NULL AS BBZ,
        /* 采集日期：商业单据.采集日期 -> T_9_4.J040008；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(src.J040008) AS VARCHAR(4)), LPAD(CAST(MONTH(src.J040008) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.J040008) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 业务编号：待确认来源字段：协议与单据对应关系.协议ID */
        NULL AS PJHHTH,
        /* 单据种类：商业单据.商业单据种类 -> T_9_4.J040006；加工映射：CASE WHEN T1.商业单据种类 = '01' THEN '商业发票' WHEN T1.商业单据种类 = '02' THEN '增值税发票' WHEN T1.商业单据种类 = '03' THEN '证实发票' WHEN T1.商业单据种类 = '04' THEN '收妥发票' WHEN T1.商业单据种类 = '05' THEN '厂商发票' WHEN T1.商业单据种类 = '06' THEN '形式发票' WHEN ...；转换规则需人工补齐 CASE 分支 */
        src.J040006 AS DJZL,
        /* 币种：信用证协议.协议币种 -> T_6_11.F110008；加工映射：通过协议ID关联【信用证协议/保函协议/票据协议/贸易融资协议】，获取其协议币种 */
        s1.F110008 AS BZ,
        /* 合同金额：信用证协议.开证金额 -> T_6_11.F110009；加工映射：通过协议ID关联【信用证协议/保函协议/票据协议/贸易融资协议】，获取其【开证金额/保函金额/票据金额/贸易融资金额】 */
        CAST(NULLIF(TRIM(s1.F110009), '') AS DECIMAL(20,2)) AS HTJE
    FROM T_9_4 src
    LEFT JOIN T_6_11 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_6_13 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_6_10 s3
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s3 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_1_1 s4
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s4 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《055_交易背景信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
