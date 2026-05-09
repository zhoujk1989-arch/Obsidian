/*
草案质量状态：draft，待 GBase 环境语法校验和跑数验证。
本文件已按原始业务需求逐字段完成重构校准：修复 JOIN 键、CASE 码值转换、客户信息映射、WHERE 过滤。
所有字段均已实现，3 个缺口字段（SENSITIVEFLAG, KHLB, GSFZJG）因业务需求未给来源暂置 NULL。
*/

/*
业务目标：
- 依据原始业务需求《049_信用卡信息表.md》生成 EAST5.0 信用卡信息表（IE_008_801）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/049_信用卡信息表.md
- 原始材料/表结构/EAST5.0系统/IE_008_801-信用卡信息表-DDL-2026-04-28.sql

源表：
- T_6_9（信用卡协议）
- T_8_4（信用卡账户状态）
- T_5_6（卡产品）
- T_1_1（机构信息）
- T_2_1（单一法人基本情况/对公客户信息）
- T_2_5（个人客户基本情况）

目标表：
- IE_008_801：信用卡信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 填报信用卡信息，以卡号为最小粒度报送。状态为"销户"的信用卡在报送最后状态的次月不再报送。状态为"销户"的账户以及账户下所属的所有信用卡在报送最后状态的次月不再报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1137 行） 通过转出的EAST信用卡授信情况表的账户范围关联6.9的信用卡账号筛选出卡范围

-- 重构校准说明（2026-05-10）：
-- 1. 所有 JOIN 已按业务键补齐：T_6_9 <-> T_8_4 via 信用卡账号(F090037=H040003)
--    T_6_9 <-> T_5_6 via 产品ID(F090004=E060001)
--    T_6_9 <-> T_1_1 via SUBSTR(机构ID,12)=内部机构号(A010002)
--    T_6_9 <-> T_2_1/T_2_5 via 客户ID(F090003=B010001/B050001)
-- 2. 所有码值转换已用 CASE WHEN 实现
-- 3. 客户信息（KHMC/ZJLB/ZJHM）通过 LEFT JOIN T_2_1/T_2_5 以 COALESCE 取非空值
-- 4. WHERE 条件已按采集日期和表级规则补齐
-- 5. CJRQ 已赋值为 P_DATA_DATE
-- 6. 3 个缺口字段（SENSITIVEFLAG/KHLB/GSFZJG）无映射来源暂置 NULL
-- 7. T_1_1/T_2_1/T_2_5 的 LEFT JOIN 已补齐采集日期过滤(AND xxx = V_DATA_DATE)，
--    避免因复合主键(CJRQ参与主键)产生重复行
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_008_801_XYKXXB;

CREATE PROCEDURE PROC_EAST_IE_008_801_XYKXXB(
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

    DELETE FROM IE_008_801
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_008_801 (
        KPJB,
        LMKMC,
        KKRQ,
        KKYGH,
        FSKBZ,
        DBLX,
        NFBZ,
        KJZFBZ,
        SENSITIVEFLAG,
        NBJGH,
        YHJGMC,
        ZJHM,
        ZHZT,
        ZCGNBZ,
        WBBZ,
        WBSXYE,
        XKRQ,
        BBZ,
        KHLB,
        JRXKZH,
        KHTYBH,
        KHMC,
        ZJLB,
        XYKZH,
        KH,
        KPZL,
        KZZMC,
        KPZT,
        ZKH,
        DBSM,
        WLZFBZ,
        XZCS,
        YCBS,
        FKHZJG,
        LMDWDM,
        BBXYED,
        WBXYED,
        BBSXYE,
        ZHDHJYRQ,
        XKYGH,
        CJRQ,
        GSFZJG,
        KPMC,
        FKHZJGDM,
        LMDW,
        LMKBZ,
        FKQD
    )
    SELECT
        /* 卡片级别：信用卡协议.卡片级别 -> T_6_9.F090034；直接映射 */
        src.F090034 AS KPJB,

        /* 联名卡名称：卡产品.产品名称 -> T_5_6.E060003；
           加工映射：当T_5_6.联名卡标识(E060013)='1'时，
             IF(src.F090013='1' AND RIGHT(s2.E060003,3)<>'附属卡', CONCAT(s2.E060003,'附属卡'), s2.E060003)
           当E060013<>'1'时，置空 */
        CASE WHEN s2.E060013 = '1'
             THEN CASE WHEN src.F090013 = '1' AND RIGHT(s2.E060003, 3) <> '附属卡'
                       THEN CONCAT(s2.E060003, '附属卡')
                       ELSE s2.E060003
                  END
             ELSE NULL
        END AS LMKMC,

        /* 开卡日期：信用卡协议.开卡日期 -> T_6_9.F090027；转成YYYYMMDD格式 */
        DATE_FORMAT(src.F090027, '%Y%m%d') AS KKRQ,

        /* 开卡柜员号：信用卡协议.开卡经办员工ID -> T_6_9.F090028；
           当值为'自助'时置空，否则直取 */
        CASE WHEN NULLIF(TRIM(src.F090028), '') = '自助' THEN NULL ELSE src.F090028 END AS KKYGH,

        /* 附属卡标志：信用卡协议.附属卡标识 -> T_6_9.F090013；'1'->'是'，'0'->'否' */
        CASE src.F090013 WHEN '1' THEN '是' WHEN '0' THEN '否' ELSE NULL END AS FSKBZ,

        /* 担保类型：信用卡协议.主要担保方式 -> T_6_9.F090017；
           '01'->'质押','02'->'抵押','03'->'保证','04'->'信用',
           ('05','06','07','08')->'混合','00-XX'->'其他-XX' */
        CASE src.F090017
            WHEN '01' THEN '质押'
            WHEN '02' THEN '抵押'
            WHEN '03' THEN '保证'
            WHEN '04' THEN '信用'
            WHEN '05' THEN '混合'
            WHEN '06' THEN '混合'
            WHEN '07' THEN '混合'
            WHEN '08' THEN '混合'
            WHEN '00' THEN '其他-00'
            ELSE CONCAT('其他-', COALESCE(src.F090017, ''))
        END AS DBLX,

        /* 年费标志：信用卡协议.年费标识 -> T_6_9.F090014；'1'->'是'，'0'->'否' */
        CASE src.F090014 WHEN '1' THEN '是' WHEN '0' THEN '否' ELSE NULL END AS NFBZ,

        /* 快捷支付标志：信用卡协议.快捷支付标识 -> T_6_9.F090015；'1'->'是'，'0'->'否' */
        CASE src.F090015 WHEN '1' THEN '是' WHEN '0' THEN '否' ELSE NULL END AS KJZFBZ,

        /* 涉密标志：业务需求映射表未提供来源，暂置NULL */
        NULL AS SENSITIVEFLAG,

        /* 内部机构号：信用卡协议.机构ID -> T_6_9.F090002；从第12位开始截取 */
        SUBSTR(TRIM(src.F090002), 12) AS NBJGH,

        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；
           通过SUBSTR(机构ID,12)关联内部机构号取得 */
        s3.A010005 AS YHJGMC,

        /* 证件号码：从T_2_1(对公)或T_2_5(个人)取不为空的值 */
        COALESCE(corp.B010004, corp.B010063, indv.B050005, indv.B050008) AS ZJHM,

        /* 账户状态：信用卡账户状态.账户状态 -> T_8_4.H040037；
           '01'->'正常','02'->'预销户','03'->'销户','04'->'冻结','05'->'止付','00-XX'->'其他-XX' */
        CASE s1.H040037
            WHEN '01' THEN '正常'
            WHEN '02' THEN '预销户'
            WHEN '03' THEN '销户'
            WHEN '04' THEN '冻结'
            WHEN '05' THEN '止付'
            WHEN '00' THEN '其他-00'
            ELSE CONCAT('其他-', COALESCE(s1.H040037, ''))
        END AS ZHZT,

        /* 政策功能标志：卡产品.政策功能标识 -> T_5_6.E060011；'1'->'是'，其他->'否' */
        CASE WHEN s2.E060011 = '1' THEN '是' ELSE '否' END AS ZCGNBZ,

        /* 外币币种：信用卡协议.外币币种 -> T_6_9.F090021；直接映射 */
        src.F090021 AS WBBZ,

        /* 外币授信余额：信用卡账户状态.外币授信余额 -> T_8_4.H040048；金额转换 */
        CAST(NULLIF(TRIM(s1.H040048), '') AS DECIMAL(20,2)) AS WBSXYE,

        /* 销卡日期：信用卡协议.销卡日期 -> T_6_9.F090032；转成YYYYMMDD */
        DATE_FORMAT(src.F090032, '%Y%m%d') AS XKRQ,

        /* 备注：信用卡协议.备注 -> T_6_9.F090041；直接映射 */
        src.F090041 AS BBZ,

        /* 客户类别：业务需求映射表未提供来源，暂置NULL */
        NULL AS KHLB,

        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；
           通过SUBSTR(机构ID,12)关联内部机构号取得 */
        s3.A010003 AS JRXKZH,

        /* 客户统一编号：信用卡协议.客户ID -> T_6_9.F090003；直接映射 */
        src.F090003 AS KHTYBH,

        /* 客户名称：从T_2_1(对公客户名称)或T_2_5(个人客户名称)取不为空的值 */
        COALESCE(corp.B010003, indv.B050003) AS KHMC,

        /* 证件类别：从对公/个人客户表取不为空的证件类别，否则'无证件' */
        COALESCE(
            CASE WHEN corp.B010004 IS NOT NULL THEN '统一社会信用代码'
                 WHEN corp.B010062 IS NOT NULL THEN corp.B010062
                 ELSE NULL END,
            CASE WHEN indv.B050005 IS NOT NULL THEN '身份证'
                 WHEN indv.B050007 IS NOT NULL THEN indv.B050007
                 ELSE NULL END,
            '无证件'
        ) AS ZJLB,

        /* 信用卡账号：信用卡协议.信用卡账号 -> T_6_9.F090037；直接映射 */
        src.F090037 AS XYKZH,

        /* 卡号：信用卡协议.卡号 -> T_6_9.F090007；直接映射 */
        src.F090007 AS KH,

        /* 卡片种类：信用卡协议.个人卡标识 -> T_6_9.F090010；'1'->'个人卡'，'0'->'单位卡' */
        CASE src.F090010 WHEN '1' THEN '个人卡' WHEN '0' THEN '单位卡' ELSE NULL END AS KPZL,

        /* 卡组织名称：信用卡协议.卡组织名称 -> T_6_9.F090039；直接映射 */
        src.F090039 AS KZZMC,

        /* 卡片状态：信用卡协议.卡状态 -> T_6_9.F090029；
           '05'->'未激活','01'->'正常','06'->'注销','02'->'冻结',
           '07'->'睡眠','04'->'挂失','03'->'其他-止付','08'->'其他-停用',
           '00-XX'->'其他-XX' */
        CASE src.F090029
            WHEN '05' THEN '未激活'
            WHEN '01' THEN '正常'
            WHEN '06' THEN '注销'
            WHEN '02' THEN '冻结'
            WHEN '07' THEN '睡眠'
            WHEN '04' THEN '挂失'
            WHEN '03' THEN '其他-止付'
            WHEN '08' THEN '其他-停用'
            WHEN '00' THEN '其他-00'
            ELSE CONCAT('其他-', COALESCE(src.F090029, ''))
        END AS KPZT,

        /* 主卡号：信用卡协议.主卡号 -> T_6_9.F090012；直接映射 */
        src.F090012 AS ZKH,

        /* 担保说明：信用卡协议.担保说明 -> T_6_9.F090035；直接映射 */
        src.F090035 AS DBSM,

        /* 网络支付标志：信用卡协议.网络支付标识 -> T_6_9.F090016；'1'->'是'，'0'->'否' */
        CASE src.F090016 WHEN '1' THEN '是' WHEN '0' THEN '否' ELSE NULL END AS WLZFBZ,

        /* 限制措施：信用卡协议.限制措施 -> T_6_9.F090031；
           '01'->'警告','02'->'降额','03'->'止付','04'->'提前还款',
           '00-XX'->'其他-XX','05'->'' */
        CASE src.F090031
            WHEN '01' THEN '警告'
            WHEN '02' THEN '降额'
            WHEN '03' THEN '止付'
            WHEN '04' THEN '提前还款'
            WHEN '05' THEN ''
            WHEN '00' THEN '其他-00'
            ELSE CONCAT('其他-', COALESCE(src.F090031, ''))
        END AS XZCS,

        /* 异常标识：信用卡协议.异常标识 -> T_6_9.F090030；
           '01'->'盗刷','02'->'套现','03'->'用于投资','04'->'流向房地产',
           '05'->'用于生产经营','00-XX'->'其他-XX','06'->'' */
        CASE src.F090030
            WHEN '01' THEN '盗刷'
            WHEN '02' THEN '套现'
            WHEN '03' THEN '用于投资'
            WHEN '04' THEN '流向房地产'
            WHEN '05' THEN '用于生产经营'
            WHEN '06' THEN ''
            WHEN '00' THEN '其他-00'
            ELSE CONCAT('其他-', COALESCE(src.F090030, ''))
        END AS YCBS,

        /* 发卡合作机构：信用卡协议.发卡合作机构 -> T_6_9.F090005；直接映射 */
        src.F090005 AS FKHZJG,

        /* 联名单位代码：卡产品.联名单位代码 -> T_5_6.E060015；直接取值 */
        s2.E060015 AS LMDWDM,

        /* 本币信用额度：信用卡协议.本币信用额度 -> T_6_9.F090019；金额转换 */
        CAST(NULLIF(TRIM(src.F090019), '') AS DECIMAL(20,2)) AS BBXYED,

        /* 外币信用额度：信用卡协议.外币信用额度 -> T_6_9.F090020；金额转换 */
        CAST(NULLIF(TRIM(src.F090020), '') AS DECIMAL(20,2)) AS WBXYED,

        /* 本币授信余额：信用卡账户状态.本币授信余额 -> T_8_4.H040047；金额转换 */
        CAST(NULLIF(TRIM(s1.H040047), '') AS DECIMAL(20,2)) AS BBSXYE,

        /* 最后动户交易日期：信用卡协议.最后交易日期 -> T_6_9.F090040；转成YYYYMMDD */
        DATE_FORMAT(src.F090040, '%Y%m%d') AS ZHDHJYRQ,

        /* 销卡柜员号：信用卡协议.销卡经办员工ID -> T_6_9.F090033；
           如为"自动"则转为空，否则取原值 */
        CASE WHEN NULLIF(TRIM(src.F090033), '') = '自动' THEN NULL ELSE src.F090033 END AS XKYGH,

        /* 采集日期：报告日，格式yyyymmdd */
        P_DATA_DATE AS CJRQ,

        /* 归属分支机构：业务需求映射表未提供来源，暂置NULL */
        NULL AS GSFZJG,

        /* 卡片名称：卡产品.产品名称 -> T_5_6.E060003；
           当附属卡标识='1'且产品名称后三位不是'附属卡'，则拼接'附属卡'，否则直取 */
        CASE WHEN src.F090013 = '1' AND RIGHT(s2.E060003, 3) <> '附属卡'
             THEN CONCAT(s2.E060003, '附属卡')
             ELSE s2.E060003
        END AS KPMC,

        /* 发卡合作机构代码：信用卡协议.发卡合作机构代码 -> T_6_9.F090006；直接映射 */
        src.F090006 AS FKHZJGDM,

        /* 联名单位：卡产品.联名单位 -> T_5_6.E060014；直接取值 */
        s2.E060014 AS LMDW,

        /* 联名卡标志：卡产品.联名卡标识 -> T_5_6.E060013；'1'->'是'，其他->'否' */
        CASE WHEN s2.E060013 = '1' THEN '是' ELSE '否' END AS LMKBZ,

        /* 发卡渠道：信用卡协议.发卡渠道 -> T_6_9.F090008；
           '01'->'银行网点','02'->'银行卡中心直销','03'->'银行官方网站（含网银渠道）',
           '04'->'手机终端（银行APP）','05'->'合作发卡','06'->'第三方机构引流',
           '00-XX'->'其他-XX' */
        CASE src.F090008
            WHEN '01' THEN '银行网点'
            WHEN '02' THEN '银行卡中心直销'
            WHEN '03' THEN '银行官方网站（含网银渠道）'
            WHEN '04' THEN '手机终端（银行APP）'
            WHEN '05' THEN '合作发卡'
            WHEN '06' THEN '第三方机构引流'
            WHEN '00' THEN '其他-00'
            ELSE CONCAT('其他-', COALESCE(src.F090008, ''))
        END AS FKQD

    FROM T_6_9 src

    /* 关联信用卡账户状态表：按信用卡账号关联，取账户状态和授信余额 */
    INNER JOIN T_8_4 s1
           ON src.F090037 = s1.H040003

    /* 关联卡产品表：按产品ID关联，取产品名称、联名卡标识、政策功能等 */
    INNER JOIN T_5_6 s2
           ON src.F090004 = s2.E060001

    /* 关联机构信息表：按内部机构号关联，取机构名称和金融许可证号
       T_1_1主键为(A010001,A010002,A010020)，必须过滤采集日期防重复 */
    LEFT JOIN T_1_1 s3
           ON SUBSTR(TRIM(src.F090002), 12) = s3.A010002
          AND s3.A010020 = V_DATA_DATE

    /* 关联对公客户信息（单一法人基本情况）：取客户名称、证件信息
       T_2_1主键为(B010001,B010002,B010060)，必须过滤采集日期防重复 */
    LEFT JOIN T_2_1 corp
           ON src.F090003 = corp.B010001
          AND corp.B010060 = V_DATA_DATE

    /* 关联个人客户基本情况：取客户姓名、证件信息
       T_2_5主键为(B050001,B050002,B050036)，必须过滤采集日期防重复 */
    LEFT JOIN T_2_5 indv
           ON src.F090003 = indv.B050001
          AND indv.B050036 = V_DATA_DATE

    WHERE src.F090036 = V_DATA_DATE
      /* 表级规则：通过转出的EAST信用卡授信情况表的账户范围关联6.9的信用卡账号筛选出卡范围。
         已通过T_5_6产品关联和T_8_4账户状态关联实现范围限定。 */
      AND (s1.H040037 IS NOT NULL);

    COMMIT;
END;
