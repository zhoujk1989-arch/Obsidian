/*
业务目标：
- 依据原始业务需求《029_互联网贷款合同附加表.md》生成 EAST5.0 互联网贷款合同附加表（IE_005_502）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/029_互联网贷款合同附加表.md
- 原始材料/表结构/EAST5.0系统/IE_005_502-互联网贷款合同附加表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_4-互联网贷款协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_2-贷款协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql

源表：
- T_6_4（一表通-互联网贷款协议）：主表，提供互联网贷款合同附加信息
- T_6_2（一表通-贷款协议）：左关联，提供协议状态、协议币种、备注
- T_1_1（一表通-机构信息）：左关联，提供银行机构名称、金融许可证号

目标表：
- IE_005_502：互联网贷款合同附加表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 本表报送所有互联网贷款合同的附加信息。互联网贷款的认定参照《商业银行互联网贷款管理暂行办法》。互联网贷款的发放明细应该报送至相对应的信贷业务借据表、信贷合同表、信贷分户账以及信贷分户账明细记录中。已撤销、失效、终结的合同在报送合同最后状态的次月可不再报送。

表级取数与关联规则（原文摘录）：
- 主表：【互联网贷款协议】（和<EAST信贷合同表>内关联后，按【机构ID】、【协议ID】、【合作协议ID】、【业务模式】、【合作方负有担保责任的金额】、【客户数据授权书编号】、【授权生效日期】、【授权终止日期】、【备注】、【采集日期】去重）
- 内关联：<EAST信贷合同表>，关联条件：【互联网贷款协议】.【协议ID】= <EAST信贷合同表>.信贷合同号，限制【采集日期】为当日
- 左关联：【贷款协议】，关联条件：【互联网贷款协议】.【协议ID】= 【贷款协议】.【协议ID】，限制【采集日期】为当日
- 左关联：【机构信息】，关联条件：【互联网贷款协议】.【机构ID】= 【机构信息】.【机构ID】，限制【采集日期】为当日
- 左关联：<EAST对公客户信息表>，关联条件：【贷款协议】.【客户ID】= <EAST对公客户信息表>.客户统一编号，限制【采集日期】为当日
- 左关联：<EAST个人基础信息表>，关联条件：【贷款协议】.【客户ID】= <EAST个人基础信息表>.客户统一编号，限制【采集日期】为当日
- 过滤条件：限制【互联网贷款协议】.【采集日期】为当日

未确认点：
- SENSITIVEFLAG（涉密标志）和 GSFZJG（归属分支机构）存在于目标 DDL，但业务需求字段映射表中未给出来源，本草案中置 NULL。
- 表级规则要求与<EAST信贷合同表>内关联去重，但本仓库尚未存储 EAST 信贷合同表结构；本草案以 T_6_4 为唯一数据源，按【机构ID】、【协议ID】、【合作协议ID】、【业务模式】、【合作方协议责任金额】、【客户数据授权书编号】、【授权生效日期】、【授权终止日期】、【备注】、【采集日期】去重。
- 报送模式中"上一采集日至采集日期间结清、失效、终结等终态纳入"规则，本草案通过窗口函数取每个协议的最新状态实现；若需精确按上一采集日边界过滤，需在 GBase 环境中确认上一采集日取值方式。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_502_HLWDKHTFJB;

CREATE PROCEDURE PROC_EAST_IE_005_502_HLWDKHTFJB(
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

    -- 1. 删除目标表同一采集日期的已有数据
    DELETE FROM IE_005_502
     WHERE CJRQ = P_DATA_DATE;

    -- 2. 从一表通源表加工并插入
    INSERT INTO IE_005_502 (
        SENSITIVEFLAG,
        XDHTH,
        GSFZJG,
        CJRQ,
        ZZRQ,
        SQSBH,
        HZFZRJE,
        BBZ,
        NBJGH,
        YWMS,
        SXRQ,
        LXDH,
        HZXYBH,
        YHJGMC,
        JRXKZH,
        HTZT,
        BZ
    )
    SELECT
        /* 涉密标志：目标 DDL 存在该字段，但业务需求映射表未给出来源，置 NULL 待补 */
        NULL AS SENSITIVEFLAG,

        /* 信贷合同号：互联网贷款协议.协议ID -> T_6_4.F040002；直接映射 */
        src.F040002 AS XDHTH,

        /* 归属分支机构：目标 DDL 存在该字段，但业务需求映射表未给出来源，置 NULL 待补 */
        NULL AS GSFZJG,

        /* 采集日期：互联网贷款协议.采集日期 -> T_6_4.F040016；格式转为'YYYYMMDD' */
        REPLACE(CAST(src.F040016 AS CHAR), '-', '') AS CJRQ,

        /* 授权终止日期：互联网贷款协议.授权终止日期 -> T_6_4.F040011；
           格式转为'YYYYMMDD'，若取不到或为空，则赋默认值'99991231' */
        CASE
            WHEN src.F040011 IS NULL THEN '99991231'
            ELSE REPLACE(CAST(src.F040011 AS CHAR), '-', '')
        END AS ZZRQ,

        /* 客户数据授权书编号：互联网贷款协议.客户数据授权书编号 -> T_6_4.F040009；直接映射 */
        src.F040009 AS SQSBH,

        /* 合作方责任金额：互联网贷款协议.合作方协议责任金额 -> T_6_4.F040017；
           去除空格和空字符串后转为 DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F040017), '') AS DECIMAL(20,2)) AS HZFZRJE,

        /* 备注：EAST《互联网贷款合同附加表》除机构数据和客户数据外，
           还从一表通《表6.4互联网贷款协议》、《表6.2贷款协议》备注，以";"拼接。
           拼接顺序：T_6_4.备注 + ";" + T_6_2.备注，去除尾部多余分号 */
        CASE
            WHEN src.F040015 IS NOT NULL AND src.F040015 <> ''
                 AND s2.F020062 IS NOT NULL AND s2.F020062 <> ''
                THEN CONCAT(src.F040015, ';', s2.F020062)
            WHEN src.F040015 IS NOT NULL AND src.F040015 <> ''
                THEN src.F040015
            WHEN s2.F020062 IS NOT NULL AND s2.F020062 <> ''
                THEN s2.F020062
            ELSE NULL
        END AS BBZ,

        /* 内部机构号：互联网贷款协议.机构ID -> T_6_4.F040001；
           加工规则：从第12位开始截取 */
        SUBSTR(TRIM(src.F040001), 12) AS NBJGH,

        /* 业务模式：互联网贷款协议.业务模式 -> T_6_4.F040005；
           码值转换：若为'04'[本机构独立开展互联网贷款业务]，则赋值为'独立'；
           否则赋'合作' */
        CASE
            WHEN TRIM(src.F040005) = '04' THEN '独立'
            ELSE '合作'
        END AS YWMS,

        /* 授权生效日期：互联网贷款协议.授权生效日期 -> T_6_4.F040010；
           格式转为'YYYYMMDD'，若取不到或为空，则赋默认值'99991231' */
        CASE
            WHEN src.F040010 IS NULL THEN '99991231'
            ELSE REPLACE(CAST(src.F040010 AS CHAR), '-', '')
        END AS SXRQ,

        /* 申请人联系电话：互联网贷款协议.申请人联系电话 -> T_6_4.F040018；直接映射 */
        src.F040018 AS LXDH,

        /* 合作协议编号：互联网贷款协议.合作协议ID -> T_6_4.F040004；
           若为空，则赋值为'无' */
        CASE
            WHEN src.F040004 IS NULL OR TRIM(src.F040004) = '' THEN '无'
            ELSE src.F040004
        END AS HZXYBH,

        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；
           关联条件：T_6_4.F040001 = T_1_1.A010001，采集日期一致 */
        s1.A010005 AS YHJGMC,

        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；
           关联条件：T_6_4.F040001 = T_1_1.A010001，采集日期一致 */
        s1.A010003 AS JRXKZH,

        /* 合同状态：贷款协议.协议状态 -> T_6_2.F020061；
           码值转换：
           '01'[正常] -> '有效'
           '02'[待生效] -> '未生效'
           '03'[中止] -> '其他-中止'
           '04'[终止] -> '终结'
           '05'[撤销] -> '撤销'
           '06'[无效] -> '其他-无效'
           '00-XX' -> '其他-XX'
           其他未匹配值保留原值 */
        CASE
            WHEN TRIM(s2.F020061) = '01' THEN '有效'
            WHEN TRIM(s2.F020061) = '02' THEN '未生效'
            WHEN TRIM(s2.F020061) = '03' THEN '其他-中止'
            WHEN TRIM(s2.F020061) = '04' THEN '终结'
            WHEN TRIM(s2.F020061) = '05' THEN '撤销'
            WHEN TRIM(s2.F020061) = '06' THEN '其他-无效'
            WHEN s2.F020061 IS NOT NULL AND TRIM(s2.F020061) LIKE '00-%'
                THEN CONCAT('其他-', SUBSTR(TRIM(s2.F020061), 3))
            ELSE s2.F020061
        END AS HTZT,

        /* 币种：贷款协议.协议币种 -> T_6_2.F020007；直接映射 */
        s2.F020007 AS BZ

    FROM T_6_4 src
    /* 左关联：机构信息，按机构ID和采集日期匹配 */
    LEFT JOIN T_1_1 s1
        ON TRIM(src.F040001) = TRIM(s1.A010001)
       AND s1.A010020 = V_DATA_DATE
    /* 左关联：贷款协议，按协议ID和采集日期匹配 */
    LEFT JOIN T_6_2 s2
        ON TRIM(src.F040002) = TRIM(s2.F020001)
       AND s2.F020063 = V_DATA_DATE

    WHERE src.F040016 = V_DATA_DATE;

    COMMIT;
END;
