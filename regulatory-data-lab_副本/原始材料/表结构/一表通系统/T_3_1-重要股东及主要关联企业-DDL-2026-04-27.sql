-- =====================================================
-- 报表：3.1重要股东及主要关联企业
-- 表名：T_3_1
-- 字段数：21
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_3_1`;
CREATE TABLE `T_3_1` (
  `C010001` varchar(64) NOT NULL COMMENT '关系ID；原始数据格式：anc..64',
  `C010002` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `C010003` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `C010019` varchar(60) DEFAULT NULL COMMENT '股东/关联企业客户ID；原始数据格式：anc..60',
  `C010004` varchar(255) DEFAULT NULL COMMENT '公司客户名称；原始数据格式：anc',
  `C010005` varchar(200) DEFAULT NULL COMMENT '股东/关联企业名称；原始数据格式：anc..200',
  `C010006` char(1) DEFAULT NULL COMMENT '实际控制人标识；原始数据格式：1!n',
  `C010007` varchar(60) DEFAULT NULL COMMENT '股东/关联企业证件类型；原始数据格式：anc..60',
  `C010008` varchar(100) DEFAULT NULL COMMENT '股东/关联企业证件号码；原始数据格式：anc..100',
  `C010009` varchar(100) DEFAULT NULL COMMENT '登记注册代码；原始数据格式：anc..100',
  `C010010` varchar(60) DEFAULT NULL COMMENT '股东/关联企业类别；原始数据格式：anc..60',
  `C010011` char(3) DEFAULT NULL COMMENT '股东/关联企业国家地区；原始数据格式：3!a',
  `C010012` varchar(255) DEFAULT NULL COMMENT '企业股东持股比例；原始数据格式：20n(6)',
  `C010013` date DEFAULT NULL COMMENT '更新信息日期；原始数据格式：YYYY-MM-DD',
  `C010014` date DEFAULT NULL COMMENT '股东结构对应日期；原始数据格式：YYYY-MM-DD',
  `C010015` varchar(300) NOT NULL COMMENT '关系类型；原始数据格式：an..300',
  `C010021` varchar(60) DEFAULT NULL COMMENT '关系类别；原始数据格式：anc..60',
  `C010016` varchar(50) DEFAULT NULL COMMENT '关系状态；原始数据格式：an..50',
  `C010018` varchar(30) DEFAULT NULL COMMENT '关联人类别；原始数据格式：anc..30',
  `C010020` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `C010017` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`C010001`, `C010003`, `C010015`, `C010017`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='3.1重要股东及主要关联企业';
