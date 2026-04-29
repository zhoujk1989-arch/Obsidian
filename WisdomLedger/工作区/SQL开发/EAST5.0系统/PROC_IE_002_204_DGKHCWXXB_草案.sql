/*
业务目标：
- 从一表通客户财务信息及相关表映射生成 EAST5.0 对公客户财务信息表 IE_002_204_INC。

目标系统：
- EAST5.0系统。

目标产物：
- MySQL 存储过程草案。

依赖知识页：
- 原始材料/业务需求/EAST5.0/010_对公客户财务信息表.md
- 原始材料/表结构/EAST5.0系统/IE_002_204_INC-对公客户财务信息表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_2_6-客户财务信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_2_1-单一法人基本情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_2_3-同业客户基本情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_2_2-集团基本情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql

源表：
- T_2_6：一表通客户财务信息（主源，按财报录入日期筛选当月新增）。
- T_2_1：一表通单一法人基本情况（客户名称、机构ID取数）。
- T_2_3：一表通同业客户基本情况（客户名称 fallback、机构ID取数）。
- T_2_2：一表通集团基本情况（客户名称 fallback）。
- T_1_1：一表通机构信息（金融许可证号、银行机构名称、内部机构号）。

目标表：
- IE_002_204_INC：EAST5.0 对公客户财务信息表（增量表）。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

排除规则（需求文档）：
- 非授信客户、负债类客户、离岸对公客户、机关事业单位、
  未达到税务部门建账标准的个体工商户不报送。
- 当前源表 T_2_6 无客户类型标识字段，排除逻辑暂不实现，
  作为 Open Questions 待确认。

未确认点：
- 排除规则（非授信客户、负债类客户、离岸对公客户、机关事业单位、
  未达建账标准个体工商户）的筛选字段来源未确认，当前未实现排除逻辑。
- 税前利润 = 净利润 + 所得税，需确认所得税为正值还是绝对值。
- T_2_6 中金额类字段为 varchar 类型，需 CAST 转换，空字符串需 NULLIF 处理。
- 机构ID截取从第12位开始，需确认各源表机构ID固定长度和位置一致性。
- 财务报表编号在 T_2_6 中为 B060021（varchar(40)），目标表 CWBBBH 为 varchar(100)，直接映射。
*/

