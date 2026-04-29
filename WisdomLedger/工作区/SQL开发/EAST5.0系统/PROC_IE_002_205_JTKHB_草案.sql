/*
业务目标：
- 从一表通集团基本情况（T_2_2）和集团成员名单（T_3_3）为主源，
  关联集团实际控制人（T_3_4）、客户财务信息（T_2_6）、授信情况（T_8_13）、
  机构信息（T_1_1），映射生成 EAST5.0 集团客户表 IE_002_205。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案（MySQL 语法兼容）。

依赖知识页：
- 原始材料/业务需求/EAST5.0/011_集团客户表.md
- 原始材料/表结构/EAST5.0系统/IE_002_205-集团客户表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_2_2-集团基本情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_3_4-集团实际控制人-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_3_3-集团成员名单-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_2_6-客户财务信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_13-授信情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql

源表：
- T_2_2：一表通集团基本情况（主源，按集团维度和采集日期）。
- T_3_3：一表通集团成员名单（成员粒度，与集团基本情况关联）。
- T_3_4：一表通集团实际控制人（实控人名称和类型，按集团ID取第一条）。
- T_2_6：一表通客户财务信息（资产总额、负债总额，按集团ID关联）。
- T_8_13：一表通授信情况（授信币种，按集团ID关联）。
- T_1_1：一表通机构信息（金融许可证号、银行机构名称）。

目标表：
- IE_002_205：EAST5.0 集团客户表。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

报送范围：
- 报送在本行纳入集团授信的客户信息，包括供应链客户信息。
- 以集团成员为最小粒度报送。
- 同业集团客户信息无需报送（当前源表无明确同业标识字段，排除逻辑暂不实现）。

表级过滤规则（来自映射规则 Excel 第 213 行）：
- 集团基本情况失效时间限制为空或失效时间在报送当月。
- 集团实际控制人关系失效时间限制为空或失效时间在报送当月。
- 集团成员名单关系失效时间限制为空或失效时间在报送当月。
- 集团基本情况集团ID限制在授信情况客户ID范围内的。

未确认点：
- 报送模式要求"报送上一采集日至采集日期间结清、失效、终结等所有视为终态的数据"，
  当前映射规则只给出失效时间限制为空的筛选，终态数据纳入规则待确认。
- 同一集团ID-成员ID-采集日期组合可能产生多行（集团基本情况或授信情况存在多条时），
  主键重复风险待验证。
- 币种字段：一个集团可能有多个授信币种，当前取窗口函数第一条，
  是否应拼接多个币种或取最大额度对应币种待确认。
- 备注汇总：当前用英文分号连接三个来源表的备注，
  如需求意为"取第一个非空值"则需改为 COALESCE。
- 机构ID截取从第12位开始，需确认各源表机构ID固定长度和位置一致性。
- 金额类字段在源表中为 varchar(255) 类型，需 CAST 转换，空字符串需 NULLIF 处理。
- 排除规则（同业集团客户）的筛选字段来源未确认，当前未实现同业排除逻辑。
*/

