/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《033_项目贷款信息表.md》生成 EAST5.0 项目贷款信息表（IE_005_506）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/033_项目贷款信息表.md
- 原始材料/表结构/EAST5.0系统/IE_005_506-项目贷款信息表-DDL-2026-04-28.sql

源表：
- T_1_1, T_6_27, T_6_3

目标表：
- IE_005_506：项目贷款信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 符合以下特征的贷款的相关信息：（一）贷款用途通常是用于建造一个或一组大型生产装置、基础设施、房地产项目或其他项目，包括对在建或已建项目的再融资；（二）借款人通常是为建设、经营该项目或为该项目融资而专门组建的企事业法人，包括主要从事该项目建设、经营或融资的既有企事业法人；（三）还款资金来源主要依赖该项目产生的销售收入、补贴收入或其他收入，一般不具备其他还款来源。以信贷借据号为最小颗粒报送，同一合同下多笔借据的按多条报送。已结清、核销的数据在次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 781 行） 取日期在当月且通过信贷合同号关联生成EAST对公信贷业务借据表，借据号关联贷款补充协议信息表来筛选范围

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_506_XMDKXXB;

CREATE PROCEDURE PROC_EAST_IE_005_506_XMDKXXB(
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

    DELETE FROM IE_005_506
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_506 (
        QTXKZBH,
        GSFZJG,
        NBJGH,
        YHJGMC,
        BZ,
        DKYE,
        JKRBH,
        JKRMC,
        LXPW,
        TDSYZRQ,
        YDGHXKZRQ,
        GCGHXKZRQ,
        SGXKZRQ,
        KGRQ,
        CJRQ,
        JRXKZH,
        XDHTH,
        XDJJH,
        XMLX,
        XMMC,
        DKJE,
        SFYT,
        XMZTZ,
        XMZBJ,
        PWWH,
        TDSYZBH,
        YDGHXKZBH,
        GCGHXKZBH,
        SGXKZBH,
        QTXKZ,
        DKZT,
        BBZ,
        SENSITIVEFLAG
    )
    SELECT
        /* 其他许可证编号：项目贷款协议.其他许可证编号 -> T_6_3.F030018；直接映射 */
        s2.F030018 AS QTXKZBH,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 内部机构号：项目贷款协议.机构ID -> T_6_3.F030001；加工映射：SUBSTR(机构ID,12) */
        s2.F030001 AS NBJGH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        src.A010005 AS YHJGMC,
        /* 币种：待确认来源字段：EAST对公信贷业务借据表.币种 */
        NULL AS BZ,
        /* 贷款余额：待确认来源字段：EAST对公信贷业务借据表.贷款余额 */
        NULL AS DKYE,
        /* 借款人编号：待确认来源字段：EAST对公信贷业务借据表.客户统一编号 */
        NULL AS JKRBH,
        /* 借款人名称：待确认来源字段：EAST对公信贷业务借据表.客户名称 */
        NULL AS JKRMC,
        /* 立项批文：项目贷款协议.立项批文 -> T_6_3.F030008；加工映射:取立项批文的前60位 */
        s2.F030008 AS LXPW,
        /* 土地使用证日期：项目贷款协议.土地使用证日期 -> T_6_3.F030010；数据格式转成yyyymmdd */
        CONCAT(CAST(YEAR(s2.F030010) AS VARCHAR(4)), LPAD(CAST(MONTH(s2.F030010) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s2.F030010) AS VARCHAR(2)), 2, '0')) AS TDSYZRQ,
        /* 用地规划许可证日期：项目贷款协议.用地规划许可证日期 -> T_6_3.F030012；数据格式转成yyyymmdd */
        CONCAT(CAST(YEAR(s2.F030012) AS VARCHAR(4)), LPAD(CAST(MONTH(s2.F030012) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s2.F030012) AS VARCHAR(2)), 2, '0')) AS YDGHXKZRQ,
        /* 工程规划许可证日期：项目贷款协议.工程规划许可证日期 -> T_6_3.F030016；数据格式转成yyyymmdd */
        CONCAT(CAST(YEAR(s2.F030016) AS VARCHAR(4)), LPAD(CAST(MONTH(s2.F030016) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s2.F030016) AS VARCHAR(2)), 2, '0')) AS GCGHXKZRQ,
        /* 施工许可证日期：项目贷款协议.施工许可证日期 -> T_6_3.F030014；数据格式转成yyyymmdd */
        CONCAT(CAST(YEAR(s2.F030014) AS VARCHAR(4)), LPAD(CAST(MONTH(s2.F030014) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s2.F030014) AS VARCHAR(2)), 2, '0')) AS SGXKZRQ,
        /* 开工日期：项目贷款协议.开工日期 -> T_6_3.F030019；数据格式转成yyyymmdd */
        CONCAT(CAST(YEAR(s2.F030019) AS VARCHAR(4)), LPAD(CAST(MONTH(s2.F030019) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s2.F030019) AS VARCHAR(2)), 2, '0')) AS KGRQ,
        /* 采集日期：项目贷款协议.采集日期 -> T_6_3.F030021；默认值：报告日，数据格式转成yyyymmdd */
        CONCAT(CAST(YEAR(s2.F030021) AS VARCHAR(4)), LPAD(CAST(MONTH(s2.F030021) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s2.F030021) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        src.A010003 AS JRXKZH,
        /* 信贷合同号：项目贷款协议.协议ID -> T_6_3.F030002；直接映射 */
        s2.F030002 AS XDHTH,
        /* 信贷借据号：待确认来源字段：项目贷款协议.信贷借据号 */
        NULL AS XDJJH,
        /* 项目类型：项目贷款协议.项目类型 -> T_6_3.F030003；加工映射：'01'转成'基础设施建设项目'，'02'转成'房地产项目'，'03'转成'技术改造项目'，'04'转成'科技开发项目'，'05'转成'并购贷款'，'00-XX'转成'其他-XX'，其中'XX'为银行自定义 */
        s2.F030003 AS XMLX,
        /* 项目名称：项目贷款协议.项目名称 -> T_6_3.F030004；直接映射 */
        s2.F030004 AS XMMC,
        /* 贷款金额：待确认来源字段：EAST对公信贷业务借据表.贷款金额 */
        NULL AS DKJE,
        /* 是否银团：贷款协议补充信息.银团贷款标识 -> T_6_27.F270039；加工映射：取【贷款协议补充信息】的【银团贷款标识】，再将1转成是，0转成否 */
        s1.F270039 AS SFYT,
        /* 项目总投资：项目贷款协议.项目总投资 -> T_6_3.F030005；加工映射：取【项目贷款协议】.【项目总投资】，当其为空时，置0 */
        CAST(NULLIF(TRIM(s2.F030005), '') AS DECIMAL(20,2)) AS XMZTZ,
        /* 项目资本金：项目贷款协议.项目资本金 -> T_6_3.F030006；加工映射：取【项目贷款协议】.【项目资本金】，当其为空时，置0 */
        CAST(NULLIF(TRIM(s2.F030006), '') AS DECIMAL(20,2)) AS XMZBJ,
        /* 批文文号：项目贷款协议.批文文号 -> T_6_3.F030007；加工映射:取批文文号的前60位 */
        s2.F030007 AS PWWH,
        /* 土地使用证编号：项目贷款协议.土地使用证编号 -> T_6_3.F030009；直接映射 */
        s2.F030009 AS TDSYZBH,
        /* 用地规划许可证编号：项目贷款协议.用地规划许可证编号 -> T_6_3.F030011；直接映射 */
        s2.F030011 AS YDGHXKZBH,
        /* 工程规划许可证编号：项目贷款协议.工程规划许可证编号 -> T_6_3.F030015；直接映射 */
        s2.F030015 AS GCGHXKZBH,
        /* 施工许可证编号：项目贷款协议.施工许可证编号 -> T_6_3.F030013；直接映射 */
        s2.F030013 AS SGXKZBH,
        /* 其他许可证：项目贷款协议.其他许可证 -> T_6_3.F030017；加工映射：取其他许可证的前150位 */
        s2.F030017 AS QTXKZ,
        /* 贷款状态：待确认来源字段：EAST对公信贷业务借据表.贷款状态 */
        NULL AS DKZT,
        /* 备注：项目贷款协议.备注 -> T_6_3.F030020；加工映射：提取一表通《6.3项目贷款协议》备注。 */
        s2.F030020 AS BBZ,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG
    FROM T_1_1 src
    LEFT JOIN T_6_27 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_6_3 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《033_项目贷款信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
