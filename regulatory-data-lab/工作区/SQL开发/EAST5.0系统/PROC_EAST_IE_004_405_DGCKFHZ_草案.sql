/*
草案质量状态：待验证（JOIN 条件、码值 CASE、WHERE 过滤已按业务需求补齐，尚未在 GBase 环境执行验证）。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md

校准记录：2026-05-10 按业务需求序号校准字段顺序；码值 CASE ELSE 改为 NULL；日期 CONCAT 改为 TO_CHAR；
          NULLIF(TRIM) 改为 NULLIF；DATE_FORMAT 改为 TO_CHAR。
*/

/*
业务目标：
- 依据原始业务需求《020_对公存款分户账.md》生成 EAST5.0 对公存款分户账（IE_004_405）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/020_对公存款分户账.md
- 原始材料/表结构/EAST5.0系统/IE_004_405-对公存款分户账-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_1-存款协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_4_3-分户账信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_4_2-科目信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_14-存款状态-DDL-2026-04-27.sql

源表：
- T_6_1（存款协议）— 主表
- T_4_3（分户账信息）— 内关联，过滤分户账类型='01'、账户状态条件
- T_1_1（机构信息）— 左关联，取金融许可证号、银行机构名称
- T_4_2（科目信息）— 左关联，取会计科目名称
- T_8_14（存款状态）— 左关联，取存款余额、上次动户日期

目标表：
- IE_004_405：对公存款分户账。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 填报银行机构吸收的除个人以外的机构（包括企业、财政部门、社保基金、部队、住房公积金、社会团体、同业机构等）开立的所有存款账户信息。个人存款账户和对公存款账户按照《人民币银行结算账户管理办法》（中国人民银行令2003年第5号）划分。个体工商户、私营业主以营业执照等证件开立的对公账户计入本表，以个人名义开立的账户不计入本表。以存款账号为最小颗粒报送，如账户注销或终结，在报送该账户最终状态后的次月可不再报送。

表级取数与关联规则（原文摘录）：
主表：【存款协议】(T_6_1)
 内关联1：【分户账信息表】(T_4_3)
 关联条件1：
   T_6_1.F010007 = T_4_3.D030002  -- 分户账号
   AND T_6_1.F010022 = T_4_3.D030009  -- 币种
   AND T_6_1.F010023 = T_4_3.D030016  -- 钞汇类别
   AND T_4_3.D030005 = '01'  -- 分户账类型
 左关联：【机构信息表】(T_1_1)
 关联条件：T_6_1.F010002 = T_1_1.A010001  -- 内部机构号
 左关联：【科目信息】(T_4_2)
 关联条件：T_6_1.F010005 = T_4_2.D020001  -- 科目ID
 左关联：【存款状态】(T_8_14) — 整张表，非单字段
 关联条件：
   T_6_1.F010001 = T_8_14.H140018  -- 协议ID
   AND T_6_1.F010007 = T_8_14.H140001  -- 分户账号
   AND T_6_1.F010022 = T_8_14.H140004  -- 币种
   AND T_6_1.F010023 = T_8_14.H140017  -- 钞汇类别
筛选条件：
   (T_4_3.D030013 <> '03')  -- 账户状态不为销户
   OR (T_4_3.D030013 = '03' AND T_4_3.D030012 >= 上月首日)  -- 销户且销户日期在当月

未确认点：
- T_6_1（存款协议）DDL 中无"账户状态"字段，业务需求文档第19条标注来源为"存款协议.账户状态"与实际 DDL 不符；
  经核对 T_4_3（分户账信息）DDL，账户状态字段为 D030013。本草案以 T_4_3.D030013 作为 ZHZT 来源，
  并在 Open Questions 中标注此冲突。
- T_8_14（存款状态）的关联键字段名已根据 DDL 确认：
  H140018=协议ID, H140001=分户账号, H140004=币种, H140017=钞汇类别。
  存款余额取自 H140013，上次动户日期取自 H140016。
- GBase 尚未执行验证，目标页和血缘状态应保持 draft。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_405_DGCKFHZ;

CREATE PROCEDURE PROC_EAST_IE_004_405_DGCKFHZ(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_LAST_MONTH_FIRST DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);

    -- 计算上月首日，用于筛选当月销户的账户
    SET V_LAST_MONTH_FIRST = DATE_SUB(TO_DATE(TO_CHAR(V_DATA_DATE, 'YYYY-MM-01'), 'YYYY-MM-DD'), INTERVAL 1 MONTH);

    START TRANSACTION;

    DELETE FROM IE_004_405
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_405 (
        JRXKZH,          /* 1.  金融许可证号 */
        NBJGH,           /* 2.  内部机构号 */
        YHJGMC,          /* 3.  银行机构名称 */
        MXKMBH,          /* 4.  明细科目编号 */
        MXKMMC,          /* 5.  明细科目名称 */
        KHTYBH,          /* 6.  客户统一编号 */
        ZHMC,            /* 7.  账户名称 */
        DGCKZH,          /* 8.  对公存款账号 */
        DGCKZHLX,        /* 9.  对公存款账户类型 */
        BZJZHBZ,         /* 10. 保证金账户标志 */
        LL,              /* 11. 利率 */
        BZ,              /* 12. 币种 */
        CKYE,            /* 13. 存款余额 */
        KHRQ,            /* 14. 开户日期 */
        KHGYH,           /* 15. 开户柜员号 */
        XHRQ,            /* 16. 销户日期 */
        SCDHRQ,          /* 17. 上次动户日期 */
        CHLB,            /* 18. 钞汇类别 */
        ZHZT,            /* 19. 账户状态 */
        BBZ,             /* 20. 备注 */
        GSFZJG,          /* 21. 归属分支机构（系统保留，置NULL） */
        SENSITIVEFLAG,   /* 22. 涉密标志（系统保留，置NULL） */
        CJRQ             /* 23. 采集日期 */
    )
    SELECT
        /* 1. 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003 */
        s3.A010003 AS JRXKZH,

        /* 2. 内部机构号：存款协议.机构ID -> T_6_1.F010002，从第12位开始截取 */
        SUBSTR(TRIM(src.F010002), 12) AS NBJGH,

        /* 3. 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005 */
        s3.A010005 AS YHJGMC,

        /* 4. 明细科目编号：存款协议.科目ID -> T_6_1.F010005 */
        src.F010005 AS MXKMBH,

        /* 5. 明细科目名称：科目信息.科目名称 -> T_4_2.D020003 */
        s4.D020003 AS MXKMMC,

        /* 6. 客户统一编号：存款协议.客户ID -> T_6_1.F010003 */
        src.F010003 AS KHTYBH,

        /* 7. 账户名称：分户账信息.分户账名称 -> T_4_3.D030004 */
        s1.D030004 AS ZHMC,

        /* 8. 对公存款账号：存款协议.分户账号 -> T_6_1.F010007 */
        src.F010007 AS DGCKZH,

        /* 9. 对公存款账户类型：存款协议.存款产品类别/社会保障基金存款标识 -> T_6_1.F010048/F010049 */
        CASE
            WHEN src.F010049 = '1' THEN '社会保障基金'
            WHEN src.F010048 = '01' THEN '单位活期存款'
            WHEN src.F010048 = '02' THEN '单位定期存款'
            WHEN src.F010048 = '03' THEN '单位通知存款'
            WHEN src.F010048 = '04' THEN '单位协议存款'
            WHEN src.F010048 = '05' THEN '单位协定存款'
            WHEN src.F010048 = '06' THEN '单位保证金存款'
            WHEN src.F010048 = '07' THEN '单位结构性存款（不含保本理财）'
            WHEN src.F010048 = '08' THEN '单位其他存款'
            WHEN src.F010048 = '18' THEN '其他-国库定期存款'
            WHEN src.F010048 = '19' THEN '其他-临时性存款'
            WHEN src.F010048 IN ('20', '21') THEN '保险公司存放款'
            WHEN src.F010048 = '22' THEN '同业存放款'
            WHEN src.F010048 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(src.F010048, 5))
            ELSE NULL
        END AS DGCKZHLX,

        /* 10. 保证金账户标志：存款协议.保证金账户标识 -> T_6_1.F010016 */
        CASE WHEN src.F010016 = '1' THEN '是' ELSE '否' END AS BZJZHBZ,

        /* 11. 利率：存款协议.利率 -> T_6_1.F010017 */
        CAST(NULLIF(src.F010017, '') AS DECIMAL(20,6)) AS LL,

        /* 12. 币种：存款协议.协议币种 -> T_6_1.F010022 */
        src.F010022 AS BZ,

        /* 13. 存款余额：存款状态.存款余额 -> T_8_14.H140013 */
        CAST(NULLIF(s2.H140013, '') AS DECIMAL(20,2)) AS CKYE,

        /* 14. 开户日期：存款协议.开户日期 -> T_6_1.F010019 */
        CASE WHEN src.F010019 IS NULL THEN '99991231'
             ELSE TO_CHAR(src.F010019, 'YYYYMMDD')
        END AS KHRQ,

        /* 15. 开户柜员号：存款协议.经办员工ID -> T_6_1.F010028 */
        CASE WHEN src.F010028 = '自动' THEN NULL ELSE src.F010028 END AS KHGYH,

        /* 16. 销户日期：存款协议.销户日期 -> T_6_1.F010024 */
        CASE WHEN src.F010024 IS NULL THEN '99991231'
             ELSE TO_CHAR(src.F010024, 'YYYYMMDD')
        END AS XHRQ,

        /* 17. 上次动户日期：存款状态.上次动户日期 -> T_8_14.H140016 */
        CASE WHEN s2.H140016 IS NULL THEN '99991231'
             ELSE TO_CHAR(s2.H140016, 'YYYYMMDD')
        END AS SCDHRQ,

        /* 18. 钞汇类别：存款协议.钞汇类别 -> T_6_1.F010023 */
        CASE
            WHEN src.F010022 = 'CNY' THEN '人民币'
            WHEN src.F010023 = '01' THEN '钞'
            WHEN src.F010023 = '02' THEN '汇'
            WHEN src.F010023 = '03' THEN '可钞可汇'
            WHEN src.F010023 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(src.F010023, 5))
            ELSE NULL
        END AS CHLB,

        /* 19. 账户状态：分户账信息.账户状态 -> T_4_3.D030013
           注意：业务需求文档标注来源为"存款协议.账户状态"，但 T_6_1 DDL 无此字段；
           实际账户状态在 T_4_3.D030013，本草案以 T_4_3 为准。详见 Open Questions。 */
        CASE
            WHEN s1.D030013 = '01' THEN '正常'
            WHEN s1.D030013 = '02' THEN '预销户'
            WHEN s1.D030013 = '03' THEN '销户'
            WHEN s1.D030013 = '04' THEN '冻结'
            WHEN s1.D030013 = '05' THEN '止付'
            WHEN s1.D030013 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(s1.D030013, 5))
            ELSE NULL
        END AS ZHZT,

        /* 20. 备注：多源拼接 */
        CONCAT_WS(';',
            src.F010032,          -- 存款协议.备注 (T_6_1.F010032)
            s2.H140021,           -- 存款状态.备注 (T_8_14.H140021)
            s1.D030014,           -- 分户账信息.备注 (T_4_3.D030014)
            s3.A010026,           -- 机构信息.备注 (T_1_1.A010026)
            s4.D020010            -- 科目信息.备注 (T_4_2.D020010)
        ) AS BBZ,

        /* 21. 归属分支机构：系统保留字段，不派生，置NULL */
        NULL AS GSFZJG,

        /* 22. 涉密标志：系统保留字段，不派生，置NULL */
        NULL AS SENSITIVEFLAG,

        /* 23. 采集日期：参数 P_DATA_DATE */
        P_DATA_DATE AS CJRQ

    FROM T_6_1 src
    /* 内关联：分户账信息表 */
    INNER JOIN T_4_3 s1
        ON src.F010007 = s1.D030002          -- 分户账号
        AND src.F010022 = s1.D030009          -- 币种
        AND src.F010023 = s1.D030016          -- 钞汇类别
        AND s1.D030005 = '01'                 -- 分户账类型 = '01'
    /* 左关联：机构信息表 */
    LEFT JOIN T_1_1 s3
        ON src.F010002 = s3.A010001          -- 内部机构号
    /* 左关联：科目信息 */
    LEFT JOIN T_4_2 s4
        ON src.F010005 = s4.D020001          -- 科目ID
    /* 左关联：存款状态(T_8_14) — 整张表，取存款余额、上次动户日期 */
    LEFT JOIN T_8_14 s2
        ON src.F010001 = s2.H140018          -- 协议ID
        AND src.F010007 = s2.H140001          -- 分户账号
        AND src.F010022 = s2.H140004          -- 币种
        AND src.F010023 = s2.H140017          -- 钞汇类别
    WHERE 1 = 1
      /* 筛选条件：账户状态不为销户，或为销户但销户日期在当月 */
      AND (s1.D030013 <> '03'
           OR (s1.D030013 = '03' AND s1.D030012 >= V_LAST_MONTH_FIRST))
      /* 采集日期过滤：仅取当月数据 */
      AND src.F010035 = V_DATA_DATE;

    COMMIT;
END;
