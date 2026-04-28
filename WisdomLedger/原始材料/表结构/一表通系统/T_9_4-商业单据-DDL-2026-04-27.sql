-- =====================================================
-- 报表：9.4商业单据
-- 表名：T_9_4
-- 字段数：9
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_9_4`;
CREATE TABLE `T_9_4` (
  `J040001` varchar(200) NOT NULL COMMENT '单据ID；原始数据格式：anc..200',
  `J040002` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `J040003` varchar(60) DEFAULT NULL COMMENT '开票人客户ID；原始数据格式：anc..60',
  `J040009` varchar(100) DEFAULT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `J040004` char(3) DEFAULT NULL COMMENT '商业单据币种；原始数据格式：3!a',
  `J040005` varchar(255) DEFAULT NULL COMMENT '商业单据金额；原始数据格式：20n(2)',
  `J040006` varchar(30) DEFAULT NULL COMMENT '商业单据种类；原始数据格式：anc..30',
  `J040007` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `J040008` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`J040001`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='9.4商业单据';
