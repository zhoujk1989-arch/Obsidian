/*
重构校准状态：已按原始业务需求《048_贷款五级形态变动表.md》逐字段校准完成。
校准日期：2026-05-09
重构内容：
- 源表从 TODO_SOURCE_TABLE 替换为 T_8_12（五级分类状态，一表通系统）
- 补齐所有 18 个字段的来源字段映射、码值转换、JOIN 条件、WHERE 筛选
- 补全 LEFT JOIN 关联：EAST 对公信贷分户账(IE_004_411)、个人信贷分户账(IE_004_409)、
  信用卡信息表(IE_008_801)、机构信息(T_1_1)、对公客户信息表(IE_002_203)、个人基础信息表(IE_002_201)
- 补齐表级规则：采集日期在跑批日期当月内 且 采集日期=调整日期
- 排除新发放业务（原五级分类为空或'00'的记录）
- 码值转换：五级分类码值传递、变动方式码值传递、经办人工号自动变动置空
- 信用卡 XDJJH 特殊处理：若细分资产ID非空则取之，否则取信用卡信息表第一条卡号
- 信贷借据号分行标识：对公/个人取细分资产ID；信用卡取细分资产ID或信用卡卡号
- 缺口字段 GSFZJG/KHLB/SENSITIVEFLAG 从 EAST 表关联获取
- 移除 WHERE 1=1 占位，直接以首个 AND 条件开始
- T_1_1 LEFT JOIN 补齐采集日期过滤防止重复行（inst.A010020 = V_DATA_DATE）
*/

