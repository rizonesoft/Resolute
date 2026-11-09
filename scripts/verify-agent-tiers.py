#!/usr/bin/env python3
"""Enforce the delegation tier invariant on this project's agent definitions.

The rule is in AGENTS.md: mechanical subtasks delegate to subagents on the
Sonnet tier; an elevated tier is reserved for work whose verdict quality
demands it; Haiku is allowed only for near-mechanical work (at least 90%
mechanical) whose output a script or the main loop verifies; and no subagent
writes: subagents read and run, and the main loop makes every change. True
mechanical work is run as a script by the lead and given to no model; the
Muse Spark workflow (`.agents/workflows/spark.js`) takes the dummy work
around those scripts on `muse-spark-1.3` at medium effort, and this check
also holds that workflow to its model pin, its effort pin, its read-only
contract, its judgment screen, its cited-source evidence check, and the
replay that qualifies it.

A rule stated in prose is protected by discipline. This makes it protected by
a check: an agent with no `model:` line, an agent that could edit files, or a
Haiku agent that does not meet every Haiku condition below, fails here instead
of passing every gate and being noticed later, or never.

An absent `model:` is an error rather than a default, because an unpinned
agent silently inherits the caller's model: mechanical work then runs on the
expensive tier with no signal at all, which is the exact regression this
exists to catch.

No dependencies, so a bootstrapped project can run it from day one. With no
agents defined yet it passes with nothing checked, and starts enforcing the
moment the first definition appears. The Spark check follows the same rule:
it starts enforcing the moment the workflow or its AGENTS.md route appears.

This is a line-for-line port of the former verify-agent-tiers.mjs (retired
2026-11-09 so the repository's gates need no Node installation at all; the
pinned CPython in reskit/python is the only interpreter the tooling runs).

    python scripts/verify-agent-tiers.py
    python scripts/verify-agent-tiers.py --self-test
"""

import os
import re
import sys
import tempfile
from pathlib import Path

# Tier vocabulary.
#
# Kept as substrings rather than exact model IDs so a version bump (sonnet-5
# to a later sonnet) does not silently fail a project that is still obeying
# the rule. The tier is the invariant; the exact pin is a routing decision that
# belongs elsewhere. Haiku is the exception: it must be an exact, versioned pin.
BASE_AGENT_MODEL_TOKENS = ["sonnet"]
ELEVATED_AGENT_MODEL_TOKENS = ["opus", "fable"]
RESTRICTED_AGENT_MODEL_TOKENS = ["haiku"]

# The Haiku allowance, every condition required.
#
# - An exact pin of Haiku 5.5 or later (`claude-haiku-5-5`, optionally with a
#   date suffix). The bare `haiku` alias is refused because it is not a version.
# - `mechanical_share:` of 90 or more: the share of the agent's work that is
#   mechanical (lookups, inventories, structural checks), declared so a reviewer
#   can challenge it.
# - `haiku_replay:` naming a file in this repository that records a replay on
#   known-answer inputs showing no loss against the base tier.
# - No judgment work in its name or description: never review, audit,
#   research, security, debugging, diagnosis, planning or design.
HAIKU_MINIMUM_VERSION = (5, 5)
HAIKU_PIN = re.compile(r"claude-haiku-(\d+)-(\d+)(?:-\d{8})?")
HAIKU_MECHANICAL_FIELD = "mechanical_share"
HAIKU_MINIMUM_MECHANICAL_SHARE = 90
HAIKU_REPLAY_FIELD = "haiku_replay"
HAIKU_JUDGMENT_TERMS = re.compile(
    r"\b(review|audit|research|secur|debug|diagnos|plan|design|architect|judg|verdict)",
    re.IGNORECASE,
)

# Where an elevated pin must record why it is elevated.
ELEVATION_RATIONALE_FIELD = "model_rationale"

# The Muse Spark workflow: dummy work on muse-spark-1.3 at medium effort.
#
# AGENTS.md routes dummy work to this saved workflow, so the route is part
# of the tier invariant: a workflow that drifts back to low effort, loses
# its read-only contract, or loses the replay that qualifies it fails here
# rather than silently spending or misrouting. A tree with neither the
# workflow nor the AGENTS.md route has not adopted Spark and passes, the
# same bootstrap rule as having no agent definitions yet.
SPARK_WORKFLOW = Path(".agents") / "workflows" / "spark.js"
SPARK_REPLAY = Path("docs") / "replays" / "2026-11-09-spark-replay.md"
SPARK_MODEL_PIN = "muse-spark-1.3"
SPARK_EFFORT_PIN = "medium"

