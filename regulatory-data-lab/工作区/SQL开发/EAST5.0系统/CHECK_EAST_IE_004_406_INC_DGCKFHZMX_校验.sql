/*
校验目标：EAST5.0 对公存款分户账明细记录（IE_004_406_INC）GBase 存储过程草案运行后检查。
对应过程：PROC_EAST_IE_004_406_INC_DGCKFHZMX
参数：P_DATA_DATE，格式 YYYYMMDD。
依据：《021_对公存款分户账明细记录.md》业务需求文档（33 个业务需求字段 + 3 个 DDL 缺口字段）。
*/

-- 1. 当期行数检查
SELECT COUNT(*) AS target_count
  FROM IE_004_406_INC
 WHERE CJRQ = ?;

-- 2. 主键/核心键重复检查（依据 DDL 注释中的 PK 字段）
SELECT DGCKZH, HXJYRQ, CJRQ, JYXLH, HXJYSJ, COUNT(*) AS dup_cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
 GROUP BY DGCKZH, HXJYRQ, CJRQ, JYXLH, HXJYSJ
HAVING COUNT(*) > 1;

-- 3. PK 字段为空检查
SELECT COUNT(*) AS null_pk_count
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND (DGCKZH IS NULL OR HXJYRQ IS NULL OR CJRQ IS NULL OR JYXLH IS NULL OR HXJYSJ IS NULL);

-- 4. 采集日期格式检查
SELECT CJRQ, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ IS NULL OR LENGTH(CJRQ) <> 8
 GROUP BY CJRQ;

-- 5. 核心交易日期格式检查（应为 YYYYMMDD，8 位数字）
SELECT HXJYRQ, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND (HXJYRQ IS NULL OR LENGTH(HXJYRQ) <> 8 OR HXJYRQ NOT LIKE '________')
 GROUP BY HXJYRQ;

-- 6. 核心交易时间格式检查（应为 HHMMSS，6 位数字或空）
SELECT HXJYSJ, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND (HXJYSJ IS NULL OR LENGTH(HXJYSJ) <> 6 OR HXJYSJ NOT LIKE '______')
 GROUP BY HXJYSJ;

-- 7. 交易类型码值检查（应为业务需求定义的码值）
SELECT JYLX, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND JYLX NOT IN ('转账', '取现', '存现', '消费', '代发', '代扣', '代缴', '结息',
                    '批量交易', '贷款发放', '贷款还本', '贷款还息', '银证业务', '投资理财',
                    '其他', '其他-XX')
 GROUP BY JYLX;

-- 8. 交易借贷标志码值检查（应为'借'或'贷'）
SELECT JYJDBZ, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND JYJDBZ NOT IN ('借', '贷')
 GROUP BY JYJDBZ;

-- 9. 币种码值检查（应为 3 位字符）
SELECT BZ, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND (BZ IS NULL OR LENGTH(BZ) <> 3)
 GROUP BY BZ;

-- 10. 冲补抹标志码值检查（应为'正常'/'冲补抹'或空）
SELECT CBMBZ, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND CBMBZ NOT IN ('正常', '冲补抹', '')
 GROUP BY CBMBZ;

-- 11. 现转标志码值检查（应为'现'/'转'或空）
SELECT XZBZ, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND XZBZ NOT IN ('现', '转', '')
 GROUP BY XZBZ;

-- 12. 交易渠道码值检查（应为业务需求定义的码值）
SELECT JYQD, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND JYQD NOT IN ('柜面', 'ATM', 'VTM', 'POS', '网银', '手机银行',
                    '第三方支付', '银联交易', '其他', '其他-XX')
 GROUP BY JYQD;

-- 13. 交易金额非负检查
SELECT COUNT(*) AS neg_amount_count
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND JYJE < 0;

-- 14. 内部机构号长度检查（SUBSTR 后应为有效长度）
SELECT COUNT(*) AS invalid_nbjgh_count
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND (NBJGH IS NULL OR LENGTH(NBJGH) = 0);

-- 15. 业务办理机构号长度检查
SELECT COUNT(*) AS invalid_ywbljgh_count
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND (YWBLJGH IS NULL OR LENGTH(YWBLJGH) = 0);

-- 16. 涉密标志来源检查（应来自 IE_004_405）
SELECT SENSITIVEFLAG, COUNT(*) AS cnt
  FROM IE_004_406_INC
 WHERE CJRQ = ?
 GROUP BY SENSITIVEFLAG;

-- 17. 对方客户类别检查（应为 NULL，业务需求未给来源）
SELECT COUNT(*) AS dfkhlb_not_null_count
  FROM IE_004_406_INC
 WHERE CJRQ = ?
   AND DFKHLB IS NOT NULL;

-- 18. 字段映射抽样回溯
-- TODO: 按存储过程中的来源表和业务键抽样核对源字段、目标字段和码值转换。
