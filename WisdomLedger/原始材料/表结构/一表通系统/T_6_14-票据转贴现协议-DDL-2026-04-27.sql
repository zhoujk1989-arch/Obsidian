-- =====================================================
-- 报表：6.14票据转贴现协议
-- 表名：T_6_14
-- 字段数：37
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_14`;
CREATE TABLE `T_6_14` (
  `F140001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F140002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F140003` varchar(60) NOT NULL COMMENT '票据号码；原始数据格式：n..60',
  `F140036` varchar(64) DEFAULT NULL COMMENT '授信ID；原始数据格式：anc..64',
  `F140037` varchar(100) NOT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `F140004` char(2) DEFAULT NULL COMMENT '票据类型；原始数据格式：2!n',
  `F140005` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F140006` varchar(255) DEFAULT NULL COMMENT '票面金额；原始数据格式：20n(2)',
  `F140007` date DEFAULT NULL COMMENT '票据签发日期；原始数据格式：YYYY-MM-DD',
  `F140008` date DEFAULT NULL COMMENT '票据到期日期；原始数据格式：YYYY-MM-DD',
  `F140009` varchar(255) DEFAULT NULL COMMENT '出票人名称；原始数据格式：anc',
  `F140010` varchar(255) DEFAULT NULL COMMENT '承兑人名称；原始数据格式：anc',
  `F140011` varchar(200) DEFAULT NULL COMMENT '贴现人名称；原始数据格式：anc..200',
  `F140012` date DEFAULT NULL COMMENT '贴现日期；原始数据格式：YYYY-MM-DD',
  `F140013` char(2) DEFAULT NULL COMMENT '交易方向；原始数据格式：2!n',
  `F140014` char(2) DEFAULT NULL COMMENT '转贴现类型；原始数据格式：2!n',
  `F140015` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `F140016` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `F140017` date DEFAULT NULL COMMENT '转贴现日期；原始数据格式：YYYY-MM-DD',
  `F140018` varchar(255) DEFAULT NULL COMMENT '转贴现金额；原始数据格式：20n(2)',
  `F140019` varchar(255) DEFAULT NULL COMMENT '转贴现计息天数；原始数据格式：n',
  `F140020` varchar(255) DEFAULT NULL COMMENT '转贴现利率；原始数据格式：20n(6)',
  `F140021` varchar(255) DEFAULT NULL COMMENT '转贴现利息；原始数据格式：20n(2)',
  `F140022` date DEFAULT NULL COMMENT '回购日期；原始数据格式：YYYY-MM-DD',
  `F140023` varchar(255) DEFAULT NULL COMMENT '回购金额；原始数据格式：20n(2)',
  `F140024` varchar(255) DEFAULT NULL COMMENT '回购利率；原始数据格式：20n(6)',
  `F140025` varchar(255) DEFAULT NULL COMMENT '回购利息；原始数据格式：20n(2)',
  `F140026` varchar(255) DEFAULT NULL COMMENT '交易对手名称；原始数据格式：anc',
  `F140027` varchar(30) DEFAULT NULL COMMENT '交易对手账号行号；原始数据格式：an..30',
  `F140028` char(3) DEFAULT NULL COMMENT '重点产业标识；原始数据格式：3!n',
  `F140029` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F140030` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F140031` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F140032` char(1) DEFAULT NULL COMMENT '或有负债标识；原始数据格式：1!n',
  `F140033` varchar(30) DEFAULT NULL COMMENT '票据状态；原始数据格式：anc..30',
  `F140034` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F140035` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F140001`, `F140002`, `F140003`, `F140037`, `F140035`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.14票据转贴现协议';
