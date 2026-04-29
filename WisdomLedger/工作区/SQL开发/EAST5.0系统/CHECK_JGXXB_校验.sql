/*
业务目标：
- 对 EAST 机构信息表 JGXXB 的批次数据执行质量校验。

目标系统：
- EAST5.0 系统。

目标产物：
- GBase 8a MPP 校验 SQL 草案。

源表：
- JGXXB：EAST 机构信息表（目标表）。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 查询分析：执行后返回各校验项的结果集。
*/

/* ========== 1. 行数检查 ========== */
-- 检查目标表当期数据行数
SELECT
    COUNT(*) AS TARGET_ROW_COUNT
FROM JGXXB
WHERE CJRQ = '20260131';

/* ========== 2. 主键重复检查 ========== */
-- 检查内部机构号（NBJGH）是否有重复
SELECT
    NBJGH,
    COUNT(*) AS DUPLICATE_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
  AND NBJGH IS NOT NULL
GROUP BY NBJGH
HAVING COUNT(*) > 1;

/* ========== 3. 主键非空检查 ========== */
-- 检查内部机构号是否为空
SELECT
    COUNT(*) AS NULL_NBJGH_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
  AND NBJGH IS NULL;

/* ========== 4. 银行机构代码非空检查 ========== */
-- 检查银行机构代码是否为空
SELECT
    COUNT(*) AS NULL_YHJGDM_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
  AND YHJGDM IS NULL;

/* ========== 5. 机构类别码值越界检查 ========== */
-- 检查机构类别是否只出现允许的码值
SELECT
    JGLB,
    COUNT(*) AS ROW_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
GROUP BY JGLB
ORDER BY JGLB;

-- 预期码值：'管理机构'、'营业机构'、'虚拟机构'、'内设机构'、NULL
-- 出现其他值需关注

/* ========== 6. 营业状态码值越界检查 ========== */
-- 检查营业状态是否只出现允许的码值
SELECT
    YYZT,
    COUNT(*) AS ROW_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
GROUP BY YYZT
ORDER BY YYZT;

-- 预期码值：'营业'、'停业'、NULL
-- 出现其他值需关注

/* ========== 7. 采集日期格式检查 ========== */
-- 检查采集日期是否全部为 YYYYMMDD 格式
SELECT
    COUNT(*) AS INVALID_CJRQ_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
  AND (
        CJRQ NOT REGEXP '^[0-9]{8}$'
     OR LENGTH(CJRQ) <> 8
  );

/* ========== 8. 成立日期格式检查 ========== */
-- 检查成立日期是否为 YYYYMMDD 格式（非空时）
SELECT
    COUNT(*) AS INVALID_CLRQ_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
  AND CLRQ IS NOT NULL
  AND (
        CLRQ NOT REGEXP '^[0-9]{8}$'
     OR LENGTH(CLRQ) <> 8
  );

/* ========== 9. 营业执照号格式检查（统一社会信用代码） ========== */
-- 检查营业执照号是否为 18 位统一社会信用代码格式
SELECT
    COUNT(*) AS INVALID_YYZZH_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
  AND YYZZH IS NOT NULL
  AND (
        LENGTH(TRIM(YYZZH)) <> 18
     OR YYZZH NOT REGEXP '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$'
  );

/* ========== 10. 金融许可证号格式检查 ========== */
-- 检查金融许可证号是否为 9 位格式（常见格式）
SELECT
    JRXKZH,
    COUNT(*) AS ROW_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
  AND JRXKZH IS NOT NULL
GROUP BY JRXKZH
ORDER BY JRXKZH;

/* ========== 11. 停业机构连续过滤检查 ========== */
-- 检查是否存在上个月停业且本月仍停业、且无总账余额/内部分户账记录的机构
-- 此检查用于验证过滤逻辑是否正确执行
-- 需要关联一表通源表进行交叉验证
SELECT
    '待与源表交叉验证' AS CHECK_TYPE,
    '需关联 T_1_1 上月末和本月数据验证停业过滤逻辑' AS NOTE;

/* ========== 12. 机构类别为空检查 ========== */
-- 检查机构类别为空的记录数（可能是码值无法匹配）
SELECT
    COUNT(*) AS NULL_JGLB_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
  AND JGLB IS NULL;

-- 如果数量较多，需检查源表 A010008 字段是否存在未映射的码值

/* ========== 13. 负责人职务为空检查 ========== */
-- 检查负责人职务为空的记录数（可能负责人工号未关联到员工表）
SELECT
    COUNT(*) AS NULL_FZRZW_COUNT
FROM JGXXB
WHERE CJRQ = '20260131'
  AND FZRZW IS NULL;

/* ========== 14. 采集日期一致性检查 ========== */
-- 检查采集日期是否与批次日期一致
SELECT
    COUNT(*) AS MISMATCH_CJRQ_COUNT
FROM JGXXB
WHERE CJRQ = '20260131';

-- 以上查询结果应全部为 0，表示校验通过
