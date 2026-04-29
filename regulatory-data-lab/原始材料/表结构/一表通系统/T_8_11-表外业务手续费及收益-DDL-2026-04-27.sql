-- =====================================================
-- 报表：8.11表外业务手续费及收益
-- 表名：T_8_11
-- 字段数：14
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_11`;
CREATE TABLE `T_8_11` (
  `H110001` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H110002` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `H110003` varchar(60) DEFAULT NULL COMMENT '业务类型；原始数据格式：anc..60',
  `H110004` varchar(255) DEFAULT NULL COMMENT '业务余额；原始数据格式：20n(2)',
  `H110005` varchar(255) DEFAULT NULL COMMENT '本年累计发生额；原始数据格式：20n(2)',
  `H110006` varchar(255) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc',
  `H110007` varchar(255) DEFAULT NULL COMMENT '累计实现产品收益；原始数据格式：20n(2)',
  `H110008` varchar(255) DEFAULT NULL COMMENT '累计实现银行端收益；原始数据格式：20n(2)',
  `H110009` varchar(255) DEFAULT NULL COMMENT '累计实现客户端收益；原始数据格式：20n(2)',
  `H110010` char(2) DEFAULT NULL COMMENT '手续费计算方式；原始数据格式：2!n',
  `H110011` varchar(255) DEFAULT NULL COMMENT '手续费总额；原始数据格式：20n(2)',
  `H110012` varchar(20) DEFAULT NULL COMMENT '手续费收取方式；原始数据格式：anc..20',
  `H110014` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H110013` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H110001`, `H110002`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.11表外业务手续费及收益';
