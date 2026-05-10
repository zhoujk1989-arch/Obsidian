/*
业务目标：
- 依据原始业务需求《013_借记卡信息表.md》生成 EAST5.0 借记卡信息表（IE_003_301）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/013_借记卡信息表.md
- 原始材料/表结构/EAST5.0系统/IE_003_301-借记卡信息表-DDL-2026-04-28.sql

源表：
- T_6_28：介质协议表，主表。
- T_1_1：机构信息表，按机构ID关联，补金融许可证号。
- T_5_6：卡产品，按卡产品ID关联，补借记卡产品名称。
- IE_002_201：EAST5.0 个人基础信息表，按客户统一编号关联，补个人客户名称、证件类别、证件号码。
- IE_002_203：EAST5.0 对公客户信息表，按客户统一编号关联，补对公客户名称、证件类别、证件号码。

目标表：
- IE_003_301：借记卡信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 个人和对公客户在银行机构开办的借记卡信息，指只能存取款而无法透支的卡片信息。当卡片状态为“注销”时，可在报送最后状态的次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 249 行） 主表：【介质协议表】 左关联：【机构信息表】 关联条件：【介质协议表】【内部机构号】关联【机构信息表】【内部机构号】 左关联：【卡产品】 关联条件：【介质协议表】【产品ID】关联【卡产品】.【产品ID】 左关联：EAST.【个人基础信息表】 关联条件：【介质协议表】【客户ID】关联EAST.【个人基础信息表】的【客户统一编号】 左关联：EAST.【对公客户信息表】 关联条件：【介质协议表】【客户ID】关联EAST.【对公客户信息表】的【客户统一编号】 过滤条件：筛选介质类型为’01-卡'、'07-卡折合一'的介质，包含失效日期大于等于当月 且 介质状态不包含上月已注销的卡

未确认点：
- 业务需求表级规则写“介质协议表.内部机构号 关联 机构信息表.内部机构号”，但一表通 `T_6_28` DDL 只有 `F280001`（机构ID），没有独立内部机构号字段；本草案按字段映射说明使用 `T_6_28.F280001 = T_1_1.A010001` 关联机构ID。
- “介质状态不包含上月已注销的卡”当前实现为排除 `介质状态=03/03-注销` 且 `介质失效日期 < 当月月初` 的记录；是否还需结合上月快照待跑数确认。
- `GSFZJG`、`SENSITIVEFLAG`、`KHLB` 在本次业务需求映射清单中未给来源，暂置空并作为 DDL 字段缺口。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_003_301_JJKXXB;

CREATE PROCEDURE PROC_EAST_IE_003_301_JJKXXB(
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

    DELETE FROM IE_003_301
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_003_301 (
        /* 按业务需求序号排列（序1~16），其后为DDL缺口字段（GSFZJG/SENSITIVEFLAG/KHLB 置NULL） */
        JRXKZH,        /*  1 金融许可证号 */
        NBJGH,         /*  2 内部机构号 */
        KHTYBH,        /*  3 客户统一编号 */
        KHMC,          /*  4 客户名称 */
        ZJLB,          /*  5 证件类别 */
        ZJHM,          /*  6 证件号码 */
        KH,            /*  7 卡号 */
        HQCKZH,        /*  8 活期存款账号 */
        JJKCPMC,       /*  9 借记卡产品名称 */
        XNKBZ,         /* 10 虚拟卡标志 */
        YGKBZ,         /* 11 员工卡标志 */
        KKRQ,          /* 12 开卡日期 */
        KKGYH,         /* 13 开卡柜员号 */
        KPZT,          /* 14 卡片状态 */
        BBZ,           /* 15 备注 */
        CJRQ,          /* 16 采集日期 */
        GSFZJG,        /* DDL缺口字段，置NULL */
        SENSITIVEFLAG,  /* DDL缺口字段，置NULL */
        KHLB            /* DDL缺口字段，置NULL */
    )
    SELECT
        /*  1 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；介质协议表.机构ID 关联 机构信息表.机构ID */
        s6.A010003 AS JRXKZH,
        /*  2 内部机构号：介质协议表.机构ID -> T_6_28.F280001；从第12位开始截取 */
        SUBSTR(TRIM(src.F280001), 12) AS NBJGH,
        /*  3 客户统一编号：介质协议表.客户ID -> T_6_28.F280002 */
        src.F280002 AS KHTYBH,
        /*  4 客户名称：优先取EAST个人基础信息表，取不到取EAST对公客户信息表 */
        COALESCE(per.KHXM, corp.KHMC) AS KHMC,
        /*  5 证件类别：优先取EAST个人基础信息表，取不到取EAST对公客户信息表 */
        COALESCE(per.ZJLB, corp.ZJLB) AS ZJLB,
        /*  6 证件号码：优先取EAST个人基础信息表，取不到取EAST对公客户信息表 */
        COALESCE(per.ZJHM, corp.ZJHM) AS ZJHM,
        /*  7 卡号：介质协议表.介质号 -> T_6_28.F280005 */
        src.F280005 AS KH,
        /*  8 活期存款账号：介质协议表.分户账号 -> T_6_28.F280003 */
        src.F280003 AS HQCKZH,
        /*  9 借记卡产品名称：卡产品.产品名称 -> T_5_6.E060003；通过卡产品ID关联 */
        card.E060003 AS JJKCPMC,
        /* 10 虚拟卡标志：介质协议表.虚拟卡标识 -> T_6_28.F280007；0否，1是 */
        CASE
            WHEN src.F280007 = '1' THEN '是'
            WHEN src.F280007 = '0' THEN '否'
            ELSE NULL
        END AS XNKBZ,
        /* 11 员工卡标志：介质协议表.员工标志 -> T_6_28.F280008；0否，1是 */
        CASE
            WHEN src.F280008 = '1' THEN '是'
            WHEN src.F280008 = '0' THEN '否'
            ELSE NULL
        END AS YGKBZ,
        /* 12 开卡日期：介质协议表.介质启用日期 -> T_6_28.F280009；YYYY-MM-DD转YYYYMMDD */
        TO_CHAR(src.F280009, 'YYYYMMDD') AS KKRQ,
        /* 13 开卡柜员号：介质协议表.介质启用柜员ID -> T_6_28.F280011；如为"自动"则置空 */
        CASE WHEN src.F280011 = '自动' THEN NULL ELSE src.F280011 END AS KKGYH,
        /* 14 卡片状态：介质协议表.介质状态 -> T_6_28.F280012；码值转换 */
        CASE
            WHEN src.F280012 = '01' THEN '未激活'
            WHEN src.F280012 = '02' THEN '正常'
            WHEN src.F280012 = '03' THEN '注销'
            WHEN src.F280012 = '04' THEN '冻结'
            WHEN src.F280012 = '05' THEN '睡眠'
            WHEN src.F280012 = '06' THEN '挂失'
            WHEN src.F280012 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(src.F280012, 4))
            WHEN src.F280012 LIKE '00%' THEN CONCAT('其他-', SUBSTR(src.F280012, 3))
            ELSE NULL
        END AS KPZT,
        /* 15 备注：介质协议表备注和卡产品备注以英文分号拼接 */
        TRIM(BOTH ';' FROM CONCAT(
            COALESCE(NULLIF(TRIM(src.F280013), ''), ''),
            CASE
                WHEN NULLIF(TRIM(src.F280013), '') IS NOT NULL
                 AND NULLIF(TRIM(card.E060016), '') IS NOT NULL
                THEN ';' ELSE '' END,
            COALESCE(NULLIF(TRIM(card.E060016), ''), '')
        )) AS BBZ,
        /* 16 采集日期：参数 P_DATA_DATE */
        P_DATA_DATE AS CJRQ,
        /* 归属分支机构：业务需求未给来源，置NULL */
        NULL AS GSFZJG,
        /* 涉密标志：业务需求未给来源，置NULL */
        NULL AS SENSITIVEFLAG,
        /* 客户类别：业务需求未给来源，置NULL */
        NULL AS KHLB
    FROM T_6_28 src
    LEFT JOIN T_1_1 s6
           ON src.F280001 = s6.A010001
          AND s6.A010020 = V_DATA_DATE
    LEFT JOIN T_5_6 card
           ON src.F280004 = card.E060001
          AND card.E060017 = V_DATA_DATE
    LEFT JOIN IE_002_201 per
           ON src.F280002 = per.KHTYBH
          AND per.CJRQ = P_DATA_DATE
    LEFT JOIN IE_002_203 corp
           ON src.F280002 = corp.KHTYBH
          AND corp.CJRQ = P_DATA_DATE
    WHERE src.F280014 = V_DATA_DATE
      /* 筛选介质类型为 01-卡、07-卡折合一 */
      AND (
            src.F280006 IN ('01', '01-卡', '07', '07-卡折合一')
         OR src.F280006 LIKE '01-%'
         OR src.F280006 LIKE '07-%'
      )
      /* 包含失效日期为空或大于等于当月月初的介质 */
      AND (src.F280010 IS NULL OR src.F280010 >= V_MON_START)
      /* 排除上月及以前已注销的卡 */
      AND NOT (
            src.F280012 IN ('03', '03-注销')
        AND src.F280010 IS NOT NULL
        AND src.F280010 < V_MON_START
      );

    COMMIT;
END;
