-- =====================================================
-- 报表：2.2集团基本情况
-- 表名：T_2_2
-- 字段数：24
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_2_2`;
CREATE TABLE `T_2_2` (
  `B020001` varchar(60) NOT NULL COMMENT '集团ID；原始数据格式：anc..60',
  `B020002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `B020003` varchar(18) DEFAULT NULL COMMENT '母公司统一社会信用代码；原始数据格式：an..18',
  `B020004` varchar(100) DEFAULT NULL COMMENT '工商注册编号；原始数据格式：an..100',
  `B020020` varchar(60) DEFAULT NULL COMMENT '母公司客户ID；原始数据格式：anc..60',
  `B020005` varchar(255) DEFAULT NULL COMMENT '母公司名称；原始数据格式：anc',
  `B020006` char(2) DEFAULT NULL COMMENT '授信类型；原始数据格式：2!n',
  `B020007` varchar(255) DEFAULT NULL COMMENT '集团名称；原始数据格式：anc',
  `B020008` varchar(255) DEFAULT NULL COMMENT '集团成员数；原始数据格式：n',
  `B020009` varchar(255) DEFAULT NULL COMMENT '注册地址；原始数据格式：anc..255',
  `B020010` char(3) DEFAULT NULL COMMENT '注册地国家地区；原始数据格式：3!a',
  `B020011` char(6) DEFAULT NULL COMMENT '注册地行政区划；原始数据格式：6!n',
  `B020012` date DEFAULT NULL COMMENT '更新注册信息日期；原始数据格式：YYYY-MM-DD',
  `B020013` varchar(255) DEFAULT NULL COMMENT '办公地址；原始数据格式：anc..255',
  `B020014` varchar(255) DEFAULT NULL COMMENT '办公地址行政区划；原始数据格式：anc',
  `B020015` date DEFAULT NULL COMMENT '更新办公地址日期；原始数据格式：YYYY-MM-DD',
  `B020016` varchar(30) DEFAULT NULL COMMENT '风险预警信号；原始数据格式：an..30',
  `B020017` varchar(30) DEFAULT NULL COMMENT '关注事件代码；原始数据格式：an..30',
  `B020018` varchar(255) DEFAULT NULL COMMENT '内部评级结果；原始数据格式：an',
  `B020023` varchar(255) DEFAULT NULL COMMENT '授信敞口额度；原始数据格式：20n(2)',
  `B020024` varchar(255) DEFAULT NULL COMMENT '授信敞口已用额度；原始数据格式：20n(2)',
  `B020022` date DEFAULT NULL COMMENT '失效日期；原始数据格式：YYYY-MM-DD',
  `B020021` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `B020019` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`B020001`, `B020002`, `B020019`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='2.2集团基本情况';
