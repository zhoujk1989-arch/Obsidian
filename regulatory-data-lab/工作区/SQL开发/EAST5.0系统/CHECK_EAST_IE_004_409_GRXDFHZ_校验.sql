/*
校验目标：
- 校验 PROC_EAST_IE_004_409_GRXDFHZ 存储过程输出质量。

依赖材料：
- 原始材料/业务需求/EAST5.0/024_个人信贷分户账.md
- 原始材料/表结构/EAST5.0系统/IE_004_409-个人信贷分户账-DDL-2026-04-28.sql
- 工作区/SQL开发/EAST5.0系统/PROC_EAST_IE_004_409_GRXDFHZ_草案.sql

参数：
- V_DATA_DATE：测试用采集日期，格式 YYYYMMDD，执行前替换。
*/

SET @V_DATA_DATE = '20260430';

/* ============================================================
   校验 1：目标行数是否符合业务范围（非零）
   ============================================================ */
SELECT 'CHK_01_ROW_COUNT' AS check_name,
       COUNT(*) AS actual_rows,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE;

/* ============================================================
   校验 2：主键组合（CJRQ + DKFHZH + XDJJH + BZ）是否重复
   ============================================================ */
SELECT 'CHK_02_PK_DUPLICATE' AS check_name,
       COUNT(*) - COUNT(DISTINCT CJRQ || DKFHZH || XDJJH || BZ) AS duplicate_count,
       CASE WHEN COUNT(*) - COUNT(DISTINCT CJRQ || DKFHZH || XDJJH || BZ) = 0
            THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE;

/* ============================================================
   校验 3：必填字段 DKFHZH（贷款分户账号）是否为空
   ============================================================ */
SELECT 'CHK_03_REQUIRED_DKFHZH' AS check_name,
       COUNT(*) AS null_dkfhzh_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND (DKFHZH IS NULL OR TRIM(DKFHZH) = '');

/* ============================================================
   校验 4：必填字段 XDJJH（信贷借据号）是否为空
   ============================================================ */
SELECT 'CHK_04_REQUIRED_XDJJH' AS check_name,
       COUNT(*) AS null_xdjjh_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND (XDJJH IS NULL OR TRIM(XDJJH) = '');

/* ============================================================
   校验 5：账户状态 ZHZT 是否只出现允许码值
   ============================================================ */
SELECT 'CHK_05_CODE_ZHZT' AS check_name,
       ZHZT AS code_value,
       COUNT(*) AS cnt,
       CASE WHEN ZHZT IN ('正常', '预销户', '销户', '冻结', '止付', '其他')
                 OR ZHZT LIKE '其他-%'
            THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
 GROUP BY ZHZT;

/* ============================================================
   校验 6：贷款状态 DKZT 是否只出现允许码值
   ============================================================ */
SELECT 'CHK_06_CODE_DKZT' AS check_name,
       DKZT AS code_value,
       COUNT(*) AS cnt,
       CASE WHEN DKZT IN ('正常', '核销', '转让', '结清', '逾期', '其他')
                 OR DKZT LIKE '其他-%'
            THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
 GROUP BY DKZT;

/* ============================================================
   校验 7：日期格式校验 — FFRQ（发放日期）是否为 YYYYMMDD
   ============================================================ */
SELECT 'CHK_07_DATE_FFRQ' AS check_name,
       COUNT(*) AS bad_format_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND (FFRQ IS NULL
        OR LENGTH(FFRQ) <> 8
        OR FFRQ NOT REGEXP '^[0-9]{8}$');

/* ============================================================
   校验 8：日期格式校验 — XHRQ（销户日期）是否为 YYYYMMDD 或 99991231
   ============================================================ */
SELECT 'CHK_08_DATE_XHRQ' AS check_name,
       COUNT(*) AS bad_format_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND (XHRQ IS NULL
        OR (XHRQ <> '99991231' AND (LENGTH(XHRQ) <> 8 OR XHRQ NOT REGEXP '^[0-9]{8}$')));

/* ============================================================
   校验 9：日期格式校验 — KHRQ（开户日期）是否为 YYYYMMDD 或 99991231
   ============================================================ */
SELECT 'CHK_09_DATE_KHRQ' AS check_name,
       COUNT(*) AS bad_format_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND (KHRQ IS NULL
        OR (KHRQ <> '99991231' AND (LENGTH(KHRQ) <> 8 OR KHRQ NOT REGEXP '^[0-9]{8}$')));

