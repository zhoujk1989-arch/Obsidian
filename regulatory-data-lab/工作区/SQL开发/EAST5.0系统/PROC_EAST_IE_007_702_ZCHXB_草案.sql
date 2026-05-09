/*
重构质量状态：draft，待 GBase 环境执行验证。
重构依据：原始业务需求《045_资产核销表.md》逐字段校验映射逻辑、JOIN条件、WHERE筛选、码值转换。
来源材料：
  - 原始材料/业务需求/EAST5.0/045_资产核销表.md
  - 原始材料/表结构/EAST5.0系统/IE_007_702-资产核销表-DDL-2026-04-28.sql
  - 原始材料/表结构/一表通系统/T_7_8-不良资产处置-DDL-2026-04-27.sql
  - 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
重构日期：2026-05-09
*/

/*
业务目标：
- 依据原始业务需求《045_资产核销表.md》生成 EAST5.0 资产核销表（IE_007_702）GBase 存储过程。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程。

依赖材料：
- 原始材料/业务需求/EAST5.0/045_资产核销表.md
- 原始材料/表结构/EAST5.0系统/IE_007_702-资产核销表-DDL-2026-04-28.sql

源表：
- T_7_8（一表通不良资产处置）
- T_1_1（一表通机构信息）

目标表：
- IE_007_702：资产核销表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送范围：
- 已核销的个人贷款、对公贷款、信用卡以及其他债权和股权资产信息。

表级规则（045_资产核销表.md 2.1节）：
- 主表：【一表通】【不良资产处置】（T_7_8）
- 子查询：从 T_7_8 取处置类型='70'（已核销收回）且采集日期在有效范围内的记录，
  按细分资产ID/协议ID/币种/资产类型分组，汇总收回资产金额和收回利息金额，
  每组按采集日期降序、处置收回日期降序取最新记录（rn=1）。
- 左关联子查询：ON 细分资产ID/协议ID/币种/资产类型 且 rn=1
- 左关联机构信息（T_1_1）：ON SUBSTR(机构ID,12) = SUBSTR(机构ID,12) 且 机构信息.采集日期=跑批日期

字段映射摘要：
  字段              来源/映射                                 码值/转换
  JRXKZH            T_1_1.A010003（通过机构ID截取关联）        直接映射
  NBJGH             SUBSTR(T_7_8.机构ID, 12)                  截取映射
  KHTYBH            T_7_8.G080005（客户ID）                   直接映射
  KHMC              需关联EAST客户信息表（待补）                暂置NULL
  ZCLX              T_7_8.G080006（资产类型）                  CASE: 01→个人贷款, 02→对公贷款, 03/04→信用卡贷款, ELSE→非信贷类债权
  HTH               T_7_8.G080004（协议ID）                   直接映射
  JJH               T_7_8.G080003（细分资产ID）                直接映射
  BZ                T_7_8.G080022（币种）                     直接映射
  HXBJ              T_7_8.G080009（处置本金金额）               CAST DECIMAL(20,2)
  SHBNLX            T_7_8.G080010（处置表内利息金额）           CAST DECIMAL(20,2)
  SHBWLX            T_7_8.G080011（处置表外利息金额）           CAST DECIMAL(20,2)
  HXRQ              T_7_8.G080008（处置日期）                  DATE_FORMAT→YYYYMMDD, NULL→99991231
  SHBJ              子查询.G080013（收回资产金额 SUM）          COALESCE→0
  SHLX              子查询.(G080014+G080015)（收回利息 SUM）    COALESCE→0
  SHRQ              子查询.G080020（处置收回日期）              DATE_FORMAT→YYYYMMDD, NULL→99991231
  SHBZ              子查询.G080018（收回标识）                  CASE: 01→未收回, 02→部分收回, 03→完全收回, ELSE→未收回
  SHYGH             子查询.G080019（收回员工ID）                NULL→''
  HXZT              COALESCE(子查询.G080021, T_7_8.G080021)    CASE: 03→账销案存, 04→完全终结, ELSE→''
  BBZ               COALESCE(子查询.G080026, T_7_8.G080026)   直接映射
  CJRQ              P_DATA_DATE                              直接赋值
  SENSITIVEFLAG     NULL（缺口字段，DDL存在但业务需求未给来源）
  KHLB              NULL（缺口字段，DDL存在但业务需求未给来源）
  GSFZJG            NULL（缺口字段，DDL存在但业务需求未给来源）

未确认点：
- KHMC（客户名称）需关联 EAST对公客户信息表（IE_002_203）和 EAST个人客户信息表（IE_002_202），
  本次重构暂未添加该 JOIN，置 NULL 待补。
- SENSITIVEFLAG、KHLB、GSFZJG 三个字段在 DDL 中定义但业务需求映射表未给来源，置 NULL。
- 41~45核销场景与70已核销收回场景通过 LEFT JOIN 子查询自然区分（无匹配时回退默认值）。
- 金额字段从 varchar(255) CAST 为 DECIMAL(20,2)，需在 GBase 环境验证兼容性。
- DATE_FORMAT 函数在 GBase 8a 中是否支持，如不支持需替换为 CONCAT(YEAR(...), ...) 模式。
- 重构后 SQL 尚未在 GBase 环境执行验证。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_007_702_ZCHXB;

CREATE PROCEDURE PROC_EAST_IE_007_702_ZCHXB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);

    START TRANSACTION;

    -- 全量表：先删除同一采集日期的数据，再插入映射结果
    DELETE FROM IE_007_702
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_007_702 (
        SHLX,
        SENSITIVEFLAG,
        HTH,
        ZCLX,
        NBJGH,
        SHYGH,
        KHMC,
        CJRQ,
        BBZ,
        SHRQ,
        SHBJ,
        SHBNLX,
        SHBZ,
        HXZT,
        JRXKZH,
        KHTYBH,
        BZ,
        SHBWLX,
        HXRQ,
        KHLB,
        GSFZJG,
        JJH,
        HXBJ
    )
    /*
    子查询 subq_agg：
    - 从 T_7_8 筛选已核销收回（处置类型='70'）且在采集日期有效范围内的记录
    - 按细分资产ID/协议ID/币种/资产类型分组
    - 汇总收回资产金额（SHBJ_AMT）和收回利息金额（SHLX_AMT=收回表内+收回表外）
    - 取每组最新记录（按采集日期DESC、处置收回日期DESC）的非聚合字段
    */
    WITH subq_ranked AS (
        SELECT
            sq.G080003 AS XFZC_ID,
            sq.G080004 AS XY_ID,
            sq.G080022 AS BZ,
            sq.G080006 AS ZCLX_CODE,
            sq.G080020 AS CZSHRQ,
            sq.G080018 AS SHBZ_CODE,
            sq.G080021 AS CZZT_CODE,
            sq.G080019 AS SHYGH,
            sq.G080026 AS BBZ,
            CAST(COALESCE(NULLIF(sq.G080013, ''), '0') AS DECIMAL(20,2)) AS SHBJ_RAW,
            CAST(COALESCE(NULLIF(sq.G080014, ''), '0') AS DECIMAL(20,2)) AS SHBNLX_RAW,
            CAST(COALESCE(NULLIF(sq.G080015, ''), '0') AS DECIMAL(20,2)) AS SHBWLX_RAW,
            ROW_NUMBER() OVER (
                PARTITION BY sq.G080003, sq.G080004, sq.G080022, sq.G080006
                ORDER BY sq.G080023 DESC, sq.G080020 DESC
            ) AS rn
        FROM T_7_8 sq
        WHERE ((sq.G080023 <= V_DATA_DATE AND sq.G080023 >= '2025-01-01' AND sq.G080007 = '70')
            OR sq.G080023 = '1900-12-31')
    ),
    subq_agg AS (
        SELECT
            r.XFZC_ID,
            r.XY_ID,
            r.BZ,
            r.ZCLX_CODE,
            r.CZSHRQ,
            r.SHBZ_CODE,
            r.CZZT_CODE,
            r.SHYGH,
            r.BBZ,
            SUM(r.SHBJ_RAW) AS SHBJ_AMT,
            SUM(r.SHBNLX_RAW + r.SHBWLX_RAW) AS SHLX_AMT
        FROM subq_ranked r
        WHERE r.rn = 1
        GROUP BY
            r.XFZC_ID,
            r.XY_ID,
            r.BZ,
            r.ZCLX_CODE,
            r.CZSHRQ,
            r.SHBZ_CODE,
            r.CZZT_CODE,
            r.SHYGH,
            r.BBZ
    )
    SELECT
        /* SHLX: 收回利息 = 子查询收回表内利息+收回表外利息的汇总，为空置0 */
        COALESCE(sa.SHLX_AMT, 0) AS SHLX,

        /* SENSITIVEFLAG: 缺口字段，DDL中定义但业务需求映射表未给来源 */
        NULL AS SENSITIVEFLAG,

        /* HTH: 合同号 = 协议ID（T_7_8.G080004） */
        TRIM(src.G080004) AS HTH,

        /* ZCLX: 资产类型，码值转换
           01 → 个人贷款
           02 → 对公贷款
           03/04 → 信用卡贷款
           其他 → 非信贷类债权
        */
        CASE TRIM(src.G080006)
            WHEN '01' THEN '个人贷款'
            WHEN '02' THEN '对公贷款'
            WHEN '03' THEN '信用卡贷款'
            WHEN '04' THEN '信用卡贷款'
            ELSE '非信贷类债权'
        END AS ZCLX,

        /* NBJGH: 内部机构号 = 机构ID从第12位开始截取（T_7_8.G080002） */
        SUBSTR(TRIM(src.G080002), 12) AS NBJGH,

        /* SHYGH: 收回员工号 = 子查询最后收回员工ID，为空置'' */
        COALESCE(sa.SHYGH, '') AS SHYGH,

        /*
        KHMC: 客户名称
        待确认：需将主表不良资产处置的客户ID分别关联 EAST对公客户信息表（IE_002_203）
        和 EAST个人客户信息表（IE_002_202）的客户统一编号，取客户名称/客户姓名。
        当前暂置NULL，待补 JOIN。
        */
        NULL AS KHMC,

        /* CJRQ: 采集日期 = 跑批日期 */
        P_DATA_DATE AS CJRQ,

        /* BBZ: 备注 = 优先取子查询备注，为空时取主表备注 */
        COALESCE(sa.BBZ, src.G080026) AS BBZ,

        /* SHRQ: 收回日期 = 子查询处置收回日期，格式转为YYYYMMDD，为空取99991231 */
        COALESCE(DATE_FORMAT(sa.CZSHRQ, '%Y%m%d'), '99991231') AS SHRQ,

        /* SHBJ: 收回本金 = 子查询收回资产金额汇总，为空置0 */
        COALESCE(sa.SHBJ_AMT, 0) AS SHBJ,

        /* SHBNLX: 实核表内利息 = 处置表内利息金额（T_7_8.G080010） */
        CAST(COALESCE(NULLIF(src.G080010, ''), '0') AS DECIMAL(20,2)) AS SHBNLX,

        /* SHBZ: 收回标志 = 子查询收回标识，码值转换
           01 → 未收回
           02 → 部分收回
           03 → 完全收回
           其他/空 → 未收回
        */
        CASE
            WHEN sa.SHBZ_CODE IS NULL THEN '未收回'
            WHEN TRIM(sa.SHBZ_CODE) = '01' THEN '未收回'
            WHEN TRIM(sa.SHBZ_CODE) = '02' THEN '部分收回'
            WHEN TRIM(sa.SHBZ_CODE) = '03' THEN '完全收回'
            ELSE '未收回'
        END AS SHBZ,

        /* HXZT: 核销状态 = 优先取子查询处置状态，为空时取主表处置状态，码值转换
           03 → 账销案存
           04 → 完全终结
           其他 → 空
        */
        CASE
            WHEN COALESCE(sa.CZZT_CODE, src.G080021) = '03' THEN '账销案存'
            WHEN COALESCE(sa.CZZT_CODE, src.G080021) = '04' THEN '完全终结'
            ELSE ''
        END AS HXZT,

        /* JRXKZH: 金融许可证号 = 通过机构信息表获取
           关联条件：主表不良资产处置的机构ID从第12位截取 = 机构信息的机构ID从第12位截取
           且机构信息采集日期 = 跑批日期
        */
        org.A010003 AS JRXKZH,

        /* KHTYBH: 客户统一编号 = 客户ID（T_7_8.G080005） */
        TRIM(src.G080005) AS KHTYBH,

        /* BZ: 币种 = 币种（T_7_8.G080022） */
        TRIM(src.G080022) AS BZ,

        /* SHBWLX: 实核表外利息 = 处置表外利息金额（T_7_8.G080011） */
        CAST(COALESCE(NULLIF(src.G080011, ''), '0') AS DECIMAL(20,2)) AS SHBWLX,

        /* HXRQ: 核销日期 = 处置日期（T_7_8.G080008），格式转为YYYYMMDD，为空取99991231 */
        COALESCE(DATE_FORMAT(src.G080008, '%Y%m%d'), '99991231') AS HXRQ,

        /* KHLB: 缺口字段，DDL中定义但业务需求映射表未给来源 */
        NULL AS KHLB,

        /* GSFZJG: 缺口字段，DDL中定义但业务需求映射表未给来源 */
        NULL AS GSFZJG,

        /* JJH: 借据号 = 细分资产ID（T_7_8.G080003） */
        TRIM(src.G080003) AS JJH,

        /* HXBJ: 实核本金 = 处置本金金额（T_7_8.G080009） */
        CAST(COALESCE(NULLIF(src.G080009, ''), '0') AS DECIMAL(20,2)) AS HXBJ

    FROM T_7_8 src

    /* 左关联子查询：匹配已核销收回记录
       关联条件：细分资产ID、协议ID、币种、资产类型 四字段等值匹配
       且子查询排序 rn = 1（每组取最新记录）
    */
    LEFT JOIN subq_agg sa
      ON TRIM(src.G080003) = TRIM(sa.XFZC_ID)
     AND TRIM(src.G080004) = TRIM(sa.XY_ID)
     AND TRIM(src.G080022) = TRIM(sa.BZ)
     AND TRIM(src.G080006) = TRIM(sa.ZCLX_CODE)

    /* 左关联机构信息表：获取金融许可证号
       关联条件：机构ID从第12位截取等值匹配
       且机构信息采集日期 = 跑批日期
    */
    LEFT JOIN T_1_1 org
      ON SUBSTR(TRIM(src.G080002), 12) = SUBSTR(TRIM(org.A010001), 12)
     AND org.A010020 = V_DATA_DATE

    /* WHERE 过滤：采集日期 <= 跑批日期（全量表范围） */
    WHERE src.G080023 <= V_DATA_DATE;

    COMMIT;
END;
