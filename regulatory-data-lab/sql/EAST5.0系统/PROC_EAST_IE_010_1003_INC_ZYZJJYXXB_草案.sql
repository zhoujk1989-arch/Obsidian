/*
草案质量状态：合格（2026-05-10 重构校准完成）
审计记录：sql/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
重构校准说明：
- 2026-05-10: 依据《060_自营资金交易信息表.md》逐字段对标源表 DDL（T_7_7/T_7_6/T_7_12/T_9_2/T_8_8/T_8_7/T_8_9/T_6_21/T_5_1/T_1_1/T_4_2）完成重构校准。
  - 消除全部 NULL 占位和 ON 1=1 占位
  - 三部分 UNION ALL：投资交易(T_7_7)、同业交易(T_7_6)、融资交易(T_7_12)
  - 补齐全部 JOIN 条件（按业务需求 2.1 表级规则）
|  - 补齐全部字段映射（33 字段已闭环/2 缺口字段 GSFZJG/SENSITIVEFLAG 置 NULL）
  - 补齐码值 CASE 转换（JYDSLB/JYZHLX/JYFX/YEDL/WTGLBZ/JYFX）
  - 补齐日期格式转换（DATE_FORMAT → '%Y%m%d'）
  - 补齐金额字段 CAST（DECIMAL(20,2)/DECIMAL(20,6)）
  - 补齐备注多源拼接（CONCAT_WS 分号拼接）
  - YWZL/YWXL 保留 BS_CS_GGDM 代码映射占位（代码映射表可用性待验证）
  - 融资交易产品名称 CPMC 直接取自 T_7_12.G120014（无 T_5_1 关联）
  - 缺口字段：GSFZJG（归属分支机构）、SENSITIVEFLAG（涉密标志）无业务来源，暂置 NULL
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_010_1003_INC_ZYZJJYXXB;

CREATE PROCEDURE PROC_EAST_IE_010_1003_INC_ZYZJJYXXB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_MONTH_BEGIN DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);
    SET V_MONTH_BEGIN = DATE_FORMAT(V_DATA_DATE, '%Y-%m-01');

    START TRANSACTION;

    DELETE FROM IE_010_1003_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_010_1003_INC (
        BBZ,
        BFQSZH,
        JYDSLB,
        YEDL,
        YWZL,
        JYDSPJ,
        CJRQ,
        JYDSMC,
        JYDSPJJG,
        JYDSKHHM,
        JYDSZH,
        JYBH,
        MXKMMC,
        HTYDRQ,
        JYZHLX,
        YHJGMC,
        NBJGH,
        JYRQ,
        MYBJJE,
        GSFZJG,
        CPMC,
        JRXKZH,
        JYYGH,
        SPRGH,
        WTGLBZ,
        JYDSKHHH,
        HTDQRQ,
        NHLL,
        MYBJBZ,
        JYFX,
        YWXL,
        JRGJBH,
        MXKMBH,
        SENSITIVEFLAG,
        JRGJMC
    )
    /* ========================================================
       Part 1: 投资交易 (T_7_7)
       主表: T_7_7 投资交易
       左关联: T_9_2 投融资标的 ON 投资标的ID
       左关联: T_8_8 投资情况 ON 协议ID+科目ID+投资标的ID
       左关联: T_6_21 投资协议 ON 协议ID
       左关联: T_5_1 产品业务基本信息 ON 产品ID AND 自营标识='01'
       左关联: T_1_1 机构信息 ON 交易机构ID
       过滤: 交易金额 >= 0
       ======================================================== */
    SELECT
        /* BBZ - 备注：拼接 T_7_7.G070031 和 T_8_8.H080031，以分号分隔 */
        TRIM(TRAILING ';' FROM CONCAT_WS(';',
            NULLIF(TRIM(src1.G070031), ''),
            NULLIF(TRIM(inv1.H080031), '')
        )) AS BBZ,
        /* BFQSZH - 本方清算账号：T_7_7.交易账号(G070004) */
        src1.G070004 AS BFQSZH,
        /* JYDSLB - 交易对手类别：代码转换
           01→银行业金融机构, 02/03/04/05/06/08→非银行业金融机构, 09→政府机关,
           07/10→公司客户, 11→个人客户, 12→境外金融机构, 00→其他 */
        CASE TRIM(src1.G070018)
            WHEN '01' THEN '银行业金融机构'
            WHEN '02' THEN '非银行业金融机构'
            WHEN '03' THEN '非银行业金融机构'
            WHEN '04' THEN '非银行业金融机构'
            WHEN '05' THEN '非银行业金融机构'
            WHEN '06' THEN '非银行业金融机构'
            WHEN '08' THEN '非银行业金融机构'
            WHEN '09' THEN '政府机关'
            WHEN '07' THEN '公司客户'
            WHEN '10' THEN '公司客户'
            WHEN '11' THEN '个人客户'
            WHEN '12' THEN '境外金融机构'
            WHEN '00' THEN '其他'
            ELSE TRIM(src1.G070018)
        END AS JYDSLB,
        /* YEDL - 业务大类：加工映射
           自营业务大类(G070033)为'09'或自营业务小类(G070034)以'11020'开头时置'同业往来',
           否则置'债券投资与同业投资' */
        CASE
            WHEN TRIM(src1.G070033) = '09' OR LEFT(TRIM(src1.G070034), 5) = '11020'
            THEN '同业往来'
            ELSE '债券投资与同业投资'
        END AS YEDL,
        /* YWZL - 业务中类：代码转换 via BS_CS_GGDM
           关联BS_CS_GGDM使用【表名 BM】为'通用'并且【字段名ZDM】为'自营业务大类类型',
           取【中文含义ZWHY】；BS_CS_GGDM 可用性待验证，暂用原值 */
        COALESCE(dm_tz1.ZWHY, src1.G070033) AS YWZL,
        /* JYDSPJ - 交易对手评级：直接映射 */
        src1.G070019 AS JYDSPJ,
        /* CJRQ - 采集日期：参数 P_DATA_DATE */
        P_DATA_DATE AS CJRQ,
        /* JYDSMC - 交易对手名称：直接映射 */
        src1.G070017 AS JYDSMC,
        /* JYDSPJJG - 交易对手评级机构：直接映射 */
        src1.G070020 AS JYDSPJJG,
        /* JYDSKHHM - 交易对手开户行名：直接映射 */
        src1.G070023 AS JYDSKHHM,
        /* JYDSZH - 交易对手账号：直接映射 */
        src1.G070022 AS JYDSZH,
        /* JYBH - 交易编号：直接映射 */
        src1.G070001 AS JYBH,
        /* MXKMMC - 明细科目名称：直接映射 */
        src1.G070014 AS MXKMMC,
        /* HTYDRQ - 合同起始日期：生效日期(G070040) 格式转为'YYYYMMDD' */
        DATE_FORMAT(src1.G070040, '%Y%m%d') AS HTYDRQ,
        /* JYZHLX - 账户类型：代码转换 01→银行账户, 02→交易账户 */
        CASE TRIM(src1.G070036)
            WHEN '01' THEN '银行账户'
            WHEN '02' THEN '交易账户'
            ELSE TRIM(src1.G070036)
        END AS JYZHLX,
        /* YHJGMC - 银行机构名称：T_1_1.银行机构名称 */
        org1.A010005 AS YHJGMC,
        /* NBJGH - 内部机构号：截取交易机构ID(G070002) 12位以后信息 */
        SUBSTR(TRIM(src1.G070002), 13) AS NBJGH,
        /* JYRQ - 交易日期：G070015 格式转为'YYYYMMDD' */
        DATE_FORMAT(src1.G070015, '%Y%m%d') AS JYRQ,
        /* MYBJJE - 合约金额：交易金额(G070006) 转为DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src1.G070006), '') AS DECIMAL(20,2)) AS MYBJJE,
        /* GSFZJG - 归属分支机构：业务需求映射表未给来源，暂置 NULL */
        NULL AS GSFZJG,
        /* CPMC - 产品名称：T_5_1.产品名称(E010003) */
        prod1.E010003 AS CPMC,
        /* JRXKZH - 金融许可证号：T_1_1.金融许可证号(A010003) */
        org1.A010003 AS JRXKZH,
        /* JYYGH - 经办人工号：直接映射 */
        src1.G070024 AS JYYGH,
        /* SPRGH - 审批人工号：直接映射 */
        src1.G070025 AS SPRGH,
        /* WTGLBZ - 委托管理标志：投资管理方式(H080010)为'02'→'是', 否则→'否' */
        CASE WHEN TRIM(inv1.H080010) = '02' THEN '是' ELSE '否' END AS WTGLBZ,
        /* JYDSKHHH - 交易对手开户行号：直接映射 */
        src1.G070021 AS JYDSKHHH,
        /* HTDQRQ - 合同到期日期：到期日期(G070041) 格式转为'YYYYMMDD' */
        DATE_FORMAT(src1.G070041, '%Y%m%d') AS HTDQRQ,
        /* NHLL - 年化利率：G070035 转为DECIMAL(20,6) */
        CAST(NULLIF(TRIM(src1.G070035), '') AS DECIMAL(20,6)) AS NHLL,
        /* MYBJBZ - 合约币种：直接映射 */
        src1.G070008 AS MYBJBZ,
        /* JYFX - 交易方向：代码转换 01→买入, 02→卖出 */
        CASE TRIM(src1.G070007)
            WHEN '01' THEN '买入'
            WHEN '02' THEN '卖出'
            ELSE TRIM(src1.G070007)
        END AS JYFX,
        /* YWXL - 业务小类：代码转换 via BS_CS_GGDM
           关联BS_CS_GGDM使用【表名 BM】为'通用'并且【字段名ZDM】为'自营业务小类类型',
           取【中文含义ZWHY】；含特殊前缀映射（01040-XX等）；BS_CS_GGDM 可用性待验证 */
        COALESCE(
            /* 先尝试精确匹配 */
            dm_sx1.ZWHY,
            /* 再尝试前缀通配：01040-XX等特殊映射 */
            CASE
                WHEN LEFT(TRIM(src1.G070034), 5) = '01040' THEN '其他买入返售中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 5) = '02040' THEN '其他卖出回购中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 5) = '10040' THEN '其他债券发行中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 5) = '11020' THEN '其他同业往来中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 5) = '12120' THEN '其他债券投资中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 5) = '13040' THEN '其他权益类投资中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 5) = '14060' THEN '其他公募基金投资中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 5) = '15040' THEN '其他私募基金投资中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 6) = '16061' THEN '其他资产管理产品投资-公募中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 6) = '16062' THEN '其他资产管理产品投资-私募中的其他-银行自定义'
                WHEN LEFT(TRIM(src1.G070034), 5) = '17030' THEN '其他投资中的其他-银行自定义'
                ELSE src1.G070034
            END
        ) AS YWXL,
        /* JRGJBH - 金融工具编号：优先取投融资标的代码(J020011)，取不到再取投融资标的ID(J020001) */
        COALESCE(NULLIF(TRIM(bid1.J020011), ''), bid1.J020001) AS JRGJBH,
        /* MXKMBH - 明细科目编号：科目ID(G070013) */
        src1.G070013 AS MXKMBH,
        /* SENSITIVEFLAG - 涉密标志：业务需求映射表未给来源，暂置 NULL */
        NULL AS SENSITIVEFLAG,
        /* JRGJMC - 金融工具名称：T_9_2.投资标的名称(J020002) */
        bid1.J020002 AS JRGJMC
    FROM T_7_7 src1
    /* 左关联：投融资标的 T_9_2 ON 投资标的ID(G070005) = 投融资标的ID(J020001) */
    LEFT JOIN T_9_2 bid1
        ON TRIM(src1.G070005) = TRIM(bid1.J020001)
    /* 左关联：投资情况 T_8_8 ON 协议ID(G070037)+科目ID(G070013)+投资标的ID(G070005) */
    LEFT JOIN T_8_8 inv1
        ON TRIM(src1.G070037) = TRIM(inv1.H080004)
        AND TRIM(src1.G070013) = TRIM(inv1.H080008)
        AND TRIM(src1.G070005) = TRIM(inv1.H080001)
    /* 左关联：投资协议 T_6_21 ON 投资情况.协议ID */
    LEFT JOIN T_6_21 pact1
        ON TRIM(inv1.H080004) = TRIM(pact1.F210001)
    /* 左关联：产品业务基本信息 T_5_1 ON 产品ID(G070027) AND 自营标识='01' */
    LEFT JOIN T_5_1 prod1
        ON TRIM(src1.G070027) = TRIM(prod1.E010001)
        AND prod1.E010008 = '01'
    /* 左关联：机构信息 T_1_1 ON 交易机构ID(G070002) = 机构ID(A010001) */
    LEFT JOIN T_1_1 org1
        ON TRIM(src1.G070002) = TRIM(org1.A010001)
        AND org1.A010020 = V_DATA_DATE
    /* 左关联：BS_CS_GGDM 业务中类代码映射 (YWZL) */
    LEFT JOIN BS_CS_GGDM dm_tz1
        ON dm_tz1.BM = '通用'
        AND dm_tz1.ZDM = '自营业务大类类型'
        AND TRIM(dm_tz1.DM) = TRIM(src1.G070033)
    /* 左关联：BS_CS_GGDM 业务小类代码映射 (YWXL) */
    LEFT JOIN BS_CS_GGDM dm_sx1
        ON dm_sx1.BM = '通用'
        AND dm_sx1.ZDM = '自营业务小类类型'
        AND TRIM(dm_sx1.DM) = TRIM(src1.G070034)
    WHERE 1=1
        /* 采集日期过滤：当月数据 */
        AND src1.G070032 >= V_MONTH_BEGIN
        AND src1.G070032 <= V_DATA_DATE
        /* 过滤交易金额小于0的数据 */
        AND CAST(NULLIF(TRIM(src1.G070006), '') AS DECIMAL(20,2)) >= 0

    UNION ALL

    /* ========================================================
       Part 2: 同业交易 (T_7_6)
       主表: T_7_6 同业交易
       左关联: T_8_7 同业存量情况 ON 同业业务ID
       左关联: T_9_2 投融资标的 ON 投资标的ID
       左关联: T_5_1 产品业务基本信息 ON 产品ID AND 自营标识='01'
       左关联: T_1_1 机构信息 ON 交易机构ID
       过滤: 同业业务种类 != '08' (同业存放), 自营业务小类 != '07020' (结算性存放同业)
       ======================================================== */
    SELECT
        /* BBZ - 备注：拼接 T_7_6.G060032(客户备注) 和 T_8_7.H070026(备注) */
        TRIM(TRAILING ';' FROM CONCAT_WS(';',
            NULLIF(TRIM(src2.G060032), ''),
            NULLIF(TRIM(inv2.H070026), '')
        )) AS BBZ,
        /* BFQSZH - 本方清算账号：T_7_6.交易账号(G060005) */
        src2.G060005 AS BFQSZH,
        /* JYDSLB - 交易对手类别：代码转换（同投资交易规则） */
        CASE TRIM(src2.G060014)
            WHEN '01' THEN '银行业金融机构'
            WHEN '02' THEN '非银行业金融机构'
            WHEN '03' THEN '非银行业金融机构'
            WHEN '04' THEN '非银行业金融机构'
            WHEN '05' THEN '非银行业金融机构'
            WHEN '06' THEN '非银行业金融机构'
            WHEN '08' THEN '非银行业金融机构'
            WHEN '09' THEN '政府机关'
            WHEN '07' THEN '公司客户'
            WHEN '10' THEN '公司客户'
            WHEN '11' THEN '个人客户'
            WHEN '12' THEN '境外金融机构'
            WHEN '00' THEN '其他'
            ELSE TRIM(src2.G060014)
        END AS JYDSLB,
        /* YEDL - 业务大类：同业交易统一为'同业往来' */
        '同业往来' AS YEDL,
        /* YWZL - 业务中类：代码转换 via BS_CS_GGDM 自营业务大类类型 */
        COALESCE(dm_tz2.ZWHY, src2.G060026) AS YWZL,
        /* JYDSPJ - 交易对手评级 */
        src2.G060015 AS JYDSPJ,
        /* CJRQ - 采集日期 */
        P_DATA_DATE AS CJRQ,
        /* JYDSMC - 交易对手名称 */
        src2.G060013 AS JYDSMC,
        /* JYDSPJJG - 交易对手评级机构 */
        src2.G060016 AS JYDSPJJG,
        /* JYDSKHHM - 交易对手开户行名 */
        src2.G060019 AS JYDSKHHM,
        /* JYDSZH - 交易对手账号 */
        src2.G060018 AS JYDSZH,
        /* JYBH - 交易编号 */
        src2.G060001 AS JYBH,
        /* MXKMMC - 明细科目名称 */
        src2.G060012 AS MXKMMC,
        /* HTYDRQ - 合同起始日期：生效日期(G060040) */
        DATE_FORMAT(src2.G060040, '%Y%m%d') AS HTYDRQ,
        /* JYZHLX - 账户类型：代码转换（取自 T_8_7.H070007） */
        CASE TRIM(inv2.H070007)
            WHEN '01' THEN '银行账户'
            WHEN '02' THEN '交易账户'
            ELSE TRIM(inv2.H070007)
        END AS JYZHLX,
        /* YHJGMC - 银行机构名称 */
        org2.A010005 AS YHJGMC,
        /* NBJGH - 内部机构号：截取交易机构ID(G060003) 12位以后 */
        SUBSTR(TRIM(src2.G060003), 13) AS NBJGH,
        /* JYRQ - 交易日期 */
        DATE_FORMAT(src2.G060009, '%Y%m%d') AS JYRQ,
        /* MYBJJE - 合约金额 */
        CAST(NULLIF(TRIM(src2.G060006), '') AS DECIMAL(20,2)) AS MYBJJE,
        /* GSFZJG - 归属分支机构：暂置 NULL */
        NULL AS GSFZJG,
        /* CPMC - 产品名称：T_5_1.产品名称 */
        prod2.E010003 AS CPMC,
        /* JRXKZH - 金融许可证号 */
        org2.A010003 AS JRXKZH,
        /* JYYGH - 经办人工号 */
        src2.G060021 AS JYYGH,
        /* SPRGH - 审批人工号 */
        src2.G060022 AS SPRGH,
        /* WTGLBZ - 委托管理标志：同业交易统一为'否' */
        '否' AS WTGLBZ,
        /* JYDSKHHH - 交易对手开户行号 */
        src2.G060017 AS JYDSKHHH,
        /* HTDQRQ - 合同到期日期：T_8_7.合同终止日期(H070012) */
        DATE_FORMAT(inv2.H070012, '%Y%m%d') AS HTDQRQ,
        /* NHLL - 年化利率 */
        CAST(NULLIF(TRIM(src2.G060043), '') AS DECIMAL(20,6)) AS NHLL,
        /* MYBJBZ - 合约币种 */
        src2.G060008 AS MYBJBZ,
        /* JYFX - 交易方向：代码转换 01→买入, 02→卖出 */
        CASE TRIM(src2.G060007)
            WHEN '01' THEN '买入'
            WHEN '02' THEN '卖出'
            ELSE TRIM(src2.G060007)
        END AS JYFX,
        /* YWXL - 业务小类：代码转换 via BS_CS_GGDM 自营业务小类类型 */
        COALESCE(
            dm_sx2.ZWHY,
            CASE
                WHEN LEFT(TRIM(inv2.H070021), 5) = '01040' THEN '其他买入返售中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 5) = '02040' THEN '其他卖出回购中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 5) = '10040' THEN '其他债券发行中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 5) = '11020' THEN '其他同业往来中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 5) = '12120' THEN '其他债券投资中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 5) = '13040' THEN '其他权益类投资中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 5) = '14060' THEN '其他公募基金投资中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 5) = '15040' THEN '其他私募基金投资中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 6) = '16061' THEN '其他资产管理产品投资-公募中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 6) = '16062' THEN '其他资产管理产品投资-私募中的其他-银行自定义'
                WHEN LEFT(TRIM(inv2.H070021), 5) = '17030' THEN '其他投资中的其他-银行自定义'
                ELSE inv2.H070021
            END
        ) AS YWXL,
        /* JRGJBH - 金融工具编号：优先取投融资标的代码，取不到再取投融资标的ID */
        COALESCE(NULLIF(TRIM(bid2.J020011), ''), bid2.J020001) AS JRGJBH,
        /* MXKMBH - 明细科目编号 */
        src2.G060011 AS MXKMBH,
        /* SENSITIVEFLAG - 涉密标志：暂置 NULL */
        NULL AS SENSITIVEFLAG,
        /* JRGJMC - 金融工具名称 */
        bid2.J020002 AS JRGJMC
    FROM T_7_6 src2
    /* 左关联：同业存量情况 T_8_7 ON 同业业务ID(G060002) = 同业业务ID(H070001) */
    LEFT JOIN T_8_7 inv2
        ON TRIM(src2.G060002) = TRIM(inv2.H070001)
    /* 左关联：投融资标的 T_9_2 ON 同业存量情况.投资标的ID(H070016) = 投融资标的ID(J020001) */
    LEFT JOIN T_9_2 bid2
        ON TRIM(inv2.H070016) = TRIM(bid2.J020001)
    /* 左关联：产品业务基本信息 T_5_1 ON 产品ID(G060039) AND 自营标识='01' */
    LEFT JOIN T_5_1 prod2
        ON TRIM(src2.G060039) = TRIM(prod2.E010001)
        AND prod2.E010008 = '01'
    /* 左关联：机构信息 T_1_1 ON 交易机构ID(G060003) = 机构ID(A010001) */
    LEFT JOIN T_1_1 org2
        ON TRIM(src2.G060003) = TRIM(org2.A010001)
        AND org2.A010020 = V_DATA_DATE
    /* 左关联：BS_CS_GGDM 业务中类代码映射 (YWZL) */
    LEFT JOIN BS_CS_GGDM dm_tz2
        ON dm_tz2.BM = '通用'
        AND dm_tz2.ZDM = '自营业务大类类型'
        AND TRIM(dm_tz2.DM) = TRIM(src2.G060026)
    /* 左关联：BS_CS_GGDM 业务小类代码映射 (YWXL) */
    LEFT JOIN BS_CS_GGDM dm_sx2
        ON dm_sx2.BM = '通用'
        AND dm_sx2.ZDM = '自营业务小类类型'
        AND TRIM(dm_sx2.DM) = TRIM(inv2.H070021)
    WHERE 1=1
        /* 采集日期过滤 */
        AND src2.G060023 >= V_MONTH_BEGIN
        AND src2.G060023 <= V_DATA_DATE
        /* 同业业务种类不为08-同业存款-同业存放 */
        AND (TRIM(inv2.H070004) NOT LIKE '08%' OR inv2.H070004 IS NULL)
        /* 自营业务小类不为'07020'（结算性存放同业） */
        AND (TRIM(inv2.H070021) != '07020' OR inv2.H070021 IS NULL)

    UNION ALL

    /* ========================================================
       Part 3: 融资交易 (T_7_12)
       主表: T_7_12 融资交易
       左关联: T_8_9 融资情况 ON 融资业务ID
       左关联: T_9_2 投融资标的 ON 融资标的ID = 投融资标的ID
       左关联: T_1_1 机构信息 ON 机构ID
       左关联: T_4_2 科目信息 ON 科目ID
       过滤: 融资工具子类型 NOT IN ('011') （排除大额存单）
       ======================================================== */
    SELECT
        /* BBZ - 备注：拼接 T_7_12.G120030 和 T_8_9.H090022 */
        TRIM(TRAILING ';' FROM CONCAT_WS(';',
            NULLIF(TRIM(src3.G120030), ''),
            NULLIF(TRIM(fin3.H090022), '')
        )) AS BBZ,
        /* BFQSZH - 本方清算账号：T_7_12.本方清算账号(G120013) */
        src3.G120013 AS BFQSZH,
        /* JYDSLB - 交易对手类别：代码转换（同投资交易规则） */
        CASE TRIM(src3.G120008)
            WHEN '01' THEN '银行业金融机构'
            WHEN '02' THEN '非银行业金融机构'
            WHEN '03' THEN '非银行业金融机构'
            WHEN '04' THEN '非银行业金融机构'
            WHEN '05' THEN '非银行业金融机构'
            WHEN '06' THEN '非银行业金融机构'
            WHEN '08' THEN '非银行业金融机构'
            WHEN '09' THEN '政府机关'
            WHEN '07' THEN '公司客户'
            WHEN '10' THEN '公司客户'
            WHEN '11' THEN '个人客户'
            WHEN '12' THEN '境外金融机构'
            WHEN '00' THEN '其他'
            ELSE TRIM(src3.G120008)
        END AS JYDSLB,
        /* YEDL - 业务大类：融资交易统一为'同业往来' */
        '同业往来' AS YEDL,
        /* YWZL - 业务中类：代码转换 via BS_CS_GGDM 融资工具子类型 */
        COALESCE(dm_tz3.ZWHY, src3.G120024) AS YWZL,
        /* JYDSPJ - 交易对手评级 */
        src3.G120010 AS JYDSPJ,
        /* CJRQ - 采集日期 */
        P_DATA_DATE AS CJRQ,
        /* JYDSMC - 交易对手名称 */
        src3.G120005 AS JYDSMC,
        /* JYDSPJJG - 交易对手评级机构 */
        src3.G120011 AS JYDSPJJG,
        /* JYDSKHHM - 交易对手开户行名 */
        src3.G120012 AS JYDSKHHM,
        /* JYDSZH - 交易对手账号 */
        src3.G120006 AS JYDSZH,
        /* JYBH - 交易编号 */
        src3.G120001 AS JYBH,
        /* MXKMMC - 明细科目名称：T_4_2.科目名称(D020003) */
        acct3.D020003 AS MXKMMC,
        /* HTYDRQ - 合同起始日期：生效日期(G120018) */
        DATE_FORMAT(src3.G120018, '%Y%m%d') AS HTYDRQ,
        /* JYZHLX - 账户类型：代码转换（取自 T_7_12.G120016） */
        CASE TRIM(src3.G120016)
            WHEN '01' THEN '银行账户'
            WHEN '02' THEN '交易账户'
            ELSE TRIM(src3.G120016)
        END AS JYZHLX,
        /* YHJGMC - 银行机构名称 */
        org3.A010005 AS YHJGMC,
        /* NBJGH - 内部机构号：截取机构ID(G120002) 12位以后 */
        SUBSTR(TRIM(src3.G120002), 13) AS NBJGH,
        /* JYRQ - 交易日期 */
        DATE_FORMAT(src3.G120017, '%Y%m%d') AS JYRQ,
        /* MYBJJE - 合约金额：交易金额(G120021) */
        CAST(NULLIF(TRIM(src3.G120021), '') AS DECIMAL(20,2)) AS MYBJJE,
        /* GSFZJG - 归属分支机构：暂置 NULL */
        NULL AS GSFZJG,
        /* CPMC - 产品名称：融资交易直接映射 T_7_12.产品名称(G120014) */
        src3.G120014 AS CPMC,
        /* JRXKZH - 金融许可证号 */
        org3.A010003 AS JRXKZH,
        /* JYYGH - 经办人工号 */
        src3.G120026 AS JYYGH,
        /* SPRGH - 审批人工号 */
        src3.G120028 AS SPRGH,
        /* WTGLBZ - 委托管理标志：融资交易统一为'否' */
        '否' AS WTGLBZ,
        /* JYDSKHHH - 交易对手开户行号 */
        src3.G120007 AS JYDSKHHH,
        /* HTDQRQ - 合同到期日期：T_9_2.到期日期(J020016) */
        DATE_FORMAT(bid3.J020016, '%Y%m%d') AS HTDQRQ,
        /* NHLL - 年化利率 */
        CAST(NULLIF(TRIM(src3.G120032), '') AS DECIMAL(20,6)) AS NHLL,
        /* MYBJBZ - 合约币种：交易币种(G120020) */
        src3.G120020 AS MYBJBZ,
        /* JYFX - 交易方向：代码转换 01→买入, 02→卖出 */
        CASE TRIM(src3.G120015)
            WHEN '01' THEN '买入'
            WHEN '02' THEN '卖出'
            ELSE TRIM(src3.G120015)
        END AS JYFX,
        /* YWXL - 业务小类：代码转换 via BS_CS_GGDM 自营业务小类类型
           融资交易仅含 11020-XX 映射 */
        COALESCE(
            dm_sx3.ZWHY,
            CASE
                WHEN LEFT(TRIM(src3.G120024), 5) = '11020' THEN '其他同业往来中的其他-银行自定义'
                ELSE src3.G120024
            END
        ) AS YWXL,
        /* JRGJBH - 金融工具编号：优先取投融资标的代码，取不到再取投融资标的ID */
        COALESCE(NULLIF(TRIM(bid3.J020011), ''), bid3.J020001) AS JRGJBH,
        /* MXKMBH - 明细科目编号：T_8_9.科目ID(H090012) */
        fin3.H090012 AS MXKMBH,
        /* SENSITIVEFLAG - 涉密标志：暂置 NULL */
        NULL AS SENSITIVEFLAG,
        /* JRGJMC - 金融工具名称 */
        bid3.J020002 AS JRGJMC
    FROM T_7_12 src3
    /* 左关联：融资情况 T_8_9 ON 融资业务ID(G120004) = 融资业务ID(H090001) */
    LEFT JOIN T_8_9 fin3
        ON TRIM(src3.G120004) = TRIM(fin3.H090001)
    /* 左关联：投融资标的 T_9_2 ON 融资标的ID(H090020) = 投融资标的ID(J020001) */
    LEFT JOIN T_9_2 bid3
        ON TRIM(fin3.H090020) = TRIM(bid3.J020001)
    /* 左关联：机构信息 T_1_1 ON 机构ID(G120002) = 机构ID(A010001) */
    LEFT JOIN T_1_1 org3
        ON TRIM(src3.G120002) = TRIM(org3.A010001)
        AND org3.A010020 = V_DATA_DATE
    /* 左关联：科目信息 T_4_2 ON 科目ID(H090012) = 科目ID(D020001) */
    LEFT JOIN T_4_2 acct3
        ON TRIM(fin3.H090012) = TRIM(acct3.D020001)
        AND acct3.D020011 = V_DATA_DATE
    /* 左关联：BS_CS_GGDM 业务中类代码映射 - 融资工具子类型 (YWZL) */
    LEFT JOIN BS_CS_GGDM dm_tz3
        ON dm_tz3.BM = '通用'
        AND dm_tz3.ZDM = '融资工具子类型'
        AND TRIM(dm_tz3.DM) = TRIM(src3.G120024)
    /* 左关联：BS_CS_GGDM 业务小类代码映射 (YWXL) */
    LEFT JOIN BS_CS_GGDM dm_sx3
        ON dm_sx3.BM = '通用'
        AND dm_sx3.ZDM = '自营业务小类类型'
        AND TRIM(dm_sx3.DM) = TRIM(src3.G120024)
    WHERE 1=1
        /* 采集日期过滤 */
        AND src3.G120031 >= V_MONTH_BEGIN
        AND src3.G120031 <= V_DATA_DATE
        /* 融资工具子类型 NOT IN ('011') - 排除大额存单 */
        AND (TRIM(src3.G120024) NOT IN ('011') OR src3.G120024 IS NULL);

    COMMIT;
END;
