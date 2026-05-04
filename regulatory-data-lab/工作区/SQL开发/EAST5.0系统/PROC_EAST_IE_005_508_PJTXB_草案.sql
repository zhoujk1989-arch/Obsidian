/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《035_票据贴现表.md》生成 EAST5.0 票据贴现表（IE_005_508）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/035_票据贴现表.md
- 原始材料/表结构/EAST5.0系统/IE_005_508-票据贴现表-DDL-2026-04-28.sql

源表：
- T_1_1, T_6_13

目标表：
- IE_005_508：票据贴现表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 填报机构对客户办理的商业票据贴现，不包括对金融机构办理的买断式转贴现业务。票据状态为“卖断”、“解付”或“核销”的数据，在报送票据最后状态的次月可不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 838 行） 取日期在当月且剔除上月状态为失效的数据

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_508_PJTXB;

CREATE PROCEDURE PROC_EAST_IE_005_508_PJTXB(
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

    DELETE FROM IE_005_508
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_508 (
        TXRZH,
        SENSITIVEFLAG,
        CJRQ,
        CDRMC,
        PJDQRQ,
        PJCPRQ,
        BZ,
        PJHM,
        YHJGMC,
        JRXKZH,
        CPRMC,
        PMJE,
        PJLX,
        XDJJH,
        XDHTH,
        NBJGH,
        PJZT,
        TXL,
        TXRKHHMC,
        TXRMC,
        BBZ,
        TXLX,
        TXJXTS,
        GSFZJG,
        TXRQ,
        TXJE,
        TXRKHTYBH
    )
    SELECT
        /* 贴现人账号：票据协议.贴现人账号 -> T_6_13.F130027；直接映射 */
        s1.F130027 AS TXRZH,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 采集日期：票据协议.采集日期 -> T_6_13.F130049；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F130049) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F130049) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F130049) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 承兑人名称：票据协议.承兑人名称 -> T_6_13.F130007；直接映射 */
        s1.F130007 AS CDRMC,
        /* 票据到期日期：票据协议.票据到期日期 -> T_6_13.F130037；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F130037) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F130037) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F130037) AS VARCHAR(2)), 2, '0')) AS PJDQRQ,
        /* 票据出票日期：票据协议.票据签发日期 -> T_6_13.F130036；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F130036) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F130036) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F130036) AS VARCHAR(2)), 2, '0')) AS PJCPRQ,
        /* 币种：票据协议.协议币种 -> T_6_13.F130019；直接映射 */
        s1.F130019 AS BZ,
        /* 票据号码：票据协议.票据号码 -> T_6_13.F130016；直接映射 */
        s1.F130016 AS PJHM,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        src.A010005 AS YHJGMC,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        src.A010003 AS JRXKZH,
        /* 出票人名称：票据协议.出票人名称 -> T_6_13.F130005；直接映射 */
        s1.F130005 AS CPRMC,
        /* 票面金额：票据协议.票面金额 -> T_6_13.F130020；直接映射 */
        CAST(NULLIF(TRIM(s1.F130020), '') AS DECIMAL(20,2)) AS PMJE,
        /* 票据类型：票据协议.票据类型 -> T_6_13.F130015；加工映射：CASE WHEN T1.票据类型 = '01' THEN '银行承兑汇票' WHEN T1.票据类型 = '02' THEN '商业承兑汇票' WHEN T1.票据类型 = '03' THEN '财务公司承兑汇票' ELSE '' END；转换规则需人工补齐 CASE 分支 */
        s1.F130015 AS PJLX,
        /* 信贷借据号：票据协议.借据ID -> T_6_13.F130052；直接映射 */
        s1.F130052 AS XDJJH,
        /* 信贷合同号：票据协议.协议ID -> T_6_13.F130001；直接映射 */
        s1.F130001 AS XDHTH,
        /* 内部机构号：票据协议.机构ID -> T_6_13.F130003；加工映射：SUBSTR(机构ID,12) */
        s1.F130003 AS NBJGH,
        /* 票据状态：票据协议.票据状态 -> T_6_13.F130047；代码转化：CASE WHEN T1.PJZT = '01' THEN '正常' WHEN T1.PJZT = '02' THEN '卖断' WHEN T1.PJZT = '03' THEN '解付' WHEN T1.PJZT = '04' THEN '垫款' WHEN T1.PJZT = '05' THEN '核销' 当票据状态为'00-XX'时，赋值为'其他-XX'，其中'XX'为银行自定义；转换规则需人工补齐 CASE 分支 */
        s1.F130047 AS PJZT,
        /* 贴现利率：票据协议.贴现利率 -> T_6_13.F130032；直接映射 */
        CAST(NULLIF(TRIM(s1.F130032), '') AS DECIMAL(20,6)) AS TXL,
        /* 贴现人开户行名称：票据协议.贴现人开户行名称 -> T_6_13.F130028；直接映射 */
        s1.F130028 AS TXRKHHMC,
        /* 贴现人名称：票据协议.贴现客户名称 -> T_6_13.F130026；直接映射 */
        s1.F130026 AS TXRMC,
        /* 备注：票据协议.备注 -> T_6_13.F130048；加工映射：提取一表通《6.13票据协议》备注。 */
        s1.F130048 AS BBZ,
        /* 贴现利息：票据协议.贴现利息 -> T_6_13.F130033；直接映射 */
        CAST(NULLIF(TRIM(s1.F130033), '') AS DECIMAL(20,2)) AS TXLX,
        /* 贴现计息天数：票据协议.贴现计息天数 -> T_6_13.F130031；直接映射 */
        s1.F130031 AS TXJXTS,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 贴现日期：票据协议.贴现日期 -> T_6_13.F130030；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F130030) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F130030) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F130030) AS VARCHAR(2)), 2, '0')) AS TXRQ,
        /* 贴现金额：票据协议.贴现金额 -> T_6_13.F130029；直接映射 */
        CAST(NULLIF(TRIM(s1.F130029), '') AS DECIMAL(20,2)) AS TXJE,
        /* 贴现人客户统一编号：票据协议.客户ID -> T_6_13.F130004；直接映射 */
        s1.F130004 AS TXRKHTYBH
    FROM T_1_1 src
    LEFT JOIN T_6_13 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《035_票据贴现表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
