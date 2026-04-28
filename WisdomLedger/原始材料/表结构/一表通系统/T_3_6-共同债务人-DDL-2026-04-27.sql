-- =====================================================
-- 报表：3.6共同债务人
-- 表名：T_3_6
-- 字段数：10
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_3_6`;
CREATE TABLE `T_3_6` (
  `C060001` varchar(64) NOT NULL COMMENT '关系ID；原始数据格式：anc..64',
  `C060002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `C060003` varchar(200) DEFAULT NULL COMMENT '共同债务人名称；原始数据格式：anc..200',
  `C060004` varchar(60) DEFAULT NULL COMMENT '共同债务人证件类型；原始数据格式：anc..60',
  `C060005` varchar(100) DEFAULT NULL COMMENT '共同债务人证件号码；原始数据格式：anc..100',
  `C060006` varchar(60) DEFAULT NULL COMMENT '借款人ID；原始数据格式：anc..60',
  `C060007` varchar(100) DEFAULT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `C060008` varchar(50) DEFAULT NULL COMMENT '关系状态；原始数据格式：an..50',
  `C060010` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `C060009` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`C060001`, `C060002`, `C060009`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='3.6共同债务人';
