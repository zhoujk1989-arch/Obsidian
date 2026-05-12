#!/usr/bin/env python3
"""Check whether GSP can be used by extract_sql_lineage.py.

This is a diagnostic preflight for agents. Missing Java or JPype is not fatal
because extract_sql_lineage.py automatically falls back to sqlglot/regex.
"""

from __future__ import annotations

import glob
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict, List


SKILL_DIR = Path(__file__).resolve().parent.parent
GSP_JAR_DIR = SKILL_DIR / "vendor" / "gsp" / "jar"
SKILL_VENV_PYTHON = Path.home() / ".hermes" / "venvs" / "regulatory-data-lab-lineage" / "bin" / "python"


def candidate_jpype_pythons() -> List[str]:
    candidates = [
        os.environ.get("HERMES_LINEAGE_PYTHON", ""),
        str(SKILL_DIR / ".venv" / "bin" / "python"),
        str(SKILL_VENV_PYTHON),
        "/opt/homebrew/opt/python@3.12/bin/python3.12",
        "/opt/homebrew/opt/python@3.11/bin/python3.11",
        "/opt/homebrew/bin/python3",
    ]
    result: List[str] = []
    seen = set()
    for candidate in candidates:
        if not candidate or candidate in seen:
            continue
        seen.add(candidate)
        if os.path.exists(candidate) and os.access(candidate, os.X_OK):
            result.append(candidate)
    return result


def python_has_jpype(python_executable: str) -> bool:
    try:
        result = subprocess.run(
            [python_executable, "-c", "import jpype"],
            capture_output=True,
            text=True,
            timeout=10,
        )
    except Exception:
        return False
    return result.returncode == 0


def reexec_with_jpype_if_needed() -> None:
    try:
        import jpype  # noqa: F401
        return
    except Exception:
        pass

    current = os.path.realpath(sys.executable)
    for candidate in candidate_jpype_pythons():
        if os.path.realpath(candidate) == current:
            continue
        if python_has_jpype(candidate):
            os.execv(candidate, [candidate, os.path.abspath(__file__), *sys.argv[1:]])


def check_java() -> Dict[str, Any]:
    try:
        result = subprocess.run(["java", "-version"], capture_output=True, text=True, timeout=10)
    except FileNotFoundError:
        return {"name": "java", "ok": False, "detail": "java command not found"}
    except Exception as exc:
        return {"name": "java", "ok": False, "detail": str(exc)}

    output = (result.stderr or result.stdout or "").strip().splitlines()
    first_line = output[0] if output else "java returned no version text"
    return {"name": "java", "ok": result.returncode == 0, "detail": first_line}


def check_jpype() -> Dict[str, Any]:
    try:
        import jpype  # type: ignore
    except Exception as exc:
        return {"name": "jpype", "ok": False, "detail": f"import failed: {exc}"}
    return {"name": "jpype", "ok": True, "detail": f"version {getattr(jpype, '__version__', 'unknown')}"}


def check_jars() -> Dict[str, Any]:
    jars = sorted(glob.glob(str(GSP_JAR_DIR / "*.jar")))
    if not jars:
        return {"name": "gsp_jars", "ok": False, "detail": f"no jars found in {GSP_JAR_DIR}"}
    return {
        "name": "gsp_jars",
        "ok": True,
        "detail": f"{len(jars)} jar(s)",
        "files": [os.path.basename(path) for path in jars],
    }


def main() -> int:
    reexec_with_jpype_if_needed()
    checks: List[Dict[str, Any]] = [check_java(), check_jpype(), check_jars()]
    ready = all(item["ok"] for item in checks)
    payload = {
        "gsp_ready": ready,
        "fallback_available": True,
        "sqlflow_char_limit": os.environ.get("SQLFLOW_CHAR_LIMIT", "10000"),
        "skill_dir": str(SKILL_DIR),
        "checks": checks,
    }

    if "--json" in sys.argv:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        print("GSP prerequisite check")
        for item in checks:
            status = "PASS" if item["ok"] else "WARN"
            print(f"- {status} {item['name']}: {item['detail']}")
        if ready:
            print("Result: GSP is ready. Use extract_sql_lineage.py --engine auto.")
        else:
            install_cmd = (
                "/opt/homebrew/opt/python@3.12/bin/python3.12 -m venv "
                f"{SKILL_VENV_PYTHON.parent.parent} && "
                f"{SKILL_VENV_PYTHON} -m pip install jpype1"
            )
            print("Result: GSP is not ready. Fix prerequisites before lineage extraction.")
            print(f"Suggested JPype setup: {install_cmd}")

    return 0 if ready else 1


if __name__ == "__main__":
    raise SystemExit(main())
