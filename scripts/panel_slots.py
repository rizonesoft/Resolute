"""Slot resolution for the review panel (D00 T04 §27, §29).

`.conclave/panel.toml` binds every review role to a (model, effort,
timeout) slot, names the writer, and registers the models. Skills run a
role as `python scripts/panel_slots.py exec <slot>` and never name a
model; `todo-runs.py` reads family-to-model sets from here. Ported from
ScratchPad's D00 T04 §15 and §23, with the model set moved out of this
module and into the table's registry so a re-pin is one file.

A registry entry may carry `newest = "<regex>"` instead of naming one
model (D00 T04 §29 added it for the Grok fallbacks, which ran the
highest listed Grok version). The operator removed Grok from the panel
on 2026-09-25, so no slot may name a `newest` entry; the retired Grok
entry keeps it so records naming the concrete model that ran
(`grok-4.7`) still parse. An optional `served = "<regex>"` names what
the provider reported having run (`grok-4.7-build`), for records only.

Governance, not convenience:
- PANEL_SLOTS is exact. A slot is regime (the outage matrix in the
  review skill names it), so an extra slot without matrix prose is
  ungoverned and fails, and a missing one fails.
- PANEL_EFFORTS is closed. A new level arrives with probes plus review.
- A slot names a registered model that is not retired.
- A slot pins a fixed model of a family with a runner (PANEL_RUNNERS):
  the grok family survives only in retired entries.
- No slot runs the writer's family: the writer never reviews its own
  work. There are no fallback slots (operator decision 2026-09-25): a
  failed round waits for the operator.

    python scripts/panel_slots.py validate
    python scripts/panel_slots.py show
    python scripts/panel_slots.py argv <slot> [extra...]
    python scripts/panel_slots.py get <slot> model|effort|timeout|family
    python scripts/panel_slots.py writer [model|family]
    python scripts/panel_slots.py family <model>
    python scripts/panel_slots.py models <codex|claude|grok> [--all]
    python scripts/panel_slots.py exec <slot> [extra...] < prompt > out 2> err
    python scripts/panel_slots.py delegate-probe
    python scripts/panel_slots.py hook pre-agent|subagent-stop|pre-tool < payload.json
    python scripts/panel_slots.py ledger [N]
    python scripts/panel_slots.py --self-test

The delegate pin (operator decision 2026-10-01, D00 T04 §43): `[delegate]`
names the alias, the model it resolved to at the probe, and the effort
that Claude Code subagents in `.claude/agents/delegate-*.md` run on. The
table requires it, the model must be registered, live, and the writer's
family (delegates are subagents of the writer harness, never a review
slot), and `validate` refuses any agent definition whose `model` or
`effort` frontmatter differs. `delegate-probe` refuses when the alias
resolves to another model, so a newer Sonnet is a re-pin, never a drift.
The `hook` events fail open (a bad payload prints one stderr line and
allows): `pre-agent` denies an `Agent` call that would run unpinned, and
`subagent-stop` appends what each finished subagent ran on to
`build/agent-delegations.jsonl`, which `ledger` prints. `pre-agent` allows
a per-call `model` only as `opus`, `fable`, or the writer's own model id, so
an older id such as `claude-opus-3` is denied. Both agent-name hooks read
`roster_names()`, the `delegate-*.md` stems under `.claude/agents/`, so one
malformed agent file never turns the guard off (validity is `validate`'s
job). `subagent-stop` records nothing for an empty `agent_type` (a
harness-internal side agent, not a delegation). It never prints to stdout,
because a `SubagentStop` output may resume the finished subagent rather than
reach the lead; when the pin is `mismatch` or `unread` it writes one stderr
warning line, and the lead reads the ledger (`ledger`), which every
`Delegated:` commit line cites.

`pre-tool` (PreToolUse on Bash, Edit, Write, NotebookEdit) constrains only
an `agent_type` starting with `delegate-`; the lead and other agents never
are. `delegate-research` and `delegate-check` are read-only. Every delegate
is denied mutating git (`add`, `commit`, `push`, `reset`, `stash`,
`checkout`, and the rest of `GIT_DENIED`), `panel_slots.py exec`,
`panel_slots.py delegate-probe`, `codex`, and any write under `.git`,
`.claude`, `.conclave`, `todo`, or `resolute_au3`, including a shell mutator
(`rm`, `mv`, `cp`, `tee`, `sed -i`, `Remove-Item`, and the like) or a `>`
redirection aimed there. The read-only delegates may run no shell mutator and
no redirection except to `/dev/null`, `nul`, `$null`, or a descriptor
(`2>&1`). Read-only git passes. It is a guard against accidents, not a
sandbox.

`exec` runs the slot's producer with the prompt on stdin, enforces the
slot timeout, and exits 124 on expiry (the `timeout` convention the
outage matrix keys on). Its first stderr line names the slot and the
model that ran. The `independent` slot runs `codex review`,
which takes its scope from the extra arguments (`--commit <sha>`) and
reads no prompt.
"""

from __future__ import annotations

import datetime
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import tomllib

PANEL_FAMILIES = ("codex", "claude", "grok")
# Families a slot may run. `grok` stays a registry family so historical
# records parse, but it has no runner (operator decision 2026-09-25).
PANEL_RUNNERS = ("codex", "claude")
PANEL_EFFORTS = ("medium", "high", "xhigh")
PANEL_SLOTS = (
    "bulk",
    "signoff",
    "depth",
    "plan-primary",
    "stamp-check",
    "independent",
    "arch-primary",
)
# The aliases Claude Code documents for `--model`; the delegate names one.
DELEGATE_ALIASES = ("sonnet", "opus", "haiku", "fable")
DELEGATE_EFFORTS = ("high", "xhigh")
DELEGATE_PREFIX = "delegate-"
PROBE_PROMPT = "Reply with exactly: PROBE-OK"
PROBE_TIMEOUT = 180
TIMEOUT_EXIT = 124
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


class PanelSlotsError(ValueError):
    """A naming diagnostic for panel-slot resolution failures."""


def toml_path() -> str:
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.normpath(os.path.join(here, "..", ".conclave", "panel.toml"))


def agents_dir() -> str:
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.normpath(os.path.join(here, "..", ".claude", "agents"))


def ledger_path() -> str:
    override = os.environ.get("PANEL_DELEGATION_LEDGER")
    if override:
        return override
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.normpath(os.path.join(here, "..", "build", "agent-delegations.jsonl"))


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
        if family not in PANEL_RUNNERS:
            raise PanelSlotsError(
                f"panel slot {name!r} model {model!r} runs family {family!r}, which has no runner "
                f"(runners: {', '.join(PANEL_RUNNERS)})")
        if models[model]["newest"] is not None:
            raise PanelSlotsError(
                f"panel slot {name!r} model {model!r} is a `newest` entry: a slot pins a fixed model")
        if family == wfamily:
            raise PanelSlotsError(
                f"panel slot {name!r} runs the writer's family {family!r}: "
                f"no slot reviews its own writer")
        slots[name] = {"model": model, "effort": effort, "timeout": timeout, "family": family}
    if slots["independent"]["family"] != "codex":
        raise PanelSlotsError("panel slot 'independent' runs `codex review` and needs a codex model")
    delegate = _delegate(doc, models, wfamily)
    return {"writer": {"model": wmodel, "family": wfamily}, "models": models, "slots": slots,
            "delegate": delegate}


