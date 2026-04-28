-- =====================================================
-- 报表：9.1投资标的关系
-- 表名：T_9_1
-- 字段数：17
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_9_1`;
CREATE TABLE `T_9_1` (
  `J010001` varchar(60) NOT NULL COMMENT '投资标的ID；原始数据格式：anc..60',
  `J010002` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `J010003` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `J010004` varchar(60) NOT NULL COMMENT '上一层投资标的ID；原始数据格式：anc..60',
  `J010005` varchar(255) DEFAULT NULL COMMENT '占上一层投资标的比例；原始数据格式：20n(6)',
  `J010006` varchar(255) DEFAULT NULL COMMENT '产品持有底层资产折算人民币金额；原始数据格式：24n(2)',
  `J010007` varchar(255) DEFAULT NULL COMMENT '理财产品持有底层资产折算人民币金额（理财中心）；原始数据格式：24n(2)',
  `J010008` varchar(255) DEFAULT NULL COMMENT '产品持有底层资产份额；原始数据格式：26n(6)',
  `J010009` varchar(255) DEFAULT NULL COMMENT '理财产品持有底层资产份额（理财中心）；原始数据格式：26n(6)',
  `J010010` char(2) DEFAULT NULL COMMENT '直接或间接投资标识；原始数据格式：2!n',
  `J010011` varchar(255) DEFAULT NULL COMMENT '投资标的层级；原始数据格式：n',
  `J010012` varchar(255) DEFAULT NULL COMMENT '产品总层级；原始数据格式：n',
  `J010015` char(3) DEFAULT NULL COMMENT '估值币种；原始数据格式：3!a',
  `J010016` varchar(255) DEFAULT NULL COMMENT '单位资产估值（净价）；原始数据格式：20n(4)',
  `J010017` varchar(255) DEFAULT NULL COMMENT '单位资产估值（全价）；原始数据格式：20n(4)',
  `J010013` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `J010014` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`J010001`, `J010004`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='9.1投资标的关系';
