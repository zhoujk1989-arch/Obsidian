---
type: source
id: 来源-EAST5.0系统-IE_006_603-表内外业务抵质押物
status: draft
updated: 2026-05-09
external_vault: regulatory-knowledge-vault
external_paths:
  - "[[03-实体/EAST5.0-IE_006_603-表内外业务抵质押物]]"
  - "[[01-资料库/EAST5.0系统/2026-04-26-IE_006_603-表内外业务抵质押物-数据字典-原文]]"
search_keywords:
  - IE_006_603
  - 表内外业务抵质押物
  - EAST5.0
  - 数据字典
  - 采集技术接口说明
tags:
  - regulatory
  - source
  - east5
---

# 来源-EAST5.0系统-IE_006_603-表内外业务抵质押物

## Summary

- 本来源包记录 `IE_006_603` `表内外业务抵质押物` 的本地 EAST5.0 表结构 DDL 和 SQL 草案加工逻辑。
- 本地 DDL 来自用户提供的 `eastttt.xlsx` 自动生成建表脚本，生成时间为 `2026-04-28 03:38:32`。
- 2026-05-09 依据 `043_表内外业务抵质押物.md` 业务需求和 DDL 逐字段核对，完成了 SQL 草案全面校准。
- 本页只承载证据包、外部路径和关键发现；完整字段口径维护在 [[数据表-IE_006_603-表内外业务抵质押物-EAST5.0系统]]。

## 已确认的字段来源冲突（2026-05-09 DDL 核对发现）

| 字段 | 问题类型 | 需求文档写法 | DDL 实际情况 | 处理 |
| --- | --- | --- | --- | --- |
| CZQSW（处置权顺位） | 码值格式 | J030015='01'→第一顺位 | J030015 char(1) 1!n，实际单字符 | CASE 同时兼容 '1' 和 '01' |
| YPSYRZJLB（证件类别） | 码值格式 | J030017='1999-XX'→其他-XX | J030017 char(4) 4!n，4位数字码 | CASE IN('1999','2999')→'其他' |
| ZYPZHM（质押票证号码） | 来源表 | "担保协议\|抵质押品" | T_9_3 已含 J030025（质押票证号码） | 从 T_9_3.J030025 取值 |
| NBJGH（内部机构号） | 来源字段 | "机构id"→内部机构号 | J030003 机构ID 需提取 | SUBSTR(TRIM(J030003), 12) |

## 本地文件

- `原始材料/表结构/EAST5.0系统/IE_006_603-表内外业务抵质押物-DDL-2026-04-28.sql`
- `原始材料/业务需求/EAST5.0/043_表内外业务抵质押物.md`
- `原始材料/表结构/一表通系统/T_9_3-抵质押品-DDL-2026-04-27.sql`
- `原始材料/表结构/一表通系统/T_6_8-担保协议-DDL-2026-04-27.sql`
- `原始材料/表结构/一表通系统/T_1_1-机构信息-DDL-2026-04-28.sql`
- `原始材料/表结构/一表通系统/T_10_1-公共代码-DDL-2026-04-27.sql`

## SQL 草案

- `工作区/SQL开发/EAST5.0系统/PROC_EAST_IE_006_603_BNWYWDZYW_草案.sql`（2026-05-09 重构版）
- `工作区/SQL开发/EAST5.0系统/CHECK_EAST_IE_006_603_BNWYWDZYW_校验.sql`

## 系统范围

- 主系统：EAST5.0系统
- 关联系统：一表通系统（T_9_3, T_6_8, T_1_1, T_10_1）
- 文件路径是否位于正确系统目录：是

## 外部关联

- 外部知识库：`regulatory-knowledge-vault`
- 外部关联页面：[[03-实体/EAST5.0-IE_006_603-表内外业务抵质押物]]
- 外部关联页面：[[01-资料库/EAST5.0系统/2026-04-26-IE_006_603-表内外业务抵质押物-数据字典-原文]]
- 检索关键词：`IE_006_603`、`表内外业务抵质押物`、`EAST5.0`、`数据字典`

## Key Findings

