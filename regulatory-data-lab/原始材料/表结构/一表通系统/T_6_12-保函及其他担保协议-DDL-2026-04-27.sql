-- =====================================================
-- 报表：6.12保函及其他担保协议
-- 表名：T_6_12
-- 字段数：33
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_12`;
CREATE TABLE `T_6_12` (
  `F120001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F120002` varchar(100) NOT NULL COMMENT '业务号码；原始数据格式：an..100',
  `F120003` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F120004` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `F120005` varchar(60) DEFAULT NULL COMMENT '保函类型；原始数据格式：anc..60',
  `F120033` varchar(64) DEFAULT NULL COMMENT '授信ID；原始数据格式：anc..64',
  `F120006` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `F120007` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `F120009` varchar(255) DEFAULT NULL COMMENT '协议金额；原始数据格式：20n(2)',
  `F120010` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F120011` varchar(255) DEFAULT NULL COMMENT '合同贸易背景；原始数据格式：anc',
  `F120032` varchar(60) DEFAULT NULL COMMENT '业务类型；原始数据格式：anc..60',
  `F120012` char(3) DEFAULT NULL COMMENT '重点产业标识；原始数据格式：3!n',
  `F120013` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `F120014` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F120015` varchar(255) DEFAULT NULL COMMENT '保证金账号；原始数据格式：anc',
  `F120016` char(3) DEFAULT NULL COMMENT '保证金币种；原始数据格式：3!a',
  `F120017` varchar(255) DEFAULT NULL COMMENT '保证金金额；原始数据格式：20n(2)',
  `F120018` varchar(255) DEFAULT NULL COMMENT '保证金比例；原始数据格式：20n(6)',
  `F120019` varchar(255) DEFAULT NULL COMMENT '手续费金额；原始数据格式：20n(2)',
  `F120020` char(3) DEFAULT NULL COMMENT '手续费币种；原始数据格式：3!a',
  `F120021` varchar(200) DEFAULT NULL COMMENT '受益人名称；原始数据格式：anc..200',
  `F120022` char(3) DEFAULT NULL COMMENT '受益人国家地区；原始数据格式：3!a',
  `F120030` varchar(255) DEFAULT NULL COMMENT '受益人开户行账号；原始数据格式：anc',
  `F120031` varchar(255) DEFAULT NULL COMMENT '受益人开户行名称；原始数据格式：anc',
  `F120023` varchar(255) DEFAULT NULL COMMENT '待支付金额；原始数据格式：20n(2)',
  `F120024` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F120025` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F120026` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F120029` varchar(60) DEFAULT NULL COMMENT '担保协议状态；原始数据格式：anc..60',
  `F120027` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F120034` varchar(255) DEFAULT NULL COMMENT '已兑付金额；原始数据格式：20n(2)',
  `F120028` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F120001`, `F120002`, `F120003`, `F120028`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.12保函及其他担保协议';
