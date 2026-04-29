-- =====================================================
-- 报表：3.8交易与单据对应关系
-- 表名：T_3_8
-- 字段数：7
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_3_8`;
CREATE TABLE `T_3_8` (
  `C080002` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `C080003` varchar(200) NOT NULL COMMENT '单据ID；原始数据格式：anc..200',
  `C080004` varchar(24) NOT NULL COMMENT '交易机构ID；原始数据格式：anc..24',
  `C080005` char(2) DEFAULT NULL COMMENT '对应关系；原始数据格式：2!n',
  `C080008` varchar(30) DEFAULT NULL COMMENT '业务种类；原始数据格式：anc..30',
  `C080006` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `C080007` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`C080002`, `C080003`, `C080004`, `C080007`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='3.8交易与单据对应关系';
