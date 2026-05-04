/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《051_信用卡授信情况表.md》生成 EAST5.0 信用卡授信情况表（IE_008_803）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/051_信用卡授信情况表.md
- 原始材料/表结构/EAST5.0系统/IE_008_803-信用卡授信情况表-DDL-2026-04-28.sql

源表：
- T_6_9, T_8_4, T_1_1

目标表：
- IE_008_803：信用卡授信情况表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 报送信用卡持卡人当月授信情况。客户额度按同一账户下的总额度报送，不以单张信用卡额度报送。对主副卡客户（一账户多个客户）的情况，本表只报送主卡人的授信信息。同一客户多个账户的，按多条分别报送。同一账户多个币种共享额度的，按记账币种统一折算填报。状态为“销户”的账户在报送最后状态的次月可不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1221 行） 取未失效及失效日期在当月的账户

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_008_803_XYKSXQKB;

CREATE PROCEDURE PROC_EAST_IE_008_803_XYKSXQKB(
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

    DELETE FROM IE_008_803
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_008_803 (
        YQRQ,
        YSXF,
        BYLJQXZZJE,
        BYLJSR,
        YYTHSXJE,
        BBZ,
        CJRQ,
        KHLB,
        YQJE,
        BYLJXFJE,
        NBJGH,
        XZSXLX,
        YHJGMC,
        KHMC,
        ZHZT,
        ZHYE,
        DQSXED,
        QZFQYE,
        DJYE,
        GSFZJG,
        JRXKZH,
        KHTYBH,
        ZJLB,
        ZJHM,
        XYKZH,
        BZ,
        ZSXEDSX,
        YJXJSXED,
        ZJSXPGRQ,
        TZJE,
        QZLSED,
        WJFL,
        ZXZJCXRQ,
        DQSXYE,
        DYLJJYBS,
        DYLJTZJE,
        BYLJFQJYJE,
        YYXYKFKHS,
        ZJXZSXRQ,
        CSBZ,
        CSFS,
        SENSITIVEFLAG
    )
    SELECT
        /* 逾期日期：信用卡账户状态.逾期起始日期 -> T_8_4.H040031；加工映射：取【信用卡账户状态】.【逾期起始日期】并转换成'YYYYMMDD'格式 */
        CONCAT(CAST(YEAR(s1.H040031) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.H040031) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.H040031) AS VARCHAR(2)), 2, '0')) AS YQRQ,
        /* 应收息费：信用卡账户状态.应收息费 -> T_8_4.H040010；直接映射 */
        CAST(NULLIF(TRIM(s1.H040010), '') AS DECIMAL(20,2)) AS YSXF,
        /* 本月累计取现转账金额：信用卡账户状态.本月累计取现转账金额 -> T_8_4.H040022；直接映射 */
        CAST(NULLIF(TRIM(s1.H040022), '') AS DECIMAL(20,2)) AS BYLJQXZZJE,
        /* 本月累计收入：信用卡账户状态.本月累计收入 -> T_8_4.H040024；直接映射 */
        CAST(NULLIF(TRIM(s1.H040024), '') AS DECIMAL(20,2)) AS BYLJSR,
        /* 已有他行授信金额：信用卡账户状态.已有他行授信金额 -> T_8_4.H040027；直接映射 */
        CAST(NULLIF(TRIM(s1.H040027), '') AS DECIMAL(20,2)) AS YYTHSXJE,
        /* 备注：信用卡账户状态.备注 -> T_8_4.H040042；直接映射 */
        s1.H040042 AS BBZ,
        /* 采集日期：待确认来源字段：/./ */
        NULL AS CJRQ,
        /* 客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS KHLB,
        /* 逾期金额：信用卡账户状态.逾期金额 -> T_8_4.H040012；直接映射 */
        CAST(NULLIF(TRIM(s1.H040012), '') AS DECIMAL(20,2)) AS YQJE,
        /* 本月累计消费金额：信用卡账户状态.本月累计消费金额 -> T_8_4.H040021；直接映射 */
        CAST(NULLIF(TRIM(s1.H040021), '') AS DECIMAL(20,2)) AS BYLJXFJE,
        /* 内部机构号：待确认来源字段：信用卡账户状态.机构id */
        NULL AS NBJGH,
        /* 新增授信类型：信用卡账户状态.新增授信类型 -> T_8_4.H040030；加工映射：【信用卡账户状态】.【新增授信类型】按以下映射关系赋值 【新增授信类型】 = '01' 赋值 '新发卡授信' 【新增授信类型】 = '02' 赋值 '固定额度上调' 【新增授信类型】 = '03' 赋值 '专项分期额度上调' 【新增授信类型】 = '00-XX' 赋值 '其他-XX' */
        s1.H040030 AS XZSXLX,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；加工映射：从第12位开始截取【信用卡账户状态】的【机构id】，关联【机构信息】的【内部机构号】取【银行机构名称】 */
        SUBSTR(TRIM(s2.A010005), 12) AS YHJGMC,
        /* 客户名称：待确认来源字段：一表通转出的EAST对公客户信息表\.个人基础信息表 */
        NULL AS KHMC,
        /* 账户状态：信用卡账户状态.账户状态 -> T_8_4.H040037；加工映射：取【信用卡账户状态】.【账户状态】按以下转换方式转换 '01' 转为'正常' '02' 转为'预销户' '03' 转为'销户' '04' 转为'冻结' '05' 转为'止付' '00-XX' 转为'其他-XX'；转换规则需人工补齐 CASE 分支 */
        s1.H040037 AS ZHZT,
        /* 账户余额：信用卡账户状态.账户余额 -> T_8_4.H040011；直接映射 */
        CAST(NULLIF(TRIM(s1.H040011), '') AS DECIMAL(20,2)) AS ZHYE,
        /* 当前授信额度：待确认来源字段：信用卡账户状态.当前本币授信额度\ */
        NULL AS DQSXED,
        /* 其中分期余额：信用卡账户状态.分期余额 -> T_8_4.H040039；直接映射 */
        CAST(NULLIF(TRIM(s1.H040039), '') AS DECIMAL(20,2)) AS QZFQYE,
        /* 冻结金额：信用卡账户状态.冻结金额 -> T_8_4.H040018；直接映射 */
        CAST(NULLIF(TRIM(s1.H040018), '') AS DECIMAL(20,2)) AS DJYE,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工映射：从第12位开始截取【信用卡账户状态】的【机构id】，关联【机构信息】的【内部机构号】取【金融许可证号】 */
        SUBSTR(TRIM(s2.A010003), 12) AS JRXKZH,
        /* 客户统一编号：信用卡账户状态.客户ID -> T_8_4.H040001；直接映射 */
        s1.H040001 AS KHTYBH,
        /* 证件类别：待确认来源字段：一表通转出的EAST对公客户信息表\.个人基础信息表 */
        NULL AS ZJLB,
        /* 证件号码：待确认来源字段：一表通转出的EAST对公客户信息表\.个人基础信息表 */
        NULL AS ZJHM,
        /* 信用卡账号：信用卡账户状态.信用卡账号 -> T_8_4.H040003；直接映射 */
        s1.H040003 AS XYKZH,
        /* 币种：信用卡账户状态.币种 -> T_8_4.H040013；直接映射 */
        s1.H040013 AS BZ,
        /* 总授信额度上限：信用卡协议.总授信额度上限 -> T_6_9.F090018；【8.4信用卡账户状态】的信用卡账号关联【6.9信用卡协议】的信用卡账号，取【信用卡协议】.【附属卡标识】='0'时的【总授信额度上限】 */
        CAST(NULLIF(TRIM(src.F090018), '') AS DECIMAL(20,2)) AS ZSXEDSX,
        /* 预借现金授信额度：待确认来源字段：信用卡账户状态.本币现金支取额度\ */
        NULL AS YJXJSXED,
        /* 最近授信评估日期：信用卡账户状态.最近授信评估日期 -> T_8_4.H040032；加工映射：取【信用卡账户状态】.【最近授信评估日期】并转换成'YYYYMMDD'格式 */
        CONCAT(CAST(YEAR(s1.H040032) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.H040032) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.H040032) AS VARCHAR(2)), 2, '0')) AS ZJSXPGRQ,
        /* 透支金额：信用卡账户状态.透支金额 -> T_8_4.H040038；直接映射 */
        CAST(NULLIF(TRIM(s1.H040038), '') AS DECIMAL(20,2)) AS TZJE,
        /* 其中临时额度：待确认来源字段：信用卡账户状态.其中本币临时额度\ */
        NULL AS QZLSED,
        /* 五级分类：信用卡账户状态.五级分类 -> T_8_4.H040015；加工映射：取五级分类，并按以下转码： 1、'01' 转为 '正常' 2、'02' 转为 '关注' 3、'03' 转为 '次级' 4、'04' 转为 '可疑' 5、'05 转为 '损失' */
        s1.H040015 AS WJFL,
        /* 最近征信查询日期：信用卡账户状态.最近征信查询日期 -> T_8_4.H040033；加工映射：取【信用卡账户状态】.【最近征信查询日期】并转换成'YYYYMMDD'格式 */
        CONCAT(CAST(YEAR(s1.H040033) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.H040033) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.H040033) AS VARCHAR(2)), 2, '0')) AS ZXZJCXRQ,
        /* 当前授信余额：待确认来源字段：信用卡账户状态.当前本币授信额度\ */
        NULL AS DQSXYE,
        /* 当月累计交易笔数：信用卡账户状态.当月累计交易笔数 -> T_8_4.H040019；直接映射 */
        CAST(NULLIF(TRIM(s1.H040019), '') AS DECIMAL(20,2)) AS DYLJJYBS,
        /* 当月累计透支金额：信用卡账户状态.当月累计透支金额 -> T_8_4.H040020；直接映射 */
        CAST(NULLIF(TRIM(s1.H040020), '') AS DECIMAL(20,2)) AS DYLJTZJE,
        /* 本月累计分期交易金额：信用卡账户状态.本月累计分期交易金额 -> T_8_4.H040023；直接映射 */
        CAST(NULLIF(TRIM(s1.H040023), '') AS DECIMAL(20,2)) AS BYLJFQJYJE,
        /* 已有信用卡发卡银行数：信用卡账户状态.已有信用卡发卡银行数 -> T_8_4.H040026；直接映射 */
        CAST(NULLIF(TRIM(s1.H040026), '') AS DECIMAL(20,2)) AS YYXYKFKHS,
        /* 最近新增授信日期：信用卡账户状态.最近新增授信日期 -> T_8_4.H040034；加工映射：取【信用卡账户状态】.【最近新增授信日期】并转换成'YYYYMMDD'格式 */
        CONCAT(CAST(YEAR(s1.H040034) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.H040034) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.H040034) AS VARCHAR(2)), 2, '0')) AS ZJXZSXRQ,
        /* 催收标志：信用卡账户状态.催收标识 -> T_8_4.H040028；加工映射：遍历一表通当月每日催收标识的报送值，报送过“是”则转换结果为“是”，全部为“否”则转换结果为“否”；转换规则需人工补齐 CASE 分支 */
        s1.H040028 AS CSBZ,
        /* 催收方式：信用卡账户状态.催收方式 -> T_8_4.H040029；加工映射： 遍历一表通当月每日催收方式的报送值，去重后拼接在一起，最后按如下转码，同时存在多种催收方式的，以英文半角分号分隔填报： 若【催收方式】 ='01' 则赋值 '电话催收' 若【催收方式】 ='02' 则赋值 '信函催收' 若【催收方式】 ='03' 则赋值 '外访催收' 若【催收方式】 ='04' 则赋值 '司法催收' 若【催收方式】 ='05' 则赋值 '其他-委外催收' 若【催收方式】 ='00-XX' 则赋值 '其他-X... */
        s1.H040029 AS CSFS,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG
    FROM T_6_9 src
    LEFT JOIN T_8_4 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_1_1 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《051_信用卡授信情况表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
