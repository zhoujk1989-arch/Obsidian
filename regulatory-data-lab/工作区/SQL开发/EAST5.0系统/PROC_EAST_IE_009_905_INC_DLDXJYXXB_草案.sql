/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《057_代理代销交易信息表.md》生成 EAST5.0 代理代销交易信息表（IE_009_905_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/057_代理代销交易信息表.md
- 原始材料/表结构/EAST5.0系统/IE_009_905_INC-代理代销交易信息表-DDL-2026-04-28.sql

源表：
- T_6_19, T_1_1, T_7_11

目标表：
- IE_009_905_INC：代理代销交易信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 报送范围包括债券承销、代理代销信托计划、代理资产管理计划、代理代销保险产品、代理代销基金、代理贵金属交易以及其他代理代销业务，相关业务定义可参照1104报表。代理销售他行发行的理财产品也需要报送，包括填报机构理财子公司发行的理财产品。涉及分红、付息等交易无需报送。涉及赎回、卖出的交易需要报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1390 行） 主表：理财及代销产品交易，关联代理协议 过滤条件：筛选采集日期为报告期当月

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_009_905_INC_DLDXJYXXB;

CREATE PROCEDURE PROC_EAST_IE_009_905_INC_DLDXJYXXB(
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

    DELETE FROM IE_009_905_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_009_905_INC (
        CJRQ,
        XZBZ,
        DLDXJYLX,
        JYFX,
        BZ,
        FXJGPJ,
        SENSITIVEFLAG,
        FXJGPJJG,
        FXJGQSHM,
        SXFJE,
        JYYGH,
        BBZ,
        JRXKZH,
        KHTYBH,
        GSFZJG,
        FXJGMC,
        KHLB,
        NBJGH,
        YHJGMC,
        KHZH,
        KHHMC,
        JYBH,
        DXCPMC,
        JYRQ,
        JYJE,
        FXJGQSZH,
        RZRMC,
        RZRSSHY,
        SXFBZ,
        KHMC
    )
    SELECT
        /* 采集日期：待确认来源字段：. */
        NULL AS CJRQ,
        /* 现转标志：理财及代销产品交易.现转标识 -> T_7_11.G110012；码值转化：如果是01，则'现' 如果是02, 则'转'；转换规则需人工补齐 CASE 分支 */
        s2.G110012 AS XZBZ,
        /* 代理代销交易类型：代理协议.代理产品类型 -> T_6_19.F190006；码值转化： 如果 【代理协议】.【代理产品类型】为 '0101' ，则 '债券承销' 如果 【代理协议】.【代理产品类型】为 '0201' ，则 '代理代销信托计划' 如果 【代理协议】.【代理产品类型】为 '0301' ，则 '代理代销资产管理计划' 如果 【代理协议】.【代理产品类型】为 '0401' ，则 '代理代销保险产品' 如果 【代理协议】.【代理产品类型】为 '0501' ，则 '代理代销基金' 如果 【代理协议】.【代理...；转换规则需人工补齐 CASE 分支 */
        src.F190006 AS DLDXJYLX,
        /* 交易方向：理财及代销产品交易.交易方向 -> T_7_11.G110011；码值转化：如果是'01' 则'买入' 如果是'02' 则'卖出'；转换规则需人工补齐 CASE 分支 */
        s2.G110011 AS JYFX,
        /* 币种：理财及代销产品交易.交易币种 -> T_7_11.G110021；直接映射 */
        s2.G110021 AS BZ,
        /* 发行机构评级：代理协议.发行机构评级 -> T_6_19.F190008；直接映射 */
        src.F190008 AS FXJGPJ,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 发行机构评级机构：代理协议.发行机构评级机构 -> T_6_19.F190009；直接映射 */
        src.F190009 AS FXJGPJJG,
        /* 发行机构清算行名：待确认来源字段：理财及代销产品交易.对方清算行名（新增字段） */
        NULL AS FXJGQSHM,
        /* 手续费金额：理财及代销产品交易.手续费金额 -> T_7_11.G110009；直接映射 */
        CAST(NULLIF(TRIM(s2.G110009), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 经办人工号：理财及代销产品交易.经办员工ID -> T_7_11.G110017；加工映射：CASE WHEN 经办员工ID = '自动' THEN '' ELSE 经办员工ID END；转换规则需人工补齐 CASE 分支 */
        s2.G110017 AS JYYGH,
        /* 备注：待确认来源字段：理财及代销产品交易<br>代理协议.理财及代销产品交易：备注<br>代理协议：备注 */
        NULL AS BBZ,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        s1.A010003 AS JRXKZH,
        /* 客户统一编号：理财及代销产品交易.客户ID -> T_7_11.G110002；直接映射 */
        s2.G110002 AS KHTYBH,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 发行机构名称：代理协议.委托人名称 -> T_6_19.F190004；直接映射 */
        src.F190004 AS FXJGMC,
        /* 客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS KHLB,
        /* 内部机构号：理财及代销产品交易.机构ID -> T_7_11.G110014；从第12位开始截取【理财及代销产品交易】.机构ID */
        SUBSTR(TRIM(s2.G110014), 12) AS NBJGH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        s1.A010005 AS YHJGMC,
        /* 客户账号：理财及代销产品交易.关联存款账号 -> T_7_11.G110007；直接映射 */
        s2.G110007 AS KHZH,
        /* 开户行名称：理财及代销产品交易.关联存款账号开户行名称 -> T_7_11.G110008；直接映射 */
        s2.G110008 AS KHHMC,
        /* 交易编号：理财及代销产品交易.交易ID -> T_7_11.G110003；直接映射 */
        s2.G110003 AS JYBH,
        /* 代销产品名称：待确认来源字段：理财及代销产品交易.产品名称（新增字段） */
        NULL AS DXCPMC,
        /* 交易日期：理财及代销产品交易.销售日期 -> T_7_11.G110005；格式转化：YYYY-MM-DD转换为YYYYMMDD */
        CONCAT(CAST(YEAR(s2.G110005) AS VARCHAR(4)), LPAD(CAST(MONTH(s2.G110005) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s2.G110005) AS VARCHAR(2)), 2, '0')) AS JYRQ,
        /* 交易金额：理财及代销产品交易.交易金额 -> T_7_11.G110022；直接映射 */
        CAST(NULLIF(TRIM(s2.G110022), '') AS DECIMAL(20,2)) AS JYJE,
        /* 发行机构清算账号：理财及代销产品交易.对方清算账号 -> T_7_11.G110019；直接映射 */
        s2.G110019 AS FXJGQSZH,
        /* 融资人名称：代理协议.融资人名称 -> T_6_19.F190010；直接映射 */
        src.F190010 AS RZRMC,
        /* 融资人所属行业：代理协议.融资人行业类型 -> T_6_19.F190011；直接映射 */
        src.F190011 AS RZRSSHY,
        /* 手续费币种：理财及代销产品交易.手续费币种 -> T_7_11.G110010；直接映射 */
        s2.G110010 AS SXFBZ,
        /* 客户名称：待确认来源字段：对公客户信息表/个人基础信息表.客户名称/客户姓名 */
        NULL AS KHMC
    FROM T_6_19 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_7_11 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《057_代理代销交易信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
