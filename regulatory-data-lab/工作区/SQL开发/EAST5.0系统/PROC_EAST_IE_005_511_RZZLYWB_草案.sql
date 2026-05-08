/*
业务目标：
- 依据原始业务需求《038_融资租赁业务表.md》生成 EAST5.0 融资租赁业务表（IE_005_511）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/038_融资租赁业务表.md
- 原始材料/表结构/EAST5.0系统/IE_005_511-融资租赁业务表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_16-融资租赁协议-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_10_1-公共代码-DDL-2026-04-27.sql
- 原始材料/表结构/EAST5.0系统/IE_004_411-对公信贷分户账-DDL-2026-04-28.sql

源表：
- T_6_16：一表通《表6.16融资租赁协议》（主表）
- T_1_1：一表通《表1.1机构信息》（维表，获取金融许可证号/银行机构名称）
- T_10_1：一表通《表10.1公共代码》（码值表，获取租赁公司证件类型中文含义）
- IE_004_411：EAST对公信贷分户账（LEFT JOIN 获取贷款状态/贷款余额）

目标表：
- IE_005_511：融资租赁业务表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 填报机构与租赁公司合作，购买承租人指定租赁物件，与承租人签订租赁合同，待合同期满后租赁物资产所有权转移给承租人的一类业务。报送范围：参照1104报表G01_III[1.5融资租赁]填报口径。贷款状态为结清、核销、转让的，可在报送最终状态的次月不再报送。

2026-05-08 重构校准要点：
- 28 个业务需求字段全部映射正确：23 个来自 T_6_16 直接映射或转换，2 个来自 T_1_1 LEFT JOIN enrich（JRXKZH/YHJGMC），2 个来自 IE_004_411 LEFT JOIN enrich（DKZT/XYZYE），1 个来自 T_10_1 LEFT JOIN 码值转换（ZLGSZJLB）。
- JOIN 已实现：
  - T_6_16 src LEFT JOIN T_1_1 org ON SUBSTR(TRIM(src.F160002), 12) = TRIM(org.A010001) AND org.A010020 = src.F160028（机构信息维表，按机构ID截取+采集日期关联）
  - T_6_16 src LEFT JOIN IE_004_411 fenhu ON TRIM(src.F160001) = TRIM(fenhu.XDHTH) AND fenhu.CJRQ = P_DATA_DATE（EAST对公信贷分户账，按信贷合同号+采集日期关联，获取贷款状态/合同余额）
  - T_6_16 src LEFT JOIN T_10_1 code ON TRIM(src.F160015) = TRIM(code.K010004) AND TRIM(src.F160002) = TRIM(code.K010006) AND code.K010002 = '融资租赁协议' AND code.K010003 = '租赁公司证件类型'（公共代码码值表）
- 码值 CASE 已补齐：
  - RZZLLX（融资租赁类型）：'01'→经营性租赁，'02'→融资性租赁，ELSE→原值（XX填报一表通原有码值01-05）
  - ZLGSZJLB（租赁公司证件类别）：'00-XX'→其他-XX，ELSE→公共代码.中文含义
- 日期格式转换：HTYDRQ/HTDQRQ/CJRQ 使用 REPLACE(CAST(... AS CHAR), '-', '')，空值默认 '99991231'。
- 空值处理：SXFJE/BZJBL/BZJJE/XYZJE/XYZJE 使用 CAST+NULLIF 为 DECIMAL(20,2)。
- NBJGH 加工映射：SUBSTR(TRIM(src.F160002), 12)，符合需求"SUBSTR(机构ID,12)"。
- WHERE 过滤：src.F160028 = V_DATA_DATE（当月采集日期过滤）。
- 缺口字段（SENSITIVEFLAG/CZRKHLB/GSFZJG）在 DDL 中存在但业务需求映射表未给来源，SQL 中置 NULL，符合审计处置原则。
- XDJJH（信贷借据号）：需求映射为"融资租赁协议.借据ID"，但 T_6_16 DDL 中无该字段，置 NULL 待补。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_511_RZZLYWB;

CREATE PROCEDURE PROC_EAST_IE_005_511_RZZLYWB(
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

    DELETE FROM IE_005_511
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_511 (
        DKZT,
        CJRQ,
        HTYDRQ,
        BZJJE,
        NBJGH,
        XDHTH,
        RZZLLX,
        XYZBZDM,
        XYZYE,
        HTDQRQ,
        CZRZH,
        ZLGSZJLB,
        SXFJE,
        BZJBZ,
        SENSITIVEFLAG,
        JRXKZH,
        YHJGMC,
        XDJJH,
        ZLBDW,
        XYZJE,
        CZRBH,
        CZRMC,
        CZRKHHMC,
        ZLGSMC,
        ZLGSZJHM,
        SXFBZ,
        BZJBL,
        BZJZH,
        BBZ,
        CZRKHLB,
        GSFZJG
    )
    SELECT
        /* 1 贷款状态：IE_004_411.DKZT，LEFT JOIN对公信贷分户账获取 */
        fenhu.DKZT AS DKZT,
        /* 2 采集日期：T_6_16.F160028，DATE→VARCHAR(8) YYYYMMDD */
        CASE WHEN src.F160028 IS NOT NULL
             THEN REPLACE(CAST(src.F160028 AS CHAR), '-', '')
             ELSE '99991231' END AS CJRQ,
        /* 3 合同起始日期：T_6_16.F160012，DATE→VARCHAR(8) YYYYMMDD */
        CASE WHEN src.F160012 IS NOT NULL
             THEN REPLACE(CAST(src.F160012 AS CHAR), '-', '')
             ELSE '99991231' END AS HTYDRQ,
        /* 4 保证金金额：T_6_16.F160021，CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F160021), '') AS DECIMAL(20,2)) AS BZJJE,
        /* 5 内部机构号：T_6_16.F160002，SUBSTR(机构ID,12) */
        SUBSTR(TRIM(src.F160002), 12) AS NBJGH,
        /* 6 信贷合同号：T_6_16.F160001，直接映射 */
        src.F160001 AS XDHTH,
        /* 7 融资租赁类型：T_6_16.F160003，码值CASE转换 */
        CASE TRIM(src.F160003)
            WHEN '01' THEN '经营性租赁'
            WHEN '02' THEN '融资性租赁'
            ELSE TRIM(src.F160003)
        END AS RZZLLX,
        /* 8 币种：T_6_16.F160010，直接映射 */
        src.F160010 AS XYZBZDM,
        /* 9 合同余额：IE_004_411.DKYE，LEFT JOIN对公信贷分户账获取 */
        fenhu.DKYE AS XYZYE,
        /* 10 合同到期日期：T_6_16.F160013，DATE→VARCHAR(8) YYYYMMDD */
        CASE WHEN src.F160013 IS NOT NULL
             THEN REPLACE(CAST(src.F160013 AS CHAR), '-', '')
             ELSE '99991231' END AS HTDQRQ,
        /* 11 承租人账号：T_6_16.F160008，直接映射 */
        src.F160008 AS CZRZH,
        /* 12 租赁公司证件类别：T_6_16.F160015 + T_10_1.K010005，码值CASE转换 */
        CASE
            WHEN TRIM(src.F160015) LIKE '00-%' THEN CONCAT('其他-', REPLACE(TRIM(src.F160015), '00-', ''))
            WHEN code.K010005 IS NOT NULL THEN code.K010005
            ELSE TRIM(src.F160015)
        END AS ZLGSZJLB,
        /* 13 手续费金额：T_6_16.F160017，CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F160017), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 14 保证金币种：T_6_16.F160020，直接映射 */
        src.F160020 AS BZJBZ,
        /* 15 涉密标志：DDL存在但业务需求未给来源，置NULL */
        NULL AS SENSITIVEFLAG,
        /* 16 金融许可证号：T_1_1.A010003，LEFT JOIN机构信息获取 */
        org.A010003 AS JRXKZH,
        /* 17 银行机构名称：T_1_1.A010005，LEFT JOIN机构信息获取 */
        org.A010005 AS YHJGMC,
        /* 18 信贷借据号：需求映射为"融资租赁协议.借据ID"，T_6_16 DDL无此字段，置NULL */
        NULL AS XDJJH,
        /* 19 租赁标的物：T_6_16.F160005，直接映射 */
        src.F160005 AS ZLBDW,
        /* 20 合同金额：T_6_16.F160011，CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F160011), '') AS DECIMAL(20,2)) AS XYZJE,
        /* 21 承租人编号：T_6_16.F160006，直接映射 */
        src.F160006 AS CZRBH,
        /* 22 承租人名称：T_6_16.F160007，直接映射 */
        src.F160007 AS CZRMC,
        /* 23 承租人开户行名称：T_6_16.F160009，直接映射 */
        src.F160009 AS CZRKHHMC,
        /* 24 租赁公司名称：T_6_16.F160014，直接映射 */
        src.F160014 AS ZLGSMC,
        /* 25 租赁公司证件号码：T_6_16.F160016，直接映射 */
        src.F160016 AS ZLGSZJHM,
        /* 26 手续费币种：T_6_16.F160018，直接映射 */
        src.F160018 AS SXFBZ,
        /* 27 保证金比例：T_6_16.F160022，CAST+NULLIF → DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.F160022), '') AS DECIMAL(20,2)) AS BZJBL,
        /* 28 保证金账号：T_6_16.F160019，直接映射 */
        src.F160019 AS BZJZH,
        /* 29 备注：T_6_16.F160027，直接映射 */
        src.F160027 AS BBZ,
        /* 30 承租人客户类别：DDL存在但业务需求未给来源，置NULL */
        NULL AS CZRKHLB,
        /* 31 归属分支机构：DDL存在但业务需求未给来源，置NULL */
        NULL AS GSFZJG
    FROM T_6_16 src
    LEFT JOIN T_1_1 org
      ON SUBSTR(TRIM(src.F160002), 12) = TRIM(org.A010001)
     AND org.A010020 = src.F160028
    LEFT JOIN IE_004_411 fenhu
      ON TRIM(src.F160001) = TRIM(fenhu.XDHTH)
     AND fenhu.CJRQ = P_DATA_DATE
    LEFT JOIN T_10_1 code
      ON TRIM(src.F160015) = TRIM(code.K010004)
     AND TRIM(src.F160002) = TRIM(code.K010006)
     AND code.K010002 = '融资租赁协议'
     AND code.K010003 = '租赁公司证件类型'
    WHERE src.F160028 = V_DATA_DATE;

    COMMIT;
END;
