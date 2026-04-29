/*
校验目标：
- 验证 PROC_EAST_IE_002_201_GRJCBXXB 存储过程执行后的数据质量。
- 覆盖行数、主键、必填字段、码值、日期范围、关联缺失和抽样回溯。

依赖：
- PROC_EAST_IE_002_201_GRJCBXXB_草案.sql
- 目标表：IE_002_201
- 源表：T_2_5（个人客户基本情况）、T_1_1（机构信息）

参数替换说明：
- 执行前将 ${I_DATE} 替换为具体采集日期值，格式 YYYYMMDD。
*/

-- ============================================================
-- 1. 目标行数检查 — 确认目标表当期行数在合理范围
-- ============================================================
SELECT
    '目标行数' AS check_item,
    COUNT(*) AS result_value,
    CASE WHEN COUNT(*) = 0 THEN 'WARN: 目标表无数据，可能源表无当期有效客户'
         ELSE 'PASS' END AS result_flag
FROM IE_002_201
WHERE CJRQ = '${I_DATE}';

-- ============================================================
-- 2. 主键重复检查 — 确认 (KHTYBH, CJRQ) 无重复
-- ============================================================
SELECT
    '主键重复' AS check_item,
    COUNT(*) AS duplicate_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS'
         ELSE 'FAIL: 存在重复的 (KHTYBH, CJRQ)' END AS result_flag
FROM (
    SELECT KHTYBH, CJRQ, COUNT(*) AS cnt
    FROM IE_002_201
    WHERE CJRQ = '${I_DATE}'
    GROUP BY KHTYBH, CJRQ
    HAVING COUNT(*) > 1
) t;

-- ============================================================
-- 3. 必填字段为空检查
--    出生年月 CSNY、性别 XB 按 DDL 注释不可为空
-- ============================================================
SELECT 'CSNY为空' AS check_item, COUNT(*) AS null_count
FROM IE_002_201
WHERE CJRQ = '${I_DATE}' AND (CSNY IS NULL OR CSNY = '')
UNION ALL
SELECT 'XB为空' AS check_item, COUNT(*) AS null_count
FROM IE_002_201
WHERE CJRQ = '${I_DATE}' AND (XB IS NULL OR XB = '');

-- ============================================================
-- 4. 码值越界检查 — 枚举类字段值是否在允许范围内
-- ============================================================
-- 性别 XB: 应为 '男' 或 '女'
SELECT 'XB码值' AS check_item, XB AS value, COUNT(*) AS cnt
FROM IE_002_201
WHERE CJRQ = '${I_DATE}'
GROUP BY XB
ORDER BY cnt DESC;

-- 是否已婚 SFYH: 应为 '是'、'否' 或 NULL
SELECT 'SFYH码值' AS check_item, SFYH AS value, COUNT(*) AS cnt
FROM IE_002_201
WHERE CJRQ = '${I_DATE}'
GROUP BY SFYH
ORDER BY cnt DESC;

-- 是否农户 SFNH: 应为 '是'、'否' 或 NULL
SELECT 'SFNH码值' AS check_item, SFNH AS value, COUNT(*) AS cnt
FROM IE_002_201
WHERE CJRQ = '${I_DATE}'
GROUP BY SFNH
ORDER BY cnt DESC;

-- 本行员工标志 BHYGBZ: 应为 '是'、'否' 或 NULL
SELECT 'BHYGBZ码值' AS check_item, BHYGBZ AS value, COUNT(*) AS cnt
FROM IE_002_201
WHERE CJRQ = '${I_DATE}'
GROUP BY BHYGBZ
ORDER BY cnt DESC;

-- 上黑名单标志 SHMDBZ: 应为 '是'、'否' 或 NULL
SELECT 'SHMDBZ码值' AS check_item, SHMDBZ AS value, COUNT(*) AS cnt
FROM IE_002_201
WHERE CJRQ = '${I_DATE}'
GROUP BY SHMDBZ
ORDER BY cnt DESC;

-- 信贷客户标志 XDKHBZ: 应为 '是' 或 '否'
SELECT 'XDKHBZ码值' AS check_item, XDKHBZ AS value, COUNT(*) AS cnt
FROM IE_002_201
WHERE CJRQ = '${I_DATE}'
GROUP BY XDKHBZ
ORDER BY cnt DESC;

-- ============================================================
-- 5. 日期格式检查 — CSNY(6位), SHMDRQ(8位), SCJLXDGXNY(6位)
-- ============================================================
SELECT
    'CSNY格式' AS check_item,
    COUNT(*) AS bad_count
FROM IE_002_201
WHERE CJRQ = '${I_DATE}'
  AND CSNY IS NOT NULL
  AND (LENGTH(CSNY) != 6 OR CSNY NOT REGEXP '^[0-9]{6}$');

SELECT
    'SHMDRQ格式' AS check_item,
    COUNT(*) AS bad_count
FROM IE_002_201
WHERE CJRQ = '${I_DATE}'
  AND SHMDRQ IS NOT NULL
  AND (LENGTH(SHMDRQ) != 8 OR SHMDRQ NOT REGEXP '^[0-9]{8}$');

-- ============================================================
-- 6. 关联缺失检查 — 机构信息 LEFT JOIN 后金融许可证号或银行机构名称为空
-- ============================================================
SELECT
    '机构信息缺失' AS check_item,
    COUNT(*) AS missing_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS'
         ELSE 'WARN: 部分客户未能关联到机构信息' END AS result_flag
FROM IE_002_201
WHERE CJRQ = '${I_DATE}'
  AND (JRXKZH IS NULL OR JRXKZH = '' OR YHJGMC IS NULL OR YHJGMC = '');

-- ============================================================
-- 7. 客户范围覆盖检查 — 目标表客户数 vs 源表T_2_5当期去重客户数
--    预期：目标客户数 <= cust_scope 范围数 <= T_2_5当期去重客户数
-- ============================================================
SELECT
    '目标表客户数' AS metric,
    COUNT(DISTINCT KHTYBH) AS count
FROM IE_002_201 WHERE CJRQ = '${I_DATE}'
UNION ALL
SELECT
    'T_2_5源表去重客户数' AS metric,
    COUNT(DISTINCT B050001) AS count
FROM T_2_5 WHERE B050036 = STR_TO_DATE('${I_DATE}', '%Y%m%d');

-- ============================================================
-- 8. 抽样回溯 — 随机取 10 条目标记录，回溯源表字段
-- ============================================================
SELECT
    tgt.KHTYBH,
    tgt.KHXM,
    tgt.ZJLB,
    tgt.CSNY,
    tgt.XB,
    src.B050001 AS src_cust_id,
    src.B050003 AS src_cust_name,
    src.B050005 AS src_idcard,
    src.B050012 AS src_birth
FROM IE_002_201 tgt
LEFT JOIN T_2_5 src
    ON tgt.KHTYBH = src.B050001
   AND src.B050036 = STR_TO_DATE('${I_DATE}', '%Y%m%d')
WHERE tgt.CJRQ = '${I_DATE}'
ORDER BY RAND()
LIMIT 10;
