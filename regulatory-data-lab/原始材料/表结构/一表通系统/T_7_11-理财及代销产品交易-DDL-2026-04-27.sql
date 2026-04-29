-- =====================================================
-- 报表：7.11理财及代销产品交易
-- 表名：T_7_11
-- 字段数：27
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_11`;
CREATE TABLE `T_7_11` (
  `G110001` varchar(100) DEFAULT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `G110002` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `G110003` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `G110014` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `G110004` char(2) DEFAULT NULL COMMENT '销售渠道；原始数据格式：2!n',
  `G110005` date NOT NULL COMMENT '销售日期；原始数据格式：YYYY-MM-DD',
  `G110006` time NOT NULL COMMENT '销售时间；原始数据格式：HH:MM:SS',
  `G110007` varchar(255) DEFAULT NULL COMMENT '关联存款账号；原始数据格式：an',
  `G110008` varchar(255) DEFAULT NULL COMMENT '关联存款账号开户行名称；原始数据格式：anc',
  `G110009` varchar(255) DEFAULT NULL COMMENT '手续费金额；原始数据格式：20n(2)',
  `G110010` char(3) DEFAULT NULL COMMENT '手续费币种；原始数据格式：3!a',
  `G110011` char(2) DEFAULT NULL COMMENT '交易方向；原始数据格式：2!n',
  `G110012` char(2) DEFAULT NULL COMMENT '现转标识；原始数据格式：2!n',
  `G110015` varchar(60) DEFAULT NULL COMMENT '客户类型；原始数据格式：anc..60',
  `G110016` varchar(60) DEFAULT NULL COMMENT '客户风险偏好评估结果；原始数据格式：anc..60',
  `G110017` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `G110018` varchar(255) DEFAULT NULL COMMENT '本方清算账号；原始数据格式：an',
  `G110019` varchar(255) DEFAULT NULL COMMENT '对方清算账号；原始数据格式：an',
  `G110020` varchar(30) DEFAULT NULL COMMENT '对方清算行号；原始数据格式：an..30',
  `G110025` varchar(255) DEFAULT NULL COMMENT '对方清算行名；原始数据格式：anc',
  `G110021` char(3) NOT NULL COMMENT '交易币种；原始数据格式：3!a',
  `G110022` varchar(255) DEFAULT NULL COMMENT '交易金额；原始数据格式：20n(2)',
  `G110023` varchar(60) DEFAULT NULL COMMENT '代理销售协议ID；原始数据格式：anc..60',
  `G110026` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `G110027` varchar(255) DEFAULT NULL COMMENT '产品名称；原始数据格式：anc',
  `G110024` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G110013` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G110003`, `G110005`, `G110006`, `G110021`, `G110013`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.11理财及代销产品交易';
