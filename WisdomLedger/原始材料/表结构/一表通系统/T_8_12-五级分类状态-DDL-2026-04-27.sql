-- =====================================================
-- 报表：8.12五级分类状态
-- 表名：T_8_12
-- 字段数：15
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_12`;
CREATE TABLE `T_8_12` (
  `H120001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `H120002` varchar(100) NOT NULL COMMENT '细分资产ID；原始数据格式：anc..100',
  `H120003` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H120004` date DEFAULT NULL COMMENT '调整日期；原始数据格式：YYYY-MM-DD',
  `H120005` char(2) NOT NULL COMMENT '当前五级分类；原始数据格式：2!n',
  `H120006` char(2) DEFAULT NULL COMMENT '原五级分类；原始数据格式：2!n',
  `H120007` char(2) DEFAULT NULL COMMENT '变动方式；原始数据格式：2!n',
  `H120008` varchar(255) DEFAULT NULL COMMENT '变动原因；原始数据格式：anc',
  `H120014` varchar(255) DEFAULT NULL COMMENT '减值准备；原始数据格式：20n(2)',
  `H120009` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `H120010` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `H120011` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `H120012` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `H120015` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H120013` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H120001`, `H120002`, `H120003`, `H120005`, `H120013`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.12五级分类状态';
