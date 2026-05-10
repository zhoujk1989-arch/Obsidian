-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_002_203 对公客户信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_002_203`;
CREATE TABLE `IE_002_203` (
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `FRDBZJHM`               VARCHAR(70)      DEFAULT NULL COMMENT '法人代表证件号码；隐私，银行机构变形。变形规则见《采集技术接口说明》。没有法人代表的允许为空。',
  `CWFZRZJLB`              VARCHAR(60)      DEFAULT NULL COMMENT '财务负责人证件类别；部分客户未采集财务负责人信息，应尽量填报，没有可以为空。',
  `JBCKZHKHHMC`            VARCHAR(450)     DEFAULT NULL COMMENT '基本存款账户开户行名称；客户的基本存款账户所在行名称。',
  `SSZB`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '实收资本；非企业客户及未采集的允许为空。',
  `ZCDZ`                   VARCHAR(600)     DEFAULT NULL COMMENT '注册地址；客户的工商登记注册地址。没有的允许为空。',
  `JYFW`                   VARCHAR(3000)    DEFAULT NULL COMMENT '经营范围；非企业客户允许为空。',
  `SSHY`                   VARCHAR(90)      DEFAULT NULL COMMENT '所属行业；填报行业代码，不填报行业名称。',
  `XDKHBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '信贷客户标志；发生过信贷业务的客户填报为“是”，其他填报为“否”。',
  `SSGSBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '上市公司标志；在境内外市场上市的均为上市公司。',
  `XZQHDM`                 VARCHAR(6)       DEFAULT NULL COMMENT '行政区划代码',
  `GZSJDM`                 VARCHAR(500)     DEFAULT NULL COMMENT '关注事件代码；如未在客户风险统计报表中填报相关指标的，允许为空。多个关注事件的，用英文半角分号隔开填报。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报客户归属的银行机构。关联数据项：机构信息表.内部机构号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报客户归属的银行机构。关联数据项：机构信息表.银行机构名称',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；纳入集团统一授信的客户，虚拟集团客户以及成员单位均填报为集团客户。非隐私，不做变形。境内涉密机构的客户名称填报为“*********”。',
  `ZJHM`                   VARCHAR(70)      DEFAULT NULL COMMENT '证件号码；没单位的部门，填报其上级单位或母公司的统一社会信用代码（或组织机构代码）。特殊单位的，填报其上级单位的统一社会信用代码（或组织机构代码）或人民银行开户许可证号。对于同业客户，如未纳入客户管理，报唯一识别码。境内涉密机构填报为空。',
  `FRDBZJLB`               VARCHAR(60)      DEFAULT NULL COMMENT '法人代表证件类别；没有法人代表的允许为空。',
  `CWFZR`                  VARCHAR(150)     DEFAULT NULL COMMENT '财务负责人；非隐私，不做变形。填报财务负责人，无财务负责人的填报财务经办人员，应尽量填报，没有可以为空。',
  `CWFZRZJHM`              VARCHAR(70)      DEFAULT NULL COMMENT '财务负责人证件号码；隐私，银行机构变形。变形规则见《采集技术接口说明》。部分客户未采集财务负责人信息，应尽量填报，没有可以为空。',
  `JBCKZH`                 VARCHAR(60)      DEFAULT NULL COMMENT '基本存款账号；基本存款账户是存款人因办理日常转账结算和现金收付需要开立的银行结算账户。在本行开立有对公户人民币结算账户（验资户除外）需要填报。',
  `JBCKZHKHHH`             VARCHAR(30)      DEFAULT NULL COMMENT '基本存款账户开户行号；客户的基本存款账户所在行机构代码。',
  `ZCZB`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '注册资本；非企业客户及未采集的允许为空。',
  `SSZBBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '实收资本币种；非企业客户，未采集的允许为空。',
  `LXDH`                   VARCHAR(70)      DEFAULT NULL COMMENT '联系电话；非隐私，不做变形。“财务负责人”或“法人代表”未采集的允许为空。',
  `CLRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '成立日期；客户公司的注册成立日期。行政单位等开立对公账户时因所持证件未记载成立日期的，允许为空。',
  `QYFL`                   VARCHAR(30)      DEFAULT NULL COMMENT '企业分类；信贷标志为“是”时，企业分类不可为空。',
  `SCJLXDGXNY`             VARCHAR(6)       DEFAULT NULL COMMENT '首次建立信贷关系年月；信贷客户标志为“是”时，首次建立信贷关系年月不能为默认值。',
  `YGRS`                   BIGINT           DEFAULT NULL COMMENT '员工人数；非企业客户可以为空。企业客户信贷客户标志为“是”时，员工人数不可为空。',
  `FXYJXH`                 VARCHAR(500)     DEFAULT NULL COMMENT '风险预警信号；如未在客户风险统计报表中填报相关指标的，允许为空。多个风险预警信号的，用英文半角分号隔开填报。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `FRDBKHLB`               VARCHAR(6)       DEFAULT NULL COMMENT '法人代表客户类别',
  `KHLX`                   VARCHAR(60)      DEFAULT NULL COMMENT '客户类型；同业客户的范围与银保监会非现场监管统计一致。银行对企业分公司等非法人机构授信的，视同单一法人客户填报。纳入集团统一授信的客户，均填报为集团客户。',
  `ZJLB`                   VARCHAR(60)      DEFAULT NULL COMMENT '证件类别；对于对公客户：已登记统一社会信用代码的，填18位统一社会信用代码；未登记统一社会信用代码的，填营业执照注册号。',
  `ZCZBBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '注册资本币种；非企业客户及未采集的允许为空。',
  `XYPJ`                   VARCHAR(30)      DEFAULT NULL COMMENT '信用评级；非企业客户可以为空。企业客户信贷标志为“是”时，信用评级不可为空。多个评级结果的，填报评级最低的结果。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `FRDB`                   VARCHAR(150)     DEFAULT NULL COMMENT '法人代表；非隐私，不做变形。没有法人代表的允许为空。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报客户归属的银行机构。营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；PK。如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='对公客户信息表';
