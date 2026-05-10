/*
草案质量状态：可评审，禁止直接执行。
原因：本文件已按原始业务需求《055_交易背景信息表.md》逐字段重构。JOIN条件、WHERE筛选、码值CASE转换、日期格式转换、金额CAST均已补齐。
仍缺字段：SENSITIVEFLAG（涉密标志）、GSFZJG（归属分支机构）——业务需求映射表未给来源，SQL中置NULL。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0系统-GBase存储过程草案质量问题-2026-05-04.md
2026-05-10 第2轮修复：补齐 T_6_11/T_6_13/T_6_10/T_6_12 四个协议表 LEFT JOIN 的采集日期条件，防止因复合主键含采集日期产生重复行。
*/

/*
业务目标：
- 依据原始业务需求《055_交易背景信息表.md》生成 EAST5.0 交易背景信息表（IE_009_903_INC）GBase 存储过程。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程。

依赖材料：
- 原始材料/业务需求/EAST5.0/055_交易背景信息表.md
- 原始材料/表结构/EAST5.0系统/IE_009_903_INC-交易背景信息表-DDL-2026-04-28.sql

源表：
- T_9_4（商业单据）：主表
- T_3_8（协议与单据对应关系）：内关联子查询
- T_6_2（贷款协议）：LEFT JOIN 用于判断本月生效合同（子查询内）和备注拼接（主查询）
- T_6_11（信用证协议）：LEFT JOIN 取协议币种、开证金额、备注
- T_6_13（票据协议）：LEFT JOIN 取协议币种、票据金额、备注
- T_6_10（贸易融资协议）：LEFT JOIN 取协议币种、贸易融资金额、备注
- T_6_12（保函及其他担保协议）：LEFT JOIN 取协议币种、协议金额、备注
- T_1_1（机构信息）：LEFT JOIN 取金融许可证号、银行机构名称

目标表：
- IE_009_903_INC：交易背景信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

表级取数与关联规则（原文摘录自 055_交易背景信息表.md 2.1 表级规则 Excel第1349行）：
主表：【商业单据】T1 过滤条件：采集日期 = 报告日
内关联子查询：（
  select 【协议与单据对应关系】所有字段
  from 【协议与单据对应关系】 T1
  left join 【贷款协议】 DK
    on T1.协议ID = DK.协议ID and T1.采集日期 = DK.采集日期 and DK.贷款协议起始日期 在本月
  left join 【协议与单据对应关系】LST 上月末 协议ID、单据ID
    on T1.协议ID = LST.协议ID and T1.单据ID = LST.单据ID
  where T1.采集日期 = 报告日 且 （DK.协议ID非空 或 LST.协议ID为空）
）T11
关联条件：T1.单据ID = TT1.单据ID 且 T1.协议ID = TT1.协议ID 且 T1.采集日期 = TT1.采集日期
 且 TT1.业务种类 in （'03','08','09','10','00'）  /*限制为保理融资、承兑汇票、保函、信用证、其他业务*/
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_009_903_INC_JYBJXXB;

