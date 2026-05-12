---
name: regulatory-data-lab-lineage
description: Analyze, create, update, and review regulatory data lineage in regulatory-data-lab with built-in SQL lineage extraction and AI documentation review. Use when Codex or Hermes needs to parse SQL into lineage candidates, combine programmatic extraction with AI judgment, maintain lineage pages, assess upstream/downstream impact, classify confirmed versus suspected lineage, repair lineage links, or update report/table/concept pages affected by lineage changes.
---

# Regulatory Data Lab Lineage

Use this skill for lineage work in `regulatory-data-lab`. Treat lineage as an evidence-backed knowledge maintenance task, not as SQL text summarization.

## Operating Rules

1. Follow repository `AGENTS.md` first; it defines object boundaries, paths, status rules, wikilink style, and logging.
2. Always read the task-specific rule before acting:
   - Impact analysis: `.agents/rules/血缘影响分析规则.md`
   - Lineage creation or maintenance: `.agents/rules/血缘双向维护规则.md`
   - Page writing and link style: `.agents/rules/页面写作规则.md`
3. Do not infer confirmed lineage from field names alone. Confirmed edges require SQL, procedure/view definitions, DDL or field dictionaries, external wikilinks, user-confirmed materials, or existing knowledge pages.
4. Keep responsibilities separated:
   - Lineage page: upstream/downstream objects, table edges, field edges, field landing status, SQL output status, filters, dependency conditions, evidence state.
   - Data table page: field master, code values, table-local metrics, evidence summary, lineage page entry link only.
   - Report page: business scope, inclusion/exclusion, timing, fields or metrics, regulatory reporting meaning.
   - Concept/system page: reusable rules and object entry points.
5. Do not create placeholder wikilinks. If a page or SQL file is not found, write plain text such as `待补充（未找到：候选路径；检索词：...）`.
6. In Markdown tables, escape SQL wikilink aliases: `[[sql/<系统名>/<文件名>.sql\|<文件名>.sql]]`.
7. Use the bundled parser script when SQL is available and a mechanical first pass will reduce missed tables, fields, filters, joins, or constants. By default it tries GSP first, applying the GSP 10,000-character preprocessing/splitting guard, then supplements with sqlglot/regex. The script output is candidate evidence; AI review remains mandatory.
8. JPype/Java/GSP JAR are required prerequisites for the default `--engine auto` path. If `scripts/check_gsp_prereqs.py` reports JPype missing, fix the Python environment first instead of accepting regex-only lineage. Use `--engine sqlglot` only when the user explicitly approves skipping GSP.

## Workflow

1. **Classify the task**
   - SQL lineage extraction, lineage page maintenance, downstream impact analysis, upstream traceability, link repair, or review.
   - Identify system, target object, changed table/field, SQL/procedure, and whether knowledge pages must be updated.

2. **Gather evidence**
   - Read `索引.md`, then `概念/概念-系统-<系统名>.md` when it exists.
   - Search with `rg` for target table names, field names, Chinese names, aliases, procedure names, source fields, and target fields.
   - Open relevant data table pages, lineage pages, report pages, and SQL files. Do not rely on one page when SQL or another page can verify the claim.
   - For SQL ingest or SQL-backed maintenance, run `scripts/check_gsp_prereqs.py` when GSP readiness is unclear, then run `scripts/extract_sql_lineage.py` on the relevant SQL file or directory when practical. Use `--engine auto` by default so GSP is attempted first; if JPype is missing, repair the environment before continuing. The extractor accepts both `--file path.sql` and positional `path.sql`. Use `references/programmatic-lineage.md` for interpretation rules.
   - Use `工具/血缘脚手架.py` only if the repository workflow specifically benefits from it; manually verify every edge before writing it as confirmed.
   - If regulatory interpretation is required, follow `.agents/rules/外部来源规则.md` and record only `regulatory-knowledge-vault` wikilinks.

3. **Build the lineage model**
   - List nodes: source tables, dimension/reference tables, CTEs, procedures/views, target tables, report outputs, downstream consumers.
   - Use programmatic `relationships` as candidate table-level edges and `columnDependencies` as candidate field-level or dependency-condition evidence. Prefer `candidate_gsp` edges over lighter `candidate_regex` edges when both exist, but still verify against SQL and knowledge pages.
   - List table-level edges with transform type and evidence.
   - List field-level edges for every target output field when the target is a regulatory report, standard interface table, or core downstream result table.
   - Record constants, parameters, NULL assignments, system dates, default values, CASE branches, code mappings, date conversions, window functions, aggregations, and filters as lineage-relevant logic.
   - Classify each edge as confirmed, suspected, no impact, or pending based on available evidence.

4. **Write or update artifacts**
   - Use `模板/血缘模板.md` for new or heavily rewritten lineage pages.
   - Update existing lineage pages before creating new near-duplicates.
   - Add or fix data table page lineage entry links only; do not put upstream/downstream or field landing status in data table pages.
   - Update report pages only when the lineage change affects business scope, field/metric meaning, filters, timing, or reporting interpretation.
   - Update concept/system pages only for reusable rules, system boundaries, object entry lists, or system-level open questions.
   - Rejudge `status` for each touched knowledge page. Downgrade `validated` to `draft` if new evidence weakens a confirmed conclusion.
   - Append `日志.md` for durable lineage maintenance, SQL ingest, impact analysis, or skill/rule changes.

5. **Deliver the result**
   - State changed files and evidence used.
   - Separate confirmed impact, suspected impact, no impact, and pending items.
   - Include direct and indirect affected objects, severity, repair targets, validation checks, and Open Questions for impact analysis.
   - For maintenance work, report whether target fields are fully covered and where gaps remain.

## Impact Analysis Output

For table or field changes, produce at least:

- 变更对象
- 直接影响对象
- 间接影响对象
- 影响类型
- 严重级别：P0 / P1 / P2 / P3 / Unknown
- 修复对象
- 验证方案
- Open Questions

Classify findings this way:

- 确认影响: SQL, field-level lineage, data table page, or report page explicitly proves dependency.
- 疑似影响: naming, business chain, table-level edge, or nearby SQL suggests dependency but field-level evidence is missing.
- 无影响: evidence proves the field or table is not consumed by the target chain.
- 待确认: evidence is insufficient.

## References

Use `references/programmatic-lineage.md` when SQL parsing should combine programmatic extraction with AI review.

Use `references/lineage-checklist.md` before finishing non-trivial lineage work.

Use `scripts/check_gsp_prereqs.py` to verify Java + JPype + GSP JAR availability before running the extraction script when needed. The check exits non-zero when prerequisites are missing so the agent fixes the cause before writing lineage.
