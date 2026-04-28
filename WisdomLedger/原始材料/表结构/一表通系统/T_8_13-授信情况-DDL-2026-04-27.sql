-- =====================================================
-- 报表：8.13授信情况
-- 表名：T_8_13
-- 字段数：29
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_13`;
CREATE TABLE `T_8_13` (
  `H130001` varchar(64) NOT NULL COMMENT '授信ID；原始数据格式：anc..64',
  `H130002` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `H130003` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H130028` varchar(64) DEFAULT NULL COMMENT '占用集团授信ID；原始数据格式：anc..64',
  `H130005` varchar(60) DEFAULT NULL COMMENT '客户类别；原始数据格式：anc..60',
  `H130006` varchar(60) DEFAULT NULL COMMENT '授信种类；原始数据格式：anc..60',
  `H130007` char(3) DEFAULT NULL COMMENT '授信币种；原始数据格式：3!a',
  `H130008` varchar(255) DEFAULT NULL COMMENT '授信额度；原始数据格式：20n(2)',
  `H130024` varchar(255) DEFAULT NULL COMMENT '授信敞口额度；原始数据格式：20n(2)',
  `H130025` varchar(255) DEFAULT NULL COMMENT '单户授信总额；原始数据格式：20n(2)',
  `H130029` varchar(255) DEFAULT NULL COMMENT '个人客户经营性贷款授信总额；原始数据格式：20n(2)',
  `H130009` varchar(255) DEFAULT NULL COMMENT '非保本理财产品授信额度；原始数据格式：20n(2)',
  `H130010` date DEFAULT NULL COMMENT '额度申请日期；原始数据格式：YYYY-MM-DD',
  `H130011` date DEFAULT NULL COMMENT '授信起始日期；原始数据格式：YYYY-MM-DD',
  `H130012` date DEFAULT NULL COMMENT '授信到期日期；原始数据格式：YYYY-MM-DD',
  `H130013` varchar(255) DEFAULT NULL COMMENT '持有债券余额；原始数据格式：20n(2)',
  `H130014` varchar(255) DEFAULT NULL COMMENT '持有股权余额；原始数据格式：20n(2)',
  `H130015` varchar(255) DEFAULT NULL COMMENT '已用额度；原始数据格式：20n(2)',
  `H130017` varchar(255) DEFAULT NULL COMMENT '不考虑风险缓释季末风险暴露金额；原始数据格式：20n(2)',
  `H130018` varchar(255) DEFAULT NULL COMMENT '考虑风险缓释季末风险暴露金额；原始数据格式：20n(2)',
  `H130019` varchar(255) DEFAULT NULL COMMENT '授信审批意见；原始数据格式：anc',
  `H130020` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `H130021` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `H130022` char(1) DEFAULT NULL COMMENT '授信状态；原始数据格式：1!n',
  `H130026` varchar(450) DEFAULT NULL COMMENT '授信协议名称；原始数据格式：anc..450',
  `H130031` varchar(255) DEFAULT NULL COMMENT '贷款授信额度；原始数据格式：20n(2)',
  `H130032` date DEFAULT NULL COMMENT '授信失效日期；原始数据格式：YYYY-MM-DD',
  `H130033` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H130023` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H130001`, `H130003`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.13授信情况';
