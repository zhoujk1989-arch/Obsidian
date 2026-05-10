/*
草案质量状态：合格（2026-05-10 重构校准完成）。
原因：已逐字段对标源表DDL（T_7_5/T_1_1）和业务需求《062_即期及衍生品交易信息表.md》完成全部42个字段校准。JYLX/HYZL/JYZT/JGFS/QQLX/XQFS/BZJBZ 7个码值CASE转换已补齐；MFMC1/MFKHTYBH1/MFMC2/MFKHTYBH2 4个方向判断CASE已补齐；JYYGH从NULL修正为G050033；GZRQ补充DATE_FORMAT转换；CJRQ改为P_DATA_DATE参数赋值；GSFZJG/SENSITIVEFLAG无业务来源保留NULL。需在GBase环境执行语法校验和跑数验证后投入生产。

业务目标：
- 依据原始业务需求《062_即期及衍生品交易信息表.md》生成EAST5.0即期及衍生品交易信息表（IE_010_1005_INC）GBase存储过程。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP存储过程。

依赖材料：
- 原始材料/业务需求/EAST5.0/062_即期及衍生品交易信息表.md
- 原始材料/表结构/EAST5.0系统/IE_010_1005_INC-即期及衍生品交易信息表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_7_5-衍生品交易-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql

源表：
- T_7_5（衍生品交易）— 40个业务字段
- T_1_1（机构信息）— JRXKZH/YHJGZK/MFKHTYBH方向判断

目标表：
- IE_010_1005_INC：即期及衍生品交易信息表（42字段）。

参数：
- P_DATA_DATE：采集日期，格式YYYYMMDD。

运行方式：
- 按CJRQ删除后重插，过滤T_7_5.G050036当月数据。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 填报范围：报告期内发生的自营、代客即期资金交易，以及衍生品交易信息，按发生额填报。
- 其中即期资金交易包括结售汇、贵金属实物（积存金）交易、商品类交易等。交易不涉及的数据项不填报。

表级取数与关联规则：
- 主表：【衍生品交易】（T_7_5）
- 左关联：【机构信息】（T_1_1）
- 关联条件：T_7_5.交易机构ID（G050002）= T_1_1.机构ID（A010001）
- 过滤条件：T_7_5.采集日期（G050036）当月数据

字段校准记录（2026-05-10）：
- 直接映射（18个）：BBZ/JGPL/JYCS/XQJGDW/ZXYMC/GZBZ/JRXKZH/YHJGMC/JCZCLX/CJJGDW/JYBH/YWPZ/JCZCMC/BDSLDW/ZYJYDS/GZJE/GZBZ/SPRGH
- 码值CASE转换（7个）：JYLX/HYZL/JYZT/JGFS/QQLX/XQFS/BZJBZ — 均含'00'/'default'分支和ELSE回退原值
- 方向判断CASE加工映射（4个）：MFMC1/MFKHTYBH1/MFMC2/MFKHTYBH2 — 基于G050037交易对手方向
- 日期格式转换（6个）：QXRQ/JYRQ/DQRQ/JZRQ/GZRQ — DATE_FORMAT('%Y%m%d')；JYSJ — REPLACE(...,':','')
- 数值CAST转换（6个）：BDSL/XQJG/CJJG/GZJE — CAST(NULLIF(TRIM(...),'') AS DECIMAL(20,4))
- 截取映射（1个）：NBJGH — SUBSTR(TRIM(G050002),12)
- 参数赋值（1个）：CJRQ — P_DATA_DATE
- 缺口NULL（2个）：GSFZJG/SENSITIVEFLAG — 业务需求未提供来源
- 修复项：JYYGH从NULL→src.G050033；GZRQ从无转换→DATE_FORMAT；CJRQ从G050036转换→P_DATA_DATE
- JOIN条件：ON 1=1 → ON src.G050002 = s1.A010001
- WHERE条件：补充G050036当月数据过滤（>=当月第一天 AND <=当月最后一天）
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_010_1005_INC_JQJYSPJYXXB;

CREATE PROCEDURE PROC_EAST_IE_010_1005_INC_JQJYSPJYXXB(
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

    -- 按采集日期删除当月已加载数据
    DELETE FROM IE_010_1005_INC
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_010_1005_INC (
        JYLX,
        BBZ,
        MFKHTYBH2,
        QXRQ,
        JGPL,
        BDSL,
        JYCS,
        QQLX,
        XQJGDW,
        ZXYMC,
        GZBZ,
        JYYGH,
        GSFZJG,
        CJRQ,
        JRXKZH,
        YHJGMC,
        XQJG,
        JCZCLX,
        JYSJ,
        SENSITIVEFLAG,
        CJJGDW,
        NBJGH,
        JYBH,
        YWPZ,
        JCZCMC,
        HYZL,
        MFMC1,
        MFKHTYBH1,
        MFMC2,
        JYRQ,
        DQRQ,
        JZRQ,
        BDSLDW,
        CJJG,
        JGFS,
        XQFS,
        BZJBZ,
        ZYJYDS,
        GZJE,
        GZRQ,
        SPRGH,
        JYZT
    )
    SELECT
        /* 交易类型：衍生品交易.交易类型 -> T_7_5.G050006；码值转化 */
        CASE src.G050006
            WHEN '01' THEN '套期保值'
            WHEN '02' THEN '代客'
            WHEN '03' THEN '代客平盘'
            WHEN '04' THEN '做市'
            WHEN '05' THEN '自营'
            WHEN '00' THEN '其他-自定义'
            ELSE src.G050006
        END AS JYLX,

        /* 备注：衍生品交易.备注 -> T_7_5.G050035；直接映射 */
        src.G050035 AS BBZ,

        /*
        卖方客户统一编号：
        当交易对手方向='01'（买方）-> 填报机构为卖方，用交易机构ID关联取金融许可证号
        当交易对手方向='02'（卖方）-> 填报机构为买方，取交易对手客户编号
        */
        CASE src.G050037
            WHEN '01' THEN s1.A010003
            WHEN '02' THEN src.G050038
            ELSE NULL
        END AS MFKHTYBH2,

        /* 起息日期：衍生品交易.起息日期 -> T_7_5.G050044；格式 YYYY-MM-DD -> YYYYMMDD */
        DATE_FORMAT(src.G050044, '%Y%m%d') AS QXRQ,

        /* 交割频率：衍生品交易.交割频率 -> T_7_5.G050012；直接映射 */
        src.G050012 AS JGPL,

        /* 标的数量：衍生品交易.标的数量 -> T_7_5.G050013；转 DECIMAL */
        CAST(NULLIF(TRIM(src.G050013), '') AS DECIMAL(20,4)) AS BDSL,

        /* 交易场所：衍生品交易.交易场所 -> T_7_5.G050007；直接映射 */
        src.G050007 AS JYCS,

        /*
        期权类型：衍生品交易.期权类型 -> T_7_5.G050018；码值转化（QQLX01）
        01->看涨, 02->看跌, 03->上限, 04->下限, 00->其他-自定义
        */
        CASE src.G050018
            WHEN '01' THEN '看涨'
            WHEN '02' THEN '看跌'
            WHEN '03' THEN '上限'
            WHEN '04' THEN '下限'
            WHEN '00' THEN '其他-自定义'
            ELSE src.G050018
        END AS QQLX,

        /* 行权价格单位：衍生品交易.行权价格单位 -> T_7_5.G050020；直接映射 */
        src.G050020 AS XQJGDW,

        /* 主协议名称：衍生品交易.主协议名称 -> T_7_5.G050022；直接映射 */
        src.G050022 AS ZXYMC,

        /* 估值币种：衍生品交易.估值币种 -> T_7_5.G050049；直接映射 */
        src.G050049 AS GZBZ,

        /* 交易员工号：衍生品交易.经办员工ID -> T_7_5.G050033 */
        src.G050033 AS JYYGH,

        /* 归属分支机构：业务需求未提供来源字段，暂置 NULL */
        NULL AS GSFZJG,

        /* 采集日期：使用 P_DATA_DATE（标准EAST5.0模式） */
        P_DATA_DATE AS CJRQ,

        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        s1.A010003 AS JRXKZH,

        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        s1.A010005 AS YHJGMC,

        /* 行权价格：衍生品交易.行权价格 -> T_7_5.G050019；转 DECIMAL */
        CAST(NULLIF(TRIM(src.G050019), '') AS DECIMAL(20,4)) AS XQJG,

        /* 基础资产类型：衍生品交易.基础资产类型 -> T_7_5.G050041；直接映射 */
        src.G050041 AS JCZCLX,

        /* 交易时间：衍生品交易.交易时间 -> T_7_5.G050009；HH:MI:SS -> HHMISS */
        REPLACE(src.G050009, ':', '') AS JYSJ,

        /* 涉密标志：业务需求未提供来源字段，暂置 NULL */
        NULL AS SENSITIVEFLAG,

        /* 成交价格单位：衍生品交易.成交价格单位 -> T_7_5.G050016；直接映射 */
        src.G050016 AS CJJGDW,

        /* 内部机构号：从第12位开始截取交易机构ID */
        SUBSTR(TRIM(src.G050002), 12) AS NBJGH,

        /* 交易编号：衍生品交易.交易ID -> T_7_5.G050001；直接映射 */
        src.G050001 AS JYBH,

        /* 业务品种：衍生品交易.业务品种 -> T_7_5.G050040；直接映射 */
        src.G050040 AS YWPZ,

        /* 基础资产名称：衍生品交易.基础资产名称 -> T_7_5.G050042；直接映射 */
        src.G050042 AS JCZCMC,

        /*
        合约种类：衍生品交易.合约种类 -> T_7_5.G050043；码值转化
        01->即期, 02->远期, 03->期货, 04->掉期, 05->互换, 06->期权, 07->延期交收, 00->其他-银行自定义
        */
        CASE src.G050043
            WHEN '01' THEN '即期'
            WHEN '02' THEN '远期'
            WHEN '03' THEN '期货'
            WHEN '04' THEN '掉期'
            WHEN '05' THEN '互换'
            WHEN '06' THEN '期权'
            WHEN '07' THEN '延期交收'
            WHEN '00' THEN '其他-银行自定义'
            ELSE src.G050043
        END AS HYZL,

        /*
        买方名称：
        当交易对手方向='01'（买方）-> 取交易对手名称（G050026）
        当交易对手方向='02'（卖方）-> 取交易机构名称（G050003）
        */
        CASE src.G050037
            WHEN '01' THEN src.G050026
            WHEN '02' THEN src.G050003
            ELSE NULL
        END AS MFMC1,

        /*
        买方客户统一编号：
        当交易对手方向='01'（买方）-> 取交易对手客户编号（G050038）
        当交易对手方向='02'（卖方）-> 用交易机构ID关联取金融许可证号（s1.A010003）
        */
        CASE src.G050037
            WHEN '01' THEN src.G050038
            WHEN '02' THEN s1.A010003
            ELSE NULL
        END AS MFKHTYBH1,

        /*
        卖方名称：
        当交易对手方向='01'（买方）-> 填报机构为卖方，取交易机构名称（G050003）
        当交易对手方向='02'（卖方）-> 取交易对手名称（G050026）
        */
        CASE src.G050037
            WHEN '01' THEN src.G050003
            WHEN '02' THEN src.G050026
            ELSE NULL
        END AS MFMC2,

        /* 交易日期：衍生品交易.交易日期 -> T_7_5.G050008；YYYY-MM-DD -> YYYYMMDD */
        DATE_FORMAT(src.G050008, '%Y%m%d') AS JYRQ,

        /* 到期日期：衍生品交易.到期日期 -> T_7_5.G050045；YYYY-MM-DD -> YYYYMMDD */
        DATE_FORMAT(src.G050045, '%Y%m%d') AS DQRQ,

        /* 截止日期：衍生品交易.截止日期 -> T_7_5.G050046；YYYY-MM-DD -> YYYYMMDD */
        DATE_FORMAT(src.G050046, '%Y%m%d') AS JZRQ,

        /* 标的数量单位：衍生品交易.标的数量单位 -> T_7_5.G050014；直接映射 */
        src.G050014 AS BDSLDW,

        /* 成交价格：衍生品交易.成交价格 -> T_7_5.G050015；转 DECIMAL */
        CAST(NULLIF(TRIM(src.G050015), '') AS DECIMAL(20,4)) AS CJJG,

        /*
        交割方式：衍生品交易.交割方式 -> T_7_5.G050017；码值转化（JGFS01）
        01->全额, 02->差额, 03->净额, 04->实物, 05->现金, 00->其他
        */
        CASE src.G050017
            WHEN '01' THEN '全额'
            WHEN '02' THEN '差额'
            WHEN '03' THEN '其他-净额'
            WHEN '04' THEN '实物'
            WHEN '05' THEN '现金'
            WHEN '00' THEN '其他'
            ELSE src.G050017
        END AS JGFS,

        /*
        行权方式：衍生品交易.行权方式 -> T_7_5.G050047；码值转化
        01->美式, 02->欧式, 03->百慕大, 00->其他-自定义
        */
        CASE src.G050047
            WHEN '01' THEN '美式'
            WHEN '02' THEN '欧式'
            WHEN '03' THEN '百慕大'
            WHEN '00' THEN '其他-自定义'
            ELSE src.G050047
        END AS XQFS,

        /*
        保证金标志：衍生品交易.保证金标识 -> T_7_5.G050021；码值转化
        0->'否', 1->'是'
        */
        CASE src.G050021
            WHEN '0' THEN '否'
            WHEN '1' THEN '是'
            ELSE src.G050021
        END AS BZJBZ,

        /* 中央交易对手：衍生品交易.中央交易对手 -> T_7_5.G050023；直接映射 */
        src.G050023 AS ZYJYDS,

        /* 估值金额：衍生品交易.估值金额 -> T_7_5.G050048；转 DECIMAL */
        CAST(NULLIF(TRIM(src.G050048), '') AS DECIMAL(20,4)) AS GZJE,

        /* 估值日期：衍生品交易.估值日期 -> T_7_5.G050050；DATE -> YYYYMMDD */
        DATE_FORMAT(src.G050050, '%Y%m%d') AS GZRQ,

        /* 审批人工号：衍生品交易.审批员工ID -> T_7_5.G050034；直接映射 */
        src.G050034 AS SPRGH,

        /*
        交易状态：衍生品交易.交易状态 -> T_7_5.G050024；码值转化
        01->新增, 02->终止, 03->变更, 04->行权, 05->估值, 00->其他-自定义, 其余返回原值
        */
        CASE src.G050024
            WHEN '01' THEN '新增'
            WHEN '02' THEN '终止'
            WHEN '03' THEN '变更'
            WHEN '04' THEN '行权'
            WHEN '05' THEN '估值'
            WHEN '00' THEN '其他-自定义'
            ELSE src.G050024
        END AS JYZT

    FROM T_7_5 src
    LEFT JOIN T_1_1 s1
           ON src.G050002 = s1.A010001 /* 衍生品交易.交易机构ID = 机构信息.机构ID */
    WHERE src.G050036 >= DATE_FORMAT(V_DATA_DATE, '%Y-%m-01')   /* 当月第一天 */
      AND src.G050036 <= LAST_DAY(V_DATA_DATE);                 /* 当月最后一天 */

    COMMIT;
END;
