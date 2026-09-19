"""Review-prompt construction and reviewer-output validation.

Ported from ScratchPad (there D00 T01 §17): the section and item numbers in
the comments below are that section's, kept so the rationale trail survives
the port. Resolute's `review-todo-section` skill is the caller.

Prompts are ephemeral `/tmp` files, but the rules that build them are
checked-in code so a fixture can prove them: delimiter tags are unique per
prompt (item 14: fixed delimiters are injectable from TODO text), prompt
bytes are canonicalized before counting (item 5: UTF-8/LF, so Windows and
WSL checkouts agree), and reviewer output is validated whole (item 15: one
valid-looking row must not mask malformed trailing findings).
"""

import hashlib
import re
import secrets

PANEL_LENSES = ("adversarial", "consistency", "integration", "record")
PANEL_VERDICTS = ("approve", "needs-attention", "advisory")
# Runner-output verdicts only (the prompt mandates bare `**<lens>:
# <verdict>**` headers, with nothing else on the line except an optional
# finding count): the line opens with `**`, names one lens and one
# verdict, and ends. The count is one alternation taking exactly one
# count in either Markdown position (`**v (2)**` or `**v** (2)`; models
# emit both, so both are legal), never both: two optional groups once
# accepted `**v (2)** (3)`. End-anchoring is what keeps a detail line
# quoting a header (`**record: approve** claim is stale`, with or
# without a count) a detail; dash-, backtick-, or bare-lens-opened
# lines are details, never verdicts. Stated residual: a detail line
# consisting of exactly a bare header (count or not) for an
# already-seen lens still reads as a repeat (quoting with any
# surrounding prose is safe).
# Count grammar (D00 T01 §19 item 20, bounded D00 T01 §23): ASCII
# digits only (`\d` would admit Unicode digits), no sign, no
# whitespace, no leading zeros (the canonical form is bare `0` or a
# nonzero digit first), zero allowed, at most four digits (no review
# round holds ten thousand findings; the cap keeps a hostile count
# from reaching `int()` unbounded, which raises past 4300 digits
# instead of failing closed).
_COUNT_MAX_DIGITS = 4
_COUNT_INNER = r"(?:0|[1-9][0-9]{0," + str(_COUNT_MAX_DIGITS - 1) + r"})"
# Reviewer-output bounds (D00 T01 §23): a hostile or malformed
# reviewer can exhaust parser resources before semantic comparison,
# so both checkers refuse oversized output first. The caps are
# generous multiples of any plausible review (a panel round is four
# verdicts plus details; a plan round is one line per finding), so a
# legitimate reviewer never nears them.
OUTPUT_MAX_BYTES = 2**20
OUTPUT_MAX_LINES = 100_000
_PANEL_LINE_RE = re.compile(
    r"^\s*\*{2}\s*(adversarial|consistency|integration|record)\*{0,2}\s*:?\s*"
    r"(approve|needs-attention|advisory)(?:\s*\((?P<c1>" + _COUNT_INNER + r")\)\*{0,2}|\*{0,2}\s*\((?P<c2>"
    + _COUNT_INNER + r")\)|\*{0,2})\s*$"
)
# The same verdict shape with an over-long count (D00 T01 §23 review
# R1): a 5-digit count is not a verdict (the grammar caps at 4), but
# failing it as a stray line would name neither the count nor the cap,
# so the checker recognizes the shape and says which bound broke.
_LONG_DIGITS = r"[0-9]{%d,}" % (_COUNT_MAX_DIGITS + 1)
_PANEL_LONG_COUNT_RE = re.compile(
    r"^\s*\*{2}\s*(?:adversarial|consistency|integration|record)\*{0,2}\s*:?\s*"
    r"(?:approve|needs-attention|advisory)(?:\s*\(" + _LONG_DIGITS + r"\)\*{0,2}|\*{0,2}\s*\(" + _LONG_DIGITS + r"\))\s*$"
)
# A declared count is cross-checked against the findings it claims
# (D00 T01 §19 item 19): a finding is one numbered item (`1. ...`), one
# per line, so the count must equal the numbered-item tally under its
# verdict. Unnumbered detail lines are prose, never findings: they ride
# along without moving the tally. No declared count, no check: details
# in any shape pass, as before. ASCII digits like the count grammar: a
# Unicode-digit item is prose, not a finding.
_FINDING_ITEM_RE = re.compile(r"^\s*[0-9]+\.\s")


