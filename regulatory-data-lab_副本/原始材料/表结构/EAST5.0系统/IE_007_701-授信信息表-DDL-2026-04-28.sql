-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_007_701 授信信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_007_701`;
CREATE TABLE `IE_007_701` (
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；如果是个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。关联数据项：个人基础信息表.客户姓名 或 对公客户信息表.客户名称',
  `SXKSRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '授信开始日期',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填写申请授信的银行机构。关联数据项：机构信息表.内部机构号',
  `KHZJHM`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户证件号码',
  `EDSQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '额度申请日期；申请日期。',
  `SXZTZL`                 VARCHAR(60)      DEFAULT NULL COMMENT '授信主体种类',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `SXDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '授信到期日期',
  `SXJCYJ`                 VARCHAR(3000)    DEFAULT NULL COMMENT '授信审批意见',
  `JBRGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '经办人工号；指受理该笔授信的员工工号，自动办理的允许为空。关联数据项：员工表.工号。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `YHJGDM`                 VARCHAR(30)      DEFAULT NULL COMMENT '银行机构代码；填写申请授信的银行机构。关联数据项：机构信息表.银行机构代码',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `KHZJLB`                 VARCHAR(60)      DEFAULT NULL COMMENT '客户证件类别',
  `SXXYMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '授信协议名称；可以填合同名称',
  `SXED`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '授信额度',
  `YYED`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '已用额度',
  `SPRGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '审批人工号；指最终审批人工号，自动授信的允许为空。关联数据项：员工表.工号。',
  `SXZT`                   VARCHAR(6)       DEFAULT NULL COMMENT '授信状态；表示一条记录是否已经无效。默认为有效，当需要删除一条授信信息时，更新为无效。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `SXZL`                   VARCHAR(60)      DEFAULT NULL COMMENT '授信种类',
  `SXXYH`                  VARCHAR(60)      DEFAULT NULL COMMENT '授信协议号；PK。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='授信信息表';