# Tools no subagent on any tier is given. A `*` grant includes them, and so
# does a missing `tools:` list, because the agent then inherits every tool.
EDIT_TOOLS = ["edit", "write", "multiedit", "notebookedit"]


def read_agent_frontmatter(text):
    """Read the opening frontmatter as a strict, closed subset of YAML.

    Three review rounds on 2026-09-15 each found another way a regex over this
    block reads a value that is not the value: a body line outside the
    frontmatter, a trailing `# comment`, a comment inside quotes, an alias
    (`model: *sonnet` resolving to a Haiku anchor), a `model:` line inside a
    multi-line quoted scalar, a duplicate key read from the wrong end, and a
    block scalar whose indentation indicator makes its only line empty.
    Chasing them one at a time is how this file got to three rounds.

    So the reader models a deliberately small language and REFUSES everything
    else. An agent definition's frontmatter is a handful of flat scalar keys;
    a file using anchors, flow collections, tags or multi-line quoting is
    refused as unreadable rather than guessed at. Failing closed on an exotic
    definition costs whoever wrote it one plain rewrite. Failing open costs a
    run on the wrong tier, silently, for as long as nobody looks.

    Returns (fields, error): `error` is set when the block cannot be read
    under these rules, and `fields` maps key to {"value", "is_quoted"}.
    """
    match = re.match(r"^---[ \t]*\r?\n([\s\S]*?)\r?\n---[ \t]*(?:\r?\n|$)", text)
    if not match:
        return None, (
            "has no opening frontmatter block; the tier pin must be a "
            "machine-read field, not prose"
        )

    lines = match.group(1).splitlines()
    fields = {}
    index = 0

    while index < len(lines):
        line = lines[index]
        index += 1
        if line.strip() == "" or re.match(r"^[ \t]*#", line):
            continue

        # YAML needs whitespace after the colon in a block mapping:
        # `model:sonnet` is the plain scalar "model:sonnet", not a pin, and
        # reading it as one let a definition with no model field through.
        entry = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):(?:[ \t]+([^\r\n]*?))?[ \t]*$", line)
        if not entry:
            return None, (
                f"frontmatter line {line!r} is not a plain \"key: value\" pair; "
                "agent frontmatter is read as a closed subset of YAML and "
                "anything else is refused rather than guessed"
            )

        key = entry.group(1)
        rest = entry.group(2) or ""
        if key in fields:
            # This reader takes the first, a YAML parser takes the last.
            # Refuse the ambiguity rather than pick a winner: `model: sonnet`
            # above `model: claude-haiku-4-5` read as Sonnet and ran as Haiku.
            return None, (
                f'declares "{key}:" more than once; a duplicate key is read '
                "from opposite ends by this check and by YAML"
            )

        # A comment after the value is ordinary YAML, and rejecting it would
        # fail correct definitions. It is stripped here, outside the quoted
        # region, so `model: "sonnet # haiku"` still keeps its hash as content.
        quoted_with_comment = re.match(r'^((["\'])(?:[^\\]|\\.)*?\2)[ \t]+#[^\r\n]*$', rest)
        scalar_with_comment = re.match(r"^([|>][-+0-9]*)[ \t]+#[^\r\n]*$", rest)
        if quoted_with_comment:
            value = quoted_with_comment.group(1)
        elif scalar_with_comment:
            value = scalar_with_comment.group(1)
        else:
            value = rest

        if re.match(r"^[|>]$", value):
            # A bare block scalar only. An indentation indicator (`|2`)
            # changes what counts as content, and this reader does not model
            # that.
            collected = []
            while index < len(lines) and (
                lines[index].strip() == "" or re.match(r"^[ \t]", lines[index])
            ):
                collected.append(lines[index].strip())
                index += 1
            fields[key] = {
                "value": " ".join(part for part in collected if part),
                "is_quoted": True,
            }
            continue

        if re.match(r"^[|>]", value):
            return None, (
                f'"{key}:" uses a block scalar indicator ({value!r}); write '
                "the value plainly so this check and YAML agree on where it ends"
            )

        quoted = re.match(r'^([\'"])((?:[^\\]|\\.)*?)\1[ \t]*$', value)
        if quoted:
            if "\\" in quoted.group(2):
                return None, (
                    f'"{key}:" contains a backslash escape; this check does '
                    "not decode escapes, so write the value plainly"
                )
            fields[key] = {"value": quoted.group(2).strip(), "is_quoted": True}
            continue

        if re.match(r'^["\']', value):
            return None, (
                f'"{key}:" opens a quote that does not close on the same line; '
                "a multi-line quoted scalar can hide another key inside it"
            )

        plain = re.sub(r"(?:^|[ \t])#.*$", "", value).strip()
        if re.match(r"^[&*!]", plain) or re.match(r"^[\[{]", plain):
            kind = (
                "flow collection"
                if plain.startswith("[") or plain.startswith("{")
                else "anchor, alias or tag"
            )
            return None, (
                f'"{key}:" uses YAML {kind} syntax ({plain!r}); write the '
                "value plainly, because an alias resolves to something this "
                "check cannot see"
            )
        fields[key] = {"value": plain, "is_quoted": False}

    return fields, None


