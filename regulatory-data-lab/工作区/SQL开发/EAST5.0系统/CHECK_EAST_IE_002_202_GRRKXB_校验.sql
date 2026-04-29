/*
校验目标：
- 验证 PROC_EAST_IE_002_202_GRRKXB 存储过程执行后的数据质量。
- 覆盖行数、主键重复、必填字段、码值、关联缺失和抽样回溯。

依赖：
- PROC_EAST_IE_002_202_GRRKXB_草案.sql
- 目标表：IE_002_202
- 源表：T_3_7（个人客户关系人）、IE_002_201（个人基础信息表）

参数替换说明：
- 执行前将 ${p_data_date} 替换为具体采集日期值，格式 YYYYMMDD。
*/

-- ============================================================
-- 1. 目标行数检查 — 确认目标表当期行数在合理范围
-- ============================================================
SELECT
    '目标行数' AS check_item,
    COUNT(*) AS result_value,
    CASE WHEN COUNT(*) = 0 THEN 'WARN: 目标表无数据，可能源表无当期关系数据'
         ELSE 'PASS' END AS result_flag
FROM IE_002_202
WHERE CJRQ = '${p_data_date}';

-- ============================================================
-- 2. 主键重复检查 — 确认 (GXLX, CJRQ, KHTYBH, GXRZJHM) 无重复
--    PK 定义依据 DDL 字段注释
-- ============================================================
SELECT
    '主键重复' AS check_item,
    COUNT(*) AS duplicate_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS'
         ELSE 'FAIL: 存在重复的 (GXLX, CJRQ, KHTYBH, GXRZJHM)' END AS result_flag
FROM (
    SELECT GXLX, CJRQ, KHTYBH, GXRZJHM, COUNT(*) AS cnt
    FROM IE_002_202
    WHERE CJRQ = '${p_data_date}'
    GROUP BY GXLX, CJRQ, KHTYBH, GXRZJHM
    HAVING COUNT(*) > 1
) t;

-- ============================================================
-- 3. 必填字段为空检查
--    KHTYBH（客户统一编号）按需求不可为空
--    GXLX（关系类型）按 DDL 标注 PK，不可为空
--    GXRZJHM（关系人证件号码）按 DDL 标注 PK
--    GXZT（关系状态）加工字段不应为空
-- ============================================================
SELECT 'KHTYBH为空' AS check_item, COUNT(*) AS null_count
FROM IE_002_202
WHERE CJRQ = '${p_data_date}' AND (KHTYBH IS NULL OR KHTYBH = '')
UNION ALL
SELECT 'GXLX为空' AS check_item, COUNT(*) AS null_count
FROM IE_002_202
WHERE CJRQ = '${p_data_date}' AND (GXLX IS NULL OR GXLX = '')
UNION ALL
SELECT 'GXRZJHM为空' AS check_item, COUNT(*) AS null_count
FROM IE_002_202
WHERE CJRQ = '${p_data_date}' AND (GXRZJHM IS NULL OR GXRZJHM = '')
UNION ALL
SELECT 'GXZT为空' AS check_item, COUNT(*) AS null_count
FROM IE_002_202
WHERE CJRQ = '${p_data_date}' AND GXZT IS NULL;

-- ============================================================
-- 4. 码值越界检查 — 枚举类字段值是否在允许范围内
-- ============================================================
-- GXZT（关系状态）：应为 '有效' 或 '无效'
SELECT 'GXZT码值' AS check_item, GXZT AS value, COUNT(*) AS cnt
FROM IE_002_202
WHERE CJRQ = '${p_data_date}'
GROUP BY GXZT
ORDER BY cnt DESC;

-- GXRZJLB（关系人证件类别）：检查 1999-/2999- 转换是否完成
--    预期：不含以 '1999-' 或 '2999-' 开头的值（应已转为 '其他-XX'）
SELECT 'GXRZJLB_1999残留' AS check_item,
    COUNT(*) AS residual_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS'
         ELSE 'FAIL: 存在未转换的 1999-XX 或 2999-XX 值' END AS result_flag
FROM IE_002_202
WHERE CJRQ = '${p_data_date}'
  AND (GXRZJLB LIKE '1999-%' OR GXRZJLB LIKE '2999-%');

-- GXRZJLB（关系人证件类别）：列出所有码值分布
SELECT 'GXRZJLB分布' AS check_item, GXRZJLB AS value, COUNT(*) AS cnt
FROM IE_002_202
WHERE CJRQ = '${p_data_date}'
GROUP BY GXRZJLB
ORDER BY cnt DESC
LIMIT 20;

