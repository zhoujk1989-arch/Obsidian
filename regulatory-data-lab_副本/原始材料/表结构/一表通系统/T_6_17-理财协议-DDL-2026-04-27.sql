-- =====================================================
-- 报表：6.17理财协议
-- 表名：T_6_17
-- 字段数：28
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_17`;
CREATE TABLE `T_6_17` (
  `F170001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F170002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F170003` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `F170004` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `F170005` char(2) DEFAULT NULL COMMENT '客户类型；原始数据格式：2!n',
  `F170026` varchar(200) DEFAULT NULL COMMENT '客户姓名；原始数据格式：anc..200',
  `F170027` char(2) DEFAULT NULL COMMENT '客户证件类别；原始数据格式：2!n',
  `F170028` varchar(100) DEFAULT NULL COMMENT '证件号码；原始数据格式：anc..100',
  `F170006` char(2) DEFAULT NULL COMMENT '客户风险偏好评估结果；原始数据格式：2!n',
  `F170007` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `F170008` time DEFAULT NULL COMMENT '生效时间；原始数据格式：HH:MM:SS',
  `F170009` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F170010` varchar(255) DEFAULT NULL COMMENT '协议金额；原始数据格式：20n(2)',
  `F170011` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F170012` varchar(255) DEFAULT NULL COMMENT '协议份额；原始数据格式：20n(2)',
  `F170013` char(2) DEFAULT NULL COMMENT '销售渠道；原始数据格式：2!n',
  `F170014` char(2) DEFAULT NULL COMMENT '业务类型；原始数据格式：2!n',
  `F170015` varchar(24) DEFAULT NULL COMMENT '代销机构代码；原始数据格式：anc..24',
  `F170016` varchar(255) DEFAULT NULL COMMENT '代销机构名称；原始数据格式：anc',
  `F170017` char(2) DEFAULT NULL COMMENT '代销机构所属监管机构；原始数据格式：2!n',
  `F170018` varchar(255) DEFAULT NULL COMMENT '关联存款账号；原始数据格式：an',
  `F170019` varchar(255) DEFAULT NULL COMMENT '关联存款账号开户行名称；原始数据格式：anc',
  `F170020` char(2) DEFAULT NULL COMMENT '关联存款账号开户所在地；原始数据格式：2!n',
  `F170021` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F170022` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F170023` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F170024` varchar(255) DEFAULT NULL COMMENT '手续费金额；原始数据格式：20n(2)',
  `F170025` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F170001`, `F170002`, `F170025`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.17理财协议';
