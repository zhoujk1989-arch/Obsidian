-- =====================================================
-- 报表：2.6客户财务信息
-- 表名：T_2_6
-- 字段数：24
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_2_6`;
CREATE TABLE `T_2_6` (
  `B060001` varchar(60) NOT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `B060002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `B060003` varchar(200) DEFAULT NULL COMMENT '对公客户名称；原始数据格式：anc..200',
  `B060004` date DEFAULT NULL COMMENT '财务报表日期；原始数据格式：YYYY-MM-DD',
  `B060005` char(1) DEFAULT NULL COMMENT '是否审计；原始数据格式：1!n',
  `B060006` varchar(255) DEFAULT NULL COMMENT '审计机构；原始数据格式：anc',
  `B060007` varchar(30) DEFAULT NULL COMMENT '报表口径；原始数据格式：anc..30',
  `B060008` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `B060009` varchar(255) DEFAULT NULL COMMENT '资产总额；原始数据格式：20n(2)',
  `B060010` varchar(255) DEFAULT NULL COMMENT '负债总额；原始数据格式：20n(2)',
  `B060011` varchar(255) DEFAULT NULL COMMENT '所得税；原始数据格式：20n(2)',
  `B060012` varchar(255) DEFAULT NULL COMMENT '净利润；原始数据格式：20n(2)',
  `B060013` varchar(255) DEFAULT NULL COMMENT '主营业务收入；原始数据格式：20n(2)',
  `B060014` varchar(255) DEFAULT NULL COMMENT '存货；原始数据格式：20n(2)',
  `B060015` varchar(255) DEFAULT NULL COMMENT '现金流量净额；原始数据格式：20n(2)',
  `B060016` varchar(255) DEFAULT NULL COMMENT '应收账款；原始数据格式：20n(2)',
  `B060017` varchar(255) DEFAULT NULL COMMENT '其他应收款；原始数据格式：20n(2)',
  `B060018` varchar(255) DEFAULT NULL COMMENT '流动资产合计；原始数据格式：20n(2)',
  `B060019` varchar(255) DEFAULT NULL COMMENT '流动负债合计；原始数据格式：20n(2)',
  `B060020` varchar(20) DEFAULT NULL COMMENT '报表周期；原始数据格式：anc..20',
  `B060021` varchar(40) NOT NULL COMMENT '财务报表编号；原始数据格式：an..40',
  `B060023` date DEFAULT NULL COMMENT '报表录入日期；原始数据格式：YYYY-MM-DD',
  `B060024` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `B060022` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`B060001`, `B060002`, `B060021`, `B060022`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='2.6客户财务信息';
