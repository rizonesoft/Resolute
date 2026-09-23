"""Slot resolution for the review panel (D00 T04 §27).

`.conclave/panel.toml` binds every review role to a (model, effort,
timeout) slot, names the writer, and registers the models. Skills run a
role as `python scripts/panel_slots.py exec <slot>` and never name a
model; `todo-runs.py` reads family-to-model sets from here. Ported from
ScratchPad's D00 T04 §15 and §23, with the model set moved out of this
module and into the table's registry so a re-pin is one file.

Governance, not convenience:
- PANEL_SLOTS is exact. A slot is regime (the outage matrix in the
  review skill names it), so an extra slot without matrix prose is
  ungoverned and fails, and a missing one fails.
- PANEL_EFFORTS is closed. A new level arrives with probes plus review.
- A slot names a registered model that is not retired.
- Same-family fallbacks repeat their leader's effort (EFFORT_PARITY).
- Every governing slot is a different family from the writer's: the
  writer never signs off, bulk-reviews, or plan-reviews its own work.
  WRITER_FAMILY_SLOTS are the two that fill an outage from the writer's
  family and owe an outage note or a retry in the record.

    python scripts/panel_slots.py validate
    python scripts/panel_slots.py show
    python scripts/panel_slots.py argv <slot> [extra...]
    python scripts/panel_slots.py get <slot> model|effort|timeout|family
    python scripts/panel_slots.py writer [model|family]
    python scripts/panel_slots.py family <model>
    python scripts/panel_slots.py models <codex|claude> [--all]
    python scripts/panel_slots.py exec <slot> [extra...] < prompt > out 2> err
    python scripts/panel_slots.py --self-test

`exec` runs the slot's producer with the prompt on stdin, enforces the
slot timeout, and exits 124 on expiry (the `timeout` convention the
outage matrix keys on). The `independent` slot runs `codex review`,
which takes its scope from the extra arguments (`--commit <sha>`) and
reads no prompt.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
import tempfile
import tomllib

PANEL_FAMILIES = ("codex", "claude")
PANEL_EFFORTS = ("medium", "high", "xhigh")
PANEL_SLOTS = (
    "bulk",
    "signoff",
    "depth",
    "bulk-fallback",
    "signoff-fallback",
    "cross-fill",
    "plan-primary",
    "plan-fallback",
    "stamp-check",
    "independent",
    "arch-primary",
    "arch-fallback",
)
# Fill a double outage from the writer's family; the record says so.
WRITER_FAMILY_SLOTS = ("cross-fill", "plan-fallback")
# (follower, leader): a same-family failover repeats the leader's effort.
EFFORT_PARITY = (("bulk-fallback", "bulk"), ("signoff-fallback", "signoff"),
                 ("arch-fallback", "arch-primary"))
# (fallback, primary): a fallback stays in its primary's family.
SAME_FAMILY = (("bulk-fallback", "bulk"), ("signoff-fallback", "signoff"),
               ("arch-fallback", "arch-primary"))
TIMEOUT_EXIT = 124
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


class PanelSlotsError(ValueError):
    """A naming diagnostic for panel-slot resolution failures."""


def toml_path() -> str:
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.normpath(os.path.join(here, "..", ".conclave", "panel.toml"))


def _read(path: str | None) -> dict:
    src = path or toml_path()
    try:
        with open(src, "rb") as fh:
            return tomllib.load(fh)
    except FileNotFoundError:
        raise PanelSlotsError(f"panel slots file {src} does not exist")
    except tomllib.TOMLDecodeError as exc:
        raise PanelSlotsError(f"panel slots file {src} does not parse: {exc}")


def _registry(doc: dict) -> dict[str, dict]:
    models = doc.get("model")
    if not isinstance(models, dict) or not models:
        raise PanelSlotsError("panel slots file carries no [model.*] registry")
    out: dict[str, dict] = {}
    for name, entry in models.items():
        if not isinstance(entry, dict):
            raise PanelSlotsError(f"model {name!r} is not a table")
        family = entry.get("family")
        if family not in PANEL_FAMILIES:
            raise PanelSlotsError(f"model {name!r} family {family!r} is outside {', '.join(PANEL_FAMILIES)}")
        retired = entry.get("retired")
        probed = entry.get("probed")
        for key, value in (("retired", retired), ("probed", probed)):
            if value is not None and (not isinstance(value, str) or not DATE_RE.match(value)):
                raise PanelSlotsError(f"model {name!r} {key} {value!r} is not a YYYY-MM-DD date")
        if retired is None and probed is None:
            raise PanelSlotsError(f"model {name!r} is live but carries no probed date")
        out[name] = {"family": family, "retired": retired, "probed": probed}
    return out


def load(path: str | None = None) -> dict:
    """Load and validate the whole table. Raises PanelSlotsError naming why not.

    Returns {"writer": {model, family}, "models": {...}, "slots": {...}}."""
    doc = _read(path)
    models = _registry(doc)
    writer = doc.get("writer")
    if not isinstance(writer, dict) or "model" not in writer:
        raise PanelSlotsError("panel slots file carries no [writer] model")
    wmodel = writer["model"]
    if wmodel not in models:
        raise PanelSlotsError(f"writer model {wmodel!r} is not registered")
    if models[wmodel]["retired"]:
        raise PanelSlotsError(f"writer model {wmodel!r} is retired")
    wfamily = models[wmodel]["family"]
    tables = doc.get("slot")
    if not isinstance(tables, dict):
        raise PanelSlotsError("panel slots file carries no [slot.*] tables")
    missing = [name for name in PANEL_SLOTS if name not in tables]
    if missing:
        raise PanelSlotsError(f"panel slots file is missing slots: {', '.join(missing)}")
    extra = sorted(name for name in tables if name not in PANEL_SLOTS)
    if extra:
        raise PanelSlotsError(f"panel slots file carries ungoverned slots: {', '.join(extra)}")
    slots: dict[str, dict] = {}
    for name in PANEL_SLOTS:
        entry = tables[name]
        if not isinstance(entry, dict):
            raise PanelSlotsError(f"panel slot {name!r} is not a table")
        model = entry.get("model")
        if model not in models:
            raise PanelSlotsError(f"panel slot {name!r} model {model!r} is not registered")
        if models[model]["retired"]:
            raise PanelSlotsError(
                f"panel slot {name!r} model {model!r} retired {models[model]['retired']}")
        effort = entry.get("effort")
        if effort not in PANEL_EFFORTS:
            raise PanelSlotsError(
                f"panel slot {name!r} effort {effort!r} is outside {', '.join(PANEL_EFFORTS)}")
        timeout = entry.get("timeout")
        if type(timeout) is not int or timeout <= 0:
            raise PanelSlotsError(f"panel slot {name!r} timeout {timeout!r} is not a positive integer")
        family = models[model]["family"]
        if name not in WRITER_FAMILY_SLOTS and family == wfamily:
            raise PanelSlotsError(
                f"panel slot {name!r} runs the writer's family {family!r}: "
                f"a governing slot never reviews its own writer")
        slots[name] = {"model": model, "effort": effort, "timeout": timeout, "family": family}
    if slots["independent"]["family"] != "codex":
        raise PanelSlotsError("panel slot 'independent' runs `codex review` and needs a codex model")
    for follower, leader in EFFORT_PARITY:
        if slots[follower]["effort"] != slots[leader]["effort"]:
            raise PanelSlotsError(
                f"panel slot {follower!r} effort {slots[follower]['effort']!r} does not repeat "
                f"slot {leader!r} effort {slots[leader]['effort']!r}")
    for fallback, primary in SAME_FAMILY:
        if slots[fallback]["family"] != slots[primary]["family"]:
            raise PanelSlotsError(
                f"panel slot {fallback!r} family {slots[fallback]['family']!r} leaves "
                f"slot {primary!r} family {slots[primary]['family']!r}")
    return {"writer": {"model": wmodel, "family": wfamily}, "models": models, "slots": slots}


def load_slots(path: str | None = None) -> dict[str, dict]:
    return load(path)["slots"]


def family_models(family: str, path: str | None = None, include_retired: bool = True) -> tuple[str, ...]:
    """Every registered model of a family, retired ones included by default:
    historical records name retired pins and must keep parsing."""
    models = load(path)["models"]
    return tuple(sorted(name for name, entry in models.items()
                        if entry["family"] == family and (include_retired or not entry["retired"])))


def _exe(name: str) -> str:
    # npm installs `codex` as a .cmd shim on Windows; resolve it so
    # subprocess finds it without a shell.
    return shutil.which(name) or name


def argv_for_slot(slot: str, extra: list[str] | None = None, table: dict | None = None) -> list[str]:
    """Producer argv for a slot. Raises PanelSlotsError naming why not."""
    slots = (table or load())["slots"]
    if slot not in slots:
        raise PanelSlotsError(f"panel slot {slot!r} is unknown (known: {', '.join(PANEL_SLOTS)})")
    entry = slots[slot]
    model, effort, extra = entry["model"], entry["effort"], list(extra or [])
    if slot == "independent":
        # `codex review` refuses a prompt beside a scope flag, so the
        # extra args carry the scope and nothing rides stdin.
        return ["codex", "review", *extra, "-c", f'model="{model}"',
                "-c", f'model_reasoning_effort="{effort}"']
    if entry["family"] == "codex":
        return ["codex", "exec", "-m", model, "-c", f'model_reasoning_effort="{effort}"',
                "-s", "read-only", *extra, "-"]
    # --allowedTools stays last: the flag is variadic.
    return ["claude", "-p", "--model", model, "--effort", effort,
            "--output-format", "json", *extra, "--allowedTools", "Read"]


def _kill_tree(proc: subprocess.Popen) -> None:
    if os.name == "nt":
        subprocess.run(["taskkill", "/T", "/F", "/PID", str(proc.pid)],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        proc.kill()


def exec_slot(slot: str, extra: list[str], stdin, stdout, stderr, table: dict | None = None) -> int:
    """Run the slot's producer; return its exit code, or 124 on timeout."""
    table = table or load()
    argv = argv_for_slot(slot, extra, table)
    argv[0] = _exe(argv[0])
    timeout = table["slots"][slot]["timeout"]
    entry = table["slots"][slot]
    print(f"panel_slots: slot {slot} model {entry['model']} effort {entry['effort']} "
          f"timeout {timeout}s", file=sys.stderr, flush=True)
    feed = None if slot == "independent" else stdin
    proc = subprocess.Popen(argv, stdin=feed if feed is not None else subprocess.DEVNULL,
                            stdout=stdout, stderr=stderr)
    try:
        return proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        _kill_tree(proc)
        proc.wait()
        print(f"panel_slots: slot {slot} timed out after {timeout}s", file=sys.stderr, flush=True)
        return TIMEOUT_EXIT


