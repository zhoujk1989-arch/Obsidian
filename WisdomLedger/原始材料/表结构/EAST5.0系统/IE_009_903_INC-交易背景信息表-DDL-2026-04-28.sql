-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_009_903_INC 交易背景信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_009_903_INC`;
CREATE TABLE `IE_009_903_INC` (
  `DJBH`                   VARCHAR(100)     DEFAULT NULL COMMENT '单据编号；PK。',
  `DJBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '单据币种',
  `YWZL`                   VARCHAR(30)      DEFAULT NULL COMMENT '业务种类',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报办理该业务的银行机构。关联数据项：机构信息表.内部机构号',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报办理该业务的银行机构。关联数据项：机构信息表.金融许可证号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报办理该业务的银行机构。关联数据项：机构信息表.银行机构名称',
  `DJJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '单据金额；单据上实际对应的金额。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `PJHHTH`                 VARCHAR(100)     DEFAULT NULL COMMENT '业务编号；PK。票据号码、保函编号、信用证编号或者合同编号，不可为空。关联数据项：票据号码（票据出票信息、票据贴现、票据转贴现）or 保函与信用证表.合同编号 or 贸易融资信息表.信贷合同号',
  `DJZL`                   VARCHAR(30)      DEFAULT NULL COMMENT '单据种类',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `HTJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '合同金额；指票据金额或保函、信用证、保理融资的业务合同金额。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='交易背景信息表';
