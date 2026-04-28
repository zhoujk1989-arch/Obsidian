-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_008_801 信用卡信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_008_801`;
CREATE TABLE `IE_008_801` (
  `KPJB`                   VARCHAR(60)      DEFAULT NULL COMMENT '卡片级别',
  `LMKMC`                  VARCHAR(300)     DEFAULT NULL COMMENT '联名卡名称',
  `KKRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '开卡日期',
  `KKYGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '开卡柜员号；指激活生效的柜员号，关联数据项：柜员表.柜员号。自动办理的柜员号允许为空。',
  `FSKBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '附属卡标志',
  `DBLX`                   VARCHAR(60)      DEFAULT NULL COMMENT '担保类型',
  `NFBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '年费标志',
  `KJZFBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '快捷支付标志；是否绑定持有《支付业务许可证》非银行支付机构快捷支付。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报信用卡归属的银行机构。关联数据项：机构信息表.内部机构号。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报信用卡归属的银行机构。关联数据项：机构信息表.银行机构名称。',
  `ZJHM`                   VARCHAR(70)      DEFAULT NULL COMMENT '证件号码；如为个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `ZHZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '账户状态',
  `ZCGNBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '政策功能标志；是否是政策法规要求银行业金融机构发行的附加政策功能的信用卡，如根据《中央预算单位公务卡管理暂行办法》（财库〔2007〕63号）发行公务卡等。',
  `WBBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '外币币种；填写主要币种，一般由信用卡组织确定。',
  `WBSXYE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '外币授信余额；外币可用余额。',
  `XKRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '销卡日期；信用卡销卡的日期。卡片状态正常时，填默认值。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报信用卡归属的银行机构。关联数据项：机构信息表.金融许可证号',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；关联数据项：个人基础信息表.客户统一编号',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；如果是个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。关联数据项：个人基础信息表.客户姓名 或 对公客户信息表.客户名称',
  `ZJLB`                   VARCHAR(60)      DEFAULT NULL COMMENT '证件类别',
  `XYKZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '信用卡账号；PK。以信用卡账户维度填报，多个账号填写多条记录。',
  `KH`                     VARCHAR(60)      DEFAULT NULL COMMENT '卡号；PK。',
  `KPZL`                   VARCHAR(9)       DEFAULT NULL COMMENT '卡片种类；单位卡定义：以单位名义开立，所有人为单位的信用卡。',
  `KZZMC`                  VARCHAR(3000)    DEFAULT NULL COMMENT '卡组织名称；包含本卡所有可用组织通道，主要通道在前，填写信用卡组织的规范简称，如银联、VISA等。使用英文半角分号隔开。',
  `KPZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '卡片状态；以枚举类型填报，如果无法以枚举类型填报的，以“其他-XX”填报，其中XX为银行自定义的卡片状态。',
  `ZKH`                    VARCHAR(60)      DEFAULT NULL COMMENT '主卡号；主卡填本身卡号，卡片为附属卡时不能为空',
  `DBSM`                   VARCHAR(600)     DEFAULT NULL COMMENT '担保说明；担保类型不为“信用”时，此项必填。以质押或抵押办理大额信用卡的业务，需在本数据项中具体说明。',
  `WLZFBZ`                 VARCHAR(3)       DEFAULT NULL COMMENT '网络支付标志；是否开通手机银行、网上银行等网络支付功能。',
  `XZCS`                   VARCHAR(60)      DEFAULT NULL COMMENT '限制措施',
  `YCBS`                   VARCHAR(60)      DEFAULT NULL COMMENT '异常标识',
  `FKHZJG`                 VARCHAR(450)     DEFAULT NULL COMMENT '发卡合作机构；发卡渠道为“第三方机构引流”的，填报第三方机构名称。',
  `LMDWDM`                 VARCHAR(60)      DEFAULT NULL COMMENT '联名单位代码',
  `BBXYED`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '本币信用额度；如卡号额度与信用卡账户额度共享的，填写信用卡账户总额度；卡号额度独立的填写该卡号额度',
  `WBXYED`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '外币信用额度；如卡号额度与信用卡账户额度共享的，填写信用卡账户总额度；卡号额度独立的填写该卡号额度',
  `BBSXYE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '本币授信余额；本币可用额度。',
  `ZHDHJYRQ`               VARCHAR(8)       DEFAULT NULL COMMENT '最后动户交易日期',
  `XKYGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '销卡柜员号；指办理销卡的柜员号，关联数据项：柜员表.柜员号。自动办理的柜员号允许为空。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `KPMC`                   VARCHAR(60)      DEFAULT NULL COMMENT '卡片名称',
  `FKHZJGDM`               VARCHAR(40)      DEFAULT NULL COMMENT '发卡合作机构代码；发卡渠道为“第三方机构引流”的，填报第三方机构统一社会信用代码。',
  `LMDW`                   VARCHAR(450)     DEFAULT NULL COMMENT '联名单位',
  `LMKBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '联名卡标志',
  `FKQD`                   VARCHAR(60)      DEFAULT NULL COMMENT '发卡渠道；填写持卡人申请该张卡片的渠道。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='信用卡信息表';
