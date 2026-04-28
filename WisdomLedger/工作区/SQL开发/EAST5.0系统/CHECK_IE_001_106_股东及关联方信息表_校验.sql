/*
业务目标：
- 校验 PROC_EAST_IE_001_106 存储过程执行后 IE_001_106 目标表的数据质量。

目标系统：
- EAST5.0系统。

目标产物：
- 校验 SQL（配套 PROC_EAST_IE_001_106_草案.sql）。

依赖知识页：
- [[数据表-IE_001_106-股东及关联方信息表-EAST5.0系统]]
- [[数据表-T_1_6-股东及关联方信息-一表通系统]]

参数：
- ${p_data_date}：采集日期，格式 YYYYMMDD，替换为实际跑批日期执行。

使用方式：
- 存储过程执行后，逐条或批量执行以下校验 SQL。
*/

-- ============================================================
-- 1. 目标表行数检查
-- ============================================================
-- 预期：目标行数应与 source CTE 的 eligible_t16 行数一致
SELECT
    'row_count'                           AS check_type,
    COUNT(*)                              AS row_count,
    '确认目标行数在合理范围内（>0 且不超过源表当期记录数）' AS expectation
FROM IE_001_106
WHERE CJRQ = '${p_data_date}';

-- 做源表对照：
SELECT
    'source_eligible_count' AS check_type,
    COUNT(*)                AS eligible_count
FROM (
    SELECT cur.A060001
    FROM T_1_6 cur
    LEFT JOIN T_1_6 prev
           ON prev.A060001 = cur.A060001
          AND prev.A060024 = STR_TO_DATE(
                  DATE_FORMAT(
                      DATE_SUB(
                          DATE_SUB(STR_TO_DATE('${p_data_date}', '%Y%m%d'),
                                   INTERVAL (DAY(STR_TO_DATE('${p_data_date}', '%Y%m%d')) - 1) DAY),
                          INTERVAL 1 DAY
                      ), '%Y%m%d'
                  ), '%Y%m%d'
              )
    WHERE cur.A060024 = STR_TO_DATE('${p_data_date}', '%Y%m%d')
      AND (
          (cur.A060029 = '1'
           AND (
               CAST(NULLIF(TRIM(cur.A060019), '') AS DECIMAL(20,6)) >= 0.01
               OR cur.A060022 = '1'
           ))
          OR (cur.A060029 = '0')
          OR (cur.A060029 IS NULL OR cur.A060029 NOT IN ('0', '1'))
      )
      AND NOT (cur.A060017 = '00' AND prev.A060017 = '00')
) s;

-- ============================================================
-- 2. 主键/唯一性检查
--    EAST IE_001_106 的主键组合：CJRQ + NBJGH + KHTYBH（按 DDL 注释 CJRQ 和 NBJGH 为 PK）
--    同时检查 (CJRQ, NBJGH, GDHGLFZJHM) 是否重复
-- ============================================================
SELECT
    CJRQ, NBJGH, GDHGLFZJHM, COUNT(*) AS cnt
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
GROUP BY CJRQ, NBJGH, GDHGLFZJHM
HAVING COUNT(*) > 1;

-- ============================================================
-- 3. 必填字段为空检查
-- ============================================================
-- 金融许可证号：应为非空
SELECT COUNT(*) AS null_jrxkzh
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
  AND (JRXKZH IS NULL OR JRXKZH = '');

-- 内部机构号：应为非空
SELECT COUNT(*) AS null_nbjgh
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
  AND (NBJGH IS NULL OR NBJGH = '');

-- 股东或关联方证件类别：DDL 注释"不可为空"
SELECT COUNT(*) AS null_gdhglfzjlb
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
  AND (GDHGLFZJLB IS NULL OR GDHGLFZJLB = '');

-- ============================================================
-- 4. 码值越界检查
-- ============================================================

-- 4a. 股东或关联方类型 (GDHGLFLX)
SELECT GDHGLFLX, COUNT(*) AS cnt
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
GROUP BY GDHGLFLX
ORDER BY GDHGLFLX;

-- 4b. 是否限权 (SFXQ)：只允许 '是'/'否' 或空
SELECT SFXQ, COUNT(*) AS cnt
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
  AND SFXQ NOT IN ('是', '否')
  AND SFXQ IS NOT NULL
GROUP BY SFXQ;

-- 4c. 入股资金来源 (RGZJLY)
SELECT RGZJLY, COUNT(*) AS cnt
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
GROUP BY RGZJLY
ORDER BY RGZJLY;

-- 4d. 是否驻派董监事 (SFZPDJS)：只允许 '是'/'否' 或空
SELECT SFZPDJS, COUNT(*) AS cnt
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
  AND SFZPDJS NOT IN ('是', '否')
  AND SFZPDJS IS NOT NULL
GROUP BY SFZPDJS;

-- 4e. 股东或关联方状态 (GDHGLFZT)：只允许 '有效'/'无效' 或 '其他-XX'
SELECT GDHGLFZT, COUNT(*) AS cnt
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
GROUP BY GDHGLFZT
ORDER BY GDHGLFZT;

