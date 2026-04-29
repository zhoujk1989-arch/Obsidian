-- =====================================================
-- 报表：6.26其他协议
-- 表名：T_6_26
-- 字段数：31
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_26`;
CREATE TABLE `T_6_26` (
  `F260001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F260002` varchar(200) DEFAULT NULL COMMENT '业务号码；原始数据格式：anc..200',
  `F260003` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F260004` varchar(60) DEFAULT NULL COMMENT '交易对手ID；原始数据格式：anc..60',
  `F260005` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `F260028` varchar(64) DEFAULT NULL COMMENT '授信ID；原始数据格式：anc..64',
  `F260006` varchar(255) DEFAULT NULL COMMENT '交易对手名称；原始数据格式：anc',
  `F260007` varchar(30) DEFAULT NULL COMMENT '交易对手大类；原始数据格式：anc..30',
  `F260008` varchar(255) DEFAULT NULL COMMENT '交易对手账号；原始数据格式：an',
  `F260009` varchar(255) DEFAULT NULL COMMENT '交易对手账号行号；原始数据格式：an.30',
  `F260010` date DEFAULT NULL COMMENT '签约日期；原始数据格式：YYYY-MM-DD',
  `F260011` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `F260012` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F260013` varchar(128) DEFAULT NULL COMMENT '其他协议币种；原始数据格式：a..128',
  `F260014` varchar(255) DEFAULT NULL COMMENT '协议金额；原始数据格式：20n(2)',
  `F260015` char(2) DEFAULT NULL COMMENT '协议义务；原始数据格式：2!n',
  `F260016` char(4) DEFAULT NULL COMMENT '业务品种；原始数据格式：4!n',
  `F260017` varchar(255) DEFAULT NULL COMMENT '业务品种描述；原始数据格式：anc',
  `F260020` char(3) DEFAULT NULL COMMENT '重点产业标识；原始数据格式：3!n',
  `F260021` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F260022` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F260023` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F260024` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F260025` char(1) DEFAULT NULL COMMENT '或有负债标识；原始数据格式：1!n',
  `F260029` char(2) DEFAULT NULL COMMENT '交易方向；原始数据格式：2!n',
  `F260030` varchar(60) DEFAULT NULL COMMENT '其他交易对手ID；原始数据格式：anc..60',
  `F260031` varchar(255) DEFAULT NULL COMMENT '其他交易对手名称；原始数据格式：anc',
  `F260032` varchar(30) DEFAULT NULL COMMENT '其他交易对手大类；原始数据格式：anc..30',
  `F260033` varchar(255) DEFAULT NULL COMMENT '其他交易对手账号；原始数据格式：anc',
  `F260026` varchar(255) DEFAULT NULL COMMENT '备注；原始数据格式：anc',
  `F260027` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F260001`, `F260003`, `F260027`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.26其他协议';
