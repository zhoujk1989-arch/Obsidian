CREATE PROCEDURE `PROC_EAST_IE_001_101_JGXX`(
    IN I_DATE VARCHAR(8)
)
BEGIN
    /******
      程序名称：PROC_EAST_IE_001_101_JGXX
      程序功能：从一表通机构信息映射生成 EAST5.0 机构信息表
      源表：T_1_1、T_1_3、T_4_1、T_4_3
      目标表：IE_001_101
      创建日期：2026-04-28
      说明：依据用户提供的“一表通映射规则”整理。
    ******/

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
    WITH
    curr_org AS (
        SELECT *
        FROM (
            SELECT
                t.*,
                ROW_NUMBER() OVER (
                    PARTITION BY t.A010002
                    ORDER BY t.A010001
                ) AS rn
            FROM T_1_1 t
            WHERE t.A010020 = V_DATA_DATE
        ) x
        WHERE x.rn = 1
    ),
    prev_org AS (
        SELECT *
        FROM (
            SELECT
                t.*,
                ROW_NUMBER() OVER (
                    PARTITION BY t.A010002
                    ORDER BY t.A010001
                ) AS rn
            FROM T_1_1 t
            WHERE t.A010020 = V_LAST_MON_DT
        ) x
        WHERE x.rn = 1
    ),
    employee AS (
        SELECT *
        FROM (
            SELECT
                e.*,
                ROW_NUMBER() OVER (
                    PARTITION BY e.A030001
                    ORDER BY e.A030028 DESC, e.A030002
                ) AS rn
            FROM T_1_3 e
            WHERE e.A030028 <= V_DATA_DATE
        ) x
        WHERE x.rn = 1
    ),
    gl_nonzero_org AS (
        SELECT DISTINCT g.D010001 AS org_id
        FROM T_4_1 g
        WHERE g.D010012 = V_DATA_DATE
          AND (
                COALESCE(CAST(NULLIF(g.D010003, '') AS DECIMAL(22, 2)), 0)
              + COALESCE(CAST(NULLIF(g.D010004, '') AS DECIMAL(22, 2)), 0)
              + COALESCE(CAST(NULLIF(g.D010007, '') AS DECIMAL(22, 2)), 0)
              + COALESCE(CAST(NULLIF(g.D010008, '') AS DECIMAL(22, 2)), 0)
          ) <> 0
    ),
    internal_account_org AS (
        SELECT DISTINCT a.D030001 AS org_id
        FROM T_4_3 a
        WHERE a.D030015 = V_DATA_DATE
    ),
    backfill_org AS (
        SELECT org_id
        FROM gl_nonzero_org
        UNION
        SELECT org_id
        FROM internal_account_org
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
    FROM curr_org c
    LEFT JOIN prev_org p
      ON p.A010002 = c.A010002
    LEFT JOIN employee e
      ON e.A030001 = c.A010018
    LEFT JOIN backfill_org b
      ON b.org_id = c.A010001
    WHERE NOT (
            COALESCE(p.A010014, '') IN ('00', '02', '03')
        AND COALESCE(c.A010014, '') IN ('00', '02', '03')
        AND b.org_id IS NULL
    );

    COMMIT;
END;
