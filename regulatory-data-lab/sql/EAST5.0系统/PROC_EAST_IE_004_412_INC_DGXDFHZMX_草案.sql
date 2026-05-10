/*
草案质量状态：待验证。
说明：本文件已依据《027_对公信贷分户账明细记录.md》逐项校准存储过程草案，
  修正了交易类型（JYLX）"其他-XX"格式、交易渠道（JYQD）"第三方支付-XX"格式和"银联交易"码值分支。
待验证项：
- ZHMC（账户名称）依赖 EAST对公客户信息表，当前无对应 DDL，使用 LEFT JOIN TODO 占位。
- SENSITIVEFLAG、GSFZJG、DFKHLB 三个字段在业务需求映射表中无来源，保持 NULL。
- 表级规则提到通过【分户账号】关联【对公信贷分户账】，但当前仅使用 T_7_2 和 T_1_1，需确认是否需额外 JOIN 对公信贷分户账表。
审计记录：sql/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
*/

/*
业务目标：
- 依据原始业务需求《027_对公信贷分户账明细记录.md》生成 EAST5.0 对公信贷分户账明细记录（IE_004_412_INC）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 历史业务需求材料
- 历史表结构材料

源表：
- T_7_2（信贷交易）
- T_1_1（机构信息）
- EAST对公客户信息表（账户名称 ZHMC，暂无 DDL，LEFT JOIN TODO 占位）

目标表：
- IE_004_412_INC：对公信贷分户账明细记录。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 按采集日期删除后重插。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 所有影响对公信贷账户余额或利息变动的交易信息，包括还本、还息，不包括查询交易。贷款核销或者转让（包括资产证券化）也应该在本表体现：明细科目填报本金科目，交易金额为核销或转让前本金余额，余额填报为0，交易对手填写借款人自身信息，摘要中标明核销或者转让交易。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 584 行） 通过【信贷交易】的【分户账号】内关联已完成一表通转换的【对公信贷分户账】的【分户账号】，取【信贷交易】.【采集日期】为当月的数据
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_004_412_INC_DGXDFHZMX;

CREATE PROCEDURE PROC_EAST_IE_004_412_INC_DGXDFHZMX(
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

    DELETE FROM IE_004_412_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_004_412_INC (
        JYGYH,
        SENSITIVEFLAG,
        HXJYSJ,
        JYJDBZ,
        ZHYE,
        DFHM,
        JYLX,
        JRXKZH,
        MXKMBH,
        MXKMMC,
        CBMBZ,
        DFXM,
        DFXH,
        XDJJH,
        ZHMC,
        KHTYBH,
        YHJGMC,
        YWBLJGH,
        JYXLH,
        GSFZJG,
        DFZH,
        BBZ,
        JYJE,
        BZ,
        SQGYH,
        JYQD,
        ZY,
        HXJYRQ,
        DKFHZH,
        DFKHLB,
        CJRQ,
        NBJGH,
        XZBZ
    )
    SELECT
        /* 交易柜员号：信贷交易.经办员工ID -> T_7_2.G020022；加工映射，如为"自动"则转为空，否则取原值 */
        CASE WHEN TRIM(src.G020022) = '自动' THEN NULL ELSE TRIM(src.G020022) END AS JYGYH,

        /* 涉密标志：本地 DDL 存在，但业务需求映射表未给来源，保持 NULL */
        NULL AS SENSITIVEFLAG,

        /* 核心交易时间：信贷交易.核心交易时间 -> T_7_2.G020008；格式转换：HH:MM:SS -> HHMMSS */
        REPLACE(src.G020008, ':', '') AS HXJYSJ,

        /* 交易借贷标志：信贷交易.借贷标识 -> T_7_2.G020015；代码转化：'01'[借]-> '借', '02'[贷]-> '贷' */
        CASE TRIM(src.G020015)
            WHEN '01' THEN '借'
            WHEN '02' THEN '贷'
            ELSE src.G020015
        END AS JYJDBZ,

        /* 账户余额：信贷交易.账户余额 -> T_7_2.G020010；直接映射，转 DECIMAL */
        CAST(NULLIF(TRIM(src.G020010), '') AS DECIMAL(20,2)) AS ZHYE,

        /* 对方户名：信贷交易.对方户名 -> T_7_2.G020018；直接映射 */
        TRIM(src.G020018) AS DFHM,

        /* 交易类型：信贷交易.信贷交易类型 -> T_7_2.G020012；代码转化：
           '01'[发放] -> '贷款发放'
           '02'/'03'[收回] -> '贷款还本'
           '04'[收息] -> '贷款还息'
           '00-XX'[其他] -> '其他-XX'
           ELSE 原值 */
        CASE TRIM(src.G020012)
            WHEN '01' THEN '贷款发放'
            WHEN '02' THEN '贷款还本'
            WHEN '03' THEN '贷款还本'
            WHEN '04' THEN '贷款还息'
            WHEN src.G020012 LIKE '00%' THEN CONCAT('其他-', REPLACE(src.G020012, '00', ''))
            ELSE src.G020012
        END AS JYLX,

        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；用【信贷交易】.【入账机构ID】关联【机构信息】.【机构ID】 */
        TRIM(s1.A010003) AS JRXKZH,

        /* 明细科目编号：信贷交易.科目ID -> T_7_2.G020013；直接映射 */
        TRIM(src.G020013) AS MXKMBH,

        /* 明细科目名称：信贷交易.科目名称 -> T_7_2.G020014；直接映射 */
        TRIM(src.G020014) AS MXKMMC,

        /* 冲补抹标志：信贷交易.冲补抹标识 -> T_7_2.G020021；代码转化：'01'[正常]-> '正常', '02'[冲补抹]-> '冲补抹' */
        CASE TRIM(src.G020021)
            WHEN '01' THEN '正常'
            WHEN '02' THEN '冲补抹'
            ELSE src.G020021
        END AS CBMBZ,

        /* 对方行名：信贷交易.对方行名 -> T_7_2.G020020；直接映射 */
        TRIM(src.G020020) AS DFXM,

        /* 对方行号：信贷交易.对方账号行号 -> T_7_2.G020019；直接映射 */
        TRIM(src.G020019) AS DFXH,

        /* 信贷借据号：信贷交易.借据ID -> T_7_2.G020006；直接映射 */
        TRIM(src.G020006) AS XDJJH,

        /* 账户名称：EAST对公客户信息表.客户名称；优先用【信贷交易】.【借据ID】关联<EAST对公客户信息表>.<客户统一编号>
           注意：当前无 EAST对公客户信息表 DDL，使用 TODO 占位，投产前需补齐 */
        NULL AS ZHMC /* TODO: LEFT JOIN EAST对公客户信息表 on TRIM(src.G020006) = TRIM(客户信息表.客户统一编号) 取 客户名称 */ ,

        /* 客户统一编号：信贷交易.客户ID -> T_7_2.G020004；直接映射 */
        TRIM(src.G020004) AS KHTYBH,

        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；用【信贷交易】.【入账机构ID】关联【机构信息】.【机构ID】 */
        TRIM(s1.A010005) AS YHJGMC,

        /* 业务办理机构号：信贷交易.交易机构ID -> T_7_2.G020005；从第12位开始截取 */
        SUBSTR(TRIM(src.G020005), 12) AS YWBLJGH,

        /* 交易序列号：信贷交易.交易ID -> T_7_2.G020001；直接映射 */
        TRIM(src.G020001) AS JYXLH,

        /* 归属分支机构：业务需求映射表未给来源，保持 NULL */
        NULL AS GSFZJG,

        /* 对方账号：信贷交易.对方账号 -> T_7_2.G020017；直接映射 */
        TRIM(src.G020017) AS DFZH,

        /* 备注：信贷交易.备注 -> T_7_2.G020032；直接映射 */
        TRIM(src.G020032) AS BBZ,

        /* 交易金额：信贷交易.交易金额 -> T_7_2.G020009；直接映射，转 DECIMAL */
        CAST(NULLIF(TRIM(src.G020009), '') AS DECIMAL(20,2)) AS JYJE,

        /* 币种：信贷交易.币种 -> T_7_2.G020011；直接映射 */
        TRIM(src.G020011) AS BZ,

        /* 授权柜员号：信贷交易.授权员工ID -> T_7_2.G020023；加工映射，如为"自动"则转为空，否则取原值 */
        CASE WHEN TRIM(src.G020023) = '自动' THEN NULL ELSE TRIM(src.G020023) END AS SQGYH,

        /* 交易渠道：信贷交易.交易渠道 -> T_7_2.G020024；代码转化：
           '01'[柜面] -> '柜面'
           '02'[ATM(自动柜员机)] -> 'ATM'
           '03'[VTM（远程视频柜员机）] -> 'VTM'
           '04'[POS（销售终端）] -> 'POS'
           '05'[网银] -> '网银'
           '06'[手机银行] -> '手机银行'
           '07-XX'[第三方支付] -> '第三方支付-XX'
           '08'[银联交易] -> '银联交易'
           '00-XX'[其他] -> '其他-XX'
           ELSE 原值 */
        CASE TRIM(src.G020024)
            WHEN '01' THEN '柜面'
            WHEN '02' THEN 'ATM'
            WHEN '03' THEN 'VTM'
            WHEN '04' THEN 'POS'
            WHEN '05' THEN '网银'
            WHEN '06' THEN '手机银行'
            WHEN '08' THEN '银联交易'
            WHEN src.G020024 LIKE '07%' THEN CONCAT('第三方支付-', REPLACE(src.G020024, '07', ''))
            WHEN src.G020024 LIKE '00%' THEN CONCAT('其他-', REPLACE(src.G020024, '00', ''))
            ELSE src.G020024
        END AS JYQD,

        /* 摘要：信贷交易.摘要 -> T_7_2.G020029；直接映射 */
        TRIM(src.G020029) AS ZY,

        /* 核心交易日期：信贷交易.核心交易日期 -> T_7_2.G020007；格式转换：date -> 'YYYYMMDD'，默认值 99991231 */
        CASE WHEN src.G020007 IS NULL THEN '99991231'
              ELSE CONCAT(CAST(YEAR(src.G020007) AS CHAR(4)),
                          LPAD(CAST(MONTH(src.G020007) AS CHAR(2)), 2, '0'),
                          LPAD(CAST(DAY(src.G020007) AS CHAR(2)), 2, '0'))
        END AS HXJYRQ,

        /* 贷款分户账号：信贷交易.分户账号 -> T_7_2.G020003；直接映射 */
        TRIM(src.G020003) AS DKFHZH,

        /* 对方客户类别：业务需求映射表未给来源，保持 NULL */
        NULL AS DFKHLB,

        /* 采集日期：信贷交易.采集日期 -> T_7_2.G020030；格式转换：date -> 'YYYYMMDD' */
        CONCAT(CAST(YEAR(src.G020030) AS CHAR(4)),
               LPAD(CAST(MONTH(src.G020030) AS CHAR(2)), 2, '0'),
               LPAD(CAST(DAY(src.G020030) AS CHAR(2)), 2, '0')) AS CJRQ,

        /* 内部机构号：信贷交易.入账机构ID -> T_7_2.G020031；从第12位开始截取 */
        SUBSTR(TRIM(src.G020031), 12) AS NBJGH,

        /* 现转标志：信贷交易.现转标识 -> T_7_2.G020028；代码转化：'01'[现]-> '现', '02'[转]-> '转' */
        CASE TRIM(src.G020028)
            WHEN '01' THEN '现'
            WHEN '02' THEN '转'
            ELSE src.G020028
        END AS XZBZ

    FROM T_7_2 src
    LEFT JOIN T_1_1 s1
           ON TRIM(src.G020031) = TRIM(s1.A010001)
    WHERE src.G020030 = V_DATA_DATE;

    COMMIT;
END;
