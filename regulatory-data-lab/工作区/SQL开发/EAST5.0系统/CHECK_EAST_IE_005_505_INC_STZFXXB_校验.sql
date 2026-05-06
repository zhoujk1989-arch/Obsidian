/*
校验脚本：PROC_EAST_IE_005_505_INC_STZFXXB 存储过程产出校验
目标表：IE_005_505_INC（受托支付信息表）
参数：P_DATA_DATE = '20260501'（按需修改）

校验项：
1. 采集日期行数
2. 主键重复（XDJJH + STZFDXZH + CJRQ）
3. 内部机构号 NBJGH 非空
4. 受托支付日期 STZFRQ 格式校验（YYYYMMDD 或默认值 99991231）
5. 采集日期 CJRQ 格式校验（YYYYMMDD）
6. 金额字段非负
7. 金融许可证号关联缺失（LEFT JOIN T_1_1 未匹配）
8. 贷款金额关联缺失（LEFT JOIN T_6_27 未匹配）
9. 受托支付金额非空检查
10. 备注字段长度超限

运行方式：在 GBase 或 MySQL 环境中执行，参数 P_CHECK_DATE 按需修改。
*/

-- ============================================================
-- 校验项 1：采集日期行数
-- ============================================================
SELECT 'CHK_01_ROW_COUNT' AS check_id,
       COUNT(*) AS actual_rows,
       COUNT(CASE WHEN CJRQ = '20260501' THEN 1 END) AS target_date_rows
  FROM IE_005_505_INC;

-- ============================================================
-- 校验项 2：主键重复（XDJJH + STZFDXZH + CJRQ）
-- ============================================================
SELECT 'CHK_02_PK_DUPLICATE' AS check_id,
       COUNT(*) AS duplicate_groups,
       SUM(CASE WHEN cnt > 1 THEN cnt ELSE 0 END) AS duplicate_rows
  FROM (
    SELECT XDJJH, STZFDXZH, CJRQ, COUNT(*) AS cnt
      FROM IE_005_505_INC
     WHERE CJRQ = '20260501'
     GROUP BY XDJJH, STZFDXZH, CJRQ
  ) pk_grp
 WHERE cnt > 1;

-- ============================================================
-- 校验项 3：内部机构号 NBJGH 非空检查
-- ============================================================
SELECT 'CHK_03_NBJGH_NOT_NULL' AS check_id,
       COUNT(*) AS null_nbjgh_count
  FROM IE_005_505_INC
 WHERE CJRQ = '20260501'
   AND (NBJGH IS NULL OR TRIM(NBJGH) = '');

-- ============================================================
-- 校验项 4：受托支付日期 STZFRQ 格式校验
-- ============================================================
SELECT 'CHK_04_STZFRQ_FORMAT' AS check_id,
       COUNT(*) AS invalid_format_count
  FROM IE_005_505_INC
 WHERE CJRQ = '20260501'
   AND STZFRQ IS NOT NULL
   AND STZFRQ <> '99991231'
   AND STZFRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================================
-- 校验项 5：采集日期 CJRQ 格式校验
-- ============================================================
SELECT 'CHK_05_CJRQ_FORMAT' AS check_id,
       COUNT(*) AS invalid_cjrq_count
  FROM IE_005_505_INC
 WHERE CJRQ IS NOT NULL
   AND CJRQ <> '20260501'
   AND CJRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================================
-- 校验项 6：金额字段非负检查（STZFJE、DKJE）
-- ============================================================
SELECT 'CHK_06_AMOUNT_NEGATIVE' AS check_id,
       COUNT(CASE WHEN STZFJE < 0 THEN 1 END) AS negative_stzje_count,
       COUNT(CASE WHEN DKJE < 0 THEN 1 END) AS negative_dkje_count
  FROM IE_005_505_INC
 WHERE CJRQ = '20260501';

-- ============================================================
-- 校验项 7：金融许可证号关联缺失（T_1_1 LEFT JOIN 未匹配）
-- ============================================================
SELECT 'CHK_07_JRXKZH_MISSING' AS check_id,
       COUNT(*) AS null_jrxkzh_count
  FROM IE_005_505_INC i
  JOIN T_6_6 src ON src.F060002 = i.XDJJH
   AND src.F060010 = CAST(i.CJRQ AS DATE)
 WHERE i.CJRQ = '20260501'
   AND (i.JRXKZH IS NULL OR TRIM(i.JRXKZH) = '')
   AND EXISTS (
     SELECT 1 FROM T_1_1 org
      WHERE TRIM(org.A010001) = TRIM(src.F060011)
   );

-- ============================================================
-- 校验项 8：贷款金额关联缺失（T_6_27 LEFT JOIN 未匹配）
-- ============================================================
SELECT 'CHK_08_DKJE_MISSING' AS check_id,
       COUNT(*) AS null_dkje_count
  FROM IE_005_505_INC i
  JOIN T_6_6 src ON src.F060002 = i.XDJJH
   AND src.F060010 = CAST(i.CJRQ AS DATE)
 WHERE i.CJRQ = '20260501'
   AND (i.DKJE IS NULL OR i.DKJE = 0)
   AND EXISTS (
     SELECT 1 FROM T_6_27 extra
      WHERE TRIM(extra.F270001) = TRIM(src.F060002)
   );

-- ============================================================
-- 校验项 9：受托支付金额非空检查（业务关键字段）
-- ============================================================
SELECT 'CHK_09_STZFJE_NOT_NULL' AS check_id,
       COUNT(*) AS null_stzje_count
  FROM IE_005_505_INC
 WHERE CJRQ = '20260501'
   AND (STZFJE IS NULL OR STZFJE = 0);

-- ============================================================
-- 校验项 10：备注字段长度超限（DDL 定义 VARCHAR(600)）
-- ============================================================
SELECT 'CHK_10_BBZ_LENGTH' AS check_id,
       COUNT(*) AS bbz_over_limit_count,
       MAX(CHAR_LENGTH(BBZ)) AS max_bbz_length
  FROM IE_005_505_INC
 WHERE CJRQ = '20260501'
   AND CHAR_LENGTH(BBZ) > 600;

-- ============================================================
-- 校验项 11：源表到目标表抽样追溯（验证 JOIN 正确性）
-- ============================================================
SELECT 'CHK_11_SOURCE_TRACEBACK' AS check_id,
       src.F060002 AS sample_xdjjh,
       src.F060003 AS sample_src_stzje,
       i.STZFJE AS sample_tgt_stzje,
       src.F060011 AS sample_src_org_id,
       i.NBJGH AS sample_tgt_nbjgh,
       s1.A010003 AS sample_src_jrxkzh,
       i.JRXKZH AS sample_tgt_jrxkzh
  FROM T_6_6 src
  LEFT JOIN IE_005_505_INC i
    ON src.F060002 = i.XDJJH
   AND src.F060005 = i.STZFDXZH
   AND i.CJRQ = '20260501'
  LEFT JOIN T_1_1 s1
    ON TRIM(src.F060011) = TRIM(s1.A010001)
 WHERE src.F060010 = CAST('20260501' AS DATE)
 LIMIT 20;

-- ============================================================
-- 校验项 12：DELETE/INSERT 范围一致性（重跑后验证）
-- ============================================================
SELECT 'CHK_12_DELETE_INSERT_SCOPE' AS check_id,
       COUNT(*) AS remaining_other_date_rows
  FROM IE_005_505_INC
 WHERE CJRQ <> '20260501';
