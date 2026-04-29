-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_508 票据贴现表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_508`;
CREATE TABLE `IE_005_508` (
  `TXRZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '贴现人账号；贴现人申请提款的外部账号',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `CDRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '承兑人名称；填写承兑人全称。银行承兑汇票填承兑行全称。',
  `PJDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '票据到期日期',
  `PJCPRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '票据出票日期',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `PJHM`                   VARCHAR(60)      DEFAULT NULL COMMENT '票据号码；PK。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；经办机构银行机构名称。关联数据项：机构信息表.银行机构名称',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填写经办机构金融许可证号。关联数据项：机构信息表.金融许可证号',
  `CPRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '出票人名称；填写出票人全称。',
  `PMJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '票面金额',
  `PJLX`                   VARCHAR(30)      DEFAULT NULL COMMENT '票据类型',
  `XDJJH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷借据号；PK。票据贴现业务没有借据号的，填报为信贷借据号=票据号码。关联数据项：个人信贷业务借据表.信贷借据号 或 对公信贷业务借据表.信贷借据号。',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；PK。票据贴现业务没有信贷合同编号的，填报为信贷合同号=票据号码。关联数据项：信贷合同表.信贷合同号。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；PK。经办机构内部机构号。关联数据项：机构信息表.内部机构号',
  `PJZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '票据状态；正常（票据未到期），卖断（转贴现卖断），解付（票据到期且出票人已付款），垫款（票据到期产生垫款），核销（贷款核销）。',
  `TXL`                    DECIMAL(20,6)    DEFAULT NULL COMMENT '贴现利率',
  `TXRKHHMC`               VARCHAR(450)     DEFAULT NULL COMMENT '贴现人开户行名称；贴现人申请提款的开户行全称',
  `TXRMC`                  VARCHAR(450)     DEFAULT NULL COMMENT '贴现人名称；填报申请办理贴现的贴现人全称。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `TXLX`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '贴现利息',
  `TXJXTS`                 INT              DEFAULT NULL COMMENT '贴现计息天数',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `TXRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '贴现日期',
  `TXJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '贴现金额；贴现实付金额。',
  `TXRKHTYBH`              VARCHAR(70)      DEFAULT NULL COMMENT '贴现人客户统一编号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='票据贴现表';
