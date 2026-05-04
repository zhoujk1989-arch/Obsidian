/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《036_票据转贴现表.md》生成 EAST5.0 票据转贴现表（IE_005_509）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/036_票据转贴现表.md
- 原始材料/表结构/EAST5.0系统/IE_005_509-票据转贴现表-DDL-2026-04-28.sql

源表：
- T_1_1, T_6_14

目标表：
- IE_005_509：票据转贴现表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送本行发生的转贴现买断、转贴现卖断、质押式回购正回购、质押式回购逆回购、买断式回购正回购、买断式回购逆回购、再贴现等业务的明细信息。票据状态为“卖断”、“解付”或“核销”的数据，在报送票据最后状态的次月可不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 864 行） 取日期在当月且剔除上月状态为失效的数据

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_509_PJZTXB;

CREATE PROCEDURE PROC_EAST_IE_005_509_PJZTXB(
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

    DELETE FROM IE_005_509
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_509 (
        BBZ,
        YHJGMC,
        ZTXLX,
        SENSITIVEFLAG,
        JRXKZH,
        NBJGH,
        XDHTH,
        PJHM,
        PJLX,
        PMJE,
        CPRMC,
        TXRMC,
        TXRQ,
        JYFX,
        ZTXRQ,
        ZTXJE,
        ZTXLL,
        HGLV,
        JYDSMC,
        PJZT,
        CJRQ,
        GSFZJG,
        XDJJH,
        BZ,
        PJCPRQ,
        PJDQRQ,
        CDRMC,
        ZTXLB,
        ZTXJXTS,
        HGRQ,
        HGJE,
        HGLX,
        JYDSHH
    )
    SELECT
        /* 备注：票据转贴现协议.备注 -> T_6_14.F140034；提取一表通《表6.14票据转贴现协议》备注，以“;”拼接。 */
        s1.F140034 AS BBZ,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        src.A010005 AS YHJGMC,
        /* 转贴现利息：票据转贴现协议.转贴现利息 -> T_6_14.F140021；直接映射 */
        CAST(NULLIF(TRIM(s1.F140021), '') AS DECIMAL(20,2)) AS ZTXLX,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        src.A010003 AS JRXKZH,
        /* 内部机构号：票据转贴现协议.机构ID -> T_6_14.F140002；加工映射：SUBSTR(机构ID,12) */
        s1.F140002 AS NBJGH,
        /* 信贷合同号：票据转贴现协议.协议ID -> T_6_14.F140001；直接映射 */
        s1.F140001 AS XDHTH,
        /* 票据号码：票据转贴现协议.票据号码 -> T_6_14.F140003；直接映射 */
        s1.F140003 AS PJHM,
        /* 票据类型：票据转贴现协议.票据类型 -> T_6_14.F140004；加工映射：CASE WHEN T1.票据类型 = '01' THEN '银行承兑汇票' WHEN T1.票据类型 = '02' THEN '商业承兑汇票' WHEN T1.票据类型 = '03' THEN '财务公司承兑汇票' ELSE '' END；转换规则需人工补齐 CASE 分支 */
        s1.F140004 AS PJLX,
        /* 票面金额：票据转贴现协议.票面金额 -> T_6_14.F140006；直接映射 */
        CAST(NULLIF(TRIM(s1.F140006), '') AS DECIMAL(20,2)) AS PMJE,
        /* 出票人名称：票据转贴现协议.出票人名称 -> T_6_14.F140009；直接映射 */
        s1.F140009 AS CPRMC,
        /* 贴现人名称：票据转贴现协议.贴现人名称 -> T_6_14.F140011；直接映射 */
        s1.F140011 AS TXRMC,
        /* 贴现日期：票据转贴现协议.贴现日期 -> T_6_14.F140012；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F140012) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F140012) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F140012) AS VARCHAR(2)), 2, '0')) AS TXRQ,
        /* 交易方向：票据转贴现协议.交易方向 -> T_6_14.F140013；代码转化：CASE WHEN T1.JYFX = '01' THEN '买入' WHEN T1.JYFX = '02' THEN '卖出' ELSE '' END；转换规则需人工补齐 CASE 分支 */
        s1.F140013 AS JYFX,
        /* 转贴现日期：票据转贴现协议.转贴现日期 -> T_6_14.F140017；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F140017) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F140017) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F140017) AS VARCHAR(2)), 2, '0')) AS ZTXRQ,
        /* 转贴现金额：票据转贴现协议.转贴现金额 -> T_6_14.F140018；直接映射 */
        CAST(NULLIF(TRIM(s1.F140018), '') AS DECIMAL(20,2)) AS ZTXJE,
        /* 转贴现利率：票据转贴现协议.转贴现利率 -> T_6_14.F140020；直接映射 */
        CAST(NULLIF(TRIM(s1.F140020), '') AS DECIMAL(20,6)) AS ZTXLL,
        /* 回购利率：票据转贴现协议.回购利率 -> T_6_14.F140024；直接映射 */
        CAST(NULLIF(TRIM(s1.F140024), '') AS DECIMAL(20,6)) AS HGLV,
        /* 交易对手名称：票据转贴现协议.交易对手名称 -> T_6_14.F140026；直接映射 */
        s1.F140026 AS JYDSMC,
        /* 票据状态：票据转贴现协议.票据状态 -> T_6_14.F140033；代码转化：CASE WHEN T1.PJZT = '01' THEN '正常' WHEN T1.PJZT = '02' THEN '卖断' WHEN T1.PJZT = '03' THEN '解付' WHEN T1.PJZT = '04' THEN '垫款' WHEN T1.PJZT = '05' THEN '核销' WHEN T1.PJZT = '00-XX' THEN '其他-XX XX为银行自定义；转换规则需人工补齐 CASE 分支 */
        s1.F140033 AS PJZT,
        /* 采集日期：票据转贴现协议.采集日期 -> T_6_14.F140035；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F140035) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F140035) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F140035) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 信贷借据号：票据转贴现协议.借据ID -> T_6_14.F140037；直接映射 */
        s1.F140037 AS XDJJH,
        /* 币种：票据转贴现协议.协议币种 -> T_6_14.F140005；直接映射 */
        s1.F140005 AS BZ,
        /* 票据出票日期：票据转贴现协议.票据签发日期 -> T_6_14.F140007；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F140007) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F140007) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F140007) AS VARCHAR(2)), 2, '0')) AS PJCPRQ,
        /* 票据到期日期：票据转贴现协议.票据到期日期 -> T_6_14.F140008；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F140008) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F140008) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F140008) AS VARCHAR(2)), 2, '0')) AS PJDQRQ,
        /* 承兑人名称：票据转贴现协议.承兑人名称 -> T_6_14.F140010；直接映射 */
        s1.F140010 AS CDRMC,
        /* 转贴现类别：待确认来源字段：票据转贴现协议.转贴现类别 */
        NULL AS ZTXLB,
        /* 转贴现计息天数：票据转贴现协议.转贴现计息天数 -> T_6_14.F140019；直接映射 */
        s1.F140019 AS ZTXJXTS,
        /* 回购日期：票据转贴现协议.回购日期 -> T_6_14.F140022；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F140022) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F140022) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F140022) AS VARCHAR(2)), 2, '0')) AS HGRQ,
        /* 回购金额：票据转贴现协议.回购金额 -> T_6_14.F140023；直接映射 */
        CAST(NULLIF(TRIM(s1.F140023), '') AS DECIMAL(20,2)) AS HGJE,
        /* 回购利息：票据转贴现协议.回购利息 -> T_6_14.F140025；直接映射 */
        CAST(NULLIF(TRIM(s1.F140025), '') AS DECIMAL(20,2)) AS HGLX,
        /* 交易对手行号：票据转贴现协议.交易对手账号行号 -> T_6_14.F140027；直接映射 */
        s1.F140027 AS JYDSHH
    FROM T_1_1 src
    LEFT JOIN T_6_14 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《036_票据转贴现表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
