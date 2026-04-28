# SQL Development Artifact Checklist

Use this checklist before finishing durable SQL development tasks.

## Evidence

- Read the repository index if present.
- Read relevant report, table, lineage, source, concept, and system pages.
- Read DDL/field dictionaries only as needed to fill gaps.
- Record external regulatory/source links only in the repository's approved link format.
- Do not treat a field as required merely because it exists in DDL; do not treat it as unnecessary merely because an old SQL omitted it.

## Required Outputs

- SQL draft in the configured development workspace.
- Validation SQL or validation checklist.
- Implementation notes when there are meaningful mappings, assumptions, or user-facing business rules.
- Updated knowledge pages when the output is durable, reusable, or report/interface related.
- Updated index and log when required by the repository.

## SQL Header

The SQL file header should include:

- business objective,
- target system,
- artifact type,
- dependent knowledge pages/materials,
- source tables and roles,
- target table or output,
- parameters,
- refresh/run mode,
- unconfirmed points.

## Knowledge Updates

For knowledge-base repositories, update the correct owner page instead of duplicating content:

- Source page: evidence pack, local files, external links, key findings, conflicts.
- Report page: business scope, reporting grain, inclusion/exclusion rules, field or metric meaning.
- Data table page: field definitions, landing status, table-level indicators, upstream/downstream use.
- Lineage page: table-level chain, field-level source and transformation, gaps and impact.
- Concept/system page: reusable rules, system boundaries, shared date/code concepts.

When updating data table pages, distinguish target-table processing from source-table consumption:

- For the target or written table, record SQL-processed fields when the draft SQL assigns, maps, aggregates, or lands those fields.
- For source, interface, or upstream tables read by the SQL, record downstream usage, consumed fields, related lineage, and downstream objects only.
- Do not mark a source table field as "currently SQL processed" merely because it is used to generate another target table.
- Treat "current SQL processing" on a data table page as SQL that generates or writes that same table unless the repository explicitly defines another meaning.

## Final Response

The final response should include:

- generated or updated file paths,
- evidence used,
- unresolved assumptions,
- recommended first validation SQL/checks,
- any knowledge pages intentionally not updated and why.
