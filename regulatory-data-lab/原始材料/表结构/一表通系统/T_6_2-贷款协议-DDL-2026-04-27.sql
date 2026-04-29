-- =====================================================
-- 报表：6.2贷款协议
-- 表名：T_6_2
-- 字段数：19
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_2`;
CREATE TABLE `T_6_2` (
  `F020001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F020002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F020003` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `F020005` varchar(255) DEFAULT NULL COMMENT '合同名称；原始数据格式：anc',
  `F020007` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F020008` varchar(255) DEFAULT NULL COMMENT '贷款金额；原始数据格式：20n(2)',
  `F020010` varchar(255) DEFAULT NULL COMMENT '贷款用途；原始数据格式：anc',
  `F020048` date DEFAULT NULL COMMENT '贷款协议起始日期；原始数据格式：YYYY-MM-DD',
  `F020049` date DEFAULT NULL COMMENT '贷款协议到期日期；原始数据格式：YYYY-MM-DD',
  `F020057` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F020058` varchar(300) DEFAULT NULL COMMENT '管户员工ID；原始数据格式：anc..300',
  `F020059` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F020060` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F020061` varchar(30) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..30',
  `F020064` varchar(64) DEFAULT NULL COMMENT '授信ID；原始数据格式：anc..64',
  `F020065` varchar(60) DEFAULT NULL COMMENT '担保方式；原始数据格式：anc..60',
  `F020066` varchar(150) DEFAULT NULL COMMENT '信贷业务种类；原始数据格式：anc..150',
  `F020062` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F020063` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F020001`, `F020002`, `F020063`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.2贷款协议';
