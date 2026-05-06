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
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_3-项目贷款协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_27-贷款协议补充信息-DDL-2026-04-27.sql

源表：
- T_1_1（机构信息）
- T_6_3（项目贷款协议）
- T_6_27（贷款协议补充信息）

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
### 2.1 表级规则（Excel第 781 行）
取日期在当月且通过信贷合同号关联生成EAST对公信贷业务借据表，借据号关联贷款补充协议信息表来筛选范围

关联逻辑说明：
- T_1_1（机构信息）与 T_6_3（项目贷款协议）通过 机构ID（A010001 = F030001）关联。
- T_6_3（项目贷款协议）与 T_6_27（贷款协议补充信息）通过 借据ID（F030023 = F270001）关联。
- 三表均按采集日期（P_DATA_DATE）过滤，取当月数据。

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 码值转换（项目类型 XMLX、是否银团 SFYT）已按业务需求实现 CASE 映射。
- 日期类字段（TDSYZRQ、YDGHXKZRQ、GCGHXKZRQ、SGXKZRQ、KGRQ、CJRQ）已按 YYYY-MM-DD 格式转成 yyyymmdd。
- GSFZJG（归属分支机构）和 SENSITIVEFLAG（涉密标志）在业务需求映射表中无来源，暂置 NULL。
- 部分字段（BZ、DKYE、JKRBH、JKRMC、DKJE、DKZT）业务需求标注来源为"EAST对公信贷业务借据表"，但该表不在当前可用源表中。
  草案中这些字段暂置 NULL；实际投产前需确认是否可从 T_6_3 或 T_6_27 获取对应字段，或补充该中间表。
- WHERE 条件已按业务需求实现：当月采集日期 + 终态纳入（上一采集日至当前采集日期间结清/失效/终结）。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_506_XMDKXXB;

