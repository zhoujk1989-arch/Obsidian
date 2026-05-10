---
type: concept
id: 目录说明-agents-rules
status: validated
updated: 2026-05-10
tags:
  - regulatory
  - concept
---

# rules目录说明

## 目录职责

本目录保存跨流程通用规则，约束页面写作、索引日志、外部来源、血缘维护和影响分析。

## 应包含

- 独立于单一任务流程的规则文件。
- 能被多个 workflow 共同引用的检核清单。
- 与 `AGENTS.md` 原则一致的执行细则。

## 不应包含

- 单次任务记录。
- 具体报表、数据表或 SQL 内容。
- 与 workflow 重复的大段步骤说明。

## 维护要求

规则调整后，应检查相关 workflow 是否需要同步引用，并在 `日志.md` 记录变更。
