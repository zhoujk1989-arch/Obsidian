# 内部分户账明细记录 - 取数逻辑需求文档

> 本文档由《附件2：“一表通”转换EAST映射规则.xls》自动整理生成。用途：依据字段映射规则梳理取数来源、关联关系、过滤条件与字段转换逻辑。

## 1. 目标

- 目标 EAST 表：`内部分户账明细记录`
- 数据表代码：`NBFHZMX`
- 数据表编号：`408`
- 主题：会计记账信息
- 报送模式：增量表，报送上一采集日至采集日期间新增的数据。
- 报送要求：根据会计核算科目，除单列账之外的科目原则上都归入内部账采集；单列账报送至信用卡、对公/个人等分户账中；资本账户需要报送。
- 主要来源表：0、EAST.内部分户账、内部分户账交易、内部科目对照表

## 2. 表级取数与关联规则

### 2.1 表级规则（Excel第 469 行）

主表：【内部分户账交易】
左关联：【EAST.内部分户账】
关联条件：【内部分户账交易】.【分户账号】 = 【EAST.内部分户账】.【分户账号】
左关联：【EAST.内部科目对照表】
关联条件：【客户存款账户交易表】【科目ID】，关联【EAST.内部科目对照表】的【会计科目编号】

## 3. 字段取数逻辑清单

| 序号 | EAST目标字段 | 一表通来源表 | 一表通来源字段 | 规则类型 | 映射/转换规则 | 数据元格式 |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | 交易序列号 | 内部分户账交易 | 交易ID | 直接映射 | 直接映射：【内部分户账交易 BS_JY_NBFHZJY】.【交易ID JYID】 | C..100 |
| 2 | 金融许可证号 | EAST.内部分户账 | 金融许可证号 | 直接映射 | 直接映射：T2.【金融许可证号 JRXKZH】 | C..30 |
| 3 | 内部机构号 | EAST.内部分户账 | 内部机构号 | 直接映射 | 直接映射：T2.【内部机构号 NBJGH】 | C..30 |
| 4 | 银行机构名称 | EAST.内部分户账 | 银行机构名称 | 直接映射 | 直接映射：T2.【银行机构名称 YHJGMC】 |  |
| 5 | 明细科目编号 | 内部分户账交易 | 科目ID | 直接映射 | 直接映射：【内部分户账交易 BS_JY_NBFHZJY】.【科目ID KMID】 |  |
| 6 | 明细科目名称 | 内部科目对照表 | 会计科目名称 | 直接映射 | 直接映射:T7.【会计科目名称 KJKMMC】 |  |
| 7 | 账户名称 | EAST.内部分户账 | 账户名称 | 直接映射 | 直接映射：T2.【账户名称 ZHMC】 | C..450 |
| 8 | 内部分户账账号 | 内部分户账交易 | 分户账号 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【分户账号 FHZH】 |  |
| 9 | 核心交易日期 | 内部分户账交易 | 核心交易日期 | 转换映射 | 加工映射：格式由YYYY-MM-DD转化成YYYYMMDD |  |
| 10 | 核心交易时间 | 内部分户账交易 | 核心交易时间 | 加工映射 | 加工映射：REPLACE(T1.HXJYSJ,':','') |  |
| 11 | 币种 | 内部分户账交易 | 币种 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【币种 BZ】 | C3 |
| 12 | 交易类型 | 内部分户账交易 | 交易类型 | 转换映射 | 码值转化：CASE WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '01' THEN '转账'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '02' THEN '取现'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '03' THEN '存现'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '04' THEN '消费'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '05' THEN '代发'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '06' THEN '代扣'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '07' THEN '代缴'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '08' THEN '结息'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '09' THEN '批量交易'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '10' THEN '贷款发放'<br>            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '11' THEN '贷款还本'<br>   WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '12' THEN '贷款还息'<br>   WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '13' THEN '银证业务'<br>   WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '14' THEN '投资理财'<br>   WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 like  '00%' THEN replace(【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】,'00','其他')<br>        END | C..60 |
| 13 | 交易借贷标志 | 内部分户账交易 | 借贷标识 | 转换映射 | 码值转化：<br>01 借<br>02 贷<br>03 借贷并列 <br>其他赋值  '' | C3 |
| 14 | 交易金额 | 内部分户账交易 | 交易金额 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【交易金额 JYJE】 |  |
| 15 | 借方余额 | 内部分户账交易 | 借方余额 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【借方余额 JFYE】 |  |
| 16 | 贷方余额 | 内部分户账交易 | 贷方余额 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【贷方余额 DFYE】 |  |
| 17 | 对方账号 | 内部分户账交易 | 对方账号 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【对方账号 DFZH】 |  |
| 18 | 对方科目编号 | 内部分户账交易 | 对方科目ID编号 | 直接映射 | 直接映射：【内部分户账交易 BS_JY_NBFHZJY】.【对方科目ID DFKMID】 |  |
| 19 | 对方科目名称 | 内部科目对照表 | 会计科目名称 | 直接映射 | 直接映射:T8.【会计科目名称 KJKMMC】 |  |
| 20 | 对方户名 | 内部分户账交易 | 对方户名 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【对方户名 DFHUM】 |  |
| 21 | 对方行号 | 内部分户账交易 | 对方账号行号 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【对方行号 DFZHHH】 |  |
| 22 | 对方行名 | 内部分户账交易 | 对方行名 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【对方行名 DFHAM】 |  |
| 23 | 摘要 | 内部分户账交易 | 摘要 | 直接映射 | 直接映射:【内部分户账交易 BS_JY_NBFHZJY】.【摘要 ZY】 | C..600 |
| 24 | 冲补抹标志 | 内部分户账交易 | 冲补抹标识 | 转换映射 | 码值转化：<br>01 正常<br>02 冲补抹 | C..9 |
| 25 | 交易渠道 | 内部分户账交易 | 交易渠道 | 转换映射 | 码值转化：CASE WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '01' THEN '柜面' <br>    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '02' THEN 'ATM'<br>    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '03' THEN 'VTM'<br>    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '04' THEN 'POS'<br>    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '05' THEN '网银'<br>    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '06' THEN '手机银行'<br>    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 LIKE '07%' THEN replace(【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】,'07','第三方支付')<br>    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '08' THEN '银联交易'<br>    ELSE replace(【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】,'00','其他') END | C..60 |
| 26 | 现转标志 | 内部分户账交易 | 现转标识 | 转换映射 | 码值转化：<br>01 现<br>02 转<br>ELSE '' | C3 |
| 27 | 交易柜员号 | 内部分户账交易 | 经办员工ID | 加工映射 | 加工映射：【内部分户账交易 BS_JY_NBFHZJY】.【经办员工ID JBYGID】，如为“自动”则转为空，否则取原值 |  |
| 28 | 授权柜员号 | 内部分户账交易 | 授权员工ID | 加工映射 | 加工映射：【内部分户账交易 BS_JY_NBFHZJY】.【授权员工ID SQYGID】，如为“自动”则转为空，否则取原值 |  |
| 29 | 进账日期 | 内部分户账交易 | 进账日期 | 转换映射 | 加工映射：格式由YYYY-MM-DD转化成YYYYMMDD |  |
| 30 | 销账日期 | 内部分户账交易 | 销账日期 | 转换映射 | 加工映射：格式由YYYY-MM-DD转化成YYYYMMDD |  |
| 31 | 备注 | 内部分户账交易 | 备注 | 加工映射 | 提取一表通《表7.10内部分户账交易》》备注，如有多项，以英文分隔符';'拼接 | C..600 |
| 32 | 采集日期 | 0 | 0 | 直接映射 | 直接映射：REPLACE('${TXNDATE}','-','') |  |

