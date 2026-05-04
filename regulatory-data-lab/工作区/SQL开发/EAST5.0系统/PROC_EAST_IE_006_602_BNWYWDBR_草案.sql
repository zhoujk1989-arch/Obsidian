/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《042_表内外业务担保人.md》生成 EAST5.0 表内外业务担保人（IE_006_602）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/042_表内外业务担保人.md
- 原始材料/表结构/EAST5.0系统/IE_006_602-表内外业务担保人-DDL-2026-04-28.sql

源表：
- T_6_8, T_10_1, T_1_1

目标表：
- IE_006_602：表内外业务担保人。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 担保合同中约定的担保人信息。同一份担保合同有多个担保人的，每个担保人填写一条记录。失效担保合同的担保人于次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1002 行） 取报送日期为当月，通过取不为抵质押类型且在生成EAST《表内外业务担保合同表》中报送的担保合同号作为报送范围

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_006_602_BNWYWDBR;

CREATE PROCEDURE PROC_EAST_IE_006_602_BNWYWDBR(
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

    DELETE FROM IE_006_602
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_006_602 (
        SENSITIVEFLAG,
        BZRMC,
        CJRQ,
        JRXKZH,
        DBHTH,
        BBZ,
        DBRZJLB,
        DBRJZC,
        DBRZJHM,
        NBJGH,
        BZRLB,
        GSFZJG,
        DBRJZCBZ,
        DBHTZT
    )
    SELECT
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 担保人名称：担保协议.担保人名称 -> T_6_8.F080009；直接映射 */
        src.F080009 AS BZRMC,
        /* 采集日期：担保协议.采集日期 -> T_6_8.F080025；格式转换：格式转为'YYYYMMDD'。 */
        CONCAT(CAST(YEAR(src.F080025) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F080025) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F080025) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工映射：【表内外业务担保合同表】按照【担保合同号】分组取最小的【内部机构号】，然后与【机构信息】.【机构ID】关联取【金融许可证号】。 */
        s2.A010003 AS JRXKZH,
        /* 担保合同号：担保协议.协议ID -> T_6_8.F080001；直接映射 */
        src.F080001 AS DBHTH,
        /* 备注：担保协议.备注 -> T_6_8.F080024；提取一表通《表6.8担保协议》备注，以“;”拼接。 */
        src.F080024 AS BBZ,
        /* 担保人证件类别：待确认来源字段：担保协议\.公共代码 */
        NULL AS DBRZJLB,
        /* 担保人净资产：担保协议.担保人净资产 -> T_6_8.F080018；直接映射 */
        CAST(NULLIF(TRIM(src.F080018), '') AS DECIMAL(20,2)) AS DBRJZC,
        /* 担保人证件号码：担保协议.担保人证件号码 -> T_6_8.F080011；直接映射 */
        src.F080011 AS DBRZJHM,
        /* 内部机构号：待确认来源字段：担保协议.机构id */
        NULL AS NBJGH,
        /* 担保人类别：担保协议.担保人类别 -> T_6_8.F080008；代码转换：01转对公，02转个人，其他用''；转换规则需人工补齐 CASE 分支 */
        src.F080008 AS BZRLB,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 担保人净资产币种：担保协议.担保人净资产币种 -> T_6_8.F080017；直接映射 */
        src.F080017 AS DBRJZCBZ,
        /* 担保合同状态：担保协议.协议状态 -> T_6_8.F080019；加工映射：【表内外业务担保合同表】按照【担保合同号】分组取最大的【担保合同状态】 */
        src.F080019 AS DBHTZT
    FROM T_6_8 src
    LEFT JOIN T_10_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_1_1 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《042_表内外业务担保人.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
