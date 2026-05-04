/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《062_即期及衍生品交易信息表.md》生成 EAST5.0 即期及衍生品交易信息表（IE_010_1005_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/062_即期及衍生品交易信息表.md
- 原始材料/表结构/EAST5.0系统/IE_010_1005_INC-即期及衍生品交易信息表-DDL-2026-04-28.sql

源表：
- T_7_5, T_1_1

目标表：
- IE_010_1005_INC：即期及衍生品交易信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 填报范围：报告期内发生的自营、代客即期资金交易，以及衍生品交易信息，按发生额填报。其中即期资金交易包括结售汇、贵金属实物（积存金）交易、商品类交易等。交易不涉及的数据项不填报。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1524 行） 主表：【衍生品交易】 左关联：【机构信息】 关联条件：【衍生品交易】【交易机构ID】关联【机构信息】【机构ID】 过滤条件：【衍生品交易】【采集日期】当月数据

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_010_1005_INC_JQJYSPJYXXB;

CREATE PROCEDURE PROC_EAST_IE_010_1005_INC_JQJYSPJYXXB(
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

    DELETE FROM IE_010_1005_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_010_1005_INC (
        JYLX,
        BBZ,
        MFKHTYBH2,
        QXRQ,
        JGPL,
        BDSL,
        JYCS,
        QQLX,
        XQJGDW,
        ZXYMC,
        GZBZ,
        JYYGH,
        GSFZJG,
        CJRQ,
        JRXKZH,
        YHJGMC,
        XQJG,
        JCZCLX,
        JYSJ,
        SENSITIVEFLAG,
        CJJGDW,
        NBJGH,
        JYBH,
        YWPZ,
        JCZCMC,
        HYZL,
        MFMC1,
        MFKHTYBH1,
        MFMC2,
        JYRQ,
        DQRQ,
        JZRQ,
        BDSLDW,
        CJJG,
        JGFS,
        XQFS,
        BZJBZ,
        ZYJYDS,
        GZJE,
        GZRQ,
        SPRGH,
        JYZT
    )
    SELECT
        /* 交易类型：衍生品交易.交易类型 -> T_7_5.G050006；码值转化：根据如下转换 源码值 目标值 01 套期保值 02 代客 卖出衍生品。 03 代客平盘 含权衍生品执行权利。 04 做市 衍生品到期按合同约定交割。 05 自营 远期或互换中按固定利率支付利息。 00 其他-自定义；转换规则需人工补齐 CASE 分支 */
        src.G050006 AS JYLX,
        /* 备注：衍生品交易.备注 -> T_7_5.G050035；直接映射 */
        src.G050035 AS BBZ,
        /* 卖方客户统一编号：衍生品交易.交易对手方向 -> T_7_5.G050037；当【衍生品交易】.交易对手方向 ='01' /*买方* /则用【衍生品交易】.交易机构ID 关联取金融许可证号 当【衍生品交易】.交易对手方向 ='02' /*买方* /则【衍生品交易】.交易对手客户编号 */
        src.G050037 AS MFKHTYBH2,
        /* 起息日期：衍生品交易.起息日期 -> T_7_5.G050044；格式转化：YYYY-MM-DD转换为YYYYMMDD */
        CONCAT(CAST(YEAR(src.G050044) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G050044) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G050044) AS VARCHAR(2)), 2, '0')) AS QXRQ,
        /* 交割频率：衍生品交易.交割频率 -> T_7_5.G050012；直接映射 */
        src.G050012 AS JGPL,
        /* 标的数量：衍生品交易.标的数量 -> T_7_5.G050013；直接映射 */
        CAST(NULLIF(TRIM(src.G050013), '') AS DECIMAL(20,2)) AS BDSL,
        /* 交易场所：衍生品交易.交易场所 -> T_7_5.G050007；直接映射 */
        src.G050007 AS JYCS,
        /* 期权类型：衍生品交易.期权类型 -> T_7_5.G050018；码值转化：（代码值域：QQLX01） 一表通代码 映射east： 01 看涨 看涨 02 看跌 看跌 03 上限 上限 04 下限 下限 00-自定义 其他-自定义；转换规则需人工补齐 CASE 分支 */
        src.G050018 AS QQLX,
        /* 行权价格单位：衍生品交易.行权价格单位 -> T_7_5.G050020；直接映射 */
        src.G050020 AS XQJGDW,
        /* 主协议名称：衍生品交易.主协议名称 -> T_7_5.G050022；直接映射 */
        src.G050022 AS ZXYMC,
        /* 估值币种：衍生品交易.估值币种 -> T_7_5.G050049；直接映射 */
        src.G050049 AS GZBZ,
        /* 交易员工号：待确认来源字段：衍生品交易.交易员工ID */
        NULL AS JYYGH,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 采集日期：衍生品交易.采集日期 -> T_7_5.G050036；加工映射转换'YYYYMMDD'格式 */
        CONCAT(CAST(YEAR(src.G050036) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G050036) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G050036) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        s1.A010003 AS JRXKZH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        s1.A010005 AS YHJGMC,
        /* 行权价格：衍生品交易.行权价格 -> T_7_5.G050019；直接映射 */
        CAST(NULLIF(TRIM(src.G050019), '') AS DECIMAL(20,2)) AS XQJG,
        /* 基础资产类型：衍生品交易.基础资产类型 -> T_7_5.G050041；直接映射 */
        src.G050041 AS JCZCLX,
        /* 交易时间：衍生品交易.交易时间 -> T_7_5.G050009；格式转化：HH:MI:SS转换为HHMISS */
        REPLACE(src.G050009, ':', '') AS JYSJ,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 成交价格单位：衍生品交易.成交价格单位 -> T_7_5.G050016；直接映射 */
        src.G050016 AS CJJGDW,
        /* 内部机构号：衍生品交易.交易机构ID -> T_7_5.G050002；从第12位开始截取【衍生品交易】.交易机构ID */
        SUBSTR(TRIM(src.G050002), 12) AS NBJGH,
        /* 交易编号：衍生品交易.交易ID -> T_7_5.G050001；直接映射 */
        src.G050001 AS JYBH,
        /* 业务品种：衍生品交易.业务品种 -> T_7_5.G050040；直接映射 */
        src.G050040 AS YWPZ,
        /* 基础资产名称：衍生品交易.基础资产名称 -> T_7_5.G050042；直接映射 */
        src.G050042 AS JCZCMC,
        /* 合约种类：衍生品交易.合约种类 -> T_7_5.G050043；码值转化：根据如下转换 源码值 目标值 01 即期 即期 02 远期 远期 03 期货 期货 04 掉期 掉期 05 互换 互换 06 期权 期权 07 延期交收 延期交收 00-自定义 其他-银行自定义。；转换规则需人工补齐 CASE 分支 */
        src.G050043 AS HYZL,
        /* 买方名称：衍生品交易.交易对手方向 -> T_7_5.G050037；当【衍生品交易】.交易对手方向 ='01' /*买方* /则取 【衍生品交易】.交易对手名称 当【衍生品交易】.交易对手方向 ='02' /*卖方* /则取 【衍生品交易】.交易机构名称 */
        src.G050037 AS MFMC1,
        /* 买方客户统一编号：衍生品交易.交易对手方向 -> T_7_5.G050037；当【衍生品交易】.交易对手方向 ='01' /*买方* /则取 【衍生品交易】.交易对手客户编号 当【衍生品交易】.交易对手方向 ='02' /*卖方* /则用【衍生品交易】.交易机构ID 关联取金融许可证号。 */
        src.G050037 AS MFKHTYBH1,
        /* 卖方名称：衍生品交易.交易对手方向 -> T_7_5.G050037；当【衍生品交易】.交易对手方向 ='01' /*买方* /则 '各取 【衍生品交易】.交易机构名称。 当【衍生品交易】.交易对手方向 ='02' /*买方* /则【衍生品交易】.交易对手名称 */
        src.G050037 AS MFMC2,
        /* 交易日期：衍生品交易.交易日期 -> T_7_5.G050008；格式转化：YYYY-MM-DD转换为YYYYMMDD */
        CONCAT(CAST(YEAR(src.G050008) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G050008) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G050008) AS VARCHAR(2)), 2, '0')) AS JYRQ,
        /* 到期日期：衍生品交易.到期日期 -> T_7_5.G050045；格式转化：YYYY-MM-DD转换为YYYYMMDD */
        CONCAT(CAST(YEAR(src.G050045) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G050045) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G050045) AS VARCHAR(2)), 2, '0')) AS DQRQ,
        /* 截止日期：衍生品交易.截止日期 -> T_7_5.G050046；格式转化：YYYY-MM-DD转换为YYYYMMDD */
        CONCAT(CAST(YEAR(src.G050046) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G050046) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G050046) AS VARCHAR(2)), 2, '0')) AS JZRQ,
        /* 标的数量单位：衍生品交易.标的数量单位 -> T_7_5.G050014；直接映射 */
        src.G050014 AS BDSLDW,
        /* 成交价格：衍生品交易.成交价格 -> T_7_5.G050015；直接映射 */
        CAST(NULLIF(TRIM(src.G050015), '') AS DECIMAL(20,2)) AS CJJG,
        /* 交割方式：衍生品交易.交割方式 -> T_7_5.G050017；码值转化：（代码值域：JGFS01） 一表通代码 映射east： 01 全额 全额 02 差额 差额 03 净额 其他-净额 04 实物 实物 05 现金 现金 00 其他 其他；转换规则需人工补齐 CASE 分支 */
        src.G050017 AS JGFS,
        /* 行权方式：衍生品交易.行权方式 -> T_7_5.G050047；码值转化： 一表通代码 映射east： 01 美式 美式 02 欧式 欧式 03 百慕大 百慕大 00-自定义 其他-自定义；转换规则需人工补齐 CASE 分支 */
        src.G050047 AS XQFS,
        /* 保证金标志：衍生品交易.保证金标识 -> T_7_5.G050021；码值转化：0 转'否'，1转'是'；转换规则需人工补齐 CASE 分支 */
        src.G050021 AS BZJBZ,
        /* 中央交易对手：衍生品交易.中央交易对手 -> T_7_5.G050023；直接映射 */
        src.G050023 AS ZYJYDS,
        /* 估值金额：衍生品交易.估值金额 -> T_7_5.G050048；直接映射 */
        CAST(NULLIF(TRIM(src.G050048), '') AS DECIMAL(20,2)) AS GZJE,
        /* 估值日期：衍生品交易.估值日期 -> T_7_5.G050050；直接映射 */
        src.G050050 AS GZRQ,
        /* 审批人工号：衍生品交易.审批员工ID -> T_7_5.G050034；直接映射 */
        src.G050034 AS SPRGH,
        /* 交易状态：衍生品交易.交易状态 -> T_7_5.G050024；码值转化： 一表通代码 映射east： 01 新增 新增 02 终止 终止 03 变更 变更 04 行权 行权 05 估值 估值 00 00-自定义 其他-自定义 其余返回 交易状态字段值；转换规则需人工补齐 CASE 分支 */
        src.G050024 AS JYZT
    FROM T_7_5 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《062_即期及衍生品交易信息表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
