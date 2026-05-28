#!/usr/bin/env python3
"""Validate the public job-kinds contract.

The job-kind contract is published at
``apps/shared-fixtures/schema/job_kinds.json`` and is the single source the
clients consume.

Behaviour:

* Always validates the public JSON (well-formed, 11 unique ``monkeyword/*`` kinds).
* If a local canonical source is provided via the ``MONKEYWORD_JOB_KINDS_SOURCE``
  environment variable (a path to a Python module defining a ``JobKind`` enum),
  this tool statically parses it with :mod:`ast` — it never imports or executes
  it — and exits non-zero if the kind sets drift.

Run from anywhere::

    python tools/gen_job_kinds.py
"""

from __future__ import annotations

import ast
import json
import os
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
JSON_PATH = REPO_ROOT / "apps" / "shared-fixtures" / "schema" / "job_kinds.json"
CANONICAL_SOURCE_ENV = "MONKEYWORD_JOB_KINDS_SOURCE"

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

    source = os.environ.get(CANONICAL_SOURCE_ENV)
    if source and Path(source).exists():
        canonical = enum_string_values(Path(source).read_text(encoding="utf-8"), "JobKind")
        if set(kinds) != set(canonical):
            sys.stderr.write(
                "DRIFT: public contract differs from the canonical source\n"
                f"  public   : {sorted(kinds)}\n"
                f"  canonical: {sorted(canonical)}\n"
            )
            return 1
        print(f"OK: {len(kinds)} job kinds match the canonical source")
    else:
        print(f"OK: {len(kinds)} job kinds validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
