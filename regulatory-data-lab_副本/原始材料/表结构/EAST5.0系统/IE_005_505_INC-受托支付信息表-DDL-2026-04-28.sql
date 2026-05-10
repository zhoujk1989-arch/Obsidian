-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_505_INC 受托支付信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_505_INC`;
CREATE TABLE `IE_005_505_INC` (
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。关联数据项：个人信贷业务借据表.信贷借据号 或 对公信贷业务借据表.信贷借据号',
  `STZFDXKHLB`             VARCHAR(6)       DEFAULT NULL COMMENT '受托支付对象客户类别',
  `STZFJE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '受托支付金额；填写单笔受托支付金额',
  `STZFDXZH`               VARCHAR(60)      DEFAULT NULL COMMENT '受托支付对象账号；PK。必须填最终支付对象的收款账号，不可填中间过渡账户或清算账户，优先填报外部账号。银团贷款受托支付对象账号可为发起行内部账号',
  `STZFDXXM`               VARCHAR(450)     DEFAULT NULL COMMENT '受托支付对象行名；必须填最终支付对象的银行机构名称，跨境交易行名按实际填写(可接受英文)，不可填中间过渡账户或清算账户。支付到第三方平台账户的，填写第三方平台名称。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；营业机构、管理机构必须填报金融许可证号，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；关联数据项：信贷合同表.信贷合同号',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `STZFRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '受托支付日期；指该笔受托支付实际划转给交易对手的日期。',
  `STZFDXHM`               VARCHAR(450)     DEFAULT NULL COMMENT '受托支付对象户名；必须填最终支付对象的户名，不可填中间过渡账户或清算账户。若交易对手为个人，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。其他情况则为非隐私，不做变形。如果为境内涉密机构的，填报为“*********”。',
  `STZFDXHH`               VARCHAR(30)      DEFAULT NULL COMMENT '受托支付对象行号；必须填最终支付对象的12位人行支付行号，分支机构如没有人行支付行号，可填写最近的上一级管理机构支付行号，不可填中间过渡账户或清算账户。跨境交易行号可填SWIFT编码。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `DKJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '贷款金额；借款人应还本金总额。票据填报票面金额，信用证填报信用证金额。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='受托支付信息表';
