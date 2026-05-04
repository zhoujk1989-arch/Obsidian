/*
业务目标：
- 依据原始业务需求《014_存折信息表.md》生成 EAST5.0 存折信息表（IE_003_302）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/014_存折信息表.md
- 原始材料/表结构/一表通系统/T_6_28-介质协议表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_201-个人基础信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_203-对公客户信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_003_302-存折信息表-DDL-2026-04-28.sql

源表：
- T_6_28：介质协议表，主表。
- T_1_1：机构信息表，用于取金融许可证号。
- IE_002_201：EAST 个人基础信息表，用于补客户姓名、证件类别、证件号码。
- IE_002_203：EAST 对公客户信息表，用于补客户名称、证件类别、证件号码。

目标表：
- IE_003_302：存折信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 全量截面重跑；先删除目标表同一采集日期数据，再插入截至采集日仍有效或当月应保留终态的存折/存单介质。

关键口径：
- 介质协议表按采集日期取数。
- 筛选介质类型不为 01-卡的介质。
- 保留失效日期为空或大于等于采集月月初的数据。
- 排除上月已注销且失效日期早于采集月月初的除卡外介质。
- 客户名称、证件类别、证件号码优先取个人基础信息，取不到再取对公客户信息；证件类别均取不到时赋“无证件”。

未确认点：
- 业务需求写“内部机构号关联机构信息内部机构号”，但 T_6_28 当前 DDL 只有 F280001 机构ID；本草案按字段映射规则使用 T_6_28.F280001 = T_1_1.A010001。
- 需求字段“交易介质”在 T_6_28 DDL 中未单列；本草案按介质类型 F280006 做存折类型转换。
- 目标 DDL 字段 KHLB、SENSITIVEFLAG、GSFZJG 在本业务需求未给出来源，保留 NULL，待补充来源后再加工。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_003_302_CZXXB;

CREATE PROCEDURE PROC_EAST_IE_003_302_CZXXB(
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

    DELETE FROM IE_003_302
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_003_302 (
        JRXKZH,
        KHLB,
        NBJGH,
        KHMC,
        ZJHM,
        HQCKZH,
        YGBZ,
        QYGYH,
        CJRQ,
        CZZT,
        SENSITIVEFLAG,
        KHTYBH,
        ZJLB,
        CZH,
        CZLX,
        QYRQ,
        BBZ,
        GSFZJG
    )
    SELECT
        /* 金融许可证号：介质协议表.机构ID 关联机构信息表.机构ID 取金融许可证号 */
        org.A010003 AS JRXKZH,
        /* 客户类别：业务需求未提供来源 */
        NULL AS KHLB,
        /* 内部机构号：介质协议表.机构ID 从第12位开始截取 */
        SUBSTR(TRIM(src.F280001), 12) AS NBJGH,
        /* 客户名称：优先个人客户姓名，取不到再取对公客户名称 */
        COALESCE(per.KHXM, corp.KHMC) AS KHMC,
        /* 证件号码：优先个人，取不到再取对公 */
        COALESCE(per.ZJHM, corp.ZJHM) AS ZJHM,
        /* 存款账号：介质协议表.分户账号 */
        src.F280003 AS HQCKZH,
        /* 员工标志：0=否，1=是 */
        CASE
            WHEN src.F280008 = '1' THEN '是'
            WHEN src.F280008 = '0' THEN '否'
            ELSE src.F280008
        END AS YGBZ,
        /* 启用柜员号：“自动”转为空，否则取原值 */
        CASE WHEN src.F280011 = '自动' THEN NULL ELSE src.F280011 END AS QYGYH,
        /* 采集日期：跑批参数 */
        P_DATA_DATE AS CJRQ,
        /* 存折状态：介质状态码值转换 */
        CASE
            WHEN src.F280012 = '01' THEN '未激活'
            WHEN src.F280012 = '02' THEN '正常'
            WHEN src.F280012 = '03' THEN '注销'
            WHEN src.F280012 = '04' THEN '冻结'
            WHEN src.F280012 = '05' THEN '睡眠'
            WHEN src.F280012 = '06' THEN '挂失'
            WHEN src.F280012 LIKE '00%' THEN REPLACE(src.F280012, '00', '其他')
            ELSE src.F280012
        END AS CZZT,
        /* 涉密标志：业务需求未提供来源 */
        NULL AS SENSITIVEFLAG,
        /* 客户统一编号：介质协议表.客户ID */
        src.F280002 AS KHTYBH,
        /* 证件类别：优先个人，取不到再取对公，均取不到赋“无证件” */
        COALESCE(per.ZJLB, corp.ZJLB, '无证件') AS ZJLB,
        /* 存折号：介质协议表.介质号 */
        src.F280005 AS CZH,
        /* 存折类型：按介质类型转换 */
        CASE
            WHEN src.F280006 = '02' THEN '普通存折'
            WHEN src.F280006 = '04' THEN '存单'
            WHEN src.F280006 = '05' THEN '大额定期存单'
            WHEN src.F280006 = '06' THEN '一本通'
            WHEN src.F280006 = '07' THEN '普通存折'
            WHEN src.F280006 LIKE '00%' THEN REPLACE(src.F280006, '00', '其他')
            ELSE src.F280006
        END AS CZLX,
        /* 启用日期：YYYY-MM-DD 转 YYYYMMDD */
        CASE WHEN src.F280009 IS NULL THEN NULL ELSE CONCAT(CAST(YEAR(src.F280009) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F280009) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F280009) AS VARCHAR(2)), 2, '0')) END AS QYRQ,
        /* 备注：介质协议表.备注 */
        src.F280013 AS BBZ,
        /* 归属分支机构：业务需求未提供来源 */
        NULL AS GSFZJG
    FROM T_6_28 src
    LEFT JOIN T_1_1 org
           ON src.F280001 = org.A010001
          AND org.A010020 = V_DATA_DATE
    LEFT JOIN IE_002_201 per
           ON src.F280002 = per.KHTYBH
          AND per.CJRQ = P_DATA_DATE
    LEFT JOIN IE_002_203 corp
           ON src.F280002 = corp.KHTYBH
          AND corp.CJRQ = P_DATA_DATE
    WHERE src.F280014 = V_DATA_DATE
      AND NOT (
          src.F280006 IN ('01', '01-卡')
          OR src.F280006 LIKE '01-%'
      )
      AND (
          src.F280010 IS NULL
          OR src.F280010 >= V_MON_START
      )
      AND NOT (
          src.F280012 IN ('03', '03-注销')
          AND src.F280010 < V_MON_START
      );

    COMMIT;
END;
