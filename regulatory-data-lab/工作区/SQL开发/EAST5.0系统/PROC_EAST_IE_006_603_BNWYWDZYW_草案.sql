/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《043_表内外业务抵质押物.md》生成 EAST5.0 表内外业务抵质押物（IE_006_603）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/043_表内外业务抵质押物.md
- 原始材料/表结构/EAST5.0系统/IE_006_603-表内外业务抵质押物-DDL-2026-04-28.sql

源表：
- T_9_3, T_6_8, T_1_1

目标表：
- IE_006_603：表内外业务抵质押物。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 担保合同中约定的各类质押、抵押物信息。对于同一担保合同有不同的抵质押物的，需以不同的质或抵押物编号分多条记录报送。以保证金形式的押品无需在本表填报，但以存单质押形式的押品需要填报。失效担保合同的押品信息于次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1015 行） 取报送日期为当月，通过担保协议ID关联生成EAST《表内外业务担保合同表》的担保合同号，取不为保证金担保的数据作为报送范围

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_006_603_BNWYWDZYW;

CREATE PROCEDURE PROC_EAST_IE_006_603_BNWYWDZYW(
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

    DELETE FROM IE_006_603
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_006_603 (
        SENSITIVEFLAG,
        CJRQ,
        BBZ,
        QZDJMJ,
        ZYPZHM,
        YPSYRZJHM,
        YPSYRMC,
        CZQSW,
        BZ,
        DZYWZT,
        YPMC,
        DBHTH,
        JRXKZH,
        ZYPZQFJG,
        YPSYRKHLB,
        GSFZJG,
        DZYL,
        PGJZ,
        DBHTZT,
        QZDJHM,
        YPSYRZJLB,
        YDYJZ,
        YXRDJZ,
        YPLX,
        YPBH,
        NBJGH
    )
    SELECT
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 采集日期：抵质押品.采集日期 -> T_9_3.J030037；格式转换：格式转为'YYYYMMDD'。 */
        CONCAT(CAST(YEAR(src.J030037) AS VARCHAR(4)), LPAD(CAST(MONTH(src.J030037) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.J030037) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 备注：抵质押品.备注 -> T_9_3.J030036；提取一表通《表9.3抵质押品》、《表6.8担保协议》备注，以“;”拼接。。 */
        src.J030036 AS BBZ,
        /* 权证登记面积：抵质押品.权证登记面积 -> T_9_3.J030029；直接映射 */
        CAST(NULLIF(TRIM(src.J030029), '') AS DECIMAL(20,2)) AS QZDJMJ,
        /* 质押票证号码：待确认来源字段：担保协议\.抵质押品 */
        NULL AS ZYPZHM,
        /* 押品所有人证件号码：抵质押品.抵质押物所有权人证件号码 -> T_9_3.J030018；直接映射 */
        src.J030018 AS YPSYRZJHM,
        /* 押品所有人名称：抵质押品.抵质押物所有权人名称 -> T_9_3.J030016；直接映射 */
        src.J030016 AS YPSYRMC,
        /* 处置权顺位：抵质押品.抵押顺位 -> T_9_3.J030015；码值转换： ’01’赋值为’第一顺位’， ’02’赋值为’第二顺位’， ’03’赋值为’第三顺位’， ’00-xx’赋值为’xx’；转换规则需人工补齐 CASE 分支 */
        src.J030015 AS CZQSW,
        /* 币种：抵质押品.币种 -> T_9_3.J030009；直接映射 */
        src.J030009 AS BZ,
        /* 抵质押物状态：抵质押品.抵质押物状态 -> T_9_3.J030007；代码转换： ’01’赋值为’正常’， ’02’赋值为’冻结’， ’03’赋值为’查封’， ’04’赋值为’扣押’， ’00-XX’赋值为’其他-XX’。 XX为银行自定义；转换规则需人工补齐 CASE 分支 */
        src.J030007 AS DZYWZT,
        /* 押品名称：抵质押品.抵质押物名称 -> T_9_3.J030006；直接映射 */
        src.J030006 AS YPMC,
        /* 担保合同号：抵质押品.担保协议ID -> T_9_3.J030002；直接映射 */
        src.J030002 AS DBHTH,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工映射：【表内外业务担保合同表】按照【担保合同号】分组取最小的【内部机构号】，然后与【机构信息】.【机构ID】关联取【金融许可证号】。 */
        s2.A010003 AS JRXKZH,
        /* 质押票证签发机构：抵质押品.质押票证签发机构 -> T_9_3.J030026；直接映射 */
        src.J030026 AS ZYPZQFJG,
        /* 押品所有人客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS YPSYRKHLB,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 抵质押率：抵质押品.抵质押率 -> T_9_3.J030021；直接映射 */
        CAST(NULLIF(TRIM(src.J030021), '') AS DECIMAL(20,2)) AS DZYL,
        /* 起始估值：抵质押品.起始估值 -> T_9_3.J030008；直接映射 */
        CAST(NULLIF(TRIM(src.J030008), '') AS DECIMAL(20,2)) AS PGJZ,
        /* 担保合同状态：担保协议.协议状态 -> T_6_8.F080019；加工映射：【表内外业务担保合同表】按照【担保合同号】分组取最大的【担保合同状态】 */
        s1.F080019 AS DBHTZT,
        /* 权证登记号码：抵质押品.权证登记号码 -> T_9_3.J030028；直接映射 */
        src.J030028 AS QZDJHM,
        /* 押品所有人证件类别：抵质押品.抵质押物所有权人证件类型 -> T_9_3.J030017；当【抵质押品】.【抵质押物所有权人证件类型】为 '1999-XX'或'2999-XX'时 取 '其他-XX' ， 当【抵质押品】.【抵质押物所有权人证件类型】不为 '1999-XX'或'2999-XX' ，根据【YBT-EAST-DZYWLX】映射 XX为银行自定义。 */
        src.J030017 AS YPSYRZJLB,
        /* 已抵押价值：抵质押品.已抵押价值 -> T_9_3.J030019；直接映射 */
        CAST(NULLIF(TRIM(src.J030019), '') AS DECIMAL(20,2)) AS YDYJZ,
        /* 最新估值：抵质押品.最新估值 -> T_9_3.J030010；直接映射 */
        CAST(NULLIF(TRIM(src.J030010), '') AS DECIMAL(20,2)) AS YXRDJZ,
        /* 押品类型：抵质押品.抵质押物类型 -> T_9_3.J030005；当【抵质押品】.【抵质押物类型】为 '00-XX' 取 '其他-XX' ， 当【抵质押品】.【抵质押物类型】不为 '00-XX' ，根据【YBT-EAST-DZYWLX】映射 XX为银行自定义 */
        src.J030005 AS YPLX,
        /* 押品编号：抵质押品.押品ID -> T_9_3.J030001；加工映射：如果【抵质押品】.【押品ID】中存在'_'则取【押品ID】中'_'之前的部分作为押品编号；如果【抵质押品】.【押品ID】中不存在'_'，则直接取【押品ID】作为押品编号。 */
        src.J030001 AS YPBH,
        /* 内部机构号：待确认来源字段：抵质押品.机构id */
        NULL AS NBJGH
    FROM T_9_3 src
    LEFT JOIN T_6_8 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_1_1 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《043_表内外业务抵质押物.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
