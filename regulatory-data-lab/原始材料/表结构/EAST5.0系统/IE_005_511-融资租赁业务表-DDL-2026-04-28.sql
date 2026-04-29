-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_511 融资租赁业务表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_511`;
CREATE TABLE `IE_005_511` (
  `DKZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '贷款状态',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `HTYDRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同起始日期；合同约定履行日期，若无该字段信息可填报合同的开始日期',
  `BZJJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金金额；填报首付金额。如没有首付金额，填写默认值0。多个保证金币种统一按一种币种转换合计报送。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报经办的银行机构。关联数据项：机构信息表.内部机构号',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；PK。关联数据项：信贷合同表.信贷合同号',
  `RZZLLX`                 VARCHAR(30)      DEFAULT NULL COMMENT '融资租赁类型；传统经营性租赁：提供融物的服务；融资性租赁：提供金融服务和推销服务。',
  `XYZBZDM`                VARCHAR(3)       DEFAULT NULL COMMENT '币种；指合同约定的币种。',
  `XYZYE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '合同余额；指承租人尚未支付的本金余额。',
  `HTDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同到期日期；合同原始到期日期',
  `CZRZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '承租人账号',
  `ZLGSZJLB`               VARCHAR(60)      DEFAULT NULL COMMENT '租赁公司证件类别',
  `SXFJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '手续费金额；填写本行收取客户的手续费金额，如果没有手续费填写默认值0。',
  `BZJBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '保证金币种；多个保证金币种统一按一种币种转换合计报送。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报经办的银行机构。关联数据项：机构信息表.金融许可证号',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；填报经办的银行机构。关联数据项：机构信息表.银行机构名称',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。关联数据项：个人信贷业务借据表.信贷借据号 或 对公信贷业务借据表.信贷借据号。',
  `ZLBDW`                  VARCHAR(600)     DEFAULT NULL COMMENT '租赁标的物；银行自定义的对租赁标的物的描述，按照租赁合同中约定的租赁标的物填报。',
  `XYZJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '合同金额',
  `CZRBH`                  VARCHAR(70)      DEFAULT NULL COMMENT '承租人编号；关联数据项：个人基础信息表.客户统一编号 或 对公客户信息表.客户统一编号',
  `CZRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '承租人名称；如果承租人为个人客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。如果承租人人为对公客户，则为非隐私，不做变形。',
  `CZRKHHMC`               VARCHAR(450)     DEFAULT NULL COMMENT '承租人开户行名称',
  `ZLGSMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '租赁公司名称；合作融资租赁公司的全称。',
  `ZLGSZJHM`               VARCHAR(70)      DEFAULT NULL COMMENT '租赁公司证件号码',
  `SXFBZ`                  VARCHAR(3)       DEFAULT NULL COMMENT '手续费币种；填写本行收取客户的手续费币种，如果没有允许为空。',
  `BZJBL`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '保证金比例；多个保证金币种统一按一种币种转换合计报送。如没有保证金，填写默认值0。',
  `BZJZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '保证金账号；客户缴纳保证金的实际账号，填报外部账号。若没有填空。多个保证金币种统一按一种币种转换合计报送。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `CZRKHLB`                VARCHAR(6)       DEFAULT NULL COMMENT '承租人客户类别',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='融资租赁业务表';
