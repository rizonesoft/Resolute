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
                   *, nonce: str,
                   commits: list[str] | None = None) -> tuple[str, str]:
    """Fence chunks and describe them. Returns (manifest_line, fenced_body).

    The manifest covers the fenced body only, never itself: it is
    emitted ahead of the body and counts the bytes that follow it.
    A combined-diff opener in a diff-titled chunk raises ValueError
    naming the shape: merge candidates are refused, never parsed.
    `commits` names the assembled commits a non-contiguous chunk
    claims to cover; the content leg verifies the claim (D00 T04
    §21). It rides ahead of base/head, which stay trailing for the
    anchored identity parse.
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
        line += " diff-files=" + "|".join(quote_manifest_name(p) for p in diff_files)
    if commits:
        line += " commits=" + "|".join(commits)
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


def panel_text_from_envelope(text: str) -> tuple[str, str | None]:
    """Unwrap a Claude JSON envelope to its `result` text, else passthrough.

    Bare reviewer output (RECEIPT-led) passes through untouched; only a
    `{`-led payload parses as JSON. A parsed envelope without a string
    `result`, or one flagging `is_error`, fails naming the shape: a
    failed round approves nothing.
    """
    if not text.lstrip().startswith("{"):
        return text, None
    try:
        obj = json.loads(text)
    except ValueError:
        return text, None
    if not isinstance(obj, dict):
        return text, None
    if obj.get("is_error") is True:
        return text, f"round errored ({obj.get('subtype', 'unknown subtype')}), approving nothing"
    result = obj.get("result")
    if not isinstance(result, str):
        return text, "JSON envelope carries no string `result`"
    return result, None


def round_cost_from_envelope(text: str) -> tuple[int | None, str | None]:
    """(total tokens, error) from a Claude JSON envelope's usage block.

    Total is the runs header's cost sum: input + output + cache_read +
    cache_creation, each at face value. Returns an error naming the
    missing shape instead of guessing. Present classes must be strict
    integers (D00 T04 §20 round 1 F1): `int()` coercion would accept
    bools, floats, and numeric strings as false costs. Absent classes
    read as zero: omission is the envelope's zero, not malformation.
    """
    try:
        obj = json.loads(text)
    except ValueError as exc:
        return None, f"not a JSON envelope: {exc}"
    if not isinstance(obj, dict):
        return None, "JSON envelope is not an object"
    usage = obj.get("usage")
    if not isinstance(usage, dict):
        return None, "JSON envelope carries no `usage` block"
    total = 0
    for key in ("input_tokens", "output_tokens", "cache_read_input_tokens",
                "cache_creation_input_tokens"):
        value = usage.get(key, 0)
        if type(value) is not int or value < 0:
            return None, f"usage block carries non-integer token count for {key}"
        total += value
    return total, None


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
    text, envelope_err = panel_text_from_envelope(text)
    if envelope_err is not None:
        return False, envelope_err
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


_STAMP_HOLDS_RE = re.compile(r"^STAMP HOLDS\.\s*$")


def check_stamp_output(text: str, manifest: tuple[str, str, str] | None = None) -> tuple[bool, str]:
    """Whole-output validation for a stamp-review round: the receipt
    (against the stamp manifest), then exactly `STAMP HOLDS.` or one or
    more naming lines (D00 T04 §21: the eyeball verification was the
    gap). Like check-panel, findings still pass: namings are valid
    reviewer output the session must answer, so they pass with their
    count and the skill branches on the reason (`stamp holds` proceeds;
    `N naming(s)` re-stages; anything else re-runs). A receipt-less,
    empty, or HOLDS-plus-junk output fails. Returns (ok, reason)."""
    text, envelope_err = panel_text_from_envelope(text)
    if envelope_err is not None:
        return False, envelope_err
    bounded = _output_within_bounds(text)
    if bounded is not None:
        return bounded
    if manifest is not None:
        text, reason = strip_receipt(text, manifest[0], manifest[1], manifest[2])
        if text is None:
            return False, reason
    numbered = [(i, ln) for i, ln in enumerate(text.splitlines(), start=1)
                if ln.strip()]
    if not numbered:
        return False, "no verdict after the receipt"
    if _STAMP_HOLDS_RE.match(numbered[0][1]):
        if len(numbered) > 1:
            return False, f"line {numbered[1][0]} follows STAMP HOLDS"
        return True, "stamp holds"
    return True, f"{len(numbered)} naming(s) to answer"


def quote_manifest_name(name: str) -> str:
    """Escape one file name for the `diff-files` field: backslash, pipe,
    newline, space, tab, and CR escape (space as `\\s`: a literal space
    would let a name ending `foo commits=deadbeef` parse as manifest
    metadata), so hostile names round-trip exactly (D00 T04 §21: the
    §21 independent review caught the lookalike-F7)."""
    return (name.replace("\\", "\\\\").replace("|", "\\|")
                .replace("\n", "\\n").replace(" ", "\\s")
                .replace("\t", "\\t").replace("\r", "\\r"))


def split_manifest_names(field: str) -> list[str]:
    """Split a `diff-files` field on unescaped pipes, unescaping each
    name. Lenient on unknown escapes (`\\` plus anything unlisted keeps
    both chars), so legacy unquoted names carrying backslashes survive
    the read; the writer never emits a trailing lone backslash, and a
    hand-made one keeps its backslash. A pre-`\\s` unquoted name that
    already carries a literal backslash-s reads wrong, but no manifest
    is ever committed (review scratch only), so no legacy corpus
    exists to corrupt; hand-made manifests avoid backslash-s."""
    names: list[str] = []
    cur: list[str] = []
    esc = False
    for ch in field:
        if esc:
            if ch == "n":
                cur.append("\n")
            elif ch == "s":
                cur.append(" ")
            elif ch == "t":
                cur.append("\t")
            elif ch == "r":
                cur.append("\r")
            elif ch in "\\|":
                cur.append(ch)
            else:
                cur.append("\\")
                cur.append(ch)
            esc = False
        elif ch == "\\":
            esc = True
        elif ch == "|":
            names.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    if esc:
        cur.append("\\")
    names.append("".join(cur))
    return names


def parse_manifest_diff_files(text: str) -> list[str]:
    """The diff-files list from saved TAG + MANIFEST lines. Raises
    ValueError when no MANIFEST line reads; an absent diff-files field
    reads as the empty list (a manifest that lists no files). Trailing
    fields strip from the END (`commits`, then the anchored `base`/
    `head` pair): a mid-value lookalike (`x base=y` inside a hostile
    name) can never match an end-anchored field, so the remainder is
    the value whole (and writer-emitted names carry no literal space
    at all, so on review output the strips only ever match real
    fields). It then splits on unescaped pipes: quoted emissions
    round-trip hostile names exactly, and legacy unquoted values read
    as before."""
    for line in text.splitlines():
        mm = MANIFEST_RE.match(line.strip())
        if mm:
            rest = mm.group("rest")
            dm = re.search(r"diff-files=", rest)
            if dm is None:
                return []
            tail = rest[dm.end():]
            for pat in (r"\s+base=\S+\s+head=\S+\s*$",
                        r"\s+base=\S+\s*$",
                        r"\s+head=\S+\s*$"):
                tm = re.search(pat, tail)
                if tm is not None:
                    tail = tail[:tm.start()]
                    break
            cm = re.search(r"\s+commits=\S+\s*$", tail)
            if cm is not None:
                tail = tail[:cm.start()]
            if not tail:
                return []
            return split_manifest_names(tail)
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


def parse_manifest_commits(text: str) -> list[str]:
    """The commits= claim from saved TAG + MANIFEST lines: the assembled
    commits a non-contiguous chunk claims to cover. Empty when the field
    is absent (the contiguous flow claims nothing). The last match wins:
    titles precede the field and quoted diff-files carry no literal
    space, so only the real field can sit last; a forged claim still
    fails closed downstream (unresolvable, or uncovered)."""
    for line in text.splitlines():
        mm = MANIFEST_RE.match(line.strip())
        if mm:
            found = re.findall(r"\scommits=(\S+)", mm.group("rest"))
            if found:
                return [c for c in found[-1].split("|") if c]
            return []
    raise ValueError("manifest file carries no MANIFEST line")


_FENCE_OPEN_RE = re.compile(r"^--- (?P<title>.+) \[(?P<tag>[^\]]+)\] ---\s*$")
_FENCE_END_RE = re.compile(r"^--- END \[(?P<tag>[^\]]+)\] nonce=[0-9a-f]{16} ---\s*$")


def unfence_diff_bodies(text: str, tag: str) -> list[str]:
    """Diff-titled chunk bodies from a fenced file: only lines carrying
    [tag] delimit, mirroring the reviewer's contract (a colliding tag
    cannot exist: fencing refuses it). Returns the bodies of chunks
    whose title reads as a diff (DIFF/PATCH/STAMP)."""
    bodies: list[str] = []
    cur: list[str] | None = None
    want = False
    for line in text.splitlines():
        m = _FENCE_OPEN_RE.match(line)
        if m is not None and m.group("tag") == tag:
            if cur is not None and want:
                bodies.append("\n".join(cur))
            cur = []
            want = bool(_DIFF_TITLE_RE.search(m.group("title")))
            continue
        e = _FENCE_END_RE.match(line)
        if e is not None and e.group("tag") == tag:
            if cur is not None and want:
                bodies.append("\n".join(cur))
            break
        if cur is not None and want:
            cur.append(line)
    else:
        if cur is not None and want:
            bodies.append("\n".join(cur))
    return bodies


_PLUS3_RE = re.compile(r"^\+\+\+ (?P<path>.+?)\s*$")
_MINUS3_RE = re.compile(r"^--- (?P<path>.+?)\s*$")


def _header_path(raw: str) -> str | None:
    """One side of a `---`/`+++` pair: a/ and b/ prefixes stripped,
    C-quoted forms unquoted, /dev/null as None (the other side names
    the file)."""
    raw = raw.strip()
    if raw == "/dev/null":
        return None
    if len(raw) >= 2 and raw.startswith('"') and raw.endswith('"'):
        raw = _unquote_git_path(raw[1:-1])
    for prefix in ("a/", "b/"):
        if raw.startswith(prefix):
            return raw[len(prefix):]
    return raw


def _diff_change_lines(diff_text: str) -> dict[str, "Counter[str]"]:
    """Per-file (sign, line) multisets from unified diff text. Each
    `diff --git` block opens expecting its `---`/`+++` pair; only that
    pair names the file (`+++` wins unless /dev/null, so deletions
    attribute to the `---` side), and every `---`/`+++`-looking line
    past it is content (a removed `-- x` line reads `--- x`: position,
    not shape, disambiguates). `+`/`-` lines count with their sign;
    headers, hunk markers, and prose never count. A dangling pair
    (truncated hand assembly) drops its lines, failing closed
    downstream: fewer chunk lines only ever add failures."""
    from collections import Counter
    per_file: dict[str, Counter[str]] = {}
    cur: str | None = None
    state = "idle"
    for line in diff_text.splitlines():
        if _DIFF_LINE_RE.match(line):
            cur, state = None, "minus"
            continue
        if state == "minus":
            nm = _MINUS3_RE.match(line)
            if nm is not None:
                got = _header_path(nm.group("path"))
                cur = got if got is not None else cur
                state = "plus"
            continue
        if state == "plus":
            pm = _PLUS3_RE.match(line)
            if pm is not None:
                got = _header_path(pm.group("path"))
                if got is not None:
                    cur = got
                state = "content"
            continue
        if state != "content" or cur is None:
            continue
        if line.startswith("+"):
            per_file.setdefault(cur, Counter())[line] += 1
        elif line.startswith("-"):
            per_file.setdefault(cur, Counter())[line] += 1
    return per_file


_SIGNAL_PREFIXES = ("old mode ", "new mode ", "new file mode ",
                    "deleted file mode ", "similarity index ",
                    "dissimilarity index ", "rename from ", "rename to ",
                    "copy from ", "copy to ", "Binary files ")


def _diff_signal_lines(diff_text: str) -> dict[str, "Counter[str]"]:
    """Per-file block-marker multisets from unified diff text: the
    mode, rename/copy, similarity, and binary markers a metadata-only
    commit leaves (a pure rename, mode flip, or binary patch has no
    +/- lines, so the content leg alone covers it vacuously: the §21
    independent review caught the hole-F5). Attribution is the
    block's b-side (`_diff_paths` last), deterministic on both
    sides. The `diff --git` and `index` lines are NOT signals: a
    range-diff chunk re-emits them per net block with net sides and
    collapsed hashes, so per-commit values would false-fail on
    contiguous ranges; mode/rename/binary markers survive range
    diffs verbatim. Content lines can never collide: every +/-/space
    body line starts with its prefix, never a bare marker."""
    from collections import Counter
    per_file: dict[str, Counter[str]] = {}
    cur: str | None = None
    for line in diff_text.splitlines():
        if _DIFF_LINE_RE.match(line):
            sides = _diff_paths(line)
            cur = sides[-1] if sides else None
            continue
        if cur is None:
            continue
        if line.startswith(_SIGNAL_PREFIXES):
            per_file.setdefault(cur, Counter())[line] += 1
    return per_file


def git_show_patch(oid: str, cwd=None):
    """One commit's patch without its message (`--format=` suppresses
    the header, so message lines can never pollute the line count),
    replacement refs disabled like every review read. Returns the
    completed process; raises OSError when git cannot spawn."""
    import subprocess
    return subprocess.run(
        ["git", "--no-replace-objects", "show", "--format=", oid],
        capture_output=True, check=False, cwd=cwd)


def git_commit_parents(oid: str, cwd=None) -> list[str] | None:
    """The parent oids of a commit, None when git cannot list them."""
    import subprocess
    proc = subprocess.run(
        ["git", "--no-replace-objects", "rev-list", "--parents", "-1", oid],
        capture_output=True, check=False, cwd=cwd)
    if proc.returncode != 0:
        return None
    return proc.stdout.decode("utf-8", "replace").split()[1:]


def check_parent_binding(commit: str, expected: str, cwd=None) -> str | None:
    """None when a commit lands on its expected parent, else the
    failure. A merge fails naming every parent (D00 T04 §21: `HEAD^`
    reads the first parent, so the second side's resolution would ride
    unreviewed); the linear tree this project keeps is why merges stay
    rare, and this gate is why a stray one never slips through."""
    if not git_oid_exists(commit, cwd=cwd):
        return f"check-parents: {commit} resolves to nothing"
    if git_object_type(commit, cwd=cwd) != "commit":
        return f"check-parents: {commit} is not a commit"
    parents = git_commit_parents(commit, cwd=cwd)
    if parents is None:
        return f"check-parents: {commit} lists no parents"
    if len(parents) > 1:
        return (f"check-parents: {commit} is a merge "
                f"(parents {' '.join(parents)}); linear stamps refuse merges")
    if not parents:
        return f"check-parents: {commit} sits on none (root), want {expected}"
    want_full = git_resolve_oid(expected, cwd=cwd)
    if want_full is None:
        return f"check-parents: expected parent {expected} resolves to nothing"
    if parents[0] != want_full:
        return f"check-parents: {commit} sits on {parents[0]}, want {expected}"
    return None


def git_resolve_oid(oid: str, cwd=None) -> str | None:
    """The full oid for a revision, None when it resolves to nothing."""
    import subprocess
    proc = subprocess.run(
        ["git", "--no-replace-objects", "rev-parse", "--verify", "--quiet",
         oid + "^{commit}"],
        capture_output=True, check=False, cwd=cwd)
    if proc.returncode != 0:
        return None
    return proc.stdout.decode("utf-8", "replace").strip() or None


_ANCHOR_TICK_RE = re.compile(r"`(?P<body>[^`]+)`")
_ANCHOR_OID_RE = re.compile(r"\A[0-9a-f]{7,40}\Z")
_ANCHOR_RANGE_RE = re.compile(r"\A([0-9a-f]{7,40})\.\.([0-9a-f]{7,40})\Z")
_ANCHOR_PATHLINE_RE = re.compile(r"\A(?P<path>[\w./-]+\.\w+):(?P<first>\d+)(?:-(?P<last>\d+))?\Z")
_ANCHOR_PATH_RE = re.compile(r"\A[\w./-]+\.(?:md|py|ps1|json)\Z")
_ANCHOR_FULLREF_RE = re.compile(r"D(?P<dom>\d\d)\s+T(?P<todo>\d\d)\s+§(?P<sec>\d+)")
_ANCHOR_BAREREF_RE = re.compile(r"(?<![\wT])§(?P<sec>\d+)")
_ANCHOR_SECTION_RE = re.compile(r"^##\s+(?P<num>\d+)\.")
_STAMP_KINDS = ("Verified", "Review", "Plan review", "CRUD", "Duration",
                "Deferred", "Resolved")


def _stamp_anchor_lines(todo_text: str, section: int) -> list[tuple[int, str, str]]:
    """(lineno, kind, body) stamp lines of one section: `## <section>.`
    to the next `## ` heading, lines shaped `> **Kind:** body`."""
    out: list[tuple[int, str, str]] = []
    inside = False
    for lineno, line in enumerate(todo_text.splitlines(), start=1):
        m = _ANCHOR_SECTION_RE.match(line)
        if m is not None:
            inside = int(m.group("num")) == section
            continue
        if not inside:
            continue
        sm = re.match(r"^>\s*\*\*(?P<kind>[A-Za-z ]+):\*\*\s*(?P<body>.+?)\s*$", line)
        if sm is not None and sm.group("kind") in _STAMP_KINDS:
            out.append((lineno, sm.group("kind"), sm.group("body")))
    return out


def _todo_section_exists(todo_path: str, section: int) -> bool:
    """Whether `## <section>.` heads a section of a TODO file."""
    import os
    try:
        with open(todo_path, encoding="utf-8") as fh:
            text = fh.read()
    except OSError:
        return False
    return any(_ANCHOR_SECTION_RE.match(line) is not None
               and int(_ANCHOR_SECTION_RE.match(line).group("num")) == section
               for line in text.splitlines())


def _resolve_full_ref(dom: str, todo: str, sec: int) -> str | None:
    """The failure for an unresolvable `DNN TNN §N` ref, else None:
    domain dir, TODO file, and section heading must each exist."""
    import glob
    import os
    dirs = sorted(glob.glob(os.path.join("todo", f"{dom}-*")))
    if not dirs or not os.path.isdir(dirs[0]):
        return f"D{dom} T{todo} §{sec}: no D{dom} domain dir"
    files = sorted(glob.glob(os.path.join(dirs[0], f"TODO-{todo}-*.md")))
    if not files:
        return f"D{dom} T{todo} §{sec}: no TODO-{todo} file"
    if not _todo_section_exists(files[0], sec):
        return f"D{dom} T{todo} §{sec}: no §{sec} in {files[0]}"
    return None


def check_stamp_anchors(todo_path: str, section: int) -> list[str]:
    """Dead anchors in one section's stamp block, empty when every
    cited line, section, and oid resolves (D00 T04 §21: reviewer
    judgment caught these nondeterministically; the reviewer round
    stays as the semantic backstop). Oids resolve only on Review
    lines: Verified evidence quotes version dates (`20251216`), report
    shas, and external commits no same-repo gate may judge. Path:line
    cites resolve file plus range; bare `§N` resolves in-file; full
    D-refs resolve dir, file, and heading. Failures name file, stamp
    line, and the dead anchor."""
    import os
    failures: list[str] = []
    try:
        with open(todo_path, encoding="utf-8") as fh:
            todo_text = fh.read()
    except OSError as exc:
        return [f"{todo_path}: cannot read: {exc}"]
    for lineno, kind, body in _stamp_anchor_lines(todo_text, section):
        where = f"{todo_path}:{lineno}"
        if kind == "Review":
            for tick in _ANCHOR_TICK_RE.finditer(body):
                span = tick.group("body")
                rm = _ANCHOR_RANGE_RE.match(span)
                if rm is not None:
                    for side in rm.groups():
                        if not git_oid_exists(side):
                            failures.append(f"{where}: Review range cites dead oid {side}")
                    continue
                if _ANCHOR_OID_RE.match(span) is not None:
                    if not git_oid_exists(span):
                        failures.append(f"{where}: Review cites dead oid {span}")
        for tick in _ANCHOR_TICK_RE.finditer(body):
            span = tick.group("body")
            pm = _ANCHOR_PATHLINE_RE.match(span)
            if pm is not None:
                path, first = pm.group("path"), int(pm.group("first"))
                last = int(pm.group("last")) if pm.group("last") else first
                if not os.path.exists(path):
                    failures.append(f"{where}: cites missing file {path}")
                    continue
                try:
                    with open(path, encoding="utf-8", errors="replace") as fh:
                        total = len(fh.read().splitlines())
                except OSError as exc:
                    failures.append(f"{where}: cites unreadable file {path}: {exc}")
                    continue
                if not (1 <= first <= last <= total):
                    failures.append(
                        f"{where}: cites dead lines {path}:{first}"
                        f"{('-' + str(last)) if last != first else ''} "
                        f"(file has {total})")
                continue
            if _ANCHOR_PATH_RE.match(span) is not None and ":" not in span:
                if not os.path.exists(span):
                    failures.append(f"{where}: cites missing file {span}")
        full_spans = [m.span() for m in _ANCHOR_FULLREF_RE.finditer(body)]
        for fm in _ANCHOR_FULLREF_RE.finditer(body):
            bad = _resolve_full_ref(fm.group("dom"), fm.group("todo"), int(fm.group("sec")))
            if bad is not None:
                failures.append(f"{where}: cites dead ref {bad}")
        for bm in _ANCHOR_BAREREF_RE.finditer(body):
            if any(s <= bm.start() and bm.end() <= e for s, e in full_spans):
                continue
            if not _todo_section_exists(todo_path, int(bm.group("sec"))):
                failures.append(f"{where}: cites dead in-file §{bm.group('sec')}")
    return failures


def check_commits_covered(commits: list[str], tag: str, body_text: str,
                          cwd=None) -> list[str]:
    """Failures of the content leg, empty when covered. Each declared
    oid must resolve to a non-merge commit (a merge's resolution has
    no line decomposition the tool can verify, so it fails closed
    naming itself); each of its per-file +/- multisets must sit inside
    the fenced diff chunks', and so must its per-file block-marker
    multisets (mode/rename/binary: the metadata-only shape the +/-
    leg covers vacuously). Failures name commit, file, and the first
    uncovered line or marker, bounded. Order-insensitive like the
    file leg: the chunk may concatenate commits in any order."""
    from collections import Counter
    failures: list[str] = []
    chunk: dict[str, Counter[str]] = {}
    chunk_signals: dict[str, Counter[str]] = {}
    for body in unfence_diff_bodies(body_text, tag):
        for path, counts in _diff_change_lines(body).items():
            chunk[path] = chunk.get(path, Counter()) + counts
        for path, counts in _diff_signal_lines(body).items():
            chunk_signals[path] = chunk_signals.get(path, Counter()) + counts
    for oid in commits:
        if not git_oid_exists(oid, cwd=cwd):
            failures.append(f"declared commit {oid} resolves to nothing")
            continue
        if git_object_type(oid, cwd=cwd) != "commit":
            failures.append(f"declared commit {oid} is not a commit")
            continue
        parents = git_commit_parents(oid, cwd=cwd)
        if parents is None:
            failures.append(f"declared commit {oid} lists no parents")
            continue
        if len(parents) > 1:
            failures.append(
                f"declared commit {oid} is a merge ({len(parents)} parents); "
                "declare linear commits")
            continue
        try:
            proc = git_show_patch(oid, cwd=cwd)
        except OSError as exc:
            failures.append(f"declared commit {oid} unreadable: {exc}")
            continue
        if proc.returncode != 0:
            detail = proc.stderr.decode("utf-8", "replace").strip()[:120]
            failures.append(f"declared commit {oid} unreadable: {detail}")
            continue
        patch_text = proc.stdout.decode("utf-8", "replace")
        for path, counts in _diff_change_lines(patch_text).items():
            have = chunk.get(path)
            if have is None:
                failures.append(
                    f"declared commit {oid} touches {path}, absent from the chunk")
                continue
            missing = counts - have
            if missing:
                first = sorted(missing.elements())[0][:80]
                failures.append(
                    f"declared commit {oid} leaves {sum(missing.values())} "
                    f"line(s) uncovered in {path} (e.g. {first!r})")
        for path, counts in _diff_signal_lines(patch_text).items():
            have = chunk_signals.get(path)
            if have is None:
                failures.append(
                    f"declared commit {oid} marks {path}, absent from the chunk")
                continue
            missing = counts - have
            if missing:
                first = sorted(missing.elements())[0][:80]
                failures.append(
                    f"declared commit {oid} leaves {sum(missing.values())} "
                    f"marker(s) uncovered in {path} (e.g. {first!r})")
    return failures


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
    MANIFEST line reads. The pair anchors to the line's trailing
    fields: a `base=` or `head=` inside `diff-files` or `titles` is
    payload, never identity (D00 T04 §21: a hostile path poisoned the
    old whole-line search). A pair anywhere but trailing reads as no
    pair, failing closed at the identity check."""
    for line in text.splitlines():
        mm = MANIFEST_RE.match(line.strip())
        if mm:
            rest = mm.group("rest")
            m = re.search(r"\sbase=(\S+)\s+head=(\S+)\s*$", rest)
            if m:
                return m.group(1), m.group(2)
            m = re.search(r"\sbase=(\S+)\s*$", rest)
            if m:
                return m.group(1), None
            m = re.search(r"\shead=(\S+)\s*$", rest)
            if m:
                return None, m.group(1)
            return None, None
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
        ["git", "--no-replace-objects", "cat-file", "-e", oid],
        capture_output=True, cwd=cwd)
    return proc.returncode == 0