CREATE PROCEDURE `PROC_IE_002_205_JTKHB`(
    IN I_DATE VARCHAR(8)
)
BEGIN
    # 采集日期（DATE 类型）和当月起始/终止日期
    DECLARE V_DATA_DATE DATE;
    DECLARE V_MON_START DATE;
    DECLARE V_MON_END DATE;

    # 变量初始化
    SET V_DATA_DATE = STR_TO_DATE(I_DATE, '%Y%m%d');
    SET V_MON_START = DATE_FORMAT(V_DATA_DATE, '%Y-%m-01');
    SET V_MON_END = LAST_DAY(V_DATA_DATE);

    # 1. 清除目标表当期数据
    DELETE FROM IE_002_205
     WHERE CJRQ = I_DATE;

    # 2. 插入映射数据
    INSERT INTO IE_002_205 (
        JTMC,
        MGSMC,
        CYYYED,
        GSFZJG,
        SENSITIVEFLAG,
        SKRLX,
        JTFZZE,
        JTYYED,
        CYMC,
        BBZ,
        JRXKZH,
        JTBH,
        NBJGH,
        YHJGMC,
        MGSKHTYBH,
        SKRMC,
        BZ,
        JTZCZE,
        JTSXED,
        CYKHTYBH,
        CJRQ
    )
    SELECT
        # 集团名称（T_2_2.B020007，直接映射）
        grp.B020007 AS JTMC,

        # 母公司名称（T_2_2.B020005，直接映射；无母公司允许为空）
        grp.B020005 AS MGSMC,

        # 成员已用额度（T_3_3.C030014，varchar → DECIMAL）
        CAST(NULLIF(TRIM(mem.C030014), '') AS DECIMAL(20,2)) AS CYYYED,

        # 归属分支机构（无映射来源，置空）
        NULL AS GSFZJG,

        # 涉密标志（无映射来源，置空）
        NULL AS SENSITIVEFLAG,

        # 实控人类型（T_3_4.C040012，直接映射；取每个集团第一条）
        ctrl.C040012 AS SKRLX,

        # 集团负债总额（T_2_6.B060010，varchar → DECIMAL）
        CAST(NULLIF(TRIM(fin.B060010), '') AS DECIMAL(20,2)) AS JTFZZE,

        # 集团已用额度（T_2_2.B020024，直接映射，varchar 类型）
        grp.B020024 AS JTYYED,

        # 成员名称（T_3_3.C030003，直接映射）
        mem.C030003 AS CYMC,

        # 备注（汇总集团基本情况、授信情况、集团实际控制人三种表备注，
        #       用英文分号连接非空备注）
        CONCAT(
            grp.B020021,
            CASE WHEN grp.B020021 IS NOT NULL AND grp.B020021 <> ''
                 THEN ';' ELSE '' END,
            COALESCE(wx_note.note, ''),
            CASE WHEN wx_note.note IS NOT NULL AND wx_note.note <> ''
                 AND grp.B020021 IS NOT NULL AND grp.B020021 <> ''
                 THEN ';'
                 WHEN wx_note.note IS NOT NULL AND wx_note.note <> ''
                      AND (grp.B020021 IS NULL OR grp.B020021 = '')
                 THEN ';'
                 ELSE '' END,
            ctrl.C040013
        ) AS BBZ,

        # 金融许可证号（通过机构ID关联 T_1_1 获取）
        org.A010003 AS JRXKZH,

        # 集团编号（T_2_2.B020001，PK 组成部分，直接映射）
        grp.B020001 AS JTBH,

        # 内部机构号（T_2_2.B020002 从第12位开始截取）
        SUBSTR(TRIM(grp.B020002), 12) AS NBJGH,

        # 银行机构名称（通过机构ID关联 T_1_1 获取）
        org.A010005 AS YHJGMC,

        # 母公司客户统一编号（T_2_2.B020020，直接映射；无母公司允许为空）
        grp.B020020 AS MGSKHTYBH,

        # 实控人名称（T_3_4.C040004，取每个集团按实际控制人类别排序第一条）
        ctrl.C040004 AS SKRMC,

        # 币种（T_8_13.H130007 授信币种，取每个集团第一条）
        wx.H130007 AS BZ,

        # 集团资产总额（T_2_6.B060009，varchar → DECIMAL）
        CAST(NULLIF(TRIM(fin.B060009), '') AS DECIMAL(20,2)) AS JTZCZE,

        # 集团授信额度（T_2_2.B020023，直接映射，varchar 类型）
        grp.B020023 AS JTSXED,

        # 成员客户统一编号（T_3_3.C030002，PK 组成部分，直接映射）
        mem.C030002 AS CYKHTYBH,

        # 采集日期（T_2_2.B020019，date → YYYYMMDD 字符串，PK 组成部分）
        DATE_FORMAT(grp.B020019, '%Y%m%d') AS CJRQ

    FROM T_2_2 grp

    # 关联集团成员名单（以集团成员为最小粒度，一对多）
    LEFT JOIN T_3_3 mem
      ON mem.C030007 = grp.B020001
     AND mem.C030008 = grp.B020002
     # 集团成员名单关系失效时间限制为空或失效时间在报送当月
     AND (mem.C030009 IS NULL OR mem.C030009 >= V_MON_START AND mem.C030009 <= V_MON_END)

    # 关联集团实际控制人（取每个集团按实际控制人类别排序的第一条）
    LEFT JOIN (
        SELECT
            C040002,
            C040004,
            C040012,
            C040013,
            ROW_NUMBER() OVER (
                PARTITION BY C040002
                ORDER BY C040005
            ) AS rn
        FROM T_3_4
        # 集团实际控制人关系失效时间限制为空或失效时间在报送当月
        WHERE C040010 IS NULL OR C040010 >= V_MON_START AND C040010 <= V_MON_END
    ) ctrl
      ON ctrl.C040002 = grp.B020001
     AND ctrl.rn = 1

    # 关联客户财务信息（按集团ID关联取资产总额和负债总额）
    LEFT JOIN T_2_6 fin
      ON fin.B060001 = grp.B020001

    # 关联授信情况（取授信币种，按集团ID关联取第一条）
    LEFT JOIN (
        SELECT
            H130002,
            H130007,
            H130033,
            ROW_NUMBER() OVER (
                PARTITION BY H130002
                ORDER BY H130001
            ) AS rn
        FROM T_8_13
    ) wx
      ON wx.H130002 = grp.B020001
     AND wx.rn = 1

    # 关联机构信息（取金融许可证号和银行机构名称）
    # 关联键：集团基本情况机构ID从第12位开始截取
    LEFT JOIN T_1_1 org
      ON org.A010001 = SUBSTR(TRIM(grp.B020002), 12)
     AND org.A010020 = V_DATA_DATE

    # 集团基本情况失效时间限制为空或失效时间在报送当月
    WHERE (grp.B020022 IS NULL OR grp.B020022 >= V_MON_START AND grp.B020022 <= V_MON_END)

    # 集团基本情况集团ID限制在授信情况客户ID范围内
    AND wx.H130002 IS NOT NULL;

    COMMIT;
END;
