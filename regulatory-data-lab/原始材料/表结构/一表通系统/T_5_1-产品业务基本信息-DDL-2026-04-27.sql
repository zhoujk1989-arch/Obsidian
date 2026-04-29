-- =====================================================
-- 报表：5.1产品业务基本信息
-- 表名：T_5_1
-- 字段数：17
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_5_1`;
CREATE TABLE `T_5_1` (
  `E010001` varchar(32) NOT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `E010002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `E010003` varchar(255) DEFAULT NULL COMMENT '产品名称；原始数据格式：anc',
  `E010004` varchar(255) DEFAULT NULL COMMENT '产品编号；原始数据格式：an',
  `E010005` char(2) DEFAULT NULL COMMENT '科目类型；原始数据格式：2!n',
  `E010007` varchar(200) DEFAULT NULL COMMENT '产品类别；原始数据格式：anc..200',
  `E010008` char(2) DEFAULT NULL COMMENT '自营标识；原始数据格式：2!n',
  `E010009` varchar(255) DEFAULT NULL COMMENT '产品币种；原始数据格式：anc',
  `E010010` varchar(255) DEFAULT NULL COMMENT '产品期限；原始数据格式：anc',
  `E010011` date DEFAULT NULL COMMENT '产品成立日期；原始数据格式：YYYY-MM-DD',
  `E010012` date DEFAULT NULL COMMENT '产品到期日期；原始数据格式：YYYY-MM-DD',
  `E010013` varchar(255) DEFAULT NULL COMMENT '产品期次；原始数据格式：n',
  `E010014` char(2) DEFAULT NULL COMMENT '利率类型；原始数据格式：2!n',
  `E010015` char(2) DEFAULT NULL COMMENT '产品状态代码；原始数据格式：2!n',
  `E010018` varchar(255) DEFAULT NULL COMMENT '代客产品所属机构名称；原始数据格式：anc',
  `E010016` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `E010017` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`E010001`, `E010002`, `E010017`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='5.1产品业务基本信息';