def tier_pin(fields, field):
    """A tier pin: one bare token, optionally quoted, and nothing else."""
    entry = fields.get(field)
    if not entry or entry["value"] == "":
        return None
    return entry["value"] if re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", entry["value"]) else None


def recorded_prose(fields, field):
    """A recorded justification: prose that survives unquoting and trimming.

    An unquoted `null` or `~` is YAML's way of writing nothing, so it records
    nothing. Quoted, it is a word someone chose to write, and stays content.
    """
    entry = fields.get(field)
    if not entry:
        return None
    value = entry["value"].strip()
    if value == "":
        return None
    if not entry["is_quoted"] and re.fullmatch(r"null|Null|NULL|~", value):
        return None
    return value


def tool_problems(fields):
    """A subagent reads and runs; the main loop writes.

    A grant such as `Edit(src/**)` is still Edit, so the rule spec after
    the name is ignored.
    """
    tools = recorded_prose(fields, "tools")
    if not tools:
        return [
            'needs an explicit "tools:" list; without one the agent inherits '
            "every tool, edit tools included"
        ]
    names = [
        re.sub(r"\(.*$", "", tool).strip().lower() for tool in tools.split(",")
    ]
    if any(tool == "*" or tool in EDIT_TOOLS for tool in names):
        return [
            "grants edit tools (Edit, Write, MultiEdit, NotebookEdit or *); "
            "subagents read and run, and the main loop writes"
        ]
    return []


def haiku_problems(repo_root, fields, model):
    """Every unmet Haiku condition, so one run names them all."""
    problems = []
    pin = HAIKU_PIN.fullmatch(model)
    min_major, min_minor = HAIKU_MINIMUM_VERSION
    if (
        not pin
        or int(pin.group(1)) < min_major
        or (int(pin.group(1)) == min_major and int(pin.group(2)) < min_minor)
    ):
        problems.append(
            "Haiku must be an exact pin of claude-haiku-5-5 or later, never "
            "the bare alias or an older version"
        )

    share = recorded_prose(fields, HAIKU_MECHANICAL_FIELD)
    if (
        not share
        or not re.fullmatch(r"\d{1,3}", share)
        or int(share) < HAIKU_MINIMUM_MECHANICAL_SHARE
        or int(share) > 100
    ):
        problems.append(
            f'Haiku needs "{HAIKU_MECHANICAL_FIELD}:" as a whole percentage '
            f"from {HAIKU_MINIMUM_MECHANICAL_SHARE} to 100; Haiku is only "
            "for near-mechanical work"
        )

    replay = recorded_prose(fields, HAIKU_REPLAY_FIELD)
    replay_path = os.path.normpath(replay) if replay else None
    inside = (
        replay_path
        and not os.path.isabs(replay_path)
        and replay_path != ".."
        and not replay_path.startswith(".." + os.sep)
    )
    if (
        not inside
        or not (Path(repo_root) / replay_path).is_file()
    ):
        problems.append(
            f'Haiku needs "{HAIKU_REPLAY_FIELD}:" naming a file in this '
            "repository that records a known-answer replay showing no loss "
            "against the base tier"
        )

    purpose = (
        f"{recorded_prose(fields, 'name') or ''} "
        f"{recorded_prose(fields, 'description') or ''}"
    )
    judgment = HAIKU_JUDGMENT_TERMS.search(purpose)
    if judgment:
        problems.append(
            f"Haiku never does judgment work, and this agent's name or "
            f'description says "{judgment.group(0)}"; review, audit, '
            "research, security, debugging, diagnosis, planning and design "
            "stay on Sonnet or above"
        )
    return problems


