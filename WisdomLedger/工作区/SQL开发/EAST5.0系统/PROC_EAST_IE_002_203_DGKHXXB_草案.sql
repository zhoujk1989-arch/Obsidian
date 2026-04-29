/*
业务目标：
- 从一表通单一法人基本情况、同业客户基本情况、集团基本情况及集团成员名单，
  映射生成 EAST5.0 对公客户信息表 IE_002_203（DGKHXXB）。
- 报送模式：全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间
  结清、失效、终结等所有视为终态的数据。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖知识页：
- 原始材料/业务需求/EAST5.0/009_对公客户信息表.md
- 原始材料/表结构/一表通系统/T_2_1-单一法人基本情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_2_3-同业客户基本情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_2_2-集团基本情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_3_3-集团成员名单-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_203-对公客户信息表-DDL-2026-04-28.sql
- 原始材料/语法参考/GBase-8a-MPP-存储过程语法要点.md

源表：
- T_2_1：一表通单一法人基本情况，单一法人客户主源。
- T_2_3：一表通同业客户基本情况，同业客户主源。
- T_2_2：一表通集团基本情况，集团客户主源。
- T_3_3：一表通集团成员名单，集团客户成员关联。
- T_1_1：一表通机构信息，补金融许可证号和银行机构名称。

目标表：
- IE_002_203：EAST5.0 对公客户信息表。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- 需求文档"表级取数与关联规则"中要求以 20+ 个 EAST 表的客户统一编号
  做 UNION ALL 去重后作为纳入范围过滤，但当前一表通源表已含完整客户数据，
  且这些 EAST 表多数尚未落地，故当前实现不对一表通源做客户编号过滤。
  若后续需要纳入范围过滤，可在 UNION ALL 之后加 WHERE KHTYBH IN (子查询1)。
- 集团客户"首次建立信贷关系年月"取成员最早的日期，需要集团成员名单与
  单一法人/同业客户表关联后取 MIN，当前已实现。
- 证件类别中"其他-统一社会信用代码"等码值映射依赖一表通公共代码表，
  当前使用需求文档中给出的码值说明直接映射。
- 采集日期格式转换使用 TO_CHAR(TO_DATE(col, 'YYYY-MM-DD'), 'YYYYMMDD')，
  若源表采集日期字段已是字符串格式，可简化为直接截取。

开发说明：
- 本存储过程按 GBase 8a 生产环境风格编写。
- 不使用 CTE；三大客户类型分别查询后 UNION ALL 合并。
- 不使用 select *；派生表只查询实际使用字段。
- 日期格式转换：源表日期为 YYYY-MM-DD，目标为 YYYYMMDD 字符串。
- 内部机构号：从机构ID第12位开始截取。
*/

