-- =====================================================
-- 报表：8.5信用卡分期状态
-- 表名：T_8_5
-- 字段数：25
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_5`;
CREATE TABLE `T_8_5` (
  `H050001` varchar(100) DEFAULT NULL COMMENT '分期业务ID；原始数据格式：anc..100',
  `H050002` varchar(40) DEFAULT NULL COMMENT '卡号；原始数据格式：n..40',
  `H050003` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `H050004` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `H050019` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H050005` varchar(60) DEFAULT NULL COMMENT '分期交易类型；原始数据格式：anc..60',
  `H050006` varchar(60) DEFAULT NULL COMMENT '分期业务类型；原始数据格式：anc..60',
  `H050007` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `H050008` varchar(255) DEFAULT NULL COMMENT '分期总额度；原始数据格式：20n(2)',
  `H050009` varchar(255) DEFAULT NULL COMMENT '可用分期额度；原始数据格式：20n(2)',
  `H050010` varchar(255) DEFAULT NULL COMMENT '分期金额；原始数据格式：20n(2)',
  `H050011` varchar(255) DEFAULT NULL COMMENT '分期期数；原始数据格式：n',
  `H050012` varchar(255) DEFAULT NULL COMMENT '分期利率；原始数据格式：20n(6)',
  `H050013` date DEFAULT NULL COMMENT '办理分期日期；原始数据格式：YYYY-MM-DD',
  `H050014` time DEFAULT NULL COMMENT '办理分期时间；原始数据格式：HH:MM:SS',
  `H050015` varchar(40) DEFAULT NULL COMMENT '分期转入卡号；原始数据格式：n..40',
  `H050020` varchar(255) DEFAULT NULL COMMENT '分期转入户名；原始数据格式：anc',
  `H050016` char(1) DEFAULT NULL COMMENT '个性化分期标识；原始数据格式：1!n',
  `H050017` char(1) DEFAULT NULL COMMENT '提前结清标识；原始数据格式：1!n',
  `H050021` varchar(255) DEFAULT NULL COMMENT '分期余额；原始数据格式：20n(2)',
  `H050022` varchar(255) DEFAULT NULL COMMENT '逾期金额；原始数据格式：20n(2)',
  `H050024` varchar(255) DEFAULT NULL COMMENT '信用卡账号；原始数据格式：an',
  `H050025` char(6) DEFAULT NULL COMMENT '绿色融资类型；原始数据格式：6!n',
  `H050023` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H050018` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H050003`, `H050019`, `H050018`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.5信用卡分期状态';
