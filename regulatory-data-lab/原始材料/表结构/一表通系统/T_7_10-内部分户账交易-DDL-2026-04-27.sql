-- =====================================================
-- 报表：7.10内部分户账交易
-- 表名：T_7_10
-- 字段数：31
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_10`;
CREATE TABLE `T_7_10` (
  `G100001` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：an..100',
  `G100002` varchar(255) DEFAULT NULL COMMENT '分户账号；原始数据格式：an',
  `G100029` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `G100003` date NOT NULL COMMENT '核心交易日期；原始数据格式：YYYY-MM-DD',
  `G100004` time NOT NULL COMMENT '核心交易时间；原始数据格式：HH:MM:SS',
  `G100005` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `G100006` varchar(60) DEFAULT NULL COMMENT '交易类型；原始数据格式：anc..60',
  `G100007` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `G100008` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `G100009` char(2) DEFAULT NULL COMMENT '借贷标识；原始数据格式：2!n',
  `G100010` varchar(255) DEFAULT NULL COMMENT '交易金额；原始数据格式：20n(2)',
  `G100011` varchar(255) DEFAULT NULL COMMENT '利率；原始数据格式：20n(6)',
  `G100012` varchar(255) DEFAULT NULL COMMENT '借方余额；原始数据格式：20n(2)',
  `G100013` varchar(255) DEFAULT NULL COMMENT '贷方余额；原始数据格式：20n(2)',
  `G100014` varchar(255) DEFAULT NULL COMMENT '对方账号；原始数据格式：an',
  `G100015` varchar(255) DEFAULT NULL COMMENT '对方户名；原始数据格式：anc',
  `G100016` varchar(30) DEFAULT NULL COMMENT '对方账号行号；原始数据格式：an..30',
  `G100017` varchar(255) DEFAULT NULL COMMENT '对方行名；原始数据格式：anc',
  `G100018` varchar(255) DEFAULT NULL COMMENT '摘要；原始数据格式：anc',
  `G100019` varchar(60) DEFAULT NULL COMMENT '交易渠道；原始数据格式：anc..60',
  `G100020` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `G100021` varchar(32) DEFAULT NULL COMMENT '授权员工ID；原始数据格式：anc..32',
  `G100022` char(2) DEFAULT NULL COMMENT '冲补抹标识；原始数据格式：2!n',
  `G100023` varchar(32) DEFAULT NULL COMMENT '对方科目ID；原始数据格式：anc..32',
  `G100024` varchar(255) DEFAULT NULL COMMENT '对方科目名称；原始数据格式：anc',
  `G100025` char(2) DEFAULT NULL COMMENT '现转标识；原始数据格式：2!n',
  `G100026` date DEFAULT NULL COMMENT '进账日期；原始数据格式：YYYY-MM-DD',
  `G100027` date DEFAULT NULL COMMENT '销账日期；原始数据格式：YYYY-MM-DD',
  `G100031` date DEFAULT NULL COMMENT '会计日期；原始数据格式：YYYY-MM-DD',
  `G100030` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G100028` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G100001`, `G100029`, `G100003`, `G100004`, `G100028`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.10内部分户账交易';