CREATE PROCEDURE `PROC_EAST_IE_002_204_DGKHCWXXB`(
    IN I_DATE VARCHAR(8)
)
BEGIN
    # 采集日期（DATE 类型）和当月起始日期
    DECLARE V_DATA_DATE DATE;
    DECLARE V_MON_START DATE;
    DECLARE V_MON_END DATE;

    # 变量初始化
    SET V_DATA_DATE = STR_TO_DATE(I_DATE, '%Y%m%d');
    SET V_MON_START = DATE_FORMAT(V_DATA_DATE, '%Y-%m-01');
    SET V_MON_END = LAST_DAY(V_DATA_DATE);

    # 1. 清除目标表当期数据
    DELETE FROM IE_002_204_INC
     WHERE CJRQ = I_DATE;

    # 2. 插入映射数据
    INSERT INTO IE_002_204_INC (
        ZCZE,
        ZYYWSR,
        SDS,
        CJRQ,
        BBZQ,
        JLR,
        FZZE,
        BBKJ,
        SFSJ,
        KHMC,
        YHJGMC,
        JRXKZH,
        QTYSK,
        SENSITIVEFLAG,
        GSFZJG,
        NBJGH,
        CWBBBH,
        KHTYBH,
        CWBBRQ,
        SJJG,
        BZ,
        SQLR,
        XJLLJE,
        YSZK,
        BBZ
    )
    SELECT
        # 资产总额（T_2_6.B060009，varchar → DECIMAL）
        CAST(NULLIF(TRIM(t.B060009), '') AS DECIMAL(20,2)) AS ZCZE,

        # 主营业务收入（T_2_6.B060013，varchar → DECIMAL）
        CAST(NULLIF(TRIM(t.B060013), '') AS DECIMAL(20,2)) AS ZYYWSR,

        # 所得税（T_2_6.B060011，varchar → DECIMAL）
        CAST(NULLIF(TRIM(t.B060011), '') AS DECIMAL(20,2)) AS SDS,

        # 采集日期（T_2_6.B060022，date → YYYYMMDD 字符串）
        DATE_FORMAT(t.B060022, '%Y%m%d') AS CJRQ,

        # 报表周期（T_2_6.B060020，码值映射）
        CASE TRIM(t.B060020)
            WHEN '01' THEN '日报'
            WHEN '02' THEN '月报'
            WHEN '03' THEN '季报'
            WHEN '04' THEN '半年报'
            WHEN '05' THEN '年报'
            WHEN '00' THEN '其他'
            ELSE t.B060020
        END AS BBZQ,

        # 净利润（T_2_6.B060012，varchar → DECIMAL）
        CAST(NULLIF(TRIM(t.B060012), '') AS DECIMAL(20,2)) AS JLR,

        # 负债总额（T_2_6.B060010，varchar → DECIMAL）
        CAST(NULLIF(TRIM(t.B060010), '') AS DECIMAL(20,2)) AS FZZE,

        # 报表口径（T_2_6.B060007，码值映射）
        CASE TRIM(t.B060007)
            WHEN '01' THEN '本部报表'
            WHEN '02' THEN '合并报表'
            WHEN '00' THEN '其他'
            ELSE t.B060007
        END AS BBKJ,

        # 是否审计（T_2_6.B060005，码值转换：0→'否'，1→'是'）
        CASE TRIM(t.B060005)
            WHEN '0' THEN '否'
            WHEN '1' THEN '是'
            ELSE NULL
        END AS SFSJ,

        # 客户名称（优先 T_2_1 对公客户名称，fallback T_2_3 客户名称，再 fallback T_2_2 集团名称）
        COALESCE(
            f.B010003,
            i.B030003,
            g.B020007
        ) AS KHMC,

        # 银行机构名称（通过机构ID关联 T_1_1 获取）
        org.A010005 AS YHJGMC,

        # 金融许可证号（通过机构ID关联 T_1_1 获取）
        org.A010003 AS JRXKZH,

        # 其他应收款（T_2_6.B060017，varchar → DECIMAL）
        CAST(NULLIF(TRIM(t.B060017), '') AS DECIMAL(20,2)) AS QTYSK,

        # 涉密标志（无映射来源，置空）
        NULL AS SENSITIVEFLAG,

        # 归属分支机构（无映射来源，置空）
        NULL AS GSFZJG,

        # 内部机构号（T_2_6.B060002 截取第12位起；fallback 取 T_2_1.B010002 或 T_2_3.B030002）
        SUBSTR(
            COALESCE(
                CASE WHEN TRIM(f.B010002) IS NOT NULL AND LENGTH(TRIM(f.B010002)) >= 12 THEN SUBSTR(TRIM(f.B010002), 12)
                     ELSE NULL END,
                CASE WHEN TRIM(i.B030002) IS NOT NULL AND LENGTH(TRIM(i.B030002)) >= 12 THEN SUBSTR(TRIM(i.B030002), 12)
                     ELSE NULL END,
                SUBSTR(TRIM(t.B060002), 12)
            ),
            1,
            LENGTH(COALESCE(
                CASE WHEN TRIM(f.B010002) IS NOT NULL AND LENGTH(TRIM(f.B010002)) >= 12 THEN SUBSTR(TRIM(f.B010002), 12)
                     ELSE NULL END,
                CASE WHEN TRIM(i.B030002) IS NOT NULL AND LENGTH(TRIM(i.B030002)) >= 12 THEN SUBSTR(TRIM(i.B030002), 12)
                     ELSE NULL END,
                SUBSTR(TRIM(t.B060002), 12)
            ))
        ) AS NBJGH,

        # 财务报表编号（T_2_6.B060021，直接映射）
        t.B060021 AS CWBBBH,

        # 客户统一编号（T_2_6.B060001，直接映射）
        t.B060001 AS KHTYBH,

        # 财务报表日期（T_2_6.B060004，date → YYYYMMDD 字符串）
        DATE_FORMAT(t.B060004, '%Y%m%d') AS CWBBRQ,

        # 审计机构（T_2_6.B060006，直接映射）
        t.B060006 AS SJJG,

        # 币种（T_2_6.B060008，直接映射）
        t.B060008 AS BZ,

        # 税前利润（净利润 + 所得税）
        CAST(NULLIF(TRIM(t.B060012), '') AS DECIMAL(20,2))
            + CAST(NULLIF(TRIM(t.B060011), '') AS DECIMAL(20,2)) AS SQLR,

        # 现金流量净额（T_2_6.B060015，varchar → DECIMAL）
        CAST(NULLIF(TRIM(t.B060015), '') AS DECIMAL(20,2)) AS XJLLJE,

        # 应收账款（T_2_6.B060016，varchar → DECIMAL）
        CAST(NULLIF(TRIM(t.B060016), '') AS DECIMAL(20,2)) AS YSZK,

        # 备注（T_2_6.B060024，直接映射）
        t.B060024 AS BBZ

    FROM T_2_6 t

    # 关联单一法人基本情况（取客户名称和机构ID）
    LEFT JOIN T_2_1 f
      ON f.B010001 = t.B060001

    # 关联同业客户基本情况（取客户名称 fallback 和机构ID）
    LEFT JOIN T_2_3 i
      ON i.B030001 = t.B060001

    # 关联集团基本情况（取客户名称 fallback）
    LEFT JOIN T_2_2 g
      ON g.B020001 = t.B060001

    # 关联机构信息（取金融许可证号和银行机构名称）
    # 关联键：截取后的机构ID（优先单一法人/同业客户机构ID截取，fallback 财务信息机构ID截取）
    LEFT JOIN T_1_1 org
      ON org.A010001 = SUBSTR(
            COALESCE(
                CASE WHEN TRIM(f.B010002) IS NOT NULL AND LENGTH(TRIM(f.B010002)) >= 12 THEN SUBSTR(TRIM(f.B010002), 12)
                     ELSE NULL END,
                CASE WHEN TRIM(i.B030002) IS NOT NULL AND LENGTH(TRIM(i.B030002)) >= 12 THEN SUBSTR(TRIM(i.B030002), 12)
                     ELSE NULL END,
                SUBSTR(TRIM(t.B060002), 12)
            ),
            1,
            LENGTH(COALESCE(
                CASE WHEN TRIM(f.B010002) IS NOT NULL AND LENGTH(TRIM(f.B010002)) >= 12 THEN SUBSTR(TRIM(f.B010002), 12)
                     ELSE NULL END,
                CASE WHEN TRIM(i.B030002) IS NOT NULL AND LENGTH(TRIM(i.B030002)) >= 12 THEN SUBSTR(TRIM(i.B030002), 12)
                     ELSE NULL END,
                SUBSTR(TRIM(t.B060002), 12)
            ))
         )
         AND org.A010020 = V_DATA_DATE

    # 主过滤条件：按财报录入日期筛选当月录入的财报
    WHERE t.B060023 >= V_MON_START
      AND t.B060023 <= V_MON_END;

    COMMIT;
END;
