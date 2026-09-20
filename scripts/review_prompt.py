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

import datetime
import hashlib
import json
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


def unique_nonce() -> str:
    """A closing nonce no truncation can predict: 64 random bits, hex."""
    return secrets.token_hex(8)


def fence_chunks(tag: str, chunks: list[tuple[str, str]], *, nonce: str) -> str:
    """Wrap (title, body) chunks in tagged delimiter lines.

    The tag is the control: a fake `--- SECTION ---` inside untrusted TODO
    text carries no tag and matches nothing. The nonce rides the closing
    END line only, so a receipt quoting it proves the reviewer saw the
    tail of the stream.
    """
    parts = []
    for title, body in chunks:
        parts.append(f"--- {title} [{tag}] ---")
        parts.append(body.rstrip("\n"))
    parts.append(f"--- END [{tag}] nonce={nonce} ---")
    return "\n".join(parts) + "\n"


# Delimiter-tag contract (D00 T01 §19 item 11): 64 bits of entropy
# (`secrets.token_hex(8)`), collision-checked against every payload
# chunk, with bounded retries. A tag that appears in the payload would
# let TODO text forge structure, so generation retries until the tag is
# absent (a collision at 64 bits is a broken RNG, not luck, which is
# why exhaustion raises instead of degrading to a weak tag). The
# closing nonce (D00 T04 §12) shares the check: a nonce the payload
# already carries would receipt a cut stream.
TAG_ENTROPY_BITS = 64
TAG_MAX_ATTEMPTS = 100


def fence_chunks_checked(prefix: str, chunks: list[tuple[str, str]]) -> tuple[str, str, str]:
    """Fence chunks under a fresh tag proven absent from the payload,
    with a fresh closing nonce on the END line.

    Returns (tag, nonce, prompt). Raises RuntimeError if every attempt collides.
    """
    bodies = [body for _, body in chunks]
    for _ in range(TAG_MAX_ATTEMPTS):
        tag = unique_tag(prefix)
        nonce = unique_nonce()
        if all(tag not in body and nonce not in body for body in bodies):
            return tag, nonce, fence_chunks(tag, chunks, nonce=nonce)
    raise RuntimeError(f"tag collided with the payload {TAG_MAX_ATTEMPTS} times; refusing a weak tag")


def canonical_prompt_bytes(text: str) -> bytes:
    """Prompt bytes as the manifest counts them: LF newlines, UTF-8."""
    return text.replace("\r\n", "\n").replace("\r", "\n").encode("utf-8")


# Completeness manifest (D00 T04 §9, hardened §12): the fence emits
# what the session sent (byte count, file list, sha, base/head on
# candidate manifests), and the reviewer opens its output with a
# receipt quoting the manifest sha, the closing END tag, and the
# closing nonce. The nonce rides the END line only: the preamble
# never carries it, so a stream cut past the manifest but before the
# END line yields no valid receipt, and the checker fails the round
# instead of approving from partial input. The model never counts
# bytes: it copies three strings it saw, and the byte count stays
# the session's own record.
MANIFEST_RE = re.compile(
    r"^MANIFEST\s+bytes=(?P<bytes>[0-9]+)\s+files=(?P<files>[0-9]+)\s+"
    r"sha=(?P<sha>[0-9a-f]{64})(?P<rest>.*)$"
)
# Chunks carrying a unified diff name it in the title (CANDIDATE DIFF,
# STAGED STAMP); only those are scanned for changed files, so a `+++`
# line in prose can never forge the file list. Each side of a `diff
# --git` line is independently bare or whole-token C-quoted, so the
# parse is a small tokenizer, not one regex. The rename scan stops
# at the hunk body and at binary-diff bodies, so pasted post-hunk
# or post-binary `rename from/to` pairs are ignored by
# construction. Combined diffs (`diff --cc` / `diff --combined`)
# are refused at the manifest, never parsed: a merge candidate
# fences no file list rather than a guessed one. The title match is
# case-insensitive so a mistyped `candidate diff` still demands
# base/head; novel labels stay outside the contract (the skill's
# titles are fixed strings, and content-sniffing would re-admit
# the prose forgery the title gate exists to refuse).
_DIFF_TITLE_RE = re.compile(r"DIFF|PATCH|STAMP", re.IGNORECASE)
_DIFF_LINE_RE = re.compile(r"^diff --git (?P<rest>.+?)\s*$")
_DIFF_QUOTED_RE = re.compile(r'^"a/((?:[^"\\]|\\.)*)"\s+(?P<right>.*)$')
_RENAME_RE = re.compile(r"^rename (?P<dir>from|to) (?P<path>.+?)\s*$")
_COMBINED_RE = re.compile(r"^diff --(?:cc|combined)\b")


def _rename_path(raw: str) -> str:
    """One `rename from/to` value: whole-token C-quoted or bare to EOL."""
    raw = raw.strip()
    if len(raw) >= 2 and raw.startswith('"') and raw.endswith('"'):
        return _unquote_git_path(raw[1:-1])
    return raw


def _scan_diff_block(lines: list[str]) -> list[str]:
    """Changed paths from one diff block: the `rename from/to` pair
    from the header when git names one (exact even when both sides
    carry spaces), else the `diff --git` sides. The rename scan stops
    at the hunk body (`--- `, `+++ `, or `@@`) and at binary-diff
    bodies (`GIT binary patch`, `Binary files ... differ`): git emits
    the pair above both, so anything below is pasted input, never a
    rename. Combined diffs are refused at the manifest, never parsed."""
    renames: dict[str, str] = {}
    diff_line = None
    for line in lines:
        if diff_line is None and _DIFF_LINE_RE.match(line):
            diff_line = line
        if line.startswith(("--- ", "+++ ", "@@", "GIT binary patch", "Binary files ")):
            break
        rm = _RENAME_RE.match(line)
        if rm and rm.group("dir") not in renames:
            renames[rm.group("dir")] = _rename_path(rm.group("path"))
    if diff_line is None:
        return []
    if "from" in renames and "to" in renames:
        old, new = renames["from"], renames["to"]
        return [new] if old == new else [old, new]
    return _diff_paths(diff_line)


