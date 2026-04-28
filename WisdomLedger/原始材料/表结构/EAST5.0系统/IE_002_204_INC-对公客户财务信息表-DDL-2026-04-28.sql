-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_002_204_INC 对公客户财务信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_002_204_INC`;
CREATE TABLE `IE_002_204_INC` (
  `ZCZE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '资产总额',
  `ZYYWSR`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '主营业务收入',
  `SDS`                    DECIMAL(20,2)    DEFAULT NULL COMMENT '所得税',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `BBZQ`                   VARCHAR(20)      DEFAULT NULL COMMENT '报表周期',
  `JLR`                    DECIMAL(20,2)    DEFAULT NULL COMMENT '净利润',
  `FZZE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '负债总额',
  `BBKJ`                   VARCHAR(30)      DEFAULT NULL COMMENT '报表口径',
  `SFSJ`                   VARCHAR(3)       DEFAULT NULL COMMENT '是否审计',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；非隐私，不做变形。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报客户归属的银行机构。关联数据项：机构信息表.银行机构名称',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报客户归属的银行机构。营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `QTYSK`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '其他应收款',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报客户归属的银行机构。关联数据项：机构信息表.内部机构号',
  `CWBBBH`                 VARCHAR(100)     DEFAULT NULL COMMENT '财务报表编号；PK。',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；PK。如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `CWBBRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '财务报表日期；PK。',
  `SJJG`                   VARCHAR(450)     DEFAULT NULL COMMENT '审计机构；按实际情况填写，优先填报外部审计机构，其次填报内部审计机构，如果没有审计机构的允许为空。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `SQLR`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '税前利润',
  `XJLLJE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '现金流量净额',
  `YSZK`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '应收账款',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='对公客户财务信息表';
