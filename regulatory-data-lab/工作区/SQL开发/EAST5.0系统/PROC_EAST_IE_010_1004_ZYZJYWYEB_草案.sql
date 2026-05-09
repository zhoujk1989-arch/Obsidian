/*
草案质量状态：合格（2026-05-10 重构校准完成，BQSY 差额口径已修正）
历史处理：原草案含源表、字段和过滤占位，本次已整体替换为可复核草案，且已完成 BQSY 差额口径修正。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
重构校准说明：2026-05-10 依据《061_自营资金业务余额表.md》、目标 DDL 和一表通源表 DDL 完成三段 UNION ALL 重写。
  - 投资情况段：T_8_8 关联 T_9_2/T_6_21/T_8_12/T_5_1/T_1_1/T_7_7，并按余额、上月末余额、本月交易、失效日期纳入。
  - 同业存量情况段：T_8_7 关联 T_9_2/T_8_12/T_5_1/T_1_1，并排除同业存放和结算性存放同业。
  - 融资情况段：T_8_9 关联 T_9_2/T_8_12/T_5_1/T_1_1/T_4_2，并按融资标的ID分组取成本总额最大记录。
  - 2 个缺口字段（SENSITIVEFLAG/GSFZJG）业务需求无来源，按需求置 NULL。
  - BQSY（本期收益）实现 1 月直接取值、非 1 月本月减上月差额口径。
  - LJSY（累计收益）维持直接映射（业务需求第 17 条：来源于本期投资收益/本期收益）。
*/

