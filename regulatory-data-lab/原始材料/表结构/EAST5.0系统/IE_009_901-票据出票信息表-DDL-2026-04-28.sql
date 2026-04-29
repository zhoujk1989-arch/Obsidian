-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_009_901 票据出票信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_009_901`;
CREATE TABLE `IE_009_901` (
  `PJDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '票据到期日期',
  `CPRBH`                  VARCHAR(60)      DEFAULT NULL COMMENT '出票人编号；如果为代理承兑业务该项允许为空。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SXFBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '其他费用币种；填写本行收取客户的除手续费以外的币种，如果没有允许为空。',
  `SKRKHLB`                VARCHAR(6)       DEFAULT NULL COMMENT '收款人客户类别',
  `CPRKHLB`                VARCHAR(6)       DEFAULT NULL COMMENT '出票人客户类别',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `JBYGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '经办人工号；指受理该笔业务的客户经理工号，自动办理的允许为空。关联数据项：员工表.工号。',
  `PJZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '票据状态；正常（票据未到期），卖断（转贴现卖断），解付（票据到期且出票人已付款），垫款（票据到期产生垫款），核销（贷款核销）。',
  `BZJJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金金额；以现金担保的在此填报，以其他形式的保证在担保合同表里报送。若没有填默认值0。多个保证金币种统一按一种币种转换合计报送。',
  `BZJBL`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金比例；以现金担保的在此填报，以其他形式的保证在担保合同表里报送。多个保证金币种统一按一种币种转换合计报送。如没有保证金，填写默认值0。',
  `MYBJ`                   VARCHAR(600)     DEFAULT NULL COMMENT '贸易背景；票据开票的贸易背景简述。',
  `SFZBHTX`                VARCHAR(3)       DEFAULT NULL COMMENT '是否在本行贴现',
  `SKRZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '收款人账号；填报票面上的收款人账号',
  `SKRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '收款人名称；票面上的收款人。如果为个人，则为隐私，银行机构变形，变性规则见《采集技术接口说明》。其他情况为非隐私，不作变形。',
  `CPRKHHMC`               VARCHAR(450)     DEFAULT NULL COMMENT '出票人开户行名称',
  `CPRZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '出票人账号；填报票面上的出票人账号，优先填报外部账号。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `MXKMMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '明细科目名称；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `MXKMBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '明细科目编号；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报出票的银行机构。关联数据项：机构信息表.银行机构名称',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报出票的银行机构。关联数据项：机构信息表.金融许可证号',
  `CPRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '出票人名称；如果出票人为个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。如果出票人为对公客户，则为非隐私，不做变形。',
  `PJCPRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '票据出票日期',
  `PMJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '票面金额',
  `PJLX`                   VARCHAR(30)      DEFAULT NULL COMMENT '票据类型',
  `PJHM`                   VARCHAR(60)      DEFAULT NULL COMMENT '票据号码；PK',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报出票的银行机构。关联数据项：机构信息表.内部机构号。填写开出票据行的内部机构号。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `SKRKHHMC`               VARCHAR(450)     DEFAULT NULL COMMENT '收款人开户行名称；填报票面上的收款人开户行名称',
  `SXFJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '其他费用金额；填写本行收取客户的除手续费以为的其他费用的金额，如果没有填写默认值0。',
  `BZJBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '保证金币种；以现金担保的在此填报，以其他形式的保证在担保合同表里报送。若没有允许为空。多个保证金币种统一按一种币种转换合计报送。',
  `BZJZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '保证金账号；客户缴纳保证金的实际账号，填报外部账号。若没有填空。多个保证金币种统一按一种币种转换合计报送。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='票据出票信息表';
