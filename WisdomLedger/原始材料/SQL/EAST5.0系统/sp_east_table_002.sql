DELIMITER $$

CREATE PROCEDURE `sp_east_IE_001_102`(
    IN p_data_date VARCHAR(8)
)
BEGIN
    /******
      程序名称：sp_east_table_002
      程序功能：从一表通员工表映射生成 EAST5.0 员工表
      源表：T_1_3、T_1_1、T_10_1
      目标表：IE_001_102
      创建日期：2026-04-28
      说明：依据用户提供的“一表通转换 EAST 映射规则”员工表需求整理。
    ******/

    DECLARE v_data_date DATE;
    DECLARE v_month_begin DATE;
    DECLARE v_deleted_rows INT DEFAULT 0;
    DECLARE v_inserted_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- TODO: 写入异常日志表，例如 etl_proc_log，记录 p_batch_no、p_data_date 和异常信息。
        RESIGNAL;
    END;

    SET v_data_date = STR_TO_DATE(p_data_date, '%Y%m%d');
    SET v_month_begin = STR_TO_DATE(CONCAT(LEFT(p_data_date, 6), '01'), '%Y%m%d');

    START TRANSACTION;

    DELETE FROM IE_001_102
     WHERE CJRQ = p_data_date;
    SET v_deleted_rows = ROW_COUNT();

    INSERT INTO IE_001_102 (
        SENSITIVEFLAG,
        BBZ,
        JRXKZH,
        YHJGMC,
        ZJLB,
        SSBM,
        YGLX,
        CJRQ,
        GSFZJG,
        NBJGH,
        GH,
        XM,
        GJHDQ,
        ZJHM,
        LXDH,
        GWBH,
        SFGG,
        PFRQ,
        RZRQ,
        YGZT,
        GWMC
    )
    WITH
    emp_src AS (
        SELECT *
        FROM (
            SELECT
                e.*,
                ROW_NUMBER() OVER (
                    PARTITION BY e.A030001, e.A030002
                    ORDER BY e.A030028 DESC
                ) AS rn
            FROM T_1_3 e
            WHERE e.A030028 = v_data_date
              AND (
                    e.A030022 IN ('01', '03')
                 OR e.A030029 >= v_month_begin
              )
        ) x
        WHERE x.rn = 1
    ),
    org_src AS (
        SELECT *
        FROM (
            SELECT
                o.*,
                ROW_NUMBER() OVER (
                    PARTITION BY o.A010001
                    ORDER BY o.A010020 DESC, o.A010002
                ) AS rn
            FROM T_1_1 o
            WHERE o.A010020 = v_data_date
        ) x
        WHERE x.rn = 1
    ),
    country_code AS (
        SELECT *
        FROM (
            SELECT
                c.K010004 AS code_value,
                c.K010005 AS code_name,
                ROW_NUMBER() OVER (
                    PARTITION BY c.K010004
                    ORDER BY c.K010001
                ) AS rn
            FROM T_10_1 c
            WHERE c.K010002 = '通用'
              AND c.K010003 = '国家地区'
        ) x
        WHERE x.rn = 1
    ),
    cert_type_code AS (
        SELECT *
        FROM (
            SELECT
                c.K010004 AS code_value,
                c.K010005 AS code_name,
                ROW_NUMBER() OVER (
                    PARTITION BY c.K010004
                    ORDER BY c.K010001
                ) AS rn
            FROM T_10_1 c
            WHERE c.K010002 = '通用'
              AND c.K010003 = '证件类型'
        ) x
        WHERE x.rn = 1
    )
    SELECT
        NULL AS SENSITIVEFLAG,
        NULLIF(TRIM(e.A030027), '') AS BBZ,
        NULLIF(TRIM(o.A010003), '') AS JRXKZH,
        NULLIF(TRIM(o.A010005), '') AS YHJGMC,
        CASE
            WHEN e.A030005 LIKE '1999%' THEN '其他-自定义'
            WHEN e.A030005 LIKE '2999%' THEN '其他-自定义'
            WHEN ct.code_name IS NOT NULL THEN ct.code_name
            ELSE NULLIF(TRIM(e.A030005), '')
        END AS ZJLB,
        NULLIF(TRIM(e.A030010), '') AS SSBM,
        CASE
            WHEN e.A030015 = '01' THEN '正式员工'
            WHEN e.A030015 = '02' THEN '非正式员工'
            WHEN e.A030015 = '03' THEN '非员工高管'
            WHEN e.A030015 LIKE '00%' THEN '其他-自定义'
            ELSE NULLIF(TRIM(e.A030015), '')
        END AS YGLX,
        DATE_FORMAT(e.A030028, '%Y%m%d') AS CJRQ,
        NULL AS GSFZJG,
        SUBSTRING(NULLIF(TRIM(e.A030002), ''), 12) AS NBJGH,
        NULLIF(TRIM(e.A030001), '') AS GH,
        NULLIF(TRIM(e.A030003), '') AS XM,
        COALESCE(cc.code_name, NULLIF(TRIM(e.A030004), '')) AS GJHDQ,
        NULLIF(TRIM(e.A030006), '') AS ZJHM,
        NULLIF(TRIM(e.A030008), '') AS LXDH,
        COALESCE(NULLIF(TRIM(e.A030016), ''), '') AS GWBH,
        CASE
            WHEN e.A030012 = '1' THEN '是'
            WHEN e.A030012 = '0' THEN '否'
            ELSE NULLIF(TRIM(e.A030012), '')
        END AS SFGG,
        CASE
            WHEN e.A030013 IS NULL THEN NULL
            ELSE DATE_FORMAT(e.A030013, '%Y%m%d')
        END AS PFRQ,
        CASE
            WHEN e.A030014 IS NULL THEN NULL
            ELSE DATE_FORMAT(e.A030014, '%Y%m%d')
        END AS RZRQ,
        CASE
            WHEN e.A030022 = '01' THEN '在岗'
            WHEN e.A030022 = '02' THEN '其他-退休'
            WHEN e.A030022 = '03' THEN '其他-待岗'
            WHEN e.A030022 = '04' THEN '离职'
            WHEN e.A030022 = '05' THEN '离岗'
            WHEN e.A030022 LIKE '00%' THEN '其他-自定义'
            ELSE NULLIF(TRIM(e.A030022), '')
        END AS YGZT,
        COALESCE(NULLIF(TRIM(e.A030017), ''), '') AS GWMC
    FROM emp_src e
    LEFT JOIN org_src o
      ON o.A010001 = e.A030002
    LEFT JOIN country_code cc
      ON cc.code_value = e.A030004
    LEFT JOIN cert_type_code ct
      ON ct.code_value = e.A030005;

    SET v_inserted_rows = ROW_COUNT();

    -- TODO: 写入正常日志表，例如 etl_proc_log，记录 p_batch_no、p_data_date、v_deleted_rows、v_inserted_rows。
    COMMIT;
END$$

DELIMITER ;
