/*
业务目标：
- 从一表通个人客户关系人 T_3_7 映射生成 EAST5.0 个人客户关系表 IE_002_202。
- 报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。
- 个人客户的所有关联关系，包括个人对个人、个人对对公的相关关联关系。本人为本人担保的关系不报送。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖知识页：
- [[来源-EAST5.0系统-IE_002_202-个人客户关系表]]
- [[数据表-IE_002_202-个人客户关系表-EAST5.0系统]]
- [[来源-一表通系统-3.7-个人客户关系人]]
- [[数据表-T_3_7-个人客户关系人-一表通系统]]
- [[数据表-IE_002_201-个人基础信息表-EAST5.0系统]]
- [[概念-系统-EAST5.0系统]]
- [[概念-系统-一表通系统]]

源表：
- T_3_7：一表通 个人客户关系人，主源表。关联键：C070003（个人ID）→ KHTYBH。
- IE_002_201：EAST5.0 个人基础信息表，通过 KHTYBH 关联取 JRXKZH、NBJGH、KHXM、ZJLB、ZJHM。

目标表：
- IE_002_202：EAST5.0 个人客户关系表。目标字段 17 个，其中 14 个有映射来源，3 个置空。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。
- I_BATCH_NO：批次号/任务流水号。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- 上一采集日的计算方式：当前按 DATE_SUB(p_data_date, INTERVAL 1 DAY)，与 PROC_EAST_IE_002_201 保持一致。
- 本人为本人担保的"担保"码值：假设 T_3_7.C070004（社会关系）直接存储中文'担保'；如为编码，需替换对应码值。
- IE_002_201 可能因机构关联缺失导致 JRXKZH、NBJGH 为空，当前不做强制校验，留空处理。
- SENSITIVEFLAG（涉密标志）、GXRKHLB（关系人客户类别）、GSFZJG（归属分支机构）在需求文档中无映射来源，当前均置 NULL。
- T_3_7 的 采集日期（C070011）是 DATE 类型，目标 IE_002_202.CJRQ 是 VARCHAR(8)，需转换。

开发说明：
- 日期函数使用 GBase 8a 风格：TO_DATE / TO_CHAR。
- 直接 DML + COMMIT，不写 START TRANSACTION。
- 异常处理使用 GET DIAGNOSTICS CONDITION 1 + GBASE_ERRNO。
*/

