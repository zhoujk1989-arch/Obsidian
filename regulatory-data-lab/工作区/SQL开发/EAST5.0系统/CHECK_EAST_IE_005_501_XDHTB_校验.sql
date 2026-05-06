/*
校验目标：EAST5.0 信贷合同表（IE_005_501）GBase 存储过程草案运行后检查。
对应过程：PROC_EAST_IE_005_501_XDHTB
参数：P_DATA_DATE，格式 YYYYMMDD。
*/

-- 1. 当期行数检查
SELECT COUNT(*) AS target_count
  FROM IE_005_501
 WHERE CJRQ = ?;

-- 2. 主键/核心键重复检查（依据 DDL 注释中的 PK 字段：XDHTH + CJRQ）
SELECT XDHTH, CJRQ, COUNT(*) AS dup_cnt
  FROM IE_005_501
 WHERE CJRQ = ?
 GROUP BY XDHTH, CJRQ
HAVING COUNT(*) > 1;

-- 3. PK 字段为空检查
SELECT COUNT(*) AS null_pk_count
  FROM IE_005_501
 WHERE CJRQ = ?
   AND (XDHTH IS NULL OR CJRQ IS NULL);

-- 4. 采集日期格式检查
SELECT CJRQ, COUNT(*) AS cnt
  FROM IE_005_501
 WHERE CJRQ IS NULL OR LENGTH(CJRQ) <> 8
 GROUP BY CJRQ;

-- 5. 合同到期日期格式检查（应为 YYYYMMDD 或 99991231）
SELECT HTDQRQ, COUNT(*) AS cnt
  FROM IE_005_501
 WHERE CJRQ = ?
   AND (HTDQRQ IS NULL OR LENGTH(HTDQRQ) <> 8 OR HTDQRQ NOT LIKE '________')
 GROUP BY HTDQRQ;

-- 6. 合同起始日期格式检查（应为 YYYYMMDD 或 99991231）
SELECT HTQSRQ, COUNT(*) AS cnt
  FROM IE_005_501
 WHERE CJRQ = ?
   AND (HTQSRQ IS NULL OR LENGTH(HTQSRQ) <> 8 OR HTQSRQ NOT LIKE '________')
 GROUP BY HTQSRQ;

-- 7. 信贷业务种类码值检查（XDWZL 应在映射后的允许码值范围内）
SELECT XDYWZL, COUNT(*) AS cnt
  FROM IE_005_501
 WHERE CJRQ = ?
   AND XDYWZL NOT IN (
       '流动资金贷款', '法人账户透支', '项目贷款', '项目贷款（银团）',
       '一般固定资产贷款', '住房按揭贷款', '个人经营性贷款', '商用房贷款',
       '汽车贷款', '助学贷款', '消费贷款', '票据贴现', '买断式转贴现',
       '贸易融资业务', '融资租赁业务', '垫款', '委托贷款',
       LIKE '其他-%', XDYWZL
   )
   AND XDYWZL NOT LIKE '其他-%'
 GROUP BY XDYWZL;

-- 8. 合同状态码值检查（HTZT 应在映射后的允许码值范围内）
SELECT HTZT, COUNT(*) AS cnt
  FROM IE_005_501
 WHERE CJRQ = ?
   AND HTZT NOT IN ('有效', '未生效', '其他-中止', '终结', '撤销', '其他-无效')
   AND HTZT NOT LIKE '其他-%'
 GROUP BY HTZT;

-- 9. 担保类型码值检查（DBLX 应在映射后的允许码值范围内）
SELECT DBLX, COUNT(*) AS cnt
  FROM IE_005_501
 WHERE CJRQ = ?
   AND DBLX NOT IN ('质押', '抵押', '保证', '信用', '混合')
   AND DBLX NOT LIKE '其他-%'
 GROUP BY DBLX;

-- 10. 合同金额非负检查
SELECT HTJE, COUNT(*) AS cnt
  FROM IE_005_501
 WHERE CJRQ = ?
   AND HTJE IS NOT NULL AND HTJE < 0
 GROUP BY HTJE;

-- 11. 币种长度检查（BZ 应为 3 字符）
SELECT BZ, COUNT(*) AS cnt
  FROM IE_005_501
 WHERE CJRQ = ?
   AND (BZ IS NULL OR LENGTH(BZ) <> 3)
 GROUP BY BZ;

-- 12. 内部机构号长度检查（NBJGH 截取后不应为空）
SELECT COUNT(*) AS empty_nbjgh_count
  FROM IE_005_501
 WHERE CJRQ = ?
   AND NBJGH IS NULL OR NBJGH = '';

-- 13. 缺口字段 NULL 检查（GSFZJG/SENSITIVEFLAG/KHLB 应为 NULL）
SELECT
    COUNT(*) AS total_count,
    COUNT(GSFZJG) AS gsfzjg_non_null,
    COUNT(SENSITIVEFLAG) AS sensitive_non_null,
    COUNT(KHLB) AS khlb_non_null
  FROM IE_005_501
 WHERE CJRQ = ?;

-- 14. 客户名称 NULL 检查（KHMC 暂为 NULL 赋值）
SELECT COUNT(*) AS khmc_null_count
  FROM IE_005_501
 WHERE CJRQ = ?
   AND KHMC IS NULL;

-- 15. 源表覆盖检查（确认 T_6_2 和 T_1_1 均有数据产出）
SELECT COUNT(DISTINCT s1.F020002) AS distinct_org_count
  FROM T_6_2 s1
 WHERE s1.F020063 = ?;

-- 16. 金融许可证号覆盖率检查
SELECT
    COUNT(*) AS total_count,
    COUNT(JRXKZH) AS jrxkzh_non_null,
    CAST(COUNT(JRXKZH) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS jrxkzh_coverage_pct
  FROM IE_005_501
 WHERE CJRQ = ?;

-- 17. 合同名称非空检查（DDL 注释标注为必填项）
SELECT COUNT(*) AS null_htmc_count
  FROM IE_005_501
 WHERE CJRQ = ?
   AND (HTMC IS NULL OR TRIM(HTMC) = '');

-- 18. 源表抽样回溯
-- TODO: 按协议ID（F020001）+ 采集日期抽样核对源字段、目标字段和码值转换。
