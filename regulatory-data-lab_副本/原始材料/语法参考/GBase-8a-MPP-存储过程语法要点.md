# GBase 8a MPP 存储过程语法要点

> 本文件基于生产环境可运行的存储过程 `PROC_BSP_T_1_1_JGXX` 总结，供 EAST 等监管报表存储过程开发参考。

## 1. 过程定义

### 1.1 基本结构

```sql
CREATE PROCEDURE PROC_NAME(
    IN  I_PARAM1 VARCHAR(8),
    OUT O_RESULT INT,
    OUT O_MSG    VARCHAR(500)
)
BEGIN
    -- 过程体
END;
```

| 要点 | 说明 |
| --- | --- |
| 不需要 `DROP PROCEDURE IF EXISTS` | GBase 8a 支持自动重建，不需要先删除 |
| 不需要 `LANGUAGE` 子句 | 不要写 `LANGUAGE SQL`、`LANGUAGE PLBuiltin` 等 |
| 参数不支持 `DEFAULT` 默认值 | 默认值改在过程体内用 `IF P_PARAM IS NULL THEN` 处理 |
| 参数命名规范 | IN 参数用 `I_` 前缀，OUT 参数用 `O_` 前缀 |
| 结尾 | `END;` 后加分号 |

### 1.2 参数默认值处理

```sql
-- 错误：GBase 不支持参数默认值
CREATE PROCEDURE P_TEST(IN P_DATE VARCHAR(8) DEFAULT NULL)

-- 正确：过程体内处理
CREATE PROCEDURE P_TEST(IN I_DATE VARCHAR(8))
BEGIN
    IF I_DATE IS NULL OR LENGTH(TRIM(I_DATE)) = 0 THEN
        SET I_DATE = TO_CHAR(NOW(), 'YYYYMMDD');
    END IF;
END;
```

## 2. 变量声明

### 2.1 DECLARE 语法

```sql
#声明变量
DECLARE P_DATE      DATE;            #数据日期
DECLARE P_PROC_NAME VARCHAR(200);    #存储过程名称
DECLARE P_STATUS    INT;             #执行状态
DECLARE P_STEP_NO   INT;             #日志执行步骤
DECLARE P_DESCB     VARCHAR(200);    #日志执行步骤描述
```

- 所有 `DECLARE` 必须在 `BEGIN` 之后**最前面**，不能与语句混写
- 变量声明中**可以使用 `DEFAULT`**
- 变量名建议使用 `P_` 前缀（Process 变量）

### 2.2 变量赋值

```sql
#变量初始化
SET P_DATE = TO_DATE(I_DATE, 'YYYYMMDD');
SET P_PROC_NAME = 'PROC_BSP_T_1_1_JGXX';
SET P_STATUS = 0;
SET P_STEP_NO = 0;

-- 字符串拼接使用 ||
SET P_DESCB = '过程结束执行：删除 ' || V_DELETE_CNT || ' 行';
```

### 2.3 注释风格

```sql
#单行注释（GBase 8a 支持 # 风格）
DECLARE V_VAR INT;  -- 也支持 -- 风格

/* 多行注释 */
```

## 3. 控制流

### 3.1 IF ... ELSEIF ... ELSE ... END IF

```sql
IF P_STATUS = '1' THEN
    SET V_RESULT = '成功';
ELSEIF P_STATUS = '0' THEN
    SET V_RESULT = '失败';
ELSE
    SET V_RESULT = '未知';
END IF;
```

### 3.2 CASE 表达式

```sql
CASE
    WHEN org.A010008 IN ('0101', '0102') THEN '管理机构'
    WHEN org.A010008 IN ('0201', '0202', '0203') THEN '营业机构'
    ELSE NULL
END AS JGLB
```

### 3.3 WHILE 循环

```sql
DECLARE V_I INTEGER DEFAULT 1;

WHILE V_I <= 10 DO
    SET V_I = V_I + 1;
END WHILE;
```

## 4. 异常处理

### 4.1 EXIT HANDLER（生产环境写法）

```sql
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1
        P_SQLCDE = GBASE_ERRNO,
        P_SQLMSG = MESSAGE_TEXT,
        P_STATE  = RETURNED_SQLSTATE;
    SET P_STATUS = -1;
    SET P_START_DT = NOW();
    SET P_STEP_NO = P_STEP_NO + 1;
    SET P_DESCB = '程序异常';
    CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                          P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);
    ROLLBACK;
END;
```

