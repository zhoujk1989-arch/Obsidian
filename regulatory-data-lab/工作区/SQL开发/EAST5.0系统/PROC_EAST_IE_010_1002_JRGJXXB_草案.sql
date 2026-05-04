/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《059_金融工具信息表.md》生成 EAST5.0 金融工具信息表（IE_010_1002）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/059_金融工具信息表.md
- 原始材料/表结构/EAST5.0系统/IE_010_1002-金融工具信息表-DDL-2026-04-28.sql

源表：
- T_9_2, T_9_1, T_1_1

目标表：
- IE_010_1002：金融工具信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 记录《自营资金交易信息表》和《自营资金业务余额表》中所有业务对应的标的物。债券、非标准化债权类资产等以产品为单位的标的物，以单一产品为金融工具；同业拆放、存放同业等以对某机构为单位的业务，以对某机构为单一金融工具，如：金融工具名称为“存放XX银行”。已结清（余额为0）/赎回/终结的业务在报送最后状态的次月不再报送。同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报基础资产相关信息，基础资产如对应多个，按多条报送。票据业务不在本表报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1429 行） 主表：【表9.2投融资标的】 左关联：【表1.1机构信息】 关联条件：【表9.2投融资标的】【机构ID】关联【机构信息】【机构ID】 左关联：【表9.1投资标的关系】 关联条件：【表9.2投融资标的】【投融资标的ID】关联【表9.1投资标的关系】【投资标的ID】 过滤条件：不包含【表8.7同业存量情况】【自营业务小类】为结算性存放同业、非结算性同业存放、结算性同业存放数据的【投融资标的ID】 并且（（只报送【表9.2投融资标的】【投融资标的代码】或【表9.2投融资标的】【投融资标的ID】在 自营资金交易信息表、自营资金业务余额表范围内） 或者 （【表9.2投融资标的】【失效日期】大于等于当月月初日期））

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_010_1002_JRGJXXB;

