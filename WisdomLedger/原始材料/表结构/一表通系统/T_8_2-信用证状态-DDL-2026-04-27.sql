-- =====================================================
-- 报表：8.2信用证状态
-- 表名：T_8_2
-- 字段数：15
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_2`;
CREATE TABLE `T_8_2` (
  `H020001` varchar(60) NOT NULL COMMENT '信用证ID；原始数据格式：anc..60',
  `H020002` varchar(24) DEFAULT NULL COMMENT '开票机构ID；原始数据格式：anc..24',
  `H020003` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `H020004` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `H020005` varchar(255) DEFAULT NULL COMMENT '议付交单机构；原始数据格式：anc',
  `H020006` char(3) NOT NULL COMMENT '币种；原始数据格式：3!a',
  `H020007` varchar(255) DEFAULT NULL COMMENT '已兑付金额；原始数据格式：20n(2)',
  `H020008` date DEFAULT NULL COMMENT '撤销日期；原始数据格式：YYYY-MM-DD',
  `H020009` date DEFAULT NULL COMMENT '闭卷日期；原始数据格式：YYYY-MM-DD',
  `H020010` varchar(255) DEFAULT NULL COMMENT '押汇余额；原始数据格式：20n(2)',
  `H020011` varchar(255) DEFAULT NULL COMMENT '垫款余额；原始数据格式：20n(2)',
  `H020012` varchar(60) DEFAULT NULL COMMENT '合同状态；原始数据格式：anc..60',
  `H020014` varchar(255) DEFAULT NULL COMMENT '待支付金额；原始数据格式：20n(2)',
  `H020015` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H020013` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H020001`, `H020006`, `H020013`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.2信用证状态';
