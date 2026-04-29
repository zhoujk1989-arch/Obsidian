/*
业务目标：
- 从一表通机构信息映射生成 EAST 机构信息表 JGXXB（表编号 101）。
- 报送截至采集日有效的数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。
- 过滤掉上个月为停业和被合并、该月还是停业和被合并的机构，但回补总账会计全科目余额不为 0 和内部分户账有记录的机构。

目标系统：
- EAST5.0 系统 / 一表通系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖知识页：
- 待补充：[[来源-EAST5.0系统-101-机构信息表]]
- 待补充：[[报表-101-机构信息表-EAST5.0系统]]
- 待补充：[[数据表-101-机构信息表-EAST5.0系统]]
- 待补充：[[血缘-101-机构信息表-EAST5.0系统]]
- 待补充：[[数据表-T_1_1-机构信息-一表通系统]]
- 待补充：[[数据表-T_1_3-员工信息-一表通系统]]
- 待补充：[[数据表-T_4_1-总账会计全科目-一表通系统]]
- 待补充：[[数据表-T_4_3-内部分户账-一表通系统]]

源表：
- T_1_1：一表通机构信息，当日快照为主源，上月末快照用于连续停业判断。
- T_1_3：一表通员工表，用负责人工号补负责人职务。
- T_4_1：一表通总账会计全科目，用于识别仍有余额的机构。
- T_4_3：一表通内部分户账，用于识别仍有分户账记录的机构。

目标表：
- JGXXB：EAST 机构信息表（表编号 101）。

参数：
- P_DATA_DATE：采集日期，格式 YYYYMMDD。
- P_ORG_CODE：机构范围，可选，默认全量。
- P_BATCH_NO：批次号，可选。
- P_RERUN_FLAG：重跑标志，可选。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- GBase 8a MPP 日期函数 YEAR()、MONTH()、DAY()、DATE_SUB()、LAST_DAY() 的具体兼容性需按现场版本确认。
- 一表通源表的实际表名（T_1_1、T_1_3、T_4_1、T_4_3）需按现场环境替换。
- EAST 目标表 JGXXB 的实际表名和字段顺序需按现场 DDL 确认。
- 总账余额不为 0 的字段（D010003~D010008）是否覆盖全部余额方向需确认。
- 内部分户账的采集日期字段 D030015 是否准确需确认。
- 一表通机构信息表的内部机构号字段 A010002 与总账/内部分户账的内部机构号字段名是否一致需确认。
*/

