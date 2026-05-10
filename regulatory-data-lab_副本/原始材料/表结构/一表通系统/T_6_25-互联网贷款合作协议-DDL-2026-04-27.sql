-- =====================================================
-- 报表：6.25互联网贷款合作协议
-- 表名：T_6_25
-- 字段数：17
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_25`;
CREATE TABLE `T_6_25` (
  `F250001` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F250002` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F250017` varchar(100) DEFAULT NULL COMMENT '主合作协议ID；原始数据格式：anc..100',
  `F250003` varchar(255) DEFAULT NULL COMMENT '合作方名称；原始数据格式：anc',
  `F250004` varchar(60) DEFAULT NULL COMMENT '合作方证件类型；原始数据格式：anc..60',
  `F250005` varchar(100) DEFAULT NULL COMMENT '合作方证件号码；原始数据格式：anc..100',
  `F250006` varchar(60) DEFAULT NULL COMMENT '合作方类型；原始数据格式：anc..60',
  `F250007` varchar(60) NOT NULL COMMENT '合作方式；原始数据格式：anc..60',
  `F250008` char(2) DEFAULT NULL COMMENT '提供增信的模式；原始数据格式：2!n',
  `F250009` char(6) DEFAULT NULL COMMENT '合作方注册地行政区划；原始数据格式：6!n',
  `F250010` date DEFAULT NULL COMMENT '合作协议起始日期；原始数据格式：YYYY-MM-DD',
  `F250011` date DEFAULT NULL COMMENT '合作协议到期日期；原始数据格式：YYYY-MM-DD',
  `F250012` date DEFAULT NULL COMMENT '合作协议实际终止日期；原始数据格式：YYYY-MM-DD',
  `F250013` char(1) DEFAULT NULL COMMENT '限制标识；原始数据格式：1!n',
  `F250014` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F250015` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F250016` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F250001`, `F250002`, `F250007`, `F250016`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.25互联网贷款合作协议';
