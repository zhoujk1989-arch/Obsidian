-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_002_206 关联关系表
-- ============================================================

DROP TABLE IF EXISTS `IE_002_206`;
CREATE TABLE `IE_002_206` (
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `GLRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '关联人名称；若关系人类别为个人，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。若关系人类别为对公，则非隐私，不作变形。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报客户归属的银行机构。营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `GLRLB`                  VARCHAR(30)      DEFAULT NULL COMMENT '关联人类别',
  `KHZJHM`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户证件号码；PK。对公统一社会信用代码（组织机构代码）或对私个人身份证件号码。如是个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报客户归属的银行机构。关联数据项：机构信息表.内部机构号',
  `GLRZJLB`                VARCHAR(60)      DEFAULT NULL COMMENT '关联人证件类别；不可为空。如未收集证件号码，可以填写为其他任意能识别关联人的编号,如“其他-客户编号”。',
  `GLRZJHM`                VARCHAR(70)      DEFAULT NULL COMMENT '关联人证件号码；PK。如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `GLRKHTYBH`              VARCHAR(70)      DEFAULT NULL COMMENT '关联人客户统一编号；关联人如果不是本行客户，则填空。',
  `GXLX`                   VARCHAR(300)     DEFAULT NULL COMMENT '关系类型；PK。同一关联人具有多重关联关系的，以多条分别填报。',
  `KHZJLB`                 VARCHAR(60)      DEFAULT NULL COMMENT '客户证件类别',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；非隐私，不做变形。',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；若非本行客户，则填报为空。',
  `GLRKHLB`                VARCHAR(6)       DEFAULT NULL COMMENT '关联人客户类别',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `GXZT`                   VARCHAR(6)       DEFAULT NULL COMMENT '关系状态；表示该条关系是否已经失效。标记为失效状态的关联关系在次月不再报送。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='关联关系表';