def spark_problems(repo_root):
    """Every way the Spark route in AGENTS.md and spark.js disagree."""
    repo_root = Path(repo_root)
    workflow_path = repo_root / SPARK_WORKFLOW
    agents_path = repo_root / "AGENTS.md"
    route_declared = (
        agents_path.is_file()
        and ".agents/workflows/spark.js" in agents_path.read_text(encoding="utf-8")
    )
    if not workflow_path.is_file():
        if route_declared:
            return [
                f"{SPARK_WORKFLOW} is routed to by AGENTS.md but does not exist"
            ]
        return []

    problems = []
    text = workflow_path.read_text(encoding="utf-8")
    if not re.search(
        rf'SPARK_MODEL\s*=\s*"{re.escape(SPARK_MODEL_PIN)}"', text
    ):
        problems.append(
            f'{SPARK_WORKFLOW} must pin SPARK_MODEL = "{SPARK_MODEL_PIN}"'
        )
    if not re.search(
        rf'SPARK_EFFORT\s*=\s*"{SPARK_EFFORT_PIN}"', text
    ) or not re.search(r"effort:\s*SPARK_EFFORT", text):
        problems.append(
            f"{SPARK_WORKFLOW} must run at medium effort through "
            "SPARK_EFFORT; dummy work on Spark is a medium-effort route, "
            "not low"
        )
    if re.search(r'effort:\s*"low"', text):
        problems.append(
            f'{SPARK_WORKFLOW} still carries an effort: "low" call; Spark '
            "runs at medium"
        )
    if "never edit" not in text.lower():
        problems.append(
            f"{SPARK_WORKFLOW} lost its read-only contract (never edit, "
            "create, move, or delete a file)"
        )
    if not re.search(r"\bisJudgmentBrief\b", text):
        problems.append(
            f"{SPARK_WORKFLOW} lost its judgment screen (isJudgmentBrief): "
            "a brief that needs choosing, assessing, or deciding what is "
            "relevant must be refused before any agent spawns"
        )
    if not re.search(r"\bisCitedSource\b", text):
        problems.append(
            f"{SPARK_WORKFLOW} lost its cited-source check (isCitedSource): "
            "evidence without a file:line or command: source must be "
            "dropped before it reaches the lead"
        )
    replay_path = repo_root / SPARK_REPLAY
    if not replay_path.is_file():
        problems.append(
            f"Spark needs {SPARK_REPLAY} recording a known-answer replay "
            "at medium effort showing no loss"
        )
    elif SPARK_EFFORT_PIN not in replay_path.read_text(encoding="utf-8").lower():
        problems.append(
            f"{SPARK_REPLAY} does not record a medium-effort replay; the "
            "qualifying replay must match the pinned effort"
        )
    return problems


