-- =====================================================
-- 报表：4.1总账会计全科目
-- 表名：T_4_1
-- 字段数：13
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_4_1`;
CREATE TABLE `T_4_1` (
  `D010001` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `D010002` varchar(32) NOT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `D010003` varchar(255) DEFAULT NULL COMMENT '期初借方余额；原始数据格式：20n(2)',
  `D010004` varchar(255) DEFAULT NULL COMMENT '期初贷方余额；原始数据格式：20n(2)',
  `D010005` varchar(255) DEFAULT NULL COMMENT '本期借方发生额；原始数据格式：20n(2)',
  `D010006` varchar(255) DEFAULT NULL COMMENT '本期贷方发生额；原始数据格式：20n(2)',
  `D010007` varchar(255) DEFAULT NULL COMMENT '期末借方余额；原始数据格式：20n(2)',
  `D010008` varchar(255) DEFAULT NULL COMMENT '期末贷方余额；原始数据格式：20n(2)',
  `D010009` char(3) NOT NULL COMMENT '币种；原始数据格式：3!a',
  `D010010` date NOT NULL COMMENT '会计日期；原始数据格式：YYYY-MM-DD',
  `D010011` varchar(30) NOT NULL COMMENT '报表周期；原始数据格式：anc..30',
  `D010013` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `D010012` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`D010001`, `D010002`, `D010009`, `D010010`, `D010011`, `D010012`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='4.1总账会计全科目';
