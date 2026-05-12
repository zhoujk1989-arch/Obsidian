# Lineage Checklist

Use this checklist before finishing lineage extraction, lineage maintenance, or impact analysis.

## Evidence

- Read `AGENTS.md`, the relevant lineage rule, and page writing rule.
- Read `索引.md` and the system concept page if present.
- Search by technical name, Chinese name, aliases, source fields, target fields, and procedure names.
- Open the actual SQL/procedure/view when lineage depends on implementation.
- When SQL is available, run `scripts/extract_sql_lineage.py --engine auto` and use the default Markdown scaffold, or explain why it was skipped.
- Check the `解析摘要`: if GSP prerequisites are missing, fix the environment before normal lineage extraction instead of accepting regex-only coverage.
- For large SQL, check `gsp_chunk_count`, `gsp_skipped_chunk_count`, and `gsp_errors`; skipped GSP chunks mean field coverage is incomplete until AI/manual review fills gaps.
- Treat parser output as candidate evidence; manually confirm before writing `已确认`.
- Mark edges without SQL, field dictionary, external wikilink, user confirmation, or existing page support as `待确认` or `疑似`.

## Page Boundaries

- Lineage page contains upstream/downstream, table edges, field edges, filters, dependency conditions, landing status, output status, evidence status, and gaps.
- Data table page contains field master, code values, table-local metrics, evidence summary, and a lineage page entry link only.
- Report page contains business scope, reporting object, inclusion/exclusion, timing, field/metric meaning, and regulatory reporting interpretation.
- Concept/system page contains reusable rules, system boundaries, object entries, and system-level Open Questions.

## Link Integrity

- Existing internal pages and SQL files use Obsidian wikilinks.
- Nonexistent targets stay as plain text `待补充（未找到：...；检索词：...）`.
- SQL file aliases inside Markdown tables escape `|` as `\|`.
- Table-level edge `From`, `To`, and `Evidence` link to existing object pages or SQL files when available.
- Field-level edge source and target objects link to existing data table pages when available.

## Minimum Lineage Coverage

- Regulatory report, standard interface table, or core downstream result table: every target output field has a field-level row.
- Constants, parameters, NULLs, dates, default values, CASE, code mappings, aggregations, windows, joins, filters, and delete/insert scope are recorded.
- GSP `candidate_gsp` edges are preferred over lighter fallback edges when duplicated; `candidate_table_scan` and `candidate_regex` remain review-only candidates.
- Parser `fdd` output is reviewed for actual relation type; parser `join` and `fdr` output is written as dependency/filter evidence unless it directly affects target field derivation.
- Direct upstream and direct downstream objects are stated.
- Open gaps are listed with补证方向.

## Finish

- Touched pages have status rejudged.
- Related data table pages have lineage entry links when appropriate.
- Related report/system/concept pages are updated only when their responsibilities are affected.
- `日志.md` records durable maintenance work.
- Final response separates confirmed, suspected, no-impact, and pending conclusions when relevant.
