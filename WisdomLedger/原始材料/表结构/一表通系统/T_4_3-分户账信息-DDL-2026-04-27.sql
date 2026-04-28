-- =====================================================
-- 报表：4.3分户账信息
-- 表名：T_4_3
-- 字段数：19
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_4_3`;
CREATE TABLE `T_4_3` (
  `D030001` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `D030002` varchar(255) NOT NULL COMMENT '分户账号；原始数据格式：anc',
  `D030003` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `D030004` varchar(255) DEFAULT NULL COMMENT '分户账名称；原始数据格式：anc',
  `D030005` char(2) DEFAULT NULL COMMENT '分户账类型；原始数据格式：2!n',
  `D030006` char(1) DEFAULT NULL COMMENT '计息标识；原始数据格式：1!n',
  `D030007` varchar(60) DEFAULT NULL COMMENT '计息方式；原始数据格式：anc..60',
  `D030008` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `D030009` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `D030010` char(2) DEFAULT NULL COMMENT '借贷标识；原始数据格式：2!n',
  `D030016` varchar(12) DEFAULT NULL COMMENT '钞汇类别；原始数据格式：anc..12',
  `D030017` varchar(255) DEFAULT NULL COMMENT '内部账利率；原始数据格式：20n(6)',
  `D030018` varchar(255) DEFAULT NULL COMMENT '借方余额；原始数据格式：20n(2)',
  `D030019` varchar(255) DEFAULT NULL COMMENT '贷方余额；原始数据格式：20n(2)',
  `D030011` date DEFAULT NULL COMMENT '开户日期；原始数据格式：YYYY-MM-DD',
  `D030012` date DEFAULT NULL COMMENT '销户日期；原始数据格式：YYYY-MM-DD',
  `D030013` varchar(30) DEFAULT NULL COMMENT '账户状态；原始数据格式：anc..30',
  `D030014` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `D030015` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`D030001`, `D030002`, `D030015`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='4.3分户账信息';
