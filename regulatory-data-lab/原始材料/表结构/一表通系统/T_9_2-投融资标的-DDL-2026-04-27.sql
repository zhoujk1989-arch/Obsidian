-- =====================================================
-- 报表：9.2投融资标的
-- 表名：T_9_2
-- 字段数：41
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_9_2`;
CREATE TABLE `T_9_2` (
  `J020001` varchar(60) NOT NULL COMMENT '投融资标的ID；原始数据格式：anc..60',
  `J020002` varchar(255) DEFAULT NULL COMMENT '投融资标的名称；原始数据格式：anc',
  `J020003` varchar(24) DEFAULT NULL COMMENT '机构ID；原始数据格式：anc..24',
  `J020004` varchar(255) DEFAULT NULL COMMENT '发行价格；原始数据格式：20n(6)',
  `J020005` varchar(255) DEFAULT NULL COMMENT '发行规模；原始数据格式：20n(2)',
  `J020006` varchar(255) DEFAULT NULL COMMENT '发行机构名称；原始数据格式：anc',
  `J020007` varchar(20) DEFAULT NULL COMMENT '发行机构代码；原始数据格式：an..20',
  `J020008` varchar(60) DEFAULT NULL COMMENT '发行机构大类；原始数据格式：anc..60',
  `J020107` char(8) DEFAULT NULL COMMENT '发行机构小类；原始数据格式：8!n',
  `J020009` varchar(300) DEFAULT NULL COMMENT '发行国家地区；原始数据格式：anc..300',
  `J020108` varchar(60) DEFAULT NULL COMMENT '交易流通场所；原始数据格式：anc..60',
  `J020010` char(3) DEFAULT NULL COMMENT '投融资标的币种；原始数据格式：3!a',
  `J020011` varchar(255) DEFAULT NULL COMMENT '投融资标的代码；原始数据格式：an',
  `J020014` date DEFAULT NULL COMMENT '起息日期；原始数据格式：YYYY-MM-DD',
  `J020015` date DEFAULT NULL COMMENT '发行日期；原始数据格式：YYYY-MM-DD',
  `J020016` date DEFAULT NULL COMMENT '到期日期；原始数据格式：YYYY-MM-DD',
  `J020017` char(2) DEFAULT NULL COMMENT '投融资标的利率类型；原始数据格式：2!n',
  `J020018` varchar(255) DEFAULT NULL COMMENT '利率/收益率；原始数据格式：20n(6)',
  `J020019` varchar(255) DEFAULT NULL COMMENT '最近评估价格；原始数据格式：20n(2)',
  `J020020` date DEFAULT NULL COMMENT '评估价格日期；原始数据格式：YYYY-MM-DD',
  `J020021` varchar(120) DEFAULT NULL COMMENT '投融资标的类别；原始数据格式：anc..120',
  `J020022` varchar(255) DEFAULT NULL COMMENT '资产风险权重；原始数据格式：20n(6)',
  `J020026` varchar(255) DEFAULT NULL COMMENT '基础资产客户名称；原始数据格式：anc',
  `J020027` char(3) DEFAULT NULL COMMENT '基础资产客户国家；原始数据格式：3!a',
  `J020028` varchar(255) DEFAULT NULL COMMENT '基础资产客户评级；原始数据格式：an',
  `J020029` varchar(255) DEFAULT NULL COMMENT '基础资产客户评级机构；原始数据格式：anc',
  `J020030` char(5) DEFAULT NULL COMMENT '基础资产客户行业类型；原始数据格式：5!an',
  `J020031` varchar(255) DEFAULT NULL COMMENT '基础资产外部评级；原始数据格式：an',
  `J020032` varchar(255) DEFAULT NULL COMMENT '基础资产评级机构；原始数据格式：anc',
  `J020109` varchar(255) DEFAULT NULL COMMENT '基础资产内部评级；原始数据格式：an',
  `J020033` varchar(150) DEFAULT NULL COMMENT '基础资产最终投向类型；原始数据格式：anc..150',
  `J020034` char(5) DEFAULT NULL COMMENT '基础资产最终投向行业类型；原始数据格式：5!an',
  `J020087` varchar(20) DEFAULT NULL COMMENT '含权类型；原始数据格式：anc..20',
  `J020103` char(1) DEFAULT NULL COMMENT '存在变现障碍标识；原始数据格式：1!n',
  `J020106` char(1) DEFAULT NULL COMMENT '是否投向市场化债转股相关产品；原始数据格式：1!n',
  `J020110` char(1) DEFAULT NULL COMMENT '是否投向产业基金；原始数据格式：1!n',
  `J020111` varchar(60) DEFAULT NULL COMMENT '被持有股权企业客户ID；原始数据格式：anc..60',
  `J020112` varchar(600) DEFAULT NULL COMMENT '担保协议ID；原始数据格式：anc..600',
  `J020113` date DEFAULT NULL COMMENT '失效日期；原始数据格式：YYYY-MM-DD',
  `J020104` varchar(600) DEFAULT NULL COMMENT '备注；原始数据格式：anc..600',
  `J020105` date DEFAULT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`J020001`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='9.2投融资标的';
