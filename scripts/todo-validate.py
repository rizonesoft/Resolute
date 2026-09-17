"""TODO validation, separated from graph query/projection commands.

The caller supplies its graph module so fixture roots, severity policy and
warning accounting use the same state as query/resolve. No copied constants.
"""
from __future__ import annotations

import importlib.util
from pathlib import Path
import re
import sys


def validate(graph, _args) -> int:
    todos = graph.load_todos()
    fatal: list[str] = []
    warn: list[str] = []

    def flag(cls: str, msg: str) -> None:
        # Route through the map, never straight to a list, so the severity
        # decision lives in exactly one place (D00 T01 §21).
        (fatal if graph.SEVERITY_MAP[cls] == "fatal" else warn).append(msg)
    # Acknowledged history, not live signal (D00 T01 §38): a warning whose own
    # message forbids the fix ("do not reopen the stamp") trains readers to
    # skip the WARN channel. A stamped section's occurrence of the two
    # pre-convention kinds moves here -- queryable via `warnings --acked`,
    # never printed as WARN. The stamped/open distinction is the row's `[x]`
    # plus the Verified stamp, both already parsed; never a ref allowlist.
    # "Pre-convention" is DATE-BOUND PER RULE (terminal integration findings):
    # only a stamp dated on or before the RULE'S OWN cutoff qualifies, so a
    # later stamp carrying the same defect stays in the live channel instead
    # of shipping the gap under a false "pre-convention" label. An undated
    # stamp never acks. The filter rule carries its own landing date
    # (D00 T06 §26, 2026-08-22). The Fidelity cutoff is the operator's §38
    # filing date, NOT the check's code-landing date, deliberately: Fidelity
    # blocks were swept onto already-stamped sections retroactively
    # (D00 T03 §3), so the debt boundary is the day the operator declared the
    # 17 acknowledged, and every one of them is stamped 2026-08-21 or earlier.
    FIDELITY_ACK_CUTOFF = "2026-08-27"
    FILTER_ACK_CUTOFF = "2026-08-22"

    def pre_convention(sec, cutoff: str) -> bool:
        return (
            sec.status == "x"
            and sec.stamped_on is not None
            and sec.stamped_on <= cutoff
        )

    acked: list[str] = []
    # Reset at entry so an early return never leaves `warnings --acked`
    # reading the PREVIOUS run's list through the function attribute
    # (round-2 integration finding: the attribute outlived the run).
    graph.cmd_validate.last_acked = acked  # type: ignore[attr-defined]

    if not todos:
        print("FATAL no TODO files found under todo/; cannot verify the control inventory")
        return 1

    by_id = {}
    by_key = {}
    for t in todos:
        for e in t.fm_errors:
            fatal.append(f"{t.path}: {e}")
        # 1. required fields
        for fld in ("id", "domain", "status", "title"):
            if not getattr(t, fld, None) and fld != "domain":
                fatal.append(f"{t.path}: frontmatter missing required field '{fld}'")
        if t.id and not graph.ID_RE.match(t.id):
            fatal.append(f"{t.path}: id {t.id!r} fails ^[a-z][a-z0-9-]*[a-z0-9]$ (2-60 chars)")
        if t.status and t.status not in graph.STATUSES:
            fatal.append(f"{t.path}: status {t.status!r} not one of {sorted(graph.STATUSES)}")
        # 2. duplicate ids
        if t.id:
            if t.id in by_id:
                fatal.append(f"{t.path}: duplicate id {t.id!r} (also in {by_id[t.id].path})")
            by_id[t.id] = t
        by_key[(t.domain, t.number)] = t
        # 3. frontmatter domain matches directory
        # Parent-directory name, not split("/")[1]: fixture trees live under
        # absolute temp paths where index 1 is "tmp" (§21's warn-only ratchet
        # fixture surfaced it); identical on the live tree.
        fm_domain = Path(t.path).parent.name
        if t.domain and t.domain != fm_domain:
            fatal.append(f"{t.path}: frontmatter domain {t.domain!r} != directory {fm_domain!r}")
        if t.status == "superseded" and not t.superseded_by:
            flag("superseded-no-successor", f"{t.path}: status is 'superseded' but superseded_by is unset")

    for t in todos:
        # 4. Implementation Order rows <-> body sections
        for num, s in sorted(t.sections.items()):
            if s.has_row and not s.has_body:
                fatal.append(f"{t.path}: Implementation Order row §{num} has no '## {num}.' body section")
            if s.has_body and not s.has_row:
                fatal.append(f"{t.path}: '## {num}. {s.title}' has no Implementation Order row")
            if not s.has_body:
                continue
            # 8. every section needs a test checkpoint
            if not s.has_test_checkpoint:
                fatal.append(f"{t.path}:{s.line}: §{num} has no '**Test checkpoint:**'")
            # 8c. a `**Needs:**` value must come from the closed list (D00 T07 §28)
            if s.needs_raw and not s.needs:
                allowed = ", ".join(f"`{k}`" for k in graph.NEEDS_ALLOWED)
                flag(
                    "needs-unknown",
                    f"{t.path}:{s.line}: §{num} has **Needs:** {s.needs_raw!r}, "
                    f"which is not in the closed list ({allowed})",
                )
            # 8b. a `--filter` checkpoint that ALSO claims a second suite stays
            #     green is claiming something the command it names cannot show.
            #
            #     `D00 T06 §26`, 2026-08-22: the checkpoint ran
            #     `pest --filter=RebuildProgress` and then said "LandingCharts
            #     still pass". Measured, that filter selects 11 tests in ONE
            #     file, and no LandingCharts id contains the string -- so the
            #     cheaper substitute the section explicitly forbade (deleting
            #     the shared component instead of removing one include) WOULD
            #     HAVE PASSED the prescribed command. The Codex `plan` lens
            #     caught it before any code was written; nothing else would have.
            #
            #     Warning rather than fatal, deliberately: 150 checkpoints use
            #     `--filter` legitimately, and only the ones ALSO asserting that
            #     something else stays green are making the unfalsifiable claim.
            #     Naming test FILES costs nothing and cannot go stale this way.
            if s.has_test_checkpoint and "--filter" in s.test_checkpoint_text:
                low_cp = s.test_checkpoint_text.lower()
                claims_green = any(
                    claim in low_cp
                    for claim in ("still pass", "still green", "remain green", "stay green")
                )
                # Naming the FILES is the fix, so a checkpoint that names them
                # has already been corrected -- including one whose prose quotes
                # the old `--filter` while explaining the correction. Without
                # this the rule flags its own remedy, which is how a warning
                # teaches people to ignore it.
                names_files = "test.php" in low_cp
                if claims_green and not names_files:
                    fmsg = (
                        f"{t.path}:{s.line}: §{num} has a `--filter` Test checkpoint that "
                        f"also claims another suite stays green. A filter selects the tests "
                        f"whose ID matches it, so that claim is unfalsifiable by the command "
                        f"it names -- name the test FILES instead (D00 T06 §26, 2026-08-22)"
                    )
                    if num in t.verified_sections and pre_convention(s, FILTER_ACK_CUTOFF):
                        acked.append(
                            fmsg + " -- stamped pre-convention: the rule postdates the stamp"
                        )
                    elif s.status == "x" and num in t.verified_sections:
                        flag(
                            "filter-overclaim-stamped",
                            fmsg + " -- stamped AFTER the rule landed: the claim was "
                            "unfalsifiable at stamp time; fix the checkpoint forward",
                        )
                    else:
                        flag("filter-overclaim-open", fmsg)
            # 13. every section ends on a commit item
            if not s.has_commit_item:
                flag("no-commit-item", f"{t.path}:{s.line}: §{num} has no '- [ ] Commit:' checklist item")
            # 14. a CLOSED section must not carry orphaned work.
            #
            # A finding filed as a plain checklist item inside a section that later
            # ships is invisible: the section is done, nobody reopens it, and the
            # item sits unticked forever. Found 2026-08-14 with 21 such items across
            # 8 closed sections, one of them a real review-panel finding.
            #
            # Three shapes are legitimate and are not flagged. A struck item
            # (`~~...~~`) is a decision recorded against, not work owed. A bare
            # `-> XREF:` line is a cross-reference, not a task. A `Commit:` item is
            # bookkeeping the stamp already covers.
            #
            # WARN and not FATAL, deliberately, and the reasoning is D00 T03 §3's:
            # a rule that fails 21 existing items the day it lands gets disabled in
            # its first week and takes the rest of the gate with it. Promote it once
            # the existing ones are re-homed.
            if s.moved:
                moved_path = graph.moved_target(s.moved)
                if not moved_path or not (graph.TODO_DIR.parent / moved_path).is_file():
                    flag(
                        "moved-target-missing",
                        f"{t.path}:{s.line}: §{num} carries a Moved: marker that names no "
                        f"existing file ({s.moved[:80]!r}); the work it points at cannot be found",
                    )
            if s.status == "x":
                orphaned = [
                    txt for done, txt in s.items
                    if not done
                    and not txt.lstrip().startswith("~~")
                    and not txt.lstrip().startswith("->")
                    and not txt.lstrip().lower().startswith("commit:")
                ]
                if orphaned:
                    flag(
                        "orphaned-items-shipped",
                        f"{t.path}:{s.line}: §{num} is [x] but carries {len(orphaned)} "
                        f"unticked item(s) that are neither struck through nor a bare XREF -- "
                        f"orphaned work in a shipped section. Re-home each to an OPEN section, "
                        f"strike it with the decision, or tick it. First: {orphaned[0][:80]!r}"
                    )
            if (
                s.has_fidelity_block
                and not s.fidelity_exempt
            ):
                missing = [
                    name
                    for name, present in (
                        ("Job", s.has_job),
                        ("Treatment", s.has_treatment),
                        ("Chrome", s.has_chrome),
                    )
                    if not present
                ]
                if missing:
                    labels = ", ".join(f"**{n}:**" for n in missing)
                    msg = (
                        f"{t.path}:{s.line}: §{num} has **Fidelity:** naming a "
                        f"page but is missing {labels}"
                    )
                    if num in t.verified_sections and pre_convention(s, FIDELITY_ACK_CUTOFF):
                        acked.append(
                            msg + " -- stamped pre-convention: the three-line "
                            "convention postdates the stamp; do not reopen it"
                        )
                    elif s.status == "x" and num in t.verified_sections:
                        flag(
                            "fidelity-missing-lines-stamped",
                            msg + " -- stamped AFTER the convention landed: the gap "
                            "is real; fix it forward, never by editing the stamp",
                        )
                    elif s.status == "x":
                        flag("fidelity-missing-lines-stamped", msg + " -- row is [x] with no covering stamp")
                    else:
                        flag("fidelity-missing-lines-open", msg)
            if s.items_total == 0:
                flag("no-checklist-items", f"{t.path}:{s.line}: §{num} has no checklist items")
            elif s.items_total > 30:
                flag(
                    "over-30-items",
                    f"{t.path}:{s.line}: §{num} has {s.items_total} checklist items "
                    f"(max 30 -- split it; see todo/README.md#section-sizing)"
                )
            # 7. [x] requires a Verified stamp covering the section
            if s.status == "x" and num not in t.verified_sections:
                fatal.append(
                    f"{t.path}: §{num} is [x] in Implementation Order but no "
                    f"'> **Verified:**' stamp covers it"
                )
            # 9. frozen TODOs need at least one freeze check
        if t.frozen and not any(s.has_freeze_check for s in t.sections.values()):
            flag(
                "frozen-no-freeze-check",
                f"{t.path}: frozen: true but no section carries a '**Freeze check:**' block",
            )
        if not t.frozen and any(s.has_freeze_check for s in t.sections.values()):
            flag("freeze-check-not-frozen", f"{t.path}: has a Freeze check but frontmatter does not set frozen: true")
        # 10. bare cross-TODO refs
        for b in t.bare_refs:
            flag("bare-todo-ref", f"{t.path}: bare TODO reference without a section -- {b}")
        # 5. depends_on (frontmatter, todo-level) resolves
        for dep in t.depends_on:
            if dep and dep not in by_id:
                fatal.append(f"{t.path}: depends_on {dep!r} does not match any TODO id")
        # 5b. section-level Depends On resolves
        for num, s in sorted(t.sections.items()):
            for raw in s.depends_on:
                r = graph.resolve_ref(raw, t, by_key)
                if r is None:
                    fatal.append(f"{t.path}: §{num} Depends On {raw!r} does not resolve")
                    continue
                tid, sec = r
                target = by_id.get(tid)
                if target is None or sec not in target.sections:
                    fatal.append(
                        f"{t.path}: §{num} Depends On {raw!r} -> {tid} §{sec}, which does not exist"
                    )

    # 6. cycles -- todo level and section level
    fatal.extend(graph._cycles({t.id: set(t.depends_on) for t in todos if t.id}, "TODO"))
    sec_edges: dict[str, set[str]] = {}
    for t in todos:
        for num, s in t.sections.items():
            node = f"{t.id} §{num}"
            targets = set()
            for raw in s.depends_on:
                r = graph.resolve_ref(raw, t, by_key)
                if r:
                    targets.add(f"{r[0]} §{r[1]}")
            sec_edges[node] = targets
    fatal.extend(graph._cycles(sec_edges, "section"))

    # 11. one-sided XREFs
    for t in todos:
        for raw in t.xrefs:
            r = graph.resolve_ref(raw, t, by_key)
            if r is None or r[0] == t.id:
                continue
            target = by_id.get(r[0])
            if target is None:
                continue
            if not any(
                graph.resolve_ref(x, target, by_key) and graph.resolve_ref(x, target, by_key)[0] == t.id
                for x in target.xrefs
            ):
                flag(
                    "one-sided-xref",
                    f"{t.path}: XREF to {target.path} is one-sided -- "
                    f"{target.path} does not point back",
                )

    # 13. deferral lifecycle -- a deferral must be closeable and must be closed
    #
    # Added 2026-08-10. Deferrals were raw strings that nothing resolved, so two
    # of eight had gone stale: the owning item shipped and the deferral kept
    # announcing an outstanding problem. The stale case is FATAL rather than a
    # warning, because a warning is exactly what let it happen -- the section
    # that resolves a deferral is the one that has to close it, and a red build
    # is what tells them.
    for t in todos:
        for d in t.deferred:
            where = f"{t.path}:{d.line}"
            short = (d.body[:60] + "…") if len(d.body) > 60 else d.body

            if not d.ref:
                flag(
                    "deferral-no-owner",
                    f"{where}: deferral names no owner (no '-> XREF:') -- {short}",
                )
                continue

            r = graph.resolve_ref(d.ref, t, by_key)
            target = by_id.get(r[0]) if r else None
            if target is None or r[1] not in target.sections:
                fatal.append(
                    f"{where}: deferral owner '{d.ref}' does not resolve to a real "
                    f"section -- {short}"
                )
                continue

            tsec = target.sections[r[1]]
            owner = f"{target.path} §{r[1]}"

            matched = None
            if d.item:
                for done, text in tsec.items:
                    if d.item.lower() in text.lower():
                        matched = done
                        break
                if matched is None:
                    fatal.append(
                        f"{where}: deferral names item \"{d.item}\" but {owner} has no "
                        f"such checklist item -- it was reworded or removed"
                    )
                    continue

            settled = matched if matched is not None else (tsec.status == "x")
            if settled and not d.resolved:
                fatal.append(
                    f"{where}: deferral is STALE -- {owner} has shipped the work but "
                    f"the line still reads 'Deferred:'. Close it with "
                    f"'> **Resolved:**' -- {short}"
                )
            elif not settled and d.resolved:
                flag(
                    "resolved-owner-unshipped",
                    f"{where}: marked 'Resolved:' but {owner} has not shipped it yet "
                    f"-- {short}",
                )

    # 12. every TODO appears in its domain INDEX.md
    for t in todos:
        # TODO_DIR, not REPO/todo: the self-test rebinds TODO_DIR to a
        # fixture tree, and an INDEX check pinned to the live repo would be
        # untestable by construction (found by §21's missing-from-index
        # fixture, 2026-08-28).
        idx = graph.TODO_DIR / t.domain / "INDEX.md"
        if not idx.exists():
            fatal.append(f"todo/{t.domain}/INDEX.md is missing")
        elif Path(t.path).name not in idx.read_text(encoding="utf-8"):
            flag("missing-from-index", f"{t.path}: not listed in todo/{t.domain}/INDEX.md")

    # 15. a `Verified:` line the parser refused (D00 T01 §39, dev ticket #7).
    # The refusal already happened in parse_todo -- the section is NOT in
    # verified_sections, so rule 7 will also fire on an [x] row. This rule is
    # what tells the reader WHICH line is wrong and why, instead of leaving
    # them with a missing-stamp message about a section that visibly has one.
    for t in todos:
        for lineno, detail in t.malformed_stamps:
            flag("malformed-stamp", f"{t.path}:{lineno}: refused '> **Verified:** {detail}")

    # The warning BASELINE. A count that only grows is a count nobody reads,
    # and 17 of these have stood for over a week: 15 name STAMPED sections
    # whose warning text says in as many words "do not reopen the stamp to add
    # prose", so zero was never reachable and chasing it was the wrong target.
    # What is reachable is that the set only shrinks -- a warning not in the
    # baseline is NEW, and new is what a reader wants to see. -> XREF: INT-0034.
    baseline_new: list[str] = []
    baseline = graph.load_warning_baseline()
    if baseline is not None:
        keys = {graph.warning_key(w) for w in warn}
        baseline_new = sorted(k for k in keys if k not in baseline)
        gone = sorted(k for k in baseline if k not in keys)
        if gone and not baseline_new:
            print(
                f"NOTE  {len(gone)} baselined warning(s) are fixed. "
                "Shrink the baseline: python scripts/todo-graph.py warnings --accept"
            )

    # DUPLICATE FILINGS, across the whole tree rather than per file. A scanner
    # that runs twice a day must never open a second row for one production
    # exception, and "search before filing" is a judgement call made by
    # whoever is tired. A provenance key is not.
    # THE SECTION CAP. Checked per file, before anything else that walks them.
    for todo in todos:
        count = len(todo.sections)
        if count > graph.MAX_SECTIONS_PER_FILE:
            flag(
                "over-section-cap",
                f"{todo.path} has {count} sections, over the {graph.MAX_SECTIONS_PER_FILE} cap. "
                "Section numbers are permanent addresses (`DNN TNN §N` encodes them), so this "
                "file can never be renumbered or made smaller. Put the next work in a NEW "
                "TODO file in the same domain, split by SUBJECT rather than by count, and "
                "leave every existing section exactly where it is.",
            )

    seen_sources: dict[str, str] = {}
    for todo in todos:
        try:
            text = (graph.REPO / todo.path).read_text(encoding="utf-8")
        except OSError:
            continue
        current = "?"
        for line in text.split("\n"):
            heading = re.match(r"^## (\d+)\.", line)
            if heading:
                current = f"§{heading.group(1)}"
            for m in graph.SOURCE_RE.finditer(line):
                key = m.group("key").lower()
                here = f"{todo.path} {current}"
                if key in seen_sources and seen_sources[key] != here:
                    flag(
                        "duplicate-source-key",
                        f"{todo.path} {current} claims `-> SOURCE: {key}`, already "
                        f"filed at {seen_sources[key]}. One real-world thing, one row: "
                        "fold this into the existing section rather than opening a second.",
                    )
                seen_sources.setdefault(key, here)

    # Internal self-tests deliberately point TODO_DIR at a standalone fixture.
    # Normal checkout validation always inspects its actual platform sources.
    # Resolute day-1 port: the coming-soon inspector is not ported
    # yet (see Deferred in the repo README). The severity class stays
    # reserved; this block runs again unchanged once the inspector lands.
    coming_soon_path = graph.REPO / "scripts/coming-soon-inspect.py"
    if graph.TODO_DIR.resolve() == (graph.REPO / "todo").resolve() and coming_soon_path.exists():
        try:
            spec = importlib.util.spec_from_file_location("coming_soon_inspect", coming_soon_path)
            if spec is None or spec.loader is None:
                raise ValueError("coming-soon inspector unavailable")
            inspector = importlib.util.module_from_spec(spec)
            sys.modules[spec.name] = inspector
            spec.loader.exec_module(inspector)
            result = inspector.inspect(graph.REPO, todos, graph)
            if not isinstance(result, dict) or not isinstance(result.get("failures"), list) or any(not isinstance(failure, str) for failure in result["failures"]):
                raise ValueError("coming-soon inspector must return a list of failure strings")
            for failure in result["failures"]:
                flag("pending-control-contract", failure)
        except Exception as error:
            flag("pending-control-contract", f"coming-soon inspection failed: {error}")

    # D00 T04 §5: semantic feature ownership needs human judgment.
    # It is advisory even with an empty/populated warning baseline. Existing
    # structural failures and ratcheted warning classes retain their decisions.
    advisory = []
    try:
        inspector = graph.adjacency_module()
        result = inspector.inspect(graph, todos)
        if not isinstance(result, dict) or result.get("files") != len(todos) or not isinstance(result.get("diagnostics"), list):
            raise ValueError("incomplete adjacency inspection result")
        for issue in result["diagnostics"]:
            if not isinstance(issue, dict) or not all(isinstance(issue.get(key), str) for key in ("file", "code", "message")):
                raise ValueError("malformed adjacency diagnostic")
        advisory = result["diagnostics"]
    except Exception as error:
        fatal.append(f"adjacency inspection unavailable: {error}")
    for issue in advisory:
        print(f"WARN [adjacency advisory] {issue['file']}:{issue.get('line', 0)}: {issue.get('kind', issue['code'])}: {issue['message']}")
    for w in warn:
        marker = "WARN* " if graph.warning_key(w) in set(baseline_new) else "WARN  "
        print(f"{marker}{w}")
    for f in fatal:
        print(f"FATAL {f}")
    graph.cmd_validate.last_acked = acked  # type: ignore[attr-defined] -- warnings --acked reads it
    print(
        f"\n{len(todos)} todos, {sum(len(t.sections) for t in todos)} sections -- "
        f"{len(fatal)} fatal, {len(warn)} warning(s)"
        + (f", {len(advisory)} adjacency advisory" if advisory else "")
        + (f", {len(baseline_new)} NEW (marked WARN*)" if baseline_new else "")
        + (
            f", {len(acked)} acknowledged (warnings --acked)"
            if acked
            else ""
        )
    )
    if baseline_new:
        print(
            "\nA warning outside the baseline is new work, not history. Fix it, or "
            "accept it deliberately: python scripts/todo-graph.py warnings --accept",
            file=sys.stderr,
        )
    return 1 if (fatal or baseline_new) else 0
