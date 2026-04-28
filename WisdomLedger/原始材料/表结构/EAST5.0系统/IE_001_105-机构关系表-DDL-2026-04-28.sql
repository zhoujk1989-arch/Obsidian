-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_001_105 机构关系表
-- ============================================================

DROP TABLE IF EXISTS `IE_001_105`;
CREATE TABLE `IE_001_105` (
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `SJGLJGDM`               VARCHAR(30)      DEFAULT NULL COMMENT '上级管理机构代码；没有上级机构的该项填写为0。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SJGLNBJGH`              VARCHAR(30)      DEFAULT NULL COMMENT '上级管理内部机构号；没有上级机构的该项填写为0。',
  `YHJGDM`                 VARCHAR(30)      DEFAULT NULL COMMENT '银行机构代码；关联数据项：机构信息表.银行机构代码',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；PK',
  `SJGLJGMC`               VARCHAR(450)     DEFAULT NULL COMMENT '上级管理机构名称；没有上级机构的该项填写为空，其中总行本级上级机构为总行法人名称。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='机构关系表';
