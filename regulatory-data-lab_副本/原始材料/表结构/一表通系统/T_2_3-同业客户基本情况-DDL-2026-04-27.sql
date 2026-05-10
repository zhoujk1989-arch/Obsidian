-- =====================================================
-- 报表：2.3同业客户基本情况
-- 表名：T_2_3
-- 字段数：43
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_2_3`;
CREATE TABLE `T_2_3` (
  `B030001` varchar(60) NOT NULL COMMENT '同业ID；原始数据格式：anc..60',
  `B030002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `B030003` varchar(450) DEFAULT NULL COMMENT '客户名称；原始数据格式：anc..450',
  `B030004` char(2) DEFAULT NULL COMMENT '机构类型；原始数据格式：2!n',
  `B030037` char(2) DEFAULT NULL COMMENT '对公客户类型；原始数据格式：2!n',
  `B030038` char(2) DEFAULT NULL COMMENT '企业控股类型；原始数据格式：2!n',
  `B030005` char(15) DEFAULT NULL COMMENT '金融许可证件号码；原始数据格式：15!an',
  `B030006` char(11) DEFAULT NULL COMMENT 'SWIFT编码；原始数据格式：11!an',
  `B030007` varchar(18) DEFAULT NULL COMMENT '统一社会信用代码；原始数据格式：an..18',
  `B030039` varchar(60) DEFAULT NULL COMMENT '其他证件类型；原始数据格式：anc..60',
  `B030040` varchar(100) DEFAULT NULL COMMENT '其他证件号码；原始数据格式：anc..100',
  `B030008` varchar(255) DEFAULT NULL COMMENT '经营范围；原始数据格式：anc',
  `B030009` date DEFAULT NULL COMMENT '成立日期；原始数据格式：YYYY-MM-DD',
  `B030010` varchar(255) DEFAULT NULL COMMENT '注册地址；原始数据格式：anc..255',
  `B030011` char(3) DEFAULT NULL COMMENT '注册地国家地区；原始数据格式：3!a',
  `B030012` char(6) DEFAULT NULL COMMENT '注册地行政区划；原始数据格式：6!n',
  `B030013` varchar(200) DEFAULT NULL COMMENT '法定代表人姓名；原始数据格式：anc..200',
  `B030014` varchar(60) DEFAULT NULL COMMENT '法定代表人证件类型；原始数据格式：anc..60',
  `B030015` varchar(100) DEFAULT NULL COMMENT '法定代表人证件号码；原始数据格式：anc..100',
  `B030016` varchar(200) DEFAULT NULL COMMENT '财务人员姓名；原始数据格式：anc..200',
  `B030017` varchar(60) DEFAULT NULL COMMENT '财务人员证件类型；原始数据格式：anc..60',
  `B030018` varchar(100) DEFAULT NULL COMMENT '财务人员证件号码；原始数据格式：anc..100',
  `B030019` varchar(255) DEFAULT NULL COMMENT '基本存款账号；原始数据格式：an',
  `B030020` varchar(12) DEFAULT NULL COMMENT '基本存款账户开户行行号；原始数据格式：an..12',
  `B030021` varchar(255) DEFAULT NULL COMMENT '基本存款账户开户行名称；原始数据格式：anc',
  `B030022` varchar(255) DEFAULT NULL COMMENT '注册资本；原始数据格式：20n(2)',
  `B030023` char(3) DEFAULT NULL COMMENT '注册资本币种；原始数据格式：3!a',
  `B030024` varchar(255) DEFAULT NULL COMMENT '实收资本；原始数据格式：20n(2)',
  `B030025` char(3) DEFAULT NULL COMMENT '实收资本币种；原始数据格式：3!a',
  `B030026` char(1) DEFAULT NULL COMMENT '上市企业标识；原始数据格式：1!n',
  `B030027` decimal(8,0) DEFAULT NULL COMMENT '员工人数；原始数据格式：n..8',
  `B030028` varchar(200) DEFAULT NULL COMMENT '负责人姓名；原始数据格式：anc..200',
  `B030029` varchar(128) DEFAULT NULL COMMENT '机构联系电话；原始数据格式：an..128',
  `B030030` varchar(255) DEFAULT NULL COMMENT '外部评级结果；原始数据格式：an',
  `B030031` varchar(255) DEFAULT NULL COMMENT '信用评级机构；原始数据格式：anc',
  `B030032` varchar(255) DEFAULT NULL COMMENT '内部评级结果；原始数据格式：an',
  `B030033` date DEFAULT NULL COMMENT '首次授信日期；原始数据格式：YYYY-MM-DD',
  `B030034` varchar(30) DEFAULT NULL COMMENT '风险预警信号；原始数据格式：an..30',
  `B030035` varchar(30) DEFAULT NULL COMMENT '关注事件代码；原始数据格式：an..30',
  `B030041` char(5) DEFAULT NULL COMMENT '行业类型；原始数据格式：5!an',
  `B030042` date DEFAULT NULL COMMENT '失效日期；原始数据格式：YYYY-MM-DD',
  `B030043` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `B030036` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`B030001`, `B030002`, `B030036`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='2.3同业客户基本情况';
