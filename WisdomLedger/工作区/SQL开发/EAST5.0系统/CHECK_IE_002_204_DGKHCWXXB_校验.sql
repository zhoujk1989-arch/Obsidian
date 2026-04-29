/*
校验目标：
- 验证 PROC_EAST_IE_002_204_DGKHCWXXB 存储过程的输出正确性。

目标系统：
- EAST5.0系统。

依赖存储过程：
- PROC_EAST_IE_002_204_DGKHCWXXB

运行方式：
- 先调用存储过程，再执行以下校验查询。
*/

# ============================================
# 校验 1：目标表行数非零（基本 sanity check）
# ============================================
SELECT COUNT(*) AS row_cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429';

# 预期：> 0，否则说明映射未产出数据


# ============================================
# 校验 2：主键唯一性（CJRQ + CWBBBH + KHTYBH + CWBBRQ）
# ============================================
# 注意：DDL 中主键为 CJRQ + CWBBBH + KHTYBH + CWBBRQ
# 但 DDL 实际 PK 定义未显式声明，此处校验组合唯一性
SELECT CJRQ, CWBBBH, KHTYBH, CWBBRQ, COUNT(*) AS cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429'
 GROUP BY CJRQ, CWBBBH, KHTYBH, CWBBRQ
HAVING cnt > 1;

# 预期：0 行，如有重复说明去重逻辑有问题


# ============================================
# 校验 3：金额字段非空检查
# ============================================
SELECT
    SUM(CASE WHEN ZCZE IS NULL THEN 1 ELSE 0 END) AS zcze_null_cnt,
    SUM(CASE WHEN FZZE IS NULL THEN 1 ELSE 0 END) AS fzze_null_cnt,
    SUM(CASE WHEN JLR IS NULL THEN 1 ELSE 0 END) AS jlr_null_cnt,
    SUM(CASE WHEN SDS IS NULL THEN 1 ELSE 0 END) AS sds_null_cnt,
    SUM(CASE WHEN SQLR IS NULL THEN 1 ELSE 0 END) AS sqlr_null_cnt,
    SUM(CASE WHEN ZYYWSR IS NULL THEN 1 ELSE 0 END) AS zywysr_null_cnt,
    SUM(CASE WHEN XJLLJE IS NULL THEN 1 ELSE 0 END) AS xjllje_null_cnt,
    SUM(CASE WHEN YSZK IS NULL THEN 1 ELSE 0 END) AS yszk_null_cnt,
    SUM(CASE WHEN QTYSK IS NULL THEN 1 ELSE 0 END) AS qtsk_null_cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429';

# 预期：各列数值反映空值数量，全部为 0 说明金额字段全覆盖


# ============================================
# 校验 4：税前利润 = 净利润 + 所得税（逻辑一致性）
# ============================================
SELECT COUNT(*) AS mismatch_cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429'
   AND SQLR IS NOT NULL
   AND (JLR + SDS) IS NOT NULL
   AND ABS(SQLR - (JLR + SDS)) > 0.01;

# 预期：0 行，如有说明税前利润计算有误


# ============================================
# 校验 5：码值字段合法性
# ============================================
# 是否审计码值
SELECT SFSJ, COUNT(*) AS cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429'
   AND SFSJ IS NOT NULL
 GROUP BY SFSJ;

# 预期：SFSJ 只出现 '是'、'否' 或其他空值


# 报表口径码值
SELECT BBKJ, COUNT(*) AS cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429'
   AND BBKJ IS NOT NULL
 GROUP BY BBKJ;

# 预期：BBKJ 只出现 '本部报表'、'合并报表'、'其他' 或原始值


# 报表周期码值
SELECT BBZQ, COUNT(*) AS cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429'
   AND BBZQ IS NOT NULL
 GROUP BY BBZQ;

# 预期：BBZQ 只出现 '日报'、'月报'、'季报'、'半年报'、'年报'、'其他' 或原始值


# ============================================
# 校验 6：日期格式校验（YYYYMMDD）
# ============================================
SELECT COUNT(*) AS bad_date_cnt
  FROM IE_002_204_INC
 WHERE CJRQ IS NOT NULL
   AND CJRQ NOT LIKE '________'
   OR CWBBRQ IS NOT NULL
   AND CWBBRQ NOT LIKE '________';

# 预期：0 行，日期格式应为 8 位数字


# ============================================
# 校验 7：客户名称非空检查
# ============================================
SELECT COUNT(*) AS khmc_null_cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429'
   AND KHMC IS NULL;

# 预期：0 行，客户名称应能通过 T_2_1/T_2_3/T_2_2 取到


# ============================================
# 校验 8：与源表行数对比
# ============================================
# 取当月财报录入的源表记录数
SELECT COUNT(*) AS source_row_cnt
  FROM T_2_6
 WHERE B060023 >= DATE_FORMAT(STR_TO_DATE('20260429', '%Y%m%d'), '%Y-%m-01')
   AND B060023 <= LAST_DAY(STR_TO_DATE('20260429', '%Y%m%d'));

# 与目标表行数对比，如有差异需排查排除规则或关联去重逻辑


# ============================================
# 校验 9：内部机构号截取后非空检查
# ============================================
SELECT COUNT(*) AS nbjgh_null_cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429'
   AND NBJGH IS NULL;

# 预期：视数据情况而定，如为 0 说明所有记录都能取到机构号


# ============================================
# 校验 10：金融许可证号和银行机构名称关联检查
# ============================================
SELECT COUNT(*) AS org_null_cnt
  FROM IE_002_204_INC
 WHERE CJRQ = '20260429'
   AND (JRXKZH IS NULL OR YHJGMC IS NULL);

# 预期：视机构ID关联情况而定，如为 0 说明所有记录都能关联到机构信息
