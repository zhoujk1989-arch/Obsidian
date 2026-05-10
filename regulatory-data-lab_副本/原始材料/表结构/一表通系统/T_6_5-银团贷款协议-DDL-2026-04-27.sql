-- =====================================================
-- 报表：6.5银团贷款协议
-- 表名：T_6_5
-- 字段数：17
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_5`;
CREATE TABLE `T_6_5` (
  `F050001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F050016` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：an..24',
  `F050002` varchar(255) DEFAULT NULL COMMENT '牵头行行名；原始数据格式：anc',
  `F050003` varchar(600) DEFAULT NULL COMMENT '牵头行行号；原始数据格式：anc..600',
  `F050004` varchar(255) DEFAULT NULL COMMENT '参加行行名；原始数据格式：anc',
  `F050005` varchar(2000) DEFAULT NULL COMMENT '参加行行号；原始数据格式：anc..2000',
  `F050006` varchar(255) DEFAULT NULL COMMENT '代理行行名；原始数据格式：anc',
  `F050007` varchar(600) DEFAULT NULL COMMENT '代理行行号；原始数据格式：anc..600',
  `F050008` varchar(60) DEFAULT NULL COMMENT '银团成员类型；原始数据格式：anc..60',
  `F050009` varchar(255) DEFAULT NULL COMMENT '银团贷款总金额；原始数据格式：20n(2)',
  `F050017` char(3) DEFAULT NULL COMMENT '银团贷款总金额币种；原始数据格式：3!a',
  `F050010` varchar(255) DEFAULT NULL COMMENT '承担贷款金额；原始数据格式：20n(2)',
  `F050011` varchar(255) DEFAULT NULL COMMENT '已发放银团贷款金额；原始数据格式：20n(2)',
  `F050012` varchar(255) DEFAULT NULL COMMENT '已发放银团贷款余额；原始数据格式：20n(2)',
  `F050015` varchar(255) DEFAULT NULL COMMENT '已发放承担银团贷款金额；原始数据格式：20n(2)',
  `F050013` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F050014` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F050001`, `F050016`, `F050014`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.5银团贷款协议';
