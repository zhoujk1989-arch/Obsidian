/*
业务目标：
- 从一表通员工表映射生成 EAST5.0 员工表 IE_001_102。

目标系统：
- EAST5.0系统。

目标产物：
- MySQL 存储过程草案。

依赖知识页：
- [[来源-EAST5.0系统-IE_001_102-员工表]]
- [[报表-IE_001_102-员工表-EAST5.0系统]]
- [[数据表-IE_001_102-员工表-EAST5.0系统]]
- [[血缘-IE_001_102-员工表-EAST5.0系统]]

源表：
- T_1_3：一表通员工表，作为员工明细主源。
- T_1_1：一表通机构信息，补金融许可证号和银行机构名称。
- T_10_1：一表通公共代码，补国家地区和证件类型中文含义。

目标表：
- IE_001_102：EAST5.0 员工表。

参数：
- p_data_date：采集日期，格式 YYYYMMDD。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- 子公司员工排除规则和理财子公司纳入规则缺少字段来源，当前未实现。
- GSFZJG、SENSITIVEFLAG 当前无映射来源，仍置空。
- 公共代码表国家地区、证件类型码值完整性待跑数验证。

开发说明：
- 本文件按 SQL 开发规范调整为直接 select + left join 风格。
- 不使用 select *；派生表只查询实际使用字段。
- 不使用 CTE；员工主源用实际使用字段 distinct 去重，机构和代码表用派生表中的 not exists 收窄。
*/

DELIMITER $$

CREATE PROCEDURE `sp_east_IE_001_102`(
    IN p_data_date VARCHAR(8)
)
BEGIN
    DECLARE v_data_date DATE;
    DECLARE v_month_begin DATE;
    DECLARE v_deleted_rows INT DEFAULT 0;
    DECLARE v_inserted_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- TODO: 写入异常日志表，例如 etl_proc_log，记录 p_data_date 和异常信息。
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
            WHEN e.A030015 LIKE '00%' THEN CONCAT('其他-', SUBSTRING(e.A030015, 3))
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
            WHEN e.A030022 LIKE '00%' THEN CONCAT('其他-', SUBSTRING(e.A030022, 3))
            ELSE NULLIF(TRIM(e.A030022), '')
        END AS YGZT,
        COALESCE(NULLIF(TRIM(e.A030017), ''), '') AS GWMC
    FROM (
        SELECT DISTINCT
            emp.A030001,
            emp.A030002,
            emp.A030003,
            emp.A030004,
            emp.A030005,
            emp.A030006,
            emp.A030008,
            emp.A030010,
            emp.A030012,
            emp.A030013,
            emp.A030014,
            emp.A030015,
            emp.A030016,
            emp.A030017,
            emp.A030022,
            emp.A030027,
            emp.A030028,
            emp.A030029
        FROM T_1_3 emp
        WHERE emp.A030028 = v_data_date
          AND (
                emp.A030022 IN ('01', '03')
             OR emp.A030029 >= v_month_begin
          )
    ) e
    LEFT JOIN (
        SELECT
            org.A010001,
            org.A010003,
            org.A010005
        FROM T_1_1 org
        WHERE org.A010020 = v_data_date
          AND NOT EXISTS (
              SELECT 1
              FROM T_1_1 org_rank
              WHERE org_rank.A010020 = v_data_date
                AND org_rank.A010001 = org.A010001
                AND (
                    org_rank.A010020 > org.A010020
                    OR (
                        org_rank.A010020 = org.A010020
                        AND org_rank.A010002 < org.A010002
                    )
                )
          )
    ) o
      ON o.A010001 = e.A030002
    LEFT JOIN (
        SELECT
            code.K010004 AS code_value,
            code.K010005 AS code_name
        FROM T_10_1 code
        WHERE code.K010002 = '通用'
          AND code.K010003 = '国家地区'
          AND NOT EXISTS (
              SELECT 1
              FROM T_10_1 code_rank
              WHERE code_rank.K010002 = '通用'
                AND code_rank.K010003 = '国家地区'
                AND code_rank.K010004 = code.K010004
                AND code_rank.K010001 < code.K010001
          )
    ) cc
      ON cc.code_value = e.A030004
    LEFT JOIN (
        SELECT
            code.K010004 AS code_value,
            code.K010005 AS code_name
        FROM T_10_1 code
        WHERE code.K010002 = '通用'
          AND code.K010003 = '证件类型'
          AND NOT EXISTS (
              SELECT 1
              FROM T_10_1 code_rank
              WHERE code_rank.K010002 = '通用'
                AND code_rank.K010003 = '证件类型'
                AND code_rank.K010004 = code.K010004
                AND code_rank.K010001 < code.K010001
          )
    ) ct
      ON ct.code_value = e.A030005;

    SET v_inserted_rows = ROW_COUNT();

    -- TODO: 写入正常日志表，例如 etl_proc_log，记录 p_data_date、v_deleted_rows、v_inserted_rows。
    COMMIT;
END$$

DELIMITER ;