- `IE_006_603` 的业务名称为 `表内外业务抵质押物`，DDL 包含 26 个字段，主键为 CJRQ + DBHTH + YPBH。
- 2026-05-09 校准完成的主要技术实现：
  - 主驱动表：T_9_3（抵质押品），LEFT JOIN T_6_8（担保协议）ON J030002=F080001
  - NBJGH 提取：SUBSTR(TRIM(J030003), 12)
  - JRXKZH：按担保协议ID分组取最小NBJGH → T_1_1 关联取 A010003
  - 码值映射：T_10_1 公共代码表（抵质押物类型、抵质押物所有权人证件类型）
  - 排除规则：J030039 NOT IN ('1', 'Y') 排除保证金担保
  - 日期过滤：J030037 = V_DATA_DATE
- 三个缺口字段暂置 NULL：SENSITIVEFLAG、YPSYRKHLB、GSFZJG

## 共享知识更新检查

- 是否触发系统页更新：是，已纳入 [[概念-系统-EAST5.0系统]]。
- 是否触发通用概念页更新：否。
- 是否需要同步补充接口表字段中的码值说明：是，T_10_1 码值映射需要外部原文确认。

## 变更与冲突

- 2026-05-09：全面校准 SQL 草案和知识页。发现字段来源冲突 4 处（CZQSW 码值格式、YPSYRZJLB 码值格式、ZYPZHM 来源表、NBJGH 来源字段）。
- 与外部 `regulatory-knowledge-vault` 中 EAST5.0 原文页如有字段差异，后续需逐字段核对后再调整状态。

## Evidence

```sql
-- 核心 SQL 结构（2026-05-09 重构版）
-- 完整见 工作区/SQL开发/EAST5.0系统/PROC_EAST_IE_006_603_BNWYWDZYW_草案.sql
SELECT
    CONCAT(CAST(YEAR(src.J030037) AS VARCHAR(4)), ...) AS CJRQ,
    CONCAT_WS(';', NULLIF(TRIM(src.J030036), ''), NULLIF(TRIM(s1.F080024), '')) AS BBZ,
    CASE WHEN TRIM(src.J030015) IN ('1','01') THEN '第一顺位' ... END AS CZQSW,
    CASE WHEN TRIM(src.J030007) = '01' THEN '正常' ... END AS DZYWZT,
    CASE WHEN LEFT(TRIM(src.J030005),3)='00-' THEN CONCAT('其他-',...) ELSE COALESCE(TRIM(code_yplx.K010005),...) END AS YPLX,
    SUBSTR(TRIM(src.J030003), 12) AS NBJGH,
    s2.A010003 AS JRXKZH
FROM T_9_3 src
LEFT JOIN T_6_8 s1 ON TRIM(src.J030002)=TRIM(s1.F080001) AND s1.F080025=V_DATA_DATE
LEFT JOIN T_10_1 code_yplx ON ... AND K010002='抵质押品' AND K010003='抵质押物类型'
LEFT JOIN T_10_1 code_zjlb ON ... AND K010002='抵质押品' AND K010003='抵质押物所有权人证件类型'
LEFT JOIN (SELECT TRIM(J030002) AS DBHTH, MIN(SUBSTR(TRIM(J030003),12)) AS MIN_NBJGH FROM T_9_3 WHERE J030037=V_DATA_DATE AND NVL(TRIM(J030039),'') NOT IN ('1','Y') GROUP BY TRIM(J030002)) min_org ON ...
LEFT JOIN T_1_1 s2 ON TRIM(min_org.MIN_NBJGH)=TRIM(s2.A010002) AND s2.A010020=V_DATA_DATE
WHERE src.J030037=V_DATA_DATE AND NVL(TRIM(src.J030039),'') NOT IN ('1','Y');
```

## Linked Pages

- 数据表页：[[数据表-IE_006_603-表内外业务抵质押物-EAST5.0系统]]
- 血缘页：[[血缘-IE_006_603-表内外业务抵质押物-EAST5.0系统]]
- 报表页：[[报表-IE_006_603-表内外业务抵质押物-EAST5.0系统]]

## Open Questions

- T_10_1 中 '抵质押品.抵质押物类型' 和 '抵质押品.抵质押物所有权人证件类型' 的实际码值列表需外部原文确认。
- DBHTZT 当前取单条 T_6_8.F080019，但需求文档要求"按担保合同号分组取最大的担保合同状态"——验证是否有多条协议对应同一合同号。
- 终态纳入规则（跨月结清/失效/终结回算）当前仅在 WHERE 中过滤 J030037=V_DATA_DATE，未实现跨月终态补充。
- 缺口字段 SENSITIVEFLAG、YPSYRKHLB、GSFZJG 的监管报送要求待确认。
- GBase 环境执行验证待完成。
