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
