/*
业务目标：
- 依据原始业务需求《025_个人信贷分户账明细记录.md》生成 EAST5.0 个人信贷分户账明细记录（IE_004_410_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/025_个人信贷分户账明细记录.md
- 原始材料/表结构/EAST5.0系统/IE_004_410_INC-个人信贷分户账明细记录-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_7_2-信贷交易-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_201-个人基础信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_409-个人信贷分户账-DDL-2026-04-28.sql

源表：
- T_7_2（信贷交易）：主数据源，所有交易明细均来自此表
- IE_004_409（个人信贷分户账）：驱动表，通过分户账号关联校验
- T_1_1（机构信息）：维表，取金融许可证号、银行机构名称
- IE_002_201（个人基础信息表）：维表，取账户名称、证件类别、证件号码

目标表：
- IE_004_410_INC：个人信贷分户账明细记录。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 增量追加或按采集日期重跑；当前草案采用按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 所有影响个人信贷账户余额或利息变动的交易信息，包括还本、还息，不包括查询交易。贷款核销或者转让（包括资产证券化）也应该在本表体现：明细科目填报本金科目，交易金额为核销或转让前本金余额，余额填报为0，交易对手填写借款人自身信息，摘要中标明核销或者转让交易。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 525 行）
通过【信贷交易】的【分户账号】内关联已完成一表通转换的【个人信贷分户账】的【分户账号】，取【信贷交易】.【采集日期】为当月的数据

已实现项：
- 3 个 LEFT JOIN 已实现（IE_004_409 分户账/T_1_1 机构信息/IE_002_201 个人基础信息表）
- WHERE 过滤 src.G020030 = V_DATA_DATE（采集日期为当月）
- 7 个码值 CASE 已补齐（JYLX 4分支/JYJDBZ 2分支/JYQD 8分支+通配/CBMBZ 2分支/XZBZ 2分支/HXJYSJ 格式转换/CJRQ 格式转换）
- 3 个 NULL 赋值（GSFZJG、SENSITIVEFLAG、DFKHLB）为 DDL 存在但业务需求未给来源的字段，符合处置原则
- DBRKHLB（代办人客户类别）同样无来源字段，置 NULL
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_410_INC_GRXDFHZMX;

CREATE PROCEDURE PROC_EAST_IE_004_410_INC_GRXDFHZMX(
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

    DELETE FROM IE_004_410_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_410_INC (
        DFHM,
        DFXM,
        ZY,
        CBMBZ,
        DBRXM,
        DBRZJHM,
        JYGYH,
        XZBZ,
        CJRQ,
        DFKHLB,
        DBRKHLB,
        JYXLH,
        JRXKZH,
        YHJGMC,
        MXKMMC,
        KHTYBH,
        ZJLB,
        DKFHZH,
        XDJJH,
        JYJDBZ,
        JYJE,
        DFZH,
        SENSITIVEFLAG,
        DFXH,
        GSFZJG,
        JYQD,
        DBRZJLB,
        SQGYH,
        BBZ,
        HXJYSJ,
        BZ,
        NBJGH,
        YWBLJGH,
        MXKMBH,
        ZHMC,
        ZJHM,
        HXJYRQ,
        JYLX,
        ZHYE
    )
    SELECT
        /* 1. 对方户名：信贷交易.对方户名 -> T_7_2.G020018；直接映射 */
        src.G020018 AS DFHM,

        /* 2. 对方行名：信贷交易.对方行名 -> T_7_2.G020020；直接映射 */
        src.G020020 AS DFXM,

        /* 3. 摘要：信贷交易.摘要 -> T_7_2.G020029；直接映射 */
        src.G020029 AS ZY,

        /* 4. 冲补抹标志：信贷交易.冲补抹标识 -> T_7_2.G020021；代码转化 */
        CASE TRIM(src.G020021)
            WHEN '01' THEN '正常'
            WHEN '02' THEN '冲补抹'
            ELSE src.G020021
        END AS CBMBZ,

        /* 5. 代办人姓名：信贷交易.代办人姓名 -> T_7_2.G020025；直接映射 */
        src.G020025 AS DBRXM,

        /* 6. 代办人证件号码：信贷交易.代办人证件号码 -> T_7_2.G020027；直接映射 */
        src.G020027 AS DBRZJHM,

        /* 7. 交易柜员号：信贷交易.经办员工ID -> T_7_2.G020022；加工映射，如为"自动"则转为空 */
        CASE WHEN TRIM(src.G020022) = '自动' THEN NULL ELSE TRIM(src.G020022) END AS JYGYH,

        /* 8. 现转标志：信贷交易.现转标识 -> T_7_2.G020028；代码转化 */
        CASE TRIM(src.G020028)
            WHEN '01' THEN '现'
            WHEN '02' THEN '转'
            ELSE src.G020028
        END AS XZBZ,

        /* 9. 采集日期：信贷交易.采集日期 -> T_7_2.G020030；格式转换 YYYYMMDD */
        CONCAT(CAST(YEAR(src.G020030) AS CHAR(4)),
               LPAD(CAST(MONTH(src.G020030) AS CHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.G020030) AS CHAR(2)), 2, '0')) AS CJRQ,

        /* 10. 对方客户类别：DDL 存在，业务需求未给来源，置 NULL */
        NULL AS DFKHLB,

        /* 11. 代办人客户类别：DDL 存在，业务需求未给来源，置 NULL */
        NULL AS DBRKHLB,

        /* 12. 交易序列号：信贷交易.交易ID -> T_7_2.G020001；直接映射 */
        src.G020001 AS JYXLH,

        /* 13. 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；加工映射 */
        s1.A010003 AS JRXKZH,

        /* 14. 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；加工映射 */
        s1.A010005 AS YHJGMC,

        /* 15. 明细科目名称：信贷交易.科目名称 -> T_7_2.G020014；直接映射 */
        src.G020014 AS MXKMMC,

        /* 16. 客户统一编号：信贷交易.客户ID -> T_7_2.G020004；直接映射 */
        src.G020004 AS KHTYBH,

        /* 17. 证件类别：EAST个人基础信息表.证件类别 -> IE_002_201.ZJLB；加工映射 */
        s2.ZJLB AS ZJLB,

        /* 18. 贷款分户账号：信贷交易.分户账号 -> T_7_2.G020003；直接映射 */
        src.G020003 AS DKFHZH,

        /* 19. 信贷借据号：信贷交易.借据ID -> T_7_2.G020006；直接映射 */
        src.G020006 AS XDJJH,

        /* 20. 交易借贷标志：信贷交易.借贷标识 -> T_7_2.G020015；代码转化 */
        CASE TRIM(src.G020015)
            WHEN '01' THEN '借'
            WHEN '02' THEN '贷'
            ELSE src.G020015
        END AS JYJDBZ,

        /* 21. 交易金额：信贷交易.交易金额 -> T_7_2.G020009；直接映射，转 DECIMAL */
        CAST(NULLIF(TRIM(src.G020009), '') AS DECIMAL(20,2)) AS JYJE,

        /* 22. 对方账号：信贷交易.对方账号 -> T_7_2.G020017；直接映射 */
        src.G020017 AS DFZH,

        /* 23. 涉密标志：DDL 存在，业务需求未给来源，置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 24. 对方行号：信贷交易.对方账号行号 -> T_7_2.G020019；直接映射 */
        src.G020019 AS DFXH,

        /* 25. 归属分支机构：DDL 存在，业务需求未给来源，置 NULL */
        NULL AS GSFZJG,

        /* 26. 交易渠道：信贷交易.交易渠道 -> T_7_2.G020024；代码转化 */
        CASE TRIM(src.G020024)
            WHEN '01' THEN '柜面'
            WHEN '02' THEN 'ATM'
            WHEN '03' THEN 'VTM'
            WHEN '04' THEN 'POS'
            WHEN '05' THEN '网银'
            WHEN '06' THEN '手机银行'
            WHEN '07' THEN '第三方支付'
            WHEN '08' THEN '银联交易'
            WHEN '00' THEN REPLACE(TRIM(src.G020024), '00', '其他')
            ELSE src.G020024
        END AS JYQD,

        /* 27. 代办人证件类别：信贷交易.代办人证件类型 -> T_7_2.G020026；直接映射 */
        src.G020026 AS DBRZJLB,

        /* 28. 授权柜员号：信贷交易.授权员工ID -> T_7_2.G020023；加工映射，如为"自动"则转为空 */
        CASE WHEN TRIM(src.G020023) = '自动' THEN NULL ELSE TRIM(src.G020023) END AS SQGYH,

        /* 29. 备注：信贷交易.备注 -> T_7_2.G020032；直接映射 */
        src.G020032 AS BBZ,

        /* 30. 核心交易时间：信贷交易.核心交易时间 -> T_7_2.G020008；格式转换 HH:MM:SS -> HHMMSS */
        REPLACE(REPLACE(CAST(src.G020008 AS CHAR(8)), ':', ''), ' ', '') AS HXJYSJ,

        /* 31. 币种：信贷交易.币种 -> T_7_2.G020011；直接映射 */
        src.G020011 AS BZ,

        /* 32. 内部机构号：信贷交易.入账机构ID -> T_7_2.G020031；从第12位开始截取 */
        SUBSTR(TRIM(src.G020031), 12) AS NBJGH,

        /* 33. 业务办理机构号：信贷交易.交易机构ID -> T_7_2.G020005；从第12位开始截取 */
        SUBSTR(TRIM(src.G020005), 12) AS YWBLJGH,

        /* 34. 明细科目编号：信贷交易.科目ID -> T_7_2.G020013；直接映射 */
        src.G020013 AS MXKMBH,

        /* 35. 账户名称：EAST个人基础信息表.客户姓名 -> IE_002_201.KHXM；加工映射 */
        s2.KHXM AS ZHMC,

        /* 36. 证件号码：EAST个人基础信息表.证件号码 -> IE_002_201.ZJHM；加工映射 */
        s2.ZJHM AS ZJHM,

        /* 37. 核心交易日期：信贷交易.核心交易日期 -> T_7_2.G020007；格式转换 YYYY-MM-DD -> YYYYMMDD，默认 99991231 */
        CASE WHEN src.G020007 IS NULL THEN '99991231'
             ELSE CONCAT(CAST(YEAR(src.G020007) AS CHAR(4)),
                        LPAD(CAST(MONTH(src.G020007) AS CHAR(2)), 2, '0'),
                        LPAD(CAST(DAY(src.G020007) AS CHAR(2)), 2, '0'))
        END AS HXJYRQ,

        /* 38. 交易类型：信贷交易.信贷交易类型 -> T_7_2.G020012；代码转化 */
        CASE TRIM(src.G020012)
            WHEN '01' THEN '贷款发放'
            WHEN '02' THEN '贷款还本'
            WHEN '03' THEN '贷款还本'
            WHEN '04' THEN '贷款还息'
            WHEN '00' THEN REPLACE(TRIM(src.G020012), '00', '其他')
            ELSE src.G020012
        END AS JYLX,

        /* 39. 账户余额：信贷交易.账户余额 -> T_7_2.G020010；直接映射，转 DECIMAL */
        CAST(NULLIF(TRIM(src.G020010), '') AS DECIMAL(20,2)) AS ZHYE

    FROM T_7_2 src

    /*
     * 表级规则：通过【信贷交易】的【分户账号】内关联已完成一表通转换的
     * 【个人信贷分户账】的【分户账号】。
     * 使用 INNER JOIN，确保信贷交易的分户账号在个人信贷分户账中存在。
     */
    INNER JOIN IE_004_409 grx
        ON grx.DKFHZH = src.G020003

    /*
     * 机构信息维表：用【信贷交易】.【入账机构ID】关联【机构信息】.【机构ID】，
     * 取【机构信息】.【金融许可证号】和【银行机构名称】。
     */
    LEFT JOIN T_1_1 s1
        ON s1.A010001 = src.G020031
       AND s1.A010020 = V_DATA_DATE

    /*
     * 个人基础信息表：用【信贷交易】.【客户ID】关联【个人基础信息表】.【客户统一编号】，
     * 取【个人基础信息表】.【客户姓名】、【证件类别】、【证件号码】。
     * 注意：业务需求中"客户统一编号"对应 T_7_2.G020004（客户ID），
     * 而 IE_002_201 的 PK 为 KHTYBH + CJRQ。
     */
    LEFT JOIN IE_002_201 s2
        ON s2.KHTYBH = src.G020004
       AND s2.CJRQ = P_DATA_DATE

    WHERE src.G020030 = V_DATA_DATE;

    COMMIT;

END;
