-- ============================================================
-- EAST5.0 垫款登记表（IE_005_512）GBase 存储过程
-- 业务需求：《039_垫款登记表.md》（Excel映射规则第951行）
-- 数据库方言：GBase 8a MPP
-- 生成/重构日期：2026-05-09
-- 状态：draft（尚未在 GBase 环境执行验证）
-- ============================================================
-- 业务目标：
--   依据《039_垫款登记表.md》映射规则，从一表通垫款状态（T_8_3）
--   主源出发，关联机构信息（T_1_1）和对公客户信息（IE_002_203），
--   生成 EAST5.0 垫款登记表 IE_005_512。
--
-- 报送模式：
--   全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间
--   结清、失效、终结等所有视为终态的数据。
--
-- 报送要求：
--   填报信用证、承兑汇票、保函、贵金属租赁等业务产生的各项垫款信息，
--   相关业务定义参照1104报表《各项垫款情况表》。
--   垫款状态为"结清"、"转让"、"核销"的，在报送最后状态的次月可不再报送。
--
-- 表级规则：
--   取日期在当月且通过信贷借据号关联生成对公信贷业务借据表来筛选范围
--   （注：当前草案未实现信贷借据号关联筛选，仅按采集日期过滤。
--    该表级规则的具体实现逻辑待需求方确认。）
--
-- 源表：
--   T_8_3  — 一表通垫款状态（主源）
--   T_1_1  — 一表通机构信息（维表）
--   IE_002_203 — EAST对公客户信息表（客户名称 enrich）
--
-- 目标表：
--   IE_005_512 — 垫款登记表
--
-- 参数：
--   P_DATA_DATE — 采集日期，格式 YYYYMMDD
--
-- 运行方式：
--   先删除目标表同一采集日期数据，再插入映射结果。
-- ============================================================

DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_512_DKDJB;