def verify_agent_tiers(repo_root=None, relative_root=None):
    if repo_root is None:
        repo_root = Path.cwd()
    else:
        repo_root = Path(repo_root)
    if relative_root is None:
        relative_root = Path(".claude") / "agents"
    errors = []
    absolute_root = repo_root / relative_root
    if not absolute_root.exists():
        spark_errors = spark_problems(repo_root)
        errors.extend(spark_errors)
        return {
            "checked": 0,
            "elevated": 0,
            "haiku": 0,
            "spark": 1 if (repo_root / SPARK_WORKFLOW).is_file() and not spark_errors else 0,
            "errors": errors,
        }

    files = sorted(
        entry.name
        for entry in absolute_root.iterdir()
        if entry.is_file() and entry.name.endswith(".md")
    )

    elevated = 0
    haiku = 0
    for name in files:
        relative = Path(relative_root) / name
        text = (absolute_root / name).read_text(encoding="utf-8")
        fields, error = read_agent_frontmatter(text)

        if error:
            errors.append(f"{relative} {error}")
            continue

        errors.extend(
            f"{relative} {problem}" for problem in tool_problems(fields)
        )

        model_entry = tier_pin(fields, "model")
        model = model_entry.lower() if model_entry else None

        if not model:
            errors.append(
                f'{relative} must declare an explicit "model:" field in its '
                "frontmatter carrying one bare tier token; an unpinned or "
                "unparseable pin inherits the caller's model"
            )
            continue

        if any(token in model for token in RESTRICTED_AGENT_MODEL_TOKENS):
            problems = haiku_problems(repo_root, fields, model)
            if problems:
                errors.extend(
                    f'{relative} pins "{model}": {problem}'
                    for problem in problems
                )
            else:
                haiku += 1
            continue

        is_base = any(token in model for token in BASE_AGENT_MODEL_TOKENS)
        is_elevated = any(
            token in model for token in ELEVATED_AGENT_MODEL_TOKENS
        )
        if not is_base and not is_elevated:
            errors.append(
                f'{relative} pins unrecognized tier "{model}"; use the base '
                "tier, or an elevated tier with a recorded rationale"
            )
            continue

        if is_elevated:
            elevated += 1
            # An elevated pin has to be argued for. Without this the
            # expensive tier becomes the path of least resistance and
            # drifts upward silently.
            if not recorded_prose(fields, ELEVATION_RATIONALE_FIELD):
                errors.append(
                    f'{relative} pins the elevated tier "{model}" without a '
                    f'non-empty "{ELEVATION_RATIONALE_FIELD}:" field; an '
                    "elevated agent must be a deliberate decision, not a "
                    "default that drifted"
                )

    spark_errors = spark_problems(repo_root)
    errors.extend(spark_errors)
    return {
        "checked": len(files),
        "elevated": elevated,
        "haiku": haiku,
        "spark": 1 if (repo_root / SPARK_WORKFLOW).is_file() and not spark_errors else 0,
        "errors": errors,
    }


def _agent(name, model_line, extra="", tools="Read, Grep"):
    return (
        f"---\nname: {name}\ndescription: bounded lookup work\n"
        f"{model_line}\ntools: {tools}\n{extra}---\n\nBody.\n"
    )


