-- =====================================================
-- 报表：6.8担保协议
-- 表名：T_6_8
-- 字段数：29
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_8`;
CREATE TABLE `T_6_8` (
  `F080001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F080002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F080003` varchar(60) NOT NULL COMMENT '被担保协议ID；原始数据格式：anc..60',
  `F080004` varchar(60) DEFAULT NULL COMMENT '担保类型；原始数据格式：anc..60',
  `F080005` char(2) DEFAULT NULL COMMENT '担保合同方向；原始数据格式：2!n',
  `F080006` varchar(30) DEFAULT NULL COMMENT '被担保业务类型；原始数据格式：anc..30',
  `F080007` char(2) DEFAULT NULL COMMENT '担保合同类型；原始数据格式：2!n',
  `F080008` varchar(60) DEFAULT NULL COMMENT '担保人类别；原始数据格式：anc..60',
  `F080009` varchar(200) NOT NULL COMMENT '担保人名称；原始数据格式：anc..200',
  `F080010` varchar(60) DEFAULT NULL COMMENT '担保人证件类型；原始数据格式：anc..60',
  `F080011` varchar(100) NOT NULL COMMENT '担保人证件号码；原始数据格式：anc..100',
  `F080026` char(2) DEFAULT NULL COMMENT '担保人类型；原始数据格式：2!n',
  `F080027` varchar(255) DEFAULT NULL COMMENT '担保人担保能力上限；原始数据格式：20n(2)',
  `F080012` date DEFAULT NULL COMMENT '签约日期；原始数据格式：YYYY-MM-DD',
  `F080013` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `F080014` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F080015` varchar(255) DEFAULT NULL COMMENT '协议金额；原始数据格式：20n(2)',
  `F080016` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F080017` char(3) DEFAULT NULL COMMENT '担保人净资产币种；原始数据格式：3!a',
  `F080018` varchar(255) DEFAULT NULL COMMENT '担保人净资产；原始数据格式：20n(2)',
  `F080019` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F080020` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F080021` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F080022` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F080023` char(1) DEFAULT NULL COMMENT '或有负债标识；原始数据格式：1!n',
  `F080028` varchar(60) DEFAULT NULL COMMENT '担保人客户ID；原始数据格式：anc..60',
  `F080029` varchar(60) DEFAULT NULL COMMENT '担保人分类；原始数据格式：anc..60',
  `F080024` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F080025` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F080001`, `F080002`, `F080003`, `F080009`, `F080011`, `F080025`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.8担保协议';