def _delegate(doc: dict, models: dict[str, dict], wfamily: str) -> dict:
    entry = doc.get("delegate")
    if not isinstance(entry, dict):
        raise PanelSlotsError("panel slots file carries no [delegate] table")
    for key in ("alias", "model", "effort"):
        if not isinstance(entry.get(key), str):
            raise PanelSlotsError(f"delegate {key} {entry.get(key)!r} is not a string")
    alias = entry.get("alias")
    if alias not in DELEGATE_ALIASES:
        raise PanelSlotsError(
            f"delegate alias {alias!r} is outside {', '.join(DELEGATE_ALIASES)}")
    model = entry.get("model")
    if model not in models:
        raise PanelSlotsError(f"delegate model {model!r} is not registered")
    if models[model]["retired"]:
        raise PanelSlotsError(f"delegate model {model!r} retired {models[model]['retired']}")
    family = models[model]["family"]
    if family != wfamily:
        raise PanelSlotsError(
            f"delegate model {model!r} runs family {family!r}, not the writer's {wfamily!r}: "
            f"delegates are subagents of the writer harness")
    effort = entry.get("effort")
    if effort not in DELEGATE_EFFORTS:
        raise PanelSlotsError(
            f"delegate effort {effort!r} is outside {', '.join(DELEGATE_EFFORTS)}")
    return {"alias": alias, "model": model, "effort": effort, "family": family}


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
    model a `newest` entry of that family matches (a record names what
    ran, `grok-4.7`, never the registry alias)."""
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
    # npm installs `codex` as a .cmd shim on Windows: resolve it so
    # subprocess finds it without a shell.
    return shutil.which(name) or name


def argv_for_slot(slot: str, extra: list[str] | None = None, table: dict | None = None) -> list[str]:
    """Producer argv for a slot. Raises PanelSlotsError naming why not."""
    slots = (table or load())["slots"]
    if slot not in slots:
        raise PanelSlotsError(f"panel slot {slot!r} is unknown (known: {', '.join(PANEL_SLOTS)})")
    entry = slots[slot]
    effort, extra, model = entry["effort"], list(extra or []), entry["model"]
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
    if slot not in table["slots"]:
        raise PanelSlotsError(f"panel slot {slot!r} is unknown (known: {', '.join(PANEL_SLOTS)})")
    entry = table["slots"][slot]
    timeout = entry["timeout"]
    print(f"panel_slots: slot {slot} model {entry['model']} effort {entry['effort']} "
          f"timeout {timeout}s", file=sys.stderr, flush=True)
    # `codex review` takes its scope from the extra args and reads no prompt.
    feed = subprocess.DEVNULL if slot == "independent" else stdin
    argv = argv_for_slot(slot, extra, table)
    argv[0] = _exe(argv[0])
    proc = subprocess.Popen(argv, stdin=feed, stdout=stdout, stderr=stderr)
    try:
        return proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        _kill_tree(proc)
        proc.wait()
        print(f"panel_slots: slot {slot} timed out after {timeout}s", file=sys.stderr, flush=True)
        return TIMEOUT_EXIT


# --- delegates ---------------------------------------------------------------


def agent_frontmatter(path: str) -> dict[str, str]:
    """Scalar `key: value` frontmatter of an agent definition. Raises
    PanelSlotsError naming the file when it has none, never closes, or
    carries a line that is not a scalar."""
    try:
        with open(path, encoding="utf-8-sig") as fh:
            lines = fh.read().splitlines()
    except OSError as exc:
        raise PanelSlotsError(f"agent file {path} is unreadable: {exc}")
    if not lines or lines[0].strip() != "---":
        raise PanelSlotsError(f"agent file {path} has no frontmatter (it must open with ---)")
    fields: dict[str, str] = {}
    for number, line in enumerate(lines[1:], start=2):
        if line.strip() == "---":
            return fields
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        key, sep, value = line.partition(":")
        if not sep or not key.strip() or key != key.strip():
            raise PanelSlotsError(f"agent file {path} line {number} is not a `key: value` scalar")
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        fields[key.strip()] = value
    raise PanelSlotsError(f"agent file {path} frontmatter has no closing ---")


def check_agents(table: dict, directory: str | None = None) -> list[str]:
    """Refuse an empty roster or any agent definition that contradicts the
    delegate pin; return the agent names, sorted."""
    directory = directory or agents_dir()
    delegate = table["delegate"]
    try:
        files = sorted(name for name in os.listdir(directory) if name.endswith(".md"))
    except OSError:
        raise PanelSlotsError(f"agent roster directory {directory} does not exist")
    if not files:
        raise PanelSlotsError(f"agent roster directory {directory} holds no *.md agent files")
    names: list[str] = []
    for filename in files:
        path = os.path.join(directory, filename)
        fields = agent_frontmatter(path)
        stem = filename[:-len(".md")]
        name = fields.get("name")
        if name != stem:
            raise PanelSlotsError(f"agent file {path} field name {name!r} is not the file stem {stem!r}")
        if not name.startswith(DELEGATE_PREFIX):
            raise PanelSlotsError(
                f"agent file {path} field name {name!r} lacks the {DELEGATE_PREFIX!r} prefix")
        for key, want in (("model", delegate["alias"]), ("effort", delegate["effort"])):
            got = fields.get(key)
            if got is None:
                raise PanelSlotsError(f"agent file {path} omits field {key} (the pin is {want!r})")
            if got != want:
                raise PanelSlotsError(f"agent file {path} field {key} {got!r} is not the pin {want!r}")
        names.append(name)
    return names


def roster_names(directory: str | None = None) -> list[str]:
    """Sorted stems of the `delegate-*.md` files in the roster directory, []
    when it is absent. It reads names only, so one malformed agent file never
    turns a hook off; whether the files are valid is `check_agents`'s job."""
    directory = directory or agents_dir()
    try:
        files = os.listdir(directory)
    except OSError:
        return []
    return sorted(name[:-len(".md")] for name in files
                  if name.endswith(".md") and name.startswith(DELEGATE_PREFIX))


def probe_verdict(json_text: str, table: dict) -> str:
    """The model a `delegate-probe` run resolved to, when it is the pin.
    Raises PanelSlotsError naming why the run does not prove the pin."""
    delegate = table["delegate"]
    try:
        obj = json.loads(json_text)
    except (ValueError, TypeError):
        raise PanelSlotsError("delegate-probe output is not JSON")
    if not isinstance(obj, dict):
        raise PanelSlotsError("delegate-probe output is not a JSON object")
    if obj.get("is_error"):
        raise PanelSlotsError("delegate-probe run reported is_error")
    result = obj.get("result")
    if not isinstance(result, str) or "PROBE-OK" not in result:
        raise PanelSlotsError("delegate-probe reply lacks PROBE-OK")
    usage = obj.get("modelUsage")
    if not isinstance(usage, dict) or not usage:
        raise PanelSlotsError("delegate-probe output carries no modelUsage")
    if set(usage) != {delegate["model"]}:
        raise PanelSlotsError(
            f"alias {delegate['alias']!r} resolved to {', '.join(sorted(map(str, usage)))}, but the "
            f"pin is {delegate['model']}: the alias has moved; re-pin [delegate] model in "
            f".conclave/panel.toml after review, with a fresh probe date")
    return delegate["model"]


