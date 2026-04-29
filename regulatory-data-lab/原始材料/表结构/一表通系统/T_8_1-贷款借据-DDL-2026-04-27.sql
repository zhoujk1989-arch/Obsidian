-- =====================================================
-- 报表：8.1贷款借据
-- 表名：T_8_1
-- 字段数：8
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_1`;
CREATE TABLE `T_8_1` (
  `H010001` varchar(100) NOT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `H010004` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H010010` varchar(255) DEFAULT NULL COMMENT '借款余额；原始数据格式：20n(2)',
  `H010019` varchar(30) DEFAULT NULL COMMENT '贷款状态；原始数据格式：anc..30',
  `H010021` varchar(255) DEFAULT NULL COMMENT '贷款利率；原始数据格式：20n(6)',
  `H010025` char(1) DEFAULT NULL COMMENT '贷款逾期标识；原始数据格式：1!n',
  `H010030` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H010029` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H010001`, `H010029`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.1贷款借据';
