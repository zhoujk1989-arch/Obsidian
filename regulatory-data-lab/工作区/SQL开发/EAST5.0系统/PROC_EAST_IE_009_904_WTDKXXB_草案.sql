/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《056_委托贷款信息表.md》生成 EAST5.0 委托贷款信息表（IE_009_904）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/056_委托贷款信息表.md
- 原始材料/表结构/EAST5.0系统/IE_009_904-委托贷款信息表-DDL-2026-04-28.sql

源表：
- T_2_1, T_2_5, T_2_3, T_2_4, T_6_18, T_1_1

目标表：
- IE_009_904：委托贷款信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送范围为个人及对公委托贷款业务，包括现金管理项下委托贷款、非现金管理项下委托贷款和公积金委托贷款。对于现金管理项下委托贷款，每发生一笔放款仅报送一次，以后不再报送，贷款状态以“其他-现金管理项下”报送。结清或者终结的委托贷款，在报送合同最后状态的次月不再填报。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1363 行） 委托贷款整体范围划分为：①对私委托贷款（不含现金管理项下委托贷款）、②对公委托贷款（不含现金管理项下委托贷款）、③现金管理项下委托贷款三部分。对私和对公部分通过关联EAST转换结果表的个人信贷分户账和对公信贷分户账确定范围。 ①对私委托贷款（不含现金管理项下委托贷款）:委托贷款类型不为“01 现金管理项下委托贷款”，关联《6.27贷款协议补充信息》（6.18与6.27关联条件：借据ID、采集日期），再内关联转换生成的《对公信贷分户账》（6.27分户账号=对公信贷分户账.贷款分户账号）确定范围。 ②对公委托贷款（不含现金管理项下委托贷款）:委托贷款类型不为“01 现金管理项下委托贷款”，关联《6.27贷款协议补充信息》（6.18与6.27关联条件：借据ID、采集日期），再内关联转换生成的《个人信贷分户账》（6.27分户账号=个人信贷分户账.贷款分户账号）确定范围。 ③现金管理项下委托贷款：委托贷款类型为“01 现金管理项下委托贷款”，关联上月末委托贷款协议（筛选协议状态为非正常04,05,06，00-现金管理项下），剔除上月末已报失效数据，卡出当月数据范围。

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_009_904_WTDKXXB;

