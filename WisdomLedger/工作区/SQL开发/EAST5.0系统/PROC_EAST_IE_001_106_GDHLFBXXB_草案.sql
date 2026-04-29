/*
业务目标：
- 从一表通 T_1_6（股东及关联方信息）映射生成 EAST5.0 IE_001_106（股东及关联方信息表）。
- 报送截至采集日有效的股东及关联方数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。
- 填报银行股东及银行关联方相关信息。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖知识页：
- [[来源-EAST5.0系统-IE_001_106-股东及关联方信息表]]
- [[来源-一表通系统-1.6-股东及关联方信息]]
- [[数据表-IE_001_106-股东及关联方信息表-EAST5.0系统]]
- [[数据表-T_1_6-股东及关联方信息-一表通系统]]
- [[数据表-T_1_1-机构信息-一表通系统]]
- [[概念-系统-EAST5.0系统]]
- [[概念-系统-一表通系统]]

源表：
- T_1_6：一表通 股东及关联方信息，作为股东/关联方明细主源。
- T_1_1：一表通 机构信息，补金融许可证号和银行机构名称。
- dim_code_mapping：代码映射表，用于证件类别码值转换（转换规则编号 YBT-EAST-GDHGLFZJLB）。
- v_ybt_to_east_corp_cust：转 east 后的对公客户表，用于映射客户统一编号。
- v_ybt_to_east_person_cust：转 east 后的个人客户表，用于映射客户统一编号。

目标表：
- IE_001_106：EAST5.0 股东及关联方信息表。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。
- I_BATCH_NO：批次号/任务流水号。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- 代码映射表（dim_code_mapping）的物理表名和库归属需业务确认。
- 转 east 后的对公客户表（v_ybt_to_east_corp_cust）和转 east 后的个人客户表（v_ybt_to_east_person_cust）的物理表名/视图名和字段名需确认——当前假定其提供 `src_cust_id`（一表通客户ID）到 `east_cust_id`（EAST统一编号）的映射。
- 一表通 T_1_6 中「股东或关联方状态」(A060017) 的枚举：当前已知 01=有效、00=无效；其他状态值是否存在待确认。
- T_1_6 中「不良信息」(A060013) 去掉前导0后的最大长度，与 EAST IE_001_106.BLXX VARCHAR(300) 的适配性。
- 对公/个人客户表的一表通源表字段名（当前假定为一表通 T_2_X 表）待确认。
- 归属分支机构（GSFZJG）字段：一表通映射规则文档未提供来源，当前按内部机构号（NBJGH）兜底。
- 涉密标志（SENSITIVEFLAG）字段：一表通映射规则文档未提供来源，当前置空。

开发说明：
- 本草案使用 CTE（WITH）组织复杂过滤逻辑，分为当期数据 CTE、上月数据 CTE、分支过滤 CTE。
- 不使用 select *；所有 CTE 和主查询只取实际使用字段。
- 日期统一输出 YYYYMMDD 格式。
- 字符字段使用 NULLIF(TRIM(col),'') 清洗空值。
- 码值转换使用 CASE WHEN；证件类别优先通过代码映射表获取，映射表未命中时回退到枚举兜底。
- 持股数量（CGSL）、参股/控股商业银行数量（CGSYYHSL、KGSL）需转换 VARCHAR→DECIMAL(20,0)。
- 持股比例（CGBL）、质押比例（ZYBL）需转换 VARCHAR→DECIMAL(20,6)。
- 日期函数使用 GBase 8a 风格：TO_DATE / TO_CHAR。
- 直接 DML + COMMIT，不写 START TRANSACTION。
- 异常处理使用 GET DIAGNOSTICS CONDITION 1 + GBASE_ERRNO。
*/

