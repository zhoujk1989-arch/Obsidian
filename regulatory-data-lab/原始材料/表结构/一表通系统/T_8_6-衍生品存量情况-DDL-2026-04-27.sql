-- =====================================================
-- 报表：8.6衍生品存量情况
-- 表名：T_8_6
-- 字段数：36
-- 生成时间：2026-04-27
-- =====================================================
DROP TABLE IF EXISTS `T_8_6`;
CREATE TABLE `T_8_6` (
  `H060001` varchar(60) NOT NULL COMMENT '衍生品ID；原始数据格式：anc..60',
  `H060002` varchar(24) NOT NULL COMMENT '交易机构ID；原始数据格式：anc..24',
  `H060003` varchar(100) NOT NULL COMMENT '协议ID；原始数据格式：anc..100',
  `H060004` varchar(255) NOT NULL COMMENT '衍生品名称；原始数据格式：anc',
  `H060005` varchar(60) NOT NULL COMMENT '衍生品类型；原始数据格式：anc..60',
  `H060006` varchar(200) NOT NULL COMMENT '基础资产名称；原始数据格式：anc..200',
  `H060007` varchar(30) NOT NULL COMMENT '基础资产类型；原始数据格式：anc..30',
  `H060008` char(2) NOT NULL COMMENT '账户类型；原始数据格式：2!n',
  `H060009` char(3) NOT NULL COMMENT '币种；原始数据格式：3!a',
  `H060010` varchar(255) NOT NULL COMMENT '正总市场价值；原始数据格式：20n(2)',
  `H060011` varchar(255) NOT NULL COMMENT '负总市场价值；原始数据格式：20n(2)',
  `H060012` date NOT NULL COMMENT '估值日期；原始数据格式：YYYY-MM-DD',
  `H060013` varchar(255) NOT NULL COMMENT '多头头寸；原始数据格式：20n(2)',
  `H060014` varchar(255) NOT NULL COMMENT '空头头寸；原始数据格式：20n(2)',
  `H060015` date NOT NULL COMMENT '合同起始日期；原始数据格式：YYYY-MM-DD',
  `H060016` date NOT NULL COMMENT '合同终止日期；原始数据格式：YYYY-MM-DD',
  `H060017` date NOT NULL COMMENT '衍生品发行日期；原始数据格式：YYYY-MM-DD',
  `H060018` date NOT NULL COMMENT '衍生品到期日期；原始数据格式：YYYY-MM-DD',
  `H060019` varchar(32) NOT NULL COMMENT '科目ID；原始数据格式：anc..32',
  `H060020` varchar(255) NOT NULL COMMENT '科目名称；原始数据格式：anc',
  `H060021` char(3) NOT NULL COMMENT '国家地区；原始数据格式：3!a',
  `H060022` varchar(30) NOT NULL COMMENT '行权方式；原始数据格式：anc..30',
  `H060023` char(3) NOT NULL COMMENT '本方初始币种；原始数据格式：3!a',
  `H060024` char(3) NOT NULL COMMENT '对方初始币种；原始数据格式：3!a',
  `H060025` char(2) NOT NULL COMMENT '本方利率类型；原始数据格式：2!n',
  `H060026` char(2) NOT NULL COMMENT '对方利率类型；原始数据格式：2!n',
  `H060027` varchar(255) NOT NULL COMMENT '本方利率基准；原始数据格式：anc',
  `H060028` varchar(255) NOT NULL COMMENT '本方利率浮动点；原始数据格式：n',
  `H060029` varchar(255) NOT NULL COMMENT '对方利率基准；原始数据格式：anc',
  `H060030` varchar(255) NOT NULL COMMENT '对方利率浮动点；原始数据格式：n',
  `H060031` varchar(600) NOT NULL COMMENT '担保协议ID；原始数据格式：anc..600',
  `H060033` varchar(255) NOT NULL COMMENT '估值金额；原始数据格式：20n(2)',
  `H060034` char(3) NOT NULL COMMENT '估值币种；原始数据格式：3!a',
  `H060035` varchar(255) NOT NULL COMMENT '保证金金额；原始数据格式：20n(2)',
  `H060036` varchar(600) NOT NULL COMMENT '备注；原始数据格式：anc..600',
  `H060032` date NOT NULL COMMENT '采集日期；原始数据格式：YYYY-MM-DD',
  PRIMARY KEY (`H060001`, `H060002`, `H060003`, `H060004`, `H060005`, `H060006`, `H060007`, `H060008`, `H060009`, `H060010`, `H060011`, `H060012`, `H060013`, `H060014`, `H060015`, `H060016`, `H060017`, `H060018`, `H060019`, `H060020`, `H060021`, `H060022`, `H060023`, `H060024`, `H060025`, `H060026`, `H060027`, `H060028`, `H060029`, `H060030`, `H060031`, `H060033`, `H060034`, `H060035`, `H060036`, `H060032`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='8.6衍生品存量情况';
