-- =====================================================
-- 报表：1.6股东及关联方信息
-- 表名：T_1_6
-- 字段数：30
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_1_6`;
CREATE TABLE `T_1_6` (
  `A060001` varchar(60) NOT NULL COMMENT '股东或关联方ID；原始数据格式：anc..60',
  `A060002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `A060003` varchar(200) DEFAULT NULL COMMENT '股东或关联方名称；原始数据格式：anc..200',
  `A060004` varchar(60) DEFAULT NULL COMMENT '股东或关联方类型；原始数据格式：anc..60',
  `A060005` varchar(60) DEFAULT NULL COMMENT '股东或关联方证件类型；原始数据格式：anc..60',
  `A060006` varchar(100) DEFAULT NULL COMMENT '股东或关联方证件号码；原始数据格式：anc..100',
  `A060007` char(5) DEFAULT NULL COMMENT '股东或关联方行业类型；原始数据格式：5!an',
  `A060008` varchar(255) DEFAULT NULL COMMENT '股东或关联方注册地址；原始数据格式：anc..255',
  `A060009` varchar(60) DEFAULT NULL COMMENT '机构关系类型；原始数据格式：anc..60',
  `A060010` varchar(450) DEFAULT NULL COMMENT '实际控制人名称；原始数据格式：anc..450',
  `A060011` varchar(255) DEFAULT NULL COMMENT '参股商业银行的数量；原始数据格式：n',
  `A060012` varchar(255) DEFAULT NULL COMMENT '控股商业银行的数量；原始数据格式：n',
  `A060013` char(2) DEFAULT NULL COMMENT '不良信息；原始数据格式：2!n',
  `A060014` char(1) DEFAULT NULL COMMENT '是否限权；原始数据格式：1!n',
  `A060015` varchar(60) DEFAULT NULL COMMENT '入股资金来源；原始数据格式：anc..60',
  `A060016` varchar(255) DEFAULT NULL COMMENT '入股资金账号；原始数据格式：an',
  `A060017` char(2) DEFAULT NULL COMMENT '股东或关联方状态；原始数据格式：2!n',
  `A060018` varchar(26) DEFAULT NULL COMMENT '股东持股数量；原始数据格式：n..26',
  `A060019` varchar(255) DEFAULT NULL COMMENT '股东持股比例；原始数据格式：20n(6)',
  `A060020` date DEFAULT NULL COMMENT '入股日期；原始数据格式：YYYY-MM-DD',
  `A060021` varchar(255) DEFAULT NULL COMMENT '股东股权质押比例；原始数据格式：20n(6)',
  `A060022` char(1) DEFAULT NULL COMMENT '是否驻派董监事；原始数据格式：1!n',
  `A060023` date DEFAULT NULL COMMENT '最近一次变动日期；原始数据格式：YYYY-MM-DD',
  `A060025` varchar(255) DEFAULT NULL COMMENT '股东股权最终受益人；原始数据格式：anc..255',
  `A060026` char(2) DEFAULT NULL COMMENT '控股股东标识；原始数据格式：2!n',
  `A060027` varchar(255) DEFAULT NULL COMMENT '资产负债率；原始数据格式：20n(6)',
  `A060029` char(1) DEFAULT NULL COMMENT '上市标识；原始数据格式：1!n',
  `A060030` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `A060028` varchar(255) DEFAULT NULL COMMENT '净利润；原始数据格式：20n(2)',
  `A060024` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`A060001`, `A060002`, `A060024`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='1.6股东及关联方信息';
