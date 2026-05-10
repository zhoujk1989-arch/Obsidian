---
type: source
id: 来源-EAST5.0系统-IE_005_508-票据贴现表
status: draft
updated: 2026-05-06
tags:
  - regulatory
  - source
  - east5
external_vault: regulatory-knowledge-vault
external_paths:
  - "[[035_票据贴现表]]"
search_keywords:
  - EAST5.0 票据贴现表 IE_005_508
---

# 来源-EAST5.0系统-IE_005_508-票据贴现表

## 页面边界

- 本页维护 `票据贴现表`（IE_005_508）的证据包，包括本地 SQL/DDL 材料、外部来源和关键发现。
- 业务口径见 [[报表-IE_005_508-票据贴现表-EAST5.0系统]]；数据表定义见 [[数据表-IE_005_508-票据贴现表-EAST5.0系统]]；血缘见 [[血缘-IE_005_508-票据贴现表-EAST5.0系统]]。

## 本地材料

| 类型 | 文件路径 |
| --- | --- |
| DDL | `原始材料/表结构/EAST5.0系统/IE_005_508-票据贴现表-DDL-2026-04-28.sql` |
| 业务需求 | `原始材料/业务需求/EAST5.0/035_票据贴现表.md` |
| 源表 DDL（一表通） | `原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql` |
| 源表 DDL（一表通） | `原始材料/表结构/一表通系统/T_6_13-票据协议-DDL-2026-04-27.sql` |
| SQL 草案 | `工作区/SQL开发/EAST5.0系统/PROC_EAST_IE_005_508_PJTXB_草案.sql` |

## 外部来源

- `regulatory-knowledge-vault`：[[035_票据贴现表]]

## 关键发现与实现结论（2026-05-06）

- SQL 草案已修复所有 TODO 占位：JOIN 条件（T_1_1.A010001 = T_6_13.F130003）、WHERE 过滤（F130049 = V_DATA_DATE）、CASE 码值转换（PJLX/PJZT）。
- NBJGH 加工映射已实现 SUBSTR(F130003, 12)。
- BZ（币种）来源已修正为 F130019（协议币种），原始映射文档标注 F130048 有误。
- SENSITIVEFLAG（涉密标志）和 GSFZJG（归属分支机构）在业务需求映射表中无来源，暂置 NULL。
- "剔除上月状态为失效的数据"：当前仅实现当月采集日期过滤，失效状态字段来源未明确。
- SQL 草案尚未在 GBase 环境执行验证，状态保持 draft。
