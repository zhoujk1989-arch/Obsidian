/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《047_资产转让关系表.md》生成 EAST5.0 资产转让关系表（IE_007_704）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/047_资产转让关系表.md
- 原始材料/表结构/EAST5.0系统/IE_007_704-资产转让关系表-DDL-2026-04-28.sql

源表：
- T_7_9, T_1_1

目标表：
- IE_007_704：资产转让关系表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 本表报送信贷资产转让合同与被转让贷款借据的对应关系，一个转让合同对应多个借据的，按借据填报多条记录。对于信用卡资产转让，以信用卡账号填报为借据号。票据的买卖、买入返售、卖出回购不在本表填报。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1111 行） 主表：【一表通】【信贷资产转让】，取按照【借据ID】、【资产转让方向】分组，采集日期降序排列后的第一条数据 过滤条件：【信贷资产转让】.采集日期<=跑批日期 左关联：【一表通】【机构信息】 关联条件：【信贷资产转让】.【机构ID】从第12位开始截取=【机构信息】.【机构ID】从第12位开始截取 且【机构信息】.采集日期为跑批日期 内关联：【一表通转EAST】【信贷资产转让表】 关联条件：【信贷资产转让表】.采集日期为跑批日期 且【信贷资产转让表】.【转让合同号】=【信贷资产转让】.【协议ID】 且【信贷资产转让表】.【资产转让方向】=【信贷资产转让】.【资产转让方向】为01时记为'转入'，为02时记为'转出'，其他为''

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_007_704_ZCZRGXB;

CREATE PROCEDURE PROC_EAST_IE_007_704_ZCZRGXB(
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

    DELETE FROM IE_007_704
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_007_704 (
        ZRHTH,
        XDJJH,
        NBJGH,
        JRXKZH,
        ZRDKLX,
        SENSITIVEFLAG,
        BBZ,
        ZRDKBJ,
        XDZCLX,
        GSFZJG,
        CJRQ
    )
    SELECT
        /* 转让合同号：信贷资产转让.协议ID -> T_7_9.G090001；直接映射 */
        src.G090001 AS ZRHTH,
        /* 信贷借据号：待确认来源字段：信贷资产转让.借据ID */
        NULL AS XDJJH,
        /* 内部机构号：信贷资产转让.机构ID -> T_7_9.G090002；针对月中信息调整的情况，由于各家行EAST报送方式不同，转换过程中可依据行内情况判定使用调整前或调整后信息，确保转换后结果一致。 加工映射：将【一表通】【信贷资产转让】的【机构id】从第12位开始截取 */
        SUBSTR(TRIM(src.G090002), 12) AS NBJGH,
        /* 金融许可证号：待确认来源字段：信贷资产转让\.机构信息 */
        NULL AS JRXKZH,
        /* 转让贷款利息：信贷资产转让.转让贷款利息总额 -> T_7_9.G090008；直接映射 */
        CAST(NULLIF(TRIM(src.G090008), '') AS DECIMAL(20,2)) AS ZRDKLX,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 备注：信贷资产转让.备注 -> T_7_9.G090019；直接映射 */
        src.G090019 AS BBZ,
        /* 转让贷款本金：信贷资产转让.转让贷款本金总额 -> T_7_9.G090007；直接映射 */
        CAST(NULLIF(TRIM(src.G090007), '') AS DECIMAL(20,2)) AS ZRDKBJ,
        /* 信贷资产类型：信贷资产转让.资产类型 -> T_7_9.G090009；加工映射：01为个人贷款，02为对公贷款，03为信用卡贷款，其他码值转为其他；转换规则需人工补齐 CASE 分支 */
        src.G090009 AS XDZCLX,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 采集日期：待确认来源字段：/./ */
        NULL AS CJRQ
    FROM T_7_9 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《047_资产转让关系表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
