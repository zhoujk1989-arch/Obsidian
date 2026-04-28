---
name: sql-dev
description: Create traceable SQL, stored procedure, view, ETL, validation SQL, and implementation notes from repository knowledge pages, table structures, lineage docs, report definitions, or regulatory/business rules. Use when the user asks to write SQL, generate SQL, fix or complete SQL, write a stored procedure, build an insert-select, create a view, produce validation checks, map fields between source and target tables, or implement a report/data mart/interface table from documented knowledge.
---

# SQL Development

Use this skill to turn documented knowledge into executable SQL artifacts without inventing business logic. Treat SQL development as a traceability task: every important field, filter, join, code mapping, date rule, and aggregation must have an evidence source or be marked as unconfirmed.

## Operating Rules

1. Follow the repository's own `AGENTS.md` first. If it defines paths, page types, status rules, source-of-truth rules, or logging requirements, those are mandatory.
2. Prefer existing knowledge pages over guessing from field names. Read the index first when present, then relevant report, table, lineage, source, concept, and system pages.
3. If knowledge pages are missing or incomplete, read local DDL, data dictionaries, interface specs, and existing SQL in the repository. Do not modify raw source materials unless the user explicitly asks.
4. Before generating SQL, write or record an implementation-scope confirmation: target object, grain, source tables, joins, time conditions, filters, field mappings, code mappings, and open risks.
5. Do not invent fields, tables, enum values, regulatory rules, joins, or date semantics. Put uncertain items in Open Questions or the implementation notes.
6. Always create validation SQL or a validation checklist unless the user explicitly asks for only a small ad hoc query.
7. For durable report/interface/table development, update the repository's knowledge objects, index, and log according to its local rules.

## Workflow

1. **Classify the request**
   - Query only, insert-select, stored procedure, view, ETL script, validation SQL, or debugging an existing SQL.
   - Identify target system, target table/output, database dialect, run date parameter, refresh mode, and whether knowledge pages must be updated.

2. **Gather evidence**
   - Read `索引.md` or the local index if present.
   - Search for the target report/table name, technical table name, field names, and business terms.
   - Open relevant knowledge pages before raw DDL; use DDL or field dictionaries when page evidence is incomplete.
   - If regulatory or external-source interpretation is required, use the repository's prescribed external-source search tool or workflow.

3. **Confirm implementation scope**
   - State the business objective and one-row grain.
   - List source and target tables with roles.
   - Specify join keys and date conditions.
   - Specify inclusion/exclusion filters.
   - Map target fields to sources, constants, transformations, code mappings, and derivations.
   - Mark unresolved assumptions clearly.

4. **Generate artifacts**
   - Put draft SQL in the repository's configured SQL development workspace when one exists, commonly `工作区/SQL开发/<系统名>/`.
   - Use the local SQL template if present, commonly `模板/SQL开发模板.sql`.
   - Generate separate validation SQL for non-trivial outputs, commonly `CHECK_<需求名>_校验.sql`.
   - Generate implementation notes when the task is a report/interface/stored procedure or has meaningful assumptions.

5. **Maintain knowledge**
   - If this is more than a disposable query, update relevant source, report, table, lineage, concept/system pages as required by the repository.
   - Mark draft SQL and draft lineage as unverified until the user confirms execution or production adoption.
   - Update index and log files when the repository requires it.

6. **Deliver**
   - List generated/updated files.
   - List evidence pages/materials used.
   - List open questions and risks.
   - Recommend the first validation checks to run.

## SQL Style

Use `references/sql-style.md` when writing non-trivial SQL, stored procedures, insert-selects, views, or validation checks.

## Artifact Checklist

Use `references/artifact-checklist.md` before finishing any durable SQL development task.

## Common Prompt Shape

When the user gives an incomplete SQL request, infer what is safe from the repository and ask only for blockers. Useful request fields are:

```text
目标系统：
业务目标：
目标产物：查询 SQL / insert select / 存储过程 / 视图 / 校验 SQL
目标表或输出字段：
数据粒度：
时间口径：
纳入规则：
排除规则：
运行参数：
数据库方言：
是否需要先删后插：
是否同步维护知识页：
```