CREATE PROCEDURE PROC_EAST_IE_002_203_DGKHXXB(
    IN  I_DATE        VARCHAR(8),
    OUT O_RETCODE     INT,
    OUT O_REMESSAGE   VARCHAR(500)
)
BEGIN

  #声明变量
  DECLARE P_DATE      DATE;
  DECLARE P_PROC_NAME VARCHAR(200);
  DECLARE P_STATUS    INT;
  DECLARE P_START_DT  DATETIME;
  DECLARE P_STEP_NO   INT;
  DECLARE P_DESCB     VARCHAR(200);
  DECLARE P_SQLCDE    VARCHAR(200);
  DECLARE P_STATE     VARCHAR(200);
  DECLARE P_SQLMSG    VARCHAR(2000);

  #声明异常
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1
        P_SQLCDE = GBASE_ERRNO,
        P_SQLMSG = MESSAGE_TEXT,
        P_STATE  = RETURNED_SQLSTATE;
    SET P_STATUS = -1;
    SET P_START_DT = NOW();
    SET P_STEP_NO = P_STEP_NO + 1;
    SET P_DESCB = '程序异常';
    CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                          P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);
    ROLLBACK;
  END;

  #变量初始化
  SET P_DATE = TO_DATE(I_DATE, 'YYYYMMDD');
  SET P_PROC_NAME = 'PROC_EAST_IE_002_203_DGKHXXB';
  SET P_STATUS = 0;
  SET P_STEP_NO = 0;

  #1. 过程开始执行
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '过程开始执行';
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

  #2. 清除数据
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '清除数据';
  DELETE FROM IE_002_203 WHERE CJRQ = I_DATE;
  COMMIT;
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

  #3. 插入数据
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '数据插入';

  INSERT INTO IE_002_203 (
    JRXKZH,
    NBJGH,
    YHJGMC,
    KHTYBH,
    KHMC,
    KHTX,
    ZJLB,
    ZJHM,
    FRDB,
    FRDBZJLB,
    FRDBZJHM,
    CWFZR,
    CWFZRZJLB,
    CWFZRZJHM,
    JBCKZH,
    JBCKZHKHHH,
    JBCKZHKHHMC,
    ZCZB,
    ZCZBBZ,
    SSZB,
    SSZBBZ,
    ZCDZ,
    LXDH,
    JYFW,
    CLRQ,
    SSHY,
    QYFL,
    XDKHBZ,
    SCJLXDGXNY,
    SSGSBZ,
    XYPJ,
    YGRS,
    XZQHDM,
    FXYJXH,
    GZSJDM,
    BBZ,
    CJRQ
  )
  SELECT
    # 1. 金融许可证号：用机构ID关联机构信息表取金融许可证号
    NULLIF(TRIM(org.A010003), '') AS JRXKZH,

    # 2. 内部机构号：从机构ID第12位开始截取
    SUBSTR(CASE cust_type WHEN '1' THEN single.B010002
                           WHEN '2' THEN tony.B030002
                           WHEN '3' THEN grp.B020002
                      END, 12) AS NBJGH,

    # 3. 银行机构名称：用机构ID关联机构信息表取银行机构名称
    NULLIF(TRIM(org.A010005), '') AS YHJGMC,

    # 4. 客户统一编号
    CASE cust_type
      WHEN '1' THEN single.B010001
      WHEN '2' THEN tony.B030001
      WHEN '3' THEN grp.B020001
    END AS KHTYBH,

    # 5. 客户名称
    CASE cust_type
      WHEN '1' THEN single.B010003
      WHEN '2' THEN tony.B030003
      WHEN '3' THEN grp.B020007
    END AS KHMC,

    # 6. 客户类型：单一法人/同业客户/集团客户
    CASE cust_type
      WHEN '1' THEN '单一法人客户'
      WHEN '2' THEN '同业客户'
      WHEN '3' THEN '集团客户'
    END AS KHTX,

    # 7. 证件类别：按客户类型分别取
    CASE cust_type
      # 单一法人：统一社会信用代码优先，否则其他证件类型
      WHEN '1' THEN
        CASE
          WHEN NULLIF(TRIM(single.B010004), '') IS NOT NULL THEN '统一社会信用代码'
          WHEN single.B010062 = '01' THEN '组织机构代码'
          WHEN single.B010062 = '02' THEN '营业执照（工商注册号）'
          WHEN single.B010062 = '03' THEN '公司注册证书'
          WHEN single.B010062 = '04' THEN '全球法人识别码'
          WHEN single.B010062 LIKE '00%' THEN '其他' || SUBSTR(single.B010062, 3)
          ELSE NULLIF(TRIM(single.B010062), '')
        END
      # 同业客户：优先统一社会信用代码，其次金融许可证，其次SWIFT，其次其他证件类型，最后银行机构代码
      WHEN '2' THEN
        CASE
          WHEN NULLIF(TRIM(tony.B030007), '') IS NOT NULL THEN '其他-统一社会信用代码'
          WHEN NULLIF(TRIM(tony.B030005), '') IS NOT NULL THEN '金融许可证件号码'
          WHEN NULLIF(TRIM(tony.B030006), '') IS NOT NULL THEN 'SWIFT编码'
          WHEN tony.B030039 LIKE '00%' AND tony.B030039 <> '00-统一社会信用代码'
            THEN '其他' || SUBSTR(tony.B030039, 3)
          WHEN NULLIF(TRIM(tony.B030039), '') IS NOT NULL THEN NULLIF(TRIM(tony.B030039), '')
          WHEN NULLIF(TRIM(tony.B030040), '') IS NOT NULL THEN '银行机构代码'
          ELSE NULL
        END
      # 集团客户：通过母公司客户ID关联单一法人取证件信息
      WHEN '3' THEN
        CASE
          WHEN NULLIF(TRIM(parent.B010004), '') IS NOT NULL THEN '统一社会信用代码'
          WHEN parent.B010062 = '01' THEN '组织机构代码'
          WHEN parent.B010062 = '02' THEN '营业执照（工商注册号）'
          WHEN parent.B010062 = '03' THEN '公司注册证书'
          WHEN parent.B010062 = '04' THEN '全球法人识别码'
          WHEN parent.B010062 LIKE '00%' THEN '其他' || SUBSTR(parent.B010062, 3)
          ELSE NULL
        END
    END AS ZJLB,

    # 8. 证件号码：取证件类别对应的证件号码
    CASE cust_type
      WHEN '1' THEN
        CASE
          WHEN NULLIF(TRIM(single.B010004), '') IS NOT NULL THEN single.B010004
          ELSE NULLIF(TRIM(single.B010063), '')
        END
      WHEN '2' THEN
        CASE
          WHEN NULLIF(TRIM(tony.B030007), '') IS NOT NULL THEN tony.B030007
          WHEN NULLIF(TRIM(tony.B030005), '') IS NOT NULL THEN tony.B030005
          WHEN NULLIF(TRIM(tony.B030006), '') IS NOT NULL THEN tony.B030006
          WHEN tony.B030039 LIKE '00%' AND tony.B030039 <> '00-统一社会信用代码'
            THEN tony.B030040
          WHEN NULLIF(TRIM(tony.B030039), '') IS NOT NULL THEN tony.B030040
          ELSE NULL
        END
      WHEN '3' THEN
        # 集团客户取母公司统一社会信用代码
        NULLIF(TRIM(grp.B020003), '')
    END AS ZJHM,

    # 9. 法人代表
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010032), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030013), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010032), '')
    END AS FRDB,

    # 10. 法人代表证件类别
    CASE cust_type
      WHEN '1' THEN
        CASE
          WHEN single.B010033 = '01' THEN '组织机构代码'
          WHEN single.B010033 = '02' THEN '营业执照（工商注册号）'
          WHEN single.B010033 = '03' THEN '公司注册证书'
          WHEN single.B010033 = '04' THEN '全球法人识别码'
          WHEN single.B010033 LIKE '00%' THEN '其他' || SUBSTR(single.B010033, 3)
          ELSE NULLIF(TRIM(single.B010033), '')
        END
      WHEN '2' THEN
        CASE
          WHEN tony.B030014 = '01' THEN '组织机构代码'
          WHEN tony.B030014 = '02' THEN '营业执照（工商注册号）'
          WHEN tony.B030014 = '03' THEN '公司注册证书'
          WHEN tony.B030014 = '04' THEN '全球法人识别码'
          WHEN tony.B030014 LIKE '00%' THEN '其他' || SUBSTR(tony.B030014, 3)
          ELSE NULLIF(TRIM(tony.B030014), '')
        END
      WHEN '3' THEN
        CASE
          WHEN parent.B010033 = '01' THEN '组织机构代码'
          WHEN parent.B010033 = '02' THEN '营业执照（工商注册号）'
          WHEN parent.B010033 = '03' THEN '公司注册证书'
          WHEN parent.B010033 = '04' THEN '全球法人识别码'
          WHEN parent.B010033 LIKE '00%' THEN '其他' || SUBSTR(parent.B010033, 3)
          ELSE NULLIF(TRIM(parent.B010033), '')
        END
    END AS FRDBZJLB,

    # 11. 法人代表证件号码
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010034), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030015), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010034), '')
    END AS FRDBZJHM,

    # 12. 财务负责人
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010035), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030016), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010035), '')
    END AS CWFZR,

    # 13. 财务负责人证件类别
    CASE cust_type
      WHEN '1' THEN
        CASE
          WHEN single.B010036 = '01' THEN '组织机构代码'
          WHEN single.B010036 = '02' THEN '营业执照（工商注册号）'
          WHEN single.B010036 = '03' THEN '公司注册证书'
          WHEN single.B010036 = '04' THEN '全球法人识别码'
          WHEN single.B010036 LIKE '00%' THEN '其他' || SUBSTR(single.B010036, 3)
          ELSE NULLIF(TRIM(single.B010036), '')
        END
      WHEN '2' THEN
        CASE
          WHEN tony.B030017 = '01' THEN '组织机构代码'
          WHEN tony.B030017 = '02' THEN '营业执照（工商注册号）'
          WHEN tony.B030017 = '03' THEN '公司注册证书'
          WHEN tony.B030017 = '04' THEN '全球法人识别码'
          WHEN tony.B030017 LIKE '00%' THEN '其他' || SUBSTR(tony.B030017, 3)
          ELSE NULLIF(TRIM(tony.B030017), '')
        END
      WHEN '3' THEN
        CASE
          WHEN parent.B010036 = '01' THEN '组织机构代码'
          WHEN parent.B010036 = '02' THEN '营业执照（工商注册号）'
          WHEN parent.B010036 = '03' THEN '公司注册证书'
          WHEN parent.B010036 = '04' THEN '全球法人识别码'
          WHEN parent.B010036 LIKE '00%' THEN '其他' || SUBSTR(parent.B010036, 3)
          ELSE NULLIF(TRIM(parent.B010036), '')
        END
    END AS CWFZRZJLB,

    # 14. 财务负责人证件号码
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010037), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030018), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010037), '')
    END AS CWFZRZJHM,

    # 15. 基本存款账号
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010038), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030019), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010038), '')
    END AS JBCKZH,

    # 16. 基本存款账户开户行号
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010039), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030020), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010039), '')
    END AS JBCKZHKHHH,

    # 17. 基本存款账户开户行名称
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010040), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030021), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010040), '')
    END AS JBCKZHKHHMC,

    # 18. 注册资本
    CASE cust_type
      WHEN '1' THEN single.B010019
      WHEN '2' THEN tony.B030022
      WHEN '3' THEN parent.B010019
    END AS ZCZB,

    # 19. 注册资本币种
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010020), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030023), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010020), '')
    END AS ZCZBBZ,

    # 20. 实收资本
    CASE cust_type
      WHEN '1' THEN single.B010021
      WHEN '2' THEN tony.B030024
      WHEN '3' THEN parent.B010021
    END AS SSZB,

    # 21. 实收资本币种
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010022), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030025), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010022), '')
    END AS SSZBBZ,

    # 22. 注册地址
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010029), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030010), '')
      WHEN '3' THEN NULLIF(TRIM(grp.B020009), '')
    END AS ZCDZ,

    # 23. 联系电话
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010031), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030029), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010031), '')
    END AS LXDH,

    # 24. 经营范围
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010024), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030008), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010024), '')
    END AS JYFW,

    # 25. 成立日期：yyyy-mm-dd 转为 yyyymmdd
    CASE cust_type
      WHEN '1' THEN
        CASE
          WHEN single.B010023 IS NOT NULL
            THEN TO_CHAR(TO_DATE(single.B010023, 'YYYY-MM-DD'), 'YYYYMMDD')
          ELSE NULL
        END
      WHEN '2' THEN
        CASE
          WHEN tony.B030009 IS NOT NULL
            THEN TO_CHAR(TO_DATE(tony.B030009, 'YYYY-MM-DD'), 'YYYYMMDD')
          ELSE NULL
        END
      WHEN '3' THEN
        CASE
          WHEN parent.B010023 IS NOT NULL
            THEN TO_CHAR(TO_DATE(parent.B010023, 'YYYY-MM-DD'), 'YYYYMMDD')
          ELSE NULL
        END
    END AS CLRQ,

    # 26. 所属行业
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010025), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030041), '')
      WHEN '3' THEN NULLIF(TRIM(parent.B010025), '')
    END AS SSHY,

    # 27. 企业分类
    CASE cust_type
      WHEN '1' THEN
        CASE single.B010026
          WHEN '01' THEN '大型企业'
          WHEN '02' THEN '中型企业'
          WHEN '03' THEN '小型企业'
          WHEN '04' THEN '微型企业'
          WHEN '05' THEN '政府机关'
          WHEN '06' THEN '事业单位'
          WHEN '07' THEN '社会团体'
          WHEN '08' THEN '其他-其他组织机构'
          WHEN '09' THEN '其他-个体工商户'
          WHEN '10' THEN '境外机构'
          WHEN single.B010026 LIKE '00%' THEN '其他' || SUBSTR(single.B010026, 3)
          ELSE NULL
        END
      WHEN '2' THEN
        CASE tony.B030037
          WHEN '01' THEN '大型企业'
          WHEN '02' THEN '中型企业'
          WHEN '03' THEN '小型企业'
          WHEN '04' THEN '微型企业'
          WHEN '05' THEN '政府机关'
          WHEN '06' THEN '事业单位'
          WHEN '07' THEN '社会团体'
          WHEN '08' THEN '其他-其他组织机构'
          WHEN '09' THEN '其他-个体工商户'
          WHEN '10' THEN '境外机构'
          WHEN tony.B030037 LIKE '00%' THEN '其他' || SUBSTR(tony.B030037, 3)
          ELSE NULL
        END
      WHEN '3' THEN NULL
    END AS QYFL,

    # 28. 信贷客户标志：首次建立信贷关系年月不为空且不为9999-12则取'是'
    CASE cust_type
      WHEN '1' THEN
        CASE
          WHEN single.B010048 IS NOT NULL AND LENGTH(TRIM(single.B010048)) > 0
               AND TRIM(single.B010048) <> '999912'
            THEN '是'
          ELSE '否'
        END
      WHEN '2' THEN
        CASE
          WHEN tony.B030033 IS NOT NULL AND LENGTH(TRIM(tony.B030033)) > 0
               AND TRIM(tony.B030033) <> '999912'
            THEN '是'
          ELSE '否'
        END
      WHEN '3' THEN
        CASE
          WHEN earliest_credit_date IS NOT NULL
               AND LENGTH(TRIM(earliest_credit_date)) > 0
               AND TRIM(earliest_credit_date) <> '999912'
            THEN '是'
          ELSE '否'
        END
    END AS XDKHBZ,

    # 29. 首次建立信贷关系年月
    CASE cust_type
      WHEN '1' THEN
        # 直接映射，保留 YYYYMM 格式（源为 YYYY-MM，截取前6位）
        CASE
          WHEN single.B010048 IS NOT NULL THEN SUBSTR(TRIM(single.B010048), 1, 6)
          ELSE NULL
        END
      WHEN '2' THEN
        # 直接映射
        CASE
          WHEN tony.B030033 IS NOT NULL THEN SUBSTR(TRIM(tony.B030033), 1, 6)
          ELSE NULL
        END
      WHEN '3' THEN
        # 集团客户取成员最早的日期
        earliest_credit_date
    END AS SCJLXDGXNY,

    # 30. 上市公司标志
    CASE cust_type
      WHEN '1' THEN
        CASE
          WHEN NULLIF(TRIM(single.B010042), '') <> '' THEN '是'
          ELSE '否'
        END
      WHEN '2' THEN
        CASE
          WHEN tony.B030026 = '1' THEN '是'
          ELSE '否'
        END
      WHEN '3' THEN '否'
    END AS SSGSBZ,

    # 31. 信用评级：外部评级优先，否则内部评级
    CASE cust_type
      WHEN '1' THEN
        COALESCE(NULLIF(TRIM(single.B010044), ''), NULLIF(TRIM(single.B010046), ''))
      WHEN '2' THEN
        COALESCE(NULLIF(TRIM(tony.B030030), ''), NULLIF(TRIM(tony.B030032), ''))
      WHEN '3' THEN
        NULLIF(TRIM(grp.B020018), '')
    END AS XYPJ,

    # 32. 员工人数
    CASE cust_type
      WHEN '1' THEN single.B010041
      WHEN '2' THEN tony.B030027
      WHEN '3' THEN COALESCE(parent_emp_total, 0)
    END AS YGRS,

    # 33. 行政区划代码
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010030), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030012), '')
      WHEN '3' THEN NULLIF(TRIM(grp.B020011), '')
    END AS XZQHDM,

    # 34. 风险预警信号
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010049), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030034), '')
      WHEN '3' THEN NULLIF(TRIM(grp.B020016), '')
    END AS FXYJXH,

    # 35. 关注事件代码
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010050), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030035), '')
      WHEN '3' THEN NULLIF(TRIM(grp.B020017), '')
    END AS GZSJDM,

    # 36. 备注
    CASE cust_type
      WHEN '1' THEN NULLIF(TRIM(single.B010065), '')
      WHEN '2' THEN NULLIF(TRIM(tony.B030043), '')
      WHEN '3' THEN NULLIF(TRIM(grp.B020021), '')
    END AS BBZ,

    # 37. 采集日期：转为 YYYYMMDD 格式
    CASE cust_type
      WHEN '1' THEN TO_CHAR(TO_DATE(single.B010060, 'YYYY-MM-DD'), 'YYYYMMDD')
      WHEN '2' THEN TO_CHAR(TO_DATE(tony.B030036, 'YYYY-MM-DD'), 'YYYYMMDD')
      WHEN '3' THEN TO_CHAR(TO_DATE(grp.B020019, 'YYYY-MM-DD'), 'YYYYMMDD')
    END AS CJRQ

  FROM (
    # 子查询：三大客户类型合并源
    SELECT
      '1' AS cust_type,
      s.B010001,
      s.B010002,
      s.B010003,
      s.B010004,
      s.B010023,
      s.B010019,
      s.B010020,
      s.B010021,
      s.B010022,
      s.B010024,
      s.B010025,
      s.B010026,
      s.B010029,
      s.B010030,
      s.B010031,
      s.B010032,
      s.B010033,
      s.B010034,
      s.B010035,
      s.B010036,
      s.B010037,
      s.B010038,
      s.B010039,
      s.B010040,
      s.B010041,
      s.B010042,
      s.B010044,
      s.B010046,
      s.B010048,
      s.B010049,
      s.B010050,
      s.B010060,
      s.B010062,
      s.B010063,
      NULL AS B030007,
      NULL AS B030005,
      NULL AS B030006,
      NULL AS B030039,
      NULL AS B030040,
      NULL AS B030008,
      NULL AS B030009,
      NULL AS B030010,
      NULL AS B030012,
      NULL AS B030013,
      NULL AS B030014,
      NULL AS B030015,
      NULL AS B030016,
      NULL AS B030017,
      NULL AS B030018,
      NULL AS B030019,
      NULL AS B030020,
      NULL AS B030021,
      NULL AS B030022,
      NULL AS B030023,
      NULL AS B030024,
      NULL AS B030025,
      NULL AS B030026,
      NULL AS B030027,
      NULL AS B030029,
      NULL AS B030033,
      NULL AS B030034,
      NULL AS B030035,
      NULL AS B030041,
      NULL AS B030037,
      NULL AS B030043,
      NULL AS parent_B010004,
      NULL AS parent_B010032,
      NULL AS parent_B010033,
      NULL AS parent_B010034,
      NULL AS parent_B010035,
      NULL AS parent_B010036,
      NULL AS parent_B010037,
      NULL AS parent_B010019,
      NULL AS parent_B010020,
      NULL AS parent_B010021,
      NULL AS parent_B010022,
      NULL AS parent_B010023,
      NULL AS parent_B010024,
      NULL AS parent_B010025,
      NULL AS parent_B010030,
      NULL AS parent_B010031,
      NULL AS parent_B010038,
      NULL AS parent_B010039,
      NULL AS parent_B010040,
      NULL AS parent_B010041,
      NULL AS earliest_credit_date,
      NULL AS parent_emp_total
    FROM T_2_1 s
    WHERE s.B010060 = P_DATE

    UNION ALL

    SELECT
      '2' AS cust_type,
      t.B030001,
      t.B030002,
      t.B030003,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      t.B030036,
      NULL,
      NULL,
      t.B030007,
      t.B030005,
      t.B030006,
      t.B030039,
      t.B030040,
      t.B030008,
      t.B030009,
      t.B030010,
      t.B030012,
      t.B030013,
      t.B030014,
      t.B030015,
      t.B030016,
      t.B030017,
      t.B030018,
      t.B030019,
      t.B030020,
      t.B030021,
      t.B030022,
      t.B030023,
      t.B030024,
      t.B030025,
      t.B030026,
      t.B030027,
      t.B030029,
      t.B030033,
      t.B030034,
      t.B030035,
      t.B030041,
      t.B030037,
      t.B030043,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL
    FROM T_2_3 t
    WHERE t.B030036 = P_DATE

    UNION ALL

    SELECT
      '3' AS cust_type,
      grp.B020001,
      grp.B020002,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      grp.B020009,
      grp.B020011,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      grp.B020019,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      grp.B020018,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      parent.B010004,
      parent.B010032,
      parent.B010033,
      parent.B010034,
      parent.B010035,
      parent.B010036,
      parent.B010037,
      parent.B010019,
      parent.B010020,
      parent.B010021,
      parent.B010022,
      parent.B010023,
      parent.B010024,
      parent.B010025,
      parent.B010030,
      parent.B010031,
      parent.B010038,
      parent.B010039,
      parent.B010040,
      parent.B010041,
      mem_earliest.credit_date AS earliest_credit_date,
      mem_agg.emp_total AS parent_emp_total
    FROM T_2_2 grp
    LEFT JOIN T_2_1 parent
      ON parent.B010001 = grp.B020020
     AND parent.B010060 = P_DATE
    LEFT JOIN (
      # 集团客户首次建立信贷关系年月：取成员最早日期
      SELECT
        mc.C030007 AS集团ID,
        MIN(
          CASE
            WHEN sc.B010048 IS NOT NULL AND LENGTH(TRIM(sc.B010048)) > 0
              THEN SUBSTR(TRIM(sc.B010048), 1, 6)
            WHEN tny.B030033 IS NOT NULL AND LENGTH(TRIM(tony.B030033)) > 0
              THEN SUBSTR(TRIM(tony.B030033), 1, 6)
            ELSE NULL
          END
        ) AS credit_date
      FROM T_3_3 mc
      LEFT JOIN T_2_1 sc
        ON sc.B010001 = mc.C030002
       AND sc.B010060 = P_DATE
      LEFT JOIN T_2_3 tny
        ON tny.B030001 = mc.C030002
       AND tny.B030036 = P_DATE
      WHERE mc.C030010 = P_DATE
      GROUP BY mc.C030007
    ) mem_earliest
      ON mem_earliest.集团ID = grp.B020001
    LEFT JOIN (
      # 集团客户员工人数汇总：汇总所有成员的员工人数
      SELECT
        mc.C030007 AS集团ID,
        SUM(
          CASE
            WHEN sc.B010041 IS NOT NULL THEN sc.B010041
            ELSE 0
          END
        ) AS emp_total
      FROM T_3_3 mc
      LEFT JOIN T_2_1 sc
        ON sc.B010001 = mc.C030002
       AND sc.B010060 = P_DATE
      WHERE mc.C030010 = P_DATE
      GROUP BY mc.C030007
    ) mem_agg
      ON mem_agg.集团ID = grp.B020001
    WHERE grp.B020019 = P_DATE
  ) cust_data

  # 关联机构信息表：取金融许可证号和银行机构名称
  LEFT JOIN (
    SELECT
      org.A010001,
      org.A010003,
      org.A010005
    FROM T_1_1 org
    WHERE org.A010020 = P_DATE
      AND NOT EXISTS (
        SELECT 1
        FROM T_1_1 org_rank
        WHERE org_rank.A010020 = P_DATE
          AND org_rank.A010001 = org.A010001
          AND (
            org_rank.A010020 > org.A010020
            OR (
              org_rank.A010020 = org.A010020
              AND org_rank.A010002 < org.A010002
            )
          )
      )
  ) org
    ON org.A010001 = CASE cust_type
                      WHEN '1' THEN cust_data.B010002
                      WHEN '2' THEN cust_data.B030002
                      WHEN '3' THEN cust_data.B020002
                    END

  WHERE cust_type IN ('1', '2', '3');

  COMMIT;
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

  #4. 过程结束执行
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '过程结束执行';
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);
  SET O_RETCODE = P_STATUS;
  SET O_REMESSAGE = P_DESCB;

END;
