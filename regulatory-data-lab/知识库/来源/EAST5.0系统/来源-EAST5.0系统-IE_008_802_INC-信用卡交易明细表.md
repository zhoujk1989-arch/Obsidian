---
type: source
id: 来源-EAST5.0系统-IE_008_802_INC-信用卡交易明细表
status: draft
updated: 2026-05-09
external_vault: regulatory-knowledge-vault
external_paths: []
search_keywords:
  - IE_008_802_INC
  - 信用卡交易明细表
  - EAST5.0
  - 数据字典
  - 采集技术接口说明
tags:
  - regulatory
  - source
  - east5
---

# 来源-EAST5.0系统-IE_008_802_INC-信用卡交易明细表

## Summary

- 本来源包记录 `IE_008_802_INC` `信用卡交易明细表` 的本地 EAST5.0 表结构 DDL。
- 本地 DDL 来自用户提供的 `eastttt.xlsx` 自动生成建表脚本，生成时间为 `2026-04-28 03:38:32`。
- 本页只承载证据包、外部路径和关键发现；完整字段口径维护在 [[数据表-IE_008_802_INC-信用卡交易明细表-EAST5.0系统]]。

## 本地文件

- `原始材料/表结构/EAST5.0系统/IE_008_802_INC-信用卡交易明细表-DDL-2026-04-28.sql`

## 系统范围

- 主系统：EAST5.0系统
- 关联系统：待确认
- 文件路径是否位于正确系统目录：是

## 外部关联

- 外部知识库：`regulatory-knowledge-vault`
- 外部关联页面：待补充
- 检索关键词：`IE_008_802_INC`、`信用卡交易明细表`、`EAST5.0`、`数据字典`

## Key Findings

- `IE_008_802_INC` 的业务名称为 `信用卡交易明细表`，本地建表注释为"信用卡交易明细表"。
- DDL 当前包含 `42` 个字段，字段注释中标注 `PK` 的核心标识为：`HXJYRQ`, `JYXLH`, `KH`, `HXJYSJ`, `CJRQ`。
- **2026-05-09 重构校准**：SQL 草案已按《050_信用卡交易明细表.md》逐字段校准，消除全部占位。
  - 4 个 LEFT JOIN 已补齐：T_7_4→T_6_9（卡号关联）、T_6_9→T_1_1（机构ID截取第12位）、T_7_4→IE_002_201（个人客户）、T_7_4→IE_002_203（对公客户）
  - WHERE 条件已补齐：增量日期过滤（上一采集日至采集日）+ 排除已核销卡
  - 6 个码值 CASE 转换已补齐：XSXXJYBZ/KPJYLX/JYJDBZ/TQJQBZ/JYQD/FQFKBZ
  - 5 个日期格式转换已补齐：HXJYRQ/JYZDRQ/ZCHKRQ/HXJYSJ/CJRQ
  - 3 个金额字段 CAST 已补齐：SXFJE/ZHYE/JYJE
  - 客户名称/证件多源合并已补齐：COALESCE(对公客户名称/证件, 个人客户姓名/证件)
  - 4 个缺口字段（SENSITIVEFLAG/DFKHLB/GSFZJG/KHLB）置 NULL，符合审计处置原则

## 共享知识更新检查

- 是否触发系统页更新：是，已纳入 [[概念-系统-EAST5.0系统]]。
- 是否触发通用概念页更新：否。
- 是否需要同步补充接口表字段中的码值说明：是，字段注释中出现的取值、枚举和特殊规则已优先写入数据表页字段口径。

## 变更与冲突

- 本次来源为新增本地 DDL 证据，不直接推翻既有一表通 `T_...` 页面。
- 与外部 `regulatory-knowledge-vault` 中 EAST5.0 原文页如有字段差异，后续需逐字段核对后再调整状态。

## Evidence

```sql
-- 完整 DDL 见 `原始材料/表结构/EAST5.0系统/IE_008_802_INC-信用卡交易明细表-DDL-2026-04-28.sql`
-- 重构后 SQL 草案见 `工作区/SQL开发/EAST5.0系统/PROC_EAST_IE_008_802_INC_XYKJYMXB_草案.sql`
CREATE TABLE `IE_008_802_INC` (...)
```

## Linked Pages

- 数据表页：[[数据表-IE_008_802_INC-信用卡交易明细表-EAST5.0系统]]
- 血缘页：[[血缘-IE_008_802_INC-信用卡交易明细表-EAST5.0系统]]

## Open Questions

- SQL 草案尚未在 GBase 环境执行语法校验和跑数验证。
- WHERE 过滤当前仅按增量日期过滤，报送要求中"不包括查询交易"未实现具体交易类型码值排除，需业务确认哪些码值属于查询交易。
- 多源客户信息合并（对公 vs 个人）的 COALESCE 优先级策略需要业务方确认。
- 已核销卡排除逻辑当前按卡状态='已核销'过滤，可能需精确匹配 T_6_9.F090029 的实际码值。
