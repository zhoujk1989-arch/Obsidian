-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_006_601 表内外业务担保合同表
-- ============================================================

DROP TABLE IF EXISTS `IE_006_601`;
CREATE TABLE `IE_006_601` (
  `DBHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '担保合同号；PK。填报本担保合同的编号。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `DBLX`                   VARCHAR(60)      DEFAULT NULL COMMENT '担保类型',
  `DBJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '担保金额；对于一般担保合同，报送一般担保合同金额；对于最高额担保合同，报送最高额担保合同金额。',
  `DBDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '担保到期日期；担保关系解除的日期。',
  `DBHTZT`                 VARCHAR(6)       DEFAULT NULL COMMENT '担保合同状态',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `DBBZ`                   VARCHAR(3)       DEFAULT NULL COMMENT '担保币种；填报担保合同的币种，非被担保贷款的币种。',
  `DBQSRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '担保起始日期；担保关系开始的日期。',
  `JBRGH`                  VARCHAR(70)      DEFAULT NULL COMMENT '经办人工号；建立担保合同信息的员工号。自动办理的员工号允许为空。关联数据项：员工表.员工号。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `BDBYWLX`                VARCHAR(30)      DEFAULT NULL COMMENT '被担保业务类型',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；关联数据项：机构信息表.金融许可证号',
  `DBHTLX`                 VARCHAR(30)      DEFAULT NULL COMMENT '担保合同类型',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `BDBHTH`                 VARCHAR(100)     DEFAULT NULL COMMENT '被担保合同号；PK。填报本合同担保贷款的合同号。当被担保业务类型为表内信贷时，需关联数据项：信贷合同表.信贷合同号。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='表内外业务担保合同表';
