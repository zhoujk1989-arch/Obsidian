-- =====================================================
-- 报表：6.15房地产贷款协议
-- 表名：T_6_15
-- 字段数：18
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_6_15`;
CREATE TABLE `T_6_15` (
  `F150001` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `F150017` varchar(24) NOT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `F150002` varchar(255) DEFAULT NULL COMMENT '房地产开发贷款对应的项目资本金比例；原始数据格式：20n(6)',
  `F150003` varchar(255) DEFAULT NULL COMMENT '房地产开发贷款对应的项目资本金金额；原始数据格式：20n(2)',
  `F150004` varchar(255) DEFAULT NULL COMMENT '房地产开发贷款对应的项目投资额；原始数据格式：20n(2)',
  `F150005` varchar(60) DEFAULT NULL COMMENT '商业用房购房贷款购买主体类型；原始数据格式：anc..60',
  `F150006` decimal(4,0) DEFAULT NULL COMMENT '个人住房贷款对应的住房套数；原始数据格式：n..4',
  `F150007` varchar(255) DEFAULT NULL COMMENT '贷款价值比；原始数据格式：20n(6)',
  `F150008` char(2) DEFAULT NULL COMMENT '新建个人住房贷款标识；原始数据格式：2!n',
  `F150009` char(2) DEFAULT NULL COMMENT '个人住房贷款利率分类标识；原始数据格式：2!n',
  `F150010` char(2) DEFAULT NULL COMMENT '个人住房贷款基于贷款市场报价利率（LPR）标识；原始数据格式：2!n',
  `F150011` varchar(255) DEFAULT NULL COMMENT '个人住房贷款对应房屋建筑面积；原始数据格式：20n(2)',
  `F150012` varchar(255) DEFAULT NULL COMMENT '个人住房贷款偿债收入比；原始数据格式：20n(6)',
  `F150013` varchar(255) DEFAULT NULL COMMENT '个人住房贷款首付金额；原始数据格式：20n(2)',
  `F150014` varchar(255) DEFAULT NULL COMMENT '个人住房贷款对应房屋总价；原始数据格式：20n(2)',
  `F150015` varchar(255) DEFAULT NULL COMMENT '个人住房贷款对应房地产押品市场价值；原始数据格式：20n(2)',
  `F150018` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `F150016` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`F150001`, `F150017`, `F150016`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='6.15房地产贷款协议';
