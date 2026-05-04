/*
校验目标：EAST5.0 汇率信息表（IE_010_1001_INC）GBase 存储过程草案运行后检查。
对应过程：PROC_EAST_IE_010_1001_INC_HLXXB
参数：P_DATA_DATE，格式 YYYYMMDD。
*/

-- 1. 当期行数检查
SELECT COUNT(*) AS target_count
  FROM IE_010_1001_INC
 WHERE CJRQ = ?;

-- 2. 主键/核心键重复检查（依据 DDL 注释中的 PK 字段）
SELECT HLRQ, CJRQ, WBBZ, BBBZ, COUNT(*) AS dup_cnt
  FROM IE_010_1001_INC
 WHERE CJRQ = ?
 GROUP BY HLRQ, CJRQ, WBBZ, BBBZ
HAVING COUNT(*) > 1;

-- 3. PK 字段为空检查
SELECT COUNT(*) AS null_pk_count
  FROM IE_010_1001_INC
 WHERE CJRQ = ?
   AND (HLRQ IS NULL OR CJRQ IS NULL OR WBBZ IS NULL OR BBBZ IS NULL);

-- 4. 采集日期格式检查
SELECT CJRQ, COUNT(*) AS cnt
  FROM IE_010_1001_INC
 WHERE CJRQ IS NULL OR LENGTH(CJRQ) <> 8
 GROUP BY CJRQ;

-- 5. 字段映射抽样回溯
-- TODO: 按存储过程中的来源表和业务键抽样核对源字段、目标字段和码值转换。
