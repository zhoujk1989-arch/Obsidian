-- ============================================================
-- EAST 表结构建表脚本拆分文件
-- 来源: 用户提供 eastttt.xlsx 自动生成 DDL
-- 生成时间: 2026-04-28 03:38:32
-- 拆分时间: 2026-04-28
-- 表: IE_005_501 信贷合同表
-- ============================================================

DROP TABLE IF EXISTS `IE_005_501`;
CREATE TABLE `IE_005_501` (
  `KHJLGH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户经理工号；关联数据项：员工表.工号。',
  `GSFZJG`                 VARCHAR(200)     DEFAULT NULL COMMENT '归属分支机构',
  `HTJE`                   DECIMAL(20,2)    DEFAULT NULL COMMENT '合同金额',
  `XDYWZL`                 VARCHAR(150)     DEFAULT NULL COMMENT '信贷业务种类；一般固定资产贷款指除了项目贷款外的固定资产贷款。个人经营性贷款不包括个人商用房贷款，消费贷款不包括住房按揭贷款、汽车贷款、助学贷款。',
  `ZHTH`                   VARCHAR(100)     DEFAULT NULL COMMENT '主合同号；此项填写信贷合同对应的主合同号，如果没有主合同则填报此记录的信贷合同号，不可为空。',
  `KHTYBH`                 VARCHAR(70)      DEFAULT NULL COMMENT '客户统一编号；如包含个人身份证件号码，则为隐私，银行机构需做变形，变形规则见《采集技术接口说明》。',
  `SENSITIVEFLAG`          VARCHAR(30)      DEFAULT NULL COMMENT '涉密标志',
  `NBJGH`                  VARCHAR(30)      DEFAULT NULL COMMENT '内部机构号；关联数据项：机构信息表.内部机构号',
  `HTDKYT`                 VARCHAR(1500)    DEFAULT NULL COMMENT '合同贷款用途；填报信贷合同中约定的贷款用途，非借据贷款用途。票据、信用证等填报贸易交易内容。',
  `HTDQRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同到期日期；合同原始到期日期。',
  `HTQSRQ`                 VARCHAR(8)       DEFAULT NULL COMMENT '合同起始日期；若合同约定签订日生效，则填写签订日日期，若合同约定非签订日生效，则填写约定的生效日期。',
  `BZ`                     VARCHAR(3)       DEFAULT NULL COMMENT '币种',
  `HTMC`                   VARCHAR(300)     DEFAULT NULL COMMENT '合同名称；必填项。',
  `XDHTH`                  VARCHAR(100)     DEFAULT NULL COMMENT '信贷合同号；PK。当业务为票据贴现和买断式转贴现时，可以填报为信贷合同号=信贷借据号=票据号码；对于其他若没有对应合同号的业务，可以填报为信贷合同号=信贷借据号=业务编号',
  `KHMC`                   VARCHAR(450)     DEFAULT NULL COMMENT '客户名称；关联数据项：个人基础信息表.客户姓名 或 对公客户信息表.客户名称',
  `JRXKZH`                 VARCHAR(30)      DEFAULT NULL COMMENT '金融许可证号；营业机构、管理机构必须填报“金融许可证号”，内设机构、虚拟机构及营业部取本级或上一级管理机构的金融许可证号，优先取本级。',
  `BBZ`                    VARCHAR(600)     DEFAULT NULL COMMENT '备注；描述其他字段未能详尽说明的情况，或标注对本条报送记录的特殊说明（如视需要可用于说明各种不满足检核规则的例外情况：客户信息表中可标注“境外客户”“客户已工商注销”“客户名下账户均已管控”，信贷分户账中可标注“线上化业务”“自助类贷款”等）。不同备注事项用英文半角分号隔开。',
  `KHLB`                   VARCHAR(6)       DEFAULT NULL COMMENT '客户类别',
  `CJRQ`                   VARCHAR(8)       DEFAULT NULL COMMENT '采集日期；PK。采集日期指该期（批次）数据报送的期末日期，例如：按日采集的表，采集日期应为每日；按月采集的表，采集日期应为月末最后一天；以此类推。有特殊报送要求的，应以报送要求的截至日期为采集日期。',
  `HTZT`                   VARCHAR(30)      DEFAULT NULL COMMENT '合同状态',
  `DBLX`                   VARCHAR(60)      DEFAULT NULL COMMENT '担保类型'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='信贷合同表';
