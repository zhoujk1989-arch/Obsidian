/*
校验目标：
- 校验 PROC_EAST_IE_004_411_DGXDFHZ 存储过程输出 IE_004_411 的数据质量。

依赖材料：
- 原始材料/业务需求/EAST5.0/026_对公信贷分户账.md
- 原始材料/表结构/EAST5.0系统/IE_004_411-对公信贷分户账-DDL-2026-04-28.sql
- 工作区/SQL开发/EAST5.0系统/PROC_EAST_IE_004_411_DGXDFHZ_草案.sql

参数：
- P_CHECK_DATE：校验采集日期，格式 YYYYMMDD。
*/

-- ============================================================
-- 校验 1：目标表行数非零
-- ============================================================
SELECT
    '01_row_count_nonzero' AS check_id,
    COUNT(*) AS actual_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM IE_004_411
WHERE CJRQ = '20260504';

-- ============================================================
-- 校验 2：主键重复检查（XDJJH + CJRQ + BZ + DKFHZH）
-- ============================================================
SELECT
    '02_pk_duplicate' AS check_id,
    COUNT(*) AS duplicate_count
FROM (
    SELECT XDJJH, CJRQ, BZ, DKFHZH, COUNT(*) AS cnt
    FROM IE_004_411
    WHERE CJRQ = '20260504'
    GROUP BY XDJJH, CJRQ, BZ, DKFHZH
    HAVING cnt > 1
) dup;

-- ============================================================
-- 校验 3：信贷借据号 XDJJH 非空
-- ============================================================
SELECT
    '03_xdjjh_notnull' AS check_id,
    COUNT(*) AS null_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND (XDJJH IS NULL OR TRIM(XDJJH) = '');

-- ============================================================
-- 校验 4：贷款分户账号 DKFHZH 非空
-- ============================================================
SELECT
    '04_dkfhzh_notnull' AS check_id,
    COUNT(*) AS null_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND (DKFHZH IS NULL OR TRIM(DKFHZH) = '');

-- ============================================================
-- 校验 5：采集日期 CJRQ 格式 YYYYMMDD
-- ============================================================
SELECT
    '05_cjrq_format' AS check_id,
    COUNT(*) AS bad_format_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND CJRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================================
-- 校验 6：贷款状态 DKZT 码值检查
-- ============================================================
SELECT
    '06_dkzt_codeval' AS check_id,
    DKZT AS code_value,
    COUNT(*) AS cnt
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND DKZT IS NOT NULL
GROUP BY DKZT
ORDER BY cnt DESC;

-- ============================================================
-- 校验 7：账户状态 ZHZT 码值检查
-- ============================================================
SELECT
    '07_zhzt_codeval' AS check_id,
    ZHZT AS code_value,
    COUNT(*) AS cnt
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND ZHZT IS NOT NULL
GROUP BY ZHZT
ORDER BY cnt DESC;

-- ============================================================
-- 校验 8：贷款状态 DKZT 码值越界检查
-- ============================================================
SELECT
    '08_dkzt_outofrange' AS check_id,
    COUNT(*) AS outofrange_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND DKZT NOT IN ('正常', '核销', '转让', '结清', '逾期', '其他-XX');

-- ============================================================
-- 校验 9：账户状态 ZHZT 码值越界检查
-- ============================================================
SELECT
    '09_zhzt_outofrange' AS check_id,
    COUNT(*) AS outofrange_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND ZHZT NOT IN ('正常', '预销户', '销户', '冻结', '止付', '其他-XX');

-- ============================================================
-- 校验 10：发放日期 FFRQ 格式 YYYYMMDD
-- ============================================================
SELECT
    '10_ffrq_format' AS check_id,
    COUNT(*) AS bad_format_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND FFRQ IS NOT NULL
  AND FFRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================================
-- 校验 11：开户日期 KHRQ 格式 YYYYMMDD（含默认值检查）
-- ============================================================
SELECT
    '11_khrq_format' AS check_id,
    COUNT(*) AS bad_format_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND KHRQ IS NOT NULL
  AND KHRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================================
