/*
校验目标：
- 验证 PROC_IE_002_205_JTKHB 存储过程执行后 IE_002_205 的数据质量。

依赖知识页：
- 原始材料/业务需求/EAST5.0/011_集团客户表.md
- 原始材料/表结构/EAST5.0系统/IE_002_205-集团客户表-DDL-2026-04-28.sql

参数：
- I_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 执行存储过程后，逐项运行以下校验查询。
*/

/* 1. 行数检查：目标表当期数据行数 */
-- 预期：应与符合条件的集团成员记录数一致
SELECT COUNT(*) AS target_row_count
FROM IE_002_205
WHERE CJRQ = '20260430';  -- 替换为实际跑批日期

/* 2. 主键重复检查：JTBH + CYKHTYBH + CJRQ */
-- 预期：应为 0 行（主键不允许重复）
SELECT JTBH, CYKHTYBH, CJRQ, COUNT(*) AS cnt
FROM IE_002_205
WHERE CJRQ = '20260430'  -- 替换为实际跑批日期
GROUP BY JTBH, CYKHTYBH, CJRQ
HAVING COUNT(*) > 1;

/* 3. 必填字段为空检查：集团编号、集团名称、成员客户统一编号、成员名称、采集日期 */
-- 预期：主键和核心标识字段不应为空
SELECT
    COUNT(*) AS null_jtbh_count,
    SUM(CASE WHEN JTMC IS NULL OR TRIM(JTMC) = '' THEN 1 ELSE 0 END) AS null_jtmc_count,
    SUM(CASE WHEN CYKHTYBH IS NULL OR TRIM(CYKHTYBH) = '' THEN 1 ELSE 0 END) AS null_cykhtybh_count,
    SUM(CASE WHEN CYMC IS NULL OR TRIM(CYMC) = '' THEN 1 ELSE 0 END) AS null_cymc_count,
    SUM(CASE WHEN CJRQ IS NULL OR TRIM(CJRQ) = '' THEN 1 ELSE 0 END) AS null_cjrq_count
FROM IE_002_205
WHERE CJRQ = '20260430';  -- 替换为实际跑批日期

/* 4. 采集日期格式检查：应为 YYYYMMDD 8位数字 */
-- 预期：应为 0 行
SELECT COUNT(*) AS invalid_date_format_count
FROM IE_002_205
WHERE CJRQ = '20260430'  -- 替换为实际跑批日期
  AND (CJRQ NOT LIKE '____ __ __' OR CJRQ REGEXP '[^0-9]');

/* 5. 币种码值分布检查：BZ 字段 */
-- 预期：应只出现常见的币种码值（如 CNY、USD、EUR 等）
SELECT BZ, COUNT(*) AS cnt
FROM IE_002_205
WHERE CJRQ = '20260430'  -- 替换为实际跑批日期
  AND BZ IS NOT NULL
GROUP BY BZ
ORDER BY cnt DESC;

/* 6. 集团授信额度方向检查：JTSXED >= JTYYED */
-- 预期：集团已用额度不应超过集团授信额度
SELECT COUNT(*) AS over_limit_count
FROM IE_002_205
WHERE CJRQ = '20260430'  -- 替换为实际跑批日期
  AND JTSXED IS NOT NULL
  AND JTYYED IS NOT NULL
  AND JTYYED > JTSXED;

/* 7. 金额字段空值检查：资产总额、负债总额 */
-- 预期：需要编制合并财务报表的集团客户不允许为空
SELECT
    SUM(CASE WHEN JTZCZE IS NULL THEN 1 ELSE 0 END) AS null_asset_count,
    SUM(CASE WHEN JTFZZE IS NULL THEN 1 ELSE 0 END) AS null_liability_count
FROM IE_002_205
WHERE CJRQ = '20260430';  -- 替换为实际跑批日期

/* 8. 内部机构号来源一致性检查：NBJGH 是否从机构ID第12位截取 */
-- 预期：NBJGH 不应为空（除非源表机构ID不足12位）
SELECT COUNT(*) AS null_nbjgh_count
FROM IE_002_205
WHERE CJRQ = '20260430'  -- 替换为实际跑批日期
  AND NBJGH IS NULL;

/* 9. 源表覆盖检查：确认源表数据是否被完整覆盖 */
-- 检查 T_2_2 中符合条件的集团基本情况记录是否都有对应目标记录
SELECT COUNT(*) AS source_not_mapped_count
FROM T_2_2 grp
WHERE (grp.B020022 IS NULL OR grp.B020022 >= '2026-04-01' AND grp.B020022 <= '2026-04-30')
  AND EXISTS (SELECT 1 FROM T_8_13 wx WHERE wx.H130002 = grp.B020001)
  AND NOT EXISTS (
      SELECT 1 FROM IE_002_205 tgt
      WHERE tgt.JTBH = grp.B020001
        AND tgt.CJRQ = DATE_FORMAT(grp.B020019, '%Y%m%d')
  );

/* 10. 实控人名称来源一致性检查：同一集团的所有成员记录实控人名称应相同 */
-- 预期：同一集团编号下 SKRMC 应一致
SELECT JTBH, COUNT(DISTINCT SKRMC) AS distinct_skrmc_count
FROM IE_002_205
WHERE CJRQ = '20260430'  -- 替换为实际跑批日期
  AND SKRMC IS NOT NULL
GROUP BY JTBH
HAVING COUNT(DISTINCT SKRMC) > 1;

/* 11. 备注字段来源分布检查 */
-- 统计备注有值和无值的记录数
SELECT
    SUM(CASE WHEN BBZ IS NOT NULL AND TRIM(BBZ) <> '' THEN 1 ELSE 0 END) AS has_remark_count,
    SUM(CASE WHEN BBZ IS NULL OR TRIM(BBZ) = '' THEN 1 ELSE 0 END) AS no_remark_count
FROM IE_002_205
WHERE CJRQ = '20260430';  -- 替换为实际跑批日期

/* 12. 金融许可证号映射覆盖率检查 */
-- 检查通过机构ID关联是否成功获取金融许可证号
SELECT
    SUM(CASE WHEN JRXKZH IS NOT NULL THEN 1 ELSE 0 END) AS has_license_count,
    SUM(CASE WHEN JRXKZH IS NULL THEN 1 ELSE 0 END) AS null_license_count
FROM IE_002_205
WHERE CJRQ = '20260430';  -- 替换为实际跑批日期

/* 13. 成员已用额度方向检查：CYYYED 不应为负数 */
-- 预期：已用额度不应出现负值
SELECT COUNT(*) AS negative_limit_count
FROM IE_002_205
WHERE CJRQ = '20260430'  -- 替换为实际跑批日期
  AND CYYYED IS NOT NULL
  AND CYYYED < 0;

/* 14. 抽样回溯检查：随机抽取 5 条记录，人工核对源表数据 */
SELECT
    JTBH,
    CYKHTYBH,
    CJRQ,
    JTMC,
    CYMC,
    SKRMC,
    SKRLX,
    BZ,
    JTZCZE,
    JTFZZE,
    JTSXED,
    JTYYED,
    CYYYED,
    NBJGH,
    JRXKZH,
    YHJGMC
FROM IE_002_205
WHERE CJRQ = '20260430'  -- 替换为实际跑批日期
ORDER BY RAND()
LIMIT 5;