CREATE PROCEDURE PROC_EAST_IE_010_1002_JRGJXXB(
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

    DELETE FROM IE_010_1002
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_010_1002 (
        JCZCKHPJJG,
        BBZ,
        ZZTXHY,
        JCZCHKHHY,
        JCZCKHPJ,
        JCZCKHGJ,
        JCZCKHMC,
        JCZCPJ,
        JCZCZB,
        JCZCMC,
        SJLL,
        DQRQ,
        FXGB,
        FXJGMC,
        FXZGM,
        FXJG,
        ZCLX,
        JRGJMC,
        ZJPGJG,
        JRGJBH,
        NBJGH,
        JRXKZH,
        CJRQ,
        ZZTXLX,
        JCZCPJJG,
        JCZCBH,
        PGJGRQ,
        GSFZJG,
        SENSITIVEFLAG,
        JCZCGM,
        YHJGMC,
        BZ,
        FXJGDM,
        FXRQ,
        LLLX,
        HQBS
    )
    SELECT
        /* 基础资产客户评级机构：投融资标的.基础资产客户评级机构 -> T_9_2.J020029；直接映射 */
        src.J020029 AS JCZCKHPJJG,
        /* 备注：投融资标的.备注 -> T_9_2.J020104；加工映射：提取一表通《9.2投融资标的》、《9.1投资标的关系》备注，以“；”拼接。 */
        src.J020104 AS BBZ,
        /* 最终投向行业：投融资标的.基础资产最终投向行业类型 -> T_9_2.J020034；加工映射：当【投融资标的】.【基础资产最终投向行业类型】为'99999'时赋值'境外'，否则取【投融资标的】.【基础资产最终投向行业类型】 */
        src.J020034 AS ZZTXHY,
        /* 基础资产客户行业：投融资标的.基础资产客户行业类型 -> T_9_2.J020030；加工映射：当【投融资标的】.【基础资产客户行业类型】为'99999'时赋值'境外'，否则取【投资标的】.【基础资产客户行业类型】 */
        src.J020030 AS JCZCHKHHY,
        /* 基础资产客户评级：投融资标的.基础资产客户评级 -> T_9_2.J020028；直接映射 */
        src.J020028 AS JCZCKHPJ,
        /* 基础资产客户国家：投融资标的.基础资产客户国家 -> T_9_2.J020027；代码映射：关联BS_CS_GGDM使用【表名 BM】为'通用'并且【字段名ZDM】为‘国家地区’,取【中文含义ZWHY】 */
        src.J020027 AS JCZCKHGJ,
        /* 基础资产客户名称：投融资标的.基础资产客户名称 -> T_9_2.J020026；直接映射 */
        src.J020026 AS JCZCKHMC,
        /* 基础资产评级：投融资标的.基础资产外部评级 -> T_9_2.J020031；加工映射：先取【基础资产外部评级】，取不到则取【基础资产内部评级】 */
        src.J020031 AS JCZCPJ,
        /* 基础资产占比：投资标的关系.占上一层投资标的比例 -> T_9_1.J010005；直接映射 */
        CAST(NULLIF(TRIM(s1.J010005), '') AS DECIMAL(20,2)) AS JCZCZB,
        /* 基础资产名称：待确认来源字段：投融资标的.投资标的名称 */
        NULL AS JCZCMC,
        /* 实际利率：待确认来源字段：投融资标的.利率/收益率 */
        NULL AS SJLL,
        /* 到期日期：投融资标的.到期日期 -> T_9_2.J020016；加工映射:将【投融资标的】.【到期日期】格式由yyyy-mm-dd转为yyyymmdd,如果空则赋值:'99991231' */
        CASE WHEN src.J020016 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.J020016) AS VARCHAR(4)), LPAD(CAST(MONTH(src.J020016) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.J020016) AS VARCHAR(2)), 2, '0')) END AS DQRQ,
        /* 发行国别：投融资标的.发行国家地区 -> T_9_2.J020009；直接映射 */
        src.J020009 AS FXGB,
        /* 发行机构名称：投融资标的.发行机构名称 -> T_9_2.J020006；直接映射 */
        src.J020006 AS FXJGMC,
        /* 发行总规模：投融资标的.发行规模 -> T_9_2.J020005；直接映射 */
        CAST(NULLIF(TRIM(src.J020005), '') AS DECIMAL(20,2)) AS FXZGM,
        /* 发行价格：投融资标的.发行价格 -> T_9_2.J020004；直接映射 */
        CAST(NULLIF(TRIM(src.J020004), '') AS DECIMAL(20,2)) AS FXJG,
        /* 资产类型：投融资标的.投融资标的类别 -> T_9_2.J020021；代码映射：【投融资标的的】.【投资标的类别】关联【代码映射表 TA99_CODE_REF_H】.【源代码 SrcCd】,使用【规则编号 RnvRuleNo】为'YBT-EAST-ZCLX',取【代码映射表 TA99_CODE_REF_H】.【目标代码描述 TargetCdDsc】；'0000-自定义'-'其他-自定义' */
        src.J020021 AS ZCLX,
        /* 金融工具名称：待确认来源字段：投融资标的.投资标的名称 */
        NULL AS JRGJMC,
        /* 最近评估价格：投融资标的.最近评估价格 -> T_9_2.J020019；直接映射 */
        CAST(NULLIF(TRIM(src.J020019), '') AS DECIMAL(20,2)) AS ZJPGJG,
        /* 金融工具编号：投融资标的.投融资标的代码 -> T_9_2.J020011；加工映射：优先取投融资标的代码，取不到再取投融资标的ID */
        src.J020011 AS JRGJBH,
        /* 内部机构号：投融资标的.机构ID -> T_9_2.J020003；截取12位以后 */
        src.J020003 AS NBJGH,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        s2.A010003 AS JRXKZH,
        /* 采集日期：投融资标的.采集日期 -> T_9_2.J020105；直接映射:yyyy-mm-dd转为yyyymmdd */
        CONCAT(CAST(YEAR(src.J020105) AS VARCHAR(4)), LPAD(CAST(MONTH(src.J020105) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.J020105) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 最终投向类型：投融资标的.基础资产最终投向类型 -> T_9_2.J020033；代码映射：代码转中文描述 01-货币市场工具及货币市场公募基金 02-债券及债券公募基金 03-存款 04-信贷类投资 05-权益类投资及股票公募基金 00-自定义 - 其他-自定义 */
        src.J020033 AS ZZTXLX,
        /* 基础资产评级机构：投融资标的.基础资产评级机构 -> T_9_2.J020032；优先使用外部评级机构，若无外部评级机构，填报内部评级机构名称（各银行内部评级机构，可为固定值）。若两者均无的，置为空。 */
        src.J020032 AS JCZCPJJG,
        /* 基础资产编号：待确认来源字段：投融资标的.投资标的代码 */
        NULL AS JCZCBH,
        /* 评估价格日期：投融资标的.评估价格日期 -> T_9_2.J020020；加工映射:yyyy-mm-dd转为yyyymmdd,如果空则赋值:'99991231' */
        CASE WHEN src.J020020 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.J020020) AS VARCHAR(4)), LPAD(CAST(MONTH(src.J020020) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.J020020) AS VARCHAR(2)), 2, '0')) END AS PGJGRQ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 基础资产规模：投资标的关系.产品持有底层资产折算人民币金额 -> T_9_1.J010006；直接映射 */
        CAST(NULLIF(TRIM(s1.J010006), '') AS DECIMAL(20,2)) AS JCZCGM,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        s2.A010005 AS YHJGMC,
        /* 币种：待确认来源字段：投融资标的.投资标的币种 */
        NULL AS BZ,
        /* 发行机构代码：投融资标的.发行机构代码 -> T_9_2.J020007；加工映射：发行机构代码长度为20位时，转成‘0’，其他取发行机构代码 */
        src.J020007 AS FXJGDM,
        /* 发行日期：投融资标的.发行日期 -> T_9_2.J020015；直接映射:yyyy-mm-dd转为yyyymmdd */
        CONCAT(CAST(YEAR(src.J020015) AS VARCHAR(4)), LPAD(CAST(MONTH(src.J020015) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.J020015) AS VARCHAR(2)), 2, '0')) AS FXRQ,
        /* 利率类型：待确认来源字段：投融资标的.投资标的利率类型 */
        NULL AS LLLX,
        /* 含权标识：投融资标的.含权类型 -> T_9_2.J020087；加工映射：含权类型非空时，填写“是”，否则填写“否” */
        src.J020087 AS HQBS
    FROM T_9_2 src
    LEFT JOIN T_9_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_1_1 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《059_金融工具信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
