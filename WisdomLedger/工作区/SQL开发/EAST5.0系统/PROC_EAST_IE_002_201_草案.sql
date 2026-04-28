/*
业务目标：
- 从一表通个人客户基本情况 T_2_5 映射生成 EAST5.0 个人基础信息表 IE_002_201。
- 报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。
- 报送范围：从 23 张 EAST 业务表 + 担保人补集中取当期有效客户统一编号，再关联 T_2_5 取客户信息。

目标系统：
- EAST5.0系统。

目标产物：
- MySQL 存储过程草案。

依赖知识页：
- [[来源-EAST5.0系统-IE_002_201-个人基础信息表]]
- [[数据表-IE_002_201-个人基础信息表-EAST5.0系统]]
- [[来源-一表通系统-2.5-个人客户基本情况]]
- [[数据表-T_2_5-个人客户基本情况-一表通系统]]
- [[概念-系统-EAST5.0系统]]
- [[概念-系统-一表通系统]]

源表：
- T_2_5：一表通 个人客户基本情况，主源表。
- T_1_1：一表通 机构信息，通过机构ID关联取金融许可证号、银行机构名称。
- T_10_1：一表通 公共代码，用于国籍、学历码值转换。
- IE_001_106 ~ IE_010_1005_INC：23 张 EAST 业务表，取当期客户统一编号圈定报送范围。
- IE_006_601 + T_6_8：担保合同 + 担保协议，补集担保人客户。

目标表：
- IE_002_201：EAST5.0 个人基础信息表。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。
- I_BATCH_NO：批次号/任务流水号。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- 同一客户在 T_2_5 中跨多机构的去重策略：当前按 KHTYBH 分组取 MIN(机构ID) 对应的记录，可能丢失部分机构维度信息。如需保留多机构记录，目标表 PK 需要调整为 (KHTYBH, NBJGH, CJRQ)。
- 内部机构号"从第12位开始截取"需确认 T_2_5.B050002 机构ID 的实际格式和截取逻辑。
- T_2_5.B050033 是"农户及新型农业经营主体标识"，需求文档写"农户标识"，字段映射可能存在偏差。
- GSFZJG（归属分支机构）、SENSITIVEFLAG（涉密标志）当前无映射来源，仍置空。
- 23 张 EAST 表中对公存款分户账 IE_004_405 的 KHTYBH 字段注释关联对公客户信息表（非个人），按需求文档仍需纳入。
- T_2_5 的 采集日期是 DATE 类型，与 EAST 目标表 VARCHAR(8) 的 CJRQ 对比时需注意类型转换。
- 学历字段需求文档要求通过公共代码表转换，但 T_2_5.B050011 直接存储的是 varchar(30)，可能与代码表不一致。
*/

DELIMITER $$

