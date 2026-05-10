-- =====================================================
-- 报表：2.4个体工商户及小微企业主基本情况
-- 表名：T_2_4
-- 字段数：24
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_2_4`;
CREATE TABLE `T_2_4` (
  `B040001` varchar(60) NOT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `B040002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `B040034` varchar(60) DEFAULT NULL COMMENT '经营户个人ID；原始数据格式：anc..60',
  `B040003` varchar(200) DEFAULT NULL COMMENT '经营者姓名；原始数据格式：anc..200',
  `B040004` varchar(60) DEFAULT NULL COMMENT '经营者证件类型；原始数据格式：anc..60',
  `B040005` varchar(100) DEFAULT NULL COMMENT '经营者证件号码；原始数据格式：anc..100',
  `B040006` varchar(255) DEFAULT NULL COMMENT '经营者从业年限；原始数据格式：n',
  `B040033` varchar(255) DEFAULT NULL COMMENT '经营主体名称；原始数据格式：anc',
  `B040019` varchar(255) DEFAULT NULL COMMENT '经营范围；原始数据格式：anc',
  `B040020` char(5) DEFAULT NULL COMMENT '行业类型；原始数据格式：5!an',
  `B040021` char(2) DEFAULT NULL COMMENT '经营户客户类型；原始数据格式：2!n',
  `B040022` varchar(600) DEFAULT NULL COMMENT '经营地址；原始数据格式：anc..600',
  `B040023` char(6) DEFAULT NULL COMMENT '经营地所在行政区划；原始数据格式：6!n',
  `B040032` varchar(128) DEFAULT NULL COMMENT '联系电话；原始数据格式：an..128',
  `B040024` varchar(255) DEFAULT NULL COMMENT '资产总额；原始数据格式：20n(2)',
  `B040025` varchar(255) DEFAULT NULL COMMENT '负债总额；原始数据格式：20n(2)',
  `B040026` varchar(255) DEFAULT NULL COMMENT '税前利润；原始数据格式：20n(2)',
  `B040027` varchar(255) DEFAULT NULL COMMENT '主营业务收入；原始数据格式：20n(2)',
  `B040028` date DEFAULT NULL COMMENT '财务报表日期；原始数据格式：YYYY-MM-DD',
  `B040029` varchar(255) DEFAULT NULL COMMENT '信用评级结果；原始数据格式：an',
  `B040030` varchar(255) DEFAULT NULL COMMENT '首次建立信贷关系年月；原始数据格式：YYYY-MM',
  `B040036` date DEFAULT NULL COMMENT '失效日期；原始数据格式：YYYY-MM-DD',
  `B040035` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `B040031` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`B040001`, `B040002`, `B040031`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='2.4个体工商户及小微企业主基本情况';