CREATE PROCEDURE `PROC_EAST_IE_002_202_GRRKXB`(
    IN I_DATE VARCHAR(8),
    IN I_BATCH_NO VARCHAR(64)
)
BEGIN
  #声明变量
  DECLARE P_DATA_DATE      DATE;
  DECLARE P_PREV_DATE      DATE;
  DECLARE P_SQLCDE         VARCHAR(200);
  DECLARE P_STATE          VARCHAR(200);
  DECLARE P_SQLMSG         VARCHAR(2000);

  #声明异常
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1
        P_SQLCDE = GBASE_ERRNO,
        P_SQLMSG = MESSAGE_TEXT,
        P_STATE  = RETURNED_SQLSTATE;
    ROLLBACK;
  END;

  #变量初始化
  SET P_DATA_DATE = TO_DATE(I_DATE, 'YYYYMMDD');
  SET P_PREV_DATE = P_DATA_DATE - 1;

  #1.清除数据
  DELETE FROM IE_002_202
   WHERE CJRQ = I_DATE;
  COMMIT;

  #2.插入数据
  INSERT INTO IE_002_202 (
      SENSITIVEFLAG,   # 涉密标志
      GXZT,            # 关系状态
      ZJLB,            # 证件类别
      GXLX,            # 关系类型
      GXRMC,           # 关系人名称
      JRXKZH,          # 金融许可证号
      KHXM,            # 客户姓名
      BBZ,             # 备注
      CJRQ,            # 采集日期
      GXRKHLB,         # 关系人客户类别
      NBJGH,           # 内部机构号
      KHTYBH,          # 客户统一编号
      ZJHM,            # 证件号码
      GXRKHTYBH,       # 关系人客户统一编号
      GXRZJLB,         # 关系人证件类别
      GXRZJHM,         # 关系人证件号码
      GSFZJG           # 归属分支机构
  )
  SELECT
      # 1. SENSITIVEFLAG：涉密标志，需求文档无映射来源，置空
      NULL AS SENSITIVEFLAG,

      # 2. GXZT：关系状态
      #    加工映射：解除关系日期不为空且小于等于跑批日期 → '无效'，否则 '有效'
      CASE
          WHEN rel.C070010 IS NOT NULL
           AND rel.C070010 <= TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
          THEN '无效'
          ELSE '有效'
      END AS GXZT,

      # 3. ZJLB：证件类别，关联 IE_002_201 取
      NULLIF(TRIM(e201.ZJLB), '') AS ZJLB,

      # 4. GXLX：关系类型，直接映射 T_3_7.社会关系
      NULLIF(TRIM(rel.C070004), '') AS GXLX,

      # 5. GXRMC：关系人名称，直接映射 T_3_7.关系人姓名
      NULLIF(TRIM(rel.C070006), '') AS GXRMC,

      # 6. JRXKZH：金融许可证号，关联 IE_002_201 取
      NULLIF(TRIM(e201.JRXKZH), '') AS JRXKZH,

      # 7. KHXM：客户姓名，关联 IE_002_201 取
      NULLIF(TRIM(e201.KHXM), '') AS KHXM,

      # 8. BBZ：备注，直接映射 T_3_7.备注
      NULLIF(TRIM(rel.C070012), '') AS BBZ,

      # 9. CJRQ：采集日期，DATE → YYYYMMDD
      TO_CHAR(rel.C070011, 'YYYYMMDD') AS CJRQ,

      # 10. GXRKHLB：关系人客户类别，需求文档无映射来源，置空
      NULL AS GXRKHLB,

      # 11. NBJGH：内部机构号，关联 IE_002_201 取
      NULLIF(TRIM(e201.NBJGH), '') AS NBJGH,

      # 12. KHTYBH：客户统一编号，直接映射 T_3_7.个人ID
      rel.C070003 AS KHTYBH,

      # 13. ZJHM：证件号码，关联 IE_002_201 取
      NULLIF(TRIM(e201.ZJHM), '') AS ZJHM,

      # 14. GXRKHTYBH：关系人客户统一编号，直接映射 T_3_7.关系人ID
      rel.C070005 AS GXRKHTYBH,

      # 15. GXRZJLB：关系人证件类别，码值转换
      #     1999-XX → 其他-XX；2999-XX → 其他-XX；其余直接映射
      CASE
          WHEN NULLIF(TRIM(rel.C070007), '') LIKE '1999-%'
          THEN CONCAT('其他-', SUBSTR(NULLIF(TRIM(rel.C070007), ''), 6))
          WHEN NULLIF(TRIM(rel.C070007), '') LIKE '2999-%'
          THEN CONCAT('其他-', SUBSTR(NULLIF(TRIM(rel.C070007), ''), 6))
          ELSE NULLIF(TRIM(rel.C070007), '')
      END AS GXRZJLB,

      # 16. GXRZJHM：关系人证件号码，直接映射 T_3_7.关系人证件号码
      NULLIF(TRIM(rel.C070008), '') AS GXRZJHM,

      # 17. GSFZJG：归属分支机构，需求文档无映射来源，置空
      NULL AS GSFZJG

  FROM T_3_7 rel

  # 关联 IE_002_201 取个人基础信息（金融许可证号、内部机构号、客户姓名、证件类别、证件号码）
  # 使用子查询按 KHTYBH 去重，避免一对多导致目标表重复
  LEFT JOIN (
      SELECT
          KHTYBH,
          JRXKZH,
          NBJGH,
          KHXM,
          ZJLB,
          ZJHM,
          ROW_NUMBER() OVER (
              PARTITION BY KHTYBH
              ORDER BY NBJGH
          ) AS rn
      FROM IE_002_201
      WHERE CJRQ = I_DATE
  ) e201
      ON rel.C070003 = e201.KHTYBH
     AND e201.rn = 1

  WHERE rel.C070011 = TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
    # 剔除：解除关系日期非空且小于上个采集日期（已在上个周期前解除的关系不再报送）
    AND NOT (rel.C070010 IS NOT NULL AND rel.C070010 < TO_CHAR(P_PREV_DATE, 'YYYY-MM-DD'))
    # 剔除：本人为本人担保的关系不报送
    #     未确认点："担保"码值假设 T_3_7.C070004 直接存储中文；如为编码需替换
    AND NOT (rel.C070003 = rel.C070005 AND NULLIF(TRIM(rel.C070004), '') = '担保')
    # 客户统一编号不可为空（否则无法关联个人基础信息表）
    AND rel.C070003 IS NOT NULL
    AND TRIM(rel.C070003) != '';

  COMMIT;

END;
