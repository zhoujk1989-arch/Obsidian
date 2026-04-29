-- =====================================================
-- 报表：7.3贸易融资交易
-- 表名：T_7_3
-- 字段数：19
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_3`;
CREATE TABLE `T_7_3` (
  `G030001` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `G030002` varchar(100) DEFAULT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `G030003` varchar(255) DEFAULT NULL COMMENT '分户账号；原始数据格式：an',
  `G030004` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `G030005` varchar(24) NOT NULL COMMENT '交易机构ID；原始数据格式：anc..24',
  `G030006` date DEFAULT NULL COMMENT '核心交易日期；原始数据格式：YYYY-MM-DD',
  `G030007` time DEFAULT NULL COMMENT '核心交易时间；原始数据格式：HH:MM:SS',
  `G030008` varchar(60) DEFAULT NULL COMMENT '交易类型；原始数据格式：anc..60',
  `G030009` varchar(255) DEFAULT NULL COMMENT '交易金额；原始数据格式：20n(2)',
  `G030010` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `G030011` varchar(255) DEFAULT NULL COMMENT '业务余额；原始数据格式：20n(2)',
  `G030012` varchar(255) DEFAULT NULL COMMENT '对方账号；原始数据格式：an',
  `G030013` varchar(255) DEFAULT NULL COMMENT '对方户名；原始数据格式：anc',
  `G030014` varchar(30) DEFAULT NULL COMMENT '对方账号行号；原始数据格式：an..30',
  `G030015` varchar(255) DEFAULT NULL COMMENT '对方行名；原始数据格式：anc',
  `G030016` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `G030017` varchar(32) DEFAULT NULL COMMENT '授权员工ID；原始数据格式：anc..32',
  `G030019` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G030018` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G030001`, `G030005`, `G030018`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.3贸易融资交易';
