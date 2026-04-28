-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_001_106 股东及关联方信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_001_106`;
CREATE TABLE `IE_001_106` (
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报机构金融许可证号。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `BLXX`                   VARCHAR(300)     DEFAULT NULL COMMENT '不良信息',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报本行法人机构名称。关联数据项：机构信息表.银行机构名称',
  `ZCD`                    VARCHAR(600)     DEFAULT NULL COMMENT '股东或关联方注册地；主要股东不得为空。',
  `GXLX`                   VARCHAR(300)     DEFAULT NULL COMMENT '关系类型；股东：上市银行持有或控制1%以上、5%以下股份或表决权的股东；非上市银行为持有或控制5%以下股份的所有股东。控制：包括直接控制、间接控制，是指有权决定一个企业的财务和经营决策，并能据以从该企业的经营活动中获取利益。持有：包括直接持有与间接持有。重大影响：是指对法人或组织的财务和经营政策有参与决策的权力，但不能够控制或者与其他方共同控制这些政策的制定。包括但不限于派驻董事、监事或高级管理人员、通过协议或其他方式影响法人或组织的财务和经营管理决策，以及银保监会或其派出机构认定的其他情形。控股股东：是指持股比例达到50%以上的股东；或持股比例虽不足50%，但依享有的表决权已足以对股东（大）会的决议产生控制性影响的股东。实际控制人：是指虽不是公司的股东，但通过投资关系、协议或者其他安排，能够实际支配公司行为的自然人或其他最终控制人。一致行动人：是指通过协议、合作或其他途径，在行使表决权或参与其他经济活动时采取相同意思表示的自然人、法人或非法人组织。最终受益人：是指实际享有银行保险机构股权收益、金融产品收益的人。“以上”含本数，“以下”不含本数。未尽事宜参照《银行保险机构关联交易管理办法》（中国银行保险监督管理委员会令〔2022〕1号）填报。',
  `CGSYYHSL`               DECIMAL(20,0)    DEFAULT NULL COMMENT '参股商业银行的数量；同一股东及其关联方、一致行动人作为主要股东参股商业银行的数量',
  `SFXQ`                   VARCHAR(3)       DEFAULT NULL COMMENT '是否限权；是否存在限制股东参与经营管理的相关权利，包括股东大会召开请求权、表决权、提名权、提案权、处分权等',
  `RGZJLY`                 VARCHAR(60)      DEFAULT NULL COMMENT '入股资金来源',
  `CGSL`                   DECIMAL(20,0)    DEFAULT NULL COMMENT '持股数量；股东持有银行股数，以股为单位。填报机构为非股份法人的可以为空。',
  `RGRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '入股日期；最近一次持股份额由0变为非0的日期。',
  `ZYBL`                   DECIMAL(20,6)    DEFAULT NULL COMMENT '质押比例；填报该股东截至报送日持有的本行股权用于质押的比例。未质押股权的填0，未采集质押比例的填报为空。',
  `ZJYCBDRQ`               VARCHAR(8)       DEFAULT NULL COMMENT '最近一次变动日期；报送最近一次入股、增资扩股或股权转让等影响持股比例的日期。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；PK',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；如果股东不是本银行客户，填为空值。',
  `GDHGLFMC`               VARCHAR(450)     DEFAULT NULL COMMENT '股东或关联方名称；对个人股东，为股东姓名；对法人股东及关联法人，为经有关部门批准正式使用的客户全称，与客户公章所使用的名称完全一致。非股东的关联自然人名称为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `GDHGLFLX`               VARCHAR(60)      DEFAULT NULL COMMENT '股东或关联方类型；同时存在多种类型的以英文半角分号“;”分隔填报',
  `GDHGLFZJLB`             VARCHAR(60)      DEFAULT NULL COMMENT '股东或关联方证件类别；不可为空。如未收集证件号码，可以填写为其他任意能识别该股东的编号,如“其他-客户编号”。',
  `GDHGLFZJHM`             VARCHAR(70)      DEFAULT NULL COMMENT '股东或关联方证件号码；如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `SSHY`                   VARCHAR(90)      DEFAULT NULL COMMENT '股东或关联方所属行业；股东或关联方主营业务所属的行业',
  `SJKZR`                  VARCHAR(450)     DEFAULT NULL COMMENT '实际控制人；应按照穿透原则填报股东的最终实际控制人，公有制企业的应填报至最终出资人，如XX国资委；非公有制企业应填报至出资自然人名称；外资企业应填报境外出资人名称。实控人为多人以英文半角分号隔开。无实控人的，填报“无”。非隐私，不做变形。',
  `KGSL`                   DECIMAL(20,0)    DEFAULT NULL COMMENT '控股商业银行的数量；同一股东及其关联方、一致行动人作为主要股东控股商业银行的数量',
  `RGZJZH`                 VARCHAR(60)      DEFAULT NULL COMMENT '入股资金账号；需填写入股时在本行开立的验资户账户号。二级市场买入可为空。多个账号用英文半角分号隔开。',
  `CGBL`                   DECIMAL(20,6)    DEFAULT NULL COMMENT '持股比例',
  `SFZPDJS`                VARCHAR(3)       DEFAULT NULL COMMENT '是否驻派董监事；该股东是否向本行派驻董事、监事。',
  `GDHGLFZT`               VARCHAR(6)       DEFAULT NULL COMMENT '股东或关联方状态；表示一条记录是否已经无效。默认为有效，当需要删除一条股东信息时，更新为无效。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='股东及关联方信息表';
