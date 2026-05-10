-- =====================================================
-- 报表：8.16客户理财产品持有状态
-- 表名：T_8_16
-- 字段数：12
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_16`;
CREATE TABLE `T_8_16` (
  `H160001` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `H160002` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `H160012` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H160003` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `H160009` varchar(200) DEFAULT NULL COMMENT '客户姓名；原始数据格式：anc..200',
  `H160010` char(2) DEFAULT NULL COMMENT '客户证件类别；原始数据格式：2!n',
  `H160011` varchar(100) DEFAULT NULL COMMENT '证件号码；原始数据格式：anc..100',
  `H160004` varchar(255) DEFAULT NULL COMMENT '客户持有理财余额；原始数据格式：20n(2)',
  `H160005` varchar(255) DEFAULT NULL COMMENT '客户持有理财折算人民币余额；原始数据格式：20n(2)',
  `H160006` varchar(255) DEFAULT NULL COMMENT '客户持有理财份额；原始数据格式：24n(5)',
  `H160008` date DEFAULT NULL COMMENT '客户持有日期；原始数据格式：YYYY-MM-DD',
  `H160007` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.16客户理财产品持有状态';