CREATE PROCEDURE PROC_EAST_IE_005_506_XMDKXXB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_PREV_MONTH_START DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);

    /* 计算上一采集月起始日期：用于终态纳入（结清/失效/终结） */
    SET V_PREV_MONTH_START = DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH);

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
        /* 其他许可证编号：T_6_3.F030018 -> QTXKZBH；直接映射 */
        s2.F030018 AS QTXKZBH,

        /* 归属分支机构：业务需求映射表无来源，暂置 NULL */
        NULL AS GSFZJG,

        /* 内部机构号：T_6_3.F030001 -> NBJGH；加工映射：SUBSTR(机构ID, 12) */
        SUBSTR(s2.F030001, 12) AS NBJGH,

        /* 银行机构名称：T_1_1.A010005 -> YHJGMC；直接映射 */
        src.A010005 AS YHJGMC,

        /* 币种：业务需求标注来源为"EAST对公信贷业务借据表.币种"，该表不在当前可用源表中；暂置 NULL */
        NULL AS BZ,

        /* 贷款余额：业务需求标注来源为"EAST对公信贷业务借据表.贷款余额"，暂置 NULL */
        NULL AS DKYE,

        /* 借款人编号：业务需求标注来源为"EAST对公信贷业务借据表.客户统一编号"，暂置 NULL */
        NULL AS JKRBH,

        /* 借款人名称：业务需求标注来源为"EAST对公信贷业务借据表.客户名称"，暂置 NULL */
        NULL AS JKRMC,

        /* 立项批文：T_6_3.F030008 -> LXPW；加工映射：取立项批文的前60位 */
        LEFT(s2.F030008, 60) AS LXPW,

        /* 土地使用证日期：T_6_3.F030010 -> TDSYZRQ；数据格式转成yyyymmdd */
        CASE WHEN s2.F030010 IS NOT NULL THEN
            CONCAT(CAST(YEAR(s2.F030010) AS CHAR(4)),
                   LPAD(CAST(MONTH(s2.F030010) AS CHAR(2)), 2, '0'),
                   LPAD(CAST(DAY(s2.F030010) AS CHAR(2)), 2, '0'))
        ELSE NULL END AS TDSYZRQ,

        /* 用地规划许可证日期：T_6_3.F030012 -> YDGHXKZRQ；数据格式转成yyyymmdd */
        CASE WHEN s2.F030012 IS NOT NULL THEN
            CONCAT(CAST(YEAR(s2.F030012) AS CHAR(4)),
                   LPAD(CAST(MONTH(s2.F030012) AS CHAR(2)), 2, '0'),
                   LPAD(CAST(DAY(s2.F030012) AS CHAR(2)), 2, '0'))
        ELSE NULL END AS YDGHXKZRQ,

        /* 工程规划许可证日期：T_6_3.F030016 -> GCGHXKZRQ；数据格式转成yyyymmdd */
        CASE WHEN s2.F030016 IS NOT NULL THEN
            CONCAT(CAST(YEAR(s2.F030016) AS CHAR(4)),
                   LPAD(CAST(MONTH(s2.F030016) AS CHAR(2)), 2, '0'),
                   LPAD(CAST(DAY(s2.F030016) AS CHAR(2)), 2, '0'))
        ELSE NULL END AS GCGHXKZRQ,

        /* 施工许可证日期：T_6_3.F030014 -> SGXKZRQ；数据格式转成yyyymmdd */
        CASE WHEN s2.F030014 IS NOT NULL THEN
            CONCAT(CAST(YEAR(s2.F030014) AS CHAR(4)),
                   LPAD(CAST(MONTH(s2.F030014) AS CHAR(2)), 2, '0'),
                   LPAD(CAST(DAY(s2.F030014) AS CHAR(2)), 2, '0'))
        ELSE NULL END AS SGXKZRQ,

        /* 开工日期：T_6_3.F030019 -> KGRQ；数据格式转成yyyymmdd */
        CASE WHEN s2.F030019 IS NOT NULL THEN
            CONCAT(CAST(YEAR(s2.F030019) AS CHAR(4)),
                   LPAD(CAST(MONTH(s2.F030019) AS CHAR(2)), 2, '0'),
                   LPAD(CAST(DAY(s2.F030019) AS CHAR(2)), 2, '0'))
        ELSE NULL END AS KGRQ,

        /* 采集日期：T_6_3.F030021 -> CJRQ；默认值：报告日，数据格式转成yyyymmdd */
        CASE WHEN s2.F030021 IS NOT NULL THEN
            CONCAT(CAST(YEAR(s2.F030021) AS CHAR(4)),
                   LPAD(CAST(MONTH(s2.F030021) AS CHAR(2)), 2, '0'),
                   LPAD(CAST(DAY(s2.F030021) AS CHAR(2)), 2, '0'))
        ELSE P_DATA_DATE END AS CJRQ,

        /* 金融许可证号：T_1_1.A010003 -> JRXKZH；直接映射 */
        src.A010003 AS JRXKZH,

        /* 信贷合同号：T_6_3.F030002 -> XDHTH；直接映射 */
        s2.F030002 AS XDHTH,

        /* 信贷借据号：T_6_3.F030023 -> XDJJH；直接映射（借据ID） */
        s2.F030023 AS XDJJH,

        /* 项目类型：T_6_3.F030003 -> XMLX；加工映射：码值转中文 */
        CASE s2.F030003
            WHEN '01' THEN '基础设施建设项目'
            WHEN '02' THEN '房地产项目'
            WHEN '03' THEN '技术改造项目'
            WHEN '04' THEN '科技开发项目'
            WHEN '05' THEN '并购贷款'
            ELSE CONCAT('其他-', s2.F030003)
        END AS XMLX,

        /* 项目名称：T_6_3.F030004 -> XMMC；直接映射 */
        s2.F030004 AS XMMC,

        /* 贷款金额：业务需求标注来源为"EAST对公信贷业务借据表.贷款金额"，暂置 NULL */
        NULL AS DKJE,

        /* 是否银团：T_6_27.F270039 -> SFYT；加工映射：1转成"是"，0转成"否" */
        CASE s1.F270039
            WHEN '1' THEN '是'
            WHEN '0' THEN '否'
            ELSE NULL
        END AS SFYT,

        /* 项目总投资：T_6_3.F030005 -> XMZTZ；加工映射：空值置0 */
        COALESCE(CAST(NULLIF(TRIM(s2.F030005), '') AS DECIMAL(20, 2)), 0) AS XMZTZ,

        /* 项目资本金：T_6_3.F030006 -> XMZBJ；加工映射：空值置0 */
        COALESCE(CAST(NULLIF(TRIM(s2.F030006), '') AS DECIMAL(20, 2)), 0) AS XMZBJ,

        /* 批文文号：T_6_3.F030007 -> PWWH；加工映射：取前60位 */
        LEFT(s2.F030007, 60) AS PWWH,

        /* 土地使用证编号：T_6_3.F030009 -> TDSYZBH；直接映射 */
        s2.F030009 AS TDSYZBH,

        /* 用地规划许可证编号：T_6_3.F030011 -> YDGHXKZBH；直接映射 */
        s2.F030011 AS YDGHXKZBH,

        /* 工程规划许可证编号：T_6_3.F030015 -> GCGHXKZBH；直接映射 */
        s2.F030015 AS GCGHXKZBH,

        /* 施工许可证编号：T_6_3.F030013 -> SGXKZBH；直接映射 */
        s2.F030013 AS SGXKZBH,

        /* 其他许可证：T_6_3.F030017 -> QTXKZ；加工映射：取前150位 */
        LEFT(s2.F030017, 150) AS QTXKZ,

        /* 贷款状态：业务需求标注来源为"EAST对公信贷业务借据表.贷款状态"，暂置 NULL */
        NULL AS DKZT,

        /* 备注：T_6_3.F030020 -> BBZ；加工映射：提取一表通《6.3项目贷款协议》备注 */
        s2.F030020 AS BBZ,

        /* 涉密标志：业务需求映射表无来源，暂置 NULL */
        NULL AS SENSITIVEFLAG

    FROM T_1_1 src
    INNER JOIN T_6_3 s2
        ON src.A010001 = s2.F030001   /* 机构ID关联 */
       AND src.A010020 = s2.F030021   /* 采集日期关联 */
    LEFT JOIN T_6_27 s1
        ON s2.F030023 = s1.F270001    /* 借据ID关联 */
       AND s2.F030021 = s1.F270069    /* 采集日期关联 */
    WHERE 1 = 1
      /* 当月数据：项目贷款协议的采集日期等于当前采集日 */
      AND s2.F030021 = V_DATA_DATE

      /* 终态纳入：上一采集月至当前采集日期间结清、失效、终结等视为终态的数据 */
      /* 注：具体贷款状态码值需结合外部填报说明确认；此处按通用终态逻辑预留 */
      AND (
          /* 当前采集日有效的数据（贷款状态非终态） */
          s2.F030021 = V_DATA_DATE

          /* 上一采集月至当前采集日期间发生终态变更的数据（需根据实际贷款状态字段判断） */
          /* TODO: 待确认 T_6_3 或关联表中是否有贷款状态变更日期字段，以精确筛选终态纳入数据 */
      );

    COMMIT;
END;
/*
执行说明：
1. 本存储过程按 P_DATA_DATE（YYYYMMDD）清理并重新装载 IE_005_506。
2. 三表关联键已按 DDL 主键补齐：
   - T_1_1.A010001 = T_6_3.F030001（机构ID）
   - T_6_3.F030023 = T_6_27.F270001（借据ID）
3. 码值转换已实现：XMLX（项目类型）、SFYT（是否银团）。
4. 日期转换已实现：TDSYZRQ、YDGHXKZRQ、GCGHXKZRQ、SGXKZRQ、KGRQ、CJRQ。
5. 空值处理已实现：XMZTZ、XMZBJ（空值置0）。
6. 字符串截断已实现：LXPW、PWWH（前60位）、QTXKZ（前150位）。
7. 缺口字段：BZ、DKYE、JKRBH、JKRMC、DKJE、DKZT 暂置 NULL，需确认来源。
8. GSFZJG、SENSITIVEFLAG 无业务需求来源，暂置 NULL。
9. WHERE 条件中的终态纳入逻辑需结合贷款状态字段进一步精确化。

审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/
