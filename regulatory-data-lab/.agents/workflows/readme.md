---
type: concept
id: 目录说明-agents-workflows
status: validated
updated: 2026-05-10
tags:
  - regulatory
  - concept
---

# workflows目录说明

## 目录职责

本目录保存按用户意图划分的执行流程。

## 应包含

- 数据表 ingest、报表 SQL ingest、SQL 开发、查询与回写、巡检 lint 等流程。
- 每个流程的输入识别、必读规则、操作步骤、产出和检核要求。
- 对 `.agents/rules/` 和 `.agents/skills/` 的引用。

## 不应包含

- 具体报表知识内容。
- 可执行 SQL 草案。
- 与 `AGENTS.md` 冲突的仓库结构定义。

## 维护要求

新增工作方法时，优先判断是 workflow、rule 还是 skill：有固定任务路径的写 workflow，跨任务约束写 rule，专门能力写 skill。
