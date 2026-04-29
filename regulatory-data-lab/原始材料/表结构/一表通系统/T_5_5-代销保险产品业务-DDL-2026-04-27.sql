-- =====================================================
-- 报表：5.5代销保险产品业务
-- 表名：T_5_5
-- 字段数：10
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_5_5`;
CREATE TABLE `T_5_5` (
  `E050001` varchar(32) NOT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `E050002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `E050003` varchar(255) DEFAULT NULL COMMENT '产品名称；原始数据格式：anc',
  `E050004` varchar(255) DEFAULT NULL COMMENT '产品编号；原始数据格式：an',
  `E050005` varchar(255) DEFAULT NULL COMMENT '保险公司名称；原始数据格式：anc',
  `E050006` char(4) DEFAULT NULL COMMENT '险种子类型代码；原始数据格式：4!n',
  `E050007` varchar(255) NOT NULL COMMENT '附加险产品编号；原始数据格式：an',
  `E050008` varchar(255) DEFAULT NULL COMMENT '附加险名称；原始数据格式：anc',
  `E050009` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `E050010` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`E050001`, `E050002`, `E050007`, `E050010`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='5.5代销保险产品业务';