/* ============================================================
   校验 10：CJRQ（采集日期）是否等于跑批日期
   ============================================================ */
SELECT 'CHK_10_CJRQ_MATCH' AS check_name,
       COUNT(*) AS mismatch_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ != @V_DATA_DATE;

/* ============================================================
   校验 11：金额字段 DKJE（贷款金额）是否非负
   ============================================================ */
SELECT 'CHK_11_AMOUNT_DKJE' AS check_name,
       COUNT(*) AS negative_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND DKJE IS NOT NULL
   AND DKJE < 0;

/* ============================================================
   校验 12：金额字段 DKYE（贷款余额）是否非负
   ============================================================ */
SELECT 'CHK_12_AMOUNT_DKYE' AS check_name,
       COUNT(*) AS negative_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND DKYE IS NOT NULL
   AND DKYE < 0;

/* ============================================================
   校验 13：币种 BZ 是否为 3 位字符
   ============================================================ */
SELECT 'CHK_13_CURRENCY_BZ' AS check_name,
       COUNT(*) AS bad_currency_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND (BZ IS NULL OR LENGTH(BZ) != 3);

/* ============================================================
   校验 14：利率 DKLL 是否在合理范围（0~1 之间，即 0%~100%）
   ============================================================ */
SELECT 'CHK_14_RATE_DKLL' AS check_name,
       COUNT(*) AS out_of_range_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND DKLL IS NOT NULL
   AND (DKLL < 0 OR DKLL > 1);

/* ============================================================
   校验 15：源表覆盖检查 — T_6_27（贷款协议补充信息）是否有对应数据
   ============================================================ */
SELECT 'CHK_15_SRC_COVER_T6_27' AS check_name,
       COUNT(*) AS unmatched_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409 tgt
 WHERE NOT EXISTS (
         SELECT 1 FROM T_6_27 src
        WHERE src.F270001 = tgt.XDJJH
          AND src.F270005 = tgt.DKFHZH
          AND src.F270069 = tgt.CJRQ
       );

/* ============================================================
   校验 16：源表覆盖检查 — T_4_3（分户账信息）是否有对应数据
   ============================================================ */
SELECT 'CHK_16_SRC_COVER_T4_3' AS check_name,
       COUNT(*) AS unmatched_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
  FROM IE_004_409 tgt
 WHERE NOT EXISTS (
         SELECT 1 FROM T_4_3 src
        WHERE src.D030002 = tgt.DKFHZH
          AND src.D030015 = tgt.CJRQ
       );

/* ============================================================
   校验 17：涉密标志 SENSITIVEFLAG 是否全为 NULL（预期）
   ============================================================ */
SELECT 'CHK_17_NULL_SENSITIVEFLAG' AS check_name,
       COUNT(*) AS non_null_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS (expected NULL)' ELSE 'UNEXPECTED VALUE' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND SENSITIVEFLAG IS NOT NULL;

/* ============================================================
   校验 18：归属分支机构 GSFZJG 是否全为 NULL（预期）
   ============================================================ */
SELECT 'CHK_18_NULL_GSFZJG' AS check_name,
       COUNT(*) AS non_null_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS (expected NULL)' ELSE 'UNEXPECTED VALUE' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND GSFZJG IS NOT NULL;

/* ============================================================
   校验 19：贷款余额 DKYE 为 NULL 时贷款状态是否已终态（核销/转让/结清）
   ============================================================ */
SELECT 'CHK_19_DKYE_ZERO_FINAL' AS check_name,
       'DKYE=0 when final state' AS check_desc,
       COUNT(*) AS check_count
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND DKYE IS NOT NULL
   AND DKYE = 0
   AND DKZT IN ('核销', '转让', '结清');

/* ============================================================
   校验 20：内部机构号 NBJGH 长度检查（截取后不应为空）
   ============================================================ */
SELECT 'CHK_20_NBJGH_LENGTH' AS check_name,
       COUNT(*) AS empty_nbjgh_count,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'WARN' END AS status
  FROM IE_004_409
 WHERE CJRQ = @V_DATA_DATE
   AND (NBJGH IS NULL OR TRIM(NBJGH) = '');
