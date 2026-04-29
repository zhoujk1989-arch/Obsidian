-- =====================================================
-- 报表：2.5个人客户基本情况
-- 表名：T_2_5
-- 字段数：39
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_2_5`;
CREATE TABLE `T_2_5` (
  `B050001` varchar(60) NOT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `B050002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `B050003` varchar(200) DEFAULT NULL COMMENT '个人客户名称；原始数据格式：anc..200',
  `B050004` varchar(60) DEFAULT NULL COMMENT '个人客户类型；原始数据格式：anc..60',
  `B050005` varchar(100) DEFAULT NULL COMMENT '客户身份证；原始数据格式：anc..100',
  `B050006` varchar(100) DEFAULT NULL COMMENT '客户护照号；原始数据格式：anc..100',
  `B050007` varchar(60) DEFAULT NULL COMMENT '客户其他证件类型；原始数据格式：anc..60',
  `B050008` varchar(100) DEFAULT NULL COMMENT '客户其他证件号码；原始数据格式：anc..100',
  `B050009` varchar(255) DEFAULT NULL COMMENT '民族；原始数据格式：anc',
  `B050010` char(2) DEFAULT NULL COMMENT '性别；原始数据格式：2!n',
  `B050011` varchar(30) DEFAULT NULL COMMENT '学历；原始数据格式：anc..30',
  `B050012` date DEFAULT NULL COMMENT '出生日期；原始数据格式：YYYY-MM-DD',
  `B050013` char(1) DEFAULT NULL COMMENT '已婚标识；原始数据格式：1!n',
  `B050014` varchar(128) DEFAULT NULL COMMENT '电话1；原始数据格式：an..128',
  `B050015` varchar(128) DEFAULT NULL COMMENT '电话2；原始数据格式：an..128',
  `B050016` varchar(255) DEFAULT NULL COMMENT '工作单位名称；原始数据格式：anc',
  `B050017` varchar(128) DEFAULT NULL COMMENT '工作单位电话；原始数据格式：an..128',
  `B050018` varchar(255) DEFAULT NULL COMMENT '工作单位地址；原始数据格式：anc..255',
  `B050019` varchar(60) DEFAULT NULL COMMENT '单位性质；原始数据格式：anc..60',
  `B050020` varchar(200) DEFAULT NULL COMMENT '职业；原始数据格式：an..200',
  `B050021` varchar(200) DEFAULT NULL COMMENT '职务；原始数据格式：anc..200',
  `B050022` varchar(255) DEFAULT NULL COMMENT '个人年收入；原始数据格式：20n(2)',
  `B050023` varchar(255) DEFAULT NULL COMMENT '家庭收入；原始数据格式：20n(2)',
  `B050024` varchar(600) DEFAULT NULL COMMENT '通讯地址；原始数据格式：anc..600',
  `B050037` char(6) DEFAULT NULL COMMENT '个人客户行政区划；原始数据格式：6!n',
  `B050026` char(1) DEFAULT NULL COMMENT '本行员工标识；原始数据格式：1!n',
  `B050027` varchar(255) DEFAULT NULL COMMENT '首次建立信贷关系年月；原始数据格式：YYYY-MM',
  `B050028` char(1) DEFAULT NULL COMMENT '上本行黑名单标识；原始数据格式：1!n',
  `B050029` date DEFAULT NULL COMMENT '上黑名单日期；原始数据格式：YYYY-MM-DD',
  `B050030` varchar(255) DEFAULT NULL COMMENT '上黑名单原因；原始数据格式：anc',
  `B050031` char(1) DEFAULT NULL COMMENT '居民标识；原始数据格式：1!n',
  `B050032` char(3) DEFAULT NULL COMMENT '国家地区；原始数据格式：3!a',
  `B050033` char(1) DEFAULT NULL COMMENT '农户及新型农业经营主体标识；原始数据格式：1!n',
  `B050034` char(1) DEFAULT NULL COMMENT '已脱贫人口标识；原始数据格式：1!n',
  `B050035` char(1) DEFAULT NULL COMMENT '边缘易致贫人口标识；原始数据格式：1!n',
  `B050040` char(1) DEFAULT NULL COMMENT '新型农业经营主体标识；原始数据格式：1!n',
  `B050038` date DEFAULT NULL COMMENT '失效日期；原始数据格式：YYYY-MM-DD',
  `B050039` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `B050036` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`B050001`, `B050002`, `B050036`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='2.5个人客户基本情况';
