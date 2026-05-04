/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

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

源表：
- T_6_4, T_1_1, T_6_2

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
### 2.1 表级规则（Excel第 634 行） 主表：【互联网贷款协议】（和<EAST信贷合同表>内关联后，按【机构ID】、【协议ID】、【合作协议ID】、【业务模式】、【合作方负有担保责任的金额】、【客户数据授权书编号】、【授权生效日期】、【授权终止日期】、【备注】、【采集日期】 去重） 内关联：<EAST信贷合同表> 关联条件 : 【互联网贷款协议】.【协议ID】= <EAST信贷合同表> .信贷合同号。限制【采集日期】为当日 左关联：【贷款协议】 关联条件 : 【互联网贷款协议】.【协议ID】= 【贷款协议】 .【协议ID】。限制【采集日期】为当日 左关联：【机构信息】 关联条件 : 【互联网贷款协议】.【机构ID】= 【机构信息】.【机构ID】。限制【采集日期】为当日 左关联：<EAST对公客户信息表> 关联条件：【贷款协议】 .【客户ID】 = <EAST对公客户信息表> .客户统一编号。限制【采集日期】为当日 左关联：<EAST个人基础信息表> 关联条件：【贷款协议】 .【客户ID】 = <EAST个人基础信息表> .客户统一编号。限制【采集日期】为当日 过滤条件：限制【互联网贷款协议】.【采集日期】为当日

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
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

    DELETE FROM IE_005_502
     WHERE CJRQ = P_DATA_DATE;

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
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 信贷合同号：互联网贷款协议.协议ID -> T_6_4.F040002；直接映射 */
        src.F040002 AS XDHTH,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 采集日期：互联网贷款协议.采集日期 -> T_6_4.F040016；格式转换：格式转为'YYYYMMDD'。 */
        CONCAT(CAST(YEAR(src.F040016) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F040016) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F040016) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 授权终止日期：互联网贷款协议.授权终止日期 -> T_6_4.F040011；格式转换：转字符格式'YYYYMMDD'，若取不到或为空，则赋默认值99991231。 */
        CASE WHEN src.F040011 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.F040011) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F040011) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F040011) AS VARCHAR(2)), 2, '0')) END AS ZZRQ,
        /* 客户数据授权书编号：互联网贷款协议.客户数据授权书编号 -> T_6_4.F040009；直接映射 */
        src.F040009 AS SQSBH,
        /* 合作方责任金额：互联网贷款协议.合作方协议责任金额 -> T_6_4.F040017；直接映射 */
        CAST(NULLIF(TRIM(src.F040017), '') AS DECIMAL(20,2)) AS HZFZRJE,
        /* 备注：互联网贷款协议.备注 -> T_6_4.F040015；EAST《互联网贷款合同附加表》除机构数据和客户数据外，还从一表通《表6.4互联网贷款协议》、《表6.2贷款协议》备注，以“;”拼接。 */
        src.F040015 AS BBZ,
        /* 内部机构号：互联网贷款协议.机构ID -> T_6_4.F040001；加工规则：从【互联网贷款协议】.【机构ID】第12位开始截取。 */
        SUBSTR(TRIM(src.F040001), 12) AS NBJGH,
        /* 业务模式：互联网贷款协议.业务模式 -> T_6_4.F040005；加工规则：若【互联网贷款协议】.【业务模式】为'04'[本机构独立开展互联网贷款业务]，则赋值为'独立'；否则赋'合作'。 */
        src.F040005 AS YWMS,
        /* 授权生效日期：互联网贷款协议.授权生效日期 -> T_6_4.F040010；格式转换：转字符格式'YYYYMMDD'，若取不到或为空，则赋默认值99991231。 */
        CASE WHEN src.F040010 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.F040010) AS VARCHAR(4)), LPAD(CAST(MONTH(src.F040010) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.F040010) AS VARCHAR(2)), 2, '0')) END AS SXRQ,
        /* 申请人联系电话：互联网贷款协议.申请人联系电话 -> T_6_4.F040018；直接映射 */
        src.F040018 AS LXDH,
        /* 合作协议编号：互联网贷款协议.合作协议ID -> T_6_4.F040004；加工规则：取【互联网贷款协议】.【合作协议ID】；若为空，则赋值为'无'。 */
        src.F040004 AS HZXYBH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；加工规则：用【互联网贷款协议】.【机构ID】关联【机构信息】.【机构ID】，取【机构信息】.【银行机构名称】 */
        s1.A010005 AS YHJGMC,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工规则：用【互联网贷款协议】.【机构ID】关联【机构信息】.【机构ID】，取【机构信息】.【金融许可证号】 */
        s1.A010003 AS JRXKZH,
        /* 合同状态：贷款协议.协议状态 -> T_6_2.F020061；代码转化： 用【互联网贷款协议】.【协议ID】关联【贷款协议】.【协议ID】，取【贷款协议】.【合同状态】进行代码转化： 若为'01'[正常],则赋值为'有效'; 若为'02'[待生效],则赋值为'未生效'; 若为'03'[中止],则赋值为'其他-中止'; 若为'04'[终止],则赋值为'终结'; 若为'05'[撤销],则赋值为'撤销'; 若为'06'[无效],则赋值为'其他-无效'; 若为'00-XX',则赋值为'其他-XX'。；转换规则需人工补齐 CASE 分支 */
        s2.F020061 AS HTZT,
        /* 币种：贷款协议.协议币种 -> T_6_2.F020007；加工规则：用【互联网贷款协议】.【协议ID】关联【贷款协议】.【协议ID】，取【贷款协议】.【协议币种】 */
        s2.F020007 AS BZ
    FROM T_6_4 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_6_2 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《029_互联网贷款合同附加表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