/*
业务目标：
- 依据原始业务需求《048_贷款五级形态变动表.md》生成 EAST5.0 贷款五级形态变动表（IE_007_705_INC）GBase 存储过程。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程。

依赖材料：
- 原始材料/业务需求/EAST5.0/048_贷款五级形态变动表.md
- 原始材料/表结构/EAST5.0系统/IE_007_705_INC-贷款五级形态变动表-DDL-2026-04-28.sql
- 原始材料/表结构/一表通系统/T_8_12-五级分类状态-DDL-2026-04-27.sql
- 原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_411-对公信贷分户账-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_004_409-个人信贷分户账-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_008_801-信用卡信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_203-对公客户信息表-DDL-2026-04-28.sql
- 原始材料/表结构/EAST5.0系统/IE_002_201-个人基础信息表-DDL-2026-04-28.sql

源表（一表通系统）：
- T_8_12 五级分类状态（主表）
- T_1_1 机构信息（关联获取银行机构名称、金融许可证号）

源表（EAST5.0转换结果表）：
- IE_004_411 对公信贷分户账（关联获取对公客户统一编号）
- IE_004_409 个人信贷分户账（关联获取个人客户统一编号）
- IE_008_801 信用卡信息表（关联获取信用卡客户统一编号、客户名称、卡号）
- IE_002_203 对公客户信息表（关联获取对公客户名称）
- IE_002_201 个人基础信息表（关联获取个人客户名称）

目标表：
- IE_007_705_INC：贷款五级形态变动表。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。

运行方式：
- 按采集日期删除后重插（增量重跑）。

报送模式：
- 增量表，报送上一采集日至采集日期间新增的数据。

报送要求：
- 所有表内信贷的五级分类变动信息，与其他表格中五级分类字段一致。
- 需要报送信用卡业务的五级形态变动，填报为信贷合同号=信用卡账号，信贷借据号=信用卡卡号。
- 无需报送新发放业务（五级分类从无到有）的五级形态变动。

表级取数与关联规则：
### 2.1 表级规则（Excel第 1121 行）
【五级分类状态】.【采集日期】在跑批日期当月内
且【五级分类状态】.【采集日期】=【五级分类状态】.【调整日期】

字段映射概要：
| EAST目标字段 | 来源 | 来源字段 | 规则 |
|---|---|---|---|
| XDJJH 信贷借据号 | T_8_12 | 细分资产ID(H120002) / 信用卡信息表.KH | 对公/个人：直接取H120002；信用卡：H120002非空取H120002否则取信用卡KH(按开卡日期降序\卡号降序取首条) |
| KHTYBH 客户统一编号 | EAST信贷分户账/信用卡信息表 | KHTYBH | 对公LEFT JOIN IE_004_411, 个人LEFT JOIN IE_004_409, 信用卡LEFT JOIN IE_008_801, COALESCE |
| CJRQ 采集日期 | 参数P_DATA_DATE | - | 格式转换：跑批日期YYYYMMDD |
| GSFZJG 归属分支机构 | EAST信贷分户账/信用卡信息表 | GSFZJG | COALESCE(dk.GSFZJG, gr.GSFZJG, cc.GSFZJG) |
| YWJFL 原五级分类 | T_8_12 | 原五级分类(H120006) | 码值透传：01正常02关注03次级04可疑05损失00为空 |
| TZRQ 调整日期 | T_8_12 | 调整日期(H120004) | 格式转换：DATE->YYYYMMDD |
| YHJGMC 银行机构名称 | T_1_1 | 银行机构名称(A010005) | SUBSTR(H120003,12) LEFT JOIN T_1_1 |
| BBZ 备注 | T_8_12 | 备注(H120015) | 直接映射 |
| NBJGH 内部机构号 | T_8_12 | 机构ID(H120003) | SUBSTR(H120003, 12) |
| JRXKZH 金融许可证号 | T_1_1 | 金融许可证号(A010003) | SUBSTR(H120003,12) LEFT JOIN T_1_1 |
| KHLB 客户类别 | IE_008_801 | KHLB | 从信用卡信息表获取（缺口字段） |
| SENSITIVEFLAG 涉密标志 | EAST信贷账/信用卡信息表 | SENSITIVEFLAG | COALESCE(dk.SENSITIVEFLAG, gr.SENSITIVEFLAG, cc.SENSITIVEFLAG) |
| BDFS 变动方式 | T_8_12 | 变动方式(H120007) | 码值透传：01人工02自动 |
| BDYY 变动原因 | T_8_12 | 变动原因(H120008) | 直接映射 |
| JBGYH 经办人工号 | T_8_12 | 经办员工ID(H120009) | 变动方式=02(自动)时置空，否则直接映射 |
| XWJFL 新五级分类 | T_8_12 | 当前五级分类(H120005) | 码值透传：01正常02关注03次级04可疑05损失00为空 |
| KHMC 客户名称 | EAST客户信息表 | KHMC/KHXM | 对公: dk.KHTYBH->IE_002_203.KHMC; 个人: gr.KHTYBH->IE_002_201.KHXM; 信用卡: cc.KHMC |
| XDHTH 信贷合同号 | T_8_12 | 协议ID(H120001) | 直接映射 |

注意：现场库名、模式名可能需要根据实际部署环境调整（如加库名前缀或Schema）。
*/

DROP PROCEDURE IF EXISTS PROC_EAST_IE_007_705_INC_DKWJXTBDB;

