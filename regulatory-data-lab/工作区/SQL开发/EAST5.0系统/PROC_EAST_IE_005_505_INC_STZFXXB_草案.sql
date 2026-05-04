/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《032_受托支付信息表.md》生成 EAST5.0 受托支付信息表（IE_005_505_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/032_受托支付信息表.md
- 原始材料/表结构/EAST5.0系统/IE_005_505_INC-受托支付信息表-DDL-2026-04-28.sql

源表：
- T_6_6, T_1_1, T_6_27

目标表：
- IE_005_505_INC：受托支付信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 《个人信贷业务借据表》和《对公信贷业务借据表》中放款方式为“受托支付”或“混合支付”的，在该表中报送受托支付对象信息。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 766 行） 直接映射

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_505_INC_STZFXXB;

CREATE PROCEDURE PROC_EAST_IE_005_505_INC_STZFXXB(
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

    DELETE FROM IE_005_505_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_505_INC (
        XDJJH,
        STZFDXKHLB,
        STZFJE,
        STZFDXZH,
        STZFDXXM,
        NBJGH,
        JRXKZH,
        SENSITIVEFLAG,
        GSFZJG,
        XDHTH,
        BZ,
        STZFRQ,
        STZFDXHM,
        STZFDXHH,
        BBZ,
        CJRQ,
        DKJE
    )
    SELECT
        /* 信贷借据号：受托支付信息.借据ID -> T_6_6.F060002；直接映射 */
        src.F060002 AS XDJJH,
        /* 受托支付对象客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS STZFDXKHLB,
        /* 受托支付金额：受托支付信息.受托支付金额 -> T_6_6.F060003；直接映射 */
        CAST(NULLIF(TRIM(src.F060003), '') AS DECIMAL(20,2)) AS STZFJE,
        /* 受托支付对象账号：受托支付信息.受托支付对象账号 -> T_6_6.F060005；直接映射 */
        src.F060005 AS STZFDXZH,
        /* 受托支付对象行名：受托支付信息.受托支付对象行名 -> T_6_6.F060008；直接映射 */
        src.F060008 AS STZFDXXM,
        /* 内部机构号：受托支付信息.机构ID -> T_6_6.F060011；加工规则：从【受托支付信息】.【机构ID】第12位开始截取。 */
        SUBSTR(TRIM(src.F060011), 12) AS NBJGH,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工规则：用【受托支付信息】.【机构ID】关联【机构信息】.【机构ID】,取【机构信息】.【金融许可证号】。 */
        s1.A010003 AS JRXKZH,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 信贷合同号：受托支付信息.协议ID -> T_6_6.F060001；直接映射 */
        src.F060001 AS XDHTH,
        /* 币种：受托支付信息.币种 -> T_6_6.F060012；直接映射 */
        src.F060012 AS BZ,
        /* 受托支付日期：受托支付信息.受托支付日期 -> T_6_6.F060004；格式转换：格式转为'YYYYMMDD'，若为空，则赋默认值'99991231'。 */
        CASE WHEN src.F060004 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.F060004) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F060004) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F060004) AS VARCHAR(2)), 2, '0')) END AS STZFRQ,
        /* 受托支付对象户名：受托支付信息.受托支付对象户名 -> T_6_6.F060006；直接映射 */
        src.F060006 AS STZFDXHM,
        /* 受托支付对象行号：受托支付信息.受托支付对象行号 -> T_6_6.F060007；直接映射 */
        src.F060007 AS STZFDXHH,
        /* 备注：受托支付信息.备注 -> T_6_6.F060009；加工映射：提取一表通《6.6受托支付信息》、《6.27贷款协议补充信息》备注，以“;”拼接。 */
        src.F060009 AS BBZ,
        /* 采集日期：受托支付信息.采集日期 -> T_6_6.F060010；赋值：批量【数据日期】，格式转换：格式转为'YYYYMMDD'。 */
        CONCAT(CAST(YEAR(src.F060010) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F060010) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F060010) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 贷款金额：贷款协议补充信息.借款金额 -> T_6_27.F270009；加工规则：用【受托支付信息】.【借据ID】关联【贷款协议补充信息】.【借据ID】,取【贷款协议补充信息】.【借款金额】。 */
        CAST(NULLIF(TRIM(s2.F270009), '') AS DECIMAL(20,2)) AS DKJE
    FROM T_6_6 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_6_27 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《032_受托支付信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