CREATE PROCEDURE `PROC_EAST_IE_001_106_GDHLFBXXB`(
    IN I_DATE VARCHAR(8),
    IN I_BATCH_NO VARCHAR(64)
)
BEGIN
  #声明变量
  DECLARE P_DATA_DATE      DATE;
  DECLARE P_PREV_MONTH_LAST DATE;
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
  # 上月最后一天：当月第一天减1天
  SET P_PREV_MONTH_LAST = (P_DATA_DATE - DAY(P_DATA_DATE) + 1) - 1;

  #1.清除数据
  DELETE FROM IE_001_106
   WHERE CJRQ = I_DATE;
  COMMIT;

  #2.插入数据
  INSERT INTO IE_001_106 (
      JRXKZH, CJRQ, BLXX, YHJGMC, ZCD, GXLX,
      CGSYYHSL, SFXQ, RGZJLY, CGSL, RGRQ, ZYBL,
      ZJYCBDRQ, BBZ, GSFZJG, NBJGH, KHTYBH,
      GDHGLFMC, GDHGLFLX, GDHGLFZJLB, GDHGLFZJHM,
      SSHY, SJKZR, KGSL, RGZJZH, CGBL, SFZPDJS,
      GDHGLFZT, SENSITIVEFLAG
  )
  WITH
  # CTE1: 当期 T_1_6 数据，采集日期 = p_data_date
  cur_t16 AS (
      SELECT
          A060001,  # 股东或关联方ID
          A060002,  # 机构ID
          A060003,  # 股东或关联方名称
          A060004,  # 股东或关联方类型
          A060005,  # 股东或关联方证件类型
          A060006,  # 股东或关联方证件号码
          A060007,  # 股东或关联方行业类型
          A060008,  # 股东或关联方注册地址
          A060009,  # 机构关系类型
          A060010,  # 实际控制人名称
          A060011,  # 参股商业银行的数量
          A060012,  # 控股商业银行的数量
          A060013,  # 不良信息
          A060014,  # 是否限权
          A060015,  # 入股资金来源
          A060016,  # 入股资金账号
          A060017,  # 股东或关联方状态 (01=有效, 00=无效)
          A060018,  # 股东持股数量
          A060019,  # 股东持股比例
          A060020,  # 入股日期
          A060021,  # 股东股权质押比例
          A060022,  # 是否驻派董监事
          A060023,  # 最近一次变动日期
          A060029,  # 上市标识 (1=上市, 0=未上市)
          A060030   # 备注
      FROM T_1_6
      WHERE A060024 = TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
  ),
  # CTE2: 上月最后一天 T_1_6 数据，用于判断终态
  prev_t16 AS (
      SELECT
          A060001,  # 股东或关联方ID
          A060017   # 股东或关联方状态
      FROM T_1_6
      WHERE A060024 = TO_CHAR(P_PREV_MONTH_LAST, 'YYYY-MM-DD')
  ),
  # CTE3: 按报送规则过滤后的股东/关联方记录
  # 分支1（上市标识='1'）：持股比例>=1% 或 是否驻派董监事='1'
  # 分支2（上市标识='0'）：全量
  # 通用过滤：当月无效(00) 且 上月也为无效(00) → 不报送
  eligible_t16 AS (
      SELECT
          cur.A060001,
          cur.A060002,
          cur.A060003,
          cur.A060004,
          cur.A060005,
          cur.A060006,
          cur.A060007,
          cur.A060008,
          cur.A060009,
          cur.A060010,
          cur.A060011,
          cur.A060012,
          cur.A060013,
          cur.A060014,
          cur.A060015,
          cur.A060016,
          cur.A060017,
          cur.A060018,
          cur.A060019,
          cur.A060020,
          cur.A060021,
          cur.A060022,
          cur.A060023,
          cur.A060029,
          cur.A060030
      FROM cur_t16 cur
      LEFT JOIN prev_t16 prev
             ON prev.A060001 = cur.A060001
      # 上市/未上市分支过滤
      WHERE (
          # 分支1: 上市 — 持股比例>=1% 或 派驻董监事=1
          (cur.A060029 = '1'
           AND (
               CAST(NULLIF(TRIM(cur.A060019), '') AS DECIMAL(20,6)) >= 0.01
               OR cur.A060022 = '1'
           ))
          # 分支2: 未上市 — 全量
          OR (cur.A060029 = '0')
          # 上市标识为空或其他值 — 保守保留（待确认）
          OR (cur.A060029 IS NULL OR cur.A060029 NOT IN ('0', '1'))
      )
      # 终态过滤：当月无效 AND 上月无效 → 排除
      AND NOT (
          cur.A060017 = '00'
          AND prev.A060017 = '00'
      )
  )
  # 主 SELECT：关联机构信息、代码映射、客户统一编号
  SELECT
      #  1. 金融许可证号：关联 T_1_1，取金融许可证号
      NULLIF(TRIM(org.A010003), '') AS JRXKZH,

      #  2. 采集日期：入参格式化输出
      I_DATE AS CJRQ,

      #  3. 不良信息：如果为'00'则置空，否则去掉前面的0
      CASE
          WHEN cur.A060013 = '00' THEN NULL
          WHEN cur.A060013 IS NULL THEN NULL
          ELSE TRIM(LEADING '0' FROM cur.A060013)
      END AS BLXX,

      #  4. 银行机构名称：关联 T_1_1，取银行机构名称
      NULLIF(TRIM(org.A010005), '') AS YHJGMC,

      #  5. 股东或关联方注册地：直接取自 T_1_6.A060008
      NULLIF(TRIM(cur.A060008), '') AS ZCD,

      #  6. 关系类型：
      #     码值映射：01→1, 02→2, ..., 13→13, 00→其他-自定义
      CASE
          WHEN cur.A060009 BETWEEN '01' AND '13' THEN CAST(CAST(cur.A060009 AS UNSIGNED) AS CHAR)
          WHEN cur.A060009 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(cur.A060009, 4))
          ELSE NULLIF(TRIM(cur.A060009), '')
      END AS GXLX,

      #  7. 参股商业银行的数量：直接取 T_1_6.A060011，转 DECIMAL
      CAST(NULLIF(TRIM(cur.A060011), '') AS DECIMAL(20, 0)) AS CGSYYHSL,

      #  8. 是否限权：0→'否', 1→'是'
      CASE
          WHEN cur.A060014 = '0' THEN '否'
          WHEN cur.A060014 = '1' THEN '是'
          ELSE NULLIF(TRIM(cur.A060014), '')
      END AS SFXQ,

      #  9. 入股资金来源：
      #     码值映射：01→自有资金, 02→委托资金, 03→债务资金, 00-XX→其他-XX
      CASE
          WHEN cur.A060015 = '01' THEN '自有资金'
          WHEN cur.A060015 = '02' THEN '委托资金'
          WHEN cur.A060015 = '03' THEN '债务资金'
          WHEN cur.A060015 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(cur.A060015, 4))
          ELSE NULLIF(TRIM(cur.A060015), '')
      END AS RGZJLY,

      # 10. 持股数量：直接取 T_1_6.A060018，转 DECIMAL
      CAST(NULLIF(TRIM(cur.A060018), '') AS DECIMAL(20, 0)) AS CGSL,

      # 11. 入股日期：yyyy-mm-dd 转为 yyyymmdd
      CASE
          WHEN cur.A060020 IS NULL THEN NULL
          ELSE TO_CHAR(cur.A060020, 'YYYYMMDD')
      END AS RGRQ,

      # 12. 质押比例：直接取 T_1_6.A060021，转 DECIMAL
      CAST(NULLIF(TRIM(cur.A060021), '') AS DECIMAL(20, 6)) AS ZYBL,

      # 13. 最近一次变动日期：yyyy-mm-dd 转为 yyyymmdd
      CASE
          WHEN cur.A060023 IS NULL THEN NULL
          ELSE TO_CHAR(cur.A060023, 'YYYYMMDD')
      END AS ZJYCBDRQ,

      # 14. 备注：直接取自 T_1_6.A060030
      NULLIF(TRIM(cur.A060030), '') AS BBZ,

      # 15. 归属分支机构：一表通映射规则未提供来源，暂按 NBJGH 兜底
      #     TODO: 确认业务来源
      SUBSTR(NULLIF(TRIM(cur.A060002), ''), 12) AS GSFZJG,

      # 16. 内部机构号：从 T_1_6.A060002 第12位截取至最后一位
      SUBSTR(NULLIF(TRIM(cur.A060002), ''), 12) AS NBJGH,

      # 17. 客户统一编号：
      #     优先关联对公客户表，其次关联个人客户表，均关联不上则赋空
      COALESCE(
          NULLIF(TRIM(corp.east_cust_id), ''),
          NULLIF(TRIM(person.east_cust_id), '')
      ) AS KHTYBH,

      # 18. 股东或关联方名称：直接取自 T_1_6.A060003
      NULLIF(TRIM(cur.A060003), '') AS GDHGLFMC,

      # 19. 股东或关联方类型：
      #     码值映射：01→自然人(中国公民), 02→自然人(非中国公民), ...
      CASE
          WHEN cur.A060004 = '01' THEN '自然人（中国公民）'
          WHEN cur.A060004 = '02' THEN '自然人（非中国公民）'
          WHEN cur.A060004 = '03' THEN '境内银行业金融机构'
          WHEN cur.A060004 = '04' THEN '境内非银行金融机构'
          WHEN cur.A060004 = '05' THEN '境外银行'
          WHEN cur.A060004 = '06' THEN '金融产品'
          WHEN cur.A060004 IN ('07', '08') THEN '国有控股企业'
          WHEN cur.A060004 IN ('09', '10', '11', '12') THEN '民营企业'
          WHEN cur.A060004 = '13' THEN '政府机关'
          WHEN cur.A060004 = '14' THEN '事业单位'
          WHEN cur.A060004 = '15' THEN '社会团体'
          WHEN cur.A060004 = '16' THEN '境外机构'
          WHEN cur.A060004 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(cur.A060004, 4))
          ELSE NULLIF(TRIM(cur.A060004), '')
      END AS GDHGLFLX,

      # 20. 股东或关联方证件类别：
      #     优先通过代码映射表 YBT-EAST-GDHGLFZJLB 转换；
      #     映射表未命中时回退到 '00-XX'→'其他-XX' 兜底
      COALESCE(
          NULLIF(TRIM(cm.target_desc), ''),
          CASE
              WHEN cur.A060005 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(cur.A060005, 4))
              ELSE NULLIF(TRIM(cur.A060005), '')
          END
      ) AS GDHGLFZJLB,

      # 21. 股东或关联方证件号码：直接取自 T_1_6.A060006
      NULLIF(TRIM(cur.A060006), '') AS GDHGLFZJHM,

      # 22. 股东或关联方所属行业：
      #     如果为 '99999' 则赋值 '境外'，否则直取
      CASE
          WHEN cur.A060007 = '99999' THEN '境外'
          ELSE NULLIF(TRIM(cur.A060007), '')
      END AS SSHY,

      # 23. 实际控制人：如果值为 '0' 时转成 '无'，其他直接映射
      CASE
          WHEN cur.A060010 = '0' THEN '无'
          ELSE NULLIF(TRIM(cur.A060010), '')
      END AS SJKZR,

      # 24. 控股商业银行的数量：直接取 T_1_6.A060012，转 DECIMAL
      CAST(NULLIF(TRIM(cur.A060012), '') AS DECIMAL(20, 0)) AS KGSL,

      # 25. 入股资金账号：直接取自 T_1_6.A060016
      NULLIF(TRIM(cur.A060016), '') AS RGZJZH,

      # 26. 持股比例：直接取 T_1_6.A060019，转 DECIMAL
      CAST(NULLIF(TRIM(cur.A060019), '') AS DECIMAL(20, 6)) AS CGBL,

      # 27. 是否驻派董监事：0→'否', 1→'是'
      CASE
          WHEN cur.A060022 = '0' THEN '否'
          WHEN cur.A060022 = '1' THEN '是'
          ELSE NULLIF(TRIM(cur.A060022), '')
      END AS SFZPDJS,

      # 28. 股东或关联方状态：01→有效, 00→无效
      CASE
          WHEN cur.A060017 = '01' THEN '有效'
          WHEN cur.A060017 = '00' THEN '无效'
          WHEN cur.A060017 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(cur.A060017, 4))
          ELSE NULLIF(TRIM(cur.A060017), '')
      END AS GDHGLFZT,

      # 29. 涉密标志：一表通映射规则文档未提供来源，当前置空
      NULL AS SENSITIVEFLAG

  FROM eligible_t16 cur
  # 关联机构信息：通过 A060002(机构ID) = A010001 获取金融许可证号和银行机构名称
  LEFT JOIN T_1_1 org
         ON org.A010001 = cur.A060002
        AND org.A010020  = TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
  # 关联代码映射表：证件类别转换 YBT-EAST-GDHGLFZJLB
  LEFT JOIN dim_code_mapping cm
         ON cm.src_code     = cur.A060005
        AND cm.rule_id      = 'YBT-EAST-GDHGLFZJLB'
        AND cm.start_date  <= TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
        AND cm.end_date     > TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
  # 关联转 east 后的对公客户表：通过 股东或关联方ID 获取客户统一编号
  LEFT JOIN v_ybt_to_east_corp_cust corp
         ON corp.src_cust_id = cur.A060001
  # 关联转 east 后的个人客户表：通过 股东或关联方ID 获取客户统一编号
  LEFT JOIN v_ybt_to_east_person_cust person
         ON person.src_cust_id = cur.A060001;

  COMMIT;

END;
