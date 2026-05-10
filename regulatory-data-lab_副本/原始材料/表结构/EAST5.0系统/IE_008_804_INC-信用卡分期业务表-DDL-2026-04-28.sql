-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_008_804_INC 信用卡分期业务表
-- ============================================================

DROP TABLE IF EXISTS `IE_008_804_INC`;
CREATE TABLE `IE_008_804_INC` (
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `ZJLB`                   VARCHAR(60)      DEFAULT NULL COMMENT '证件类别；持卡人证件类别',
  `ZJHM`                   VARCHAR(70)      DEFAULT NULL COMMENT '证件号码；持卡人证件号码。隐私，银行机构变形。变形规则见《采集技术接口说明》。',
  `XYKZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '信用卡账号；PK。以账号维度填报，多个账号填多条记录。',
  `FQYWLX`                 VARCHAR(60)      DEFAULT NULL COMMENT '分期业务类型',
  `FQZED`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '分期总额度；专项分期指该笔专项分期的额度，对于其他循环信用分期，指该客户可用于办理分期的总额度。',
  `FQZRKH`                 VARCHAR(60)      DEFAULT NULL COMMENT '分期转入卡号；分期业务转入借记卡的填报入账卡号，其他情况允许为空。',
  `FQLL`                   DECIMAL(20,6)    DEFAULT NULL COMMENT '分期利率；填报分期实际年化利率。',
  `FQQS`                   INT              DEFAULT NULL COMMENT '分期期数',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `KYFQED`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '可用分期额度；办理分期时可用的分期额度。',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；如果是个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。关联数据项：个人基础信息表.客户姓名 或 对公客户信息表.客户名称',
  `FQZRKHLB`               VARCHAR(6)       DEFAULT NULL COMMENT '分期转入客户类别',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `FQYWBH`                 VARCHAR(100)     DEFAULT NULL COMMENT '分期业务编号；PK。标注该笔分期的唯一业务编号。',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；PK,如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。关联数据项：个人基础信息表.客户姓名 或 对公客户信息表.客户名称。',
  `FQJYLX`                 VARCHAR(60)      DEFAULT NULL COMMENT '分期交易类型；“普通分期”指账单分期等循环额度内分期。“专项分期”指家装分期、汽车分期等专项审批额度的分期。“总额”指多笔信用卡交易合并为一笔分期的情况，“单笔”指单笔信用卡交易进行分期的情况。',
  `BLFQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '办理分期日期',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `FQJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '分期金额',
  `FQZRHM`                 VARCHAR(450)     DEFAULT NULL COMMENT '分期转入户名；分期业务转入借记卡的填报入账户名，其他情况允许为空。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `BLFQSJ`                 VARCHAR(6)       DEFAULT NULL COMMENT '办理分期时间',
  `GXHFQBZ`                VARCHAR(3)       DEFAULT NULL COMMENT '个性化分期标志；个性化分期定义参照《商业银行信用卡业务监督管理办法》（中国银监会令2011年第2号）第七十条。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='信用卡分期业务表';
