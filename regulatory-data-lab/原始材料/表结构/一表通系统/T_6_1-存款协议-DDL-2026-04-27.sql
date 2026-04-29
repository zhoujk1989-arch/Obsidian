-- =====================================================
-- 报表：6.1存款协议
-- 表名：T_6_1
-- 字段数：32
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_1`;
CREATE TABLE `T_6_1` (
  `F010001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F010002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F010003` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `F010004` varchar(60) DEFAULT NULL COMMENT '客户类型；原始数据格式：anc..60',
  `F010005` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `F010006` varchar(32) DEFAULT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `F010007` varchar(255) DEFAULT NULL COMMENT '分户账号；原始数据格式：an',
  `F010008` varchar(60) DEFAULT NULL COMMENT '存款账户类型；原始数据格式：anc..60',
  `F010009` char(2) DEFAULT NULL COMMENT '提前支取标识；原始数据格式：2!n',
  `F010010` varchar(255) DEFAULT NULL COMMENT '提前支取罚息；原始数据格式：20n(2)',
  `F010011` char(1) DEFAULT NULL COMMENT '业务关系标识；原始数据格式：1!n',
  `F010012` char(1) DEFAULT NULL COMMENT '行为性期权标识；原始数据格式：1!n',
  `F010016` char(1) DEFAULT NULL COMMENT '保证金账户标识；原始数据格式：1!n',
  `F010017` varchar(255) DEFAULT NULL COMMENT '利率；原始数据格式：20n(6)',
  `F010018` varchar(60) DEFAULT NULL COMMENT '利率定价基础；原始数据格式：anc..60',
  `F010019` date DEFAULT NULL COMMENT '开户日期；原始数据格式：YYYY-MM-DD',
  `F010020` varchar(255) DEFAULT NULL COMMENT '开户金额；原始数据格式：20n(2)',
  `F010021` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F010022` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F010023` varchar(12) DEFAULT NULL COMMENT '钞汇类别；原始数据格式：anc..12',
  `F010024` date DEFAULT NULL COMMENT '销户日期；原始数据格式：YYYY-MM-DD',
  `F010026` varchar(60) DEFAULT NULL COMMENT '账户资金控制情况；原始数据格式：anc..60',
  `F010027` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F010028` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F010029` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F010030` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F010031` varchar(255) DEFAULT NULL COMMENT '管户员工ID；原始数据格式：anc.300',
  `F010048` varchar(60) DEFAULT NULL COMMENT '存款产品类别；原始数据格式：anc..60',
  `F010049` char(1) DEFAULT NULL COMMENT '社会保障基金存款标识；原始数据格式：1!n',
  `F010050` char(1) DEFAULT NULL COMMENT '特定养老储蓄存款标识；原始数据格式：1!n',
  `F010032` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F010035` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F010001`, `F010002`, `F010035`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.1存款协议';
