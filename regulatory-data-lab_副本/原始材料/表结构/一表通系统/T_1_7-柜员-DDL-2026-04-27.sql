-- =====================================================
-- 报表：1.7柜员
-- 表名：T_1_7
-- 字段数：12
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_1_7`;
CREATE TABLE `T_1_7` (
  `A070001` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `A070002` varchar(30) DEFAULT NULL COMMENT '柜员号；原始数据格式：anc..30',
  `A070003` varchar(70) DEFAULT NULL COMMENT '员工ID；原始数据格式：anc..70',
  `A070004` varchar(30) DEFAULT NULL COMMENT '柜员类型；原始数据格式：anc..30',
  `A070012` char(1) DEFAULT NULL COMMENT '是否实体柜员；原始数据格式：1!n',
  `A070005` varchar(100) DEFAULT NULL COMMENT '岗位编号；原始数据格式：an..100',
  `A070006` varchar(60) DEFAULT NULL COMMENT '柜员权限级别；原始数据格式：anc..60',
  `A070007` date DEFAULT NULL COMMENT '上岗日期；原始数据格式：YYYY-MM-DD',
  `A070008` varchar(60) DEFAULT NULL COMMENT '柜员状态；原始数据格式：anc..60',
  `A070009` date DEFAULT NULL COMMENT '失效日期；原始数据格式：YYYY-MM-DD',
  `A070010` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `A070011` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='1.7柜员';
