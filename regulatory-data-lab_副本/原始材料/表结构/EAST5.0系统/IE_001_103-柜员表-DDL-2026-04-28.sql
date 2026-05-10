-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_001_103 柜员表
-- ============================================================

DROP TABLE IF EXISTS `IE_001_103`;
CREATE TABLE `IE_001_103` (
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `GYQXJB`                 VARCHAR(30)      DEFAULT NULL COMMENT '柜员权限级别',
  `SFSTGY`                 VARCHAR(3)       DEFAULT NULL COMMENT '是否实体柜员；必填，实体柜员填是，其他填否。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SGRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '上岗日期；虚拟柜员可填写默认日期。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `GYZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '柜员状态',
  `GWBH`                   VARCHAR(60)      DEFAULT NULL COMMENT '岗位编号；关联数据项：岗位信息表.岗位编号',
  `GYLX`                   VARCHAR(30)      DEFAULT NULL COMMENT '柜员类型；银行自定义，“柜员类型”需体现具体虚拟柜员，如自助银行，网银等。',
  `GH`                     VARCHAR(70)      DEFAULT NULL COMMENT '工号；虚拟柜员员工号允许为空。关联数据项：员工表.工号。',
  `GYH`                    VARCHAR(30)      DEFAULT NULL COMMENT '柜员号；PK，虚拟柜员也需要填写柜员号。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；PK。关联数据项：机构信息表.内部机构号',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='柜员表';