def git_head_tree(head: str, cwd=None) -> str | None:
    """The `^{tree}` of an OID, else None when it resolves to nothing.
    Pass-through for trees: `rev-parse <tree>^{tree}` exits 0 echoing
    the tree (driven), so callers needing a commit gate the type first."""
    import subprocess
    proc = subprocess.run(
        ["git", "--no-replace-objects", "rev-parse", f"{head}^{{tree}}"],
        capture_output=True, text=True, cwd=cwd)
    if proc.returncode != 0:
        return None
    return proc.stdout.strip()


def git_object_type(oid: str, cwd=None) -> str | None:
    """The object type of an OID, else None when it resolves to nothing.
    Replacement refs stay disabled on every identity call: a
    refs/replace/<tree> pointing at a commit would otherwise spoof the
    type gate (driven)."""
    import subprocess
    proc = subprocess.run(
        ["git", "--no-replace-objects", "cat-file", "-t", oid],
        capture_output=True, text=True, cwd=cwd)
    if proc.returncode != 0:
        return None
    return proc.stdout.strip()


def git_range_merges(base: str, head: str, cwd=None) -> list[str] | None:
    """Merge commits in (base..head], None when git cannot list them
    (an unresolvable pair or a non-commit endpoint: the offline path
    skips the merge gate, since only resolved commit pairs fence in
    the skill flows)."""
    import subprocess
    proc = subprocess.run(
        ["git", "--no-replace-objects", "rev-list", "--merges",
         f"{base}..{head}"],
        capture_output=True, check=False, cwd=cwd)
    if proc.returncode != 0:
        return None
    return proc.stdout.decode("utf-8", "replace").split()


