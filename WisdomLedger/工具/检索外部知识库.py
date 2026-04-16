#!/usr/bin/env python3

"""Search the external Obsidian vault for regulatory report sources.

This repository stores SQL and semantic documentation, but not original
regulatory texts. Use this script to search the external vault and record
only path references in local source pages.
"""

from __future__ import annotations

import argparse
from pathlib import Path


EXTERNAL_ROOT = Path("/Users/zhoujingkun/Documents/GitHub/Obsidian/my-dev-brain")
SEARCH_ROOTS = [
    "04-综合/监管系统-报表清单.md",
    "03-实体",
    "02-主题",
    "01-资料库",
    "05-日志",
]


def score_path(path: Path, terms: list[str]) -> int:
    text = str(path).lower()
    score = 0
    for term in terms:
        if term in text:
            score += 5
    if "监管系统-报表清单.md" in text:
        score += 10
    if "/03-实体/" in text:
        score += 8
    if "/01-资料库/" in text:
        score += 6
    if "/02-主题/" in text:
        score += 4
    return score


def build_candidates(terms: list[str], limit: int) -> list[tuple[int, Path]]:
    candidates: list[tuple[int, Path]] = []
    for relative_root in SEARCH_ROOTS:
        root = EXTERNAL_ROOT / relative_root
        if root.is_file():
            haystacks = [root]
        else:
            haystacks = [p for p in root.rglob("*.md") if p.is_file()]
        for path in haystacks:
            text = path.read_text(encoding="utf-8", errors="ignore").lower()
            name = path.name.lower()
            matched_terms = [term for term in terms if term in name or term in text]
            if matched_terms:
                score = score_path(path, matched_terms) + len(matched_terms)
                candidates.append((score, path))
    candidates.sort(key=lambda item: (-item[0], str(item[1])))
    deduped: list[tuple[int, Path]] = []
    seen: set[str] = set()
    for score, path in candidates:
        key = str(path)
        if key in seen:
            continue
        seen.add(key)
        deduped.append((score, path))
        if len(deduped) >= limit:
            break
    return deduped


def render_results(query: str, candidates: list[tuple[int, Path]]) -> str:
    lines = []
    lines.append(f"# 外部知识库检索：{query}")
    lines.append("")
    lines.append(f"- 外部知识库：`{EXTERNAL_ROOT}`")
    lines.append("")
    if not candidates:
        lines.append("- 未找到候选文件")
        return "\n".join(lines)
    lines.append("## 候选文件")
    lines.append("")
    for score, path in candidates:
        try:
            relative_path = path.relative_to(EXTERNAL_ROOT)
        except ValueError:
            relative_path = path
        lines.append(f"- 分值 `{score}` | `{relative_path}`")
    lines.append("")
    lines.append("## 使用建议")
    lines.append("")
    lines.append("- 优先打开分值最高的报表清单页、实体页和原文页")
    lines.append("- 将命中的路径写入本库 `知识库/来源/` 页面的 `external_paths`")
    lines.append("- 只回写结论和路径，不复制原文全文")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Search regulatory sources in the external Obsidian vault.")
    parser.add_argument("query", help="Search query, e.g. 'G01 资产负债项目统计表'")
    parser.add_argument("--limit", type=int, default=12, help="Maximum number of candidates to print")
    args = parser.parse_args()

    terms = [term.strip().lower() for term in args.query.split() if term.strip()]
    candidates = build_candidates(terms, args.limit)
    print(render_results(args.query, candidates))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
