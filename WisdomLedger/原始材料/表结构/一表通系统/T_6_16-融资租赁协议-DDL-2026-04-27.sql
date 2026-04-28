-- =====================================================
-- 报表：6.16融资租赁协议
-- 表名：T_6_16
-- 字段数：28
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_16`;
CREATE TABLE `T_6_16` (
  `F160001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F160002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F160003` char(2) DEFAULT NULL COMMENT '融资租赁类型；原始数据格式：2!n',
  `F160004` char(2) DEFAULT NULL COMMENT '融资租赁方式；原始数据格式：2!n',
  `F160005` varchar(32) DEFAULT NULL COMMENT '租赁标的物；原始数据格式：anc..32',
  `F160006` varchar(255) DEFAULT NULL COMMENT '承租人编号；原始数据格式：anc',
  `F160007` varchar(200) DEFAULT NULL COMMENT '承租人名称；原始数据格式：anc..200',
  `F160008` varchar(255) DEFAULT NULL COMMENT '承租人账号；原始数据格式：anc',
  `F160009` varchar(255) DEFAULT NULL COMMENT '承租人开户行名称；原始数据格式：anc',
  `F160010` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F160011` varchar(255) DEFAULT NULL COMMENT '合同金额；原始数据格式：20n(2)',
  `F160012` date DEFAULT NULL COMMENT '合同起始日期；原始数据格式：YYYY-MM-DD',
  `F160013` date DEFAULT NULL COMMENT '合同到期日期；原始数据格式：YYYY-MM-DD',
  `F160014` varchar(200) DEFAULT NULL COMMENT '租赁公司名称；原始数据格式：anc..200',
  `F160015` varchar(60) DEFAULT NULL COMMENT '租赁公司证件类型；原始数据格式：anc..60',
  `F160016` varchar(100) DEFAULT NULL COMMENT '租赁公司证件号码；原始数据格式：anc..100',
  `F160017` varchar(255) DEFAULT NULL COMMENT '手续费金额；原始数据格式：20n(2)',
  `F160018` char(3) DEFAULT NULL COMMENT '手续费币种；原始数据格式：3!a',
  `F160019` varchar(255) DEFAULT NULL COMMENT '保证金账号；原始数据格式：anc',
  `F160020` char(3) DEFAULT NULL COMMENT '保证金币种；原始数据格式：3!a',
  `F160021` varchar(255) DEFAULT NULL COMMENT '保证金金额；原始数据格式：20n(2)',
  `F160022` varchar(255) DEFAULT NULL COMMENT '保证金比例；原始数据格式：20n(6)',
  `F160023` char(3) DEFAULT NULL COMMENT '重点产业标识；原始数据格式：3!n',
  `F160024` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F160025` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F160026` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F160027` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F160028` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F160001`, `F160002`, `F160028`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.16融资租赁协议';
