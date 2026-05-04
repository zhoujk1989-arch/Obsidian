/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《052_信用卡分期业务表.md》生成 EAST5.0 信用卡分期业务表（IE_008_804_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/052_信用卡分期业务表.md
- 原始材料/表结构/EAST5.0系统/IE_008_804_INC-信用卡分期业务表-DDL-2026-04-28.sql

源表：
- T_8_5, T_8_4, T_1_1

目标表：
- IE_008_804_INC：信用卡分期业务表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 填报每月新增的持卡人分期业务情况。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1261 行） 取分期办理日期在当月的

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_008_804_INC_XYKFQYWB;

CREATE PROCEDURE PROC_EAST_IE_008_804_INC_XYKFQYWB(
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

    DELETE FROM IE_008_804_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_008_804_INC (
        JRXKZH,
        SENSITIVEFLAG,
        ZJLB,
        ZJHM,
        XYKZH,
        FQYWLX,
        FQZED,
        FQZRKH,
        FQLL,
        FQQS,
        CJRQ,
        KHLB,
        GSFZJG,
        KYFQED,
        KHMC,
        FQZRKHLB,
        NBJGH,
        FQYWBH,
        KHTYBH,
        FQJYLX,
        BLFQRQ,
        BZ,
        FQJE,
        FQZRHM,
        BBZ,
        BLFQSJ,
        GXHFQBZ,
        YHJGMC
    )
    SELECT
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工映射：用【信用卡分期状态】.【信用卡账号】关联【信用卡账户状态】.【信用卡账号】取【信用卡账户状态】.【机构ID】，然后从第12位开始截取至最后，关联【机构信息】的【内部机构号】取【金融许可证号】 */
        SUBSTR(TRIM(s2.A010003), 12) AS JRXKZH,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 证件类别：待确认来源字段：一表通转出的EAST对公客户信息表\.个人基础信息表 */
        NULL AS ZJLB,
        /* 证件号码：待确认来源字段：一表通转出的EAST对公客户信息表\.个人基础信息表 */
        NULL AS ZJHM,
        /* 信用卡账号：信用卡分期状态.信用卡账号 -> T_8_5.H050024；直接映射 */
        src.H050024 AS XYKZH,
        /* 分期业务类型：信用卡分期状态.分期业务类型 -> T_8_5.H050006；加工映射：'01'转成'账单分期'，'02'转成'单笔消费分期'，'03'转成'现金分期'，'04'转成'POS商户分期'，'05'转成'邮购电购分期'，'06'转成'汽车分期'，'07'转成'家装分期'，'08'转成'车位分期'，'09'转成'教育分期'，'10'转成'婚庆分期'，'00-XX'的转成'其他-XX' */
        src.H050006 AS FQYWLX,
        /* 分期总额度：信用卡分期状态.分期总额度 -> T_8_5.H050008；直接映射 */
        CAST(NULLIF(TRIM(src.H050008), '') AS DECIMAL(20,2)) AS FQZED,
        /* 分期转入卡号：信用卡分期状态.分期转入卡号 -> T_8_5.H050015；直接映射 */
        src.H050015 AS FQZRKH,
        /* 分期利率：信用卡分期状态.分期利率 -> T_8_5.H050012；直接映射 */
        CAST(NULLIF(TRIM(src.H050012), '') AS DECIMAL(20,6)) AS FQLL,
        /* 分期期数：信用卡分期状态.分期期数 -> T_8_5.H050011；直接映射 */
        src.H050011 AS FQQS,
        /* 采集日期：待确认来源字段：/./ */
        NULL AS CJRQ,
        /* 客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS KHLB,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 可用分期额度：信用卡分期状态.可用分期额度 -> T_8_5.H050009；直接映射 */
        CAST(NULLIF(TRIM(src.H050009), '') AS DECIMAL(20,2)) AS KYFQED,
        /* 客户名称：待确认来源字段：一表通转出的EAST对公客户信息表\.个人基础信息表 */
        NULL AS KHMC,
        /* 分期转入客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS FQZRKHLB,
        /* 内部机构号：信用卡账户状态.机构ID -> T_8_4.H040043；加工映射：用【信用卡分期状态】.【信用卡账号】关联【信用卡账户状态】.【信用卡账号】取【信用卡账户状态】.【机构ID】，从第12位开始截取至最后 */
        SUBSTR(TRIM(s1.H040043), 12) AS NBJGH,
        /* 分期业务编号：信用卡分期状态.分期业务ID -> T_8_5.H050001；直接映射 */
        src.H050001 AS FQYWBH,
        /* 客户统一编号：信用卡分期状态.客户ID -> T_8_5.H050004；直接映射 */
        src.H050004 AS KHTYBH,
        /* 分期交易类型：信用卡分期状态.分期交易类型 -> T_8_5.H050005；加工映射：'01'转成'普通分期总额'，'02'转成'普通分期单笔'，'03'转成'专项分期总额'，'04'转成'专项分期单笔'，'05'转成'现金分期总额'，'06'转成'现金分期单笔'，'00-XX'转成'其他-XX' */
        src.H050005 AS FQJYLX,
        /* 办理分期日期：信用卡分期状态.办理分期日期 -> T_8_5.H050013；加工映射：数据格式转成YYYYMMDD */
        CONCAT(CAST(YEAR(src.H050013) AS VARCHAR(4)), LPAD(CAST(MONTH(src.H050013) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.H050013) AS VARCHAR(2)), 2, '0')) AS BLFQRQ,
        /* 币种：信用卡分期状态.币种 -> T_8_5.H050007；直接映射 */
        src.H050007 AS BZ,
        /* 分期金额：信用卡分期状态.分期金额 -> T_8_5.H050010；直接映射 */
        CAST(NULLIF(TRIM(src.H050010), '') AS DECIMAL(20,2)) AS FQJE,
        /* 分期转入户名：信用卡分期状态.分期转入户名 -> T_8_5.H050020；直接映射 */
        src.H050020 AS FQZRHM,
        /* 备注：信用卡分期状态.备注 -> T_8_5.H050023；直接映射 */
        src.H050023 AS BBZ,
        /* 办理分期时间：信用卡分期状态.办理分期时间 -> T_8_5.H050014；加工映射：删除":"，将数据格式转成HHMMSS */
        src.H050014 AS BLFQSJ,
        /* 个性化分期标志：信用卡分期状态.个性化分期标识 -> T_8_5.H050016；加工映射：'1'转为'是'，其他转为'否' */
        src.H050016 AS GXHFQBZ,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；加工映射：用【信用卡分期状态】.【信用卡账号】关联【信用卡账户状态】.【信用卡账号】取【信用卡账户状态】.【机构ID】，然后从第12位开始截取至最后，关联【机构信息】的【内部机构号】取【银行机构名称】 */
        SUBSTR(TRIM(s2.A010005), 12) AS YHJGMC
    FROM T_8_5 src
    LEFT JOIN T_8_4 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_1_1 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《052_信用卡分期业务表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
