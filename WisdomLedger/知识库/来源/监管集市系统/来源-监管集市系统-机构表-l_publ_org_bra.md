---
type: source
id: 来源-监管集市系统-机构表-l_publ_org_bra
status: draft
updated: 2026-04-17
external_vault: /Users/zhoujingkun/Documents/GitHub/Obsidian/my-dev-brain
external_paths: []
search_keywords:
  - 监管集市
  - l_publ_org_bra
  - 机构表
tags:
  - regulatory
  - source
  - schema
  - system
---

# 来源-监管集市系统-机构表-l_publ_org_bra

## Summary

- 本来源页记录监管集市系统 `l_publ_org_bra` 的字段字典。
- 该表承载机构主数据，包括机构标识、层级、营业状态、证照信息和多类机构属性标志。
- 多个字段直接引用监管集市系统码表，是后续报表、指标和血缘分析的基础维度来源。

## 本地文件

- `原始材料/表结构/监管集市系统/l_publ_org_bra-字段字典.tsv`

## 系统范围

- 主系统：监管集市系统
- 对应对象：机构表 `l_publ_org_bra`
- 文件路径是否位于正确系统目录：是
- 是否存在跨系统加工：待确认

## Key Findings

- 主键字段包括 `DATA_DATE` 和 `ORG_NUM`，表按数据日期保存机构主数据快照。
- 该表至少包含 `18` 个显式引用码表的字段，且大量是否类字段复用 `[[概念-码值集合-A0010-是否标志]]`。
- 部分字段引用的码表页尚未导入，例如 `C0002`、`C0010`、`F0020`、`F0025`。

## Linked Pages

- [[数据表-机构表-l_publ_org_bra-监管集市系统]]
- [[概念-系统-监管集市系统]]
- [[来源-监管集市系统-码值字典]]

## Open Questions

- `REGION_CD`、`REGION_CD_NEW`、`DISTRICT_CODE` 三类区域字段的业务分工是否存在时点替代关系。
- `BANK_CD`、`ACCOUNTBANK`、`FINA_ORG_CODE`、`CBRC_CODE` 四类机构编码的权威优先级是什么。
- `XYJGBS` 虽未显式挂接码表，但业务说明表现为是否类字段，是否应统一映射到 `A0010` 还是单建概念页。