/*
业务目标：
- 依据原始业务需求《061_自营资金业务余额表.md》生成 EAST5.0 自营资金业务余额表（IE_010_1004）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/061_自营资金业务余额表.md
- 原始材料/表结构/EAST5.0系统/IE_010_1004-自营资金业务余额表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_8_8-投资情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_7-同业存量情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_9-融资情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_9_2-投融资标的-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_21-投资协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_12-五级分类状态-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_5_1-产品业务基本信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_4_2-科目信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_7_7-投资交易-DDL-2026-04-27.sql

源表：
- T_8_8：投资情况，投资余额、自营业务类别、账户类型、收益、成本、科目、币种、交易机构和投资标的。
- T_8_7：同业存量情况，同业合同余额、自营业务类别、账户类型、收益、成本、科目、币种、交易机构和投资标的。
- T_8_9：融资情况，融资余额、融资工具子类型、收益、成本、科目、币种、机构和融资标的。
- T_9_2：投融资标的，金融工具编号/名称、起息日期、到期日期和资产风险权重。
- T_6_21：投资协议，投资段起息日期和协议备注。
- T_8_12：五级分类状态，五级分类和减值准备。
- T_5_1：产品业务基本信息，自营标识和产品名称。
- T_1_1：机构信息，金融许可证号和银行机构名称。
- T_4_2：科目信息，融资段明细科目名称。
- T_7_7：投资交易，投资段本月发生交易的终态纳入判断。

目标表：
- IE_010_1004：自营资金业务余额表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入三段 UNION ALL 映射结果。

未确认点：
  - 投资情况、同业存量情况的业务中类/小类按需求需关联 BS_CS_GGDM 码值表转换中文含义；当前未取得码值表 DDL，暂取源代码原值。
  - 日期函数采用 GBase 常见 TO_DATE/TO_CHAR 与 DATE_SUB 写法，需在现场 GBase 版本执行验证。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_010_1004_ZYZJYWYEB;

CREATE PROCEDURE PROC_EAST_IE_010_1004_ZYZJYWYEB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_MONTH_BEGIN DATE;
    DECLARE V_PREV_MONTH_END DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = TO_DATE(P_DATA_DATE, 'YYYYMMDD');
    SET V_MONTH_BEGIN = TO_DATE(CONCAT(SUBSTR(P_DATA_DATE, 1, 6), '01'), 'YYYYMMDD');
    SET V_PREV_MONTH_END = DATE_SUB(V_MONTH_BEGIN, INTERVAL 1 DAY);

    START TRANSACTION;

    DELETE FROM IE_010_1004
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_010_1004 (
        BZ,
        SENSITIVEFLAG,
        BBZ,
        QXRQ,
        WJFL,
        NHLL,
        ZMYE,
        CPMC,
        YWZL,
        JYZHLX,
        JRGJBH,
        MXKMMC,
        MXKMBH,
        NBJGH,
        JRGJMC,
        GSFZJG,
        YHJGMC,
        JRXKZH,
        BQSY,
        CYCB,
        YWXL,
        YEDL,
        CJRQ,
        DQRQ,
        JZZB,
        XYFXQZ,
        LJSY
    )
    /* Part 1: 投资情况。每行代表采集日一笔投资标的+协议+科目下的自营投资余额或本月终态记录。 */
    SELECT
        cur.H080012 AS BZ,
        NULL AS SENSITIVEFLAG,
        TRIM(BOTH '；' FROM CONCAT(
            COALESCE(NULLIF(TRIM(cur.H080031), ''), ''),
            CASE
                WHEN NULLIF(TRIM(cur.H080031), '') IS NOT NULL
                 AND NULLIF(TRIM(agr.F210029), '') IS NOT NULL THEN '；'
                ELSE ''
            END,
            COALESCE(NULLIF(TRIM(agr.F210029), ''), '')
        )) AS BBZ,
        COALESCE(TO_CHAR(agr.F210008, 'YYYYMMDD'), TO_CHAR(inst.J020014, 'YYYYMMDD')) AS QXRQ,
        CASE cls.H120005
            WHEN '01' THEN '正常'
            WHEN '02' THEN '关注'
            WHEN '03' THEN '次级'
            WHEN '04' THEN '可疑'
            WHEN '05' THEN '损失'
            ELSE ''
        END AS WJFL,
        CAST(NULLIF(TRIM(cur.H080024), '') AS DECIMAL(20,6)) AS NHLL,
        CAST(NULLIF(TRIM(cur.H080011), '') AS DECIMAL(20,2)) AS ZMYE,
        prod.E010003 AS CPMC,
        cur.H080018 AS YWZL,
        CASE cur.H080006
            WHEN '01' THEN '银行账户'
            WHEN '02' THEN '交易账户'
            ELSE NULL
        END AS JYZHLX,
        COALESCE(NULLIF(TRIM(inst.J020011), ''), NULLIF(TRIM(inst.J020001), '')) AS JRGJBH,
        cur.H080009 AS MXKMMC,
        cur.H080008 AS MXKMBH,
        SUBSTR(cur.H080003, 13) AS NBJGH,
        inst.J020002 AS JRGJMC,
        NULL AS GSFZJG,
        org.A010005 AS YHJGMC,
        org.A010003 AS JRXKZH,
        CASE
            WHEN SUBSTR(P_DATA_DATE, 5, 2) = '01'
            THEN CAST(NULLIF(TRIM(cur.H080013), '') AS DECIMAL(20,2))
            ELSE CAST(COALESCE(NULLIF(TRIM(cur.H080013), ''), '0') AS DECIMAL(20,2))
                 - CAST(COALESCE(NULLIF(TRIM(prev.H080013), ''), '0') AS DECIMAL(20,2))
        END AS BQSY,
        CAST(NULLIF(TRIM(cur.H080015), '') AS DECIMAL(20,2)) AS CYCB,
        cur.H080019 AS YWXL,
        CASE
            WHEN cur.H080018 = '09' OR cur.H080019 LIKE '11020%' THEN '同业往来'
            ELSE '债券投资与同业投资'
        END AS YEDL,
        P_DATA_DATE AS CJRQ,
        TO_CHAR(inst.J020016, 'YYYYMMDD') AS DQRQ,
        CAST(COALESCE(NULLIF(TRIM(cls.H120014), ''), '0') AS DECIMAL(20,2)) AS JZZB,
        CAST(COALESCE(NULLIF(TRIM(inst.J020022), ''), '0') AS DECIMAL(20,6)) / 100 AS XYFXQZ,
        CAST(NULLIF(TRIM(cur.H080013), '') AS DECIMAL(20,2)) AS LJSY
    FROM T_8_8 cur
    LEFT JOIN T_8_8 prev
           ON prev.H080004 = cur.H080004
          AND prev.H080001 = cur.H080001
          AND COALESCE(prev.H080008, '') = COALESCE(cur.H080008, '')
          AND prev.H080017 = V_PREV_MONTH_END
    LEFT JOIN T_9_2 inst
           ON inst.J020001 = cur.H080001
          AND inst.J020105 = V_DATA_DATE
    LEFT JOIN T_6_21 agr
           ON agr.F210001 = cur.H080004
          AND agr.F210002 = cur.H080003
          AND agr.F210030 = V_DATA_DATE
    LEFT JOIN T_8_12 cls
           ON cls.H120001 = cur.H080004
          AND cls.H120002 = cur.H080001
          AND cls.H120003 = cur.H080003
          AND cls.H120013 = V_DATA_DATE
    INNER JOIN T_5_1 prod
            ON prod.E010001 = cur.H080007
           AND prod.E010002 = cur.H080003
           AND prod.E010017 = V_DATA_DATE
           AND prod.E010008 = '01'
    LEFT JOIN T_1_1 org
           ON org.A010001 = cur.H080003
          AND org.A010020 = V_DATA_DATE
    WHERE cur.H080017 = V_DATA_DATE
      AND (
            CAST(COALESCE(NULLIF(TRIM(cur.H080011), ''), '0') AS DECIMAL(20,2)) <> 0
         OR (
                CAST(COALESCE(NULLIF(TRIM(cur.H080011), ''), '0') AS DECIMAL(20,2)) = 0
            AND CAST(COALESCE(NULLIF(TRIM(prev.H080011), ''), '0') AS DECIMAL(20,2)) <> 0
            )
         OR EXISTS (
                SELECT 1
                FROM T_7_7 trn
                WHERE trn.G070005 = cur.H080001
                  AND COALESCE(trn.G070013, '') = COALESCE(cur.H080008, '')
                  AND trn.G070002 = cur.H080003
                  AND trn.G070032 BETWEEN V_MONTH_BEGIN AND V_DATA_DATE
            )
         OR (cur.H080030 IS NOT NULL AND cur.H080030 >= V_MONTH_BEGIN)
      )

    UNION ALL

    /* Part 2: 同业存量情况。每行代表采集日一笔同业业务的自营存量余额或本月终态记录。 */
    SELECT
        cur.H070010 AS BZ,
        NULL AS SENSITIVEFLAG,
        cur.H070026 AS BBZ,
        TO_CHAR(cur.H070011, 'YYYYMMDD') AS QXRQ,
        CASE cls.H120005
            WHEN '01' THEN '正常'
            WHEN '02' THEN '关注'
            WHEN '03' THEN '次级'
            WHEN '04' THEN '可疑'
            WHEN '05' THEN '损失'
            ELSE ''
        END AS WJFL,
        CAST(NULLIF(TRIM(cur.H070013), '') AS DECIMAL(20,6)) AS NHLL,
        CAST(NULLIF(TRIM(cur.H070009), '') AS DECIMAL(20,2)) AS ZMYE,
        prod.E010003 AS CPMC,
        cur.H070020 AS YWZL,
        CASE cur.H070007
            WHEN '01' THEN '银行账户'
            WHEN '02' THEN '交易账户'
            ELSE NULL
        END AS JYZHLX,
        COALESCE(NULLIF(TRIM(inst.J020011), ''), NULLIF(TRIM(inst.J020001), '')) AS JRGJBH,
        cur.H070006 AS MXKMMC,
        cur.H070005 AS MXKMBH,
        SUBSTR(cur.H070002, 13) AS NBJGH,
        inst.J020002 AS JRGJMC,
        NULL AS GSFZJG,
        org.A010005 AS YHJGMC,
        org.A010003 AS JRXKZH,
        CASE
            WHEN SUBSTR(P_DATA_DATE, 5, 2) = '01'
            THEN CAST(NULLIF(TRIM(cur.H070018), '') AS DECIMAL(20,2))
            ELSE CAST(COALESCE(NULLIF(TRIM(cur.H070018), ''), '0') AS DECIMAL(20,2))
                 - CAST(COALESCE(NULLIF(TRIM(prev.H070018), ''), '0') AS DECIMAL(20,2))
        END AS BQSY,
        CAST(NULLIF(TRIM(cur.H070028), '') AS DECIMAL(20,2)) AS CYCB,
        cur.H070021 AS YWXL,
        '同业往来' AS YEDL,
        P_DATA_DATE AS CJRQ,
        TO_CHAR(cur.H070012, 'YYYYMMDD') AS DQRQ,
        CAST(COALESCE(NULLIF(TRIM(cls.H120014), ''), '0') AS DECIMAL(20,2)) AS JZZB,
        CAST(COALESCE(NULLIF(TRIM(inst.J020022), ''), '0') AS DECIMAL(20,6)) / 100 AS XYFXQZ,
        CAST(NULLIF(TRIM(cur.H070018), '') AS DECIMAL(20,2)) AS LJSY
    FROM T_8_7 cur
    LEFT JOIN T_8_7 prev
           ON prev.H070001 = cur.H070001
          AND prev.H070002 = cur.H070002
          AND prev.H070017 = V_PREV_MONTH_END
    LEFT JOIN T_9_2 inst
           ON inst.J020001 = cur.H070016
          AND inst.J020105 = V_DATA_DATE
    LEFT JOIN T_8_12 cls
           ON cls.H120002 = cur.H070001
          AND cls.H120003 = cur.H070002
          AND cls.H120013 = V_DATA_DATE
    INNER JOIN T_5_1 prod
            ON prod.E010001 = cur.H070027
           AND prod.E010002 = cur.H070002
           AND prod.E010017 = V_DATA_DATE
           AND prod.E010008 = '01'
    LEFT JOIN T_1_1 org
           ON org.A010001 = cur.H070002
          AND org.A010020 = V_DATA_DATE
    WHERE cur.H070017 = V_DATA_DATE
      AND COALESCE(TRIM(cur.H070020), '') <> '08'
      AND COALESCE(TRIM(cur.H070021), '') <> '07020'
      AND (
            prev.H070001 IS NULL
         OR (
                CAST(COALESCE(NULLIF(TRIM(cur.H070009), ''), '0') AS DECIMAL(20,2)) = 0
            AND CAST(COALESCE(NULLIF(TRIM(prev.H070009), ''), '0') AS DECIMAL(20,2)) <> 0
            )
         OR CAST(COALESCE(NULLIF(TRIM(cur.H070009), ''), '0') AS DECIMAL(20,2)) <> 0
         OR (cur.H070029 IS NOT NULL AND cur.H070029 >= V_MONTH_BEGIN)
      )

    UNION ALL

    /* Part 3: 融资情况。每行代表采集日按融资标的ID保留成本总额最大的一笔融资余额或本月终态记录。 */
    SELECT
        cur.H090006 AS BZ,
        NULL AS SENSITIVEFLAG,
        cur.H090022 AS BBZ,
        TO_CHAR(cur.H090015, 'YYYYMMDD') AS QXRQ,
        CASE cls.H120005
            WHEN '01' THEN '正常'
            WHEN '02' THEN '关注'
            WHEN '03' THEN '次级'
            WHEN '04' THEN '可疑'
            WHEN '05' THEN '损失'
            ELSE ''
        END AS WJFL,
        CAST(NULLIF(TRIM(cur.H090008), '') AS DECIMAL(20,6)) AS NHLL,
        CAST(NULLIF(TRIM(cur.H090007), '') AS DECIMAL(20,2)) AS ZMYE,
        prod.E010003 AS CPMC,
        CASE
            WHEN cur.H090004 = '012' THEN '同业存单'
            WHEN cur.H090004 IN ('021', '031', '032', '033', '034', '039', '041', '051', '061', '071', '081', '091') THEN '债券发行'
            ELSE '其他'
        END AS YWZL,
        '银行账户' AS JYZHLX,
        COALESCE(NULLIF(TRIM(inst.J020011), ''), NULLIF(TRIM(inst.J020001), '')) AS JRGJBH,
        subj.D020003 AS MXKMMC,
        cur.H090012 AS MXKMBH,
        SUBSTR(cur.H090011, 13) AS NBJGH,
        inst.J020002 AS JRGJMC,
        NULL AS GSFZJG,
        org.A010005 AS YHJGMC,
        org.A010003 AS JRXKZH,
        CASE
            WHEN SUBSTR(P_DATA_DATE, 5, 2) = '01'
            THEN CAST(NULLIF(TRIM(cur.H090023), '') AS DECIMAL(20,2))
            ELSE CAST(COALESCE(NULLIF(TRIM(cur.H090023), ''), '0') AS DECIMAL(20,2))
                 - CAST(COALESCE(NULLIF(TRIM(prev.H090023), ''), '0') AS DECIMAL(20,2))
        END AS BQSY,
        CAST(NULLIF(TRIM(cur.H090014), '') AS DECIMAL(20,2)) AS CYCB,
        CASE
            WHEN cur.H090004 = '012' THEN '同业存单发行'
            WHEN cur.H090004 = '021' THEN '商业银行债'
            WHEN cur.H090004 = '081' THEN '银行永续债'
            WHEN cur.H090004 = '041' THEN '银行次级债'
            ELSE '其他-银行自定义'
        END AS YWXL,
        '同业往来' AS YEDL,
        P_DATA_DATE AS CJRQ,
        TO_CHAR(cur.H090016, 'YYYYMMDD') AS DQRQ,
        CAST(COALESCE(NULLIF(TRIM(cls.H120014), ''), '0') AS DECIMAL(20,2)) AS JZZB,
        CAST(COALESCE(NULLIF(TRIM(inst.J020022), ''), '0') AS DECIMAL(20,6)) / 100 AS XYFXQZ,
        CAST(NULLIF(TRIM(cur.H090023), '') AS DECIMAL(20,2)) AS LJSY
    FROM (
        SELECT
            s.*,
            ROW_NUMBER() OVER (
                PARTITION BY s.H090020
                ORDER BY CAST(COALESCE(NULLIF(TRIM(s.H090014), ''), '0') AS DECIMAL(20,2)) DESC,
                         s.H090001
            ) AS rn
        FROM T_8_9 s
        WHERE s.H090010 = V_DATA_DATE
          AND (
                (
                    COALESCE(TRIM(s.H090004), '') NOT IN ('011')
                AND s.H090016 >= V_MONTH_BEGIN
                )
             OR (s.H090025 IS NOT NULL AND s.H090025 >= V_MONTH_BEGIN)
          )
    ) cur
    LEFT JOIN T_8_9 prev
           ON prev.H090020 = cur.H090020
          AND prev.H090001 = cur.H090001
          AND prev.H090010 = V_PREV_MONTH_END
    LEFT JOIN T_9_2 inst
           ON inst.J020001 = cur.H090020
          AND inst.J020105 = V_DATA_DATE
    LEFT JOIN T_8_12 cls
           ON cls.H120002 = cur.H090001
          AND cls.H120003 = cur.H090011
          AND cls.H120013 = V_DATA_DATE
    INNER JOIN T_5_1 prod
            ON prod.E010001 = cur.H090002
           AND prod.E010002 = cur.H090011
           AND prod.E010017 = V_DATA_DATE
           AND prod.E010008 = '01'
    LEFT JOIN T_1_1 org
           ON org.A010001 = cur.H090011
          AND org.A010020 = V_DATA_DATE
    LEFT JOIN T_4_2 subj
           ON subj.D020001 = cur.H090012
          AND subj.D020002 = cur.H090011
          AND subj.D020011 = V_DATA_DATE
    WHERE cur.rn = 1;

    COMMIT;
END;
