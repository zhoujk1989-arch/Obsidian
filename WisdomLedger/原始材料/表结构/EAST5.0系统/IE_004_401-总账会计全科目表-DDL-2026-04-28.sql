-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_004_401 总账会计全科目表
-- ============================================================

DROP TABLE IF EXISTS `IE_004_401`;
CREATE TABLE `IE_004_401` (
  `DFFSE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '本期贷方发生额；本期贷方发生额。最底层科目的贷方发生额应为对应的其他会计类分户账发生明细表中[明细科目编号]等于该[总账会计科目编号]的所有交易记录的贷方发生额的汇总。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；PK。该列中的值应与机构信息表中的[内部机构号]字段保持一致。填报的各机构层级应为总分各级机构汇总及其下属作为独立核算单位的各营业机构（法人汇总、省级和地市分行汇总、支行汇总及下属网点，如内部机构号标识某省分行的数据应为该级汇总，包括本级和下属机构）。关联数据项：机构信息表.内部机构号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `QCJFYE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '期初借方余额；当前科目本期期初余额',
  `JFFSE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '本期借方发生额；本期借方发生额。最底层科目的借方发生额应为对应的其他会计类分户账发生明细表中[明细科目编号]等于该[总账会计科目编号]的所有交易记录的借方发生额的汇总。',
  `QMDFYE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '期末贷方余额；当前科目本期期末余额',
  `KJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '会计日期；PK。会计记账日期',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `KJKMBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '会计科目编号；PK。该列应包含机构设置的全部级次会计科目，其他会计类表中的[明细科目编号]字段填列的值应与本表中最底层科目的编号保持一致。关联数据项：内部科目对照表.总账会计科目编号',
  `KJKMMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '会计科目名称；关联数据项：内部科目对照表.总账会计科目名称',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种；PK',
  `QCDFYE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '期初贷方余额；当前科目本期期初余额',
  `QMJFYE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '期末借方余额；当前科目本期期末余额',
  `BSZQ`                   VARCHAR(20)      DEFAULT NULL COMMENT '报送周期；PK。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='总账会计全科目表';
