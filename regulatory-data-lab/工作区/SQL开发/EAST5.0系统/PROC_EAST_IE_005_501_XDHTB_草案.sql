/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《028_信贷合同表.md》生成 EAST5.0 信贷合同表（IE_005_501）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/028_信贷合同表.md
- 原始材料/表结构/EAST5.0系统/IE_005_501-信贷合同表-DDL-2026-04-28.sql

源表：
- T_1_1, T_6_2

目标表：
- IE_005_501：信贷合同表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送范围应至少包括1104报表中：各项贷款+非现金管理项下委托贷款-信用卡。如，个人贷款、对公贷款、票据贴现、买断式转贴现、贸易融资业务、融资租赁业务、委托贷款（非现金管理项下）对应的业务合同，以及各项垫款对应的原业务合同。表外业务只报送委托贷款（非现金管理项下），其他不报送。信用卡业务不报送。对于票据贴现和买断式转贴现，可以填报为信贷合同号=信贷借据号=票据号码；对于其他若没有对应合同号的业务，可以填报为信贷合同号=信贷借据号=业务编号。已撤销、失效、终结的合同在报送合同最后状态的次月可不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 615 行） 取报送日期为当月，且剔除上月失效的数据

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_501_XDHTB;

CREATE PROCEDURE PROC_EAST_IE_005_501_XDHTB(
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

    DELETE FROM IE_005_501
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_501 (
        KHJLGH,
        GSFZJG,
        HTJE,
        XDYWZL,
        ZHTH,
        KHTYBH,
        SENSITIVEFLAG,
        NBJGH,
        HTDKYT,
        HTDQRQ,
        HTQSRQ,
        BZ,
        HTMC,
        XDHTH,
        KHMC,
        JRXKZH,
        BBZ,
        KHLB,
        CJRQ,
        HTZT,
        DBLX
    )
    SELECT
        /* 客户经理工号：贷款协议.管户员工ID -> T_6_2.F020058；直接映射 */
        s1.F020058 AS KHJLGH,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 合同金额：贷款协议.贷款金额 -> T_6_2.F020008；直接映射 */
        CAST(NULLIF(TRIM(s1.F020008), '') AS DECIMAL(20,2)) AS HTJE,
        /* 信贷业务种类：贷款协议.信贷业务种类 -> T_6_2.F020066；代码转化： 若为'01'[流动资金贷款]，则赋值为'流动资金贷款'； 若为'02'[法人账户透支]，则赋值为'法人账户透支'； 若为'03'[项目贷款]，则赋值为'项目贷款'； 若为'04'[项目贷款（银团）]，则赋值为'项目贷款（银团）'； 若为'05'[一般固定资产贷款]，则赋值为'一般固定资产贷款'； 若为'06'[住房按揭贷款（公转商）]、'07'[住房按揭贷款（非公转商）]，则赋值为'住房按揭贷款'； 若为'08'[个人经营性...；转换规则需人工补齐 CASE 分支 */
        s1.F020066 AS XDYWZL,
        /* 主合同号：贷款协议.协议ID -> T_6_2.F020001；直接映射 */
        s1.F020001 AS ZHTH,
        /* 客户统一编号：贷款协议.客户ID -> T_6_2.F020003；直接映射 */
        s1.F020003 AS KHTYBH,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 内部机构号：贷款协议.机构ID -> T_6_2.F020002；加工规则：从【贷款协议】.【机构ID】第12位开始截取。 */
        SUBSTR(TRIM(s1.F020002), 12) AS NBJGH,
        /* 合同贷款用途：贷款协议.贷款用途 -> T_6_2.F020010；直接映射 */
        s1.F020010 AS HTDKYT,
        /* 合同到期日期：贷款协议.贷款协议到期日期 -> T_6_2.F020049；格式转换：转字符格式'YYYYMMDD'，若取不到或为空，则赋默认值99991231。 */
        CASE WHEN s1.F020049 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(s1.F020049) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F020049) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F020049) AS VARCHAR(2)), 2, '0')) END AS HTDQRQ,
        /* 合同起始日期：贷款协议.贷款协议起始日期 -> T_6_2.F020048；格式转换：转字符格式'YYYYMMDD'，若取不到或为空，则赋默认值99991231。 */
        CASE WHEN s1.F020048 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(s1.F020048) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F020048) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F020048) AS VARCHAR(2)), 2, '0')) END AS HTQSRQ,
        /* 币种：贷款协议.协议币种 -> T_6_2.F020007；直接映射 */
        s1.F020007 AS BZ,
        /* 合同名称：贷款协议.合同名称 -> T_6_2.F020005；直接映射 */
        s1.F020005 AS HTMC,
        /* 信贷合同号：贷款协议.协议ID -> T_6_2.F020001；直接映射 */
        s1.F020001 AS XDHTH,
        /* 客户名称：待确认来源字段：EAST对公客户信息表\.EAST个人基础信息表 */
        NULL AS KHMC,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工规则：用【贷款协议】.【机构ID】关联【机构信息】.【机构ID】，取【机构信息】.【金融许可证号】 */
        src.A010003 AS JRXKZH,
        /* 备注：贷款协议.备注 -> T_6_2.F020062；加工映射：提取一表通《6.2贷款协议》备注 */
        s1.F020062 AS BBZ,
        /* 客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS KHLB,
        /* 采集日期：贷款协议.采集日期 -> T_6_2.F020063；格式转换：格式转为'YYYYMMDD'。 */
        CONCAT(CAST(YEAR(s1.F020063) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F020063) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F020063) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 合同状态：贷款协议.协议状态 -> T_6_2.F020061；代码转化： 若为'01'[正常],则赋值为'有效'; 若为'02'[待生效],则赋值为'未生效'; 若为'03'[中止],则赋值为'其他-中止'; 若为'04'[终止],则赋值为'终结'; 若为'05'[撤销],则赋值为'撤销'; 若为'06'[无效],则赋值为'其他-无效'; 若为'00-XX'，则赋值为'其他-XX'，其中“XX”为银行自定义。；转换规则需人工补齐 CASE 分支 */
        s1.F020061 AS HTZT,
        /* 担保类型：贷款协议.担保方式 -> T_6_2.F020065；加工规则： 若为'01'[质押],则赋值为'质押'; 若为'02'[抵押],则赋值为'抵押'; 若为'03'[保证],则赋值为'保证'; 若为'04'[信用],则赋值为'信用'; 若为('05'[抵押+质押+其他],'06'[抵押+保证（或信用）],'07'[ 质押+保证（或信用）],'08'[保证+信用]),则赋值为'混合'; 若为'00-XX'，则赋值为'其他-XX'，其中“XX”为银行自定义。 */
        s1.F020065 AS DBLX
    FROM T_1_1 src
    LEFT JOIN T_6_2 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《028_信贷合同表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
