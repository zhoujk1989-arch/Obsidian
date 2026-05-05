---
type: source
id: 来源-EAST5.0系统-IE_004_408_INC-内部分户账明细记录
status: draft
updated: 2026-04-28
external_vault: regulatory-knowledge-vault
external_paths: []
search_keywords:
  - IE_004_408_INC
  - 内部分户账明细记录
  - EAST5.0
  - 数据字典
  - 采集技术接口说明
tags:
  - regulatory
  - source
  - east5
---

# 来源-EAST5.0系统-IE_004_408_INC-内部分户账明细记录

## Summary

- 本来源包记录 `IE_004_408_INC` `内部分户账明细记录` 的本地 EAST5.0 表结构 DDL。
- 本地 DDL 来自用户提供的 `eastttt.xlsx` 自动生成建表脚本，生成时间为 `2026-04-28 03:38:32`。
- 本页只承载证据包、外部路径和关键发现；完整字段口径维护在 [[数据表-IE_004_408_INC-内部分户账明细记录-EAST5.0系统]]。

## 本地文件

- `原始材料/表结构/EAST5.0系统/IE_004_408_INC-内部分户账明细记录-DDL-2026-04-28.sql`

## 系统范围

- 主系统：EAST5.0系统
- 关联系统：待确认
- 文件路径是否位于正确系统目录：是

## 外部关联

- 外部知识库：`regulatory-knowledge-vault`
- 外部关联页面：待补充
- 检索关键词：`IE_004_408_INC`、`内部分户账明细记录`、`EAST5.0`、`数据字典`

## Key Findings

- `IE_004_408_INC` 的业务名称为 `内部分户账明细记录`，本地建表注释为"内部分户账明细记录"。
- DDL 当前包含 `35` 个字段，字段注释中标注 `PK` 的核心标识为：`JYXLH`, `HXJYRQ`, `HXJYSJ`, `CJRQ`, `NBFHZZH`。
- 2026-05-05 已生成 GBase 存储过程草案（`PROC_EAST_IE_408_INC_NBFHZMX_草案.sql`），消除了 JOIN TODO 和码值 CASE 占位，32 个业务需求字段全部闭环（3 个缺口字段置 NULL）。
- 字段级血缘已更新为设计血缘（依据 SQL 草案），尚未运行验证，状态保持 `draft`。

## 共享知识更新检查

- 是否触发系统页更新：是，已纳入 [[概念-系统-EAST5.0系统]]。
- 是否触发通用概念页更新：否。
- 是否需要同步补充接口表字段中的码值说明：是，字段注释中出现的取值、枚举和特殊规则已优先写入数据表页字段口径。

## 变更与冲突

- 本次来源为新增本地 DDL 证据，不直接推翻既有一表通 `T_...` 页面。
- 与外部 `regulatory-knowledge-vault` 中 EAST5.0 原文页如有字段差异，后续需逐字段核对后再调整状态。

## Evidence

```sql
-- 完整 DDL 见 `原始材料/表结构/EAST5.0系统/IE_004_408_INC-内部分户账明细记录-DDL-2026-04-28.sql`
CREATE TABLE `IE_004_408_INC` (...)
```

## Linked Pages

- 数据表页：[[数据表-IE_004_408_INC-内部分户账明细记录-EAST5.0系统]]
- 血缘页：[[血缘-IE_004_408_INC-内部分户账明细记录-EAST5.0系统]]

## Open Questions

- `IE_004_408_INC` 的实际装载 SQL 已生成 GBase 存储过程草案（2026-05-05 重构），但尚未运行验证。
- 缺口字段 GSFZJG/SENSITIVEFLAG/DFKHLB 无映射来源，需需求方确认。
- WHERE 过滤仅有采集日期条件，终态纳入和排除条件待需求方确认。
