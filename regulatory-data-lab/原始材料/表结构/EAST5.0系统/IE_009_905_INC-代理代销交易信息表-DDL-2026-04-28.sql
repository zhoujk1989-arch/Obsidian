-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_009_905_INC 代理代销交易信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_009_905_INC`;
CREATE TABLE `IE_009_905_INC` (
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `XZBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '现转标志',
  `DLDXJYLX`               VARCHAR(60)      DEFAULT NULL COMMENT '代理代销交易类型；参照1104报表G01_I中代理代销业务的分类口径。',
  `JYFX`                   VARCHAR(6)       DEFAULT NULL COMMENT '交易方向',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `FXJGPJ`                 VARCHAR(20)      DEFAULT NULL COMMENT '发行机构评级；允许填报内部评级。若既无外部评级又无内部评级，允许为空。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `FXJGPJJG`               VARCHAR(450)     DEFAULT NULL COMMENT '发行机构评级机构；评级机构名称，如果没有允许为空。',
  `FXJGQSHM`               VARCHAR(450)     DEFAULT NULL COMMENT '发行机构清算行名；发行机构清算账户的所属行名。第三方支付平台填写第三方支付平台名称。',
  `SXFJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '手续费金额；填写本行收取客户的手续费金额，如果没有手续费填写默认值0。',
  `JYYGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '经办人工号；指推荐人或有权销售人的员工号，自动办理的允许为空。关联数据项：员工表.工号。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报办理该业务的银行机构。关联数据项：机构信息表.金融许可证号',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；填报购买产品的客户编号。关联数据项：个人基础信息表.客户统一编号或对公客户信息表.客户统一编号。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `FXJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '发行机构名称；填写发行机构的全称。',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报办理该业务的银行机构。关联数据项：机构信息表.内部机构号。填写经办的银行机构。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报办理该业务的银行机构。关联数据项：机构信息表.银行机构名称',
  `KHZH`                   VARCHAR(60)      DEFAULT NULL COMMENT '客户账号；填报客户付款的账号，如果为现金交易，可以为空。',
  `KHHMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '开户行名称；填报客户缴款的开户行名称，如果为现金交易，可以为空。',
  `JYBH`                   VARCHAR(60)      DEFAULT NULL COMMENT '交易编号；PK。识别交易的唯一编号。',
  `DXCPMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '代销产品名称',
  `JYRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '交易日期；填写客户实际购买并缴费的日期。',
  `JYJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '交易金额；填写客户实际购买并缴费的金额。',
  `FXJGQSZH`               VARCHAR(60)      DEFAULT NULL COMMENT '发行机构清算账号；填写发行机构清算账户的账号，优先填报外部账号。',
  `RZRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '融资人名称；代销产品融资人的名称。如融资人即发行人，则填发行机构名称。如有多个融资人的，填报融资比例最高的名称。银行应按照《关于规范商业银行代理销售业务的通知》（银监发〔2016〕24号）代销产品准入管理等相关规定进行尽职调查，如不掌握融资人信息的，允许为空。',
  `RZRSSHY`                VARCHAR(30)      DEFAULT NULL COMMENT '融资人所属行业；代销产品融资人所属行业。如融资人即发行人，则填发行机构所属行业。如有多个融资人的，填报融资比例最高的融资人行业。如不掌握融资人信息的，允许为空。',
  `SXFBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '手续费币种；填写本行收取客户的手续费币种，如果没有手续费允许为空。',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；如果是个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。关联数据项：个人基础信息表.客户姓名或对公客户信息表.客户名称。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代理代销交易信息表';
