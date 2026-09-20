"""TODO validation, separated from graph query/projection commands.

The caller supplies its graph module so fixture roots, severity policy and
warning accounting use the same state as query/resolve. No copied constants.
"""
from __future__ import annotations

import importlib.util
from pathlib import Path
import re
import subprocess
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
    # PANEL_CUTOFF below is not a third ack cutoff: it grandfathers a FATAL
    # (rule 16), acks nothing, and moves no warning. It sits with the other
    # cutoffs for discoverability only.
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
    # The panel rule landed with the 2026-09-19 review-system port; every
    # Resolute stamp (newest 2026-09-17) predates it.
    PANEL_CUTOFF = "2026-09-18"

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

    # Raw span cache for rule 14: path -> file lines. The partial-flip
    # rule scans spans, not s.items, because its exemptions need line
    # context the parser does not keep (fence state, stamp position,
    # the owner XREFs on a deferral's continuation lines). Separate
    # from the marker cache below: that one reads raw lines, this one
    # strips fences per span.
    span_cache: dict[str, list[str] | None] = {}
    deferred_mark_re = re.compile(r"\bdeferred\b", re.IGNORECASE)
    header_re = re.compile(r"#{1,6}(?:\s|$)")
    word_re = re.compile(r"[a-z0-9]+")
    commit_quote_re = re.compile(r"""^commit:\s*`"(?P<msg>[^"]+)"`""", re.IGNORECASE)
    # Commit-subject cache for the history binding: repo root -> subjects,
    # None when git cannot read them. Keyed by root because the self-test
    # rebinds TODO_DIR between trees within one process.
    history_cache: dict[str, list[str] | None] = {}

    def _span_file(path: str) -> list[str] | None:
        if path not in span_cache:
            try:
                span_cache[path] = (graph.TODO_DIR.parent / path).read_text(encoding="utf-8").splitlines()
            except OSError:
                span_cache[path] = None
        return span_cache[path]

    def _span_slice(raw: list[str], sec_line: int) -> tuple[list[str], int]:
        """Raw span lines plus the 1-based lineno of the first: one slicing for both views."""
        start = max(sec_line, 1)
        end = len(raw) + 1
        for j in range(start + 1, len(raw) + 1):
            if raw[j - 1].startswith("## "):
                end = j
                break
        return raw[start : end - 1], start + 1

    def _marked_stripped(raw: list[str], flags: list[bool]
                       ) -> tuple[list[str], dict[int, int]]:
        """Stripped lines with one blank marker per dropped region, plus the raw index map.

        The marker is what stops deferral owner collection at fence
        boundaries (D00 T04 §20): a fence is at least as strong a
        boundary as a blank line, so each stripped region collapses to
        one. The map carries raw span indexes to stripped indexes for
        the report, which classifies raw lines against stripped blocks.
        """
        stripped: list[str] = []
        at_stripped: dict[int, int] = {}
        prev_dropped = False
        for r_i, (ln, keep) in enumerate(zip(raw, flags)):
            if keep:
                at_stripped[r_i] = len(stripped)
                stripped.append(ln)
                prev_dropped = False
            elif not prev_dropped:
                stripped.append("")
                prev_dropped = True
        return stripped, at_stripped

    def span_lines(path: str, sec_line: int) -> list[str] | None:
        """Stripped body lines of one whole section span, or None.

        Span mirrors the parser: from the `## N.` heading to the next
        `## ` line of any kind (a `## Verification` block ends the
        span exactly as it clears `current`). Fences strip per span
        through the shared stripper, keeping the rule on the parser's
        own section model; a span-local unbalanced fence falls back to
        the raw span, which is what the fence-blind parser sees. Each
        stripped region leaves one blank boundary marker, so deferral
        owner collection stops at fences. No stamp cut applies (D00
        T04 §20 removed it): below-stamp checklist items fail as
        appended work, while genuine stamp fields ride `>` lines the
        item scan never matches.
        """
        raw = _span_file(path)
        if raw is None:
            return None
        span, _first = _span_slice(raw, sec_line)
        flags, unbalanced = graph.strip_fenced_map("\n".join(span))
        if unbalanced is not None:
            return span
        stripped, _at = _marked_stripped(span, flags)
        return stripped

    def span_raw(path: str, sec_line: int) -> tuple[list[str] | None, int | None]:
        """Raw span lines with the 1-based lineno of the first, or (None, None).

        The disposition report's view: same span model as `span_lines`,
        unstripped, so fenced items keep their lines.
        """
        raw = _span_file(path)
        if raw is None:
            return None, None
        lines, first = _span_slice(raw, sec_line)
        return lines, first

    def commit_subjects() -> list[str] | None:
        """One `git log` per tree: the subjects a `Commit:` line may bind to."""
        root = str(graph.TODO_DIR.parent)
        if root not in history_cache:
            try:
                proc = subprocess.run(
                    ["git", "log", "--format=%s"], cwd=root,
                    capture_output=True, text=True, timeout=60,
                )
            except (OSError, subprocess.SubprocessError):
                proc = None
            history_cache[root] = (
                proc.stdout.splitlines() if proc is not None and proc.returncode == 0
                else None
            )
        return history_cache[root]

    def _contains_seq(hay: list[str], needle: list[str]) -> bool:
        """Whether the needle words appear in the hay words in order, consecutively."""
        if not needle or len(needle) > len(hay):
            return False
        return any(hay[i:i + len(needle)] == needle for i in range(len(hay) - len(needle) + 1))

    def commit_shape(span: list[str]) -> list[str]:
        """Section-level Commit shape problems (cardinality, placement): message tails."""
        last_item = None
        commits = []
        for i, ln in enumerate(span):
            if graph.checklist_state(ln.strip()) is None:
                continue
            last_item = i
            if ln.strip()[5:].strip().lower().startswith("commit:"):
                commits.append(i)
        if len(commits) > 1:
            return [f"carries {len(commits)} Commit items -- one section ends on one commit"]
        if len(commits) == 1 and commits[0] != last_item:
            return ["its Commit item is not the final checklist item -- the commit ends the section"]
        return []

    def classify_unchecked(todo, s_num: int, span: list[str], i: int, text: str
                           ) -> tuple[str, str]:
        """One unchecked item's disposition: (code, payload).

        The scan and the disposition report share this classifier, so the
        report can never describe a rule the scan does not enforce.
        Codes: commit-bound (payload: the bound subject), commit-unquoted,
        commit-unverified, commit-unbound (payload: the quoted message),
        plain-open, struck-unmarked, deferral-unowned, deferral-ok
        (payload: the owner acknowledgments), deferral-bad (payload: the
        semicolon-joined problems).
        """
        ln = span[i]
        if text.lower().startswith("commit:"):
            # Proven by history, mechanically (D00 T04 §20): the quoted
            # message binds when a commit subject equals it or starts
            # with it. Exact-or-prefix, not substring: every live
            # binding is one of the two (suffixes append, never
            # prepend), while a substring would bless mid-subject
            # lookalikes -- and not boundary-prefix either, which a
            # future suffix shape would brick into a FATAL on a
            # stamped checklist no one may edit.
            quote = commit_quote_re.match(text)
            if quote is None:
                return ("commit-unquoted", "")
            subjects = commit_subjects()
            if subjects is None:
                return ("commit-unverified", "")
            msg = quote.group("msg")
            bound = next((s for s in subjects if s == msg or s.startswith(msg)), None)
            if bound is None:
                return ("commit-unbound", msg)
            return ("commit-bound", bound)
        if not text.startswith("~~"):
            return ("plain-open", "")
        if not deferred_mark_re.search(text):
            return ("struck-unmarked", "")
        # A deferral's owner rides the contiguous lines belonging to
        # the item: the item line itself plus following lines until a
        # blank line, the next item, or a header. (D00 T02 §4 defers
        # to D04 T01 §1 exactly this way, owner on the next line.)
        # Fences stop collection too: each stripped region leaves one
        # blank boundary marker in the span.
        block = [ln]
        for cont in span[i + 1 :]:
            cst = cont.strip()
            if not cst or graph.checklist_state(cst) is not None or header_re.match(cst):
                break
            block.append(cont)
        owners = [
            (m.group("ref"), line) for line in block
            for m in graph.DEFER_REF_RE.finditer(line)
        ]
        if not owners:
            return ("deferral-unowned", "")
        problems = []
        acks = []
        for raw_ref, src_line in owners:
            # The typed citation (D00 T04 §20): the forward XREF names
            # the owner's item, and the owner acknowledges it by
            # carrying that item and linking back. A section link to
            # an item-silent target fails, as does an untyped forward
            # XREF -- the pair is section plus item, named at the
            # source (D00 T02 §4 names D04 T01 §1's pair exactly so).
            cited = graph.DEFER_ITEM_RE.search(src_line)
            if cited is None:
                problems.append(
                    f"owner {raw_ref!r} names no item (no '(item: ...)' "
                    "on its XREF line)"
                )
                continue
            r = graph.resolve_ref(raw_ref, todo, by_key)
            if r is None or r[0] not in by_id or r[1] not in by_id[r[0]].sections:
                problems.append(f"owner {raw_ref!r} resolves to nothing")
                continue
            target = by_id[r[0]]
            tsec = target.sections[r[1]]
            # Contiguous word-sequence matching, not substring (D00 T04
            # §20 round 1 F2, round 2 F5): a vague citation like `(item:
            # "net")` must not satisfy off an unrelated item's
            # substring, and neither must a reordered bag of common
            # words like `(item: "work the network")` off "Do the
            # network work". The citation's words must appear in order
            # and consecutively, case- and punctuation-insensitive; a
            # genuine citation keeps affix tolerance but not reorder
            # tolerance. The stamp-line lifecycle keeps containment;
            # the two rules differ deliberately, each recorded beside
            # its own match.
            want_seq = word_re.findall(cited.group("item").lower())
            item_ok = bool(want_seq) and any(
                _contains_seq(word_re.findall(item_text.lower()), want_seq)
                for _done, item_text in tsec.items)
            want = cited.group("item").strip()
            if not item_ok:
                problems.append(
                    f"owner {r[0]} §{r[1]} carries no such item "
                    f"({want[:80]!r}) -- it was reworded or removed"
                )
            tspan = span_lines(target.path, tsec.line)
            back_depends = any(
                graph.resolve_ref(dep, target, by_key) == (todo.id, s_num)
                for dep in tsec.depends_on
            )
            back_xref = tspan is not None and any(
                graph.resolve_ref(m.group("ref"), target, by_key) == (todo.id, s_num)
                for tln in tspan
                for m in graph.DEFER_REF_RE.finditer(tln)
            )
            if not (back_depends or back_xref):
                problems.append(
                    f"owner {r[0]} §{r[1]} carries no back-pointer "
                    f"(neither an XREF nor Depends On {todo.id} §{s_num})"
                )
            elif tsec.status == "x":
                # Ship-time resolution proof (D00 T04 §20): a deferral
                # whose owner has shipped fails unless the owner's stamp
                # records the debt done -- a `Resolved:` line citing the
                # deferring section. The proof lands owner-side because
                # the deferring checklist is stamped and uneditable; an
                # open-owner requirement would FATAL it the day the
                # owner ships, with no legal fix.
                proof = tspan is not None and any(
                    (sm := graph.STAMP_RE.match(tln)) is not None
                    and sm.group("kind") == "Resolved"
                    and any(
                        graph.resolve_ref(m.group("ref"), target, by_key)
                        == (todo.id, s_num)
                        for m in graph.DEFER_REF_RE.finditer(tln)
                    )
                    for tln in tspan
                )
                if not proof:
                    problems.append(
                        f"owner {r[0]} §{r[1]} has shipped without recording "
                        f"the debt done (no '> **Resolved:**' citing {todo.id} "
                        f"§{s_num})"
                    )
                elif item_ok:
                    acks.append(f"{r[0]} §{r[1]} carries {want[:60]!r}, "
                                "shipped with proof")
            elif item_ok:
                legs = "+".join(leg for leg, ok in
                                (("Depends", back_depends), ("XREF", back_xref)) if ok)
                acks.append(f"{r[0]} §{r[1]} carries {want[:60]!r}, {legs} back, "
                            "owner open")
        if problems:
            return ("deferral-bad", "; ".join(problems))
        return ("deferral-ok", "; ".join(acks))

    def _report_entry(path: str, lineno: int, st: str, code: str, payload: str,
                      counts: dict[str, int]) -> tuple[str, str, str]:
        """(tag, item location, detail) for one classified line, counting it."""
        item = f"{path}:{lineno}: {st[:100]}"
        if code == "commit-bound":
            counts["commit"] += 1
            return ("EXEMPT Commit", item, f"bound to {payload!r}")
        if code == "commit-unverified":
            counts["unverified"] += 1
            return ("UNVERIFIED Commit", item, "history unreadable")
        if code == "commit-unquoted":
            counts["fail"] += 1
            return ("FAIL", item, "Commit line with no quoted subject")
        if code == "commit-unbound":
            counts["fail"] += 1
            return ("FAIL", item, f"bound to no commit (quoted {payload!r})")
        if code == "plain-open":
            counts["fail"] += 1
            return ("FAIL", item, "unticked item")
        if code == "struck-unmarked":
            counts["fail"] += 1
            return ("FAIL", item, "struck item with no Deferred marker")
        if code == "deferral-unowned":
            counts["fail"] += 1
            return ("FAIL", item, "deferral naming no owner")
        if code == "deferral-ok":
            counts["deferral"] += 1
            return ("EXEMPT deferral", item, payload)
        counts["fail"] += 1
        return ("FAIL", item, payload)  # deferral-bad

    def report_shipped_items() -> int:
        """Every unchecked item under shipped rows with its disposition.

        The committed form of the §19 probe: the exemption counts
        re-derive from this query instead of ad-hoc inspection. A
        reading, not a gate: always exits 0.
        """
        counts = {"commit": 0, "deferral": 0, "fenced": 0, "unverified": 0, "fail": 0}
        for t in todos:
            for num, s in sorted(t.sections.items()):
                if s.status != "x" or not s.has_body:
                    continue
                raw, first = span_raw(t.path, s.line)
                if raw is None or first is None:
                    continue
                flags, unbalanced = graph.strip_fenced_map("\n".join(raw))
                if unbalanced is None:
                    stripped, at_stripped = _marked_stripped(raw, flags)
                else:
                    stripped = list(raw)
                    at_stripped = {r_i: r_i for r_i in range(len(raw))}
                entries = []
                for tail in commit_shape(stripped):
                    entries.append(("FAIL shape", "", tail))
                    counts["fail"] += 1
                for r_i, ln in enumerate(raw):
                    st = ln.strip()
                    state = graph.checklist_state(st)
                    if state is None or state:
                        continue
                    if unbalanced is None and not flags[r_i]:
                        entries.append(("EXEMPT fenced", f"{t.path}:{first + r_i}: {st[:100]}",
                                        "stripped before the scan"))
                        counts["fenced"] += 1
                        continue
                    code, payload = classify_unchecked(t, num, stripped, at_stripped[r_i],
                                                       st[5:].strip())
                    entries.append(_report_entry(t.path, first + r_i, st, code, payload, counts))
                if entries:
                    print(f"{t.path} §{num}:")
                    for tag, where_item, detail in entries:
                        if where_item:
                            print(f"  - [{tag}] {where_item} -- {detail}")
                        else:
                            print(f"  - [{tag}] {detail}")
        print(f"shipped items: {counts['commit']} Commit, {counts['deferral']} deferral, "
              f"{counts['fenced']} fenced, {counts['unverified']} unverified, "
              f"{counts['fail']} failures")
        return 0

    def partial_flip_scan(todo, s_num: int, sec) -> None:
        span = span_lines(todo.path, sec.line)
        if span is None:
            return
        where = f"{todo.path}:{sec.line}: §{s_num}"
        # One section ends on one commit (D00 T04 §20): at most one
        # `Commit:` item in any state, and it is the final checklist
        # item, so a duplicate or mid-list lookalike cannot read as
        # bookkeeping.
        for tail in commit_shape(span):
            flag("partial-flip-shipped", f"{where} is [x] but {tail}")
        for i, ln in enumerate(span):
            st = ln.strip()
            state = graph.checklist_state(st)
            if state is None or state:
                continue
            text = st[5:].strip()
            code, payload = classify_unchecked(todo, s_num, span, i, text)
            if code in ("commit-bound", "deferral-ok"):
                continue
            if code == "commit-unverified":
                flag(
                    "commit-history-unreadable",
                    f"{where} carries an unchecked Commit line but git history "
                    f"cannot be read; the binding is unverified: {text[:100]!r}",
                )
            elif code == "commit-unquoted":
                flag(
                    "partial-flip-shipped",
                    f"{where} is [x] but carries a Commit line with no quoted subject: "
                    f"{text[:100]!r} -- quote the committed subject",
                )
            elif code == "commit-unbound":
                flag(
                    "partial-flip-shipped",
                    f"{where} is [x] but carries a Commit line bound to no commit: "
                    f"{text[:100]!r} -- quote the committed subject",
                )
            elif code == "plain-open":
                flag(
                    "partial-flip-shipped",
                    f"{where} is [x] but carries an unticked item: {text[:100]!r} -- "
                    f"tick it, defer it with an owner, or unship the row",
                )
            elif code == "struck-unmarked":
                flag(
                    "partial-flip-shipped",
                    f"{where} is [x] but carries a struck item with no Deferred marker: "
                    f"{text[:100]!r} -- a strike without the marker reads as hidden work",
                )
            elif code == "deferral-unowned":
                flag(
                    "partial-flip-shipped",
                    f"{where} is [x] but carries a deferral naming no owner: "
                    f"{text[:100]!r} -- attach '-> XREF:' to the owning section",
                )
            elif code == "deferral-bad":
                flag(
                    "partial-flip-shipped",
                    f"{where} is [x] but carries a deferral with a defective owner: "
                    f"{text[:100]!r} -- " + payload,
                )
    if getattr(_args, "report_shipped_items", False):
        return report_shipped_items()

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
            # 8d. a `**Requires:**` value must come from the closed list, and
            # the mark must cite its reason. Shipped sections carry no marks
            # and need none: grandfathered, not retrofitted.
            if s.requires_has_line and (s.requires_unknown or not s.requires):
                allowed = ", ".join(f"`{k}`" for k in graph.REQUIRES_ALLOWED)
                bad = ", ".join(f"`{v}`" for v in s.requires_unknown) or "no values"
                flag(
                    "requires-unknown",
                    f"{t.path}:{s.line}: §{num} has **Requires:** {bad}, "
                    f"not in the closed list ({allowed})",
                )
            if s.requires_has_line and not s.requires_reason:
                flag(
                    "requires-no-reason",
                    f"{t.path}:{s.line}: §{num} has **Requires:** with no reason; "
                    "cite the measurement that convicted the section after ` -- `",
                )
            # 13. every section ends on a commit item
            if not s.has_commit_item:
                flag("no-commit-item", f"{t.path}:{s.line}: §{num} has no '- [ ] Commit:' checklist item")
            # 14. a CLOSED section must not carry open work: a `[x]` row
            # with an open checklist reads as done while work remains,
            # the one state the completion-first policy refuses to
            # represent (D00 T04 §19, superseding `orphaned-items-shipped`).
            #
            # A finding filed as a plain checklist item inside a section that later
            # ships is invisible: the section is done, nobody reopens it, and the
            # item sits unticked forever. Found 2026-08-14 with 21 such items across
            # 8 closed sections, one of them a real review-panel finding.
            #
            # Three shapes are excused, each for a stated reason (D00 T04
            # §20 removed the fourth, the stamp-region cut: below-stamp
            # items fail as appended work). A `Commit:` line is excused
            # when its quoted message binds to a commit subject by
            # exact-or-prefix containment, proven by history rather than
            # by the checkbox -- and ticking one on a shipped section
            # would rewrite a stamped checklist. The row determines its
            # reading: unticked on `[ ]` means doing, unticked on `[x]`
            # means excused, ticked means done (todo/README.md's
            # Completion-first states the order). One section ends on
            # one commit: a second `Commit:` item or a non-final one
            # fails, in any tick state.
            # A struck `~~` item carrying a `Deferred` marker
            # is filed debt with an owner, not open work -- and the owner
            # must resolve to a live section that points back, either
            # with an XREF or through Depends On. The forward XREF names
            # the owner's item (`(item: ...)`), and the owner must carry
            # those words in order and consecutively: a section link to
            # an item-silent target fails, and so do vague or reordered
            # citations matching only a substring or a bag of words.
            # When the owner ships, its stamp must record the debt done
            # (`Resolved:` citing the deferrer), or the deferral fails.
            # Fenced code blocks strip before the scan. Everything else
            # unticked fails,
            # including a struck item without the marker and a
            # checkbox-wrapped `-> XREF:` (a cross-reference needs
            # no checkbox).
            if s.moved:
                moved_path = graph.moved_target(s.moved)
                if not moved_path or not (graph.TODO_DIR.parent / moved_path).is_file():
                    flag(
                        "moved-target-missing",
                        f"{t.path}:{s.line}: §{num} carries a Moved: marker that names no "
                        f"existing file ({s.moved[:80]!r}); the work it points at cannot be found",
                    )
            if s.status == "x":
                partial_flip_scan(t, num, s)
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
            # 7b. [ ] must not carry Verified coverage: an open row with a
            # stamp reads as reviewed-but-open (D00 T04 §20). Audit-stance
            # reopens do not fire: the parser discards Reopened sections
            # from coverage. The converse is deliberately NOT a rule --
            # ticked-then-reviewed is the review flow, so a fully ticked
            # open row waits without failing.
            if s.status != "x" and num in t.verified_sections:
                fatal.append(
                    f"{t.path}: §{num} is [ ] in Implementation Order but a "
                    f"'> **Verified:**' stamp covers it -- flip the row"
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

    # 16. a stamp dated after the Opus-panel rule landed must point at
    # findings carrying the panel's verdicts. The skill makes
    # headless-Opus lens verdicts mandatory; this rule is what stops a
    # session stamping without running the panel. It enforces the RECORD
    # (findings file exists, has an `Opus panel` section, all four lenses
    # carry a verdict word), which defeats forgetfulness; it cannot prove
    # Opus ran rather than a hand-typed verdict, and does not try.
    # When the Opus panel is unreachable the skill runs the same four
    # lenses through the GPT fallback rung, recorded under a `GPT panel`
    # heading with an Opus outage note, and that record satisfies this
    # rule. The LAST panel section of either family governs: a fallback
    # round authorizes the stamp exactly like an Opus round, so
    # last-wins crosses families and a superseded section of either
    # family never validates the stamp. The honesty limit is unchanged
    # (a mislabeled heading defeats forgetfulness, not forgery).
    # Grandfathering is date-bound like rule 8b/13 (cutoff declared
    # beside the others above): stamps on or before the rule's landing
    # date predate enforcement. FATAL, not WARN: an unpaneled stamp
    # reads as reviewed evidence while verifying nothing. The date test
    # is open-coded rather than via pre_convention() deliberately: that
    # predicate conjoins row-status [x], but the stamp is the claim
    # here, so an undated stamp fails closed (evaluated, not skipped)
    # per the file convention that an undated stamp never acks.
    # Unreachable today (the parser dates every covered section), kept
    # as defense if that invariant changes.
    PANEL_LENSES = ("adversarial", "consistency", "integration", "record")
    PANEL_VERDICTS = ("approve", "needs-attention", "advisory")
    # Level 2+ and STARTING with the words: a `# Review:` title may itself
    # mention the Opus panel, and matching it would slice the verdicts
    # away and false-fire on a clean file. Levels run to 6 (the
    # documented "or deeper"), and any heading level ends the panel
    # section, so a `##### Leftover notes` tail after the panel can
    # neither supply lens verdicts nor displace the record.
    PANEL_HEADING_RE = re.compile(r"^#{2,6}\s+Opus panel\b", re.IGNORECASE | re.MULTILINE)
    # Same level and word-boundary rules as the Opus heading: the fallback
    # record differs in family, not in shape. Runs on the same stripped
    # text, so fenced `GPT panel` quotes are invisible for free.
    GPT_PANEL_HEADING_RE = re.compile(r"^#{2,6}\s+GPT panel\b", re.IGNORECASE | re.MULTILINE)
    # The outage note is words, not a shape: the skill mandates the
    # `Opus outage: <what>` line, and the rule checks the words survived
    # transcription. Substring, not line-anchored: the note explains, it
    # does not authorize, so marker strictness would reject honest prose.
    GPT_OUTAGE_RE = re.compile(r"opus outage", re.IGNORECASE)
    # Verdicts are line-anchored, never substring: the mandated shape puts
    # each verdict on its own marker-led line, so unheaded prose after an
    # incomplete panel (or a mid-line mention anywhere) must not supply a
    # verdict. The marker run is required and same-line: a bare `record
    # approve` prose line, even at column 0, does not count.
    PANEL_VERDICT_RES = {
        lens: re.compile(
            r"^[ \t]{0,3}[*`>-][ *`>-]*`?"
            + lens
            + r"`?[^\w\n]{1,4}("
            + "|".join(PANEL_VERDICTS)
            + r")\b",
            re.IGNORECASE | re.MULTILINE,
        )
        for lens in PANEL_LENSES
    }

    for t in todos:
        for num, s in sorted(t.sections.items()):
            if num not in t.verified_sections:
                continue
            if s.stamped_on is not None and s.stamped_on <= PANEL_CUTOFF:
                continue
            stamp_day = s.stamped_on if s.stamped_on is not None else "undated"
            where = f"{t.path}:{s.line}: §{num} stamped {stamp_day}"
            body = getattr(s, "review_body", None) or ""
            m = graph.FINDINGS_RE.search(body)
            if not m:
                flag(
                    "stamp-no-opus-panel",
                    f"{where} names no findings file in its Review: line "
                    f"(needs 'Raw findings: <path>' to panel verdicts)",
                )
                continue
            # TODO_DIR.parent, not REPO: the self-test rebinds TODO_DIR to a
            # fixture tree, and findings paths are repo-relative.
            findings = graph.TODO_DIR.parent / m.group(1)
            try:
                text = findings.read_text(encoding="utf-8")
            except OSError:
                flag(
                    "stamp-no-opus-panel",
                    f"{where} names findings {m.group(1)}, which does not exist",
                )
                continue
            # Fenced code blocks are invisible to the scan: findings files
            # quote the mandated panel shape inside fences (the skill shows
            # it), and a quoted `## Opus panel (round N)` must neither
            # satisfy the rule nor, under last-wins, displace the real
            # panel. The stripper lives in the graph module (shared with
            # `query plan-health`).
            text, unbalanced = graph.strip_fenced_code(text)
            if unbalanced is not None:
                flag(
                    "stamp-no-opus-panel",
                    f"{where} findings {m.group(1)} has an unbalanced fence "
                    f"opened at line {unbalanced}",
                )
                continue
            heads = list(PANEL_HEADING_RE.finditer(text))
            gpt_heads = list(GPT_PANEL_HEADING_RE.finditer(text))
            if not heads and not gpt_heads:
                flag(
                    "stamp-no-opus-panel",
                    f"{where} findings {m.group(1)} carry no `Opus panel` section",
                )
                continue
            last_is_gpt = gpt_heads and (
                not heads or gpt_heads[-1].start() > heads[-1].start()
            )
            if last_is_gpt:
                # GPT fallback path: same verdict bar as the Opus panel,
                # plus the Opus outage note that earns the fallback. Taken
                # when the last panel section of either family is GPT: a
                # fallback round authorizes the stamp, so an Opus section
                # anywhere earlier never excuses a defective GPT last.
                gpt = text[gpt_heads[-1].end():]
                nxt = re.search(r"^#{1,6}\s+", gpt, re.MULTILINE)
                if nxt:
                    gpt = gpt[:nxt.start()]
                missing = [
                    lens
                    for lens in PANEL_LENSES
                    if not PANEL_VERDICT_RES[lens].search(gpt)
                ]
                if missing:
                    flag(
                        "stamp-no-opus-panel",
                        f"{where} findings {m.group(1)} GPT panel lacks verdicts for: "
                        + ", ".join(missing),
                    )
                if not GPT_OUTAGE_RE.search(gpt):
                    flag(
                        "stamp-no-opus-panel",
                        f"{where} findings {m.group(1)} GPT panel lacks the Opus outage note",
                    )
                continue
            # The LAST panel section of either family is the record (the
            # branch above took the GPT-last case): fix-loop rounds append,
            # so reading anything but the last would validate a superseded
            # round and never the verdicts that authorize the stamp.
            panel = text[heads[-1].end():]
            nxt = re.search(r"^#{1,6}\s+", panel, re.MULTILINE)
            if nxt:
                panel = panel[:nxt.start()]
            missing = [
                lens
                for lens in PANEL_LENSES
                if not PANEL_VERDICT_RES[lens].search(panel)
            ]
            if missing:
                flag(
                    "stamp-no-opus-panel",
                    f"{where} findings {m.group(1)} panel lacks verdicts for: "
                    + ", ".join(missing),
                )

    # 17. a stamp dated after the plan-review rule landed must carry the
    # review's completion marker. The skill runs the review after
    # panel-close and the marker rides the stamp commit, so a stamp
    # without it either skipped the second-family round or lost the
    # record. Grandfathering is date-bound like rule 16: stamps on or
    # before the cutoff predate enforcement, and an undated stamp fails
    # closed (evaluated, not skipped). FATAL, not WARN: an unmarked stamp
    # reads as fully reviewed while the required round may never have
    # run. The marker names the filings or `no findings`; the ledger
    # lives in the findings file, not here, so presence is the whole
    # check.
    # All `Plan review:` lines of one section, in order: the parser keeps
    # the last (last-governs), but lineage is a property of the chain, so
    # the validator re-slices the span. Marker helpers live in the graph
    # module: the validator and the run query share one `outage marker`
    # reading and one chain slice, so the two can never drift apart.
    todo_lines: dict[str, list[str]] = {}

    def section_markers(todo, num: int) -> list[str] | None:
        return graph.section_markers(todo_lines, todo, num)

    def marker_states(body: str) -> dict[str, bool]:
        return graph.marker_states(body)

    def is_outage_marker(body: str) -> bool:
        return graph.is_outage_marker(body)

    for t in todos:
        for num, s in sorted(t.sections.items()):
            if num not in t.verified_sections:
                continue
            if s.stamped_on is not None and s.stamped_on <= graph.PLAN_REVIEW_CUTOFF:
                continue
            marker = getattr(s, "plan_review_body", None) or ""
            if not marker.strip():
                stamp_day = s.stamped_on if s.stamped_on is not None else "undated"
                flag(
                    "stamp-no-plan-review",
                    f"{t.path}:{s.line}: §{num} stamped {stamp_day} carries no "
                    f"`Plan review:` completion marker (name the filings or `no findings`)",
                )
                continue
            # The marker's claims are checked, not just its presence. Every
            # ref it names must resolve (a filing that points nowhere is a
            # dropped filing), and every ledger `filed` row's target must
            # appear in the marker (the marker claims filing completeness).
            # `outage:` markers skip both: there was no review to file from.
            # Rule 16 owns missing or unreadable findings, so the
            # cross-check quietly skips those. The marker grammar, checked
            # before the outage skip (grammar binds every marker). The last
            # marker line governs: the parser overwrites, so this body
            # already IS the last one, and a superseded line's claims are
            # void. States are mutually exclusive where they contradict: `no
            # findings` beside a `filed` claim, and any filing claim beside
            # `outage:`, are FATAL; outage purity also forbids `no findings`
            # (nothing ran, so nothing was found) and `retry-owed` (no
            # fallback ran, so no rerun is owed) beside `outage:`.
            # Coherent pairs stay silent: filings or `no findings` beside
            # `retry-owed` (the fallback ran and owes a second-family
            # rerun), and prose refs like `attempted §N` beside `outage:`
            # (an attempt is not a filing claim). `partial: <rung>`: one
            # rung failed while the other produced findings, so filings
            # beside `partial:` stay silent (the survivor's findings
            # stand) while `outage:` beside `partial:` is FATAL (an outage
            # produced nothing).
            st = marker_states(marker)
            has_outage = st["outage"]
            has_nofind = st["nofind"]
            has_filed = st["filed"]
            has_retry = st["retry"]
            has_partial = st["partial"]
            if has_nofind and has_filed:
                flag(
                    "stamp-no-plan-review",
                    f"{t.path}:{s.line}: §{num} marker claims both `no findings` and filings",
                )
            if has_outage and has_filed:
                flag(
                    "stamp-no-plan-review",
                    f"{t.path}:{s.line}: §{num} outage marker carries filing claims",
                )
            if has_outage and has_nofind:
                flag(
                    "stamp-no-plan-review",
                    f"{t.path}:{s.line}: §{num} outage marker claims `no findings` (nothing ran)",
                )
            if has_outage and has_retry:
                flag(
                    "stamp-no-plan-review",
                    f"{t.path}:{s.line}: §{num} outage marker carries `retry-owed` (no fallback ran)",
                )
            if has_outage and has_partial:
                flag(
                    "stamp-no-plan-review",
                    f"{t.path}:{s.line}: §{num} outage marker carries `partial:` (an outage produced no findings)",
                )
            # Partial-owed-rerun coherence. `partial:` names the FAILED rung
            # (`gpt rung`, the primary, or `opus rung`, the fallback); the
            # survivor is the other family. A fallback survivor is a
            # same-family run and owes a second-family rerun, so it carries
            # `retry-owed`; a primary survivor is a complete second-family
            # review and carries neither `retry-owed` nor accountability
            # fields (there is nothing to own). Unknown rungs fail:
            # positional names cannot say which family survived.
            if has_partial and not has_outage:
                prm = re.search(
                    r"\bpartial\s*:\s*([a-z][a-z0-9]*(?:\s+[a-z][a-z0-9]*)?)",
                    marker.lower(),
                )
                rung = prm.group(1) if prm else ""
                if rung not in ("gpt rung", "opus rung"):
                    flag(
                        "stamp-no-plan-review",
                        f"{t.path}:{s.line}: §{num} partial names no known rung (gpt rung or opus rung)",
                    )
                elif rung == "opus rung":
                    if has_retry:
                        flag(
                            "stamp-no-plan-review",
                            f"{t.path}:{s.line}: §{num} complete partial run owes no retry (drop retry-owed)",
                        )
                    elif graph.OWNER_RE.search(marker) or graph.DUE_RE.search(marker):
                        flag(
                            "stamp-no-plan-review",
                            f"{t.path}:{s.line}: §{num} complete partial run carries accountability fields with nothing owed",
                        )
                elif not has_retry:
                    flag(
                        "stamp-no-plan-review",
                        f"{t.path}:{s.line}: §{num} partial run with a fallback survivor owes a retry (retry-owed (owner, due))",
                    )
            if has_outage:
                continue
            for xm in graph.XREF_RE.finditer(marker):
                r = graph.resolve_ref(xm.group(0), t, by_key)
                if not r or r[0] not in by_id or r[1] not in by_id[r[0]].sections:
                    flag(
                        "stamp-no-plan-review",
                        f"{t.path}:{s.line}: §{num} marker names unresolvable filing {xm.group(0)!r}",
                    )
            fm = graph.FINDINGS_RE.search(getattr(s, "review_body", None) or "")
            if not fm:
                continue
            try:
                ftext = (graph.TODO_DIR.parent / fm.group(1)).read_text(encoding="utf-8")
            except OSError:
                continue
            # Per-marker, deliberately not deduped: the omission is each
            # marker's own (a shared file's second section can omit a
            # target the first one named), so every marker is checked
            # independently. Reports on identical markers sharing one file
            # are distinct per-marker defects, not duplicates.
            ftext, _u = graph.strip_fenced_code(ftext)
            # Marker lineage. A marker whose findings carry a Plan review
            # record binds to it by run ID: the last line carries `run
            # <id>`, rerun lines chain via `supersedes <prior-run>`, runs
            # never repeat within the section, and the last run is one
            # the manifest carries. Markers over record-less findings
            # (panel-shape probes) carry nothing to bind to and stay
            # exempt; outage markers skipped above.
            heads = list(graph.PLAN_REVIEW_HEADING_RE.finditer(ftext))
            chain = section_markers(t, num) or []
            if heads and chain:
                runs: list[str | None] = []
                for body in chain:
                    rm = graph.RUN_ID_RE.search(body)
                    runs.append(rm.group(1) if rm else None)
                last_run = runs[-1] if runs else None
                if last_run is None:
                    flag(
                        "plan-review-no-lineage",
                        f"{t.path}:{s.line}: §{num} marker carries no run ID "
                        f"(name the review run: run YYYYMMDD-DNN-TNN-SN-<family>[-rN])",
                    )
                elif not graph.RUN_ID_SHAPE_RE.match(last_run):
                    flag(
                        "plan-review-no-lineage",
                        f"{t.path}:{s.line}: §{num} marker run {last_run!r} is outside the run-ID shape",
                    )
                prior_outage = len(chain) > 1 and is_outage_marker(chain[-2])
                follows = graph.FOLLOWS_OUTAGE_RE.search(chain[-1]) is not None
                if len(chain) == 1 and graph.SUPERSEDES_RE.search(chain[0]) is not None:
                    # A singleton marker is genesis: run, no supersedes.
                    # One carrying a supersedes edge names ancestry it
                    # cannot have: deleted or fabricated lineage
                    # masquerading as a first run.
                    flag(
                        "plan-review-no-lineage",
                        f"{t.path}:{s.line}: §{num} genesis marker carries supersedes (a first run has no ancestry to name)",
                    )
                claimed: set[str] = set()
                for _ci, _cbody in enumerate(chain):
                    _csm = graph.SUPERSEDES_RE.search(_cbody)
                    if _csm is None:
                        continue
                    _ctgt = graph.normalize_run_id(_csm.group(1))
                    if _ctgt in claimed:
                        # Two successors, one predecessor: the second claim
                        # breaks the directed chain. The flag names the
                        # later marker by run (or position when the marker
                        # carries no run).
                        _claimer = runs[_ci] if runs[_ci] is not None else f"marker {_ci + 1}"
                        flag(
                            "plan-review-no-lineage",
                            f"{t.path}:{s.line}: §{num} run {_claimer} re-supersedes {_csm.group(1)} (two successors claim one predecessor)",
                        )
                    else:
                        claimed.add(_ctgt)
                if len(chain) > 1:
                    for _ei in range(len(chain) - 1):
                        _esm = graph.SUPERSEDES_RE.search(chain[_ei])
                        if _esm is None:
                            continue
                        _past = {graph.normalize_run_id(r) for r in runs[:_ei] if r is not None}
                        if graph.normalize_run_id(_esm.group(1)) not in _past:
                            # Edges point strictly backward: the last marker
                            # keeps its specific unknown-run diagnostic
                            # above, and every earlier edge must name a run
                            # already in the chain. A forward or dangling
                            # edge is a cycle or a fabrication.
                            _whom = runs[_ei] if runs[_ei] is not None else f"marker {_ei + 1}"
                            flag(
                                "plan-review-no-lineage",
                                f"{t.path}:{s.line}: §{num} run {_whom} supersedes {_esm.group(1)} outside its past (edges point strictly backward)",
                            )
                    seen_runs = set()
                    for run in runs:
                        if run is not None:
                            nrun = graph.normalize_run_id(run)
                            if nrun in seen_runs:
                                flag(
                                    "plan-review-no-lineage",
                                    f"{t.path}:{s.line}: §{num} marker reuses run {run} (a rerun is a new run)",
                                )
                            seen_runs.add(nrun)
                    sm = graph.SUPERSEDES_RE.search(chain[-1])
                    prior = {graph.normalize_run_id(r) for r in runs[:-1] if r is not None}
                    if sm is None and not (prior_outage and follows):
                        # A rerun chains via supersedes, unless the marker
                        # right before it is an outage: outage markers
                        # carry no run to name, so the rerun carries
                        # `follows-outage` instead (the predecessor is
                        # immediate, never anywhere-upchain). A singleton
                        # marker is genesis: run, no supersedes, silent.
                        flag(
                            "plan-review-no-lineage",
                            f"{t.path}:{s.line}: §{num} rerun marker names no superseded run (supersedes <prior-run>)",
                        )
                    elif sm is not None and graph.normalize_run_id(sm.group(1)) not in prior:
                        flag(
                            "plan-review-no-lineage",
                            f"{t.path}:{s.line}: §{num} marker supersedes unknown run {sm.group(1)}",
                        )
                if follows and not prior_outage:
                    # Dangling on any chain length: a singleton carrying
                    # `follows-outage` follows nothing at all.
                    flag(
                        "plan-review-no-lineage",
                        f"{t.path}:{s.line}: §{num} marker follows no outage (dangling follows-outage)",
                    )
                if last_run is not None and graph.RUN_ID_SHAPE_RE.match(last_run):
                    manifest_runs = set()
                    for h in heads:
                        hsec = ftext[h.end():]
                        hnxt = re.search(r"^#{1,6}\s+", hsec, re.MULTILINE)
                        if hnxt:
                            hsec = hsec[: hnxt.start()]
                        hmm = graph.MANIFEST_RE.search(hsec)
                        if hmm and hmm.group(4):
                            manifest_runs.add(graph.normalize_run_id(hmm.group(4)))
                    if manifest_runs and graph.normalize_run_id(last_run) not in manifest_runs:
                        flag(
                            "plan-review-no-lineage",
                            f"{t.path}:{s.line}: §{num} marker run {last_run} matches no manifest run",
                        )
            marker_keys = set()
            for xm in graph.XREF_RE.finditer(marker):
                r = graph.resolve_ref(xm.group(0), t, by_key)
                if r and r[0] in by_id and r[1] in by_id[r[0]].sections:
                    marker_keys.add(r)
            for h in graph.PLAN_REVIEW_HEADING_RE.finditer(ftext):
                sec = ftext[h.end():]
                nxt = re.search(r"^#{1,6}\s+", sec, re.MULTILINE)
                if nxt:
                    sec = sec[: nxt.start()]
                block, _bproblem = graph.ledger_block(sec)
                if block is None:
                    continue
                for lr in graph.LEDGER_ROW_RE.finditer(block):
                    if lr.group(3).lower() != "filed":
                        continue
                    rest = block[lr.end() :].split("\n", 1)[0]
                    for xm in graph.XREF_RE.finditer(rest):
                        r = graph.resolve_ref(xm.group(0), t, by_key)
                        key = (
                            r
                            if r and r[0] in by_id and r[1] in by_id[r[0]].sections
                            else None
                        )
                        if key is None or key not in marker_keys:
                            # Quoted like message (a): a bare §ref here would
                            # trip per-section silence checks keyed on "§N ".
                            flag(
                                "stamp-no-plan-review",
                                f"{t.path}:{s.line}: §{num} filed target {xm.group(0)!r} not named in marker",
                            )

    # 18. plan-review records of post-cutoff stamps must be machine-shaped:
    # the query parses manifests and ledgers, so a record it cannot parse
    # is a record that silently drops out of governance. Every `Plan
    # review` section needs its `Manifest:` line and its `Ledger:`/`End
    # of ledger` block (rows are only rows inside the block); every
    # non-blank line inside the block must match the row shape.
    # Post-cutoff manifests carry the run; the optional field stays for
    # pre-cutoff records only, plus run-less chains (outage-only records
    # name no run by design). Date-scoped like rules 16-17. FATAL: the
    # fix is mechanical (shape the record) and the defect breaks the
    # query's contract.
    seen_18 = set()
    for t in todos:
        for num, s in sorted(t.sections.items()):
            if num not in t.verified_sections:
                continue
            if s.stamped_on is not None and s.stamped_on <= graph.PLAN_REVIEW_CUTOFF:
                continue
            fm = graph.FINDINGS_RE.search(getattr(s, "review_body", None) or "")
            if not fm or fm.group(1) in seen_18:
                continue
            try:
                ftext = (graph.TODO_DIR.parent / fm.group(1)).read_text(encoding="utf-8")
            except OSError:
                continue
            # One file, one report: the shape defect is the file's, not the
            # marker's, so sections sharing a findings file would
            # otherwise multi-fire it. First reporter wins in sorted
            # order, so the report is deterministic. (Rule 17b above is
            # per-marker and stays un-deduped: each marker's omission is
            # its own defect.)
            seen_18.add(fm.group(1))
            ftext, _u = graph.strip_fenced_code(ftext)
            for h in graph.PLAN_REVIEW_HEADING_RE.finditer(ftext):
                sec = ftext[h.end() :]
                nxt = re.search(r"^#{1,6}\s+", sec, re.MULTILINE)
                if nxt:
                    sec = sec[: nxt.start()]
                mm = graph.MANIFEST_RE.search(sec)
                if not mm:
                    flag(
                        "plan-review-malformed",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} Plan review section without a Manifest line",
                    )
                elif not mm.group(4):
                    # A run-less post-cutoff manifest names a review run
                    # nothing can resolve: the run field is optional for
                    # pre-cutoff records only, which skip this whole rule
                    # by stamp date above. Chains that carry no run stay
                    # exempt: an outage-only record has no run to name
                    # (run IDs for unruns are false attribution), and a
                    # run-less non-outage marker already fires its own
                    # lineage flag, so a second fire here would
                    # double-count one defect.
                    _chain = section_markers(t, num) or []
                    if any(graph.RUN_ID_RE.search(_c or "") for _c in _chain):
                        flag(
                            "plan-review-malformed",
                            f"{t.path}:{s.line}: §{num} findings {fm.group(1)} post-cutoff Manifest without a run (name the review run: run YYYYMMDD-DNN-TNN-SN-<family>[-rN])",
                        )
                block, problem = graph.ledger_block(sec)
                if block is None:
                    flag(
                        "plan-review-malformed",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} Plan review section {problem}",
                    )
                    continue
                for ln in block.splitlines():
                    if ln.strip() and not graph.LEDGER_ROW_RE.match(ln):
                        flag(
                            "plan-review-malformed",
                            f"{t.path}:{s.line}: §{num} findings {fm.group(1)} malformed ledger row: {ln.strip()[:80]}",
                        )
                # Row-legality for the content-bearing dispositions. A
                # `deferred` row must carry its owner, date, and trigger
                # (an unaccountable deferral satisfies the shape while
                # promising nothing); a `duplicate` row must name its
                # canonical finding; a `filed` row must name a target (a
                # filing that points nowhere is filed nowhere). An
                # `accepted` critical or major must carry its owner and
                # due date (open high-severity findings are accountable
                # or they sit invisible).
                for lr in graph.LEDGER_ROW_RE.finditer(block):
                    sev = lr.group(2).lower()
                    disp = lr.group(3).lower()
                    rest = block[lr.end():].split("\n", 1)[0]
                    if disp == "deferred":
                        if not (
                            "owner" in rest.lower()
                            and re.search(r"\d{4}-\d{2}-\d{2}", rest)
                            and "trigger" in rest.lower()
                        ):
                            flag(
                                "plan-review-malformed",
                                f"{t.path}:{s.line}: §{num} findings {fm.group(1)} deferred row without owner, date, and trigger: {lr.group(1)}",
                            )
                    elif disp == "duplicate":
                        if not re.search(r"\bPR\d+\b|[A-Z0-9]+-T\d+-S\d+-PR\d+", rest):
                            flag(
                                "plan-review-malformed",
                                f"{t.path}:{s.line}: §{num} findings {fm.group(1)} duplicate row names no canonical finding: {lr.group(1)}",
                            )
                    elif disp == "filed":
                        if not list(graph.XREF_RE.finditer(rest)):
                            flag(
                                "plan-review-malformed",
                                f"{t.path}:{s.line}: §{num} findings {fm.group(1)} filed row names no target: {lr.group(1)}",
                            )
                    elif disp == "accepted" and sev in ("critical", "major"):
                        if not (graph.OWNER_RE.search(rest) and graph.DUE_RE.search(rest)):
                            flag(
                                "plan-review-malformed",
                                f"{t.path}:{s.line}: §{num} findings {fm.group(1)} accepted {sev} row without owner and due: {lr.group(1)}",
                            )

    # 19. filed rows trace back from the target: every filed row's ID
    # must appear in its target's file, word-bounded so PR1 never matches
    # inside PR10. A filing untraceable from the target side cannot
    # attribute remediation to the finding. Date-scoped like rules 16-18.
    # Unresolvable targets are skipped: rule 17 already convicts the
    # marker that names them. File-scoped with first-reporter dedup like
    # rules 18 and 20 (unlike 17b, whose claim each marker owns): the
    # missing back-link is a property of the row and target, identical
    # for every section over a shared file.
    target_texts: dict[str, str] = {}
    seen_19 = set()
    for t in todos:
        for num, s in sorted(t.sections.items()):
            if num not in t.verified_sections:
                continue
            if s.stamped_on is not None and s.stamped_on <= graph.PLAN_REVIEW_CUTOFF:
                continue
            fm = graph.FINDINGS_RE.search(getattr(s, "review_body", None) or "")
            if not fm or fm.group(1) in seen_19:
                continue
            try:
                ftext = (graph.TODO_DIR.parent / fm.group(1)).read_text(encoding="utf-8")
            except OSError:
                continue
            seen_19.add(fm.group(1))
            ftext, _u = graph.strip_fenced_code(ftext)
            for h in graph.PLAN_REVIEW_HEADING_RE.finditer(ftext):
                sec = ftext[h.end():]
                nxt = re.search(r"^#{1,6}\s+", sec, re.MULTILINE)
                if nxt:
                    sec = sec[: nxt.start()]
                block, _bproblem = graph.ledger_block(sec)
                if block is None:
                    continue
                for lr in graph.LEDGER_ROW_RE.finditer(block):
                    if lr.group(3).lower() != "filed":
                        continue
                    rest = block[lr.end():].split("\n", 1)[0]
                    for xm in graph.XREF_RE.finditer(rest):
                        r = graph.resolve_ref(xm.group(0), t, by_key)
                        if not r or r[0] not in by_id or r[1] not in by_id[r[0]].sections:
                            continue
                        tpath = by_id[r[0]].path
                        if tpath not in target_texts:
                            try:
                                target_texts[tpath] = (graph.TODO_DIR.parent / tpath).read_text(
                                    encoding="utf-8"
                                )
                            except OSError:
                                target_texts[tpath] = ""
                        if not re.search(r"\b" + re.escape(lr.group(1)) + r"\b", target_texts[tpath]):
                            tlabel = f"{by_id[r[0]].path} §{r[1]}"
                            flag(
                                "filed-target-no-backlink",
                                f"{t.path}:{s.line}: §{num} filed row {lr.group(1)} has no back-link in {tlabel}",
                            )

    # 20. finding IDs unique per ledger: the same ID twice in one file is
    # FATAL even with identical targets, because the second row reads as
    # a second finding and remediation attaches to the wrong one.
    # Multi-target findings ride one row naming every target (clearance
    # already requires all of them), so split rows are never the honest
    # shape. IDs compare case-insensitively (PR1 and pr1 collide).
    # File-scoped with first-reporter dedup like rule 18 (the defect is
    # the file's). Date-scoped like rules 16-18.
    seen_20 = set()
    for t in todos:
        for num, s in sorted(t.sections.items()):
            if num not in t.verified_sections:
                continue
            if s.stamped_on is not None and s.stamped_on <= graph.PLAN_REVIEW_CUTOFF:
                continue
            fm = graph.FINDINGS_RE.search(getattr(s, "review_body", None) or "")
            if not fm or fm.group(1) in seen_20:
                continue
            try:
                ftext = (graph.TODO_DIR.parent / fm.group(1)).read_text(encoding="utf-8")
            except OSError:
                continue
            seen_20.add(fm.group(1))
            ftext, _u = graph.strip_fenced_code(ftext)
            ids: dict[str, str] = {}
            flagged: set[str] = set()
            for h in graph.PLAN_REVIEW_HEADING_RE.finditer(ftext):
                sec = ftext[h.end():]
                nxt = re.search(r"^#{1,6}\s+", sec, re.MULTILINE)
                if nxt:
                    sec = sec[: nxt.start()]
                block, _bproblem = graph.ledger_block(sec)
                if block is None:
                    continue
                for lr in graph.LEDGER_ROW_RE.finditer(block):
                    key = lr.group(1).lower()
                    if key in ids and key not in flagged:
                        flagged.add(key)
                        flag(
                            "plan-review-duplicate-id",
                            f"{t.path}:{s.line}: §{num} findings {fm.group(1)} duplicate finding ID {lr.group(1)}",
                        )
                    ids.setdefault(key, lr.group(1))

    # 21. a reopen voids proof downstream: the body must read `<YYYY-MM-DD>
    # | <finding ref> | <reason>` with a resolvable §ref (the audit locus
    # whose finding voids this stamp); the row must be [ ] (a checked
    # reopened row claims shipped work on voided proof); and no verified
    # section may keep a reopened section anywhere in its Depends closure
    # (the cascade is recursive: a verified dependent of a verified
    # dependent builds on voided proof exactly like a direct one, so
    # dependents park until the root re-stamps, bottom-up). No date
    # scope: the mechanism is new, so nothing predates it.
    reopened = {
        (t.id, num)
        for t in todos
        for num, s in t.sections.items()
        if (getattr(s, "reopened_body", None) or "").strip()
    }
    for t in todos:
        for num, s in sorted(t.sections.items()):
            body = (getattr(s, "reopened_body", None) or "").strip()
            if not body:
                continue
            m = graph.REOPENED_BODY_RE.match(body)
            ref_ok = False
            if m:
                for xm in graph.XREF_RE.finditer(m.group("rest")):
                    r = graph.resolve_ref(xm.group(0), t, by_key)
                    if r and r[0] in by_id and r[1] in by_id[r[0]].sections:
                        ref_ok = True
                        break
            if not m or not ref_ok:
                flag(
                    "stamp-reopened",
                    f"{t.path}:{s.line}: §{num} Reopened line outside `<date> | <finding ref> | <reason>` with a resolvable ref",
                )
            if s.status == "x":
                flag(
                    "stamp-reopened",
                    f"{t.path}:{s.line}: §{num} reopened but still [x]: uncheck the row (the stamp is void)",
                )
    rev_deps: dict[tuple[str, int], set[tuple[str, int]]] = {}
    for t in todos:
        for num, s in t.sections.items():
            for raw in s.depends_on:
                r = graph.resolve_ref(raw, t, by_key)
                if r and r[0] in by_id and r[1] in by_id[r[0]].sections:
                    rev_deps.setdefault(r, set()).add((t.id, num))
    for root in sorted(reopened):
        # The cascade walks the whole reverse closure, not just direct
        # dependents: every verified section downstream of the root parks.
        reached: set[tuple[str, int]] = set()
        queue = sorted(rev_deps.get(root, ()))
        while queue:
            key = queue.pop(0)
            if key in reached:
                continue
            reached.add(key)
            queue.extend(sorted(rev_deps.get(key, ())))
        for t in todos:
            for num, s in sorted(t.sections.items()):
                if (t.id, num) in reached and num in t.verified_sections:
                    # Quoted like rule 17b's message (a): a bare §ref here
                    # would trip per-section silence checks keyed on "§N ".
                    flag(
                        "stamp-reopened",
                        f"{t.path}:{s.line}: §{num} still stamped while {root[0]} '§{root[1]}' is reopened: park until it re-stamps",
                    )

    # 22. ledger rows keep their history: every ledger row's disposition
    # is diffed against the committed record, and forbidden transitions
    # fail. Triage stays open (`accepted` may move anywhere; a correction
    # is not a rewrite), `deferred` may only file, and `filed`,
    # `rejected`, and `duplicate` are terminal: later evidence against a
    # terminal row lands as a NEW row naming the superseded ID
    # (amendment by supersession, never by editing the old row), so a
    # row that vanishes between HEAD and the tree fails too. A new ID
    # (rerun continuation numbers past the previous max) is always
    # silent. No date scope: old ledgers deserve the same protection.
    # Uncommitted findings (no HEAD bytes) skip: without history nothing
    # is provable.
    HISTORY_OK = {
        "accepted": {"accepted", "filed", "deferred", "rejected", "duplicate"},
        "deferred": {"deferred", "filed"},
        "filed": {"filed"},
        "rejected": {"rejected"},
        "duplicate": {"duplicate"},
    }
    seen_22 = set()
    for t in todos:
        for num, s in sorted(t.sections.items()):
            if num not in t.verified_sections:
                continue
            fm = graph.FINDINGS_RE.search(getattr(s, "review_body", None) or "")
            if not fm or fm.group(1) in seen_22:
                continue
            try:
                ftext = (graph.TODO_DIR.parent / fm.group(1)).read_text(encoding="utf-8")
            except OSError:
                continue
            committed = graph.git_file_at("HEAD", fm.group(1))
            if committed is None:
                continue
            seen_22.add(fm.group(1))

            def _ledger_ids(text: str) -> dict[str, str]:
                ids: dict[str, str] = {}
                stripped, _u = graph.strip_fenced_code(text)
                for h in graph.PLAN_REVIEW_HEADING_RE.finditer(stripped):
                    hsec = stripped[h.end():]
                    hnxt = re.search(r"^#{1,6}\s+", hsec, re.MULTILINE)
                    if hnxt:
                        hsec = hsec[: hnxt.start()]
                    # Rows inside the block when one exists, else by row
                    # shape: a pre-block committed record still diffs row
                    # for row across the migration, and a tree that merely
                    # lost its block markers reports once (rule 18), not
                    # once per row here.
                    hblock, _hp = graph.ledger_block(hsec)
                    for lr in graph.LEDGER_ROW_RE.finditer(hblock if hblock is not None else hsec):
                        ids[lr.group(1).lower()] = lr.group(3).lower()
                return ids

            now_ids = _ledger_ids(ftext)
            was_ids = _ledger_ids(committed)
            for gone in sorted(set(was_ids) - set(now_ids)):
                flag(
                    "ledger-history-violation",
                    f"{t.path}:{s.line}: §{num} findings {fm.group(1)} ledger row {gone} vanished "
                    f"against the committed record (amend via a new row, never by deleting)",
                )
            for rid in sorted(set(now_ids) & set(was_ids)):
                if now_ids[rid] not in HISTORY_OK.get(was_ids[rid], set()):
                    flag(
                        "ledger-history-violation",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} ledger row {rid} moved "
                        f"{was_ids[rid]} -> {now_ids[rid]} against the committed record "
                        f"(terminal rows amend via a new row)",
                    )

    # 23. provenance binds live quotes to runs: every post-cutoff findings
    # file needs its `Provenance:` lines, each carrying all seven fields
    # in order (candidate, command, exit, tool, digest, path, run). The
    # run must be shaped and carried by a marker of the reviewing
    # section; the candidate must resolve in git; the path must exist in
    # the tree. Malformed, missing, run-less, unresolving, or dangling
    # provenance fails closed. First reporter wins per file (the defect
    # is the file's). Date-scoped: pre-cutoff files predate the mandate.
    # No HEAD legs: presence and shape only, never history.
    seen_23 = set()
    for t in todos:
        for num, s in sorted(t.sections.items()):
            if num not in t.verified_sections:
                continue
            if s.stamped_on is not None and s.stamped_on <= graph.PLAN_REVIEW_CUTOFF:
                continue
            fm = graph.FINDINGS_RE.search(getattr(s, "review_body", None) or "")
            if not fm or fm.group(1) in seen_23:
                continue
            try:
                ftext = (graph.TODO_DIR.parent / fm.group(1)).read_text(encoding="utf-8")
            except OSError:
                continue
            seen_23.add(fm.group(1))
            ftext, _u = graph.strip_fenced_code(ftext)
            # Marker runs of this section: every provenance run must be
            # one a marker of the reviewing section carries (a run no
            # marker carries attests nothing for this review). Range
            # stamps read their parsed fallback via the shared slice.
            chain = section_markers(t, num) or []
            marker_runs = set()
            for body in chain:
                rm = graph.RUN_ID_RE.search(body)
                if rm:
                    marker_runs.add(graph.normalize_run_id(rm.group(1)))
            provs: list[tuple[str, str, str, str, str, str, str]] = []
            malformed = False
            for ln in ftext.splitlines():
                if not ln.startswith("Provenance:"):
                    continue
                pm = graph.PROVENANCE_RE.match(ln)
                if pm is None:
                    malformed = True
                    break
                provs.append(
                    (
                        pm.group(1),
                        pm.group(2),
                        pm.group(3),
                        pm.group(4),
                        pm.group(5),
                        pm.group(6),
                        pm.group(7),
                    )
                )
            if malformed or not provs:
                flag(
                    "provenance-malformed",
                    f"{t.path}:{s.line}: §{num} findings {fm.group(1)} has "
                    + (
                        "a malformed Provenance: line (seven fields in order: candidate, command, exit, tool, digest, path, run)"
                        if malformed
                        else "no Provenance: line (every post-cutoff findings file names its runs)"
                    ),
                )
                continue
            for cand, _cmd, _exit, _tool, _digest, ppath, run in provs:
                if not graph.RUN_ID_SHAPE_RE.match(run):
                    flag(
                        "provenance-malformed",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} provenance run {run!r} is outside the run-ID shape",
                    )
                elif graph.normalize_run_id(run) not in marker_runs:
                    flag(
                        "provenance-malformed",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} provenance run {run} "
                        f"is carried by no marker of this section",
                    )
                if graph.git_resolves(cand) is not True:
                    flag(
                        "provenance-malformed",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} provenance candidate {cand} resolves to nothing",
                    )
                if not (graph.TODO_DIR.parent / ppath).exists():
                    flag(
                        "provenance-malformed",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} provenance path {ppath} does not exist",
                    )

    # 24. risk acceptances terminate escalations in a checkable shape: each
    # `Risk accepted:` line carries its target, approver, action owner,
    # record date, expiry, review date, evidence commit, optional
    # supersedes link, and rationale. Legs: shape, target coverage (a
    # finding ID, a shaped run, or an outage instance), forward
    # chronology (recorded <= expires), review-inside-window (recorded
    # <= review <= expires), evidence equals the current owning-record
    # bytes at the recorded commit (a silent edit voids and must renew),
    # and chain integrity (a `supersedes <date>` link names an earlier
    # record on the same target, chains never branch or cycle).
    # Findings-file scoped like rule 18 (acceptances live beside the
    # escalations they terminate); first reporter wins per file. No date
    # scope: a waiver is current procedure whenever it is written.
    seen_24 = set()
    for t in todos:
        for num, s in sorted(t.sections.items()):
            if num not in t.verified_sections:
                continue
            fm = graph.FINDINGS_RE.search(getattr(s, "review_body", None) or "")
            if not fm or fm.group(1) in seen_24:
                continue
            try:
                ftext = (graph.TODO_DIR.parent / fm.group(1)).read_text(encoding="utf-8")
            except OSError:
                continue
            seen_24.add(fm.group(1))
            raw_text = ftext
            ftext, _u = graph.strip_fenced_code(ftext)
            accs = graph.acceptance_lines(ftext)
            for ln in ftext.splitlines():
                if ln.startswith("Risk accepted:") and graph.RISK_ACCEPTED_RE.match(ln) is None:
                    flag(
                        "risk-acceptance-malformed",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} malformed Risk accepted line: {ln.strip()[:100]}",
                    )
            for tgt, appr, own, exp, rec, rvw, evi, sup, rat, kind in accs:
                if rec > exp:
                    flag(
                        "risk-acceptance-malformed",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} acceptance for {tgt} expires {exp} before it is recorded {rec}",
                    )
                if rvw < rec or rvw > exp:
                    flag(
                        "risk-acceptance-malformed",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} acceptance for {tgt} reviewed {rvw} outside its record-expiry window {rec}..{exp}",
                    )
                owner_path = fm.group(1) if kind == "finding" else t.path
                owner_text = raw_text if kind == "finding" else target_texts.get(
                    t.path,
                    (lambda: target_texts.setdefault(
                        t.path,
                        (
                            (graph.TODO_DIR.parent / t.path).read_text(encoding="utf-8")
                            if (graph.TODO_DIR.parent / t.path).exists()
                            else ""
                        ),
                    ))(),
                )
                if not graph.evidence_fresh(evi, owner_path, owner_text):
                    flag(
                        "risk-acceptance-silent-edit",
                        f"{t.path}:{s.line}: §{num} findings {fm.group(1)} acceptance for {tgt} "
                        f"evidence {evi} no longer matches the owning record (renew via a superseding record)",
                    )
            # Chain integrity: same-target links only, strictly backward,
            # acyclic, unbranched. Malformed sup dates (unshaped or absent
            # from the file's records on that target) fail here, not as
            # silent history.
            by_target: dict[str, list[tuple[str, str]]] = {}
            for tgt, _appr, _own, _exp, rec, _rvw, _evi, sup, _rat, _kind in accs:
                by_target.setdefault(tgt.lower(), []).append((rec, sup))
            for tgt, chain in sorted(by_target.items()):
                records = {rec for rec, _sup in chain}
                succ: dict[str, str] = {}
                for rec, sup in chain:
                    if not sup:
                        continue
                    if sup not in records:
                        flag(
                            "risk-acceptance-chain-broken",
                            f"{t.path}:{s.line}: §{num} findings {fm.group(1)} acceptance for {tgt} "
                            f"supersedes {sup}, which names no record on this target",
                        )
                        continue
                    if sup >= rec:
                        flag(
                            "risk-acceptance-chain-broken",
                            f"{t.path}:{s.line}: §{num} findings {fm.group(1)} acceptance for {tgt} "
                            f"supersedes {sup}, which is not earlier than {rec} (edges point strictly backward)",
                        )
                        continue
                    if sup in succ:
                        flag(
                            "risk-acceptance-chain-broken",
                            f"{t.path}:{s.line}: §{num} findings {fm.group(1)} two acceptances for {tgt} "
                            f"supersede {sup} (the chain branches)",
                        )
                        continue
                    succ[sup] = rec
                seen_c: set[str] = set()
                # Cycle walk from every head: a link set with no head is a
                # pure cycle, so heads-first would miss it.
                for rec, sup in chain:
                    cur: str | None = sup or None
                    path: list[str] = [rec]
                    while cur is not None and cur in records and cur not in seen_c:
                        if cur in path:
                            flag(
                                "risk-acceptance-chain-broken",
                                f"{t.path}:{s.line}: §{num} findings {fm.group(1)} acceptance chain for {tgt} "
                                f"cycles at {cur}",
                            )
                            break
                        path.append(cur)
                        nxt = next((s2 for r2, s2 in chain if r2 == cur), "")
                        cur = nxt or None
                    seen_c.update(path)

    # 25. ledger amendments link or fail: a row carrying `supersedes
    # <finding-id>` must name another row of the same block in the same
    # review namespace, and neither end may sit in a supersedes cycle.
    # Orphaned links, cross-namespace links, and cycles fail: an
    # amendment that names nothing (or contradicts itself) leaves the
    # chain head ambiguous. File-scoped with first-reporter dedup like
    # rules 18-20. No date scope: amendment history is current procedure
    # whenever it is written.
    seen_25 = set()
    for t in todos:
        for num, s in sorted(t.sections.items()):
            if num not in t.verified_sections:
                continue
            fm = graph.FINDINGS_RE.search(getattr(s, "review_body", None) or "")
            if not fm or fm.group(1) in seen_25:
                continue
            try:
                ftext = (graph.TODO_DIR.parent / fm.group(1)).read_text(encoding="utf-8")
            except OSError:
                continue
            seen_25.add(fm.group(1))
            ftext, _u = graph.strip_fenced_code(ftext)
            for h in graph.PLAN_REVIEW_HEADING_RE.finditer(ftext):
                sec = ftext[h.end():]
                nxt = re.search(r"^#{1,6}\s+", sec, re.MULTILINE)
                if nxt:
                    sec = sec[: nxt.start()]
                block, _bproblem = graph.ledger_block(sec)
                if block is None:
                    continue
                links = graph.ledger_supersedes(block)
                _valid, cyclic = graph.ledger_supersession(block)
                ids = {lr.group(1).lower() for lr in graph.LEDGER_ROW_RE.finditer(block)}
                for rid, tgt in sorted(links.items()):
                    if rid in cyclic:
                        flag(
                            "ledger-supersession-broken",
                            f"{t.path}:{s.line}: §{num} findings {fm.group(1)} row {rid} sits in a supersedes cycle",
                        )
                    elif tgt.lower() not in ids:
                        flag(
                            "ledger-supersession-broken",
                            f"{t.path}:{s.line}: §{num} findings {fm.group(1)} row {rid} supersedes {tgt}, which names no row of its block",
                        )
                    elif graph.finding_namespace(tgt) != graph.finding_namespace(rid):
                        flag(
                            "ledger-supersession-broken",
                            f"{t.path}:{s.line}: §{num} findings {fm.group(1)} row {rid} supersedes {tgt} across review namespaces",
                        )

    # 26. skill-to-plan citations resolve: every full section ref in a skill
    # names a live section, or the skill teaches a dead address (D00 T04 §9).
    # Short forms are banned outright (D00 T04 §13): a bare §N has no
    # origin in a skill file, and TNN §N and file §N are shorthand.
    # The scan root rides the graph global so fixtures substitute their own.
    if todos:
        origin = todos[0]
        skills_dir = getattr(graph, "SKILLS_DIR", graph.REPO / ".claude" / "skills")
        if skills_dir.is_dir():
            for path in sorted(skills_dir.glob("*/SKILL.md")):
                try:
                    text = path.read_text(encoding="utf-8")
                except OSError:
                    continue
                for lineno, line in enumerate(text.splitlines(), 1):
                    for cite in graph.SKILL_CITE_RE.finditer(line):
                        ref = cite.group(0)
                        r = graph.resolve_ref(ref, origin, by_key)
                        target = by_id.get(r[0]) if r else None
                        if target is None or r[1] not in target.sections:
                            flag(
                                "skill-citation-unresolved",
                                f"{path}:{lineno}: skill cites {ref}, which resolves to no live section",
                            )
                    full_spans = [m.span() for m in graph.SKILL_CITE_RE.finditer(line)]
                    for short in graph.SKILL_SHORT_RE.finditer(line):
                        form = short.group(0)
                        # A full ref with wide spacing (tabs, doubled
                        # spaces) is legal per SKILL_CITE_RE's \s+, but the
                        # short-form lookbehinds only exclude single-space
                        # spans: anything inside a full ref's span stays.
                        if any(s <= short.start() and short.end() <= e
                               for s, e in full_spans):
                            continue
                        flag(
                            "skill-citation-short-form",
                            f"{path}:{lineno}: skill cites short form {form}, use a full DNN TNN §N ref",
                        )

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
