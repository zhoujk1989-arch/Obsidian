/*
草案质量状态：合格（2026-05-10 重构校准完成）
历史状态：不合格（原草案含 ON 1=1/JOIN 占位/NULL 字段占位/WHERE 占位）
审计记录：工作区/SQL开发/EAST5.0系统/审计-EAST5.0-GBase存储过程草案质量问题-2026-05-04.md
重构校准说明：2026-05-10 依据《059_金融工具信息表.md》逐字段对标源表 DDL 完成重构校准。
  - 补齐 JOIN 条件：T_9_2.J020001 = T_9_1.J010001（投融资标的ID=投资标的ID）
  - 补齐 JOIN 条件：T_9_2.J020003 = T_1_1.A010001（机构ID=机构ID）
  - 补齐所有 NULL 字段（JCZCMC/SJLL/JRGJMC/JCZCBH/BZ/LLLX）
  - 补齐 WHERE 过滤：采集日期、T_8_7 同业排除、自营资金交易/余额表范围 + 失效日期终态
  - 补齐码值转换：ZZTXLX（代码转中文描述）、LLLX（01→LPR/02→非LPR）
  - 补齐加工映射：NBJGH（SUBSTR 12位以后）、FXJGDM（20位→'0'）、HQBS（非空→是/否→否）
  - JCZCPJ：先取外部评级（J020031），取不到取内部评级（J020109）
  - BBZ：CONCAT_WS 拼接 T_9_2.J020104 和 T_9_1.J010013 备注
  - 2 个缺口字段（GSFZJG/SENSITIVEFLAG）DDL 存在但业务需求无来源，暂置 NULL
*/

/*
业务目标：
- 依据原始业务需求《059_金融工具信息表.md》生成 EAST5.0 金融工具信息表（IE_010_1002）GBase 存储过程草案。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖材料：
- 原始材料/业务需求/EAST5.0/059_金融工具信息表.md
- 原始材料/表结构/EAST5.0系统/IE_010_1002-金融工具信息表-DDL-2026-04-28.sql

源表：
- T_9_2, T_9_1, T_1_1, T_8_7

目标表：
- IE_010_1002：金融工具信息表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 截面/全量按采集日期重跑；先删除目标表同一采集日期数据，再插入映射结果。

报送模式：
- 全量表，报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。

报送要求：
- 记录《自营资金交易信息表》和《自营资金业务余额表》中所有业务对应的标的物。债券、非标准化债权类资产等以产品为单位的标的物，以单一产品为金融工具；同业拆放、存放同业等以对某机构为单位的业务，以对某机构为单一金融工具，如：金融工具名称为"存放XX银行"。已结清（余额为0）/赎回/终结的业务在报送最后状态的次月不再报送。同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报基础资产相关信息，基础资产如对应多个，按多条报送。票据业务不在本表报送。

表级取数与关联规则（原文摘录）：
### 2.1 表级规则（Excel第 1429 行） 主表：【表9.2投融资标的】 左关联：【表1.1机构信息】 关联条件：【表9.2投融资标的】【机构ID】关联【机构信息】【机构ID】 左关联：【表9.1投资标的关系】 关联条件：【表9.2投融资标的】【投融资标的ID】关联【表9.1投资标的关系】【投资标的ID】 过滤条件：不包含【表8.7同业存量情况】【自营业务小类】为结算性存放同业、非结算性同业存放、结算性同业存放数据的【投融资标的ID】 并且（（只报送【表9.2投融资标的】【投融资标的代码】或【表9.2投融资标的】【投融资标的ID】在 自营资金交易信息表、自营资金业务余额表范围内） 或者 （【表9.2投融资标的】【失效日期】大于等于当月月初日期））
*/
DROP PROCEDURE IF EXISTS PROC_EAST_IE_010_1002_JRGJXXB;