# --- self-test ---------------------------------------------------------------

GOOD = """
[writer]
model = "w-claude"
[model."w-claude"]
family = "claude"
probed = "2026-09-23"
[model."g-one"]
family = "codex"
probed = "2026-09-23"
[model."g-two"]
family = "codex"
probed = "2026-09-23"
[model."g-old"]
family = "codex"
retired = "2026-09-01"
[slot.bulk]
model = "g-one"
effort = "medium"
timeout = 600
[slot.signoff]
model = "g-one"
effort = "high"
timeout = 600
[slot.depth]
model = "g-one"
effort = "high"
timeout = 600
[slot.bulk-fallback]
model = "g-two"
effort = "medium"
timeout = 600
[slot.signoff-fallback]
model = "g-two"
effort = "high"
timeout = 600
[slot.cross-fill]
model = "w-claude"
effort = "high"
timeout = 600
[slot.plan-primary]
model = "g-one"
effort = "high"
timeout = 900
[slot.plan-fallback]
model = "w-claude"
effort = "high"
timeout = 900
[slot.stamp-check]
model = "g-one"
effort = "high"
timeout = 600
[slot.independent]
model = "g-one"
effort = "high"
timeout = 900
[slot.arch-primary]
model = "g-one"
effort = "high"
timeout = 600
[slot.arch-fallback]
model = "g-two"
effort = "high"
timeout = 900
"""


