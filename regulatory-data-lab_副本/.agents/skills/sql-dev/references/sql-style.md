# SQL Style Reference

Load this reference when writing SQL, stored procedures, views, insert-selects, ETL scripts, or validation SQL.

## General Style

- Prefer business-readable SQL comments. Explain why a field/filter exists, not merely what the syntax does.
- Do not use `select *`.
- Keep target fields in the order required by the target table DDL, data-table page, or user-specified output list.
- Use explicit aliases that reflect table roles, such as `src`, `acct`, `cust`, `org`, `dim`, or meaningful abbreviations already used by the project.
- Join on business keys with clear date/version conditions. Do not join only because columns share a name.
- Normalize empty strings deliberately when the target semantics require it, for example `NULLIF(TRIM(col), '')`.
- Keep database dialect consistent. If dialect is unknown, write conservative ANSI-style SQL and mark dialect as unconfirmed.

## Query Shape

- Default to direct `select` plus `left join` for ordinary field mapping, dimension enrichment, and code conversion.
- Use CTEs only when they materially improve correctness or readability, such as:
  - pre-aggregation before joining,
  - window-function de-duplication,
  - reusing the same intermediate result,
  - isolating complex eligibility logic.
- For large tables, push partition/date/org filters as early as possible and avoid accidental Cartesian products.
- For detail outputs, define what one row represents and how duplicates are prevented or intentionally allowed.
- For aggregate outputs, define grouping grain, numerator/denominator, de-duplication, null handling, and aggregate functions.

## Date and Refresh Rules

- Distinguish run date, data date, transaction date, accounting date, natural date, report period, and collection date.
- For re-runnable loads, make `delete` scope match `insert` scope exactly, using date/period/org/batch filters as appropriate.
- For snapshots, state whether the output is full snapshot, incremental, or final-state carry-forward.
- For incremental outputs, state inclusion window and whether late-arriving changes are handled.

## Field Mapping Rules

- Every target field should map to exactly one of:
  - direct source field,
  - transformed source field,
  - constant,
  - code mapping,
  - derived expression,
  - aggregation,
  - intentionally null/not applicable,
  - unresolved pending confirmation.
- For money, balance, rate, date, institution, customer, account, contract, product, and transaction identifiers, name the source table and source field in comments or notes.
- For constants, explain the business meaning and source of the constant.
- For code fields, use only documented values. Missing enum evidence must become an open question, not an invented mapping.

## Stored Procedure Rules

- Define input parameters, output parameters if needed, transaction strategy, error handling, and logging expectations.
- Choose and document one refresh strategy: delete-and-reload, incremental append, or snapshot refresh.
- Use meaningful procedure and temporary object names. Avoid names like `tmp1` unless the project already standardizes them.
- Include row-count capture or logging placeholders when production logging tables are unknown.

## Validation SQL

Include checks appropriate to the artifact:

- target row count by date/period/org,
- primary key or expected unique-key duplicates,
- required fields null or blank,
- code fields outside allowed values,
- date format and date range anomalies,
- amount/balance sign or extreme-value anomalies,
- orphan joins or missing dimension enrichment,
- source-to-target sampling traceback,
- delete/insert scope consistency for reruns.
