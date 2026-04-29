/*
业务目标：
- 从一表通机构信息映射生成 EAST5.0 机构信息表 IE_001_101。

目标系统：
- EAST5.0系统。

目标产物：
- MySQL 存储过程草案。

依赖知识页：
- [[来源-EAST5.0系统-IE_001_101-机构信息表]]
- [[报表-IE_001_101-机构信息表-EAST5.0系统]]
- [[数据表-IE_001_101-机构信息表-EAST5.0系统]]
- [[血缘-IE_001_101-机构信息表-EAST5.0系统]]

源表：
- T_1_1：一表通机构信息，当日快照为主源，上月末快照用于连续停业判断。
- T_1_3：一表通员工表，用负责人工号补负责人职务。
- T_4_1：一表通总账会计全科目，用于识别仍有余额的机构。
- T_4_3：一表通分户账信息，用于识别仍有分户账记录的机构。

目标表：
- IE_001_101：EAST5.0 机构信息表。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- GSFZJG、SENSITIVEFLAG 当前无映射来源，仍置空。
- “被合并”是否由 A010014='03' 表达仍待确认。
- 总账余额不为 0 当前沿用原 SQL 中余额类字段合计不为 0 的判断。

开发说明：
- 本文件按 SQL 开发规范调整为直接 select + left join 风格。
- 不使用 select *；派生表只查询实际使用字段。
- 不使用 CTE；去重逻辑改为派生表中的 not exists。
*/

CREATE PROCEDURE `PROC_EAST_IE_001_101_JGXX`(
    IN I_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_LAST_MON_DT DATE;

    SET V_DATA_DATE = STR_TO_DATE(I_DATE, '%Y%m%d');
    SET V_LAST_MON_DT = LAST_DAY(DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH));

    DELETE FROM IE_001_101
     WHERE CJRQ = I_DATE;

    INSERT INTO IE_001_101 (
        FZRLXDH,
        GSFZJG,
        SENSITIVEFLAG,
        JGLB,
        CLRQ,
        JGDZ,
        BBZ,
        NBJGH,
        JRXKZH,
        YYZZH,
        YHJGMC,
        XZQHDM,
        YYZT,
        JGLXDH,
        FZRXM,
        FZRZW,
        CJRQ,
        YHJGDM
    )
    SELECT
        c.A010019 AS FZRLXDH,
        NULL AS GSFZJG,
        NULL AS SENSITIVEFLAG,
        CASE
            WHEN c.A010008 IN ('0101', '0102') THEN '管理机构'
            WHEN c.A010008 IN ('0201', '0202', '0203') THEN '营业机构'
            WHEN c.A010008 IN ('0301', '0302') THEN '虚拟机构'
            WHEN c.A010008 IN ('0401', '0402') THEN '内设机构'
            ELSE NULL
        END AS JGLB,
        DATE_FORMAT(c.A010015, '%Y%m%d') AS CLRQ,
        c.A010016 AS JGDZ,
        c.A010026 AS BBZ,
        c.A010002 AS NBJGH,
        c.A010003 AS JRXKZH,
        c.A010004 AS YYZZH,
        c.A010005 AS YHJGMC,
        c.A010013 AS XZQHDM,
        CASE
            WHEN c.A010014 = '01' THEN '营业'
            WHEN c.A010014 IN ('00', '02', '03') THEN '停业'
            ELSE '停业'
        END AS YYZT,
        c.A010024 AS JGLXDH,
        c.A010017 AS FZRXM,
        e.A030011 AS FZRZW,
        DATE_FORMAT(c.A010020, '%Y%m%d') AS CJRQ,
        c.A010006 AS YHJGDM
    FROM (
        SELECT
            t.A010001,
            t.A010002,
            t.A010003,
            t.A010004,
            t.A010005,
            t.A010006,
            t.A010008,
            t.A010013,
            t.A010014,
            t.A010015,
            t.A010016,
            t.A010017,
            t.A010018,
            t.A010019,
            t.A010020,
            t.A010024,
            t.A010026
        FROM T_1_1 t
        WHERE t.A010020 = V_DATA_DATE
          AND NOT EXISTS (
              SELECT 1
              FROM T_1_1 t_min
              WHERE t_min.A010020 = V_DATA_DATE
                AND t_min.A010002 = t.A010002
                AND t_min.A010001 < t.A010001
          )
    ) c
    LEFT JOIN (
        SELECT
            p0.A010002,
            p0.A010014
        FROM T_1_1 p0
        WHERE p0.A010020 = V_LAST_MON_DT
          AND NOT EXISTS (
              SELECT 1
              FROM T_1_1 p_min
              WHERE p_min.A010020 = V_LAST_MON_DT
                AND p_min.A010002 = p0.A010002
                AND p_min.A010001 < p0.A010001
          )
    ) p
      ON p.A010002 = c.A010002
    LEFT JOIN (
        SELECT
            emp.A030001,
            emp.A030011
        FROM T_1_3 emp
        WHERE emp.A030028 <= V_DATA_DATE
          AND NOT EXISTS (
              SELECT 1
              FROM T_1_3 emp_rank
              WHERE emp_rank.A030001 = emp.A030001
                AND emp_rank.A030028 <= V_DATA_DATE
                AND (
                    emp_rank.A030028 > emp.A030028
                    OR (
                        emp_rank.A030028 = emp.A030028
                        AND emp_rank.A030002 < emp.A030002
                    )
                )
          )
    ) e
      ON e.A030001 = c.A010018
    LEFT JOIN (
        SELECT DISTINCT g.D010001 AS org_id
        FROM T_4_1 g
        WHERE g.D010012 = V_DATA_DATE
          AND (
                COALESCE(CAST(NULLIF(g.D010003, '') AS DECIMAL(22, 2)), 0)
              + COALESCE(CAST(NULLIF(g.D010004, '') AS DECIMAL(22, 2)), 0)
              + COALESCE(CAST(NULLIF(g.D010007, '') AS DECIMAL(22, 2)), 0)
              + COALESCE(CAST(NULLIF(g.D010008, '') AS DECIMAL(22, 2)), 0)
          ) <> 0
        UNION
        SELECT DISTINCT a.D030001 AS org_id
        FROM T_4_3 a
        WHERE a.D030015 = V_DATA_DATE
    ) b
      ON b.org_id = c.A010001
    WHERE NOT (
            COALESCE(p.A010014, '') IN ('00', '02', '03')
        AND COALESCE(c.A010014, '') IN ('00', '02', '03')
        AND b.org_id IS NULL
    );

    COMMIT;
END;