| 要点 | 说明 |
| --- | --- |
| `GET DIAGNOSTICS CONDITION 1` | 使用 `CONDITION` 而非 `EXCEPTION` |
| `GBASE_ERRNO` | 获取 GBase 错误号 |
| 不写 `RESIGNAL` | 异常处理后直接回滚，不向上传递 |
| 记录日志 | 调用 `PROC_ETL_JOB_LOG` 记录异常信息 |

### 4.2 抛出异常

GBase 8a **不支持 `SIGNAL`**，用除零错误触发异常（会被 EXIT HANDLER 捕获）：

```sql
-- 错误：GBase 不支持
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '参数错误';

-- 正确：除零触发异常
SELECT 1 / 0;
```

## 5. 日期函数（生产环境写法）

### 5.1 日期转换

```sql
-- 字符串转日期
SET P_DATE = TO_DATE(I_DATE, 'YYYYMMDD');

-- 日期转字符串（YYYYMMDD 格式）
SET BEG_MON_DT = SUBSTR(I_DATE, 1, 6) || '01';
SET LAST_DT = TO_CHAR(TO_DATE(I_DATE, 'YYYYMMDD') - 1, 'YYYYMMDD');

-- 日期转字符串（YYYY-MM-DD 格式）
SELECT TO_CHAR(P_DATE, 'YYYY-MM-DD');

-- 日期转字符串（HH24MISS 格式，用于批次号）
SELECT TO_CHAR(NOW(), 'HH24MISS');
```

### 5.2 日期运算

```sql
-- 日期减 1 天
SET LAST_MON_DT = TO_CHAR(TO_DATE(BEG_MON_DT, 'YYYYMMDD') - 1, 'YYYYMMDD');

-- 季度计算
SET BEG_QUAR_DT = TO_CHAR(TO_DATE(I_DATE, 'YYYYMMDD'), 'YYYY')
                  || TRIM(TO_CHAR(QUARTER(TO_DATE(I_DATE, 'YYYYMMDD')) * 3 - 2, '00'))
                  || '01';
```

### 5.3 日期比较

```sql
-- 字符串日期比较（源表字段为字符串类型）
WHERE t.A010020 = TO_CHAR(P_DATE, 'YYYY-MM-DD')

-- 或直接用字符串
WHERE t.A010020 = I_DATE
```

## 6. 字符串函数

| 函数 | 说明 | 示例 |
| --- | --- | --- |
| `TRIM()` | 去空格 | `TRIM(col)` |
| `CONCAT()` | 拼接 | `CONCAT('A', 'B')` |
| `SUBSTR(str, p, n)` | 从位置 p 取 n 位 | `SUBSTR('20260429', 1, 6)` → `'202604'` |
| `LENGTH()` | 字符长度 | `LENGTH('abc')` → `3` |
| `TRIM(数字, '格式')` | 数字转字符串并填充 | `TRIM(TO_CHAR(QUARTER(...)*3-2, '00'))` |
| `||` | 字符串拼接符 | `'A' || 'B'` → `'AB'` |

### 6.1 日期格式校验

```sql
-- 用 LIKE 替代 REGEXP
IF I_DATE NOT LIKE '________' THEN
    -- GBase 不支持 SIGNAL，用除零触发异常
    SELECT 1 / 0;
END IF;
```

## 7. NULL 处理

```sql
-- 空值判断
IF I_PARAM IS NULL OR LENGTH(TRIM(I_PARAM)) = 0 THEN
    SET I_PARAM = '默认值';
END IF;

-- 空值替换
COALESCE(T1.FIELD, T2.FIELD)

-- 空字符串转 NULL
NULLIF(TRIM(col), '')
```

## 8. 事务控制

```sql
-- 不需要 START TRANSACTION，直接 DML + COMMIT
DELETE FROM target_table WHERE ...;
COMMIT;

INSERT INTO target_table SELECT ...;
COMMIT;

-- 异常时回滚（在 EXIT HANDLER 中）
ROLLBACK;
```

> 注意：生产环境写法不显式使用 `START TRANSACTION`，直接 DML + `COMMIT`。

## 9. 日志记录

### 9.1 PROC_ETL_JOB_LOG 调用

```sql
-- 过程开始
SET P_START_DT = NOW();
SET P_STEP_NO = P_STEP_NO + 1;
SET P_DESCB = '过程开始执行';
CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                      P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

-- 各步骤执行
SET P_START_DT = NOW();
SET P_STEP_NO = P_STEP_NO + 1;
SET P_DESCB = '清除数据';
-- DML 操作
COMMIT;
CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                      P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);
```

