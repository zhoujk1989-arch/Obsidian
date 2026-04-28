/*
业务目标：
- 从一表通机构关系（T_1_2）和机构信息（T_1_1）映射生成 EAST5.0 机构关系表 IE_001_105。
- 每条记录描述一个机构与其上级管理机构的管理关系，含机构代码、许可证号、机构名称等。

目标系统：
- EAST5.0系统。

目标产物：
- MySQL 存储过程草案。

依赖知识页：
- [[来源-EAST5.0系统-IE_001_105-机构关系表]]
- [[数据表-IE_001_105-机构关系表-EAST5.0系统]]
- [[数据表-T_1_2-机构关系-一表通系统]]
- [[数据表-T_1_1-机构信息-一表通系统]]
- [[来源-一表通系统-1.2-机构关系]]
- [[来源-一表通系统-1.1-机构信息]]

源表：
- T_1_2：一表通机构关系，提供机构ID（A020001）和上级管理机构ID（A020002）。
- T_1_1：一表通机构信息，用于补充机构的支付行号、许可证号、机构名称等。

目标表：
- IE_001_105：EAST5.0 机构关系表。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- GSFZJG（归属分支机构）、SENSITIVEFLAG（涉密标志）当前无映射来源，置 NULL。
- A020002 = '0' 是否稳定表示"无上级机构"，待确认。
- 是否需要在 INSERT 前校验 IE_001_101 中已存在对应内部机构号，待确认。

开发说明：
- 按 SQL 开发规范使用直接 select + left join 风格。
- 不使用 select *。
- 不使用 CTE；T_1_1 去重通过派生表 NOT EXISTS 实现。
- INSERT 字段顺序与目标表 DDL 一致。
*/