CREATE PROCEDURE PROC_EAST_IE_007_705_INC_DKWJXTBDB(
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

    DELETE FROM IE_007_705_INC
     WHERE CJRQ = P_DATA_DATE;

    -- 信用卡信息表排名：用于信用卡的 XDJJH 回退取卡号、KHTYBH/KHMC 取首条
    -- 按 信用卡账号 分组，按 开卡日期 降序、卡号 降序取第一条
    WITH cc_ranked AS (
        SELECT
            XYKZH,
            KH,
            KHTYBH,
            KHMC,
            GSFZJG,
            SENSITIVEFLAG,
            KHLB,
            ROW_NUMBER() OVER (
                PARTITION BY XYKZH
                ORDER BY KKRQ DESC, KH DESC
            ) AS rn
        FROM IE_008_801
        WHERE CJRQ = P_DATA_DATE
    )
    INSERT INTO IE_007_705_INC (
        XDJJH,
        KHTYBH,
        CJRQ,
        GSFZJG,
        YWJFL,
        TZRQ,
        YHJGMC,
        BBZ,
        NBJGH,
        JRXKZH,
        KHLB,
        SENSITIVEFLAG,
        BDFS,
        BDYY,
        JBGYH,
        XWJFL,
        KHMC,
        XDHTH
    )
    SELECT
        /* XDJJH 信贷借据号
           对公/个人贷款：直接取 T_8_12.细分资产ID(H120002)
           信用卡：若细分资产ID非空则取之，否则取信用卡信息表首条卡号(KH)
        */
        COALESCE(NULLIF(src.H120002, ''), cc.KH) AS XDJJH,

        /* KHTYBH 客户统一编号
           对公：H120002 -> LEFT JOIN IE_004_411.XDJJH -> IE_004_411.KHTYBH
           个人：H120002 -> LEFT JOIN IE_004_409.XDJJH -> IE_004_409.KHTYBH
           信用卡：H120001 -> LEFT JOIN IE_008_801.XYKZH -> IE_008_801.KHTYBH（首条）
        */
        COALESCE(dk.KHTYBH, gr.KHTYBH, cc.KHTYBH) AS KHTYBH,

        /* CJRQ 采集日期
           格式转换：取参数 P_DATA_DATE（YYYYMMDD）
        */
        P_DATA_DATE AS CJRQ,

        /* GSFZJG 归属分支机构
           缺口字段：从关联的 EAST 表获取（对公/个人/信用卡）
        */
        COALESCE(dk.GSFZJG, gr.GSFZJG, cc.GSFZJG) AS GSFZJG,

        /* YWJFL 原五级分类
           来源：T_8_12.原五级分类(H120006)
           码值透传：01正常 02关注 03次级 04可疑 05损失 00为空
        */
        src.H120006 AS YWJFL,

        /* TZRQ 调整日期
           来源：T_8_12.调整日期(H120004)
           格式转换：DATE -> YYYYMMDD
        */
        DATE_FORMAT(src.H120004, '%Y%m%d') AS TZRQ,

        /* YHJGMC 银行机构名称
           来源：从 T_8_12.机构ID(H120003) 第12位截取 -> LEFT JOIN T_1_1.机构ID(A010001) -> T_1_1.银行机构名称(A010005)
        */
        inst.A010005 AS YHJGMC,

        /* BBZ 备注
           来源：T_8_12.备注(H120015) - 直接映射
        */
        src.H120015 AS BBZ,

        /* NBJGH 内部机构号
           来源：T_8_12.机构ID(H120003) 从第12位开始截取
        */
        SUBSTR(src.H120003, 12) AS NBJGH,

        /* JRXKZH 金融许可证号
           来源：从 T_8_12.机构ID(H120003) 第12位截取 -> LEFT JOIN T_1_1 -> T_1_1.金融许可证号(A010003)
        */
        inst.A010003 AS JRXKZH,

        /* KHLB 客户类别
           缺口字段：从信用卡信息表获取
        */
        cc.KHLB AS KHLB,

        /* SENSITIVEFLAG 涉密标志
           缺口字段：从关联的 EAST 表获取（对公/个人/信用卡）
        */
        COALESCE(dk.SENSITIVEFLAG, gr.SENSITIVEFLAG, cc.SENSITIVEFLAG) AS SENSITIVEFLAG,

        /* BDFS 变动方式
           来源：T_8_12.变动方式(H120007)
           码值透传：01人工 02自动
        */
        src.H120007 AS BDFS,

        /* BDYY 变动原因
           来源：T_8_12.变动原因(H120008) - 直接映射
        */
        src.H120008 AS BDYY,

        /* JBGYH 经办人工号
           来源：T_8_12.经办员工ID(H120009)
           规则：若变动方式='02'(自动)，则置空；否则直接映射
        */
        CASE WHEN src.H120007 = '02' THEN '' ELSE src.H120009 END AS JBGYH,

        /* XWJFL 新五级分类
           来源：T_8_12.当前五级分类(H120005)
           码值透传：01正常 02关注 03次级 04可疑 05损失 00为空
        */
        src.H120005 AS XWJFL,

        /* KHMC 客户名称
           对公：dk.KHTYBH -> LEFT JOIN IE_002_203(对公客户信息表).KHTYBH -> IE_002_203.KHMC
           个人：gr.KHTYBH -> LEFT JOIN IE_002_201(个人基础信息表).KHTYBH -> IE_002_201.KHXM
           信用卡：cc.KHMC（来自信用卡信息表）
        */
        COALESCE(dk_cust.KHMC, gr_cust.KHXM, cc.KHMC) AS KHMC,

        /* XDHTH 信贷合同号
           来源：T_8_12.协议ID(H120001) - 直接映射
        */
        src.H120001 AS XDHTH

    FROM T_8_12 src

    /* LEFT JOIN 对公信贷分户账 (IE_004_411)
       关联键：T_8_12.细分资产ID(H120002) = IE_004_411.信贷借据号(XDJJH)
       用于获取对公贷款客户的：客户统一编号、归属分支机构、涉密标志
    */
    LEFT JOIN IE_004_411 dk
        ON src.H120002 = dk.XDJJH
        AND dk.CJRQ = P_DATA_DATE

    /* LEFT JOIN 个人信贷分户账 (IE_004_409)
       关联键：T_8_12.细分资产ID(H120002) = IE_004_409.信贷借据号(XDJJH)
       用于获取个人贷款客户的：客户统一编号、归属分支机构、涉密标志
    */
    LEFT JOIN IE_004_409 gr
        ON src.H120002 = gr.XDJJH
        AND gr.CJRQ = P_DATA_DATE

    /* LEFT JOIN 信用卡信息表 (cc_ranked)
       关联键：T_8_12.协议ID(H120001) = IE_008_801.信用卡账号(XYKZH)
       取按信用卡账号分组、开卡日期降序、卡号降序的首条记录
       用于获取信用卡客户的：卡号(用于XDJJH回退)、客户统一编号、客户名称等
    */
    LEFT JOIN cc_ranked cc
        ON src.H120001 = cc.XYKZH
        AND cc.rn = 1

    /* LEFT JOIN 机构信息 (T_1_1)
       关联键：SUBSTR(T_8_12.机构ID(H120003), 12) = SUBSTR(T_1_1.机构ID(A010001), 12)
       用于获取：银行机构名称、金融许可证号
    */
    LEFT JOIN T_1_1 inst
        ON SUBSTR(src.H120003, 12) = SUBSTR(inst.A010001, 12)
        AND inst.A010020 = V_DATA_DATE

    /* LEFT JOIN 对公客户信息表 (IE_002_203)
       关联键：IE_004_411.客户统一编号(KHTYBH) = IE_002_203.客户统一编号(KHTYBH)
       用于获取对公客户名称
    */
    LEFT JOIN IE_002_203 dk_cust
        ON dk.KHTYBH = dk_cust.KHTYBH
        AND dk_cust.CJRQ = P_DATA_DATE

    /* LEFT JOIN 个人基础信息表 (IE_002_201)
       关联键：IE_004_409.客户统一编号(KHTYBH) = IE_002_201.客户统一编号(KHTYBH)
       用于获取个人客户名称
    */
    LEFT JOIN IE_002_201 gr_cust
        ON gr.KHTYBH = gr_cust.KHTYBH
        AND gr_cust.CJRQ = P_DATA_DATE

    WHERE
        /* 表级规则：五级分类状态.采集日期(H120013) 在跑批日期当月内 */
        src.H120013 >= DATE_FORMAT(V_DATA_DATE, '%Y-%m-01')
        AND src.H120013 <= LAST_DAY(V_DATA_DATE)
        /* 表级规则：五级分类状态.采集日期(H120013) = 五级分类状态.调整日期(H120004) */
        AND src.H120013 = src.H120004
        /* 报送排除：无需报送新发放业务（五级分类从无到有）
           即排除原五级分类(H120006)为NULL或'00'(空)的记录 */
        AND (src.H120006 IS NOT NULL AND src.H120006 != '00' AND src.H120006 != '')
        /* 注意：以下条件确保只取发生变动的记录
           原五级分类(H120006) != 当前五级分类(H120005) 表示确实发生了变动 */
        AND src.H120006 != src.H120005;

    COMMIT;
END;
