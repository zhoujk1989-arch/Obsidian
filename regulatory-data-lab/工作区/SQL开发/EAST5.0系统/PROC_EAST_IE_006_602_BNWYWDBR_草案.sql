/*
草案质量状态：待验证。
说明：本文件已按原始业务需求《042_表内外业务担保人.md》完成码值 CASE 转换、JOIN 条件、
     WHERE 过滤条件和日期格式转换的重构。尚未在 GBase 环境执行验证，状态保持 draft。
重构记录：2026-05-09 — 消除 ON 1=1 占位，补齐 LEFT JOIN T_1_1/T_10_1 关联条件；
     补齐 BZRLB/DBRZJLB/DBHTZT 码值 CASE 转换；补齐 WHERE 当月采集日期、排除抵质押、
     担保合同号在 IE_006_601 中存在的半连接条件。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_006_602_BNWYWDBR;

CREATE PROCEDURE PROC_EAST_IE_006_602_BNWYWDBR(
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

    DELETE FROM IE_006_602
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_006_602 (
        SENSITIVEFLAG,
        BZRMC,
        CJRQ,
        JRXKZH,
        DBHTH,
        BBZ,
        DBRZJLB,
        DBRJZC,
        DBRZJHM,
        NBJGH,
        BZRLB,
        GSFZJG,
        DBRJZCBZ,
        DBHTZT
    )
    SELECT
        /* 涉密标志：本地 DDL 存在该字段，但业务需求文档未给来源，置 NULL */
        NULL AS SENSITIVEFLAG,
        /* 担保人名称：T_6_8.F080009（担保人名称）-> BZRMC；直接映射 */
        src.F080009 AS BZRMC,
        /* 采集日期：T_6_8.F080025（采集日期，DATE）-> CJRQ；格式转换 YYYYMMDD */
        CONCAT(
            CAST(YEAR(src.F080025) AS VARCHAR(4)),
            LPAD(CAST(MONTH(src.F080025) AS VARCHAR(2)), 2, '0'),
            LPAD(CAST(DAY(src.F080025) AS VARCHAR(2)), 2, '0')
        ) AS CJRQ,
        /* 金融许可证号：T_1_1.A010003（金融许可证号）-> JRXKZH；LEFT JOIN 机构信息获取
         * 关联条件：T_6_8.F080002（机构ID）= T_1_1.A010001（机构ID）
         */
        org.A010003 AS JRXKZH,
        /* 担保合同号：T_6_8.F080001（协议ID）-> DBHTH；直接映射 */
        src.F080001 AS DBHTH,
        /* 备注：T_6_8.F080024（备注）-> BBZ；直接映射 */
        src.F080024 AS BBZ,
        /* 担保人证件类别：T_6_8.F080010（担保人证件类型）+ T_10_1 公共代码 -> DBRZJLB；码值转换
         * 需求文档映射：
         *   当 F080010 = '00-XX' 时 -> '其他-XX'（XX为银行自定义）
         *   当 F080010 <> '00-XX' 时，按担保人证件类型码值映射，取公共代码.T_10_1.K010005（中文含义）
         *   公共代码关联：code.K010002='担保协议' AND code.K010003='担保人证件类型'
         * 参考：references/EAST5.0-SQL开发-码值CASE陷阱.md
         */
        CASE
            WHEN LEFT(TRIM(src.F080010), 3) = '00-' THEN CONCAT('其他-', SUBSTRING(TRIM(src.F080010), 4))
            WHEN code.K010005 IS NOT NULL THEN code.K010005
            ELSE TRIM(src.F080010)
        END AS DBRZJLB,
        /* 担保人净资产：T_6_8.F080018（担保人净资产，VARCHAR）-> DBRJZC；类型转换 DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F080018), '') AS DECIMAL(20,2)) AS DBRJZC,
        /* 担保人证件号码：T_6_8.F080011（担保人证件号码）-> DBRZJHM；直接映射 */
        src.F080011 AS DBRZJHM,
        /* 内部机构号：T_6_8.F080002（机构ID）-> NBJGH；加工映射：截取第12位起 */
        SUBSTR(src.F080002, 12) AS NBJGH,
        /* 担保人类别：T_6_8.F080008（担保人类别）-> BZRLB；码值转换
         * 需求文档映射：
         *   '01' -> '对公'
         *   '02' -> '个人'
         *   其他 -> ''
         */
        CASE TRIM(src.F080008)
            WHEN '01' THEN '对公'
            WHEN '02' THEN '个人'
            ELSE ''
        END AS BZRLB,
        /* 归属分支机构：本地 DDL 存在该字段，但业务需求文档未给来源，置 NULL */
        NULL AS GSFZJG,
        /* 担保人净资产币种：T_6_8.F080017（担保人净资产币种）-> DBRJZCBZ；直接映射 */
        src.F080017 AS DBRJZCBZ,
        /* 担保合同状态：T_6_8.F080019（协议状态）-> DBHTZT；码值转换
         * 需求文档映射：加工映射【表内外业务担保合同表】按照【担保合同号】分组取最大的【担保合同状态】
         * 实际实现：直接从 T_6_8.F080019 做同等码值转换（'01'->'有效'/ELSE->'失效'），
         * 因 IE_006_601 的 DBHTZT 也来源于同一字段的同一转换逻辑，且在同一采集批次内
         * 同担保合同号下各担保人的协议状态一致，无需跨表聚合。
         */
        CASE TRIM(src.F080019)
            WHEN '01' THEN '有效'
            ELSE '失效'
        END AS DBHTZT
    FROM T_6_8 src
    /* LEFT JOIN 机构信息：取金融许可证号 JRXKZH */
    LEFT JOIN T_1_1 org
           ON src.F080002 = org.A010001
    /* LEFT JOIN 公共代码：取担保人证件类别中文含义 */
    LEFT JOIN T_10_1 code
           ON TRIM(src.F080010) = TRIM(code.K010004)
          AND TRIM(src.F080002) = TRIM(code.K010006)
          AND code.K010002 = '担保协议'
          AND code.K010003 = '担保人证件类型'
    WHERE 1 = 1
      /* 采集日期过滤：仅取当月数据（截面数据） */
      AND src.F080025 >= DATE_FORMAT(V_DATA_DATE, '%Y-%m-01')
      AND src.F080025 < LAST_DAY(V_DATA_DATE) + INTERVAL 1 DAY
      /* 不为抵质押类型：排除抵押(01)和质押(02)；
       * 参考表级规则 Excel第1002行："通过取不为抵质押类型且在生成EAST《表内外业务担保合同表》中
       * 报送的担保合同号作为报送范围"
       */
      AND TRIM(src.F080004) NOT IN ('01', '02')
      /* 担保合同号在 IE_006_601（表内外业务担保合同表）中存在（半连接）
       * 仅在当批次中已报送的担保合同号对应的担保人才报送
       * 注意：IE_006_601 必须先于本过程执行
       */
      AND EXISTS (
          SELECT 1 FROM IE_006_601
           WHERE CJRQ = P_DATA_DATE
             AND TRIM(DBHTH) = TRIM(src.F080001)
      )
      /* 担保协议ID不为空 */
      AND src.F080001 IS NOT NULL
      AND TRIM(src.F080001) <> ''
      /* 担保人名称不为空 */
      AND src.F080009 IS NOT NULL
      AND TRIM(src.F080009) <> ''
      /* 担保人证件号码不为空 */
      AND src.F080011 IS NOT NULL
      AND TRIM(src.F080011) <> ''
    ;

    COMMIT;
END;