CREATE PROCEDURE `PROC_EAST_IE_001_105`(
    IN I_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;

    -- 参数区：将入参日期转为 DATE 类型
    SET V_DATA_DATE = STR_TO_DATE(I_DATE, '%Y%m%d');

    -- 清理区：删除目标表当期数据
    DELETE FROM IE_001_105
     WHERE CJRQ = I_DATE;

    -- 主加工区 + 落地区
    INSERT INTO IE_001_105 (
        YHJGMC,             --  1. 银行机构名称
        JRXKZH,             --  2. 金融许可证号
        SJGLJGDM,           --  3. 上级管理机构代码
        GSFZJG,             --  4. 归属分支机构（暂无来源）
        SJGLNBJGH,          --  5. 上级管理内部机构号
        YHJGDM,             --  6. 银行机构代码
        BBZ,                --  7. 备注
        CJRQ,               --  8. 采集日期
        SENSITIVEFLAG,      --  9. 涉密标志（暂无来源）
        NBJGH,              -- 10. 内部机构号
        SJGLJGMC            -- 11. 上级管理机构名称
    )
    SELECT
        --  1. YHJGMC：用本表机构ID关联机构信息表，取银行机构名称
        cur_org.A010005                                          AS YHJGMC,

        --  2. JRXKZH：用本表机构ID关联机构信息表，取金融许可证号
        cur_org.A010003                                          AS JRXKZH,

        --  3. SJGLJGDM：上级管理机构代码
        --     上级id='0'时赋'0'，否则关联上级机构信息表取支付行号
        CASE
            WHEN t.A020002 = '0' THEN '0'
            ELSE par_org.A010006
        END                                                      AS SJGLJGDM,

        --  4. GSFZJG：归属分支机构，当前无映射来源
        NULL                                                     AS GSFZJG,

        --  5. SJGLNBJGH：上级管理内部机构号
        --     上级id='0'时赋'0'，否则取上级机构ID从第12位截取
        CASE
            WHEN t.A020002 = '0' THEN '0'
            ELSE SUBSTR(t.A020002, 12)
        END                                                      AS SJGLNBJGH,

        --  6. YHJGDM：银行机构代码，用本表机构ID关联机构信息表，取支付行号
        cur_org.A010006                                          AS YHJGDM,

        --  7. BBZ：备注，直接取自机构关系表
        t.A020004                                                AS BBZ,

        --  8. CJRQ：采集日期，日期格式转换为 YYYYMMDD
        DATE_FORMAT(t.A020003, '%Y%m%d')                         AS CJRQ,

        --  9. SENSITIVEFLAG：涉密标志，当前无映射来源
        NULL                                                     AS SENSITIVEFLAG,

        -- 10. NBJGH：内部机构号，机构关系表机构ID从第12位截取
        SUBSTR(t.A020001, 12)                                    AS NBJGH,

        -- 11. SJGLJGMC：上级管理机构名称
        --     上级id='0'时用本机构名称，否则关联上级机构信息表取名称
        CASE
            WHEN t.A020002 = '0' THEN cur_org.A010005
            ELSE par_org.A010005
        END                                                      AS SJGLJGMC

    FROM T_1_2 t

    -- LEFT JOIN 本机构信息（机构ID = 机构信息.机构ID，同采集日期）
    -- 对 T_1_1 去重：同机构ID同日期只保留一条，避免一对多造成目标表重复
    LEFT JOIN (
        SELECT
            org.A010001,
            org.A010002,
            org.A010003,
            org.A010005,
            org.A010006
        FROM T_1_1 org
        WHERE org.A010020 = V_DATA_DATE
          AND NOT EXISTS (
              SELECT 1
              FROM T_1_1 org_min
              WHERE org_min.A010020 = V_DATA_DATE
                AND org_min.A010001 = org.A010001
                AND org_min.A010002 < org.A010002
          )
    ) cur_org
      ON cur_org.A010001 = t.A020001

    -- LEFT JOIN 上级机构信息（上级管理机构ID = 机构信息.机构ID，同采集日期）
    -- 同上，去重避免一对多
    LEFT JOIN (
        SELECT
            org.A010001,
            org.A010002,
            org.A010003,
            org.A010005,
            org.A010006
        FROM T_1_1 org
        WHERE org.A010020 = V_DATA_DATE
          AND NOT EXISTS (
              SELECT 1
              FROM T_1_1 org_min
              WHERE org_min.A010020 = V_DATA_DATE
                AND org_min.A010001 = org.A010001
                AND org_min.A010002 < org.A010002
          )
    ) par_org
      ON par_org.A010001 = t.A020002
     AND t.A020002 <> '0'

    WHERE t.A020003 = V_DATA_DATE;

    COMMIT;
END;


/* ============================================================
   校验 SQL（建议另存为 CHECK_IE_001_105_校验.sql）
   ============================================================ */

-- 1. 行数检查：确认目标表当期记录数量
-- SELECT COUNT(*) AS target_cnt
-- FROM IE_001_105
-- WHERE CJRQ = I_DATE;

-- 2. 主键重复检查：NBJGH + CJRQ 不应重复
-- SELECT NBJGH, CJRQ, COUNT(*) AS cnt
-- FROM IE_001_105
-- WHERE CJRQ = I_DATE
-- GROUP BY NBJGH, CJRQ
-- HAVING COUNT(*) > 1;

-- 3. 必填为空检查：NBJGH、CJRQ 不应为空
-- SELECT COUNT(*) AS null_nbjgh
-- FROM IE_001_105
-- WHERE CJRQ = I_DATE
--   AND NBJGH IS NULL;
--
-- SELECT COUNT(*) AS null_cjrq
-- FROM IE_001_105
-- WHERE CJRQ = I_DATE
--   AND CJRQ IS NULL;

-- 4. 上级字段一致性：SJGLJGDM='0' 时，SJGLNBJGH 也应为 '0'
-- SELECT COUNT(*) AS mismatch_count
-- FROM IE_001_105
-- WHERE CJRQ = I_DATE
--   AND SJGLJGDM = '0'
--   AND SJGLNBJGH <> '0';

-- 5. 与一表通源表行数比对
-- SELECT COUNT(*) AS src_cnt
-- FROM T_1_2
-- WHERE A020003 = STR_TO_DATE(I_DATE, '%Y%m%d');
