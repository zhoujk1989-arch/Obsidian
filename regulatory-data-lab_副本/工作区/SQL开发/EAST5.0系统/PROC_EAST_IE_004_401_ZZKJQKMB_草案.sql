/*
业务目标：
- 依据原始业务需求《016_总账会计全科目表.md》生成 EAST5.0 总账会计全科目表（IE_004_401）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/016_总账会计全科目表.md
- 原始材料/表结构/一表通系统/T_4_1-总账会计全科目-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_4_2-科目信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_401-总账会计全科目表-DDL-2026-04-28.sql

源表：
- T_4_1：总账会计全科目，主表。
- T_1_1：机构信息，用于金融许可证号、银行机构名称。
- T_4_2：科目信息，用于会计科目名称。

目标表：
- IE_004_401：总账会计全科目表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 全量截面重跑；先删除目标表同一采集日期数据，再插入币种为 CNY/BWB 且采集日期等于跑批日的总账会计科目。

关键口径：
- 只取 `T_4_1.D010009` 币种为 `CNY`、`BWB` 的记录。
- 只取 `T_4_1.D010012` 采集日期等于 `P_DATA_DATE` 的记录。
- 机构关联按 `T_4_1.D010001 = T_1_1.A010001`。
- 科目名称按 `T_4_1.D010001/D010002 = T_4_2.D020002/D020001` 且 `T_4_2.D020011 = P_DATA_DATE` 关联。

未确认点：
- 业务需求写“统计当月的数据”，当前按采集日期等于跑批日实现；如现场按月内多日数据合并，应调整过滤。
- 目标 DDL 字段 GSFZJG、SENSITIVEFLAG 在本业务需求未给出来源，保留 NULL，待补充来源后再加工。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_401_ZZKJQKMB;

CREATE PROCEDURE PROC_EAST_IE_004_401_ZZKJQKMB(
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

    DELETE FROM IE_004_401
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_401 (
        JRXKZH,
        NBJGH,
        YHJGMC,
        KJKMBH,
        KJKMMC,
        BZ,
        QCJFYE,
        QCDFYE,
        JFFSE,
        DFFSE,
        QMJFYE,
        QMDFYE,
        BSZQ,
        KJRQ,
        BBZ,
        CJRQ,
        GSFZJG,
        SENSITIVEFLAG
    )
    SELECT
        /* 1 金融许可证号：机构信息.金融许可证号 */
        org.A010003 AS JRXKZH,
        /* 2 内部机构号：机构ID 从第12位开始截取 */
        SUBSTR(TRIM(src.D010001), 12) AS NBJGH,
        /* 3 银行机构名称：机构信息.银行机构名称 */
        org.A010005 AS YHJGMC,
        /* 4 会计科目编号 */
        src.D010002 AS KJKMBH,
        /* 5 会计科目名称：科目信息.科目名称 */
        subj.D020003 AS KJKMMC,
        /* 6 币种：只保留 CNY/BWB */
        src.D010009 AS BZ,
        /* 7 期初借方余额 */
        CAST(NULLIF(TRIM(src.D010003), '') AS DECIMAL(20,2)) AS QCJFYE,
        /* 8 期初贷方余额 */
        CAST(NULLIF(TRIM(src.D010004), '') AS DECIMAL(20,2)) AS QCDFYE,
        /* 9 本期借方发生额 */
        CAST(NULLIF(TRIM(src.D010005), '') AS DECIMAL(20,2)) AS JFFSE,
        /* 10 本期贷方发生额 */
        CAST(NULLIF(TRIM(src.D010006), '') AS DECIMAL(20,2)) AS DFFSE,
        /* 11 期末借方余额 */
        CAST(NULLIF(TRIM(src.D010007), '') AS DECIMAL(20,2)) AS QMJFYE,
        /* 12 期末贷方余额 */
        CAST(NULLIF(TRIM(src.D010008), '') AS DECIMAL(20,2)) AS QMDFYE,
        /* 13 报送周期：01 日报、02 月报、03 季报、04 半年报、05 年报、00% 其他 */
        CASE
            WHEN src.D010011 = '01' THEN '日报'
            WHEN src.D010011 = '02' THEN '月报'
            WHEN src.D010011 = '03' THEN '季报'
            WHEN src.D010011 = '04' THEN '半年报'
            WHEN src.D010011 = '05' THEN '年报'
            WHEN src.D010011 LIKE '00%' THEN CONCAT('其他-', REPLACE(src.D010011, '00', ''))
            ELSE NULL
        END AS BSZQ,
        /* 14 会计日期：YYYY-MM-DD 转 YYYYMMDD */
        TO_CHAR(src.D010010, 'YYYYMMDD') AS KJRQ,
        /* 15 备注 */
        src.D010013 AS BBZ,
        /* 16 采集日期：总账会计全科目.采集日期 YYYY-MM-DD 转 YYYYMMDD */
        TO_CHAR(src.D010012, 'YYYYMMDD') AS CJRQ,
        /* 17 归属分支机构：业务需求未提供来源 */
        NULL AS GSFZJG,
        /* 18 涉密标志：业务需求未提供来源 */
        NULL AS SENSITIVEFLAG
    FROM T_4_1 src
    LEFT JOIN T_1_1 org
           ON src.D010001 = org.A010001
          AND org.A010020 = V_DATA_DATE
    LEFT JOIN T_4_2 subj
           ON src.D010001 = subj.D020002
          AND src.D010002 = subj.D020001
          AND subj.D020011 = V_DATA_DATE
    WHERE src.D010012 = V_DATA_DATE
      AND src.D010009 IN ('CNY', 'BWB');

    COMMIT;
END;
