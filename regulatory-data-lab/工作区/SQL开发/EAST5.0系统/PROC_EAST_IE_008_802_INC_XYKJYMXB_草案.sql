/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《050_信用卡交易明细表.md》生成 EAST5.0 信用卡交易明细表（IE_008_802_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/050_信用卡交易明细表.md
- 原始材料/表结构/EAST5.0系统/IE_008_802_INC-信用卡交易明细表-DDL-2026-04-28.sql

源表：
- T_7_4, T_6_9, T_1_1

目标表：
- IE_008_802_INC：信用卡交易明细表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 影响信用卡余额变动的交易明细，不包括查询交易，以信用账号、卡号中取较小粒度报送。已核销卡的交易明细不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1182 行） 直接映射

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_008_802_INC_XYKJYMXB;

CREATE PROCEDURE PROC_EAST_IE_008_802_INC_XYKJYMXB(
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

    DELETE FROM IE_008_802_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_008_802_INC (
        DFXH,
        SHMC,
        XSXXJYBZ,
        SXFJE,
        JYZDRQ,
        ZJLB,
        KPJYLX,
        SENSITIVEFLAG,
        HXJYRQ,
        BZ,
        JRXKZH,
        MXKMMC,
        JYXLH,
        YHJGMC,
        KHTYBH,
        KHMC,
        ZJHM,
        XYKZH,
        KH,
        JYJDBZ,
        HXJYSJ,
        ZHYE,
        DFZH,
        DFHM,
        DFXM,
        SHBH,
        ZY,
        SXFBZ,
        ZCHKRQ,
        IPDZ,
        MACDZ,
        CJRQ,
        DFKHLB,
        TQJQBZ,
        JYQD,
        BBZ,
        NBJGH,
        GSFZJG,
        MXKMBH,
        KHLB,
        JYJE,
        FQFKBZ
    )
    SELECT
        /* 对方行号：信用卡交易.对方账号行号 -> T_7_4.G040019；直接映射 */
        src.G040019 AS DFXH,
        /* 商户名称：信用卡交易.商户名称 -> T_7_4.G040023；直接映射 */
        src.G040023 AS SHMC,
        /* 线上线下交易标志：信用卡交易.线上线下交易标识 -> T_7_4.G040024；加工映射：'01'转为'线上'，'02'转为'线下' */
        src.G040024 AS XSXXJYBZ,
        /* 手续费金额：信用卡交易.手续费金额 -> T_7_4.G040014；直接映射 */
        CAST(NULLIF(TRIM(src.G040014), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 交易账单日期：信用卡交易.交易账单日期 -> T_7_4.G040036；直接映射 */
        src.G040036 AS JYZDRQ,
        /* 证件类别：待确认来源字段：一表通转出的EAST对公客户信息表\.个人基础信息表 */
        NULL AS ZJLB,
        /* 卡片交易类型：信用卡交易.交易类型 -> T_7_4.G040009；加工映射：'01'转成'消费交易'，'02'转成'现金交易'，'03'转成'还款交易，'04'转成'转账交易'，'00-XX'转成'其他-XX' */
        src.G040009 AS KPJYLX,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 核心交易日期：信用卡交易.核心交易日期 -> T_7_4.G040007；加工映射：数据格式转成yyyymmdd */
        CONCAT(CAST(YEAR(src.G040007) AS VARCHAR(4)), LPAD(CAST(MONTH(src.G040007) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.G040007) AS VARCHAR(2)), 2, '0')) AS HXJYRQ,
        /* 币种：信用卡交易.币种 -> T_7_4.G040015；直接映射 */
        src.G040015 AS BZ,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工映射：用【信用卡交易】.【卡号】关联【信用卡协议】.【卡号】取【信用卡协议】.【机构id】，从第12位开始截取【信用卡协议】的【机构id】，关联【机构信息】的【内部机构号】取【金融许可证号】 */
        SUBSTR(TRIM(s2.A010003), 12) AS JRXKZH,
        /* 明细科目名称：信用卡交易.科目名称 -> T_7_4.G040013；直接映射 */
        src.G040013 AS MXKMMC,
        /* 交易序列号：信用卡交易.交易ID -> T_7_4.G040001；直接映射 */
        src.G040001 AS JYXLH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；加工映射：用【信用卡交易】.【卡号】关联【信用卡协议】.【卡号】取【信用卡协议】.【机构id】，从第12位开始截取【信用卡协议】的【机构id】，关联【机构信息】的【内部机构号】取【银行机构名称】 */
        SUBSTR(TRIM(s2.A010005), 12) AS YHJGMC,
        /* 客户统一编号：信用卡交易.客户ID -> T_7_4.G040004；直接映射 */
        src.G040004 AS KHTYBH,
        /* 客户名称：待确认来源字段：一表通转出的EAST对公客户信息表\.个人基础信息表 */
        NULL AS KHMC,
        /* 证件号码：待确认来源字段：一表通转出的EAST对公客户信息表\.个人基础信息表 */
        NULL AS ZJHM,
        /* 信用卡账号：信用卡交易.分户账号 -> T_7_4.G040003；直接映射 */
        src.G040003 AS XYKZH,
        /* 卡号：信用卡交易.卡号 -> T_7_4.G040002；直接映射 */
        src.G040002 AS KH,
        /* 交易借贷标志：信用卡交易.借贷标识 -> T_7_4.G040021；加工映射：'01'转为'借'，'02'转为'贷' */
        src.G040021 AS JYJDBZ,
        /* 核心交易时间：信用卡交易.核心交易时间 -> T_7_4.G040008；加工映射：删除":"，将数据格式转成HHMMSS */
        src.G040008 AS HXJYSJ,
        /* 账户余额：信用卡交易.账户余额 -> T_7_4.G040011；直接映射 */
        CAST(NULLIF(TRIM(src.G040011), '') AS DECIMAL(20,2)) AS ZHYE,
        /* 对方账号：信用卡交易.对方账号 -> T_7_4.G040017；直接映射 */
        src.G040017 AS DFZH,
        /* 对方户名：信用卡交易.对方户名 -> T_7_4.G040018；直接映射 */
        src.G040018 AS DFHM,
        /* 对方行名：信用卡交易.对方行名 -> T_7_4.G040020；直接映射 */
        src.G040020 AS DFXM,
        /* 商户编号：信用卡交易.商户编号 -> T_7_4.G040022；直接映射 */
        src.G040022 AS SHBH,
        /* 摘要：信用卡交易.交易摘要 -> T_7_4.G040031；直接映射 */
        src.G040031 AS ZY,
        /* 手续费币种：信用卡交易.手续费币种 -> T_7_4.G040016；直接映射 */
        src.G040016 AS SXFBZ,
        /* 最迟还款日期：信用卡交易.最迟还款日期 -> T_7_4.G040037；直接映射 */
        src.G040037 AS ZCHKRQ,
        /* IP地址：信用卡交易.IP地址 -> T_7_4.G040026；直接映射 */
        src.G040026 AS IPDZ,
        /* MAC地址：信用卡交易.MAC地址 -> T_7_4.G040027；直接映射 */
        src.G040027 AS MACDZ,
        /* 采集日期：待确认来源字段：/./ */
        NULL AS CJRQ,
        /* 对方客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS DFKHLB,
        /* 提前结清标志：信用卡交易.提前结清标志 -> T_7_4.G040034；加工映射：'1'转为'是'，'0'转为'否' */
        src.G040034 AS TQJQBZ,
        /* 交易渠道：信用卡交易.交易渠道 -> T_7_4.G040030；加工映射：'01' 转为 '柜面'，'02' 转为 'ATM'，'03' 转为 'VTM'，'04' 转为 'POS'，'05' 转为 '网银'，'06' 转为 '手机银行'，'07-XX' 转为 '第三方支付-XX'，'08' 转为 '银联交易'，'00-XX' 转为 '其他-XX' */
        src.G040030 AS JYQD,
        /* 备注：信用卡交易.备注 -> T_7_4.G040035；直接映射 */
        src.G040035 AS BBZ,
        /* 内部机构号：待确认来源字段：信用卡协议.机构id */
        NULL AS NBJGH,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 明细科目编号：信用卡交易.科目ID -> T_7_4.G040012；直接映射 */
        src.G040012 AS MXKMBH,
        /* 客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS KHLB,
        /* 交易金额：信用卡交易.交易金额 -> T_7_4.G040010；直接映射 */
        CAST(NULLIF(TRIM(src.G040010), '') AS DECIMAL(20,2)) AS JYJE,
        /* 分期付款标志：信用卡交易.分期业务ID -> T_7_4.G040025；加工映射：【分期业务ID】非空转为'是'，其他转为‘否’ */
        src.G040025 AS FQFKBZ
    FROM T_7_4 src
    LEFT JOIN T_6_9 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_1_1 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《050_信用卡交易明细表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
