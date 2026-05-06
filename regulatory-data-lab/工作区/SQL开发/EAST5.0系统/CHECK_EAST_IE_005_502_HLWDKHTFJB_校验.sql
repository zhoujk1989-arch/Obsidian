/*
校验目标：EAST5.0 互联网贷款合同附加表（IE_005_502）GBase 存储过程草案运行后检查。
对应过程：PROC_EAST_IE_005_502_HLWDKHTFJB
参数：P_DATA_DATE，格式 YYYYMMDD。
*/

-- 1. 当期行数检查
SELECT COUNT(*) AS target_count
  FROM IE_005_502
 WHERE CJRQ = ?;

-- 2. 主键/核心键重复检查（依据 DDL 注释中的 PK 字段）
SELECT XDHTH, CJRQ, HZXYBH, COUNT(*) AS dup_cnt
  FROM IE_005_502
 WHERE CJRQ = ?
 GROUP BY XDHTH, CJRQ, HZXYBH
HAVING COUNT(*) > 1;

-- 3. PK 字段为空检查
SELECT COUNT(*) AS null_pk_count
  FROM IE_005_502
 WHERE CJRQ = ?
   AND (XDHTH IS NULL OR CJRQ IS NULL OR HZXYBH IS NULL);

-- 4. 采集日期格式检查
SELECT CJRQ, COUNT(*) AS cnt
  FROM IE_005_502
 WHERE CJRQ IS NULL OR LENGTH(CJRQ) <> 8
    OR CJRQ NOT REGEXP '^[0-9]{8}$'
 GROUP BY CJRQ;

-- 5. 授权生效日期格式和默认值检查
SELECT SXRQ, COUNT(*) AS cnt
  FROM IE_005_502
 WHERE SXRQ IS NULL
    OR LENGTH(SXRQ) <> 8
    OR (SXRQ <> '99991231' AND SXRQ <> '00000000' AND SXRQ NOT REGEXP '^[0-9]{8}$')
 GROUP BY SXRQ;

-- 6. 授权终止日期格式和默认值检查
SELECT ZZRQ, COUNT(*) AS cnt
  FROM IE_005_502
 WHERE ZZRQ IS NULL
    OR LENGTH(ZZRQ) <> 8
    OR (ZZRQ <> '99991231' AND ZZRQ <> '00000000' AND ZZRQ NOT REGEXP '^[0-9]{8}$')
 GROUP BY ZZRQ;

-- 7. 业务模式码值检查：只允许'独立'或'合作'
SELECT YWMS, COUNT(*) AS cnt
  FROM IE_005_502
 WHERE CJRQ = ?
   AND YWMS NOT IN ('独立', '合作')
 GROUP BY YWMS;

-- 8. 合同状态码值检查：确认码值转换结果
SELECT HTZT, COUNT(*) AS cnt
  FROM IE_005_502
 WHERE CJRQ = ?
 GROUP BY HTZT;

-- 9. 合作协议编号空值检查：不允许为 NULL，应已转为'无'
SELECT COUNT(*) AS null_hzxybh_count
  FROM IE_005_502
 WHERE CJRQ = ?
   AND HZXYBH IS NULL;

-- 10. 备注拼接检查：确认备注字段存在（来自 T_6_4 或 T_6_2）
SELECT COUNT(*) AS empty_bbz_count
  FROM IE_005_502
 WHERE CJRQ = ?
   AND BBZ IS NULL;

-- 11. 内部机构号截取检查：确认截取后非空
SELECT COUNT(*) AS null_nbjgh_count
  FROM IE_005_502
 WHERE CJRQ = ?
   AND NBJGH IS NULL;

-- 12. 合作方责任金额格式检查
SELECT HZFZRJE, COUNT(*) AS cnt
  FROM IE_005_502
 WHERE CJRQ = ?
   AND HZFZRJE IS NOT NULL
 GROUP BY HZFZRJE
LIMIT 20;

-- 13. 字段映射抽样回溯：
--    按 XDHTH（信贷合同号）抽样，核对源字段与目标字段。
--    请将 ? 替换为实际采集日期，并手动比对返回结果。
SELECT
    ie.XDHTH,
    ie.NBJGH,
    ie.YWMS,
    ie.HZXYBH,
    ie.SXRQ,
    ie.ZZRQ,
    ie.HTZT,
    ie.BZ,
    ie.BBZ,
    ie.YHJGMC,
    ie.JRXKZH
  FROM IE_005_502 ie
 WHERE ie.CJRQ = ?
 ORDER BY ie.XDHTH
 LIMIT 20;

-- 14. 重跑幂等检查：连续执行两次存储过程后，行数应一致
--    执行方式：先执行 PROC_EAST_IE_005_502_HLWDKHTFJB('20260101')，
--    再执行一次，然后对比：
--    SELECT COUNT(*) FROM IE_005_502 WHERE CJRQ = '20260101';