def refuse_merge_candidate(base: str | None, head: str | None,
                           cwd=None) -> str | None:
    """The merge-candidate refusal, else None when fenceable. Merge
    candidates are forbidden outright (D00 T04 §21): any parent range
    satisfies the old advice while concealing merge-resolution
    behavior, so a merge head or a range spanning a merge refuses
    naming the merges. Unresolvable pairs and tree heads skip (the
    offline path: the stamp flow fences a staged tree by design)."""
    if base is None or head is None:
        return None
    if git_object_type(head, cwd=cwd) == "commit":
        parents = git_commit_parents(head, cwd=cwd) or []
        if len(parents) > 1:
            return (f"refusing merge candidate {head} "
                    f"(parents {' '.join(parents)}): fence a linear range instead")
    merges = git_range_merges(base, head, cwd=cwd)
    if merges:
        shown = " ".join(merges[:3])
        more = "" if len(merges) <= 3 else f" (+{len(merges) - 3} more)"
        return (f"refusing range {base}..{head} spanning merge(s) "
                f"{shown}{more}: fence a linear range instead")
    return None


def git_diff_names(base: str, head: str, cwd=None):
    """The cross-check file listing: NUL-delimited paths, no rename
    detection, replacement refs disabled so a refs/replace cannot swap
    the compared content. Returns the completed process; raises OSError
    when git cannot spawn."""
    import subprocess
    return subprocess.run(
        ["git", "--no-replace-objects", "diff", "--name-only", "-z",
         "--no-renames", base, head],
        capture_output=True, check=False, cwd=cwd)


def git_commit_names(oid: str, cwd=None):
    """One commit's touched paths: NUL-delimited, no rename detection
    (both sides list, matching the manifest's [old, new]), message
    suppressed, replacement refs disabled. Returns the completed
    process; raises OSError when git cannot spawn."""
    import subprocess
    return subprocess.run(
        ["git", "--no-replace-objects", "show", "--format=",
         "--name-only", "-z", "--no-renames", oid],
        capture_output=True, check=False, cwd=cwd)


def check_attest_resolution(base: str, head: str, tree: str, cwd=None) -> str | None:
    """Resolve the attest triple before anything is written: base and head
    must be commits (existence alone admits a tree-as-head, since
    `rev-parse <tree>^{tree}` passes the tree through), and the tree must
    belong to the head. Returns the failure line, else None."""
    for name, oid in (("--base", base), ("--head", head)):
        if not git_oid_exists(oid, cwd=cwd):
            return f"attest: {name} {oid} resolves to nothing"
        if git_object_type(oid, cwd=cwd) != "commit":
            return f"attest: {name} {oid} is not a commit"
    if not git_oid_exists(tree, cwd=cwd):
        return f"attest: --tree {tree} resolves to nothing"
    if git_head_tree(head, cwd=cwd) != tree:
        return f"attest: --tree {tree} is not the tree of --head {head}"
    return None


def read_attestation(text: str) -> dict:
    """Read an attestation back: JSON parses, schema asserts, every
    field re-validates through its schema's writer. Schema 1 is the
    frozen legacy shape (bare PASS checker, no bindings); schema 2
    carries the emit-time bindings (D00 T04 §21). Raises ValueError
    naming the first defect."""
    try:
        doc = json.loads(text)
    except json.JSONDecodeError as exc:
        raise ValueError(f"attestation is not JSON: {exc}")
    if not isinstance(doc, dict):
        raise ValueError("attestation is not an object")
    schema = doc.get("schema")
    if type(schema) is not int or schema not in (ATTEST_SCHEMA, ATTEST_SCHEMA_V2):
        raise ValueError(
            f"attestation schema is {schema!r}, want {ATTEST_SCHEMA} or {ATTEST_SCHEMA_V2}")
    fields = _ATTEST_FIELDS if schema == ATTEST_SCHEMA else _ATTEST_V2_FIELDS
    writer = write_attestation if schema == ATTEST_SCHEMA else write_attestation_v2
    try:
        writer(**{k: doc[k] for k in fields})
    except KeyError as exc:
        raise ValueError(f"attestation misses field {exc}")
    return doc


ATTEST_SCHEMA_V2 = 2
_ATTEST_V2_FIELDS = ("manifest_sha", "candidate_base", "candidate_head", "tree",
                     "reviewer", "model", "verdict", "checker", "timestamp",
                     "findings_path", "findings_sha256", "runner_sha256")
_CHECKER_BOUND_RE = re.compile(r"^PASS (?P<reason>.+) :: (?P<sha>[0-9a-f]{64})$")


def write_attestation_v2(*, manifest_sha: str, candidate_base: str,
                         candidate_head: str, tree: str, reviewer: str,
                         model: str, verdict: str, checker: str,
                         timestamp: str, findings_path: str,
                         findings_sha256: str, runner_sha256: str) -> str:
    """A schema-2 attestation: the v1 fields plus emit-time bindings.
    The shared fields re-validate through the frozen v1 writer (one
    shape authority); the checker must be a bound PASS line (`PASS
    <reason> :: <transcript sha>`, from the check step's own output
    file, never a pasted string); findings_path is repo-relative with
    its sha binding the artifact beside the attestation; runner_sha256
    binds the runner output the reviewer/model/timestamp derived from.
    Anything else raises ValueError."""
    base = json.loads(write_attestation(
        manifest_sha=manifest_sha, candidate_base=candidate_base,
        candidate_head=candidate_head, tree=tree, reviewer=reviewer,
        model=model, verdict=verdict, checker=checker, timestamp=timestamp))
    m = _CHECKER_BOUND_RE.match(checker)
    if m is None or not m.group("reason").strip():
        raise ValueError(
            "attestation checker is not a bound PASS line "
            "(`PASS <reason> :: <64hex transcript sha>`)")
    segs = findings_path.split("/") if isinstance(findings_path, str) else []
    if (not isinstance(findings_path, str) or not findings_path
            or "\\" in findings_path or findings_path.startswith("/")
            or any(s in ("", ".", "..") for s in segs)):
        raise ValueError(
            f"attestation findings_path is not a repo-relative path: "
            f"{findings_path[:80]!r}")
    for name, oid in (("findings_sha256", findings_sha256),
                      ("runner_sha256", runner_sha256)):
        if not isinstance(oid, str) or not re.fullmatch(r"[0-9a-f]{64}", oid):
            shown = oid if isinstance(oid, str) else repr(oid)
            raise ValueError(
                f"attestation {name} is not 64 hex chars: {shown[:80]!r}")
    base["schema"] = ATTEST_SCHEMA_V2
    base["findings_path"] = findings_path
    base["findings_sha256"] = findings_sha256
    base["runner_sha256"] = runner_sha256
    return json.dumps(base, indent=2, sort_keys=True) + "\n"


