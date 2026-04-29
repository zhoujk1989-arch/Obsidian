-- =====================================================
-- 报表：4.2科目信息
-- 表名：T_4_2
-- 字段数：11
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_4_2`;
CREATE TABLE `T_4_2` (
  `D020001` varchar(32) NOT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `D020002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `D020003` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `D020004` char(2) DEFAULT NULL COMMENT '科目级次；原始数据格式：2!n',
  `D020005` char(2) DEFAULT NULL COMMENT '科目类型；原始数据格式：2!n',
  `D020006` char(2) DEFAULT NULL COMMENT '借贷标识；原始数据格式：2!n',
  `D020007` varchar(300) DEFAULT NULL COMMENT '归属业务子类；原始数据格式：anc..300',
  `D020008` varchar(32) DEFAULT NULL COMMENT '上级科目ID；原始数据格式：anc..32',
  `D020009` char(1) DEFAULT NULL COMMENT '分户账标识；原始数据格式：1!n',
  `D020010` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `D020011` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`D020001`, `D020002`, `D020011`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='4.2科目信息';
