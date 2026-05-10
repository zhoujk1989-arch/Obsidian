-- =====================================================
-- 报表：2.7收单商户信息表
-- 表名：T_2_7
-- 字段数：19
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_2_7`;
CREATE TABLE `T_2_7` (
  `B070001` varchar(24) NOT NULL COMMENT '商户ID；原始数据格式：anc..24',
  `B070002` varchar(60) NOT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `B070003` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `B070004` varchar(450) DEFAULT NULL COMMENT '商户名称；原始数据格式：anc..450',
  `B070005` char(1) DEFAULT NULL COMMENT '是否为POS机特约商户；原始数据格式：1!n',
  `B070006` varchar(255) NOT NULL COMMENT '终端号；原始数据格式：anc',
  `B070007` char(4) DEFAULT NULL COMMENT '商户类别码；原始数据格式：4!n',
  `B070008` varchar(255) DEFAULT NULL COMMENT '商户类别码名称；原始数据格式：anc',
  `B070009` varchar(255) DEFAULT NULL COMMENT '清算卡号或账号；原始数据格式：an',
  `B070010` varchar(60) DEFAULT NULL COMMENT '清算账号类型；原始数据格式：anc..60',
  `B070011` varchar(255) DEFAULT NULL COMMENT '清算账户名称；原始数据格式：anc',
  `B070012` varchar(255) DEFAULT NULL COMMENT '清算账号开户行名称；原始数据格式：anc',
  `B070013` date DEFAULT NULL COMMENT '商户起效日期；原始数据格式：YYYY-MM-DD',
  `B070014` date DEFAULT NULL COMMENT '商户失效日期；原始数据格式：YYYY-MM-DD',
  `B070015` char(6) DEFAULT NULL COMMENT '商户地区；原始数据格式：6!n',
  `B070016` varchar(255) DEFAULT NULL COMMENT '商户状态；原始数据格式：anc',
  `B070019` date DEFAULT NULL COMMENT '终端失效日期；原始数据格式：YYYY-MM-DD',
  `B070018` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `B070017` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`B070001`, `B070002`, `B070003`, `B070006`, `B070017`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='2.7收单商户信息表';