def delegate_probe(table: dict, stdout, stderr) -> int:
    """Run the live probe; 0 when the alias resolves to the pin, 1 on any
    refusal, 124 on timeout."""
    delegate = table["delegate"]
    argv = [_exe("claude"), "-p", "--model", delegate["alias"], "--effort", delegate["effort"],
            "--output-format", "json", PROBE_PROMPT]
    proc = subprocess.Popen(argv, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    try:
        out, err = proc.communicate(timeout=PROBE_TIMEOUT)
    except subprocess.TimeoutExpired:
        _kill_tree(proc)
        proc.communicate()
        print(f"delegate-probe: timed out after {PROBE_TIMEOUT}s", file=stderr, flush=True)
        return TIMEOUT_EXIT
    try:
        model = probe_verdict(out.decode("utf-8", errors="replace"), table)
    except PanelSlotsError as exc:
        note = f" (claude exited {proc.returncode})" if proc.returncode else ""
        print(f"delegate-probe: {exc}{note}", file=stderr, flush=True)
        return 1
    print(f"delegate-probe: alias {delegate['alias']} effort {delegate['effort']} resolved "
          f"{model} (pinned {delegate['model']}): ok", file=stdout, flush=True)
    return 0


def _stronger_than_delegate(model: str, table: dict) -> bool:
    """Only the aliases Claude Code resolves to the newest `opus` or `fable`,
    or the writer's own model id, are stronger than the delegate. A dated or
    older id (`claude-opus-3`) is not, so it is never waved through."""
    return str(model).lower() in ("opus", "fable") or str(model) == table["writer"]["model"]


def pre_agent_decision(tool_input: dict, table: dict, agent_names) -> str | None:
    """A deny reason for an `Agent` call that would run unpinned, or None."""
    delegate = table["delegate"]
    kind = tool_input.get("subagent_type") or ""
    model = tool_input.get("model") or ""
    roster = ", ".join(sorted(agent_names))
    pin = f"{delegate['alias']} at effort {delegate['effort']}"
    tail = (f"Use a delegate agent ({roster}); consequential work stays with the lead or the "
            f"GPT panel.")
    if kind == "fork":
        return None
    if kind in agent_names:
        if model:
            return (f"{kind} runs the pin in its definition ({pin}); omit `model` "
                    f"(got {model!r}).")
        return None
    if model and _stronger_than_delegate(model, table):
        return None
    if not model:
        return (f"This call (subagent_type {kind or 'unset'!r}) would run on an inherited or "
                f"built-in model at an unpinned effort. {tail}")
    return (f"A per-call model {model!r} runs at that model's default effort, not the pinned "
            f"{delegate['effort']}. {tail}")


def ledger_entry(payload: dict, table: dict, agent_names, transcript_lines, now_iso: str) -> dict:
    """One delegation-ledger record. Model and effort come from the last
    assistant line of the transcript, whose format is internal to Claude
    Code, so anything unreadable is recorded as `unread`, never guessed."""
    model = effort = "unread"
    for line in reversed(list(transcript_lines)):
        try:
            obj = json.loads(line)
        except (ValueError, TypeError):
            continue
        if not isinstance(obj, dict) or obj.get("type") != "assistant":
            continue
        message = obj.get("message")
        got_model = message.get("model") if isinstance(message, dict) else None
        got_effort = obj.get("effort")
        model = got_model if isinstance(got_model, str) and got_model else "unread"
        effort = got_effort if isinstance(got_effort, str) and got_effort else "unread"
        break
    agent_type = payload.get("agent_type")
    delegate = table["delegate"]
    if agent_type not in agent_names:
        pin = "n/a"
    elif "unread" in (model, effort):
        pin = "unread"
    elif model == delegate["model"] and effort == delegate["effort"]:
        pin = "match"
    else:
        pin = "mismatch"
    return {"at": now_iso, "session": payload.get("session_id"), "agent_type": agent_type,
            "agent_id": payload.get("agent_id"), "model": model, "effort": effort,
            "payload_effort": payload.get("effort"), "pin": pin}


# What a delegate may never touch. The lead owns git state, the review panel,
# and these roots (`.git`, the agent and panel configuration, the plan, and the
# frozen AutoIt specification).
PROTECTED_ROOTS = (".git", ".claude", ".conclave", "todo", "resolute_au3")
READ_ONLY_DELEGATES = ("delegate-research", "delegate-check")
WRITE_TOOLS = ("Edit", "Write", "NotebookEdit")
GUARDED_TOOLS = ("Bash",) + WRITE_TOOLS
GIT_DENIED = ("add", "am", "apply", "branch", "checkout", "cherry-pick", "clean", "commit",
              "config", "gc", "merge", "mv", "notes", "pull", "push", "rebase", "reset",
              "restore", "revert", "rm", "stash", "submodule", "switch", "tag", "update-index",
              "update-ref", "worktree")

_ARG = r"""(?:"[^"]*"|'[^']*'|[^\s;&|()`"']+)"""
_PATHISH = r"""[^\s;&|()`"']*[\\/]"""
# Horizontal whitespace, or a backslash-newline continuation: argument scans
# never cross a bare newline, which ends the command.
_HS = r"(?:[ \t]|\\\r?\n)"
# A command position: the start, or after `;`, `&`, `|`, `(`, a backtick, or a
# newline, then optional spaces and `NAME=value` assignments. `$(` ends in `(`.
_CMD_POS = r"""(?:^|[;&|(`\n])\s*(?:[A-Za-z_]\w*=(?:"[^"]*"|'[^']*'|[^\s;&|()`"']*)\s+)*"""
_GIT_RE = re.compile(
    _CMD_POS + r"(?:" + _PATHISH + r")?git(?:\.exe)?"
    r"(?:" + _HS + r"+(?:-[Cc]" + _HS + r"+" + _ARG + r"|--(?:git-dir|work-tree|namespace|config-env|exec-path)"
    r"(?:=" + _ARG + r"|" + _HS + r"+" + _ARG + r")|--?[A-Za-z][\w-]*(?:=" + _ARG + r")?))*"
    + _HS + r"+(?P<sub>" + "|".join(GIT_DENIED) + r")(?![\w-])")
_PANEL_RE = re.compile(
    _CMD_POS + r"(?:(?:" + _PATHISH + r")?(?:python3?|py)(?:\.exe)?(?:" + _HS + r"+-[^\s;&|()`]+)*"
    + _HS + r"+)?"
    r"""["']?[^\s;&|()`"']*panel_slots\.py["']?""" + _HS + r"+(?P<sub>exec|delegate-probe)(?![\w-])")
_CODEX_RE = re.compile(
    _CMD_POS + r"(?:" + _PATHISH + r")?codex(?:\.cmd|\.exe|\.ps1)?(?![\w.-])")


_MUTATORS = ("rm", "rmdir", "mv", "cp", "touch", "mkdir", "tee", "truncate", "dd", "ln", "chmod",
             "chown", "install", "patch", "unzip", "tar")
_CMDLETS = ("Remove-Item", "Set-Content", "Add-Content", "Out-File", "New-Item", "Copy-Item",
            "Move-Item", "Rename-Item", "Clear-Content")
_MUTATOR_RE = re.compile(
    _CMD_POS + r"(?:" + _PATHISH + r")?(?P<name>" + "|".join(_MUTATORS) + r")(?:\.exe)?(?![\w.-])")
_CMDLET_RE = re.compile(
    _CMD_POS + r"(?:" + _PATHISH + r")?(?P<name>" + "|".join(_CMDLETS) + r")(?![\w.-])", re.IGNORECASE)
# `sed` and `perl` mutate only with an in-place option (`-i`, `-pi`, `-i.bak`, `--in-place`).
_INPLACE_RE = re.compile(
    _CMD_POS + r"(?:" + _PATHISH + r")?(?P<name>sed|perl)(?:\.exe)?(?:" + _HS + r"+" + _ARG + r")*?"
    + _HS + r"+(?:-[A-Za-z]*i[^\s;&|()`]*|--in-place[^\s;&|()`]*)(?![\w-])")
_ARG_RE = re.compile(_ARG)
_HARMLESS_SINKS = ("/dev/null", "nul", "$null")


def _unquoted(token: str) -> str:
    return token.replace('"', "").replace("'", "")


def _mutators(command: str) -> list[tuple[str, int]]:
    """Every mutating command in `command`: its name and where the name ends."""
    found = []
    for regex in (_MUTATOR_RE, _CMDLET_RE, _INPLACE_RE):
        for match in regex.finditer(command):
            name = match.group("name")
            found.append((f"{name} -i" if regex is _INPLACE_RE else name, match.end("name")))
    return sorted(found, key=lambda item: item[1])


_REDIRECT_TOKEN_RE = re.compile(r"^\d*(?:>>?|<)[|&]?(?P<rest>.*)$")


def _segment_args(command: str, start: int) -> list[str]:
    """The quote-stripped arguments of the command whose name ends at `start`,
    up to the next unquoted separator (a newline, `;`, `|`, `(`, `)`, a
    backtick, or a `&` that does not belong to `2>&1` or `&>`). Redirection
    tokens (`2>/dev/null`, `> out`) are dropped: `_redirect_targets` judges them."""
    quote = None
    end = start
    while end < len(command):
        char = command[end]
        if quote:
            if char == quote:
                quote = None
        elif char in "\"'":
            quote = char
        elif char in ";|\n()`":
            break
        elif char == "&" and command[end - 1:end] != ">" and command[end + 1:end + 2] != ">":
            break
        end += 1
    args = []
    skip = False
    for token in _ARG_RE.findall(command[start:end]):
        if skip:
            skip = False
            continue
        redirect = None if token[:1] in "\"'" else _REDIRECT_TOKEN_RE.match(token)
        if redirect:
            skip = not redirect.group("rest")  # `> out`: the target is the next token
            continue
        args.append(_unquoted(token))
    return args


def _target_option(args: list[str], i: int, rest: str) -> tuple[str | None, int]:
    """The value of a short option whose letter was just read: the rest of its
    cluster when there is one, else the next argument. Returns (value, next index)."""
    if rest:
        return rest, i
    if i < len(args):
        return args[i], i + 1
    return None, i


def _copy_destinations(name: str, args: list[str]) -> list[str]:
    """The operand `cp`, `install`, or `ln` writes: the value of `-t DIR` or
    `--target-directory=DIR`, else the last non-option operand. `install -d`
    creates every operand, so all of them count."""
    operands: list[str] = []
    target = None
    makes_dirs = False
    i = 0
    while i < len(args):
        arg = args[i]
        i += 1
        if arg == "--":
            operands.extend(args[i:])
            break
        if arg.startswith("--"):
            flag, eq, value = arg.partition("=")
            if flag == "--target-directory":
                target, i = (value, i) if eq else _target_option(args, i, "")
            elif flag == "--directory":
                makes_dirs = True
        elif arg.startswith("-") and len(arg) > 1:
            cluster = arg[1:]
            pos = cluster.find("t")
            if pos != -1:
                target, i = _target_option(args, i, cluster[pos + 1:])
            makes_dirs = makes_dirs or "d" in cluster[:pos if pos != -1 else len(cluster)]
        else:
            operands.append(arg)
    if target is not None:
        return [target]
    if name == "install" and makes_dirs:
        return operands
    return operands[-1:]


# Copy-Item parameters that take a value (matched by an unambiguous prefix of at
# least three letters, case-insensitively, as PowerShell does).
_PS_VALUE_PARAMS = ("path", "literalpath", "destination", "filter", "include", "exclude",
                    "credential", "tosession", "fromsession")


def _copy_item_destinations(args: list[str]) -> list[str]:
    """The operand `Copy-Item` writes: `-Destination X`, else the second
    positional operand (the first when `-Path` was named)."""
    positional: list[str] = []
    destination = None
    path_named = False
    i = 0
    while i < len(args):
        arg = args[i]
        i += 1
        if len(arg) > 1 and arg[0] == "-" and arg[1].isalpha():
            name, colon, value = arg[1:].partition(":")
            name = name.lower()
            full = next((p for p in _PS_VALUE_PARAMS if len(name) >= 3 and p.startswith(name)), None)
            if full is None:
                continue  # a switch, or a parameter that names no path
            if not value and i < len(args):
                value = args[i]
                i += 1
            if full == "destination":
                destination = value
            elif full in ("path", "literalpath"):
                path_named = True
        else:
            positional.append(arg)
    if destination is not None:
        return [destination]
    index = 0 if path_named else 1
    return positional[index:index + 1]


_TAR_LONG_MODES = {"--create": "c", "--extract": "x", "--get": "x", "--append": "r",
                   "--update": "u", "--delete": "delete", "--concatenate": "A",
                   "--catenate": "A"}
# Short options that take a value, so the rest of their cluster is not a mode.
_TAR_VALUE_LETTERS = "fCTXIbLNVgKH"


def _tar_scan(args: list[str]) -> tuple[set[str], str | None, str | None]:
    """(modes, archive file, directory) of a `tar` command. A mode is `c`, `x`,
    `r`, `u`, `A`, or `delete`; `-t` and `--list` add none, so an empty set is
    list mode. The first argument may be a bundled cluster with no dash (`xzf`)."""
    modes: set[str] = set()
    archive = directory = None
    i = 0
    while i < len(args):
        arg = args[i]
        first = i == 0
        i += 1
        if arg.startswith("--"):
            flag, eq, value = arg.partition("=")
            if flag in _TAR_LONG_MODES:
                modes.add(_TAR_LONG_MODES[flag])
            elif flag in ("--file", "--directory"):
                if not eq:
                    value, i = _target_option(args, i, "")
                if flag == "--file":
                    archive = value
                else:
                    directory = value
            continue
        if not first and not (arg.startswith("-") and len(arg) > 1):
            continue
        cluster = arg[1:] if arg.startswith("-") else arg
        for pos, letter in enumerate(cluster):
            if letter in "cxruA":
                modes.add(letter)
            elif letter in _TAR_VALUE_LETTERS:
                value, i = _target_option(args, i, cluster[pos + 1:])
                if letter == "f":
                    archive = value
                elif letter == "C":
                    directory = value
                break
    return modes, archive, directory


def _tar_targets(args: list[str]) -> list[str]:
    """What `tar` writes: `-C DIR` when it extracts, and the archive file
    when it creates, appends to, updates, or deletes from one."""
    modes, archive, directory = _tar_scan(args)
    targets = []
    if "x" in modes and directory:
        targets.append(directory)
    if modes & {"c", "r", "u", "A", "delete"} and archive:
        targets.append(archive)
    return targets


def _unzip_scan(args: list[str]) -> tuple[bool, str | None]:
    """(read-only, `-d` directory) of an `unzip` command. `-l`, `-v`, `-t`,
    `-z`, and `-Z` list, test, or print without extracting."""
    read_only = False
    directory = None
    i = 0
    while i < len(args):
        arg = args[i]
        i += 1
        if arg.startswith("--") or not arg.startswith("-") or len(arg) == 1:
            continue
        cluster = arg[1:]
        for pos, letter in enumerate(cluster):
            if letter in "lvtzZ":
                read_only = True
            elif letter in "dP":
                value, i = _target_option(args, i, cluster[pos + 1:])
                if letter == "d":
                    directory = value
                break
    return read_only, directory


def _archive_mutates(name: str, args: list[str]) -> bool:
    """False for list or test mode (`tar -t`, `unzip -l`), which only reads."""
    if name == "tar":
        return bool(_tar_scan(args)[0])
    return not _unzip_scan(args)[0]


def _write_operands(name: str, args: list[str]) -> list[str]:
    """The operands of a mutator that it writes. A copy writes its destination
    only, so a protected source is fine; a move modifies both ends, and every
    other mutator is judged by all of its operands."""
    key = name.lower()
    if key in ("cp", "install", "ln"):
        return _copy_destinations(key, args)
    if key == "copy-item":
        return _copy_item_destinations(args)
    if key == "tar":
        return _tar_targets(args)
    if key == "unzip":
        directory = _unzip_scan(args)[1]
        return [directory] if directory else []
    return args


def _redirect_targets(command: str) -> list[str]:
    """The target of every unquoted `>` or `>>` (fd prefixes such as `2>` are
    covered because only the `>` is looked for), minus the harmless sinks and
    descriptor duplication (`2>&1`, `>&2`). A redirection with no readable
    target is returned as an empty string."""
    targets = []
    quote = None
    i = 0
    while i < len(command):
        char = command[i]
        if quote:
            if char == quote:
                quote = None
        elif char in "\"'":
            quote = char
        elif char == ">":
            i += 1
            if command[i:i + 1] == ">":
                i += 1
            if command[i:i + 1] == "|":
                i += 1
            if command[i:i + 1] == "&":
                i += 1
                if command[i:i + 1] in tuple("0123456789-"):
                    i += 1
                    continue
            while command[i:i + 1] in (" ", "\t"):
                i += 1
            found = _ARG_RE.match(command, i)
            target = _unquoted(found.group()) if found else ""
            if target.lower() not in _HARMLESS_SINKS:
                targets.append(target)
            i = found.end() if found else i
            continue
        i += 1
    return targets


def _protected_root(token: str, repo_root: str) -> str | None:
    """The protected root a path token names, or None. A relative token is a
    root name or starts with one followed by a separator (`./` and `..` are
    normalised away); an absolute token must resolve into `repo_root/<root>`."""
    token = _unquoted(token).strip()
    if not token or token.startswith("-"):
        return None
    if re.match(r"(?:[A-Za-z]:)?[\\/]", token):
        full = _resolved(token)
        for name in PROTECTED_ROOTS:
            root = _resolved(os.path.join(repo_root, name))
            if full == root or full.startswith(root + os.sep):
                return name
        return None
    relative = os.path.normcase(os.path.normpath(token.replace("\\", "/"))).replace("\\", "/")
    for name in PROTECTED_ROOTS:
        name_cmp = os.path.normcase(name).replace("\\", "/")
        if relative == name_cmp or relative.startswith(name_cmp + "/"):
            return name
    return None


def _mutation_rule(command: str, read_only: bool, repo_root: str) -> str | None:
    """The name of the shell-mutation rule `command` breaks, or None. A
    read-only delegate may not mutate at all (any mutator, any redirection
    that is not a harmless sink); every other delegate may not mutate a
    protected root."""
    for name, end in _mutators(command):
        args = _segment_args(command, end)
        if name in ("tar", "unzip") and not _archive_mutates(name, args):
            continue
        if read_only:
            return f"read-only: {name}"
        for token in _write_operands(name, args):
            root = _protected_root(token, repo_root)
            if root is not None:
                return f"{name} into {root}"
    for target in _redirect_targets(command):
        if read_only:
            return "read-only: redirection"
        root = _protected_root(target, repo_root)
        if root is not None:
            return f"redirection into {root}"
    return None


def _bash_rule(command: str, read_only: bool = False, repo_root: str = ".") -> str | None:
    """The name of the rule a delegate's Bash command breaks, or None."""
    found = _GIT_RE.search(command)
    if found:
        return f"git {found.group('sub')}"
    found = _PANEL_RE.search(command)
    if found:
        return f"panel_slots.py {found.group('sub')}"
    if _CODEX_RE.search(command):
        return "codex"
    return _mutation_rule(command, read_only, repo_root)


def _resolved(path: str) -> str:
    return os.path.normcase(os.path.realpath(os.path.normpath(path)))


def pre_tool_decision(payload: dict, repo_root: str) -> str | None:
    """A deny reason for a delegate's Bash, Edit, Write, or NotebookEdit call,
    or None. Only an `agent_type` starting with `delegate-` is constrained: the
    lead and every other agent are never. `delegate-research` and
    `delegate-check` are read-only. Every delegate is kept out of mutating git,
    the review panel (`panel_slots.py exec`, `delegate-probe`, `codex`), and the
    protected roots under `repo_root`; paths outside the repository (scratch)
    are free. Bash also guards ordinary shell mutations: a read-only delegate
    may run no mutator (`rm`, `cp`, `tee`, `sed -i`, `Remove-Item`, and the
    rest of `_MUTATORS` and `_CMDLETS`) and no output redirection except the
    harmless sinks (`2>&1`, `>&2`, `/dev/null`, `nul`, `$null`), and any other
    delegate may not aim a mutator or a redirection at a protected root. A
    command ends at a newline or separator; `cp`, `install`, `ln`, and
    `Copy-Item` are judged by their destination only (a move by both ends); and
    `tar -t` and `unzip -l` (list or test) are not mutations. This is
    a guard against accidents, not a sandbox: it reads the command text with a
    regex, so a determined `bash -c`, a quoted separator, a PowerShell alias
    such as `del`, an interpreter that writes the file itself, or a script that
    does the same thing gets past it, and it is not a security boundary."""
    kind = payload.get("agent_type")
    if not isinstance(kind, str) or not kind.startswith(DELEGATE_PREFIX):
        return None
    tool = payload.get("tool_name")
    tool_input = payload.get("tool_input")
    if tool not in GUARDED_TOOLS or not isinstance(tool_input, dict):
        return None
    owns = (f"The lead owns git state, the review panel, and the protected roots "
            f"({', '.join(PROTECTED_ROOTS)}); report what you need instead of doing it.")
    if tool == "Bash":
        command = tool_input.get("command")
        rule = (_bash_rule(command, kind in READ_ONLY_DELEGATES, repo_root)
                if isinstance(command, str) else None)
        if rule is None:
            return None
        return f"{kind} may not run `{rule}`. {owns}"
    if kind in READ_ONLY_DELEGATES:
        return f"{kind} is read-only, so {tool} is denied. {owns}"
    path = tool_input.get("file_path") or tool_input.get("notebook_path")
    if not isinstance(path, str) or not path:
        return None
    full = _resolved(path if os.path.isabs(path) else os.path.join(repo_root, path))
    for name in PROTECTED_ROOTS:
        root = _resolved(os.path.join(repo_root, name))
        if full == root or full.startswith(root + os.sep):
            return f"{kind} may not write under `{name}` ({path}). {owns}"
    return None


def _read_json_payload(stdin, stderr, event: str) -> dict | None:
    try:
        payload = json.loads(stdin.read())
    except (ValueError, OSError):
        print(f"panel_slots: hook {event}: payload is not JSON; allowing", file=stderr, flush=True)
        return None
    if not isinstance(payload, dict):
        print(f"panel_slots: hook {event}: payload is not an object; allowing", file=stderr, flush=True)
        return None
    return payload


def _deny(reason: str, stdout) -> None:
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse", "permissionDecision": "deny",
        "permissionDecisionReason": reason}}), file=stdout, flush=True)