def unique_tag(prefix: str) -> str:
    """A delimiter tag no TODO text can predict: prefix plus 64 random bits."""
    return f"{prefix}-{secrets.token_hex(8)}"


def fence_chunks(tag: str, chunks: list[tuple[str, str]]) -> str:
    """Wrap (title, body) chunks in tagged delimiter lines.

    The tag is the control: a fake `--- SECTION ---` inside untrusted TODO
    text carries no tag and matches nothing.
    """
    parts = []
    for title, body in chunks:
        parts.append(f"--- {title} [{tag}] ---")
        parts.append(body.rstrip("\n"))
    parts.append(f"--- END [{tag}] ---")
    return "\n".join(parts) + "\n"


# Delimiter-tag contract (D00 T01 §19 item 11): 64 bits of entropy
# (`secrets.token_hex(8)`), collision-checked against every payload
# chunk, with bounded retries. A tag that appears in the payload would
# let TODO text forge structure, so generation retries until the tag is
# absent (a collision at 64 bits is a broken RNG, not luck, which is
# why exhaustion raises instead of degrading to a weak tag).
TAG_ENTROPY_BITS = 64
TAG_MAX_ATTEMPTS = 100


def fence_chunks_checked(prefix: str, chunks: list[tuple[str, str]]) -> tuple[str, str]:
    """Fence chunks under a fresh tag proven absent from the payload.

    Returns (tag, prompt). Raises RuntimeError if every attempt collides.
    """
    bodies = [body for _, body in chunks]
    for _ in range(TAG_MAX_ATTEMPTS):
        tag = unique_tag(prefix)
        if all(tag not in body for body in bodies):
            return tag, fence_chunks(tag, chunks)
    raise RuntimeError(f"tag collided with the payload {TAG_MAX_ATTEMPTS} times; refusing a weak tag")


def canonical_prompt_bytes(text: str) -> bytes:
    """Prompt bytes as the manifest counts them: LF newlines, UTF-8."""
    return text.replace("\r\n", "\n").replace("\r", "\n").encode("utf-8")


# Completeness manifest (D00 T04 §9): the fence emits what the session
# sent (byte count, file list, sha, base/head when the chunks are a
# diff), and the reviewer opens its output with a receipt quoting the
# manifest sha plus the closing END tag. A tail-truncated prompt never
# shows the reviewer its END line, so the receipt is unforgeable from
# a cut stream and the checker fails the round instead of approving
# from partial input. The model never counts bytes: it copies two
# strings it saw, and the byte count stays the session's own record.
MANIFEST_RE = re.compile(
    r"^MANIFEST\s+bytes=(?P<bytes>[0-9]+)\s+files=(?P<files>[0-9]+)\s+"
    r"sha=(?P<sha>[0-9a-f]{64})(?P<rest>.*)$"
)
# Chunks carrying a unified diff name it in the title (CANDIDATE DIFF,
# STAGED STAMP); only those are scanned for changed files, so a `+++`
# line in prose can never forge the file list.
_DIFF_TITLE_RE = re.compile(r"DIFF|PATCH|STAMP")
_DIFF_FILE_RE = re.compile(r"^diff --git a/\S+ b/(?P<path>\S+)\s*$", re.MULTILINE)
RECEIPT_RE = re.compile(r"^RECEIPT\s+sha=(?P<sha>[0-9a-f]{64})\s+end=(?P<end>\S+)\s*$")
TAG_LINE_RE = re.compile(r"^TAG\s+(?P<tag>\S+)\s*$")


def build_manifest(tag: str, chunks: list[tuple[str, str]],
                   base: str | None = None, head: str | None = None) -> tuple[str, str]:
    """Fence chunks and describe them. Returns (manifest_line, fenced_body).

    The manifest covers the fenced body only, never itself: it is
    emitted ahead of the body and counts the bytes that follow it.
    """
    body = fence_chunks(tag, chunks)
    digest = hashlib.sha256(canonical_prompt_bytes(body)).hexdigest()
    count = len(canonical_prompt_bytes(body))
    titles = "|".join(title for title, _ in chunks)
    line = f"MANIFEST bytes={count} files={len(chunks)} sha={digest} titles={titles}"
    diff_files = []
    for title, chunk_body in chunks:
        if _DIFF_TITLE_RE.search(title):
            diff_files.extend(m.group("path") for m in _DIFF_FILE_RE.finditer(chunk_body))
    if diff_files:
        line += " diff-files=" + "|".join(diff_files)
    if base is not None:
        line += f" base={base}"
    if head is not None:
        line += f" head={head}"
    return line, body


