/*
校验目标：EAST5.0 内部分户账（IE_004_407）GBase 存储过程草案运行后检查。
对应过程：PROC_EAST_IE_004_407_NBFHZ
参数：P_DATA_DATE，格式 YYYYMMDD。
*/

-- 1. 当期行数检查
SELECT COUNT(*) AS target_count
  FROM IE_004_407
 WHERE CJRQ = ?;

-- 2. 主键重复检查（依据 DDL 注释中的 PK：NBFHZZH + BZ + CJRQ）
SELECT NBFHZZH, BZ, CJRQ, COUNT(*) AS dup_cnt
  FROM IE_004_407
 WHERE CJRQ = ?
 GROUP BY NBFHZZH, BZ, CJRQ
HAVING COUNT(*) > 1;

-- 3. PK 字段为空检查
SELECT COUNT(*) AS null_pk_count
  FROM IE_004_407
 WHERE CJRQ = ?
   AND (NBFHZZH IS NULL OR BZ IS NULL OR CJRQ IS NULL);

-- 4. 采集日期格式检查
SELECT CJRQ, COUNT(*) AS cnt
  FROM IE_004_407
 WHERE CJRQ IS NULL OR LENGTH(CJRQ) <> 8 OR CJRQ NOT REGEXP '^[0-9]{8}$'
 GROUP BY CJRQ;

-- 5. 分户账类型过滤验证：所有记录的 NBJGH 来源应来自 D030005='03' 的记录
-- 无法直接校验，需通过源表抽样确认

-- 6. 账户状态码值分布检查
SELECT ZHZT, COUNT(*) AS cnt
  FROM IE_004_407
 WHERE CJRQ = ?
 GROUP BY ZHZT
 ORDER BY cnt DESC;
-- 期望码值：正常、预销户、销户、冻结、止付、其他-XX、或原始值

-- 7. 计息方式码值分布检查
SELECT JXFS, COUNT(*) AS cnt
  FROM IE_004_407
 WHERE CJRQ = ?
 GROUP BY JXFS
 ORDER BY cnt DESC;
-- 期望码值：按月结息、按季结息、按半年结息、按年结息、不定期结息、不记利息、利随本清、其他-XX、或原始值

-- 8. 计息标志码值分布检查
SELECT JXBZ, COUNT(*) AS cnt
  FROM IE_004_407
 WHERE CJRQ = ?
 GROUP BY JXBZ
 ORDER BY cnt DESC;
-- 期望码值：是、否、''

-- 9. 借贷标志码值分布检查
SELECT JDBZ, COUNT(*) AS cnt
  FROM IE_004_407
 WHERE CJRQ = ?
 GROUP BY JDBZ
 ORDER BY cnt DESC;
-- 期望码值：借、贷、借贷并列、''

-- 10. 开户日期格式检查
SELECT KHRQ, COUNT(*) AS cnt
  FROM IE_004_407
 WHERE CJRQ = ?
   AND (KHRQ IS NULL OR LENGTH(KHRQ) <> 8 OR KHRQ NOT REGEXP '^[0-9]{8}$')
 GROUP BY KHRQ;

-- 11. 销户日期格式检查
SELECT XHRQ, COUNT(*) AS cnt
  FROM IE_004_407
 WHERE CJRQ = ?
   AND (XHRQ IS NULL OR LENGTH(XHRQ) <> 8 OR XHRQ NOT REGEXP '^[0-9]{8}$')
 GROUP BY XHRQ;

-- 12. 利率非负检查
SELECT COUNT(*) AS negative_rate_count
  FROM IE_004_407
 WHERE CJRQ = ?
   AND LL IS NOT NULL
   AND LL < 0;

-- 13. 余额非负检查（借方/贷方余额不应为负）
SELECT COUNT(*) AS negative_balance_count
  FROM IE_004_407
 WHERE CJRQ = ?
   AND (JFYE < 0 OR DFYE < 0);

-- 14. 缺口字段来源检查：GSFZJG 和 SENSITIVEFLAG 应为 NULL
SELECT COUNT(*) AS gap_field_null_count
  FROM IE_004_407
 WHERE CJRQ = ?
   AND (GSFZJG IS NOT NULL OR SENSITIVEFLAG IS NOT NULL);
-- 期望：0（两个缺口字段应全部为 NULL）

-- 15. 销户账户的销户日期检查：账户状态为"销户"的记录，XHRQ 应不为默认值
SELECT ZHZT, XHRQ, COUNT(*) AS cnt
  FROM IE_004_407
 WHERE CJRQ = ?
   AND ZHZT = '销户'
 GROUP BY ZHZT, XHRQ;

-- 16. 源表抽样回溯：按主键抽样核对源字段与目标字段
-- TODO: 按 NBFHZZH+BZ+CJRQ 抽样，与 T_4_3、T_1_1、T_4_2 源字段逐项比对
