-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_010_1005_INC 即期及衍生品交易信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_010_1005_INC`;
CREATE TABLE `IE_010_1005_INC` (
  `JYLX`                   VARCHAR(30)      DEFAULT NULL COMMENT '交易类型；套期保值、代客、做市、自营定义见《银行业金融机构衍生产品交易业务管理暂行办法》（中国银监会令2011年第1号）第四条，代客平盘指银行业金融机构为对冲代客交易相关风险而进行的交易。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `MFKHTYBH2`              VARCHAR(70)      DEFAULT NULL COMMENT '卖方客户统一编号；若填报机构及其分支机构为卖方，填报金融许可证号。',
  `QXRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '起息日期；起息日期指交易达成后，交易双方履行资金划拨，其货币收款或付款能真正执行生效的日期。利率互换、货币掉期交易填报首个计息周期开始的日期。期权交易填报期权费起息日。',
  `JGPL`                   VARCHAR(20)      DEFAULT NULL COMMENT '交割频率；适用于多次交割的交易，如利率互换、交叉货币互换等。交割日期不确定以及到期交割的交易不填报。',
  `BDSL`                   DECIMAL(20,4)    DEFAULT NULL COMMENT '标的数量；卖方可能向买方交付的资产数量，或基础资产的名义本金。交叉货币互换填报近端卖方向买方支付的本金。普通看跌期权填报买方可能向卖方交付的资产数量。',
  `JYCS`                   VARCHAR(60)      DEFAULT NULL COMMENT '交易场所；为区分银行间市场和其他场外市场，银行间市场业务按交易平台填报“中国外汇交易中心”或“全国银行间同业拆借中心”。国外交易所填报完整英文名称，如美国洲际交易所填报“Intercontinental Exchange”。',
  `QQLX`                   VARCHAR(30)      DEFAULT NULL COMMENT '期权类型；仅期权类交易填报。',
  `XQJGDW`                 VARCHAR(20)      DEFAULT NULL COMMENT '行权价格单位；货币单位为《GB/T 12406 表示货币和资金的代码》中的三字母代码，如CNY；商品及贵金属为盎司、桶、磅等。汇率单位为USDCNY、EURUSD等；债券单位为面值单位，如中国国债单位为CNY；利率换算为年化利率，单位为BP。',
  `ZXYMC`                  VARCHAR(600)     DEFAULT NULL COMMENT '主协议名称；本表中的主协议指《中国银行间市场金融衍生产品交易主协议》（填报“NAFMII”），《中国证券期货市场衍生品交易主协议》（填报“SAC”），《国际掉期及衍生工具协会2002年主协议》（包括该协议1992年版，填报“ISDA”）以及银保监会认可的其他合法有效净额结算主协议。交易适用多个主协议的，以英文分号“;”分隔填报。',
  `GZBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '估值币种',
  `JYYGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '交易员工号',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；关联数据项：机构信息表.银行机构名称',
  `XQJG`                   DECIMAL(20,4)    DEFAULT NULL COMMENT '行权价格；约定的行权价格（总价）或行权条件边界。仅期权类交易填报。',
  `JCZCLX`                 VARCHAR(30)      DEFAULT NULL COMMENT '基础资产类型',
  `JYSJ`                   VARCHAR(6)       DEFAULT NULL COMMENT '交易时间',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `CJJGDW`                 VARCHAR(20)      DEFAULT NULL COMMENT '成交价格单位；货币单位为《GB/T 12406 表示货币和资金的代码》中的三字母代码，如CNY；商品及贵金属为盎司、桶、磅等。汇率单位为USDCNY、EURUSD等；债券单位为面值单位，如中国国债单位为CNY；利率换算为年化利率，单位为BP。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `JYBH`                   VARCHAR(100)     DEFAULT NULL COMMENT '交易编号',
  `YWPZ`                   VARCHAR(300)     DEFAULT NULL COMMENT '业务品种',
  `JCZCMC`                 VARCHAR(60)      DEFAULT NULL COMMENT '基础资产名称；即期交易填报标的资产名称。掉期（互换）交易填报买方向卖方交付的资产名称。信用违约互换填报信用事件。',
  `HYZL`                   VARCHAR(30)      DEFAULT NULL COMMENT '合约种类；即期交易定义参照《银行办理结售汇业务管理办法》（中国人民银行令〔2014〕第2号）第三条第三项。',
  `MFMC1`                  VARCHAR(450)     DEFAULT NULL COMMENT '买方名称；交易双方中支付成交价格或者收取交易标的一方。期权类交易中买方为可以行使选择权并支付期权费的一方，信用违约互换交易中买方为支付保费的一方。',
  `MFKHTYBH1`              VARCHAR(70)      DEFAULT NULL COMMENT '买方客户统一编号；若填报机构及其分支机构为买方，填报金融许可证号。',
  `MFMC2`                  VARCHAR(450)     DEFAULT NULL COMMENT '卖方名称；交易双方中收取成交价格或者交付交易标的一方。期权类交易中卖方为收取期权费的一方，信用违约互换交易中卖方为收取保费的一方。',
  `JYRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '交易日期',
  `DQRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '到期日期；根据不同的合约种类填报到期日期、交割日期、计息终止日期，或者实际行权日期、提前终止日期。涉及多次交割的交易填报首次交割日期，远期择期交易填报最远端到期日期。到期时间为月份按YYYYMM格式填报。',
  `JZRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '截止日期；交易有效期截止日期。',
  `BDSLDW`                 VARCHAR(20)      DEFAULT NULL COMMENT '标的数量单位；货币单位为《GB/T 12406 表示货币和资金的代码》中的三字母代码，如CNY；商品及贵金属为盎司、桶、磅等。汇率单位为USDCNY、EURUSD等；债券单位为面值单位，如中国国债单位为CNY；利率换算为年化利率，单位为BP。',
  `CJJG`                   DECIMAL(20,4)    DEFAULT NULL COMMENT '成交价格；买方向卖方交付的资产数量。期权类交易填报期权费。浮动利率填报利率加点，对应利率指标在数据项“基础资产名称”中体现。',
  `JGFS`                   VARCHAR(60)      DEFAULT NULL COMMENT '交割方式；交割方式按合约规定报送。仅衍生品交易报送。枚举值定义参照市场交易规则，如：《银行间人民币外汇市场交易规则》（中汇交发〔2019〕401号）第四十二条、第四十七条，《银行间市场利率期权交易规则（试行）》（中汇交发〔2020〕51号）第三十四条，《中国金融期货交易所交易规则》（2018年12月28日第四次修订）第五十三条、第五十四条。',
  `XQFS`                   VARCHAR(30)      DEFAULT NULL COMMENT '行权方式；欧式期权指期权买入方必须在期权到期日才能行使选择权的期权，美式期权是指期权买入方可以在成交后有效期内任何一天行使选择权的期权，百慕大期权是指可以在期权到期日前所规定的某些日期行使选择权的期权。仅期权类交易填报。',
  `BZJBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '保证金标志；交易是否为保证金交易。根据《衍生工具交易对手违约风险资产计量规则》（银监发〔2018〕1号）、《中国银保监会办公厅关于衍生工具交易对手违约风险资产计量规则有关问题的通知》（银保监办发〔2021〕124号），仅具有单向保证金协议应认定为无保证金衍生品交易，单向保证金协议是指单向支出盯市保证金和押品的协议。单向从交易对手收取保证金和押品或者采用双向盯市保证金的，可认定为保证金衍生品交易。',
  `ZYJYDS`                 VARCHAR(450)     DEFAULT NULL COMMENT '中央交易对手；根据《中央交易对手风险暴露资本计量规则》（银监发〔2013〕33号），中央交易对手是指清算过程中以原始市场参与者的法定对手方身份介入交易清算，充当原买方的卖方和原卖方的买方，并保证交易得以执行的实体，其核心功能是合约更替和担保交收。',
  `GZJE`                   DECIMAL(20,4)    DEFAULT NULL COMMENT '估值金额',
  `GZRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '估值日期',
  `SPRGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '审批人工号',
  `JYZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '交易状态；“变更”是指成交后对原合约内容进行调整，包括部分平盘、重组、展期等。“终止”是指交易达成后交易双方按照协议规定取消交易，以及因违约、触发终止事件导致的交易终止。期权交易行权时，填报“交易状态”为“行权”、“到期日期”为实际行权日的记录。若填报机构对交易进行估值，按估值周期填报“交易状态”为“估值”的记录，按日估值则按日填报。终止、变更、估值、行权记录交易编号与原交易编号保持一致。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='即期及衍生品交易信息表';
