-- =====================================================
-- 报表：7.7投资交易
-- 表名：T_7_7
-- 字段数：41
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_7`;
CREATE TABLE `T_7_7` (
  `G070001` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `G070002` varchar(24) NOT NULL COMMENT '交易机构ID；原始数据格式：anc..24',
  `G070037` varchar(100) DEFAULT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `G070003` varchar(255) DEFAULT NULL COMMENT '交易机构名称；原始数据格式：anc',
  `G070004` varchar(255) DEFAULT NULL COMMENT '交易账号；原始数据格式：anc',
  `G070005` varchar(60) DEFAULT NULL COMMENT '投资标的ID；原始数据格式：anc..60',
  `G070006` varchar(255) DEFAULT NULL COMMENT '交易金额；原始数据格式：20n(2)',
  `G070007` char(2) DEFAULT NULL COMMENT '交易方向；原始数据格式：2!n',
  `G070008` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `G070009` varchar(255) DEFAULT NULL COMMENT '数量；原始数据格式：20n(6)',
  `G070010` varchar(255) DEFAULT NULL COMMENT '单位成交净价；原始数据格式：20n(2)',
  `G070011` varchar(255) DEFAULT NULL COMMENT '单位成交全价；原始数据格式：20n(2)',
  `G070012` varchar(60) DEFAULT NULL COMMENT '资产计量方式；原始数据格式：anc..60',
  `G070013` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `G070014` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `G070015` date DEFAULT NULL COMMENT '交易日期；原始数据格式：YYYY-MM-DD',
  `G070016` time DEFAULT NULL COMMENT '交易时间；原始数据格式：HH:MM:SS',
  `G070038` varchar(60) DEFAULT NULL COMMENT '交易对手ID；原始数据格式：anc..60',
  `G070017` varchar(255) DEFAULT NULL COMMENT '交易对手名称；原始数据格式：anc',
  `G070018` varchar(30) DEFAULT NULL COMMENT '交易对手大类；原始数据格式：anc..30',
  `G070039` varchar(60) DEFAULT NULL COMMENT '交易对手小类；原始数据格式：anc..60',
  `G070019` varchar(20) DEFAULT NULL COMMENT '交易对手评级；原始数据格式：anc..20',
  `G070020` varchar(200) DEFAULT NULL COMMENT '交易对手评级机构；原始数据格式：anc..200',
  `G070021` varchar(30) DEFAULT NULL COMMENT '交易对手账号行号；原始数据格式：an..30',
  `G070022` varchar(255) DEFAULT NULL COMMENT '交易对手账号；原始数据格式：an',
  `G070023` varchar(100) DEFAULT NULL COMMENT '交易对手账号开户行名称；原始数据格式：anc..100',
  `G070024` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `G070025` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `G070026` varchar(255) DEFAULT NULL COMMENT '行内归属部门；原始数据格式：anc',
  `G070027` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `G070028` varchar(100) DEFAULT NULL COMMENT '理财交易登记ID；原始数据格式：anc..100',
  `G070029` varchar(100) DEFAULT NULL COMMENT '行内理财交易ID；原始数据格式：anc..100',
  `G070030` char(2) DEFAULT NULL COMMENT '资金流动类型；原始数据格式：2!n',
  `G070033` char(2) DEFAULT NULL COMMENT '自营业务大类；原始数据格式：2!n',
  `G070034` char(5) DEFAULT NULL COMMENT '自营业务小类；原始数据格式：5!n',
  `G070035` varchar(255) DEFAULT NULL COMMENT '年化利率；原始数据格式：20n(6)',
  `G070036` char(2) DEFAULT NULL COMMENT '账户类型；原始数据格式：2!n',
  `G070031` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G070040` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `G070041` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `G070032` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G070001`, `G070002`, `G070032`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.7投资交易';
