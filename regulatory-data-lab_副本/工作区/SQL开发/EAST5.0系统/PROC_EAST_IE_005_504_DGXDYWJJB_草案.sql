/*
业务目标：
- 依据原始业务需求《031_对公信贷业务借据表.md》生成 EAST5.0 对公信贷业务借据表（IE_005_504）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案（可执行，无 TODO 占位）。

依赖材料：
- 原始材料/业务需求/EAST5.0/031_对公信贷业务借据表.md
- 原始材料/表结构/EAST5.0系统/IE_005_504-对公信贷业务借据表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_27-贷款协议补充信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_1-贷款借据-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_8_12-五级分类状态-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_15-还款状态-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_7-贷款展期协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_6_2-贷款协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_10_1-公共代码-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_8_13-授信情况-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_2_1-对公客户基本情况-DDL-2026-04-27.sql
- 知识库/数据表/EAST5.0系统/数据表-IE_005_504-对公信贷业务借据表-EAST5.0系统.md
- 知识库/血缘/EAST5.0系统/血缘-IE_005_504-对公信贷业务借据表-EAST5.0系统.md
- 知识库/报表业务口径/EAST5.0系统/报表-IE_005_504-对公信贷业务借据表-EAST5.0系统.md

源表（角色说明）：
- T_6_27：贷款协议补充信息（主表，驱动粒度）
- T_8_15：还款状态（明细还款数据）
- T_8_1：贷款借据（本期余额、状态、利率）
- T_8_12：五级分类状态（最新分类，窗口去重）
- T_1_1：机构信息（机构名称、许可证号）
- T_6_2：贷款协议（管户员工ID）
- T_6_7：贷款展期协议（展期次数汇总）
- T_8_13：授信情况（最新授信额度，窗口去重）
- T_10_1：公共代码（行业门类转码）
- T_2_1：对公客户基本情况（客户名称）

目标表：
- IE_005_504：对公信贷业务借据表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 所有以机构名义在信贷业务中签订的借据信息。个体工商户、私营业主以机构名义办理的贷款计入本表，以个人名义办理的贷款不计入本表。表外业务只报送委托贷款（非现金管理项下），其他不报送。信用卡业务不报送。对于票据贴现和买断式转贴现，可以填报为信贷合同号=信贷借据号=票据号码；对于其他若没有对应借据号的业务，可以填报为信贷合同号=信贷借据号=业务编号。转贴、二级市场福费廷业务的借款人按照交易对手（同业）填报，贴现和信用证下融资的借款人按照贴现申请人、信用证融资人填报。借据状态为结清、核销、转让的可在报送最后状态的次月不再报送。

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 码值转换已按业务需求文档逐项补齐为 CASE 表达式。
- 缺口字段（GSFZJG、SENSITIVEFLAG、KHLB）因业务需求未给来源，仍置 NULL。
- 备注字段（BBZ）按需求文档要求拼接 6 个来源表的备注（以";"分隔）：T_6_2 贷款协议、T_6_7 贷款展期协议、T_6_27 贷款协议补充信息、T_8_1 贷款借据、T_8_12 五级分类状态、T_8_15 还款状态。T_10_1 公共代码无备注字段，实际拼接 5 个来源。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
- 表级规则：### 2.1 表级规则（Excel第 709 行） 取日期在当月且通过分户账号和币种关联贷款协议补充信息来筛选数据范围
- 上月末贷款借据状态过滤：需计算上月末日期，关联 T_8_1 取上月末数据判断贷款状态。
- 信贷员工号（XDYGH）：T_6_2 贷款协议.F020001 为协议ID，T_6_27.F270003 为协议ID，按协议ID关联。
- 是否科技贷款（SFKJDK）：需求文档要求取"科技相关产业类型"和"科技企业类型"，T_2_1 单一法人客户基本情况中对应字段待确认具体字段名，此处按 T_2_1 的 F010014（科技相关产业类型）和 F010015（科技企业类型）处理，若二者含有'1'则赋值为'是'。
- 贷款投向行业（DKTXHY）：需求文档要求按境内外标识、信贷业务种类和行业类型综合判断，T_6_27.F270033 为境内外贷款标识，F270023 为行业类型（按贷款投向划分），F270025 为信贷业务种类。
- 还款方式（HKFS）：需求文档要求取还款状态的还本方式（H150011）和还息方式（H150012）进行加工，以还本方式为主。还本方式中'(码值代码待定)'为业务需求原文，实际映射时暂按已知码值处理。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_504_DGXDYWJJB;

CREATE PROCEDURE PROC_EAST_IE_005_504_DGXDYWJJB(
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

    DELETE FROM IE_005_504
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_504 (
        DKYE,
        ZQS,
        ZQCS,
        DKDQRQ,
        QBRQ,
        BWQXYE,
        LXQKQS,
        DKRZZH,
        DKRZHM,
        LLLX,
        SJLL,
        HKFS,
        HKZHSSHMC,
        JXFS,
        XQYHLX,
        JJDKYT,
        DKTXHY,
        SFHLWDK,
        SFSNDK,
        SFPHXXWQYDK,
        XDYGH,
        CJRQ,
        QXRQ,
        LJQKQS,
        DKZT,
        RZZHSSHMC,
        HKZH,
        XQHKRQ,
        BZ,
        SBXDJJH,
        XQYHBJ,
        KHLB,
        DKTXDQ,
        SFLSDK,
        SFPHXSNDK,
        SFKJDK,
        BBZ,
        NBJGH,
        GSFZJG,
        MXKMBH,
        MXKMMC,
        KHMC,
        XDYWZL,
        SENSITIVEFLAG,
        DKWJFL,
        DQQS,
        DKFFRQ,
        ZJRQ,
        QBJE,
        BNQXYE,
        JRXKZH,
        YHJGMC,
        KHTYBH,
        XDHTH,
        XDJJH,
        DKFHZH,
        DKFFLX,
        FKFS,
        DKJE
    )
    SELECT
        /* 15. 贷款金额：贷款协议补充信息.F270009 */
        CAST(NULLIF(TRIM(src.F270009), '') AS DECIMAL(20,2)) AS DKJE,

        /* 1. 金融许可证号：机构信息.A010003 */
        org.A010003 AS JRXKZH,

        /* 2. 内部机构号：从贷款协议补充信息.机构ID第12位开始截取 */
        SUBSTR(TRIM(src.F270004), 12) AS NBJGH,

        /* 3. 银行机构名称：机构信息.A010005 */
        org.A010005 AS YHJGMC,

        /* 4. 明细科目编号：贷款协议补充信息.F270007 */
        src.F270007 AS MXKMBH,

        /* 5. 明细科目名称：贷款协议补充信息.F270008 */
        src.F270008 AS MXKMMC,

        /* 6. 客户统一编号：贷款协议补充信息.F270002 */
        src.F270002 AS KHTYBH,

        /* 7. 客户名称：对公客户基本情况.B010001，优先取对公客户名称 */
        cust.B010001 AS KHMC,

        /* 8. 信贷合同号：贷款协议补充信息.F270003 */
        src.F270003 AS XDHTH,

        /* 9. 信贷借据号：贷款协议补充信息.F270001 */
        src.F270001 AS XDJJH,

        /* 10. 贷款分户账号：贷款协议补充信息.F270005 */
        src.F270005 AS DKFHZH,

        /* 11. 信贷业务种类：代码转化 */
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

        /* 12. 贷款发放类型：代码转化 */
        CASE TRIM(src.F270010)
            WHEN '01' THEN '新增'
            WHEN '02' THEN '借新还旧'
            WHEN '03' THEN '重组贷款'
            WHEN '04' THEN '无还本续贷'
            WHEN '00' THEN '其他-自定义'
            ELSE src.F270010
        END AS DKFFLX,

        /* 13. 放款方式：代码转化 */
        CASE TRIM(src.F270037)
            WHEN '01' THEN '自主支付'
            WHEN '02' THEN '受托支付'
            WHEN '03' THEN '混合支付'
            WHEN '00' THEN '其他-自定义'
            ELSE src.F270037
        END AS FKFS,

        /* 14. 币种：贷款协议补充信息.F270006 */
        src.F270006 AS BZ,

        /* 16. 贷款余额：贷款借据.H010010 */
        CAST(NULLIF(TRIM(loan.H010010), '') AS DECIMAL(20,2)) AS DKYE,

        /* 17. 贷款五级分类：代码转化，取最新一条 */
        CASE TRIM(latest_class.H120005)
            WHEN '01' THEN '正常'
            WHEN '02' THEN '关注'
            WHEN '03' THEN '次级'
            WHEN '04' THEN '可疑'
            WHEN '05' THEN '损失'
            WHEN '00' THEN ''
            ELSE latest_class.H120005
        END AS DKWJFL,

        /* 18. 总期数：还款状态.H150007 */
        TRIM(repay.H150007) AS ZQS,

        /* 19. 当前期数：还款状态.H150006 */
        TRIM(repay.H150006) AS DQQS,

        /* 20. 展期次数：汇总取最大值，空则置0 */
        COALESCE(expansion.ZQ_SUM, 0) AS ZQCS,

        /* 21. 贷款发放日期：格式转换 YYYYMMDD */
        CASE WHEN src.F270016 IS NULL THEN '99991231'
              ELSE CONCAT(CAST(YEAR(src.F270016) AS VARCHAR(4)),
                          LPAD(CAST(MONTH(src.F270016) AS VARCHAR(2)), 2, '0'),
                          LPAD(CAST(DAY(src.F270016) AS VARCHAR(2)), 2, '0'))
        END AS DKFFRQ,

        /* 22. 贷款到期日期：格式转换 YYYYMMDD */
        CASE WHEN src.F270018 IS NULL THEN '99991231'
              ELSE CONCAT(CAST(YEAR(src.F270018) AS VARCHAR(4)),
                          LPAD(CAST(MONTH(src.F270018) AS VARCHAR(2)), 2, '0'),
                          LPAD(CAST(DAY(src.F270018) AS VARCHAR(2)), 2, '0'))
        END AS DKDQRQ,

        /* 23. 终结日期：格式转换 YYYYMMDD */
        CASE WHEN repay.H150025 IS NULL THEN '99991231'
              ELSE CONCAT(CAST(YEAR(repay.H150025) AS VARCHAR(4)),
                          LPAD(CAST(MONTH(repay.H150025) AS VARCHAR(2)), 2, '0'),
                          LPAD(CAST(DAY(repay.H150025) AS VARCHAR(2)), 2, '0'))
        END AS ZJRQ,

        /* 24. 欠本金额：还款状态.H150020 */
        CAST(NULLIF(TRIM(repay.H150020), '') AS DECIMAL(20,2)) AS QBJE,

        /* 25. 欠本日期：格式转换 YYYYMMDD */
        CASE WHEN repay.H150023 IS NULL THEN '99991231'
              ELSE CONCAT(CAST(YEAR(repay.H150023) AS VARCHAR(4)),
                          LPAD(CAST(MONTH(repay.H150023) AS VARCHAR(2)), 2, '0'),
                          LPAD(CAST(DAY(repay.H150023) AS VARCHAR(2)), 2, '0'))
        END AS QBRQ,

        /* 26. 表内欠息余额：还款状态.H150021 */
        CAST(NULLIF(TRIM(repay.H150021), '') AS DECIMAL(20,2)) AS BNQXYE,

        /* 27. 表外欠息余额：还款状态.H150022 */
        CAST(NULLIF(TRIM(repay.H150022), '') AS DECIMAL(20,2)) AS BWQXYE,

        /* 28. 欠息日期：格式转换 YYYYMMDD */
        CASE WHEN repay.H150024 IS NULL THEN '99991231'
              ELSE CONCAT(CAST(YEAR(repay.H150024) AS VARCHAR(4)),
                          LPAD(CAST(MONTH(repay.H150024) AS VARCHAR(2)), 2, '0'),
                          LPAD(CAST(DAY(repay.H150024) AS VARCHAR(2)), 2, '0'))
        END AS QXRQ,

        /* 29. 连续欠款期数：还款状态.H150018 */
        TRIM(repay.H150018) AS LXQKQS,

        /* 30. 累计欠款期数：还款状态.H150019 */
        TRIM(repay.H150019) AS LJQKQS,

        /* 31. 上笔信贷借据号：贷款协议补充信息.F270067，截取前100位 */
        LEFT(TRIM(src.F270067), 100) AS SBXDJJH,

        /* 32. 贷款入账账号：贷款协议补充信息.F270011 */
        src.F270011 AS DKRZZH,

        /* 33. 贷款入账户名：贷款协议补充信息.F270012 */
        src.F270012 AS DKRZHM,

        /* 34. 入账账号所属行名称：贷款协议补充信息.F270013 */
        src.F270013 AS RZZHSSHMC,

        /* 35. 利率类型：代码转化 */
        CASE TRIM(src.F270060)
            WHEN '02' THEN 'LPR'
            ELSE '非LPR'
        END AS LLLX,

        /* 36. 实际利率：贷款借据.H010021 */
        CAST(NULLIF(TRIM(loan.H010021), '') AS DECIMAL(20,6)) AS SJLL,

        /* 37. 还款方式：还本方式（H150011）为主，还息方式（H150012）为辅 */
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

        /* 38. 还款账号：贷款协议补充信息.F270014 */
        src.F270014 AS HKZH,

        /* 39. 还款账号所属行名称：贷款协议补充信息.F270015 */
        src.F270015 AS HKZHSSHMC,

        /* 40. 计息方式：代码转化 */
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

        /* 41. 下期还款日期：格式转换 YYYYMMDD */
        CASE WHEN repay.H150008 IS NULL THEN '99991231'
              ELSE CONCAT(CAST(YEAR(repay.H150008) AS VARCHAR(4)),
                          LPAD(CAST(MONTH(repay.H150008) AS VARCHAR(2)), 2, '0'),
                          LPAD(CAST(DAY(repay.H150008) AS VARCHAR(2)), 2, '0'))
        END AS XQHKRQ,

        /* 42. 下期应还本金：还款状态.H150009 */
        CAST(NULLIF(TRIM(repay.H150009), '') AS DECIMAL(20,2)) AS XQYHBJ,

        /* 43. 下期应还利息：还款状态.H150010 */
        CAST(NULLIF(TRIM(repay.H150010), '') AS DECIMAL(20,2)) AS XQYHLX,

        /* 44. 借据贷款用途：贷款协议补充信息.F270019 */
        src.F270019 AS JJDKYT,

        /* 45. 贷款投向地区：贷款协议补充信息.F270063 */
        src.F270063 AS DKTXDQ,

        /* 46. 贷款投向行业：复杂规则 */
        CASE
            WHEN TRIM(src.F270033) = '02' THEN '3.对境外贷款'
            WHEN TRIM(src.F270025) = '15' THEN '2.22买断式转贴现'
            WHEN TRIM(src.F270025) = '21' THEN '2.23买断其他票据类资产'
            ELSE COALESCE(dim_industry.CNAME, '')
        END AS DKTXHY,

        /* 47. 是否互联网贷款：代码转化 */
        CASE TRIM(src.F270031)
            WHEN '1' THEN '是'
            ELSE '否'
        END AS SFHLWDK,

        /* 48. 是否绿色贷款：规则映射 */
        CASE WHEN src.F270040 IS NOT NULL AND TRIM(src.F270040) <> '' AND TRIM(src.F270040) <> '0' THEN '是'
             ELSE '否'
        END AS SFLSDK,

        /* 49. 是否涉农贷款：代码转化 */
        CASE TRIM(src.F270042)
            WHEN '1' THEN '是'
            ELSE '否'
        END AS SFSNDK,

        /* 50. 是否普惠型涉农贷款：规则映射 */
        CASE TRIM(src.F270046)
            WHEN '01' THEN '是'
            WHEN '02' THEN '是'
            ELSE '否'
        END AS SFPHXSNDK,

        /* 51. 是否普惠型小微企业贷款：规则映射，关联授信情况 */
        CASE
            WHEN src.F270043 = '01' AND latest_credit.CREDIT_LIMIT <= 10000000 THEN '是'
            WHEN src.F270043 = '03' AND latest_credit.OPER_CREDIT_LIMIT <= 10000000 THEN '是'
            ELSE '否'
        END AS SFPHXXWQYDK,

        /* 52. 是否科技贷款：代码转化 */
        CASE
            WHEN TRIM(src.F270028) = '02' THEN '否'
            WHEN LENGTH(src.F270041) >= 4 AND (
                SUBSTR(TRIM(src.F270041), 1, 1) = '1' OR
                SUBSTR(TRIM(src.F270041), 2, 1) = '1' OR
                SUBSTR(TRIM(src.F270041), 3, 1) = '1' OR
                SUBSTR(TRIM(src.F270041), 4, 1) = '1'
            ) THEN '是'
            ELSE '否'
        END AS SFKJDK,

        /* 53. 信贷员工号：贷款协议.F020058 */
        agreement.F020058 AS XDYGH,

        /* 54. 采集日期：格式转换 YYYYMMDD */
        CONCAT(CAST(YEAR(src.F270069) AS VARCHAR(4)),
               LPAD(CAST(MONTH(src.F270069) AS VARCHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.F270069) AS VARCHAR(2)), 2, '0')) AS CJRQ,

        /* 55. 贷款状态：代码转化 */
        CASE TRIM(loan.H010019)
            WHEN '01' THEN '正常'
            WHEN '02' THEN '核销'
            WHEN '03' THEN '转让'
            WHEN '04' THEN '结清'
            WHEN '05' THEN '逾期'
            WHEN '00' THEN '其他-自定义'
            ELSE loan.H010019
        END AS DKZT,

        /* 56. 备注：6个来源表备注以";"拼接 */
        CONCAT_WS(';',
            src.F270068,
            loan.H010030,
            latest_class.H120015,
            repay.H150028,
            agreement.F020062,
            expansion.EXP_REMARK
        ) AS BBZ,

        /* 缺口字段：客户类别，业务需求未给来源 */
        NULL AS KHLB,

        /* 缺口字段：归属分支机构，业务需求未给来源 */
        NULL AS GSFZJG,

        /* 缺口字段：涉密标志，业务需求未给来源 */
        NULL AS SENSITIVEFLAG

    FROM T_6_27 src

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

    /* 左关联：对公客户基本情况（EAST对公客户信息表对应 T_2_1） */
    LEFT JOIN T_2_1 cust
        ON TRIM(cust.B010001) = TRIM(src.F270002)
       AND cust.B010018 = V_DATA_DATE

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