def _self_test() -> int:
    passed = failed = 0

    def check(name: str, ok: bool, detail: str = "") -> None:
        nonlocal passed, failed
        if ok:
            passed += 1
        else:
            failed += 1
            print(f"FAIL {name} {detail}")

    tmpd = tempfile.mkdtemp(prefix="panel-slots-")

    def write(text: str) -> str:
        path = os.path.join(tmpd, f"t{passed + failed}.toml")
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(text)
        return path

    def refuses(name: str, text: str, needle: str) -> None:
        try:
            load(write(text))
        except PanelSlotsError as exc:
            check(name, needle in str(exc), f"message {exc!s} lacks {needle!r}")
            return
        check(name, False, "loaded without refusal")

    def slot_line(text: str, slot: str, key: str, value: str) -> str:
        head = f"[slot.{slot}]\n"
        start = text.index(head) + len(head)
        end = text.find("[", start)
        block = text[start:end]
        block = re.sub(rf"^{key} = .*$", f"{key} = {value}", block, flags=re.MULTILINE)
        return text[:start] + block + text[end:]

    good = load(write(GOOD))
    check("good table loads", good["writer"] == {"model": "w-claude", "family": "claude"})
    check("slot family derived", good["slots"]["signoff"]["family"] == "codex")
    check("argv codex exec",
          argv_for_slot("bulk", table=good) == ["codex", "exec", "-m", "g-one", "-c",
                                                 'model_reasoning_effort="medium"', "-s",
                                                 "read-only", "-"])
    check("argv claude keeps allowedTools last",
          argv_for_slot("cross-fill", table=good)[-2:] == ["--allowedTools", "Read"])
    check("argv independent takes scope, no stdin dash",
          argv_for_slot("independent", ["--commit", "abc"], table=good)
          == ["codex", "review", "--commit", "abc", "-c", 'model="g-one"', "-c",
              'model_reasoning_effort="high"'])
    try:
        argv_for_slot("nope", table=good)
        check("unknown slot refuses", False)
    except PanelSlotsError as exc:
        check("unknown slot refuses", "unknown" in str(exc))

    refuses("empty file", "", "no [model.*] registry")
    refuses("missing slot", GOOD.replace("[slot.depth]", "[slot.depthx]"), "missing slots: depth")
    refuses("arch fallback leaves family", slot_line(GOOD, "arch-fallback", "model", '"w-claude"'),
            "never reviews its own writer")
    refuses("extra slot", GOOD + '[slot.arch]\nmodel = "g-one"\neffort = "high"\ntimeout = 1\n',
            "ungoverned slots: arch")
    refuses("unregistered model", slot_line(GOOD, "bulk", "model", '"g-nope"'), "is not registered")
    refuses("retired model in slot", slot_line(GOOD, "bulk", "model", '"g-old"'), "retired 2026-09-01")
    refuses("bad effort", slot_line(GOOD, "bulk", "effort", '"low"'), "effort 'low' is outside")
    refuses("bad timeout", slot_line(GOOD, "bulk", "timeout", "0"), "not a positive integer")
    refuses("string timeout", slot_line(GOOD, "bulk", "timeout", '"600"'), "not a positive integer")
    refuses("parity break", slot_line(GOOD, "signoff-fallback", "effort", '"xhigh"'),
            "does not repeat slot 'signoff'")
    refuses("writer family governs", slot_line(GOOD, "signoff", "model", '"w-claude"'),
            "never reviews its own writer")
    refuses("writer family bulk", slot_line(GOOD, "bulk", "model", '"w-claude"'),
            "never reviews its own writer")
    refuses("unregistered writer", GOOD.replace('model = "w-claude"\n[model', 'model = "x"\n[model', 1),
            "writer model 'x' is not registered")
    refuses("live model without probe", GOOD.replace('family = "codex"\nprobed = "2026-09-23"\n[model."g-two"]',
                                                     'family = "codex"\n[model."g-two"]'),
            "carries no probed date")
    refuses("bad family", GOOD.replace('[model."g-two"]\nfamily = "codex"', '[model."g-two"]\nfamily = "grok"'),
            "family 'grok' is outside")
    refuses("bad toml", "[writer\n", "does not parse")
    # Writer flips to codex: every codex governing slot now fails.
    flipped = GOOD.replace('[writer]\nmodel = "w-claude"', '[writer]\nmodel = "g-two"')
    refuses("writer flip fails governing slots", flipped, "never reviews its own writer")

    fam = os.path.join(tmpd, "fam.toml")
    with open(fam, "w", encoding="utf-8") as fh:
        fh.write(GOOD)
    check("family models include retired", family_models("codex", fam) == ("g-old", "g-one", "g-two"))
    check("family models live only", family_models("codex", fam, include_retired=False) == ("g-one", "g-two"))

    # exec: timeout path returns 124 and kills the child.
    slow = dict(good)
    slow_slots = {k: dict(v) for k, v in good["slots"].items()}
    slow_slots["bulk"]["timeout"] = 1
    slow["slots"] = slow_slots
    real_argv = argv_for_slot
    try:
        globals()["argv_for_slot"] = lambda slot, extra=None, table=None: [
            sys.executable, "-c", "import time; time.sleep(30)"]
        rc = exec_slot("bulk", [], subprocess.DEVNULL, subprocess.DEVNULL, subprocess.DEVNULL, slow)
        check("exec timeout exits 124", rc == TIMEOUT_EXIT, f"rc={rc}")
        globals()["argv_for_slot"] = lambda slot, extra=None, table=None: [
            sys.executable, "-c", "import sys; sys.stdout.write(sys.stdin.read().upper())"]
        with tempfile.TemporaryFile() as fin, tempfile.TemporaryFile() as fout:
            fin.write(b"echo")
            fin.seek(0)
            rc = exec_slot("bulk", [], fin, fout, subprocess.DEVNULL, good)
            fout.seek(0)
            check("exec pipes stdin to stdout", rc == 0 and fout.read() == b"ECHO")
    finally:
        globals()["argv_for_slot"] = real_argv

    # The checked-in table validates.
    try:
        live = load()
        check("checked-in table validates", live["writer"]["family"] == "claude")
    except PanelSlotsError as exc:
        check("checked-in table validates", False, str(exc))

    print(f"panel_slots self-test: {passed + failed} cases, {failed} failed")
    return 1 if failed else 0


