/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《021_对公存款分户账明细记录.md》生成 EAST5.0 对公存款分户账明细记录（IE_004_406_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/021_对公存款分户账明细记录.md
- 原始材料/表结构/EAST5.0系统/IE_004_406_INC-对公存款分户账明细记录-DDL-2026-04-28.sql

源表：
- T_7_1

目标表：
- IE_004_406_INC：对公存款分户账明细记录。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 除计息、扣利息税外，所有影响对公存款账户余额变动的交易信息，包括结息交易，不包括查询交易。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 415 行） 主表：【客户存款账户交易表】 内关联1：【EAST.对公存款分户账】 关联条件1：【客户存款账户交易表】【分户账号】=【EAST.对公存款分户账】【分户账号】 AND 【客户存款账户交易表】【币种】=【分户账号】【币种】 AND CASE WHEN 【客户存款账户交易表】【币种】 = 'CNY' THEN '人民币' WHEN 【客户存款账户交易表】【钞汇类别】 = '01' THEN '钞' WHEN 【客户存款账户交易表】【钞汇类别】 = '02' THEN '汇' WHEN 【客户存款账户交易表】【钞汇类别】 = '03' THEN '可钞可汇' =【个人存款分户账】【钞汇类别】 左关联：【EAST.机构信息表】 关联条件：【客户存款账户交易表】【内部机构号】关联【EAST.机构信息表】【内部机构号】 左关联：【EAST.内部科目对照表】 关联条件：【客户存款账户交易表】【科目ID】，关联【EAST.内部科目对照表】的【会计科目编号】 左关联：【EAST.对公存款分户账】 关联条件：【客户存款账户交易表】【客户ID】，关联【EAST.对公存款分户账】的【统一客户编号】

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_406_INC_DGCKFHZMX;

