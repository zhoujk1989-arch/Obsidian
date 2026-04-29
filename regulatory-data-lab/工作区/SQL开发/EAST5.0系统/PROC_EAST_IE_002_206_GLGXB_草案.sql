CREATE PROCEDURE PROC_EAST_IE_002_206_GLGXB(
    IN I_DATE VARCHAR(8),
                                                OUT OI_RETCODE   INT,
                                                OUT OI_REMESSAGE VARCHAR
)
BEGIN
/******
      程序名称  ：关联关系表
      程序功能  ：加工 EAST 关联关系表 IE_002_206
      目标表    ：IE_002_206
      源表      ：
        - T_3_1 重要股东及主要关联企业（关系人为对公、集团和供应链）
        - T_3_2 高管及重要关系人信息（关系人为个人）
        - IE_002_203 对公客户信息表（客户主数据 enrichment）
      创建人    ：opencode（LLM）
      创建日期  ：2026-04-29
      版本号    ：V0.0.1-draft
      依据材料  ：《附件2："一表通"转换EAST映射规则.xls》第 233 行
                 原始材料/业务需求/EAST5.0/012_关联关系表.md
******/

  DECLARE P_DATE      DATE;
  DECLARE P_PROC_NAME VARCHAR(200);
  DECLARE P_STATUS    INT;
  DECLARE P_START_DT  DATETIME;
  DECLARE P_SQLCDE    VARCHAR(200);
  DECLARE P_STATE     VARCHAR(200);
  DECLARE P_SQLMSG    VARCHAR(2000);
  DECLARE P_STEP_NO   INT;
  DECLARE P_DESCB     VARCHAR(200);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 P_SQLCDE = GBASE_ERRNO,
                              P_SQLMSG = MESSAGE_TEXT,
                              P_STATE  = RETURNED_SQLSTATE;
    SET P_STATUS = -1;
    SET P_START_DT = NOW();
    SET P_STEP_NO = P_STEP_NO + 1;
    SET P_DESCB = '程序异常';
    CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                          P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);
    SET OI_RETCODE = P_STATUS;
    SET OI_REMESSAGE = P_DESCB || ':' || P_SQLCDE || ' - ' || P_SQLMSG;
    SELECT OI_RETCODE, '|', OI_REMESSAGE;
  END;

  /* 变量初始化 */
  SET P_DATE = TO_DATE(I_DATE, 'YYYYMMDD');
  SET P_PROC_NAME = 'PROC_EAST_IE_002_206_GLGXB';
  SET OI_RETCODE = 0;
  SET P_STATUS = 0;
  SET P_STEP_NO = 0;

  /* 1. 过程开始执行 */
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '过程开始执行';
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

  /* 2. 清除数据：按采集日期全量刷新 */
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '清除数据';

  DELETE FROM IE_002_206 WHERE CJRQ = I_DATE;

  COMMIT;

  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

  /* 3. 插入数据 */
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '数据插入';

  INSERT INTO IE_002_206 (
    JRXKZH,    -- 01 金融许可证号
    NBJGH,     -- 02 内部机构号
    KHTYBH,    -- 03 客户统一编号
    KHMC,      -- 04 客户名称
    KHZJLB,    -- 05 客户证件类别
    KHZJHM,    -- 06 客户证件号码
    GXLX,      -- 07 关系类型
    GLRKHTYBH, -- 08 关联人客户统一编号
    GLRMC,     -- 09 关联人名称
    GLRLB,     -- 10 关联人类别
    GLRZJLB,   -- 11 关联人证件类别
    GLRZJHM,   -- 12 关联人证件号码
    GXZT,      -- 13 关系状态
    BBZ,       -- 14 备注
    CJRQ       -- 15 采集日期
  )
  SELECT
    cust.JRXKZH,                          -- 金融许可证号：关联对公客户信息表
    cust.NBJGH,                           -- 内部机构号：关联对公客户信息表
    src.KHDID,                            -- 客户统一编号：直接映射
    cust.KHMC,                            -- 客户名称：关联对公客户信息表
    cust.ZJLB,                            -- 客户证件类别：关联对公客户信息表
    cust.ZJHM,                            -- 客户证件号码：关联对公客户信息表
    CASE src.GXLX_DM
      WHEN '01' THEN '母公司'
      WHEN '02' THEN '子公司'
      WHEN '03' THEN '与该企业受同一母公司控制的其他企业'
      WHEN '04' THEN '与该企业实施共同控制的投资方'
      WHEN '05' THEN '对该企业施加重大影响的投资方'
      WHEN '06' THEN '该企业的合营企业'
      WHEN '07' THEN '该企业的联营企业'
      WHEN '08' THEN '该企业的主要投资者个人及与其关系密切的家庭成员'
      WHEN '09' THEN '该企业或其母公司的关键管理人员及与其关系密切的家庭成员'
      WHEN '10' THEN '该企业主要投资者个人、关键管理人员或与其关系密切的家庭成员控制、共同控制或施加重大影响的其他企业'
      WHEN '11' THEN '供应链上下游'
      WHEN '12' THEN '担保关系'
      WHEN src.GXLX_DM LIKE '00-%' THEN CONCAT('其他-', SUBSTRING(src.GXLX_DM, 4))
      ELSE src.GXLX_DM
    END,                                  -- 关系类型：码值转换
    src.GLRKHDID,                         -- 关联人客户统一编号：直接映射
    src.GLRMC,                            -- 关联人名称：直接映射
    CASE src.GLRLB_DM
      WHEN '01' THEN '自然人'
      WHEN '02' THEN '国有企业'
      WHEN '03' THEN '民营企业'
      WHEN '04' THEN '政府机关'
      WHEN '05' THEN '事业单位'
      WHEN '06' THEN '社会团体'
      WHEN '07' THEN '境外机构'
      WHEN src.GLRLB_DM LIKE '00-%' THEN CONCAT('其他-', SUBSTRING(src.GLRLB_DM, 4))
      ELSE src.GLRLB_DM
    END,                                  -- 关联人类别：码值转换
    CASE
      WHEN src.GLRZJLB_DM LIKE '1999-%' THEN CONCAT('其他-', SUBSTRING(src.GLRZJLB_DM, 6))
      WHEN src.GLRZJLB_DM LIKE '2999-%' THEN CONCAT('其他-', SUBSTRING(src.GLRZJLB_DM, 6))
      ELSE src.GLRZJLB_DM
    END,                                  -- 关联人证件类别：1999/2999转其他
    src.GLRZJHM,                          -- 关联人证件号码：直接映射
    CASE
      WHEN src.GXLX_SX_RQ IS NULL OR src.GXLX_SX_RQ > TO_DATE(I_DATE, 'YYYYMMDD') THEN '1'
      ELSE '0'
    END,                                  -- 关系状态：失效判断
    src.BZ,                               -- 备注：直接映射
    I_DATE                                -- 采集日期：默认值报告日
  FROM (
    /* 来源1：重要股东及主要关联企业（关系人为对公、集团和供应链） */
    SELECT
      C010002   AS KHDID,                -- 客户ID
      C010019   AS GLRKHDID,             -- 股东/关联企业客户ID
      C010005   AS GLRMC,                -- 股东/关联企业名称
      C010015   AS GXLX_DM,              -- 关系类型代码
      C010018   AS GLRLB_DM,             -- 关联人类别代码
      C010007   AS GLRZJLB_DM,           -- 股东/关联企业证件类型
      C010008   AS GLRZJHM,              -- 股东/关联企业证件号码
      C010020   AS BZ,                   -- 备注
      C010017   AS GXLX_SX_RQ            -- 采集日期（作为关系失效时间代理）
    FROM T_3_1
    WHERE C010017 = TO_DATE(I_DATE, 'YYYYMMDD')

    UNION ALL

    /* 来源2：高管及重要关系人信息（关系人为个人） */
    SELECT
      C020002   AS KHDID,                -- 客户ID
      C020016   AS GLRKHDID,             -- 关系人客户ID
      C020004   AS GLRMC,                -- 关系人姓名
      C020009   AS GXLX_DM,              -- 关系类型代码
      C020015   AS GLRLB_DM,             -- 关联人类别代码
      C020005   AS GLRZJLB_DM,           -- 关系人证件类型
      C020006   AS GLRZJHM,              -- 关系人证件号码
      C020017   AS BZ,                   -- 备注
      C020013   AS GXLX_SX_RQ            -- 关系失效日期
    FROM T_3_2
    WHERE C020014 = TO_DATE(I_DATE, 'YYYYMMDD')
      AND (C020013 IS NULL OR C020013 > TO_DATE(I_DATE, 'YYYYMMDD'))
  ) src
  LEFT JOIN IE_002_203 cust
    ON src.KHDID = cust.KHTYBH
   AND cust.CJRQ = I_DATE;

  COMMIT;

  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

  /* 4. 过程结束执行 */
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '过程结束执行';
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);
  SET OI_RETCODE = P_STATUS;
  SET OI_REMESSAGE = P_DESCB;
  SELECT OI_RETCODE, '|', OI_REMESSAGE;
END;
