/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《053_票据出票信息表.md》生成 EAST5.0 票据出票信息表（IE_009_901）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/053_票据出票信息表.md
- 原始材料/表结构/EAST5.0系统/IE_009_901-票据出票信息表-DDL-2026-04-28.sql

源表：
- T_1_1, T_6_13

目标表：
- IE_009_901：票据出票信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送由出票人签发并向填报机构申请，经填报机构承兑的汇票。票据状态为卖断（转贴现卖断），解付（票据到期且出票人已付款）的数据，在报送票据最后状态的次月可不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1286 行） 过滤条件：业务类型 = '01'(承兑)，关联上月末6.13票据协议表，剔除上月已失效范围且剔除一直垫款状态的业务。

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_009_901_PJCPXXB;

CREATE PROCEDURE PROC_EAST_IE_009_901_PJCPXXB(
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

    DELETE FROM IE_009_901
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_009_901 (
        PJDQRQ,
        CPRBH,
        GSFZJG,
        SXFBZ,
        SKRKHLB,
        CPRKHLB,
        CJRQ,
        JBYGH,
        PJZT,
        BZJJE,
        BZJBL,
        MYBJ,
        SFZBHTX,
        SKRZH,
        SKRMC,
        CPRKHHMC,
        CPRZH,
        BZ,
        MXKMMC,
        MXKMBH,
        YHJGMC,
        JRXKZH,
        CPRMC,
        PJCPRQ,
        PMJE,
        PJLX,
        PJHM,
        NBJGH,
        SENSITIVEFLAG,
        SKRKHHMC,
        SXFJE,
        BZJBZ,
        BZJZH,
        BBZ
    )
    SELECT
        /* 票据到期日期：票据协议.票据到期日期 -> T_6_13.F130037；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F130037) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F130037) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F130037) AS VARCHAR(2)), 2, '0')) AS PJDQRQ,
        /* 出票人编号：票据协议.客户ID -> T_6_13.F130004；直接映射 */
        s1.F130004 AS CPRBH,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 其他费用币种：票据协议.其他费用币种 -> T_6_13.F130034；直接映射 */
        s1.F130034 AS SXFBZ,
        /* 收款人客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SKRKHLB,
        /* 出票人客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS CPRKHLB,
        /* 采集日期：票据协议.采集日期 -> T_6_13.F130049；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F130049) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F130049) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F130049) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 经办人工号：票据协议.经办员工ID -> T_6_13.F130042；加工映射：CASE WHEN 经办员工ID = '自动' THEN '' ELSE 经办员工ID END；转换规则需人工补齐 CASE 分支 */
        s1.F130042 AS JBYGH,
        /* 票据状态：票据协议.票据状态 -> T_6_13.F130047；加工映射：正常，卖断，解付，垫款，核销码值直接映射，“00-自定义”映射为“其他-自定义” CASE WHEN T1.PJZT = '01' THEN '正常' WHEN T1.PJZT = '02' THEN '卖断' WHEN T1.PJZT = '03' THEN '解付' WHEN T1.PJZT = '04' THEN '垫款' WHEN T1.PJZT = '05' THEN '核销' WHEN T1.PJZT LIKE '...；转换规则需人工补齐 CASE 分支 */
        s1.F130047 AS PJZT,
        /* 保证金金额：票据协议.保证金金额 -> T_6_13.F130023；直接映射 */
        CAST(NULLIF(TRIM(s1.F130023), '') AS DECIMAL(20,2)) AS BZJJE,
        /* 保证金比例：票据协议.保证金比例 -> T_6_13.F130024；直接映射 */
        CAST(NULLIF(TRIM(s1.F130024), '') AS DECIMAL(20,2)) AS BZJBL,
        /* 贸易背景：票据协议.贸易背景 -> T_6_13.F130046；直接映射 */
        s1.F130046 AS MYBJ,
        /* 是否在本行贴现：票据协议.在本行贴现标识 -> T_6_13.F130025；加工映射：CASE WHEN T1.ZBHTXBS ='1' THEN '是' ELSE '否' END；转换规则需人工补齐 CASE 分支 */
        s1.F130025 AS SFZBHTX,
        /* 收款人账号：票据协议.收款人账号 -> T_6_13.F130011；直接映射 */
        s1.F130011 AS SKRZH,
        /* 收款人名称：票据协议.收款人名称 -> T_6_13.F130006；直接映射 */
        s1.F130006 AS SKRMC,
        /* 出票人开户行名称：票据协议.出票人开户行名称 -> T_6_13.F130014；直接映射 */
        s1.F130014 AS CPRKHHMC,
        /* 出票人账号：票据协议.出票人账号 -> T_6_13.F130013；直接映射 */
        s1.F130013 AS CPRZH,
        /* 币种：票据协议.协议币种 -> T_6_13.F130019；直接映射 */
        s1.F130019 AS BZ,
        /* 明细科目名称：票据协议.科目名称 -> T_6_13.F130010；直接映射 */
        s1.F130010 AS MXKMMC,
        /* 明细科目编号：票据协议.科目ID -> T_6_13.F130009；直接映射 */
        s1.F130009 AS MXKMBH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        src.A010005 AS YHJGMC,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        src.A010003 AS JRXKZH,
        /* 出票人名称：票据协议.出票人名称 -> T_6_13.F130005；直接映射 */
        s1.F130005 AS CPRMC,
        /* 票据出票日期：票据协议.票据签发日期 -> T_6_13.F130036；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F130036) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F130036) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F130036) AS VARCHAR(2)), 2, '0')) AS PJCPRQ,
        /* 票面金额：票据协议.票面金额 -> T_6_13.F130020；直接映射 */
        CAST(NULLIF(TRIM(s1.F130020), '') AS DECIMAL(20,2)) AS PMJE,
        /* 票据类型：票据协议.票据类型 -> T_6_13.F130015；加工映射：CASE WHEN T1.票据类型 = '01' THEN '银行承兑汇票' WHEN T1.票据类型 = '02' THEN '商业承兑汇票' ELSE '' END；转换规则需人工补齐 CASE 分支 */
        s1.F130015 AS PJLX,
        /* 票据号码：票据协议.票据号码 -> T_6_13.F130016；直接映射 */
        s1.F130016 AS PJHM,
        /* 内部机构号：票据协议.机构ID -> T_6_13.F130003；加工映射：SUBSTR(机构ID,12) */
        s1.F130003 AS NBJGH,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 收款人开户行名称：票据协议.收款人开户行名称 -> T_6_13.F130012；直接映射 */
        s1.F130012 AS SKRKHHMC,
        /* 其他费用金额：票据协议.其他费用金额 -> T_6_13.F130035；直接映射 */
        CAST(NULLIF(TRIM(s1.F130035), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 保证金币种：票据协议.保证金币种 -> T_6_13.F130022；直接映射 */
        s1.F130022 AS BZJBZ,
        /* 保证金账号：票据协议.保证金账号 -> T_6_13.F130021；直接映射 */
        s1.F130021 AS BZJZH,
        /* 备注：票据协议.备注 -> T_6_13.F130048；提取《6.13票据协议》备注中内容。 */
        s1.F130048 AS BBZ
    FROM T_1_1 src
    LEFT JOIN T_6_13 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《053_票据出票信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
