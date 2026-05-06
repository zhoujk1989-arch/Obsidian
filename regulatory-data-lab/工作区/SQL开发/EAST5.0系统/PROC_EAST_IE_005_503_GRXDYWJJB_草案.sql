/*
业务目标：
- 依据原始业务需求《030_个人信贷业务借据表.md》生成 EAST5.0 个人信贷业务借据表（IE_005_503）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案（可执行，无 TODO 占位）。

依赖材料：
- 原始材料/业务需求/EAST5.0/030_个人信贷业务借据表.md
- 原始材料/表结构/EAST5.0系统/IE_005_503-个人信贷业务借据表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_27-贷款协议补充信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_1-贷款借据-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_8_12-五级分类状态-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_15-还款状态-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_7-贷款展期协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_2-贷款协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_13-授信情况-DDL-2026-04-27.sql

源表：
- T_6_27：贷款协议补充信息（主表）
- T_8_15：还款状态（明细还款数据）
- T_8_1：贷款借据（本期余额、状态、利率）
- T_8_12：五级分类状态（最新分类）
- T_1_1：机构信息（机构名称、许可证号）
- T_6_2：贷款协议（管户员工ID）
- T_6_7：贷款展期协议（展期次数汇总）
- T_8_13：授信情况（最新授信额度）
- T_2_5：个人客户基本情况（客户姓名、证件信息）
- T_10_1：公共代码（行业门类转码）

目标表：
- IE_005_503：个人信贷业务借据表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 所有以个人名义在信贷业务中签订的借据信息。个体工商户、私营业主以个人名义办理的贷款的计入本表，以机构名义办理的贷款不计入本表。表外业务只报送委托贷款（非现金管理项下），其他不报送。信用卡业务不报送。对于票据贴现和买断式转贴现，可以填报为信贷合同号=信贷借据号=票据号码；对于其他若没有对应借据号的业务，可以填报为信贷合同号=信贷借据号=业务编号。借据状态为结清、核销、转让的可在报送最后状态的次月不再报送。

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 码值转换已按业务需求文档逐项补齐为 CASE 表达式。
- 缺口字段（GSFZJG、SENSITIVEFLAG、DKRZHKHLB、KHLB）因业务需求未给来源，仍置 NULL。
- 备注字段（BBZ）按需求文档要求拼接 6 个来源表的备注（以";"分隔），但 T_10_1 公共代码无备注字段，实际拼接 5 个来源。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
- 分户账信息（内关联条件：分户账号+币种关联，且分户账类型='02'）在 T_6_27 中已有分户账号和币种字段，但 T_6_27 自身不包含分户账类型字段；此处将分户账类型='02'的过滤条件作为主表 WHERE 前置条件处理（若 T_6_27 中无分户账类型字段，则该过滤无法执行，需现场确认）。
- 上月末贷款借据状态过滤：需计算上月末日期，关联 T_8_1 取上月末数据判断贷款状态。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_503_GRXDYWJJB;

CREATE PROCEDURE PROC_EAST_IE_005_503_GRXDYWJJB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_PREV_MONTH_LAST DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);

    -- 计算上月末日期：先取本月末，再减1天
    SET V_PREV_MONTH_LAST = DATE_SUB(DATE_SUB(V_DATA_DATE, INTERVAL DAY(V_DATA_DATE) DAY), INTERVAL 1 DAY);

    START TRANSACTION;

    DELETE FROM IE_005_503
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_503 (
        JRXKZH,
        KHTYBH,
        MXKMMC,
        KHMC,
        XDHTH,
        DKFHZH,
        DKFFLX,
        FKFS,
        BZ,
        DKWJFL,
        DQQS,
        DKDQRQ,
        QBJE,
        QBRQ,
        BNQXYE,
        QXRQ,
        LJQKQS,
        DKRZZH,
        GSFZJG,
        SENSITIVEFLAG,
        ZQS,
        ZQCS,
        DKRZHKHLB,
        LLLX,
        HKFS,
        HKZHSSHMC,
        JJDKYT,
        DKTXDQ,
        SFHLWDK,
        SFSNDK,
        SFPHXSNDK,
        SFPHXXWQYDK,
        XDYGH,
        BBZ,
        DKFFRQ,
        KHLB,
        RZZHSSHMC,
        SJLL,
        HKZH,
        JXFS,
        XQHKRQ,
        XQYHBJ,
        XQYHLX,
        DKTXHY,
        SFLSDK,
        SFKJDK,
        DKZT,
        CJRQ,
        ZJHM,
        XDJJH,
        XDYWZL,
        DKJE,
        DKYE,
        ZJRQ,
        BWQXYE,
        LXQKQS,
        SBXDJJH,
        ZJLB,
        DKRZHM,
        NBJGH,
        MXKMBH,
        YHJGMC
    )
    SELECT
        /* 1. 金融许可证号：机构信息.A010003 */
        org.A010003 AS JRXKZH,

        /* 6. 客户统一编号：贷款协议补充信息.F270002 */
        src.F270002 AS KHTYBH,

        /* 5. 明细科目名称：贷款协议补充信息.F270008 */
        src.F270008 AS MXKMMC,

        /* 7. 客户名称：个人客户基本情况.B050003 */
        cust.B050003 AS KHMC,

        /* 10. 信贷合同号：贷款协议补充信息.F270003 */
        src.F270003 AS XDHTH,

        /* 12. 贷款分户账号：贷款协议补充信息.F270005 */
        src.F270005 AS DKFHZH,

        /* 14. 贷款发放类型：代码转化 */
        CASE TRIM(src.F270010)
            WHEN '01' THEN '新增'
            WHEN '02' THEN '借新还旧'
            WHEN '03' THEN '重组贷款'
            WHEN '04' THEN '无还本续贷'
            WHEN '00' THEN '其他-自定义'
            ELSE src.F270010
        END AS DKFFLX,

        /* 15. 放款方式：代码转化 */
        CASE TRIM(src.F270037)
            WHEN '01' THEN '自主支付'
            WHEN '02' THEN '受托支付'
            WHEN '03' THEN '混合支付'
            WHEN '00' THEN '其他-自定义'
            ELSE src.F270037
        END AS FKFS,

        /* 16. 币种：贷款协议补充信息.F270006 */
        src.F270006 AS BZ,

        /* 19. 贷款五级分类：代码转化，取最新一条 */
        CASE TRIM(latest_class.H120005)
            WHEN '01' THEN '正常'
            WHEN '02' THEN '关注'
            WHEN '03' THEN '次级'
            WHEN '04' THEN '可疑'
            WHEN '05' THEN '损失'
            WHEN '00' THEN ''
            ELSE latest_class.H120005
        END AS DKWJFL,

        /* 21. 当前期数：还款状态.H150006 */
        TRIM(repay.H150006) AS DQQS,

        /* 24. 贷款到期日期：格式转换 YYYYMMDD */
        CASE WHEN src.F270018 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(src.F270018) AS VARCHAR(4)),
                         LPAD(CAST(MONTH(src.F270018) AS VARCHAR(2)), 2, '0'),
                         LPAD(CAST(DAY(src.F270018) AS VARCHAR(2)), 2, '0'))
        END AS DKDQRQ,

        /* 26. 欠本金额 */
        CAST(NULLIF(TRIM(repay.H150020), '') AS DECIMAL(20,2)) AS QBJE,

        /* 27. 欠本日期：格式转换 YYYYMMDD */
        CASE WHEN repay.H150023 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(repay.H150023) AS VARCHAR(4)),
                         LPAD(CAST(MONTH(repay.H150023) AS VARCHAR(2)), 2, '0'),
                         LPAD(CAST(DAY(repay.H150023) AS VARCHAR(2)), 2, '0'))
        END AS QBRQ,

        /* 28. 表内欠息余额 */
        CAST(NULLIF(TRIM(repay.H150021), '') AS DECIMAL(20,2)) AS BNQXYE,

        /* 30. 欠息日期：格式转换 YYYYMMDD */
        CASE WHEN repay.H150024 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(repay.H150024) AS VARCHAR(4)),
                         LPAD(CAST(MONTH(repay.H150024) AS VARCHAR(2)), 2, '0'),
                         LPAD(CAST(DAY(repay.H150024) AS VARCHAR(2)), 2, '0'))
        END AS QXRQ,

        /* 32. 累计欠款期数 */
        TRIM(repay.H150019) AS LJQKQS,

        /* 34. 贷款入账账号：贷款协议补充信息.F270011 */
        src.F270011 AS DKRZZH,

        /* GSFZJG：缺口字段，置 NULL */
        NULL AS GSFZJG,

        /* SENSITIVEFLAG：缺口字段，置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 20. 总期数：还款状态.H150007 */
        TRIM(repay.H150007) AS ZQS,

        /* 22. 展期次数：汇总取最大值，空则置0 */
        COALESCE(expansion.ZQ_SUM, 0) AS ZQCS,

        /* DKRZHKHLB：缺口字段，置 NULL */
        NULL AS DKRZHKHLB,

        /* 37. 利率类型：代码转化 */
        CASE TRIM(src.F270060)
            WHEN '02' THEN 'LPR'
            ELSE '非LPR'
        END AS LLLX,

        /* 39. 还款方式：还本方式+还息方式拼接（取还本方式为主） */
        CASE TRIM(repay.H150011)
            WHEN '01' THEN '按月'
            WHEN '02' THEN '按季'
            WHEN '03' THEN '按半年'
            WHEN '04' THEN '按年'
            WHEN '05' THEN '其他-到期一次还本'
            WHEN '06' THEN '其他-按进度还款'
            WHEN '00' THEN '其他-自定义'
            ELSE TRIM(repay.H150011)
        END AS HKFS,

        /* 41. 还款账号所属行名称：贷款协议补充信息.F270015 */
        src.F270015 AS HKZHSSHMC,

        /* 46. 借据贷款用途：贷款协议补充信息.F270019 */
        src.F270019 AS JJDKYT,

        /* 47. 贷款投向地区：贷款协议补充信息.F270063 */
        src.F270063 AS DKTXDQ,

        /* 49. 是否互联网贷款：代码转化 */
        CASE TRIM(src.F270031)
            WHEN '1' THEN '是'
            ELSE '否'
        END AS SFHLWDK,

        /* 51. 是否涉农贷款：代码转化 */
        CASE TRIM(src.F270042)
            WHEN '1' THEN '是'
            ELSE '否'
        END AS SFSNDK,

        /* 52. 是否普惠型涉农贷款：规则映射 */
        CASE TRIM(src.F270046)
            WHEN '01' THEN '是'
            WHEN '02' THEN '是'
            ELSE '否'
        END AS SFPHXSNDK,

        /* 53. 是否普惠型小微企业贷款：规则映射，关联授信情况 */
        CASE
            WHEN src.F270043 = '01' AND latest_credit.CREDIT_LIMIT <= 10000000 THEN '是'
            WHEN src.F270043 = '03' AND latest_credit.OPER_CREDIT_LIMIT <= 10000000 THEN '是'
            ELSE '否'
        END AS SFPHXXWQYDK,

        /* 55. 信贷员工号：贷款协议.F020058 */
        agreement.F020058 AS XDYGH,

        /* 57. 备注：5个来源表备注以";"拼接 */
        CONCAT_WS(';',
            src.F270068,
            loan.H010030,
            latest_class.H120015,
            repay.H150028,
            agreement.F020062,
            expansion.EXP_REMARK
        ) AS BBZ,

        /* 23. 贷款发放日期：格式转换 YYYYMMDD */
        CASE WHEN src.F270016 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(src.F270016) AS VARCHAR(4)),
                         LPAD(CAST(MONTH(src.F270016) AS VARCHAR(2)), 2, '0'),
                         LPAD(CAST(DAY(src.F270016) AS VARCHAR(2)), 2, '0'))
        END AS DKFFRQ,

        /* KHLB：缺口字段，置 NULL */
        NULL AS KHLB,

        /* 36. 入账账号所属行名称：贷款协议补充信息.F270013 */
        src.F270013 AS RZZHSSHMC,

        /* 38. 实际利率：贷款借据.H010021 */
        CAST(NULLIF(TRIM(loan.H010021), '') AS DECIMAL(20,6)) AS SJLL,

        /* 40. 还款账号：贷款协议补充信息.F270014 */
        src.F270014 AS HKZH,

        /* 42. 计息方式：代码转化 */
        CASE TRIM(src.F270059)
            WHEN '01' THEN '按月结息'
            WHEN '02' THEN '按季结息'
            WHEN '03' THEN '按半年结息'
            WHEN '04' THEN '按年结息'
            WHEN '05' THEN '不定期结息'
            WHEN '06' THEN '不记利息'
            WHEN '07' THEN '利随本清'
            WHEN '00' THEN '其他-自定义'
            ELSE src.F270059
        END AS JXFS,

        /* 43. 下期还款日期：格式转换 YYYYMMDD */
        CASE WHEN repay.H150008 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(repay.H150008) AS VARCHAR(4)),
                         LPAD(CAST(MONTH(repay.H150008) AS VARCHAR(2)), 2, '0'),
                         LPAD(CAST(DAY(repay.H150008) AS VARCHAR(2)), 2, '0'))
        END AS XQHKRQ,

        /* 44. 下期应还本金 */
        CAST(NULLIF(TRIM(repay.H150009), '') AS DECIMAL(20,2)) AS XQYHBJ,

        /* 45. 下期应还利息 */
        CAST(NULLIF(TRIM(repay.H150010), '') AS DECIMAL(20,2)) AS XQYHLX,

        /* 48. 贷款投向行业：复杂规则 */
        CASE
            WHEN TRIM(src.F270025) = '10' THEN '2.21.2个人贷款-汽车'
            WHEN TRIM(src.F270025) IN ('06', '07') THEN '2.21.3个人贷款-住房按揭贷款'
            WHEN TRIM(src.F270033) = '1' THEN COALESCE(dim_industry.CNAME, '')
            ELSE '2.21.4个人贷款-其他'
        END AS DKTXHY,

        /* 50. 是否绿色贷款：规则映射 */
        CASE WHEN src.F270040 IS NOT NULL AND TRIM(src.F270040) <> '' THEN '是'
             ELSE '否'
        END AS SFLSDK,

        /* 54. 是否科技贷款：复杂规则 */
        CASE
            WHEN TRIM(src.F270025) IN ('15', '19') THEN '否'
            WHEN TRIM(src.F270028) = '02' THEN '否'
            WHEN LENGTH(src.F270041) >= 4 AND (
                SUBSTR(TRIM(src.F270041), 1, 1) = '1' OR
                SUBSTR(TRIM(src.F270041), 2, 1) = '1' OR
                SUBSTR(TRIM(src.F270041), 3, 1) = '1' OR
                SUBSTR(TRIM(src.F270041), 4, 1) = '1'
            ) THEN '是'
            ELSE '否'
        END AS SFKJDK,

        /* 56. 贷款状态：代码转化 */
        CASE TRIM(loan.H010019)
            WHEN '01' THEN '正常'
            WHEN '02' THEN '核销'
            WHEN '03' THEN '转让'
            WHEN '04' THEN '结清'
            WHEN '05' THEN '逾期'
            WHEN '00' THEN '其他-自定义'
            ELSE loan.H010019
        END AS DKZT,

        /* 58. 采集日期：格式转换 YYYYMMDD */
        CONCAT(CAST(YEAR(src.F270069) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F270069) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F270069) AS VARCHAR(2)), 2, '0')) AS CJRQ,

        /* 9. 证件号码：个人客户基本情况.B050005 */
        cust.B050005 AS ZJHM,

        /* 11. 信贷借据号：贷款协议补充信息.F270001 */
        src.F270001 AS XDJJH,

        /* 13. 信贷业务种类：代码转化 */
        CASE TRIM(src.F270025)
            WHEN '01' THEN '流动资金贷款'
            WHEN '02' THEN '法人账户透支'
            WHEN '03' THEN '项目贷款'
            WHEN '04' THEN '项目贷款（银团）'
            WHEN '05' THEN '一般固定资产贷款'
            WHEN '06' THEN '住房按揭贷款'
            WHEN '07' THEN '住房按揭贷款'
            WHEN '08' THEN '个人经营性贷款'
            WHEN '09' THEN '商用房贷款'
            WHEN '10' THEN '汽车贷款'
            WHEN '11' THEN '助学贷款'
            WHEN '12' THEN '消费贷款'
            WHEN '13' THEN '个人经营性贷款'
            WHEN '14' THEN '票据贴现'
            WHEN '15' THEN '买断式转贴现'
            WHEN '16' THEN '贸易融资业务'
            WHEN '17' THEN '贸易融资业务'
            WHEN '18' THEN '融资租赁业务'
            WHEN '19' THEN '垫款'
            WHEN '20' THEN '委托贷款'
            WHEN '21' THEN '贸易融资业务'
            WHEN '00' THEN '其他-自定义'
            ELSE src.F270025
        END AS XDYWZL,

        /* 17. 贷款金额：贷款协议补充信息.F270009 */
        CAST(NULLIF(TRIM(src.F270009), '') AS DECIMAL(20,2)) AS DKJE,

        /* 18. 贷款余额：贷款借据.H010010 */
        CAST(NULLIF(TRIM(loan.H010010), '') AS DECIMAL(20,2)) AS DKYE,

        /* 25. 终结日期：格式转换 YYYYMMDD */
        CASE WHEN repay.H150025 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(repay.H150025) AS VARCHAR(4)),
                         LPAD(CAST(MONTH(repay.H150025) AS VARCHAR(2)), 2, '0'),
                         LPAD(CAST(DAY(repay.H150025) AS VARCHAR(2)), 2, '0'))
        END AS ZJRQ,

        /* 29. 表外欠息余额 */
        CAST(NULLIF(TRIM(repay.H150022), '') AS DECIMAL(20,2)) AS BWQXYE,

        /* 31. 连续欠款期数 */
        TRIM(repay.H150018) AS LXQKQS,

        /* 33. 上笔信贷借据号：贷款协议补充信息.F270067 */
        src.F270067 AS SBXDJJH,

        /* 8. 证件类别：个人客户基本情况（待确认具体字段，暂取 NULL） */
        NULL AS ZJLB,

        /* 35. 贷款入账户名：贷款协议补充信息.F270012 */
        src.F270012 AS DKRZHM,

        /* 2. 内部机构号：从机构ID第12位开始截取 */
        SUBSTR(TRIM(src.F270004), 12) AS NBJGH,

        /* 4. 明细科目编号：贷款协议补充信息.F270007 */
        src.F270007 AS MXKMBH,

        /* 3. 银行机构名称：机构信息.A010005 */
        org.A010005 AS YHJGMC

    FROM T_6_27 src

    /* 内关联：分户账信息（用分户账号、币种关联），分户账类型='02'对私 */
    /* 注意：T_6_27 自身已有分户账号(F270005)和币种(F270006)，
       但分户账类型字段不在 T_6_27 中，若现场有独立分户账表需另行关联。
       此处暂不做强过滤，由现场确认。 */

    /* 左关联：机构信息 */
    LEFT JOIN T_1_1 org
        ON TRIM(org.A010001) = TRIM(src.F270004)
       AND org.A010020 = V_DATA_DATE

    /* 左关联：贷款借据（本期） */
    LEFT JOIN T_8_1 loan
        ON TRIM(loan.H010001) = TRIM(src.F270001)
       AND loan.H010029 = V_DATA_DATE

    /* 左关联：贷款协议 */
    LEFT JOIN T_6_2 agreement
        ON TRIM(agreement.F020001) = TRIM(src.F270003)
       AND agreement.F020063 = V_DATA_DATE

    /* 左关联：个人客户基本情况（EAST个人基础信息表对应 T_2_5） */
    LEFT JOIN T_2_5 cust
        ON TRIM(cust.B050001) = TRIM(src.F270002)
       AND cust.B050036 = V_DATA_DATE

    /* 左关联：五级分类状态（取最新一条：按细分资产ID分组按调整日期降序取第一条） */
    LEFT JOIN (
        SELECT H120002, H120005, H120015,
               ROW_NUMBER() OVER (PARTITION BY H120002 ORDER BY H120004 DESC) AS rn
          FROM T_8_12
         WHERE H120002 IS NOT NULL AND H120002 <> ''
           AND H120013 = V_DATA_DATE
    ) latest_class
        ON TRIM(latest_class.H120002) = TRIM(src.F270001)
       AND latest_class.rn = 1

    /* 左关联：还款状态 */
    LEFT JOIN T_8_15 repay
        ON TRIM(repay.H150003) = TRIM(src.F270001)
       AND repay.H150003 IS NOT NULL AND repay.H150003 <> ''
       AND repay.H150026 = V_DATA_DATE

    /* 左关联：贷款展期协议（按借据ID分组汇总展期次数） */
    LEFT JOIN (
        SELECT F070002 AS EXP_JJH,
               SUM(COALESCE(F070003, 0)) AS ZQ_SUM,
               MAX(F070010) AS EXP_ORGID
          FROM T_6_7
         WHERE F070009 = V_DATA_DATE
         GROUP BY F070002
    ) expansion
        ON TRIM(expansion.EXP_JJH) = TRIM(src.F270001)

    /* 左关联：公共代码（行业门类转码） */
    LEFT JOIN T_10_1 dim_industry
        ON TRIM(dim_industry.代码) = LEFT(TRIM(src.F270023), 1)
       AND dim_industry.表名 = '通用'
       AND dim_industry.字段名 = '行业门类'

    /* 左关联：授信情况（按客户ID分组，按授信状态降序、到期日降序取最近一笔） */
    LEFT JOIN (
        SELECT H130002, H130025, H130029,
               ROW_NUMBER() OVER (PARTITION BY H130002 ORDER BY H130022 DESC, H130012 DESC) AS rn
          FROM T_8_13
         WHERE H130023 = V_DATA_DATE
    ) latest_credit
        ON TRIM(latest_credit.H130002) = TRIM(src.F270002)
       AND latest_credit.rn = 1

    WHERE 1 = 1
      /* 筛选（1）：上月末贷款借据.贷款状态为 '01'[正常] 或 '05'[逾期] */
      AND EXISTS (
          SELECT 1
            FROM T_8_1 loan_prev
           WHERE TRIM(loan_prev.H010001) = TRIM(src.F270001)
             AND loan_prev.H010029 = V_PREV_MONTH_LAST
             AND TRIM(loan_prev.H010019) IN ('01', '05')
      )
      /* 筛选（2）：本期贷款借据.贷款状态为 '01'[正常] 或 '05'[逾期] */
      AND TRIM(loan.H010019) IN ('01', '05');

    COMMIT;
END;
