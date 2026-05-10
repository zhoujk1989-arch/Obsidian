-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_512 垫款登记表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_512`;
CREATE TABLE `IE_005_512` (
  `DKYE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '垫款余额；垫款本金余额（不含罚息）。',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；指经办该笔业务的银行机构。关联数据项：机构信息表.内部机构号',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；PK。关联数据项：信贷合同表.信贷合同号',
  `DKLX`                   VARCHAR(60)      DEFAULT NULL COMMENT '垫款类型；以枚举类型填报，如无法以枚举类型填报的，以“其他-XX”填报，其中“XX”为银行自定义垫款类型。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种；可能与原币种不一致',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；指经办该笔业务的银行机构。关联数据项：机构信息表.银行机构名称',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。关联数据项：个人信贷业务借据表.信贷借据号 或 对公信贷业务借据表.信贷借据号。',
  `YHTBH`                  VARCHAR(100)     DEFAULT NULL COMMENT '原合同编号；PK。票据号码，信用证合同编号，保函合同编号，其他能唯一识别具体业务的号码。原合同号有多个的时候按多条报送。关联数据项：票据号码（票据出票信息、票据贴现、票据转贴现） or 保函与信用证表.合同编号',
  `DKJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '垫款金额；垫款本金金额。',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；PK。',
  `DKRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '垫款日期',
  `DKZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '垫款状态',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；指产生该笔垫款的客户名称。如果是个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。其余情况则为非隐私，不做变形。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='垫款登记表';
