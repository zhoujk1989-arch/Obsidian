-- =====================================================
-- 报表：7.2信贷交易
-- 表名：T_7_2
-- 字段数：32
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_2`;
CREATE TABLE `T_7_2` (
  `G020001` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `G020002` varchar(100) DEFAULT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `G020003` varchar(255) DEFAULT NULL COMMENT '分户账号；原始数据格式：an',
  `G020004` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `G020005` varchar(24) NOT NULL COMMENT '交易机构ID；原始数据格式：anc..24',
  `G020006` varchar(100) NOT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `G020007` date NOT NULL COMMENT '核心交易日期；原始数据格式：YYYY-MM-DD',
  `G020008` time NOT NULL COMMENT '核心交易时间；原始数据格式：HH:MM:SS',
  `G020009` varchar(255) DEFAULT NULL COMMENT '交易金额；原始数据格式：20n(2)',
  `G020010` varchar(255) DEFAULT NULL COMMENT '账户余额；原始数据格式：20n(2)',
  `G020011` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `G020012` varchar(60) DEFAULT NULL COMMENT '信贷交易类型；原始数据格式：anc..60',
  `G020013` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `G020014` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `G020015` char(2) DEFAULT NULL COMMENT '借贷标识；原始数据格式：2!n',
  `G020016` varchar(30) DEFAULT NULL COMMENT '受托支付类型；原始数据格式：anc..30',
  `G020017` varchar(255) DEFAULT NULL COMMENT '对方账号；原始数据格式：an',
  `G020018` varchar(255) DEFAULT NULL COMMENT '对方户名；原始数据格式：anc',
  `G020019` varchar(30) DEFAULT NULL COMMENT '对方账号行号；原始数据格式：an..30',
  `G020020` varchar(255) DEFAULT NULL COMMENT '对方行名；原始数据格式：anc',
  `G020021` char(2) DEFAULT NULL COMMENT '冲补抹标识；原始数据格式：2!n',
  `G020022` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `G020023` varchar(32) DEFAULT NULL COMMENT '授权员工ID；原始数据格式：anc..32',
  `G020024` varchar(60) DEFAULT NULL COMMENT '交易渠道；原始数据格式：anc..60',
  `G020025` varchar(200) DEFAULT NULL COMMENT '代办人姓名；原始数据格式：anc..200',
  `G020026` varchar(60) DEFAULT NULL COMMENT '代办人证件类型；原始数据格式：anc..60',
  `G020027` varchar(100) DEFAULT NULL COMMENT '代办人证件号码；原始数据格式：anc..100',
  `G020028` char(2) DEFAULT NULL COMMENT '现转标识；原始数据格式：2!n',
  `G020029` varchar(255) DEFAULT NULL COMMENT '摘要；原始数据格式：anc',
  `G020031` varchar(24) DEFAULT NULL COMMENT '入账机构ID；原始数据格式：anc..24',
  `G020032` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G020030` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G020001`, `G020005`, `G020006`, `G020007`, `G020008`, `G020030`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.2信贷交易';
