-- =====================================================
-- 报表：6.4互联网贷款协议
-- 表名：T_6_4
-- 字段数：17
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_4`;
CREATE TABLE `T_6_4` (
  `F040001` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F040002` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F040003` varchar(100) NOT NULL COMMENT '借据ID；原始数据格式：anc..100',
  `F040004` varchar(60) DEFAULT NULL COMMENT '合作协议ID；原始数据格式：anc..60',
  `F040005` char(2) DEFAULT NULL COMMENT '业务模式；原始数据格式：2!n',
  `F040006` varchar(255) DEFAULT NULL COMMENT '合作方负有担保责任的金额；原始数据格式：20n(2)',
  `F040007` varchar(255) DEFAULT NULL COMMENT '合作方出资发放贷款金额；原始数据格式：20n(2)',
  `F040008` varchar(255) DEFAULT NULL COMMENT '本机构出资发放贷款金额；原始数据格式：20n(2)',
  `F040009` varchar(255) DEFAULT NULL COMMENT '客户数据授权书编号；原始数据格式：anc',
  `F040010` date DEFAULT NULL COMMENT '授权生效日期；原始数据格式：YYYY-MM-DD',
  `F040011` date DEFAULT NULL COMMENT '授权终止日期；原始数据格式：YYYY-MM-DD',
  `F040012` varchar(255) DEFAULT NULL COMMENT '提供部分风险评价服务合作机构名称；原始数据格式：anc',
  `F040013` varchar(255) DEFAULT NULL COMMENT '提供担保增信合作机构名称；原始数据格式：anc',
  `F040017` varchar(255) DEFAULT NULL COMMENT '合作方协议责任金额；原始数据格式：20n(2)',
  `F040018` varchar(128) DEFAULT NULL COMMENT '申请人联系电话；原始数据格式：anc..128',
  `F040015` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F040016` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F040001`, `F040002`, `F040003`, `F040016`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.4互联网贷款协议';