def _diff_paths(line: str) -> list[str]:
    """Changed paths from one `diff --git` line: the b-side always, the
    a-side too when a rename makes them differ. Bare sides may carry
    spaces (git leaves those unquoted); several ` b/` splits prefer
    the one whose sides agree, which real non-renames always have,
    else the last, which fires only on lines git never emits."""
    m = _DIFF_LINE_RE.match(line)
    if m is None:
        return []
    rest = m.group("rest")
    sides: tuple[str, str] | None = None
    q = _DIFF_QUOTED_RE.match(rest)
    if q is not None:
        after = q.group("right")
        if after.startswith('"b/') and after.endswith('"') and len(after) >= 4:
            sides = (_unquote_git_path(q.group(1)), _unquote_git_path(after[3:-1]))
        elif after.startswith("b/"):
            sides = (_unquote_git_path(q.group(1)), after[2:])
    elif rest.startswith("a/"):
        body = rest[2:]
        qi = body.find(' "b/')
        if qi >= 0 and body.endswith('"'):
            sides = (body[:qi], _unquote_git_path(body[qi + 4:-1]))
        elif " b/" in body:
            splits = []
            start = 0
            while True:
                i = body.find(" b/", start)
                if i < 0:
                    break
                splits.append((body[:i], body[i + 3:]))
                start = i + 1
            sides = next((s for s in splits if s[0] == s[1]), splits[-1])
    if sides is None:
        return []
    old, new = sides
    return [new] if old == new else [old, new]


def _unquote_git_path(raw: str) -> str:
    """Undo git's C-style quoting on a diff path: backslash, double
    quote, n/r/t, and octal escapes (the last is how non-ASCII names
    arrive, one escape per UTF-8 byte, so bytes accumulate and decode
    once). Unknown escapes stay literal rather than vanishing."""
    out = bytearray()
    i = 0
    simple = {"\\": b"\\", '"': b'"', "n": b"\n", "r": b"\r", "t": b"\t"}
    while i < len(raw):
        if raw[i] == "\\" and i + 1 < len(raw):
            nxt = raw[i + 1]
            if nxt in simple:
                out.extend(simple[nxt])
                i += 2
                continue
            octal = raw[i + 1:i + 4]
            if len(octal) == 3 and all(c in "01234567" for c in octal):
                out.append(int(octal, 8))
                i += 4
                continue
            out.extend(b"\\")
            i += 1
            continue
        out.extend(raw[i].encode("utf-8"))
        i += 1
    return bytes(out).decode("utf-8", "replace")
RECEIPT_RE = re.compile(r"^RECEIPT\s+sha=(?P<sha>[0-9a-f]{64})\s+end=(?P<end>\S+)\s+nonce=(?P<nonce>[0-9a-f]{16})\s*$")
TAG_LINE_RE = re.compile(r"^TAG\s+(?P<tag>\S+)\s+nonce=(?P<nonce>[0-9a-f]{16})\s*$")


def assert_candidate_identity(chunks: list[tuple[str, str]],
                              base: str | None, head: str | None) -> None:
    """A candidate manifest (any diff-titled chunk) without both base
    and head floats free: it lists files no commit pair pins down.
    Raise ValueError naming the missing sides."""
    diff_titles = sorted({title for title, _ in chunks if _DIFF_TITLE_RE.search(title)})
    if not diff_titles:
        return
    missing = [name for name, val in (("base", base), ("head", head)) if not val]
    if missing:
        raise ValueError(
            f"refusing candidate manifest without {' and '.join(missing)} "
            f"(diff in: {'|'.join(diff_titles)}; pass --base/--head)"
        )


def build_manifest(tag: str, chunks: list[tuple[str, str]],
                   base: str | None = None, head: str | None = None,
                   *, nonce: str) -> tuple[str, str]:
    """Fence chunks and describe them. Returns (manifest_line, fenced_body).

    The manifest covers the fenced body only, never itself: it is
    emitted ahead of the body and counts the bytes that follow it.
    A combined-diff opener in a diff-titled chunk raises ValueError
    naming the shape: merge candidates are refused, never parsed.
    """
    body = fence_chunks(tag, chunks, nonce=nonce)
    digest = hashlib.sha256(canonical_prompt_bytes(body)).hexdigest()
    count = len(canonical_prompt_bytes(body))
    titles = "|".join(title for title, _ in chunks)
    line = f"MANIFEST bytes={count} files={len(chunks)} sha={digest} titles={titles}"
    diff_files = []
    for title, chunk_body in chunks:
        if _DIFF_TITLE_RE.search(title):
            for chunk_line in chunk_body.splitlines():
                cm = _COMBINED_RE.match(chunk_line)
                if cm:
                    raise ValueError(
                        f"refusing combined diff ({cm.group(0)}) in {title}: "
                        "merge candidates list no files; fence a non-merge range instead"
                    )
            block: list[str] = []
            for chunk_line in chunk_body.splitlines():
                if _DIFF_LINE_RE.match(chunk_line) and block:
                    for path in _scan_diff_block(block):
                        if path not in diff_files:
                            diff_files.append(path)
                    block = []
                block.append(chunk_line)
            for path in _scan_diff_block(block):
                if path not in diff_files:
                    diff_files.append(path)
    if diff_files:
        line += " diff-files=" + "|".join(diff_files)
    if base is not None:
        line += f" base={base}"
    if head is not None:
        line += f" head={head}"
    return line, body


def parse_manifest_file(text: str) -> tuple[str, str, str]:
    """Read (tag, sha, nonce) from saved TAG + MANIFEST lines. Raises ValueError."""
    tag = sha = nonce = None
    for line in text.splitlines():
        tm = TAG_LINE_RE.match(line.strip())
        if tm:
            tag = tm.group("tag")
            nonce = tm.group("nonce")
        mm = MANIFEST_RE.match(line.strip())
        if mm:
            sha = mm.group("sha")
    if tag is None or sha is None or nonce is None:
        raise ValueError("manifest file carries no TAG + MANIFEST pair")
    return tag, sha, nonce


