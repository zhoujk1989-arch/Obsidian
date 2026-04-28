-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_004_409 个人信贷分户账
-- ============================================================

DROP TABLE IF EXISTS `IE_004_409`;
CREATE TABLE `IE_004_409` (
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报账户归属的银行机构。营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `MXKMBH`                 VARCHAR(60)      DEFAULT NULL COMMENT '明细科目编号；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。关联数据项：个人基础信息表.客户统一编号',
  `ZHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '账户名称；账户归属者的名称。隐私，银行机构变形，变形规则见《采集技术接口说明》。',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；关联数据项：信贷合同表.信贷合同号',
  `DKLL`                   DECIMAL(20,6)    DEFAULT NULL COMMENT '实际利率；按业务实际填写，利率类型为LPR时填报最新执行利率。百分比为单位，即1/100，为年利，精确到小数点后4位。若利率为0，允许填报为0。',
  `DKJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '贷款金额；借款人应还本金总额。票据填报票面金额，信用证填报信用证金额。',
  `FFRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '发放日期；填写贷款实际发放日期，YYYYMMDD。',
  `XHRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '销户日期；账户销户的日期。账户状态正常时，填默认值。',
  `ZHZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '账户状态',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `MXKMMC`                 VARCHAR(300)     DEFAULT NULL COMMENT '明细科目名称；同一条数据涉及多个明细科目的，仅填报该笔业务指向的主要科目，如：一笔贷款仅包含正常本金时，填报正常本金科目，如一笔贷款既包含正常本金也包含逾期本金时，填报逾期本金科目。关联数据项：总账会计全科目表.会计科目编号。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报账户归属的银行机构。关联数据项：机构信息表.银行机构名称',
  `DKFHZH`                 VARCHAR(60)      DEFAULT NULL COMMENT '贷款分户账号；PK。',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。关联数据项：个人信贷业务借据表.信贷借据号',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种；PK',
  `DKYE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '贷款余额；贷款账户截止到目前未还的本金余额，包括逾期未还本金，已转让/核销贷款余额为0。',
  `KHRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '开户日期',
  `DKZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '贷款状态',
  `DQRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '到期日期；贷款借据（包括展期）约定的到期日期。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报账户归属的银行机构。关联数据项：机构信息表.内部机构号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='个人信贷分户账';
