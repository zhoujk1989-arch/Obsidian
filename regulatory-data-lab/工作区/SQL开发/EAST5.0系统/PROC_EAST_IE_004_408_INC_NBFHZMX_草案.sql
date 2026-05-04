/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《023_内部分户账明细记录.md》生成 EAST5.0 内部分户账明细记录（IE_004_408_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/023_内部分户账明细记录.md
- 原始材料/表结构/EAST5.0系统/IE_004_408_INC-内部分户账明细记录-DDL-2026-04-28.sql

源表：
- T_7_10

目标表：
- IE_004_408_INC：内部分户账明细记录。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 根据会计核算科目，除单列账之外的科目原则上都归入内部账采集；单列账报送至信用卡、对公/个人等分户账中；资本账户需要报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 469 行） 主表：【内部分户账交易】 左关联：【EAST.内部分户账】 关联条件：【内部分户账交易】.【分户账号】 = 【EAST.内部分户账】.【分户账号】 左关联：【EAST.内部科目对照表】 关联条件：【客户存款账户交易表】【科目ID】，关联【EAST.内部科目对照表】的【会计科目编号】

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_408_INC_NBFHZMX;

CREATE PROCEDURE PROC_EAST_IE_004_408_INC_NBFHZMX(
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

    DELETE FROM IE_004_408_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_408_INC (
        DFXM,
        JYQD,
        SQGYH,
        JZRQ,
        BBZ,
        JYXLH,
        NBJGH,
        MXKMBH,
        MXKMMC,
        HXJYRQ,
        HXJYSJ,
        JYLX,
        JYJE,
        DFYE,
        DFZH,
        DFHM,
        CJRQ,
        GSFZJG,
        SENSITIVEFLAG,
        JRXKZH,
        YHJGMC,
        ZHMC,
        NBFHZZH,
        BZ,
        JYJDBZ,
        JFYE,
        DFKMBH,
        DFKMMC,
        DFXH,
        ZY,
        CBMBZ,
        XZBZ,
        JYGYH,
        XZRQ,
        DFKHLB
    )
    SELECT
        /* 对方行名：内部分户账交易.对方行名 -> T_7_10.G100017；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【对方行名 DFHAM】 */
        src.G100017 AS DFXM,
        /* 交易渠道：内部分户账交易.交易渠道 -> T_7_10.G100019；码值转化：CASE WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '01' THEN '柜面' WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '02' THEN 'ATM' WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '03' THEN 'VTM' WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道...；转换规则需人工补齐 CASE 分支 */
        src.G100019 AS JYQD,
        /* 授权柜员号：内部分户账交易.授权员工ID -> T_7_10.G100021；加工映射：【内部分户账交易 BS_JY_NBFHZJY】.【授权员工ID SQYGID】，如为“自动”则转为空，否则取原值 */
        CASE WHEN src.G100021 = '自动' THEN NULL ELSE src.G100021 END AS SQGYH,
        /* 进账日期：内部分户账交易.进账日期 -> T_7_10.G100026；加工映射：格式由YYYY-MM-DD转化成YYYYMMDD */
        CONCAT(CAST(YEAR(src.G100026) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G100026) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G100026) AS VARCHAR(2)), 2, '0')) AS JZRQ,
        /* 备注：内部分户账交易.备注 -> T_7_10.G100030；提取一表通《表7.10内部分户账交易》》备注，如有多项，以英文分隔符';'拼接 */
        src.G100030 AS BBZ,
        /* 交易序列号：内部分户账交易.交易ID -> T_7_10.G100001；直接映射：【内部分户账交易 BS_JY_NBFHZJY】.【交易ID JYID】 */
        src.G100001 AS JYXLH,
        /* 内部机构号：待确认来源字段：EAST.内部分户账.内部机构号 */
        NULL AS NBJGH,
        /* 明细科目编号：内部分户账交易.科目ID -> T_7_10.G100007；直接映射：【内部分户账交易 BS_JY_NBFHZJY】.【科目ID KMID】 */
        src.G100007 AS MXKMBH,
        /* 明细科目名称：待确认来源字段：内部科目对照表.会计科目名称 */
        NULL AS MXKMMC,
        /* 核心交易日期：内部分户账交易.核心交易日期 -> T_7_10.G100003；加工映射：格式由YYYY-MM-DD转化成YYYYMMDD */
        CONCAT(CAST(YEAR(src.G100003) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G100003) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G100003) AS VARCHAR(2)), 2, '0')) AS HXJYRQ,
        /* 核心交易时间：内部分户账交易.核心交易时间 -> T_7_10.G100004；加工映射：REPLACE(T1.HXJYSJ,':','') */
        src.G100004 AS HXJYSJ,
        /* 交易类型：内部分户账交易.交易类型 -> T_7_10.G100006；码值转化：CASE WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '01' THEN '转账' WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '02' THEN '取现' WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '03' THEN '存现' WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 J...；转换规则需人工补齐 CASE 分支 */
        src.G100006 AS JYLX,
        /* 交易金额：内部分户账交易.交易金额 -> T_7_10.G100010；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【交易金额 JYJE】 */
        CAST(NULLIF(TRIM(src.G100010), '') AS DECIMAL(20,2)) AS JYJE,
        /* 贷方余额：内部分户账交易.贷方余额 -> T_7_10.G100013；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【贷方余额 DFYE】 */
        CAST(NULLIF(TRIM(src.G100013), '') AS DECIMAL(20,2)) AS DFYE,
        /* 对方账号：内部分户账交易.对方账号 -> T_7_10.G100014；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【对方账号 DFZH】 */
        src.G100014 AS DFZH,
        /* 对方户名：内部分户账交易.对方户名 -> T_7_10.G100015；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【对方户名 DFHUM】 */
        src.G100015 AS DFHM,
        /* 采集日期：参数 P_DATA_DATE */
        P_DATA_DATE AS CJRQ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 金融许可证号：待确认来源字段：EAST.内部分户账.金融许可证号 */
        NULL AS JRXKZH,
        /* 银行机构名称：待确认来源字段：EAST.内部分户账.银行机构名称 */
        NULL AS YHJGMC,
        /* 账户名称：待确认来源字段：EAST.内部分户账.账户名称 */
        NULL AS ZHMC,
        /* 内部分户账账号：内部分户账交易.分户账号 -> T_7_10.G100002；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【分户账号 FHZH】 */
        src.G100002 AS NBFHZZH,
        /* 币种：内部分户账交易.币种 -> T_7_10.G100005；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【币种 BZ】 */
        src.G100005 AS BZ,
        /* 交易借贷标志：内部分户账交易.借贷标识 -> T_7_10.G100009；码值转化： 01 借 02 贷 03 借贷并列 其他赋值 ''；转换规则需人工补齐 CASE 分支 */
        src.G100009 AS JYJDBZ,
        /* 借方余额：内部分户账交易.借方余额 -> T_7_10.G100012；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【借方余额 JFYE】 */
        CAST(NULLIF(TRIM(src.G100012), '') AS DECIMAL(20,2)) AS JFYE,
        /* 对方科目编号：待确认来源字段：内部分户账交易.对方科目ID编号 */
        NULL AS DFKMBH,
        /* 对方科目名称：待确认来源字段：内部科目对照表.会计科目名称 */
        NULL AS DFKMMC,
        /* 对方行号：内部分户账交易.对方账号行号 -> T_7_10.G100016；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【对方行号 DFZHHH】 */
        src.G100016 AS DFXH,
        /* 摘要：内部分户账交易.摘要 -> T_7_10.G100018；直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【摘要 ZY】 */
        src.G100018 AS ZY,
        /* 冲补抹标志：内部分户账交易.冲补抹标识 -> T_7_10.G100022；码值转化： 01 正常 02 冲补抹；转换规则需人工补齐 CASE 分支 */
        src.G100022 AS CBMBZ,
        /* 现转标志：内部分户账交易.现转标识 -> T_7_10.G100025；码值转化： 01 现 02 转 ELSE ''；转换规则需人工补齐 CASE 分支 */
        src.G100025 AS XZBZ,
        /* 交易柜员号：内部分户账交易.经办员工ID -> T_7_10.G100020；加工映射：【内部分户账交易 BS_JY_NBFHZJY】.【经办员工ID JBYGID】，如为“自动”则转为空，否则取原值 */
        CASE WHEN src.G100020 = '自动' THEN NULL ELSE src.G100020 END AS JYGYH,
        /* 销账日期：内部分户账交易.销账日期 -> T_7_10.G100027；加工映射：格式由YYYY-MM-DD转化成YYYYMMDD */
        CONCAT(CAST(YEAR(src.G100027) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G100027) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G100027) AS VARCHAR(2)), 2, '0')) AS XZRQ,
        /* 对方客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS DFKHLB
    FROM T_7_10 src
    WHERE 1 = 1
      /* TODO: 按《023_内部分户账明细记录.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
