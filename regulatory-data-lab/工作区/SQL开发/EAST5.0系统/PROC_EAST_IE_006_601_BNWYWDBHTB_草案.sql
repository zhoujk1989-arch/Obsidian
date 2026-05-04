/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《041_表内外业务担保合同表.md》生成 EAST5.0 表内外业务担保合同表（IE_006_601）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/041_表内外业务担保合同表.md
- 原始材料/表结构/EAST5.0系统/IE_006_601-表内外业务担保合同表-DDL-2026-04-28.sql

源表：
- T_6_8, T_1_1

目标表：
- IE_006_601：表内外业务担保合同表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 各项表内外业务（包括但不限于贷款、同业投资、表外业务等）中签订的各类担保合同信息。被担保业务若无合同号，则“被担保合同号”填写该笔业务唯一识别标识，如“自营资金业务余额表.金融工具编号”。以保证金形式的担保无需在本表填报，但以存单质押形式的担保需要填报。本表反映被担保合同和担保合同之间的关系，为多对多关系表，一个担保合同担保多个业务合同的，需按多笔填报，多个担保合同担保一个合同的，也需按多笔填报。失效的担保合同于次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 986 行） 取报送日期为当月，且剔除上月失效数据，通过抵质押类型且担保协议ID不为空的数据，或不为抵质押类型当期仍然生效的协议，关联9.3的担保协议ID，取不为保证金的数据作为报送范围

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_006_601_BNWYWDBHTB;

CREATE PROCEDURE PROC_EAST_IE_006_601_BNWYWDBHTB(
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

    DELETE FROM IE_006_601
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_006_601 (
        DBHTH,
        GSFZJG,
        NBJGH,
        DBLX,
        DBJE,
        DBDQRQ,
        DBHTZT,
        CJRQ,
        DBBZ,
        DBQSRQ,
        JBRGH,
        BBZ,
        BDBYWLX,
        JRXKZH,
        DBHTLX,
        SENSITIVEFLAG,
        BDBHTH
    )
    SELECT
        /* 担保合同号：担保协议.协议ID -> T_6_8.F080001；直接映射 */
        src.F080001 AS DBHTH,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 内部机构号：待确认来源字段：担保协议.机构id */
        NULL AS NBJGH,
        /* 担保类型：担保协议.担保类型 -> T_6_8.F080004；代码转换： ’01’转为’抵押’ ’02’转为’质押’ ’03、04、05、06’转为’保证’， ’07’转为’混合’， ’00-XX’转为’其他-XX’。 XX为银行自定义；转换规则需人工补齐 CASE 分支 */
        src.F080004 AS DBLX,
        /* 担保金额：担保协议.协议金额 -> T_6_8.F080015；直接映射 */
        CAST(NULLIF(TRIM(src.F080015), '') AS DECIMAL(20,2)) AS DBJE,
        /* 担保到期日期：担保协议.到期日期 -> T_6_8.F080014；加工映射：需转成'YYYYMMDD'格式 */
        CONCAT(CAST(YEAR(src.F080014) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F080014) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F080014) AS VARCHAR(2)), 2, '0')) AS DBDQRQ,
        /* 担保合同状态：担保协议.协议状态 -> T_6_8.F080019；代码转换：01转有效，其他转失效；转换规则需人工补齐 CASE 分支 */
        src.F080019 AS DBHTZT,
        /* 采集日期：担保协议.采集日期 -> T_6_8.F080025；格式转换：格式转为'YYYYMMDD'。 */
        CONCAT(CAST(YEAR(src.F080025) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F080025) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F080025) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 担保币种：担保协议.协议币种 -> T_6_8.F080016；直接映射 */
        src.F080016 AS DBBZ,
        /* 担保起始日期：担保协议.生效日期 -> T_6_8.F080013；加工映射：需转成'YYYYMMDD'格式 */
        CONCAT(CAST(YEAR(src.F080013) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F080013) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F080013) AS VARCHAR(2)), 2, '0')) AS DBQSRQ,
        /* 经办人工号：担保协议.经办员工ID -> T_6_8.F080020；直接映射 */
        src.F080020 AS JBRGH,
        /* 备注：担保协议.备注 -> T_6_8.F080024；提取一表通《表6.8担保协议》备注，以“;”拼接。 */
        src.F080024 AS BBZ,
        /* 被担保业务类型：担保协议.被担保业务类型 -> T_6_8.F080006；代码转换： ‘01’赋值为’表内信贷’ ‘02’赋值为’承兑汇票’ ‘03’赋值为’保函’ ‘04’赋值为’信用证’ ‘05’赋值为’贷款承诺‘ ‘06’赋值为’委托贷款’ ‘07’赋值为’自营投资’ ‘00-XX’赋值为’其他-XX’ XX为银行自定义；转换规则需人工补齐 CASE 分支 */
        src.F080006 AS BDBYWLX,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射，通过【担保协议】.【机构ID】=【机构信息】.【机构ID】关联。 */
        s1.A010003 AS JRXKZH,
        /* 担保合同类型：担保协议.担保合同类型 -> T_6_8.F080007；代码转换：01转为“一般担保合同”，02转为“最高额担保合同”；转换规则需人工补齐 CASE 分支 */
        src.F080007 AS DBHTLX,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 被担保合同号：担保协议.被担保协议ID -> T_6_8.F080003；直接映射 */
        src.F080003 AS BDBHTH
    FROM T_6_8 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《041_表内外业务担保合同表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