def strip_receipt(text: str, tag: str, sha: str, nonce: str) -> tuple[str | None, str]:
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
    if m.group("nonce") != nonce:
        return None, f"line {first + 1} receipts nonce {m.group('nonce')[:12]}..., manifest wants {nonce[:12]}..."
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


def check_panel_output(text: str, manifest: tuple[str, str, str] | None = None) -> tuple[bool, str]:
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
        text, reason = strip_receipt(text, manifest[0], manifest[1], manifest[2])
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


def check_plan_output(text: str, manifest: tuple[str, str, str] | None = None) -> tuple[bool, str]:
    """Whole-output validation for a plan-review round: every non-blank line
    is one `- ` finding (or the round is an explicit no-findings
    statement). With a manifest the output must open with its receipt.
    Returns (ok, reason)."""
    bounded = _output_within_bounds(text)
    if bounded is not None:
        return bounded
    if manifest is not None:
        text, reason = strip_receipt(text, manifest[0], manifest[1], manifest[2])
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


def parse_manifest_diff_files(text: str) -> list[str]:
    """The diff-files list from saved TAG + MANIFEST lines. Raises
    ValueError when no MANIFEST line reads; an absent diff-files field
    reads as the empty list (a manifest that lists no files). Paths
    may carry spaces, so the value runs to the next ` base=`/` head=`
    field or EOL; a path containing those tokens truncates the list,
    which the cross-check then fails loudly rather than agreeing."""
    for line in text.splitlines():
        mm = MANIFEST_RE.match(line.strip())
        if mm:
            dm = re.search(r"diff-files=(?P<files>.*?)(?:\s+base=|\s+head=|$)", mm.group("rest"))
            if dm is None or not dm.group("files"):
                return []
            return dm.group("files").split("|")
    raise ValueError("manifest file carries no MANIFEST line")


def parse_nul_file_list(data: bytes) -> list[str]:
    """Split git's -z file list: NUL-delimited UTF-8, decoded like the
    diff parse (`replace`), trailing NUL tolerated, empties dropped."""
    return [p for p in data.decode("utf-8", "replace").split("\0") if p]


def cross_check_files(parsed: list[str], nul_data: bytes) -> list[str]:
    """Divergences between the manifest's parsed set and git's own NUL
    list, as sorted `only in ...` lines; empty when the sets agree.
    Order-insensitive: the manifest lists in encounter order, git sorts."""
    want = set(parsed)
    got = set(parse_nul_file_list(nul_data))
    lines = [f"only in manifest: {p}" for p in sorted(want - got)]
    lines += [f"only in git: {p}" for p in sorted(got - want)]
    return lines


ATTEST_SCHEMA = 1
_ATTEST_FIELDS = ("manifest_sha", "candidate_base", "candidate_head", "tree",
                  "reviewer", "model", "verdict", "checker", "timestamp")


