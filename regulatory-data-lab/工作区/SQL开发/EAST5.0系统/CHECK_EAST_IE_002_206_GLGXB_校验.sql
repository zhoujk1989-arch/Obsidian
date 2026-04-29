/*
业务目标：校验 IE_002_206 关联关系表存储过程输出质量

目标系统：一表通系统 -> EAST5.0

目标产物：校验 SQL

源表：
- IE_002_203 对公客户信息表（客户主数据 enrichment 校验）
- T_3_1 重要股东及主要关联企业（来源1 行数校验）
- T_3_2 高管及重要关系人信息（来源2 行数校验）

目标表：IE_002_206 关联关系表

参数：
- ${I_DATE}：跑批日期，格式 YYYYMMDD，例如 '20260428'

运行方式：手动校验

未确认点：
- T_3_1 无显式关系失效日期字段，以采集日期作为当月过滤代理；T_3_2 使用关系失效日期字段
- 关联人客户统一编号为空时允许（非本行客户填空）
- 码值转换覆盖范围是否完整需与公共代码表 T_10_1 核对
*/

-- 参数设置（执行前替换）
-- SET @I_DATE = '20260428';

/* 1. 目标表行数检查 */
SELECT
  COUNT(*) AS target_row_count
FROM IE_002_206
WHERE CJRQ = @I_DATE;

/* 2. 来源1（T_3_1）贡献行数 */
SELECT
  COUNT(*) AS src1_row_count
FROM T_3_1
WHERE C010017 = TO_DATE(@I_DATE, 'YYYYMMDD');

/* 3. 来源2（T_3_2）贡献行数（含失效日期过滤） */
SELECT
  COUNT(*) AS src2_row_count
FROM T_3_2
WHERE C020014 = TO_DATE(@I_DATE, 'YYYYMMDD')
  AND (C020013 IS NULL OR C020013 > TO_DATE(@I_DATE, 'YYYYMMDD'));

/* 4. 主键重复检查（GSLX + GLRZJHM + KHZJHM + CJRQ）
   EAST 关联关系表 PK 包含：关系类型(GXLX)、关联人证件号码(GLRZJHM)、
   客户证件号码(KHZJHM)、采集日期(CJRQ) */
SELECT
  GXLX, GLRZJHM, KHZJHM, CJRQ, COUNT(*) AS cnt
FROM IE_002_206
WHERE CJRQ = @I_DATE
GROUP BY GXLX, GLRZJHM, KHZJHM, CJRQ
HAVING COUNT(*) > 1;

/* 5. 客户统一编号为空检查（非必填，但应能关联到对公客户信息表）
   若 KHTYBH 为空且 KHMC 也为空，说明 enrichment 失败 */
SELECT
  COUNT(*) AS enrichment_fail_count
FROM IE_002_206
WHERE CJRQ = @I_DATE
  AND KHTYBH IS NULL
  AND KHMC IS NULL;

/* 6. 关系类型码值检查 */
SELECT
  GXLX, COUNT(*) AS cnt
FROM IE_002_206
WHERE CJRQ = @I_DATE
  AND GXLX NOT IN (
    '母公司', '子公司',
    '与该企业受同一母公司控制的其他企业',
    '与该企业实施共同控制的投资方',
    '对该企业施加重大影响的投资方',
    '该企业的合营企业', '该企业的联营企业',
    '该企业的主要投资者个人及与其关系密切的家庭成员',
    '该企业或其母公司的关键管理人员及与其关系密切的家庭成员',
    '该企业主要投资者个人、关键管理人员或与其关系密切的家庭成员控制、共同控制或施加重大影响的其他企业',
    '供应链上下游', '担保关系',
    '其他-XX'
  )
GROUP BY GXLX
ORDER BY GXLX;

/* 7. 关联人类别码值检查 */
SELECT
  GLRLB, COUNT(*) AS cnt
FROM IE_002_206
WHERE CJRQ = @I_DATE
  AND GLRLB NOT IN (
    '自然人', '国有企业', '民营企业',
    '政府机关', '事业单位', '社会团体',
    '境外机构', '其他-XX'
  )
GROUP BY GLRLB
ORDER BY GLRLB;

/* 8. 关系状态码值检查（仅允许 '1' 或 '0'） */
SELECT
  GXZT, COUNT(*) AS cnt
FROM IE_002_206
WHERE CJRQ = @I_DATE
  AND GXZT NOT IN ('1', '0')
GROUP BY GXZT
ORDER BY GXZT;

/* 9. 采集日期格式检查 */
SELECT
  COUNT(*) AS bad_date_format_count
FROM IE_002_206
WHERE CJRQ NOT REGEXP '^[0-9]{8}$';

/* 10. 关联人证件类别码值检查（1999/2999 应已转为其他-XX） */
SELECT
  COUNT(*) AS unconverted_id_type_count
FROM IE_002_206
WHERE CJRQ = @I_DATE
  AND GLRZJLB LIKE '1999-%';

SELECT
  COUNT(*) AS unconverted_id_type_2999_count
FROM IE_002_206
WHERE CJRQ = @I_DATE
  AND GLRZJLB LIKE '2999-%';

/* 11. 来源抽样追溯：随机取 5 条，验证客户名称能从对公客户信息表查到 */
SELECT
  t.KHTYBH,
  t.KHMC          AS target_khmc,
  c.KHMC          AS source_khmc,
  t.GXRQ          AS target_gxlx,
  t.GLRMC
FROM IE_002_206 t
LEFT JOIN IE_002_203 c ON t.KHTYBH = c.KHTYBH AND c.CJRQ = @I_DATE
WHERE t.CJRQ = @I_DATE
LIMIT 5;
