-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_003_303 收单商户信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_003_303`;
CREATE TABLE `IE_003_303` (
  `QSZHLB`                 VARCHAR(6)       DEFAULT NULL COMMENT '清算账户类别',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `SHMCCMC`                VARCHAR(450)     DEFAULT NULL COMMENT '商户MCC名称',
  `QSZH`                   VARCHAR(60)      DEFAULT NULL COMMENT '清算账号；PK。商户绑定的收款账号，以外部账号报送。外部账号报送规则参考个人活期存款分户账明细.对方账号。',
  `QSZHKHHMC`              VARCHAR(450)     DEFAULT NULL COMMENT '清算账号开户行名称；填报清算账号所属行名。第三方支付平台填写第三方支付平台名称。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；填报收集该商户的银行机构。营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；填报收集该商户的银行机构。关联数据项：机构信息表.内部机构号。填写商户归属的的银行机构。',
  `SHBH`                   VARCHAR(200)     DEFAULT NULL COMMENT '商户编号；PK.',
  `SHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '商户名称；对公客户填报商户注册登记证件上记载的法定名称全称。个人客户若未收集商户注册登记证件信息的，允许填报客户名称。',
  `SFPOS`                  VARCHAR(3)       DEFAULT NULL COMMENT '是否POS商户；若为POS商户填报为是，其他情况无pos终端的填报为否。',
  `ZDH`                    VARCHAR(60)      DEFAULT NULL COMMENT '终端号；PK。若为商户，填报终端号，其他情况允许为空。存在多个终端的，以多条报送。',
  `SHMCCM`                 VARCHAR(4)       DEFAULT NULL COMMENT '商户MCC码；特指银联MCC码，用于标明银联卡交易环境、所在商户的主营业务范围和行业归属的商户类别码。',
  `SHDQ`                   VARCHAR(150)     DEFAULT NULL COMMENT '商户地区；填报商户实际地址所在地区，若无法填报商户实际地址所在地区的，填报商户注册登记地址所在地区',
  `QSZHLX`                 VARCHAR(60)      DEFAULT NULL COMMENT '清算账号类型',
  `QSZHMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '清算账户名称；指POS绑定的商户收款账户名称',
  `QXRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '起效日期；商户生效日期',
  `SXRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '失效日期；商户失效或不可用的日期',
  `SHZT`                   VARCHAR(60)      DEFAULT NULL COMMENT '商户状态',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收单商户信息表';
