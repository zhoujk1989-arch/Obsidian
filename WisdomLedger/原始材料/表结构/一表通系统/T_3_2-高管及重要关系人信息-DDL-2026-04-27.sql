-- =====================================================
-- 报表：3.2高管及重要关系人信息
-- 表名：T_3_2
-- 字段数：18
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_3_2`;
CREATE TABLE `T_3_2` (
  `C020001` varchar(64) NOT NULL COMMENT '关系ID；原始数据格式：anc..64',
  `C020002` varchar(60) NOT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `C020003` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `C020016` varchar(60) DEFAULT NULL COMMENT '关系人客户ID；原始数据格式：anc..60',
  `C020004` varchar(200) DEFAULT NULL COMMENT '关系人姓名；原始数据格式：anc..200',
  `C020005` varchar(60) DEFAULT NULL COMMENT '关系人证件类型；原始数据格式：anc..60',
  `C020006` varchar(100) DEFAULT NULL COMMENT '关系人证件号码；原始数据格式：anc..100',
  `C020007` date DEFAULT NULL COMMENT '证件签发日期；原始数据格式：YYYY-MM-DD',
  `C020008` date DEFAULT NULL COMMENT '证件到期日期；原始数据格式：YYYY-MM-DD',
  `C020009` varchar(300) DEFAULT NULL COMMENT '关系类型；原始数据格式：an..300',
  `C020018` varchar(60) DEFAULT NULL COMMENT '关系类别；原始数据格式：anc..60',
  `C020010` char(4) DEFAULT NULL COMMENT '关系人类别；原始数据格式：4!n',
  `C020011` char(3) DEFAULT NULL COMMENT '关系人国家地区；原始数据格式：3!a',
  `C020012` date DEFAULT NULL COMMENT '更新信息日期；原始数据格式：YYYY-MM-DD',
  `C020013` date DEFAULT NULL COMMENT '关系失效日期；原始数据格式：YYYY-MM-DD',
  `C020015` varchar(30) DEFAULT NULL COMMENT '关联人类别；原始数据格式：anc..30',
  `C020017` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `C020014` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`C020001`, `C020002`, `C020014`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='3.2高管及重要关系人信息';
