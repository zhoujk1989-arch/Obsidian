-- =====================================================
-- 报表：5.3债券产品业务
-- 表名：T_5_3
-- 字段数：34
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_5_3`;
CREATE TABLE `T_5_3` (
  `E030001` varchar(32) NOT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `E030002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `E030003` varchar(255) DEFAULT NULL COMMENT '产品名称；原始数据格式：anc',
  `E030004` varchar(255) DEFAULT NULL COMMENT '产品编号；原始数据格式：an',
  `E030005` varchar(60) DEFAULT NULL COMMENT '债券产品业务类型；原始数据格式：anc..60',
  `E030006` varchar(60) DEFAULT NULL COMMENT '债券类型代码；原始数据格式：anc..60',
  `E030007` varchar(60) DEFAULT NULL COMMENT '债券子类型代码；原始数据格式：anc..60',
  `E030008` varchar(255) DEFAULT NULL COMMENT '票面金额；原始数据格式：20n(2)',
  `E030009` varchar(255) DEFAULT NULL COMMENT '债券期次；原始数据格式：n',
  `E030010` varchar(255) DEFAULT NULL COMMENT '发行规模；原始数据格式：20n(2)',
  `E030011` varchar(18) DEFAULT NULL COMMENT '债券发行人统一社会信用代码；原始数据格式：an..18',
  `E030012` varchar(200) DEFAULT NULL COMMENT '债券发行人名称；原始数据格式：anc..200',
  `E030013` varchar(255) DEFAULT NULL COMMENT '定期付息账号；原始数据格式：an',
  `E030014` char(1) DEFAULT NULL COMMENT '可回购标识；原始数据格式：1!n',
  `E030015` char(1) DEFAULT NULL COMMENT '可提前偿还标识；原始数据格式：1!n',
  `E030016` varchar(255) DEFAULT NULL COMMENT '发行价格；原始数据格式：20n(6)',
  `E030017` varchar(255) DEFAULT NULL COMMENT '赎回价格；原始数据格式：20n(2)',
  `E030034` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `E030018` varchar(300) DEFAULT NULL COMMENT '发行国家地区；原始数据格式：anc..300',
  `E030019` char(3) DEFAULT NULL COMMENT '担保机构国家地区；原始数据格式：3!a',
  `E030020` varchar(60) DEFAULT NULL COMMENT '债券发行机构类型；原始数据格式：anc..60',
  `E030021` char(2) DEFAULT NULL COMMENT '担保机构类型；原始数据格式：2!n',
  `E030022` char(2) DEFAULT NULL COMMENT '发行方式；原始数据格式：2!n',
  `E030023` char(6) DEFAULT NULL COMMENT '发行人所在地行政区划；原始数据格式：6!n',
  `E030024` char(2) DEFAULT NULL COMMENT '发行资金用途；原始数据格式：2!n',
  `E030025` varchar(255) DEFAULT NULL COMMENT '资产风险权重；原始数据格式：20n(6)',
  `E030026` char(2) DEFAULT NULL COMMENT '资产等级；原始数据格式：2!n',
  `E030027` char(2) DEFAULT NULL COMMENT '主权风险权重；原始数据格式：2!n',
  `E030028` varchar(255) DEFAULT NULL COMMENT '基准国债收益率；原始数据格式：20n(6)',
  `E030029` varchar(60) DEFAULT NULL COMMENT '交易方式代码；原始数据格式：anc..60',
  `E030030` date DEFAULT NULL COMMENT '发行日期；原始数据格式：YYYY-MM-DD',
  `E030031` date DEFAULT NULL COMMENT '到期兑付日期；原始数据格式：YYYY-MM-DD',
  `E030032` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `E030033` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`E030001`, `E030002`, `E030033`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='5.3债券产品业务';
