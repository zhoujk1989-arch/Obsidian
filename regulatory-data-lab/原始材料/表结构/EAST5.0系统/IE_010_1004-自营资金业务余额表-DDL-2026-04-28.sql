-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_010_1004 自营资金业务余额表
-- ============================================================

DROP TABLE IF EXISTS `IE_010_1004`;
CREATE TABLE `IE_010_1004` (
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种；本报表涉及所有业务的交易币种、科目币种、清算金额币种均应相同。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `QXRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '起息日期；金融资产起息日',
  `WJFL`                   VARCHAR(6)       DEFAULT NULL COMMENT '五级分类；按照需要进行五级分类的资产进行风险分类。到期业务填报到期前的五级分类。',
  `NHLL`                   DECIMAL(20,6)    DEFAULT NULL COMMENT '年化利率；该业务在存量日的最新到期收益率。无到期收益率的允许为空。',
  `ZMYE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '账面余额；填写财务口径账面估值总额，含本金及利息，同一产品合并计算。',
  `CPMC`                   VARCHAR(300)     DEFAULT NULL COMMENT '产品名称',
  `YWZL`                   VARCHAR(60)      DEFAULT NULL COMMENT '业务中类',
  `JYZHLX`                 VARCHAR(12)      DEFAULT NULL COMMENT '账户类型',
  `JRGJBH`                 VARCHAR(300)     DEFAULT NULL COMMENT '金融工具编号；关联数据项：金融工具信息表.金融工具编号',
  `MXKMMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '明细科目名称；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `MXKMBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '明细科目编号；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `JRGJMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '金融工具名称；关联数据项：金融工具信息表.金融工具名称',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `BQSY`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '本期收益；对于净值型产品，份额赎回按照“先进先出”原则计算赎回部分的实际收益；对于非净值型产品，按照赎回金额与当前持有产品总价值的比例来计算本次赎回部分的收益。',
  `CYCB`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '持有成本；填写自营资金交易实际支付成本，同一产品合并计算。',
  `YWXL`                   VARCHAR(60)      DEFAULT NULL COMMENT '业务小类',
  `YEDL`                   VARCHAR(60)      DEFAULT NULL COMMENT '业务大类',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `DQRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '到期日期；金融资产到期日。对于永续债、需要赎回才能终止的业务（如货币基金、债券基金等）统一填报默认值（如9999年12月31日）',
  `JZZB`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '减值准备；对于不需要计提减值准备的资产，如FVPTL类的资产则填为0',
  `XYFXQZ`                 DECIMAL(20,6)    DEFAULT NULL COMMENT '信用风险权重；负债类业务可以为空。',
  `LJSY`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '累计收益；客户在某个产品下获得的累计收益（即历史月份本期收益的加总，若历史某月末时点不持有该产品，则累计收益自下个月起重新从零计算）。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='自营资金业务余额表';
