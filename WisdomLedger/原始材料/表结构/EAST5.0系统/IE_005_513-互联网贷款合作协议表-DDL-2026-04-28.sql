-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_513 互联网贷款合作协议表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_513`;
CREATE TABLE `IE_005_513` (
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；协议签订机构金融许可证号。',
  `HZFZJHM`                VARCHAR(70)      DEFAULT NULL COMMENT '合作方证件号码；PK。没单位的部门，填报其上级单位或母公司的统一社会信用代码（或组织机构代码）。特殊单位的，填报其上级单位的统一社会信用代码（或组织机构代码）或人民银行开户许可证号。对于同业客户，如未纳入客户管理，报唯一识别码。境内涉密机构填报为空。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `XZBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '限制标志；合作方是否被采取限制合作、降低评级、禁止准入、违约诉讼等有关负面措施，或产生其他影响后续合作的不利因素。',
  `XYDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '协议到期日期；合作协议约定的到期日期。',
  `XZQHDM`                 VARCHAR(6)       DEFAULT NULL COMMENT '合作方注册地代码；合作方工商登记注册地的行政区划代码。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；协议签订机构内部机构号。关联数据项：机构信息表.内部机构号',
  `HZXYBH`                 VARCHAR(200)     DEFAULT NULL COMMENT '合作协议编号；PK。',
  `HZFZJLB`                VARCHAR(60)      DEFAULT NULL COMMENT '合作方证件类别；对于对公客户：已登记统一社会信用代码的，填18位统一社会信用代码；未登记统一社会信用代码的，选择其他方式填写。',
  `HZFMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '合作方名称；非隐私，不做变形。境内涉密机构的客户名称填报为“*********”。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `XYZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '协议状态',
  `SJZZRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '实际终止日期；合作关系终止日期。未终止的填99991231。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `XYQSRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '协议起始日期；合作协议约定的起始日期。',
  `HZFS`                   VARCHAR(150)     DEFAULT NULL COMMENT '合作方式',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `HZFLX`                  VARCHAR(150)     DEFAULT NULL COMMENT '合作方类型',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；协议签订机构名称。关联数据项：机构信息表.银行机构名称'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='互联网贷款合作协议表';
