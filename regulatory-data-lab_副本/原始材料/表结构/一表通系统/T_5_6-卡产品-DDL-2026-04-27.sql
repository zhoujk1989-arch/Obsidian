-- =====================================================
-- 报表：5.6卡产品
-- 表名：T_5_6
-- 字段数：17
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_5_6`;
CREATE TABLE `T_5_6` (
  `E060001` varchar(32) NOT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `E060002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `E060003` varchar(255) DEFAULT NULL COMMENT '产品名称；原始数据格式：anc',
  `E060004` varchar(255) DEFAULT NULL COMMENT '产品编号；原始数据格式：an',
  `E060005` varchar(60) DEFAULT NULL COMMENT '卡组织代码；原始数据格式：anc..60',
  `E060006` varchar(60) DEFAULT NULL COMMENT '卡类型；原始数据格式：anc..60',
  `E060007` char(2) DEFAULT NULL COMMENT '卡介质类型代码；原始数据格式：2!n',
  `E060008` char(2) DEFAULT NULL COMMENT '允许取现类型；原始数据格式：2!n',
  `E060009` char(1) DEFAULT NULL COMMENT '允许转出标识；原始数据格式：1!n',
  `E060010` char(1) DEFAULT NULL COMMENT '收取费用标识；原始数据格式：1!n',
  `E060011` char(1) DEFAULT NULL COMMENT '政策功能标识；原始数据格式：1!n',
  `E060012` char(2) DEFAULT NULL COMMENT '卡片形态；原始数据格式：2!n',
  `E060013` char(1) DEFAULT NULL COMMENT '联名卡标识；原始数据格式：1!n',
  `E060014` varchar(255) DEFAULT NULL COMMENT '联名单位；原始数据格式：anc',
  `E060015` varchar(128) DEFAULT NULL COMMENT '联名单位代码；原始数据格式：anc..128',
  `E060016` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `E060017` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`E060001`, `E060002`, `E060017`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='5.6卡产品';
