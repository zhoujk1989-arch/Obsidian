-- =====================================================
-- 报表：7.1客户存款账户交易
-- 表名：T_7_1
-- 字段数：36
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_1`;
CREATE TABLE `T_7_1` (
  `G010001` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `G010002` varchar(255) DEFAULT NULL COMMENT '分户账号；原始数据格式：an',
  `G010003` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `G010004` varchar(24) NOT NULL COMMENT '交易机构ID；原始数据格式：anc..24',
  `G010035` varchar(24) DEFAULT NULL COMMENT '入账机构ID；原始数据格式：anc..24',
  `G010005` date DEFAULT NULL COMMENT '核心交易日期；原始数据格式：YYYY-MM-DD',
  `G010006` time DEFAULT NULL COMMENT '核心交易时间；原始数据格式：HH:MM:SS',
  `G010007` varchar(255) DEFAULT NULL COMMENT '交易金额；原始数据格式：20n(2)',
  `G010008` varchar(255) DEFAULT NULL COMMENT '账户余额；原始数据格式：20n(2)',
  `G010009` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `G010010` varchar(60) DEFAULT NULL COMMENT '账户交易类型；原始数据格式：anc..60',
  `G010011` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `G010012` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `G010013` char(2) DEFAULT NULL COMMENT '现转标识；原始数据格式：2!n',
  `G010014` char(2) DEFAULT NULL COMMENT '借贷标识；原始数据格式：2!n',
  `G010015` varchar(255) DEFAULT NULL COMMENT '对方账号；原始数据格式：an',
  `G010016` varchar(255) DEFAULT NULL COMMENT '对方户名；原始数据格式：anc',
  `G010017` varchar(30) DEFAULT NULL COMMENT '对方账号行号；原始数据格式：an..30',
  `G010018` varchar(255) DEFAULT NULL COMMENT '对方行名；原始数据格式：anc',
  `G010019` varchar(255) DEFAULT NULL COMMENT '交易摘要；原始数据格式：anc',
  `G010020` char(2) DEFAULT NULL COMMENT '冲补抹标识；原始数据格式：2!n',
  `G010033` varchar(12) DEFAULT NULL COMMENT '钞汇类别；原始数据格式：anc..12',
  `G010036` char(1) DEFAULT NULL COMMENT '跨境汇款标识；原始数据格式：1!n',
  `G010021` varchar(60) DEFAULT NULL COMMENT '交易渠道；原始数据格式：anc..60',
  `G010022` varchar(32) DEFAULT NULL COMMENT '交易终端ID；原始数据格式：anc..32',
  `G010023` varchar(40) DEFAULT NULL COMMENT 'IP地址；原始数据格式：an..40',
  `G010024` varchar(60) DEFAULT NULL COMMENT 'MAC地址；原始数据格式：anc..60',
  `G010025` varchar(255) DEFAULT NULL COMMENT '外部账号（交易介质号）；原始数据格式：an',
  `G010026` varchar(200) DEFAULT NULL COMMENT '代办人姓名；原始数据格式：anc..200',
  `G010027` varchar(60) DEFAULT NULL COMMENT '代办人证件类型；原始数据格式：anc..60',
  `G010028` varchar(100) DEFAULT NULL COMMENT '代办人证件号码；原始数据格式：anc..100',
  `G010029` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `G010030` varchar(32) DEFAULT NULL COMMENT '授权员工ID；原始数据格式：anc..32',
  `G010031` varchar(600) DEFAULT NULL COMMENT '附言；原始数据格式：anc..600',
  `G010034` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G010032` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G010001`, `G010004`, `G010032`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.1客户存款账户交易';
