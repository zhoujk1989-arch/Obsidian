-- =====================================================
-- 报表：3.4集团实际控制人
-- 表名：T_3_4
-- 字段数：13
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_3_4`;
CREATE TABLE `T_3_4` (
  `C040001` varchar(64) NOT NULL COMMENT '关系ID；原始数据格式：anc..64',
  `C040002` varchar(60) DEFAULT NULL COMMENT '集团ID；原始数据格式：anc..60',
  `C040003` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `C040004` varchar(200) DEFAULT NULL COMMENT '实际控制人名称；原始数据格式：anc..200',
  `C040005` varchar(60) DEFAULT NULL COMMENT '实际控制人类别；原始数据格式：anc..60',
  `C040006` char(3) DEFAULT NULL COMMENT '实际控制人国家地区；原始数据格式：3!a',
  `C040007` varchar(60) DEFAULT NULL COMMENT '实际控制人证件类型；原始数据格式：anc..60',
  `C040008` varchar(100) DEFAULT NULL COMMENT '实际控制人证件号码；原始数据格式：anc..100',
  `C040009` varchar(100) DEFAULT NULL COMMENT '登记注册代码；原始数据格式：anc..100',
  `C040010` date DEFAULT NULL COMMENT '关系失效日期；原始数据格式：YYYY-MM-DD',
  `C040012` varchar(60) DEFAULT NULL COMMENT '实际控制人类型；原始数据格式：anc..60',
  `C040013` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `C040011` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`C040001`, `C040003`, `C040011`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='3.4集团实际控制人';
