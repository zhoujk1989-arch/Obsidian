-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_007_702 资产核销表
-- ============================================================

DROP TABLE IF EXISTS `IE_007_702`;
CREATE TABLE `IE_007_702` (
  `SHLX`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '收回利息；报送数据采集时点的累计核销收回利息，多次收回应报送合计值。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `HTH`                    VARCHAR(100)     DEFAULT NULL COMMENT '合同号；PK。关联数据项：信贷合同表.信贷合同号或信用卡信息.信用卡账号',
  `ZCLX`                   VARCHAR(30)      DEFAULT NULL COMMENT '资产类型；个人贷款和对公贷款均为除了信用卡透支以外的贷款。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；该笔贷款所属行的内部机构号，关联数据项：机构信息表.内部机构号',
  `SHYGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '收回员工号；对于多次收回的情况，填报最近一次收回的员工号。无收回员工号的允许为空值。关联数据项：员工表.工号。',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；如果是个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。关联数据项：个人基础信息表.客户姓名 或 对公客户信息表.客户名称',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `SHRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '收回日期；对于多次收回的情况，填报最近一次收回日期。',
  `SHBJ`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '收回本金；报送数据采集时点的累计核销收回本金，多次收回应报送合计值。',
  `SHBNLX`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '实核表内利息；填报核销时点数据。实核贷款本金如果是打包的，按比例拆分填报。',
  `SHBZ`                   VARCHAR(12)      DEFAULT NULL COMMENT '收回标志；填报最新的贷款核销后清收状态。',
  `HXZT`                   VARCHAR(12)      DEFAULT NULL COMMENT '核销状态；根据财政部2017年《金融企业呆账核销管理办法》规定，符合规定完全终结的信贷资产可填报为“完全终结”。通过各种手段处置已核销资产结清欠款或已无追索权的，也视为“完全终结”',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种；PK。',
  `SHBWLX`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '实核表外利息；填报核销时点数据。表外利息指已转入表外核算的利息。',
  `HXRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '核销日期',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `JJH`                    VARCHAR(100)     DEFAULT NULL COMMENT '借据号；PK。关联数据项：个人信贷业务借据表.信贷借据号 或 对公信贷业务借据表.信贷借据号 或 信用卡信息表.卡号。当核销贷款为信用卡时，信贷借据号填报为该信用卡账户下主要的一张有效卡号。',
  `HXBJ`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '实核本金；填报核销时点数据。实核贷款本金如果是打包的，按比例拆分填报。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资产核销表';
