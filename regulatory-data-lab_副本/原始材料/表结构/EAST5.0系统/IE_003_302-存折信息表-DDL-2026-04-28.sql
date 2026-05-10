-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_003_302 存折信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_003_302`;
CREATE TABLE `IE_003_302` (
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报存折归属的银行机构。营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报存折归属的银行机构。关联数据项：机构信息表.内部机构号',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；如果是对公客户，则为非隐私，不做变形。如果是个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。',
  `ZJHM`                   VARCHAR(70)      DEFAULT NULL COMMENT '证件号码；如为个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `HQCKZH`                 VARCHAR(60)      DEFAULT NULL COMMENT '存款账号；PK。银行个人客户开立活期或定期存款账户的账号，一个定期存折下面有多个存单的情况，每一个形成一条记录。',
  `YGBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '员工标志；若为员工存折，则填写“是”。',
  `QYGYH`                  VARCHAR(30)      DEFAULT NULL COMMENT '启用柜员号；启用存折柜员号。关联数据项：柜员表.柜员号，自动办理的柜员号允许为空。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `CZZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '存折状态',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `ZJLB`                   VARCHAR(60)      DEFAULT NULL COMMENT '证件类别',
  `CZH`                    VARCHAR(60)      DEFAULT NULL COMMENT '存折号；PK。无存折号时填存款账号',
  `CZLX`                   VARCHAR(30)      DEFAULT NULL COMMENT '存折类型',
  `QYRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '启用日期；启用存折日期。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='存折信息表';
