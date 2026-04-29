-- =====================================================
-- 报表：8.7同业存量情况
-- 表名：T_8_7
-- 字段数：29
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_7`;
CREATE TABLE `T_8_7` (
  `H070001` varchar(60) NOT NULL COMMENT '同业业务ID；原始数据格式：anc..60',
  `H070002` varchar(24) NOT NULL COMMENT '交易机构ID；原始数据格式：anc..24',
  `H070003` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `H070025` varchar(24) DEFAULT NULL COMMENT '交易对手ID；原始数据格式：anc..24',
  `H070004` varchar(60) DEFAULT NULL COMMENT '同业业务种类；原始数据格式：anc..60',
  `H070005` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `H070006` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `H070007` char(2) DEFAULT NULL COMMENT '账户类型；原始数据格式：2!n',
  `H070008` varchar(255) DEFAULT NULL COMMENT '合同金额；原始数据格式：20n(2)',
  `H070009` varchar(255) DEFAULT NULL COMMENT '合同余额；原始数据格式：20n(2)',
  `H070010` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `H070011` date DEFAULT NULL COMMENT '合同起始日期；原始数据格式：YYYY-MM-DD',
  `H070012` date DEFAULT NULL COMMENT '合同终止日期；原始数据格式：YYYY-MM-DD',
  `H070013` varchar(255) DEFAULT NULL COMMENT '合同执行利率；原始数据格式：20n(6)',
  `H070014` char(2) DEFAULT NULL COMMENT '业务目的；原始数据格式：2!n',
  `H070015` varchar(600) DEFAULT NULL COMMENT '担保协议ID；原始数据格式：anc..600',
  `H070016` varchar(60) DEFAULT NULL COMMENT '投资标的ID；原始数据格式：anc..60',
  `H070018` varchar(255) DEFAULT NULL COMMENT '本期投资收益；原始数据格式：20n(2)',
  `H070019` varchar(255) DEFAULT NULL COMMENT '累计投资收益；原始数据格式：20n(2)',
  `H070020` char(2) DEFAULT NULL COMMENT '自营业务大类；原始数据格式：2!n',
  `H070021` varchar(60) DEFAULT NULL COMMENT '自营业务小类；原始数据格式：anc..60',
  `H070022` varchar(255) DEFAULT NULL COMMENT '分户账号；原始数据格式：an',
  `H070023` varchar(12) DEFAULT NULL COMMENT '钞汇类别；原始数据格式：anc..12',
  `H070024` date DEFAULT NULL COMMENT '上次动户日期；原始数据格式：YYYY-MM-DD',
  `H070027` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `H070028` varchar(255) DEFAULT NULL COMMENT '成本总额；原始数据格式：20n(2)',
  `H070029` date DEFAULT NULL COMMENT '失效日期；原始数据格式：YYYY-MM-DD',
  `H070026` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H070017` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H070001`, `H070002`, `H070003`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.7同业存量情况';
