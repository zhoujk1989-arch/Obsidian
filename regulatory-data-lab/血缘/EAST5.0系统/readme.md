---
type: concept
id: 目录说明-血缘-EAST5.0系统
status: validated
updated: 2026-05-10
tags:
  - regulatory
  - concept
---

# EAST5.0系统血缘目录说明

## 目录职责

本目录保存 EAST5.0 系统 SQL 加工链路、结果表血缘和跨表依赖页面。

## 应包含

- EAST5.0 报表结果表的源表、目标表和字段级映射。
- 存储过程或视图中的过滤条件、JOIN 条件、派生逻辑和码值转换。
- 与 EAST5.0 数据表页、报表业务口径页、SQL 文件的互链。
- Open Questions 中保留未跑数、未语法验证或业务待确认问题。

## 不应包含

- 存储过程全文。
- 结果表字段字典全文。
- 缺乏 SQL 证据的字段级边。

## 状态判断

只完成草案抽取但未完成字段级核对时保持 `draft`。确认 SQL、证据、双向互链和日志闭环后，才可评估 `validated`。
