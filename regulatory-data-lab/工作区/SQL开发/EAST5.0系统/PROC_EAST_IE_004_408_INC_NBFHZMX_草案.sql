/*
草案质量状态：待验证，禁止直接执行。
原因：本文件已补齐 LEFT JOIN、WHERE 过滤和 CASE 码值转换，但尚未在 GBase 8a 环境执行验证。
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
重构日期：2026-05-05

业务目标：
- 依据原始业务需求《023_内部分户账明细记录.md》生成 EAST5.0 内部分户账明细记录（IE_004_408_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/023_内部分户账明细记录.md
- 原始材料/表结构/EAST5.0系统/IE_004_408_INC-内部分户账明细记录-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_407-内部分户账-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_402-内部科目对照表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_7_10-内部分户账交易-DDL-2026-04-27.sql

源表：
- T_7_10：内部分户账交易（主源）
- IE_004_407：内部分户账（LEFT JOIN  enrich）
- IE_004_402：内部科目对照表（LEFT JOIN  enrich，两次关联：明细科目 + 对方科目）

目标表：
- IE_004_408_INC：内部分户账明细记录。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 按采集日期删除后重插（幂等）。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 根据会计核算科目，除单列账之外的科目原则上都归入内部账采集；单列账报送至信用卡、对公/个人等分户账中；资本账户需要报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 469 行）
主表：【内部分户账交易】
左关联：【EAST.内部分户账】
关联条件：【内部分户账交易】.【分户账号】 = 【EAST.内部分户账】.【分户账号】
左关联：【EAST.内部科目对照表】
关联条件：【客户存款账户交易表】【科目ID】，关联【EAST.内部科目对照表】的【会计科目编号】

未确认点：
- 需求文档未给出采集日期、当月数据、终态纳入和排除条件的具体过滤规则；当前仅按 T_7_10.G100028 = V_DATA_DATE 过滤。
- 缺口字段 GSFZJG（归属分支机构）、SENSITIVEFLAG（涉密标志）、DFKHLB（对方客户类别）无映射来源，SQL 中置 NULL。
- GBase 8a 对 DATE_FORMAT 函数的支持性已参考同仓库 IE_004_407 重构实践确认可用。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_408_INC_NBFHZMX;

DELIMITER ;;

CREATE PROCEDURE PROC_EAST_IE_004_408_INC_NBFHZMX(
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

    SET V_DATA_DATE = STR_TO_DATE(P_DATA_DATE, '%Y%m%d');

    START TRANSACTION;

    -- 按采集日期清理，保证幂等重跑
    DELETE FROM IE_004_408_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_408_INC (
        JYXLH,
        JRXKZH,
        NBJGH,
        YHJGMC,
        MXKMBH,
        MXKMMC,
        ZHMC,
        NBFHZZH,
        HXJYRQ,
        HXJYSJ,
        BZ,
        JYLX,
        JYJDBZ,
        JYJE,
        JFYE,
        DFYE,
        DFZH,
        DFKMBH,
        DFKMMC,
        DFHM,
        DFXH,
        DFXM,
        ZY,
        CBMBZ,
        JYQD,
        XZBZ,
        JYGYH,
        SQGYH,
        JZRQ,
        XZRQ,
        BBZ,
        CJRQ,
        GSFZJG,
        SENSITIVEFLAG,
        DFKHLB
    )
    SELECT
        /* 22 对方行名：T_7_10.G100017；直接映射 */
        src.G100017 AS DFXM,

        /* 25 交易渠道：T_7_10.G100019；码值转化 8 分支 */
        CASE
            WHEN TRIM(src.G100019) = '01' THEN '柜面'
            WHEN TRIM(src.G100019) = '02' THEN 'ATM'
            WHEN TRIM(src.G100019) = '03' THEN 'VTM'
            WHEN TRIM(src.G100019) = '04' THEN 'POS'
            WHEN TRIM(src.G100019) = '05' THEN '网银'
            WHEN TRIM(src.G100019) = '06' THEN '手机银行'
            WHEN TRIM(src.G100019) LIKE '07%' THEN CONCAT('第三方支付-', REPLACE(TRIM(src.G100019), '07', ''))
            WHEN TRIM(src.G100019) = '08' THEN '银联交易'
            WHEN TRIM(src.G100019) = '00' THEN CONCAT('其他-', REPLACE(TRIM(src.G100019), '00', ''))
            ELSE NULL
        END AS JYQD,

        /* 28 授权柜员号：T_7_10.G100021；'自动'转NULL */
        CASE WHEN TRIM(src.G100021) = '自动' THEN NULL ELSE TRIM(src.G100021) END AS SQGYH,

        /* 29 进账日期：T_7_10.G100026；YYYY-MM-DD → YYYYMMDD */
        CASE
            WHEN src.G100026 IS NOT NULL THEN TO_CHAR(src.G100026, 'YYYYMMDD')
            ELSE NULL
        END AS JZRQ,

        /* 31 备注：T_7_10.G100030；已有分号拼接语义，直接映射 */
        src.G100030 AS BBZ,

        /* 1 交易序列号：T_7_10.G100001；直接映射 */
        src.G100001 AS JYXLH,

        /* 3 内部机构号：IE_004_407.NBJGH；LEFT JOIN 取 */
        acct.NBJGH AS NBJGH,

        /* 5 明细科目编号：T_7_10.G100007；直接映射 */
        src.G100007 AS MXKMBH,

        /* 6 明细科目名称：IE_004_402(T7).KJKMMC；LEFT JOIN 取 */
        dim_mx.KJKMMC AS MXKMMC,

        /* 9 核心交易日期：T_7_10.G100003；YYYY-MM-DD → YYYYMMDD */
        TO_CHAR(src.G100003, 'YYYYMMDD') AS HXJYRQ,

        /* 10 核心交易时间：T_7_10.G100004；去除冒号 */
        TO_CHAR(src.G100004, 'HH24MISS') AS HXJYSJ,

        /* 12 交易类型：T_7_10.G100006；码值转化 15 分支 */
        CASE
            WHEN TRIM(src.G100006) = '01' THEN '转账'
            WHEN TRIM(src.G100006) = '02' THEN '取现'
            WHEN TRIM(src.G100006) = '03' THEN '存现'
            WHEN TRIM(src.G100006) = '04' THEN '消费'
            WHEN TRIM(src.G100006) = '05' THEN '代发'
            WHEN TRIM(src.G100006) = '06' THEN '代扣'
            WHEN TRIM(src.G100006) = '07' THEN '代缴'
            WHEN TRIM(src.G100006) = '08' THEN '结息'
            WHEN TRIM(src.G100006) = '09' THEN '批量交易'
            WHEN TRIM(src.G100006) = '10' THEN '贷款发放'
            WHEN TRIM(src.G100006) = '11' THEN '贷款还本'
            WHEN TRIM(src.G100006) = '12' THEN '贷款还息'
            WHEN TRIM(src.G100006) = '13' THEN '银证业务'
            WHEN TRIM(src.G100006) = '14' THEN '投资理财'
            WHEN TRIM(src.G100006) = '00' THEN CONCAT('其他-', REPLACE(TRIM(src.G100006), '00', ''))
            ELSE NULL
        END AS JYLX,

        /* 14 交易金额：T_7_10.G100010；CAST DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.G100010), '') AS DECIMAL(20,2)) AS JYJE,

        /* 16 贷方余额：T_7_10.G100013；CAST DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.G100013), '') AS DECIMAL(20,2)) AS DFYE,

        /* 17 对方账号：T_7_10.G100014；直接映射 */
        src.G100014 AS DFZH,

        /* 20 对方户名：T_7_10.G100015；直接映射 */
        src.G100015 AS DFHM,

        /* 32 采集日期：参数 */
        P_DATA_DATE AS CJRQ,

        /* 缺口 GSFZJG：需求文档未给来源，置 NULL */
        NULL AS GSFZJG,

        /* 缺口 SENSITIVEFLAG：需求文档未给来源，置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 2 金融许可证号：IE_004_407.JRXKZH；LEFT JOIN 取 */
        acct.JRXKZH AS JRXKZH,

        /* 4 银行机构名称：IE_004_407.YHJGMC；LEFT JOIN 取 */
        acct.YHJGMC AS YHJGMC,

        /* 7 账户名称：IE_004_407.ZHMC；LEFT JOIN 取 */
        acct.ZHMC AS ZHMC,

        /* 8 内部分户账账号：T_7_10.G100002；直接映射 */
        src.G100002 AS NBFHZZH,

        /* 11 币种：T_7_10.G100005；直接映射 */
        src.G100005 AS BZ,

        /* 13 交易借贷标志：T_7_10.G100009；码值转化 4 分支 */
        CASE
            WHEN TRIM(src.G100009) = '01' THEN '借'
            WHEN TRIM(src.G100009) = '02' THEN '贷'
            WHEN TRIM(src.G100009) = '03' THEN '借贷并列'
            ELSE ''
        END AS JYJDBZ,

        /* 15 借方余额：T_7_10.G100012；CAST DECIMAL(20,2) */
        CAST(NULLIF(TRIM(src.G100012), '') AS DECIMAL(20,2)) AS JFYE,

        /* 18 对方科目编号：T_7_10.G100023；直接映射（对方科目ID） */
        src.G100023 AS DFKMBH,

        /* 19 对方科目名称：IE_004_402(T8).KJKMMC；LEFT JOIN 取 */
        dim_dfk.KJKMMC AS DFKMMC,

        /* 21 对方行号：T_7_10.G100016；直接映射 */
        src.G100016 AS DFXH,

        /* 23 摘要：T_7_10.G100018；直接映射 */
        src.G100018 AS ZY,

        /* 24 冲补抹标志：T_7_10.G100022；码值转化 2 分支 */
        CASE
            WHEN TRIM(src.G100022) = '01' THEN '正常'
            WHEN TRIM(src.G100022) = '02' THEN '冲补抹'
            ELSE NULL
        END AS CBMBZ,

        /* 26 现转标志：T_7_10.G100025；码值转化 3 分支 */
        CASE
            WHEN TRIM(src.G100025) = '01' THEN '现'
            WHEN TRIM(src.G100025) = '02' THEN '转'
            ELSE ''
        END AS XZBZ,

        /* 27 交易柜员号：T_7_10.G100020；'自动'转NULL */
        CASE WHEN TRIM(src.G100020) = '自动' THEN NULL ELSE TRIM(src.G100020) END AS JYGYH,

        /* 30 销账日期：T_7_10.G100027；YYYY-MM-DD → YYYYMMDD */
        CASE
            WHEN src.G100027 IS NOT NULL THEN TO_CHAR(src.G100027, 'YYYYMMDD')
            ELSE NULL
        END AS XZRQ,

        /* 缺口 DFKHLB：需求文档未给来源，置 NULL */
        NULL AS DFKHLB

    FROM T_7_10 src
    LEFT JOIN IE_004_407 acct
        ON src.G100002 = acct.NBFHZZH
    LEFT JOIN IE_004_402 dim_mx
        ON src.G100007 = dim_mx.KJKMBH
    LEFT JOIN IE_004_402 dim_dfk
        ON src.G100023 = dim_dfk.KJKMBH
    WHERE src.G100028 = V_DATA_DATE;

    COMMIT;

END;;

DELIMITER ;