| 参数 | 说明 |
| --- | --- |
| P_DATE | 业务日期（DATE 类型） |
| P_PROC_NAME | 存储过程名 |
| P_STATUS | 执行状态（0=成功，-1=失败） |
| P_START_DT | 步骤开始时间 |
| NOW() | 步骤结束时间 |
| P_SQLCDE | 错误号（成功时为 NULL） |
| P_STATE | SQLSTATE 码（成功时为 NULL） |
| P_SQLMSG | 错误信息（成功时为 NULL） |
| P_STEP_NO | 步骤号 |
| P_DESCB | 步骤描述 |

## 10. 行计数

```sql
DELETE FROM target_table WHERE CJRQ = I_DATE;
-- 注意：GBase 8a 中 ROW_COUNT() 可能不可用，删除计数可不记录
```

## 11. 与之前文档的差异

| 特性 | 之前文档 | 生产环境实际 |
| --- | --- | --- |
| 异常诊断 | `GET DIAGNOSTICS EXCEPTION 1` | `GET DIAGNOSTICS CONDITION 1` |
| 错误号字段 | `RETURNED_SQLSTATE` | `GBASE_ERRNO` |
| 异常处理 | `RESIGNAL` 向上传递 | 不 `RESIGNAL`，直接 `ROLLBACK` |
| 日期转换 | `CAST(... AS DATE)` | `TO_DATE(..., '格式')` |
| 日期格式化 | `DATE_FORMAT(..., '%格式')` | `TO_CHAR(..., '格式')` |
| 当前时间 | `CURRENT_TIMESTAMP` | `NOW()` |
| 事务控制 | `START TRANSACTION` + `COMMIT` | 直接 DML + `COMMIT` |
| 日志过程 | `PROC_ETL_PROC_LOG` | `PROC_ETL_JOB_LOG` |
| 参数命名 | `P_` 前缀 | IN 用 `I_`，OUT 用 `O_` |
| 注释风格 | `--` | `#` 和 `--` 均可 |
| `LANGUAGE` | 写 `LANGUAGE SQL` | 不需要 |

## 12. 存储过程开发模板（生产环境风格）

```sql
CREATE PROCEDURE PROC_<NAME>(
    IN  I_PARAM1 VARCHAR(64),
    OUT O_RETCODE   INT,
    OUT O_REMESSAGE VARCHAR(500)
)
BEGIN
/******
    程序名称  ：<名称>
    程序功能  ：<描述>
    目标表：<表名>
    源表  ：<表名>
    创建人  ：<姓名>
    创建日期  ：<YYYYMMDD>
    版本号：V0.0.1
******/

  #声明变量
  DECLARE P_DATE      DATE;
  DECLARE P_PROC_NAME VARCHAR(200);
  DECLARE P_STATUS    INT;
  DECLARE P_START_DT  DATETIME;
  DECLARE P_STEP_NO   INT;
  DECLARE P_DESCB     VARCHAR(200);
  DECLARE P_SQLCDE    VARCHAR(200);
  DECLARE P_STATE     VARCHAR(200);
  DECLARE P_SQLMSG    VARCHAR(2000);

  #声明异常
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1
        P_SQLCDE = GBASE_ERRNO,
        P_SQLMSG = MESSAGE_TEXT,
        P_STATE  = RETURNED_SQLSTATE;
    SET P_STATUS = -1;
    SET P_START_DT = NOW();
    SET P_STEP_NO = P_STEP_NO + 1;
    SET P_DESCB = '程序异常';
    CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                          P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);
    ROLLBACK;
  END;

  #变量初始化
  SET P_DATE = TO_DATE(I_PARAM1, 'YYYYMMDD');
  SET P_PROC_NAME = 'PROC_<NAME>';
  SET P_STATUS = 0;
  SET P_STEP_NO = 0;

  #1.过程开始执行
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '过程开始执行';
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

  #2.清除数据
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '清除数据';
  DELETE FROM <target_table> WHERE ...;
  COMMIT;
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

  #3.插入数据
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '数据插入';
  INSERT INTO <target_table> SELECT ...;
  COMMIT;
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);

  #4.过程结束执行
  SET P_START_DT = NOW();
  SET P_STEP_NO = P_STEP_NO + 1;
  SET P_DESCB = '过程结束执行';
  CALL PROC_ETL_JOB_LOG(P_DATE, P_PROC_NAME, P_STATUS, P_START_DT, NOW(),
                        P_SQLCDE, P_STATE, P_SQLMSG, P_STEP_NO, P_DESCB);
  SET O_RETCODE = P_STATUS;
  SET O_REMESSAGE = P_DESCB;

END;
```