def parse_manifest_file(text: str) -> tuple[str, str]:
    """Read (tag, sha) from saved TAG + MANIFEST lines. Raises ValueError."""
    tag = sha = None
    for line in text.splitlines():
        tm = TAG_LINE_RE.match(line.strip())
        if tm:
            tag = tm.group("tag")
        mm = MANIFEST_RE.match(line.strip())
        if mm:
            sha = mm.group("sha")
    if tag is None or sha is None:
        raise ValueError("manifest file carries no TAG + MANIFEST pair")
    return tag, sha


def strip_receipt(text: str, tag: str, sha: str) -> tuple[str | None, str]:
    """Verify the opening receipt against the manifest. Returns (rest, \"\")
    on success, (None, reason) when the receipt is missing or wrong."""
    lines = text.splitlines()
    first = next((i for i, ln in enumerate(lines) if ln.strip()), None)
    if first is None:
        return None, "empty output carries no receipt"
    m = RECEIPT_RE.match(lines[first].strip())
    if m is None:
        return None, f"line {first + 1} is not a receipt: {lines[first].strip()[:80]}"
    if m.group("sha") != sha:
        return None, f"line {first + 1} receipts sha {m.group('sha')[:12]}..., manifest wants {sha[:12]}..."
    if m.group("end") != tag:
        return None, f"line {first + 1} receipts end {m.group('end')!r}, manifest tag is {tag!r}"
    rest = [ln for j, ln in enumerate(lines) if j != first]
    return "\n".join(rest) + ("\n" if rest else ""), ""


def _output_within_bounds(text: str) -> tuple[bool, str] | None:
    """The size gate both checkers run before semantic comparison, or
    None when the output fits. Bytes count UTF-8; lines count newline
    splits; both bounds are inclusive. The byte measure encodes in
    chunks with early exit, never a second full copy of the input, so
    a hostile string costs the gate bounded extra memory; the line
    split only runs once bytes fit, so it is bounded too."""
    total = 0
    for i in range(0, len(text), 8192):
        total += len(text[i:i + 8192].encode("utf-8"))
        if total > OUTPUT_MAX_BYTES:
            return False, f"output exceeds {OUTPUT_MAX_BYTES} bytes"
    if len(text.splitlines()) > OUTPUT_MAX_LINES:
        return False, f"output exceeds {OUTPUT_MAX_LINES} lines"
    return None


def check_panel_output(text: str, manifest: tuple[str, str] | None = None) -> tuple[bool, str]:
    """Whole-output validation for a panel round: every lens verdicts
    exactly once, and every other non-blank line is a detail line under the
    most recent non-approve verdict (an approve takes no details, and
    nothing precedes the first verdict). A declared finding count must
    equal the numbered-item tally under its verdict. With a manifest the
    output must open with its receipt, proving the reviewer saw the
    stream through the END line. Returns (ok, reason); the first bad
    line is the reason, so trailing garbage after four good verdicts
    still fails instead of masking."""
    bounded = _output_within_bounds(text)
    if bounded is not None:
        return bounded
    if manifest is not None:
        text, reason = strip_receipt(text, manifest[0], manifest[1])
        if text is None:
            return False, reason
    seen: dict[str, int] = {}
    detail_open = False
    declared: int | None = None
    tally = 0
    open_lens = ""
    open_line = 0

    def close_block() -> tuple[bool, str] | None:
        if declared is not None and tally != declared:
            return False, (
                f"line {open_line} declares {declared} findings "
                f"but {tally} numbered items follow under {open_lens}"
            )
        return None

    for lineno, line in enumerate(text.splitlines(), start=1):
        if not line.strip():
            continue
        m = _PANEL_LINE_RE.match(line)
        if m:
            bad = close_block()
            if bad:
                return bad
            lens = m.group(1)
            if lens in seen:
                return False, f"line {lineno} repeats the {lens} verdict (first at line {seen[lens]})"
            seen[lens] = lineno
            detail_open = m.group(2) != "approve"
            raw = m.group("c1") or m.group("c2")
            # An approve takes no details, so its tally is fixed at
            # zero: `approve (0)` passes, `approve (2)` fails.
            declared = int(raw) if raw is not None else None
            tally = 0
            open_lens, open_line = lens, lineno
            continue
        if _PANEL_LONG_COUNT_RE.match(line):
            return False, f"line {lineno} count exceeds {_COUNT_MAX_DIGITS} digits"
        if not seen:
            return False, f"line {lineno} precedes the first verdict: {line.strip()[:80]}"
        if not detail_open:
            return False, f"line {lineno} is not a verdict or finding detail: {line.strip()[:80]}"
        if _FINDING_ITEM_RE.match(line):
            tally += 1
    bad = close_block()
    if bad:
        return bad
    missing = [lens for lens in PANEL_LENSES if lens not in seen]
    if missing:
        return False, f"missing verdicts: {', '.join(missing)}"
    return True, "four lenses, one verdict each"


