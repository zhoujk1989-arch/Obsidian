/*
校验目标：
- 验证 PROC_EAST_IE_001_103 生成的 IE_001_103 柜员表数据质量。

依赖知识页：
- [[来源-EAST5.0系统-IE_001_103-柜员表]]
- [[数据表-IE_001_103-柜员表-EAST5.0系统]]

参数：
- p_data_date：采集日期，格式 YYYYMMDD。
*/

-- ============================================
-- 校验 1：目标行数是否符合业务范围
-- ============================================
-- 预期：IE_001_103 行数应等于 T_1_7 中采集日期=p_data_date 且 (柜员状态=01 或 失效日期>=当月月初) 的记录数
SELECT
    'CHK_ROW_COUNT' AS check_name,
    (SELECT COUNT(*) FROM IE_001_103 WHERE CJRQ = '20260428') AS target_rows,
    (SELECT COUNT(*) FROM T_1_7
     WHERE A070011 = '2026-04-28'
       AND (A070008 = '01' OR A070009 >= '2026-04-01')) AS source_rows,
    CASE
        WHEN (SELECT COUNT(*) FROM IE_001_103 WHERE CJRQ = '20260428')
           = (SELECT COUNT(*) FROM T_1_7
              WHERE A070011 = '2026-04-28'
                AND (A070008 = '01' OR A070009 >= '2026-04-01'))
        THEN 'PASS' ELSE 'FAIL'
    END AS result;

-- ============================================
-- 校验 2：主键重复检查
-- ============================================
-- IE_001_103 主键：CJRQ + GYH + NBJGH
SELECT
    'CHK_PK_DUPLICATE' AS check_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT CJRQ, GYH, NBJGH, COUNT(*) AS cnt
    FROM IE_001_103
    WHERE CJRQ = '20260428'
    GROUP BY CJRQ, GYH, NBJGH
    HAVING cnt > 1
) dup;

-- ============================================
-- 校验 3：必填字段为空检查
-- ============================================
-- 柜员号(GYH) 和 采集日期(CJRQ) 根据 DDL 注释为必填（PK）
SELECT
    'CHK_REQUIRED_FIELDS' AS check_name,
    SUM(CASE WHEN GYH IS NULL OR GYH = '' THEN 1 ELSE 0 END) AS null_gyh_count,
    SUM(CASE WHEN CJRQ IS NULL OR CJRQ = '' THEN 1 ELSE 0 END) AS null_cjrq_count,
    SUM(CASE WHEN NBJGH IS NULL OR NBJGH = '' THEN 1 ELSE 0 END) AS null_nbjgh_count
FROM IE_001_103
WHERE CJRQ = '20260428';

-- ============================================
-- 校验 4：码值越界检查 - 是否实体柜员(SFSTGY)
-- ============================================
-- 允许值：'是'、'否'、NULL
SELECT
    'CHK_SFSTGY_CODE' AS check_name,
    SFSTGY,
    COUNT(*) AS cnt
FROM IE_001_103
WHERE CJRQ = '20260428'
GROUP BY SFSTGY;

-- ============================================
-- 校验 5：码值越界检查 - 柜员权限级别(GYQXJB)
-- ============================================
-- 允许值：'高柜'、'低柜'、'其他-***'、NULL
SELECT
    'CHK_GYQXJB_CODE' AS check_name,
    GYQXJB,
    COUNT(*) AS cnt
FROM IE_001_103
WHERE CJRQ = '20260428'
GROUP BY GYQXJB;

-- ============================================
-- 校验 6：码值越界检查 - 柜员状态(GYZT)
-- ============================================
-- 允许值：'在岗'、'离岗'、'其他-***'、NULL
SELECT
    'CHK_GYZT_CODE' AS check_name,
    GYZT,
    COUNT(*) AS cnt
FROM IE_001_103
WHERE CJRQ = '20260428'
GROUP BY GYZT;

-- ============================================
-- 校验 7：日期格式检查 - 采集日期(CJRQ)
-- ============================================
-- 应为 8 位数字字符串 YYYYMMDD
SELECT
    'CHK_CJRQ_FORMAT' AS check_name,
    COUNT(*) AS invalid_format_count
FROM IE_001_103
WHERE CJRQ IS NOT NULL
  AND CJRQ != ''
  AND CJRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================
-- 校验 8：日期格式检查 - 上岗日期(SGRQ)
-- ============================================
-- 应为 8 位数字字符串 YYYYMMDD 或 NULL
SELECT
    'CHK_SGRQ_FORMAT' AS check_name,
    COUNT(*) AS invalid_format_count
FROM IE_001_103
WHERE SGRQ IS NOT NULL
  AND SGRQ != ''
  AND SGRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================
-- 校验 9：内部机构号格式检查 - 来源一致性
-- ============================================
-- 内部机构号应由柜员表.机构ID 第12位截取，抽查验证
SELECT
    'CHK_NBJGH_SOURCE' AS check_name,
    t.A070001 AS source_org_id,
    i.NBJGH AS derived_nbjgh,
    SUBSTRING(t.A070001, 12) AS expected_nbjgh,
    CASE
        WHEN SUBSTRING(t.A070001, 12) = i.NBJGH THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS match_status
FROM IE_001_103 i
JOIN T_1_7 t ON t.A070002 = i.GYH AND t.A070011 = STR_TO_DATE(i.CJRQ, '%Y%m%d')
WHERE i.CJRQ = '20260428'
  AND i.NBJGH IS NOT NULL
  AND SUBSTRING(t.A070001, 12) != i.NBJGH
LIMIT 20;

-- ============================================
-- 校验 10：与上游来源的抽样回溯
-- ============================================
-- 随机抽取 10 条记录，验证各字段映射是否正确
SELECT
    'CHK_SAMPLE_TRACEBACK' AS check_name,
    i.GYH AS 柜员号,
    t.A070002 AS 源柜员号,
    i.GH AS 工号,
    t.A070003 AS 源工号,
    i.GYLX AS 柜员类型,
    t.A070004 AS 源柜员类型,
    i.SFSTGY AS 是否实体柜员,
    t.A070012 AS 源是否实体柜员,
    i.GYQXJB AS 柜员权限级别,
    t.A070006 AS 源权限级别,
    i.GYZT AS 柜员状态,
    t.A070008 AS 源柜员状态
FROM IE_001_103 i
JOIN T_1_7 t ON t.A070002 = i.GYH AND t.A070011 = STR_TO_DATE(i.CJRQ, '%Y%m%d')
WHERE i.CJRQ = '20260428'
LIMIT 10;
