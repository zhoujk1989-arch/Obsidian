/*
校验脚本：CHECK_EAST_IE_004_412_INC_DGXDFHZMX_校验.sql
业务目标：校验 PROC_EAST_IE_004_412_INC_DGXDFHZMX 存储过程输出质量。
目标系统：EAST5.0系统。
依赖：IE_004_412_INC 目标表、T_7_2 源表、T_1_1 源表。
参数：P_DATA_DATE（YYYYMMDD）。
*/

/* 校验 1：目标行数与源表采集日期过滤行数一致 */
SELECT
    COUNT(*) AS target_rows
FROM IE_004_412_INC
WHERE CJRQ = '20260501';  /* 替换为实际 P_DATA_DATE */

SELECT
    COUNT(*) AS source_rows
FROM T_7_2
WHERE G020030 = DATE '2026-05-01';  /* 替换为实际 P_DATA_DATE */

/* 校验 2：主键重复检查（HXJYSJ, XDJJH, JYXLH, HXJYRQ, DKFHZH, CJRQ） */
SELECT
    HXJYSJ, XDJJH, JYXLH, HXJYRQ, DKFHZH, CJRQ,
    COUNT(*) AS cnt
FROM IE_004_412_INC
GROUP BY HXJYSJ, XDJJH, JYXLH, HXJYRQ, DKFHZH, CJRQ
HAVING COUNT(*) > 1;

/* 校验 3：交易类型（JYLX）码值检查 */
SELECT
    JYLX,
    COUNT(*) AS cnt
FROM IE_004_412_INC
GROUP BY JYLX;
-- 预期码值：贷款发放、贷款还本、贷款还息、其他-XX、原值

/* 校验 4：交易借贷标志（JYJDBZ）码值检查 */
SELECT
    JYJDBZ,
    COUNT(*) AS cnt
FROM IE_004_412_INC
GROUP BY JYJDBZ;
-- 预期码值：借、贷、原值

/* 校验 5：交易渠道（JYQD）码值检查 */
SELECT
    JYQD,
    COUNT(*) AS cnt
FROM IE_004_412_INC
GROUP BY JYQD;
-- 预期码值：柜面、ATM、VTM、POS、网银、手机银行、银联交易、第三方支付-XX、其他-XX、原值

/* 校验 6：冲补抹标志（CBMBZ）码值检查 */
SELECT
    CBMBZ,
    COUNT(*) AS cnt
FROM IE_004_412_INC
GROUP BY CBMBZ;
-- 预期码值：正常、冲补抹、原值

/* 校验 7：现转标志（XZBZ）码值检查 */
SELECT
    XZBZ,
    COUNT(*) AS cnt
FROM IE_004_412_INC
GROUP BY XZBZ;
-- 预期码值：现、转、原值

/* 校验 8：核心交易时间（HXJYSJ）格式检查：应为 6 位数字 HHMMSS */
SELECT
    HXJYSJ,
    COUNT(*) AS cnt
FROM IE_004_412_INC
WHERE HXJYSJ IS NOT NULL
  AND HXJYSJ NOT LIKE '[0-2][0-9][0-5][0-9][0-5][0-9]'
GROUP BY HXJYSJ;

/* 校验 9：核心交易日期（HXJYRQ）格式检查：应为 8 位数字 YYYYMMDD */
SELECT
    HXJYRQ,
    COUNT(*) AS cnt
FROM IE_004_412_INC
WHERE HXJYRQ IS NOT NULL
  AND HXJYRQ NOT LIKE '[0-9][0-9][0-9][0-9][0-1][0-2][0-3][0-9]'
GROUP BY HXJYRQ;

/* 校验 10：采集日期（CJRQ）格式检查：应为 8 位数字 YYYYMMDD */
SELECT
    CJRQ,
    COUNT(*) AS cnt
FROM IE_004_412_INC
WHERE CJRQ IS NOT NULL
  AND CJRQ NOT LIKE '[0-9][0-9][0-9][0-9][0-1][0-2][0-3][0-9]'
GROUP BY CJRQ;

