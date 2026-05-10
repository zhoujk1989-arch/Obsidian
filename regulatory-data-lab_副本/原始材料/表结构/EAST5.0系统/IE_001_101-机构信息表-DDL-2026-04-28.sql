-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_001_101 机构信息表
-- ============================================================

DROP TABLE IF EXISTS `IE_001_101`;
CREATE TABLE `IE_001_101` (
  `FZRLXDH`                VARCHAR(70)      DEFAULT NULL COMMENT '负责人联系电话；负责人联系电话，区号-座机电话/手机，虚拟机构、自助银行及自助设备机构、机构本部和仅承担内部核算职能的机构可为空。非隐私，不做变形',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `JGLB`                   VARCHAR(30)      DEFAULT NULL COMMENT '机构类别；仅允许填报为：管理机构，营业机构，虚拟机构，内设机构。各行根据实际情况进行映射：管理机构：总行、一级分行、专营机构；营业机构：除总行、一级分行、专营机构以外的有金融许可证的实体机构。专营机构分支机构作为营业机构。营业部也作为营业机构，若无金融许可证号则填报上一级管理机构的金融许可证号；虚拟机构：具有单独标识、分账核算体系、独立出表的非实体机构，如自由贸易专用账务核算体系（FTU-Free Trade Accounting Unit）；内设机构：如清算中心等内设部门。',
  `CLRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '成立日期；填报银保监会及其派出机构批复成立的日期',
  `JGDZ`                   VARCHAR(600)     DEFAULT NULL COMMENT '机构地址；虚拟机构可为空',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；PK',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；内设机构、虚拟机构及营业部如有金融许可证的填写金融许可证号，没有金融许可证的取上一级管理机构的金融许可证号。',
  `YYZZH`                  VARCHAR(60)      DEFAULT NULL COMMENT '营业执照号；内设机构、虚拟机构及营业部如有营业执照的填写营业执照号，没有营业执照的取上一级管理机构的营业执照号。',
  `YHJGMC`                 VARCHAR(450)     DEFAULT NULL COMMENT '银行机构名称；需填写全称，有金融许可证号的需与金融许可证上的机构名称保持一致。例如：应填报“XX银行股份有限公司XX省分行”，不应填报为“XX省分行”。无独立金融机构许可证的机构，可在本名称中体现出机构特征。',
  `XZQHDM`                 VARCHAR(6)       DEFAULT NULL COMMENT '行政区划代码；营业机构、管理机构必须填报实际的“行政区划代码”（要求到区县一级，6位代码），内设机构、虚拟机构，营业部取本级或上一级管理机构的行政区划代码，优先取本级。',
  `YYZT`                   VARCHAR(6)       DEFAULT NULL COMMENT '营业状态；营业：正常、拟撤销等状态的机构停业：歇业、筹建中等状态的机构',
  `JGLXDH`                 VARCHAR(70)      DEFAULT NULL COMMENT '机构联系电话；机构办公联系电话，区号-座机电话，虚拟机构、自助银行及自助设备机构、机构本部和仅承担内部核算职能的机构可为空。非隐私，不做变形。',
  `FZRXM`                  VARCHAR(150)     DEFAULT NULL COMMENT '负责人姓名；非隐私，不做变形。虚拟机构、自助银行及自助设备机构、机构本部和仅承担内部核算职能的机构可为空。',
  `FZRZW`                  VARCHAR(150)     DEFAULT NULL COMMENT '负责人职务；虚拟机构、自助银行及自助设备机构、机构本部和仅承担内部核算职能的机构可为空。',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `YHJGDM`                 VARCHAR(30)      DEFAULT NULL COMMENT '银行机构代码；需填报人行大小额支付系统中登记的“人行支付行号”；允许多个内部机构号对应同一个“人行支付行号”；该字段不可为空，内设机构、虚拟机构等无“人行支付行号”的，填报本级或上一级机构的“人行支付行号”，优先填本级。'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='机构信息表';