CREATE PROCEDURE PROC_EAST_IE_009_903_INC_JYBJXXB(
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
    -- 上月末日期
    SET V_LAST_MONTH_END = LAST_DAY(DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH));

    START TRANSACTION;

    DELETE FROM IE_009_903_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_009_903_INC (
        DJBH,
        DJBZ,
        YWZL,
        NBJGH,
        SENSITIVEFLAG,
        JRXKZH,
        YHJGMC,
        DJJE,
        BBZ,
        CJRQ,
        GSFZJG,
        PJHHTH,
        DJZL,
        BZ,
        HTJE
    )
    SELECT
        /* 单据编号：商业单据.单据ID -> T_9_4.J040001；直接映射 */
        src.J040001 AS DJBH,

        /* 单据币种：商业单据.商业单据币种 -> T_9_4.J040004；直接映射 */
        src.J040004 AS DJBZ,

        /*
          业务种类：协议与单据对应关系.业务种类 -> T11.C080008
          加工映射：CASE WHEN T11.业务种类 = '08' THEN '承兑汇票'
                    WHEN T11.业务种类 = '09' THEN '保函'
                    WHEN T11.业务种类 = '10' THEN '信用证'
                    WHEN T11.业务种类 = '01' THEN '其他-打包贷款'
                    WHEN T11.业务种类 = '02' THEN '其他-押汇'
                    WHEN T11.业务种类 = '03' THEN '其他-保理'
                    WHEN T11.业务种类 = '04' THEN '其他-议付信用证'
                    WHEN T11.业务种类 = '05' THEN '其他-买方信贷'
                    WHEN T11.业务种类 = '06' THEN '其他-卖方信贷'
                    WHEN T11.业务种类 = '07' THEN '其他-福费廷'
                    WHEN LEFT(TRIM(T11.C080008), 2) = '00' THEN CONCAT('其他', SUBSTR(TRIM(T11.C080008), 3))
                    ELSE ''
               END
        */
        CASE
            WHEN T11.C080008 = '08' THEN '承兑汇票'
            WHEN T11.C080008 = '09' THEN '保函'
            WHEN T11.C080008 = '10' THEN '信用证'
            WHEN T11.C080008 = '01' THEN '其他-打包贷款'
            WHEN T11.C080008 = '02' THEN '其他-押汇'
            WHEN T11.C080008 = '03' THEN '其他-保理'
            WHEN T11.C080008 = '04' THEN '其他-议付信用证'
            WHEN T11.C080008 = '05' THEN '其他-买方信贷'
            WHEN T11.C080008 = '06' THEN '其他-卖方信贷'
            WHEN T11.C080008 = '07' THEN '其他-福费廷'
            WHEN LEFT(TRIM(T11.C080008), 2) = '00' THEN CONCAT('其他', SUBSTR(TRIM(T11.C080008), 3))
            ELSE ''
        END AS YWZL,

        /*
          内部机构号：商业单据.机构ID -> T_9_4.J040002
          加工映射：SUBSTR(机构ID, 12)
        */
        SUBSTR(src.J040002, 12) AS NBJGH,

        /* 涉密标志：需求字段未与目标DDL注释精确匹配，无来源信息，置NULL */
        NULL AS SENSITIVEFLAG,

        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        s4.A010003 AS JRXKZH,

        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        s4.A010005 AS YHJGMC,

        /* 单据金额：商业单据.商业单据金额 -> T_9_4.J040005；直接映射 */
        CAST(NULLIF(TRIM(src.J040005), '') AS DECIMAL(20,2)) AS DJJE,

        /*
          备注：多表备注拼接
          来源：T_9_4.J040007（商业单据.备注）
                T11.C080006（协议与单据对应关系.备注）
                DK2.F020062（贷款协议.备注）
                s1.F110036（信用证协议.备注）
                s2.F130048（票据协议.备注）
                s3.F100025（贸易融资协议.备注）
                s5.F120027（保函及其他担保协议.备注）
          加工映射：CONCAT_WS(';', ...) 分号拼接，去除NULL和空串
        */
        TRIM(TRAILING ';' FROM CONCAT_WS(';',
            NULLIF(TRIM(src.J040007), ''),
            NULLIF(TRIM(T11.C080006), ''),
            NULLIF(TRIM(DK2.F020062), ''),
            NULLIF(TRIM(s1.F110036), ''),
            NULLIF(TRIM(s2.F130048), ''),
            NULLIF(TRIM(s3.F100025), ''),
            NULLIF(TRIM(s5.F120027), '')
        )) AS BBZ,

        /* 采集日期：商业单据.采集日期 -> T_9_4.J040008；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(src.J040008) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.J040008) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.J040008) AS VARCHAR(2)), 2, '0')) AS CJRQ,

        /* 归属分支机构：需求字段未与目标DDL注释精确匹配，无来源信息，置NULL */
        NULL AS GSFZJG,

        /* 业务编号：协议与单据对应关系.协议ID -> T11.C080002；直接映射 */
        T11.C080002 AS PJHHTH,

        /*
          单据种类：商业单据.商业单据种类 -> T_9_4.J040006
          加工映射：CASE WHEN T1.商业单据种类 = '01' THEN '商业发票'
                    WHEN T1.商业单据种类 = '02' THEN '增值税发票'
                    WHEN T1.商业单据种类 = '03' THEN '证实发票'
                    WHEN T1.商业单据种类 = '04' THEN '收妥发票'
                    WHEN T1.商业单据种类 = '05' THEN '厂商发票'
                    WHEN T1.商业单据种类 = '06' THEN '形式发票'
                    WHEN T1.商业单据种类 = '07' THEN '样品发票'
                    WHEN T1.商业单据种类 = '08' THEN '领事发票'
                    WHEN T1.商业单据种类 = '09' THEN '寄售发票'
                    WHEN T1.商业单据种类 = '10' THEN '海关发票'
                    WHEN T1.商业单据种类 = '11' THEN '提单'
                    WHEN T1.商业单据种类 = '12' THEN '报关单'
                    WHEN T1.商业单据种类 = '13' THEN '货物清单'
                    WHEN LEFT(TRIM(src.J040006), 2) = '00' THEN REPLACE(TRIM(src.J040006), '00', '')
                    ELSE ''
               END
        */
        CASE
            WHEN src.J040006 = '01' THEN '商业发票'
            WHEN src.J040006 = '02' THEN '增值税发票'
            WHEN src.J040006 = '03' THEN '证实发票'
            WHEN src.J040006 = '04' THEN '收妥发票'
            WHEN src.J040006 = '05' THEN '厂商发票'
            WHEN src.J040006 = '06' THEN '形式发票'
            WHEN src.J040006 = '07' THEN '样品发票'
            WHEN src.J040006 = '08' THEN '领事发票'
            WHEN src.J040006 = '09' THEN '寄售发票'
            WHEN src.J040006 = '10' THEN '海关发票'
            WHEN src.J040006 = '11' THEN '提单'
            WHEN src.J040006 = '12' THEN '报关单'
            WHEN src.J040006 = '13' THEN '货物清单'
            WHEN LEFT(TRIM(src.J040006), 2) = '00' THEN REPLACE(TRIM(src.J040006), '00', '')
            ELSE ''
        END AS DJZL,

        /*
          币种：通过协议ID关联【信用证协议/保函协议/票据协议/贸易融资协议】，获取其协议币种
          COALESCE 优先级：信用证协议.F110008 > 票据协议.F130019 > 贸易融资协议.F100004 > 保函协议.F120010
        */
        COALESCE(s1.F110008, s2.F130019, s3.F100004, s5.F120010) AS BZ,

        /*
          合同金额：通过协议ID关联【信用证协议/保函协议/票据协议/贸易融资协议】，获取其各协议金额
          COALESCE 优先级：信用证协议.F110009 > 票据协议.F130020 > 贸易融资协议.F100006 > 保函协议.F120009
        */
        CAST(NULLIF(TRIM(COALESCE(s1.F110009, s2.F130020, s3.F100006, s5.F120009)), '') AS DECIMAL(20,2)) AS HTJE

    FROM T_9_4 src

    /*
      表级规则（Excel第1349行）：
      内关联子查询 T11：从协议与单据对应关系（T_3_8）中，
      左连接贷款协议（T_6_2）判断本月生效合同，
      左连接上月协议与单据对应关系（T_3_8 自连接）判断上月未报送过，
      条件：本月生效合同（DK.协议ID非空）或 上月未报送过（LST.协议ID为空）
    */
    INNER JOIN (
        SELECT
            T_3_8.*
        FROM T_3_8
        LEFT JOIN T_6_2 DK
            ON T_3_8.C080002 = DK.F020001           -- 协议ID
           AND T_3_8.C080007 = DK.F020063            -- 采集日期
           AND DK.F020048 >= DATE_ADD(V_DATA_DATE, INTERVAL 1 - DAY(V_DATA_DATE) DAY)   -- 本月第一天
           AND DK.F020048 <= LAST_DAY(V_DATA_DATE)    -- 本月最后一天（贷款协议起始日期在本月）
        LEFT JOIN T_3_8 LST
            ON T_3_8.C080002 = LST.C080002            -- 协议ID
           AND T_3_8.C080003 = LST.C080003            -- 单据ID
           AND LST.C080007 = V_LAST_MONTH_END          -- 上月末采集日期
        WHERE T_3_8.C080007 = V_DATA_DATE             -- 采集日期 = 报告日
          AND (DK.F020001 IS NOT NULL OR LST.C080002 IS NULL)  -- 本月生效合同 或 上月未报送过
    ) T11
        ON src.J040001 = T11.C080003                  -- 商业单据.单据ID = 协议与单据对应关系.单据ID
       AND src.J040009 = T11.C080002                  -- 商业单据.协议ID = 协议与单据对应关系.协议ID
       AND src.J040008 = T11.C080007                  -- 商业单据.采集日期 = 协议与单据对应关系.采集日期

    /*
      贷款协议 LEFT JOIN：用于获取备注（BBZ字段多源拼接需要）
      与子查询中 DK 的关联条件保持一致
    */
    LEFT JOIN T_6_2 DK2
        ON T11.C080002 = DK2.F020001                  -- 协议ID
       AND T11.C080007 = DK2.F020063                  -- 采集日期

    /* 信用证协议 LEFT JOIN：用于获取协议币种、开证金额、备注
       注意：T_6_11 主键含 F110038（采集日期），必须加采集日期条件防止重复行 */
    LEFT JOIN T_6_11 s1
        ON T11.C080002 = s1.F110001                   -- 协议ID
       AND T11.C080007 = s1.F110038                   -- 采集日期

    /* 票据协议 LEFT JOIN：用于获取协议币种、票据金额、备注
       注意：T_6_13 主键含 F130049（采集日期），必须加采集日期条件防止重复行 */
    LEFT JOIN T_6_13 s2
        ON T11.C080002 = s2.F130001                   -- 协议ID
       AND T11.C080007 = s2.F130049                   -- 采集日期

    /* 贸易融资协议 LEFT JOIN：用于获取协议币种、贸易融资金额、备注
       注意：T_6_10 主键含 F100026（采集日期），必须加采集日期条件防止重复行 */
    LEFT JOIN T_6_10 s3
        ON T11.C080002 = s3.F100002                   -- 协议ID
       AND T11.C080007 = s3.F100026                   -- 采集日期

    /* 机构信息 LEFT JOIN：用于获取金融许可证号、银行机构名称 */
    LEFT JOIN T_1_1 s4
        ON src.J040002 = s4.A010001                   -- 商业单据.机构ID = 机构信息.机构ID
       AND s4.A010020 = V_DATA_DATE                   -- 机构信息采集日期过滤，防止主键重复

    /* 保函及其他担保协议 LEFT JOIN：用于获取协议币种、协议金额、备注
       注意：T_6_12 主键含 F120028（采集日期），必须加采集日期条件防止重复行 */
    LEFT JOIN T_6_12 s5
        ON T11.C080002 = s5.F120001                   -- 协议ID
       AND T11.C080007 = s5.F120028                   -- 采集日期

    WHERE src.J040008 = V_DATA_DATE                   -- 商业单据采集日期 = 报告日
      AND T11.C080008 IN ('03', '08', '09', '10', '00')  -- 限制业务种类：保理融资、承兑汇票、保函、信用证、其他业务
      AND s4.A010001 IS NOT NULL;                     -- 确保机构信息关联存在（JRXKZH/YHJGMC 必填）

    COMMIT;
END;
