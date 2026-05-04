/*
业务目标：
- 依据原始业务需求《017_内部科目对照表.md》生成 EAST5.0 内部科目对照表（IE_004_402）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/017_内部科目对照表.md
- 原始材料/表结构/一表通系统/T_4_2-科目信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_402-内部科目对照表-DDL-2026-04-28.sql

源表：
- T_4_2：科目信息，主表。
- T_1_1：机构信息，用于金融许可证号、银行机构名称。
- T_4_2 parent：科目信息自关联，用于取上级科目名称。

目标表：
- IE_004_402：内部科目对照表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 全量截面重跑；先删除目标表同一采集日期数据，再插入采集日期等于跑批日的科目信息。

关键口径：
- 取 `T_4_2.D020011` 采集日期等于 `P_DATA_DATE` 的记录。
- 机构关联按 `T_4_2.D020002 = T_1_1.A010001`。
- 上级科目编号：一级科目填 `0`，非一级取 `T_4_2.D020008`。
- 上级科目名称：非一级科目按同机构、同采集日期、上级科目ID关联科目信息取科目名称。

未确认点：
- 业务需求写“当月末的数据”，当前按采集日期等于跑批日实现；如跑批日不是月末，应由调度保证传入月末日期。
- 归属业务子类规则写“关联公共参数取对应转换值”，但当前业务需求和 DDL 未给出公共参数表名/字段条件；本草案暂取 `T_4_2.D020007` 原值，待补公共参数来源后再替换。
- 目标 DDL 字段 GSFZJG、SENSITIVEFLAG 在本业务需求未给出来源，保留 NULL，待补充来源后再加工。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_402_NBKMDZB;

CREATE PROCEDURE PROC_EAST_IE_004_402_NBKMDZB(
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

    DELETE FROM IE_004_402
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_402 (
        NBJGH,
        BBZ,
        KJKMJC,
        SJKMMC,
        GSYWDL,
        GSYWZL,
        CJRQ,
        SENSITIVEFLAG,
        GSFZJG,
        JRXKZH,
        YHJGMC,
        KJKMMC,
        SJKMBH,
        KMJDBZ,
        KJKMBH
    )
    SELECT
        /* 内部机构号：机构ID 从第12位开始截取 */
        SUBSTR(TRIM(src.D020002), 12) AS NBJGH,
        /* 备注 */
        src.D020010 AS BBZ,
        /* 会计科目级次：01-1 ... 20-20 */
        CASE
            WHEN src.D020004 BETWEEN '01' AND '20' THEN CAST(src.D020004 AS INTEGER)
            ELSE NULL
        END AS KJKMJC,
        /* 上级科目名称：一级科目为空，非一级取上级科目名称 */
        CASE
            WHEN src.D020004 = '01' THEN NULL
            ELSE parent.D020003
        END AS SJKMMC,
        /* 归属业务大类 */
        CASE
            WHEN src.D020005 = '01' THEN '资产'
            WHEN src.D020005 = '02' THEN '负债'
            WHEN src.D020005 = '03' THEN '所有者权益'
            WHEN src.D020005 = '04' THEN '损益'
            WHEN src.D020005 = '05' THEN '资产负债共同类'
            WHEN src.D020005 = '06' THEN '表外'
            WHEN src.D020005 = '00' THEN '其他'
            ELSE src.D020005
        END AS GSYWDL,
        /* 归属业务子类：公共参数来源待补，暂取科目信息原值 */
        src.D020007 AS GSYWZL,
        /* 采集日期：跑批参数 */
        P_DATA_DATE AS CJRQ,
        /* 涉密标志：业务需求未提供来源 */
        NULL AS SENSITIVEFLAG,
        /* 归属分支机构：业务需求未提供来源 */
        NULL AS GSFZJG,
        /* 金融许可证号：机构信息.金融许可证号 */
        org.A010003 AS JRXKZH,
        /* 银行机构名称：机构信息.银行机构名称 */
        org.A010005 AS YHJGMC,
        /* 会计科目名称 */
        src.D020003 AS KJKMMC,
        /* 上级科目编号：一级科目填0，其他取上级科目ID */
        CASE
            WHEN src.D020004 = '01' THEN '0'
            ELSE src.D020008
        END AS SJKMBH,
        /* 科目借贷标志 */
        CASE
            WHEN src.D020006 = '01' THEN '借'
            WHEN src.D020006 = '02' THEN '贷'
            WHEN src.D020006 = '03' THEN '借贷并列'
            ELSE src.D020006
        END AS KMJDBZ,
        /* 会计科目编号 */
        src.D020001 AS KJKMBH
    FROM T_4_2 src
    LEFT JOIN T_1_1 org
           ON src.D020002 = org.A010001
          AND org.A010020 = V_DATA_DATE
    LEFT JOIN T_4_2 parent
           ON src.D020002 = parent.D020002
          AND src.D020008 = parent.D020001
          AND parent.D020011 = V_DATA_DATE
    WHERE src.D020011 = V_DATA_DATE;

    COMMIT;
END;
