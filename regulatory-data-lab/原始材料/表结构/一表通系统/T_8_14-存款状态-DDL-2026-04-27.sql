-- =====================================================
-- 报表：8.14存款状态
-- 表名：T_8_14
-- 字段数：21
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_14`;
CREATE TABLE `T_8_14` (
  `H140001` varchar(255) NOT NULL COMMENT '分户账号；原始数据格式：an',
  `H140018` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `H140002` varchar(60) NOT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `H140003` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H140004` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `H140005` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `H140006` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `H140007` varchar(30) DEFAULT NULL COMMENT '交易介质类型；原始数据格式：anc..30',
  `H140008` varchar(255) DEFAULT NULL COMMENT '交易介质号；原始数据格式：anc',
  `H140009` char(2) DEFAULT NULL COMMENT '存款期限；原始数据格式：2!n',
  `H140010` varchar(255) DEFAULT NULL COMMENT '利率；原始数据格式：20n(6)',
  `H140011` date DEFAULT NULL COMMENT '开户日期；原始数据格式：YYYY-MM-DD',
  `H140012` date DEFAULT NULL COMMENT '销户日期；原始数据格式：YYYY-MM-DD',
  `H140016` date DEFAULT NULL COMMENT '上次动户日期；原始数据格式：YYYY-MM-DD',
  `H140013` varchar(255) DEFAULT NULL COMMENT '存款余额；原始数据格式：20n(2)',
  `H140019` char(2) DEFAULT NULL COMMENT '通过互联网吸收的存款类型；原始数据格式：2!n',
  `H140020` char(1) DEFAULT NULL COMMENT '各项存款剔除项标识；原始数据格式：1!n',
  `H140014` varchar(30) DEFAULT NULL COMMENT '账户状态；原始数据格式：anc..30',
  `H140017` varchar(12) DEFAULT NULL COMMENT '钞汇类别；原始数据格式：anc..12',
  `H140021` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H140015` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H140001`, `H140018`, `H140002`, `H140015`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.14存款状态';
