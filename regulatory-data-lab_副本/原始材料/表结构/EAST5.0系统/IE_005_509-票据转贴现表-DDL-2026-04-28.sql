-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_509 票据转贴现表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_509`;
CREATE TABLE `IE_005_509` (
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；本行银行机构名称。关联数据项：机构信息表.银行机构名称',
  `ZTXLX`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '转贴现利息',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；PK。本行内部机构号。关联数据项：机构信息表.内部机构号',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；仅当转贴现类型为“转贴现买断”时需填报，其他情况填空值。按信贷合同号=信贷借据号=票据号码填报。关联数据项：信贷合同表.信贷合同号',
  `PJHM`                   VARCHAR(60)      DEFAULT NULL COMMENT '票据号码；PK。',
  `PJLX`                   VARCHAR(30)      DEFAULT NULL COMMENT '票据类型',
  `PMJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '票面金额',
  `CPRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '出票人名称',
  `TXRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '贴现人名称',
  `TXRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '贴现日期',
  `JYFX`                   VARCHAR(6)       DEFAULT NULL COMMENT '交易方向',
  `ZTXRQ`                  VARCHAR(8)       DEFAULT NULL COMMENT '转贴现日期',
  `ZTXJE`                  DECIMAL(20,2)    DEFAULT NULL COMMENT '转贴现金额；转贴现实付金额',
  `ZTXLL`                  DECIMAL(20,6)    DEFAULT NULL COMMENT '转贴现利率',
  `HGLV`                   DECIMAL(20,6)    DEFAULT NULL COMMENT '回购利率；“质押式回购正回购”、“质押式回购逆回购”、“买断式回购正回购”、“买断式回购逆回购”类业务，填报该字段，回购前如无法填报的可以置空。“转贴现买断”、“转贴现卖断”该字段置空。',
  `JYDSMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '交易对手名称；填报交易对手行全称。',
  `PJZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '票据状态；正常（票据未到期），卖断（转贴现卖断），解付（票据到期且出票人已付款），垫款（票据到期产生垫款），核销（贷款核销）。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；仅当转贴现类型为“转贴现买断”时需填报，其他情况填空值。按信贷合同号=信贷借据号=票据号码填报。关联数据项：个人信贷业务借据表.信贷借据号 或 对公信贷业务借据表.信贷借据号。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `PJCPRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '票据出票日期',
  `PJDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '票据到期日期',
  `CDRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '承兑人名称',
  `ZTXLB`                  VARCHAR(60)      DEFAULT NULL COMMENT '转贴现类别',
  `ZTXJXTS`                INT              DEFAULT NULL COMMENT '转贴现计息天数；转贴现实际计息天数',
  `HGRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '回购日期；约定回购/返售日期。“质押式回购正回购”、“质押式回购逆回购”、“买断式回购正回购”、“买断式回购逆回购”类业务，填报该字段。“转贴现买断”、“转贴现卖断”该字段可以为空。',
  `HGJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '回购金额；约定回购/返售总金额。“质押式回购正回购”、“质押式回购逆回购”、“买断式回购正回购”、“买断式回购逆回购”类业务，填报该字段，回购前如无法填报的可以置空。“转贴现买断”、“转贴现卖断”该字段置空。',
  `HGLX`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '回购利息；“质押式回购正回购”、“质押式回购逆回购”、“买断式回购正回购”、“买断式回购逆回购”类业务，填报该字段，回购前如无法填报的可以置空。“转贴现买断”、“转贴现卖断”该字段置空。',
  `JYDSHH`                 VARCHAR(30)      DEFAULT NULL COMMENT '交易对手行号；交易对手的银行机构代码，跨境交易行号可填SWIFT编码。对方账号和对方户名必须填实际收款人，不可填中间过渡账户或清算账户。交易对手是第三方支付平台的，可以为空。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='票据转贴现表';
