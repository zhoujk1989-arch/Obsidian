-- =====================================================
-- 报表：6.9信用卡协议
-- 表名：T_6_9
-- 字段数：39
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_9`;
CREATE TABLE `T_6_9` (
  `F090001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F090002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F090003` varchar(60) NOT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `F090004` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `F090038` varchar(64) DEFAULT NULL COMMENT '授信ID；原始数据格式：anc..64',
  `F090037` varchar(255) DEFAULT NULL COMMENT '信用卡账号；原始数据格式：an',
  `F090005` varchar(255) DEFAULT NULL COMMENT '发卡合作机构；原始数据格式：anc',
  `F090006` varchar(40) DEFAULT NULL COMMENT '发卡合作机构代码；原始数据格式：anc..40',
  `F090007` varchar(40) NOT NULL COMMENT '卡号；原始数据格式：n..40',
  `F090008` varchar(60) DEFAULT NULL COMMENT '发卡渠道；原始数据格式：anc..60',
  `F090009` char(1) DEFAULT NULL COMMENT '准贷记卡标识；原始数据格式：1!n',
  `F090010` char(1) DEFAULT NULL COMMENT '个人卡标识；原始数据格式：1!n',
  `F090011` char(1) DEFAULT NULL COMMENT '员工卡标识；原始数据格式：1!n',
  `F090012` varchar(40) DEFAULT NULL COMMENT '主卡号；原始数据格式：n..40',
  `F090013` char(1) DEFAULT NULL COMMENT '附属卡标识；原始数据格式：1!n',
  `F090014` char(1) DEFAULT NULL COMMENT '年费标识；原始数据格式：1!n',
  `F090015` char(1) DEFAULT NULL COMMENT '快捷支付标识；原始数据格式：1!n',
  `F090016` char(1) DEFAULT NULL COMMENT '网络支付标识；原始数据格式：1!n',
  `F090017` varchar(60) DEFAULT NULL COMMENT '主要担保方式；原始数据格式：anc..60',
  `F090018` varchar(255) DEFAULT NULL COMMENT '总授信额度上限；原始数据格式：20n(2)',
  `F090019` varchar(255) DEFAULT NULL COMMENT '本币信用额度；原始数据格式：20n(2)',
  `F090020` varchar(255) DEFAULT NULL COMMENT '外币信用额度；原始数据格式：20n(2)',
  `F090021` char(3) DEFAULT NULL COMMENT '外币币种；原始数据格式：3!a',
  `F090024` date DEFAULT NULL COMMENT '受理日期；原始数据格式：YYYY-MM-DD',
  `F090025` decimal(2,0) DEFAULT NULL COMMENT '交易账单日期；原始数据格式：n..2',
  `F090026` decimal(3,0) DEFAULT NULL COMMENT '最迟还款天数；原始数据格式：n..3',
  `F090027` date DEFAULT NULL COMMENT '开卡日期；原始数据格式：YYYY-MM-DD',
  `F090028` varchar(32) DEFAULT NULL COMMENT '开卡经办员工ID；原始数据格式：anc..32',
  `F090029` varchar(30) DEFAULT NULL COMMENT '卡状态；原始数据格式：anc..30',
  `F090030` varchar(60) DEFAULT NULL COMMENT '异常标识；原始数据格式：anc..60',
  `F090031` varchar(60) DEFAULT NULL COMMENT '限制措施；原始数据格式：anc..60',
  `F090032` date DEFAULT NULL COMMENT '销卡日期；原始数据格式：YYYY-MM-DD',
  `F090033` varchar(32) DEFAULT NULL COMMENT '销卡经办员工ID；原始数据格式：anc..32',
  `F090034` varchar(255) DEFAULT NULL COMMENT '卡片级别；原始数据格式：anc',
  `F090035` varchar(255) DEFAULT NULL COMMENT '担保说明；原始数据格式：anc',
  `F090039` varchar(3000) DEFAULT NULL COMMENT '卡组织名称；原始数据格式：anc..3000',
  `F090040` date DEFAULT NULL COMMENT '最后交易日期；原始数据格式：YYYY-MM-DD',
  `F090041` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F090036` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F090001`, `F090002`, `F090003`, `F090007`, `F090036`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.9信用卡协议';
