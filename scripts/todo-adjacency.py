#!/usr/bin/env python3
"""Advisory feature ownership from TODO declarations and implementing bodies.

This is a source matcher, not proof that a business feature works. Semantic
warnings stay outside the structural validator's ratchet (D00 T03 section 19).
Only an explicit closeout/conformance request turns them into a refusal.
"""
from __future__ import annotations

import argparse
from contextlib import contextmanager
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile
import tempfile

KINDS = ("list", "document", "settings", "reporting", "notifications", "permissions", "audit", "exchange", "reverse")
KEYWORDS = {
    "list": r"\b(?:list|lists|board|queue|search|browse|lookup|dashboard|filters?|paging|last run|next run|status page|catalogue)\b",
    "document": r"\b(?:pdf|print(?:able|ing)?|documents?|attachments?|preview|signature|photo)\b",
    "settings": r"\b(?:settings?|config(?:uration|ured)?|tunable|thresholds?|retention|routing|factors?|multipliers?|schedules?)\b|(?<![a-z])Settings(?:Registry|Catalog)?\b",
    "reporting": r"\b(?:reports?|reporting|dashboards?|variance|reconciliation|analytics|summary)\b",
    "notifications": r"\b(?:notifications?|notify|mail|email|whatsapp|alerts?|recipients?)\b",
    "permissions": r"\b(?:permissions?|403|forbidden|authori[sz]\w*|polic(?:y|ies)|guests?|roles?)\b",
    "audit": r"\b(?:audit\w*|history|timeline|actor|per.run record|immutable log)\b",
    "exchange": r"\b(?:imports?|exports?|upload\w*|download\w*|ingest\w*|artifact delivery|file transfer)\b",
    "reverse": r"\b(?:cancel\w*|reopen\w*|void|delet\w*|prun\w*|undo|rollback|revo[ck]\w*|deactivat\w*|withdraw|restor\w*|retry|revers\w*)\b",
}
CAPABILITY = {key: re.compile(value, re.I) for key, value in KEYWORDS.items()}
HEADING = re.compile(r"^##\s+(\d+)\.\s+(.+)$")
REFERENCE = re.compile(r"(?:D(?P<dom>\d{2})\s+)?(?:T(?P<todo>\d{2})\s+)?§(?P<section>\d+)")
EXACT_REFERENCE = re.compile(r"D\d{2}\s+T\d{2}\s+§\d+")
DECLARATION = re.compile(r"^\*\*Adjacency(?::\*\*|\*\*.*?:)\s*(.*)$")
ACTION = re.compile(r"\b(?:add|build|implement|repair|resolve|reuse|validate|persist|expose|attach|support|retain|store|route|emit|return|renders?|generates?|creates?|save|edit|update|show|display|lists?|search|filter|view|open|read|write|records?|audit|log|notify|sends?|deliver|export|import|upload|download|register|enforce|refuse|deny|allow|scope|grant|seed(?:ed)?|configure|consume|apply|compare|reconcile|report|cancel|reopen|delete|prune|retry|restore|revoke|set|select|choose|uses?|runs?|prints?|opens?|sees|can|produces?|receives?|completes?)\b", re.I)


class InspectionError(ValueError):
    pass


def split_entries(value):
    entries, start, depth = [], 0, 0
    for index, char in enumerate(value):
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth < 0:
                raise InspectionError("unbalanced declaration parentheses")
        elif char == ";" and depth == 0:
            entries.append(value[start:index].strip())
            start = index + 1
    if depth:
        raise InspectionError("unbalanced declaration parentheses")
    entries.append(value[start:].strip())
    return entries


