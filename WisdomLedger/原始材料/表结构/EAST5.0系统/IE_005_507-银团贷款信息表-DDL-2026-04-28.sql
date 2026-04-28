-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_507 银团贷款信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_507`;
CREATE TABLE `IE_005_507` (
  `YTDKZJE`                DECIMAL(20,2)    DEFAULT NULL COMMENT '银团贷款总金额；填写银团贷款协议总额度。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `CJHHM`                  VARCHAR(4000)    DEFAULT NULL COMMENT '参加行行名；填写参贷行行名。有多个参贷行的，逐个填写，使用英文半角分号隔开。没有人行支付行号的，填报SWIFT行号。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `JJYE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '借据余额；以借据为最小颗粒，填写本借据本金余额（不含利息）。',
  `YFFCDDKJE`              DECIMAL(20,2)    DEFAULT NULL COMMENT '已发放承担贷款金额；填写本行实际已发的贷款金额。填报未结清的贷款总额，不填报循环发放累计金额。',
  `YFFDKJE`                DECIMAL(20,2)    DEFAULT NULL COMMENT '已发放银团贷款金额；填写银团实际已发的贷款金额。当代理参贷标志为“代理行”时不可为空。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `DLHHH`                  VARCHAR(600)     DEFAULT NULL COMMENT '代理行行号；填写代理行的人行支付行号。有多个代理行的，逐个填写，使用英文半角分号隔开。没有人行支付行号的，填报SWIFT行号。',
  `JKRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '借款人名称；如果借款人为对私客户，则为隐私，银行机构变形，变形规则见《采集技术接口说明》。如果借款人为对公客户，则为非隐私，不做变形。',
  `CJHHH`                  VARCHAR(600)     DEFAULT NULL COMMENT '参加行行号；填写参贷行的人行支付行号。有多个参贷行的，逐个填写，使用英文半角分号隔开。没有人行支付行号的，填报SWIFT行号。',
  `QTHHH`                  VARCHAR(600)     DEFAULT NULL COMMENT '牵头行行号；填写牵头行行号。有多个牵头行的，逐个填写，使用英文半角分号隔开。没有人行支付行号的，填报SWIFT行号。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。关联数据项：机构信息表.银行机构名称',
  `JKRBH`                  VARCHAR(70)      DEFAULT NULL COMMENT '借款人编号；关联数据项：对公客户信息表.客户统一编号',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。关联数据项：个人信贷业务借据.信贷借据号 或 对公信贷业务借据.信贷借据号。',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；PK。关联数据项：信贷合同表.信贷合同号',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `QTHHM`                  VARCHAR(3000)    DEFAULT NULL COMMENT '牵头行行名；填写牵头行行名。有多个牵头行的，逐个填写，使用英文半角分号隔开。',
  `JKRKHLB`                VARCHAR(6)       DEFAULT NULL COMMENT '借款人客户类别',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `JJJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '借据金额；以借据为最小颗粒，填写本借据放款金额。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `DLHHM`                  VARCHAR(3000)    DEFAULT NULL COMMENT '代理行行名；填写代理行行名。有多个代理行的，逐个填写，使用英文半角分号隔开。没有人行支付行号的，填报SWIFT行号。',
  `CDDKJE`                 DECIMAL(20,2)    DEFAULT NULL COMMENT '承担贷款金额；填写本行承担的银团贷款额度。',
  `DKZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '贷款状态',
  `YTCYLX`                 VARCHAR(60)      DEFAULT NULL COMMENT '银团成员类型；同时存在除参加行以外的多个银团成员类型的，以英文半角分号分隔填报。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='银团贷款信息表';