-- 4f. 关系类型 (GXLX)
SELECT GXLX, COUNT(*) AS cnt
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
GROUP BY GXLX
ORDER BY GXLX;

-- ============================================================
-- 5. 日期格式与范围检查
-- ============================================================

-- 采集日期：必须为 8 位数字
SELECT COUNT(*) AS bad_cjrq
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
  AND (CJRQ NOT REGEXP '^[0-9]{8}$' OR CJRQ IS NULL);

-- 入股日期：非空时须为 8 位数字且不大于采集日期
SELECT COUNT(*) AS bad_rgrq
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
  AND RGRQ IS NOT NULL
  AND (RGRQ NOT REGEXP '^[0-9]{8}$' OR RGRQ > CJRQ);

-- 最近一次变动日期：非空时须为 8 位数字
SELECT COUNT(*) AS bad_zjyc
FROM IE_001_106
WHERE CJRQ = '${p_data_date}'
  AND ZJYCBDRQ IS NOT NULL
  AND ZJYCBDRQ NOT REGEXP '^[0-9]{8}$';

-- ============================================================
-- 6. 金额/比例异常值检查
-- ============================================================

-- 持股比例：应在 0~1 范围内（比例）或 0~100（百分比）待确认
SELECT MIN(CGBL) AS min_cgbl, MAX(CGBL) AS max_cgbl, AVG(CGBL) AS avg_cgbl
FROM IE_001_106
WHERE CJRQ = '${p_data_date}';

-- 质押比例：应在 0~1 范围内
SELECT MIN(ZYBL) AS min_zybl, MAX(ZYBL) AS max_zybl, AVG(ZYBL) AS avg_zybl
FROM IE_001_106
WHERE CJRQ = '${p_data_date}';

-- ============================================================
-- 7. 与源表抽样回溯核对
-- ============================================================

-- 抽查 10 条记录，对比关键字段
SELECT
    e.NBJGH,
    e.GDHGLFMC,
    e.GDHGLFLX,
    s.A060004 AS src_gdhglflx,
    e.CGBL,
    s.A060019 AS src_cgbl,
    e.GDHGLFZT,
    s.A060017 AS src_zt
FROM IE_001_106 e
LEFT JOIN T_1_6 s
       ON s.A060002 = (SELECT A010001 FROM T_1_1 WHERE A010020 = STR_TO_DATE('${p_data_date}', '%Y%m%d') AND A010001 = (SELECT A060002 FROM T_1_6 WHERE A060024 = STR_TO_DATE('${p_data_date}', '%Y%m%d') AND SUBSTRING(A060002, 12) = e.NBJGH LIMIT 1) LIMIT 1)
      AND s.A060024 = STR_TO_DATE('${p_data_date}', '%Y%m%d')
WHERE e.CJRQ = '${p_data_date}'
LIMIT 10;

-- ============================================================
-- 8. 分支逻辑校验
-- ============================================================

-- 上市分支：不应存在 持股比例<1% 且 驻派董监事!='是' 的上市股东
SELECT COUNT(*) AS listed_filter_violation
FROM IE_001_106 e
JOIN T_1_6 s
  ON s.A060024 = STR_TO_DATE('${p_data_date}', '%Y%m%d')
 AND SUBSTRING(NULLIF(TRIM(s.A060002), ''), 12) = e.NBJGH
 AND s.A060001 = (
     SELECT A060001 FROM T_1_6 t2
     WHERE t2.A060024 = STR_TO_DATE('${p_data_date}', '%Y%m%d')
       AND SUBSTRING(NULLIF(TRIM(t2.A060002), ''), 12) = e.NBJGH
       AND NULLIF(TRIM(t2.A060003), '') = e.GDHGLFMC
     LIMIT 1
 )
WHERE e.CJRQ = '${p_data_date}'
  AND s.A060029 = '1'
  AND CAST(NULLIF(TRIM(s.A060019), '') AS DECIMAL(20,6)) < 0.01
  AND s.A060022 != '1';

-- ============================================================
-- 9. 终态过滤校验
-- ============================================================

-- 不应存在 当月无效 且 上月也为无效 的记录
-- （需要上月目标表数据支持，以下为占位示意）
SELECT COUNT(*) AS final_state_violation
FROM IE_001_106 e
JOIN T_1_6 cur
  ON cur.A060024 = STR_TO_DATE('${p_data_date}', '%Y%m%d')
 AND SUBSTRING(NULLIF(TRIM(cur.A060002), ''), 12) = e.NBJGH
 AND NULLIF(TRIM(cur.A060003), '') = e.GDHGLFMC
WHERE e.CJRQ = '${p_data_date}'
  AND e.GDHGLFZT = '无效'
  AND EXISTS (
      SELECT 1 FROM T_1_6 prev
      WHERE prev.A060024 = STR_TO_DATE(
          DATE_FORMAT(DATE_SUB(DATE_SUB(STR_TO_DATE('${p_data_date}', '%Y%m%d'),
              INTERVAL (DAY(STR_TO_DATE('${p_data_date}', '%Y%m%d')) - 1) DAY), INTERVAL 1 DAY), '%Y%m%d'),
          '%Y%m%d')
        AND prev.A060001 = cur.A060001
        AND prev.A060017 = '00'
  );
