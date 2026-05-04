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
 GROUP BY CJRQ;

-- 5. 字段映射抽样回溯
-- TODO: 按存储过程中的来源表和业务键抽样核对源字段、目标字段和码值转换。
