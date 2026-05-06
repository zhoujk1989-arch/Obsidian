/*
草案质量状态：待验证（已修复 JOIN 占位、CJRQ 赋值、BBZ 拼接和 WHERE 过滤）。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md

业务目标：
- 依据原始业务需求《032_受托支付信息表.md》生成 EAST5.0 受托支付信息表（IE_005_505_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/032_受托支付信息表.md
- 原始材料/表结构/EAST5.0系统/IE_005_505_INC-受托支付信息表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_6-受托支付信息-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_6_27-贷款协议补充信息-DDL-2026-04-27.sql

源表：
- T_6_6（受托支付信息）：主来源表。
- T_1_1（机构信息）：通过机构ID关联，取金融许可证号。
- T_6_27（贷款协议补充信息）：通过借据ID关联，取借款金额和备注。

目标表：
- IE_005_505_INC：受托支付信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 按采集日期删除后重插（delete-and-reload）。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 《个人信贷业务借据表》和《对公信贷业务借据表》中放款方式为"受托支付"或"混合支付"的，在该表中报送受托支付对象信息。

Open Questions（需人工复核）：
1. 需求文档未明确 T_6_6.F060010（采集日期）与 P_DATA_DATE 的关系；当前 WHERE 过滤 F060010 = P_DATA_DATE，需确认是否应改为"上一采集日 < F060010 <= P_DATA_DATE"。
2. 需求文档表级规则提及《个人信贷业务借据表》和《对公信贷业务借据表》的放款方式过滤，但本 SQL 未关联这两张表；需确认是否需要在 T_6_6 层面过滤，或放款方式信息在受托支付信息中已有标识。
3. STZFDXKHLB（受托支付对象客户类别）、SENSITIVEFLAG（涉密标志）、GSFZJG（归属分支机构）三个字段在业务需求映射表中无来源，暂赋 NULL。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_005_505_INC_STZFXXB;

CREATE PROCEDURE PROC_EAST_IE_005_505_INC_STZFXXB(
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

    -- 按采集日期清理，确保重跑一致性
    DELETE FROM IE_005_505_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_005_505_INC (
        XDJJH,
        STZFDXKHLB,
        STZFJE,
        STZFDXZH,
        STZFDXXM,
        NBJGH,
        JRXKZH,
        SENSITIVEFLAG,
        GSFZJG,
        XDHTH,
        BZ,
        STZFRQ,
        STZFDXHM,
        STZFDXHH,
        BBZ,
        CJRQ,
        DKJE
    )
    SELECT
        /* 信贷借据号：受托支付信息.借据ID -> T_6_6.F060002；直接映射 */
        src.F060002 AS XDJJH,

        /* 受托支付对象客户类别：业务需求映射表未给出来源，暂赋 NULL */
        NULL AS STZFDXKHLB,

        /* 受托支付金额：受托支付信息.受托支付金额 -> T_6_6.F060003；直接映射 */
        CAST(NULLIF(TRIM(src.F060003), '') AS DECIMAL(20,2)) AS STZFJE,

        /* 受托支付对象账号：受托支付信息.受托支付对象账号 -> T_6_6.F060005；直接映射 */
        src.F060005 AS STZFDXZH,

        /* 受托支付对象行名：受托支付信息.受托支付对象行名 -> T_6_6.F060008；直接映射 */
        src.F060008 AS STZFDXXM,

        /* 内部机构号：受托支付信息.机构ID -> T_6_6.F060011；
           加工规则：从第12位开始截取。 */
        SUBSTR(TRIM(src.F060011), 12) AS NBJGH,

        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；
           加工规则：用【受托支付信息】.【机构ID】关联【机构信息】.【机构ID】,
           取【机构信息】.【金融许可证号】。 */
        s1.A010003 AS JRXKZH,

        /* 涉密标志：业务需求映射表未给出来源，暂赋 NULL */
        NULL AS SENSITIVEFLAG,

        /* 归属分支机构：业务需求映射表未给出来源，暂赋 NULL */
        NULL AS GSFZJG,

        /* 信贷合同号：受托支付信息.协议ID -> T_6_6.F060001；直接映射 */
        src.F060001 AS XDHTH,

        /* 币种：受托支付信息.币种 -> T_6_6.F060012；直接映射 */
        src.F060012 AS BZ,

        /* 受托支付日期：受托支付信息.受托支付日期 -> T_6_6.F060004；
           格式转换：格式转为'YYYYMMDD'，若为空则赋默认值'99991231'。 */
        CASE WHEN src.F060004 IS NULL THEN '99991231'
             ELSE REPLACE(CONCAT(CAST(YEAR(src.F060004) AS CHAR(4)),
                                 LPAD(CAST(MONTH(src.F060004) AS CHAR(2)), 2, '0'),
                                 LPAD(CAST(DAY(src.F060004) AS CHAR(2)), 2, '0')), '-', '')
        END AS STZFRQ,

        /* 受托支付对象户名：受托支付信息.受托支付对象户名 -> T_6_6.F060006；直接映射 */
        src.F060006 AS STZFDXHM,

        /* 受托支付对象行号：受托支付信息.受托支付对象行号 -> T_6_6.F060007；直接映射 */
        src.F060007 AS STZFDXHH,

        /* 备注：受托支付信息.备注 + 贷款协议补充信息.备注 -> T_6_6.F060009 || T_6_27.F270068；
           加工映射：提取一表通《6.6受托支付信息》、《6.27贷款协议补充信息》备注，以";"拼接。 */
        TRIM(TRAILING ';' FROM
            COALESCE(NULLIF(TRIM(src.F060009), ''), '')
            || CASE WHEN src.F060009 IS NOT NULL AND TRIM(src.F060009) <> ''
                    THEN ';' ELSE '' END
            || COALESCE(NULLIF(TRIM(s2.F270068), ''), '')
        ) AS BBZ,

        /* 采集日期：赋值批量【数据日期】P_DATA_DATE，格式 YYYYMMDD。
           不再从源表 F060010 转换，因为 WHERE 已过滤 F060010 = P_DATA_DATE。 */
        P_DATA_DATE AS CJRQ,

        /* 贷款金额：贷款协议补充信息.借款金额 -> T_6_27.F270009；
           加工规则：用【受托支付信息】.【借据ID】关联【贷款协议补充信息】.【借据ID】,
           取【贷款协议补充信息】.【借款金额】。 */
        CAST(NULLIF(TRIM(s2.F270009), '') AS DECIMAL(20,2)) AS DKJE

    FROM T_6_6 src
    LEFT JOIN T_1_1 s1
        ON TRIM(src.F060011) = TRIM(s1.A010001)
    LEFT JOIN T_6_27 s2
        ON TRIM(src.F060002) = TRIM(s2.F270001)
    WHERE src.F060010 = V_DATA_DATE;

    COMMIT;
END;
