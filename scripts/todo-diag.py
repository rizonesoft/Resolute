"""Stable diagnostic codes for the review checkers (D00 T04 §22).

`todo-findings.py` and `todo-runs.py` refused work in line-numbered
English only, so IDE, CI, and dashboard consumers string-matched prose
that any edit could move. Every refusal family now carries a code from
the single registry below, beside the line-numbered message, plus a
machine-readable rendering of the same refusal.

A family is a checking phase, not a message string: all of one phase's
shapes share the phase's code, so a reworded message never renumbers
the family and a new shape inside a phase needs no new code. The
registry maps each code to its CLI exit and family description, and is
the only documented place the list lives: README, skill, and callers
name codes, never redefine them. Emitting an unlisted code raises
instead of printing, so a typo fails closed at the call site.

Usage refusals (FIND-001, RUN-001) always render as text: argv did not
parse, so no format was selected. Every other refusal renders as text
by default or as one JSON array under `--format json` (code, path,
line, message per refusal; null where a refusal has no location).
"""

import json

# code -> (exit, family). Exits: 2 usage, 1 problem report, 0 green
# (green emits nothing; the exit rides the table for the pins).
CODES = {
    # todo-findings.py.
    "FIND-001": (2, "usage: bad flags or arguments"),
    "FIND-002": (1, "unreadable finding headings"),
    "FIND-003": (1, "stale findings ledger"),
    "FIND-004": (1, "incomplete outcome transitions"),
    "FIND-005": (1, "write refused: ledger would drop headings"),
    # todo-runs.py.
    "RUN-001": (2, "usage: conflicting flags or bad arguments"),
    "RUN-002": (1, "run-file read or parse"),
    "RUN-003": (1, "run-block shape"),
    "RUN-004": (1, "finding attribution and coverage"),
    "RUN-005": (1, "panel-round correspondence"),
    "RUN-006": (1, "candidate resolution"),
    "RUN-007": (1, "export document problems"),
}

SCHEMA_KEYS = ("code", "path", "line", "message")


def describe(code: str) -> tuple[int, str]:
    """(exit, family) for a code. Unlisted codes raise KeyError:
    emit nothing that is not in the registry."""
    try:
        return CODES[code]
    except KeyError:
        raise ValueError(f"unlisted diagnostic code {code!r}") from None


def emit(code: str, path: str | None, line: int | None, message: str) -> str:
    """One human refusal line: `path:line: [CODE] message`, with the
    location collapsing to `path:` or nothing when unlocated."""
    describe(code)
    if path is None:
        where = ""
    elif line is None:
        where = f"{path}: "
    else:
        where = f"{path}:{line}: "
    return f"{where}[{code}] {message}"


def refusal(code: str, path: str | None, line: int | None,
             message: str) -> dict:
    """One structured refusal. Same membership rule as emit."""
    describe(code)
    return {"code": code, "path": path, "line": line, "message": message}


def dumps(items: list[dict]) -> str:
    """The canonical JSON rendering: one sorted-key array, also when
    empty (green runs print `[]`, never nothing-at-all)."""
    return json.dumps(items, indent=2, sort_keys=True) + "\n"
