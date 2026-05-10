-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_506 项目贷款信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_506`;
CREATE TABLE `IE_005_506` (
  `QTXKZBH`                VARCHAR(600)     DEFAULT NULL COMMENT '其他许可证编号；允许为空。如有多个许可证，按英文半角分号隔开填报。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `DKYE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '贷款余额；贷款账户截止到目前未还的本金余额，包括逾期未还本金，已转让/核销贷款余额为0。',
  `JKRBH`                  VARCHAR(70)      DEFAULT NULL COMMENT '借款人编号；关联数据项：对公客户信息表.客户统一编号',
  `JKRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '借款人名称；非隐私，不做变形。',
  `LXPW`                   VARCHAR(60)      DEFAULT NULL COMMENT '立项批文；填报批文标题。无相关批文的允许为空。',
  `TDSYZRQ`                VARCHAR(80)      DEFAULT NULL COMMENT '土地使用证日期；证上标注的发证日期。非房地产类项目贷款允许为空。',
  `YDGHXKZRQ`              VARCHAR(80)      DEFAULT NULL COMMENT '用地规划许可证日期；证上标注的发证日期。非房地产类项目贷款允许为空。',
  `GCGHXKZRQ`              VARCHAR(80)      DEFAULT NULL COMMENT '工程规划许可证日期；证上标注的发证日期。非房地产类项目贷款允许为空。',
  `SGXKZRQ`                VARCHAR(80)      DEFAULT NULL COMMENT '施工许可证日期；证上标注的发证日期。非房地产类项目贷款允许为空。',
  `KGRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '开工日期',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；PK。关联数据项：信贷合同表.信贷合同号',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。关联数据项：个人信贷业务借据表.信贷借据号 或 对公信贷业务借据表.信贷借据号。',
  `XMLX`                   VARCHAR(60)      DEFAULT NULL COMMENT '项目类型',
  `XMMC`                   VARCHAR(300)     DEFAULT NULL COMMENT '项目名称',
  `DKJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '贷款金额；借款人应还本金总额。',
  `SFYT`                   VARCHAR(3)       DEFAULT NULL COMMENT '是否银团',
  `XMZTZ`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '项目总投资',
  `XMZBJ`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '项目资本金',
  `PWWH`                   VARCHAR(60)      DEFAULT NULL COMMENT '批文文号；无相关批文的允许为空。',
  `TDSYZBH`                VARCHAR(600)     DEFAULT NULL COMMENT '土地使用证编号；非房地产类项目贷款允许为空。',
  `YDGHXKZBH`              VARCHAR(600)     DEFAULT NULL COMMENT '用地规划许可证编号；非房地产类项目贷款允许为空。',
  `GCGHXKZBH`              VARCHAR(600)     DEFAULT NULL COMMENT '工程规划许可证编号；非房地产类项目贷款允许为空。',
  `SGXKZBH`                VARCHAR(600)     DEFAULT NULL COMMENT '施工许可证编号；非房地产类项目贷款允许为空。',
  `QTXKZ`                  VARCHAR(150)     DEFAULT NULL COMMENT '其他许可证；允许为空。如有多个许可证，按英文半角分号隔开填报。',
  `DKZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '贷款状态',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='项目贷款信息表';
