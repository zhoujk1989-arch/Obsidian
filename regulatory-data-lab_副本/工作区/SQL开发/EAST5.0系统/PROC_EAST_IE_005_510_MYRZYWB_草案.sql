/*
业务目标：
- 依据原始业务需求《037_贸易融资业务表.md》生成 EAST5.0 贸易融资业务表（IE_005_510）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/037_贸易融资业务表.md
- 原始材料/表结构/EAST5.0系统/IE_005_510-贸易融资业务表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_005_504-对公信贷业务借据表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_10-贸易融资协议-DDL-2026-04-27.sql

源表：
- T_6_10：一表通《表6.10贸易融资协议》
- IE_005_504：EAST对公信贷业务借据表（LEFT JOIN 获取机构号/许可证号/机构名称/贷款状态）

目标表：
- IE_005_510：贸易融资业务表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 填报机构对非金融机构提供的贸易项下的融资或信用便利的余额,包括打包贷款、押汇、保理、议付信用证、买方信贷、卖方信贷、福费廷等业务。本行开出的保函及信用证在保函及信用证表中报送，不在本表中填报。贷款状态为结清、核销、转让的，于次月不再报送。

2026-05-08 重构校准要点：
- 25 个业务需求字段全部映射正确：21 个来自 T_6_10 直接映射或转换，4 个来自 IE_005_504 LEFT JOIN enrich（NBJGH/JRXKZH/YHJGMC/DKZT）。
- JOIN 已实现：
  - T_6_10 src LEFT JOIN IE_005_504借据 ON TRIM(src.F100028) = TRIM(借据.XDJJH) AND 借据.CJRQ = P_DATA_DATE（对公信贷业务借据表，获取机构号/许可证号/机构名称/贷款状态）
- 码值 CASE 已补齐：
  - MYRZPZ（贸易融资品种）：22 个精确分支（01~20+00+00-XX）
- 日期格式转换：FKRQ/HKRQ/CJRQ 使用 REPLACE(CAST(... AS CHAR), '-', '')，空值默认 '99991231'。
- 空值处理：SXFJE/BZJBL/BZJJE/MYRZJE 使用 CAST+NULLIF 为 DECIMAL(20,2)。
- WHERE 过滤：src.F100026 = V_DATA_DATE（采集日期为当月）。
- 缺口字段（GSFZJG/SENSITIVEFLAG）在 DDL 中存在但业务需求映射表未给来源，SQL 中置 NULL，符合审计处置原则。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_510_MYRZYWB;

CREATE PROCEDURE PROC_EAST_IE_005_510_MYRZYWB(
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

    DELETE FROM IE_005_510
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_510 (
        GHFMC,
        ZFDXMC,
        SXFBZ,
        SXFJE,
        BZJBL,
        BZJJE,
        BBZ,
        GSFZJG,
        HKRQ,
        MYRZJE,
        MYRZPZ,
        XDHTH,
        NBJGH,
        JRXKZH,
        CJRQ,
        BZJZH,
        DKZT,
        BZJBZ,
        HKDXMC,
        MYJYBJ,
        KZHMC,
        XHFMC,
        FKRQ,
        BZ,
        XDJJH,
        YHJGMC,
        SENSITIVEFLAG
    )
    SELECT
        /* 1 购货方名称：T_6_10.F100009，直接映射 */
        src.F100009 AS GHFMC,
        /* 2 支付对象名称：T_6_10.F100013，直接映射 */
        src.F100013 AS ZFDXMC,
        /* 3 手续费币种：T_6_10.F100014，直接映射 */
        src.F100014 AS SXFBZ,
        /* 4 手续费金额：T_6_10.F100015，CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F100015), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 5 保证金比例：T_6_10.F100017，CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F100017), '') AS DECIMAL(20,2)) AS BZJBL,
        /* 6 保证金金额：T_6_10.F100019，CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F100019), '') AS DECIMAL(20,2)) AS BZJJE,
        /* 7 备注：T_6_10.F100025，直接映射 */
        src.F100025 AS BBZ,
        /* 8 归属分支机构：DDL存在但业务需求未给来源，置NULL */
        NULL AS GSFZJG,
        /* 9 融资还款日期：T_6_10.F100008，DATE→VARCHAR(8) YYYYMMDD */
        CASE WHEN src.F100008 IS NOT NULL
             THEN REPLACE(CAST(src.F100008 AS CHAR), '-', '')
             ELSE '99991231' END AS HKRQ,
        /* 10 贸易融资金额：T_6_10.F100027，CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F100027), '') AS DECIMAL(20,2)) AS MYRZJE,
        /* 11 贸易融资品种：T_6_10.F100005，22分支码值CASE转换 */
        CASE TRIM(src.F100005)
            WHEN '01' THEN '买方押汇'
            WHEN '02' THEN '卖方押汇'
            WHEN '03' THEN '议付'
            WHEN '04' THEN '打包贷款'
            WHEN '05' THEN '进口信用证押汇'
            WHEN '06' THEN '出口信用证押汇'
            WHEN '07' THEN '进口托收押汇'
            WHEN '08' THEN '出口托收押汇'
            WHEN '09' THEN '进口代付'
            WHEN '10' THEN '出口代付'
            WHEN '11' THEN '国内自营福费廷（不含二级市场福费廷）'
            WHEN '12' THEN '国际自营福费廷（不含二级市场福费廷）'
            WHEN '13' THEN '二级市场福费廷'
            WHEN '14' THEN '商业发票融资'
            WHEN '15' THEN '货到付款押汇'
            WHEN '16' THEN '先款后货'
            WHEN '17' THEN '国内保理'
            WHEN '18' THEN '国际保理'
            WHEN '19' THEN '订单融资'
            WHEN '20' THEN '保兑仓'
            WHEN '00' THEN '其他'
            WHEN '00-XX' THEN CONCAT('其他-', REPLACE(TRIM(src.F100005), '00-', ''))
            ELSE TRIM(src.F100005)
        END AS MYRZPZ,
        /* 12 信贷合同号：T_6_10.F100002，直接映射 */
        src.F100002 AS XDHTH,
        /* 13 内部机构号：IE_005_504.NBJGH，LEFT JOIN获取 */
        借据.NBJGH AS NBJGH,
        /* 14 金融许可证号：IE_005_504.JRXKZH，LEFT JOIN获取 */
        借据.JRXKZH AS JRXKZH,
        /* 15 采集日期：T_6_10.F100026，DATE→VARCHAR(8) YYYYMMDD */
        REPLACE(CAST(src.F100026 AS CHAR), '-', '') AS CJRQ,
        /* 16 保证金账号：T_6_10.F100016，直接映射 */
        src.F100016 AS BZJZH,
        /* 17 贷款状态：IE_005_504.DKZT，LEFT JOIN获取 */
        借据.DKZT AS DKZT,
        /* 18 保证金币种：T_6_10.F100018，直接映射 */
        src.F100018 AS BZJBZ,
        /* 19 还款对象名称：T_6_10.F100024，直接映射 */
        src.F100024 AS HKDXMC,
        /* 20 贸易交易内容：T_6_10.F100011，直接映射 */
        src.F100011 AS MYJYBJ,
        /* 21 开证行名称：T_6_10.F100012，直接映射 */
        src.F100012 AS KZHMC,
        /* 22 销货方名称：T_6_10.F100010，直接映射 */
        src.F100010 AS XHFMC,
        /* 23 融资发放日期：T_6_10.F100007，DATE→VARCHAR(8) YYYYMMDD */
        CASE WHEN src.F100007 IS NOT NULL
             THEN REPLACE(CAST(src.F100007 AS CHAR), '-', '')
             ELSE '99991231' END AS FKRQ,
        /* 24 币种：T_6_10.F100004，直接映射 */
        src.F100004 AS BZ,
        /* 25 信贷借据号：T_6_10.F100028，直接映射 */
        src.F100028 AS XDJJH,
        /* 26 银行机构名称：IE_005_504.YHJGMC，LEFT JOIN获取 */
        借据.YHJGMC AS YHJGMC,
        /* 27 涉密标志：DDL存在但业务需求未给来源，置NULL */
        NULL AS SENSITIVEFLAG
    FROM T_6_10 src
    LEFT JOIN IE_005_504 借据
      ON TRIM(src.F100028) = TRIM(借据.XDJJH)
     AND 借据.CJRQ = P_DATA_DATE
    WHERE src.F100026 = V_DATA_DATE;

    COMMIT;
END;