def parse_declaration(lines):
    """Never convert missing, legacy, or malformed prose into an NA decision."""
    in_outcome, fence = False, False
    found, misplaced = [], []
    for number, line in enumerate(lines, 1):
        if line.lstrip().startswith(("```", "~~~")):
            fence = not fence
            continue
        if fence:
            continue
        if line.startswith("## "):
            in_outcome = line.strip() == "## Outcome"
        match = DECLARATION.match(line)
        if match:
            (found if in_outcome else misplaced).append((number, match.group(1)))
    states = {key: {"status": "undeclared"} for key in KINDS}
    errors = []
    if len(found) != 1:
        errors.append("missing Outcome declaration" if not found else "duplicate Outcome declarations")
        if misplaced:
            errors.append("Adjacency declaration outside Outcome")
        return states, errors, found[0][0] if found else 0
    number, value = found[0]
    try:
        entries = split_entries(value)
    except InspectionError as error:
        return states, [str(error)], number
    if len(entries) == 1 and entries[0].startswith("all="):
        match = re.fullmatch(r"all=not-applicable\s*\((.+)\)", entries[0])
        if not match or not match.group(1).strip():
            return states, ["blanket NA requires a nonempty scope reason"], number
        return {key: {"status": "not-applicable", "reason": match.group(1).strip()} for key in KINDS}, [], number
    seen = set()
    for entry in entries:
        match = re.fullmatch(r"([a-z-]+)=(.*)", entry)
        if not match:
            errors.append("malformed/legacy declaration entry: use key=applicable or key=not-applicable (reason)")
            continue
        key, disposition = match.groups()
        if key not in KINDS:
            errors.append("unknown declaration key: " + key)
            continue
        if key in seen:
            errors.append("duplicate/contradictory declaration key: " + key)
            states[key] = {"status": "undeclared"}
            continue
        seen.add(key)
        if disposition == "applicable":
            states[key] = {"status": "applicable"}
        elif disposition.startswith("applicable @ ") and EXACT_REFERENCE.fullmatch(disposition[13:].strip()):
            states[key] = {"status": "applicable", "reference": disposition[13:].strip()}
        else:
            na = re.fullmatch(r"not-applicable\s*\((.+)\)", disposition)
            if na and na.group(1).strip():
                states[key] = {"status": "not-applicable", "reason": na.group(1).strip()}
            else:
                errors.append("invalid disposition or missing NA reason: " + key)
    for key in KINDS:
        if states[key]["status"] == "undeclared":
            errors.append("undeclared kind: " + key)
    if misplaced:
        errors.append("Adjacency declaration outside Outcome")
    return states, errors, number


def positive_clauses(body):
    """Keep implementing clauses; evidence, examples and negation are not owners."""
    fence = False
    for number, original in body:
        stripped = original.strip()
        if stripped.startswith(("```", "~~~")):
            fence = not fence
            continue
        if fence or not stripped or stripped.startswith((">", "<!--", "|", "##", "-> XREF:")):
            continue
        if re.match(r"(?:- \[[ x/]\]\s*)?(?:Commit:|\*\*Commit:)", stripped, re.I):
            continue
        if stripped.startswith("**") and not re.match(r"\*\*(?:Job|Build order|Outcome|Deliverable):", stripped):
            continue
        clean = re.split(r"Cheaper substitute|Would have caught|Source:|Found \d{4}-|-> XREF:", stripped, flags=re.I)[0]
        clean = re.sub(r"`[^`]*\.(?:md|json|txt|csv)`", "", clean)
        clean = re.sub(r'"[^"\n]*"|“[^”\n]*”|\u2018[^\u2019\n]*\u2019', "", clean)
        clean = re.sub(r"^(?:- \[[ x/]\]|\d+\.)\s*", "", clean).replace("**", "")
        if re.match(r"(?:inventory|probe|measure|assuming|document\b|migration\b|schema\b|additive tables|create (?:a )?table|add (?:a )?test|test\b|cover\b|assert\b)", clean, re.I):
            continue
        for clause in re.split(r";|(?<=[.!?])\s+(?=[A-Z])", clean):
            clause = clause.strip()
            if not clause or re.match(r"(?:no\b|not\b|never\b|do not\b|must not\b|without\b|e\.g\.)", clause, re.I):
                continue
            # A negative tail must not lend its capability word to a positive action.
            clause = re.split(r"\b(?:rather than|instead of|without|do not|does not|never|not|no separate|no new)\b", clause, flags=re.I)[0].strip()
            if ACTION.search(clause):
                yield number, clause