## 4. 字段级取数逻辑说明

### 4.1 日期类字段

- `核心交易日期`：加工映射：格式由YYYY-MM-DD转化成YYYYMMDD
- `进账日期`：加工映射：格式由YYYY-MM-DD转化成YYYYMMDD
- `销账日期`：加工映射：格式由YYYY-MM-DD转化成YYYYMMDD
- `采集日期`：直接映射：REPLACE('${TXNDATE}','-','')

### 4.2 码值/枚举转换字段

- `核心交易日期`：加工映射：格式由YYYY-MM-DD转化成YYYYMMDD
- `交易类型`：码值转化：CASE WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '01' THEN '转账'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '02' THEN '取现'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '03' THEN '存现'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '04' THEN '消费'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '05' THEN '代发'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '06' THEN '代扣'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '07' THEN '代缴'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '08' THEN '结息'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '09' THEN '批量交易'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '10' THEN '贷款发放'
            WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '11' THEN '贷款还本'
   WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '12' THEN '贷款还息'
   WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '13' THEN '银证业务'
   WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 = '14' THEN '投资理财'
   WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】 like  '00%' THEN replace(【内部分户账交易 BS_JY_NBFHZJY】.【交易类型 JYLX】,'00','其他')
        END
- `交易借贷标志`：码值转化：
01 借
02 贷
03 借贷并列 
其他赋值  ''
- `冲补抹标志`：码值转化：
01 正常
02 冲补抹
- `交易渠道`：码值转化：CASE WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '01' THEN '柜面' 
    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '02' THEN 'ATM'
    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '03' THEN 'VTM'
    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '04' THEN 'POS'
    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '05' THEN '网银'
    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '06' THEN '手机银行'
    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 LIKE '07%' THEN replace(【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】,'07','第三方支付')
    WHEN 【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】 = '08' THEN '银联交易'
    ELSE replace(【内部分户账交易 BS_JY_NBFHZJY】.【交易渠道 JYQD】,'00','其他') END
- `现转标志`：码值转化：
01 现
02 转
ELSE ''
- `进账日期`：加工映射：格式由YYYY-MM-DD转化成YYYYMMDD
- `销账日期`：加工映射：格式由YYYY-MM-DD转化成YYYYMMDD
