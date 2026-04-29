# 对公存款分户账明细记录 - 取数逻辑需求文档

> 本文档由《附件2：“一表通”转换EAST映射规则.xls》自动整理生成。用途：依据字段映射规则梳理取数来源、关联关系、过滤条件与字段转换逻辑。

## 1. 目标

- 目标 EAST 表：`对公存款分户账明细记录`
- 数据表代码：`DGCKFHZMX`
- 数据表编号：`406`
- 主题：会计记账信息
- 报送模式：增量表，报送上一采集日至采集日期间新增的数据。
- 报送要求：除计息、扣利息税外，所有影响对公存款账户余额变动的交易信息，包括结息交易，不包括查询交易。
- 主要来源表：0、EAST.内部科目对照表、EAST.对公存款分户账、EAST.机构信息表、客户存款账户交易

## 2. 表级取数与关联规则

### 2.1 表级规则（Excel第 415 行）

主表：【客户存款账户交易表】
 内关联1：【EAST.对公存款分户账】
 关联条件1：【客户存款账户交易表】【分户账号】=【EAST.对公存款分户账】【分户账号】
 AND 【客户存款账户交易表】【币种】=【分户账号】【币种】
 AND CASE WHEN 【客户存款账户交易表】【币种】 = 'CNY' THEN '人民币'   WHEN 【客户存款账户交易表】【钞汇类别】 = '01' THEN '钞' WHEN 【客户存款账户交易表】【钞汇类别】 = '02' THEN '汇' WHEN 【客户存款账户交易表】【钞汇类别】 = '03' THEN '可钞可汇'  =【个人存款分户账】【钞汇类别】
 左关联：【EAST.机构信息表】
 关联条件：【客户存款账户交易表】【内部机构号】关联【EAST.机构信息表】【内部机构号】  
 左关联：【EAST.内部科目对照表】
 关联条件：【客户存款账户交易表】【科目ID】，关联【EAST.内部科目对照表】的【会计科目编号】
 左关联：【EAST.对公存款分户账】
 关联条件：【客户存款账户交易表】【客户ID】，关联【EAST.对公存款分户账】的【统一客户编号】

## 3. 字段取数逻辑清单