def bodies(lines, todo):
    result, current, chunk, fence = {}, None, [], False
    for number, line in enumerate(lines, 1):
        if line.lstrip().startswith(("```", "~~~")):
            fence = not fence
        if not fence and line.startswith("## "):
            if current is not None:
                result[current] = chunk
            match = HEADING.match(line)
            current = int(match.group(1)) if match else None
            chunk = []
        elif current is not None:
            chunk.append((number, line))
    if current is not None:
        result[current] = chunk
    eligible = {}
    for num, body in result.items():
        section = todo.sections.get(num)
        if not section or not section.has_row or not section.has_body or section.moved or todo.status == "superseded":
            continue
        if re.match(r"(?:inventory|source inventory|measure|probe)\b", section.title, re.I):
            continue
        eligible[num] = list(positive_clauses(body))
    return eligible


def resolve(reference, origin, todos):
    """Unique file/domain and actual section, not just a syntactically valid ref."""
    match = REFERENCE.fullmatch(reference.strip())
    if not match:
        return None
    domain = match.group("dom")
    number = match.group("todo") or origin.number
    candidates = [t for t in todos if t.number == number and
                  (t.domain.startswith(domain + "-") if domain else t.domain == origin.domain)]
    if len(candidates) != 1:
        return None
    target = candidates[0]
    section = target.sections.get(int(match.group("section")))
    if not section or not section.has_row or not section.has_body or section.moved or target.status == "superseded":
        return None
    return target, section.num


def ref(todo, number):
    return f"D{todo.domain[:2]} T{todo.number} §{number}"


def owners(kind, todo, catalog, explicit=None):
    selected = [(todo, num) for num in catalog[todo.path]["bodies"]]
    if explicit:
        selected = [explicit]
    matches = []
    for target, num in selected:
        for line, clause in catalog[target.path]["bodies"].get(num, []):
            matches_kind = CAPABILITY[kind].search(clause)
            if kind == "document":
                matches_kind = matches_kind and (re.search(r"\b(?:pdf|print\w*|preview|signature|photo|attachment)\b", clause, re.I) or
                                                (re.search(r"\bdocuments?\b", clause, re.I) and re.search(r"\b(?:render\w*|download\w*|upload\w*|display|template|layout)\b", clause, re.I)))
            if matches_kind:
                matches.append({"ref": ref(target, num), "file": target.path, "line": line, "evidence": clause[:220]})
                break
    return matches


