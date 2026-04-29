-- =====================================================
-- 报表：8.15还款状态
-- 表名：T_8_15
-- 字段数：29
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_15`;
CREATE TABLE `T_8_15` (
  `H150001` varchar(60) NOT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `H150002` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `H150003` varchar(100) NOT NULL COMMENT '细分资产ID；原始数据格式：anc..100',
  `H150027` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H150004` varchar(60) DEFAULT NULL COMMENT '还本方式；原始数据格式：anc..60',
  `H150005` varchar(60) DEFAULT NULL COMMENT '还息方式；原始数据格式：anc..60',
  `H150006` varchar(255) DEFAULT NULL COMMENT '本期还款期数；原始数据格式：n',
  `H150007` varchar(255) DEFAULT NULL COMMENT '计划还款期数；原始数据格式：n',
  `H150008` date DEFAULT NULL COMMENT '本期计划还款日期；原始数据格式：YYYY-MM-DD',
  `H150028` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `H150009` varchar(255) DEFAULT NULL COMMENT '本期计划归还本金金额；原始数据格式：20n(2)',
  `H150010` varchar(255) DEFAULT NULL COMMENT '本期计划归还利息金额；原始数据格式：20n(2)',
  `H150011` varchar(255) DEFAULT NULL COMMENT '本期已归还本金；原始数据格式：20n(2)',
  `H150012` varchar(255) DEFAULT NULL COMMENT '本期已归还利息；原始数据格式：20n(2)',
  `H150013` varchar(255) DEFAULT NULL COMMENT '累计展期次数；原始数据格式：n',
  `H150014` varchar(255) DEFAULT NULL COMMENT '连续欠本天数；原始数据格式：n',
  `H150015` varchar(255) DEFAULT NULL COMMENT '连续欠息天数；原始数据格式：n',
  `H150016` varchar(255) DEFAULT NULL COMMENT '累积欠本天数；原始数据格式：n',
  `H150017` varchar(255) DEFAULT NULL COMMENT '累积欠息天数；原始数据格式：n',
  `H150018` varchar(255) DEFAULT NULL COMMENT '连续欠款期数；原始数据格式：n',
  `H150019` varchar(255) DEFAULT NULL COMMENT '累计欠款期数；原始数据格式：n',
  `H150020` varchar(255) DEFAULT NULL COMMENT '欠本金额；原始数据格式：20n(2)',
  `H150021` varchar(255) DEFAULT NULL COMMENT '表内欠款利息；原始数据格式：20n(2)',
  `H150022` varchar(255) DEFAULT NULL COMMENT '表外欠款利息；原始数据格式：20n(2)',
  `H150023` date DEFAULT NULL COMMENT '欠本日期；原始数据格式：YYYY-MM-DD',
  `H150024` date DEFAULT NULL COMMENT '欠息日期；原始数据格式：YYYY-MM-DD',
  `H150025` date DEFAULT NULL COMMENT '终结日期；原始数据格式：YYYY-MM-DD',
  `H150029` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H150026` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H150001`, `H150002`, `H150003`, `H150027`, `H150026`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.15还款状态';
