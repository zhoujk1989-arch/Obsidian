-- =====================================================
-- 报表：7.8不良资产处置
-- 表名：T_7_8
-- 字段数：25
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_7_8`;
CREATE TABLE `T_7_8` (
  `G080001` varchar(100) NOT NULL COMMENT '交易ID；原始数据格式：anc..100',
  `G080002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `G080003` varchar(100) NOT NULL COMMENT '细分资产ID；原始数据格式：anc..100',
  `G080004` varchar(100) DEFAULT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `G080005` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `G080006` varchar(60) DEFAULT NULL COMMENT '资产类型；原始数据格式：anc..60',
  `G080007` varchar(60) DEFAULT NULL COMMENT '处置类型；原始数据格式：anc..60',
  `G080024` char(5) DEFAULT NULL COMMENT '行业类型；原始数据格式：5!n',
  `G080008` date DEFAULT NULL COMMENT '处置日期；原始数据格式：YYYY-MM-DD',
  `G080009` varchar(255) DEFAULT NULL COMMENT '处置本金金额；原始数据格式：20n(2)',
  `G080010` varchar(255) DEFAULT NULL COMMENT '处置表内利息金额；原始数据格式：20n(2)',
  `G080011` varchar(255) DEFAULT NULL COMMENT '处置表外利息金额；原始数据格式：20n(2)',
  `G080025` varchar(32) DEFAULT NULL COMMENT '处置员工ID；原始数据格式：anc..32',
  `G080013` varchar(255) DEFAULT NULL COMMENT '收回资产金额；原始数据格式：20n(2)',
  `G080014` varchar(255) DEFAULT NULL COMMENT '收回表内利息金额；原始数据格式：20n(2)',
  `G080015` varchar(255) DEFAULT NULL COMMENT '收回表外利息金额；原始数据格式：20n(2)',
  `G080016` varchar(255) DEFAULT NULL COMMENT '转让资产名称；原始数据格式：anc',
  `G080017` varchar(60) DEFAULT NULL COMMENT '转让资产协议ID；原始数据格式：anc..60',
  `G080018` char(2) DEFAULT NULL COMMENT '收回标识；原始数据格式：2!n',
  `G080019` varchar(32) DEFAULT NULL COMMENT '收回员工ID；原始数据格式：anc..32',
  `G080020` date DEFAULT NULL COMMENT '处置收回日期；原始数据格式：YYYY-MM-DD',
  `G080021` char(2) DEFAULT NULL COMMENT '处置状态；原始数据格式：2!n',
  `G080022` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `G080026` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `G080023` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`G080001`, `G080002`, `G080003`, `G080023`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='7.8不良资产处置';
