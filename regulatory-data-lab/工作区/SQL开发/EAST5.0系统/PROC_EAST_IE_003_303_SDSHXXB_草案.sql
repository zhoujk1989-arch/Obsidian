/*
业务目标：
- 依据原始业务需求《015_收单商户信息表.md》生成 EAST5.0 收单商户信息表（IE_003_303）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/015_收单商户信息表.md
- 原始材料/表结构/一表通系统/T_2_7-收单商户信息表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_10_1-公共代码-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_003_303-收单商户信息表-DDL-2026-04-28.sql

源表：
- T_2_7：收单商户信息表，主表。
- T_1_1：机构信息表，用于取金融许可证号。
- T_10_1：公共代码，用于商户地区行政区划中文含义转换。

目标表：
- IE_003_303：收单商户信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 全量截面重跑；先删除目标表同一采集日期数据，再插入截至采集日仍有效或当月应保留终态的收单商户/终端记录。

关键口径：
- 收单商户信息表按采集日期取数。
- 机构ID 关联机构信息表取金融许可证号。
- 商户地区分别按省级、地市级、区县级代码关联公共代码表，表名=通用、字段名=行政区划。
- 保留商户失效日期为空/大于等于采集月月初，或终端失效日期为空/大于等于采集月月初的数据。

未确认点：
- 业务需求第 2.1 节第二处“左关联：机构信息”实际关联条件指向公共代码；本草案按字段级规则使用 T_10_1 公共代码表。
- 目标 DDL 字段 QSZHLB、SENSITIVEFLAG、GSFZJG 在本业务需求未给出来源，保留 NULL，待补充来源后再加工。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_003_303_SDSHXXB;

CREATE PROCEDURE PROC_EAST_IE_003_303_SDSHXXB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_MON_START DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);
    SET V_MON_START = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-01') AS DATE);

    START TRANSACTION;

    DELETE FROM IE_003_303
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_003_303 (
        QSZHLB,
        BBZ,
        SENSITIVEFLAG,
        SHMCCMC,
        QSZH,
        QSZHKHHMC,
        CJRQ,
        JRXKZH,
        NBJGH,
        SHBH,
        SHMC,
        SFPOS,
        ZDH,
        SHMCCM,
        SHDQ,
        QSZHLX,
        QSZHMC,
        QXRQ,
        SXRQ,
        SHZT,
        GSFZJG
    )
    SELECT
        /* 清算账户类别：业务需求未提供来源 */
        NULL AS QSZHLB,
        /* 备注：收单商户信息.备注 */
        src.B070018 AS BBZ,
        /* 涉密标志：业务需求未提供来源 */
        NULL AS SENSITIVEFLAG,
        /* 商户MCC名称：收单商户信息.商户类别码名称 */
        src.B070008 AS SHMCCMC,
        /* 清算账号：收单商户信息.清算卡号或账号 */
        src.B070009 AS QSZH,
        /* 清算账号开户行名称：收单商户信息.清算账号开户行名称 */
        src.B070012 AS QSZHKHHMC,
        /* 采集日期：跑批参数 */
        P_DATA_DATE AS CJRQ,
        /* 金融许可证号：机构ID 关联机构信息取金融许可证号 */
        org.A010003 AS JRXKZH,
        /* 内部机构号：机构ID 从第12位开始截取 */
        SUBSTR(TRIM(src.B070003), 12) AS NBJGH,
        /* 商户编号：收单商户信息.商户ID */
        src.B070001 AS SHBH,
        /* 商户名称：收单商户信息.商户名称 */
        src.B070004 AS SHMC,
        /* 是否POS商户：1=是，其余=否 */
        CASE WHEN src.B070005 = '1' THEN '是' ELSE '否' END AS SFPOS,
        /* 终端号：收单商户信息.终端号 */
        src.B070006 AS ZDH,
        /* 商户MCC码：收单商户信息.商户类别码 */
        src.B070007 AS SHMCCM,
        /* 商户地区：按行政区划公共代码拼接中文含义 */
        CASE
            WHEN RIGHT(src.B070015, 4) = '0000' THEN pc_prov.K010005
            WHEN RIGHT(src.B070015, 2) = '00' THEN CONCAT(COALESCE(pc_prov.K010005, ''), COALESCE(pc_city.K010005, ''))
            ELSE CONCAT(COALESCE(pc_prov.K010005, ''), COALESCE(pc_city.K010005, ''), COALESCE(pc_county.K010005, ''))
        END AS SHDQ,
        /* 清算账号类型：按一表通代码转换 EAST 展示值 */
        CASE
            WHEN src.B070010 = '01' THEN '本行卡'
            WHEN src.B070010 = '02' THEN '本行对公结算账户'
            WHEN src.B070010 = '03' THEN '他行卡'
            WHEN src.B070010 = '04' THEN '他行对公结算账户'
            WHEN src.B070010 LIKE '00%' THEN REPLACE(src.B070010, '00', '其他')
            ELSE src.B070010
        END AS QSZHLX,
        /* 清算账户名称：收单商户信息.清算账户名称 */
        src.B070011 AS QSZHMC,
        /* 起效日期：YYYY-MM-DD 转 YYYYMMDD */
        CASE WHEN src.B070013 IS NULL THEN NULL ELSE CONCAT(CAST(YEAR(src.B070013) AS VARCHAR(4)), LPAD(CAST(MONTH(src.B070013) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.B070013) AS VARCHAR(2)), 2, '0')) END AS QXRQ,
        /* 失效日期：为空赋值 99991231，否则 YYYY-MM-DD 转 YYYYMMDD */
        CASE WHEN src.B070014 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.B070014) AS VARCHAR(4)), LPAD(CAST(MONTH(src.B070014) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.B070014) AS VARCHAR(2)), 2, '0')) END AS SXRQ,
        /* 商户状态：收单商户信息.商户状态 */
        src.B070016 AS SHZT,
        /* 归属分支机构：业务需求未提供来源 */
        NULL AS GSFZJG
    FROM T_2_7 src
    LEFT JOIN T_1_1 org
           ON src.B070003 = org.A010001
          AND org.A010020 = V_DATA_DATE
    LEFT JOIN T_10_1 pc_prov
           ON pc_prov.K010002 = '通用'
          AND pc_prov.K010003 = '行政区划'
          AND pc_prov.K010004 = CONCAT(LEFT(src.B070015, 2), '0000')
    LEFT JOIN T_10_1 pc_city
           ON pc_city.K010002 = '通用'
          AND pc_city.K010003 = '行政区划'
          AND pc_city.K010004 = CONCAT(LEFT(src.B070015, 4), '00')
    LEFT JOIN T_10_1 pc_county
           ON pc_county.K010002 = '通用'
          AND pc_county.K010003 = '行政区划'
          AND pc_county.K010004 = src.B070015
    WHERE src.B070017 = V_DATA_DATE
      AND (
          src.B070014 IS NULL
          OR src.B070014 >= V_MON_START
          OR src.B070019 IS NULL
          OR src.B070019 >= V_MON_START
      );

    COMMIT;
END;