CREATE PROCEDURE PROC_EAST_IE_005_512_DKDJB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 参数校验
    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);

    START TRANSACTION;

    -- 先删后插：清除目标表该采集日期的历史数据
    DELETE FROM IE_005_512
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_512 (
        DKYE,
        KHLB,
        CJRQ,
        GSFZJG,
        SENSITIVEFLAG,
        NBJGH,
        XDHTH,
        DKLX,
        BZ,
        JRXKZH,
        YHJGMC,
        XDJJH,
        YHTBH,
        DKJE,
        KHTYBH,
        DKRQ,
        DKZT,
        BBZ,
        KHMC
    )
    SELECT
        /* 1. DKYE 垫款余额：T_8_3.H030009 → CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.H030009), '') AS DECIMAL(20,2)) AS DKYE,

        /* 2. KHLB 客户类别：业务需求未给来源，缺口字段置 NULL */
        NULL AS KHLB,

        /* 3. CJRQ 采集日期：直接赋入参 P_DATA_DATE（YYYYMMDD） */
        P_DATA_DATE AS CJRQ,

        /* 4. GSFZJG 归属分支机构：业务需求未给来源，缺口字段置 NULL */
        NULL AS GSFZJG,

        /* 5. SENSITIVEFLAG 涉密标志：业务需求未给来源，缺口字段置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 6. NBJGH 内部机构号：T_8_3.H030003 → SUBSTR 从第12位截取 */
        SUBSTR(TRIM(src.H030003), 12) AS NBJGH,

        /* 7. XDHTH 信贷合同号：T_8_3.H030001 → 直接映射 */
        src.H030001 AS XDHTH,

        /* 8. DKLX 垫款类型：T_8_3.H030007 → 码值 CASE 转换
         * 2026-05-09 修正：
         *   XX 是银行自定义代号（变量），不是字面量。
         *   原草案用 WHEN '00-XX' 精确匹配字面字符串，匹配不到实际数据。
         *   改为 WHEN LEFT(...) = '00-' 模式匹配，取 '00-' 后面的部分拼接。
         *   需求文档只写了 '00-XX' 一种通配，没有 '00XX' 分支。
         */
        CASE
            WHEN TRIM(src.H030007) = '01' THEN '1.1承兑汇票'
            WHEN TRIM(src.H030007) = '02' THEN '1.2融资性保函'
            WHEN TRIM(src.H030007) = '03' THEN '1.3其他等同于贷款的授信业务'
            WHEN TRIM(src.H030007) = '04' THEN '2.1非融资性保函'
            WHEN TRIM(src.H030007) = '05' THEN '2.2其他与交易相关的或有项目'
            WHEN TRIM(src.H030007) = '06' THEN '3.1跟单信用证'
            WHEN TRIM(src.H030007) = '07' THEN '3.2其他与贸易相关的或有项目'
            WHEN TRIM(src.H030007) = '00' THEN '其他'
            WHEN LEFT(TRIM(src.H030007), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(src.H030007), 4))
            ELSE ''
        END AS DKLX,

        /* 9. BZ 币种：T_8_3.H030006 → 直接映射 */
        src.H030006 AS BZ,

        /* 10. JRXKZH 金融许可证号：T_1_1.A010003 → LEFT JOIN 机构信息表 */
        s1.A010003 AS JRXKZH,

        /* 11. YHJGMC 银行机构名称：T_1_1.A010005 → LEFT JOIN 机构信息表 */
        s1.A010005 AS YHJGMC,

        /* 12. XDJJH 信贷借据号：T_8_3.H030004 → 直接映射 */
        src.H030004 AS XDJJH,

        /* 13. YHTBH 原合同编号：T_8_3.H030005 → 直接映射 */
        src.H030005 AS YHTBH,

        /* 14. DKJE 垫款金额：T_8_3.H030008 → CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.H030008), '') AS DECIMAL(20,2)) AS DKJE,

        /* 15. KHTYBH 客户统一编号：T_8_3.H030002 → 直接映射 */
        src.H030002 AS KHTYBH,

        /* 16. DKRQ 垫款日期：T_8_3.H030010 → DATE→VARCHAR(8) YYYYMMDD，空值默认99991231 */
        CASE
            WHEN src.H030010 IS NULL THEN '99991231'
            ELSE REPLACE(CAST(src.H030010 AS CHAR), '-', '')
        END AS DKRQ,

        /* 17. DKZT 垫款状态：T_8_3.H030011 → 码值 CASE 转换
         * 2026-05-09 修正：同 DKLX，XX 是变量，改用 LEFT/SUBSTRING 模式匹配。
         */
        CASE
            WHEN TRIM(src.H030011) = '01' THEN '未结清'
            WHEN TRIM(src.H030011) = '02' THEN '已结清'
            WHEN TRIM(src.H030011) = '03' THEN '转让'
            WHEN TRIM(src.H030011) = '04' THEN '核销'
            WHEN TRIM(src.H030011) = '00' THEN '其他'
            WHEN LEFT(TRIM(src.H030011), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(src.H030011), 4))
            ELSE ''
        END AS DKZT,

        /* 18. BBZ 备注：T_8_3.H030012 → 直接映射
         * 需求文档写"提取一表通《表8.3垫款状态》备注，以';'拼接"。
         * 当前垫款数据仅来自 T_8_3 单表，无多源拼接场景，故直接映射。
         * 若后续发现需多源拼接（如 T_6_1 等表也有备注字段），需在此处重构。
         */
        src.H030012 AS BBZ,

        /* 19. KHMC 客户名称：IE_002_203.KHMC → LEFT JOIN 对公客户信息表 enrich */
        cust.KHMC AS KHMC

    FROM T_8_3 src
    /* 机构信息维表：按机构ID截取第12位关联 T_1_1.A010002（内部机构号）+ 采集日期 */
    LEFT JOIN T_1_1 s1
        ON SUBSTR(TRIM(src.H030003), 12) = TRIM(s1.A010002)
       AND s1.A010020 = V_DATA_DATE
    /* 对公客户信息表：按客户ID关联 IE_002_203.KHTYBH（客户统一编号）+ 采集日期 */
    LEFT JOIN IE_002_203 cust
        ON TRIM(src.H030002) = TRIM(cust.KHTYBH)
       AND cust.CJRQ = P_DATA_DATE

    WHERE 1 = 1
      /* 当月采集日期过滤 */
      AND src.H030013 = V_DATA_DATE
      /* 终态纳入规则预留：垫款状态为"结清"、"转让"、"核销"的，在报送最后状态的次月可不再报送 */
      /* 当前按全量采集日期过滤，终态次月排除逻辑待需求方确认 */;

    COMMIT;
END;
