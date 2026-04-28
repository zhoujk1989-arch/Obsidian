-- =====================================================
-- 报表：7.9信贷资产转让
-- 表名：T_7_9
-- 字段数：19
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_9`;
CREATE TABLE `T_7_9` (
  `G090001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `G090002` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `G090003` varchar(100) NOT NULL COMMENT '细分资产ID；原始数据格式：anc..100',
  `G090004` varchar(255) DEFAULT NULL COMMENT '转让价款入账账号；原始数据格式：an',
  `G090005` char(2) NOT NULL COMMENT '资产转让方向；原始数据格式：2!n',
  `G090006` varchar(60) DEFAULT NULL COMMENT '资产转让方式；原始数据格式：anc..60',
  `G090007` varchar(255) DEFAULT NULL COMMENT '转让贷款本金总额；原始数据格式：20n(2)',
  `G090008` varchar(255) DEFAULT NULL COMMENT '转让贷款利息总额；原始数据格式：20n(2)',
  `G090009` varchar(60) DEFAULT NULL COMMENT '资产类型；原始数据格式：anc..60',
  `G090010` date NOT NULL COMMENT '核心交易日期；原始数据格式：YYYY-MM-DD',
  `G090011` time DEFAULT NULL COMMENT '核心交易时间；原始数据格式：HH:MM:SS',
  `G090012` varchar(255) DEFAULT NULL COMMENT '对方账号；原始数据格式：an',
  `G090013` varchar(255) DEFAULT NULL COMMENT '对方户名；原始数据格式：anc',
  `G090014` varchar(30) DEFAULT NULL COMMENT '对方账号行号；原始数据格式：an..30',
  `G090015` varchar(255) DEFAULT NULL COMMENT '对方行名；原始数据格式：anc',
  `G090016` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `G090017` varchar(255) DEFAULT NULL COMMENT '交易对手已支付金额；原始数据格式：20n(2)',
  `G090019` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G090018` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G090001`, `G090003`, `G090005`, `G090010`, `G090018`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.9信贷资产转让';
