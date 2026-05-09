/*
草案质量状态：已重构校准，待 GBase 环境执行验证。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
重构校准记录：2026-05-09 依据《047_资产转让关系表.md》逐项校准并重写。
  - 消除全部 NULL AS 占位（XDJJH、JRXKZH、SENSITIVEFLAG、GSFZJG、CJRQ）。
  - 消除 ON 1=1 和 WHERE 1=1 占位，补齐全部 JOIN 条件。
  - 补齐窗口去重逻辑（按借据ID+资产转让方向分组，采集日期降序取第一条）。
  - 补齐内关联 IE_007_703 信贷资产转让表（转让合同号+资产转让方向匹配）。
  - 补齐 XDZCLX 码值 CASE 转换。
  - SENSITIVEFLAG、GSFZJG 为缺口字段（DDL 存在但业务需求未给来源），置 NULL。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_007_704_ZCZRGXB;

CREATE PROCEDURE PROC_EAST_IE_007_704_ZCZRGXB(
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

    DELETE FROM IE_007_704
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_007_704 (
        ZRHTH,
        XDJJH,
        NBJGH,
        JRXKZH,
        ZRDKLX,
        SENSITIVEFLAG,
        BBZ,
        ZRDKBJ,
        XDZCLX,
        GSFZJG,
        CJRQ
    )
    SELECT
        /* 转让合同号：信贷资产转让.协议ID -> T_7_9.G090001；直接映射 */
        dedup.G090001 AS ZRHTH,

        /* 信贷借据号：信贷资产转让.借据ID -> T_7_9.G090003（细分资产ID=借据ID）；直接映射 */
        dedup.G090003 AS XDJJH,

        /* 内部机构号：信贷资产转让.机构ID -> T_7_9.G090002；
           加工映射：将【一表通】【信贷资产转让】的【机构id】从第12位开始截取 */
        SUBSTR(TRIM(dedup.G090002), 12) AS NBJGH,

        /* 金融许可证号：左关联【一表通】【机构信息】(T_1_1)，
           按机构ID从第12位开始截取关联，取【金融许可证号JRXKZH】 */
        s1.A010003 AS JRXKZH,

        /* 转让贷款利息：信贷资产转让.转让贷款利息总额 -> T_7_9.G090008；直接映射 */
        CAST(NULLIF(TRIM(dedup.G090008), '') AS DECIMAL(20,2)) AS ZRDKLX,

        /* 涉密标志：DDL存在但业务需求映射表未给来源，置NULL */
        NULL AS SENSITIVEFLAG,

        /* 备注：信贷资产转让.备注 -> T_7_9.G090019；直接映射 */
        dedup.G090019 AS BBZ,

        /* 转让贷款本金：信贷资产转让.转让贷款本金总额 -> T_7_9.G090007；直接映射 */
        CAST(NULLIF(TRIM(dedup.G090007), '') AS DECIMAL(20,2)) AS ZRDKBJ,

        /* 信贷资产类型：信贷资产转让.资产类型 -> T_7_9.G090009；
           加工映射：01为个人贷款，02为对公贷款，03为信用卡贷款，其他码值转为其他 */
        CASE TRIM(dedup.G090009)
            WHEN '01' THEN '个人贷款'
            WHEN '02' THEN '对公贷款'
            WHEN '03' THEN '信用卡贷款'
            ELSE '其他'
        END AS XDZCLX,

        /* 归属分支机构：DDL存在但业务需求映射表未给来源，置NULL */
        NULL AS GSFZJG,

        /* 采集日期：跑批日期格式改为YYYYMMDD */
        P_DATA_DATE AS CJRQ

    FROM (
        /* 表级规则：取按照【借据ID】、【资产转让方向】分组，采集日期降序排列后的第一条数据 */
        SELECT t.*
        FROM (
            SELECT src.*,
                   ROW_NUMBER() OVER (
                       PARTITION BY src.G090003, src.G090005
                       ORDER BY src.G090018 DESC
                   ) AS rn
            FROM T_7_9 src
            WHERE src.G090018 <= V_DATA_DATE
              /* 过滤条件：【信贷资产转让】.采集日期<=跑批日期 */
        ) t
        WHERE t.rn = 1
    ) dedup

    /* 左关联：【一表通】【机构信息】(T_1_1) */
    LEFT JOIN T_1_1 s1
        ON SUBSTR(TRIM(dedup.G090002), 12) = SUBSTR(TRIM(s1.A010001), 12)
       AND s1.A010020 = V_DATA_DATE
       /* 关联条件：【信贷资产转让】.【机构ID】从第12位开始截取=【机构信息】.【机构ID】从第12位开始截取
          且【机构信息】.采集日期为跑批日期 */

    /* 内关联：【一表通转EAST】【信贷资产转让表】(IE_007_703) */
    INNER JOIN IE_007_703 east703
        ON east703.CJRQ = P_DATA_DATE
       AND east703.ZRHTH = dedup.G090001
       AND east703.ZCZRFX = CASE TRIM(dedup.G090005)
                                WHEN '01' THEN '转入'
                                WHEN '02' THEN '转出'
                                ELSE ''
                            END;
       /* 关联条件：【信贷资产转让表】.采集日期为跑批日期
          且【信贷资产转让表】.【转让合同号】=【信贷资产转让】.【协议ID】
          且【信贷资产转让表】.【资产转让方向】=【信贷资产转让】.【资产转让方向】
             为01时记为'转入'，为02时记为'转出'，其他为'' */

    COMMIT;
END;
