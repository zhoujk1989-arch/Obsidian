-- =====================================================
-- 报表：8.9融资情况
-- 表名：T_8_9
-- 字段数：25
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_9`;
CREATE TABLE `T_8_9` (
  `H090001` varchar(60) NOT NULL COMMENT '融资业务ID；原始数据格式：anc..60',
  `H090020` varchar(60) NOT NULL COMMENT '融资标的ID；原始数据格式：anc..60',
  `H090002` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `H090011` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `H090017` varchar(24) DEFAULT NULL COMMENT '同业ID；原始数据格式：anc..24',
  `H090003` varchar(60) DEFAULT NULL COMMENT '融资工具类型；原始数据格式：anc..60',
  `H090004` varchar(60) DEFAULT NULL COMMENT '融资工具子类型；原始数据格式：anc..60',
  `H090012` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `H090013` varchar(60) DEFAULT NULL COMMENT '成本类型；原始数据格式：anc..60',
  `H090014` varchar(255) DEFAULT NULL COMMENT '成本总额；原始数据格式：20n(2)',
  `H090005` varchar(255) DEFAULT NULL COMMENT '合同金额；原始数据格式：20n(2)',
  `H090006` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `H090007` varchar(255) DEFAULT NULL COMMENT '融资余额；原始数据格式：20n(2)',
  `H090008` varchar(255) DEFAULT NULL COMMENT '合同执行利率；原始数据格式：20n(6)',
  `H090021` varchar(300) DEFAULT NULL COMMENT '发行国家地区；原始数据格式：anc..300',
  `H090009` varchar(600) DEFAULT NULL COMMENT '担保协议ID；原始数据格式：an..600',
  `H090018` varchar(255) DEFAULT NULL COMMENT '股权托管比例；原始数据格式：20n(6)',
  `H090019` varchar(255) DEFAULT NULL COMMENT '托管机构名称；原始数据格式：anc',
  `H090015` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `H090016` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `H090023` varchar(255) DEFAULT NULL COMMENT '本期收益；原始数据格式：20n(2)',
  `H090024` varchar(255) DEFAULT NULL COMMENT '累计收益；原始数据格式：20n(2)',
  `H090025` date DEFAULT NULL COMMENT '失效日期；原始数据格式：YYYY-MM-DD',
  `H090022` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `H090010` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H090001`, `H090020`, `H090010`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.9融资情况';