def run_hook(event: str, stdin, stdout, stderr, table: dict | None = None,
             agent_names: list[str] | None = None, ledger: str | None = None,
             agents: str | None = None, repo_root: str | None = None) -> int:
    """Handle one hook event. Always exits 0: a hook that cannot decide
    allows, with one stderr line saying why. Agent names come from
    `agent_names`, else from the `agents` roster directory (default
    `.claude/agents`)."""
    payload = _read_json_payload(stdin, stderr, event)
    if payload is None:
        return 0
    try:
        if event == "pre-tool":
            if payload.get("tool_name") not in GUARDED_TOOLS:
                return 0
            here = os.path.dirname(os.path.abspath(__file__))
            reason = pre_tool_decision(payload, repo_root or os.path.join(here, ".."))
            if reason is not None:
                _deny(reason, stdout)
            return 0
        if event == "subagent-stop":
            kind = payload.get("agent_type")
            if not isinstance(kind, str) or not kind:
                return 0  # a harness-internal side agent, not a delegation
        table = table or load()
        if event == "pre-agent":
            if payload.get("tool_name") != "Agent":
                return 0
            tool_input = payload.get("tool_input")
            if not isinstance(tool_input, dict):
                print("panel_slots: hook pre-agent: no tool_input; allowing", file=stderr, flush=True)
                return 0
            reason = pre_agent_decision(tool_input, table,
                                        agent_names if agent_names is not None else roster_names(agents))
            if reason is not None:
                _deny(reason, stdout)
            return 0
        lines: list[str] = []
        transcript = payload.get("agent_transcript_path")
        if isinstance(transcript, str) and transcript:
            try:
                with open(transcript, encoding="utf-8", errors="replace") as fh:
                    lines = fh.read().splitlines()
            except OSError:
                lines = []
        names = agent_names if agent_names is not None else roster_names(agents)
        now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        entry = ledger_entry(payload, table, names, lines, now)
        path = ledger or ledger_path()
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        with open(path, "a", encoding="utf-8") as fh:
            fh.write(json.dumps(entry) + "\n")
        warning = None
        if entry["pin"] == "mismatch":
            warning = (f"panel_slots: delegation {entry['agent_type']} ran {entry['model']} at effort "
                       f"{entry['effort']}, not the pin {table['delegate']['model']} at "
                       f"{table['delegate']['effort']}")
        elif entry["pin"] == "unread":
            warning = (f"panel_slots: delegation {entry['agent_type']} left no readable model or effort "
                       f"in its transcript; the pin is unproven for this run")
        if warning is not None:
            print(warning, file=stderr, flush=True)
    except Exception as exc:  # fail open: a hook that cannot decide never blocks
        print(f"panel_slots: hook {event}: {type(exc).__name__}: {exc}; allowing", file=stderr, flush=True)
    return 0


