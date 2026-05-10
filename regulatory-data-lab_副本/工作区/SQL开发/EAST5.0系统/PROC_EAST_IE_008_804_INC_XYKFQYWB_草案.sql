/*
草案质量状态：已校准（待验证）。
重构校准日期：2026-05-10
重构校准说明：
- 逐字段对标原始业务需求《052_信用卡分期业务表.md》完成校准
- 消除全部 ON 1=1 和 WHERE 1=1 TODO 占位
- 补齐所有码值 CASE 转换（FQYWLX 10类+通配、FQJYLX 6类+通配、GXHFQBZ 是否）、日期格式转换（BLFQRQ/BLFQSJ/CJRQ）、JOIN 条件（T_8_5↔T_8_4↔T_1_1 链式、T_2_1/T_2_5 客户信息）、WHERE 过滤（分期办理日期在当月）
- 补齐 T_1_1 采集日期过滤（AND s2.A010020 = V_DATA_DATE），防止因复合主键产生重复行
- 补齐 T_8_4 采集日期过滤（AND s1.H040036 = V_DATA_DATE），确保数据一致性
- 缺口字段（SENSITIVEFLAG/KHLB/GSFZJG/FQZRKHLB）在 DDL 中存在但业务需求映射表未给来源，SQL 中置 NULL
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
- T_8_5（信用卡分期状态）, T_8_4（信用卡账户状态）, T_1_1（机构信息）
- T_2_1（单一法人基本情况/对公客户信息）, T_2_5（个人客户基本情况/个人基础信息）

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
- GBase 8a 中 DATE_FORMAT() 和 LAST_DAY() 函数兼容性待跑数验证
- 缺口字段（SENSITIVEFLAG/KHLB/GSFZJG/FQZRKHLB）来源待确认
- T_2_1/T_2_5 客户表关联的实际映射逻辑（证件类别判定）待业务确认
- '00-XX' 通配策略（LEFT+SUBSTR）在 GBase 8a 兼容性待验证
- T_8_5 表同一 分期业务ID（H050001）在多个采集日期出现时的去重策略待确认（当前未做去重，若存在同一分期多版本采集可能产生主键冲突）
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
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003 */
        /* 加工映射：T_8_5.H050024 -> T_8_4.H040003, T_8_4.H040043 截取第12位 -> T_1_1.A010002, 取 T_1_1.A010003 */
        TRIM(s2.A010003) AS JRXKZH,
        /* 涉密标志：DDL 存在但业务需求映射表未给来源，置 NULL */
        NULL AS SENSITIVEFLAG,
        /* 证件类别：一表通转出的EAST对公客户信息表/个人基础信息表 -> T_2_1/T_2_5 */
        /* 加工映射：T_8_5.H050004 关联 T_2_1.B010001 / T_2_5.B050001，取不为空的证件类别名称，若取不到赋'无证件' */
        CASE
            WHEN corp.B010001 IS NOT NULL THEN '营业执照'
            WHEN ind.B050005 IS NOT NULL THEN '身份证'
            WHEN ind.B050006 IS NOT NULL THEN '护照'
            WHEN ind.B050007 IS NOT NULL THEN TRIM(ind.B050007)
            ELSE '无证件'
        END AS ZJLB,
        /* 证件号码：一表通转出的EAST对公客户信息表/个人基础信息表 -> T_2_1.B010004 / T_2_5.B050005/006/008 */
        /* 加工映射：T_8_5.H050004 关联 T_2_1.B010001 / T_2_5.B050001，取不为空的证件号码，若取不到赋空值 */
        COALESCE(
            NULLIF(TRIM(corp.B010004), ''),
            NULLIF(TRIM(ind.B050005), ''),
            NULLIF(TRIM(ind.B050006), ''),
            NULLIF(TRIM(ind.B050008), '')
        ) AS ZJHM,
        /* 信用卡账号：信用卡分期状态.信用卡账号 -> T_8_5.H050024；直接映射 */
        TRIM(src.H050024) AS XYKZH,
        /* 分期业务类型：信用卡分期状态.分期业务类型 -> T_8_5.H050006；加工映射 */
        /* '01'->'账单分期','02'->'单笔消费分期','03'->'现金分期','04'->'POS商户分期',
           '05'->'邮购电购分期','06'->'汽车分期','07'->'家装分期','08'->'车位分期',
           '09'->'教育分期','10'->'婚庆分期','00-XX'->'其他-XX' */
        CASE
            WHEN TRIM(src.H050006) = '01' THEN '账单分期'
            WHEN TRIM(src.H050006) = '02' THEN '单笔消费分期'
            WHEN TRIM(src.H050006) = '03' THEN '现金分期'
            WHEN TRIM(src.H050006) = '04' THEN 'POS商户分期'
            WHEN TRIM(src.H050006) = '05' THEN '邮购电购分期'
            WHEN TRIM(src.H050006) = '06' THEN '汽车分期'
            WHEN TRIM(src.H050006) = '07' THEN '家装分期'
            WHEN TRIM(src.H050006) = '08' THEN '车位分期'
            WHEN TRIM(src.H050006) = '09' THEN '教育分期'
            WHEN TRIM(src.H050006) = '10' THEN '婚庆分期'
            WHEN LEFT(TRIM(src.H050006), 3) = '00-' THEN CONCAT('其他-', SUBSTR(TRIM(src.H050006), 4))
            ELSE TRIM(src.H050006)
        END AS FQYWLX,
        /* 分期总额度：信用卡分期状态.分期总额度 -> T_8_5.H050008；直接映射 */
        CAST(NULLIF(TRIM(src.H050008), '') AS DECIMAL(20,2)) AS FQZED,
        /* 分期转入卡号：信用卡分期状态.分期转入卡号 -> T_8_5.H050015；直接映射 */
        TRIM(src.H050015) AS FQZRKH,
        /* 分期利率：信用卡分期状态.分期利率 -> T_8_5.H050012；直接映射 */
        CAST(NULLIF(TRIM(src.H050012), '') AS DECIMAL(20,6)) AS FQLL,
        /* 分期期数：信用卡分期状态.分期期数 -> T_8_5.H050011；直接映射 */
        CAST(NULLIF(TRIM(src.H050011), '') AS SIGNED) AS FQQS,
        /* 采集日期：默认值报告日，取参数 P_DATA_DATE */
        P_DATA_DATE AS CJRQ,
        /* 客户类别：DDL 存在但业务需求映射表未给来源，置 NULL */
        NULL AS KHLB,
        /* 归属分支机构：DDL 存在但业务需求映射表未给来源，置 NULL */
        NULL AS GSFZJG,
        /* 可用分期额度：信用卡分期状态.可用分期额度 -> T_8_5.H050009；直接映射 */
        CAST(NULLIF(TRIM(src.H050009), '') AS DECIMAL(20,2)) AS KYFQED,
        /* 客户名称：一表通转出的EAST对公客户信息表/个人基础信息表 -> T_2_1.B010003 / T_2_5.B050003 */
        /* 加工映射：T_8_5.H050004 关联 T_2_1.B010001 / T_2_5.B050001，取不为空的客户名称/客户姓名 */
        COALESCE(
            NULLIF(TRIM(corp.B010003), ''),
            NULLIF(TRIM(ind.B050003), '')
        ) AS KHMC,
        /* 分期转入客户类别：DDL 存在但业务需求映射表未给来源，置 NULL */
        NULL AS FQZRKHLB,
        /* 内部机构号：信用卡账户状态.机构ID -> T_8_4.H040043 */
        /* 加工映射：T_8_5.H050024 -> T_8_4.H040003, 取 T_8_4.H040043 从第12位开始截取至最后 */
        SUBSTR(TRIM(s1.H040043), 12) AS NBJGH,
        /* 分期业务编号：信用卡分期状态.分期业务ID -> T_8_5.H050001；直接映射 */
        TRIM(src.H050001) AS FQYWBH,
        /* 客户统一编号：信用卡分期状态.客户ID -> T_8_5.H050004；直接映射 */
        TRIM(src.H050004) AS KHTYBH,
        /* 分期交易类型：信用卡分期状态.分期交易类型 -> T_8_5.H050005；加工映射 */
        /* '01'->'普通分期总额','02'->'普通分期单笔','03'->'专项分期总额','04'->'专项分期单笔',
           '05'->'现金分期总额','06'->'现金分期单笔','00-XX'->'其他-XX' */
        CASE
            WHEN TRIM(src.H050005) = '01' THEN '普通分期总额'
            WHEN TRIM(src.H050005) = '02' THEN '普通分期单笔'
            WHEN TRIM(src.H050005) = '03' THEN '专项分期总额'
            WHEN TRIM(src.H050005) = '04' THEN '专项分期单笔'
            WHEN TRIM(src.H050005) = '05' THEN '现金分期总额'
            WHEN TRIM(src.H050005) = '06' THEN '现金分期单笔'
            WHEN LEFT(TRIM(src.H050005), 3) = '00-' THEN CONCAT('其他-', SUBSTR(TRIM(src.H050005), 4))
            ELSE TRIM(src.H050005)
        END AS FQJYLX,
        /* 办理分期日期：信用卡分期状态.办理分期日期 -> T_8_5.H050013；格式转成YYYYMMDD */
        DATE_FORMAT(src.H050013, '%Y%m%d') AS BLFQRQ,
        /* 币种：信用卡分期状态.币种 -> T_8_5.H050007；直接映射 */
        TRIM(src.H050007) AS BZ,
        /* 分期金额：信用卡分期状态.分期金额 -> T_8_5.H050010；直接映射 */
        CAST(NULLIF(TRIM(src.H050010), '') AS DECIMAL(20,2)) AS FQJE,
        /* 分期转入户名：信用卡分期状态.分期转入户名 -> T_8_5.H050020；直接映射 */
        TRIM(src.H050020) AS FQZRHM,
        /* 备注：信用卡分期状态.备注 -> T_8_5.H050023；直接映射 */
        TRIM(src.H050023) AS BBZ,
        /* 办理分期时间：信用卡分期状态.办理分期时间 -> T_8_5.H050014 */
        /* 加工映射：删除":"，将数据格式转成HHMMSS */
        REPLACE(CAST(src.H050014 AS CHAR(8)), ':', '') AS BLFQSJ,
        /* 个性化分期标志：信用卡分期状态.个性化分期标识 -> T_8_5.H050016 */
        /* 加工映射：'1'转为'是'，其他转为'否' */
        CASE WHEN TRIM(src.H050016) = '1' THEN '是' ELSE '否' END AS GXHFQBZ,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005 */
        /* 加工映射：T_8_5.H050024 -> T_8_4.H040003, T_8_4.H040043 截取第12位 -> T_1_1.A010002, 取 T_1_1.A010005 */
        TRIM(s2.A010005) AS YHJGMC
    FROM T_8_5 src
    /* 关联信用卡账户状态：按信用卡账号关联 */
    LEFT JOIN T_8_4 s1
           ON TRIM(src.H050024) = TRIM(s1.H040003)
          AND s1.H040036 = V_DATA_DATE
    /* 关联机构信息：按内部机构号（机构ID截取第12位）关联 */
    LEFT JOIN T_1_1 s2
           ON SUBSTR(TRIM(s1.H040043), 12) = TRIM(s2.A010002)
          AND s2.A010020 = V_DATA_DATE
    /* 关联单一法人基本情况（对公客户信息）：按客户ID关联 */
    LEFT JOIN T_2_1 corp
           ON TRIM(src.H050004) = TRIM(corp.B010001)
          AND corp.B010060 = V_DATA_DATE
    /* 关联个人客户基本情况（个人基础信息）：按客户ID关联 */
    LEFT JOIN T_2_5 ind
           ON TRIM(src.H050004) = TRIM(ind.B050001)
          AND ind.B050036 = V_DATA_DATE
    /* 表级规则：取分期办理日期在当月的 */
    WHERE YEAR(src.H050013) = YEAR(V_DATA_DATE)
      AND MONTH(src.H050013) = MONTH(V_DATA_DATE);

    COMMIT;
END;
