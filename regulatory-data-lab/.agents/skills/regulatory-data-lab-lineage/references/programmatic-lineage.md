# Programmatic Lineage Extraction

Use `scripts/extract_sql_lineage.py` when SQL is available and the task benefits from a first-pass mechanical extraction before AI writes or updates knowledge pages.

Default engine order is:

1. GSP first, using vendored JAR files under `vendor/gsp/jar/`.
2. sqlglot for supplemental parsing where available.
3. regex fallback for basic table/projection/filter candidates only after GSP prerequisites are satisfied, or when `--engine sqlglot` is explicitly selected.

If JPype, JVM, or GSP JAR loading is unavailable, fix the prerequisite before running the default `--engine auto` path. JPype absence is an environment problem, not a completed lineage extraction.

GSP Lite/free runtimes commonly have an input limit around 10,000 characters. The script handles this before calling GSP:

- `preprocess_for_gsp` normalizes full-width punctuation, removes comments, strips `NOLOGGING`, and compacts blank lines.
- `SQLFLOW_CHAR_LIMIT` controls the limit and defaults to `10000`.
- `split_for_gsp` attempts safe splitting for procedure bodies, multi-statement scripts, multi-row `VALUES`, and top-level `UNION ALL`.
- Chunks still above the limit are not sent to GSP; the output records `gsp_skipped_chunk_count` and `gsp_errors`, then sqlglot/regex fallback still runs.

## Scope

This skill embeds only the reusable parsing methods needed from the lineage engine:

- GSP parser wrapper and GSP relationship mapping (`fdd`, `fdr`, `join`, `call`, `er`)
- Vendored GSP JAR runtime files under `vendor/gsp/jar/`
- SQL splitting with quote/comment/delimiter handling
- Procedure body extraction for `CREATE PROCEDURE ... BEGIN ... END`
- Dialect hints for Oracle and Hive-style syntax
- Table name normalization
- Table-level source-to-target candidates
- Field-level candidates from `INSERT INTO ... SELECT`, CTAS, joins, filters, grouping, ordering, and expressions
- Dependency hints:
  - `fdd`: direct data flow / selected output expression
  - `fdr`: filter, group, having, or order dependency
  - `join`: join condition dependency

Do not import or call the old external `sql-lineage-engine` project. Do not bring in Neo4j export, logs, `.venv`, Docker, uploader logic, or upload/service code. The only copied runtime files are the GSP JARs required by the parser.

## Run

If the environment is new or changed, verify GSP readiness first:

```bash
python3 .agents/skills/regulatory-data-lab-lineage/scripts/check_gsp_prereqs.py
```

On this machine the skill uses a Hermes-managed Python environment when the default `/usr/bin/python3` lacks JPype:

```bash
/opt/homebrew/opt/python@3.12/bin/python3.12 -m venv ~/.hermes/venvs/regulatory-data-lab-lineage
~/.hermes/venvs/regulatory-data-lab-lineage/bin/python -m pip install jpype1
```

`check_gsp_prereqs.py` and `extract_sql_lineage.py --engine auto` automatically re-exec through that environment if it has JPype installed.

From the repository root:

```bash
python3 .agents/skills/regulatory-data-lab-lineage/scripts/extract_sql_lineage.py --file sql/<系统名>/<文件名>.sql --dialect auto --engine auto
```

For a directory:

```bash
python3 .agents/skills/regulatory-data-lab-lineage/scripts/extract_sql_lineage.py --file sql/<系统名>/ --dialect auto --engine auto --output-file /tmp/lineage.json
```

For inline SQL:

```bash
python3 .agents/skills/regulatory-data-lab-lineage/scripts/extract_sql_lineage.py --sql "insert into b(id) select id from a" --dialect auto --engine auto
```

Use `--engine gsp` only when you specifically want to force GSP attempt. Use `--engine sqlglot` only when the user explicitly accepts skipping GSP. Regex-only fallback output is weaker and must be treated as candidate evidence only.

## AI Review Contract

Treat script output as a draft extraction layer. The AI must still:

- Verify every important edge against the SQL snippet and existing knowledge pages.
- Check `gsp_available`, `gsp_error`, and each edge confidence before trusting coverage. `candidate_gsp` is usually stronger than `candidate_regex`, but neither is automatically confirmed.
- Check `gsp_chunk_count`, `gsp_skipped_chunk_count`, and `gsp_errors` for large SQL. If chunks were skipped, mark coverage as incomplete and keep the unresolved parts in Open Questions.
- Convert `relationships` into the lineage page `表级 Edge List`.
- Convert `columnDependencies` into the lineage page `字段级 Edge List`.
- Map dependency hints to repository relation types:
  - `fdd` direct selected expression -> `直接映射`, `条件映射`, `聚合派生`, `窗口派生`, `日期转换`, `码值转换`, `常量赋值`, etc. after reading expression context.
  - `join` -> record in `关键过滤与依赖条件`; only add field edge when it affects a target field or standard field-level coverage requires dependency capture.
  - `fdr` -> record as filter/dependency condition; do not overstate it as a direct source field.
- Mark low-confidence, `UNKNOWN`, unqualified ambiguous fields, star expansion, constants, and expressions as `待确认` unless page/SQL evidence resolves them.
- Add actual Obsidian wikilinks only after confirming the target data table, report, lineage page, or SQL file exists.

## Recommended Documentation Flow

1. Run the script on the relevant SQL file or directory and save JSON when the output is large.
2. Read the target data table page, source data table pages, existing lineage page, report page, and system page.
3. Compare programmatic candidates with existing page content.
4. Write confirmed, suspected, and pending edges separately.
5. For generated lineage pages, use `模板/血缘模板.md`.
6. Update data table pages only with lineage entry links, not upstream/downstream details.
7. Update report or concept pages only if business scope, timing, filters, field meaning, or reusable rules changed.
