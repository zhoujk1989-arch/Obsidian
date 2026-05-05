---
type: source
id: 来源-EAST5.0系统-IE_004_406_INC-对公存款分户账明细记录
status: draft
updated: 2026-05-05
external_vault: regulatory-knowledge-vault
external_paths: []
search_keywords:
  - IE_004_406_INC
  - 对公存款分户账明细记录
  - EAST5.0
  - 数据字典
  - 采集技术接口说明
tags:
  - regulatory
  - source
  - east5
---

# 来源-EAST5.0系统-IE_004_406_INC-对公存款分户账明细记录

## Summary

- 本来源包记录 `IE_004_406_INC` `对公存款分户账明细记录` 的本地 EAST5.0 表结构 DDL。
- 本地 DDL 来自用户提供的 `eastttt.xlsx` 自动生成建表脚本，生成时间为 `2026-04-28 03:38:32`。
- 本页只承载证据包、外部路径和关键发现；完整字段口径维护在 [[数据表-IE_004_406_INC-对公存款分户账明细记录-EAST5.0系统]]。

## 本地文件

- `原始材料/表结构/EAST5.0系统/IE_004_406_INC-对公存款分户账明细记录-DDL-2026-04-28.sql`

## 系统范围

- 主系统：EAST5.0系统
- 关联系统：待确认
- 文件路径是否位于正确系统目录：是

## 外部关联

- 外部知识库：`regulatory-knowledge-vault`
- 外部关联页面：待补充
- 检索关键词：`IE_004_406_INC`、`对公存款分户账明细记录`、`EAST5.0`、`数据字典`

## Key Findings

- `IE_004_406_INC` 的业务名称为 `对公存款分户账明细记录`，本地建表注释为"对公存款分户账明细记录"。
- DDL 当前包含 `36` 个字段，字段注释中标注 `PK` 的核心标识为：`DGCKZH`, `HXJYRQ`, `CJRQ`, `JYXLH`, `HXJYSJ`。
- 本次材料只有表结构与字段说明，未包含 SQL 加工、装载过程或上游取数字段，因此字段级血缘暂不闭环。
- 2026-05-05：依据《021_对公存款分户账明细记录.md》业务需求文档重构 GBase 存储过程草案，33 个业务需求字段全部映射正确，3 个 DDL 缺口字段（SENSITIVEFLAG/GSFZJG/DFKHLB）保留 NULL 或从 IE_004_405 获取。交易渠道码值 ELSE 分支修正为 `REPLACE(G010021,'00','其他')`，与业务需求文档一致。

## 共享知识更新检查

- 是否触发系统页更新：是，已纳入 [[概念-系统-EAST5.0系统]]。
- 是否触发通用概念页更新：否。
- 是否需要同步补充接口表字段中的码值说明：是，字段注释中出现的取值、枚举和特殊规则已优先写入数据表页字段口径。

## 变更与冲突

- 本次来源为新增本地 DDL 证据，不直接推翻既有一表通 `T_...` 页面。
- 与外部 `regulatory-knowledge-vault` 中 EAST5.0 原文页如有字段差异，后续需逐字段核对后再调整状态。

## Evidence

```sql
-- 完整 DDL 见 `原始材料/表结构/EAST5.0系统/IE_004_406_INC-对公存款分户账明细记录-DDL-2026-04-28.sql`
CREATE TABLE `IE_004_406_INC` (...)
```

- SQL 草案：`工作区/SQL开发/EAST5.0系统/PROC_EAST_IE_004_406_INC_DGCKFHZMX_草案.sql`（2026-05-05 重构）
- 校验 SQL：`工作区/SQL开发/EAST5.0系统/CHECK_EAST_IE_004_406_INC_DGCKFHZMX_校验.sql`（2026-05-05 更新）

## Linked Pages

- 数据表页：[[数据表-IE_004_406_INC-对公存款分户账明细记录-EAST5.0系统]]
- 血缘页：[[血缘-IE_004_406_INC-对公存款分户账明细记录-EAST5.0系统]]

## Open Questions

- 当前尚未取得 `IE_004_406_INC` 的实际装载 SQL、存储过程或接口落地脚本，字段级来源和加工状态待补。