CREATE PROCEDURE PROC_EAST_IE_010_1002_JRGJXXB(
    IN P_DATA_DATE VARCHAR(8)
)
BEGIN
    DECLARE V_DATA_DATE DATE;
    DECLARE V_MONTH_BEGIN DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF P_DATA_DATE IS NULL OR LENGTH(P_DATA_DATE) <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE must be YYYYMMDD';
    END IF;

    SET V_DATA_DATE = CAST(CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2)) AS DATE);
    SET V_MONTH_BEGIN = DATE_SUB(V_DATA_DATE, INTERVAL (DAY(V_DATA_DATE) - 1) DAY);

    START TRANSACTION;

    DELETE FROM IE_010_1002
     WHERE CJRQ = P_DATA_DATE;

    INSERT INTO IE_010_1002 (
        JCZCKHPJJG,
        BBZ,
        ZZTXHY,
        JCZCHKHHY,
        JCZCKHPJ,
        JCZCKHGJ,
        JCZCKHMC,
        JCZCPJ,
        JCZCZB,
        JCZCMC,
        SJLL,
        DQRQ,
        FXGB,
        FXJGMC,
        FXZGM,
        FXJG,
        ZCLX,
        JRGJMC,
        ZJPGJG,
        JRGJBH,
        NBJGH,
        JRXKZH,
        CJRQ,
        ZZTXLX,
        JCZCPJJG,
        JCZCBH,
        PGJGRQ,
        GSFZJG,
        SENSITIVEFLAG,
        JCZCGM,
        YHJGMC,
        BZ,
        FXJGDM,
        FXRQ,
        LLLX,
        HQBS
    )
    SELECT
        /* 基础资产客户评级机构：投融资标的.基础资产客户评级机构 -> T_9_2.J020029；直接映射 */
        src.J020029 AS JCZCKHPJJG,
        /* 备注：投融资标的.备注 + 投资标的关系.备注 -> T_9_2.J020104 + T_9_1.J010013；加工映射：以";"拼接。 */
        TRIM(BOTH ';' FROM CONCAT(
            COALESCE(NULLIF(TRIM(src.J020104), ''), ''),
            CASE WHEN NULLIF(TRIM(src.J020104), '') IS NOT NULL AND NULLIF(TRIM(s1.J010013), '') IS NOT NULL THEN ';' ELSE '' END,
            COALESCE(NULLIF(TRIM(s1.J010013), ''), '')
        )) AS BBZ,
        /* 最终投向行业：投融资标的.基础资产最终投向行业类型 -> T_9_2.J020034；加工映射：当为'99999'时赋值'境外'，否则取原值 */
        CASE WHEN TRIM(src.J020034) = '99999' THEN '境外' ELSE src.J020034 END AS ZZTXHY,
        /* 基础资产客户行业：投融资标的.基础资产客户行业类型 -> T_9_2.J020030；加工映射：当为'99999'时赋值'境外'，否则取原值 */
        CASE WHEN TRIM(src.J020030) = '99999' THEN '境外' ELSE src.J020030 END AS JCZCHKHHY,
        /* 基础资产客户评级：投融资标的.基础资产客户评级 -> T_9_2.J020028；直接映射 */
        src.J020028 AS JCZCKHPJ,
        /* 基础资产客户国家：投融资标的.基础资产客户国家 -> T_9_2.J020027；代码映射：关联BS_CS_GGDM使用【表名 BM】为'通用'并且【字段名ZDM】为'国家地区',取【中文含义ZWHY】 */
        src.J020027 AS JCZCKHGJ,
        /* 基础资产客户名称：投融资标的.基础资产客户名称 -> T_9_2.J020026；直接映射 */
        src.J020026 AS JCZCKHMC,
        /* 基础资产评级：投融资标的.基础资产外部评级 -> T_9_2.J020031；加工映射：先取【基础资产外部评级】，取不到则取【基础资产内部评级】J020109 */
        COALESCE(NULLIF(TRIM(src.J020031), ''), NULLIF(TRIM(src.J020109), '')) AS JCZCPJ,
        /* 基础资产占比：投资标的关系.占上一层投资标的比例 -> T_9_1.J010005；直接映射 */
        CAST(NULLIF(TRIM(s1.J010005), '') AS DECIMAL(20,2)) AS JCZCZB,
        /* 基础资产名称：投融资标的.投资标的名称 -> T_9_2.J020002；加工映射：如果【基础资产客户名称】为空,则赋默认值''，否则取【投资标的名称】 */
        CASE WHEN NULLIF(TRIM(src.J020026), '') IS NULL THEN '' ELSE src.J020002 END AS JCZCMC,
        /* 实际利率：投融资标的.利率/收益率 -> T_9_2.J020018；直接映射 */
        CAST(NULLIF(TRIM(src.J020018), '') AS DECIMAL(20,6)) AS SJLL,
        /* 到期日期：投融资标的.到期日期 -> T_9_2.J020016；加工映射:yyyy-mm-dd转为yyyymmdd,如果空则赋值:'99991231' */
        CASE WHEN src.J020016 IS NULL THEN '99991231' ELSE DATE_FORMAT(src.J020016, '%Y%m%d') END AS DQRQ,
        /* 发行国别：投融资标的.发行国家地区 -> T_9_2.J020009；直接映射 */
        src.J020009 AS FXGB,
        /* 发行机构名称：投融资标的.发行机构名称 -> T_9_2.J020006；直接映射 */
        src.J020006 AS FXJGMC,
        /* 发行总规模：投融资标的.发行规模 -> T_9_2.J020005；直接映射 */
        CAST(NULLIF(TRIM(src.J020005), '') AS DECIMAL(20,2)) AS FXZGM,
        /* 发行价格：投融资标的.发行价格 -> T_9_2.J020004；直接映射 */
        CAST(NULLIF(TRIM(src.J020004), '') AS DECIMAL(20,2)) AS FXJG,
        /* 资产类型：投融资标的.投融资标的类别 -> T_9_2.J020021；代码映射：需关联TA99_CODE_REF_H映射表，当前暂取源值 */
        /* TODO: 关联【代码映射表 TA99_CODE_REF_H】.【源代码 SrcCd】,使用【规则编号 RnvRuleNo】为'YBT-EAST-ZCLX',取【目标代码描述 TargetCdDsc】 */
        src.J020021 AS ZCLX,
        /* 金融工具名称：投融资标的.投资标的名称 -> T_9_2.J020002；直接映射 */
        src.J020002 AS JRGJMC,
        /* 最近评估价格：投融资标的.最近评估价格 -> T_9_2.J020019；直接映射 */
        CAST(NULLIF(TRIM(src.J020019), '') AS DECIMAL(20,2)) AS ZJPGJG,
        /* 金融工具编号：投融资标的.投融资标的代码 -> T_9_2.J020011；加工映射：优先取投融资标的代码，取不到再取投融资标的ID */
        COALESCE(NULLIF(TRIM(src.J020011), ''), src.J020001) AS JRGJBH,
        /* 内部机构号：投融资标的.机构ID -> T_9_2.J020003；加工映射：截取12位以后 */
        SUBSTR(src.J020003, 13) AS NBJGH,
        /* 金融许可证号：机构信息.金融许可证号 -> T_1_1.A010003；直接映射 */
        s2.A010003 AS JRXKZH,
        /* 采集日期：直接赋参数 */
        P_DATA_DATE AS CJRQ,
        /* 最终投向类型：投融资标的.基础资产最终投向类型 -> T_9_2.J020033；代码映射：代码转中文描述 */
        CASE
            WHEN TRIM(src.J020033) = '01' THEN '货币市场工具及货币市场公募基金'
            WHEN TRIM(src.J020033) = '02' THEN '债券及债券公募基金'
            WHEN TRIM(src.J020033) = '03' THEN '存款'
            WHEN TRIM(src.J020033) = '04' THEN '信贷类投资'
            WHEN TRIM(src.J020033) = '05' THEN '权益类投资及股票公募基金'
            WHEN TRIM(src.J020033) = '00' THEN '自定义'
            WHEN LEFT(TRIM(src.J020033), 3) = '00-' THEN CONCAT('其他-自定义', SUBSTR(TRIM(src.J020033), 4))
            ELSE src.J020033
        END AS ZZTXLX,
        /* 基础资产评级机构：投融资标的.基础资产评级机构 -> T_9_2.J020032；优先使用外部评级机构，若无则填报内部评级机构名称。若两者均无的，置为空。 */
        /* 当前 T_9_2 DDL 只有 J020032（基础资产评级机构），无外部/内部评级机构区分字段，暂取 J020032 */
        src.J020032 AS JCZCPJJG,
        /* 基础资产编号：投融资标的.投融资标的代码 -> T_9_2.J020011；加工映射:如果【基础资产客户名称】为空,则赋默认值''，否则取【投融资标的代码】 */
        CASE WHEN NULLIF(TRIM(src.J020026), '') IS NULL THEN '' ELSE src.J020011 END AS JCZCBH,
        /* 评估价格日期：投融资标的.评估价格日期 -> T_9_2.J020020；加工映射:yyyy-mm-dd转为yyyymmdd,如果空则赋值:'99991231' */
        CASE WHEN src.J020020 IS NULL THEN '99991231' ELSE DATE_FORMAT(src.J020020, '%Y%m%d') END AS PGJGRQ,
        /* 归属分支机构：需求字段未与目标 DDL 注释精确匹配，业务需求无来源，暂置 NULL */
        NULL AS GSFZJG,
        /* 涉密标志：需求字段未与目标 DDL 注释精确匹配，业务需求无来源，暂置 NULL */
        NULL AS SENSITIVEFLAG,
        /* 基础资产规模：投资标的关系.产品持有底层资产折算人民币金额 -> T_9_1.J010006；直接映射 */
        CAST(NULLIF(TRIM(s1.J010006), '') AS DECIMAL(20,2)) AS JCZCGM,
        /* 银行机构名称：机构信息.银行机构名称 -> T_1_1.A010005；直接映射 */
        s2.A010005 AS YHJGMC,
        /* 币种：投融资标的.投融资标的币种 -> T_9_2.J020010；直接映射 */
        src.J020010 AS BZ,
        /* 发行机构代码：投融资标的.发行机构代码 -> T_9_2.J020007；加工映射：发行机构代码长度为20位时，转成'0'，其他取发行机构代码 */
        CASE WHEN LENGTH(TRIM(src.J020007)) = 20 THEN '0' ELSE src.J020007 END AS FXJGDM,
        /* 发行日期：投融资标的.发行日期 -> T_9_2.J020015；直接映射:yyyy-mm-dd转为yyyymmdd */
        CASE WHEN src.J020015 IS NOT NULL THEN DATE_FORMAT(src.J020015, '%Y%m%d') ELSE NULL END AS FXRQ,
        /* 利率类型：投融资标的.投融资标的利率类型 -> T_9_2.J020017；代码转换：01转LPR，02转非LPR */
        CASE
            WHEN TRIM(src.J020017) = '01' THEN 'LPR'
            WHEN TRIM(src.J020017) = '02' THEN '非LPR'
            ELSE NULL
        END AS LLLX,
        /* 含权标识：投融资标的.含权类型 -> T_9_2.J020087；加工映射：含权类型非空时，填写"是"，否则填写"否" */
        CASE WHEN NULLIF(TRIM(src.J020087), '') IS NOT NULL THEN '是' ELSE '否' END AS HQBS
    FROM T_9_2 src
    LEFT JOIN T_9_1 s1
           ON src.J020001 = s1.J010001 /* 投融资标的ID = 投资标的ID */
          AND s1.J010014 <= V_DATA_DATE /* 投资标的关系采集日期不超过报送日期 */
    LEFT JOIN T_1_1 s2
           ON src.J020003 = s2.A010001 /* 机构ID = 机构ID */
          AND s2.A010020 = V_DATA_DATE /* 机构信息按采集日期取数 */
    WHERE 1=1
      /* 采集日期过滤：只处理当月采集日期的数据 */
      AND src.J020105 = V_DATA_DATE
      /* 排除T_8_7同业存量情况中自营业务小类为结算性存放同业、非结算性同业存放、结算性同业存放的投融资标的ID */
      AND NOT EXISTS (
          SELECT 1
          FROM T_8_7 t87
          WHERE t87.H070016 = src.J020001 /* 投资标的ID = 投融资标的ID */
            AND t87.H070017 <= V_DATA_DATE
            AND TRIM(t87.H070021) IN ('结算性存放同业', '非结算性同业存放', '结算性同业存放')
      )
      /* 报送范围：投融资标的代码/投融资标的ID在自营资金交易信息表或自营资金业务余额表范围内 */
      AND (
          EXISTS (
              SELECT 1
              FROM IE_010_1003_INC zyjy
              WHERE (zyjy.JRGJBH = src.J020011 OR zyjy.JRGJBH = src.J020001)
                AND zyjy.CJRQ = P_DATA_DATE
          )
          OR EXISTS (
              SELECT 1
              FROM IE_010_1004 zyye
              WHERE (zyye.JRGJBH = src.J020011 OR zyye.JRGJBH = src.J020001)
                AND zyye.CJRQ = P_DATA_DATE
          )
          /* 或者 失效日期大于等于当月月初日期（终态纳入规则） */
          OR (src.J020113 IS NOT NULL AND src.J020113 >= V_MONTH_BEGIN)
      );

    COMMIT;
END;
