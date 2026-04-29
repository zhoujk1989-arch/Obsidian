-- =====================================================
-- 报表：8.10理财产品状态
-- 表名：T_8_10
-- 字段数：27
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_10`;
CREATE TABLE `T_8_10` (
  `H100001` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `H100002` varchar(255) DEFAULT NULL COMMENT '累计申购金额；原始数据格式：20n(2)',
  `H100026` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H100003` varchar(255) DEFAULT NULL COMMENT '累计申购份额；原始数据格式：22n(6)',
  `H100004` varchar(255) DEFAULT NULL COMMENT '累计兑付金额；原始数据格式：20n(2)',
  `H100005` varchar(255) DEFAULT NULL COMMENT '累计兑付收益金额；原始数据格式：20n(2)',
  `H100006` varchar(255) DEFAULT NULL COMMENT '累计赎回份额；原始数据格式：22n(6)',
  `H100007` varchar(255) DEFAULT NULL COMMENT '产品存续余额；原始数据格式：20n(2)',
  `H100008` varchar(255) DEFAULT NULL COMMENT '初始净值；原始数据格式：22n(6)',
  `H100009` varchar(255) DEFAULT NULL COMMENT '产品净值；原始数据格式：22n(6)',
  `H100010` varchar(255) DEFAULT NULL COMMENT '累计净值；原始数据格式：22n(6)',
  `H100011` char(3) DEFAULT NULL COMMENT '净值币种；原始数据格式：3!a',
  `H100012` varchar(255) DEFAULT NULL COMMENT '折算人民币初始净值；原始数据格式：22n(6)',
  `H100013` varchar(255) DEFAULT NULL COMMENT '折算人民币净值；原始数据格式：22n(6)',
  `H100014` varchar(255) DEFAULT NULL COMMENT '折算人民币累计净值；原始数据格式：22n(6)',
  `H100015` varchar(255) DEFAULT NULL COMMENT '实现收益率；原始数据格式：20n(6)',
  `H100016` varchar(255) DEFAULT NULL COMMENT '银行实现收益；原始数据格式：20n(2)',
  `H100017` varchar(255) DEFAULT NULL COMMENT '理财产品杠杆率；原始数据格式：20n(6)',
  `H100018` varchar(255) DEFAULT NULL COMMENT '理财产品总资产金额；原始数据格式：20n(2)',
  `H100019` varchar(255) DEFAULT NULL COMMENT '穿透后资产余额；原始数据格式：20n(2)',
  `H100020` varchar(255) DEFAULT NULL COMMENT '穿透后负债余额；原始数据格式：20n(2)',
  `H100021` varchar(255) DEFAULT NULL COMMENT '自然人持有余额；原始数据格式：20n(2)',
  `H100022` varchar(255) DEFAULT NULL COMMENT '非金融机构持有余额；原始数据格式：20n(2)',
  `H100023` varchar(255) DEFAULT NULL COMMENT '银行类金融机构持有余额；原始数据格式：20n(2)',
  `H100024` varchar(255) DEFAULT NULL COMMENT '其他金融机构持有余额；原始数据格式：20n(2)',
  `H100027` varchar(255) DEFAULT NULL COMMENT '备注；原始数据格式：2.1版',
  `H100025` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.10理财产品状态';
