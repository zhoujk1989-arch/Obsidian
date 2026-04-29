-- =====================================================
-- 报表：9.3抵质押品
-- 表名：T_9_3
-- 字段数：36
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_9_3`;
CREATE TABLE `T_9_3` (
  `J030001` varchar(60) NOT NULL COMMENT '押品ID；原始数据格式：anc..60',
  `J030002` varchar(60) NOT NULL COMMENT '担保协议ID；原始数据格式：anc..60',
  `J030003` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `J030005` char(2) DEFAULT NULL COMMENT '抵质押物类型；原始数据格式：2!n',
  `J030006` varchar(255) DEFAULT NULL COMMENT '抵质押物名称；原始数据格式：anc',
  `J030007` char(2) DEFAULT NULL COMMENT '抵质押物状态；原始数据格式：2!n',
  `J030008` varchar(255) DEFAULT NULL COMMENT '起始估值；原始数据格式：20n(2)',
  `J030009` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `J030010` varchar(255) DEFAULT NULL COMMENT '最新估值；原始数据格式：20n(2)',
  `J030011` date DEFAULT NULL COMMENT '首次估值日期；原始数据格式：YYYY-MM-DD',
  `J030012` date DEFAULT NULL COMMENT '最新估值日期；原始数据格式：YYYY-MM-DD',
  `J030013` date DEFAULT NULL COMMENT '估值到期日期；原始数据格式：YYYY-MM-DD',
  `J030014` char(1) DEFAULT NULL COMMENT '对应唯一担保协议标识；原始数据格式：1!n',
  `J030015` char(1) DEFAULT NULL COMMENT '抵押顺位；原始数据格式：1!n',
  `J030016` varchar(200) DEFAULT NULL COMMENT '抵质押物所有权人名称；原始数据格式：anc..200',
  `J030017` char(4) DEFAULT NULL COMMENT '抵质押物所有权人证件类型；原始数据格式：4!n',
  `J030018` varchar(100) DEFAULT NULL COMMENT '抵质押物所有权人证件号码；原始数据格式：anc..100',
  `J030019` varchar(255) DEFAULT NULL COMMENT '已抵押价值；原始数据格式：20n(2)',
  `J030020` varchar(255) DEFAULT NULL COMMENT '审批抵质押率；原始数据格式：20n(6)',
  `J030021` varchar(255) DEFAULT NULL COMMENT '抵质押率；原始数据格式：20n(6)',
  `J030022` date DEFAULT NULL COMMENT '登记日期；原始数据格式：YYYY-MM-DD',
  `J030023` varchar(255) DEFAULT NULL COMMENT '登记机构；原始数据格式：anc',
  `J030024` char(2) DEFAULT NULL COMMENT '质押票证类型；原始数据格式：2!n',
  `J030025` varchar(255) DEFAULT NULL COMMENT '质押票证号码；原始数据格式：an',
  `J030026` varchar(255) DEFAULT NULL COMMENT '质押票证签发机构；原始数据格式：anc',
  `J030027` char(4) DEFAULT NULL COMMENT '权证种类；原始数据格式：4!n',
  `J030028` varchar(255) DEFAULT NULL COMMENT '权证登记号码；原始数据格式：an',
  `J030029` varchar(255) DEFAULT NULL COMMENT '权证登记面积；原始数据格式：20n(2)',
  `J030032` char(1) DEFAULT NULL COMMENT '触及预警线标识；原始数据格式：1!n',
  `J030033` char(1) DEFAULT NULL COMMENT '触及平仓线标识；原始数据格式：1!n',
  `J030034` char(2) DEFAULT NULL COMMENT '交易场所；原始数据格式：2!n',
  `J030035` varchar(255) DEFAULT NULL COMMENT '股票股数；原始数据格式：n',
  `J030036` varchar(255) DEFAULT NULL COMMENT '备注；原始数据格式：anc',
  `J030037` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  `J030038` varchar(24) DEFAULT NULL COMMENT '同业业务ID；原始数据格式：anc..24',
  `J030039` char(1) DEFAULT NULL COMMENT '是否保证金担保；原始数据格式：1!n',
  PRIMARY KEY (`J030001`, `J030002`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='9.3抵质押品';