def stated_steps(todo, catalog, todos):
    """Bounded source hints, separate from declared nine-kind applicability."""
    lines = catalog[todo.path]["lines"]
    requirements = []
    generated_output = any(re.search(r"\b(?:zip|artifact|extract|file|output|sftp)\b", line, re.I) for line in lines)
    for number, line in enumerate(lines, 1):
        if HEADING.match(line):
            break
        if re.search(r"Industry default", line, re.I) and re.search(r"→|->", line):
            flow = re.sub(r"^.*?Industry default[^:]*:\s*", "", line).replace("**", "")
            for step in re.split(r"→|->", flow):
                step = re.split(r"\.(?:\s|$)", step)[0].strip(" >.*")
                if step:
                    requirements.append((number, step, "flow"))
    for number, line in enumerate(lines, 1):
        # A sink/destination hint only applies to generated artifacts, not e.g. a warehouse destination.
        if re.match(r"\s*(?:\d+\.\s+|- \[[ x/]\]\s+)?(?:inventory|measure|probe)\b", line, re.I):
            continue
        if generated_output and re.search(r"\b(?:sink|destination)\b", line, re.I) and (re.search(r"\b(?:zip|artifact|extract|file|output|sftp)\b", line, re.I) or re.search(r"`sink`|`destination`", line)):
            requirements.append((number, "artifact delivery", "delivery"))
            break
    connected = {(todo.path, num): (todo, num) for num in catalog[todo.path]["bodies"]}
    for reference in todo.xrefs:
        resolved = resolve(reference, todo, todos)
        if resolved:
            connected[(resolved[0].path, resolved[1])] = resolved
    results = []
    for number, phrase, kind in requirements:
        found = []
        short = re.split(r"\b(?:from|to|against)\b", phrase, maxsplit=1, flags=re.I)[0]
        alternatives = [re.findall(r"[a-z0-9]+", part.lower()) for part in short.split("/")]
        alternatives = [[w for w in words if w not in {"inbound", "the", "a", "and"}] for words in alternatives]
        for target, sec in connected.values():
            clauses = catalog[target.path]["bodies"].get(sec, [])
            combined = " ".join(clause for _, clause in clauses).lower().replace("-", " ")
            if kind == "delivery":
                match = re.search(r"\b(?:upload\w*|deliver\w*|send\w*|transfer\w*)\b", combined) and re.search(r"\b(?:zip|artifact|file|sink|destination|sftp|collector)\b", combined)
            else:
                match = any(words and all(re.search(r"\b" + re.escape(w) + r"\w*\b", combined) for w in words) for words in alternatives)
            if match:
                found.append(ref(target, sec))
        results.append({"phrase": phrase, "source_line": number, "status": "owned" if found else "stated-step-unowned", "owners": sorted(found)})
    return results


def inspect(graph, todos=None, only=None):
    todos = graph.load_todos() if todos is None else todos
    if not todos:
        raise InspectionError("no TODO files found; cannot establish adjacency coverage")
    catalog, digest = {}, hashlib.sha256()
    for todo in sorted(todos, key=lambda t: t.path):
        path = Path(todo.path)
        path = path if path.is_absolute() else graph.REPO / path
        if path.is_symlink() or not path.resolve().is_relative_to(graph.TODO_DIR.resolve()):
            raise InspectionError("TODO source is outside the inspected tree or is a symlink")
        data = path.read_bytes()
        lines = data.decode("utf-8").splitlines()
        digest.update(todo.path.encode() + b"\0" + data + b"\0")
        catalog[todo.path] = {"lines": lines, "bodies": bodies(lines, todo)}
    if only and only not in catalog:
        raise InspectionError("selected TODO does not exist in inspected graph: " + only)
    results, diagnostics = [], []
    counts = {kind: {"applicable": 0, "not_applicable": 0, "undeclared": 0, "owned": 0, "unowned": 0} for kind in KINDS}
    for todo in sorted(todos, key=lambda t: t.path):
        if only and todo.path != only:
            continue
        states, errors, line = parse_declaration(catalog[todo.path]["lines"])
        for error in errors:
            diagnostics.append({"file": todo.path, "line": line, "code": "declaration", "message": error})
        for kind, state in states.items():
            status = state["status"]
            counts[kind][status.replace("-", "_")] += 1
            if status == "not-applicable":
                continue
            reference = state.get("reference")
            target = resolve(reference, todo, todos) if reference else None
            matches = [] if reference and target is None else owners(kind, todo, catalog, target)
            state["owners"] = matches
            if status == "applicable":
                counts[kind]["owned" if matches else "unowned"] += 1
                if not matches:
                    diagnostics.append({"file": todo.path, "line": line, "code": "unowned", "kind": kind,
                                        "message": "applicable kind has no implementing owner" + (": " + reference if reference else "")})
            elif not matches:
                state["inferred_candidate"] = "no positive owner found; applicability undeclared"
        steps = stated_steps(todo, catalog, todos)
        for step in steps:
            if step["status"] == "stated-step-unowned":
                diagnostics.append({"file": todo.path, "line": step["source_line"], "code": "stated-step-unowned", "message": step["phrase"]})
        results.append({"file": todo.path, "declaration_line": line, "declaration_errors": errors, "kinds": states, "stated_steps": steps})
    return {"schema_version": 1, "source_digest": digest.hexdigest(), "files": len(results), "counts": counts, "diagnostics": diagnostics, "results": results}


