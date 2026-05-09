/*
草案质量状态：待验证。
说明：本文件已按原始业务需求《041_表内外业务担保合同表.md》完成码值 CASE 转换、JOIN 条件、
     WHERE 过滤条件和日期格式转换的重构。尚未在 GBase 环境执行验证，状态保持 draft。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
重构记录：2026-05-09 — 依据数据字典原文重构码值 CASE、补齐 JOIN/WHERE 条件、完善日期 NULL 处理。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_006_601_BNWYWDBHTB;

CREATE PROCEDURE PROC_EAST_IE_006_601_BNWYWDBHTB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_PREV_MONTH_END DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);
    /* 上一采集月末：用于剔除上月失效数据 */
    SET V_PREV_MONTH_END = LAST_DAY(V_DATA_DATE - INTERVAL 1 MONTH);

    START TRANSACTION;

    DELETE FROM IE_006_601
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_006_601 (
        DBHTH,
        GSFZJG,
        NBJGH,
        DBLX,
        DBJE,
        DBDQRQ,
        DBHTZT,
        CJRQ,
        DBBZ,
        DBQSRQ,
        JBRGH,
        BBZ,
        BDBYWLX,
        JRXKZH,
        DBHTLX,
        SENSITIVEFLAG,
        BDBHTH
    )
    SELECT
        /* 担保合同号：T_6_8.F080001（协议ID）-> DBHTH；直接映射 */
        src.F080001 AS DBHTH,
        /* 归属分支机构：本地 DDL 存在该字段，但业务需求映射表和 SQL 草案均未能确认来源，置空 */
        NULL AS GSFZJG,
        /* 内部机构号：T_6_8.F080002（机构ID）-> NBJGH；加工映射：截取第12位起 */
        SUBSTR(src.F080002, 12) AS NBJGH,
        /* 担保类型：T_6_8.F080004（担保类型）-> DBLX；码值转换
         * 需求文档映射：
         *   '01' -> '抵押'
         *   '02' -> '质押'
         *   '03'/'04'/'05'/'06' -> '保证'
         *   '07' -> '混合'
         *   '00-XX' -> '其他-XX'（XX为银行自定义）
         *   '00'   -> '其他'（兜底码值，不能落入 ELSE）
         *   ELSE   -> ''（未列出的未知码值）
         * 参考：references/EAST5.0-SQL开发-码值CASE陷阱.md
         */
        CASE
            WHEN TRIM(src.F080004) = '01' THEN '抵押'
            WHEN TRIM(src.F080004) = '02' THEN '质押'
            WHEN TRIM(src.F080004) IN ('03', '04', '05', '06') THEN '保证'
            WHEN TRIM(src.F080004) = '07' THEN '混合'
            WHEN TRIM(src.F080004) = '00' THEN '其他'
            /* '00-XX' 通配分支：LEFT(TRIM(...), 3) = '00-' 匹配 '00-信托'、'00-01' 等 */
            WHEN LEFT(TRIM(src.F080004), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(src.F080004), 4))
            ELSE ''
        END AS DBLX,
        /* 担保金额：T_6_8.F080015（协议金额）-> DBJE；类型转换 DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F080015), '') AS DECIMAL(20,2)) AS DBJE,
        /* 担保到期日期：T_6_8.F080014（到期日期，DATE）-> DBDQRQ；格式转换 YYYYMMDD，NULL 默认 99991231 */
        COALESCE(
            CONCAT(
                CAST(YEAR(src.F080014) AS VARCHAR(4)),
                LPAD(CAST(MONTH(src.F080014) AS VARCHAR(2)), 2, '0'),
                LPAD(CAST(DAY(src.F080014) AS VARCHAR(2)), 2, '0')
            ),
            '99991231'
        ) AS DBDQRQ,
        /* 担保合同状态：T_6_8.F080019（协议状态）-> DBHTZT；码值转换
         * '01' -> '有效'
         * 其他 -> '失效'
         */
        CASE TRIM(src.F080019)
            WHEN '01' THEN '有效'
            ELSE '失效'
        END AS DBHTZT,
        /* 采集日期：T_6_8.F080025（采集日期，DATE）-> CJRQ；格式转换 YYYYMMDD */
        CONCAT(
            CAST(YEAR(src.F080025) AS VARCHAR(4)),
            LPAD(CAST(MONTH(src.F080025) AS VARCHAR(2)), 2, '0'),
            LPAD(CAST(DAY(src.F080025) AS VARCHAR(2)), 2, '0')
        ) AS CJRQ,
        /* 担保币种：T_6_8.F080016（协议币种）-> DBBZ；直接映射 */
        src.F080016 AS DBBZ,
        /* 担保起始日期：T_6_8.F080013（生效日期，DATE）-> DBQSRQ；格式转换 YYYYMMDD，NULL 默认 99991231 */
        COALESCE(
            CONCAT(
                CAST(YEAR(src.F080013) AS VARCHAR(4)),
                LPAD(CAST(MONTH(src.F080013) AS VARCHAR(2)), 2, '0'),
                LPAD(CAST(DAY(src.F080013) AS VARCHAR(2)), 2, '0')
            ),
            '99991231'
        ) AS DBQSRQ,
        /* 经办人工号：T_6_8.F080020（经办员工ID）-> JBRGH；直接映射 */
        src.F080020 AS JBRGH,
        /* 备注：T_6_8.F080024（备注）-> BBZ；直接映射 */
        src.F080024 AS BBZ,
        /* 被担保业务类型：T_6_8.F080006（被担保业务类型）-> BDBYWLX；码值转换
         * 需求文档映射：
         *   '01' -> '表内信贷'
         *   '02' -> '承兑汇票'
         *   '03' -> '保函'
         *   '04' -> '信用证'
         *   '05' -> '贷款承诺'
         *   '06' -> '委托贷款'
         *   '07' -> '自营投资'
         *   '00-XX' -> '其他-XX'（XX为银行自定义）
         *   '00'   -> '其他'（兜底码值，不能落入 ELSE）
         *   ELSE   -> ''（未列出的未知码值）
         * 参考：references/EAST5.0-SQL开发-码值CASE陷阱.md
         * 注意：数据字典码表 EAST_BDGYWLX 中未列出 '00' 码值，但需求文档写明 '00-XX' 通配分支，
         *       按 EAST5.0 码值惯例，'00' 应映射为 '其他'。
         */
        CASE
            WHEN TRIM(src.F080006) = '01' THEN '表内信贷'
            WHEN TRIM(src.F080006) = '02' THEN '承兑汇票'
            WHEN TRIM(src.F080006) = '03' THEN '保函'
            WHEN TRIM(src.F080006) = '04' THEN '信用证'
            WHEN TRIM(src.F080006) = '05' THEN '贷款承诺'
            WHEN TRIM(src.F080006) = '06' THEN '委托贷款'
            WHEN TRIM(src.F080006) = '07' THEN '自营投资'
            WHEN TRIM(src.F080006) = '00' THEN '其他'
            /* '00-XX' 通配分支：LEFT(TRIM(...), 3) = '00-' 匹配 '00-信托'、'00-01' 等 */
            WHEN LEFT(TRIM(src.F080006), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(src.F080006), 4))
            ELSE ''
        END AS BDBYWLX,
        /* 金融许可证号：T_1_1.A010003（金融许可证号）-> JRXKZH；直接映射
         * 关联条件：T_6_8.F080002（机构ID）= T_1_1.A010001（机构ID）
         */
        s1.A010003 AS JRXKZH,
        /* 担保合同类型：T_6_8.F080007（担保合同类型）-> DBHTLX；码值转换
         * '01' -> '一般担保合同'
         * '02' -> '最高额担保合同'
         */
        CASE TRIM(src.F080007)
            WHEN '01' THEN '一般担保合同'
            WHEN '02' THEN '最高额担保合同'
            ELSE ''
        END AS DBHTLX,
        /* 涉密标志：本地 DDL 存在该字段，但业务需求映射表和 SQL 草案均未能确认来源，置空 */
        NULL AS SENSITIVEFLAG,
        /* 被担保合同号：T_6_8.F080003（被担保协议ID）-> BDBHTH；直接映射 */
        src.F080003 AS BDBHTH
    FROM T_6_8 src
    LEFT JOIN T_1_1 s1
           ON src.F080002 = s1.A010001
    WHERE 1 = 1
      /* 采集日期过滤：仅取当月数据（截面数据） */
      AND src.F080025 >= DATE_FORMAT(V_DATA_DATE, '%Y-%m-01')
      AND src.F080025 < LAST_DAY(V_DATA_DATE) + INTERVAL 1 DAY
      /* 排除上月失效数据：剔除上一采集月末前已失效的记录 */
      AND (src.F080025 > V_PREV_MONTH_END
           OR (src.F080019 = '01' AND src.F080014 >= V_DATA_DATE))
      /* 担保协议ID不为空 */
      AND src.F080001 IS NOT NULL
      AND TRIM(src.F080001) <> ''
      /* 取不为保证金的数据：担保类型不为保证金（具体保证金码值待与业务确认） */
      AND TRIM(src.F080004) NOT IN ('保证金')
    ;

    COMMIT;
END;