def next_run_id(todo_path: str, section: int, family: str, date: str, *texts: str) -> str:
    """The canonical run ID for a review run (D00 T01 §20 item 1).

    The base is `<YYYYMMDD>-D<dom>-T<num>-S<section>-<family>`, derived
    from the TODO path (`todo/<dom>-<name>/TODO-<num>-*.md`); the suffix
    walks past every run already claimed in the given texts (marker and
    manifest lines): no claim, no suffix, else `-r<max+1>`. One
    generator, so two writers cannot mint competing identities by hand.
    Raises ValueError on an off-shape input. Numbering: within one date
    base the bare base is run 1 and `-rN` is run N for N >= 2, so a
    claimed base (or `-r1`, its accepted synonym) yields `-r2` next; a
    later day mints a bare base again.
    """
    if not re.fullmatch(r"[a-z0-9]+", family):
        raise ValueError(f"family {family!r} is outside [a-z0-9]+")
    if not re.fullmatch(r"\d{8}", date):
        raise ValueError(f"date {date!r} is outside YYYYMMDD")
    parts = todo_path.replace("\\", "/").split("/")
    try:
        dom = parts[-2].split("-")[0]
        num = parts[-1].split("-")[1]
    except IndexError:
        raise ValueError(f"TODO path {todo_path!r} carries no domain/number") from None
    if not re.fullmatch(r"\d+", dom) or not re.fullmatch(r"\d+", num):
        raise ValueError(f"TODO path {todo_path!r} carries no domain/number")
    if not isinstance(section, int) or isinstance(section, bool) or section < 1:
        raise ValueError(f"section {section!r} is outside positive-int")
    base = f"{date}-D{dom}-T{num}-S{section}-{family}"
    taken = set()
    for text in texts:
        for rm in re.finditer(r"\brun\s+(\S+?)(?=[,;)]|\s|$)", text):
            taken.add(rm.group(1))
    if base not in taken and not any(t.startswith(base + "-r") for t in taken):
        return base
    mx = 1
    for t in taken:
        if t == base:
            mx = max(mx, 1)
        elif t.startswith(base + "-r"):
            tail = t[len(base) + 2:]
            if tail.isdigit():
                mx = max(mx, int(tail))
    return f"{base}-r{mx + 1}"


def check_plan_output(text: str, manifest: tuple[str, str] | None = None) -> tuple[bool, str]:
    """Whole-output validation for a plan-review round: every non-blank line
    is one `- ` finding (or the round is an explicit no-findings
    statement). With a manifest the output must open with its receipt.
    Returns (ok, reason)."""
    bounded = _output_within_bounds(text)
    if bounded is not None:
        return bounded
    if manifest is not None:
        text, reason = strip_receipt(text, manifest[0], manifest[1])
        if text is None:
            return False, reason
    lines = [ln for ln in text.splitlines() if ln.strip()]
    if not lines:
        return False, "empty output"
    if len(lines) == 1 and re.search(r"no findings?", lines[0], re.IGNORECASE):
        return True, "explicit no-findings statement"
    for lineno, line in enumerate(text.splitlines(), start=1):
        if not line.strip():
            continue
        if not line.startswith("- "):
            return False, f"line {lineno} is not a `- ` finding: {line.strip()[:80]}"
    return True, f"{len(lines)} findings, one per line"


