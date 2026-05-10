-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_510 贸易融资业务表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_510`;
CREATE TABLE `IE_005_510` (
  `GHFMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '购货方名称；即该笔贸易中的买入方。信用证业务填报证上申请人名称，保理融资业务填报应收账款债务人名称。非隐私，不做变形。如果为境内涉密机构的，填报为“*********”。',
  `ZFDXMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '支付对象名称；指该笔融资实际支付对象的名称，二级市场福费廷业务的实际支付对象填报同业机构名称。',
  `SXFBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '手续费币种；填写本行收取客户的手续费币种，如果没有手续费允许为空。',
  `SXFJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '手续费金额；填写本行收取客户的手续费金额，如果没有手续费填写默认值0。',
  `BZJBL`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金比例；如没有保证金，填写默认值0。',
  `BZJJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金金额；若没有保证金填默认值0。多个保证金币种的以本外币合计（BWB）报送。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `HKRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '融资还款日期；指融资款发放后，开证行/申请人的最迟还款日期。',
  `MYRZJE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '贸易融资金额；指融资实际支付的金额，福费廷业务填报实际支付金额，非信用证上金额。',
  `MYRZPZ`                 VARCHAR(60)      DEFAULT NULL COMMENT '贸易融资品种；无法以枚举类型填报的，以“其他-XX”填报，其中“XX”为银行自定义贸易融资品种。',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；PK。关联数据项：信贷合同表.信贷合同号',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报经办的银行机构。关联数据项：机构信息表.内部机构号',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报经办的银行机构。关联数据项：机构信息表.金融许可证号',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `BZJZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '保证金账号；客户缴纳保证金的实际账号，填报外部账号。若没有填空。多个保证金账号的仅报送主要保证金账号。',
  `DKZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '贷款状态',
  `BZJBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '保证金币种；若没有保证金允许为空。多个保证金币种的以本外币合计（BWB）报送。',
  `HKDXMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '还款对象名称；指该笔融资的还款对象名称，非本行开出的信用证还款对象为信用证开证行。',
  `MYJYBJ`                 VARCHAR(1500)    DEFAULT NULL COMMENT '贸易交易内容；填报贸易合同的交易内容简述，如合同为英文的应翻译文中文并保留英文原文。',
  `KZHMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '开证行名称；信用证业务填报开证行名称，其他业务允许为空。',
  `XHFMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '销货方名称；即该笔贸易中的卖出方。信用证业务填报证上受益人名称，保理融资业务填报保理业务申请人名称。非隐私，不做变形。如果为境内涉密机构的，填报为“*********”。',
  `FKRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '融资发放日期；指融资实际放款的日期，多次付款的以首次付款日期填报。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种；PK。指贸易融资币种，非贸易合同币种。多个币种的以本外币合计（BWB）报送。',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。关联数据项：个人信贷业务借据表.信贷借据号 或 对公信贷业务借据表.信贷借据号。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报经办的银行机构。关联数据项：机构信息表.银行机构名称',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='贸易融资业务表';
