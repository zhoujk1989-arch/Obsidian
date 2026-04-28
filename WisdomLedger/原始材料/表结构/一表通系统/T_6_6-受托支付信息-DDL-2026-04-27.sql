-- =====================================================
-- 报表：6.6受托支付信息
-- 表名：T_6_6
-- 字段数：12
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_6`;
CREATE TABLE `T_6_6` (
  `F060001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F060002` varchar(100) NOT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `F060011` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F060003` varchar(255) DEFAULT NULL COMMENT '受托支付金额；原始数据格式：20n(2)',
  `F060004` date NOT NULL COMMENT '受托支付日期；原始数据格式：YYYY-MM-DD',
  `F060005` varchar(255) NOT NULL COMMENT '受托支付对象账号；原始数据格式：an',
  `F060006` varchar(255) DEFAULT NULL COMMENT '受托支付对象户名；原始数据格式：anc',
  `F060007` varchar(30) DEFAULT NULL COMMENT '受托支付对象行号；原始数据格式：an..30',
  `F060008` varchar(255) DEFAULT NULL COMMENT '受托支付对象行名；原始数据格式：anc',
  `F060012` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `F060009` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F060010` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F060001`, `F060002`, `F060011`, `F060004`, `F060005`, `F060010`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.6受托支付信息';