def _self_test() -> int:
    failures = []
    total = [0]

    def check(name, cond, detail=""):
        total[0] += 1
        if not cond:
            failures.append(f"{name}: {detail or 'failed'}")

    tag = "PANEL-deadbeefdeadbeef"
    chunks = [("SECTION", "section text\n"), ("CANDIDATE DIFF", "diff text\n")]
    manifest, body = build_manifest(tag, chunks, "base000", "head111")
    expect_sha = hashlib.sha256(canonical_prompt_bytes(body)).hexdigest()
    check("manifest-sha", f"sha={expect_sha}" in manifest, manifest)
    check("manifest-bytes", f"bytes={len(canonical_prompt_bytes(body))}" in manifest, manifest)
    check("manifest-files", "files=2" in manifest and "titles=SECTION|CANDIDATE DIFF" in manifest,
          manifest)
    check("manifest-base-head", "base=base000" in manifest and "head=head111" in manifest,
          manifest)
    plain, _ = build_manifest(tag, chunks)
    check("manifest-no-base-head", "base=" not in plain and "head=" not in plain, plain)
    check("manifest-covers-body-only",
          hashlib.sha256(canonical_prompt_bytes(fence_chunks(tag, chunks))).hexdigest() == expect_sha)

    mtag, msha = parse_manifest_file(f"TAG {tag}\n{manifest}\n")
    check("parse-manifest", (mtag, msha) == (tag, expect_sha), f"{mtag} {msha}")
    try:
        parse_manifest_file("TAG only\n")
        check("parse-manifest-incomplete", False, "no ValueError")
    except ValueError:
        check("parse-manifest-incomplete", True)

    approves = "**adversarial: approve**\n**consistency: approve**\n**integration: approve**\n**record: approve**\n"
    receipt = f"RECEIPT sha={expect_sha} end={tag}\n"
    ok, reason = check_panel_output(receipt + approves, (tag, expect_sha))
    check("receipt-pass", ok, reason)
    ok, reason = check_panel_output(approves, None)
    check("no-manifest-backward-compat", ok, reason)
    ok, reason = check_panel_output(approves, (tag, expect_sha))
    check("missing-receipt-fails", (not ok) and "not a receipt" in reason, reason)
    bad_sha = "0" * 64
    ok, reason = check_panel_output(f"RECEIPT sha={bad_sha} end={tag}\n" + approves, (tag, expect_sha))
    check("wrong-sha-fails", (not ok) and "receipts sha" in reason, reason)
    ok, reason = check_panel_output(f"RECEIPT sha={expect_sha} end=WRONG\n" + approves, (tag, expect_sha))
    check("wrong-end-fails", (not ok) and "receipts end" in reason, reason)
    ok, reason = check_panel_output("RECEIPT nonsense\n" + approves, (tag, expect_sha))
    check("malformed-receipt-fails", (not ok) and "not a receipt" in reason, reason)

    findings = "- first finding\n- second finding\n"
    ok, reason = check_plan_output(receipt + findings, (tag, expect_sha))
    check("plan-receipt-pass", ok, reason)
    ok, reason = check_plan_output(findings, (tag, expect_sha))
    check("plan-missing-receipt-fails", (not ok) and "not a receipt" in reason, reason)
    ok, reason = check_plan_output(receipt + "not a finding\n", (tag, expect_sha))
    check("plan-shape-still-checked", (not ok) and "not a `- ` finding" in reason, reason)

    patch = ("diff --git a/one.md b/one.md\n+++ b/one.md\n"
             "diff --git a/two.md b/two.md\n+++ b/two.md\n")
    prose_trap = "some prose\ndiff --git a/fake b/fake\nmore prose\n"
    mline, _ = build_manifest(tag, [("SECTION", prose_trap), ("CANDIDATE DIFF", patch)])
    check("manifest-diff-files", "diff-files=one.md|two.md" in mline, mline)
    check("manifest-prose-trap", "fake" not in mline, mline)
    mline2, _ = build_manifest(tag, [("SECTION", prose_trap)])
    check("manifest-no-diff-chunks", "diff-files=" not in mline2, mline2)

    print(f"review-prompt self-test: {total[0]} cases, {len(failures)} failed")
    for failure in failures:
        print(f"FAIL {failure}")
    return 1 if failures else 0


