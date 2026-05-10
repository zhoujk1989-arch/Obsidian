-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_010_1003_INC 自营资金交易信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_010_1003_INC`;
CREATE TABLE `IE_010_1003_INC` (
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `BFQSZH`                 VARCHAR(60)      DEFAULT NULL COMMENT '本方清算账号；填报机构进行交易实际使用的账号。',
  `JYDSLB`                 VARCHAR(30)      DEFAULT NULL COMMENT '交易对手类别',
  `YEDL`                   VARCHAR(60)      DEFAULT NULL COMMENT '业务大类',
  `YWZL`                   VARCHAR(60)      DEFAULT NULL COMMENT '业务中类',
  `JYDSPJ`                 VARCHAR(20)      DEFAULT NULL COMMENT '交易对手评级；允许填报内部评级，如交易对手为个人，允许为空',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `JYDSMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '交易对手名称；如果交易对手为个人，则为隐私，银行机构变形，个人变性规则见《采集技术接口说明》。如果为境内涉密机构的，填报为“*********”。其他情况，则为非隐私，不做变形。',
  `JYDSPJJG`               VARCHAR(450)     DEFAULT NULL COMMENT '交易对手评级机构',
  `JYDSKHHM`               VARCHAR(450)     DEFAULT NULL COMMENT '交易对手开户行名',
  `JYDSZH`                 VARCHAR(60)      DEFAULT NULL COMMENT '交易对手账号；填写交易对手结算实际使用的账号。',
  `JYBH`                   VARCHAR(60)      DEFAULT NULL COMMENT '交易编号；PK。',
  `MXKMMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '明细科目名称；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `HTYDRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同起始日期；合同约定生效日期，若无该字段信息可填报交易日期。',
  `JYZHLX`                 VARCHAR(12)      DEFAULT NULL COMMENT '账户类型',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `JYRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '交易日期',
  `MYBJJE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '合约金额；填报交易本金金额。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `CPMC`                   VARCHAR(300)     DEFAULT NULL COMMENT '产品名称',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `JYYGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '经办人工号；关联数据项：员工表.工号',
  `SPRGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '审批人工号；关联数据项：员工表.工号',
  `WTGLBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '委托管理标志；是否资金通过通道委托其他机构投资标识',
  `JYDSKHHH`               VARCHAR(30)      DEFAULT NULL COMMENT '交易对手开户行号',
  `HTDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同到期日期；对于永续债、需要赎回才能终止的业务（如货币基金、债券基金等）统一填报默认值（99991231）',
  `NHLL`                   DECIMAL(20,6)    DEFAULT NULL COMMENT '年化利率；成交时该业务的原始到期收益率年化值（净值类产品除外）。',
  `MYBJBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '合约币种',
  `JYFX`                   VARCHAR(6)       DEFAULT NULL COMMENT '交易方向；PK。资产类业务余额增加填写为买入，余额减少为卖出。',
  `YWXL`                   VARCHAR(60)      DEFAULT NULL COMMENT '业务小类',
  `JRGJBH`                 VARCHAR(300)     DEFAULT NULL COMMENT '金融工具编号；关联数据项：金融工具信息表.金融工具编号',
  `MXKMBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '明细科目编号；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `JRGJMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '金融工具名称；关联数据项：金融工具信息表.金融工具名称'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='自营资金交易信息表';