/* 校验 11：交易金额（JYJE）非负检查（账户余额统一正数填报） */
SELECT
    COUNT(*) AS neg_jyje_cnt
FROM IE_004_412_INC
WHERE JYJE IS NOT NULL AND JYJE < 0;

SELECT
    COUNT(*) AS neg_zhye_cnt
FROM IE_004_412_INC
WHERE ZHYE IS NOT NULL AND ZHYE < 0;

/* 校验 12：交易类型（JYLX）非空检查 */
SELECT
    COUNT(*) AS null_jylx_cnt
FROM IE_004_412_INC
WHERE JYLX IS NULL OR TRIM(JYLX) = '';

/* 校验 13：币种（BZ）长度检查：应为 3 位 */
SELECT
    BZ,
    COUNT(*) AS cnt
FROM IE_004_412_INC
WHERE BZ IS NOT NULL AND LENGTH(TRIM(BZ)) <> 3
GROUP BY BZ;

/* 校验 14：内部机构号（NBJGH）长度检查 */
SELECT
    NBJGH,
    COUNT(*) AS cnt
FROM IE_004_412_INC
WHERE NBJGH IS NOT NULL AND LENGTH(TRIM(NBJGH)) = 0
GROUP BY NBJGH;

/* 校验 15：业务办理机构号（YWBLJGH）长度检查 */
SELECT
    YWBLJGH,
    COUNT(*) AS cnt
FROM IE_004_412_INC
WHERE YWBLJGH IS NOT NULL AND LENGTH(TRIM(YWBLJGH)) = 0
GROUP BY YWBLJGH;

/* 校验 16：涉密标志（SENSITIVEFLAG）预期 NULL 检查 */
SELECT
    COUNT(*) AS sensitiveflag_not_null_cnt
FROM IE_004_412_INC
WHERE SENSITIVEFLAG IS NOT NULL;

/* 校验 17：归属分支机构（GSFZJG）预期 NULL 检查 */
SELECT
    COUNT(*) AS gsfzjg_not_null_cnt
FROM IE_004_412_INC
WHERE GSFZJG IS NOT NULL;

/* 校验 18：对方客户类别（DFKHLB）预期 NULL 检查 */
SELECT
    COUNT(*) AS dfkhlb_not_null_cnt
FROM IE_004_412_INC
WHERE DFKHLB IS NOT NULL;

/* 校验 19：账户名称（ZHMC）NULL 检查（已知 TODO 占位） */
SELECT
    COUNT(*) AS zhmc_null_cnt
FROM IE_004_412_INC
WHERE ZHMC IS NULL;

/* 校验 20：机构信息关联缺失检查（JRXKZH/YHJGMC 为空的比例） */
SELECT
    COUNT(*) AS org_missing_cnt
FROM IE_004_412_INC
WHERE JRXKZH IS NULL OR YHJGMC IS NULL;

/* 校验 21：交易柜员号（JYGYH）"自动"残留检查 */
SELECT
    COUNT(*) AS jygyh_auto_cnt
FROM IE_004_412_INC
WHERE JYGYH = '自动';

/* 校验 22：授权柜员号（SQGYH）"自动"残留检查 */
SELECT
    COUNT(*) AS sqgyh_auto_cnt
FROM IE_004_412_INC
WHERE SQGYH = '自动';

/* 校验 23：交易金额（JYJE）与账户余额（ZHYE）同时为空的异常检查 */
SELECT
    COUNT(*) AS both_null_amt_cnt
FROM IE_004_412_INC
WHERE JYJE IS NULL AND ZHYE IS NULL;

/* 校验 24：交易序列号（JYXLH）非空检查 */
SELECT
    COUNT(*) AS null_jyxlh_cnt
FROM IE_004_412_INC
WHERE JYXLH IS NULL OR TRIM(JYXLH) = '';

/* 校验 25：贷款分户账号（DKFHZH）非空检查 */
SELECT
    COUNT(*) AS null_dkfzh_cnt
FROM IE_004_412_INC
WHERE DKFHZH IS NULL OR TRIM(DKFHZH) = '';
