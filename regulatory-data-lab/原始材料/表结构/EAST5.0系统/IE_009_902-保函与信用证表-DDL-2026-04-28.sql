-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_009_902 保函与信用证表
-- ============================================================

DROP TABLE IF EXISTS `IE_009_902`;
CREATE TABLE `IE_009_902` (
  `BZJBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '保证金币种；以现金担保的在此填报，以其他形式的保证在担保合同表里报送。若没有允许为空。多个保证金币种统一按一种币种转换合计报送。',
  `HTZT`                   VARCHAR(60)      DEFAULT NULL COMMENT '合同状态',
  `JBYGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '经办人工号；指受理该笔业务的客户经理工号，自动办理的允许为空。关联数据项：员工表.工号。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报办理该业务的银行机构。关联数据项：机构信息表.金融许可证号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报办理该业务的银行机构。关联数据项：机构信息表.银行机构名称',
  `MXKMMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '明细科目名称；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `YWZL`                   VARCHAR(30)      DEFAULT NULL COMMENT '业务种类；指银行办理保函与信用证业务的业务种类。',
  `YDFJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '已兑付金额；指填报机构实际已支付的金额。若无兑付金额允许填报为0。',
  `KTDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同到期日期；填报保函或信用证合同信息，非贸易合同信息。',
  `SQRBH`                  VARCHAR(70)      DEFAULT NULL COMMENT '申请人编号；指申请人的客户统一编号。如本行不做为开证行，办理信用证保兑业务时客户统一编号可以为空。',
  `SQRGJDM`                VARCHAR(3)       DEFAULT NULL COMMENT '申请人国家代码；如非国际业务填写默认值CHN',
  `SYRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '受益人名称；如果受益人为个人客户，则为隐私，银行机构变形，个人变性规则见《采集技术接口说明》。如果受益人为对公客户，则为非隐私，不做变形。如果为境内涉密机构的，填报为“*********”。信用风险仍在银行的销售与购买协议允许为空。',
  `ZFQX`                   INT              DEFAULT NULL COMMENT '支付期限；信用证见单提示付款/承兑后，本行作为开证行付款的天数，如为即期则为0天。信用风险仍在银行的销售与购买协议允许为空。',
  `SXFBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '手续费币种；若没有允许为空。多个币种统一按一种币种转换合计报送。',
  `KTQSRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同起始日期；填报保函或信用证合同信息，非贸易合同信息。',
  `SXFJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '手续费金额；填写本行收取客户的手续费金额，如果没有手续费填写默认值0。',
  `BZJBL`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金比例；以现金担保的在此填报，以其他形式的保证在担保合同表里报送。多个保证金币种统一按一种币种转换合计报送。如没有保证金，填写默认值0。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报办理该业务的银行机构。关联数据项：机构信息表.内部机构号',
  `MXKMBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '明细科目编号；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `HTBH`                   VARCHAR(100)     DEFAULT NULL COMMENT '合同编号；PK。识别该笔业务的唯一编号，可以是信用证、保函编号，可以是业务合同编号。',
  `XYZBZDM`                VARCHAR(3)       DEFAULT NULL COMMENT '币种；PK。指合同约定的币种。同一合同多个币种的按照多条报送。',
  `XYZJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '合同金额',
  `XYZYE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '待支付金额；指申请人未支付的金额，包含已承兑待支付金额。保函等或有担保允许填报为0。',
  `SQRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '申请人名称；如果申请人为个人客户，则为隐私，银行机构变形，个人变性规则见《采集技术接口说明》。如果申请人为对公客户，则为非隐私，不做变形。如果为境内涉密机构的，填报为“*********”。不可为空。',
  `SYRGJDM`                VARCHAR(3)       DEFAULT NULL COMMENT '受益人国家代码；如非国际业务填写默认值CHN。',
  `SYRZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '受益人开户行账号；填报实际向受益人支付的银行机构结算账户。信用风险仍在银行的销售与购买协议允许为空。',
  `SYRKHHMC`               VARCHAR(450)     DEFAULT NULL COMMENT '受益人开户行名称；填报实际向受益人支付的银行机构全称，境外机构可以填报英文。信用风险仍在银行的销售与购买协议允许为空。',
  `HTMYBJ`                 VARCHAR(600)     DEFAULT NULL COMMENT '合同贸易背景；指开立保函或信用证的交易内容、货品或服务的描述。',
  `BZJJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金金额；以现金担保的在此填报，以其他形式的保证在担保合同表里报送。若没有填默认值0。多个保证金币种统一按一种币种转换合计报送。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `SQRKHLB`                VARCHAR(6)       DEFAULT NULL COMMENT '申请人客户类别',
  `SYRKHLB`                VARCHAR(6)       DEFAULT NULL COMMENT '受益人客户类别'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='保函与信用证表';
