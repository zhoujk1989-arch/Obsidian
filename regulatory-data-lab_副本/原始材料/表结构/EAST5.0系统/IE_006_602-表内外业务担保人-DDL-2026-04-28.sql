-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_006_602 表内外业务担保人
-- ============================================================

DROP TABLE IF EXISTS `IE_006_602`;
CREATE TABLE `IE_006_602` (
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `BZRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '担保人名称；PK。如果担保人为个人，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。其他情况，则为非隐私，不做变形。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `DBHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '担保合同号；PK。关联数据项：表内外业务担保合同.担保合同号。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `DBRZJLB`                VARCHAR(60)      DEFAULT NULL COMMENT '担保人证件类别；不可为空。如未收集证件号码，可以填写为其他任意能识别担保人的编号,如“其他-客户编号”。',
  `DBRJZC`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '担保人净资产；按实际情况填写，如未收集担保人净资产允许为空。',
  `DBRZJHM`                VARCHAR(70)      DEFAULT NULL COMMENT '担保人证件号码；PK。如为个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `BZRLB`                  VARCHAR(6)       DEFAULT NULL COMMENT '担保人类别',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `DBRJZCBZ`               VARCHAR(3)       DEFAULT NULL COMMENT '担保人净资产币种；按实际情况填写，如未收集担保人净资产允许为空。',
  `DBHTZT`                 VARCHAR(6)       DEFAULT NULL COMMENT '担保合同状态'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='表内外业务担保人';