CREATE PROCEDURE `PROC_EAST_IE_002_201`(
    IN I_DATE VARCHAR(8),
    IN I_BATCH_NO VARCHAR(64)
)
BEGIN
    -- 声明变量
    DECLARE V_DATA_DATE DATE;
    DECLARE V_DELETE_COUNT INT DEFAULT 0;
    DECLARE V_INSERT_COUNT INT DEFAULT 0;
    DECLARE V_PROC_NAME VARCHAR(200) DEFAULT 'PROC_EAST_IE_002_201';
    DECLARE V_STATUS INT DEFAULT 0;
    DECLARE V_START_DT DATETIME;
    DECLARE V_STEP_NO INT DEFAULT 0;
    DECLARE V_DESCB VARCHAR(200);
    DECLARE P_SQLCDE VARCHAR(200);
    DECLARE P_STATE VARCHAR(200);
    DECLARE P_SQLMSG VARCHAR(2000);

    -- 异常处理器
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 P_SQLCDE = GBASE_ERRNO, P_SQLMSG = MESSAGE_TEXT, P_STATE = RETURNED_SQLSTATE;
        SET V_STATUS = -1;
        SET V_STEP_NO = V_STEP_NO + 1;
        SET V_DESCB = '程序异常';
        -- 日志写入占位：CALL PROC_ETL_JOB_LOG(...)
        ROLLBACK;
        RESIGNAL;
    END;

    -- 事务开始
    START TRANSACTION;

    -- 初始化日期变量
    SET V_DATA_DATE = STR_TO_DATE(I_DATE, '%Y%m%d');

    -- ============================================================
    -- 1. 清理区：删除目标表当期数据，保证幂等
    -- ============================================================
    SET V_START_DT = NOW();
    SET V_STEP_NO = V_STEP_NO + 1;
    SET V_DESCB = '删除目标表当期数据';

    DELETE FROM IE_002_201
     WHERE CJRQ = I_DATE;

    SET V_DELETE_COUNT = ROW_COUNT();

    -- ============================================================
    -- 2. 主加工区：客户范围圈定 + 字段映射
    -- ============================================================
    SET V_START_DT = NOW();
    SET V_STEP_NO = V_STEP_NO + 1;
    SET V_DESCB = '主加工：客户范围圈定并映射个人基础信息';

    INSERT INTO IE_002_201 (
        JRXKZH,
        NBJGH,
        YHJGMC,
        KHTYBH,
        KHXM,
        ZJLB,
        ZJHM,
        BXYGBZ,
        GJHDQ,
        MZ,
        XB,
        XL,
        CSNY,
        SFYH,
        GZDWMC,
        GZDWDZ,
        GZDWDH,
        DWXZ,
        ZY,
        ZW,
        GRNSR,
        TXDZ,
        LXDH,
        XDKHBZ,
        SCJLXDGXNY,
        SFNH,
        BHYGBZ,
        SHMDBZ,
        SHMDRQ,
        BBZ,
        CJRQ,
        SENSITIVEFLAG,
        GSFZJG
    )
    WITH
    -- ============================================================
    -- CTE-1: 子查询1 — 从 23 张 EAST 业务表 UNION ALL 取当期有效客户统一编号
    -- ============================================================
    cust_scope_raw AS (
        -- 1. 股东及关联方信息表
        SELECT KHTYBH FROM IE_001_106 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 2. 借记卡信息表
        SELECT KHTYBH FROM IE_003_301 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 3. 存折信息表
        SELECT KHTYBH FROM IE_003_302 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 4. 个人存款分户账
        SELECT KHTYBH FROM IE_004_403 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 5. 对公存款分户账
        SELECT KHTYBH FROM IE_004_405 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 6. 个人信贷分户账
        SELECT KHTYBH FROM IE_004_409 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 7. 对公信贷分户账
        SELECT KHTYBH FROM IE_004_411 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 8. 信贷合同表
        SELECT KHTYBH FROM IE_005_501 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 9. 授信信息表
        SELECT KHTYBH FROM IE_007_701 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 10. 资产核销表
        SELECT KHTYBH FROM IE_007_702 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 11. 贷款五级形态变动表
        SELECT KHTYBH FROM IE_007_705_INC WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 12. 信用卡信息表
        SELECT KHTYBH FROM IE_008_801 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 13. 信用卡授信情况表
        SELECT KHTYBH FROM IE_008_803 WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 14. 信用卡交易明细表
        SELECT KHTYBH FROM IE_008_802_INC WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 15. 保函与信用证表（字段名：SQRBH 申请人编号）
        SELECT SQRBH AS KHTYBH FROM IE_009_902 WHERE SQRBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 16. 委托贷款信息表（字段名：WTRBH 委托人编号）
        SELECT WTRBH AS KHTYBH FROM IE_009_904 WHERE WTRBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 17. 代理代销交易信息表
        SELECT KHTYBH FROM IE_009_905_INC WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 18. 即期及衍生品交易信息表（字段名：MFKHTYBH2 买方客户统一编号）
        SELECT MFKHTYBH2 AS KHTYBH FROM IE_010_1005_INC WHERE MFKHTYBH2 IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 19. 个人存款分户账明细
        SELECT KHTYBH FROM IE_004_404_INC WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 20. 对公存款分户账明细
        SELECT KHTYBH FROM IE_004_406_INC WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 21. 个人信贷分户账明细
        SELECT KHTYBH FROM IE_004_410_INC WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
        UNION ALL
        -- 22. 对公信贷分户账明细
        SELECT KHTYBH FROM IE_004_412_INC WHERE KHTYBH IS NOT NULL AND CJRQ = I_DATE
    ),

    -- ============================================================
    -- CTE-2: 担保人补集 — 表内外业务担保合同表 LEFT JOIN 一表通担保协议
    --   关联条件：
    --     IE_006_601.DBHTH  = T_6_8.F080001  (担保合同号 = 协议ID)
    --     IE_006_601.BDBHTH = T_6_8.F080003  (被担保合同号 = 被担保协议ID)
    --     T_6_8.F080004 IN ('03','04','05','06') (担保类型)
    -- ============================================================
    cust_scope_guar AS (
        SELECT DISTINCT g.F080028 AS KHTYBH
        FROM IE_006_601 d
        INNER JOIN T_6_8 g
            ON d.DBHTH  = g.F080001
           AND d.BDBHTH = g.F080003
        WHERE d.CJRQ = I_DATE
          AND g.F080004 IN ('03','04','05','06')
          AND g.F080028 IS NOT NULL
    ),

    -- ============================================================
    -- CTE-3: 最终客户范围 — 子查询1 UNION ALL 担保人补集，然后 GROUP BY 去重
    -- ============================================================
    cust_scope AS (
        SELECT DISTINCT KHTYBH
        FROM (
            SELECT KHTYBH FROM cust_scope_raw
            UNION ALL
            SELECT KHTYBH FROM cust_scope_guar
        ) t
    ),

    -- ============================================================
    -- CTE-4: 个人客户信息主源 — 取 T_2_5 当期有效数据，按 KHTYBH 去重
    --   同一客户跨多机构时，按机构ID排序取第一条（策略见未确认点）
    --   有效数据：失效日期为 NULL 或失效日期 >= 上一采集日
    -- ============================================================
    cust_info AS (
        SELECT *
        FROM (
            SELECT
                t.B050001,  -- 客户ID
                t.B050002,  -- 机构ID
                t.B050003,  -- 个人客户名称
                t.B050004,  -- 个人客户类型
                t.B050005,  -- 客户身份证
                t.B050006,  -- 客户护照号
                t.B050007,  -- 客户其他证件类型
                t.B050008,  -- 客户其他证件号码
                t.B050009,  -- 民族
                t.B050010,  -- 性别
                t.B050011,  -- 学历
                t.B050012,  -- 出生日期
                t.B050013,  -- 已婚标识
                t.B050014,  -- 电话1
                t.B050015,  -- 电话2
                t.B050016,  -- 工作单位名称
                t.B050017,  -- 工作单位电话
                t.B050018,  -- 工作单位地址
                t.B050019,  -- 单位性质
                t.B050020,  -- 职业
                t.B050021,  -- 职务
                t.B050022,  -- 个人年收入
                t.B050024,  -- 通讯地址
                t.B050026,  -- 本行员工标识
                t.B050027,  -- 首次建立信贷关系年月
                t.B050028,  -- 上本行黑名单标识
                t.B050029,  -- 上黑名单日期
                t.B050033,  -- 农户及新型农业经营主体标识
                t.B050039,  -- 备注
                t.B050038,  -- 失效日期
                ROW_NUMBER() OVER (
                    PARTITION BY t.B050001
                    ORDER BY t.B050002  -- 按机构ID排序取第一条
                ) AS rn
            FROM T_2_5 t
            WHERE t.B050036 = V_DATA_DATE  -- 采集日期 = 当期
              AND (t.B050038 IS NULL OR t.B050038 >= DATE_SUB(V_DATA_DATE, INTERVAL 1 DAY))
                -- 失效日期为空（有效）或失效日期 >= 上一采集日（终态仍报送）
        ) ranked
        WHERE rn = 1
    ),

    -- ============================================================
    -- CTE-5: 机构信息维表 — 取当期有效机构信息
    -- ============================================================
    org_info AS (
        SELECT DISTINCT
            t.A010002,  -- 内部机构号
            t.A010003,  -- 金融许可证号
            t.A010005   -- 银行机构名称
        FROM T_1_1 t
        WHERE t.A010020 = V_DATA_DATE
    ),

    -- ============================================================
    -- CTE-6: 公共代码 — 国籍（国家地区）码值
    --   过滤：表名='通用', 字段名='国家地区'
    -- ============================================================
    code_nation AS (
        SELECT
            t.K010004,  -- 代码
            t.K010005   -- 中文含义
        FROM T_10_1 t
        WHERE t.K010002 = '通用'
          AND t.K010003 = '国家地区'
    ),

    -- ============================================================
    -- CTE-7: 公共代码 — 学历码值
    --   过滤：表名='通用', 字段名='学历'
    -- ============================================================
    code_edu AS (
        SELECT
            t.K010004,  -- 代码
            t.K010005   -- 中文含义
        FROM T_10_1 t
        WHERE t.K010002 = '通用'
          AND t.K010003 = '学历'
    )

    -- ============================================================
    -- 主 SELECT：字段映射
    -- ============================================================
    SELECT
        -- 1. 金融许可证号：通过机构ID关联机构信息表
        NULLIF(TRIM(org.A010003), '') AS JRXKZH,

        -- 2. 内部机构号：机构ID 从第12位开始截取
        --    TODO: 需确认 SUBSTR(B050002, 12) 是否准确
        SUBSTR(cust.B050002, 12) AS NBJGH,

        -- 3. 银行机构名称：通过机构ID关联机构信息表
        NULLIF(TRIM(org.A010005), '') AS YHJGMC,

        -- 4. 客户统一编号
        cust.B050001 AS KHTYBH,

        -- 5. 客户姓名
        cust.B050003 AS KHXM,

        -- 6. 证件类别：客户身份证不为空 → '居民身份证'；护照不为空 → '护照'；否则取其他证件类型
        CASE
            WHEN NULLIF(TRIM(cust.B050005), '') IS NOT NULL THEN '居民身份证'
            WHEN NULLIF(TRIM(cust.B050006), '') IS NOT NULL THEN '护照'
            ELSE NULLIF(TRIM(cust.B050007), '')
        END AS ZJLB,

        -- 7. 证件号码：优先身份证 → 护照号 → 其他证件号码
        COALESCE(
            NULLIF(TRIM(cust.B050005), ''),
            NULLIF(TRIM(cust.B050006), ''),
            NULLIF(TRIM(cust.B050008), '')
        ) AS ZJHM,

        -- 8. 客户类型：码值转换
        --    '01' → 普通个人客户; '02' → 个体工商户; '03' → 小微企业主; '04' → 境外客户; '00-XX' → 其他-XX
        CASE
            WHEN NULLIF(TRIM(cust.B050004), '') = '01' THEN '普通个人客户'
            WHEN NULLIF(TRIM(cust.B050004), '') = '02' THEN '个体工商户'
            WHEN NULLIF(TRIM(cust.B050004), '') = '03' THEN '小微企业主'
            WHEN NULLIF(TRIM(cust.B050004), '') = '04' THEN '境外客户'
            WHEN NULLIF(TRIM(cust.B050004), '') LIKE '00-%' THEN
                CONCAT('其他-', SUBSTR(NULLIF(TRIM(cust.B050004), ''), 4))
            ELSE NULLIF(TRIM(cust.B050004), '')
        END AS BXYGBZ,

        -- 9. 国籍：通过公共代码表转换，取不到则赋值为'其他国家和地区'
        COALESCE(
            NULLIF(TRIM(cn.K010005), ''),
            '其他国家和地区'
        ) AS GJHDQ,

        -- 10. 民族：直接映射
        NULLIF(TRIM(cust.B050009), '') AS MZ,

        -- 11. 性别：'01' → '男'; '02' → '女'
        CASE NULLIF(TRIM(cust.B050010), '')
            WHEN '01' THEN '男'
            WHEN '02' THEN '女'
            ELSE NULLIF(TRIM(cust.B050010), '')
        END AS XB,

        -- 12. 学历：通过公共代码表转换
        NULLIF(TRIM(ce.K010005), '') AS XL,

        -- 13. 出生年月：转为 YYYYMMDD 再截取前6位
        CASE
            WHEN cust.B050012 IS NOT NULL
            THEN LEFT(DATE_FORMAT(cust.B050012, '%Y%m%d'), 6)
            ELSE NULL
        END AS CSNY,

        -- 14. 是否已婚：'0' → '否'; '1' → '是'
        CASE NULLIF(TRIM(cust.B050013), '')
            WHEN '0' THEN '否'
            WHEN '1' THEN '是'
            ELSE NULLIF(TRIM(cust.B050013), '')
        END AS SFYH,

        -- 15. 工作单位名称：直接映射
        NULLIF(TRIM(cust.B050016), '') AS GZDWMC,

        -- 16. 工作单位地址：直接映射
        NULLIF(TRIM(cust.B050018), '') AS GZDWDZ,

        -- 17. 工作单位电话：直接映射
        NULLIF(TRIM(cust.B050017), '') AS GZDWDH,

        -- 18. 单位性质：码值转换
        --     '01'→国有企业; '02'→民营企业; '03'→政府机关; '04'→事业单位; '05'→社会团体; '06'→境外机构; '00-XX'→其他-XX
        CASE
            WHEN NULLIF(TRIM(cust.B050019), '') = '01' THEN '国有企业'
            WHEN NULLIF(TRIM(cust.B050019), '') = '02' THEN '民营企业'
            WHEN NULLIF(TRIM(cust.B050019), '') = '03' THEN '政府机关'
            WHEN NULLIF(TRIM(cust.B050019), '') = '04' THEN '事业单位'
            WHEN NULLIF(TRIM(cust.B050019), '') = '05' THEN '社会团体'
            WHEN NULLIF(TRIM(cust.B050019), '') = '06' THEN '境外机构'
            WHEN NULLIF(TRIM(cust.B050019), '') LIKE '00-%' THEN
                CONCAT('其他-', SUBSTR(NULLIF(TRIM(cust.B050019), ''), 4))
            ELSE NULLIF(TRIM(cust.B050019), '')
        END AS DWXZ,

        -- 19. 职业：直接映射
        NULLIF(TRIM(cust.B050020), '') AS ZY,

        -- 20. 职务：直接映射
        NULLIF(TRIM(cust.B050021), '') AS ZW,

        -- 21. 个人年收入：直接映射
        NULLIF(TRIM(cust.B050022), '') AS GRNSR,

        -- 22. 通讯地址：直接映射
        NULLIF(TRIM(cust.B050024), '') AS TXDZ,

        -- 23. 联系电话：先取电话1，取不到取电话2
        COALESCE(
            NULLIF(TRIM(cust.B050014), ''),
            NULLIF(TRIM(cust.B050015), '')
        ) AS LXDH,

        -- 24. 信贷客户标志：首次建立信贷关系年月不为 '9999-12' 则为'是'，否则'否'
        CASE
            WHEN NULLIF(TRIM(cust.B050027), '') IS NOT NULL
             AND NULLIF(TRIM(cust.B050027), '') != '9999-12'
            THEN '是'
            ELSE '否'
        END AS XDKHBZ,

        -- 25. 首次建立信贷关系年月：转为 YYYYMM 格式
        --     来源字段为 YYYY-MM 字符串格式，替换 '-' 为空即可
        REPLACE(NULLIF(TRIM(cust.B050027), ''), '-', '') AS SCJLXDGXNY,

        -- 26. 是否农户：'0' → '否'; '1' → '是'
        CASE NULLIF(TRIM(cust.B050033), '')
            WHEN '0' THEN '否'
            WHEN '1' THEN '是'
            ELSE NULLIF(TRIM(cust.B050033), '')
        END AS SFNH,

        -- 27. 本行员工标志：'0' → '否'; '1' → '是'
        CASE NULLIF(TRIM(cust.B050026), '')
            WHEN '0' THEN '否'
            WHEN '1' THEN '是'
            ELSE NULLIF(TRIM(cust.B050026), '')
        END AS BHYGBZ,

        -- 28. 上黑名单标志：'0' → '否'; '1' → '是'
        CASE NULLIF(TRIM(cust.B050028), '')
            WHEN '0' THEN '否'
            WHEN '1' THEN '是'
            ELSE NULLIF(TRIM(cust.B050028), '')
        END AS SHMDBZ,

        -- 29. 上黑名单日期：YYYY-MM-DD 转换为 YYYYMMDD
        CASE
            WHEN cust.B050029 IS NOT NULL
            THEN DATE_FORMAT(cust.B050029, '%Y%m%d')
            ELSE NULL
        END AS SHMDRQ,

        -- 30. 备注：直接映射
        NULLIF(TRIM(cust.B050039), '') AS BBZ,

        -- 31. 采集日期：使用入参 I_DATE
        I_DATE AS CJRQ,

        -- 32. 涉密标志：当前无映射来源，置空
        NULL AS SENSITIVEFLAG,

        -- 33. 归属分支机构：当前无映射来源，置空
        NULL AS GSFZJG

    FROM cust_scope cs
    INNER JOIN cust_info cust
        ON cs.KHTYBH = cust.B050001   -- 客户范围与个人客户信息关联
    LEFT JOIN org_info org
        ON cust.B050002 = org.A010002  -- 机构ID关联机构信息表
    LEFT JOIN code_nation cn
        ON cust.B050032 = cn.K010004  -- 国家地区代码关联公共代码表
    LEFT JOIN code_edu ce
        ON cust.B050011 = ce.K010004; -- 学历代码关联公共代码表

    SET V_INSERT_COUNT = ROW_COUNT();

    -- ============================================================
    -- 3. 提交事务
    -- ============================================================
    COMMIT;

    -- 日志写入占位（生产环境）：
    -- CALL PROC_ETL_JOB_LOG(V_DATA_DATE, V_PROC_NAME, V_STATUS, V_START_DT, NOW(),
    --     NULL, NULL,
    --     CONCAT('删除', V_DELETE_COUNT, '行, 插入', V_INSERT_COUNT, '行'),
    --     V_STEP_NO, '过程结束执行');

END$$

DELIMITER ;
