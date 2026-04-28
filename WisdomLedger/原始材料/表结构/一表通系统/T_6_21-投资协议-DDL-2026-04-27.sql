-- =====================================================
-- 报表：6.21投资协议
-- 表名：T_6_21
-- 字段数：30
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_21`;
CREATE TABLE `T_6_21` (
  `F210001` varchar(60) NOT NULL COMMENT '协议ID；原始数据格式：anc..60',
  `F210002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F210003` varchar(60) DEFAULT NULL COMMENT '交易对手ID；原始数据格式：anc..60',
  `F210004` varchar(255) DEFAULT NULL COMMENT '交易对手名称；原始数据格式：anc',
  `F210005` varchar(255) DEFAULT NULL COMMENT '交易对手账号；原始数据格式：an',
  `F210006` varchar(30) DEFAULT NULL COMMENT '交易对手账号行号；原始数据格式：an..30',
  `F210007` date DEFAULT NULL COMMENT '签约日期；原始数据格式：YYYY-MM-DD',
  `F210008` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `F210009` char(2) DEFAULT NULL COMMENT '收益类型；原始数据格式：2!n',
  `F210010` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F210011` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F210012` varchar(255) DEFAULT NULL COMMENT '协议金额；原始数据格式：20n(2)',
  `F210013` varchar(255) DEFAULT NULL COMMENT '保证金账号；原始数据格式：anc',
  `F210014` varchar(255) DEFAULT NULL COMMENT '保证金比例；原始数据格式：20n(6)',
  `F210015` char(3) DEFAULT NULL COMMENT '保证金币种；原始数据格式：3!a',
  `F210016` varchar(255) DEFAULT NULL COMMENT '保证金金额；原始数据格式：20n(2)',
  `F210017` char(2) DEFAULT NULL COMMENT '估值方法；原始数据格式：2!n',
  `F210018` char(2) DEFAULT NULL COMMENT '资金来源；原始数据格式：2!n',
  `F210019` char(2) DEFAULT NULL COMMENT '投资管理方式；原始数据格式：2!n',
  `F210020` varchar(60) DEFAULT NULL COMMENT '投资标的ID；原始数据格式：an..60',
  `F210021` varchar(255) DEFAULT NULL COMMENT '合同执行利率；原始数据格式：20n(6)',
  `F210022` char(1) DEFAULT NULL COMMENT '含权标识；原始数据格式：1!n',
  `F210023` char(3) DEFAULT NULL COMMENT '重点产业标识；原始数据格式：3!n',
  `F210024` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F210025` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F210026` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F210027` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F210028` char(1) DEFAULT NULL COMMENT '或有负债标识；原始数据格式：1!n',
  `F210029` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F210030` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F210001`, `F210002`, `F210030`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.21投资协议';
