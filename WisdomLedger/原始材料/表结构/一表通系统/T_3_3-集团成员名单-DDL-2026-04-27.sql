-- =====================================================
-- 报表：3.3集团成员名单
-- 表名：T_3_3
-- 字段数：14
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_3_3`;
CREATE TABLE `T_3_3` (
  `C030001` varchar(64) NOT NULL COMMENT '关系ID；原始数据格式：anc..64',
  `C030002` varchar(60) DEFAULT NULL COMMENT '成员ID；原始数据格式：anc..60',
  `C030003` varchar(255) DEFAULT NULL COMMENT '成员企业名称；原始数据格式：anc',
  `C030004` varchar(18) DEFAULT NULL COMMENT '成员统一社会信用代码；原始数据格式：an..18',
  `C030005` char(2) DEFAULT NULL COMMENT '成员类型；原始数据格式：2!n',
  `C030006` varchar(100) DEFAULT NULL COMMENT '登记注册代码；原始数据格式：anc..100',
  `C030007` varchar(60) DEFAULT NULL COMMENT '集团ID；原始数据格式：anc..60',
  `C030008` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `C030009` date DEFAULT NULL COMMENT '关系失效日期；原始数据格式：YYYY-MM-DD',
  `C030011` char(1) DEFAULT NULL COMMENT '母公司标识；原始数据格式：1!n',
  `C030013` varchar(30) DEFAULT NULL COMMENT '关联人类别；原始数据格式：anc..30',
  `C030014` varchar(255) DEFAULT NULL COMMENT '授信敞口已用额度；原始数据格式：20n(2)',
  `C030012` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `C030010` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`C030001`, `C030008`, `C030010`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='3.3集团成员名单';
