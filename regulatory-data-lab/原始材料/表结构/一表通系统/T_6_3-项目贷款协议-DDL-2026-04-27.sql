-- =====================================================
-- 报表：6.3项目贷款协议
-- 表名：T_6_3
-- 字段数：23
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_3`;
CREATE TABLE `T_6_3` (
  `F030001` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F030002` varchar(60) NOT NULL COMMENT '协议ID；原始数据格式：anc..60',
  `F030023` varchar(100) NOT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `F030003` varchar(60) DEFAULT NULL COMMENT '项目类型；原始数据格式：anc..60',
  `F030004` varchar(255) DEFAULT NULL COMMENT '项目名称；原始数据格式：anc',
  `F030005` varchar(255) DEFAULT NULL COMMENT '项目总投资；原始数据格式：20n(2)',
  `F030022` char(3) DEFAULT NULL COMMENT '项目总投资币种；原始数据格式：3!a',
  `F030006` varchar(255) DEFAULT NULL COMMENT '项目资本金；原始数据格式：20n(2)',
  `F030007` varchar(255) DEFAULT NULL COMMENT '批文文号；原始数据格式：anc',
  `F030008` varchar(255) DEFAULT NULL COMMENT '立项批文；原始数据格式：anc',
  `F030009` varchar(255) DEFAULT NULL COMMENT '土地使用证编号；原始数据格式：anc',
  `F030010` varchar(255) DEFAULT NULL COMMENT '土地使用证日期；原始数据格式：anc',
  `F030011` varchar(255) DEFAULT NULL COMMENT '用地规划许可证编号；原始数据格式：anc',
  `F030012` varchar(255) DEFAULT NULL COMMENT '用地规划许可证日期；原始数据格式：anc',
  `F030013` varchar(255) DEFAULT NULL COMMENT '施工许可证编号；原始数据格式：anc',
  `F030014` varchar(255) DEFAULT NULL COMMENT '施工许可证日期；原始数据格式：anc',
  `F030015` varchar(255) DEFAULT NULL COMMENT '工程规划许可证编号；原始数据格式：anc',
  `F030016` varchar(255) DEFAULT NULL COMMENT '工程规划许可证日期；原始数据格式：anc',
  `F030017` varchar(255) DEFAULT NULL COMMENT '其他许可证；原始数据格式：anc',
  `F030018` varchar(255) DEFAULT NULL COMMENT '其他许可证编号；原始数据格式：anc',
  `F030019` date DEFAULT NULL COMMENT '开工日期；原始数据格式：YYYY-MM-DD',
  `F030020` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F030021` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F030001`, `F030002`, `F030023`, `F030021`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.3项目贷款协议';
