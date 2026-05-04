/*
草案质量状态：不合格，禁止直接执行。
原因：本文件仍存在未实现的 JOIN、WHERE 或 CASE 转换占位，必须按原始业务需求逐项重写并复核后才能作为可运行草案。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

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

源表：
- T_1_1, T_6_16, T_10_1

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

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 922 行） 取日期在当月且通过信贷合同号关联生成EAST对公信贷分户账来筛选范围

未确认点：
- 一表通中文来源表已按本仓库 DDL 文件名反查为 T_... 物理表；现场库名、模式名和字段类型需复核。
- 复杂关联条件、筛选条件和窗口去重规则已保留在注释中；本草案中无法自动确定的 JOIN 使用 ON 1 = 1 TODO 占位，投产前必须替换为业务键。
- 码值转换、备注拼接、多源择优、终态纳入规则如未能由规则自动转成 CASE，已在字段注释中标记，需要人工复核。
- SQL 草案尚未在 GBase 环境执行验证，目标页和血缘状态应保持 draft。
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
        /* 贷款状态：待确认来源字段：EAST.对公信贷分户账.贷款状态 */
        NULL AS DKZT,
        /* 采集日期：融资租赁协议.采集日期 -> T_6_16.F160028；加工映射：日期转YYYYMMDD格式 */
        CONCAT(CAST(YEAR(s1.F160028) AS VARCHAR(4)), LPAD(CAST(MONTH(s1.F160028) AS VARCHAR(2)), 2, '0'), LPAD(CAST(DAY(s1.F160028) AS VARCHAR(2)), 2, '0')) AS CJRQ,
        /* 合同起始日期：融资租赁协议.合同起始日期 -> T_6_16.F160012；直接映射 */
        s1.F160012 AS HTYDRQ,
        /* 保证金金额：融资租赁协议.保证金金额 -> T_6_16.F160021；直接映射 */
        CAST(NULLIF(TRIM(s1.F160021), '') AS DECIMAL(20,2)) AS BZJJE,
        /* 内部机构号：融资租赁协议.机构ID -> T_6_16.F160002；加工映射：SUBSTR(机构ID,12) */
        s1.F160002 AS NBJGH,
        /* 信贷合同号：融资租赁协议.协议ID -> T_6_16.F160001；直接映射 */
        s1.F160001 AS XDHTH,
        /* 融资租赁类型：融资租赁协议.融资租赁类型 -> T_6_16.F160003；当 【融资租赁协议】.【融资租赁类型】 = '01XX' 取 '经营性租赁' 当 【融资租赁协议】.【融资租赁类型】 = '02XX' 取 '融资性租赁' XX填报一表通原有的码值，01-05；转换规则需人工补齐 CASE 分支 */
        s1.F160003 AS RZZLLX,
        /* 币种：融资租赁协议.协议币种 -> T_6_16.F160010；直接映射 */
        s1.F160010 AS XYZBZDM,
        /* 合同余额：待确认来源字段：EAST.对公信贷分户账.贷款余额 */
        NULL AS XYZYE,
        /* 合同到期日期：融资租赁协议.合同到期日期 -> T_6_16.F160013；直接映射 */
        s1.F160013 AS HTDQRQ,
        /* 承租人账号：融资租赁协议.承租人账号 -> T_6_16.F160008；直接映射 */
        s1.F160008 AS CZRZH,
        /* 租赁公司证件类别：待确认来源字段：融资租赁协议\.公共代码 */
        NULL AS ZLGSZJLB,
        /* 手续费金额：融资租赁协议.手续费金额 -> T_6_16.F160017；直接映射 */
        CAST(NULLIF(TRIM(s1.F160017), '') AS DECIMAL(20,2)) AS SXFJE,
        /* 保证金币种：融资租赁协议.保证金币种 -> T_6_16.F160020；直接映射 */
        s1.F160020 AS BZJBZ,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS SENSITIVEFLAG,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        src.A010003 AS JRXKZH,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        src.A010005 AS YHJGMC,
        /* 信贷借据号：待确认来源字段：融资租赁协议.借据ID */
        NULL AS XDJJH,
        /* 租赁标的物：融资租赁协议.租赁标的物 -> T_6_16.F160005；直接映射 */
        s1.F160005 AS ZLBDW,
        /* 合同金额：融资租赁协议.合同金额 -> T_6_16.F160011；直接映射 */
        CAST(NULLIF(TRIM(s1.F160011), '') AS DECIMAL(20,2)) AS XYZJE,
        /* 承租人编号：融资租赁协议.承租人编号 -> T_6_16.F160006；直接映射 */
        s1.F160006 AS CZRBH,
        /* 承租人名称：融资租赁协议.承租人名称 -> T_6_16.F160007；直接映射 */
        s1.F160007 AS CZRMC,
        /* 承租人开户行名称：融资租赁协议.承租人开户行名称 -> T_6_16.F160009；直接映射 */
        s1.F160009 AS CZRKHHMC,
        /* 租赁公司名称：融资租赁协议.租赁公司名称 -> T_6_16.F160014；直接映射 */
        s1.F160014 AS ZLGSMC,
        /* 租赁公司证件号码：融资租赁协议.租赁公司证件号码 -> T_6_16.F160016；直接映射 */
        s1.F160016 AS ZLGSZJHM,
        /* 手续费币种：融资租赁协议.手续费币种 -> T_6_16.F160018；直接映射 */
        s1.F160018 AS SXFBZ,
        /* 保证金比例：融资租赁协议.保证金比例 -> T_6_16.F160022；直接映射 */
        CAST(NULLIF(TRIM(s1.F160022), '') AS DECIMAL(20,2)) AS BZJBL,
        /* 保证金账号：融资租赁协议.保证金账号 -> T_6_16.F160019；直接映射 */
        s1.F160019 AS BZJZH,
        /* 备注：融资租赁协议.备注 -> T_6_16.F160027；提取一表通《表6.16融资租赁协议》备注，以“;”拼接。 */
        s1.F160027 AS BBZ,
        /* 承租人客户类别：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS CZRKHLB,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，待确认 */
        NULL AS GSFZJG
    FROM T_1_1 src
    LEFT JOIN T_6_16 s1
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s1 的业务关联键，避免笛卡尔积 */
    LEFT JOIN T_10_1 s2
           ON 1 = 1 /* TODO: 按需求文档表级规则补齐 src 与 s2 的业务关联键，避免笛卡尔积 */
    WHERE 1 = 1
      /* TODO: 按《038_融资租赁业务表.md》补齐采集日期、当月数据、终态纳入和排除条件。 */;

    COMMIT;
END;