| 序号 | EAST目标字段 | 一表通来源表 | 一表通来源字段 | 规则类型 | 映射/转换规则 | 数据元格式 |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | 交易序列号 | 客户存款账户交易 | 交易ID | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【交易ID JYID】 | C..100 |
| 2 | 金融许可证号 | EAST.机构信息表 | 金融许可证号 | 直接映射 | 直接映射：T8.【金融许可证号 JRXKZH】 | C..30 |
| 3 | 内部机构号 | 客户存款账户交易 | 入账机构ID | 加工映射 | 加工映射：SUBSTR(【客户存款账户交易 BS_JY_KHZZJY】.【入账机构ID JYJGID】,12) | C..30 |
| 4 | 业务办理机构号 | 客户存款账户交易 | 交易机构ID | 加工映射 | 加工映射：SUBSTR(【客户存款账户交易表 BS_JY_KHZZJY】.【交易机构ID JYJGID】,12) |  |
| 5 | 银行机构名称 | EAST.机构信息表 | 银行机构名称 | 直接映射 | 直接映射：T8.【银行机构名称 YHJGMC】 |  |
| 6 | 明细科目编号 | 客户存款账户交易 | 科目ID | 加工映射 | 加工映射：COALESCE(【客户存款账户交易表 BS_JY_KHZZJY】.【科目ID KMID】,【对公存款分户账 T_EAST_YBT_DGCKFHZ】.【明细科目编号 MXKMBH】) |  |
| 7 | 明细科目名称 | EAST.内部科目对照表 | 会计科目名称 | 直接映射 | 直接映射：【内部科目对照表 T_EAST_YBT_NBKMDZB】.【会计科目名称 KJKMMC】 |  |
| 8 | 客户统一编号 | 客户存款账户交易 | 客户ID | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【客户ID KHID】 | C..60 |
| 9 | 账户名称 | EAST.对公存款分户账 | 账户名称 | 直接映射 | 直接映射：T2.【账户名称 ZHMC】 | C..450 |
| 10 | 对公存款账号 | 客户存款账户交易 | 分户账号 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【分户账号 FHZH】 |  |
| 11 | 外部账号 | 客户存款账户交易 | 外部账号（交易介质号） | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【外部账号 WBZH】 | C..60 |
| 12 | 交易类型 | 客户存款账户交易 | 账户交易类型 | 转换映射 | 码值转化：CASE WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '01' THEN '转账'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '02' THEN '取现'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '03' THEN '存现'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '04' THEN '消费'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '05' THEN '代发'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '06' THEN '代扣'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '07' THEN '代缴'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '08' THEN '结息'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '09' THEN '批量交易'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '10' THEN '贷款发放'<br>            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '11' THEN '贷款还本'<br>   WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '12' THEN '贷款还息'<br>   WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '13' THEN '银证业务'<br>   WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '14' THEN '投资理财'<br>   WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 like  '00%' THEN replace(【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】,'00','其他')<br>        END | C..60 |
| 13 | 交易借贷标志 | 客户存款账户交易 | 借贷标识 | 转换映射 | 码值转换：01 借<br>02 贷 | C3 |
| 14 | 核心交易日期 | 客户存款账户交易 | 核心交易日期 | 转换映射 | 加工映射：格式由YYYY-MM-DD转化成YYYYMMDD |  |
| 15 | 核心交易时间 | 客户存款账户交易 | 核心交易时间 | 加工映射 | 加工映射：REPLACE(【客户存款账户交易表 BS_JY_KHZZJY】.【核心交易时间 HXJYSJ,】,':','') |  |
| 16 | 币种 | 客户存款账户交易 | 币种 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【币种 BZ】 | C3 |
| 17 | 交易金额 | 客户存款账户交易 | 交易金额 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【交易金额 JYJE】 |  |
| 18 | 账户余额 | 客户存款账户交易 | 账户余额 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【账户余额 ZHYE】 |  |
| 19 | 对方账号 | 客户存款账户交易 | 对方账号 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【对方账号 DFZH】 |  |
| 20 | 对方户名 | 客户存款账户交易 | 对方户名 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【对方户名 HFHUM】 |  |
| 21 | 对方行号 | 客户存款账户交易 | 对方账号行号 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【对方账号行号 DFZHHH】 |  |
| 22 | 对方行名 | 客户存款账户交易 | 对方行名 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【对方行名 DFHM】 |  |
| 23 | 摘要 | 客户存款账户交易 | 交易摘要 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【交易摘要 JYZY】 | C..600 |
| 24 | 附言 | 客户存款账户交易 | 附言 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【附言】 | C..600 |
| 25 | 冲补抹标志 | 客户存款账户交易 | 冲补抹标识 | 转换映射 | 码值转化：当【客户存款账户交易表】.【冲补抹标识】='01'时，赋值'正常'<br>当【客户存款账户交易表】.【冲补抹标识】='02'时，赋值'冲补抹' <br> ELSE '' | C..9 |
| 26 | 现转标志 | 客户存款账户交易 | 现转标识 | 转换映射 | 码值转化：当【客户存款账户交易表】.【现转标识】='01'时，赋值'现'<br>当【客户存款账户交易表】.【现转标识】='02'时，赋值'转' <br>ELSE '' | C3 |
| 27 | 交易渠道 | 客户存款账户交易 | 交易渠道 | 转换映射 | 码值转化：CASE WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '01' THEN '柜面' <br>    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '02' THEN 'ATM'<br>    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '03' THEN 'VTM'<br>    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '04' THEN 'POS'<br>    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '05' THEN '网银'<br>    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '06' THEN '手机银行'<br>    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 LIKE '07%' THEN replace(【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】,'07','第三方支付')<br>    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '08' THEN '银联交易'<br>    ELSE replace(【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】,'00','其他') END | C..60 |
| 28 | IP地址 | 客户存款账户交易 | IP地址 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【IP地址 IPDZ】 | C..40 |
| 29 | MAC地址 | 客户存款账户交易 | MAC地址 | 直接映射 | 直接映射：【客户存款账户交易表 BS_JY_KHZZJY】.【MAC地址 MACDZ】 | C..60 |
| 30 | 交易柜员号 | 客户存款账户交易 | 经办员工ID | 加工映射 | 加工映射：如果【客户存款账户交易表 BS_JY_KHZZJY】.【经办员工ID JBYGID】为'自动'，则为''，否则为【客户存款账户交易表 BS_JY_KHZZJY】.【经办员工ID JBYGID】 |  |
| 31 | 授权柜员号 | 客户存款账户交易 | 授权员工ID | 加工映射 | 加工映射：【客户存款账户交易表 BS_JY_KHZZJY】.【授权员工ID SQYGID】，如为“自动”则转为空，否则取原值 |  |
| 32 | 备注 | 客户存款账户交易 | 备注 | 加工映射 | 提取一表通《表7.1客户存款账户交易》备注，如有多项，以英文分隔符';'拼接 | C..600 |
| 33 | 采集日期 | 0 | 0 | 加工映射 | 加工映射：REPLACE('${TXNDATE}','-','') |  |

## 4. 字段级取数逻辑说明

### 4.1 日期类字段

- `核心交易日期`：加工映射：格式由YYYY-MM-DD转化成YYYYMMDD
- `采集日期`：加工映射：REPLACE('${TXNDATE}','-','')

### 4.2 码值/枚举转换字段

- `交易类型`：码值转化：CASE WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '01' THEN '转账'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '02' THEN '取现'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '03' THEN '存现'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '04' THEN '消费'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '05' THEN '代发'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '06' THEN '代扣'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '07' THEN '代缴'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '08' THEN '结息'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '09' THEN '批量交易'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '10' THEN '贷款发放'
            WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '11' THEN '贷款还本'
   WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '12' THEN '贷款还息'
   WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '13' THEN '银证业务'
   WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 = '14' THEN '投资理财'
   WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】 like  '00%' THEN replace(【客户存款账户交易表 BS_JY_KHZZJY】.【账户交易类型 ZZJYLX】,'00','其他')
        END
- `交易借贷标志`：码值转换：01 借
02 贷
- `核心交易日期`：加工映射：格式由YYYY-MM-DD转化成YYYYMMDD
- `冲补抹标志`：码值转化：当【客户存款账户交易表】.【冲补抹标识】='01'时，赋值'正常'
当【客户存款账户交易表】.【冲补抹标识】='02'时，赋值'冲补抹' 
 ELSE ''
- `现转标志`：码值转化：当【客户存款账户交易表】.【现转标识】='01'时，赋值'现'
当【客户存款账户交易表】.【现转标识】='02'时，赋值'转' 
ELSE ''
- `交易渠道`：码值转化：CASE WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '01' THEN '柜面' 
    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '02' THEN 'ATM'
    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '03' THEN 'VTM'
    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '04' THEN 'POS'
    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '05' THEN '网银'
    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '06' THEN '手机银行'
    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 LIKE '07%' THEN replace(【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】,'07','第三方支付')
    WHEN 【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】 = '08' THEN '银联交易'
    ELSE replace(【客户存款账户交易表 BS_JY_KHZZJY】.【交易渠道 JYQD】,'00','其他') END
