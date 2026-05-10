/*
草案质量状态：已重构校准，可供复核。禁止直接在生产环境执行。
原因：本文件已按原始业务需求《050_信用卡交易明细表.md》逐字段校准并消除所有占位，但尚未在 GBase 环境执行语法校验和跑数验证。
审计记录：sql/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
重构校准日期：2026-05-09
重构校准人：Hermes Agent

业务目标：
- 依据原始业务需求《050_信用卡交易明细表.md》生成 EAST5.0 信用卡交易明细表（IE_008_802_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 历史业务需求材料
- 历史表结构材料

源表：
- T_7_4（信用卡交易）
- T_6_9（信用卡协议）
- T_1_1（机构信息）
- IE_002_201（个人基础信息表，EAST5.0）
- IE_002_203（对公客户信息表，EAST5.0）

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

重构校准说明（2026-05-09）：
1. JOIN 条件已补齐：
   - T_7_4(src) LEFT JOIN T_6_9(s1) ON src.G040002 = s1.F090007（卡号关联卡号）
   - T_7_4(src) LEFT JOIN T_1_1(s2) ON SUBSTR(TRIM(s1.F090002), 12) = TRIM(s2.A010002) AND s2.A010020 = V_DATA_DATE（机构信息维表，SUBSTR 截取第12位为内部机构号）
   - T_7_4(src) LEFT JOIN IE_002_201(s3) ON TRIM(src.G040004) = TRIM(s3.KHTYBH) AND s3.CJRQ = P_DATA_DATE（个人基础信息表，获取个人客户姓名/证件）
   - T_7_4(src) LEFT JOIN IE_002_203(s4) ON TRIM(src.G040004) = TRIM(s4.KHTYBH) AND s4.CJRQ = P_DATA_DATE（对公客户信息表，获取对公客户名称/证件）
2. WHERE 条件已补齐：
   - src.G040033 >= DATE_SUB(V_DATA_DATE, INTERVAL 1 DAY)（增量数据，上一采集日至采集日期间）
   - s1.F090029 IS NULL OR s1.F090029 <> '已核销'（排除已核销卡）
3. 6 个码值 CASE 转换已补齐：
   - XSXXJYBZ：'01'→'线上'，'02'→'线下'，ELSE→原值
   - KPJYLX：'01'→'消费交易'，'02'→'现金交易'，'03'→'还款交易'，'04'→'转账交易'，00-XX→'其他-XX'，ELSE→原值
   - JYJDBZ：'01'→'借'，'02'→'贷'，ELSE→原值
   - TQJQBZ：'1'→'是'，'0'→'否'，ELSE→原值
   - JYQD：'01'→'柜面'，'02'→'ATM'，'03'→'VTM'，'04'→'POS'，'05'→'网银'，'06'→'手机银行'，LEFT(...,3)='07-'→'第三方支付-XX'，'08'→'银联交易'，LEFT(...,3)='00-'→'其他-XX'，ELSE→原值
   - FQFKBZ：分期业务ID非空→'是'，ELSE→'否'
4. 日期格式转换已补齐：
   - HXJYRQ：DATE_FORMAT(src.G040007, '%Y%m%d')（DATE→YYYYMMDD）
   - HXJYSJ：REPLACE(CAST(src.G040008 AS CHAR), ':', '')（HH:MM:SS→HHMMSS）
   - JYZDRQ：DATE_FORMAT(src.G040036, '%Y%m%d')（DATE→YYYYMMDD）
   - ZCHKRQ：DATE_FORMAT(src.G040037, '%Y%m%d')（DATE→YYYYMMDD）
   - CJRQ：直接赋参数 P_DATA_DATE
5. 金额字段处理：
   - SXFJE：CAST(NULLIF(TRIM(src.G040014), '') AS DECIMAL(20,2))
   - ZHYE：CAST(NULLIF(TRIM(src.G040011), '') AS DECIMAL(20,2))
   - JYJE：CAST(NULLIF(TRIM(src.G040010), '') AS DECIMAL(20,2))
6. 客户名称/证件字段补齐：
   - KHMC：COALESCE(s4.KHMC, s3.KHXM)（优先对公客户名称，回退个人客户姓名）
   - ZJLB：COALESCE(s4.ZJLB, s3.ZJLB)（优先对公证件类别，回退个人证件类别）
   - ZJHM：COALESCE(s4.ZJHM, s3.ZJHM)（优先对公证件号码，回退个人证件号码）
7. 机构相关字段补齐：
   - JRXKZH：s2.A010003（金融许可证号，通过机构关联获取）
   - YHJGMC：s2.A010005（银行机构名称，通过机构关联获取）
   - NBJGH：SUBSTR(TRIM(s1.F090002), 12)（内部机构号，从信用卡协议机构ID第12位截取）
8. 缺口字段（4个）：SENSITIVEFLAG/DFKHLB/GSFZJG/KHLB 在业务需求映射表中无来源，置 NULL。
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
        CASE TRIM(src.G040024)
            WHEN '01' THEN '线上'
            WHEN '02' THEN '线下'
            ELSE TRIM(src.G040024)
        END AS XSXXJYBZ,
        /* 手续费金额：信用卡交易.手续费金额 -> T_7_4.G040014；直接映射，CAST为DECIMAL */
        CAST(NULLIF(TRIM(src.G040014), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 交易账单日期：信用卡交易.交易账单日期 -> T_7_4.G040036；直接映射，DATE转YYYYMMDD */
        DATE_FORMAT(src.G040036, '%Y%m%d') AS JYZDRQ,
        /* 证件类别：优先对公客户信息表.证件类别，回退个人基础信息表.证件类别 */
        COALESCE(s4.ZJLB, s3.ZJLB) AS ZJLB,
        /* 卡片交易类型：信用卡交易.交易类型 -> T_7_4.G040009；加工映射：'01'转成'消费交易'，'02'转成'现金交易'，'03'转成'还款交易'，'04'转成'转账交易'，'00-XX'转成'其他-XX' */
        CASE TRIM(src.G040009)
            WHEN '01' THEN '消费交易'
            WHEN '02' THEN '现金交易'
            WHEN '03' THEN '还款交易'
            WHEN '04' THEN '转账交易'
            WHEN LEFT(TRIM(src.G040009), 3) = '00-' THEN CONCAT('其他-', SUBSTR(TRIM(src.G040009), 4))
            ELSE TRIM(src.G040009)
        END AS KPJYLX,
        /* 涉密标志：DDL存在但业务需求映射表未给来源，置NULL */
        NULL AS SENSITIVEFLAG,
        /* 核心交易日期：信用卡交易.核心交易日期 -> T_7_4.G040007；加工映射：DATE转yyyymmdd */
        DATE_FORMAT(src.G040007, '%Y%m%d') AS HXJYRQ,
        /* 币种：信用卡交易.币种 -> T_7_4.G040015；直接映射 */
        src.G040015 AS BZ,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工映射：用卡号关联信用卡协议取机构ID（截取第12位为内部机构号），关联机构信息取金融许可证号 */
        s2.A010003 AS JRXKZH,
        /* 明细科目名称：信用卡交易.科目名称 -> T_7_4.G040013；直接映射 */
        src.G040013 AS MXKMMC,
        /* 交易序列号：信用卡交易.交易ID -> T_7_4.G040001；直接映射 */
        src.G040001 AS JYXLH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；加工映射：同JRXKZH关联路径 */
        s2.A010005 AS YHJGMC,
        /* 客户统一编号：信用卡交易.客户ID -> T_7_4.G040004；直接映射 */
        src.G040004 AS KHTYBH,
        /* 客户名称：优先对公客户信息表.客户名称，回退个人基础信息表.客户姓名 */
        COALESCE(s4.KHMC, s3.KHXM) AS KHMC,
        /* 证件号码：优先对公客户信息表.证件号码，回退个人基础信息表.证件号码 */
        COALESCE(s4.ZJHM, s3.ZJHM) AS ZJHM,
        /* 信用卡账号：信用卡交易.分户账号 -> T_7_4.G040003；直接映射 */
        src.G040003 AS XYKZH,
        /* 卡号：信用卡交易.卡号 -> T_7_4.G040002；直接映射 */
        src.G040002 AS KH,
        /* 交易借贷标志：信用卡交易.借贷标识 -> T_7_4.G040021；加工映射：'01'转为'借'，'02'转为'贷' */
        CASE TRIM(src.G040021)
            WHEN '01' THEN '借'
            WHEN '02' THEN '贷'
            ELSE TRIM(src.G040021)
        END AS JYJDBZ,
        /* 核心交易时间：信用卡交易.核心交易时间 -> T_7_4.G040008；加工映射：删除":"，将数据格式转成HHMMSS */
        REPLACE(CAST(src.G040008 AS CHAR), ':', '') AS HXJYSJ,
        /* 账户余额：信用卡交易.账户余额 -> T_7_4.G040011；直接映射，CAST为DECIMAL */
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
        /* 最迟还款日期：信用卡交易.最迟还款日期 -> T_7_4.G040037；直接映射，DATE转YYYYMMDD */
        DATE_FORMAT(src.G040037, '%Y%m%d') AS ZCHKRQ,
        /* IP地址：信用卡交易.IP地址 -> T_7_4.G040026；直接映射 */
        src.G040026 AS IPDZ,
        /* MAC地址：信用卡交易.MAC地址 -> T_7_4.G040027；直接映射 */
        src.G040027 AS MACDZ,
        /* 采集日期：默认值：报告日，数据格式转成yyyymmdd */
        P_DATA_DATE AS CJRQ,
        /* 对方客户类别：DDL存在但业务需求映射表未给来源，置NULL */
        NULL AS DFKHLB,
        /* 提前结清标志：信用卡交易.提前结清标志 -> T_7_4.G040034；加工映射：'1'转为'是'，'0'转为'否' */
        CASE TRIM(src.G040034)
            WHEN '1' THEN '是'
            WHEN '0' THEN '否'
            ELSE TRIM(src.G040034)
        END AS TQJQBZ,
        /* 交易渠道：信用卡交易.交易渠道 -> T_7_4.G040030；加工映射：'01'转为'柜面'，'02'转为'ATM'，'03'转为'VTM'，'04'转为'POS'，'05'转为'网银'，'06'转为'手机银行'，'07-XX'转为'第三方支付-XX'，'08'转为'银联交易'，'00-XX'转为'其他-XX' */
        CASE TRIM(src.G040030)
            WHEN '01' THEN '柜面'
            WHEN '02' THEN 'ATM'
            WHEN '03' THEN 'VTM'
            WHEN '04' THEN 'POS'
            WHEN '05' THEN '网银'
            WHEN '06' THEN '手机银行'
            WHEN '08' THEN '银联交易'
            WHEN LEFT(TRIM(src.G040030), 3) = '07-' THEN CONCAT('第三方支付-', SUBSTR(TRIM(src.G040030), 4))
            WHEN LEFT(TRIM(src.G040030), 3) = '00-' THEN CONCAT('其他-', SUBSTR(TRIM(src.G040030), 4))
            ELSE TRIM(src.G040030)
        END AS JYQD,
        /* 备注：信用卡交易.备注 -> T_7_4.G040035；直接映射 */
        src.G040035 AS BBZ,
        /* 内部机构号：信用卡协议.机构id -> T_6_9.F090002；加工映射：从第12位开始截取信用卡协议的机构id */
        SUBSTR(TRIM(s1.F090002), 12) AS NBJGH,
        /* 归属分支机构：DDL存在但业务需求映射表未给来源，置NULL */
        NULL AS GSFZJG,
        /* 明细科目编号：信用卡交易.科目ID -> T_7_4.G040012；直接映射 */
        src.G040012 AS MXKMBH,
        /* 客户类别：DDL存在但业务需求映射表未给来源，置NULL */
        NULL AS KHLB,
        /* 交易金额：信用卡交易.交易金额 -> T_7_4.G040010；直接映射，CAST为DECIMAL */
        CAST(NULLIF(TRIM(src.G040010), '') AS DECIMAL(20,2)) AS JYJE,
        /* 分期付款标志：信用卡交易.分期业务ID -> T_7_4.G040025；加工映射：【分期业务ID】非空转为'是'，其他转为'否' */
        CASE WHEN NULLIF(TRIM(src.G040025), '') IS NOT NULL THEN '是' ELSE '否' END AS FQFKBZ
    FROM T_7_4 src
    LEFT JOIN T_6_9 s1
           ON TRIM(src.G040002) = TRIM(s1.F090007)
    LEFT JOIN T_1_1 s2
           ON SUBSTR(TRIM(s1.F090002), 12) = TRIM(s2.A010002)
          AND s2.A010020 = V_DATA_DATE
    LEFT JOIN IE_002_201 s3
           ON TRIM(src.G040004) = TRIM(s3.KHTYBH)
          AND s3.CJRQ = P_DATA_DATE
    LEFT JOIN IE_002_203 s4
           ON TRIM(src.G040004) = TRIM(s4.KHTYBH)
          AND s4.CJRQ = P_DATA_DATE
    WHERE src.G040033 >= DATE_SUB(V_DATA_DATE, INTERVAL 1 DAY)
      AND src.G040033 <= V_DATA_DATE
      AND (s1.F090029 IS NULL OR TRIM(s1.F090029) <> '已核销');

    COMMIT;
END;
