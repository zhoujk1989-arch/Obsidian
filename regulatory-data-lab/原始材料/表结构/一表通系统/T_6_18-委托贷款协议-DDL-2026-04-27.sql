-- =====================================================
-- 报表：6.18委托贷款协议
-- 表名：T_6_18
-- 字段数：28
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_18`;
CREATE TABLE `T_6_18` (
  `F180001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F180002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F180003` char(2) DEFAULT NULL COMMENT '委托贷款类型；原始数据格式：2!n',
  `F180004` varchar(60) DEFAULT NULL COMMENT '委托客户ID；原始数据格式：anc..60',
  `F180028` varchar(64) DEFAULT NULL COMMENT '授信ID；原始数据格式：anc..64',
  `F180005` varchar(255) DEFAULT NULL COMMENT '委托客户账号；原始数据格式：an',
  `F180006` varchar(255) DEFAULT NULL COMMENT '委托客户账号开户行名称；原始数据格式：anc',
  `F180007` varchar(255) DEFAULT NULL COMMENT '协议金额；原始数据格式：20n(2)',
  `F180008` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F180009` char(1) DEFAULT NULL COMMENT '收息标识；原始数据格式：1!n',
  `F180010` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `F180011` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F180012` varchar(100) NOT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `F180013` varchar(60) DEFAULT NULL COMMENT '借款人ID；原始数据格式：anc..60',
  `F180014` varchar(200) DEFAULT NULL COMMENT '借款人名称；原始数据格式：anc..200',
  `F180026` varchar(255) DEFAULT NULL COMMENT '借款人账号；原始数据格式：anc',
  `F180027` varchar(255) DEFAULT NULL COMMENT '借款人开户行名称；原始数据格式：anc',
  `F180015` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F180016` varchar(32) DEFAULT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `F180017` varchar(255) DEFAULT NULL COMMENT '科目名称；原始数据格式：anc',
  `F180018` char(3) DEFAULT NULL COMMENT '重点产业标识；原始数据格式：3!n',
  `F180019` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F180020` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F180021` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F180022` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F180023` char(3) DEFAULT NULL COMMENT '手续费币种；原始数据格式：3!a',
  `F180024` varchar(255) DEFAULT NULL COMMENT '手续费金额；原始数据格式：20n(2)',
  `F180025` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F180001`, `F180002`, `F180012`, `F180025`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.18委托贷款协议';
