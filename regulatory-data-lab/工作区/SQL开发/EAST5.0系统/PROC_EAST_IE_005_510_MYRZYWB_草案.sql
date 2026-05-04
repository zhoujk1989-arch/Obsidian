/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《037_贸易融资业务表.md》生成 EAST5.0 贸易融资业务表（IE_005_510）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/037_贸易融资业务表.md
- 原始材料/表结构/EAST5.0系统/IE_005_510-贸易融资业务表-DDL-2026-04-28.sql

源表：
- T_6_10

目标表：
- IE_005_510：贸易融资业务表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 填报机构对非金融机构提供的贸易项下的融资或信用便利的余额,包括打包贷款、押汇、保理、议付信用证、买方信贷、卖方信贷、福费廷等业务。本行开出的保函及信用证在保函及信用证表中报送，不在本表中填报。贷款状态为结清、核销、转让的，于次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 896 行） 通过生成EAST对公信贷业务借据表的信贷借据号关联贸易融资协议的借据ID筛选出报送范围

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_510_MYRZYWB;

CREATE PROCEDURE PROC_EAST_IE_005_510_MYRZYWB(
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

    DELETE FROM IE_005_510
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_510 (
        GHFMC,
        ZFDXMC,
        SXFBZ,
        SXFJE,
        BZJBL,
        BZJJE,
        BBZ,
        GSFZJG,
        HKRQ,
        MYRZJE,
        MYRZPZ,
        XDHTH,
        NBJGH,
        JRXKZH,
        CJRQ,
        BZJZH,
        DKZT,
        BZJBZ,
        HKDXMC,
        MYJYBJ,
        KZHMC,
        XHFMC,
        FKRQ,
        BZ,
        XDJJH,
        YHJGMC,
        SENSITIVEFLAG
    )
    SELECT
        /* 购货方名称：贸易融资协议.购货方名称 -> T_6_10.F100009；直接映射 */
        src.F100009 AS GHFMC,
        /* 支付对象名称：贸易融资协议.支付对象名称 -> T_6_10.F100013；直接映射 */
        src.F100013 AS ZFDXMC,
        /* 手续费币种：贸易融资协议.手续费币种 -> T_6_10.F100014；直接映射 */
        src.F100014 AS SXFBZ,
        /* 手续费金额：贸易融资协议.手续费金额 -> T_6_10.F100015；直接映射 */
        CAST(NULLIF(TRIM(src.F100015), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 保证金比例：贸易融资协议.保证金比例 -> T_6_10.F100017；直接映射 */
        CAST(NULLIF(TRIM(src.F100017), '') AS DECIMAL(20,2)) AS BZJBL,
        /* 保证金金额：贸易融资协议.保证金金额 -> T_6_10.F100019；直接映射 */
        CAST(NULLIF(TRIM(src.F100019), '') AS DECIMAL(20,2)) AS BZJJE,
        /* 备注：贸易融资协议.备注 -> T_6_10.F100025；提取一表通《表6.10贸易融资协议》备注，以“;”拼接。 */
        src.F100025 AS BBZ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 融资还款日期：贸易融资协议.到期日期 -> T_6_10.F100008；加工映射：需转成'YYYYMMDD'格式 */
        CONCAT(CAST(YEAR(src.F100008) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F100008) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F100008) AS VARCHAR(2)), 2, '0')) AS HKRQ,
        /* 贸易融资金额：贸易融资协议.实际支付金额 -> T_6_10.F100027；直接映射 */
        CAST(NULLIF(TRIM(src.F100027), '') AS DECIMAL(20,2)) AS MYRZJE,
        /* 贸易融资品种：贸易融资协议.贸易融资品种 -> T_6_10.F100005；加工映射： CASE WHEN 【贸易融资协议】.【贸易融资品种】 = '01' THEN '买方押汇' WHEN 【贸易融资协议】.【贸易融资品种】 = '02' THEN '卖方押汇' WHEN 【贸易融资协议】.【贸易融资品种】 = '03' THEN '议付' WHEN 【贸易融资协议】.【贸易融资品种】 = '04' THEN '打包贷款' WHEN 【贸易融资协议】.【贸易融资品种】 = '05' THEN '进口信用证押汇...；转换规则需人工补齐 CASE 分支 */
        src.F100005 AS MYRZPZ,
        /* 信贷合同号：贸易融资协议.协议ID -> T_6_10.F100002；直接映射 */
        src.F100002 AS XDHTH,
        /* 内部机构号：待确认来源字段：EAST对公信贷业务借据表.内部机构号 */
        NULL AS NBJGH,
        /* 金融许可证号：待确认来源字段：EAST对公信贷业务借据表.金融许可证号 */
        NULL AS JRXKZH,
        /* 采集日期：贸易融资协议.采集日期 -> T_6_10.F100026；默认值：报告日，数据格式转成yyyymmdd */
        CONCAT(CAST(YEAR(src.F100026) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F100026) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F100026) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 保证金账号：贸易融资协议.保证金账号 -> T_6_10.F100016；直接映射 */
        src.F100016 AS BZJZH,
        /* 贷款状态：待确认来源字段：EAST对公信贷业务借据表.贷款状态 */
        NULL AS DKZT,
        /* 保证金币种：贸易融资协议.保证金币种 -> T_6_10.F100018；直接映射 */
        src.F100018 AS BZJBZ,
        /* 还款对象名称：贸易融资协议.还款对象名称 -> T_6_10.F100024；直接映射 */
        src.F100024 AS HKDXMC,
        /* 贸易交易内容：贸易融资协议.贸易交易内容 -> T_6_10.F100011；直接映射 */
        src.F100011 AS MYJYBJ,
        /* 开证行名称：贸易融资协议.开证行名称 -> T_6_10.F100012；直接映射 */
        src.F100012 AS KZHMC,
        /* 销货方名称：贸易融资协议.销货方名称 -> T_6_10.F100010；直接映射 */
        src.F100010 AS XHFMC,
        /* 融资发放日期：贸易融资协议.发放日期 -> T_6_10.F100007；加工映射：需转成'YYYYMMDD'格式 */
        CONCAT(CAST(YEAR(src.F100007) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F100007) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F100007) AS VARCHAR(2)), 2, '0')) AS FKRQ,
        /* 币种：贸易融资协议.协议币种 -> T_6_10.F100004；直接映射 */
        src.F100004 AS BZ,
        /* 信贷借据号：贸易融资协议.借据ID -> T_6_10.F100028；直接映射 */
        src.F100028 AS XDJJH,
        /* 银行机构名称：待确认来源字段：EAST对公信贷业务借据表.银行机构名称 */
        NULL AS YHJGMC,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG
    FROM T_6_10 src
    WHERE 1 = 1
      /* TODO: 按《037_贸易融资业务表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
