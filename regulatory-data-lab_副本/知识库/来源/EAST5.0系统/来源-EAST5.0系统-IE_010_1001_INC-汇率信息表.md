---
type: source
id: 来源-EAST5.0系统-IE_010_1001_INC-汇率信息表
status: draft
updated: 2026-05-10
external_vault: regulatory-knowledge-vault
external_paths: []
search_keywords:
  - IE_010_1001_INC
  - 汇率信息表
  - EAST5.0
  - 数据字典
  - 采集技术接口说明
tags:
  - regulatory
  - source
  - east5
---

# 来源-EAST5.0系统-IE_010_1001_INC-汇率信息表

## Summary

- 本来源包记录 `IE_010_1001_INC` `汇率信息表` 的本地 EAST5.0 表结构 DDL。
- 本地 DDL 来自用户提供的 `eastttt.xlsx` 自动生成建表脚本，生成时间为 `2026-04-28 03:38:32`。
- 本页只承载证据包、外部路径和关键发现；完整字段口径维护在 [[数据表-IE_010_1001_INC-汇率信息表-EAST5.0系统]]。

## 本地文件

- `原始材料/表结构/EAST5.0系统/IE_010_1001_INC-汇率信息表-DDL-2026-04-28.sql`

## 系统范围

- 主系统：EAST5.0系统
- 关联系统：一表通系统（来源表 T_10_2、T_1_2、T_1_1）
- 文件路径是否位于正确系统目录：是

## 外部关联

- 外部知识库：`regulatory-knowledge-vault`
- 外部关联页面：待补充
- 检索关键词：`IE_010_1001_INC`、`汇率信息表`、`EAST5.0`、`数据字典`

## Key Findings

- `IE_010_1001_INC` 的业务名称为 `汇率信息表`，本地建表注释为"汇率信息表"。
- DDL 当前包含 `12` 个字段，字段注释中标注 `PK` 的核心标识为：`HLRQ`, `CJRQ`, `WBBZ`, `BBBZ`。
- 2026-05-10 重构校准：完成 SQL 草案重构，消除全部 `ON 1=1` 和 `WHERE 1=1` 占位。
- 表级规则（Excel第1418行）实现：主表T_10_2 INNER JOIN T_1_2（机构关系）ON 机构ID + 上级管理机构ID='0' LEFT JOIN T_1_1（机构信息）ON 机构ID。
- 10 个字段已映射来源，2 个缺口字段（SENSITIVEFLAG/GSFZJG）无业务需求来源，SQL 中置 NULL。
- CJRQ 采用 P_DATA_DATE 参数赋值（标准模式）。

## 共享知识更新检查

- 是否触发系统页更新：是，已纳入 [[概念-系统-EAST5.0系统]]。
- 是否触发通用概念页更新：否。
- 是否需要同步补充接口表字段中的码值说明：是，字段注释中出现的取值、枚举和特殊规则已优先写入数据表页字段口径。

## 变更与冲突

- 2026-05-10 重构校准：补齐 T_1_2 INNER JOIN、修正 T_1_1 LEFT JOIN 键、补齐 WHERE 过滤、修正 HLRQ/WBSL/NBJGH/BBBZ 映射逻辑、修正 ZBBSL 精度、CJRQ 改参数赋值。
- 本次重构不推翻既有一表通 `T_...` 页面结论。
- 与外部 `regulatory-knowledge-vault` 中 EAST5.0 原文页如有字段差异，后续需逐字段核对后再调整状态。

## Evidence

```sql
-- 表级规则实现
-- FROM T_10_2 src
-- INNER JOIN T_1_2 rel ON src.K020001 = rel.A020001 AND rel.A020002 = '0'
-- LEFT JOIN T_1_1 s1 ON rel.A020001 = s1.A010001
-- WHERE SUBSTR(src.K020002, 7, 6) = LEFT(P_DATA_DATE, 6)
```

```sql
-- 完整 DDL 见 `原始材料/表结构/EAST5.0系统/IE_010_1001_INC-汇率信息表-DDL-2026-04-28.sql`
CREATE TABLE `IE_010_1001_INC` (...)
```

## Linked Pages

- 数据表页：[[数据表-IE_010_1001_INC-汇率信息表-EAST5.0系统]]
- 血缘页：[[血缘-IE_010_1001_INC-汇率信息表-EAST5.0系统]]
- 报表业务口径页：[[报表-IE_010_1001_INC-汇率信息表-EAST5.0系统]]

## Open Questions

- SQL 草案尚未在 GBase 环境执行语法校验和跑数验证。
- 缺口字段 SENSITIVEFLAG/GSFZJG 无业务需求映射来源，待确认是否监管必报或允许置空。
- T_1_2 DDL 文件尚未入库至 `原始材料/表结构/一表通系统/`。
