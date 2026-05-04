/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《048_贷款五级形态变动表.md》生成 EAST5.0 贷款五级形态变动表（IE_007_705_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/048_贷款五级形态变动表.md
- 原始材料/表结构/EAST5.0系统/IE_007_705_INC-贷款五级形态变动表-DDL-2026-04-28.sql

源表：
- 待确认

目标表：
- IE_007_705_INC：贷款五级形态变动表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 所有表内信贷的五级分类变动信息，与其他表格中五级分类字段一致。需要报送信用卡业务的五级形态变动，填报为信贷合同号=信用卡账号，信贷借据号=信用卡卡号。无需报送新发放业务（五级分类从无到有）的五级形态变动。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1121 行） 【五级分类状态】.【采集日期】在跑批日期当月内 且【五级分类状态】.【采集日期】=【五级分类状态】.【调整日期】

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_007_705_INC_DKWJXTBDB;

CREATE PROCEDURE PROC_EAST_IE_007_705_INC_DKWJXTBDB(
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

    DELETE FROM IE_007_705_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_007_705_INC (
        XDJJH,
        KHTYBH,
        CJRQ,
        GSFZJG,
        YWJFL,
        TZRQ,
        YHJGMC,
        BBZ,
        NBJGH,
        JRXKZH,
        KHLB,
        SENSITIVEFLAG,
        BDFS,
        BDYY,
        JBGYH,
        XWJFL,
        KHMC,
        XDHTH
    )
    SELECT
        /* 信贷借据号：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：细分资产ID<br>个人贷款：细分资产ID<br>信用卡：细分资产ID */
        NULL AS XDJJH,
        /* 客户统一编号：待确认来源字段：对公贷款、小企业：一表通转出的EAST【对公信贷分户账】<br>个人贷款：一表通转出的EAST【个人信贷分户账】<br>信用卡：一表通转出的EAST【信用卡信息表】.对公贷款、小企业：客户统一编号<br>个人贷款：客户统一编号<br>信用卡：客户统一编号 */
        NULL AS KHTYBH,
        /* 采集日期：待确认来源字段：/./ */
        NULL AS CJRQ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 原五级分类：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：原五级分类<br>个人贷款：原五级分类<br>信用卡：原五级分类 */
        NULL AS YWJFL,
        /* 调整日期：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：调整日期<br>个人贷款：调整日期<br>信用卡：调整日期 */
        NULL AS TZRQ,
        /* 银行机构名称：待确认来源字段：对公贷款、小企业：五级分类状态\.机构信息<br>个人贷款：五级分类状态\ */
        NULL AS YHJGMC,
        /* 备注：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：备注<br>个人贷款：备注<br>信用卡：备注 */
        NULL AS BBZ,
        /* 内部机构号：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：机构ID<br>个人贷款：机构ID<br>信用卡：机构ID */
        NULL AS NBJGH,
        /* 金融许可证号：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：机构ID\ */
        NULL AS JRXKZH,
        /* 客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS KHLB,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 变动方式：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：变动方式<br>个人贷款：变动方式<br>信用卡：变动方式 */
        NULL AS BDFS,
        /* 变动原因：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：变动原因<br>个人贷款：变动原因<br>信用卡：变动原因 */
        NULL AS BDYY,
        /* 经办人工号：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：经办员工ID<br>个人贷款：经办员工ID<br>信用卡：经办员工ID */
        NULL AS JBGYH,
        /* 新五级分类：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：当前五级分类<br>个人贷款：当前五级分类<br>信用卡：当前五级分类 */
        NULL AS XWJFL,
        /* 客户名称：待确认来源字段：对公贷款、小企业：一表通转出的EAST【对公客户信息表】<br>个人贷款：一表通转出的EAST【个人基础信息表】<br>信用卡：一表通转出的EAST【信用卡信息表】.对公贷款、小企业：客户名称<br>个人贷款：客户名称<br>信用卡：客户名称 */
        NULL AS KHMC,
        /* 信贷合同号：待确认来源字段：对公贷款、小企业：五级分类状态<br>个人贷款：五级分类状态<br>信用卡：五级分类状态.对公贷款、小企业：协议ID<br>个人贷款：协议ID<br>信用卡：协议ID */
        NULL AS XDHTH
    FROM TODO_SOURCE_TABLE src
    WHERE 1 = 1
      /* TODO: 按《048_贷款五级形态变动表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
