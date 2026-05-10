-- =====================================================
-- 报表：3.7个人客户关系人
-- 表名：T_3_7
-- 字段数：12
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_3_7`;
CREATE TABLE `T_3_7` (
  `C070001` varchar(64) NOT NULL COMMENT '关系ID；原始数据格式：anc..64',
  `C070002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `C070003` varchar(60) DEFAULT NULL COMMENT '个人ID；原始数据格式：anc..60',
  `C070004` varchar(60) DEFAULT NULL COMMENT '社会关系；原始数据格式：anc..60',
  `C070005` varchar(60) DEFAULT NULL COMMENT '关系人ID；原始数据格式：anc..60',
  `C070006` varchar(200) DEFAULT NULL COMMENT '关系人姓名；原始数据格式：anc..200',
  `C070007` varchar(60) DEFAULT NULL COMMENT '关系人证件类型；原始数据格式：anc..60',
  `C070008` varchar(100) DEFAULT NULL COMMENT '关系人证件号码；原始数据格式：anc..100',
  `C070009` date DEFAULT NULL COMMENT '建立关系日期；原始数据格式：YYYY-MM-DD',
  `C070010` date DEFAULT NULL COMMENT '解除关系日期；原始数据格式：YYYY-MM-DD',
  `C070012` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `C070011` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`C070001`, `C070002`, `C070011`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='3.7个人客户关系人';
