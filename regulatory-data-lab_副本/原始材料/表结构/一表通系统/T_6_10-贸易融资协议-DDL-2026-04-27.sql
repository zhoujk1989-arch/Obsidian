-- =====================================================
-- 报表：6.10贸易融资协议
-- 表名：T_6_10
-- 字段数：28
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_10`;
CREATE TABLE `T_6_10` (
  `F100001` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F100002` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F100003` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `F100028` varchar(100) NOT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `F100004` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F100005` varchar(60) DEFAULT NULL COMMENT '贸易融资品种；原始数据格式：anc..60',
  `F100006` varchar(255) DEFAULT NULL COMMENT '贸易融资金额；原始数据格式：20n(2)',
  `F100027` varchar(255) DEFAULT NULL COMMENT '实际支付金额；原始数据格式：20n(2)',
  `F100007` date DEFAULT NULL COMMENT '发放日期；原始数据格式：YYYY-MM-DD',
  `F100008` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F100009` varchar(600) DEFAULT NULL COMMENT '购货方名称；原始数据格式：anc..600',
  `F100010` varchar(600) DEFAULT NULL COMMENT '销货方名称；原始数据格式：anc..600',
  `F100011` varchar(255) DEFAULT NULL COMMENT '贸易交易内容；原始数据格式：anc',
  `F100012` varchar(255) DEFAULT NULL COMMENT '开证行名称；原始数据格式：anc',
  `F100013` varchar(200) DEFAULT NULL COMMENT '支付对象名称；原始数据格式：anc..200',
  `F100014` char(3) DEFAULT NULL COMMENT '手续费币种；原始数据格式：3!a',
  `F100015` varchar(255) DEFAULT NULL COMMENT '手续费金额；原始数据格式：20n(2)',
  `F100016` varchar(255) DEFAULT NULL COMMENT '保证金账号；原始数据格式：anc',
  `F100017` varchar(255) DEFAULT NULL COMMENT '保证金比例；原始数据格式：20n(6)',
  `F100018` char(3) DEFAULT NULL COMMENT '保证金币种；原始数据格式：3!a',
  `F100019` varchar(255) DEFAULT NULL COMMENT '保证金金额；原始数据格式：20n(2)',
  `F100020` char(3) DEFAULT NULL COMMENT '重点产业标识；原始数据格式：3!n',
  `F100021` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F100022` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F100023` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F100024` varchar(600) DEFAULT NULL COMMENT '还款对象名称；原始数据格式：anc..600',
  `F100025` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F100026` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F100001`, `F100002`, `F100028`, `F100026`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.10贸易融资协议';
