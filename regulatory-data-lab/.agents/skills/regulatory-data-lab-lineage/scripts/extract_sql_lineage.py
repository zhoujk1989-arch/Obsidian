#!/usr/bin/env python3
"""
Self-contained SQL lineage candidate extractor for the regulatory-data-lab-lineage skill.

This script intentionally does not call the external sql-lineage-engine project. It keeps
only the reusable lineage parsing methods needed by the skill:
- SQL splitting with comments/quotes/delimiters
- Lightweight dialect detection
- Table name normalization
- Table-level lineage candidates
- Field-level lineage candidates where SQLGlot is available
- Dependency type hints: fdd, fdr, join

Output is evidence for AI review, not a final confirmed lineage page.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, asdict
from typing import Any, Dict, Iterable, List, Optional, Sequence, Set, Tuple


SQL_EXTENSIONS = (".sql", ".prc", ".pkb", ".pks", ".plb", ".pls", ".fnc", ".trg", ".vw", ".ddl")

RELATION_TYPE_MAP = {
    "fdd": "DERIVES_TO",
    "fdr": "FILTERS",
    "join": "JOINS",
    "call": "CALLS",
    "er": "REFERENCES",
}


ORACLE_PATTERNS = [
    r"\bNVL\s*\(",
    r"\bDECODE\s*\(",
    r"\bTO_CHAR\s*\(",
    r"\bTO_DATE\s*\(",
    r"\bSYSDATE\b",
    r"\bFROM\s+DUAL\b",
    r"CREATE\s+(?:OR\s+REPLACE\s+)?PROCEDURE",
    r"\bVARCHAR2\b",
    r"\bDBMS_OUTPUT\b",
]

HIVE_PATTERNS = [
    r"\bPARTITIONED\s+BY\b",
    r"\bCLUSTERED\s+BY\b",
    r"\bROW\s+FORMAT\b",
    r"\bSTORED\s+AS\b",
    r"\bLATERAL\s+VIEW\b",
    r"\bEXPLODE\s*\(",
    r"(?s)^\s*FROM\s+.*\bINSERT\s+INTO\b",
]


@dataclass(frozen=True)
class TableEdge:
    source: str
    target: str
    type: str
    statement_index: int
    confidence: str = "candidate"


@dataclass(frozen=True)
class ColumnEdge:
    source_table: str
    source_column: str
    target_table: str
    target_column: str
    dependency_type: str
    statement_index: int
    expression: str = ""
    confidence: str = "candidate"


def normalize_table_name(name: str) -> str:
    if not name:
        return name
    clean = name.replace("`", "").replace('"', "").strip()
    parts = [p.strip() for p in clean.split(".") if p.strip()]
    return ".".join(parts) if parts else clean


def normalize_identifier(name: str) -> str:
    if not name:
        return name
    return name.replace("`", "").replace('"', "").strip()


def detect_dialect(sql: str, default: str = "mysql") -> str:
    sql_upper = sql.upper()
    for pattern in ORACLE_PATTERNS:
        if re.search(pattern, sql_upper):
            return "oracle"
    for pattern in HIVE_PATTERNS:
        if re.search(pattern, sql_upper):
            return "hive"
    return default


def read_text(path: str) -> str:
    for encoding in ("utf-8", "gb18030", "gbk", "gb2312", "latin-1"):
        try:
            with open(path, "r", encoding=encoding) as handle:
                return handle.read()
        except UnicodeDecodeError:
            continue
    with open(path, "r", encoding="utf-8", errors="replace") as handle:
        return handle.read()


def strip_comments(sql: str) -> str:
    sql = re.sub(r"/\*.*?\*/", "", sql, flags=re.DOTALL)
    cleaned_lines = []
    for line in sql.splitlines():
        cleaned_lines.append(_strip_inline_comment(line))
    return "\n".join(cleaned_lines)


def preprocess_for_gsp(sql: str) -> str:
    fullwidth_trans = str.maketrans({"（": "(", "）": ")", "，": ",", "。": "."})
    sql = (sql or "").translate(fullwidth_trans)
    sql = re.sub(r"\bNOLOGGING\b", "", sql, flags=re.IGNORECASE)
    return "\n".join(line.strip() for line in strip_comments(sql).splitlines() if line.strip())


def get_gsp_char_limit() -> int:
    raw = os.environ.get("SQLFLOW_CHAR_LIMIT", "10000")
    try:
        return max(1000, int(raw))
    except ValueError:
        return 10000


def split_for_gsp(sql: str, limit: Optional[int] = None) -> List[str]:
    """Prepare SQL chunks for GSP Lite/free character limits."""
    if limit is None:
        limit = get_gsp_char_limit()
    cleaned = preprocess_for_gsp(sql)
    if not cleaned:
        return []
    if len(cleaned) <= limit:
        return [cleaned]

    proc_body = extract_procedure_body(cleaned)
    if proc_body != [cleaned]:
        return [chunk for part in proc_body for chunk in split_for_gsp(part, limit)]

    statements = split_sql(cleaned)
    if len(statements) > 1:
        return [chunk for stmt in statements for chunk in split_for_gsp(stmt, limit)]

    value_chunks = split_values_rows_for_gsp(cleaned, limit)
    if len(value_chunks) > 1:
        return [chunk for part in value_chunks for chunk in split_for_gsp(part, limit)]

    union_chunks = split_union_all_for_gsp(cleaned, limit)
    if len(union_chunks) > 1:
        return [chunk for part in union_chunks for chunk in split_for_gsp(part, limit)]

    return [cleaned]


def split_values_rows_for_gsp(sql: str, limit: int) -> List[str]:
    if len(sql) <= limit:
        return [sql]
    match = re.match(r"(?is)(INSERT\s+INTO\s+.*?\s+VALUES)\s*(.*)", sql)
    if not match:
        return [sql]
    prelude = match.group(1).strip()
    values_str = match.group(2).strip().rstrip(";").strip()
    rows = split_top_level_csv(values_str)
    if len(rows) <= 1:
        return [sql]

    chunks = []
    current_rows: List[str] = []
    current_len = len(prelude) + 1
    for row in rows:
        row_len = len(row) + 2
        if current_rows and current_len + row_len > limit:
            chunks.append(f"{prelude} {', '.join(current_rows)}")
            current_rows = []
            current_len = len(prelude) + 1
        current_rows.append(row)
        current_len += row_len
    if current_rows:
        chunks.append(f"{prelude} {', '.join(current_rows)}")
    return chunks if len(chunks) > 1 else [sql]


def split_union_all_for_gsp(sql: str, limit: int) -> List[str]:
    if len(sql) <= limit or "UNION ALL" not in sql.upper():
        return [sql]
    match = re.match(r"(?is)(INSERT\s+(?:OVERWRITE\s+)?INTO\s+(?:TABLE\s+)?[A-Za-z0-9_.$`\"]+(?:\s*\(.*?\))?)\s+(SELECT\s+.*)", sql)
    if not match:
        return [sql]
    prefix = match.group(1).strip()
    rest = match.group(2).strip().rstrip(";").strip()
    parts = split_top_level_keyword(rest, "UNION ALL")
    if len(parts) <= 1:
        return [sql]
    chunks = [f"{prefix} {part.strip()}" for part in parts if part.strip()]
    return chunks if all(len(chunk) < len(sql) for chunk in chunks) else [sql]


def split_top_level_keyword(text: str, keyword: str) -> List[str]:
    parts = []
    current = []
    depth = 0
    in_single = False
    in_double = False
    i = 0
    while i < len(text):
        ch = text[i]
        if ch == "'" and not in_double:
            if in_single and i + 1 < len(text) and text[i + 1] == "'":
                current.extend([ch, text[i + 1]])
                i += 2
                continue
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
        elif not (in_single or in_double):
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth = max(0, depth - 1)
            elif depth == 0:
                match = re.match(keyword.replace(" ", r"\s+"), text[i:], flags=re.IGNORECASE)
                if match:
                    part = "".join(current).strip()
                    if part:
                        parts.append(part)
                    current = []
                    i += match.end()
                    continue
        current.append(ch)
        i += 1
    part = "".join(current).strip()
    if part:
        parts.append(part)
    return parts


def _strip_inline_comment(line: str) -> str:
    in_single = False
    in_double = False
    i = 0
    while i < len(line):
        ch = line[i]
        if ch == "'" and not in_double:
            if in_single and i + 1 < len(line) and line[i + 1] == "'":
                i += 2
                continue
            in_single = not in_single
        elif ch == '"' and not in_single:
            if in_double and i + 1 < len(line) and line[i + 1] == '"':
                i += 2
                continue
            in_double = not in_double
        elif not in_single and not in_double and ch == "-" and i + 1 < len(line) and line[i + 1] == "-":
            return line[:i]
        i += 1
    return line


def split_sql(sql: str) -> List[str]:
    if not sql:
        return []

    statements: List[str] = []
    current: List[str] = []
    in_single = False
    in_double = False
    in_backtick = False
    in_block_comment = False
    in_line_comment = False
    delimiter = ";"
    i = 0

    while i < len(sql):
        ch = sql[i]

        if not (in_single or in_double or in_backtick or in_block_comment or in_line_comment):
            remainder = sql[i:]
            if not "".join(current).strip() and remainder.upper().startswith("DELIMITER "):
                eol = remainder.find("\n")
                line = remainder if eol == -1 else remainder[:eol]
                parts = line.strip().split()
                if len(parts) >= 2:
                    delimiter = parts[1]
                i = len(sql) if eol == -1 else i + eol + 1
                current = []
                continue
            if ch == "-" and i + 1 < len(sql) and sql[i + 1] == "-":
                in_line_comment = True
                current.extend([ch, sql[i + 1]])
                i += 2
                continue
            if ch == "/" and i + 1 < len(sql) and sql[i + 1] == "*":
                in_block_comment = True
                current.extend([ch, sql[i + 1]])
                i += 2
                continue

        if in_line_comment:
            current.append(ch)
            if ch == "\n":
                in_line_comment = False
            i += 1
            continue

        if in_block_comment:
            current.append(ch)
            if ch == "*" and i + 1 < len(sql) and sql[i + 1] == "/":
                current.append(sql[i + 1])
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue

        if ch == "'" and not (in_double or in_backtick):
            if in_single and i + 1 < len(sql) and sql[i + 1] == "'":
                current.extend([ch, sql[i + 1]])
                i += 2
                continue
            in_single = not in_single
        elif ch == '"' and not (in_single or in_backtick):
            if in_double and i + 1 < len(sql) and sql[i + 1] == '"':
                current.extend([ch, sql[i + 1]])
                i += 2
                continue
            in_double = not in_double
        elif ch == "`" and not (in_single or in_double):
            in_backtick = not in_backtick

        if not (in_single or in_double or in_backtick):
            if sql[i : i + len(delimiter)] == delimiter:
                stmt = "".join(current).strip()
                if stmt:
                    statements.append(stmt)
                current = []
                i += len(delimiter)
                continue

        current.append(ch)
        i += 1

    stmt = "".join(current).strip()
    if stmt:
        statements.append(stmt)
    return statements


def extract_procedure_body(sql: str) -> List[str]:
    body_match = re.search(r"\bBEGIN\b(.*)\bEND\b\s*;?\s*$", sql, flags=re.IGNORECASE | re.DOTALL)
    if not body_match:
        return [sql]
    body = body_match.group(1)
    return split_sql(body) or [sql]


class GSPAdapter:
    def __init__(self, jar_dir: Optional[str] = None):
        self.jar_dir = jar_dir or default_gsp_jar_dir()
        self.error: Optional[str] = None

    def available(self) -> bool:
        try:
            import jpype  # noqa: F401
        except Exception as exc:
            self.error = f"JPype unavailable: {exc}"
            return False
        if not glob.glob(os.path.join(self.jar_dir, "*.jar")):
            self.error = f"No GSP jars found in {self.jar_dir}"
            return False
        return True

    def parse(self, sql: str, dialect: str, source_file: Optional[str], statement_index: int) -> Dict[str, Any]:
        if not self.available():
            return {"error": self.error, "relationships": [], "columnDependencies": []}
        try:
            import jpype

            self._start_jvm(jpype)
            DataFlowAnalyzer = jpype.JClass("gudusoft.gsqlparser.dlineage.DataFlowAnalyzer")
            JSON = jpype.JClass("gudusoft.gsqlparser.util.json.JSON")
            EDbVendor = jpype.JClass("gudusoft.gsqlparser.EDbVendor")
            vendor = self._get_vendor(dialect, EDbVendor)

            limit = get_gsp_char_limit()
            chunks = split_for_gsp(sql, limit)
            mapped_results = []
            errors = []
            skipped = 0
            for chunk_index, cleaned_sql in enumerate(chunks, 1):
                if len(cleaned_sql) > limit:
                    skipped += 1
                    errors.append(f"GSP skipped chunk {chunk_index}: {len(cleaned_sql)} chars exceeds SQLFLOW_CHAR_LIMIT={limit}")
                    continue

                dlineage = DataFlowAnalyzer(cleaned_sql, vendor, True)
                try:
                    dlineage.setShowCallRelation(True)
                    dlineage.setShowIndirectRelation(True)
                    dlineage.setShowJoinRelation(True)
                except Exception:
                    pass

                dlineage.generateDataFlow()
                dataflow = dlineage.getDataFlow()
                if not dataflow:
                    errors.append(f"GSP generated no dataflow for chunk {chunk_index}")
                    continue
                model = DataFlowAnalyzer.getSqlflowJSONModel(dataflow, vendor)
                gsp_json = json.loads(str(JSON.toJSONString(model)))
                mapped = self._map_to_lineage_format(gsp_json, source_file, statement_index)
                mapped["chunk_index"] = chunk_index
                mapped["chunk_count"] = len(chunks)
                mapped_results.append(mapped)

            merged = merge_lineage_results(mapped_results)
            merged["gsp_chunk_count"] = len(chunks)
            merged["gsp_skipped_chunk_count"] = skipped
            merged["gsp_errors"] = errors
            if not mapped_results and errors:
                merged["error"] = "; ".join(errors)
            return merged
        except Exception as exc:
            self.error = str(exc)
            return {"error": self.error, "relationships": [], "columnDependencies": []}

    def _start_jvm(self, jpype: Any) -> None:
        if jpype.isJVMStarted():
            return

        classpath_entries = glob.glob(os.path.join(self.jar_dir, "*.jar"))
        classpath_entries.extend(collect_jaxb_jars())
        classpath = os.pathsep.join(classpath_entries)

        java_home = resolve_java_8_home()
        if java_home:
            os.environ["JAVA_HOME"] = java_home

        jvm_path = jpype.getDefaultJVMPath()
        jpype.startJVM(
            jvm_path,
            "-ea",
            f"-Djava.class.path={classpath}",
            "-Djava.awt.headless=true",
            "-Dcom.sun.xml.bind.v2.bytecode.ClassTailor.noOptimize=true",
        )

    def _get_vendor(self, dialect: str, EDbVendor: Any) -> Any:
        vendor_map = {
            "mysql": "dbvmysql",
            "hive": "dbvhive",
            "oracle": "dbvoracle",
            "gbase": "dbvoracle",
            "postgresql": "dbvpostgresql",
            "postgres": "dbvpostgresql",
            "sqlserver": "dbvsqlserver",
            "tsql": "dbvsqlserver",
            "t-sql": "dbvsqlserver",
        }
        attr = vendor_map.get((dialect or "").lower(), "dbvmysql")
        return getattr(EDbVendor, attr, EDbVendor.dbvmysql)

    def _map_to_lineage_format(self, gsp_json: Dict[str, Any], source_file: Optional[str], statement_index: int) -> Dict[str, Any]:
        dlineage = gsp_json.get("dlineage") or gsp_json
        relationships = []
        column_dependencies = []
        sources: Set[str] = set()
        targets: Set[str] = set()

        for rel in dlineage.get("relationships", []):
            rel_type = rel.get("type", "fdd")
            target = rel.get("target") or {}
            target_table = normalize_table_name(target.get("parentName") or target.get("name") or "")
            target_column = normalize_identifier(target.get("column") or "")
            if target_table and target_table.upper() != "TABLE":
                targets.add(target_table)

            for src in rel.get("sources", []):
                source_table = normalize_table_name(src.get("parentName") or src.get("name") or "")
                source_column = normalize_identifier(src.get("column") or "")
                if not source_table:
                    continue
                sources.add(source_table)
                if target_table and target_table.upper() != "TABLE":
                    relationships.append(
                        {
                            "source": source_table,
                            "target": target_table,
                            "type": rel_type,
                            "neo4j_type": RELATION_TYPE_MAP.get(rel_type, "DERIVES_TO"),
                            "source_column": source_column,
                            "target_column": target_column,
                            "source_file": source_file,
                            "statement_index": statement_index,
                            "confidence": "candidate_gsp",
                        }
                    )
                    if source_column or target_column:
                        column_dependencies.append(
                            {
                                "source_table": source_table,
                                "source_column": source_column or "UNKNOWN",
                                "target_table": target_table,
                                "target_column": target_column or "*",
                                "dependency_type": rel_type,
                                "statement_index": statement_index,
                                "expression": "GSP",
                                "confidence": "candidate_gsp",
                            }
                        )

        return {
            "sources": sorted(sources),
            "targets": sorted(targets),
            "relationships": dedupe_dicts(relationships),
            "columnDependencies": dedupe_dicts(column_dependencies),
            "gsp_json": gsp_json,
        }


def default_gsp_jar_dir() -> str:
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "vendor", "gsp", "jar"))


def collect_jaxb_jars() -> List[str]:
    jar_paths: List[str] = []
    for jar_dir in ["/usr/share/java", "/opt/homebrew/share/java", "/usr/local/share/java"]:
        if os.path.isdir(jar_dir):
            jar_paths.extend(glob.glob(os.path.join(jar_dir, "*.jar")))
    m2_repo = os.path.expanduser("~/.m2/repository")
    if os.path.isdir(m2_repo):
        patterns = [
            "javax/xml/bind/jaxb-api/*/*.jar",
            "javax/activation/activation/*/*.jar",
            "javax/activation/javax.activation-api/*/*.jar",
            "com/sun/xml/bind/jaxb-impl/*/*.jar",
            "com/sun/xml/bind/jaxb-core/*/*.jar",
            "org/glassfish/jaxb/jaxb-runtime/*/*.jar",
            "org/glassfish/jaxb/jaxb-core/*/*.jar",
            "org/glassfish/jaxb/txw2/*/*.jar",
            "com/sun/istack/istack-commons-runtime/*/*.jar",
            "jakarta/activation/jakarta.activation-api/*/*.jar",
        ]
        for pattern in patterns:
            jar_paths.extend(glob.glob(os.path.join(m2_repo, pattern)))
    filtered = []
    seen = set()
    for jar_path in jar_paths:
        name = os.path.basename(jar_path).lower()
        if jar_path in seen:
            continue
        if "jaxb" in name or "activation" in name or "javax.activation" in name:
            seen.add(jar_path)
            filtered.append(jar_path)
    return filtered


def resolve_java_8_home() -> Optional[str]:
    env_java_home = os.environ.get("JAVA_HOME")
    if env_java_home and os.path.exists(env_java_home):
        return env_java_home
    java_home_cmd = "/usr/libexec/java_home"
    if os.path.exists(java_home_cmd):
        try:
            result = subprocess.run([java_home_cmd, "-v", "1.8"], check=True, capture_output=True, text=True)
            java_home = result.stdout.strip()
            if java_home and os.path.exists(java_home):
                return java_home
        except Exception:
            pass
    return None


def merge_lineage_results(results: Sequence[Dict[str, Any]]) -> Dict[str, Any]:
    sources = sorted({source for result in results for source in result.get("sources", [])})
    targets = sorted({target for result in results for target in result.get("targets", [])})
    relationships = dedupe_dicts(rel for result in results for rel in result.get("relationships", []))
    column_dependencies = dedupe_dicts(dep for result in results for dep in result.get("columnDependencies", []))
    gsp_json = [result.get("gsp_json") for result in results if result.get("gsp_json")]
    return {
        "sources": sources,
        "targets": targets,
        "relationships": relationships,
        "columnDependencies": column_dependencies,
        "gsp_json": gsp_json,
    }


def extract_insert_target(sql: str) -> Tuple[Optional[str], List[str]]:
    match = re.search(
        r"\bINSERT\s+(?:OVERWRITE\s+)?INTO\s+(?:TABLE\s+)?([A-Za-z0-9_.$`\"]+)\s*(?:\((.*?)\))?",
        sql,
        flags=re.IGNORECASE | re.DOTALL,
    )
    if not match:
        return None, []
    target = normalize_table_name(match.group(1))
    cols = []
    if match.group(2):
        cols = [normalize_identifier(part) for part in split_top_level_csv(match.group(2))]
    return target, cols


def extract_ctas_target(sql: str) -> Optional[str]:
    match = re.search(
        r"\bCREATE\s+(?:OR\s+REPLACE\s+)?(?:GLOBAL\s+TEMPORARY\s+)?TABLE\s+([A-Za-z0-9_.$`\"]+)\b.*?\bAS\s+SELECT\b",
        sql,
        flags=re.IGNORECASE | re.DOTALL,
    )
    return normalize_table_name(match.group(1)) if match else None


def split_top_level_csv(text: str) -> List[str]:
    items: List[str] = []
    current: List[str] = []
    depth = 0
    in_single = False
    in_double = False
    for idx, ch in enumerate(text):
        if ch == "'" and not in_double:
            if in_single and idx + 1 < len(text) and text[idx + 1] == "'":
                current.append(ch)
                continue
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
        elif not (in_single or in_double):
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth = max(0, depth - 1)
            elif ch == "," and depth == 0:
                item = "".join(current).strip()
                if item:
                    items.append(item)
                current = []
                continue
        current.append(ch)
    item = "".join(current).strip()
    if item:
        items.append(item)
    return items


def strip_alias(expr: str) -> Tuple[str, Optional[str]]:
    match = re.search(r"\s+AS\s+([A-Za-z0-9_`\"]+)\s*$", expr, flags=re.IGNORECASE)
    if match:
        return expr[: match.start()].strip(), normalize_identifier(match.group(1))
    parts = expr.rsplit(None, 1)
    if len(parts) == 2 and re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", parts[1]) and ")" not in parts[1]:
        return parts[0].strip(), normalize_identifier(parts[1])
    return expr.strip(), None


def fallback_table_scan(sql: str) -> Set[str]:
    tables: Set[str] = set()
    clean = strip_comments(sql)
    patterns = [
        r"\bFROM\s+([A-Za-z0-9_.$`\"]+)",
        r"\bJOIN\s+([A-Za-z0-9_.$`\"]+)",
        r"\bUPDATE\s+([A-Za-z0-9_.$`\"]+)",
        r"\bMERGE\s+INTO\s+([A-Za-z0-9_.$`\"]+)",
        r"\bUSING\s+([A-Za-z0-9_.$`\"]+)",
    ]
    for pattern in patterns:
        for match in re.finditer(pattern, clean, flags=re.IGNORECASE):
            name = normalize_table_name(match.group(1))
            if name.upper() not in {"SELECT", "DUAL"}:
                tables.add(name)
    return tables


def fallback_alias_map(sql: str) -> Dict[str, str]:
    aliases: Dict[str, str] = {}
    clean = strip_comments(sql)
    pattern = r"\b(?:FROM|JOIN|USING)\s+([A-Za-z0-9_.$`\"]+)(?:\s+(?:AS\s+)?([A-Za-z_][A-Za-z0-9_]*))?"
    for match in re.finditer(pattern, clean, flags=re.IGNORECASE):
        table = normalize_table_name(match.group(1))
        alias = match.group(2)
        if table.upper() in {"SELECT", "DUAL"}:
            continue
        table_short = table.split(".")[-1]
        aliases[table.upper()] = table
        aliases[table_short.upper()] = table
        if alias and alias.upper() not in {"ON", "WHERE", "JOIN", "GROUP", "HAVING", "ORDER"}:
            aliases[alias.upper()] = table
    return aliases


def load_sqlglot():
    try:
        import sqlglot  # type: ignore
        from sqlglot import exp  # type: ignore

        return sqlglot, exp
    except Exception:
        return None, None


def expression_sql(node: Any) -> str:
    try:
        return node.sql()
    except Exception:
        return str(node)


def sqlglot_tables(statement: str, dialect: str) -> Tuple[Set[str], Dict[str, str], Set[str]]:
    sqlglot, exp = load_sqlglot()
    if not sqlglot:
        return fallback_table_scan(statement), {}, set()

    tables: Set[str] = set()
    aliases: Dict[str, str] = {}
    ctes: Set[str] = set()
    try:
        parsed = sqlglot.parse(statement, dialect=_sqlglot_dialect(dialect))
        for stmt in parsed:
            if stmt is None:
                continue
            for cte in stmt.find_all(exp.CTE):
                if cte.alias:
                    ctes.add(cte.alias.upper())
            for table in stmt.find_all(exp.Table):
                parts = []
                if getattr(table, "catalog", None):
                    parts.append(str(table.catalog))
                if getattr(table, "db", None):
                    parts.append(str(table.db))
                parts.append(table.name)
                name = normalize_table_name(".".join(parts))
                if name.upper() in ctes or name.upper() == "DUAL":
                    continue
                tables.add(name)
                if table.alias:
                    aliases[table.alias.upper()] = name
                aliases[table.name.upper()] = name
    except Exception:
        return fallback_table_scan(statement), {}, set()
    return tables, aliases, ctes


def _sqlglot_dialect(dialect: str) -> Optional[str]:
    mapping = {
        "postgresql": "postgres",
        "postgres": "postgres",
        "sqlserver": "tsql",
        "t-sql": "tsql",
        "spark": "spark",
        "oracle": "oracle",
        "hive": "hive",
        "mysql": "mysql",
    }
    return mapping.get((dialect or "").lower())


def sqlglot_select_projection_edges(
    statement: str,
    dialect: str,
    target_table: str,
    target_columns: Sequence[str],
    statement_index: int,
) -> List[ColumnEdge]:
    sqlglot, exp = load_sqlglot()
    if not sqlglot:
        return fallback_projection_edges(statement, target_table, target_columns, statement_index)

    edges: List[ColumnEdge] = []
    _, aliases, _ = sqlglot_tables(statement, dialect)
    try:
        parsed = sqlglot.parse(statement, dialect=_sqlglot_dialect(dialect))
        for stmt in parsed:
            if stmt is None:
                continue
            select = stmt.find(exp.Select)
            if not select:
                continue
            for idx, projection in enumerate(select.expressions):
                target_col = ""
                if idx < len(target_columns):
                    target_col = target_columns[idx]
                elif isinstance(projection, exp.Alias):
                    target_col = normalize_identifier(projection.alias)
                elif isinstance(projection, exp.Column):
                    target_col = normalize_identifier(projection.name)
                else:
                    target_col = f"EXPR_{idx + 1}"

                source_columns = list(projection.find_all(exp.Column))
                if isinstance(projection, exp.Column) and projection not in source_columns:
                    source_columns.append(projection)
                if not source_columns:
                    edges.append(
                        ColumnEdge(
                            source_table="CONSTANT_OR_EXPRESSION",
                            source_column=expression_sql(projection),
                            target_table=target_table,
                            target_column=target_col,
                            dependency_type="fdd",
                            statement_index=statement_index,
                            expression=expression_sql(projection),
                            confidence="candidate_constant",
                        )
                    )
                    continue

                for col in source_columns:
                    table_alias = (col.table or "").upper()
                    source_table = aliases.get(table_alias) if table_alias else infer_single_source_table(aliases)
                    edges.append(
                        ColumnEdge(
                            source_table=source_table or (col.table or "UNKNOWN"),
                            source_column=normalize_identifier(col.name),
                            target_table=target_table,
                            target_column=target_col,
                            dependency_type="fdd",
                            statement_index=statement_index,
                            expression=expression_sql(projection),
                        )
                    )
    except Exception:
        return fallback_projection_edges(statement, target_table, target_columns, statement_index)
    return edges


def infer_single_source_table(aliases: Dict[str, str]) -> Optional[str]:
    real_tables = {v for v in aliases.values()}
    if len(real_tables) == 1:
        return next(iter(real_tables))
    return None


def fallback_projection_edges(
    statement: str,
    target_table: str,
    target_columns: Sequence[str],
    statement_index: int,
) -> List[ColumnEdge]:
    select_match = re.search(r"\bSELECT\b(.*?)\bFROM\b", statement, flags=re.IGNORECASE | re.DOTALL)
    if not select_match:
        return []
    source_tables = sorted(fallback_table_scan(statement))
    aliases = fallback_alias_map(statement)
    source_table = source_tables[0] if len(source_tables) == 1 else "UNKNOWN"
    edges: List[ColumnEdge] = []
    for idx, expr in enumerate(split_top_level_csv(select_match.group(1))):
        clean_expr, alias = strip_alias(expr)
        target_col = target_columns[idx] if idx < len(target_columns) else alias or f"EXPR_{idx + 1}"
        col_match = re.search(r"(?:(\w+)\.)?(\w+)$", clean_expr)
        alias_source = aliases.get(col_match.group(1).upper()) if col_match and col_match.group(1) else None
        edges.append(
            ColumnEdge(
                source_table=alias_source or (source_table if col_match else "CONSTANT_OR_EXPRESSION"),
                source_column=normalize_identifier(col_match.group(2)) if col_match else clean_expr,
                target_table=target_table,
                target_column=target_col,
                dependency_type="fdd",
                statement_index=statement_index,
                expression=expr,
                confidence="candidate_regex",
            )
        )
    return edges


def sqlglot_condition_edges(
    statement: str,
    dialect: str,
    target_table: str,
    statement_index: int,
) -> List[ColumnEdge]:
    sqlglot, exp = load_sqlglot()
    if not sqlglot:
        return fallback_condition_edges(statement, target_table, statement_index)

    edges: List[ColumnEdge] = []
    _, aliases, _ = sqlglot_tables(statement, dialect)
    contexts = [
        (exp.Join, "join"),
        (exp.Where, "fdr"),
        (exp.Having, "fdr"),
        (exp.Group, "fdr"),
        (exp.Order, "fdr"),
    ]
    try:
        parsed = sqlglot.parse(statement, dialect=_sqlglot_dialect(dialect))
        for stmt in parsed:
            if stmt is None:
                continue
            for node_type, dep_type in contexts:
                for node in stmt.find_all(node_type):
                    for col in node.find_all(exp.Column):
                        table_alias = (col.table or "").upper()
                        source_table = aliases.get(table_alias) if table_alias else infer_single_source_table(aliases)
                        edges.append(
                            ColumnEdge(
                                source_table=source_table or (col.table or "UNKNOWN"),
                                source_column=normalize_identifier(col.name),
                                target_table=target_table,
                                target_column="*",
                                dependency_type=dep_type,
                                statement_index=statement_index,
                                expression=expression_sql(node),
                            )
                        )
    except Exception:
        return fallback_condition_edges(statement, target_table, statement_index)
    return edges


def fallback_condition_edges(statement: str, target_table: str, statement_index: int) -> List[ColumnEdge]:
    source_tables = sorted(fallback_table_scan(statement))
    aliases = fallback_alias_map(statement)
    source_table = source_tables[0] if len(source_tables) == 1 else "UNKNOWN"
    edges: List[ColumnEdge] = []

    join_patterns = re.finditer(r"\bJOIN\b\s+[A-Za-z0-9_.$`\"]+(?:\s+\w+)?\s+\bON\b\s+(.*?)(?=\bJOIN\b|\bWHERE\b|\bGROUP\b|\bHAVING\b|\bORDER\b|$)", statement, flags=re.IGNORECASE | re.DOTALL)
    for match in join_patterns:
        expr = match.group(1).strip()
        for alias, col in extract_column_refs(expr):
            resolved_source = aliases.get(alias.upper()) if alias else source_table
            edges.append(
                ColumnEdge(
                    source_table=resolved_source or source_table,
                    source_column=col,
                    target_table=target_table,
                    target_column="*",
                    dependency_type="join",
                    statement_index=statement_index,
                    expression=compact_sql(expr, limit=240),
                    confidence="candidate_regex",
                )
            )

    filter_patterns = re.finditer(r"\b(WHERE|HAVING|GROUP\s+BY|ORDER\s+BY)\b\s+(.*?)(?=\bGROUP\b|\bHAVING\b|\bORDER\b|$)", statement, flags=re.IGNORECASE | re.DOTALL)
    for match in filter_patterns:
        expr = match.group(2).strip()
        for alias, col in extract_column_refs(expr):
            resolved_source = aliases.get(alias.upper()) if alias else source_table
            edges.append(
                ColumnEdge(
                    source_table=resolved_source or source_table,
                    source_column=col,
                    target_table=target_table,
                    target_column="*",
                    dependency_type="fdr",
                    statement_index=statement_index,
                    expression=compact_sql(expr, limit=240),
                    confidence="candidate_regex",
                )
            )
    return dedupe_column_edges(edges)


def extract_column_tokens(expr: str) -> List[str]:
    return sorted({col for _, col in extract_column_refs(expr)})


def extract_column_refs(expr: str) -> List[Tuple[str, str]]:
    expr = re.sub(r"'(?:''|[^'])*'", " ", expr)
    expr = re.sub(r'"(?:""|[^"])*"', " ", expr)
    refs: List[Tuple[str, str]] = []
    reserved = {
        "AND", "OR", "NOT", "NULL", "IS", "IN", "EXISTS", "LIKE", "BETWEEN",
        "CASE", "WHEN", "THEN", "ELSE", "END", "ON", "WHERE", "GROUP", "BY",
        "ORDER", "HAVING", "ASC", "DESC", "AS", "SELECT", "FROM", "JOIN",
    }
    for alias, raw in re.findall(r"(?:(\b[A-Za-z_][A-Za-z0-9_]*)\.)?\b([A-Za-z_][A-Za-z0-9_]*)\b", expr):
        token = normalize_identifier(raw)
        if token.upper() in reserved or alias.upper() in reserved:
            continue
        if re.fullmatch(r"\d+", token):
            continue
        refs.append((normalize_identifier(alias), token))
    return sorted(set(refs))


def parse_statement(
    statement: str,
    statement_index: int,
    dialect: str,
    default_schema: Optional[str],
    engine: str,
    gsp_adapter: Optional[GSPAdapter],
) -> Dict[str, Any]:
    target, target_columns = extract_insert_target(statement)
    if not target:
        target = extract_ctas_target(statement)
    if default_schema and target and "." not in target:
        target = f"{default_schema}.{target}"

    gsp_result: Dict[str, Any] = {"relationships": [], "columnDependencies": []}
    if engine in {"auto", "gsp"} and gsp_adapter:
        gsp_result = gsp_adapter.parse(statement, dialect, None, statement_index)

    sources, _, _ = sqlglot_tables(statement, dialect)
    if gsp_result.get("sources"):
        sources.update(gsp_result.get("sources", []))
    if target:
        sources = {s for s in sources if s.upper() != target.upper()}
    elif gsp_result.get("targets"):
        target = gsp_result["targets"][0]
    if default_schema:
        sources = {f"{default_schema}.{s}" if "." not in s and s.upper() != "DUAL" else s for s in sources}

    table_edges = []
    if gsp_result.get("relationships"):
        table_edges = [
            TableEdge(
                source=rel.get("source", ""),
                target=rel.get("target", target or ""),
                type=rel.get("type", "fdd"),
                statement_index=statement_index,
                confidence=rel.get("confidence", "candidate_gsp"),
            )
            for rel in gsp_result.get("relationships", [])
            if rel.get("source") and rel.get("target")
        ]
    elif target:
        table_edges = [
            TableEdge(source=s, target=target, type="fdd", statement_index=statement_index)
            for s in sorted(sources)
            if s.upper() != "DUAL"
        ]

    column_edges: List[ColumnEdge] = []
    if target:
        gsp_columns = [
            ColumnEdge(
                source_table=dep.get("source_table", ""),
                source_column=dep.get("source_column", ""),
                target_table=dep.get("target_table", target),
                target_column=dep.get("target_column", ""),
                dependency_type=dep.get("dependency_type", "fdd"),
                statement_index=statement_index,
                expression=dep.get("expression", "GSP"),
                confidence=dep.get("confidence", "candidate_gsp"),
            )
            for dep in gsp_result.get("columnDependencies", [])
            if dep.get("source_table") and dep.get("target_table")
        ]
        column_edges.extend(gsp_columns)
        has_gsp_direct = any(edge.dependency_type == "fdd" for edge in gsp_columns)
        if not has_gsp_direct:
            column_edges.extend(sqlglot_select_projection_edges(statement, dialect, target, target_columns, statement_index))
        column_edges.extend(sqlglot_condition_edges(statement, dialect, target, statement_index))

    return {
        "statement_index": statement_index,
        "target": target,
        "sources": sorted(sources),
        "relationships": [asdict(edge) for edge in table_edges],
        "columnDependencies": [asdict(edge) for edge in dedupe_column_edges(column_edges)],
        "engine": "gsp+sqlglot" if gsp_result.get("relationships") or gsp_result.get("columnDependencies") else "sqlglot_or_regex",
        "gsp_error": gsp_result.get("error"),
        "gsp_chunk_count": gsp_result.get("gsp_chunk_count"),
        "gsp_skipped_chunk_count": gsp_result.get("gsp_skipped_chunk_count"),
        "gsp_errors": gsp_result.get("gsp_errors"),
        "statement_preview": compact_sql(statement),
    }


def dedupe_column_edges(edges: Iterable[ColumnEdge]) -> List[ColumnEdge]:
    seen = set()
    result = []
    for edge in edges:
        key = (
            edge.source_table,
            edge.source_column,
            edge.target_table,
            edge.target_column,
            edge.dependency_type,
            edge.expression,
        )
        if key in seen:
            continue
        seen.add(key)
        result.append(edge)
    return result


def compact_sql(sql: str, limit: int = 500) -> str:
    compact = re.sub(r"\s+", " ", strip_comments(sql)).strip()
    return compact if len(compact) <= limit else compact[: limit - 3] + "..."


def parse_sql(
    sql: str,
    source_file: Optional[str],
    dialect: str,
    default_schema: Optional[str],
    engine: str,
    gsp_jar_dir: Optional[str],
) -> Dict[str, Any]:
    effective_dialect = detect_dialect(sql, default="mysql") if dialect == "auto" else dialect
    initial_statements = split_sql(sql)
    statements: List[str] = []
    for stmt in initial_statements:
        if re.search(r"(?i)CREATE\s+.*?\bPROCEDURE\b", stmt):
            statements.extend(extract_procedure_body(stmt))
        else:
            statements.append(stmt)

    gsp_adapter = GSPAdapter(gsp_jar_dir) if engine in {"auto", "gsp"} else None
    parsed_statements = [
        parse_statement(stmt, idx + 1, effective_dialect, default_schema, engine, gsp_adapter)
        for idx, stmt in enumerate(statements)
        if stmt.strip()
    ]

    relationships = dedupe_dicts(
        rel for item in parsed_statements for rel in item.get("relationships", [])
    )
    column_dependencies = dedupe_dicts(
        dep for item in parsed_statements for dep in item.get("columnDependencies", [])
    )
    sources = sorted({rel["source"] for rel in relationships if rel.get("source")})
    targets = sorted({rel["target"] for rel in relationships if rel.get("target")})

    return {
        "source_file": source_file,
        "dialect": effective_dialect,
        "parser": "regulatory-data-lab-lineage.script",
        "engine": engine,
        "gsp_jar_dir": gsp_adapter.jar_dir if gsp_adapter else None,
        "gsp_available": gsp_adapter.available() if gsp_adapter else False,
        "gsp_error": gsp_adapter.error if gsp_adapter else None,
        "notes": [
            "Engine order: GSP first when available, then sqlglot/regex supplement.",
            "Programmatic output is candidate evidence for AI review.",
            "Confirm business meaning, object pages, SQL locations, and unresolved ambiguities before writing validated lineage.",
        ],
        "sources": sources,
        "targets": targets,
        "relationships": relationships,
        "columnDependencies": column_dependencies,
        "statements": parsed_statements,
    }


def dedupe_dicts(items: Iterable[Dict[str, Any]]) -> List[Dict[str, Any]]:
    seen = set()
    result = []
    for item in items:
        key = json.dumps(item, ensure_ascii=False, sort_keys=True)
        if key in seen:
            continue
        seen.add(key)
        result.append(item)
    return result


def discover_sql_files(path: str) -> List[str]:
    if os.path.isfile(path):
        return [path]
    files = []
    for root, _, names in os.walk(path):
        for name in names:
            if name.lower().endswith(SQL_EXTENSIONS):
                files.append(os.path.join(root, name))
    return sorted(files)


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract SQL lineage candidates for AI-assisted documentation.")
    input_group = parser.add_mutually_exclusive_group(required=True)
    input_group.add_argument("--sql", help="SQL text to parse")
    input_group.add_argument("--file", help="SQL file or directory")
    parser.add_argument("--dialect", default="auto", help="auto, oracle, hive, mysql, postgres, spark, tsql")
    parser.add_argument("--engine", default="auto", choices=["auto", "gsp", "sqlglot"], help="auto prefers GSP then supplements with sqlglot/regex")
    parser.add_argument("--gsp-jar-dir", help="Directory containing GSP jar files; defaults to skill vendor/gsp/jar")
    parser.add_argument("--default-schema", help="Schema to prefix unqualified tables")
    parser.add_argument("--output-file", help="Write JSON output to this file")
    args = parser.parse_args()

    if args.sql:
        results: Dict[str, Any] = parse_sql(args.sql, None, args.dialect, args.default_schema, args.engine, args.gsp_jar_dir)
    else:
        files = discover_sql_files(args.file)
        per_file = [parse_sql(read_text(path), path, args.dialect, args.default_schema, args.engine, args.gsp_jar_dir) for path in files]
        results = {
            "parser": "regulatory-data-lab-lineage.script",
            "engine": args.engine,
            "input": args.file,
            "file_count": len(files),
            "files": per_file,
            "relationships": dedupe_dicts(rel for item in per_file for rel in item.get("relationships", [])),
            "columnDependencies": dedupe_dicts(dep for item in per_file for dep in item.get("columnDependencies", [])),
        }

    output = json.dumps(results, ensure_ascii=False, indent=2)
    if args.output_file:
        with open(args.output_file, "w", encoding="utf-8") as handle:
            handle.write(output)
            handle.write("\n")
    else:
        print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
