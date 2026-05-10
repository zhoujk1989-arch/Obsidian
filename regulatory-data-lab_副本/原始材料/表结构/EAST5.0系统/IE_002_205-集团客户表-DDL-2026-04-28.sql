-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_002_205 集团客户表
-- ============================================================

DROP TABLE IF EXISTS `IE_002_205`;
CREATE TABLE `IE_002_205` (
  `JTMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '集团名称',
  `MGSMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '母公司名称；供应链融资情况下“母公司名称”填报为核心企业客户。对于没有母公司的集团，母公司允许为空。关联数据项：对公客户信息表.客户名称。',
  `CYYYED`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '成员已用额度',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `SKRLX`                  VARCHAR(60)      DEFAULT NULL COMMENT '实控人类型；同时存在多种类型的以英文半角分号“;”分隔填报',
  `JTFZZE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '集团负债总额；指集团合并报表负债总额，以最近一次财报披露的信息填报。需要编制合并财务报表的集团客户不允许为空报送。供应链客户等无合并报表的，填报自身报表负债金额。',
  `JTYYED`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '集团已用额度；指集团敞口授信已用额度。',
  `CYMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '成员名称；关联数据项：对公客户信息表.客户名称',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报客户归属的银行机构。营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `JTBH`                   VARCHAR(60)      DEFAULT NULL COMMENT '集团编号；PK。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报客户归属的银行机构。关联数据项：机构信息表.内部机构号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报客户归属的银行机构。关联数据项：机构信息表.银行机构名称',
  `MGSKHTYBH`              VARCHAR(70)      DEFAULT NULL COMMENT '母公司客户统一编号；对于没有母公司的集团，母公司允许为空。关联数据项：对公客户信息表.客户统一编号',
  `SKRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '实控人名称；供应链融资情况下“实控人名称”填报为核心企业客户。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `JTZCZE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '集团资产总额；指集团合并报表资产总额，以最近一次财报披露的信息填报。需要编制合并财务报表的集团客户不允许为空报送。供应链客户等无合并报表的，填报自身报表资产金额。',
  `JTSXED`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '集团授信额度；指集团敞口授信总额度。',
  `CYKHTYBH`               VARCHAR(70)      DEFAULT NULL COMMENT '成员客户统一编号；PK。关联数据项：对公客户信息表.客户统一编号',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='集团客户表';
