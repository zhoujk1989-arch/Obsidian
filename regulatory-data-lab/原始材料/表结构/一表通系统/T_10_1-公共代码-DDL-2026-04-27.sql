-- =====================================================
-- 报表：10.1公共代码
-- 表名：T_10_1
-- 字段数：6
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_10_1`;
CREATE TABLE `T_10_1` (
  `K010001` char(8) DEFAULT NULL COMMENT '参数ID；原始数据格式：8!n',
  `K010002` varchar(255) DEFAULT NULL COMMENT '表名；原始数据格式：anc',
  `K010003` varchar(255) DEFAULT NULL COMMENT '字段名；原始数据格式：anc',
  `K010004` varchar(255) DEFAULT NULL COMMENT '代码；原始数据格式：an',
  `K010005` varchar(255) DEFAULT NULL COMMENT '中文含义；原始数据格式：anc',
  `K010006` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='10.1公共代码';
