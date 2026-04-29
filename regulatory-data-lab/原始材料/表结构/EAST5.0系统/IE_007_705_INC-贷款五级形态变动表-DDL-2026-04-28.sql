-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_007_705_INC 贷款五级形态变动表
-- ============================================================

DROP TABLE IF EXISTS `IE_007_705_INC`;
CREATE TABLE `IE_007_705_INC` (
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。关联数据项：信贷借据表.信贷借据号 or 信用卡信息表.卡号。',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `YWJFL`                  VARCHAR(6)       DEFAULT NULL COMMENT '原五级分类',
  `TZRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '调整日期；PK',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `BDFS`                   VARCHAR(30)      DEFAULT NULL COMMENT '变动方式',
  `BDYY`                   VARCHAR(30)      DEFAULT NULL COMMENT '变动原因',
  `JBGYH`                  VARCHAR(70)      DEFAULT NULL COMMENT '经办人工号；经办员工的员工号，自动变动的员工号允许为空。关联数据项：员工表.工号。',
  `XWJFL`                  VARCHAR(6)       DEFAULT NULL COMMENT '新五级分类',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；如果是个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。关联数据项：个人基础信息表.客户姓名 或 对公客户信息表.客户名称',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；关联数据项：信贷合同表.信贷合同号 or 信用卡信息表.信用卡账号。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='贷款五级形态变动表';
