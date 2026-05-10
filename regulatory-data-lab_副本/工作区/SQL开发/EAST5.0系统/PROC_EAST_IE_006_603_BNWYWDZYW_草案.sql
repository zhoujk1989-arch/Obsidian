/*
草案质量状态：draft，尚未在 GBase 环境执行验证。
校验记录：工作区/SQL开发/EAST5.0系统/CHECK_EAST_IE_006_603_BNWYWDZYW_校验.sql
重建日期：2026-05-09
重建原因：依据《043_表内外业务抵质押物.md》全面校准。修复了 JOIN 键、WHERE 条件、CASE 码值转换、NBJGH 提取、
          JRXKZH 子查询、BBZ 拼接、T_10_1 码值映射和字段来源冲突（见各字段注释）。
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
- 原始材料/表结构/一表通系统/T_9_3-抵质押品-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_8-担保协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_10_1-公共代码-DDL-2026-04-27.sql

源表：
- T_9_3（抵质押品）：主驱动表
- T_6_8（担保协议）：担保合同状态、备注
- T_1_1（机构信息）：金融许可证号
- T_10_1（公共代码）：码值映射（YPLX、YPSYRZJLB）

目标表：
- IE_006_603：表内外业务抵质押物。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 担保合同中约定的各类质押、抵押物信息。对于同一担保合同有不同的抵质押物的，需以不同的质或抵押物编号分多条记录报送。
- 以保证金形式的押品无需在本表填报，但以存单质押形式的押品需要填报。
- 失效担保合同的押品信息于次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1015 行）
取报送日期为当月，通过担保协议ID关联生成EAST《表内外业务担保合同表》的担保合同号，取不为保证金担保的数据作为报送范围

字段来源验证说明：
- J030015（抵押顺位）DDL 类型 char(1)，原始格式 1!n；需求文档写 '01'/'02'/'03' 但 DDL 为单字符。
  实际值应为 '1'/'2'/'3'，按单字符匹配，并在 CASE 中同时兼容双字符格式。
- J030017（抵质押物所有权人证件类型）DDL 类型 char(4)，原始格式 4!n；
  需求文档写 '1999-XX' 但 DDL 为 4 位数字码。'1999'/'2999' 视为前缀码值，按 IN 匹配处理。
- J030005（抵质押物类型）DDL 类型 char(2)，原始格式 2!n；需求文档 '00-XX' 格式需通配匹配。
- J030007（抵质押物状态）DDL 类型 char(2)，原始格式 2!n；同上。
- ZYPZHM（质押票证号码）需求文档标注来源为"担保协议|抵质押品"，但 T_9_3 已含 J030025（质押票证号码），
  实践中直接从 T_9_3 取数。关联需求文档中"担保协议|抵质押品"可能指中间关联表，但 DDL 未提供该独立表。
- NBJGH（内部机构号）需求文档标注来源为 T_9_3 的"机构id"（J030003），按 NBJGH 提取模式 SUBSTR(J030003, 12) 获取。
- JRXKZH（金融许可证号）需按担保协议ID分组取最小 NBJGH，再与 T_1_1 关联。

未确认点：
- SENSITIVEFLAG（涉密标志）、YPSYRKHLB（押品所有人客户类别）、GSFZJG（归属分支机构）
  存在于目标表 DDL 但业务需求映射表中未给出来源，暂置 NULL。
- T_10_1 码值映射表中 '抵质押品' 的 '抵质押物类型' 和 '抵质押物所有权人证件类型' 的实际码值列表待外部原文确认。
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

    -- 删除目标表同一采集日期数据（全量重跑）
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
        /* 涉密标志：业务需求映射表未给来源，暂置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 采集日期：T_9_3.J030037 → IE_006_603.CJRQ；DATE → 'YYYYMMDD' */
        CONCAT(CAST(YEAR(src.J030037) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.J030037) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.J030037) AS VARCHAR(2)), 2, '0')) AS CJRQ,

        /* 备注：T_9_3.J030036 + T_6_8.F080024，以';'拼接。去除空值避免多余分隔符 */
        CONCAT_WS(';',
            NULLIF(TRIM(src.J030036), ''),
            NULLIF(TRIM(s1.F080024), '')
        ) AS BBZ,

        /* 权证登记面积：T_9_3.J030029 → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.J030029), '') AS DECIMAL(20,2)) AS QZDJMJ,

        /* 质押票证号码：T_9_3.J030025（质押票证号码）
           ⚠️ 需求文档标注来源为"担保协议|抵质押品"，但 T_9_3 已含本字段，直接取用 */
        TRIM(src.J030025) AS ZYPZHM,

        /* 押品所有人证件号码：T_9_3.J030018 → 直接映射 */
        TRIM(src.J030018) AS YPSYRZJHM,

        /* 押品所有人名称：T_9_3.J030016 → 直接映射 */
        TRIM(src.J030016) AS YPSYRMC,

        /* 处置权顺位：T_9_3.J030015（抵押顺位）→ 码值转换
           ⚠️ DDL 类型 char(1)（原始格式 1!n），需求文档写 '01'/'02'/'03' 但 DDL 为单字符。
           实际值应为 '1'/'2'/'3'，同时兼容双字符格式。 */
        CASE
            WHEN TRIM(src.J030015) IN ('1', '01') THEN '第一顺位'
            WHEN TRIM(src.J030015) IN ('2', '02') THEN '第二顺位'
            WHEN TRIM(src.J030015) IN ('3', '03') THEN '第三顺位'
            WHEN LEFT(TRIM(src.J030015), 2) = '0-' THEN SUBSTRING(TRIM(src.J030015), 3)
            ELSE ''
        END AS CZQSW,

        /* 币种：T_9_3.J030009 → 直接映射 */
        TRIM(src.J030009) AS BZ,

        /* 抵质押物状态：T_9_3.J030007 → 码值转换
           '01'→正常, '02'→冻结, '03'→查封, '04'→扣押, '00-XX'→其他-XX */
        CASE
            WHEN TRIM(src.J030007) = '01' THEN '正常'
            WHEN TRIM(src.J030007) = '02' THEN '冻结'
            WHEN TRIM(src.J030007) = '03' THEN '查封'
            WHEN TRIM(src.J030007) = '04' THEN '扣押'
            WHEN LEFT(TRIM(src.J030007), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(src.J030007), 4))
            ELSE ''
        END AS DZYWZT,

        /* 押品名称：T_9_3.J030006 → 直接映射 */
        TRIM(src.J030006) AS YPMC,

        /* 担保合同号：T_9_3.J030002（担保协议ID）→ 直接映射 */
        TRIM(src.J030002) AS DBHTH,

        /* 金融许可证号：先取每个担保协议ID的最小NBJGH（从机构ID提取），再与T_1_1关联
           子查询 min_org：按担保协议ID分组，取最小内部机构号
           关联 T_1_1.A010002 = min_org.MIN_NBJGH 取 A010003（金融许可证号） */
        s2.A010003 AS JRXKZH,

        /* 质押票证签发机构：T_9_3.J030026 → 直接映射 */
        TRIM(src.J030026) AS ZYPZQFJG,

        /* 押品所有人客户类别：业务需求映射表未给来源，暂置 NULL */
        NULL AS YPSYRKHLB,

        /* 归属分支机构：业务需求映射表未给来源，暂置 NULL */
        NULL AS GSFZJG,

        /* 抵质押率：T_9_3.J030021 → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.J030021), '') AS DECIMAL(20,2)) AS DZYL,

        /* 起始估值：T_9_3.J030008 → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.J030008), '') AS DECIMAL(20,2)) AS PGJZ,

        /* 担保合同状态：T_6_8.F080019（协议状态）→ 直接映射
           加工映射要求"按担保合同号分组取最大的担保合同状态"，
           但在 603 上下文中，每笔担保协议ID对应一条 T_6_8 记录，
           当协议ID统一时，单条记录的 F080019 即合同状态。
           若存在同一 DBHTH 对应多条协议记录，需加窗口函数或子查询，待验证 */
        TRIM(s1.F080019) AS DBHTZT,

        /* 权证登记号码：T_9_3.J030028 → 直接映射 */
        TRIM(src.J030028) AS QZDJHM,

        /* 押品所有人证件类别：T_9_3.J030017 → 码值映射
           ⚠️ DDL 类型 char(4)（原始格式 4!n），需求文档写 '1999-XX' 但 DDL 为 4 位数字码。
           '1999'/'2999' 按前缀码值处理（先 IN 再通配）。
           非 '1999'/'2999' 时通过 T_10_1（抵质押物所有权人证件类型）映射中文含义。 */
        CASE
            WHEN TRIM(src.J030017) IN ('1999', '2999') THEN '其他'
            WHEN LEFT(TRIM(src.J030017), 4) = '1999' OR LEFT(TRIM(src.J030017), 4) = '2999' THEN '其他'
            ELSE COALESCE(TRIM(code_zjlb.K010005), TRIM(src.J030017))
        END AS YPSYRZJLB,

        /* 已抵押价值：T_9_3.J030019 → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.J030019), '') AS DECIMAL(20,2)) AS YDYJZ,

        /* 最新估值：T_9_3.J030010 → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.J030010), '') AS DECIMAL(20,2)) AS YXRDJZ,

        /* 押品类型：T_9_3.J030005 → 码值映射
           '00-XX' → '其他-XX'，否则通过 T_10_1（抵质押物类型）映射 */
        CASE
            WHEN LEFT(TRIM(src.J030005), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(src.J030005), 4))
            ELSE COALESCE(TRIM(code_yplx.K010005), TRIM(src.J030005))
        END AS YPLX,

        /* 押品编号：T_9_3.J030001 → 加工映射
           如果 J030001 包含 '_'，取 '_' 之前的部分；否则直接取 J030001 */
        CASE
            WHEN INSTR(TRIM(src.J030001), '_') > 0
                 THEN SUBSTRING(TRIM(src.J030001), 1, INSTR(TRIM(src.J030001), '_') - 1)
            ELSE TRIM(src.J030001)
        END AS YPBH,

        /* 内部机构号：T_9_3.J030003（机构ID）→ 提取第12位起
           按 NBJGH 提取模式：SUBSTR(机构ID, 12) */
        SUBSTR(TRIM(src.J030003), 12) AS NBJGH

    FROM T_9_3 src
    -- 关联担保协议：通过担保协议ID
    LEFT JOIN T_6_8 s1
           ON TRIM(src.J030002) = TRIM(s1.F080001)
          AND s1.F080025 = V_DATA_DATE
    -- 码值映射：押品类型（YBT-EAST-DZYWLX）
    LEFT JOIN T_10_1 code_yplx
           ON TRIM(src.J030005) = TRIM(code_yplx.K010004)
          AND TRIM(src.J030003) = TRIM(code_yplx.K010006)
          AND code_yplx.K010002 = '抵质押品'
          AND code_yplx.K010003 = '抵质押物类型'
    -- 码值映射：押品所有人证件类别
    LEFT JOIN T_10_1 code_zjlb
           ON TRIM(src.J030017) = TRIM(code_zjlb.K010004)
          AND TRIM(src.J030003) = TRIM(code_zjlb.K010006)
          AND code_zjlb.K010002 = '抵质押品'
          AND code_zjlb.K010003 = '抵质押物所有权人证件类型'
    -- 子查询：按担保协议ID分组取最小NBJGH（用于 JRXKZH 关联）
    LEFT JOIN (
        SELECT TRIM(J030002) AS DBHTH,
               MIN(SUBSTR(TRIM(J030003), 12)) AS MIN_NBJGH
          FROM T_9_3
         WHERE J030037 = V_DATA_DATE
           AND NVL(TRIM(J030039), '') NOT IN ('1', 'Y')
         GROUP BY TRIM(J030002)
    ) min_org
           ON TRIM(src.J030002) = min_org.DBHTH
    -- 机构信息：通过最小 NBJGH 关联取金融许可证号
    LEFT JOIN T_1_1 s2
           ON TRIM(min_org.MIN_NBJGH) = TRIM(s2.A010002)
          AND s2.A010020 = V_DATA_DATE
    WHERE src.J030037 = V_DATA_DATE                                         -- 取当月采集日期数据
      AND NVL(TRIM(src.J030039), '') NOT IN ('1', 'Y');                     -- 排除保证金担保（J030039='1'=是保证金）
    -- TODO: 终态纳入规则（上一采集日至采集日期间结清/失效/终结的记录）需要根据实际数据情况补充
    --       当前只取了当月 J030037 的记录，未补充跨月终态回算逻辑

    COMMIT;
END;
