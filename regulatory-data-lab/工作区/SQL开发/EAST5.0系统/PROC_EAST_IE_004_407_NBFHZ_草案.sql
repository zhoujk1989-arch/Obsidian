/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《022_内部分户账.md》生成 EAST5.0 内部分户账（IE_004_407）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/022_内部分户账.md
- 原始材料/表结构/EAST5.0系统/IE_004_407-内部分户账-DDL-2026-04-28.sql

源表：
- T_4_3, T_1_1, T_4_2

目标表：
- IE_004_407：内部分户账。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 根据会计核算科目，除单列账之外的科目原则上都归入内部账采集；单列账报送至信用卡、对公/个人等分户账中；资本账户需要报送。以内部分户账号为最小颗粒报送，如账户注销或终结，在报送该账户最终状态后的次月可不再报送。交易与核算分离的机构，应根据总账科目中划分出对应内部分户账性质的科目，自定义内部分户账号进行报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 449 行） 主表：【分户账信息】 左关联： 【机构信息】 关联条件：【存款协议】【内部机构号】关联【机构信息】【内部机构号】 左关联： 【科目信息】 关联条件：【科目信息】【科目ID】关联【分户账信息】【科目ID】 过滤条件：账户状态不等于‘销户’或者账户状态等于销户且销户日期是当月的数据，【分户账信息】【分户账类型】='03'

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_407_NBFHZ;

CREATE PROCEDURE PROC_EAST_IE_004_407_NBFHZ(
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

    DELETE FROM IE_004_407
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_407 (
        BBZ,
        GSFZJG,
        JXFS,
        JXBZ,
        JDBZ,
        NBFHZZH,
        MXKMBH,
        NBJGH,
        ZHMC,
        BZ,
        DFYE,
        MXKMMC,
        YHJGMC,
        JRXKZH,
        JFYE,
        SENSITIVEFLAG,
        CJRQ,
        ZHZT,
        KHRQ,
        LL,
        XHRQ
    )
    SELECT
        /* 备注：分户账信息.备注 -> T_4_3.D030014；提取一表通《表4.3分户账信息》、《表1.1机构信息》、《表4.2科目信息》备注，如有多项，以英文分隔符';'拼接 */
        src.D030014 AS BBZ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG,
        /* 计息方式：分户账信息.计息方式 -> T_4_3.D030007；码值转化： 当计息方式为'01'时， 赋值 '按月结息'; 当计息方式为'02'时， 赋值 '按季结息'; 当计息方式为'03'时， 赋值 '按半年结息'; 当计息方式为'04'时， 赋值 '按年结息'; 当计息方式为'05'时， 赋值 '不定期结息'; 当计息方式为'06'时， 赋值‘不记利息'; 当计息方式为'07'时， 赋值 '利随本清'; 当计息方式为'00-XX'时，赋值'其他-XX'；转换规则需人工补齐 CASE 分支 */
        src.D030007 AS JXFS,
        /* 计息标志：分户账信息.计息标识 -> T_4_3.D030006；码值转化：1-是，0-否 ELSE ''；转换规则需人工补齐 CASE 分支 */
        src.D030006 AS JXBZ,
        /* 借贷标志：分户账信息.借贷标识 -> T_4_3.D030010；码值转化：01-借，02-贷，03-借贷并列 ELSE ''；转换规则需人工补齐 CASE 分支 */
        src.D030010 AS JDBZ,
        /* 内部分户账账号：分户账信息.分户账号 -> T_4_3.D030002；直接映射:【分户账信息】.【分户账号】 */
        src.D030002 AS NBFHZZH,
        /* 明细科目编号：分户账信息.科目ID -> T_4_3.D030008；直接映射:【分户账信息】.【科目ID】 */
        src.D030008 AS MXKMBH,
        /* 内部机构号：分户账信息.机构ID -> T_4_3.D030001；加工映射：将【一表通】【分户账信息】【机构id】从第12位开始截取 */
        SUBSTR(TRIM(src.D030001), 12) AS NBJGH,
        /* 账户名称：分户账信息.分户账名称 -> T_4_3.D030004；直接映射:【分户账信息】.【分户账名称】 */
        src.D030004 AS ZHMC,
        /* 币种：分户账信息.币种 -> T_4_3.D030009；直接映射:【分户账信息】.【币种】 */
        src.D030009 AS BZ,
        /* 贷方余额：分户账信息.贷方余额 -> T_4_3.D030019；直接映射:SUM(COALESCE(【分户账信息】.【贷方余额】,0)) */
        CAST(NULLIF(TRIM(src.D030019), '') AS DECIMAL(20,2)) AS DFYE,
        /* 明细科目名称：科目信息.科目名称 -> T_4_2.D020003；加工映射：将【一表通】【分户账信息】【科目ID】，关联【一表通】【科目信息】的【科目ID】取【会计科目名称】 */
        s2.D020003 AS MXKMMC,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；加工映射：将【一表通】【分户账信息】【机构id】，关联【一表通】【机构信息表】的【机构id】取【银行机构名称】 */
        s1.A010005 AS YHJGMC,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工映射：将【一表通】【分户账信息】【机构id】，关联【一表通】【机构信息表】的【机构id】取【金融许可证号】 */
        s1.A010003 AS JRXKZH,
        /* 借方余额：分户账信息.借方余额 -> T_4_3.D030018；直接映射:SUM(COALESCE(【分户账信息】.【借方余额】,0)) */
        CAST(NULLIF(TRIM(src.D030018), '') AS DECIMAL(20,2)) AS JFYE,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 采集日期：参数 P_DATA_DATE */
        P_DATA_DATE AS CJRQ,
        /* 账户状态：分户账信息.账户状态 -> T_4_3.D030013；加工映射： 当账户状态为'01'时,赋值'正常', 为'02'时，赋值'预销户', 为'03'时，赋值'销户', 为'04'时，赋值'冻结', 为'05'时，赋值'止付', 为'00-XX'时，赋值'其他-XX') */
        src.D030013 AS ZHZT,
        /* 开户日期：分户账信息.开户日期 -> T_4_3.D030011；加工映射：格式由YYYY-MM-DD转化成YYYYMMDD，空值要转成’99991231‘ */
        CASE WHEN src.D030011 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.D030011) AS VARCHAR(4)), LPAD(CAST(MONTH(src.D030011) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.D030011) AS VARCHAR(2)), 2, '0')) END AS KHRQ,
        /* 利率：待确认来源字段：分户账信息.利率 */
        NULL AS LL,
        /* 销户日期：分户账信息.销户日期 -> T_4_3.D030012；加工映射：格式由YYYY-MM-DD转化成YYYYMMDD，空值要转成’99991231‘ */
        CASE WHEN src.D030012 IS NULL THEN '99991231' ELSE CONCAT(CAST(YEAR(src.D030012) AS VARCHAR(4)), LPAD(CAST(MONTH(src.D030012) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(src.D030012) AS VARCHAR(2)), 2, '0')) END AS XHRQ
    FROM T_4_3 src
    LEFT JOIN T_1_1 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_4_2 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《022_内部分户账.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