def show_ledger(count: int, stdout, path: str | None = None) -> int:
    path = path or ledger_path()
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            lines = fh.read().splitlines()
    except FileNotFoundError:
        print("no delegations recorded", file=stdout)
        return 0
    for line in lines[-count:] if count > 0 else []:
        print(line, file=stdout)
    return 0


# --- self-test ---------------------------------------------------------------

GOOD = r"""
[writer]
model = "w-claude"
[model."w-claude"]
family = "claude"
probed = "2026-09-23"
[model."d-sonnet"]
family = "claude"
probed = "2026-10-01"
[model."d-old"]
family = "claude"
retired = "2026-09-01"
[model."g-one"]
family = "codex"
probed = "2026-09-23"
[model."g-old"]
family = "codex"
retired = "2026-09-01"
[model."k-newest"]
family = "grok"
retired = "2026-09-25"
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
[slot.plan-primary]
model = "g-one"
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
[delegate]
alias = "sonnet"
model = "d-sonnet"
effort = "high"
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
    check("argv independent takes scope, no stdin dash",
          argv_for_slot("independent", ["--commit", "abc"], table=good)
          == ["codex", "review", "--commit", "abc", "-c", 'model="g-one"', "-c",
              'model_reasoning_effort="high"'])
    try:
        argv_for_slot("nope", table=good)
        check("unknown slot refuses", False)
    except PanelSlotsError as exc:
        check("unknown slot refuses", "unknown" in str(exc))

    # A retired `newest` entry still lets historical records parse.
    check("family accepts a recorded concrete model", family_accepts("grok", "k-4.9", good))
    check("family refuses a suffixed variant", not family_accepts("grok", "k-4.9-build-fast", good))
    check("family accepts the served name", family_accepts("grok", "k-4.7-build", good))
    check("family refuses the newest alias as a recorded model", not family_accepts("grok", "k-newest", good))
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
    refuses("fallback slot is ungoverned",
            GOOD + '[slot.signoff-fallback]\nmodel = "g-one"\neffort = "high"\ntimeout = 600\n',
            "ungoverned slots: signoff-fallback")
    live_grok = GOOD.replace('family = "grok"\nretired = "2026-09-25"', 'family = "grok"\nprobed = "2026-09-25"')
    refuses("grok slot has no runner", slot_line(live_grok, "bulk", "model", '"k-newest"'),
            "which has no runner")
    live_newest = live_grok.replace('family = "grok"\nprobed', 'family = "codex"\nprobed')
    refuses("newest slot refuses", slot_line(live_newest, "bulk", "model", '"k-newest"'),
            "is a `newest` entry")
    refuses("writer family governs", slot_line(GOOD, "signoff", "model", '"w-claude"'),
            "no slot reviews its own writer")
    refuses("writer family plan", slot_line(GOOD, "plan-primary", "model", '"w-claude"'),
            "no slot reviews its own writer")
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
    refuses("bad family", GOOD.replace('[model."g-one"]\nfamily = "codex"', '[model."g-one"]\nfamily = "other"'),
            "family 'other' is outside")
    refuses("bad toml", "[writer\n", "does not parse")
    # Writer flips to codex: every codex slot now fails.
    flipped = GOOD.replace('[writer]\nmodel = "w-claude"', '[writer]\nmodel = "g-one"')
    refuses("writer flip fails its family's slots", flipped, "no slot reviews its own writer")

    fam = os.path.join(tmpd, "fam.toml")
    with open(fam, "w", encoding="utf-8") as fh:
        fh.write(GOOD)
    check("family models include retired", family_models("codex", fam) == ("g-old", "g-one"))
    check("family models live only", family_models("codex", fam, include_retired=False) == ("g-one",))

    # exec: timeout path returns 124 and kills the child; stdin pipes.
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

    # The delegate pin.
    check("delegate pin loads", good["delegate"] == {"alias": "sonnet", "model": "d-sonnet",
                                                     "effort": "high", "family": "claude"})
    refuses("delegate missing", GOOD.split("[delegate]")[0], "no [delegate] table")
    refuses("delegate alias outside the set", GOOD.replace('alias = "sonnet"', 'alias = "gpt"'),
            "delegate alias 'gpt' is outside")
    refuses("delegate model unregistered", GOOD.replace('model = "d-sonnet"', 'model = "d-nope"'),
            "delegate model 'd-nope' is not registered")
    refuses("delegate model retired", GOOD.replace('model = "d-sonnet"', 'model = "d-old"'),
            "retired 2026-09-01")
    refuses("delegate foreign family", GOOD.replace('model = "d-sonnet"', 'model = "g-one"'),
            "delegates are subagents of the writer harness")
    # The delegate block is last in GOOD, so its effort is the last one.
    head = GOOD[:GOOD.rindex('effort = "high"')]
    refuses("delegate effort medium", head + 'effort = "medium"\n',
            "delegate effort 'medium' is outside high, xhigh")
    refuses("delegate effort low", head + 'effort = "low"\n', "delegate effort 'low' is outside")
    refuses("delegate alias not a string", GOOD.replace('alias = "sonnet"', 'alias = ["a"]'),
            "delegate alias ['a'] is not a string")
    refuses("delegate model not a string", GOOD.replace('model = "d-sonnet"', 'model = ["a"]'),
            "delegate model ['a'] is not a string")
    refuses("delegate effort not a string", head + 'effort = ["a"]\n',
            "delegate effort ['a'] is not a string")
    xhigh = head + 'effort = "xhigh"\n'
    check("delegate effort xhigh accepted", load(write(xhigh))["delegate"]["effort"] == "xhigh")

    # The agent roster.
    def roster(files: dict[str, str]) -> str:
        directory = tempfile.mkdtemp(prefix="agents-", dir=tmpd)
        for name, text in files.items():
            with open(os.path.join(directory, name), "w", encoding="utf-8") as fh:
                fh.write(text)
        return directory

    def agent(name: str = "delegate-x", model: str | None = "sonnet", effort: str | None = "high") -> str:
        lines = ["---", f"name: {name}", "description: a test agent"]
        if model is not None:
            lines.append(f"model: {model}")
        if effort is not None:
            lines.append(f"effort: {effort}")
        return "\n".join(lines + ["tools: Read", "---", "body", ""])

    def agents_refuse(name: str, files: dict[str, str], needle: str) -> None:
        try:
            check_agents(good, roster(files))
        except PanelSlotsError as exc:
            check(name, needle in str(exc), f"message {exc!s} lacks {needle!r}")
            return
        check(name, False, "roster accepted without refusal")

    check("valid roster accepted",
          check_agents(good, roster({"delegate-a.md": agent("delegate-a"),
                                     "delegate-b.md": agent("delegate-b")}))
          == ["delegate-a", "delegate-b"])
    agents_refuse("roster empty", {}, "holds no *.md agent files")
    try:
        check_agents(good, os.path.join(tmpd, "no-such-dir"))
        check("roster directory missing", False, "accepted")
    except PanelSlotsError as exc:
        check("roster directory missing", "does not exist" in str(exc))
    agents_refuse("agent without frontmatter", {"delegate-x.md": "just text\n"}, "has no frontmatter")
    agents_refuse("agent frontmatter never closes", {"delegate-x.md": "---\nname: delegate-x\n"},
                  "no closing ---")
    agents_refuse("agent missing effort", {"delegate-x.md": agent(effort=None)}, "omits field effort")
    agents_refuse("agent missing model", {"delegate-x.md": agent(model=None)}, "omits field model")
    agents_refuse("agent wrong model", {"delegate-x.md": agent(model="opus")}, "field model 'opus'")
    agents_refuse("agent wrong effort", {"delegate-x.md": agent(effort="medium")},
                  "field effort 'medium'")
    agents_refuse("agent name differs from stem", {"delegate-y.md": agent("delegate-x")},
                  "is not the file stem")
    agents_refuse("agent name lacks the prefix", {"helper.md": agent("helper")}, "lacks the 'delegate-' prefix")

    names_dir = roster({"delegate-b.md": agent("delegate-b"), "delegate-a.md": "just text\n",
                        "helper.md": agent("helper"), "delegate-c.txt": "x"})
    check("roster_names lists delegate stems only", roster_names(names_dir) == ["delegate-a", "delegate-b"])
    check("roster_names of an absent directory", roster_names(os.path.join(tmpd, "no-such-dir")) == [])
    check("roster_names of an empty directory", roster_names(roster({})) == [])

    def raw_agent(data: bytes) -> str:
        directory = tempfile.mkdtemp(prefix="agents-", dir=tmpd)
        path = os.path.join(directory, "delegate-x.md")
        with open(path, "wb") as fh:
            fh.write(data)
        return path

    crlf = agent().replace("\n", "\r\n").encode("utf-8")
    check("frontmatter reads CRLF line endings",
          agent_frontmatter(raw_agent(crlf))["effort"] == "high")
    check("frontmatter reads a UTF-8 BOM",
          agent_frontmatter(raw_agent(b"\xef\xbb\xbf" + agent().encode("utf-8")))["name"] == "delegate-x")
    colon = agent().replace("description: a test agent", "description: Use when: asked, then: stop")
    check("frontmatter keeps a colon in a description",
          agent_frontmatter(raw_agent(colon.encode("utf-8")))["description"] == "Use when: asked, then: stop")

    # delegate-probe verdicts.
    def probe(model_usage: dict | None = None, **over) -> str:
        obj = {"is_error": False, "result": "PROBE-OK",
               "modelUsage": {"d-sonnet": {}} if model_usage is None else model_usage}
        obj.update(over)
        return json.dumps(obj)

    def probe_refuses(name: str, text: str, needle: str) -> None:
        try:
            probe_verdict(text, good)
        except PanelSlotsError as exc:
            check(name, needle in str(exc), f"message {exc!s} lacks {needle!r}")
            return
        check(name, False, "probe accepted without refusal")

    check("probe verdict ok", probe_verdict(probe(), good) == "d-sonnet")
    probe_refuses("probe alias moved", probe({"d-sonnet-next": {}}), "the alias has moved; re-pin")
    probe_refuses("probe names what it resolved to", probe({"d-sonnet-next": {}}), "resolved to d-sonnet-next")
    probe_refuses("probe extra model", probe({"d-sonnet": {}, "d-other": {}}), "the alias has moved")
    probe_refuses("probe is_error", probe(is_error=True), "is_error")
    probe_refuses("probe lacks PROBE-OK", probe(result="hello"), "lacks PROBE-OK")
    probe_refuses("probe unparsable", "not json", "is not JSON")
    probe_refuses("probe modelUsage empty", probe({}), "carries no modelUsage")
    missing = json.loads(probe())
    del missing["modelUsage"]
    probe_refuses("probe modelUsage missing", json.dumps(missing), "carries no modelUsage")

    # The pre-agent hook decision.
    def decision(**tool_input) -> str | None:
        return pre_agent_decision(tool_input, good, ["delegate-a", "delegate-b"])

    check("hook allows fork", decision(subagent_type="fork") is None)
    check("hook allows a bare delegate", decision(subagent_type="delegate-a") is None)
    check("hook denies a delegate with a model",
          "omit `model`" in (decision(subagent_type="delegate-a", model="sonnet") or ""))
    for label, kwargs in (("general-purpose bare", {"subagent_type": "general-purpose"}),
                          ("empty type bare", {}),
                          ("Explore bare", {"subagent_type": "Explore"})):
        reason = decision(**kwargs) or ""
        check(f"hook denies {label}", "unpinned effort" in reason and "delegate-a, delegate-b" in reason
              and "GPT panel" in reason, reason)
    for model in ("sonnet", "haiku", "claude-sonnet-5-5"):
        reason = decision(subagent_type="general-purpose", model=model) or ""
        check(f"hook denies general-purpose with {model}",
              "default effort, not the pinned high" in reason and "delegate-a, delegate-b" in reason, reason)
    for model in ("opus", "fable", "w-claude"):
        check(f"hook allows general-purpose with {model}",
              decision(subagent_type="general-purpose", model=model) is None)
    for model in ("claude-opus-3", "claude-opus-4-1", "claude-fable-1"):
        reason = decision(subagent_type="general-purpose", model=model) or ""
        check(f"hook denies the older id {model}", "default effort, not the pinned high" in reason, reason)
    check("hook denies a delegate type with model opus",
          "omit `model`" in (decision(subagent_type="delegate-b", model="opus") or ""))

    def run(event: str, text: str, **kw) -> tuple[int, str, str]:
        out, err = io.StringIO(), io.StringIO()
        rc = run_hook(event, io.StringIO(text), out, err, table=good, agent_names=["delegate-a"], **kw)
        return rc, out.getvalue(), err.getvalue()

    out, err = io.StringIO(), io.StringIO()
    rc = run_hook("pre-agent", io.StringIO(json.dumps({"tool_name": "Agent", "tool_input": {}})),
                  out, err, table={"slots": {}}, agent_names=["delegate-a"])
    check("hook fails open on an unexpected error", rc == 0 and out.getvalue() == ""
          and "KeyError" in err.getvalue() and "allowing" in err.getvalue(), err.getvalue())

    denied = run("pre-agent", json.dumps({"tool_name": "Agent", "tool_input": {
        "subagent_type": "general-purpose", "model": "sonnet"}}))
    body = json.loads(denied[1]) if denied[1].strip() else {}
    inner = body.get("hookSpecificOutput", {})
    check("deny stdout shape", denied[0] == 0 and list(body) == ["hookSpecificOutput"]
          and inner.get("hookEventName") == "PreToolUse" and inner.get("permissionDecision") == "deny"
          and "default effort" in inner.get("permissionDecisionReason", "")
          and denied[1].count("\n") == 1, denied[1])
    allowed = run("pre-agent", json.dumps({"tool_name": "Agent", "tool_input": {
        "subagent_type": "delegate-a"}}))
    check("allow is silent", allowed == (0, "", ""), repr(allowed))
    other = run("pre-agent", json.dumps({"tool_name": "Bash", "tool_input": {"command": "ls"}}))
    check("non-Agent tool is ignored", other == (0, "", ""), repr(other))
    for event in ("pre-agent", "subagent-stop"):
        for text in ("not json", "[1, 2]", ""):
            rc, out, err = run(event, text)
            check(f"{event} fails open on {text!r}", rc == 0 and out == "" and err.count("\n") == 1, err)
    rc, out, err = run("pre-agent", json.dumps({"tool_name": "Agent"}))
    check("pre-agent fails open without tool_input", rc == 0 and out == "" and "allowing" in err)

    # The delegation ledger.
    def assistant(model: str | None, effort: str | None) -> str:
        message = {} if model is None else {"model": model}
        obj = {"type": "assistant", "message": message}
        if effort is not None:
            obj["effort"] = effort
        return json.dumps(obj)

    stamp = "2026-10-01T00:00:00Z"
    base = {"session_id": "s1", "agent_type": "delegate-a", "agent_id": "a1", "effort": "high"}
    names = ["delegate-a"]
    first_user = json.dumps({"type": "user"})
    entry = ledger_entry(base, good, names, [assistant("x", "low"), first_user,
                                             assistant("d-sonnet", "high"), "garbage", first_user], stamp)
    check("ledger match", entry == {"at": stamp, "session": "s1", "agent_type": "delegate-a",
                                    "agent_id": "a1", "model": "d-sonnet", "effort": "high",
                                    "payload_effort": "high", "pin": "match"}, str(entry))
    entry = ledger_entry(base, good, names, [assistant("d-sonnet", "medium")], stamp)
    check("ledger mismatch on effort", entry["pin"] == "mismatch" and entry["effort"] == "medium")
    entry = ledger_entry(base, good, names, [assistant("d-other", "high")], stamp)
    check("ledger mismatch on model", entry["pin"] == "mismatch" and entry["model"] == "d-other")
    entry = ledger_entry({"agent_type": "delegate-a"}, good, names, [first_user], stamp)
    check("ledger unread without an assistant line", entry["model"] == "unread"
          and entry["effort"] == "unread" and entry["payload_effort"] is None
          and entry["pin"] == "unread", str(entry))
    entry = ledger_entry(base, good, names, [assistant(None, None)], stamp)
    check("ledger unread when fields are absent", entry["model"] == "unread" and entry["effort"] == "unread"
          and entry["pin"] == "unread")
    entry = ledger_entry(base, good, names, [assistant("d-sonnet", None)], stamp)
    check("ledger unread when only effort is absent", entry["pin"] == "unread", str(entry))
    entry = ledger_entry({"agent_type": "Explore"}, good, names, [assistant("x", "low")], stamp)
    check("ledger n/a for a non-delegate", entry["pin"] == "n/a")

    ledger = os.path.join(tmpd, "ledger-dir", "agent-delegations.jsonl")
    transcript = os.path.join(tmpd, "transcript.jsonl")
    with open(transcript, "w", encoding="utf-8") as fh:
        fh.write(assistant("d-sonnet", "high") + "\n")
    stop = json.dumps({**base, "agent_transcript_path": transcript})
    real_env = os.environ.get("PANEL_DELEGATION_LEDGER")
    os.environ["PANEL_DELEGATION_LEDGER"] = ledger
    try:
        rc, out, err = run("subagent-stop", stop)
        check("ledger append is silent on match", (rc, out, err) == (0, "", ""), repr((rc, out, err)))
        with open(transcript, "w", encoding="utf-8") as fh:
            fh.write(assistant("d-sonnet", "medium") + "\n")
        rc, out, err = run("subagent-stop", stop)
        check("ledger warns on mismatch on stderr only", rc == 0 and out == ""
              and "not the pin" in err and err.count("\n") == 1, repr((out, err)))
        rc, out, err = run("subagent-stop", json.dumps({**base, "agent_transcript_path": "no-such-file"}))
        check("ledger warns on unread on stderr only", rc == 0 and out == ""
              and "unproven" in err and err.count("\n") == 1, repr((out, err)))
        for label, kind in (("absent", None), ("empty", ""), ("non-string", 7)):
            side = {k: v for k, v in base.items() if k != "agent_type"}
            if kind is not None:
                side["agent_type"] = kind
            side["agent_transcript_path"] = transcript
            check(f"ledger writes nothing for an {label} agent_type",
                  run("subagent-stop", json.dumps(side)) == (0, "", ""))
        with open(ledger, encoding="utf-8") as fh:
            written = [json.loads(line) for line in fh.read().splitlines()]
        check("ledger lines landed in the override path", len(written) == 3
              and written[0]["pin"] == "match" and written[1]["pin"] == "mismatch"
              and written[2]["model"] == "unread" and written[2]["pin"] == "unread", str(written))
        shown = io.StringIO()
        show_ledger(1, shown)
        check("ledger shows the last N", shown.getvalue().count("\n") == 1
              and json.loads(shown.getvalue())["pin"] == "unread")
    finally:
        if real_env is None:
            del os.environ["PANEL_DELEGATION_LEDGER"]
        else:
            os.environ["PANEL_DELEGATION_LEDGER"] = real_env
    shown = io.StringIO()
    show_ledger(10, shown, os.path.join(tmpd, "absent.jsonl"))
    check("ledger absent", shown.getvalue() == "no delegations recorded\n")

    # A malformed roster file never turns the pre-agent guard off.
    names_out, names_err = io.StringIO(), io.StringIO()
    run_hook("pre-agent", io.StringIO(json.dumps({"tool_name": "Agent", "tool_input": {
        "subagent_type": "general-purpose", "model": "sonnet"}})), names_out, names_err,
        table=good, agents=names_dir)
    check("malformed roster file still denies", "default effort" in names_out.getvalue()
          and "delegate-a, delegate-b" in names_out.getvalue() and names_err.getvalue() == "",
          names_out.getvalue() + names_err.getvalue())
    names_out, names_err = io.StringIO(), io.StringIO()
    run_hook("subagent-stop", io.StringIO(json.dumps({"agent_type": "delegate-b", "agent_id": "z"})),
             names_out, names_err, table=good, agents=names_dir,
             ledger=os.path.join(tmpd, "roster-ledger.jsonl"))
    with open(os.path.join(tmpd, "roster-ledger.jsonl"), encoding="utf-8") as fh:
        check("ledger resolves names from the roster directory", json.loads(fh.read())["pin"] == "unread")

    # The pre-tool hook: delegates only, git state, the panel, protected roots.
    root = os.path.join(tmpd, "repo")
    os.makedirs(os.path.join(root, ".git"))

    def tool(name: str, who: str | None = "delegate-build", **tool_input) -> str | None:
        payload = {"tool_name": name, "tool_input": tool_input}
        if who is not None:
            payload["agent_type"] = who
        return pre_tool_decision(payload, root)

    def bash(command: str, who: str | None = "delegate-build") -> str | None:
        return tool("Bash", who, command=command)

    check("non-delegate git commit allowed", bash("git commit -m x", None) is None
          and bash("git commit -m x", "general-purpose") is None)
    for command, rule in (("git commit -m x", "git commit"), ("git -C sub push", "git push"),
                          ("echo a && git reset --hard", "git reset"), ("FOO=1 git stash", "git stash"),
                          ("(git checkout -- f)", "git checkout"), ("ls\ngit add .", "git add"),
                          ("x=$(git config user.name)", "git config"), ("a | git apply p", "git apply"),
                          ("git -c core.x=1 --no-pager tag v1", "git tag"),
                          ("git --git-dir=.git worktree add w", "git worktree"),
                          ('FOO="a b" git rm f', "git rm"), ("/usr/bin/git merge x", "git merge"),
                          ("python scripts/panel_slots.py exec bulk", "panel_slots.py exec"),
                          ("python scripts/panel_slots.py delegate-probe", "panel_slots.py delegate-probe"),
                          ("cd x; ./scripts/panel_slots.py exec bulk", "panel_slots.py exec"),
                          ("codex review", "codex"), ("echo a; codex exec x", "codex")):
        reason = bash(command) or ""
        check(f"delegate-build denies {command!r}", f"`{rule}`" in reason and "lead owns git state" in reason
              and "protected roots" in reason, reason)
    for command in ("git status", "git diff -- a", "git log -3", "git show HEAD", "git ls-files",
                    "git rev-parse HEAD", "git blame f", "git grep commit", "git cat-file -p x",
                    "git ls-remote origin", "git fetch", "git -C sub status",
                    'grep -rn "git commit" docs/', "echo git push", "git commit-tree x",
                    "python scripts/panel_slots.py --self-test", "python -m py_compile scripts/panel_slots.py",
                    'grep -rn "panel_slots.py exec" docs/', "ls codex-notes"):
        check(f"delegate-build allows {command!r}", bash(command) is None, str(bash(command)))
    for who in ("delegate-research", "delegate-check"):
        check(f"{who} Bash follows the git rule too", bash("git push", who) is not None
              and bash("git status", who) is None)
    # Shell mutations: read-only delegates mutate nothing, the rest spare the protected roots.
    abs_git = os.path.join(root, ".git", "config")
    for who, command, rule in (
            ("delegate-check", "rm todo/probe.md", "read-only: rm"),
            ("delegate-research", "cd x && Set-Content a.txt hi", "read-only: Set-Content"),
            ("delegate-check", "echo x > notes.txt", "read-only: redirection"),
            ("delegate-check", "echo x 2>> log.txt", "read-only: redirection"),
            ("delegate-check", "ls | tee out.txt", "read-only: tee"),
            ("delegate-check", "sed -i s/a/b/ scripts/x.py", "read-only: sed -i"),
            ("delegate-check", "perl -pi -e 1 scripts/x.py", "read-only: perl -i"),
            ("delegate-check", "remove-item x", "read-only: remove-item"),
            ("delegate-build", "cp build/probe.md .claude/settings.json", "cp into .claude"),
            ("delegate-build", "rm -rf ./todo/x", "rm into todo"),
            ("delegate-build", "echo x >> resolute_au3/a.au3", "redirection into resolute_au3"),
            ("delegate-build", "echo x 2> .conclave/e", "redirection into .conclave"),
            ("delegate-build", "sed -i s/a/b/ todo/x.md", "sed -i into todo"),
            ("delegate-build", "Remove-Item .conclave\\panel.toml", "Remove-Item into .conclave"),
            ("delegate-build", 'mv a "todo/b c"', "mv into todo"),
            ("delegate-build", "touch x/../todo", "touch into todo"),
            ("delegate-build", f'echo x | tee "{abs_git}"', "tee into .git"),
            ("delegate-build", f"echo x > {os.path.join(root, 'todo', 'a')}", "redirection into todo"),
            # a command ends at its newline, so a later line is judged on its own
            ("delegate-check", "grep -n x a.py\nsed -i s/a/b/ c.txt", "read-only: sed -i"),
            ("delegate-build", "ls\nrm todo/x", "rm into todo"),
            ("delegate-build", "sed -n p a.py\nsed -i s/a/b/ todo/c.md", "sed -i into todo"),
            # a copy writes its destination; a move touches both ends
            ("delegate-build", "cp -t todo build/x", "cp into todo"),
            ("delegate-build", "cp build/x --target-directory=.claude", "cp into .claude"),
            ("delegate-build", "cp build/x --target-directory .claude", "cp into .claude"),
            ("delegate-build", "cp build/a todo/b", "cp into todo"),
            ("delegate-build", "cp -r build/a todo/b 2>/dev/null", "cp into todo"),
            ("delegate-build", "install -d build/x todo/y", "install into todo"),
            ("delegate-build", "ln -s build/a todo/b", "ln into todo"),
            ("delegate-build", "Copy-Item build/a.md -Destination todo/a.md", "Copy-Item into todo"),
            ("delegate-build", "copy-item build/a.md -destination:todo/a.md", "copy-item into todo"),
            ("delegate-build", "Copy-Item -Path build/a.md -Force todo/a.md", "Copy-Item into todo"),
            ("delegate-build", "Copy-Item build/a.md todo/a.md", "Copy-Item into todo"),
            ("delegate-build", "mv todo/a.md build/a.md", "mv into todo"),
            ("delegate-build", "mv build/a.md todo/a.md", "mv into todo"),
            ("delegate-build", "Move-Item todo/a.md build/a.md", "Move-Item into todo"),
            ("delegate-build", "Rename-Item todo/a.md b.md", "Rename-Item into todo"),
            # archives: only a create, extract, append, update, or delete mutates
            ("delegate-check", "tar -xf build/p.tar", "read-only: tar"),
            ("delegate-check", "tar xzf build/p.tgz", "read-only: tar"),
            ("delegate-check", "tar -czf build/p.tgz src", "read-only: tar"),
            ("delegate-check", "tar --extract --file=build/p.tar", "read-only: tar"),
            ("delegate-check", "tar --delete -f build/p.tar x", "read-only: tar"),
            ("delegate-check", "unzip build/p.zip", "read-only: unzip"),
            ("delegate-check", "unzip -o build/p.zip", "read-only: unzip"),
            ("delegate-build", "tar -xf build/p.tar -C todo", "tar into todo"),
            ("delegate-build", "tar xzf build/p.tgz -C .claude", "tar into .claude"),
            ("delegate-build", "tar -xzC todo -f build/p.tgz", "tar into todo"),
            ("delegate-build", "tar -cf todo/p.tar build/x", "tar into todo"),
            ("delegate-build", "unzip build/p.zip -d todo", "unzip into todo"),
            ("delegate-build", "unzip -o build/p.zip -dtodo/out", "unzip into todo")):
        reason = bash(command, who) or ""
        check(f"{who} denies {command!r}", f"`{rule}`" in reason and "protected roots" in reason, reason)
    for who, command in (
            ("delegate-check", "git log -3 2>&1 | head"),
            ("delegate-check", "python scripts/panel_slots.py --self-test 2>/dev/null | tail -1"),
            ("delegate-check", 'grep -rn "rm -rf" docs/'),
            ("delegate-check", "ls > /dev/null; echo a 2>nul; echo b >$null; echo c >&2"),
            ("delegate-check", 'grep ">" notes.txt'),
            ("delegate-check", "ls remove-items; echo rmx"),
            ("delegate-research", "sed -n s/a/b/p scripts/x.py"),
            ("delegate-build", "echo x > build/out.txt"),
            ("delegate-build", "cp a.py scripts/b.py"),
            ("delegate-build", "mkdir -p build/tmp"),
            ("delegate-build", "rm -rf build/todo todox"),
            ("delegate-build", "sed -i s/a/b/ tests/x.py"),
            ("delegate-build", f"touch {os.path.join(tmpd, 'scratch.txt')}"),
            ("delegate-build", "rm a; ls todo"),
            ("delegate-build", "cat todo/x.md > build/copy.md"),
            ("delegate-check", "sed -n '1,20p' scripts/panel_slots.py\ngrep -i delegate AGENTS.md"),
            ("delegate-check", "sed -n p a.py\r\ngrep -i x b.txt"),
            ("delegate-research", "perl -ne print a.pl\ngrep -pi x b.txt"),
            ("delegate-check", "git log -3\ngit status"),
            ("delegate-build", "cp todo/README.md build/plan-fixture.md"),
            ("delegate-build", "cp -r todo/a .claude/b build/"),
            ("delegate-build", "cp todo/a build/b 2>/dev/null"),
            ("delegate-build", "cp -t build todo/a .claude/b"),
            ("delegate-build", "cp --target-directory=build todo/a"),
            ("delegate-build", "install -m 755 todo/a build/b"),
            ("delegate-build", "ln -s todo/a build/link"),
            ("delegate-build", "Copy-Item todo/a.md -Destination build/a.md"),
            ("delegate-build", "Copy-Item todo/a.md build/a.md"),
            ("delegate-build", "Copy-Item -Path todo/a.md -Recurse -Destination:build/a.md"),
            ("delegate-build", "Copy-Item todo/a.md"),
            ("delegate-build", "tar -czf build/p.tgz todo/"),
            ("delegate-build", "tar -xf build/p.tar"),
            ("delegate-build", "tar -xf build/p.tar -C build/out"),
            ("delegate-check", "tar -tf build/package.tar"),
            ("delegate-check", "tar tzf build/p.tgz"),
            ("delegate-check", "tar -tvf build/p.tar -C todo"),
            ("delegate-check", "tar --list --file=build/p.tar"),
            ("delegate-research", "tar -tf build/p.tar | head"),
            ("delegate-check", "unzip -l build/package.zip"),
            ("delegate-check", "unzip -Z1 build/package.zip"),
            ("delegate-check", "unzip -t build/package.zip"),
            ("delegate-check", "unzip -qv build/package.zip"),
            ("delegate-build", "unzip build/p.zip -d build/out"),
            ("delegate-build", "unzip build/p.zip"),
            ("general-purpose", "rm todo/x"),
            (None, "echo x > todo/x")):
        check(f"{who} allows {command!r}", bash(command, who) is None, str(bash(command, who)))
    for label, name, who, key, path in (
            ("Edit .claude/settings.json", "Edit", "delegate-build", "file_path", ".claude/settings.json"),
            ("Write todo/x.md", "Write", "delegate-build", "file_path", "todo/x.md"),
            ("Write resolute_au3/a.au3", "Write", "delegate-build", "file_path", "resolute_au3/a.au3"),
            ("Write .git/config absolute", "Write", "delegate-build", "file_path",
             os.path.join(root, ".git", "config")),
            ("Write TODO/../.conclave/panel.toml", "Write", "delegate-build", "file_path",
             "TODO/../.conclave/panel.toml"),
            ("Write .claude mixed separators", "Write", "delegate-build", "file_path", ".claude\\agents/x.md"),
            ("NotebookEdit under todo", "NotebookEdit", "delegate-build", "notebook_path", "todo/n.ipynb"),
            ("Write scripts/x.py as research", "Write", "delegate-research", "file_path", "scripts/x.py"),
            ("Write scripts/x.py as check", "Write", "delegate-check", "file_path", "scripts/x.py"),
            ("Edit scripts/x.py as check", "Edit", "delegate-check", "file_path", "scripts/x.py"),
            ("NotebookEdit as research", "NotebookEdit", "delegate-research", "notebook_path", "n.ipynb")):
        reason = tool(name, who, **{key: path}) or ""
        check(f"pre-tool denies {label}", "lead owns git state" in reason and "protected roots" in reason, reason)
    for label, who, path in (("scripts/x.py", "delegate-build", "scripts/x.py"),
                             ("todox/a.md", "delegate-build", "todox/a.md"),
                             ("outside the repo", "delegate-build", os.path.join(tmpd, "scratch.txt"))):
        check(f"pre-tool allows Write {label}", tool("Write", who, file_path=path) is None)
    check("pre-tool allows a non-delegate Write under todo", tool("Write", None, file_path="todo/x.md") is None)
    check("pre-tool allows Read", tool("Read", file_path="todo/x.md") is None)
    for label, payload in (("no tool_input", {"tool_name": "Bash", "agent_type": "delegate-build"}),
                           ("tool_input not an object", {"tool_name": "Write", "agent_type": "delegate-build",
                                                         "tool_input": "x"}),
                           ("command not a string", {"tool_name": "Bash", "agent_type": "delegate-build",
                                                     "tool_input": {"command": 7}}),
                           ("no path", {"tool_name": "Write", "agent_type": "delegate-build",
                                        "tool_input": {}}),
                           ("agent_type not a string", {"tool_name": "Bash", "agent_type": 3,
                                                        "tool_input": {"command": "git push"}})):
        check(f"pre-tool allows a payload with {label}", pre_tool_decision(payload, root) is None)

    def run_tool(payload: object) -> tuple[int, str, str]:
        out, err = io.StringIO(), io.StringIO()
        text = payload if isinstance(payload, str) else json.dumps(payload)
        rc = run_hook("pre-tool", io.StringIO(text), out, err, repo_root=root)
        return rc, out.getvalue(), err.getvalue()

    rc, out, err = run_tool({"tool_name": "Bash", "agent_type": "delegate-build", "agent_id": "x",
                             "tool_input": {"command": "git commit -m x"}})
    body = json.loads(out) if out.strip() else {}
    inner = body.get("hookSpecificOutput", {})
    check("pre-tool deny stdout shape", rc == 0 and err == "" and list(body) == ["hookSpecificOutput"]
          and inner.get("hookEventName") == "PreToolUse" and inner.get("permissionDecision") == "deny"
          and "git commit" in inner.get("permissionDecisionReason", "") and out.count("\n") == 1, out)
    check("pre-tool lead call is silent",
          run_tool({"tool_name": "Bash", "tool_input": {"command": "git commit -m x"}}) == (0, "", ""))
    check("pre-tool delegate allow is silent",
          run_tool({"tool_name": "Bash", "agent_type": "delegate-build",
                    "tool_input": {"command": "git status"}}) == (0, "", ""))
    check("pre-tool ignores other tools",
          run_tool({"tool_name": "Read", "agent_type": "delegate-build",
                    "tool_input": {"file_path": "todo/x.md"}}) == (0, "", ""))
    rc, out, err = run_tool({"tool_name": "Write", "agent_type": "delegate-check",
                             "tool_input": {"file_path": "scripts/x.py"}})
    check("pre-tool read-only deny via run_hook", rc == 0 and "is read-only" in out, out)
    for text in ("not json", "[1, 2]", ""):
        rc, out, err = run_tool(text)
        check(f"pre-tool fails open on {text!r}", rc == 0 and out == "" and err.count("\n") == 1, err)
    rc, out, err = run_tool({"tool_name": "Write", "agent_type": "delegate-build",
                             "tool_input": {"file_path": ".claude/x.md"}})
    check("pre-tool path deny via run_hook", rc == 0 and "may not write under `.claude`" in out, out)
    out, err = io.StringIO(), io.StringIO()
    rc = run_hook("pre-tool", io.StringIO(json.dumps({
        "tool_name": "Write", "agent_type": "delegate-build", "tool_input": {"file_path": "x"}})),
        out, err, repo_root=7)
    check("pre-tool fails open on an unexpected error", rc == 0 and out.getvalue() == ""
          and "allowing" in err.getvalue(), err.getvalue())

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
        print("usage: panel_slots.py validate | show | argv <slot> | get <slot> <field> | "
              "writer | family <model> | models <family> [--all] | exec <slot> [extra...] | "
              "delegate-probe | hook pre-agent|subagent-stop|pre-tool | ledger [N] | --self-test",
              file=sys.stderr)
        return 2
    cmd, rest = argv[0], argv[1:]
    if cmd == "hook" and len(rest) == 1 and rest[0] in ("pre-agent", "subagent-stop", "pre-tool"):
        stdin = io.TextIOWrapper(sys.stdin.buffer, encoding="utf-8", errors="replace")
        return run_hook(rest[0], stdin, sys.stdout, sys.stderr)
    try:
        if cmd == "validate" and not rest:
            table = load()
            agents = check_agents(table)
            delegate = table["delegate"]
            print(f"panel slots ok: writer {table['writer']['model']} ({table['writer']['family']}), "
                  f"{len(table['slots'])} slots, {len(table['models'])} registered models; "
                  f"delegate {delegate['alias']} -> {delegate['model']} effort {delegate['effort']}, "
                  f"{len(agents)} agents ({', '.join(agents)})")
            return 0
        if cmd == "delegate-probe" and not rest:
            return delegate_probe(load(), sys.stdout, sys.stderr)
        if cmd == "ledger" and len(rest) <= 1 and (not rest or rest[0].isdecimal()):
            return show_ledger(int(rest[0]) if rest else 10, sys.stdout)
        if cmd == "show" and not rest:
            table = load()
            print(f"writer  {table['writer']['model']} ({table['writer']['family']})")
            for name, entry in table["slots"].items():
                print(f"{name:<17} {entry['model']:<28} {entry['family']:<7} "
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
