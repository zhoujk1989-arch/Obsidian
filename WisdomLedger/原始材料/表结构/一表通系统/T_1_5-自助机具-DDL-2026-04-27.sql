-- =====================================================
-- 报表：1.5自助机具
-- 表名：T_1_5
-- 字段数：13
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_1_5`;
CREATE TABLE `T_1_5` (
  `A050001` varchar(32) NOT NULL COMMENT '机具ID；原始数据格式：anc..32',
  `A050002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `A050003` varchar(60) DEFAULT NULL COMMENT '机具类型；原始数据格式：anc..60',
  `A050004` varchar(255) DEFAULT NULL COMMENT '设备供应商；原始数据格式：anc',
  `A050005` varchar(255) DEFAULT NULL COMMENT '设备维护商；原始数据格式：anc',
  `A050006` varchar(255) DEFAULT NULL COMMENT '机具型号；原始数据格式：an',
  `A050007` varchar(255) DEFAULT NULL COMMENT '设备地址；原始数据格式：anc',
  `A050008` varchar(32) DEFAULT NULL COMMENT '虚拟柜员ID；原始数据格式：anc..32',
  `A050009` date DEFAULT NULL COMMENT '设备启用日期；原始数据格式：YYYY-MM-DD',
  `A050010` date DEFAULT NULL COMMENT '设备停用日期；原始数据格式：YYYY-MM-DD',
  `A050011` varchar(60) DEFAULT NULL COMMENT '运营状态；原始数据格式：anc..60',
  `A050013` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `A050012` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`A050001`, `A050002`, `A050012`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='1.5自助机具';
