-- =====================================================
-- 报表：10.2汇率利率
-- 表名：T_10_2
-- 字段数：10
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_10_2`;
CREATE TABLE `T_10_2` (
  `K020001` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `K020002` char(14) DEFAULT NULL COMMENT '汇率ID；原始数据格式：14!an',
  `K020003` char(3) NOT NULL COMMENT '外币币种；原始数据格式：3!a',
  `K020004` char(3) NOT NULL COMMENT '本币币种；原始数据格式：3!a',
  `K020005` varchar(255) DEFAULT NULL COMMENT '中间价；原始数据格式：20n(6)',
  `K020006` varchar(255) DEFAULT NULL COMMENT '基准价；原始数据格式：20n(6)',
  `K020007` varchar(255) DEFAULT NULL COMMENT '基准（LPR）利率（一年期）；原始数据格式：20n(6)',
  `K020008` varchar(255) DEFAULT NULL COMMENT '基准（LPR）利率（五年期）；原始数据格式：20n(6)',
  `K020010` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `K020009` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`K020001`, `K020003`, `K020004`, `K020009`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='10.2汇率利率';
