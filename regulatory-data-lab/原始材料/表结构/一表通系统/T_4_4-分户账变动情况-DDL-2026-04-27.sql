-- =====================================================
-- 报表：4.4分户账变动情况
-- 表名：T_4_4
-- 字段数：14
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_4_4`;
CREATE TABLE `T_4_4` (
  `D040001` varchar(255) NOT NULL COMMENT '分户账号；原始数据格式：an',
  `D040002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `D040003` date DEFAULT NULL COMMENT '会计日期；原始数据格式：YYYY-MM-DD',
  `D040004` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `D040005` varchar(255) DEFAULT NULL COMMENT '期初借方余额；原始数据格式：20n(2)',
  `D040006` varchar(255) DEFAULT NULL COMMENT '期初贷方余额；原始数据格式：20n(2)',
  `D040007` varchar(255) DEFAULT NULL COMMENT '本期借方发生额；原始数据格式：20n(2)',
  `D040008` varchar(255) DEFAULT NULL COMMENT '本期贷方发生额；原始数据格式：20n(2)',
  `D040009` varchar(255) DEFAULT NULL COMMENT '期末借方余额；原始数据格式：20n(2)',
  `D040010` varchar(255) DEFAULT NULL COMMENT '期末贷方余额；原始数据格式：20n(2)',
  `D040011` varchar(255) DEFAULT NULL COMMENT '应收利息；原始数据格式：20n(2)',
  `D040012` varchar(255) DEFAULT NULL COMMENT '应付利息；原始数据格式：20n(2)',
  `D040014` varchar(12) DEFAULT NULL COMMENT '钞汇类别；原始数据格式：anc..12',
  `D040013` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`D040001`, `D040002`, `D040013`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='4.4分户账变动情况';
