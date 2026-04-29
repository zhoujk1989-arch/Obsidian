-- =====================================================
-- 报表：7.4信用卡交易
-- 表名：T_7_4
-- 字段数：37
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_4`;
CREATE TABLE `T_7_4` (
  `G040001` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `G040002` varchar(40) DEFAULT NULL COMMENT '卡号；原始数据格式：n..40',
  `G040003` varchar(255) DEFAULT NULL COMMENT '分户账号；原始数据格式：an',
  `G040004` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `G040005` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `G040006` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `G040007` date DEFAULT NULL COMMENT '核心交易日期；原始数据格式：YYYY-MM-DD',
  `G040008` time DEFAULT NULL COMMENT '核心交易时间；原始数据格式：HH:MM:SS',
  `G040009` varchar(60) DEFAULT NULL COMMENT '交易类型；原始数据格式：anc..60',
  `G040010` varchar(255) DEFAULT NULL COMMENT '交易金额；原始数据格式：20n(2)',
  `G040011` varchar(255) DEFAULT NULL COMMENT '账户余额；原始数据格式：20n(2)',
  `G040012` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `G040013` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `G040014` varchar(255) DEFAULT NULL COMMENT '手续费金额；原始数据格式：20n(2)',
  `G040015` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `G040016` char(3) DEFAULT NULL COMMENT '手续费币种；原始数据格式：3!a',
  `G040017` varchar(255) DEFAULT NULL COMMENT '对方账号；原始数据格式：an',
  `G040018` varchar(255) DEFAULT NULL COMMENT '对方户名；原始数据格式：anc',
  `G040019` varchar(30) DEFAULT NULL COMMENT '对方账号行号；原始数据格式：an..30',
  `G040020` varchar(255) DEFAULT NULL COMMENT '对方行名；原始数据格式：anc',
  `G040021` char(2) DEFAULT NULL COMMENT '借贷标识；原始数据格式：2!n',
  `G040022` varchar(255) DEFAULT NULL COMMENT '商户编号；原始数据格式：anc',
  `G040023` varchar(200) DEFAULT NULL COMMENT '商户名称；原始数据格式：anc..200',
  `G040024` char(2) DEFAULT NULL COMMENT '线上线下交易标识；原始数据格式：2!n',
  `G040025` varchar(100) DEFAULT NULL COMMENT '分期业务ID；原始数据格式：anc..100',
  `G040026` varchar(40) DEFAULT NULL COMMENT 'IP地址；原始数据格式：an..40',
  `G040027` varchar(60) DEFAULT NULL COMMENT 'MAC地址；原始数据格式：anc..60',
  `G040028` char(4) DEFAULT NULL COMMENT '商户类别码；原始数据格式：4!n',
  `G040029` varchar(255) DEFAULT NULL COMMENT '商户类别码名称；原始数据格式：anc',
  `G040030` varchar(60) DEFAULT NULL COMMENT '交易渠道；原始数据格式：anc..60',
  `G040031` varchar(255) DEFAULT NULL COMMENT '交易摘要；原始数据格式：anc',
  `G040032` varchar(255) DEFAULT NULL COMMENT '客户备注；原始数据格式：anc',
  `G040034` char(1) DEFAULT NULL COMMENT '提前结清标志；原始数据格式：1!n',
  `G040037` date DEFAULT NULL COMMENT '最迟还款日期；原始数据格式：YYYY-MM-DD',
  `G040036` date DEFAULT NULL COMMENT '交易账单日期；原始数据格式：YYYY-MM-DD',
  `G040035` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G040033` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G040001`, `G040005`, `G040033`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.4信用卡交易';
