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
- 原始材料/表结构/一表通系统/T_6_2-贷款协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql

源表：
- T_6_2：贷款协议（主源表）
- T_1_1：机构信息（LEFT JOIN enrich）

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

审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
2026-05-06 重构校准：消除 2 个 JOIN TODO、1 个 WHERE TODO、补齐 3 个码值 CASE（XDYWZL/HTZT/DBLX）、补齐 3 个日期格式转换（HTDQRQ/HTQSRQ/CJRQ）；3 个缺口字段（GSFZJG/SENSITIVEFLAG/KHLB）保留 NULL 赋值，符合审计处置原则。
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

        /* 归属分支机构：本地 DDL 存在该字段，但业务需求映射表未给来源，保留 NULL */
        NULL AS GSFZJG,

        /* 合同金额：贷款协议.贷款金额 -> T_6_2.F020008；直接映射 */
        CAST(NULLIF(TRIM(s1.F020008), '') AS DECIMAL(20,2)) AS HTJE,

        /* 信贷业务种类：贷款协议.信贷业务种类 -> T_6_2.F020066；代码转化 */
        CASE TRIM(s1.F020066)
            WHEN '01' THEN '流动资金贷款'
            WHEN '02' THEN '法人账户透支'
            WHEN '03' THEN '项目贷款'
            WHEN '04' THEN '项目贷款（银团）'
            WHEN '05' THEN '一般固定资产贷款'
            WHEN '06' THEN '住房按揭贷款'
            WHEN '07' THEN '住房按揭贷款'
            WHEN '08' THEN '个人经营性贷款'
            WHEN '09' THEN '商用房贷款'
            WHEN '10' THEN '汽车贷款'
            WHEN '11' THEN '助学贷款'
            WHEN '12' THEN '消费贷款'
            WHEN '13' THEN '个人经营性贷款'
            WHEN '14' THEN '票据贴现'
            WHEN '15' THEN '买断式转贴现'
            WHEN '16' THEN '贸易融资业务'
            WHEN '17' THEN '贸易融资业务'
            WHEN '18' THEN '融资租赁业务'
            WHEN '19' THEN '垫款'
            WHEN '20' THEN '委托贷款'
            WHEN '21' THEN '贸易融资业务'
            WHEN '00' THEN CONCAT('其他-', REPLACE(SUBSTR(TRIM(s1.F020066), 3), '-', ''))
            ELSE s1.F020066
        END AS XDYWZL,

        /* 主合同号：贷款协议.协议ID -> T_6_2.F020001；直接映射 */
        s1.F020001 AS ZHTH,

        /* 客户统一编号：贷款协议.客户ID -> T_6_2.F020003；直接映射 */
        s1.F020003 AS KHTYBH,

        /* 涉密标志：本地 DDL 存在该字段，但业务需求映射表未给来源，保留 NULL */
        NULL AS SENSITIVEFLAG,

        /* 内部机构号：贷款协议.机构ID -> T_6_2.F020002；加工规则：从第 12 位开始截取 */
        SUBSTR(TRIM(s1.F020002), 12) AS NBJGH,

        /* 合同贷款用途：贷款协议.贷款用途 -> T_6_2.F020010；直接映射 */
        s1.F020010 AS HTDKYT,

        /* 合同到期日期：贷款协议.贷款协议到期日期 -> T_6_2.F020049；DATE→VARCHAR(8) YYYYMMDD */
        CASE WHEN s1.F020049 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(s1.F020049) AS VARCHAR(4)),
                         LPAD(CAST(MONTH(s1.F020049) AS VARCHAR(2)), 2, '0'),
                         LPAD(CAST(DAY(s1.F020049) AS VARCHAR(2)), 2, '0'))
        END AS HTDQRQ,

        /* 合同起始日期：贷款协议.贷款协议起始日期 -> T_6_2.F020048；DATE→VARCHAR(8) YYYYMMDD */
        CASE WHEN s1.F020048 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(s1.F020048) AS VARCHAR(4)),
                         LPAD(CAST(MONTH(s1.F020048) AS VARCHAR(2)), 2, '0'),
                         LPAD(CAST(DAY(s1.F020048) AS VARCHAR(2)), 2, '0'))
        END AS HTQSRQ,

        /* 币种：贷款协议.协议币种 -> T_6_2.F020007；直接映射 */
        s1.F020007 AS BZ,

        /* 合同名称：贷款协议.合同名称 -> T_6_2.F020005；直接映射 */
        s1.F020005 AS HTMC,

        /* 信贷合同号：贷款协议.协议ID -> T_6_2.F020001；直接映射 */
        s1.F020001 AS XDHTH,

        /* 客户名称：业务需求要求关联 EAST对公客户信息表 和 EAST个人基础信息表，
           但本仓库暂无这两张 EAST 表的 DDL，暂保留 NULL，待 DDL 到位后实现。 */
        NULL AS KHMC,

        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；
           加工规则：用【贷款协议】.【机构ID】关联【机构信息】.【机构ID】，取【机构信息】.【金融许可证号】 */
        src.A010003 AS JRXKZH,

        /* 备注：贷款协议.备注 -> T_6_2.F020062；直接映射 */
        s1.F020062 AS BBZ,

        /* 客户类别：本地 DDL 存在该字段，但业务需求映射表未给来源，保留 NULL */
        NULL AS KHLB,

        /* 采集日期：贷款协议.采集日期 -> T_6_2.F020063；DATE→VARCHAR(8) YYYYMMDD */
        CONCAT(CAST(YEAR(s1.F020063) AS VARCHAR(4)),
               LPAD(CAST(MONTH(s1.F020063) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(s1.F020063) AS VARCHAR(2)), 2, '0')) AS CJRQ,

        /* 合同状态：贷款协议.协议状态 -> T_6_2.F020061；代码转化 */
        CASE TRIM(s1.F020061)
            WHEN '01' THEN '有效'
            WHEN '02' THEN '未生效'
            WHEN '03' THEN '其他-中止'
            WHEN '04' THEN '终结'
            WHEN '05' THEN '撤销'
            WHEN '06' THEN '其他-无效'
            WHEN '00' THEN CONCAT('其他-', REPLACE(SUBSTR(TRIM(s1.F020061), 3), '-', ''))
            ELSE s1.F020061
        END AS HTZT,

        /* 担保类型：贷款协议.担保方式 -> T_6_2.F020065；加工映射 */
        CASE TRIM(s1.F020065)
            WHEN '01' THEN '质押'
            WHEN '02' THEN '抵押'
            WHEN '03' THEN '保证'
            WHEN '04' THEN '信用'
            WHEN '05' THEN '混合'
            WHEN '06' THEN '混合'
            WHEN '07' THEN '混合'
            WHEN '08' THEN '混合'
            WHEN '00' THEN CONCAT('其他-', REPLACE(SUBSTR(TRIM(s1.F020065), 3), '-', ''))
            ELSE s1.F020065
        END AS DBLX

    FROM T_6_2 s1
    LEFT JOIN T_1_1 src
           ON TRIM(s1.F020002) = TRIM(src.A010001)
          AND src.A010020 = V_DATA_DATE
    WHERE s1.F020063 = V_DATA_DATE;

    COMMIT;
END;
