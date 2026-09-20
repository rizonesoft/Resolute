#!/usr/bin/env python3
"""D00 T04 §18 decision join: export + authoritative findings + blinded ratings.

Reads the asserted export (rounds, findings refs, costs), parses dispositions
from the authoritative per-section files, values accepted finds at the blinded
severities (ratings.json), and prints the cut-rule legs. The crossover Jaccard
rides adjudicated literals below (matching is judgment; the rationale is in
the §18 record).

Accepted = fixed, filed, cleared. Excluded = refuted, withdrawn, duplicate,
raised (never-defects and the undecided carry no value).
Weights: critical 9, major 3, minor 1 (§8, unchanged).
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
XO = ROOT / "docs" / "reviews" / "crossover" / "2026-09-20-s18"
WINDOW = ["D00-T04-S13", "D00-T04-S14", "D00-T04-S15", "D00-T04-S16",
          "D00-T04-S17"]
SECTION_FILE = {
    "D00-T04-S13": "docs/reviews/00-workspace/D00-T04-s13.md",
    "D00-T04-S14": "docs/reviews/00-workspace/D00-T04-s14.md",
    "D00-T04-S15": "docs/reviews/00-workspace/D00-T04-s15.md",
    "D00-T04-S16": "docs/reviews/00-workspace/D00-T04-s16.md",
    "D00-T04-S17": "docs/reviews/00-workspace/D00-T04-s17.md",
}
WEIGHTS = {"critical": 9, "major": 3, "minor": 1}
ACCEPTED = {"FIXED", "FILED", "CLEARED"}
HEADING_RE = re.compile(r"^### (F\d+) -- .* -- ([^(]+) \((?:independent|self)\)")


def dispositions():
    """Ref -> disposition first word, from the authoritative s-files."""
    out = {}
    for section, rel in SECTION_FILE.items():
        for line in (ROOT / rel).read_text(encoding="utf-8").splitlines():
            m = HEADING_RE.match(line)
            if m:
                out[f"{section}-{m.group(1)}"] = m.group(2).split()[0].upper()
    return out


def tokens(text):
    m = re.fullmatch(r"(\d+)tokens", text or "")
    return int(m.group(1)) if m else None


def main():
    export = json.loads((XO / "export.json").read_text(encoding="utf-8"))
    ratings = json.loads((XO / "ratings.json").read_text(encoding="utf-8"))
    disp = dispositions()
    blinded = {r: v["blinded"] for r, v in ratings["ratings"].items()}
    runs = [r for r in export["runs"]
            if r["section"] in WINDOW and r["runner"] == "panel"]
    assert sorted(r["section"] for r in runs) == sorted(WINDOW), "window"

    value = {"sol": 0, "opus": 0}
    rounds_n = {"sol": 0, "opus": 0}
    cost = {"sol": 0, "opus": 0}
    cost_missing = {"sol": 0, "opus": 0}
    fullscope = {}  # (section, rung) -> weighted value at full scope
    per_section = {}
    for run in runs:
        per_section.setdefault(run["section"], {"sol": [], "opus": []})
        for rl in run["round_lines"]:
            if rl["outcome"] in ("stamp", "independent"):
                continue
            rung = ("sol" if rl["model"] == "gpt-5.6-sol"
                    else "opus" if rl["model"] == "opus" else None)
            if rung is None:
                continue
            rounds_n[rung] += 1
            tok = tokens(rl["cost"])
            if tok is None:
                cost_missing[rung] += 1
            else:
                cost[rung] += tok
            for f in rl["findings"]:
                export_disp = rl["dispositions"].get(f, "raised").upper()
                if disp.get(f, "RAISED") != export_disp:
                    raise SystemExit(
                        f"s-file/export disposition mismatch on {f}: "
                        f"{disp.get(f)} vs {export_disp}")
            refs = [f for f in rl["findings"]
                    if disp.get(f, "RAISED") in ACCEPTED]
            if any(f not in blinded for f in refs):
                missing = [f for f in refs if f not in blinded]
                raise SystemExit(f"unrated accepted refs: {missing}")
            weighted = sum(WEIGHTS[blinded[f]] for f in refs)
            value[rung] += weighted
            if rl["opportunity"] == "full-scope":
                key = (run["section"], rung)
                fullscope[key] = fullscope.get(key, 0) + weighted
        for rung in ("sol", "opus"):
            key = (run["section"], rung)
            if key in fullscope:
                per_section[run["section"]][rung].append(fullscope[key])

    print(f"window: {', '.join(WINDOW)}")
    print(f"export: version {export['export_version']}, "
          f"{len(export['runs'])} runs, as-of {export['as_of']['commit']}")
    for rung in ("sol", "opus"):
        vpc_tok = (f"{value[rung] / cost[rung]:.4f}/token"
                   if cost_missing[rung] == 0 and cost[rung] else "n/a")
        print(f"{rung}: rounds {rounds_n[rung]}, value {value[rung]}, "
              f"tokens {cost[rung]} ({cost_missing[rung]} unresolved), "
              f"value/round {value[rung] / rounds_n[rung]:.2f}, "
              f"value/token {vpc_tok}")
    for section in WINDOW:
        print(f"{section} full-scope value by rung: "
              f"sol {per_section[section]['sol'] or [0]}, "
              f"opus {per_section[section]['opus'] or 'no full-scope round'}")
    # Crossover Jaccard (adjudicated): Sol 0 finds, Opus O1/O2/O3 accepted,
    # zero same-defect pairs (nothing to pair). Union 3, intersection 0.
    sol_xo, opus_xo, pairs = 0, 3, 0
    union = sol_xo + opus_xo - pairs
    print(f"crossover: sol {sol_xo} finds, opus {opus_xo} finds, "
          f"{pairs} pairs, Jaccard "
          f"{pairs / union if union else 0.0:.2f} (frozen c33cb6e)")
    print("overlap leg: DORMANT (1 in-window comparison, needs 2+")


if __name__ == "__main__":
    sys.exit(main())
