-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_007_703 信贷资产转让表
-- ============================================================

DROP TABLE IF EXISTS `IE_007_703`;
CREATE TABLE `IE_007_703` (
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报办理转让的银行机构。关联数据项：机构信息表.内部机构号。',
  `ZRHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '转让合同号；PK。信贷资产转让交易签署的合同编号，并非转让的贷款合同号，信贷资产证券化业务填写信托合同编号。',
  `ZRJKRZZH`               VARCHAR(60)      DEFAULT NULL COMMENT '转让价款入账账号',
  `JYDSMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '交易对手名称；对于ABS产品，直接交易对手是受托机构（信托）。如果交易对手为个人，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。如果为境内涉密机构的，填报为“*********”。其他情况，则为非隐私，不做变形。',
  `ZRDKBJZE`               DECIMAL(20,2)    DEFAULT NULL COMMENT '转让贷款本金总额；对于已核销贷款的转让，本金总额填报为0。对于ABS产品填报按照合同约定转让给信托的底层资产未偿本金金额。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报办理转让的银行机构。关联数据项：机构信息表.金融许可证号',
  `ZCZRFS`                 VARCHAR(60)      DEFAULT NULL COMMENT '资产转让方式',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `BZJBL`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金比例；保证金比例=保证金金额/转让总价。多个保证金币种统一按一种币种转换合计报送。如没有保证金，填写默认值0。',
  `ZRHTDQRQ`               VARCHAR(8)       DEFAULT NULL COMMENT '转让合同到期日期；转让合同到期日期。不涉及合同到期日的填报转让交割日期。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `ZRHTZT`                 VARCHAR(30)      DEFAULT NULL COMMENT '转让合同状态；按照转让合同履约，完全收到转让价款后，视为转让合同终结。',
  `ZRJYPT`                 VARCHAR(450)     DEFAULT NULL COMMENT '转让交易平台；与1104报表G34《信贷资产转让情况统计表》[二、交易平台]填报口径一致。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `JYDSYZFJE`              DECIMAL(20,2)    DEFAULT NULL COMMENT '交易对手已支付金额；截至报送日已经支付的金额。',
  `ZRHTQSRQ`               VARCHAR(8)       DEFAULT NULL COMMENT '转让合同起始日期；填报资产转让交割日期，在ABS交易中转让合同起始日期为信托设立日。',
  `JYDSKHLB`               VARCHAR(6)       DEFAULT NULL COMMENT '交易对手客户类别',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `SFZYDZXDJ`              VARCHAR(3)       DEFAULT NULL COMMENT '是否在银登中心登记；与1104报表G34《信贷资产转让情况统计表》[三、登记平台]填报口径一致。',
  `BZJBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '保证金币种；如没有保证金，可以为空。多个保证金币种统一按一种币种转换合计报送。',
  `JYDSZRRQ`               VARCHAR(8)       DEFAULT NULL COMMENT '交易对手转账日期；如果有多次转账的，填报首笔转让价款转入日期，非定金日期。',
  `ZRZJ`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '转让总价；信贷资产转让交易中交易对手所支付的对价。',
  `ZRDKLXZE`               DECIMAL(20,2)    DEFAULT NULL COMMENT '转让贷款利息总额；对于已核销贷款填核销前应收利息总额。对于ABS产品填报按照合同约定转让给信托的底层资产利息总和。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `JYDSKHHMC`              VARCHAR(450)     DEFAULT NULL COMMENT '交易对手开户行名称；交易对手的开户行名称，如果为第三方支付交易，则填报第三方支付平台名称。如果有多个转账账户的，填写首笔转账的账户。',
  `JYDSZZZH`               VARCHAR(60)      DEFAULT NULL COMMENT '交易对手账号；交易对手支付对价的账号，如果为第三方支付交易，则填报第三方支付账号。如有多个转账账户的，填写首笔转账的账户。',
  `ZRJKRZMC`               VARCHAR(450)     DEFAULT NULL COMMENT '转让价款入账账户名称',
  `ZCZRFX`                 VARCHAR(30)      DEFAULT NULL COMMENT '资产转让方向',
  `BZJJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金金额；如没有保证金，填写默认值0。多个保证金币种统一按一种币种转换合计报送。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='信贷资产转让表';
