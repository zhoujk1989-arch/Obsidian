-- =====================================================
-- 报表：8.8投资情况
-- 表名：T_8_8
-- 字段数：32
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_8`;
CREATE TABLE `T_8_8` (
  `H080001` varchar(60) NOT NULL COMMENT '投资标的ID；原始数据格式：anc..60',
  `H080002` varchar(255) DEFAULT NULL COMMENT '投资产品名称；原始数据格式：anc',
  `H080003` varchar(24) NOT NULL COMMENT '交易机构ID；原始数据格式：anc..24',
  `H080004` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `H080005` varchar(255) DEFAULT NULL COMMENT '交易账号；原始数据格式：anc',
  `H080006` char(2) DEFAULT NULL COMMENT '账户类型；原始数据格式：2!n',
  `H080007` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `H080008` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `H080009` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `H080010` char(2) DEFAULT NULL COMMENT '投资管理方式；原始数据格式：2!n',
  `H080011` varchar(255) DEFAULT NULL COMMENT '投资余额；原始数据格式：20n(2)',
  `H080012` char(3) DEFAULT NULL COMMENT '投资标的币种；原始数据格式：3!a',
  `H080013` varchar(255) DEFAULT NULL COMMENT '本期投资收益；原始数据格式：20n(2)',
  `H080014` varchar(255) DEFAULT NULL COMMENT '累计投资收益；原始数据格式：20n(2)',
  `H080015` varchar(255) DEFAULT NULL COMMENT '持有成本；原始数据格式：20n(2)',
  `H080016` varchar(600) DEFAULT NULL COMMENT '担保协议ID；原始数据格式：anc..600',
  `H080018` char(2) DEFAULT NULL COMMENT '自营业务大类；原始数据格式：2!n',
  `H080019` varchar(60) DEFAULT NULL COMMENT '自营业务小类；原始数据格式：anc..60',
  `H080020` varchar(255) DEFAULT NULL COMMENT '基础资产逾期金额；原始数据格式：20n(2)',
  `H080021` varchar(60) DEFAULT NULL COMMENT '资产会计计量方式类别；原始数据格式：anc..60',
  `H080022` varchar(255) DEFAULT NULL COMMENT '持有非底层资产产生的间接负债余额；原始数据格式：20n(2)',
  `H080023` char(6) DEFAULT NULL COMMENT '绿色融资类型；原始数据格式：6!n',
  `H080024` varchar(255) DEFAULT NULL COMMENT '到期收益率；原始数据格式：20n(6)',
  `H080025` char(1) DEFAULT NULL COMMENT '科技创新债券标识；原始数据格式：1!n',
  `H080026` char(1) DEFAULT NULL COMMENT '绿色债券标识；原始数据格式：1!n',
  `H080027` char(1) DEFAULT NULL COMMENT '普惠债券标识；原始数据格式：1!n',
  `H080028` char(1) DEFAULT NULL COMMENT '养老产业债券标识；原始数据格式：1!n',
  `H080029` char(2) DEFAULT NULL COMMENT '数字经济核心产业债券类型；原始数据格式：2!n',
  `H080032` varchar(255) DEFAULT NULL COMMENT '修正久期；原始数据格式：20n(4)',
  `H080030` date DEFAULT NULL COMMENT '失效日期；原始数据格式：YYYY-MM-DD',
  `H080031` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H080017` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H080001`, `H080003`, `H080004`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.8投资情况';
