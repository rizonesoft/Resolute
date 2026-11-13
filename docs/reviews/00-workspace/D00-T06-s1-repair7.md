## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:25:19Z
- Candidate: 36232fb92c7f160f45671ef8495282c6fc3b204d
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 36232fb92c7f160f45671ef8495282c6fc3b204d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 76f3f2ab9f940c69

1. **P3**, `todo/00-workspace/TODO-06-reference-data.md:99`: The example script path contains literal tab and carriage-return characters where backslashes were intended. Correct it to `python '<repo>/tools/refdata/refdata.py'` so the written command names the actual script and remains on one line.

HIGHEST: P3
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: the example path's control characters (a tab and carriage returns the writer's shell made of backslashes) corrected to `python '<repo>/tools/refdata/refdata.py'` (P3), in the Repair 7 item.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:32:41Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 36232fb92c7f160f45671ef8495282c6fc3b204d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: 7f93911a42bff584

### adversarial: needs-attention

1. **P2**, `tools/refdata/refdata.py:1352`: The retry test uses `subprocess.run(timeout=600)`, which kills only `pwsh` on timeout. Its Python upgrade and MySQL descendants can continue while the `finally` block at line 1456 drops their databases. Reproduce by suspending the retry’s Python child during `python tools/refdata/refdata.py self-test` until the timeout expires, then resuming it. Cleanup races an active upgrade. Use the existing process-tree termination pattern before cleanup.

2. **P3**, `tools/refdata/refdata.py:672`: `powershell_literal` escapes ASCII apostrophes only. PowerShell also treats curly apostrophes as quote delimiters, so a valid path such as `C:\Users\D’Arcy\my-server.cnf` breaks the retry. Verified by passing that path through the candidate helper into `pwsh -NoProfile -Command`: exit 1 instead of the literal path. Escape PowerShell’s additional single-quote characters too.

HIGHEST: P2
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:37:42Z
- Effort: low
- Writer model: claude-opus-5-5
- Policy: 36232fb92c7f160f45671ef8495282c6fc3b204d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 69e9edb6a5f7781c

### consistency: approve

No findings within the scheduled consistency lens.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:39:28Z
- Candidate: ff1d75f64411202d72a73e46a04e3b1dd2ecc513
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 36232fb92c7f160f45671ef8495282c6fc3b204d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 24
- Digest: 754558738caa9927

Part 1: completeness

Scope: Repair 7 and its round 1 fixes. Database-writing tests were not rerun during this read-only review; their supplied results are supporting evidence.

1. **present:** Runnable invocation with an absolute script path and the original database and option file: `tools/refdata/refdata.py:700`. No credential contents are printed.
2. **present:** Literal path quoting handles spaces, dollar signs, backticks, ASCII and curly apostrophes: `tools/refdata/refdata.py:670`. The special-character fixture at `:1247` exercises the printed retry through PowerShell at `:1356`; supplied mutation runs demonstrate failures when quoting or invocation breaks.
3. **present:** Preconditions refuse missing sources, newer/current revisions and occupied destinations before copying: `tools/refdata/refdata.py:685`. Attempted-upgrade failures preserve their cause and report cleanup outcomes at `:711` and `:722`; regression cases cover cleanup, races, outages and TLS failures.
4. **present:** Recovery preserves persisted source data and compares destination records before success: `tools/refdata/refdata.py:733`. The retry regression reads back versions, proposed status and history, and checks unchanged source records at `:1367`.
5. **present:** The retry test ends its process tree on timeout before database cleanup: `tools/refdata/refdata.py:1360`, using `_end_tree` at `:151`. The supplied checkpoint reports a driven timeout.
6. **missing-in-scope, G1:** The unverified-copy refusal appends `, and drop the copy with: DROP DATABASE ...` directly after the PowerShell retry (`tools/refdata/refdata.py:717`). Copying that printed command line after substituting the name includes prose and SQL as arguments. A read-only PowerShell argument probe confirmed this. The regression at `:1354` extracts only the command prefix from the lossy-copy refusal, so it cannot detect this supported recovery path’s failure.

Part 2: excellence, counterpart: the documented PowerShell authoring workflow

AutoIt behavioral parity is not applicable: this is new authoring-machine tooling, with `Fidelity: none`. Graphical fidelity requirements do not apply; recovery wording and copyability remain relevant quality expectations.

1. **in-scope, G1:** Recovery still requires manual command-boundary editing when a restored copy remains unverified. **Target:** print the retry on its own line, with cleanup instructions separately labelled; substituting only the destination name must produce a successful retry in the existing unverified-copy scenario. Exercise that complete printed line, without regex-trimming trailing text. Evidence: `tools/refdata/refdata.py:717`, `:1299`, `:1354`.

No additional concrete speed or out-of-scope shortfall was established.

Gap list

1. **missing-in-scope / in-scope, G1:** Separate the retry from trailing cleanup prose and SQL, and verify the complete printed line for the unverified-copy refusal (`tools/refdata/refdata.py:717`, `:1354`).

COMPLETION: gaps

## Writer note: completion gaps

- Planned: G1 (the retry separated from trailing cleanup, verified for the unverified copy), as the Repair 8 item in D00 T06 §1, reviewed on `docs/reviews/00-workspace/D00-T06-s1-repair8.md`.
