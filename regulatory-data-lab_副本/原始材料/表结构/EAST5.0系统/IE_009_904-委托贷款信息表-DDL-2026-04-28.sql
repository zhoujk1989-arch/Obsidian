-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_009_904 委托贷款信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_009_904`;
CREATE TABLE `IE_009_904` (
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报办理该业务的关联数据项：机构信息表.内部机构号',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报办理该业务的银行机构。关联数据项：机构信息表.金融许可证号',
  `HTBH`                   VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；PK。现金管理项下委托贷款填写与客户签订的现金管理合同编号。当委托贷款类型不为现金管理项下委托贷款时，需关联数据项：信贷合同表.信贷合同号。',
  `WTDKLX`                 VARCHAR(60)      DEFAULT NULL COMMENT '委托贷款类型',
  `SXFJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '手续费金额；填写本行收取客户的手续费金额，如果没有手续费填写为0。对于现金管理项下委托贷款，如果手续费在合同签订时一次收取的，在合同签订后的第一笔放款下填报手续费金额，之后的放款不再填报。',
  `HTDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同到期日期；委托贷款实际到期日期，现金管理项下委托贷款到期日期可以填报现金管理合同有效日期，也允许填报默认日期。',
  `WTRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '委托人名称；如果委托人为个人客户，则为隐私，银行机构变形，变性规则见《采集技术接口说明》，其他情况则为非隐私，不做变形。',
  `SYRZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '受益人账号；填写委托贷款实际发放入账的账号，不可填中间过渡账户，不可为空。',
  `SFSX`                   VARCHAR(3)       DEFAULT NULL COMMENT '是否收息',
  `KHJLGH`                 VARCHAR(70)      DEFAULT NULL COMMENT '经办人工号；指受理该笔业务的客户经理工号，自动办理的允许为空。关联数据项：员工表.工号。',
  `DKZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '贷款状态；对于现金管理项下委托贷款，每发生一笔放款仅报送一次，以后不再报送，贷款状态以“其他-现金管理项下”报送。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报办理该业务的银行机构。关联数据项：机构信息表.银行机构名称',
  `MXKMMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '明细科目名称；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。现金管理项下委托贷款填写能唯一识别该笔委托贷款业务的编号。当委托贷款类型不为现金管理项下委托贷款时，需填写信贷借据号，并关联数据项：个人信贷业务借据表.信贷借据号 or 对公信贷业务借据表.信贷借据号。',
  `DKJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '合同金额；委托贷款实际发放金额。',
  `HTQSRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同起始日期；委托贷款实际发放日期。',
  `WTRBH`                  VARCHAR(70)      DEFAULT NULL COMMENT '委托人编号；填写委托人的客户统一编号。',
  `WTRZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '委托人账号；填写委托资金实际所在的账号，不可填中间过渡账户或借款人账户，不可为空。',
  `WTRKHHMC`               VARCHAR(450)     DEFAULT NULL COMMENT '委托人开户行名称；委托资金的开户银行名称。',
  `SYRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '受益人名称；如果借款人为个人，则为隐私，银行机构变形，变性规则见《采集技术接口说明》。其他情况则为非隐私，不作变形。',
  `SYRKHHMC`               VARCHAR(450)     DEFAULT NULL COMMENT '受益人开户行名称',
  `SXFBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '手续费币种；填写本行收取客户的手续费币种，如果没有手续费允许为空。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `WTRKHLB`                VARCHAR(6)       DEFAULT NULL COMMENT '委托人客户类别',
  `SYRKHLB`                VARCHAR(6)       DEFAULT NULL COMMENT '受益人客户类别',
  `MXKMBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '明细科目编号；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='委托贷款信息表';
