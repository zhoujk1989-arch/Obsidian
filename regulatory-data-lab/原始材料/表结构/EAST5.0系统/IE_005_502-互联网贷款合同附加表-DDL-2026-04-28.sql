-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_502 互联网贷款合同附加表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_502`;
CREATE TABLE `IE_005_502` (
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；PK。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `ZZRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '授权终止日期；客户签署的数据授权终止日期。根据银行或合作方授权系统自定义。未签订授权书的填00000000。协议约定数据授权随相关业务终止而消灭的，填约定业务的最后到期日期；约定业务无最后到期日期的，填99991231，约定业务已终止的，填00000000。协议约定永久授权的，填99991231。',
  `SQSBH`                  VARCHAR(300)     DEFAULT NULL COMMENT '客户数据授权书编号；不允许为空。客户与银行（或合作方）签订的数据授权书编号。数据授权书指各类经客户签署同意，内容标明允许银行（或合作方)在规定范围内使用客户相关信息的文书。签署多份授权书的，填覆盖该互联网贷款业务线上审批所需授权的、生效期内的最新授权书编号。',
  `HZFZRJE`                DECIMAL(20,2)    DEFAULT NULL COMMENT '合作方责任金额；在该笔互联网贷款合同中约定（或经合作协议相关条款换算），该合作协议编号对应的一个或多个合作方负有出资、担保责任的总金额。业务模式为“独立”时填0。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `YWMS`                   VARCHAR(6)       DEFAULT NULL COMMENT '业务模式；签订了互联网贷款合作协议的，填“合作”，未签订填“独立”。',
  `SXRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '授权生效日期；客户数据授权生效日期。根据银行或合作方授权系统自定义。',
  `LXDH`                   VARCHAR(70)      DEFAULT NULL COMMENT '申请人联系电话；线上申请互联网贷款所留手机号码或者区号-固定电话号码。按规则脱敏。',
  `HZXYBH`                 VARCHAR(200)     DEFAULT NULL COMMENT '合作协议编号；PK。业务模式为“独立”时填“无”，为“合作”时填合作协议编号。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；关联数据项：机构信息表.银行机构名称',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；合同所属机构金融许可证号。',
  `HTZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '合同状态；互联网贷款合同的状态，与所关联信贷合同表的合同状态一致。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='互联网贷款合同附加表';
