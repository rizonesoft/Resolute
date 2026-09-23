"""Slot resolution for the review panel (D00 T04 §27, §29).

`.conclave/panel.toml` binds every review role to a (model, effort,
timeout) slot, names the writer, and registers the models. Skills run a
role as `python scripts/panel_slots.py exec <slot>` and never name a
model; `todo-runs.py` reads family-to-model sets from here. Ported from
ScratchPad's D00 T04 §15 and §23, with the model set moved out of this
module and into the table's registry so a re-pin is one file.

A registry entry may carry `newest = "<regex>"` instead of naming one
model (D00 T04 §29): at run time the family's CLI lists its models and
the highest version matching the regex runs, so a new release (Grok 4.8
after 4.7) is picked up with no edit. The regex's capture groups are the
version parts, compared as integers; a listing with no match refuses.
An optional `served = "<regex>"` names what the provider reports having
run (Grok answers a `grok-4.7` request as `grok-4.7-build` in its
usage block): records and attestations carry that name, so the family
accepts it, while `newest` alone decides what runs.

Governance, not convenience:
- PANEL_SLOTS is exact. A slot is regime (the outage matrix in the
  review skill names it), so an extra slot without matrix prose is
  ungoverned and fails, and a missing one fails.
- PANEL_EFFORTS is closed. A new level arrives with probes plus review.
- A slot names a registered model that is not retired.
- A fallback repeats its primary's effort (EFFORT_PARITY).
- No slot runs the writer's family: the writer never reviews its own
  work, fallbacks included (D00 T04 §29 removed the writer-family
  cross-fill).

    python scripts/panel_slots.py validate
    python scripts/panel_slots.py show
    python scripts/panel_slots.py argv <slot> [extra...]
    python scripts/panel_slots.py get <slot> model|effort|timeout|family
    python scripts/panel_slots.py resolve <slot>
    python scripts/panel_slots.py writer [model|family]
    python scripts/panel_slots.py family <model>
    python scripts/panel_slots.py models <codex|claude|grok> [--all]
    python scripts/panel_slots.py exec <slot> [extra...] < prompt > out 2> err
    python scripts/panel_slots.py --self-test

`exec` runs the slot's producer with the prompt on stdin, enforces the
slot timeout, and exits 124 on expiry (the `timeout` convention the
outage matrix keys on). Its first stderr line names the slot and the
model that actually ran. The `independent` slot runs `codex review`,
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

PANEL_FAMILIES = ("codex", "claude", "grok")
PANEL_EFFORTS = ("medium", "high", "xhigh")
PANEL_SLOTS = (
    "bulk",
    "signoff",
    "depth",
    "bulk-fallback",
    "signoff-fallback",
    "plan-primary",
    "plan-fallback",
    "stamp-check",
    "independent",
    "arch-primary",
    "arch-fallback",
)
# (fallback, primary): a failover repeats its primary's effort.
EFFORT_PARITY = (("bulk-fallback", "bulk"), ("signoff-fallback", "signoff"),
                 ("plan-fallback", "plan-primary"), ("arch-fallback", "arch-primary"))
TIMEOUT_EXIT = 124
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
# Grok headless runs with read-only built-in tools: its OS sandbox
# profiles (Landlock, Seatbelt) do not apply on Windows, so the
# allowlist is the read-only guarantee. Subagents and the web go too.
GROK_TOOLS = "read_file,grep,list_dir"
GROK_DENIED = "Agent,web_search,web_fetch,run_terminal_cmd,search_replace"


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
        newest = entry.get("newest")
        if newest is not None:
            try:
                pattern = re.compile(newest)
            except (re.error, TypeError) as exc:
                raise PanelSlotsError(f"model {name!r} newest {newest!r} is not a regex: {exc}")
            if pattern.groups < 1:
                raise PanelSlotsError(f"model {name!r} newest {newest!r} captures no version parts")
            newest = pattern
        served = entry.get("served")
        if served is not None:
            try:
                served = re.compile(served)
            except (re.error, TypeError) as exc:
                raise PanelSlotsError(f"model {name!r} served {served!r} is not a regex: {exc}")
        out[name] = {"family": family, "retired": retired, "probed": probed, "newest": newest,
                     "served": served}
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
        if family == wfamily:
            raise PanelSlotsError(
                f"panel slot {name!r} runs the writer's family {family!r}: "
                f"no slot reviews its own writer")
        slots[name] = {"model": model, "effort": effort, "timeout": timeout, "family": family}
    if slots["independent"]["family"] != "codex" or models[slots["independent"]["model"]]["newest"]:
        raise PanelSlotsError("panel slot 'independent' runs `codex review` and needs a fixed codex model")
    for follower, leader in EFFORT_PARITY:
        if slots[follower]["effort"] != slots[leader]["effort"]:
            raise PanelSlotsError(
                f"panel slot {follower!r} effort {slots[follower]['effort']!r} does not repeat "
                f"slot {leader!r} effort {slots[leader]['effort']!r}")
    return {"writer": {"model": wmodel, "family": wfamily}, "models": models, "slots": slots}


def load_slots(path: str | None = None) -> dict[str, dict]:
    return load(path)["slots"]


def family_models(family: str, path: str | None = None, include_retired: bool = True) -> tuple[str, ...]:
    """Every registered model name of a family, retired ones included by
    default: historical records name retired pins and must keep parsing.
    A `newest` entry contributes its registry name; `family_accepts`
    matches the concrete models it resolves to."""
    models = load(path)["models"]
    return tuple(sorted(name for name, entry in models.items()
                        if entry["family"] == family and (include_retired or not entry["retired"])))


def family_accepts(family: str, model: str, table: dict | None = None) -> bool:
    """True when `model` is a registered model of `family`, or a concrete
    model a `newest` entry of that family resolves to (a record names
    what ran, `grok-4.7`, never the registry alias)."""
    models = (table or load())["models"]
    for name, entry in models.items():
        if entry["family"] != family:
            continue
        if name == model and entry["newest"] is None:
            return True
        if entry["newest"] is not None and entry["newest"].fullmatch(model):
            return True
        if entry["served"] is not None and entry["served"].fullmatch(model):
            return True
    return False


def _exe(name: str) -> str:
    # npm installs `codex` as a .cmd shim on Windows, and the Grok
    # installer puts `grok` under ~/.grok/bin, off PATH: resolve both so
    # subprocess finds them without a shell.
    found = shutil.which(name)
    if found:
        return found
    for candidate in (os.path.join(os.path.expanduser("~"), f".{name}", "bin", f"{name}.exe"),
                      os.path.join(os.path.expanduser("~"), f".{name}", "bin", name)):
        if os.path.isfile(candidate):
            return candidate
    return name


def list_family_models(family: str) -> str:
    """The family CLI's model listing, as text. Only Grok resolves
    `newest` today; a family without a listing command refuses."""
    if family != "grok":
        raise PanelSlotsError(f"family {family!r} has no model listing to resolve `newest` against")
    try:
        done = subprocess.run([_exe("grok"), "models"], capture_output=True, text=True,
                              encoding="utf-8", errors="replace", timeout=60)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise PanelSlotsError(f"grok models failed: {exc}")
    if done.returncode != 0:
        raise PanelSlotsError(f"grok models exited {done.returncode}: {done.stderr.strip()[:200]}")
    return done.stdout


def resolve_model(model: str, table: dict, lister=list_family_models) -> str:
    """The concrete model a registry name runs as: itself, or for a
    `newest` entry the highest listed version its regex matches."""
    entry = table["models"][model]
    pattern = entry["newest"]
    if pattern is None:
        return model
    listing = lister(entry["family"])
    best: tuple[tuple[int, ...], str] | None = None
    # Only list items (`* name` or `- name` lines) are listed models:
    # a name mentioned in descriptive text never runs.
    for token in re.findall(r"(?m)^\s*[*-]\s+([A-Za-z0-9][A-Za-z0-9._-]*)", listing):
        m = pattern.fullmatch(token)
        if not m:
            continue
        try:
            version = tuple(int(g) for g in m.groups())
        except (TypeError, ValueError):
            continue
        if best is None or version > best[0]:
            best = (version, token)
    if best is None:
        raise PanelSlotsError(
            f"model {model!r} resolves to nothing: no listed {entry['family']} model matches "
            f"{pattern.pattern!r}")
    return best[1]


def argv_for_slot(slot: str, extra: list[str] | None = None, table: dict | None = None,
                  model: str | None = None, prompt_file: str | None = None) -> list[str]:
    """Producer argv for a slot. `model` is the resolved concrete model
    (defaults to the registry name); `prompt_file` carries the prompt for
    producers that read no stdin. Raises PanelSlotsError naming why not."""
    slots = (table or load())["slots"]
    if slot not in slots:
        raise PanelSlotsError(f"panel slot {slot!r} is unknown (known: {', '.join(PANEL_SLOTS)})")
    entry = slots[slot]
    effort, extra = entry["effort"], list(extra or [])
    model = model or entry["model"]
    if slot == "independent":
        # `codex review` refuses a prompt beside a scope flag, so the
        # extra args carry the scope and nothing rides stdin.
        return ["codex", "review", *extra, "-c", f'model="{model}"',
                "-c", f'model_reasoning_effort="{effort}"']
    if entry["family"] == "codex":
        return ["codex", "exec", "-m", model, "-c", f'model_reasoning_effort="{effort}"',
                "-s", "read-only", *extra, "-"]
    if entry["family"] == "grok":
        return ["grok", "--prompt-file", prompt_file or "<prompt-file>", "-m", model,
                "--effort", effort, "--output-format", "json", "--tools", GROK_TOOLS,
                "--disallowed-tools", GROK_DENIED, "--no-auto-update", *extra]
    # --allowedTools stays last: the flag is variadic.
    return ["claude", "-p", "--model", model, "--effort", effort,
            "--output-format", "json", *extra, "--allowedTools", "Read"]


def _kill_tree(proc: subprocess.Popen) -> None:
    if os.name == "nt":
        subprocess.run(["taskkill", "/T", "/F", "/PID", str(proc.pid)],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        proc.kill()


def exec_slot(slot: str, extra: list[str], stdin, stdout, stderr, table: dict | None = None,
              lister=list_family_models) -> int:
    """Run the slot's producer; return its exit code, or 124 on timeout.
    A `newest` model that resolves to nothing exits 2 before any round
    runs, which the outage matrix reads as a failed rung."""
    table = table or load()
    if slot not in table["slots"]:
        raise PanelSlotsError(f"panel slot {slot!r} is unknown (known: {', '.join(PANEL_SLOTS)})")
    entry = table["slots"][slot]
    model = resolve_model(entry["model"], table, lister)
    timeout = entry["timeout"]
    named = model if model == entry["model"] else f"{model} (resolved from {entry['model']})"
    print(f"panel_slots: slot {slot} model {named} effort {entry['effort']} "
          f"timeout {timeout}s", file=sys.stderr, flush=True)
    if entry["family"] == "grok" and extra:
        raise PanelSlotsError(
            f"panel slot {slot!r} runs grok and takes no extra arguments ({' '.join(extra)}): "
            f"nothing may follow its read-only tool restrictions")
    prompt_file = None
    feed = stdin
    if entry["family"] == "grok":
        # Grok headless takes its prompt from a file, not stdin.
        fd, prompt_file = tempfile.mkstemp(prefix="panel-prompt-", suffix=".md")
        with os.fdopen(fd, "wb") as fh:
            data = stdin.read() if hasattr(stdin, "read") else b""
            fh.write(data if isinstance(data, bytes) else data.encode("utf-8"))
        feed = None
    if slot == "independent":
        feed = None
    argv = argv_for_slot(slot, extra, table, model=model, prompt_file=prompt_file)
    argv[0] = _exe(argv[0])
    try:
        proc = subprocess.Popen(argv, stdin=feed if feed is not None else subprocess.DEVNULL,
                                stdout=stdout, stderr=stderr)
        try:
            return proc.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            _kill_tree(proc)
            proc.wait()
            print(f"panel_slots: slot {slot} timed out after {timeout}s", file=sys.stderr, flush=True)
            return TIMEOUT_EXIT
    finally:
        if prompt_file is not None:
            try:
                os.unlink(prompt_file)
            except OSError:
                pass


# --- self-test ---------------------------------------------------------------

GOOD = r"""
[writer]
model = "w-claude"
[model."w-claude"]
family = "claude"
probed = "2026-09-23"
[model."g-one"]
family = "codex"
probed = "2026-09-23"
[model."g-old"]
family = "codex"
retired = "2026-09-01"
[model."k-newest"]
family = "grok"
probed = "2026-09-23"
newest = 'k-(\d+)\.(\d+)'
served = 'k-(\d+)\.(\d+)-build'
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
model = "k-newest"
effort = "medium"
timeout = 600
[slot.signoff-fallback]
model = "k-newest"
effort = "high"
timeout = 600
[slot.plan-primary]
model = "g-one"
effort = "high"
timeout = 900
[slot.plan-fallback]
model = "k-newest"
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
model = "k-newest"
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

    def listing(text: str):
        return lambda _family: text

    good = load(write(GOOD))
    check("good table loads", good["writer"] == {"model": "w-claude", "family": "claude"})
    check("slot family derived", good["slots"]["signoff-fallback"]["family"] == "grok")
    check("argv codex exec",
          argv_for_slot("bulk", table=good) == ["codex", "exec", "-m", "g-one", "-c",
                                                 'model_reasoning_effort="medium"', "-s",
                                                 "read-only", "-"])
    grok_argv = argv_for_slot("signoff-fallback", table=good, model="k-4.8", prompt_file="p.md")
    check("argv grok reads the prompt file, resolved model, slot effort, read-only tools",
          grok_argv[:8] == ["grok", "--prompt-file", "p.md", "-m", "k-4.8", "--effort", "high",
                            "--output-format"]
          and grok_argv[grok_argv.index("--tools") + 1] == GROK_TOOLS
          and "Agent" in grok_argv[grok_argv.index("--disallowed-tools") + 1], str(grok_argv))
    check("argv independent takes scope, no stdin dash",
          argv_for_slot("independent", ["--commit", "abc"], table=good)
          == ["codex", "review", "--commit", "abc", "-c", 'model="g-one"', "-c",
              'model_reasoning_effort="high"'])
    try:
        argv_for_slot("nope", table=good)
        check("unknown slot refuses", False)
    except PanelSlotsError as exc:
        check("unknown slot refuses", "unknown" in str(exc))

    # newest resolution: highest version wins, suffixed variants never do.
    real_listing = ("Available models:\n  * k-4.7 (default)\n  - k-4.7-build-fast\n"
                    "  - k-4.6\n  - k-4.10\n  - k-4.8-build-fast\n")
    check("newest picks the highest numeric version",
          resolve_model("k-newest", good, listing(real_listing)) == "k-4.10")
    check("newest picks up a new release",
          resolve_model("k-newest", good, listing("  * k-4.7\n  - k-4.8\n")) == "k-4.8")
    try:
        resolve_model("k-newest", good, listing("  - k-4.7-build-fast\n  - other-5.0\n"))
        check("suffix-only listing refuses", False)
    except PanelSlotsError as exc:
        check("suffix-only listing refuses", "resolves to nothing" in str(exc))
    check("fixed model resolves to itself", resolve_model("g-one", good, listing("")) == "g-one")
    check("family accepts a resolved concrete model", family_accepts("grok", "k-4.9", good))
    check("family refuses a suffixed variant", not family_accepts("grok", "k-4.9-build-fast", good))
    check("family accepts the served name", family_accepts("grok", "k-4.7-build", good))
    check("family refuses the newest alias as a recorded model", not family_accepts("grok", "k-newest", good))
    check("prose around the listing never resolves",
          resolve_model("k-newest", good, listing("Default model: k-9.9\n\n  * k-4.7 (default)\n")) == "k-4.7")
    check("served name never decides what runs",
          resolve_model("k-newest", good, listing("  - k-4.7\n  - k-4.9-build\n")) == "k-4.7")
    refuses("served bad regex", GOOD.replace(r"served = 'k-(\d+)\.(\d+)-build'", 'served = "k-("'),
            "is not a regex")
    check("family accepts a registered model", family_accepts("codex", "g-old", good))
    check("family refuses a foreign model", not family_accepts("codex", "k-4.9", good))

    refuses("empty file", "", "no [model.*] registry")
    refuses("missing slot", GOOD.replace("[slot.depth]", "[slot.depthx]"), "missing slots: depth")
    refuses("extra slot", GOOD + '[slot.cross-fill]\nmodel = "g-one"\neffort = "high"\ntimeout = 1\n',
            "ungoverned slots: cross-fill")
    refuses("unregistered model", slot_line(GOOD, "bulk", "model", '"g-nope"'), "is not registered")
    refuses("retired model in slot", slot_line(GOOD, "bulk", "model", '"g-old"'), "retired 2026-09-01")
    refuses("bad effort", slot_line(GOOD, "bulk", "effort", '"low"'), "effort 'low' is outside")
    refuses("bad timeout", slot_line(GOOD, "bulk", "timeout", "0"), "not a positive integer")
    refuses("string timeout", slot_line(GOOD, "bulk", "timeout", '"600"'), "not a positive integer")
    refuses("parity break", slot_line(GOOD, "signoff-fallback", "effort", '"xhigh"'),
            "does not repeat slot 'signoff'")
    refuses("plan parity break", slot_line(GOOD, "plan-fallback", "effort", '"medium"'),
            "does not repeat slot 'plan-primary'")
    refuses("writer family governs", slot_line(GOOD, "signoff", "model", '"w-claude"'),
            "no slot reviews its own writer")
    refuses("writer family fallback", slot_line(GOOD, "plan-fallback", "model", '"w-claude"'),
            "no slot reviews its own writer")
    refuses("newest independent", slot_line(GOOD, "independent", "model", '"k-newest"'),
            "needs a fixed codex model")
    refuses("newest without a capture", GOOD.replace(r"newest = 'k-(\d+)\.(\d+)'", 'newest = "k-4"'),
            "captures no version parts")
    refuses("newest bad regex", GOOD.replace(r"newest = 'k-(\d+)\.(\d+)'", 'newest = "k-("'),
            "is not a regex")
    refuses("unregistered writer", GOOD.replace('model = "w-claude"\n[model', 'model = "x"\n[model', 1),
            "writer model 'x' is not registered")
    refuses("live model without probe",
            GOOD.replace('family = "codex"\nprobed = "2026-09-23"\n[model."g-old"]',
                         'family = "codex"\n[model."g-old"]'),
            "carries no probed date")
    refuses("bad family", GOOD.replace('[model."g-one"]\nfamily = "codex"', '[model."g-one"]\nfamily = "muse"'),
            "family 'muse' is outside")
    refuses("bad toml", "[writer\n", "does not parse")
    # Writer flips to codex: every codex slot now fails.
    flipped = GOOD.replace('[writer]\nmodel = "w-claude"', '[writer]\nmodel = "g-one"')
    refuses("writer flip fails its family's slots", flipped, "no slot reviews its own writer")

    fam = os.path.join(tmpd, "fam.toml")
    with open(fam, "w", encoding="utf-8") as fh:
        fh.write(GOOD)
    check("family models include retired", family_models("codex", fam) == ("g-old", "g-one"))
    check("family models live only", family_models("codex", fam, include_retired=False) == ("g-one",))

    # exec: timeout path returns 124 and kills the child; stdin pipes;
    # a grok slot hands the prompt over as a file; a dead listing fails
    # the round before anything runs.
    slow = dict(good)
    slow_slots = {k: dict(v) for k, v in good["slots"].items()}
    slow_slots["bulk"]["timeout"] = 1
    slow["slots"] = slow_slots
    real_argv = argv_for_slot
    try:
        globals()["argv_for_slot"] = lambda slot, extra=None, table=None, model=None, prompt_file=None: [
            sys.executable, "-c", "import time; time.sleep(30)"]
        rc = exec_slot("bulk", [], subprocess.DEVNULL, subprocess.DEVNULL, subprocess.DEVNULL, slow)
        check("exec timeout exits 124", rc == TIMEOUT_EXIT, f"rc={rc}")
        globals()["argv_for_slot"] = lambda slot, extra=None, table=None, model=None, prompt_file=None: [
            sys.executable, "-c", "import sys; sys.stdout.write(sys.stdin.read().upper())"]
        with tempfile.TemporaryFile() as fin, tempfile.TemporaryFile() as fout:
            fin.write(b"echo")
            fin.seek(0)
            rc = exec_slot("bulk", [], fin, fout, subprocess.DEVNULL, good)
            fout.seek(0)
            check("exec pipes stdin to stdout", rc == 0 and fout.read() == b"ECHO")
        seen: dict = {}

        def _fake_grok(slot, extra=None, table=None, model=None, prompt_file=None):
            seen["model"], seen["file"] = model, prompt_file
            return [sys.executable, "-c",
                    "import sys; sys.stdout.write(open(sys.argv[1], encoding='utf-8').read()[::-1])",
                    prompt_file]
        globals()["argv_for_slot"] = _fake_grok
        with tempfile.TemporaryFile() as fin, tempfile.TemporaryFile() as fout, \
                tempfile.TemporaryFile() as ferr:
            fin.write(b"abc")
            fin.seek(0)
            rc = exec_slot("signoff-fallback", [], fin, fout, ferr, good,
                           lister=listing("  * k-4.7\n  - k-4.8\n"))
            fout.seek(0)
            ferr.seek(0)
            check("exec grok reads the prompt from a file and runs the newest model",
                  rc == 0 and fout.read() == b"cba" and seen["model"] == "k-4.8"
                  and not os.path.exists(seen["file"]), f"rc={rc} {seen}")
        try:
            exec_slot("signoff-fallback", ["--tools", "edit_file"], subprocess.DEVNULL,
                      subprocess.DEVNULL, subprocess.DEVNULL, good, lister=listing("  * k-4.7\n"))
            check("exec refuses extra arguments on a grok slot", False)
        except PanelSlotsError as exc:
            check("exec refuses extra arguments on a grok slot", "takes no extra arguments" in str(exc))
        before = set(os.listdir(tempfile.gettempdir()))
        try:
            exec_slot("signoff-fallback", ["--x"], subprocess.DEVNULL, subprocess.DEVNULL,
                      subprocess.DEVNULL, good, lister=listing("  * k-4.7\n"))
        except PanelSlotsError:
            pass
        leaked = [n for n in set(os.listdir(tempfile.gettempdir())) - before if n.startswith("panel-prompt-")]
        check("a refused grok call leaves no prompt file behind", leaked == [], str(leaked))
        try:
            exec_slot("signoff-fallback", [], subprocess.DEVNULL, subprocess.DEVNULL,
                      subprocess.DEVNULL, good, lister=listing("nothing here"))
            check("exec with a dead listing refuses before running", False)
        except PanelSlotsError as exc:
            check("exec with a dead listing refuses before running", "resolves to nothing" in str(exc))
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
        print("usage: panel_slots.py validate | show | argv <slot> | get <slot> <field> | resolve <slot> | "
              "writer | family <model> | models <family> [--all] | exec <slot> [extra...] | --self-test",
              file=sys.stderr)
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
                shown = entry["model"]
                if table["models"][shown]["newest"] is not None:
                    try:
                        shown = f"{resolve_model(shown, table)} (newest of {shown})"
                    except PanelSlotsError as exc:
                        shown = f"{shown} (unresolved: {exc})"
                print(f"{name:<17} {shown:<28} {entry['family']:<7} "
                      f"{entry['effort']:<7} {entry['timeout']}s")
            return 0
        if cmd == "argv" and rest:
            table = load()
            if rest[0] not in table["slots"]:
                raise PanelSlotsError(f"panel slot {rest[0]!r} is unknown")
            model = resolve_model(table["slots"][rest[0]]["model"], table)
            print(" ".join(argv_for_slot(rest[0], rest[1:], table, model=model)))
            return 0
        if cmd == "resolve" and len(rest) == 1:
            table = load()
            if rest[0] not in table["slots"]:
                raise PanelSlotsError(f"panel slot {rest[0]!r} is unknown")
            print(resolve_model(table["slots"][rest[0]]["model"], table))
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
