/*
校验目标：
- 验证 PROC_EAST_IE_002_203_DGKHXXB 执行后 IE_002_203 数据质量。

目标系统：
- EAST5.0系统。

目标表：
- IE_002_203：EAST5.0 对公客户信息表。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 执行存储过程后，按以下校验点逐一运行。
*/

# ========================
# 校验点 1：目标行数
# ========================
# 说明：检查目标表当日数据行数，确认有数据产出
SELECT COUNT(*) AS row_count
  FROM IE_002_203
 WHERE CJRQ = '20260428';

# ========================
# 校验点 2：主键唯一性
# ========================
# 说明：(客户统一编号, 采集日期) 不应有重复
SELECT KHTYBH, CJRQ, COUNT(*) AS cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
 GROUP BY KHTYBH, CJRQ
HAVING COUNT(*) > 1;

# ========================
# 校验点 3：客户类型码值
# ========================
# 说明：客户类型只应出现'单一法人客户'、'同业客户'、'集团客户'
SELECT KHTX, COUNT(*) AS cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
 GROUP BY KHTX;

# ========================
# 校验点 4：信贷客户标志码值
# ========================
# 说明：信贷客户标志只应出现'是'、'否'
SELECT XDKHBZ, COUNT(*) AS cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
 GROUP BY XDKHBZ;

# ========================
# 校验点 5：上市公司标志码值
# ========================
# 说明：上市公司标志只应出现'是'、'否'
SELECT SSGSBZ, COUNT(*) AS cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
 GROUP BY SSGSBZ;

# ========================
# 校验点 6：采集日期格式
# ========================
# 说明：采集日期应为 8 位数字
SELECT COUNT(*) AS bad_date_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND (CJRQ NOT LIKE '________'
        OR CJRQ REGEXP '[^0-9]');

# ========================
# 校验点 7：成立日期格式
# ========================
# 说明：成立日期应为 8 位数字或为空
SELECT COUNT(*) AS bad_clrq_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND CLRQ IS NOT NULL
   AND (CLRQ NOT LIKE '________'
        OR CLRQ REGEXP '[^0-9]');

# ========================
# 校验点 8：首次建立信贷关系年月格式
# ========================
# 说明：首次建立信贷关系年月应为 6 位数字或为空
SELECT COUNT(*) AS bad_scjlxdgxy_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND SCJLXDGXNY IS NOT NULL
   AND (SCJLXDGXNY NOT LIKE '______'
        OR SCJLXDGXNY REGEXP '[^0-9]');

# ========================
# 校验点 9：信贷客户标志与首次建立信贷关系年月一致性
# ========================
# 说明：信贷客户标志为'是'时，首次建立信贷关系年月不应为空且不应为999912
SELECT COUNT(*) AS inconsistency_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND XDKHBZ = '是'
   AND (SCJLXDGXNY IS NULL
        OR SCJLXDGXNY = ''
        OR SCJLXDGXNY = '999912');

# ========================
# 校验点 10：企业分类与信贷客户标志一致性
# ========================
# 说明：信贷客户标志为'是'时，企业分类不应为空
SELECT COUNT(*) AS bad_qyfl_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND XDKHBZ = '是'
   AND (QYFL IS NULL OR QYFL = '');

# ========================
# 校验点 11：证件类别码值分布
# ========================
# 说明：检查证件类别出现的值，确认映射正确
SELECT ZJLB, COUNT(*) AS cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
 GROUP BY ZJLB
 ORDER BY cnt DESC;

# ========================
# 校验点 12：各客户类型行数分布
# ========================
# 说明：检查三大客户类型的行数分布是否合理
SELECT KHTX, COUNT(*) AS cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
 GROUP BY KHTX
 ORDER BY cnt DESC;

# ========================
# 校验点 13：集团客户企业分类应为空
# ========================
# 说明：集团客户的企业分类字段应赋空值
SELECT COUNT(*) AS bad_group_qyfl_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND KHTX = '集团客户'
   AND (QYFL IS NOT NULL AND QYFL <> '');

# ========================
# 校验点 14：集团客户上市公司标志应为'否'
# ========================
# 说明：集团客户的上市公司标志应固定为'否'
SELECT COUNT(*) AS bad_group_ssgsbz_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND KHTX = '集团客户'
   AND SSGSBZ <> '否';

# ========================
# 校验点 15：证件号码与证件类别对应关系抽样
# ========================
# 说明：证件类别为'统一社会信用代码'时，证件号码应为18位
SELECT COUNT(*) AS bad_zjhm_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND ZJLB = '统一社会信用代码'
   AND (ZJHM IS NULL OR LENGTH(ZJHM) <> 18);

# ========================
# 校验点 16：注册资本和实收资本非负检查
# ========================
# 说明：注册资本和实收资本不应为负数
SELECT COUNT(*) AS negative_amount_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND (ZCZB IS NOT NULL AND ZCZB < 0)
   OR (SSZB IS NOT NULL AND SSZB < 0);

# ========================
# 校验点 17：员工人数非负检查
# ========================
# 说明：员工人数不应为负数
SELECT COUNT(*) AS negative_emp_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND YGRS IS NOT NULL
   AND YGRS < 0;

# ========================
# 校验点 18：必填字段空值检查（客户统一编号、客户名称、客户类型）
# ========================
# 说明：客户统一编号、客户名称、客户类型不应为空
SELECT
  COUNT(*) AS total_cnt,
  SUM(CASE WHEN KHTYBH IS NULL OR KHTYBH = '' THEN 1 ELSE 0 END) AS null_khtybh_cnt,
  SUM(CASE WHEN KHMC IS NULL OR KHMC = '' THEN 1 ELSE 0 END) AS null_khmc_cnt,
  SUM(CASE WHEN KHTX IS NULL OR KHTX = '' THEN 1 ELSE 0 END) AS null_khtx_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428';

# ========================
# 校验点 19：内部机构号格式检查
# ========================
# 说明：内部机构号应为从机构ID第12位截取，长度合理
SELECT NBJGH, COUNT(*) AS cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
   AND NBJGH IS NOT NULL
 GROUP BY NBJGH
 ORDER BY cnt DESC
 LIMIT 20;

# ========================
# 校验点 20：与源表数据量对比
# ========================
# 说明：对比目标表行数与源表行数，确认映射完整性
# 单一法人客户数
SELECT '单一法人客户' AS cust_type, COUNT(*) AS src_cnt
  FROM T_2_1
 WHERE B010060 = '2026-04-28'
UNION ALL
# 同业客户数
SELECT '同业客户', COUNT(*)
  FROM T_2_3
 WHERE B030036 = '2026-04-28'
UNION ALL
# 集团客户数
SELECT '集团客户', COUNT(*)
  FROM T_2_2
 WHERE B020019 = '2026-04-28';

# 目标表各类型客户数
SELECT KHTX AS cust_type, COUNT(*) AS tgt_cnt
  FROM IE_002_203
 WHERE CJRQ = '20260428'
 GROUP BY KHTX;
