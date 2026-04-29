-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_008_803 信用卡授信情况表
-- ============================================================

DROP TABLE IF EXISTS `IE_008_803`;
CREATE TABLE `IE_008_803` (
  `YQRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '逾期日期；如未逾期或已归还，填报默认值99991231。',
  `YSXF`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '应收息费；应收息费包含滞纳金、罚息及利息。',
  `BYLJQXZZJE`             DECIMAL(20,2)    DEFAULT NULL COMMENT '本月累计取现转账金额；报送自然月（1-31日）发生的取现及转账金额总和，不计算客户还款扣减，非账单月累计金额。',
  `BYLJSR`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '本月累计收入；报送自然月（1-31日）累计收入，非账单月累计收入。',
  `YYTHSXJE`               DECIMAL(20,2)    DEFAULT NULL COMMENT '已有他行授信金额；填报最近一次人行征信系统查询时，客户已有他行授信总金额。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `YQJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '逾期金额；逾期未还本金之和。',
  `BYLJXFJE`               DECIMAL(20,2)    DEFAULT NULL COMMENT '本月累计消费金额；报送自然月（1-31日）发生的消费金额总和，不计算客户还款扣减，非账单月累计消费金额。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报客户归属的银行机构。关联数据项：机构信息表.内部机构号',
  `XZSXLX`                 VARCHAR(60)      DEFAULT NULL COMMENT '新增授信类型；最近一次新增授信的类型，包括新发卡授信，但不包括新发卡客户授信额度不变的情况。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报客户归属的银行机构。关联数据项：机构信息表.银行机构名称',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；如果是个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。关联数据项：个人基础信息表.客户姓名 或 对公客户信息表.客户名称',
  `ZHZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '账户状态',
  `ZHYE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '账户余额；截止数据采集时点的账户余额。存在溢缴款时账户余额为正，其他时候账户为负或0。同一账户多个币种共享额度的，按记账币种统一折算填报。',
  `DQSXED`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '当前授信额度；以账户维度填写该账户下总额度，包含临时额度',
  `QZFQYE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '其中分期余额；以账户维度填写该账户下分期余额。',
  `DJYE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '冻结金额；根据业务实际情况，无冻结情况的可以不填。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报客户归属的银行机构。关联数据项：机构信息表.金融许可证号',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；PK。关联数据项：个人基础信息表.客户统一编号 或 对公客户信息表.客户统一编号。',
  `ZJLB`                   VARCHAR(60)      DEFAULT NULL COMMENT '证件类别；持卡人证件类别。',
  `ZJHM`                   VARCHAR(70)      DEFAULT NULL COMMENT '证件号码；持卡人若为个人客户，则证件号码为隐私，银行机构变形，变形规则见《采集技术接口说明》。若为对公客户，则不做变形。',
  `XYKZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '信用卡账号；PK。以账号维度填报，多个账号填多条记录。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种；同一账户多个币种共享额度的，按结算币种统一折算填报。',
  `ZSXEDSX`                DECIMAL(20,2)    DEFAULT NULL COMMENT '总授信额度上限；银行业金融机构根据客户信用状况、收入状况、财务状况等设置的单一客户信用卡总授信额度上限。',
  `YJXJSXED`               DECIMAL(20,2)    DEFAULT NULL COMMENT '预借现金授信额度',
  `ZJSXPGRQ`               VARCHAR(8)       DEFAULT NULL COMMENT '最近授信评估日期',
  `TZJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '透支金额；填报客户当前尚未偿还的本金，不含利息。',
  `QZLSED`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '其中临时额度；临时额度是指以各类形式向客户明示的固定额度以外的额度，临时额度既包括临时性取现或消费额度，也包括授信时有效期确定的专项分期额度。向客户明示的方式包括但不限于网络展示、电话、短信通知等，即使客户并未实际启用该额度，一旦客户获知该额度存在，则有效期内该额度也应计算在临时额度中。',
  `WJFL`                   VARCHAR(6)       DEFAULT NULL COMMENT '五级分类',
  `ZXZJCXRQ`               VARCHAR(8)       DEFAULT NULL COMMENT '最近征信查询日期；填报最近一次在人行征信系统查询授信情况的日期。',
  `DQSXYE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '当前授信余额；以账户维度填写该账户下可用的授信余额。',
  `DYLJJYBS`               DECIMAL(20,0)    DEFAULT NULL COMMENT '当月累计交易笔数；报送自然月（1-31日）累计笔数，非账单月累计笔数。',
  `DYLJTZJE`               DECIMAL(20,2)    DEFAULT NULL COMMENT '当月累计透支金额；报送自然月（1-31日）发生的透支金额总和，不计算客户还款扣减，非账单月累计透支金额。',
  `BYLJFQJYJE`             DECIMAL(20,2)    DEFAULT NULL COMMENT '本月累计分期交易金额；报送自然月（1-31日）累计分期金额，非账单月累计金额。',
  `YYXYKFKHS`              DECIMAL(20,0)    DEFAULT NULL COMMENT '已有信用卡发卡银行数；最近一次人行征信系统查询时，客户已有他行发卡行数。',
  `ZJXZSXRQ`               VARCHAR(8)       DEFAULT NULL COMMENT '最近新增授信日期；最近一次新增授信的日期，如未新增授信填报发卡核定授信日期。',
  `CSBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '催收标志；填报报告期内是否处于催收状态。',
  `CSFS`                   VARCHAR(60)      DEFAULT NULL COMMENT '催收方式；填报报告期内的催收方式。同时存在多种催收方式的，以英文半角分号分隔填报，如“电话催收;信函催收”。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='信用卡授信情况表';
