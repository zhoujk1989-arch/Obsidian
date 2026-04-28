-- =====================================================
-- 报表：6.24贷款承诺
-- 表名：T_6_24
-- 字段数：26
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_24`;
CREATE TABLE `T_6_24` (
  `F240001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F240002` varchar(100) NOT NULL COMMENT '业务号码；原始数据格式：anc..100',
  `F240003` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F240004` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `F240019` varchar(64) DEFAULT NULL COMMENT '授信ID；原始数据格式：anc..64',
  `F240005` varchar(255) DEFAULT NULL COMMENT '业务额度；原始数据格式：20n(2)',
  `F240006` char(3) DEFAULT NULL COMMENT '币种；原始数据格式：3!a',
  `F240007` char(4) DEFAULT NULL COMMENT '承诺类型；原始数据格式：4!n',
  `F240008` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `F240009` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `F240010` varchar(255) DEFAULT NULL COMMENT '未使用的额度；原始数据格式：20n(2)',
  `F240011` date DEFAULT NULL COMMENT '起始日期；原始数据格式：YYYY-MM-DD',
  `F240012` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F240013` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F240014` char(3) DEFAULT NULL COMMENT '重点产业标识；原始数据格式：3!n',
  `F240015` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F240016` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F240017` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F240020` char(3) DEFAULT NULL COMMENT '手续费币种；原始数据格式：3!a',
  `F240021` varchar(255) DEFAULT NULL COMMENT '手续费金额；原始数据格式：20n(2)',
  `F240022` char(3) DEFAULT NULL COMMENT '保证金币种；原始数据格式：3!a',
  `F240023` varchar(255) DEFAULT NULL COMMENT '保证金金额；原始数据格式：20n(2)',
  `F240024` varchar(255) DEFAULT NULL COMMENT '保证金比例；原始数据格式：20n(6)',
  `F240026` varchar(255) DEFAULT NULL COMMENT '合同贸易背景；原始数据格式：anc',
  `F240025` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F240018` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F240001`, `F240002`, `F240018`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.24贷款承诺';