-- 校验 12：销户日期 XHRQ 格式 YYYYMMDD（含默认值检查）
-- ============================================================
SELECT
    '12_xhrq_format' AS check_id,
    COUNT(*) AS bad_format_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND XHRQ IS NOT NULL
  AND XHRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================================
-- 校验 13：到期日期 DQRQ 格式 YYYYMMDD
-- ============================================================
SELECT
    '13_dqrq_format' AS check_id,
    COUNT(*) AS bad_format_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND DQRQ IS NOT NULL
  AND DQRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================================
-- 校验 14：贷款金额 DKJE 非负检查
-- ============================================================
SELECT
    '14_dkje_nonneg' AS check_id,
    COUNT(*) AS negative_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND DKJE IS NOT NULL
  AND DKJE < 0;

-- ============================================================
-- 校验 15：贷款余额 DKYE 非负检查
-- ============================================================
SELECT
    '15_dkye_nonneg' AS check_id,
    COUNT(*) AS negative_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND DKYE IS NOT NULL
  AND DKYE < 0;

-- ============================================================
-- 校验 16：币种 BZ 长度检查（应为 3 位）
-- ============================================================
SELECT
    '16_bz_length' AS check_id,
    COUNT(*) AS bad_length_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND BZ IS NOT NULL
  AND LENGTH(BZ) != 3;

-- ============================================================
-- 校验 17：实际利率 SJLL 范围检查（0~1 之间合理）
-- ============================================================
SELECT
    '17_sjll_range' AS check_id,
    COUNT(*) AS outofrange_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND SJLL IS NOT NULL
  AND (SJLL < 0 OR SJLL > 1);

-- ============================================================
-- 校验 18：内部机构号 NBJGH 长度检查
-- ============================================================
SELECT
    '18_nbjgh_length' AS check_id,
    COUNT(*) AS bad_length_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND NBJGH IS NOT NULL
  AND LENGTH(NBJGH) > 30;

-- ============================================================
-- 校验 19：缺口字段 GSFZJG 应全部为 NULL
-- ============================================================
SELECT
    '19_gsfzjg_null' AS check_id,
    COUNT(*) AS non_null_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND GSFZJG IS NOT NULL;

-- ============================================================
-- 校验 20：缺口字段 SENSITIVEFLAG 应全部为 NULL
-- ============================================================
SELECT
    '20_sensitiveflag_null' AS check_id,
    COUNT(*) AS non_null_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND SENSITIVEFLAG IS NOT NULL;

-- ============================================================
-- 校验 21：账户名称 ZHMC 非空检查（分户账应有关联）
-- ============================================================
SELECT
    '21_zhmc_notnull' AS check_id,
    COUNT(*) AS null_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND (ZHMC IS NULL OR TRIM(ZHMC) = '');

-- ============================================================
-- 校验 22：银行机构名称 YHJGMC 非空检查（机构应有关联）
-- ============================================================
SELECT
    '22_yhjgmc_notnull' AS check_id,
    COUNT(*) AS null_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND (YHJGMC IS NULL OR TRIM(YHJGMC) = '');

-- ============================================================
-- 校验 23：金融许可证号 JRXKZH 非空检查（机构应有关联）
-- ============================================================
SELECT
    '23_jrxkzh_notnull' AS check_id,
    COUNT(*) AS null_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND (JRXKZH IS NULL OR TRIM(JRXKZH) = '');

-- ============================================================
-- 校验 24：明细科目编号 MXKMBH 非空检查
-- ============================================================
SELECT
    '24_mxkmbh_notnull' AS check_id,
    COUNT(*) AS null_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND (MXKMBH IS NULL OR TRIM(MXKMBH) = '');

-- ============================================================
-- 校验 25：客户统一编号 KHTYBH 非空检查
-- ============================================================
SELECT
    '25_khtybh_notnull' AS check_id,
    COUNT(*) AS null_count
FROM IE_004_411
WHERE CJRQ = '20260504'
  AND (KHTYBH IS NULL OR TRIM(KHTYBH) = '');
