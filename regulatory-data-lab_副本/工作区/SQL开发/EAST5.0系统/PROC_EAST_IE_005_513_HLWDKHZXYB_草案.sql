/*
业务目标：
- 依据原始业务需求《040_互联网贷款合作协议表.md》生成 EAST5.0 互联网贷款合作协议表（IE_005_513）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/040_互联网贷款合作协议表.md
- 原始材料/表结构/EAST5.0系统/IE_005_513-互联网贷款合作协议表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_25-互联网贷款合作协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 知识库/数据字典/EAST5.0系统/2026-04-26-IE_005_513-互联网贷款合作协议表-数据字典-原文.md

源表：
- T_6_25（互联网贷款合作协议）
- T_1_1（机构信息）

目标表：
- IE_005_513：互联网贷款合作协议表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 本表报送机构与合作方签订的互联网贷款合作协议信息。互联网贷款的认定参照《商业银行互联网贷款管理暂行办法》。已终止的合作协议于报送协议最后状态的次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 968 行）
主表：【互联网贷款合作协议】
左关联：【机构信息】。关联条件：【机构信息】.【机构ID】关联【互联网贷款合作协议】.【机构ID】。限制【采集日期】为当日
左关联：临时表 TMP_HZFS（合作方式行转列+码值映射+按协议ID分组拼接）
左关联：【互联网贷款合作协议】（取上月末）。关联条件：上月末【互联网贷款合作协议】.【协议ID】关联本期【互联网贷款合作协议】.【协议ID】。
左关联：【代码映射表】（用于证件类别转码，对【互联网贷款合作协议】.【合作方证件类型】进行转码）关联条件：用【互联网贷款合作协议】.【合作方证件类型】关联【代码映射表】.【源字段代码值】，筛选【代码映射表】.【转换规则编号】为'YBT-EAST-ZJLX'。
筛选条件（满足以下条件之一）：
1、上月末【互联网贷款合作协议】.【协议状态】为'01'[正常]；
2、本期【互联网贷款合作协议】.【协议状态】为'01'[正常]；（注：原文写"贷款状态"，实为"协议状态"笔误）
3、本期【互联网贷款合作协议】.【合作协议起始日期】在本月。

2026-05-09 重构校准说明（依据《040_互联网贷款合作协议表.md》逐项校准）：
- 消除 1 个 ON 1=1 JOIN TODO：T_6_25 src LEFT JOIN T_1_1 s1 ON TRIM(src.F250001) = TRIM(s1.A010001) AND s1.A010020 = V_DATA_DATE
- 修正 3 处码值 CASE 偏差（HZFLX/XYZT/HZFS）：删除需求文档未定义的 '00' 码值分支（原误写为'其他-其他'），需求文档仅定义了 '00-自定义'→'其他-自定义'
- 修正 HZFS 合作方类型判断：'00'[无合作方] → '11'[无合作方]，对齐需求文档码值
- 修正合作方式复杂加工逻辑：UNNEST 行转列 → CASE 码值映射 → 按协议ID分组 '+' 拼接 → 其他-前缀置顶 → 全空默认'其他-其他'
- 修正 LAST_MONTH_STATUS 临时表 GROUP BY 字段：F250014（协议状态）
- 补齐 4 个日期格式转换（DATE → VARCHAR(8) YYYYMMDD）：XYQSRQ、XYDQRQ、SJZZRQ、CJRQ，空值默认 '99991231'（CJRQ 不默认）
- 补齐 WHERE 过滤：当月采集日期 + 3 场景终态纳入规则
- 2 个缺口字段（SENSITIVEFLAG/GSFZJG）置 NULL，符合审计处置原则
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_513_HLWDKHZXYB;

CREATE PROCEDURE PROC_EAST_IE_005_513_HLWDKHZXYB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_LAST_MONTH_END DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);

    -- 计算上月末日期：用 LAST_DAY(DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH))
    SET V_LAST_MONTH_END = LAST_DAY(DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH));

    START TRANSACTION;

    DELETE FROM IE_005_513
     WHERE CJRQ = P_DATA_DATE;

    -- ============================================================
    -- 合作方式临时表 TMP_HZFS：
    -- 将 T_6_25.F250007（合作方式，分号分隔多值）按协议ID行转列，
    -- 做码值 CASE 映射，再按协议ID分组用 '+' 拼接，
    -- 若包含'其他-'前缀则统一置顶，全空则赋'其他-其他'。
    --
    -- 码值映射（依据《040_互联网贷款合作协议表.md》第 3 条表级规则）：
    --   '01' → '营销获客'
    --   '02' → '联合贷款'
    --   '03' → '支付结算'
    --   '04' → '风险分担'
    --   '05' → '担保增信'
    --   '06' → '信息科技'
    --   '07' → '逾期清收'
    --   '08' → '其他-客户筛选'
    --   '09' → '其他-部分风险评价'
    --   '10' → '其他-无合作方'
    --   '00-xx' → '其他-xx'
    --   其他 → 保留原值
    -- 注意：需求文档未定义 '00' 码值（无'其他-其他'映射），已删除草案中的 '00' 分支。
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS TMP_HZFS;

    CREATE TEMPORARY TABLE TMP_HZFS AS
    SELECT
        F250002,
        CONCAT_WS_TMP AS HZFS
    FROM (
        SELECT
            F250002,
            -- 用 GROUP_CONCAT 按码值排序拼接，再手动处理"其他-"置顶
            GROUP_CONCAT(
                CASE_CODE
                ORDER BY sort_key
                SEPARATOR '+'
            ) AS raw_concat
        FROM (
            SELECT
                F250002,
                -- 码值映射 CASE（依据需求文档第 3 条表级规则）
                CASE
                    WHEN F250007_SINGLE = '01' THEN '营销获客'
                    WHEN F250007_SINGLE = '02' THEN '联合贷款'
                    WHEN F250007_SINGLE = '03' THEN '支付结算'
                    WHEN F250007_SINGLE = '04' THEN '风险分担'
                    WHEN F250007_SINGLE = '05' THEN '担保增信'
                    WHEN F250007_SINGLE = '06' THEN '信息科技'
                    WHEN F250007_SINGLE = '07' THEN '逾期清收'
                    WHEN F250007_SINGLE = '08' THEN '其他-客户筛选'
                    WHEN F250007_SINGLE = '09' THEN '其他-部分风险评价'
                    WHEN F250007_SINGLE = '10' THEN '其他-无合作方'
                    WHEN F250007_SINGLE LIKE '00-%' THEN CONCAT('其他-', SUBSTR(F250007_SINGLE, 4))
                    ELSE CONCAT('其他-', SUBSTR(F250007_SINGLE, 4))
                END AS CASE_CODE,
                -- sort_key: "其他-"开头的排前面（置顶）
                CASE
                    WHEN F250007_SINGLE LIKE '00%' THEN 0
                    WHEN F250007_SINGLE IN ('08', '09', '10') THEN 0
                    ELSE 1
                END AS sort_key
            FROM (
                SELECT
                    F250002,
                    TRIM(UNNEST_STR) AS F250007_SINGLE
                FROM (
                    SELECT
                        F250002,
                        -- GBase 中用分割替代 UNNEST(STRING_TO_ARRAY(...))
                        SUBSTRING_INDEX(
                            SUBSTRING_INDEX(F250007, ';', numbers.n),
                            ';', -1
                        ) AS UNNEST_STR
                    FROM (
                        SELECT
                            F250002,
                            F250007
                        FROM T_6_25
                        WHERE F250016 = V_DATA_DATE
                        GROUP BY F250002, F250007
                    ) main_table
                    INNER JOIN (
                        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
                        SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL
                        SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL
                        SELECT 10
                    ) numbers
                    ON CHAR_LENGTH(F250007) - CHAR_LENGTH(REPLACE(F250007, ';', '')) >= numbers.n - 1
                ) unnested
                WHERE TRIM(UNNEST_STR) <> ''
            ) single_values
        ) mapped
        GROUP BY F250002
    ) grouped
    -- 处理"其他-"置顶：将 raw_concat 中的"其他-xxx"提到最前面
    -- 由于 GROUP_CONCAT ORDER BY 已控制顺序，此处直接取用
    ;

    -- 处理全空默认值：同一协议ID下合作方式全为空，赋'其他-其他'
    -- 通过 LEFT JOIN 检测无合作方式记录的协议ID
    INSERT INTO TMP_HZFS (F250002, HZFS)
    SELECT
        cur.F250002,
        '其他-其他'
    FROM (
        SELECT DISTINCT F250002 FROM T_6_25 WHERE F250016 = V_DATA_DATE
    ) cur
    LEFT JOIN TMP_HZFS tmp ON cur.F250002 = tmp.F250002
    WHERE tmp.F250002 IS NULL;

    -- ============================================================
    -- 上月末协议状态临时表 LAST_MONTH_STATUS：
    -- 取上月末各协议ID的协议状态，用于终态纳入判断
    -- 2026-05-09 修复：GROUP BY 字段从 F250014（协议状态）修正
    -- ============================================================
    DROP TEMPORARY TABLE IF EXISTS LAST_MONTH_STATUS;

    CREATE TEMPORARY TABLE LAST_MONTH_STATUS AS
    SELECT
        F250002 AS F250002,
        F250014 AS LAST_MONTH_XYZT
    FROM T_6_25
    WHERE F250016 = V_LAST_MONTH_END
    GROUP BY F250002, F250014;

    INSERT INTO IE_005_513 (
        JRXKZH,
        HZFZJHM,
        BBZ,
        XZBZ,
        XYDQRQ,
        XZQHDM,
        NBJGH,
        HZXYBH,
        HZFZJLB,
        HZFMC,
        CJRQ,
        XYZT,
        SJZZRQ,
        SENSITIVEFLAG,
        XYQSRQ,
        HZFS,
        GSFZJG,
        HZFLX,
        YHJGMC
    )
    SELECT
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003 */
        s1.A010003 AS JRXKZH,

        /* 合作方证件号码：互联网贷款合作协议.合作方证件号码 -> T_6_25.F250005 */
        src.F250005 AS HZFZJHM,

        /* 备注：互联网贷款合作协议.备注 -> T_6_25.F250015 */
        src.F250015 AS BBZ,

        /* 限制标志：互联网贷款合作协议.限制标识 -> T_6_25.F250013
         * 码值转换：'1'→'是'，'0'→'否' */
        CASE TRIM(src.F250013)
            WHEN '1' THEN '是'
            WHEN '0' THEN '否'
            ELSE src.F250013
        END AS XZBZ,

        /* 协议到期日期：互联网贷款合作协议.合作协议到期日期 -> T_6_25.F250011
         * 格式转换：DATE → 'YYYYMMDD'，空值默认 '99991231' */
        CASE
            WHEN src.F250011 IS NULL THEN '99991231'
            ELSE REPLACE(CAST(src.F250011 AS CHAR), '-', '')
        END AS XYDQRQ,

        /* 合作方注册地代码：互联网贷款合作协议.合作方注册地行政区划 -> T_6_25.F250009 */
        src.F250009 AS XZQHDM,

        /* 内部机构号：互联网贷款合作协议.机构ID -> T_6_25.F250001
         * 加工规则：从第12位开始截取 */
        SUBSTR(TRIM(src.F250001), 12) AS NBJGH,

        /* 合作协议编号：互联网贷款合作协议.协议ID -> T_6_25.F250002 */
        src.F250002 AS HZXYBH,

        /* 合作方证件类别：互联网贷款合作协议.合作方证件类型 -> T_6_25.F250004
         * 加工映射：根据'YBT-EAST-ZJLX'代码映射表映射为中文；
         * '1999-自定义'→'其他-自定义'（个人），'2999-自定义'→'其他-自定义'（对公）
         * 注：实际代码映射表 T_10_1 未在当前源表中，暂直接映射，待补充 */
        CASE
            WHEN TRIM(src.F250004) = '1999-自定义' THEN '其他-自定义'
            WHEN TRIM(src.F250004) = '2999-自定义' THEN '其他-自定义'
            ELSE src.F250004
        END AS HZFZJLB,

        /* 合作方名称：互联网贷款合作协议.合作方名称 -> T_6_25.F250003 */
        src.F250003 AS HZFMC,

        /* 采集日期：互联网贷款合作协议.采集日期 -> T_6_25.F250016
         * 格式转换：DATE → 'YYYYMMDD' */
        REPLACE(CAST(src.F250016 AS CHAR), '-', '') AS CJRQ,

        /* 协议状态：互联网贷款合作协议.协议状态 -> T_6_25.F250014
         * 码值转换（依据需求文档第 3 条表级规则）：
         * '01'→'有效'，'02'→'其他-待生效'，'03'→'其他-中止'，
         * '04'→'终结'，'05'→'撤销'，'06'→'其他-无效'，
         * '00-自定义'→'其他-自定义'
         * 2026-05-09 修复：删除需求文档未定义的 '00'→'其他-其他' 分支 */
        CASE TRIM(src.F250014)
            WHEN '01' THEN '有效'
            WHEN '02' THEN '其他-待生效'
            WHEN '03' THEN '其他-中止'
            WHEN '04' THEN '终结'
            WHEN '05' THEN '撤销'
            WHEN '06' THEN '其他-无效'
            WHEN TRIM(src.F250014) LIKE '00-%' THEN CONCAT('其他-', SUBSTR(TRIM(src.F250014), 4))
            ELSE TRIM(src.F250014)
        END AS XYZT,

        /* 实际终止日期：互联网贷款合作协议.合作协议实际终止日期 -> T_6_25.F250012
         * 格式转换：DATE → 'YYYYMMDD'，空值默认 '99991231' */
        CASE
            WHEN src.F250012 IS NULL THEN '99991231'
            ELSE REPLACE(CAST(src.F250012 AS CHAR), '-', '')
        END AS SJZZRQ,

        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，无来源 → NULL */
        NULL AS SENSITIVEFLAG,

        /* 协议起始日期：互联网贷款合作协议.合作协议起始日期 -> T_6_25.F250010
         * 格式转换：DATE → 'YYYYMMDD'，空值默认 '99991231' */
        CASE
            WHEN src.F250010 IS NULL THEN '99991231'
            ELSE REPLACE(CAST(src.F250010 AS CHAR), '-', '')
        END AS XYQSRQ,

        /* 合作方式：来自 TMP_HZFS 临时表
         * 加工规则（依据需求文档第 3 条表级规则）：
         *   若合作方类型为'11'[无合作方]，则赋值为'其他-无合作方'；
         *   否则按码值映射后 '+' 拼接，其他-置顶，全空→'其他-其他'
         * 2026-05-09 修复：合作方类型判断从 '00' 改为 '11' */
        CASE
            WHEN TRIM(src.F250006) = '11' THEN '其他-无合作方'
            WHEN tmp_hzfs.HZFS IS NOT NULL THEN tmp_hzfs.HZFS
            ELSE '其他-其他'
        END AS HZFS,

        /* 归属分支机构：无来源 → NULL */
        NULL AS GSFZJG,

        /* 合作方类型：互联网贷款合作协议.合作方类型 -> T_6_25.F250006
         * 码值转换（依据需求文档第 3 条表级规则）：
         * '01'→'银行业金融机构'，'02'→'其他-信托公司'，
         * '03'→'其他-消费金融公司'，'04'→'小额贷款公司'，
         * '05'→'其他-其他银行业金融机构'，'06'→'保险公司'，
         * '07'→'融资担保公司'，'08'→'电子商务公司'，
         * '09'→'非银行支付机构'，'10'→'信息科技公司'，
         * '00-自定义'→'其他-自定义'，'11'→'其他-无合作方'
         * 2026-05-09 修复：删除需求文档未定义的 '00'→'其他-其他' 分支 */
        CASE TRIM(src.F250006)
            WHEN '01' THEN '银行业金融机构'
            WHEN '02' THEN '其他-信托公司'
            WHEN '03' THEN '其他-消费金融公司'
            WHEN '04' THEN '小额贷款公司'
            WHEN '05' THEN '其他-其他银行业金融机构'
            WHEN '06' THEN '保险公司'
            WHEN '07' THEN '融资担保公司'
            WHEN '08' THEN '电子商务公司'
            WHEN '09' THEN '非银行支付机构'
            WHEN '10' THEN '信息科技公司'
            WHEN '11' THEN '其他-无合作方'
            WHEN TRIM(src.F250006) LIKE '00-%' THEN CONCAT('其他-', SUBSTR(TRIM(src.F250006), 4))
            ELSE TRIM(src.F250006)
        END AS HZFLX,

        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005 */
        s1.A010005 AS YHJGMC

    FROM T_6_25 src
    LEFT JOIN T_1_1 s1
           ON TRIM(src.F250001) = TRIM(s1.A010001)
          AND s1.A010020 = V_DATA_DATE
    LEFT JOIN TMP_HZFS tmp_hzfs
           ON src.F250002 = tmp_hzfs.F250002
    LEFT JOIN LAST_MONTH_STATUS lms
           ON src.F250002 = lms.F250002

    WHERE src.F250016 = V_DATA_DATE
      AND (
          /* 场景1：上月末协议状态为'01'[正常] */
          (lms.LAST_MONTH_XYZT = '01')
          OR
          /* 场景2：本期协议状态为'01'[正常]
           * 注：需求文档写"贷款状态"，实为"协议状态"笔误，F250014 为协议状态字段 */
          (TRIM(src.F250014) = '01')
          OR
          /* 场景3：本期合作协议起始日期在本月 */
          (src.F250010 >= V_DATA_DATE
           AND src.F250010 < LAST_DAY(V_DATA_DATE) + INTERVAL 1 DAY)
      );

    COMMIT;
END;
