/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《034_银团贷款信息表.md》生成 EAST5.0 银团贷款信息表（IE_005_507）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/034_银团贷款信息表.md
- 原始材料/表结构/EAST5.0系统/IE_005_507-银团贷款信息表-DDL-2026-04-28.sql

源表：
- T_6_5

目标表：
- IE_005_507：银团贷款信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 银（社）团贷款信息。以信贷借据号为最小颗粒报送，同一合同下多笔借据的按多条报送。已结清、核销的数据在次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 813 行） 取日期在当月且通过信贷合同号关联生成EAST对公信贷业务借据表来筛选范围

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_507_YTDKXXB;

CREATE PROCEDURE PROC_EAST_IE_005_507_YTDKXXB(
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

    DELETE FROM IE_005_507
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_507 (
        YTDKZJE,
        GSFZJG,
        CJHHM,
        CJRQ,
        JJYE,
        YFFCDDKJE,
        YFFDKJE,
        BZ,
        DLHHH,
        JKRMC,
        CJHHH,
        QTHHH,
        YHJGMC,
        JKRBH,
        XDJJH,
        XDHTH,
        NBJGH,
        JRXKZH,
        QTHHM,
        JKRKHLB,
        BBZ,
        JJJE,
        SENSITIVEFLAG,
        DLHHM,
        CDDKJE,
        DKZT,
        YTCYLX
    )
    SELECT
        /* 银团贷款总金额：银团贷款协议.银团贷款总金额 -> T_6_5.F050009；加工映射：按【币种】的加工逻辑，如果加工出来的【币种】是'BWB'，则取【银团贷款协议】.【银团贷款总金额】按【银团贷款协议】.【银团贷款总金额币种】关联【汇率利率】，折算成人民币，否则取【银团贷款协议】.【银团贷款总金额】 */
        CAST(NULLIF(TRIM(src.F050009), '') AS DECIMAL(20,2)) AS YTDKZJE,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 参加行行名：银团贷款协议.参加行行名 -> T_6_5.F050004；直接映射 */
        src.F050004 AS CJHHM,
        /* 采集日期：银团贷款协议.采集日期 -> T_6_5.F050014；默认值：报告日，数据格式转成yyyymmdd */
        CONCAT(CAST(YEAR(src.F050014) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F050014) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F050014) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 借据余额：待确认来源字段：EAST对公信贷业务借据表.贷款余额 */
        NULL AS JJYE,
        /* 已发放承担贷款金额：待确认来源字段：银团贷款协议.已发放承担贷款金额 */
        NULL AS YFFCDDKJE,
        /* 已发放银团贷款金额：银团贷款协议.已发放银团贷款金额 -> T_6_5.F050011；加工映射：按【币种】的加工逻辑，如果加工出来的【币种】是'BWB'，则取【银团贷款协议】.【已发放银团贷款金额】按【银团贷款协议】.【银团贷款总金额币种】关联【汇率利率】，折算成人民币，否则取【银团贷款协议】.【已发放银团贷款金额】 */
        CAST(NULLIF(TRIM(src.F050011), '') AS DECIMAL(20,2)) AS YFFDKJE,
        /* 币种：待确认来源字段：银团贷款协议\.EAST对公信贷业务借据表 */
        NULL AS BZ,
        /* 代理行行号：银团贷款协议.代理行行号 -> T_6_5.F050007；直接映射 */
        src.F050007 AS DLHHH,
        /* 借款人名称：待确认来源字段：EAST对公信贷业务借据表.客户名称 */
        NULL AS JKRMC,
        /* 参加行行号：银团贷款协议.参加行行号 -> T_6_5.F050005；直接映射 */
        src.F050005 AS CJHHH,
        /* 牵头行行号：银团贷款协议.牵头行行号 -> T_6_5.F050003；直接映射 */
        src.F050003 AS QTHHH,
        /* 银行机构名称：待确认来源字段：EAST对公信贷业务借据表.银行机构名称 */
        NULL AS YHJGMC,
        /* 借款人编号：待确认来源字段：EAST对公信贷业务借据表.客户统一编号 */
        NULL AS JKRBH,
        /* 信贷借据号：待确认来源字段：EAST对公信贷业务借据表.信贷借据号 */
        NULL AS XDJJH,
        /* 信贷合同号：银团贷款协议.协议ID -> T_6_5.F050001；直接映射 */
        src.F050001 AS XDHTH,
        /* 内部机构号：待确认来源字段：EAST对公信贷业务借据表.内部机构号 */
        NULL AS NBJGH,
        /* 金融许可证号：待确认来源字段：EAST对公信贷业务借据表.金融许可证号 */
        NULL AS JRXKZH,
        /* 牵头行行名：银团贷款协议.牵头行行名 -> T_6_5.F050002；直接映射 */
        src.F050002 AS QTHHM,
        /* 借款人客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS JKRKHLB,
        /* 备注：银团贷款协议.备注 -> T_6_5.F050013；加工映射：提取一表通《6.5银团贷款协议》备注。 */
        src.F050013 AS BBZ,
        /* 借据金额：待确认来源字段：EAST对公信贷业务借据表.贷款金额 */
        NULL AS JJJE,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 代理行行名：银团贷款协议.代理行行名 -> T_6_5.F050006；直接映射 */
        src.F050006 AS DLHHM,
        /* 承担贷款金额：银团贷款协议.承担贷款金额 -> T_6_5.F050010；加工映射：按【币种】的加工逻辑，如果加工出来的【币种】是'BWB'，则取【银团贷款协议】.【承担贷款金额】按【银团贷款协议】.【银团贷款总金额币种】关联【汇率利率】，折算成人民币，否则取【银团贷款协议】.【承担贷款金额】 */
        CAST(NULLIF(TRIM(src.F050010), '') AS DECIMAL(20,2)) AS CDDKJE,
        /* 贷款状态：待确认来源字段：EAST对公信贷业务借据表.贷款状态 */
        NULL AS DKZT,
        /* 银团成员类型：银团贷款协议.银团成员类型 -> T_6_5.F050008；加工映射：将【银团贷款协议】.【银团成员类型】中码值按如下替换： '01'转化为'牵头行' '02'转化为'代理行' '03'转化为'参加行' '00-XX'转化为'其他-XX'，其中'XX'为银行自定义；转换规则需人工补齐 CASE 分支 */
        src.F050008 AS YTCYLX
    FROM T_6_5 src
    WHERE 1 = 1
      /* TODO: 按《034_银团贷款信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