def main(argv: list[str]) -> int:
    if argv == ["--self-test"]:
        return _self_test()
    if not argv:
        print(__doc__.split("\n\n")[-3], file=sys.stderr)
        return 2
    cmd, rest = argv[0], argv[1:]
    try:
        if cmd == "validate" and not rest:
            table = load()
            print(f"panel slots ok: writer {table['writer']['model']} ({table['writer']['family']}), "
                  f"{len(table['slots'])} slots, {len(table['models'])} registered models")
            return 0
        if cmd == "show" and not rest:
            table = load()
            print(f"writer  {table['writer']['model']} ({table['writer']['family']})")
            for name, entry in table["slots"].items():
                print(f"{name:<17} {entry['model']:<17} {entry['family']:<7} "
                      f"{entry['effort']:<7} {entry['timeout']}s")
            return 0
        if cmd == "argv" and rest:
            print(" ".join(argv_for_slot(rest[0], rest[1:])))
            return 0
        if cmd == "get" and len(rest) == 2:
            slots = load_slots()
            if rest[0] not in slots:
                raise PanelSlotsError(f"panel slot {rest[0]!r} is unknown")
            if rest[1] not in ("model", "effort", "timeout", "family"):
                raise PanelSlotsError(f"field {rest[1]!r} is not model, effort, timeout, or family")
            print(slots[rest[0]][rest[1]])
            return 0
        if cmd == "writer" and len(rest) <= 1:
            writer = load()["writer"]
            print(writer[rest[0]] if rest else f"{writer['model']} {writer['family']}")
            return 0
        if cmd == "family" and len(rest) == 1:
            models = load()["models"]
            if rest[0] not in models:
                raise PanelSlotsError(f"model {rest[0]!r} is not registered")
            print(models[rest[0]]["family"])
            return 0
        if cmd == "models" and rest and rest[0] in PANEL_FAMILIES and rest[1:] in ([], ["--all"]):
            print("\n".join(family_models(rest[0], include_retired=bool(rest[1:]))))
            return 0
        if cmd == "exec" and rest:
            return exec_slot(rest[0], rest[1:], sys.stdin.buffer, sys.stdout.buffer, sys.stderr.buffer)
    except PanelSlotsError as exc:
        print(f"panel_slots: {exc}", file=sys.stderr)
        return 2
    print(f"panel_slots: unknown command {' '.join(argv)!r}; see the module docstring", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