def self_test():
    cases = []

    def case(label, files, expect_errors, replay_file=False):
        cases.append((label, files, expect_errors, replay_file))

    case("base sonnet passes",
         {"a.md": _agent("a", "model: sonnet")}, 0)
    case("missing model refused",
         {"a.md": _agent("a", "effort: high")}, 1)
    case("edit tool refused",
         {"a.md": _agent("a", "model: sonnet", tools="Read, Edit")}, 1)
    case("wildcard tools refused",
         {"a.md": _agent("a", "model: sonnet", tools="*")}, 1)
    case("missing tools refused",
         {"a.md": "---\nname: a\ndescription: x\nmodel: sonnet\n---\n"}, 1)
    case("elevated without rationale refused",
         {"a.md": _agent("a", "model: opus")}, 1)
    case("elevated with rationale passes",
         {"a.md": _agent("a", "model: opus",
                         extra="model_rationale: verdict quality\n")}, 0)
    case("duplicate key refused",
         {"a.md": _agent("a", "model: sonnet\nmodel: opus")}, 1)
    case("no-space colon is not a pin",
         {"a.md": _agent("a", "model:sonnet")}, 1)
    case("haiku alias refused",
         {"a.md": _agent("a", "model: haiku")}, 1)
    case("haiku old version refused",
         {"a.md": _agent("a", "model: claude-haiku-4-5",
                         extra="mechanical_share: 95\nhaiku_replay: replay.md\n")},
         1, replay_file=True)
    case("haiku compliant passes",
         {"a.md": _agent("inventory", "model: claude-haiku-5-5",
                         extra="mechanical_share: 95\nhaiku_replay: replay.md\n")},
         0, replay_file=True)
    case("haiku judgment work refused",
         {"a.md": _agent("reviewer", "model: claude-haiku-5-5",
                         extra="mechanical_share: 95\nhaiku_replay: replay.md\n")},
         1, replay_file=True)
    case("quoted hash stays content",
         {"a.md": _agent("a", 'model: "sonnet # haiku"')}, 1)
    case("no agents passes empty", {}, 0)

    spark_good = (
        'const SPARK_MODEL = "muse-spark-1.3";\n'
        'const SPARK_EFFORT = "medium";\n'
        "effort: SPARK_EFFORT,\n"
        "// Read and run only: never edit, create, move, or delete a file.\n"
        "function isJudgmentBrief(input) { return false; }\n"
        "function isCitedSource(source) { return true; }\n"
    )
    spark_cases = []

    def spark_case(label, workflow_text, expect_errors, route=False, replay=None):
        spark_cases.append((label, workflow_text, expect_errors, route, replay))

    spark_case("spark medium passes", spark_good, 0,
               replay="medium effort replay, no loss\n")
    spark_case("spark low refused",
               spark_good.replace('"medium"', '"low"'), 1,
               replay="medium effort replay, no loss\n")
    spark_case("spark missing replay refused", spark_good, 1)
    spark_case("spark without judgment screen refused",
               spark_good.replace("isJudgmentBrief", "isScreened"), 1,
               replay="medium effort replay, no loss\n")
    spark_case("spark without cited-source check refused",
               spark_good.replace("isCitedSource", "isChecked"), 1,
               replay="medium effort replay, no loss\n")
    spark_case("spark route without workflow refused", None, 1, route=True)
    spark_case("spark not adopted passes", None, 0)

    failures = []
    for label, files, expect_errors, replay_file in cases:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            agents = root / ".claude" / "agents"
            agents.mkdir(parents=True)
            for name, text in files.items():
                (agents / name).write_text(text, encoding="utf-8")
            if replay_file:
                (root / "replay.md").write_text("replay record\n", encoding="utf-8")
            result = verify_agent_tiers(root)
            got = len(result["errors"])
            if (expect_errors == 0) != (got == 0) or (
                expect_errors > 0 and got == 0
            ):
                failures.append(
                    f"{label}: expected {'errors' if expect_errors else 'clean'}, "
                    f"got {got}: {result['errors']}"
                )
    total_cases = len(cases) + len(spark_cases)
    for label, workflow_text, expect_errors, route, replay in spark_cases:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            if workflow_text is not None:
                workflow = root / SPARK_WORKFLOW
                workflow.parent.mkdir(parents=True)
                workflow.write_text(workflow_text, encoding="utf-8")
            if route:
                (root / "AGENTS.md").write_text(
                    "route: .agents/workflows/spark.js\n", encoding="utf-8"
                )
            if replay is not None:
                replay_file = root / SPARK_REPLAY
                replay_file.parent.mkdir(parents=True)
                replay_file.write_text(replay, encoding="utf-8")
            got_errors = spark_problems(root)
            if (expect_errors == 0) != (len(got_errors) == 0):
                failures.append(
                    f"{label}: expected {'errors' if expect_errors else 'clean'}, "
                    f"got {len(got_errors)}: {got_errors}"
                )
    if failures:
        sys.stderr.write(
            "verify-agent-tiers self-test FAILED:\n"
            + "".join(f"  - {line}\n" for line in failures)
        )
        return 1
    sys.stdout.write(
        f"verify-agent-tiers self-test: {total_cases} cases, 0 failed\n"
    )
    return 0


def main(argv):
    if argv == ["--self-test"]:
        return self_test()
    if argv:
        sys.stderr.write("usage: verify-agent-tiers.py [--self-test]\n")
        return 2
    result = verify_agent_tiers()
    if result["errors"]:
        sys.stderr.write(
            "Agent tier invariant failed:\n"
            + "".join(f"  - {line}\n" for line in result["errors"])
        )
        return 1
    sys.stdout.write(
        f"Agent tiers valid: {result['checked']} definition(s) checked, "
        f"{result['elevated']} elevated with a recorded rationale, "
        f"{result['haiku']} on Haiku under the mechanical-work allowance, "
        f"{result['spark']} Spark workflow(s) at medium effort.\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

