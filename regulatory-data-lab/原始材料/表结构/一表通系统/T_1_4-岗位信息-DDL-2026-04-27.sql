-- =====================================================
-- 报表：1.4岗位信息
-- 表名：T_1_4
-- 字段数：10
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_1_4`;
CREATE TABLE `T_1_4` (
  `A040001` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `A040002` varchar(100) NOT NULL COMMENT '岗位编号；原始数据格式：an..100',
  `A040003` varchar(255) DEFAULT NULL COMMENT '岗位种类；原始数据格式：anc',
  `A040004` varchar(100) DEFAULT NULL COMMENT '岗位名称；原始数据格式：anc..100',
  `A040005` varchar(255) DEFAULT NULL COMMENT '岗位说明；原始数据格式：anc',
  `A040006` varchar(255) DEFAULT NULL COMMENT '岗位状态；原始数据格式：anc',
  `A040009` char(2) DEFAULT NULL COMMENT '是否柜员标识；原始数据格式：2!n',
  `A040010` date DEFAULT NULL COMMENT '岗位撤销日期；原始数据格式：YYYY-MM-DD',
  `A040007` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `A040008` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`A040001`, `A040002`, `A040008`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='1.4岗位信息';
