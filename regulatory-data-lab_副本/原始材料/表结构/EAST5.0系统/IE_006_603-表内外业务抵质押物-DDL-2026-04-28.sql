-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_006_603 表内外业务抵质押物
-- ============================================================

DROP TABLE IF EXISTS `IE_006_603`;
CREATE TABLE `IE_006_603` (
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `QZDJMJ`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '权证登记面积；无权证登记面积的允许为空。',
  `ZYPZHM`                 VARCHAR(300)     DEFAULT NULL COMMENT '质押票证号码；如果没有票证号码可以为空。多个票证用英文半角分号隔开报送。如长度过长截断可用“等”进行省略。',
  `YPSYRZJHM`              VARCHAR(70)      DEFAULT NULL COMMENT '押品所有人证件号码；如为个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `YPSYRMC`                VARCHAR(450)     DEFAULT NULL COMMENT '押品所有人名称；质或抵押物所有权人的名称。对应多个所有权人时，只需报送一个所有权人，可以取占有份额最大的报送。如果所有权人为个人，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。其他情况则为非隐私，不做变形。',
  `CZQSW`                  VARCHAR(30)      DEFAULT NULL COMMENT '处置权顺位；指贷款出现风险或不良时，银行具有处置抵质押品的先后顺位。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `DZYWZT`                 VARCHAR(30)      DEFAULT NULL COMMENT '抵质押物状态',
  `YPMC`                   VARCHAR(1500)    DEFAULT NULL COMMENT '押品名称',
  `DBHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '担保合同号；PK。关联数据项：表内外业务担保合同.担保合同号',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `ZYPZQFJG`               VARCHAR(450)     DEFAULT NULL COMMENT '质押票证签发机构；如果没有票证该项可以为空。多个签发机构用英文半角分号隔开报送。如长度过长截断可用“等”进行省略。',
  `YPSYRKHLB`              VARCHAR(6)       DEFAULT NULL COMMENT '押品所有人客户类别',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `DZYL`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '抵质押率；根据《商业银行押品管理指引》规定：抵质押率＝押品担保本金余额÷押品估值×100%。按合同内整体押品计算的抵质押率，不是单件押品计算出来的抵质押率。',
  `PGJZ`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '起始估值；填报银行对抵质押品首次认定价值。',
  `DBHTZT`                 VARCHAR(6)       DEFAULT NULL COMMENT '担保合同状态',
  `QZDJHM`                 VARCHAR(300)     DEFAULT NULL COMMENT '权证登记号码；对于一手房业务，房屋暂未办理权证的情况，可以填报购房合同号。如长度过长截断可用“等”进行省略。',
  `YPSYRZJLB`              VARCHAR(60)      DEFAULT NULL COMMENT '押品所有人证件类别',
  `YDYJZ`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '已抵押价值；在办理该笔信贷业务前，如已进行过抵押业务,填报押品已经抵押的价值，当填报机构为第一顺位时，已抵押价值填报为0。',
  `YXRDJZ`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '最新估值；填报距采集日期最近一次银行认定的押品价值。',
  `YPLX`                   VARCHAR(60)      DEFAULT NULL COMMENT '押品类型；与1104报表G13《押品情况统计表》分类规则一致。保证金无需在本表填报，存单质押填报为 1.1现金及等价物。',
  `YPBH`                   VARCHAR(60)      DEFAULT NULL COMMENT '押品编号；PK。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='表内外业务抵质押物';
