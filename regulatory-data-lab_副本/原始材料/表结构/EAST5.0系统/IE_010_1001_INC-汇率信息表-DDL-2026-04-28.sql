-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_010_1001_INC 汇率信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_010_1001_INC`;
CREATE TABLE `IE_010_1001_INC` (
  `HLRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '汇率日期；PK。指汇率公布日期。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `WBBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '外币币种；PK。',
  `WBSL`                   DECIMAL(20,6)    DEFAULT NULL COMMENT '外币数量；国家外汇管理局公布的人民币汇率中间价。可以是1外币折合多少本币，也可以是100外币折合多少本币。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `BBBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '本币币种；PK。',
  `ZBBSL`                  DECIMAL(20,6)    DEFAULT NULL COMMENT '折本币数量'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='汇率信息表';
