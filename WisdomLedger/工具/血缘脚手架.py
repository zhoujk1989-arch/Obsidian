#!/usr/bin/env python3

"""Generate a first-pass markdown scaffold from a SQL file.

This is intentionally lightweight:
- no external dependencies
- best-effort extraction of CTEs
- best-effort extraction of FROM/JOIN tables
- best-effort extraction of common aggregate metrics

Use it to speed up ingest, not as a substitute for manual review.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


CTE_RE = re.compile(r"\bwith\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+as\s*\(", re.IGNORECASE)
CTE_CHAIN_RE = re.compile(r"(?:\bwith\b|,)\s*([a-zA-Z_][a-zA-Z0-9_]*)\s+as\s*\(", re.IGNORECASE)
TABLE_RE = re.compile(r"\b(?:from|join)\s+([a-zA-Z_][a-zA-Z0-9_\.]*)", re.IGNORECASE)
AGG_RE = re.compile(
    r"\b(sum|count|avg|max|min)\s*\((.*?)\)\s+as\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    re.IGNORECASE | re.DOTALL,
)


def load_sql(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def normalize_sql(sql: str) -> str:
    sql = re.sub(r"--.*?$", "", sql, flags=re.MULTILINE)
    sql = re.sub(r"/\*.*?\*/", "", sql, flags=re.DOTALL)
    return sql


def extract_ctes(sql: str) -> list[str]:
    return [match.group(1) for match in CTE_CHAIN_RE.finditer(sql)]


def extract_tables(sql: str, ctes: list[str]) -> list[str]:
    cte_set = {name.lower() for name in ctes}
    tables = []
    for match in TABLE_RE.finditer(sql):
        candidate = match.group(1)
        if candidate.lower() not in cte_set and candidate not in tables:
            tables.append(candidate)
    return tables


def extract_metrics(sql: str) -> list[tuple[str, str, str]]:
    metrics = []
    for match in AGG_RE.finditer(sql):
        fn = match.group(1).upper()
        expr = " ".join(match.group(2).split())
        alias = match.group(3)
        metrics.append((alias, fn, expr))
    return metrics


def render_markdown(path: Path, ctes: list[str], tables: list[str], metrics: list[tuple[str, str, str]]) -> str:
    lines = []
    lines.append(f"# SQL 脚手架：{path.name}")
    lines.append("")
    lines.append("## File")
    lines.append("")
    lines.append(f"- Path: `{path}`")
    lines.append("")
    lines.append("## Candidate Source Tables")
    lines.append("")
    if tables:
        for table in tables:
            lines.append(f"- `{table}`")
    else:
        lines.append("- No physical tables detected")
    lines.append("")
    lines.append("## CTE Chain")
    lines.append("")
    if ctes:
        for idx, cte in enumerate(ctes, start=1):
            lines.append(f"{idx}. `{cte}`")
    else:
        lines.append("- No CTE detected")
    lines.append("")
    lines.append("## Candidate Metrics")
    lines.append("")
    if metrics:
        lines.append("| Alias | Function | Expression |")
        lines.append("| --- | --- | --- |")
        for alias, fn, expr in metrics:
            lines.append(f"| `{alias}` | `{fn}` | `{expr}` |")
    else:
        lines.append("- No aggregate metric detected")
    lines.append("")
    lines.append("## Manual Review Checklist")
    lines.append("")
    lines.append("- 这份 SQL 对应哪张监管报表")
    lines.append("- 报表的统计对象、时点和粒度是什么")
    lines.append("- 哪些过滤条件决定业务口径")
    lines.append("- 哪些字段需要单独建字段页")
    lines.append("- 是否存在隐含字典映射、汇率折算、去重规则")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate a markdown scaffold from SQL.")
    parser.add_argument("sql_file", help="Path to the SQL file")
    parser.add_argument(
        "-o",
        "--output",
        help="Optional output markdown path. Defaults to stdout.",
    )
    args = parser.parse_args()

    sql_path = Path(args.sql_file)
    sql = normalize_sql(load_sql(sql_path))

    ctes = extract_ctes(sql)
    tables = extract_tables(sql, ctes)
    metrics = extract_metrics(sql)
    markdown = render_markdown(sql_path, ctes, tables, metrics)

    if args.output:
        output_path = Path(args.output)
        output_path.write_text(markdown + "\n", encoding="utf-8")
    else:
        print(markdown)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
