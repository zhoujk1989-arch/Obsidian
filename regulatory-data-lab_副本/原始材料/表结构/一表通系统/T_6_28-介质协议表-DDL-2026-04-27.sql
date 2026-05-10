-- =====================================================
-- 报表：6.28介质协议表
-- 表名：T_6_28
-- 字段数：14
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_28`;
CREATE TABLE `T_6_28` (
  `F280001` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F280002` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `F280003` varchar(255) DEFAULT NULL COMMENT '分户账号；原始数据格式：an',
  `F280004` varchar(60) DEFAULT NULL COMMENT '卡产品ID；原始数据格式：anc..60',
  `F280005` varchar(255) DEFAULT NULL COMMENT '介质号；原始数据格式：an',
  `F280006` varchar(30) DEFAULT NULL COMMENT '介质类型；原始数据格式：anc..30',
  `F280007` char(1) DEFAULT NULL COMMENT '虚拟卡标识；原始数据格式：1!n',
  `F280008` char(1) DEFAULT NULL COMMENT '员工标志；原始数据格式：1!n',
  `F280009` date DEFAULT NULL COMMENT '介质启用日期；原始数据格式：YYYY-MM-DD',
  `F280010` date DEFAULT NULL COMMENT '介质失效日期；原始数据格式：YYYY-MM-DD',
  `F280011` varchar(32) DEFAULT NULL COMMENT '介质启用柜员ID；原始数据格式：anc..32',
  `F280012` varchar(30) DEFAULT NULL COMMENT '介质状态；原始数据格式：anc..30',
  `F280013` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F280014` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.28介质协议表';
