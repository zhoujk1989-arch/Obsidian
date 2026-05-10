-- =====================================================
-- 报表：3.5关联集团信息
-- 表名：T_3_5
-- 字段数：8
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_3_5`;
CREATE TABLE `T_3_5` (
  `C050001` varchar(64) NOT NULL COMMENT '关系ID；原始数据格式：anc..64',
  `C050002` varchar(60) DEFAULT NULL COMMENT '集团ID；原始数据格式：anc..60',
  `C050003` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `C050004` varchar(60) DEFAULT NULL COMMENT '关联集团ID；原始数据格式：anc..60',
  `C050005` char(5) DEFAULT NULL COMMENT '关联关系类型；原始数据格式：5!n',
  `C050006` date DEFAULT NULL COMMENT '关系失效日期；原始数据格式：YYYY-MM-DD',
  `C050008` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `C050007` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`C050001`, `C050003`, `C050007`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='3.5关联集团信息';
