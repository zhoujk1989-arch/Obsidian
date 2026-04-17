#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from datetime import date
from pathlib import Path
import re


def slugify(name: str) -> str:
    cleaned = re.sub(r"[\\\\/:*?\"<>|]+", "-", name.strip())
    cleaned = re.sub(r"\s+", "", cleaned)
    return cleaned


def md_escape(value: str) -> str:
    return value.replace("|", "\\|").replace("\n", "<br>")


def codebook_page_name(codebook_id: str, codebook_name: str) -> str:
    return f"概念-码值集合-{codebook_id}-{codebook_name}"


def load_rows(tsv_path: Path) -> list[dict[str, str]]:
    with tsv_path.open("r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f, delimiter="\t")
        return [{k.strip(): (v or "").strip() for k, v in row.items()} for row in reader]


def render_codebook_page(system_name: str, codebook_id: str, codebook_name: str, rows: list[dict[str, str]], source_page: str, source_path: str) -> str:
    updated = date.today().isoformat()
    page_name = codebook_page_name(codebook_id, codebook_name)
    lines = [
        "---",
        "type: concept",
        f"id: {page_name}",
        "status: draft",
        f"updated: {updated}",
        "tags:",
        "  - regulatory",
        "  - concept",
        "  - codebook",
        "---",
        "",
        f"# {page_name}",
        "",
        "## 系统归属",
        "",
        f"- 所属系统：{system_name}",
        "- 是否仅在本系统内有效：是",
        "- 文件路径是否位于正确系统目录：是",
        "- 如果涉及其他系统，是否已单独建立映射页：否",
        "",
        "## 定义",
        "",
        f"- 码表编号：`{codebook_id}`",
        f"- 码表名称：{codebook_name}",
        f"- 这组码值来自 `[[{source_page}]]`。",
        "",
        "## 适用范围",
        "",
        f"- 来源系统：{system_name}",
        "- 来源表：待补充",
        "- 来源字段：待补充",
        "- 使用该码值集合的报表：待补充",
        "- 使用该码值集合的指标：待补充",
        "",
        "## 码值表",
        "",
        "| sort_no | code_value | code_label | parent_code | level | note | valid_from | valid_to | standard | evidence |",
        "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |",
    ]

    for row in rows:
        lines.append(
            "| {sort_no} | {code_value} | {code_label} | {parent_code} | {level} | {note} | {valid_from} | {valid_to} | {standard} | {evidence} |".format(
                sort_no=md_escape(row.get("排序号", "")),
                code_value=md_escape(row.get("代码", "")),
                code_label=md_escape(row.get("名称", "")),
                parent_code=md_escape(row.get("上级代码", "")),
                level=md_escape(row.get("代码级别", "")),
                note=md_escape(row.get("特别说明", "")),
                valid_from=md_escape(row.get("启用日期", "")),
                valid_to=md_escape(row.get("废止日期", "")),
                standard=md_escape(row.get("执行标准", "")),
                evidence=md_escape(f"[[{source_page}]]"),
            )
        )

    lines.extend(
        [
            "",
            "## 层级摘要",
            "",
            f"- 码值数量：{len(rows)}",
            f"- 最大代码级别：{max((int(r.get('代码级别') or '0') for r in rows), default=0)}",
            f"- 原始材料：`{source_path}`",
            "",
            "## 与监管口径的关系",
            "",
            "- 待结合具体报表 SQL 和监管口径补充纳入、排除和特殊取值规则。",
            "",
            "## 上下游关联",
            "",
            f"- [[{source_page}]]",
            "- [[字段-...]]",
            "- [[报表-...]]",
            "- [[指标-...]]",
            "",
            "## 跨系统映射",
            "",
            "- 默认不在本页直接维护跨系统统一字典。",
            "- 如果需要与其他系统对齐，单独建立 `知识库/码值映射/<系统名>/` 下的映射页。",
            "",
            "## Open Questions",
            "",
            "- 该码表对应的权威业务字段是什么。",
            "- 是否存在仅部分地区、分支机构或报表使用的特殊取值。",
            "- 是否需要和其他系统建立码值映射。",
            "",
        ]
    )
    return "\n".join(lines)


def render_system_overview(system_name: str, rows: list[dict[str, str]], source_page: str, output_dir: Path) -> str:
    updated = date.today().isoformat()
    grouped: dict[tuple[str, str], int] = defaultdict(int)
    for row in rows:
        grouped[(row.get("码表编号", ""), row.get("码表名称", ""))] += 1

    lines = [
        "---",
        "type: concept",
        f"id: 概念-码值总览-{system_name}",
        "status: draft",
        f"updated: {updated}",
        "tags:",
        "  - regulatory",
        "  - concept",
        "  - system",
        "  - codebook",
        "---",
        "",
        f"# 概念-码值总览-{system_name}",
        "",
        "## 定义",
        "",
        f"- 这是 `{system_name}` 的系统级码值总览页。",
        f"- 本系统码值明细统一存放在 `知识库/码值/{system_name}/`。",
        "",
        "## 统计摘要",
        "",
        f"- 码值组数量：{len(grouped)}",
        f"- 码值总条数：{len(rows)}",
        f"- 来源页：[[{source_page}]]",
        "",
        "## 码值组目录",
        "",
        "| 码表编号 | 码表名称 | 码值数量 | 页面 |",
        "| --- | --- | --- | --- |",
    ]

    for (codebook_id, codebook_name), count in sorted(grouped.items()):
        page_name = codebook_page_name(codebook_id, codebook_name)
        path_hint = output_dir / f"{codebook_id}-{slugify(codebook_name)}.md"
        _ = path_hint
        lines.append(f"| `{md_escape(codebook_id)}` | {md_escape(codebook_name)} | {count} | [[{page_name}]] |")

    lines.extend(
        [
            "",
            "## Open Questions",
            "",
            "- 哪些码值组需要优先建立字段关联。",
            "- 哪些码值组已被具体监管报表直接引用。",
            "- 哪些码值组需要跨系统映射。",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="把 TSV 码值字典拆分为按码表编号组织的 Markdown 页面。")
    parser.add_argument("tsv_path", help="原始 TSV 文件路径")
    parser.add_argument("--system", required=True, help="系统名称，例如 监管集市系统")
    parser.add_argument("--source-page", required=True, help="来源页名称，例如 来源-监管集市系统-码值字典")
    args = parser.parse_args()

    tsv_path = Path(args.tsv_path)
    system_name = args.system
    source_page = args.source_page

    rows = load_rows(tsv_path)
    grouped: dict[tuple[str, str], list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[(row.get("码表编号", ""), row.get("码表名称", ""))].append(row)

    repo_root = Path(__file__).resolve().parent.parent
    output_dir = repo_root / "知识库" / "码值" / system_name
    output_dir.mkdir(parents=True, exist_ok=True)

    for (codebook_id, codebook_name), group_rows in grouped.items():
        filename = f"{codebook_id}-{slugify(codebook_name)}.md"
        page = render_codebook_page(system_name, codebook_id, codebook_name, group_rows, source_page, str(tsv_path))
        (output_dir / filename).write_text(page, encoding="utf-8")

    overview_path = output_dir / f"概念-码值总览-{system_name}.md"
    overview = render_system_overview(system_name, rows, source_page, output_dir)
    overview_path.write_text(overview, encoding="utf-8")

    print(f"generated_codebooks={len(grouped)}")
    print(f"generated_rows={len(rows)}")
    print(f"output_dir={output_dir}")


if __name__ == "__main__":
    main()
