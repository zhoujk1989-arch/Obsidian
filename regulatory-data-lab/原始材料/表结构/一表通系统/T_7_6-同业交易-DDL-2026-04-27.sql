-- =====================================================
-- 报表：7.6同业交易
-- 表名：T_7_6
-- 字段数：43
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_6`;
CREATE TABLE `T_7_6` (
  `G060001` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `G060002` varchar(60) DEFAULT NULL COMMENT '同业业务ID；原始数据格式：anc..60',
  `G060003` varchar(24) NOT NULL COMMENT '交易机构ID；原始数据格式：anc..24',
  `G060004` varchar(255) DEFAULT NULL COMMENT '交易机构名称；原始数据格式：anc',
  `G060005` varchar(255) DEFAULT NULL COMMENT '交易账号；原始数据格式：anc',
  `G060006` varchar(255) DEFAULT NULL COMMENT '交易金额；原始数据格式：20n(2)',
  `G060007` char(2) DEFAULT NULL COMMENT '交易方向；原始数据格式：2!n',
  `G060008` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `G060009` date DEFAULT NULL COMMENT '交易日期；原始数据格式：YYYY-MM-DD',
  `G060010` time DEFAULT NULL COMMENT '交易时间；原始数据格式：HH:MM:SS',
  `G060011` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `G060012` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `G060024` varchar(60) DEFAULT NULL COMMENT '交易对手ID；原始数据格式：anc..60',
  `G060013` varchar(255) DEFAULT NULL COMMENT '交易对手名称；原始数据格式：anc',
  `G060014` varchar(30) DEFAULT NULL COMMENT '交易对手大类；原始数据格式：anc..30',
  `G060025` char(8) DEFAULT NULL COMMENT '交易对手小类；原始数据格式：8!n',
  `G060015` varchar(20) DEFAULT NULL COMMENT '交易对手评级；原始数据格式：anc..20',
  `G060016` varchar(200) DEFAULT NULL COMMENT '交易对手评级机构；原始数据格式：anc..200',
  `G060017` varchar(30) DEFAULT NULL COMMENT '交易对手账号行号；原始数据格式：an..30',
  `G060018` varchar(255) DEFAULT NULL COMMENT '交易对手账号；原始数据格式：an',
  `G060019` varchar(100) DEFAULT NULL COMMENT '交易对手账号开户行名称；原始数据格式：anc..100',
  `G060020` char(2) DEFAULT NULL COMMENT '是否为“调整后存贷比口径”的调整项；原始数据格式：2!n',
  `G060021` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `G060022` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `G060026` char(2) DEFAULT NULL COMMENT '自营业务大类；原始数据格式：2!n',
  `G060027` varchar(60) DEFAULT NULL COMMENT '自营业务小类；原始数据格式：anc..60',
  `G060028` char(2) DEFAULT NULL COMMENT '账户类型；原始数据格式：2!n',
  `G060029` varchar(255) DEFAULT NULL COMMENT '账户余额；原始数据格式：20n(2)',
  `G060030` char(2) DEFAULT NULL COMMENT '账户交易类型；原始数据格式：2!n',
  `G060031` varchar(255) DEFAULT NULL COMMENT '交易摘要；原始数据格式：anc',
  `G060032` varchar(255) DEFAULT NULL COMMENT '客户备注；原始数据格式：anc',
  `G060033` char(2) DEFAULT NULL COMMENT '冲补抹标志；原始数据格式：2!n',
  `G060034` char(2) DEFAULT NULL COMMENT '现转标志；原始数据格式：2!n',
  `G060035` char(2) DEFAULT NULL COMMENT '交易渠道；原始数据格式：2!n',
  `G060036` char(15) DEFAULT NULL COMMENT 'IP地址；原始数据格式：15!an',
  `G060037` varchar(60) DEFAULT NULL COMMENT 'MAC地址；原始数据格式：anc..60',
  `G060038` varchar(255) DEFAULT NULL COMMENT '外部账号（交易介质号）；原始数据格式：an',
  `G060039` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `G060040` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `G060041` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `G060043` varchar(255) DEFAULT NULL COMMENT '年化利率；原始数据格式：20n(6)',
  `G060042` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G060023` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G060001`, `G060003`, `G060023`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.6同业交易';