def write_attestation(*, manifest_sha: str, candidate_base: str, candidate_head: str,
                      tree: str, reviewer: str, model: str, verdict: str,
                      checker: str, timestamp: str) -> str:
    """A machine-readable review attestation as JSON: which manifest
    sha, which candidate pair and tree, who reviewed with what model,
    what verdict at what time, and what the checker said. OIDs must
    read full-length hex; reviewer and model read non-blank; verdict,
    checker, and timestamp carry exact semantics. Anything else raises
    ValueError, so a malformed attestation never ships."""
    for name, oid, size in (("manifest_sha", manifest_sha, 64),
                            ("candidate_base", candidate_base, 40),
                            ("candidate_head", candidate_head, 40),
                            ("tree", tree, 40)):
        if not isinstance(oid, str) or len(oid) != size or not re.fullmatch(r"[0-9a-f]+", oid):
            shown = oid if isinstance(oid, str) else repr(oid)
            raise ValueError(f"attestation {name} is not {size} hex chars: {shown[:80]!r}")
    for name, val in (("reviewer", reviewer), ("model", model)):
        if not isinstance(val, str) or not val.strip():
            raise ValueError(f"attestation {name} is empty")
    # Reviewer and model stay open: a new runner or model must attest
    # without a code change. The rest have exact producer semantics.
    if verdict not in ("approve", "needs-attention"):
        raise ValueError(
            f"attestation verdict is {verdict!r}, want approve or needs-attention")
    if not isinstance(checker, str) or not checker.startswith("PASS "):
        raise ValueError(
            f"attestation checker is {checker!r}, want the PASS line")
    if not isinstance(timestamp, str) or not re.fullmatch(
            r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z", timestamp):
        raise ValueError(
            f"attestation timestamp is {timestamp!r}, want %Y-%m-%dT%H:%M:%SZ")
    try:
        datetime.datetime.strptime(timestamp, "%Y-%m-%dT%H:%M:%SZ")
    except ValueError:
        raise ValueError(
            f"attestation timestamp is {timestamp!r}, want a real calendar date")
    doc = {"schema": ATTEST_SCHEMA, "manifest_sha": manifest_sha,
           "candidate_base": candidate_base, "candidate_head": candidate_head,
           "tree": tree, "reviewer": reviewer, "model": model,
           "verdict": verdict, "checker": checker, "timestamp": timestamp}
    return json.dumps(doc, indent=2, sort_keys=True) + "\n"


def parse_manifest_identity(text: str) -> tuple[str | None, str | None]:
    """The (base, head) pair from saved TAG + MANIFEST lines, each None
    when the manifest carries no such field. Raises ValueError when no
    MANIFEST line reads."""
    for line in text.splitlines():
        mm = MANIFEST_RE.match(line.strip())
        if mm:
            rest = mm.group("rest")
            base = head = None
            bm = re.search(r"\sbase=(\S+)", rest)
            if bm:
                base = bm.group(1)
            hm = re.search(r"\shead=(\S+)", rest)
            if hm:
                head = hm.group(1)
            return base, head
    raise ValueError("manifest file carries no MANIFEST line")


def check_manifest_identity(manifest_text: str, base: str, head: str,
                            cmd: str) -> str | None:
    """None when the claimed pair equals the manifest's base/head, else
    the failure line: a checker must verify the range its manifest
    pinned, never an independently supplied pair (a swapped or foreign
    range with the same file set would otherwise pass silently)."""
    mbase, mhead = parse_manifest_identity(manifest_text)
    if mbase != base or mhead != head:
        return (f"{cmd}: --base/--head ({base}...{head}) do not match "
                f"the manifest (base={mbase} head={mhead})")
    return None


def check_attest_identity(manifest_text: str, base: str, head: str) -> str | None:
    """Attest's leg of the manifest-identity check, shared with
    cross-check since round-1 F6."""
    return check_manifest_identity(manifest_text, base, head, "attest")


def git_oid_exists(oid: str, cwd=None) -> bool:
    """True when git resolves the OID to an object in the repo."""
    import subprocess
    proc = subprocess.run(
        ["git", "cat-file", "-e", oid],
        capture_output=True, cwd=cwd)
    return proc.returncode == 0


def git_head_tree(head: str, cwd=None) -> str | None:
    """The tree of a commit OID, else None when it resolves to
    nothing or to no tree."""
    import subprocess
    proc = subprocess.run(
        ["git", "rev-parse", f"{head}^{{tree}}"],
        capture_output=True, text=True, cwd=cwd)
    if proc.returncode != 0:
        return None
    return proc.stdout.strip()


def read_attestation(text: str) -> dict:
    """Read an attestation back: JSON parses, schema asserts, every
    field re-validates through the writer. Raises ValueError naming
    the first defect."""
    try:
        doc = json.loads(text)
    except json.JSONDecodeError as exc:
        raise ValueError(f"attestation is not JSON: {exc}")
    if not isinstance(doc, dict):
        raise ValueError("attestation is not an object")
    schema = doc.get("schema")
    if type(schema) is not int or schema != ATTEST_SCHEMA:
        raise ValueError(
            f"attestation schema is {schema!r}, this reader asserts {ATTEST_SCHEMA}")
    try:
        write_attestation(**{k: doc[k] for k in _ATTEST_FIELDS})
    except KeyError as exc:
        raise ValueError(f"attestation misses field {exc}")
    return doc


def _self_test() -> int:
    failures = []
    total = [0]

    def check(name, cond, detail=""):
        total[0] += 1
        if not cond:
            failures.append(f"{name}: {detail or 'failed'}")

    tag = "PANEL-deadbeefdeadbeef"
    nonce = "0123456789abcdef"
    chunks = [("SECTION", "section text\n"), ("CANDIDATE DIFF", "diff text\n")]
    manifest, body = build_manifest(tag, chunks, "base000", "head111", nonce=nonce)
    expect_sha = hashlib.sha256(canonical_prompt_bytes(body)).hexdigest()
    check("manifest-sha", f"sha={expect_sha}" in manifest, manifest)
    check("manifest-bytes", f"bytes={len(canonical_prompt_bytes(body))}" in manifest, manifest)
    check("manifest-files", "files=2" in manifest and "titles=SECTION|CANDIDATE DIFF" in manifest,
          manifest)
    check("manifest-base-head", "base=base000" in manifest and "head=head111" in manifest,
          manifest)
    plain, _ = build_manifest(tag, chunks, nonce=nonce)
    check("manifest-no-base-head", "base=" not in plain and "head=" not in plain, plain)
    check("manifest-covers-body-only",
          hashlib.sha256(canonical_prompt_bytes(
              fence_chunks(tag, chunks, nonce=nonce))).hexdigest() == expect_sha)
    check("manifest-end-carries-nonce", f"nonce={nonce}" in body, body)
    check("manifest-preamble-lacks-nonce", nonce not in manifest, manifest)

    mtag, msha, mnonce = parse_manifest_file(f"TAG {tag} nonce={nonce}\n{manifest}\n")
    check("parse-manifest", (mtag, msha, mnonce) == (tag, expect_sha, nonce),
          f"{mtag} {msha} {mnonce}")
    try:
        parse_manifest_file("TAG only\n")
        check("parse-manifest-incomplete", False, "no ValueError")
    except ValueError:
        check("parse-manifest-incomplete", True)

    approves = "**adversarial: approve**\n**consistency: approve**\n**integration: approve**\n**record: approve**\n"
    receipt = f"RECEIPT sha={expect_sha} end={tag} nonce={nonce}\n"
    manifest3 = (tag, expect_sha, nonce)
    ok, reason = check_panel_output(receipt + approves, manifest3)
    check("receipt-pass", ok, reason)
    ok, reason = check_panel_output(approves, None)
    check("no-manifest-backward-compat", ok, reason)
    ok, reason = check_panel_output(approves, manifest3)
    check("missing-receipt-fails", (not ok) and "not a receipt" in reason, reason)
    bad_sha = "0" * 64
    ok, reason = check_panel_output(f"RECEIPT sha={bad_sha} end={tag} nonce={nonce}\n" + approves,
                                    manifest3)
    check("wrong-sha-fails", (not ok) and "receipts sha" in reason, reason)
    ok, reason = check_panel_output(f"RECEIPT sha={expect_sha} end=WRONG nonce={nonce}\n" + approves,
                                    manifest3)
    check("wrong-end-fails", (not ok) and "receipts end" in reason, reason)
    ok, reason = check_panel_output("RECEIPT nonsense\n" + approves, manifest3)
    check("malformed-receipt-fails", (not ok) and "not a receipt" in reason, reason)
    # A truncation past the manifest yields sha plus tag but no nonce:
    # the old two-field receipt shape fails, and a guessed nonce names
    # the mismatch rather than passing.
    ok, reason = check_panel_output(f"RECEIPT sha={expect_sha} end={tag}\n" + approves, manifest3)
    check("truncated-receipt-fails", (not ok) and "not a receipt" in reason, reason)
    ok, reason = check_panel_output(
        f"RECEIPT sha={expect_sha} end={tag} nonce={'f' * 16}\n" + approves, manifest3)
    check("wrong-nonce-fails", (not ok) and "receipts nonce" in reason, reason)

    findings = "- first finding\n- second finding\n"
    ok, reason = check_plan_output(receipt + findings, manifest3)
    check("plan-receipt-pass", ok, reason)
    ok, reason = check_plan_output(findings, manifest3)
    check("plan-missing-receipt-fails", (not ok) and "not a receipt" in reason, reason)
    ok, reason = check_plan_output(receipt + "not a finding\n", manifest3)
    check("plan-shape-still-checked", (not ok) and "not a `- ` finding" in reason, reason)

    patch = ("diff --git a/one.md b/one.md\n+++ b/one.md\n"
             "diff --git a/two.md b/two.md\n+++ b/two.md\n")
    prose_trap = "some prose\ndiff --git a/fake b/fake\nmore prose\n"
    mline, _ = build_manifest(tag, [("SECTION", prose_trap), ("CANDIDATE DIFF", patch)], nonce=nonce)
    check("manifest-diff-files", "diff-files=one.md|two.md" in mline, mline)
    check("manifest-prose-trap", "fake" not in mline, mline)
    mline2, _ = build_manifest(tag, [("SECTION", prose_trap)], nonce=nonce)
    check("manifest-no-diff-chunks", "diff-files=" not in mline2, mline2)
    # The real git grammar, probed: bare sides keep their spaces, each
    # side quotes whole-token independently, renames name both sides.
    grammar = ("diff --git a/my file.md b/my file.md\n"
               'diff --git "a/caf\\303\\251.md" "b/caf\\303\\251.md"\n'
               'diff --git "a/quo\\"te.md" b/renamed.md\n'
               "diff --git a/old.md b/new.md\n"
               "diff --git a/gone.md b/gone.md\n")
    mline3, _ = build_manifest(tag, [("CANDIDATE DIFF", grammar)], nonce=nonce)
    for want in ("my file.md", "caf\u00e9.md", 'quo"te.md', "renamed.md",
                 "old.md", "new.md", "gone.md"):
        check(f"manifest-grammar-{want}", want in mline3, mline3)
    # The adversarial split: bare ` b/` on both sides of a rename, where
    # the agree-else-last rule fabricates a path in neither side. The
    # rename pair git emits for exactly this case is authoritative.
    hostile = ("diff --git a/old b/x.md b/new b/y.md\n"
               "similarity index 50%\n"
               "rename from old b/x.md\n"
               "rename to new b/y.md\n")
    mline4, _ = build_manifest(tag, [("CANDIDATE DIFF", hostile)], nonce=nonce)
    check("manifest-rename-authoritative",
          "diff-files=old b/x.md|new b/y.md" in mline4, mline4)
    poisoned = ("a commit message musing\n"
                "rename from nowhere\n"
                "rename to nothing\n")
    mline5, _ = build_manifest(tag, [("CANDIDATE DIFF", poisoned)], nonce=nonce)
    check("manifest-rename-needs-diff-line", "diff-files=" not in mline5, mline5)
    smuggled = ("diff --git a/real.md b/real.md\n"
                "--- a/real.md\n"
                "+++ b/real.md\n"
                "@@ -1 +1 @@\n"
                "-old\n"
                "+new\n"
                "rename from smuggled.md\n"
                "rename to smuggled2.md\n")
    mline6, _ = build_manifest(tag, [("CANDIDATE DIFF", smuggled)], nonce=nonce)
    check("manifest-rename-stops-at-hunk",
          "diff-files=real.md" in mline6 and "smuggled" not in mline6, mline6)
    # One smuggle case per hunk-body terminator: each marker alone
    # stops the scan, with the other two absent.
    for first_marker, case_name in (("--- a/s.md\n", "dashes"),
                                    ("+++ b/s.md\n", "pluses"),
                                    ("@@ -1 +1 @@\n", "hunk")):
        smuggle = ("diff --git a/s.md b/s.md\n" + first_marker +
                   "rename from smuggled.md\nrename to smuggled2.md\n")
        smline, _ = build_manifest(tag, [("CANDIDATE DIFF", smuggle)], nonce=nonce)
        check(f"manifest-smuggle-stops-at-{case_name}",
              "diff-files=s.md" in smline and "smuggled" not in smline, smline)
    # Binary-diff bodies bound the scan like the hunk body: a rename
    # pair past either marker is pasted input, never a rename.
    binpatch = ("diff --git a/b.bin b/b.bin\n"
                "GIT binary patch\n"
                "literal 3\n"
                "zcmV+b0ssC0\n"
                "rename from smuggled.md\n"
                "rename to smuggled2.md\n")
    binline, _ = build_manifest(tag, [("CANDIDATE DIFF", binpatch)], nonce=nonce)
    check("manifest-binary-patch-bound",
          "diff-files=b.bin" in binline and "smuggled" not in binline, binline)
    bindiffer = ("diff --git a/c.bin b/c.bin\n"
                 "Binary files a/c.bin and b/c.bin differ\n"
                 "rename from smuggled.md\n"
                 "rename to smuggled2.md\n")
    binline2, _ = build_manifest(tag, [("CANDIDATE DIFF", bindiffer)], nonce=nonce)
    check("manifest-binary-differ-bound",
          "diff-files=c.bin" in binline2 and "smuggled" not in binline2, binline2)
    # Combined diffs are refused, never parsed, naming the shape.
    for opener in ("diff --cc m.md\n", "diff --combined m.md\n"):
        shape = opener.split()[1]
        try:
            build_manifest(tag, [("CANDIDATE DIFF", opener)], nonce=nonce)
            check(f"manifest-combined-refused-{shape}", False, "no ValueError")
        except ValueError as exc:
            check(f"manifest-combined-refused-{shape}",
                  "combined diff" in str(exc) and shape in str(exc), str(exc))
    # A candidate manifest without base and head floats free; a plan
    # manifest (no diff chunks) needs neither; an empty side is missing.
    try:
        assert_candidate_identity([("CANDIDATE DIFF", patch)], None, None)
        check("identity-diff-needs-base-head", False, "no ValueError")
    except ValueError as exc:
        check("identity-diff-needs-base-head",
              "without base and head" in str(exc), str(exc))
    try:
        assert_candidate_identity([("CANDIDATE DIFF", patch)], "base000", None)
        check("identity-diff-needs-head", False, "no ValueError")
    except ValueError as exc:
        check("identity-diff-needs-head", "without head" in str(exc), str(exc))
    try:
        assert_candidate_identity([("CANDIDATE DIFF", patch)], "", "head111")
        check("identity-empty-base", False, "no ValueError")
    except ValueError as exc:
        check("identity-empty-base", "without base" in str(exc), str(exc))
    try:
        assert_candidate_identity([("CANDIDATE DIFF", patch)], "base000", "head111")
        assert_candidate_identity([("SECTION", "prose\n")], None, None)
        check("identity-ok", True)
    except ValueError as exc:
        check("identity-ok", False, str(exc))
    try:
        assert_candidate_identity([("candidate diff", "prose, no diff lines\n")],
                                  None, None)
        check("identity-title-case-insensitive", False, "no ValueError")
    except ValueError as exc:
        check("identity-title-case-insensitive",
              "without base and head" in str(exc), str(exc))
    # The CLI emits UTF-8 even when the console is cp1252 (the Windows
    # default): a diff carrying box drawing must fence exit 0 with
    # decodable bytes. Driven 2026-09-20 against 68c7ea9a, whose tree
    # diagram crashed emission as `UnicodeEncodeError ... cp1252`.
    import os
    import subprocess
    import sys
    import tempfile
    with tempfile.TemporaryDirectory(prefix="review-emission-") as tmpd:
        chunkp = os.path.join(tmpd, "chunk.md")
        with open(chunkp, "w", encoding="utf-8") as fh:
            fh.write("diff --git a/t.md b/t.md\n+\u2500\u2500 tree\n")
        env = dict(os.environ, PYTHONIOENCODING="cp1252")
        proc = subprocess.run(
            [sys.executable, __file__, "fence", "PANEL",
             "--base", "base000", "--head", "head111",
             f"CANDIDATE DIFF={chunkp}"],
            capture_output=True, env=env)
        try:
            out = proc.stdout.decode("utf-8")
        except UnicodeDecodeError:
            out = ""
        check("fence-emits-utf8-under-cp1252",
              proc.returncode == 0 and out.startswith("TAG ")
              and "\nMANIFEST " in out
              and out.splitlines()[-1].startswith("--- END ["),
              f"exit={proc.returncode} err={proc.stderr[-160:]!r}")
    # The cross-check compares sets, not order: the manifest lists in
    # encounter order, git sorts.
    check("crosscheck-agree",
          cross_check_files(["b.md", "a.md"], b"a.md\0b.md\0") == [])
    check("crosscheck-manifest-only",
          cross_check_files(["a.md", "ghost.md"], b"a.md\0") == ["only in manifest: ghost.md"])
    check("crosscheck-git-only",
          cross_check_files(["a.md"], b"a.md\0b.md\0") == ["only in git: b.md"])
    check("crosscheck-empty", cross_check_files([], b"") == [])
    check("parse-nul-tolerates-trailing",
          parse_nul_file_list(b"a.md\0\0") == ["a.md"])
    check("manifest-diff-files-parse",
          parse_manifest_diff_files(f"TAG {tag} nonce={nonce}\n{mline4}\n") == ["old b/x.md", "new b/y.md"])
    check("manifest-diff-files-absent",
          parse_manifest_diff_files(f"TAG {tag} nonce={nonce}\n{mline2}\n") == [])
    spaced = (f"MANIFEST bytes=1 files=1 sha={'0' * 64} titles=CANDIDATE DIFF "
              "diff-files=old b/x.md|new.md base=base000 head=head111\n")
    check("manifest-diff-files-stops-at-base",
          parse_manifest_diff_files(spaced) == ["old b/x.md", "new.md"])
    # The attestation round-trips; malformed input fails at either end.
    att = write_attestation(
        manifest_sha="a" * 64, candidate_base="b" * 40, candidate_head="c" * 40,
        tree="d" * 40, reviewer="codex-panel", model="gpt-5.6-sol",
        verdict="approve", checker="PASS four lenses, one verdict each",
        timestamp="2026-09-19T19:00:00Z")
    check("attest-round-trip", read_attestation(att)["verdict"] == "approve", att)
    try:
        write_attestation(
            manifest_sha="short", candidate_base="b" * 40, candidate_head="c" * 40,
            tree="d" * 40, reviewer="r", model="m", verdict="v", checker="c",
            timestamp="t")
        check("attest-bad-sha", False, "no ValueError")
    except ValueError as exc:
        check("attest-bad-sha", "manifest_sha" in str(exc), str(exc))
    try:
        read_attestation('{"schema": 1, "verdict": "approve"}')
        check("attest-missing-field", False, "no ValueError")
    except ValueError as exc:
        check("attest-missing-field", "misses" in str(exc), str(exc))
    try:
        read_attestation(att.replace('"schema": 1', '"schema": 99'))
        check("attest-bad-schema", False, "no ValueError")
    except ValueError as exc:
        check("attest-bad-schema", "schema" in str(exc), str(exc))
    # `True == 1` and `1.0 == 1` in Python, so `!=` alone admits both
    # (the §14 bug class, in this reader): the schema gates on exact int.
    for bad_schema, case in (("true", "bool"), ("1.0", "float")):
        try:
            read_attestation(att.replace('"schema": 1', f'"schema": {bad_schema}'))
            check(f"attest-schema-not-{case}", False, "no ValueError")
        except ValueError as exc:
            check(f"attest-schema-not-{case}", "schema" in str(exc), str(exc))
    good = dict(manifest_sha="a" * 64, candidate_base="b" * 40,
                candidate_head="c" * 40, tree="d" * 40, reviewer="r",
                model="m", verdict="approve",
                checker="PASS four lenses, one verdict each",
                timestamp="2026-09-19T19:00:00Z")
    for case, field, bad_val in (("verdict", "verdict", "banana"),
                                 ("checker-fail", "checker",
                                  "FAIL line 1 is not a receipt"),
                                 ("checker-passive", "checker", "PASSIVE"),
                                 ("timestamp-loose", "timestamp", "t"),
                                 ("timestamp-impossible", "timestamp",
                                  "2026-99-99T99:99:99Z")):
        probe = dict(good, **{field: bad_val})
        try:
            write_attestation(**probe)
            check(f"attest-bad-{case}", False, "no ValueError")
        except ValueError as exc:
            check(f"attest-bad-{case}", field in str(exc), str(exc))
    try:
        read_attestation("not json {{{")
        check("attest-not-json", False, "no ValueError")
    except ValueError as exc:
        check("attest-not-json", "not JSON" in str(exc), str(exc))
    check("parse-manifest-identity",
          parse_manifest_identity(f"TAG {tag} nonce={nonce}\n{manifest}\n") == ("base000", "head111"))
    check("parse-manifest-identity-absent",
          parse_manifest_identity(f"TAG {tag} nonce={nonce}\n{plain}\n") == (None, None))
    check("attest-identity-match",
          check_attest_identity(
              f"TAG {tag} nonce={nonce}\n{manifest}\n", "base000", "head111") is None)
    mismatch = check_attest_identity(
        f"TAG {tag} nonce={nonce}\n{manifest}\n", "base000", "deadbeef")
    check("attest-identity-mismatch",
          mismatch is not None and mismatch.startswith("attest: --base/--head"),
          mismatch or "matched")
    check("crosscheck-identity-match",
          check_manifest_identity(
              f"TAG {tag} nonce={nonce}\n{manifest}\n", "base000", "head111",
              "cross-check") is None)
    xbad = check_manifest_identity(
        f"TAG {tag} nonce={nonce}\n{manifest}\n", "head111", "base000",
        "cross-check")
    check("crosscheck-identity-mismatch",
          xbad is not None and xbad.startswith("cross-check: --base/--head"),
          xbad or "matched")
    # OID resolution runs against a scratch repo (hermetic: no config
    # writes, all identity via -c flags), so the cases pass on any
    # machine with git, which the CLI paths under test require throughout.
    import os
    import subprocess
    import tempfile
    with tempfile.TemporaryDirectory(prefix="review-resolve-") as tmpd:
        subprocess.run(["git", "init", "-q", tmpd], capture_output=True,
                       check=True)
        with open(os.path.join(tmpd, "f.md"), "w", encoding="utf-8") as fh:
            fh.write("fixture\n")
        subprocess.run(["git", "-C", tmpd, "add", "f.md"],
                       capture_output=True, check=True)
        subprocess.run(["git", "-C", tmpd, "-c", "user.email=t@t.invalid",
                        "-c", "user.name=t", "-c", "commit.gpgsign=false",
                        "commit", "-qm", "fixture"], capture_output=True,
                       check=True)
        rhead = subprocess.run(["git", "-C", tmpd, "rev-parse", "HEAD"],
                               capture_output=True, text=True,
                               check=True).stdout.strip()
        rtree = subprocess.run(["git", "-C", tmpd, "rev-parse", "HEAD^{tree}"],
                               capture_output=True, text=True,
                               check=True).stdout.strip()
        check("resolve-oid-exists", git_oid_exists(rhead, cwd=tmpd)
              and git_oid_exists(rtree, cwd=tmpd))
        check("resolve-oid-missing",
              not git_oid_exists("deadbeef" * 5, cwd=tmpd))
        check("resolve-head-tree-match",
              git_head_tree(rhead, cwd=tmpd) == rtree)
        check("resolve-head-tree-missing",
              git_head_tree("deadbeef" * 5, cwd=tmpd) is None)
    check("nonce-shape", re.fullmatch(r"[0-9a-f]{16}", unique_nonce()) is not None)

    print(f"review-prompt self-test: {total[0]} cases, {len(failures)} failed")
    for failure in failures:
        print(f"FAIL {failure}")
    return 1 if failures else 0


if __name__ == "__main__":
    import sys

    # Fenced TODO text and diffs carry characters outside the Windows
    # console code page (box drawing, arrows); emission must never depend
    # on the console, so both streams are UTF-8 before any subcommand runs.
    for _stream in (sys.stdout, sys.stderr):
        try:
            _stream.reconfigure(encoding="utf-8")
        except (AttributeError, ValueError):
            pass

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
            assert_candidate_identity(chunks, base, head)
            tag, nonce, prompt = fence_chunks_checked(sys.argv[2], chunks)
            manifest, _ = build_manifest(tag, chunks, base, head, nonce=nonce)
        except (RuntimeError, ValueError) as exc:
            print(f"fence: {exc}", file=sys.stderr)
            sys.exit(1)
        print(f"TAG {tag} nonce={nonce}")
        print(manifest)
        print(prompt, end="")
        sys.exit(0)
    if len(sys.argv) == 5 and sys.argv[1] == "cross-check":
        # cross-check <manifest-file> <base> <head>: git's own NUL file
        # list for the range against the manifest's parsed diff-files.
        # Divergence fails closed; run from the repository root.
        # --no-renames lists both sides of a rename, matching the
        # manifest's [old, new]; without it every valid rename
        # diverges as `only in manifest: <old>`.
        import subprocess
        try:
            with open(sys.argv[2], encoding="utf-8") as fh:
                manifest_text = fh.read()
            parsed = parse_manifest_diff_files(manifest_text)
        except OSError as exc:
            print(f"cross-check: cannot read {sys.argv[2]}: {exc}", file=sys.stderr)
            sys.exit(2)
        except ValueError as exc:
            print(f"cross-check: {exc}", file=sys.stderr)
            sys.exit(2)
        identity_bad = check_manifest_identity(
            manifest_text, sys.argv[3], sys.argv[4], "cross-check")
        if identity_bad is not None:
            print(identity_bad, file=sys.stderr)
            sys.exit(1)
        for name, oid in (("--base", sys.argv[3]), ("--head", sys.argv[4])):
            if not git_oid_exists(oid):
                print(f"cross-check: {name} {oid} resolves to nothing",
                      file=sys.stderr)
                sys.exit(1)
        try:
            proc = subprocess.run(
                ["git", "diff", "--name-only", "-z", "--no-renames", sys.argv[3], sys.argv[4]],
                capture_output=True, check=False)
        except OSError as exc:
            print(f"cross-check: git failed: {exc}", file=sys.stderr)
            sys.exit(1)
        if proc.returncode != 0:
            detail = proc.stderr.decode("utf-8", "replace").strip()[:200]
            print(f"cross-check: git diff refused the range: {detail}", file=sys.stderr)
            sys.exit(1)
        diverged = cross_check_files(parsed, proc.stdout)
        if diverged:
            for line in diverged:
                print(f"cross-check: {line}", file=sys.stderr)
            sys.exit(1)
        print(f"cross-check: {len(parsed)} file(s) agree")
        sys.exit(0)
    if len(sys.argv) >= 3 and sys.argv[1] == "attest":
        # attest --out <path> --manifest <file> --base <b> --head <h>
        #   --tree <t> --reviewer <r> --model <m> --verdict <v>
        #   --checker <c> --timestamp <ts>
        # attest --read-back <path>
        # The manifest sha pins the reviewed input (the attestation
        # cannot claim a sha the manifest never had); the timestamp
        # rides explicit, no hidden clock.
        args = sys.argv[2:]
        if args[:1] == ["--read-back"] and len(args) == 2:
            try:
                with open(args[1], encoding="utf-8") as fh:
                    doc = read_attestation(fh.read())
            except OSError as exc:
                print(f"attest: cannot read {args[1]}: {exc}", file=sys.stderr)
                sys.exit(2)
            except ValueError as exc:
                print(f"attest: {exc}", file=sys.stderr)
                sys.exit(1)
            print(f"attest: schema {doc['schema']}, verdict {doc['verdict']}, "
                  f"manifest {doc['manifest_sha'][:12]}..., candidate "
                  f"{doc['candidate_base'][:12]}...{doc['candidate_head'][:12]}..., "
                  f"tree {doc['tree'][:12]}..., reviewer {doc['reviewer']}, "
                  f"model {doc['model']}, checker: {doc['checker']}")
            sys.exit(0)
        want = {"--out": None, "--manifest": None, "--base": None, "--head": None,
                "--tree": None, "--reviewer": None, "--model": None,
                "--verdict": None, "--checker": None, "--timestamp": None}
        rest = list(args)
        while len(rest) >= 2 and rest[0] in want:
            want[rest[0]] = rest[1]
            rest = rest[2:]
        if rest or any(v is None for v in want.values()):
            print("attest: want --out <path> --manifest <file> --base <b> --head <h> "
                  "--tree <t> --reviewer <r> --model <m> --verdict <v> --checker <c> "
                  "--timestamp <ts> | --read-back <path>", file=sys.stderr)
            sys.exit(2)
        try:
            with open(want["--manifest"], encoding="utf-8") as fh:
                manifest_text = fh.read()
            _, sha, _ = parse_manifest_file(manifest_text)
        except OSError as exc:
            print(f"attest: cannot read {want['--manifest']}: {exc}", file=sys.stderr)
            sys.exit(2)
        except ValueError as exc:
            print(f"attest: {exc}", file=sys.stderr)
            sys.exit(2)
        identity_bad = check_attest_identity(manifest_text, want["--base"], want["--head"])
        if identity_bad is not None:
            print(identity_bad, file=sys.stderr)
            sys.exit(1)
        try:
            body = write_attestation(
                manifest_sha=sha, candidate_base=want["--base"],
                candidate_head=want["--head"], tree=want["--tree"],
                reviewer=want["--reviewer"], model=want["--model"],
                verdict=want["--verdict"], checker=want["--checker"],
                timestamp=want["--timestamp"])
        except ValueError as exc:
            print(f"attest: {exc}", file=sys.stderr)
            sys.exit(1)
        for name in ("--base", "--head", "--tree"):
            if not git_oid_exists(want[name]):
                print(f"attest: {name} {want[name]} resolves to nothing",
                      file=sys.stderr)
                sys.exit(1)
        if git_head_tree(want["--head"]) != want["--tree"]:
            print(f"attest: --tree {want['--tree']} is not the tree of "
                  f"--head {want['--head']}", file=sys.stderr)
            sys.exit(1)
        try:
            with open(want["--out"], "w", encoding="utf-8", newline="\n") as fh:
                fh.write(body)
        except OSError as exc:
            print(f"attest: cannot write {want['--out']}: {exc}", file=sys.stderr)
            sys.exit(1)
        print(f"attest: wrote {want['--out']}")
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
            f"usage: {sys.argv[0]} tag <prefix> | fence <prefix> [--base <sha> --head <sha>] <title=path>... | run-id <todo-path> <section> <family> <YYYYMMDD> <scan-file>... | check-panel|check-plan [--manifest <file>] < output.txt | cross-check <manifest-file> <base> <head> | attest (--out <path> --manifest <file> --base <b> --head <h> --tree <t> --reviewer <r> --model <m> --verdict <v> --checker <c> --timestamp <ts> | --read-back <path>)",
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