CREATE OR REPLACE PROCEDURE PROC_EAST_JGXXB(
    IN P_DATA_DATE VARCHAR(8),
    IN P_ORG_CODE VARCHAR(30) DEFAULT NULL,
    IN P_BATCH_NO VARCHAR(64) DEFAULT NULL,
    IN P_RERUN_FLAG VARCHAR(1) DEFAULT 'N'
)
LANGUAGE PLBuiltin
AS
BEGIN
    /* ========== 变量声明区 ========== */
    DECLARE V_DATA_DATE DATE;
    DECLARE V_LAST_MON_DT DATE;
    DECLARE V_DELETE_COUNT INTEGER DEFAULT 0;
    DECLARE V_INSERT_COUNT INTEGER DEFAULT 0;
    DECLARE V_PROC_NAME VARCHAR(200) DEFAULT 'PROC_EAST_JGXXB';
    DECLARE V_STATUS INTEGER DEFAULT 0;
    DECLARE V_START_TIME TIMESTAMP;
    DECLARE V_STEP_DESC VARCHAR(500);

    /* 异常处理变量 */
    DECLARE V_ERR_SQLCODE INTEGER DEFAULT 0;
    DECLARE V_ERR_SQLSTATE VARCHAR(5) DEFAULT '00000';
    DECLARE V_ERR_MSG VARCHAR(2000) DEFAULT '';

    /* 异常处理器 */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS EXCEPTION 1
            V_ERR_SQLCODE = RETURNED_SQLSTATE,
            V_ERR_SQLSTATE = RETURNED_SQLSTATE,
            V_ERR_MSG = MESSAGE_TEXT;

        SET V_STATUS = -1;

        -- 日志写入：记录异常
        -- CALL PROC_ETL_PROC_LOG(
        --     P_PROC_NAME   => V_PROC_NAME,
        --     P_DATA_DATE   => P_DATA_DATE,
        --     P_BATCH_NO    => P_BATCH_NO,
        --     P_STATUS      => V_STATUS,
        --     P_START_TIME  => V_START_TIME,
        --     P_END_TIME    => CURRENT_TIMESTAMP,
        --     P_STEP_DESC   => V_STEP_DESC,
        --     P_DELETE_CNT  => V_DELETE_COUNT,
        --     P_INSERT_CNT  => V_INSERT_COUNT,
        --     P_ERROR_CODE  => V_ERR_SQLCODE,
        --     P_ERROR_MSG   => V_ERR_MSG
        -- );

        ROLLBACK;
        RESIGNAL;
    END;

    /* ========== 1. 参数校验 ========== */
    IF P_DATA_DATE IS NULL OR LENGTH(TRIM(P_DATA_DATE)) <> 8 THEN
        -- 日志：参数校验失败
        -- CALL PROC_ETL_PROC_LOG(
        --     P_PROC_NAME   => V_PROC_NAME,
        --     P_DATA_DATE   => P_DATA_DATE,
        --     P_BATCH_NO    => P_BATCH_NO,
        --     P_STATUS      => -2,
        --     P_START_TIME  => CURRENT_TIMESTAMP,
        --     P_END_TIME    => CURRENT_TIMESTAMP,
        --     P_STEP_DESC   => '参数校验失败：P_DATA_DATE 为空或非 8 位格式',
        --     P_DELETE_CNT  => 0,
        --     P_INSERT_CNT  => 0,
        --     P_ERROR_CODE  => -2,
        --     P_ERROR_MSG   => 'P_DATA_DATE 必须为 8 位日期格式 YYYYMMDD'
        -- );
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE 必须为 8 位日期格式 YYYYMMDD';
    END IF;

    -- 简单格式校验：只包含数字
    IF P_DATA_DATE NOT REGEXP '^[0-9]{8}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'P_DATA_DATE 格式错误，必须为 8 位数字 YYYYMMDD';
    END IF;

    /* ========== 2. 初始化日期变量 ========== */
    -- 将 YYYYMMDD 字符串转换为 DATE 类型
    -- 注意：此处使用标准 SQL 拼接方式，GBase 8a MPP 具体日期函数需按现场版本确认
    SET V_DATA_DATE = CAST(
        CONCAT(LEFT(P_DATA_DATE, 4), '-', SUBSTR(P_DATA_DATE, 5, 2), '-', SUBSTR(P_DATA_DATE, 7, 2))
        AS DATE
    );

    -- 上月末日期：用于连续停业判断
    SET V_LAST_MON_DT = LAST_DAY(DATE_SUB(V_DATA_DATE, INTERVAL 1 MONTH));

    /* ========== 3. 开始日志 ========== */
    SET V_START_TIME = CURRENT_TIMESTAMP;
    SET V_STEP_DESC = '过程启动：目标表 JGXXB，批次日期 ' || P_DATA_DATE;

    -- 日志写入：过程启动
    -- CALL PROC_ETL_PROC_LOG(
    --     P_PROC_NAME   => V_PROC_NAME,
    --     P_DATA_DATE   => P_DATA_DATE,
    --     P_BATCH_NO    => P_BATCH_NO,
    --     P_STATUS      => 0,
    --     P_START_TIME  => V_START_TIME,
    --     P_END_TIME    => NULL,
    --     P_STEP_DESC   => V_STEP_DESC,
    --     P_DELETE_CNT  => 0,
    --     P_INSERT_CNT  => 0,
    --     P_ERROR_CODE  => NULL,
    --     P_ERROR_MSG   => NULL
    -- );

    /* ========== 4. 事务开始 ========== */
    START TRANSACTION;

    /* ========== 5. 批次清理区 ========== */
    SET V_STEP_DESC = '清理目标表当期数据';

    DELETE FROM JGXXB
     WHERE CJRQ = P_DATA_DATE;

    SET V_DELETE_COUNT = ROW_COUNT();

    /* ========== 6. 主加工区 ========== */
    SET V_STEP_DESC = '主加工：机构信息映射与过滤';

    INSERT INTO JGXXB (
        YHJGDM,        -- 银行机构代码
        NBJGH,         -- 内部机构号
        JRXKZH,        -- 金融许可证号
        YYZZH,         -- 营业执照号
        YHJGMC,        -- 银行机构名称
        JGLB,          -- 机构类别
        XZQHDM,        -- 行政区划代码
        YYZT,          -- 营业状态
        CLRQ,          -- 成立日期
        JGDZ,          -- 机构地址
        JGLXDH,        -- 机构联系电话
        FZRXM,         -- 负责人姓名
        FZRZW,         -- 负责人职务
        FZRLXDH,       -- 负责人联系电话
        BBZ,           -- 备注
        CJRQ           -- 采集日期
    )
    SELECT
        -- 1. 银行机构代码：来源于机构信息.支付行号
        TRIM(org.A010006) AS YHJGDM,

        -- 2. 内部机构号：来源于机构信息.内部机构号
        TRIM(org.A010002) AS NBJGH,

        -- 3. 金融许可证号：来源于机构信息.金融许可证号
        TRIM(org.A010003) AS JRXKZH,

        -- 4. 营业执照号：来源于机构信息.统一社会信用代码
        TRIM(org.A010004) AS YYZZH,

        -- 5. 银行机构名称：来源于机构信息.银行机构名称
        TRIM(org.A010005) AS YHJGMC,

        -- 6. 机构类别：码值转换
        --    0101、0102 -> '管理机构'
        --    0201、0202、0203 -> '营业机构'
        --    0301、0302 -> '虚拟机构'
        --    0401、0402 -> '内设机构'
        --    其他 -> NULL（异常码值，需关注）
        CASE
            WHEN org.A010008 IN ('0101', '0102') THEN '管理机构'
            WHEN org.A010008 IN ('0201', '0202', '0203') THEN '营业机构'
            WHEN org.A010008 IN ('0301', '0302') THEN '虚拟机构'
            WHEN org.A010008 IN ('0401', '0402') THEN '内设机构'
            ELSE NULL
        END AS JGLB,

        -- 7. 行政区划代码：来源于机构信息.行政区划
        TRIM(org.A010013) AS XZQHDM,

        -- 8. 营业状态：码值转换
        --    01 -> '营业'
        --    00、02、03 -> '停业'
        --    其他 -> '停业'（未知状态按停业处理）
        CASE
            WHEN org.A010014 = '01' THEN '营业'
            WHEN org.A010014 IN ('00', '02', '03') THEN '停业'
            ELSE '停业'
        END AS YYZT,

        -- 9. 成立日期：来源于机构信息.成立日期，格式 YYYY-MM-DD 转换为 YYYYMMDD
        --    注意：GBase 8a MPP 日期函数 YEAR()/MONTH()/DAY() 需按现场版本确认
        CASE
            WHEN org.A010015 IS NOT NULL THEN
                CONCAT(
                    CAST(YEAR(org.A010015) AS VARCHAR(4)),
                    LPAD(CAST(MONTH(org.A010015) AS VARCHAR(2)), 2, '0'),
                    LPAD(CAST(DAY(org.A010015) AS VARCHAR(2)), 2, '0')
                )
            ELSE NULL
        END AS CLRQ,

        -- 10. 机构地址：来源于机构信息.机构地址
        TRIM(org.A010016) AS JGDZ,

        -- 11. 机构联系电话：来源于机构信息.机构联系电话
        TRIM(org.A010019) AS JGLXDH,

        -- 12. 负责人姓名：来源于机构信息.负责人姓名
        TRIM(org.A010017) AS FZRXM,

        -- 13. 负责人职务：来源于员工表.职务，通过机构信息.负责人工号关联员工表.员工ID 获取
        --    注意：一对多时需去重，当前通过子查询取最新记录
        emp.A030011 AS FZRZW,

        -- 14. 负责人联系电话：来源于机构信息.负责人联系电话
        TRIM(org.A010018) AS FZRLXDH,

        -- 15. 备注：来源于机构信息.备注
        TRIM(org.A010026) AS BBZ,

        -- 16. 采集日期：来源于机构信息.采集日期，格式 YYYY-MM-DD 转换为 YYYYMMDD
        --    注意：GBase 8a MPP 日期函数 YEAR()/MONTH()/DAY() 需按现场版本确认
        CASE
            WHEN org.A010020 IS NOT NULL THEN
                CONCAT(
                    CAST(YEAR(org.A010020) AS VARCHAR(4)),
                    LPAD(CAST(MONTH(org.A010020) AS VARCHAR(2)), 2, '0'),
                    LPAD(CAST(DAY(org.A010020) AS VARCHAR(2)), 2, '0')
                )
            ELSE NULL
        END AS CJRQ

    FROM (
        /* 主源：一表通机构信息表当日快照 */
        /* 去重逻辑：同一内部机构号取最大采集日期下的最大版本号 */
        SELECT
            t.A010001,
            t.A010002,
            t.A010003,
            t.A010004,
            t.A010005,
            t.A010006,
            t.A010008,
            t.A010013,
            t.A010014,
            t.A010015,
            t.A010016,
            t.A010017,
            t.A010018,
            t.A010019,
            t.A010020,
            t.A010024,
            t.A010026
        FROM T_1_1 t
        WHERE t.A010020 = V_DATA_DATE
          AND NOT EXISTS (
              SELECT 1
              FROM T_1_1 t_min
              WHERE t_min.A010020 = V_DATA_DATE
                AND t_min.A010002 = t.A010002
                AND t_min.A010001 < t.A010001
          )
    ) org

    /* 左关联：上月末机构快照，用于连续停业判断 */
    LEFT JOIN (
        SELECT
            t.A010002,
            t.A010014
        FROM T_1_1 t
        WHERE t.A010020 = V_LAST_MON_DT
          AND NOT EXISTS (
              SELECT 1
              FROM T_1_1 t_min
              WHERE t_min.A010020 = V_LAST_MON_DT
                AND t_min.A010002 = t.A010002
                AND t_min.A010001 < t.A010001
          )
    ) prev
      ON prev.A010002 = org.A010002

    /* 左关联：员工表，补负责人职务 */
    /* 去重逻辑：同一员工取最新采集日期记录 */
    LEFT JOIN (
        SELECT
            emp.A030001,
            emp.A030011
        FROM T_1_3 emp
        WHERE emp.A030028 <= V_DATA_DATE
          AND NOT EXISTS (
              SELECT 1
              FROM T_1_3 emp_rank
              WHERE emp_rank.A030001 = emp.A030001
                AND emp_rank.A030028 <= V_DATA_DATE
                AND (
                    emp_rank.A030028 > emp.A030028
                    OR (
                        emp_rank.A030028 = emp.A030028
                        AND emp_rank.A030002 < emp.A030002
                    )
                )
          )
    ) emp
      ON emp.A030001 = org.A010018

    /* 左关联：回补机构名（总账余额不为 0 或内部分户账有记录的机构） */
    LEFT JOIN (
        /* 总账会计全科目：余额不为 0 的机构 */
        SELECT DISTINCT g.A010001 AS org_id
        FROM T_4_1 g
        WHERE g.D010012 = V_DATA_DATE
          AND (
                COALESCE(CAST(NULLIF(TRIM(g.D010003), '') AS DECIMAL(22, 2)), 0)
              + COALESCE(CAST(NULLIF(TRIM(g.D010004), '') AS DECIMAL(22, 2)), 0)
              + COALESCE(CAST(NULLIF(TRIM(g.D010007), '') AS DECIMAL(22, 2)), 0)
              + COALESCE(CAST(NULLIF(TRIM(g.D010008), '') AS DECIMAL(22, 2)), 0)
          ) <> 0
        UNION
        /* 内部分户账：有当日记录的机构 */
        SELECT DISTINCT a.A010001 AS org_id
        FROM T_4_3 a
        WHERE a.D030015 = V_DATA_DATE
    ) supplement
      ON supplement.org_id = org.A010001

    /* 过滤条件：
     * 过滤掉上个月为停业（00/02/03）且该月仍为停业（00/02/03）的机构
     * 但回补总账余额不为 0 或内部分户账有记录的机构除外
     */
    WHERE NOT (
            COALESCE(prev.A010014, '') IN ('00', '02', '03')
        AND COALESCE(org.A010014, '') IN ('00', '02', '03')
        AND supplement.org_id IS NULL
    );

    SET V_INSERT_COUNT = ROW_COUNT();

    /* ========== 7. 提交事务 ========== */
    COMMIT;

    /* ========== 8. 结束日志 ========== */
    SET V_STEP_DESC = '过程结束：删除 ' || V_DELETE_COUNT || ' 行，插入 ' || V_INSERT_COUNT || ' 行';

    -- 日志写入：过程结束
    -- CALL PROC_ETL_PROC_LOG(
    --     P_PROC_NAME   => V_PROC_NAME,
    --     P_DATA_DATE   => P_DATA_DATE,
    --     P_BATCH_NO    => P_BATCH_NO,
    --     P_STATUS      => V_STATUS,
    --     P_START_TIME  => V_START_TIME,
    --     P_END_TIME    => CURRENT_TIMESTAMP,
    --     P_STEP_DESC   => V_STEP_DESC,
    --     P_DELETE_CNT  => V_DELETE_COUNT,
    --     P_INSERT_CNT  => V_INSERT_COUNT,
    --     P_ERROR_CODE  => NULL,
    --     P_ERROR_MSG   => NULL
    -- );

END;
