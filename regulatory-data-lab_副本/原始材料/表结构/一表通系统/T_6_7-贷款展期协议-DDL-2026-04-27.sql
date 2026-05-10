-- =====================================================
-- 报表：6.7贷款展期协议
-- 表名：T_6_7
-- 字段数：11
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_7`;
CREATE TABLE `T_6_7` (
  `F070001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F070002` varchar(100) NOT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `F070010` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F070003` decimal(8,0) DEFAULT NULL COMMENT '展期次数；原始数据格式：n..8',
  `F070004` varchar(255) DEFAULT NULL COMMENT '被展期贷款的贷款协议号；原始数据格式：anc',
  `F070005` date DEFAULT NULL COMMENT '展期贷款的到期日期；原始数据格式：YYYY-MM-DD',
  `F070006` varchar(255) DEFAULT NULL COMMENT '展期贷款的贷款金额；原始数据格式：20n(2)',
  `F070007` varchar(255) DEFAULT NULL COMMENT '展期贷款的贷款用途；原始数据格式：anc',
  `F070008` varchar(255) DEFAULT NULL COMMENT '展期贷款的贷款利率；原始数据格式：20n(6)',
  `F070011` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F070009` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F070001`, `F070002`, `F070010`, `F070009`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.7贷款展期协议';