if __name__ == "__main__":
    import sys

    if len(sys.argv) == 2 and sys.argv[1] == "--self-test":
        sys.exit(_self_test())

    # `tag` serves ad-hoc uses: one randomness source, no copies
    # (`$RANDOM` is a bash-ism that degrades to a bare timestamp under sh).
    # The prompt templates use `fence`, which checks the tag against the
    # payload before the prompt ships (a bare tag plus shell echo would
    # never check).
    if len(sys.argv) == 3 and sys.argv[1] == "tag":
        print(unique_tag(sys.argv[2]))
        sys.exit(0)
    if len(sys.argv) >= 4 and sys.argv[1] == "fence":
        args = sys.argv[3:]
        base = head = None
        while len(args) >= 2 and args[0] in ("--base", "--head"):
            if args[0] == "--base":
                base = args[1]
            else:
                head = args[1]
            args = args[2:]
        chunks = []
        for pair in args:
            title, sep, path = pair.partition("=")
            if not sep or not title or not path:
                print(f"fence: want <title>=<path>, got {pair!r}", file=sys.stderr)
                sys.exit(2)
            try:
                with open(path, encoding="utf-8") as fh:
                    chunks.append((title, fh.read()))
            except OSError as exc:
                print(f"fence: cannot read {path}: {exc}", file=sys.stderr)
                sys.exit(2)
        if not chunks:
            print("fence: no chunks to fence", file=sys.stderr)
            sys.exit(2)
        try:
            tag, prompt = fence_chunks_checked(sys.argv[2], chunks)
            manifest, _ = build_manifest(tag, chunks, base, head)
        except RuntimeError as exc:
            print(f"fence: {exc}", file=sys.stderr)
            sys.exit(1)
        print(f"TAG {tag}")
        print(manifest)
        print(prompt, end="")
        sys.exit(0)
    if len(sys.argv) >= 6 and sys.argv[1] == "run-id":
        # run-id <todo-path> <section> <family> <YYYYMMDD> <scan-file>...
        # The date rides explicit (no hidden clock): the caller fills it
        # from `date -u +%Y%m%d` (the skill's plan-review paragraph shows
        # the invocation; scan files are the findings files holding
        # claimed runs).
        try:
            section = int(sys.argv[3])
        except ValueError:
            print(f"run-id: section {sys.argv[3]!r} is not an integer", file=sys.stderr)
            sys.exit(2)
        texts = []
        for path in sys.argv[6:]:
            try:
                with open(path, encoding="utf-8") as fh:
                    texts.append(fh.read())
            except FileNotFoundError:
                # A genesis run mints before its findings file exists, so
                # a missing scan file warns and reads as no claims (review
                # R3). Collisions still fail loud downstream at the
                # duplicate-run check; other read errors stay fatal.
                print(f"run-id: warning: {path} does not exist, reading as no claims", file=sys.stderr)
            except OSError as exc:
                print(f"run-id: cannot read {path}: {exc}", file=sys.stderr)
                sys.exit(2)
        try:
            print(next_run_id(sys.argv[2], section, sys.argv[4], sys.argv[5], *texts))
        except ValueError as exc:
            print(f"run-id: {exc}", file=sys.stderr)
            sys.exit(2)
        sys.exit(0)
    checkers = {"check-panel": check_panel_output, "check-plan": check_plan_output}
    manifest = None
    checker_arg = sys.argv[1] if len(sys.argv) >= 2 else ""
    rest = sys.argv[2:]
    if checker_arg in checkers and rest[:1] == ["--manifest"]:
        if len(rest) != 2:
            print(f"{checker_arg}: --manifest wants exactly one file", file=sys.stderr)
            sys.exit(2)
        try:
            with open(rest[1], encoding="utf-8") as fh:
                manifest = parse_manifest_file(fh.read())
        except OSError as exc:
            print(f"{checker_arg}: cannot read {rest[1]}: {exc}", file=sys.stderr)
            sys.exit(2)
        except ValueError as exc:
            print(f"{checker_arg}: {exc}", file=sys.stderr)
            sys.exit(2)
        rest = []
    if checker_arg not in checkers or rest:
        print(
            f"usage: {sys.argv[0]} tag <prefix> | fence <prefix> [--base <sha> --head <sha>] <title=path>... | run-id <todo-path> <section> <family> <YYYYMMDD> <scan-file>... | check-panel|check-plan [--manifest <file>] < output.txt",
            file=sys.stderr,
        )
        sys.exit(2)
    # Bounded at the read (D00 T01 §23 review R1): slurping stdin
    # unbounded would let hostile output exhaust memory before the
    # size gate runs. One byte past the cap proves the excess without
    # decoding it; anything smaller decodes lossily (never a crash)
    # and the checker re-measures the text.
    raw = sys.stdin.buffer.read(OUTPUT_MAX_BYTES + 1)
    if len(raw) > OUTPUT_MAX_BYTES:
        print(f"FAIL output exceeds {OUTPUT_MAX_BYTES} bytes")
        sys.exit(1)
    ok, reason = checkers[checker_arg](raw.decode("utf-8", "replace"), manifest)
    print(("PASS " if ok else "FAIL ") + reason)
    sys.exit(0 if ok else 1)
