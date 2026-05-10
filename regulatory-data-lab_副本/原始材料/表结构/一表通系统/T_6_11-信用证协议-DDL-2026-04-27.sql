-- =====================================================
-- 报表：6.11信用证协议
-- 表名：T_6_11
-- 字段数：40
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_11`;
CREATE TABLE `T_6_11` (
  `F110001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F110002` varchar(100) NOT NULL COMMENT '业务号码；原始数据格式：an..100',
  `F110003` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F110004` varchar(60) DEFAULT NULL COMMENT '客户ID；原始数据格式：anc..60',
  `F110005` varchar(32) NOT NULL COMMENT '产品ID；原始数据格式：anc..32',
  `F110040` varchar(64) DEFAULT NULL COMMENT '授信ID；原始数据格式：anc..64',
  `F110006` char(2) DEFAULT NULL COMMENT '信用证种类；原始数据格式：2!n',
  `F110007` varchar(60) DEFAULT NULL COMMENT '信用证ID；原始数据格式：anc..60',
  `F110008` char(3) NOT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F110009` varchar(255) DEFAULT NULL COMMENT '开证金额；原始数据格式：20n(2)',
  `F110010` date DEFAULT NULL COMMENT '开证日期；原始数据格式：YYYY-MM-DD',
  `F110011` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F110012` varchar(60) DEFAULT NULL COMMENT '支付类型；原始数据格式：anc..60',
  `F110013` decimal(8,0) DEFAULT NULL COMMENT '远期天数；原始数据格式：n..8',
  `F110014` varchar(255) DEFAULT NULL COMMENT '垫款利率；原始数据格式：20n(6)',
  `F110015` varchar(255) DEFAULT NULL COMMENT '贸易合同编号；原始数据格式：anc',
  `F110016` varchar(255) DEFAULT NULL COMMENT '货品名称；原始数据格式：anc',
  `F110017` varchar(255) DEFAULT NULL COMMENT '贸易合同金额；原始数据格式：20n(2)',
  `F110018` varchar(255) DEFAULT NULL COMMENT '合同贸易背景；原始数据格式：anc',
  `F110019` char(3) DEFAULT NULL COMMENT '申请人国家代码；原始数据格式：3!a',
  `F110020` varchar(200) DEFAULT NULL COMMENT '受益人名称；原始数据格式：anc..200',
  `F110021` char(3) DEFAULT NULL COMMENT '受益人国家地区；原始数据格式：3!a',
  `F110022` varchar(255) DEFAULT NULL COMMENT '受益人开户行名称；原始数据格式：anc',
  `F110023` char(3) DEFAULT NULL COMMENT '重点产业标识；原始数据格式：3!n',
  `F110024` char(1) DEFAULT NULL COMMENT '代开信用证标识；原始数据格式：1!n',
  `F110025` varchar(255) DEFAULT NULL COMMENT '代开信用证的申请行的行名；原始数据格式：anc',
  `F110026` decimal(8,0) DEFAULT NULL COMMENT '支付期限；原始数据格式：n..8',
  `F110027` char(3) DEFAULT NULL COMMENT '手续费币种；原始数据格式：3!a',
  `F110028` varchar(255) DEFAULT NULL COMMENT '手续费金额；原始数据格式：20n(2)',
  `F110029` varchar(255) DEFAULT NULL COMMENT '保证金账号；原始数据格式：anc',
  `F110030` char(3) DEFAULT NULL COMMENT '保证金币种；原始数据格式：3!a',
  `F110031` varchar(255) DEFAULT NULL COMMENT '保证金金额；原始数据格式：20n(2)',
  `F110032` varchar(255) DEFAULT NULL COMMENT '保证金比例；原始数据格式：20n(6)',
  `F110033` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F110034` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F110035` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F110036` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F110037` varchar(255) DEFAULT NULL COMMENT '受益人开户行账号；原始数据格式：anc',
  `F110039` char(6) DEFAULT NULL COMMENT '绿色融资类型；原始数据格式：6!n',
  `F110038` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F110001`, `F110002`, `F110005`, `F110008`, `F110038`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.11信用证协议';
