/*
业务目标：
- 待填写：说明这段 SQL/存储过程要解决的业务需求。

目标系统：
- 待填写：例如 一表通系统 / EAST5.0系统 / 监管集市系统。

目标产物：
- 待填写：查询 SQL / insert select / 存储过程 / 视图 / 校验 SQL。

依赖知识页：
- 待填写：[[数据表-...]]
- 待填写：[[血缘-...]]
- 待填写：[[报表-...]]
- 待填写：[[来源-...]]

源表：
- 待填写：业务表名或技术表名，说明角色。

目标表或输出：
- 待填写：目标表名或输出字段清单。

参数：
- ${biz_date}：跑批日期或数据日期，格式待确认。
- ${org_id}：机构范围，按需使用。

运行方式：
- 待填写：全量刷新 / 截面重跑 / 增量追加 / 查询分析。

未确认点：
- 待填写：字段缺口、码值缺口、日期口径、监管口径或性能约束。
*/

/* 1. 参数区
   按目标数据库方言替换变量写法；数据库方言不明确时，保留占位符。
*/
-- 示例：
-- ${biz_date} = 'YYYY-MM-DD'

/* 2. 清理区
   如为落地脚本，delete 范围必须与 insert 范围一致。
*/
-- delete from target_table
--  where data_date = ${biz_date};

/* 3. 主加工区
   默认使用直接 select + left join。
   只查询实际使用字段，不使用 select *。
   非必要不使用 with / CTE；只有在先聚合、窗口去重或中间结果复用时才使用。
*/
/* 4. 落地区或输出区
   insert 目标字段顺序必须与目标表 DDL、数据表页或用户指定顺序一致。
*/
select
    -- 主表字段：只保留业务实际需要的字段
    main.business_key,
    main.data_date,
    -- 关联补充字段：说明业务含义和来源依据
    dim.dim_name
from main_table main
left join dim_table dim
       on main.dim_id = dim.dim_id
      and dim.data_date = ${biz_date}
where main.data_date = ${biz_date};

/* 5. 校验区
   交付时建议另存为 CHECK_<需求名>_校验.sql；简单场景可保留在同文件末尾。
*/
-- 行数检查：
-- select count(*) as target_count
-- from target_table
-- where data_date = ${biz_date};

-- 主键重复检查：
-- select business_key, count(*) as cnt
-- from target_table
-- where data_date = ${biz_date}
-- group by business_key
-- having count(*) > 1;

-- 必填为空检查：
-- select count(*) as null_required_count
-- from target_table
-- where data_date = ${biz_date}
--   and business_key is null;

-- 码值越界检查：
-- select code_field, count(*) as cnt
-- from target_table
-- where data_date = ${biz_date}
-- group by code_field
-- order by code_field;
