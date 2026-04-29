-- =====================================================
-- 报表：7.12融资交易
-- 表名：T_7_12
-- 字段数：32
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_12`;
CREATE TABLE `T_7_12` (
  `G120001` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `G120002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `G120003` varchar(60) DEFAULT NULL COMMENT '交易对手ID；原始数据格式：anc..60',
  `G120004` varchar(60) DEFAULT NULL COMMENT '融资业务ID；原始数据格式：anc..60',
  `G120005` varchar(255) DEFAULT NULL COMMENT '交易对手名称；原始数据格式：anc',
  `G120006` varchar(30) DEFAULT NULL COMMENT '交易对手账号；原始数据格式：an..30',
  `G120007` varchar(30) DEFAULT NULL COMMENT '交易对手账号行号；原始数据格式：an..30',
  `G120008` varchar(30) DEFAULT NULL COMMENT '交易对手大类；原始数据格式：anc..30',
  `G120009` char(8) DEFAULT NULL COMMENT '交易对手小类；原始数据格式：8!n',
  `G120010` varchar(20) DEFAULT NULL COMMENT '交易对手评级；原始数据格式：anc..20',
  `G120011` varchar(200) DEFAULT NULL COMMENT '交易对手评级机构；原始数据格式：anc..200',
  `G120012` varchar(100) DEFAULT NULL COMMENT '交易对手开户行名；原始数据格式：anc..100',
  `G120013` varchar(255) DEFAULT NULL COMMENT '本方清算账号；原始数据格式：an',
  `G120014` varchar(255) DEFAULT NULL COMMENT '产品名称；原始数据格式：anc',
  `G120015` char(2) DEFAULT NULL COMMENT '交易方向；原始数据格式：2!n',
  `G120016` char(2) DEFAULT NULL COMMENT '账户类型；原始数据格式：2!n',
  `G120017` date DEFAULT NULL COMMENT '交易日期；原始数据格式：YYYY-MM-DD',
  `G120018` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `G120019` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `G120020` char(3) DEFAULT NULL COMMENT '交易币种；原始数据格式：3!a',
  `G120021` varchar(255) DEFAULT NULL COMMENT '交易金额；原始数据格式：20n(2)',
  `G120022` varchar(32) DEFAULT NULL COMMENT '对应融资产品ID；原始数据格式：anc..32',
  `G120023` varchar(60) DEFAULT NULL COMMENT '融资工具类型；原始数据格式：anc..60',
  `G120024` varchar(60) DEFAULT NULL COMMENT '融资工具子类型；原始数据格式：anc..60',
  `G120025` char(2) DEFAULT NULL COMMENT '押品类型；原始数据格式：2!n',
  `G120026` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `G120027` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `G120028` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `G120029` char(1) DEFAULT NULL COMMENT '或有负债标识；原始数据格式：1!n',
  `G120032` varchar(255) DEFAULT NULL COMMENT '年化利率；原始数据格式：20n(6)',
  `G120030` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G120031` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G120001`, `G120002`, `G120031`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.12融资交易';
