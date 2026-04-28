-- =====================================================
-- 报表：6.19代理协议
-- 表名：T_6_19
-- 字段数：20
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_19`;
CREATE TABLE `T_6_19` (
  `F190001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F190002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F190003` varchar(60) DEFAULT NULL COMMENT '委托人ID；原始数据格式：anc..60',
  `F190004` varchar(200) DEFAULT NULL COMMENT '委托人名称；原始数据格式：anc..200',
  `F190005` varchar(60) DEFAULT NULL COMMENT '委托人类型；原始数据格式：anc..60',
  `F190006` varchar(60) DEFAULT NULL COMMENT '代理产品类型；原始数据格式：anc..60',
  `F190007` varchar(255) DEFAULT NULL COMMENT '代理产品ID；原始数据格式：anc',
  `F190008` varchar(255) DEFAULT NULL COMMENT '发行机构评级；原始数据格式：anc',
  `F190009` varchar(255) DEFAULT NULL COMMENT '发行机构评级机构；原始数据格式：anc',
  `F190010` varchar(200) DEFAULT NULL COMMENT '融资人名称；原始数据格式：anc..200',
  `F190011` char(5) DEFAULT NULL COMMENT '融资人行业类型；原始数据格式：5!an',
  `F190012` date DEFAULT NULL COMMENT '签约日期；原始数据格式：YYYY-MM-DD',
  `F190013` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `F190014` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F190018` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F190019` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F190020` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F190021` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F190022` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F190023` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F190001`, `F190002`, `F190023`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.19代理协议';
