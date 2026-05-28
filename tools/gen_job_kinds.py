#!/usr/bin/env python3
"""Validate (and optionally regenerate) the public job-kinds contract.

The canonical job-kind list lives in the private server repository
(``s2-monkeyword/shared/job_kinds.py``). This tool **statically parses** that
file with the :mod:`ast` module — it never imports or executes it — and compares
the kind strings against the committed public contract at
``apps/shared-fixtures/schema/job_kinds.json``.

Behaviour:

* Always validates the public JSON (well-formed, 11 unique ``monkeyword/*`` kinds).
* If the private source is present next to this repo, checks for drift and
  exits non-zero if the kind sets differ.
* In CI (private repo absent) it validates the JSON only.

Run from anywhere::

    python tools/gen_job_kinds.py
"""

from __future__ import annotations

import ast
import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
JSON_PATH = REPO_ROOT / "apps" / "shared-fixtures" / "schema" / "job_kinds.json"
PRIVATE_SOURCE = REPO_ROOT.parent / "s2-monkeyword" / "shared" / "job_kinds.py"

EXPECTED_COUNT = 11
PREFIX = "monkeyword/"


def public_kinds() -> list[str]:
    data = json.loads(JSON_PATH.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or "kinds" not in data:
        raise ValueError("job_kinds.json must be an object with a 'kinds' array")
    kinds = [entry["value"] for entry in data["kinds"]]
    return kinds


def enum_string_values(source: str, class_name: str) -> list[str]:
    """Return string constants assigned in ``class class_name`` (enum members).

    Uses ast only — the parsed module is never executed.
    """
    tree = ast.parse(source)
    for node in ast.walk(tree):
        if isinstance(node, ast.ClassDef) and node.name == class_name:
            values: list[str] = []
            for stmt in node.body:
                if isinstance(stmt, ast.Assign) and isinstance(stmt.value, ast.Constant):
                    if isinstance(stmt.value.value, str):
                        values.append(stmt.value.value)
            return values
    return []


def validate(kinds: list[str]) -> None:
    if len(kinds) != EXPECTED_COUNT:
        raise SystemExit(f"FAIL: expected {EXPECTED_COUNT} kinds, found {len(kinds)}")
    if len(set(kinds)) != len(kinds):
        raise SystemExit("FAIL: duplicate job kinds in public contract")
    bad = [k for k in kinds if not k.startswith(PREFIX)]
    if bad:
        raise SystemExit(f"FAIL: kinds without '{PREFIX}' prefix: {bad}")


def main() -> int:
    kinds = public_kinds()
    validate(kinds)

    if PRIVATE_SOURCE.exists():
        private = enum_string_values(PRIVATE_SOURCE.read_text(encoding="utf-8"), "JobKind")
        if set(kinds) != set(private):
            sys.stderr.write(
                "DRIFT: public contract differs from private SSoT\n"
                f"  public : {sorted(kinds)}\n"
                f"  private: {sorted(private)}\n"
            )
            return 1
        print(f"OK: {len(kinds)} job kinds match the private SSoT")
    else:
        print(f"OK: {len(kinds)} job kinds validated (private SSoT not present)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