CREATE PROCEDURE PROC_EAST_IE_004_406_INC_DGCKFHZMX(
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

    DELETE FROM IE_004_406_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_406_INC (
        SENSITIVEFLAG,
        GSFZJG,
        DGCKZH,
        JYLX,
        HXJYRQ,
        BZ,
        ZHYE,
        DFHM,
        DFXH,
        CBMBZ,
        XZBZ,
        IPDZ,
        SQGYH,
        CJRQ,
        JRXKZH,
        YHJGMC,
        JYXLH,
        NBJGH,
        YWBLJGH,
        MXKMBH,
        MXKMMC,
        KHTYBH,
        WBZH,
        JYJDBZ,
        HXJYSJ,
        JYJE,
        DFZH,
        DFXM,
        ZY,
        FY,
        JYQD,
        JYGYH,
        BBZ,
        MACDZ,
        DFKHLB,
        ZHMC
    )
    SELECT
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 对公存款账号：客户存款账户交易.分户账号 -> T_7_1.G010002；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【分户账号 FHZH】 */
        src.G010002 AS DGCKZH,
        /* 交易类型：客户存款账户交易.账户交易类型 -> T_7_1.G010010；码值转化：CASE WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '01' THEN '转账' WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '02' THEN '取现' WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '03' THEN '存现' WHEN 【客户存款账户交易表 BS_JY...；转换规则需人工补齐 CASE 分支 */
        src.G010010 AS JYLX,
        /* 核心交易日期：客户存款账户交易.核心交易日期 -> T_7_1.G010005；加工映射：格式由YYYY-MM-DD转化成YYYYMMDD */
        CONCAT(CAST(YEAR(src.G010005) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G010005) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G010005) AS VARCHAR(2)), 2, '0')) AS HXJYRQ,
        /* 币种：客户存款账户交易.币种 -> T_7_1.G010009；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【币种 BZ】 */
        src.G010009 AS BZ,
        /* 账户余额：客户存款账户交易.账户余额 -> T_7_1.G010008；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【账户余额 ZHYE】 */
        CAST(NULLIF(TRIM(src.G010008), '') AS DECIMAL(20,2)) AS ZHYE,
        /* 对方户名：客户存款账户交易.对方户名 -> T_7_1.G010016；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【对方户名 HFHUM】 */
        src.G010016 AS DFHM,
        /* 对方行号：客户存款账户交易.对方账号行号 -> T_7_1.G010017；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【对方账号行号 DFZHHH】 */
        src.G010017 AS DFXH,
        /* 冲补抹标志：客户存款账户交易.冲补抹标识 -> T_7_1.G010020；码值转化：当【客户存款账户交易表】.【冲补抹标识】='01'时，赋值'正常' 当【客户存款账户交易表】.【冲补抹标识】='02'时，赋值'冲补抹' ELSE ''；转换规则需人工补齐 CASE 分支 */
        src.G010020 AS CBMBZ,
        /* 现转标志：客户存款账户交易.现转标识 -> T_7_1.G010013；码值转化：当【客户存款账户交易表】.【现转标识】='01'时，赋值'现' 当【客户存款账户交易表】.【现转标识】='02'时，赋值'转' ELSE ''；转换规则需人工补齐 CASE 分支 */
        src.G010013 AS XZBZ,
        /* IP地址：客户存款账户交易.IP地址 -> T_7_1.G010023；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【IP地址 IPDZ】 */
        src.G010023 AS IPDZ,
        /* 授权柜员号：客户存款账户交易.授权员工ID -> T_7_1.G010030；加工映射：【客户存款账户交易表 BS_JY_KHZZJY】.【授权员工ID SQYGID】，如为“自动”则转为空，否则取原值 */
        CASE WHEN src.G010030 = '自动' THEN NULL ELSE src.G010030 END AS SQGYH,
        /* 采集日期：参数 P_DATA_DATE */
        P_DATA_DATE AS CJRQ,
        /* 金融许可证号：待确认来源字段：EAST.机构信息表.金融许可证号 */
        NULL AS JRXKZH,
        /* 银行机构名称：待确认来源字段：EAST.机构信息表.银行机构名称 */
        NULL AS YHJGMC,
        /* 交易序列号：客户存款账户交易.交易ID -> T_7_1.G010001；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【交易ID JYID】 */
        src.G010001 AS JYXLH,
        /* 内部机构号：客户存款账户交易.入账机构ID -> T_7_1.G010035；加工映射：SUBSTR(【客户存款账户交易 BS_JY_KHZZJY】.【入账机构ID JYJGID】,12) */
        src.G010035 AS NBJGH,
        /* 业务办理机构号：客户存款账户交易.交易机构ID -> T_7_1.G010004；加工映射：SUBSTR(【客户存款账户交易表 BS_JY_KHZZJY】.【交易机构ID JYJGID】,12) */
        src.G010004 AS YWBLJGH,
        /* 明细科目编号：客户存款账户交易.科目ID -> T_7_1.G010011；加工映射：COALESCE(【客户存款账户交易表 BS_JY_KHZZJY】.【科目ID KMID】,【对公存款分户账 T_EAST_YBT_DGCKFHZ】.【明细科目编号 MXKMBH】) */
        src.G010011 AS MXKMBH,
        /* 明细科目名称：待确认来源字段：EAST.内部科目对照表.会计科目名称 */
        NULL AS MXKMMC,
        /* 客户统一编号：客户存款账户交易.客户ID -> T_7_1.G010003；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【客户ID KHID】 */
        src.G010003 AS KHTYBH,
        /* 外部账号：客户存款账户交易.外部账号（交易介质号） -> T_7_1.G010025；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【外部账号 WBZH】 */
        src.G010025 AS WBZH,
        /* 交易借贷标志：客户存款账户交易.借贷标识 -> T_7_1.G010014；码值转换：01 借 02 贷；转换规则需人工补齐 CASE 分支 */
        src.G010014 AS JYJDBZ,
        /* 核心交易时间：客户存款账户交易.核心交易时间 -> T_7_1.G010006；加工映射：REPLACE(【客户存款账户交易表 BS_JY_KHZZJY】.【核心交易时间 HXJYSJ,】,':','') */
        src.G010006 AS HXJYSJ,
        /* 交易金额：客户存款账户交易.交易金额 -> T_7_1.G010007；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【交易金额 JYJE】 */
        CAST(NULLIF(TRIM(src.G010007), '') AS DECIMAL(20,2)) AS JYJE,
        /* 对方账号：客户存款账户交易.对方账号 -> T_7_1.G010015；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【对方账号 DFZH】 */
        src.G010015 AS DFZH,
        /* 对方行名：客户存款账户交易.对方行名 -> T_7_1.G010018；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【对方行名 DFHM】 */
        src.G010018 AS DFXM,
        /* 摘要：客户存款账户交易.交易摘要 -> T_7_1.G010019；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【交易摘要 JYZY】 */
        src.G010019 AS ZY,
        /* 附言：客户存款账户交易.附言 -> T_7_1.G010031；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【附言】 */
        src.G010031 AS FY,
        /* 交易渠道：客户存款账户交易.交易渠道 -> T_7_1.G010021；码值转化：CASE WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '01' THEN '柜面' WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '02' THEN 'ATM' WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '03' THEN 'VTM' WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【...；转换规则需人工补齐 CASE 分支 */
        src.G010021 AS JYQD,
        /* 交易柜员号：客户存款账户交易.经办员工ID -> T_7_1.G010029；加工映射：如果【客户存款账户交易表 BS_JY_KHZZJY】.【经办员工ID JBYGID】为'自动'，则为''，否则为【客户存款账户交易表 BS_JY_KHZZJY】.【经办员工ID JBYGID】 */
        src.G010029 AS JYGYH,
        /* 备注：客户存款账户交易.备注 -> T_7_1.G010034；提取一表通《表7.1客户存款账户交易》备注，如有多项，以英文分隔符';'拼接 */
        src.G010034 AS BBZ,
        /* MAC地址：客户存款账户交易.MAC地址 -> T_7_1.G010024；直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【MAC地址 MACDZ】 */
        src.G010024 AS MACDZ,
        /* 对方客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS DFKHLB,
        /* 账户名称：待确认来源字段：EAST.对公存款分户账.账户名称 */
        NULL AS ZHMC
    FROM T_7_1 src
    WHERE 1 = 1
      /* TODO: 按《021_对公存款分户账明细记录.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
