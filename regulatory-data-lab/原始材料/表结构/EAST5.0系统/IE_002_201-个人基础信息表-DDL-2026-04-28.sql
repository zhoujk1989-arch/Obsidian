-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_002_201 个人基础信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_002_201`;
CREATE TABLE `IE_002_201` (
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `ZJHM`                   VARCHAR(70)      DEFAULT NULL COMMENT '证件号码；隐私，银行机构变形。变形规则见《采集技术接口说明》。',
  `SHMDRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '上黑名单日期',
  `SFNH`                   VARCHAR(3)       DEFAULT NULL COMMENT '是否农户；统计口径参照人行涉农口径。',
  `XDKHBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '信贷客户标志；有信贷业务余额，或者开展过信贷业务的客户均为本行信贷客户。',
  `LXDH`                   VARCHAR(70)      DEFAULT NULL COMMENT '联系电话；隐私，银行机构变形，变形规则见《采集技术接口说明》，应采尽采。',
  `GRNSR`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '个人年收入；折算人民币报送。小微个人客户填报经营收入指标。学生等无收入的客户，个人年收入可填报为0。未采集的允许为空。',
  `DWXZ`                   VARCHAR(60)      DEFAULT NULL COMMENT '单位性质；未采集或无工作单位的客户，允许为空。',
  `GZDWMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '工作单位名称；未采集或无工作单位的客户，允许为空。工作单位是境内涉密机构的，客户名称填报为“*********”。',
  `CSNY`                   VARCHAR(6)       DEFAULT NULL COMMENT '出生年月；客户的出生年月，无需精确到日。不可为空。',
  `XB`                     VARCHAR(3)       DEFAULT NULL COMMENT '性别；不可为空。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `BHYGBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '本行员工标志',
  `SCJLXDGXNY`             VARCHAR(6)       DEFAULT NULL COMMENT '首次建立信贷关系年月；信贷客户标志为“是”时，首次建立信贷关系年月不能为默认值。',
  `TXDZ`                   VARCHAR(600)     DEFAULT NULL COMMENT '通讯地址；对于未采集通讯地址的客户，允许为空。',
  `ZW`                     VARCHAR(150)     DEFAULT NULL COMMENT '职务；未采集或无工作单位的客户，允许为空。',
  `ZY`                     VARCHAR(90)      DEFAULT NULL COMMENT '职业；未采集的允许为空。',
  `GZDWDH`                 VARCHAR(70)      DEFAULT NULL COMMENT '工作单位电话；未采集或无工作单位的客户，允许为空。工作单位是境内涉密机构的填报为空。',
  `GZDWDZ`                 VARCHAR(600)     DEFAULT NULL COMMENT '工作单位地址；未采集或无工作单位的客户，允许为空。工作单位是境内涉密机构的填报为空。',
  `SFYH`                   VARCHAR(3)       DEFAULT NULL COMMENT '是否已婚；未采集的允许为空。',
  `XL`                     VARCHAR(30)      DEFAULT NULL COMMENT '学历；未采集的允许为空。',
  `MZ`                     VARCHAR(30)      DEFAULT NULL COMMENT '民族；外籍客户允许为空。',
  `BXYGBZ`                 VARCHAR(60)      DEFAULT NULL COMMENT '客户类型；多个身份的，用英文半角分号隔开填报。识别为个体工商户或小为企业主的，不必填普通个人客户身份。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SHMDBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '上黑名单标志；黑名单指：反洗钱黑名单、失信人员黑名单。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报客户归属的银行机构。营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；PK。如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `ZJLB`                   VARCHAR(60)      DEFAULT NULL COMMENT '证件类别',
  `GJHDQ`                  VARCHAR(60)      DEFAULT NULL COMMENT '国家或地区',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报客户归属的银行机构。关联数据项：机构信息表.内部机构号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报客户归属的银行机构。关联数据项：机构信息表.银行机构名称',
  `KHXM`                   VARCHAR(150)     DEFAULT NULL COMMENT '客户姓名；隐私，银行机构变形，变形规则见《采集技术接口说明》。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='个人基础信息表';
