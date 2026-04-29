-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_004_402 内部科目对照表
-- ============================================================

DROP TABLE IF EXISTS `IE_004_402`;
CREATE TABLE `IE_004_402` (
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；PK。关联数据项：机构信息表.内部机构号',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `KJKMJC`                 INT              DEFAULT NULL COMMENT '会计科目级次；允许按实际科目级次填，长度不可超过2位/总账系统是树形或扁平设置的会计科目模式,按实际情况填报',
  `SJKMMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '上级科目名称；上级科目的编号与名称必须一致，一级科目的上级科目为空。非一级科目的上级科目名称关联数据项：总账会计全科目表.会计科目名称。',
  `GSYWDL`                 VARCHAR(30)      DEFAULT NULL COMMENT '归属业务大类；必填项。按七大类业务填报类型名称，不得重复填报。',
  `GSYWZL`                 VARCHAR(300)     DEFAULT NULL COMMENT '归属业务子类；与1104报表G01、G04、G01_I的科目和填报口径一致，按照[序号+中文名称]的格式报送，例：1现金。1104无对应科目的可以为空。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报机构金融许可证号。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `KJKMMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '会计科目名称；关联数据项：总账会计全科目表.会计科目名称。',
  `SJKMBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '上级科目编号；上级科目的编号与名称必须一致，一级科目的上级科目填报为0。非一级科目的上级科目编号需关联数据项：总账会计全科目表.会计科目编号。',
  `KMJDBZ`                 VARCHAR(12)      DEFAULT NULL COMMENT '科目借贷标志；借方科目填借，贷方科目填贷。',
  `KJKMBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '会计科目编号；PK。关联数据项：总账会计全科目表.会计科目编号。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='内部科目对照表';
