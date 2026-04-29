-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_010_1002 金融工具信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_010_1002`;
CREATE TABLE `IE_010_1002` (
  `JCZCKHPJJG`             VARCHAR(450)     DEFAULT NULL COMMENT '基础资产客户评级机构；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `ZZTXHY`                 VARCHAR(90)      DEFAULT NULL COMMENT '最终投向行业；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `JCZCHKHHY`              VARCHAR(90)      DEFAULT NULL COMMENT '基础资产客户行业；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `JCZCKHPJ`               VARCHAR(30)      DEFAULT NULL COMMENT '基础资产客户评级；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `JCZCKHGJ`               VARCHAR(60)      DEFAULT NULL COMMENT '基础资产客户国家；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `JCZCKHMC`               VARCHAR(450)     DEFAULT NULL COMMENT '基础资产客户名称；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `JCZCPJ`                 VARCHAR(30)      DEFAULT NULL COMMENT '基础资产评级；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `JCZCZB`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '基础资产占比；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。填报基础资产规模占资产总规模的百分比。',
  `JCZCMC`                 VARCHAR(120)     DEFAULT NULL COMMENT '基础资产名称；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `SJLL`                   DECIMAL(20,6)    DEFAULT NULL COMMENT '实际利率；按业务实际填写，浮动利率填写最新利率，没有利率的业务可以为空。',
  `DQRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '到期日期；没有对应到期日期的填写交易日期。',
  `FXGB`                   VARCHAR(3)       DEFAULT NULL COMMENT '发行国别；填写发行主体所在国家。',
  `FXJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '发行机构名称；填发行主体而不是代理人，如果没有对应发行机构的填报交易对手。',
  `FXZGM`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '发行总规模；填报该金融工具发行总规模或业务总金额。',
  `FXJG`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '发行价格；标准化的如标准化债券、证券类产品，填报单位发行金额。非标准化的业务填报发行总金额。',
  `ZCLX`                   VARCHAR(120)     DEFAULT NULL COMMENT '资产类型；填报金融工具穿透前对应的资产类型。',
  `JRGJMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '金融工具名称；可根据业务分类来填写，如存放同业：存放XX银行；同业借款：XX银行XX借款。资产类型如果是基金、理财、资管计划等产品的，金融工具名称必须填写产品全称，如XX券商XX资管计划X期，XX银行同业理财产品X期。不可为空。',
  `ZJPGJG`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '最近评估价格；有估值的填报最新估值，没有估值的填报市场最新公允价格，负债类的填报最新剩余价值。标准化的如基金、理财、证券类产品，填报单位价格，非标准化的填报业务总金额。汇率类产品填报最新汇率或者合同约定的汇率。',
  `JRGJBH`                 VARCHAR(300)     DEFAULT NULL COMMENT '金融工具编号；PK。不可为空。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号。填写经办的银行机构。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `ZZTXLX`                 VARCHAR(150)     DEFAULT NULL COMMENT '最终投向类型；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `JCZCPJJG`               VARCHAR(450)     DEFAULT NULL COMMENT '基础资产评级机构；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `JCZCBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '基础资产编号；PK。仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。 同业存单和债券业务的基础资产为证券的，资产编码使用证券代码，资产名称使用证券简称，基础资产客户为证券发行人； 股权投资业务的基础资产为股权，基础资产客户为股权归属公司； 投资的基础资产为信贷资产（或收益权）、不良资产包（或收益权），基础资产客户为信贷资产、不良资产包原始出让方（银行）； 公募基金、私募基金的基础资产为产品本身，资产编码使用基金代码，资产名称使用产品简称，基础资产客户为产品的发行人或管理人； 资管产品（包括非保本理财产品）、其他投资的基础资产为穿透后的底层投资，基础资产客户为底层投资的最终兑付方，与G31原则保持一致。',
  `PGJGRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '评估价格日期',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `JCZCGM`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '基础资产规模；仅同业往来大类下的同业存单，债券和同业投资大类下的所有业务需填报穿透后的基础资产相关信息，其他业务可以为空。基础资产如果对应多个，按多条报送。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `FXJGDM`                 VARCHAR(40)      DEFAULT NULL COMMENT '发行机构代码；填发行主体而不是代理人。如果没有发行机构的填报交易对手。',
  `FXRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '发行日期；没有对应发行日期的填写交易日期。',
  `LLLX`                   VARCHAR(6)       DEFAULT NULL COMMENT '利率类型；按业务实际填写，浮动利率填写最新利率，没有利率的业务可以为空。',
  `HQBS`                   VARCHAR(3)       DEFAULT NULL COMMENT '含权标识'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='金融工具信息表';
