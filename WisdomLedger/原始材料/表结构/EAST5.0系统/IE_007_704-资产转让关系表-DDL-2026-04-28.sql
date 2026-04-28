-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_007_704 资产转让关系表
-- ============================================================

DROP TABLE IF EXISTS `IE_007_704`;
CREATE TABLE `IE_007_704` (
  `ZRHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '转让合同号；PK。信贷资产转让交易签署的合同编号，并非转让的贷款合同号，信贷资产证券化业务填写信托合同编号。',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。如信贷资产类型为信用卡，以信用卡账号填报为借据号。关联数据项：个人信贷业务借据表.信贷借据号 or 对公信贷业务借据表.信贷借据号 or 信用卡信息表.信用卡账号。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号。填写信贷借据机构对应的内部机构号',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `ZRDKLX`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '转让贷款利息；填写该条借据转让前利息和费用余额。对于已核销贷款填核销前应收利息和费用金额。对于ABS产品填报按照合同约定转让给信托的底层资产利息和费用金额。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `ZRDKBJ`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '转让贷款本金；填写该条借据转让前本金余额。对于已核销贷款本金填报为0。对于ABS产品填报按照合同约定转让给信托的底层资产未偿本金金额。',
  `XDZCLX`                 VARCHAR(30)      DEFAULT NULL COMMENT '信贷资产类型；个人贷款和对公贷款均为除了信用卡透支以外的贷款。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资产转让关系表';
