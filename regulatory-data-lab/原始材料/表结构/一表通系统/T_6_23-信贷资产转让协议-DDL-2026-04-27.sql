-- =====================================================
-- 报表：6.23信贷资产转让协议
-- 表名：T_6_23
-- 字段数：33
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_23`;
CREATE TABLE `T_6_23` (
  `F230001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F230002` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F230003` varchar(60) DEFAULT NULL COMMENT '交易对手ID；原始数据格式：anc..60',
  `F230004` varchar(255) DEFAULT NULL COMMENT '交易对手名称；原始数据格式：anc',
  `F230005` varchar(255) DEFAULT NULL COMMENT '交易对手账号；原始数据格式：an',
  `F230006` varchar(30) DEFAULT NULL COMMENT '交易对手账号行号；原始数据格式：an..30',
  `F230007` varchar(255) DEFAULT NULL COMMENT '交易对手已支付金额；原始数据格式：20n(2)',
  `F230008` varchar(255) DEFAULT NULL COMMENT '转让价款入账账号；原始数据格式：an',
  `F230009` varchar(255) DEFAULT NULL COMMENT '转让价款入账账户名称；原始数据格式：anc',
  `F230010` date DEFAULT NULL COMMENT '签约日期；原始数据格式：YYYY-MM-DD',
  `F230011` date DEFAULT NULL COMMENT '生效日期；原始数据格式：YYYY-MM-DD',
  `F230012` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `F230013` char(3) DEFAULT NULL COMMENT '协议币种；原始数据格式：3!a',
  `F230014` varchar(255) DEFAULT NULL COMMENT '协议金额；原始数据格式：20n(2)',
  `F230015` varchar(60) DEFAULT NULL COMMENT '交易资产类型；原始数据格式：anc..60',
  `F230016` varchar(255) DEFAULT NULL COMMENT '转让涉及业务本金总额；原始数据格式：20n(2)',
  `F230017` varchar(255) DEFAULT NULL COMMENT '转让涉及业务利息总额；原始数据格式：20n(2)',
  `F230018` varchar(255) DEFAULT NULL COMMENT '转让涉及业务笔数；原始数据格式：n',
  `F230019` varchar(255) DEFAULT NULL COMMENT '保证金金额；原始数据格式：20n(2)',
  `F230020` char(3) DEFAULT NULL COMMENT '保证金币种；原始数据格式：3!a',
  `F230021` varchar(255) DEFAULT NULL COMMENT '保证金比例；原始数据格式：20n(6)',
  `F230022` varchar(60) DEFAULT NULL COMMENT '转让交易平台；原始数据格式：anc..60',
  `F230023` char(1) DEFAULT NULL COMMENT '在银登中心登记标识；原始数据格式：1!n',
  `F230024` char(2) NOT NULL COMMENT '资产转让方向；原始数据格式：2!n',
  `F230025` varchar(60) DEFAULT NULL COMMENT '资产转让方式；原始数据格式：anc..60',
  `F230033` date DEFAULT NULL COMMENT '交易对手转账日期；原始数据格式：YYYY-MM-DD',
  `F230026` varchar(32) DEFAULT NULL COMMENT '经办员工ID；原始数据格式：anc..32',
  `F230027` varchar(32) DEFAULT NULL COMMENT '审查员工ID；原始数据格式：anc..32',
  `F230028` varchar(32) DEFAULT NULL COMMENT '审批员工ID；原始数据格式：anc..32',
  `F230029` varchar(60) DEFAULT NULL COMMENT '协议状态；原始数据格式：anc..60',
  `F230030` char(1) DEFAULT NULL COMMENT '或有负债标识；原始数据格式：1!n',
  `F230031` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F230032` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F230001`, `F230002`, `F230024`, `F230032`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.23信贷资产转让协议';
