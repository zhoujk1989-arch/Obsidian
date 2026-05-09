---
type: source
id: 来源-EAST5.0系统-IE_007_704-资产转让关系表
status: draft
updated: 2026-05-09
external_vault: regulatory-knowledge-vault
external_paths:
  - "[[03-实体/EAST5.0-IE_007_704-资产转让关系表]]"
  - "[[01-资料库/EAST5.0系统/2026-04-26-IE_007_704-资产转让关系表-原文]]"
search_keywords:
  - IE_007_704
  - 资产转让关系表
  - EAST5.0
  - 数据字典
  - 采集技术接口说明
tags:
  - regulatory
  - source
  - east5
---

# 来源-EAST5.0系统-IE_007_704-资产转让关系表

## Summary

- 本来源包记录 `IE_007_704` `资产转让关系表` 的本地 EAST5.0 表结构 DDL。
- 本地 DDL 来自用户提供的 `eastttt.xlsx` 自动生成建表脚本，生成时间为 `2026-04-28 03:38:32`。
- 本页只承载证据包、外部路径和关键发现；完整字段口径维护在 [[数据表-IE_007_704-资产转让关系表-EAST5.0系统]]。
- 2026-05-09 重构校准：SQL 草案已消除全部占位符，补齐所有 JOIN、窗口去重和码值 CASE 转换。

## 本地文件

- `原始材料/表结构/EAST5.0系统/IE_007_704-资产转让关系表-DDL-2026-04-28.sql`

## 系统范围

- 主系统：EAST5.0系统
- 关联系统：一表通系统、EAST5.0系统（内关联）
- 文件路径是否位于正确系统目录：是

## 外部关联

- 外部知识库：`regulatory-knowledge-vault`
- 外部关联页面：[[03-实体/EAST5.0-IE_007_704-资产转让关系表]]
- 外部关联页面：[[01-资料库/EAST5.0系统/2026-04-26-IE_007_704-资产转让关系表-原文]]
- 检索关键词：`IE_007_704`、`资产转让关系表`、`EAST5.0`、`数据字典`

## Key Findings

- `IE_007_704` 的业务名称为 `资产转让关系表`，本地建表注释为"资产转让关系表"。
- DDL 当前包含 `11` 个字段，字段注释中标注 `PK` 的核心标识为：`ZRHTH`, `XDJJH`, `CJRQ`。
- 2026-05-09 重构校准后，SQL 草案已实现：
  - 3 个源表/目标表关联：T_7_9（主表，窗口去重）LEFT JOIN T_1_1（机构信息）INNER JOIN IE_007_703（信贷资产转让表）
  - 窗口去重：按借据ID+资产转让方向分组，采集日期降序取第一条
  - 9 个字段有源映射（ZRHTH/XDJJH/NBJGH/JRXKZH/ZRDKLX/BBZ/ZRDKBJ/XDZCLX/CJRQ）
  - 2 个缺口字段（SENSITIVEFLAG/GSFZJG）置 NULL
  - 1 个码值 CASE 转换（XDZCLX 信贷资产类型）

## 共享知识更新检查

- 是否触发系统页更新：是，已纳入 [[概念-系统-EAST5.0系统]]。
- 是否触发通用概念页更新：否。
- 是否需要同步补充接口表字段中的码值说明：是，码值规则已在 SQL 草案中实现并在数据表页字段口径中记录。

## 变更与冲突

- 2026-05-09：SQL 草案重构校准。消除全部 NULL AS 占位（XDJJH/JRXKZH/SENSITIVEFLAG/GSFZJG/CJRQ）和 ON 1=1/WHERE 1=1 TODO。补齐窗口去重逻辑、LEFT JOIN T_1_1 按机构ID截取关联、INNER JOIN IE_007_703 按转让合同号+资产转让方向关联、XDZCLX 码值 CASE 转换。
- 与外部 `regulatory-knowledge-vault` 中 EAST5.0 原文页如有字段差异，后续需逐字段核对后再调整状态。

## Evidence

```sql
-- 完整存储过程见 `工作区/SQL开发/EAST5.0系统/PROC_EAST_IE_007_704_ZCZRGXB_草案.sql`
-- 2026-05-09 重构校准后：消除全部占位符
```

## Linked Pages

- 数据表页：[[数据表-IE_007_704-资产转让关系表-EAST5.0系统]]
- 血缘页：[[血缘-IE_007_704-资产转让关系表-EAST5.0系统]]
- 报表业务口径页：[[报表-IE_007_704-资产转让关系表-EAST5.0系统]]

## Open Questions

- GBase 8a 中 ROW_NUMBER() 窗口函数嵌套子查询的兼容性待跑数验证。
- 内关联 IE_007_703 的 ZCZRFX 字段值映射（'转入'/'转出'）需要确认与行内实际数据一致。
- 外部监管实体页 wikilink 待补。
