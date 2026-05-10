---
type: concept
id: 目录说明-agents
status: validated
updated: 2026-05-10
tags:
  - regulatory
  - concept
---

# .agents目录说明

## 目录职责

本目录保存智能体执行本仓库工作的流程、规则和技能说明。

## 应包含

- `workflows/`：按用户意图组织的执行流程。
- `rules/`：跨流程生效的写作、索引、外部来源、血缘维护和影响分析规则。
- `skills/`：可复用的专门能力说明。

## 不应包含

- 具体报表知识页。
- 业务数据、监管原文或 SQL 草案。
- 与 `AGENTS.md` 冲突的替代性总章程。

## 维护要求

`AGENTS.md` 是仓库级总章程；本目录文件只补充执行细则。调整流程或规则后，应在 `日志.md` 记录规范变更。
