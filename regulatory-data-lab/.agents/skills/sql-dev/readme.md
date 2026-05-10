---
type: concept
id: 目录说明-agents-skills-sql-dev
status: validated
updated: 2026-05-10
tags:
  - regulatory
  - concept
---

# sql-dev技能目录说明

## 目录职责

本目录保存 SQL 开发技能说明，用于生成、修复、校准 SQL、存储过程、视图和校验脚本。

## 应包含

- SQL 开发的证据读取、字段映射、血缘回写和验证要求。
- 可复用脚本、示例或模板引用。

## 不应包含

- 具体系统的 SQL 草案。
- 正式数据表页、报表页或血缘页。
- 没有证据链的 SQL 生成偏好。

## 联动要求

SQL 开发技能必须服务于 `.agents/workflows/SQL开发.md`，生成的 SQL 进入 `sql/<系统名>/`，知识结论回写到对应正式知识对象。