def derive_runner_identity(runner_text: str) -> tuple[str | None, str | None, str | None]:
    """(reviewer, model-or-None, error) from the runner's own output. A
    JSON envelope with a string result reads claude-panel, with the
    envelope's non-empty model (None when absent or empty: the §20
    Opus envelope carried an empty model field, honestly unmeasured
    rather than guessed). Anything else reads codex-panel with no
    model: codex output names none, so the skill's model pin fills it
    (recorded, with the transcript hashed). An error envelope, or a
    dict JSON without a string result, fails exactly as the output
    checker fails it: the attestation never derives from output the
    checker would refuse."""
    _, envelope_err = panel_text_from_envelope(runner_text)
    if envelope_err is not None:
        return None, None, envelope_err
    try:
        obj = json.loads(runner_text)
    except ValueError:
        return "codex-panel", None, None
    if not isinstance(obj, dict) or not isinstance(obj.get("result"), str):
        return "codex-panel", None, None
    model = obj.get("model")
    model = model.strip() if isinstance(model, str) and model.strip() else None
    return "claude-panel", model, None


def runner_timestamp(path: str) -> str:
    """The run clock: the runner-output file's mtime in UTC. The skill
    redirects the runner into that file, so its mtime is the run's end
    (a hand-supplied --timestamp must equal it, never override it)."""
    import os
    return datetime.datetime.fromtimestamp(
        os.path.getmtime(path), tz=datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


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
    env = json.dumps({"type": "result", "subtype": "success", "is_error": False,
                      "result": receipt + approves,
                      "usage": {"input_tokens": 2, "output_tokens": 4,
                                "cache_read_input_tokens": 0,
                                "cache_creation_input_tokens": 39821}})
    ok, reason = check_panel_output(env, manifest3)
    check("envelope-pass", ok, reason)
    env_err = json.dumps({"type": "result", "subtype": "error", "is_error": True,
                          "result": receipt + approves})
    ok, reason = check_panel_output(env_err, manifest3)
    check("envelope-error-fails", (not ok) and "approving nothing" in reason, reason)
    env_nores = json.dumps({"type": "result", "subtype": "success", "is_error": False})
    ok, reason = check_panel_output(env_nores, manifest3)
    check("envelope-no-result-fails", (not ok) and "no string `result`" in reason, reason)
    cost_total, cost_err = round_cost_from_envelope(env)
    check("round-cost-sums-classes", cost_total == 39827 and cost_err is None,
          f"{cost_total} {cost_err}")
    cost_total, cost_err = round_cost_from_envelope(json.dumps({"type": "result"}))
    check("round-cost-no-usage-fails",
          cost_total is None and "no `usage` block" in (cost_err or ""),
          f"{cost_total} {cost_err}")
    for bad_usage, leg in (({"input_tokens": True}, "bool"),
                           ({"output_tokens": 4.5}, "float"),
                           ({"input_tokens": "12"}, "string"),
                           ({"input_tokens": -1}, "negative")):
        cost_total, cost_err = round_cost_from_envelope(json.dumps({"usage": bad_usage}))
        check(f"round-cost-{leg}-fails",
              cost_total is None and "non-integer token count" in (cost_err or ""),
              f"{cost_total} {cost_err}")
    cost_total, cost_err = round_cost_from_envelope(
        json.dumps({"usage": {"input_tokens": 2, "output_tokens": 4}}))
    check("round-cost-absent-classes-zero",
          cost_total == 6 and cost_err is None, f"{cost_total} {cost_err}")

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
    for want in ("my\\sfile.md", "caf\u00e9.md", 'quo"te.md', "renamed.md",
                 "old.md", "new.md", "gone.md"):
        check(f"manifest-grammar-{want}", want in mline3, mline3)
    check("manifest-grammar-roundtrip",
          parse_manifest_diff_files(f"TAG {tag} nonce={nonce}\n{mline3}\n") == [
              "my file.md", "caf\u00e9.md", 'quo"te.md', "renamed.md",
              "old.md", "new.md", "gone.md"],
          mline3)
    # The adversarial split: bare ` b/` on both sides of a rename, where
    # the agree-else-last rule fabricates a path in neither side. The
    # rename pair git emits for exactly this case is authoritative.
    hostile = ("diff --git a/old b/x.md b/new b/y.md\n"
               "similarity index 50%\n"
               "rename from old b/x.md\n"
               "rename to new b/y.md\n")
    mline4, _ = build_manifest(tag, [("CANDIDATE DIFF", hostile)], nonce=nonce)
    check("manifest-rename-authoritative",
          "diff-files=old\\sb/x.md|new\\sb/y.md" in mline4, mline4)
    check("manifest-rename-roundtrip",
          parse_manifest_diff_files(f"TAG {tag} nonce={nonce}\n{mline4}\n") == [
              "old b/x.md", "new b/y.md"],
          mline4)
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
    # writes, all identity via -c flags, an empty template dir, and an
    # empty hooks dir, so configured init.templateDir and core.hooksPath
    # cannot reach the fixture), on any machine with git, which the CLI
    # paths under test require throughout.
    import os
    import subprocess
    import tempfile
    with tempfile.TemporaryDirectory(prefix="review-resolve-") as tmpd:
        empty = os.path.join(tmpd, "empty")
        os.mkdir(empty)
        subprocess.run(["git", "init", "-q", "--template=" + empty, tmpd],
                       capture_output=True, check=True)
        with open(os.path.join(tmpd, "f.md"), "w", encoding="utf-8") as fh:
            fh.write("fixture\n")
        subprocess.run(["git", "-C", tmpd, "add", "f.md"],
                       capture_output=True, check=True)
        subprocess.run(["git", "-C", tmpd, "-c", "user.email=t@t.invalid",
                        "-c", "user.name=t", "-c", "commit.gpgsign=false",
                        "-c", "core.hooksPath=" + empty,
                        "commit", "-qm", "fixture"], capture_output=True,
                       check=True)
        rhead = subprocess.run(["git", "-C", tmpd, "rev-parse", "HEAD"],
                               capture_output=True, text=True,
                               check=True).stdout.strip()
        rtree = subprocess.run(["git", "-C", tmpd, "rev-parse", "HEAD^{tree}"],
                               capture_output=True, text=True,
                               check=True).stdout.strip()
        with open(os.path.join(tmpd, "g.md"), "w", encoding="utf-8") as fh:
            fh.write("second\n")
        subprocess.run(["git", "-C", tmpd, "add", "g.md"],
                       capture_output=True, check=True)
        subprocess.run(["git", "-C", tmpd, "-c", "user.email=t@t.invalid",
                        "-c", "user.name=t", "-c", "commit.gpgsign=false",
                        "-c", "core.hooksPath=" + empty,
                        "commit", "-qm", "second"], capture_output=True,
                       check=True)
        rhead2 = subprocess.run(["git", "-C", tmpd, "rev-parse", "HEAD"],
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
        check("resolve-attest-triple-ok",
              check_attest_resolution(rhead, rhead, rtree, cwd=tmpd) is None)
        got_head = check_attest_resolution(rhead, rtree, rtree, cwd=tmpd)
        check("resolve-attest-tree-head-refused",
              got_head == f"attest: --head {rtree} is not a commit",
              got_head or "ok")
        got_base = check_attest_resolution(rtree, rhead, rtree, cwd=tmpd)
        check("resolve-attest-tree-base-refused",
              got_base == f"attest: --base {rtree} is not a commit",
              got_base or "ok")
        subprocess.run(["git", "-C", tmpd, "update-ref",
                        f"refs/replace/{rtree}", rhead],
                       capture_output=True, check=True)
        got_rtype = git_object_type(rtree, cwd=tmpd)
        check("resolve-ignores-replace-refs",
              got_rtype == "tree", got_rtype or "none")
        subprocess.run(["git", "-C", tmpd, "update-ref",
                        f"refs/replace/{rhead}", rhead2],
                       capture_output=True, check=True)
        empty_tree = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
        raw_diff = subprocess.run(
            ["git", "-C", tmpd, "diff", "--name-only", "-z",
             "--no-renames", empty_tree, rhead],
            capture_output=True, check=True)
        check("resolve-diff-replace-swaps-unflagged",
              raw_diff.stdout == b"f.md\x00g.md\x00", raw_diff.stdout)
        got_diff = git_diff_names(empty_tree, rhead, cwd=tmpd)
        check("resolve-diff-ignores-replace-refs",
              got_diff.stdout == b"f.md\x00", got_diff.stdout)
    check("nonce-shape", re.fullmatch(r"[0-9a-f]{16}", unique_nonce()) is not None)
    # D00 T04 §21 pins: review-input integrity hardening.
    poison = (f"TAG {tag} nonce={nonce}\n"
              f"MANIFEST bytes=1 files=1 sha={'1' * 64} titles=CANDIDATE DIFF "
              "diff-files=a base=evil|b head=fake base=realbase head=realhead\n")
    check("identity-anchored-poisoned",
          parse_manifest_identity(poison) == ("realbase", "realhead"),
          str(parse_manifest_identity(poison)))
    clean_id = (f"TAG {tag} nonce={nonce}\n"
                f"MANIFEST bytes=1 files=1 sha={'1' * 64} titles=X base=b0 head=h1\n")
    check("identity-anchored-clean",
          parse_manifest_identity(clean_id) == ("b0", "h1"))
    base_only = (f"TAG {tag} nonce={nonce}\n"
                 f"MANIFEST bytes=1 files=1 sha={'1' * 64} titles=X base=b0\n")
    check("identity-anchored-base-only",
          parse_manifest_identity(base_only) == ("b0", None))
    mid_pair = (f"TAG {tag} nonce={nonce}\n"
                f"MANIFEST bytes=1 files=1 sha={'1' * 64} titles=X "
                "base=b0 head=h1 extra=junk\n")
    check("identity-non-trailing-closed",
          parse_manifest_identity(mid_pair) == (None, None))
    hostile_names = ["a|b.md", "li\nne.md", "sp ace.md", "back\\slash.md",
                     "x base=y.md", "weird commits=deadbeef", "ta	b.md"]
    quoted = "|".join(quote_manifest_name(n) for n in hostile_names)
    check("manifest-quote-hostile-roundtrip",
          split_manifest_names(quoted) == hostile_names, quoted)
    check("manifest-quote-space-form",
          quote_manifest_name("sp ace.md") == "sp\\sace.md")
    check("manifest-quote-no-literal-space",
          " " not in quoted and "\t" not in quoted and "\r" not in quoted,
          quoted)
    hostile_line = (f"TAG {tag} nonce={nonce}\n"
                    f"MANIFEST bytes=1 files=1 sha={'5' * 64} titles=X diff-files="
                    + quoted + " base=b0 head=h1\n")
    check("manifest-quote-hostile-boundary",
          parse_manifest_diff_files(hostile_line) == hostile_names, hostile_line)
    check("manifest-quote-legacy-backslash",
          split_manifest_names("a\\b|c") == ["a\\b", "c"])
    check("manifest-quote-trailing-backslash",
          split_manifest_names("a\\") == ["a\\"])
    mcomm = (f"TAG {tag} nonce={nonce}\n"
             f"MANIFEST bytes=1 files=1 sha={'2' * 64} titles=X "
             "commits=aaa|bbb base=b0 head=h1\n")
    check("manifest-commits-parse",
          parse_manifest_commits(mcomm) == ["aaa", "bbb"])
    check("manifest-commits-absent", parse_manifest_commits(clean_id) == [])
    _utag, _unonce, _fenced = fence_chunks_checked(
        "PANEL", [("SECTION", "prose\n+notacount\n"),
                  ("CANDIDATE DIFF", "diff --git a/f b/f\n--- a/f\n+++ b/f\n@@\n+x\n")])
    check("unfence-diff-only",
          unfence_diff_bodies(_fenced, _utag) == [
              "diff --git a/f b/f\n--- a/f\n+++ b/f\n@@\n+x"],
          _fenced)
    check("unfence-wrong-tag", unfence_diff_bodies(_fenced, "OTHER") == [])
    from collections import Counter as _Counter
    sample = ("diff --git a/f.md b/f.md\n--- a/f.md\n+++ b/f.md\n@@ -1 +1 @@\n-old\n+new\n"
              "diff --git a/g.md b/g.md\n--- a/g.md\n+++ /dev/null\n@@\n-gone\n"
              "diff --git a/h.md b/h.md\n--- /dev/null\n+++ b/h.md\n@@\n+born\n")
    check("change-lines-add-del-new",
          _diff_change_lines(sample) == {
              "f.md": _Counter({"-old": 1, "+new": 1}),
              "g.md": _Counter({"-gone": 1}),
              "h.md": _Counter({"+born": 1})},
          str(_diff_change_lines(sample)))
    tricky = "diff --git a/t b/t\n--- a/t\n+++ b/t\n@@\n--- x\n+-- y\n+++ z\n"
    check("change-lines-content-ambiguity",
          _diff_change_lines(tricky) == {
              "t": _Counter({"--- x": 1, "+-- y": 1, "+++ z": 1})},
          str(_diff_change_lines(tricky)))
    rename_block = ("diff --git a/o.md b/n.md\nsimilarity index 91% 100%\n"
                    "rename from o.md\nrename to n.md\n"
                    "--- a/o.md\n+++ b/n.md\n@@\n-old\n+new\n")
    check("signal-lines-rename",
          _diff_signal_lines(rename_block) == {
              "n.md": _Counter({"similarity index 91% 100%": 1,
                                "rename from o.md": 1,
                                "rename to n.md": 1})},
          str(_diff_signal_lines(rename_block)))
    check("signal-lines-rename-changes",
          _diff_change_lines(rename_block) == {
              "n.md": _Counter({"-old": 1, "+new": 1})},
          str(_diff_change_lines(rename_block)))
    mode_block = ("diff --git a/f.md b/f.md\nold mode 100644\n"
                  "new mode 100755\n")
    check("signal-lines-mode",
          _diff_signal_lines(mode_block) == {
              "f.md": _Counter({"old mode 100644": 1,
                                "new mode 100755": 1})},
          str(_diff_signal_lines(mode_block)))
    check("signal-lines-mode-no-changes",
          _diff_change_lines(mode_block) == {},
          str(_diff_change_lines(mode_block)))
    bin_block = ("diff --git a/b.bin b/b.bin\n"
                 "Binary files a/b.bin and b/b.bin differ\n")
    check("signal-lines-binary",
          _diff_signal_lines(bin_block) == {
              "b.bin": _Counter(
                  {"Binary files a/b.bin and b/b.bin differ": 1})},
          str(_diff_signal_lines(bin_block)))
    check("signal-lines-index-excluded",
          _diff_signal_lines("diff --git a/f b/f\nindex aaa..bbb 100644\n"
                             "--- a/f\n+++ b/f\n@@\n+x\n") == {},
          "index and diff-git lines are not signals")
    stamp_man = ("STAMP-abc", "3" * 64, "4" * 16)
    good_receipt = f"RECEIPT sha={'3' * 64} end=STAMP-abc nonce={'4' * 16}\n"
    check("stamp-holds",
          check_stamp_output(good_receipt + "STAMP HOLDS.\n", stamp_man)
          == (True, "stamp holds"))
    check("stamp-namings",
          check_stamp_output(good_receipt + "`a` -> `b`\n`c` -> `d`\n", stamp_man)
          == (True, "2 naming(s) to answer"))
    check("stamp-truncated",
          check_stamp_output("STAMP HOLDS.\n", stamp_man)[0] is False)
    check("stamp-empty",
          check_stamp_output(good_receipt + "\n", stamp_man)
          == (False, "no verdict after the receipt"))
    check("stamp-holds-junk",
          check_stamp_output(good_receipt + "STAMP HOLDS.\n`x` -> `y`\n", stamp_man)
          == (False, "line 2 follows STAMP HOLDS"))
    v2good = dict(
        manifest_sha="a" * 64, candidate_base="b" * 40,
        candidate_head="c" * 40, tree="d" * 40, reviewer="claude-panel",
        model="opus", verdict="approve",
        checker="PASS four lenses, one verdict each :: " + "e" * 64,
        timestamp="2026-09-20T13:00:00Z",
        findings_path="docs/reviews/00-workspace/D00-T04-s21.md",
        findings_sha256="f" * 64, runner_sha256="0" * 64)
    doc2 = write_attestation_v2(**v2good)
    check("attest-v2-roundtrip", read_attestation(doc2)["schema"] == 2)
    try:
        write_attestation_v2(**dict(v2good, checker="PASS four lenses, one verdict each"))
        v2_unbound = False
    except ValueError as exc:
        v2_unbound = "bound PASS" in str(exc)
    check("attest-v2-unbound-checker", v2_unbound)
    try:
        write_attestation_v2(**dict(v2good, findings_path="/abs/path.md"))
        v2_abspath = False
    except ValueError as exc:
        v2_abspath = "repo-relative" in str(exc)
    check("attest-v2-absolute-findings", v2_abspath)
    try:
        write_attestation_v2(**dict(v2good, findings_path="docs/../x.md"))
        v2_dotdot = False
    except ValueError as exc:
        v2_dotdot = "repo-relative" in str(exc)
    check("attest-v2-dotdot-findings", v2_dotdot)
    check("attest-v1-legacy-reads", read_attestation(att)["schema"] == 1)
    check("runner-id-codex",
          derive_runner_identity("RECEIPT sha=x\n**adversarial: approve**")
          == ("codex-panel", None, None))
    check("runner-id-claude",
          derive_runner_identity('{"result": "x", "model": "opus"}')
          == ("claude-panel", "opus", None))
    check("runner-id-empty-model",
          derive_runner_identity('{"result": "x", "model": ""}')
          == ("claude-panel", None, None))
    check("runner-id-error",
          derive_runner_identity('{"is_error": true, "subtype": "x"}')[2] is not None)
    check("runner-id-dict-no-result",
          derive_runner_identity('{"a": 1}')[2] is not None)
    check("runner-id-brace-text",
          derive_runner_identity("{not json") == ("codex-panel", None, None))
    # Git-backed legs: a linear r1->r2->r3 plus a merge, fenced and
    # cross-checked end to end (D00 T04 §21 items 1, 8, 12, 15).
    with tempfile.TemporaryDirectory(prefix="review-s21-") as tmpd:
        def _git(*a):
            return subprocess.run(["git", *a], cwd=tmpd, capture_output=True,
                                  check=True, text=True)

        _git("init", "-q", "-b", "main")
        _git("config", "user.email", "t@t")
        _git("config", "user.name", "t")
        _git("config", "commit.gpgsign", "false")
        with open(os.path.join(tmpd, "f.md"), "w", encoding="utf-8") as fh:
            fh.write("one\n")
        _git("add", "f.md")
        _git("commit", "-qm", "r1")
        with open(os.path.join(tmpd, "f.md"), "w", encoding="utf-8") as fh:
            fh.write("one\ntwo\n")
        _git("commit", "-qam", "r2")
        with open(os.path.join(tmpd, "f.md"), "w", encoding="utf-8") as fh:
            fh.write("one\ntwo\nthree\n")
        _git("commit", "-qam", "r3")
        r1 = _git("rev-parse", "HEAD~2").stdout.strip()
        r2 = _git("rev-parse", "HEAD~1").stdout.strip()
        r3 = _git("rev-parse", "HEAD").stdout.strip()
        show2 = subprocess.run(
            ["git", "--no-replace-objects", "show", "--format=", r2],
            cwd=tmpd, capture_output=True, check=True, text=True).stdout
        show3 = subprocess.run(
            ["git", "--no-replace-objects", "show", "--format=", r3],
            cwd=tmpd, capture_output=True, check=True, text=True).stdout
        # The §12 regression shape: r3 dropped from the chunk while the
        # file sets still agree on f.md (r2's file), so only the content
        # leg can catch it.
        full_chunk = show2 + show3
        dropped_chunk = show2
        for name, chunk in (("full", full_chunk), ("dropped", dropped_chunk)):
            ctag, cnonce, cbody = fence_chunks_checked(
                "PANEL", [("CANDIDATE DIFF", chunk)])
            cline, _ = build_manifest(ctag, [("CANDIDATE DIFF", chunk)],
                                      r1, r3, nonce=cnonce, commits=[r2, r3])
            with open(os.path.join(tmpd, f"{name}-manifest.md"), "w",
                      encoding="utf-8") as fh:
                fh.write(f"TAG {ctag} nonce={cnonce}\n{cline}\n")
            with open(os.path.join(tmpd, f"{name}-fenced.md"), "w",
                      encoding="utf-8") as fh:
                fh.write(f"TAG {ctag} nonce={cnonce}\n{cline}\n{cbody}")
        # The same dropped chunk fenced the legacy way (no commits
        # claim): the file-set leg agrees, proving the gap.
        ltag, lnonce, _lbody = fence_chunks_checked(
            "PANEL", [("CANDIDATE DIFF", dropped_chunk)])
        lcline, _ = build_manifest(ltag, [("CANDIDATE DIFF", dropped_chunk)],
                                   r1, r3, nonce=lnonce)
        with open(os.path.join(tmpd, "legacy-manifest.md"), "w",
                  encoding="utf-8") as fh:
            fh.write(f"TAG {ltag} nonce={lnonce}\n{lcline}\n")
        fenced_full = open(os.path.join(tmpd, "full-fenced.md"),
                           encoding="utf-8").read()
        ttag = parse_manifest_file(
            open(os.path.join(tmpd, "full-manifest.md"),
                 encoding="utf-8").read())[0]
        check("commits-covered",
              check_commits_covered([r2, r3], ttag, fenced_full, cwd=tmpd) == [])
        fenced_dropped = open(os.path.join(tmpd, "dropped-fenced.md"),
                              encoding="utf-8").read()
        dtag = parse_manifest_file(
            open(os.path.join(tmpd, "dropped-manifest.md"),
                 encoding="utf-8").read())[0]
        missed = check_commits_covered([r2, r3], dtag, fenced_dropped, cwd=tmpd)
        check("commits-dropped-fails",
              len(missed) == 1 and r3 in missed[0] and "f.md" in missed[0],
              str(missed))
        check("commits-unresolvable",
              check_commits_covered(["0" * 40], ttag, fenced_full, cwd=tmpd)
              == ["declared commit " + "0" * 40 + " resolves to nothing"])
        # The merge legs: a merge head and a mid-range merge refuse;
        # linear, unresolvable, and tree heads fence.
        _git("checkout", "-qb", "side", r1)
        with open(os.path.join(tmpd, "s.md"), "w", encoding="utf-8") as fh:
            fh.write("side\n")
        _git("add", "s.md")
        _git("commit", "-qm", "side1")
        _git("checkout", "-q", "main")
        _git("merge", "--no-ff", "-qm", "merge", "side")
        mg = _git("rev-parse", "HEAD").stdout.strip()
        p1 = _git("rev-parse", "HEAD^1").stdout.strip()
        check("merge-head-refused",
              (refuse_merge_candidate(r1, mg, cwd=tmpd) or "").startswith(
                  f"refusing merge candidate {mg} (parents "))
        with open(os.path.join(tmpd, "f.md"), "a", encoding="utf-8") as fh:
            fh.write("four\n")
        _git("commit", "-qam", "r4")
        r4 = _git("rev-parse", "HEAD").stdout.strip()
        check("merge-range-refused",
              (refuse_merge_candidate(r1, r4, cwd=tmpd) or "").startswith(
                  f"refusing range {r1}..{r4} spanning merge(s) "))
        check("merge-linear-passes",
              refuse_merge_candidate(r1, r3, cwd=tmpd) is None)
        check("merge-offline-skips",
              refuse_merge_candidate("base000", "head111", cwd=tmpd) is None)
        rtree = _git("rev-parse", f"{r3}^{{tree}}").stdout.strip()
        check("merge-tree-head-skips",
              refuse_merge_candidate(r1, rtree, cwd=tmpd) is None)
        check("parents-linear-ok",
              check_parent_binding(r3, r2, cwd=tmpd) is None)
        check("parents-wrong",
              (check_parent_binding(r3, r1, cwd=tmpd) or "").startswith(
                  f"check-parents: {r3} sits on "))
        check("parents-merge",
              (check_parent_binding(mg, p1, cwd=tmpd) or "").startswith(
                  f"check-parents: {mg} is a merge (parents "))
        check("parents-kind-commit",
              git_object_type(r3, cwd=tmpd) == "commit"
              and git_object_type(rtree, cwd=tmpd) == "tree")
        # The metadata-only shape (independent-review F5): a pure rename
        # commit has no +/- lines, so only the marker leg can catch a
        # chunk that drops it while another commit preserves the files.
        # (Placed after the f.md legs: the rename moves that file.)
        _git("checkout", "-q", "main")
        _git("mv", "f.md", "g.md")
        _git("commit", "-qm", "r5 rename")
        r5 = _git("rev-parse", "HEAD").stdout.strip()
        show5 = subprocess.run(
            ["git", "--no-replace-objects", "show", "--format=", r5],
            cwd=tmpd, capture_output=True, check=True, text=True).stdout
        rtag, rnonce, rbody = fence_chunks_checked(
            "PANEL", [("CANDIDATE DIFF", show5)])
        rcline, _ = build_manifest(rtag, [("CANDIDATE DIFF", show5)],
                                   r3, r5, nonce=rnonce, commits=[r5])
        rfenced = (f"TAG {rtag} nonce={rnonce}\n{rcline}\n{rbody}")
        check("commits-rename-covered",
              check_commits_covered([r5], rtag, rfenced, cwd=tmpd) == [])
        mtag, mnonce, mbody = fence_chunks_checked(
            "PANEL", [("CANDIDATE DIFF", show2)])
        mcline, _ = build_manifest(mtag, [("CANDIDATE DIFF", show2)],
                                   r1, r2, nonce=mnonce, commits=[r5])
        mfenced = (f"TAG {mtag} nonce={mnonce}\n{mcline}\n{mbody}")
        rmissed = check_commits_covered([r5], mtag, mfenced, cwd=tmpd)
        check("commits-rename-dropped-fails",
              len(rmissed) == 1 and r5 in rmissed[0]
              and "marks g.md" in rmissed[0],
              str(rmissed))
        # Hostile fence paths (D00 T04 §21 item 16): spaces, non-ASCII,
        # and `=` inside TITLE=path read clean.
        hostile_dir = os.path.join(tmpd, "my dir", "café")
        os.makedirs(hostile_dir)
        hostile_chunk = os.path.join(hostile_dir, "a=b.md")
        with open(hostile_chunk, "w", encoding="utf-8") as fh:
            fh.write("section text\n")
        proc = subprocess.run(
            [sys.executable, __file__, "fence", "PANEL",
             f"SECTION HOSTILE={hostile_chunk}"],
            capture_output=True, cwd=tmpd)
        try:
            hout = proc.stdout.decode("utf-8")
        except UnicodeDecodeError:
            hout = ""
        check("fence-hostile-path",
              proc.returncode == 0 and hout.startswith("TAG ")
              and "\nMANIFEST " in hout,
              f"exit={proc.returncode} err={proc.stderr[-160:]!r}")
        # An alternate temp root: TMP/TEMP/TMPDIR all redirected (Windows
        # python ignores TMPDIR, so all three move), chunk inside.
        alt_root = os.path.join(tmpd, "alt temp")
        os.makedirs(alt_root)
        alt_chunk = os.path.join(alt_root, "c.md")
        with open(alt_chunk, "w", encoding="utf-8") as fh:
            fh.write("alt-root text\n")
        alt_env = dict(os.environ, TMP=alt_root, TEMP=alt_root,
                       TMPDIR=alt_root)
        proc = subprocess.run(
            [sys.executable, __file__, "fence", "PANEL",
             f"SECTION ALT={alt_chunk}"],
            capture_output=True, cwd=tmpd, env=alt_env)
        try:
            aout = proc.stdout.decode("utf-8")
        except UnicodeDecodeError:
            aout = ""
        check("fence-alt-temp-root",
              proc.returncode == 0 and aout.startswith("TAG ")
              and "\nMANIFEST " in aout,
              f"exit={proc.returncode} err={proc.stderr[-160:]!r}")
        # Stamp anchors (D00 T04 §21 item 10): a seeded stamp with a
        # dead oid, a dead line, a dead section, a missing file, and a
        # dead full ref, beside passing twins (a live range, a live
        # file, a live section, a live ref) the rule must not flag. The
        # null oid never resolves in any repo, so the dead-oid leg is
        # history-proof; the live legs ride trunk commits, append-only.
        seed_todo = os.path.join(tmpd, "TODO-99-seed.md")
        with open(seed_todo, "w", encoding="utf-8") as fh:
            fh.write(
                "## 1. Seed\n\n"
                "> **Verified:** 2026-09-20 | §1 | evidence "
                "`scripts/review_prompt.py:999999` `§99` "
                "`s21-seed-missing-ghost.md` D00 T99 §1, and live twins "
                "`scripts/review_prompt.py:1` `§1` `todo/README.md` "
                "D00 T04 §21\n"
                "> **Review:** round 1, candidate "
                "`0000000000000000000000000000000000000000` plus range "
                "`fceed42..dbe5d0e` -- approve. "
                "Raw findings: docs/reviews/00-workspace/D00-T04-s99.md\n"
                "> **CRUD:** not applicable\n")
        seed_dead = check_stamp_anchors(seed_todo, 1)
        check("anchors-dead-five",
              len(seed_dead) == 5
              and any("dead oid 0000000" in d for d in seed_dead)
              and any("dead lines scripts/review_prompt.py:999999" in d
                      for d in seed_dead)
              and any("dead in-file §99" in d for d in seed_dead)
              and any("missing file s21-seed-missing-ghost.md" in d
                      for d in seed_dead)
              and any("dead ref D00 T99 §1" in d for d in seed_dead),
              str(seed_dead))
        # The cross-check CLI legs (items 1, 15): the content leg and
        # the kind gate over the fixture repo.
        def _cc(*a):
            return subprocess.run(
                [sys.executable, __file__, "cross-check", *a],
                capture_output=True, cwd=tmpd, text=True)

        full_man = os.path.join(tmpd, "full-manifest.md")
        full_fen = os.path.join(tmpd, "full-fenced.md")
        drop_man = os.path.join(tmpd, "dropped-manifest.md")
        drop_fen = os.path.join(tmpd, "dropped-fenced.md")
        got = _cc(full_man, r1, r3, "--body", full_fen,
                  "--expect-head-kind", "commit")
        check("crosscheck-body-covered",
              got.returncode == 0 and "commit(s) covered" in got.stdout,
              f"exit={got.returncode} out={got.stdout!r} err={got.stderr!r}")
        # The dropped chunk's file set still covers f.md: the legacy
        # (commits-less) manifest agrees, proving the gap the content
        # leg closes.
        got = _cc(os.path.join(tmpd, "legacy-manifest.md"), r1, r3)
        check("crosscheck-body-gap",
              got.returncode == 0 and "file(s) agree" in got.stdout,
              f"exit={got.returncode} out={got.stdout!r} err={got.stderr!r}")
        got = _cc(drop_man, r1, r3, "--body", drop_fen)
        check("crosscheck-body-dropped",
              got.returncode == 1 and r3 in got.stderr and "f.md" in got.stderr,
              f"exit={got.returncode} err={got.stderr!r}")
        got = _cc(full_man, r1, r3)
        check("crosscheck-body-missing",
              got.returncode == 2 and "no --body was given" in got.stderr,
              f"exit={got.returncode} err={got.stderr!r}")
        got = _cc(full_man, r1, r3, "--body", full_fen,
                  "--expect-head-kind", "tree")
        check("crosscheck-kind-cross",
              got.returncode == 1 and "is a commit, want tree" in got.stderr,
              f"exit={got.returncode} err={got.stderr!r}")
        # The assembled shape (review fix F1): an excluded middle commit
        # touches a file no declared commit touches, so the range diff
        # reports `only in git` while the declared union agrees.
        with open(os.path.join(tmpd, "qa.md"), "w", encoding="utf-8") as fh:
            fh.write("a\n")
        _git("add", "qa.md")
        _git("commit", "-qm", "uA")
        uA = _git("rev-parse", "HEAD").stdout.strip()
        with open(os.path.join(tmpd, "qb.md"), "w", encoding="utf-8") as fh:
            fh.write("b\n")
        _git("add", "qb.md")
        _git("commit", "-qm", "uB")
        with open(os.path.join(tmpd, "qa.md"), "a", encoding="utf-8") as fh:
            fh.write("a2\n")
        _git("commit", "-qam", "uC")
        uC = _git("rev-parse", "HEAD").stdout.strip()
        uA_par = _git("rev-parse", f"{uA}^").stdout.strip()

        def _show(oid):
            return subprocess.run(
                ["git", "--no-replace-objects", "show", "--format=", oid],
                cwd=tmpd, capture_output=True, check=True, text=True).stdout

        uchunk = _show(uA) + _show(uC)
        utag, unonce, ubody = fence_chunks_checked(
            "PANEL", [("CANDIDATE DIFF", uchunk)])
        ucline, _ = build_manifest(utag, [("CANDIDATE DIFF", uchunk)],
                                   uA_par, uC, nonce=unonce, commits=[uA, uC])
        uman = os.path.join(tmpd, "union-manifest.md")
        ufen = os.path.join(tmpd, "union-fenced.md")
        with open(uman, "w", encoding="utf-8") as fh:
            fh.write(f"TAG {utag} nonce={unonce}\n{ucline}\n")
        with open(ufen, "w", encoding="utf-8") as fh:
            fh.write(f"TAG {utag} nonce={unonce}\n{ucline}\n{ubody}")
        got = _cc(uman, uA_par, uC, "--body", ufen)
        check("crosscheck-union-assembled",
              got.returncode == 0 and "2 commit(s) covered" in got.stdout,
              f"exit={got.returncode} out={got.stdout!r} err={got.stderr!r}")
        # The same chunk fenced the legacy way: the range oracle sees
        # the excluded commit's file and refuses, proving the union leg
        # is what admits the assembly.
        ltag2, lnonce2, _lbody2 = fence_chunks_checked(
            "PANEL", [("CANDIDATE DIFF", uchunk)])
        lcline2, _ = build_manifest(ltag2, [("CANDIDATE DIFF", uchunk)],
                                    uA_par, uC, nonce=lnonce2)
        uman2 = os.path.join(tmpd, "union-legacy-manifest.md")
        with open(uman2, "w", encoding="utf-8") as fh:
            fh.write(f"TAG {ltag2} nonce={lnonce2}\n{lcline2}\n")
        got = _cc(uman2, uA_par, uC)
        check("crosscheck-union-range-diverges",
              got.returncode == 1 and "only in git: qb.md" in got.stderr,
              f"exit={got.returncode} err={got.stderr!r}")
        bogus = "0" * 40
        bcline, _ = build_manifest(utag, [("CANDIDATE DIFF", uchunk)],
                                   uA_par, uC, nonce=unonce, commits=[bogus])
        bman = os.path.join(tmpd, "union-bogus-manifest.md")
        with open(bman, "w", encoding="utf-8") as fh:
            fh.write(f"TAG {utag} nonce={unonce}\n{bcline}\n")
        got = _cc(bman, uA_par, uC, "--body", ufen)
        check("crosscheck-union-unresolvable",
              got.returncode == 1
              and f"declared commit {bogus} resolves to nothing" in got.stderr,
              f"exit={got.returncode} err={got.stderr!r}")
        # The schema-2 attest CLI (items 4, 5, 9): emit, read back,
        # mismatch, and replacement legs over the fixture repo.
        arunner = os.path.join(tmpd, "runner.out")
        with open(arunner, "w", encoding="utf-8") as fh:
            fh.write("RECEIPT sha=x\n**adversarial: approve**\n")
        acheck = os.path.join(tmpd, "check.out")
        with open(acheck, "w", encoding="utf-8") as fh:
            fh.write("PASS four lenses, one verdict each\n")
        afind = os.path.join(tmpd, "find.md")
        with open(afind, "w", encoding="utf-8") as fh:
            fh.write("# findings\n")
        aout = os.path.join(tmpd, "t.attest.json")
        aman = os.path.join(tmpd, "attest-manifest.md")
        with open(aman, "w", encoding="utf-8") as fh:
            fh.write(f"TAG PANEL-{'a' * 16} nonce={'b' * 16}\n"
                     f"MANIFEST bytes=1 files=0 sha={'c' * 64} titles=X "
                     f"base={r1} head={r3}\n")

        def _at(*a):
            return subprocess.run(
                [sys.executable, __file__, "attest", *a],
                capture_output=True, cwd=tmpd, text=True)

        got = _at("--out", aout, "--manifest", aman, "--base", r1,
                  "--head", r3, "--tree", rtree, "--runner-output", arunner,
                  "--checker-output", acheck, "--findings", "find.md",
                  "--verdict", "approve", "--reviewer", "codex-panel",
                  "--model", "gpt-5.6-sol")
        check("attest-v2-emit",
              got.returncode == 0 and f"wrote {aout}" in got.stdout,
              f"exit={got.returncode} out={got.stdout!r} err={got.stderr!r}")
        got = _at("--read-back", aout, "--findings", "find.md")
        check("attest-v2-readback",
              got.returncode == 0 and "schema 2" in got.stdout,
              f"exit={got.returncode} out={got.stdout!r} err={got.stderr!r}")
        with open(afind, "w", encoding="utf-8") as fh:
            fh.write("# findings replaced\n")
        got = _at("--read-back", aout, "--findings", "find.md")
        check("attest-v2-replacement",
              got.returncode == 1 and "hashes" in got.stderr
              and "binds" in got.stderr,
              f"exit={got.returncode} err={got.stderr!r}")
        with open(arunner, "w", encoding="utf-8") as fh:
            fh.write('{"result": "x", "model": "opus"}\n')
        got = _at("--out", aout, "--manifest", aman, "--base", r1,
                  "--head", r3, "--tree", rtree, "--runner-output", arunner,
                  "--checker-output", acheck, "--findings", "find.md",
                  "--verdict", "approve", "--model", "gpt-5.6-sol")
        check("attest-v2-model-mismatch",
              got.returncode == 1 and "disagrees with the runner output" in got.stderr,
              f"exit={got.returncode} err={got.stderr!r}")
    # The skill surface the tooling assumes (D00 T04 §21 items 2, 6, 7,
    # 8, 12, 14, 15): the suite reads the skill text, so a prose edit
    # that drops a wired command fails here, not at the next review.
    skill_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                              "..", ".claude", "skills", "review-todo-section",
                              "SKILL.md")
    try:
        with open(skill_path, encoding="utf-8") as fh:
            skill_text = fh.read()
    except OSError:
        skill_text = ""
    for pin, needle in (
            ("skill-diff-flagged", "--no-replace-objects diff --cached"),
            ("skill-selfreview-flagged", "`git --no-replace-objects diff`"),
            ("skill-coverage-sentence",
             "Every `rev-parse`, `show`, and `diff` on this page passes `--no-replace-objects`"),
            ("skill-push-explicit", "git push origin $COMMIT:refs/heads/master"),
            ("skill-push-readback",
             'git ls-remote origin refs/heads/master | cut -f1)" = "$COMMIT"'),
            ("skill-push-residual", "a concurrent force-push after it still moves the ref"),
            ("skill-parents-tool",
             "python scripts/review_prompt.py check-parents"),
            ("skill-linear-sentence", "this tree stays linear"),
            ("skill-stamp-check",
             "python scripts/review_prompt.py check-stamp --manifest $RUNDIR/stamp-manifest.md"),
            ("skill-stamp-branch", "PASS stamp holds` proceeds"),
            ("skill-merge-forbid", "refuses merge candidates outright"),
            ("skill-round-grammar", "`oid`(round N)"),
            ("skill-kind-panel", "--expect-head-kind commit"),
            ("skill-kind-stamp", "--expect-head-kind tree"),
            ("skill-attest-v2", "--runner-output <panel output file>"),
            ("skill-attest-checker", "--checker-output $RUNDIR/check.out"),
            ("skill-attest-findings", "--findings <findings path>"),
            ("skill-assembled-commits", "--commits <o1,o2,...>"),
            ("skill-assembled-body", "--body $RUNDIR/fenced.md"),
            ("skill-anchors-tool",
             "python scripts/review_prompt.py check-anchors <todo-path> <section>"),
            ("skill-findings-staged",
             "git --no-replace-objects diff --quiet -- <findings path>")):
        check(pin, needle in skill_text, skill_path)
    check("skill-attest-after-plan",
          skill_text.index("### 8. Plan review")
          < skill_text.index("### Attestation")
          < skill_text.index("### 9. Write the stamp and flip the row"),
          "attestation emits after the plan review, before the stamp")

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
    if len(sys.argv) == 3 and sys.argv[1] == "round-cost":
        try:
            with open(sys.argv[2], encoding="utf-8") as fh:
                envelope = fh.read()
        except OSError as exc:
            print(f"round-cost: cannot read {sys.argv[2]}: {exc}", file=sys.stderr)
            sys.exit(2)
        total, err = round_cost_from_envelope(envelope)
        if err is not None:
            print(f"round-cost: {err}", file=sys.stderr)
            sys.exit(1)
        print(f"{total}tokens")
        sys.exit(0)
    if len(sys.argv) >= 4 and sys.argv[1] == "fence":
        args = sys.argv[3:]
        base = head = None
        commits: list[str] | None = None
        while len(args) >= 2 and args[0] in ("--base", "--head", "--commits"):
            if args[0] == "--base":
                base = args[1]
            elif args[0] == "--head":
                head = args[1]
            else:
                commits = [c for c in
                           (p.strip() for p in args[1].split(","))
                           if c]
                if not commits:
                    print("fence: --commits names no commits", file=sys.stderr)
                    sys.exit(2)
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
        merged = refuse_merge_candidate(base, head)
        if merged is not None:
            print(f"fence: {merged}", file=sys.stderr)
            sys.exit(1)
        try:
            assert_candidate_identity(chunks, base, head)
            tag, nonce, prompt = fence_chunks_checked(sys.argv[2], chunks)
            manifest, _ = build_manifest(tag, chunks, base, head, nonce=nonce,
                                         commits=commits)
        except (RuntimeError, ValueError) as exc:
            print(f"fence: {exc}", file=sys.stderr)
            sys.exit(1)
        print(f"TAG {tag} nonce={nonce}")
        print(manifest)
        print(prompt, end="")
        sys.exit(0)
    if len(sys.argv) >= 5 and sys.argv[1] == "cross-check":
        # cross-check <manifest-file> <base> <head> [--body <file>]
        #   [--expect-head-kind commit|tree]: git's own NUL file list for
        # the range against the manifest's parsed diff-files (or, when
        # the manifest declares commits, the union of the declared
        # commits' touched files: the span may hold voided commits the
        # chunk excludes). Divergence fails closed; run from the
        # repository root. --no-renames lists
        # both sides of a rename, matching the manifest's [old, new];
        # without it every valid rename diverges as
        # `only in manifest: <old>`. --body runs the content leg when the
        # manifest declares commits (D00 T04 §21: sets agreeing proved
        # nothing once a chunk dropped 633e32b inside the span).
        # --expect-head-kind types the overloaded head per path (D00 T04
        # §21: commit on the panel path, tree on the stamp path).
        import subprocess
        cargs = sys.argv[5:]
        body_path = None
        expect_kind = None
        while cargs:
            if cargs[:1] == ["--body"] and len(cargs) >= 2:
                body_path, cargs = cargs[1], cargs[2:]
            elif cargs[:1] == ["--expect-head-kind"] and len(cargs) >= 2:
                expect_kind, cargs = cargs[1], cargs[2:]
            else:
                print(f"cross-check: unknown argument {cargs[0]!r}", file=sys.stderr)
                sys.exit(2)
        if expect_kind is not None and expect_kind not in ("commit", "tree"):
            print(f"cross-check: --expect-head-kind wants commit or tree, got {expect_kind!r}",
                  file=sys.stderr)
            sys.exit(2)
        try:
            with open(sys.argv[2], encoding="utf-8") as fh:
                manifest_text = fh.read()
            parsed = parse_manifest_diff_files(manifest_text)
            tag, sha, _ = parse_manifest_file(manifest_text)
            commits = parse_manifest_commits(manifest_text)
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
        # Existence only, never commit-typed: the stamp flow cross-checks
        # (HEAD, TREE) with a staged tree as head by design, so a type gate
        # here would refuse the flow it exists to check (D00 T04 §13 F1).
        # --expect-head-kind types the head per CALLER instead: the path
        # declares what it fenced, and a cross-kind oid fails naming it.
        for name, oid in (("--base", sys.argv[3]), ("--head", sys.argv[4])):
            if not git_oid_exists(oid):
                print(f"cross-check: {name} {oid} resolves to nothing",
                      file=sys.stderr)
                sys.exit(1)
        if expect_kind is not None:
            actual = git_object_type(sys.argv[4])
            if actual != expect_kind:
                print(f"cross-check: --head {sys.argv[4]} is a {actual}, "
                      f"want {expect_kind}", file=sys.stderr)
                sys.exit(1)
        if commits:
            # Assembled candidates (D00 T04 §21 review fix F1): the span
            # between the anchored base/head may hold voided commits the
            # chunk deliberately excludes, so the range diff is the wrong
            # oracle (it lists files no declared commit touches). The
            # file leg compares against the union of the declared
            # commits' own touched files instead; span merges are
            # likewise irrelevant (nothing traverses the range).
            union: set[str] = set()
            for oid in commits:
                try:
                    cproc = git_commit_names(oid)
                except OSError as exc:
                    print(f"cross-check: git failed: {exc}", file=sys.stderr)
                    sys.exit(1)
                if cproc.returncode != 0:
                    print(f"cross-check: declared commit {oid} resolves to "
                          "nothing", file=sys.stderr)
                    sys.exit(1)
                union |= set(parse_nul_file_list(cproc.stdout))
            git_side = "\0".join(sorted(union)).encode("utf-8")
        else:
            try:
                proc = git_diff_names(sys.argv[3], sys.argv[4])
            except OSError as exc:
                print(f"cross-check: git failed: {exc}", file=sys.stderr)
                sys.exit(1)
            if proc.returncode != 0:
                detail = proc.stderr.decode("utf-8", "replace").strip()[:200]
                print(f"cross-check: git diff refused the range: {detail}",
                      file=sys.stderr)
                sys.exit(1)
            git_side = proc.stdout
        diverged = cross_check_files(parsed, git_side)
        if diverged:
            for line in diverged:
                print(f"cross-check: {line}", file=sys.stderr)
            sys.exit(1)
        if commits:
            if body_path is None:
                print("cross-check: the manifest declares commits but no --body was given",
                      file=sys.stderr)
                sys.exit(2)
            try:
                with open(body_path, encoding="utf-8") as fh:
                    body_text = fh.read()
            except OSError as exc:
                print(f"cross-check: cannot read {body_path}: {exc}", file=sys.stderr)
                sys.exit(2)
            blines = body_text.splitlines(keepends=True)
            if (len(blines) < 3
                    or TAG_LINE_RE.match(blines[0].strip()) is None
                    or MANIFEST_RE.match(blines[1].strip()) is None):
                print("cross-check: --body is not a fenced prompt",
                      file=sys.stderr)
                sys.exit(1)
            prompt = "".join(blines[2:])
            if hashlib.sha256(canonical_prompt_bytes(prompt)).hexdigest() != sha:
                print("cross-check: --body is not the manifested prompt",
                      file=sys.stderr)
                sys.exit(1)
            body_text = prompt
            uncovered = check_commits_covered(commits, tag, body_text)
            if uncovered:
                for line in uncovered:
                    print(f"cross-check: {line}", file=sys.stderr)
                sys.exit(1)
            print(f"cross-check: {len(parsed)} file(s) agree, {len(commits)} commit(s) covered")
        else:
            print(f"cross-check: {len(parsed)} file(s) agree")
        sys.exit(0)
    if len(sys.argv) >= 3 and sys.argv[1] == "attest":
        # attest --out <path> --manifest <file> --base <b> --head <h>
        #   --tree <t> --runner-output <f> --checker-output <f>
        #   --findings <f> --verdict <v>
        #   [--reviewer <r> --model <m> --timestamp <ts>]
        # attest --read-back <path> [--findings <f>]
        # Schema 2 (D00 T04 §21) binds every field to a run: the checker
        # rides the check step's own output file (a pasted PASS string has
        # no file and refuses); reviewer/model derive from the runner's
        # output with the skill's flags as assertions a mismatch fails;
        # the timestamp is the runner output's mtime; the findings hash
        # binds the artifact beside the attestation, re-hashed at
        # read-back. Schema 1 still READS (legacy records stand); only
        # schema 2 emits.
        args = sys.argv[2:]
        if args[:1] == ["--read-back"] and 2 <= len(args) <= 4:
            rb_findings = None
            if len(args) == 4:
                if args[2] != "--findings":
                    print("attest: want --read-back <path> [--findings <file>]",
                          file=sys.stderr)
                    sys.exit(2)
                rb_findings = args[3]
            elif len(args) == 3:
                print("attest: want --read-back <path> [--findings <file>]",
                      file=sys.stderr)
                sys.exit(2)
            try:
                with open(args[1], encoding="utf-8") as fh:
                    doc = read_attestation(fh.read())
            except OSError as exc:
                print(f"attest: cannot read {args[1]}: {exc}", file=sys.stderr)
                sys.exit(2)
            except ValueError as exc:
                print(f"attest: {exc}", file=sys.stderr)
                sys.exit(1)
            if doc["schema"] == ATTEST_SCHEMA_V2:
                if rb_findings is None:
                    print("attest: schema-2 attestation needs --findings to re-hash",
                          file=sys.stderr)
                    sys.exit(2)
                want_path = doc["findings_path"].replace("\\", "/")
                got_path = rb_findings.replace("\\", "/")
                while got_path.startswith("./"):
                    got_path = got_path[2:]
                if got_path != want_path:
                    print(f"attest: findings file is {rb_findings}, "
                          f"attestation binds {doc['findings_path']}", file=sys.stderr)
                    sys.exit(1)
                try:
                    with open(rb_findings, "rb") as fh:
                        got_sha = hashlib.sha256(fh.read()).hexdigest()
                except OSError as exc:
                    print(f"attest: cannot read {rb_findings}: {exc}", file=sys.stderr)
                    sys.exit(2)
                if got_sha != doc["findings_sha256"]:
                    print(f"attest: findings file {rb_findings} hashes {got_sha[:12]}..., "
                          f"attestation binds {doc['findings_sha256'][:12]}...",
                          file=sys.stderr)
                    sys.exit(1)
            elif rb_findings is not None:
                print("attest: schema-1 attestation binds no findings file",
                      file=sys.stderr)
                sys.exit(2)
            print(f"attest: schema {doc['schema']}, verdict {doc['verdict']}, "
                  f"manifest {doc['manifest_sha'][:12]}..., candidate "
                  f"{doc['candidate_base'][:12]}...{doc['candidate_head'][:12]}..., "
                  f"tree {doc['tree'][:12]}..., reviewer {doc['reviewer']}, "
                  f"model {doc['model']}, checker: {doc['checker']}")
            sys.exit(0)
        want = {"--out": None, "--manifest": None, "--base": None, "--head": None,
                "--tree": None, "--runner-output": None, "--checker-output": None,
                "--findings": None, "--verdict": None, "--reviewer": None,
                "--model": None, "--timestamp": None}
        rest = list(args)
        while len(rest) >= 2 and rest[0] in want:
            want[rest[0]] = rest[1]
            rest = rest[2:]
        required = ("--out", "--manifest", "--base", "--head", "--tree",
                    "--runner-output", "--checker-output", "--findings", "--verdict")
        if rest or any(want[k] is None for k in required):
            print("attest: want --out <path> --manifest <file> --base <b> --head <h> "
                  "--tree <t> --runner-output <f> --checker-output <f> --findings <f> "
                  "--verdict <v> [--reviewer <r> --model <m> --timestamp <ts>] | "
                  "--read-back <path> [--findings <f>]", file=sys.stderr)
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
            with open(want["--runner-output"], "rb") as fh:
                runner_bytes = fh.read()
        except OSError as exc:
            print(f"attest: cannot read {want['--runner-output']}: {exc}", file=sys.stderr)
            sys.exit(2)
        reviewer, envelope_model, run_err = derive_runner_identity(
            runner_bytes.decode("utf-8", "replace"))
        if run_err is not None:
            print(f"attest: {run_err}", file=sys.stderr)
            sys.exit(1)
        if envelope_model is not None and want["--model"] is not None \
                and want["--model"] != envelope_model:
            print(f"attest: hand-supplied model {want['--model']} disagrees "
                  f"with the runner output {envelope_model}", file=sys.stderr)
            sys.exit(1)
        model = envelope_model if envelope_model is not None else want["--model"]
        if model is None:
            print("attest: the runner output names no model; pass --model",
                  file=sys.stderr)
            sys.exit(2)
        if want["--reviewer"] is not None and want["--reviewer"] != reviewer:
            print(f"attest: hand-supplied reviewer {want['--reviewer']} disagrees "
                  f"with the runner output {reviewer}", file=sys.stderr)
            sys.exit(1)
        try:
            timestamp = runner_timestamp(want["--runner-output"])
        except OSError as exc:
            print(f"attest: cannot stat {want['--runner-output']}: {exc}", file=sys.stderr)
            sys.exit(2)
        if want["--timestamp"] is not None and want["--timestamp"] != timestamp:
            print(f"attest: hand-supplied timestamp {want['--timestamp']} disagrees "
                  f"with the run clock {timestamp}", file=sys.stderr)
            sys.exit(1)
        try:
            with open(want["--checker-output"], "rb") as fh:
                checker_bytes = fh.read()
        except OSError as exc:
            print(f"attest: cannot read {want['--checker-output']}: {exc}", file=sys.stderr)
            sys.exit(2)
        checker_lines = checker_bytes.decode("utf-8", "replace").strip().splitlines()
        if len(checker_lines) != 1 or not checker_lines[0].startswith("PASS "):
            print("attest: the checker output is not a single PASS line",
                  file=sys.stderr)
            sys.exit(1)
        checker = f"{checker_lines[0]} :: {hashlib.sha256(checker_bytes).hexdigest()}"
        findings_arg = want["--findings"].replace("\\", "/")
        while findings_arg.startswith("./"):
            findings_arg = findings_arg[2:]
        try:
            with open(want["--findings"], "rb") as fh:
                findings_sha = hashlib.sha256(fh.read()).hexdigest()
        except OSError as exc:
            print(f"attest: cannot read {want['--findings']}: {exc}", file=sys.stderr)
            sys.exit(2)
        try:
            body = write_attestation_v2(
                manifest_sha=sha, candidate_base=want["--base"],
                candidate_head=want["--head"], tree=want["--tree"],
                reviewer=reviewer, model=model,
                verdict=want["--verdict"], checker=checker,
                timestamp=timestamp, findings_path=findings_arg,
                findings_sha256=findings_sha,
                runner_sha256=hashlib.sha256(runner_bytes).hexdigest())
        except ValueError as exc:
            print(f"attest: {exc}", file=sys.stderr)
            sys.exit(1)
        resolve_bad = check_attest_resolution(
            want["--base"], want["--head"], want["--tree"])
        if resolve_bad is not None:
            print(resolve_bad, file=sys.stderr)
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
    if len(sys.argv) == 4 and sys.argv[1] == "check-parents":
        # check-parents <commit> <expected-parent>: the stamp lands on
        # its expected parent, and a merge fails naming every parent
        # (D00 T04 §21: HEAD^ reads the first parent only).
        bad = check_parent_binding(sys.argv[2], sys.argv[3])
        if bad is not None:
            print(bad, file=sys.stderr)
            sys.exit(1)
        print(f"check-parents: {sys.argv[2]} sits on {sys.argv[3]}")
        sys.exit(0)
    if len(sys.argv) == 4 and sys.argv[1] == "check-anchors":
        # check-anchors <todo-path> <section>: every cited line,
        # section, and oid in the section's stamp block resolves
        # (D00 T04 §21: mechanical dead-anchor rejection, with the
        # reviewer round kept as the semantic backstop).
        try:
            section = int(sys.argv[3])
        except ValueError:
            print(f"check-anchors: section {sys.argv[3]!r} is not an integer",
                  file=sys.stderr)
            sys.exit(2)
        dead = check_stamp_anchors(sys.argv[2], section)
        if dead:
            for line in dead:
                print(line, file=sys.stderr)
            sys.exit(1)
        print(f"check-anchors: {sys.argv[2]} §{section} cites resolve")
        sys.exit(0)
    checkers = {"check-panel": check_panel_output, "check-plan": check_plan_output,
                "check-stamp": check_stamp_output}
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
            f"usage: {sys.argv[0]} tag <prefix> | round-cost <envelope-file> | fence <prefix> [--base <sha> --head <sha> [--commits <o1,o2>]] <title=path>... | run-id <todo-path> <section> <family> <YYYYMMDD> <scan-file>... | check-panel|check-plan|check-stamp [--manifest <file>] < output.txt | cross-check <manifest-file> <base> <head> [--body <file>] [--expect-head-kind commit|tree] | check-parents <commit> <expected-parent> | check-anchors <todo-path> <section> | attest (--out <path> --manifest <file> --base <b> --head <h> --tree <t> --runner-output <f> --checker-output <f> --findings <f> --verdict <v> [--reviewer <r> --model <m> --timestamp <ts>] | --read-back <path> [--findings <f>])",
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
