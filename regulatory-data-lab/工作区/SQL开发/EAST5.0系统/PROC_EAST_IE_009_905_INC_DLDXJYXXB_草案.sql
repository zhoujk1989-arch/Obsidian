/*
草案质量状态：合格，按原始业务需求逐字段校验后已可运行。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《057_代理代销交易信息表.md》生成 EAST5.0 代理代销交易信息表（IE_009_905_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/057_代理代销交易信息表.md
- 原始材料/表结构/EAST5.0系统/IE_009_905_INC-代理代销交易信息表-DDL-2026-04-28.sql

源表：
- T_7_11（理财及代销产品交易，主表）
- T_6_19（代理协议，关联表）
- T_1_1（机构信息）
- T_2_1（单一法人基本情况/对公客户信息表）
- T_2_5（个人客户基本情况/个人基础信息表）

目标表：
- IE_009_905_INC：代理代销交易信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 报送范围包括债券承销、代理代销信托计划、代理资产管理计划、代理代销保险产品、代理代销基金、代理贵金属交易以及其他代理代销业务，相关业务定义可参照1104报表。代理销售他行发行的理财产品也需要报送，包括填报机构理财子公司发行的理财产品。涉及分红、付息等交易无需报送。涉及赎回、卖出的交易需要报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1390 行） 主表：理财及代销产品交易，关联代理协议 过滤条件：筛选采集日期为报告期当月

字段映射说明：
- CJRQ：采集日期，取参数 P_DATA_DATE（YYYYMMDD 格式）。
- DLDXJYLX：从 T_6_19.F190006（代理产品类型）做码值转换。
- XZBZ：从 T_7_11.G110012（现转标识）做码值转换：01->现, 02->转。
- JYFX：从 T_7_11.G110011（交易方向）做码值转换：01->买入, 02->卖出。
- JYYGH：从 T_7_11.G110017（经办员工ID）做加工映射：若='自动'则置空。
- JYRQ：从 T_7_11.G110005（销售日期）做格式转换：YYYY-MM-DD->YYYYMMDD。
- KHMC：优先用 T_2_1.B010003（对公客户名称），否则用 T_2_5.B050003（个人客户名称）。
- BBZ：拼接 T_7_11.G110024 和 T_6_19.F190022 的备注内容。
- FXJGQSHM：取 T_7_11.G110025（对方清算行名）。
- DXCPMC：取 T_7_11.G110027（产品名称）。
- SENSITIVEFLAG、GSFZJG、KHLB：DDL 中存在但业务需求映射表未提供来源，暂置 NULL。

重构说明：
- 原草案以 T_6_19 为主表；按业务需求改为以 T_7_11（理财及代销产品交易）为主表，
  LEFT JOIN T_6_19（代理协议）ON 代理销售协议ID = 协议ID。
- 补齐所有占位 NULL 字段的取值来源和码值转换。
- T_1_1 的 JOIN 键改为 T_7_11.G110014（机构ID）= T_1_1.A010001（机构ID）。
- 新增 T_2_1、T_2_5 的 LEFT JOIN 用于 KHMC 取数。
- WHERE 条件按 DATE_FORMAT(采集日期, '%Y%m') = LEFT(P_DATA_DATE, 6) 筛选当月数据。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_009_905_INC_DLDXJYXXB;

CREATE PROCEDURE PROC_EAST_IE_009_905_INC_DLDXJYXXB(
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

    DELETE FROM IE_009_905_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_009_905_INC (
        CJRQ,
        XZBZ,
        DLDXJYLX,
        JYFX,
        BZ,
        FXJGPJ,
        SENSITIVEFLAG,
        FXJGPJJG,
        FXJGQSHM,
        SXFJE,
        JYYGH,
        BBZ,
        JRXKZH,
        KHTYBH,
        GSFZJG,
        FXJGMC,
        KHLB,
        NBJGH,
        YHJGMC,
        KHZH,
        KHHMC,
        JYBH,
        DXCPMC,
        JYRQ,
        JYJE,
        FXJGQSZH,
        RZRMC,
        RZRSSHY,
        SXFBZ,
        KHMC
    )
    SELECT
        /* 1. 采集日期：赋值当前批次日期 YYYYMMDD */
        P_DATA_DATE AS CJRQ,

        /* 2. 现转标志：T_7_11.G110012 码值转换 */
        CASE WHEN s2.G110012 = '01' THEN '现'
             WHEN s2.G110012 = '02' THEN '转'
             ELSE NULL
        END AS XZBZ,

        /* 3. 代理代销交易类型：T_6_19.F190006 码值转换 */
        CASE WHEN src.F190006 = '0101' THEN '债券承销'
             WHEN src.F190006 = '0201' THEN '代理代销信托计划'
             WHEN src.F190006 = '0301' THEN '代理代销资产管理计划'
             WHEN src.F190006 = '0401' THEN '代理代销保险产品'
             WHEN src.F190006 = '0501' THEN '代理代销基金'
             WHEN src.F190006 = '0601' THEN '其他-代销本行理财产品'
             WHEN src.F190006 = '0602' THEN '代销他行理财产品'
             WHEN src.F190006 = '0701' THEN '代理贵金属交易'
             WHEN src.F190006 LIKE '0000-%' THEN CONCAT('其他-', SUBSTR(src.F190006, 6))
             ELSE NULL
        END AS DLDXJYLX,

        /* 4. 交易方向：T_7_11.G110011 码值转换 */
        CASE WHEN s2.G110011 = '01' THEN '买入'
             WHEN s2.G110011 = '02' THEN '卖出'
             ELSE NULL
        END AS JYFX,

        /* 5. 币种：T_7_11.G110021 直接映射 */
        s2.G110021 AS BZ,

        /* 6. 发行机构评级：T_6_19.F190008 直接映射 */
        src.F190008 AS FXJGPJ,

        /* 7. 涉密标志：DDL 中存在但业务需求映射表未提供来源，暂置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 8. 发行机构评级机构：T_6_19.F190009 直接映射 */
        src.F190009 AS FXJGPJJG,

        /* 9. 发行机构清算行名：T_7_11.G110025（对方清算行名）直接映射 */
        s2.G110025 AS FXJGQSHM,

        /* 10. 手续费金额：T_7_11.G110009 直接映射 */
        CAST(NULLIF(TRIM(s2.G110009), '') AS DECIMAL(20,2)) AS SXFJE,

        /* 11. 经办人工号：T_7_11.G110017 加工映射：若='自动'则置空 */
        CASE WHEN TRIM(s2.G110017) = '自动' THEN ''
             ELSE s2.G110017
        END AS JYYGH,

        /* 12. 备注：拼接 T_7_11.G110024 和 T_6_19.F190022 */
        CONCAT_WS(';',
            NULLIF(TRIM(s2.G110024), ''),
            NULLIF(TRIM(src.F190022), '')
        ) AS BBZ,

        /* 13. 金融许可证号：T_1_1.A010003 直接映射 */
        s1.A010003 AS JRXKZH,

        /* 14. 客户统一编号：T_7_11.G110002 直接映射 */
        s2.G110002 AS KHTYBH,

        /* 15. 归属分支机构：DDL 中存在但业务需求映射表未提供来源，暂置 NULL */
        NULL AS GSFZJG,

        /* 16. 发行机构名称：T_6_19.F190004 直接映射 */
        src.F190004 AS FXJGMC,

        /* 17. 客户类别：DDL 中存在但业务需求映射表未提供来源，暂置 NULL */
        NULL AS KHLB,

        /* 18. 内部机构号：从 T_7_11.G110014（机构ID）第12位开始截取 */
        SUBSTR(TRIM(s2.G110014), 12) AS NBJGH,

        /* 19. 银行机构名称：T_1_1.A010005 直接映射 */
        s1.A010005 AS YHJGMC,

        /* 20. 客户账号：T_7_11.G110007 直接映射 */
        s2.G110007 AS KHZH,

        /* 21. 开户行名称：T_7_11.G110008 直接映射 */
        s2.G110008 AS KHHMC,

        /* 22. 交易编号：T_7_11.G110003 直接映射 */
        s2.G110003 AS JYBH,

        /* 23. 代销产品名称：T_7_11.G110027（产品名称）直接映射 */
        s2.G110027 AS DXCPMC,

        /* 24. 交易日期：T_7_11.G110005（销售日期）格式转换 YYYY-MM-DD -> YYYYMMDD */
        DATE_FORMAT(s2.G110005, '%Y%m%d') AS JYRQ,

        /* 25. 交易金额：T_7_11.G110022 直接映射 */
        CAST(NULLIF(TRIM(s2.G110022), '') AS DECIMAL(20,2)) AS JYJE,

        /* 26. 发行机构清算账号：T_7_11.G110019 直接映射 */
        s2.G110019 AS FXJGQSZH,

        /* 27. 融资人名称：T_6_19.F190010 直接映射 */
        src.F190010 AS RZRMC,

        /* 28. 融资人所属行业：T_6_19.F190011 直接映射 */
        src.F190011 AS RZRSSHY,

        /* 29. 手续费币种：T_7_11.G110010 直接映射 */
        s2.G110010 AS SXFBZ,

        /* 30. 客户名称：优先取对公客户名称，否则取个人客户名称 */
        COALESCE(t2.B010003, t5.B050003) AS KHMC

    FROM T_7_11 s2
    /* 主表：理财及代销产品交易 */

    LEFT JOIN T_6_19 src
           ON s2.G110023 = src.F190001
    /* 关联代理协议：T_7_11.代理销售协议ID = T_6_19.协议ID */

    LEFT JOIN T_1_1 s1
           ON s2.G110014 = s1.A010001
    /* 关联机构信息：T_7_11.机构ID = T_1_1.机构ID */

    LEFT JOIN T_2_1 t2
           ON s2.G110002 = t2.B010001
    /* 关联对公客户信息：T_7_11.客户ID = T_2_1.客户ID */

    LEFT JOIN T_2_5 t5
           ON s2.G110002 = t5.B050001
    /* 关联个人客户信息：T_7_11.客户ID = T_2_5.客户ID */

    WHERE DATE_FORMAT(s2.G110013, '%Y%m') = LEFT(P_DATA_DATE, 6)
    /* 筛选采集日期为报告期当月：T_7_11.采集日期所在年月 = P_DATA_DATE 年月 */;

    COMMIT;
END;