def conformance_errors(result):
    errors = list(result["diagnostics"])
    for kind, count in result["counts"].items():
        if count["owned"] == 0:
            errors.append({"file": "<tree>", "line": 0, "code": "vacuous-kind", "kind": kind, "message": "tree has no applicable owned population"})
    return errors


@contextmanager
def historical(graph, revision):
    root = graph.REPO
    sha = subprocess.check_output(["git", "-C", str(root), "rev-parse", "--verify", "--end-of-options", revision + "^{commit}"], text=True, stderr=subprocess.PIPE, timeout=30).strip()
    old_root, old_todo = graph.REPO, graph.TODO_DIR
    with tempfile.TemporaryDirectory(prefix="todo-adjacency-history-") as directory:
        archive_path = Path(directory) / "source.tar"
        with archive_path.open("wb") as output:
            subprocess.run(["git", "-C", str(root), "archive", sha, "--", "todo"], stdout=output, stderr=subprocess.PIPE, timeout=30, check=True)
        with tarfile.open(archive_path) as archive:
            archive.extractall(directory, filter="data")
        graph.REPO, graph.TODO_DIR = Path(directory), Path(directory) / "todo"
        try:
            yield sha
        finally:
            graph.REPO, graph.TODO_DIR = old_root, old_todo


def cli(graph, args):
    try:
        if args.file and args.require_conformance:
            raise InspectionError("--require-conformance checks the whole tree; use --require-owned for --file")
        if args.file and (Path(args.file).is_absolute() or ".." in Path(args.file).parts):
            raise InspectionError("--file must be an exact repository-relative TODO path")
        if args.at:
            with historical(graph, args.at) as sha:
                result = inspect(graph, only=args.file)
            result["source_revision"] = sha
        else:
            result = inspect(graph, only=args.file)
            result["source_revision"] = "WORKTREE"
        if args.require_conformance:
            result["diagnostics"] = conformance_errors(result)
        if args.json:
            print(json.dumps(result, indent=2, ensure_ascii=False))
        else:
            for row in result["results"]:
                print(row["file"])
                for kind, state in row["kinds"].items():
                    suffix = ", ".join(o["ref"] for o in state.get("owners", [])) or state.get("reason", "no owner found")
                    print(f"  {kind}: {state['status']} | {suffix}")
            for issue in result["diagnostics"]:
                print(f"WARN [adjacency advisory] {issue['file']}:{issue['line']}: {issue.get('kind', issue['code'])}: {issue['message']}")
            print(f"{result['files']} files; {len(result['diagnostics'])} advisory diagnostics")
        return 1 if (args.require_owned or args.require_conformance) and result["diagnostics"] else 0
    except (OSError, ValueError, subprocess.SubprocessError, tarfile.TarError) as error:
        print("adjacency inspection error: " + str(error), file=sys.stderr)
        return 2


def load_graph():
    spec = importlib.util.spec_from_file_location("adjacency_graph", Path(__file__).with_name("todo-graph.py"))
    graph = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = graph
    bytecode_setting = sys.dont_write_bytecode
    try:
        sys.dont_write_bytecode = True
        spec.loader.exec_module(graph)
    finally:
        sys.dont_write_bytecode = bytecode_setting
    return graph


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--file")
    parser.add_argument("--at")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--require-owned", action="store_true")
    parser.add_argument("--require-conformance", action="store_true")
    raise SystemExit(cli(load_graph(), parser.parse_args()))
