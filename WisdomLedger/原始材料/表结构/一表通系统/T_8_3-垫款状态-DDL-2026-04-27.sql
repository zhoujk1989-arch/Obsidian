-- =====================================================
-- 报表：8.3垫款状态
-- 表名：T_8_3
-- 字段数：14
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_3`;
CREATE TABLE `T_8_3` (
  `H030001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `H030014` varchar(100) NOT NULL COMMENT '原细分资产ID；原始数据格式：anc..100',
  `H030002` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `H030003` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H030004` varchar(100) DEFAULT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `H030005` varchar(100) NOT NULL COMMENT '原协议ID；原始数据格式：anc..100',
  `H030006` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `H030007` varchar(60) DEFAULT NULL COMMENT '垫款类型；原始数据格式：anc..60',
  `H030008` varchar(255) DEFAULT NULL COMMENT '垫款金额；原始数据格式：20n(2)',
  `H030009` varchar(255) DEFAULT NULL COMMENT '垫款余额；原始数据格式：20n(2)',
  `H030010` date DEFAULT NULL COMMENT '垫款日期；原始数据格式：YYYY-MM-DD',
  `H030011` varchar(30) DEFAULT NULL COMMENT '垫款状态；原始数据格式：anc..30',
  `H030012` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H030013` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H030001`, `H030014`, `H030003`, `H030005`, `H030013`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.3垫款状态';