-- ============================================================
-- 5. 日期格式检查 — CJRQ(8位)
-- ============================================================
SELECT
    'CJRQ格式' AS check_item,
    COUNT(*) AS bad_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS'
         ELSE 'WARN: 存在非8位日期格式' END AS result_flag
FROM IE_002_202
WHERE CJRQ = '${p_data_date}'
  AND (LENGTH(CJRQ) != 8 OR CJRQ NOT REGEXP '^[0-9]{8}$');

-- ============================================================
-- 6. 关联缺失检查 — IE_002_201 LEFT JOIN 后 JRXKZH 或 NBJGH 为空
--    非致命：机构信息缺失可能导致这些字段为空
-- ============================================================
SELECT
    '机构信息缺失(JRXKZH空)' AS check_item,
    COUNT(*) AS missing_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS'
         ELSE CONCAT('WARN: ', COUNT(*), ' 条记录的金融许可证号为空') END AS result_flag
FROM IE_002_202
WHERE CJRQ = '${p_data_date}'
  AND (JRXKZH IS NULL OR JRXKZH = '')
UNION ALL
SELECT
    '机构信息缺失(NBJGH空)' AS check_item,
    COUNT(*) AS missing_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS'
         ELSE CONCAT('WARN: ', COUNT(*), ' 条记录的内部机构号为空') END AS result_flag
FROM IE_002_202
WHERE CJRQ = '${p_data_date}'
  AND (NBJGH IS NULL OR NBJGH = '')
UNION ALL
SELECT
    '客户信息缺失(KHXM空)' AS check_item,
    COUNT(*) AS missing_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS'
         ELSE CONCAT('WARN: ', COUNT(*), ' 条记录的客户姓名为空') END AS result_flag
FROM IE_002_202
WHERE CJRQ = '${p_data_date}'
  AND (KHXM IS NULL OR KHXM = '');

-- ============================================================
-- 7. 业务规则检查 — 本人为本人担保不应出现
--    (KHTYBH = GXRKHTYBH AND GXLX = '担保')
-- ============================================================
SELECT
    '本人担保检查' AS check_item,
    COUNT(*) AS self_guarantee_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS'
         ELSE 'FAIL: 存在本人为本人担保的关系记录' END AS result_flag
FROM IE_002_202
WHERE CJRQ = '${p_data_date}'
  AND KHTYBH = GXRKHTYBH
  AND GXLX = '担保';

-- ============================================================
-- 8. 源表覆盖检查 — 目标表行数 vs T_3_7 当期有效行数
--    预期：目标行数接近 T_3_7 过滤后行数（剔除了解除和自担保后）
-- ============================================================
SELECT
    '目标表行数' AS metric,
    COUNT(*) AS row_count
FROM IE_002_202 WHERE CJRQ = '${p_data_date}'
UNION ALL
SELECT
    'T_3_7源表当期行数' AS metric,
    COUNT(*) AS row_count
FROM T_3_7
WHERE C070011 = STR_TO_DATE('${p_data_date}', '%Y%m%d')
  AND C070003 IS NOT NULL
  AND TRIM(C070003) != ''
UNION ALL
SELECT
    'T_3_7过滤后(剔除提前解除+自担保)' AS metric,
    COUNT(*) AS row_count
FROM T_3_7
WHERE C070011 = STR_TO_DATE('${p_data_date}', '%Y%m%d')
  AND C070003 IS NOT NULL
  AND TRIM(C070003) != ''
  AND NOT (C070010 IS NOT NULL AND C070010 < DATE_SUB(STR_TO_DATE('${p_data_date}', '%Y%m%d'), INTERVAL 1 DAY))
  AND NOT (C070003 = C070005 AND NULLIF(TRIM(C070004), '') = '担保');

-- ============================================================
-- 9. 抽样回溯 — 随机取 10 条目标记录，回溯源表字段
-- ============================================================
SELECT
    tgt.KHTYBH,
    tgt.KHXM,
    tgt.GXLX,
    tgt.GXRMC,
    tgt.GXRKHTYBH,
    tgt.GXRZJHM,
    tgt.GXZT,
    tgt.CJRQ,
    src.C070003 AS src_person_id,
    src.C070004 AS src_social_rel,
    src.C070005 AS src_rel_id,
    src.C070006 AS src_rel_name,
    src.C070010 AS src_rel_end_date
FROM IE_002_202 tgt
LEFT JOIN T_3_7 src
    ON tgt.KHTYBH = src.C070003
   AND src.C070011 = STR_TO_DATE('${p_data_date}', '%Y%m%d')
WHERE tgt.CJRQ = '${p_data_date}'
ORDER BY RAND()
LIMIT 10;