CREATE PROCEDURE PROC_EAST_IE_009_904_WTDKXXB(
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

    DELETE FROM IE_009_904
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_009_904 (
        NBJGH,
        JRXKZH,
        HTBH,
        WTDKLX,
        SXFJE,
        HTDQRQ,
        WTRMC,
        SYRZH,
        SFSX,
        KHJLGH,
        DKZT,
        BBZ,
        GSFZJG,
        SENSITIVEFLAG,
        BZ,
        YHJGMC,
        MXKMMC,
        XDJJH,
        DKJE,
        HTQSRQ,
        WTRBH,
        WTRZH,
        WTRKHHMC,
        SYRMC,
        SYRKHHMC,
        SXFBZ,
        CJRQ,
        WTRKHLB,
        SYRKHLB,
        MXKMBH
    )
    SELECT
        /* 内部机构号：委托贷款协议.机构ID -> T_6_18.F180002；加工映射：SUBSTR(机构ID,12) */
        s4.F180002 AS NBJGH,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        s5.A010003 AS JRXKZH,
        /* 信贷合同号：委托贷款协议.协议ID -> T_6_18.F180001；直接映射 */
        s4.F180001 AS HTBH,
        /* 委托贷款类型：委托贷款协议.委托贷款类型 -> T_6_18.F180003；加工映射：CASE WHEN T1.委托贷款类型 = '01' THEN '现金管理项下委托贷款' WHEN T1.委托贷款类型 = '02' THEN '非现金管理项下委托贷款' WHEN T1.委托贷款类型 = '03' THEN '公积金贷款' END；转换规则需人工补齐 CASE 分支 */
        s4.F180003 AS WTDKLX,
        /* 手续费金额：委托贷款协议.手续费金额 -> T_6_18.F180024；直接映射 */
        CAST(NULLIF(TRIM(s4.F180024), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 合同到期日期：委托贷款协议.到期日期 -> T_6_18.F180011；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s4.F180011) AS VARCHAR(4)), LPAD(CAST(MONTH(s4.F180011) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s4.F180011) AS VARCHAR(2)), 2, '0')) AS HTDQRQ,
        /* 委托人名称：待确认来源字段：单一法人基本情况/个人客户基本情况/同业客户基本情况/个体工商户及小微企业主基本情况.客户名称 */
        NULL AS WTRMC,
        /* 受益人账号：委托贷款协议.借款人账号 -> T_6_18.F180026；直接映射 */
        s4.F180026 AS SYRZH,
        /* 是否收息：委托贷款协议.收息标识 -> T_6_18.F180009；加工映射：CASE WHEN T1.SXBS = '1' THEN '是' ELSE '否' END；转换规则需人工补齐 CASE 分支 */
        s4.F180009 AS SFSX,
        /* 经办人工号：委托贷款协议.经办员工ID -> T_6_18.F180019；加工映射：CASE WHEN 经办员工ID = '自动' THEN '' ELSE 经办员工ID END；转换规则需人工补齐 CASE 分支 */
        s4.F180019 AS KHJLGH,
        /* 贷款状态：待确认来源字段：现金管理项下委托贷款：固定值<br>对公：【EAST对公信贷分户账】<br>对私：【EAST个人信贷分户账】.现金管理项下委托贷款：固定值<br>对公：贷款状态<br>对私：贷款状态 */
        NULL AS DKZT,
        /* 备注：委托贷款协议.备注 -> T_6_18.F180022；提取《6.18委托贷款协议》、《6.27贷款协议补充信息》、《4.3分户账信息》备注内容。 */
        s4.F180022 AS BBZ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 币种：委托贷款协议.协议币种 -> T_6_18.F180008；直接映射 */
        s4.F180008 AS BZ,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        s5.A010005 AS YHJGMC,
        /* 明细科目名称：委托贷款协议.科目名称 -> T_6_18.F180017；直接映射 */
        s4.F180017 AS MXKMMC,
        /* 信贷借据号：委托贷款协议.借据ID -> T_6_18.F180012；直接映射 */
        s4.F180012 AS XDJJH,
        /* 合同金额：委托贷款协议.协议金额 -> T_6_18.F180007；直接映射 */
        CAST(NULLIF(TRIM(s4.F180007), '') AS DECIMAL(20,2)) AS DKJE,
        /* 合同起始日期：委托贷款协议.生效日期 -> T_6_18.F180010；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s4.F180010) AS VARCHAR(4)), LPAD(CAST(MONTH(s4.F180010) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s4.F180010) AS VARCHAR(2)), 2, '0')) AS HTQSRQ,
        /* 委托人编号：委托贷款协议.委托客户ID -> T_6_18.F180004；直接映射 */
        s4.F180004 AS WTRBH,
        /* 委托人账号：委托贷款协议.委托客户账号 -> T_6_18.F180005；直接映射 */
        s4.F180005 AS WTRZH,
        /* 委托人开户行名称：委托贷款协议.委托客户账号开户行名称 -> T_6_18.F180006；直接映射 */
        s4.F180006 AS WTRKHHMC,
        /* 受益人名称：委托贷款协议.借款人名称 -> T_6_18.F180014；直接映射 */
        s4.F180014 AS SYRMC,
        /* 受益人开户行名称：委托贷款协议.借款人开户行名称 -> T_6_18.F180027；直接映射 */
        s4.F180027 AS SYRKHHMC,
        /* 手续费币种：委托贷款协议.手续费币种 -> T_6_18.F180023；直接映射 */
        s4.F180023 AS SXFBZ,
        /* 采集日期：委托贷款协议.采集日期 -> T_6_18.F180025；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s4.F180025) AS VARCHAR(4)), LPAD(CAST(MONTH(s4.F180025) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s4.F180025) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 委托人客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS WTRKHLB,
        /* 受益人客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SYRKHLB,
        /* 明细科目编号：委托贷款协议.科目ID -> T_6_18.F180016；直接映射 */
        s4.F180016 AS MXKMBH
    FROM T_2_1 src
    LEFT JOIN T_2_5 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_2_3 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_2_4 s3
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s3 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_6_18 s4
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s4 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_1_1 s5
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s5 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《056_委托贷款信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
