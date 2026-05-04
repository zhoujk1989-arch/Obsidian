/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《027_对公信贷分户账明细记录.md》生成 EAST5.0 对公信贷分户账明细记录（IE_004_412_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/027_对公信贷分户账明细记录.md
- 原始材料/表结构/EAST5.0系统/IE_004_412_INC-对公信贷分户账明细记录-DDL-2026-04-28.sql

源表：
- T_7_2, T_1_1

目标表：
- IE_004_412_INC：对公信贷分户账明细记录。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 所有影响对公信贷账户余额或利息变动的交易信息，包括还本、还息，不包括查询交易。贷款核销或者转让（包括资产证券化）也应该在本表体现：明细科目填报本金科目，交易金额为核销或转让前本金余额，余额填报为0，交易对手填写借款人自身信息，摘要中标明核销或者转让交易。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 584 行） 通过【信贷交易】的【分户账号】内关联已完成一表通转换的【对公信贷分户账】的【分户账号】，取【信贷交易】.【采集日期】为当月的数据

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_412_INC_DGXDFHZMX;

CREATE PROCEDURE PROC_EAST_IE_004_412_INC_DGXDFHZMX(
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

    DELETE FROM IE_004_412_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_412_INC (
        JYGYH,
        SENSITIVEFLAG,
        HXJYSJ,
        JYJDBZ,
        ZHYE,
        DFHM,
        JYLX,
        JRXKZH,
        MXKMBH,
        MXKMMC,
        CBMBZ,
        DFXM,
        DFXH,
        XDJJH,
        ZHMC,
        KHTYBH,
        YHJGMC,
        YWBLJGH,
        JYXLH,
        GSFZJG,
        DFZH,
        BBZ,
        JYJE,
        BZ,
        SQGYH,
        JYQD,
        ZY,
        HXJYRQ,
        DKFHZH,
        DFKHLB,
        CJRQ,
        NBJGH,
        XZBZ
    )
    SELECT
        /* 交易柜员号：信贷交易.经办员工ID -> T_7_2.G020022；加工映射，取【信贷交易】.【经办员工ID】，如为“自动”则转为空，否则取原值 */
        CASE WHEN src.G020022 = '自动' THEN NULL ELSE src.G020022 END AS JYGYH,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 核心交易时间：信贷交易.核心交易时间 -> T_7_2.G020008；格式转换：取【信贷交易】.【核心交易时间】，核心交易日期格式由HH:MM:SS转为：HHMMSS；转换规则需人工补齐 CASE 分支 */
        src.G020008 AS HXJYSJ,
        /* 交易借贷标志：信贷交易.借贷标识 -> T_7_2.G020015；代码转化：取【信贷交易】.【借贷标识】， 若为'01'[借],则赋值为'借'; 若为'02'[贷],则赋值为'贷'。；转换规则需人工补齐 CASE 分支 */
        src.G020015 AS JYJDBZ,
        /* 账户余额：信贷交易.账户余额 -> T_7_2.G020010；直接映射：取【信贷交易】.【账户余额】 */
        CAST(NULLIF(TRIM(src.G020010), '') AS DECIMAL(20,2)) AS ZHYE,
        /* 对方户名：信贷交易.对方户名 -> T_7_2.G020018；直接映射：取【信贷交易】.【对方户名】 */
        src.G020018 AS DFHM,
        /* 交易类型：信贷交易.信贷交易类型 -> T_7_2.G020012；代码转化：取【信贷交易】.【信贷交易类型】， 若为'01'[发放],则赋值为'贷款发放'; 若为'02'或'03'[收回],则赋值为'贷款还本'; 若为'04'[收息],则赋值为'贷款还息'; 若为'00-XX'[其他],则赋值为'其他-XX'。；转换规则需人工补齐 CASE 分支 */
        src.G020012 AS JYLX,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工规则：用【信贷交易】.【入账机构ID】关联【机构信息】.【机构ID】，取【机构信息】.【金融许可证号】 */
        s1.A010003 AS JRXKZH,
        /* 明细科目编号：信贷交易.科目ID -> T_7_2.G020013；直接映射：取【信贷交易】.【科目ID】 */
        src.G020013 AS MXKMBH,
        /* 明细科目名称：信贷交易.科目名称 -> T_7_2.G020014；直接映射：取【信贷交易】.【科目名称】 */
        src.G020014 AS MXKMMC,
        /* 冲补抹标志：信贷交易.冲补抹标识 -> T_7_2.G020021；代码转化：取【信贷交易】.【冲补抹标识】 若为'01'[正常],则赋值为'正常'; 若为'02'[冲补抹],则赋值为'冲补抹'。；转换规则需人工补齐 CASE 分支 */
        src.G020021 AS CBMBZ,
        /* 对方行名：信贷交易.对方行名 -> T_7_2.G020020；直接映射：取【信贷交易】.【对方行名】 */
        src.G020020 AS DFXM,
        /* 对方行号：信贷交易.对方账号行号 -> T_7_2.G020019；直接映射：取【信贷交易】.【对方账号行号】 */
        src.G020019 AS DFXH,
        /* 信贷借据号：信贷交易.借据ID -> T_7_2.G020006；直接映射：取【信贷交易】.【借据ID】 */
        src.G020006 AS XDJJH,
        /* 账户名称：待确认来源字段：EAST对公客户信息表.客户名称 */
        NULL AS ZHMC,
        /* 客户统一编号：信贷交易.客户ID -> T_7_2.G020004；直接映射：取【信贷交易】.【客户ID】 */
        src.G020004 AS KHTYBH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；加工规则：用【信贷交易】.【入账机构ID】关联【机构信息】.【机构ID】，取【机构信息】.【银行机构名称】 */
        s1.A010005 AS YHJGMC,
        /* 业务办理机构号：信贷交易.交易机构ID -> T_7_2.G020005；加工规则：从【信贷交易】.【交易机构ID】第12位开始截取。 */
        SUBSTR(TRIM(src.G020005), 12) AS YWBLJGH,
        /* 交易序列号：信贷交易.交易ID -> T_7_2.G020001；直接映射：取【信贷交易】.【交易ID】 */
        src.G020001 AS JYXLH,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 对方账号：信贷交易.对方账号 -> T_7_2.G020017；直接映射：取【信贷交易】.【对方账号】 */
        src.G020017 AS DFZH,
        /* 备注：信贷交易.备注 -> T_7_2.G020032；直接映射：取【信贷交易】.【备注】 */
        src.G020032 AS BBZ,
        /* 交易金额：信贷交易.交易金额 -> T_7_2.G020009；直接映射：取【信贷交易】.【交易金额】 */
        CAST(NULLIF(TRIM(src.G020009), '') AS DECIMAL(20,2)) AS JYJE,
        /* 币种：信贷交易.币种 -> T_7_2.G020011；直接映射：取【信贷交易】.【币种】 */
        src.G020011 AS BZ,
        /* 授权柜员号：信贷交易.授权员工ID -> T_7_2.G020023；加工映射，取【信贷交易】.【授权员工ID】，如为“自动”则转为空，否则取原值 */
        CASE WHEN src.G020023 = '自动' THEN NULL ELSE src.G020023 END AS SQGYH,
        /* 交易渠道：信贷交易.交易渠道 -> T_7_2.G020024；代码转化：取【信贷交易】.【交易渠道】 若为'01'[柜面],则赋值为'柜面'; 若为'02'[ATM(自动柜员机)],则赋值为'ATM'; 若为'03'[VTM（远程视频柜员机）)],则赋值为'VTM'; 若为'04'[POS（销售终端）],则赋值为'POS'; 若为'05'[网银],则赋值为'网银'; 若为'06'[手机银行],则赋值为'手机银行'; 若为'07-XX'[第三方支付],则赋值为'第三方支付-XX'; 若为'08'[银...；转换规则需人工补齐 CASE 分支 */
        src.G020024 AS JYQD,
        /* 摘要：信贷交易.摘要 -> T_7_2.G020029；直接映射：取【信贷交易】.【摘要】 */
        src.G020029 AS ZY,
        /* 核心交易日期：信贷交易.核心交易日期 -> T_7_2.G020007；格式转换：取【信贷交易】.【核心交易日期】，格式转为'YYYYMMDD',默认值99991231。 */
        CASE WHEN src.G020007 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.G020007) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G020007) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G020007) AS VARCHAR(2)), 2, '0')) END AS HXJYRQ,
        /* 贷款分户账号：信贷交易.分户账号 -> T_7_2.G020003；直接映射：取【信贷交易】.【分户账号】 */
        src.G020003 AS DKFHZH,
        /* 对方客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS DFKHLB,
        /* 采集日期：信贷交易.采集日期 -> T_7_2.G020030；格式转换：取【信贷交易】.【采集日期】，格式转为'YYYYMMDD'。 */
        CONCAT(CAST(YEAR(src.G020030) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G020030) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G020030) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 内部机构号：信贷交易.入账机构ID -> T_7_2.G020031；加工规则：从【信贷交易】.【入账机构ID】第12位开始截取。 */
        SUBSTR(TRIM(src.G020031), 12) AS NBJGH,
        /* 现转标志：信贷交易.现转标识 -> T_7_2.G020028；代码转化：取【信贷交易】.【现转标识】 若为'01'[现],则赋值为'现'; 若为'02'[转],则赋值为'转'。；转换规则需人工补齐 CASE 分支 */
        src.G020028 AS XZBZ
    FROM T_7_2 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《027_对公信贷分户账明细记录.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
