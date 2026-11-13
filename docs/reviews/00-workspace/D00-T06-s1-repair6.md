## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:13:50Z
- Candidate: 8820160d8b1e0edf12e9fcf5330aaa3422fb65f3
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 8820160d8b1e0edf12e9fcf5330aaa3422fb65f3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 3
- Digest: 5363a394b6e0de2b

HIGHEST: none
PLAN: complete
OVERALL: approve

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:22:00Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 8820160d8b1e0edf12e9fcf5330aaa3422fb65f3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: e69f7bc3ee21ed4a

### adversarial: needs-attention

1. **P3**, `tools/refdata/refdata.py:691`: The retry’s double-quoted option path is not escaped for PowerShell. A valid filename containing `$` or a backtick can change when pasted, so the retry does not preserve the original connection. Reproduce with an option file named `C:\refdata\$reviewProbeName.cnf`: set `$reviewProbeName='expanded'`, then follow the printed retry. PowerShell passes `C:\refdata\expanded.cnf`, which I verified with a read-only quoting probe. The self-test at line 1344 misses this because it strips quotes and calls `main(argv)` directly. Emit a PowerShell literal with appropriate escaping and verify that shell parsing preserves the path.

HIGHEST: P3
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:23:38Z
- Candidate: 5a476ae52d0c180be79c0aee33112219e94df832
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 8820160d8b1e0edf12e9fcf5330aaa3422fb65f3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 23
- Digest: 250212b3ec5fbdf0

Part 1: completeness

1. **present:** Retry arguments retain the original database and absolute option-file path without printing credentials (`tools/refdata/refdata.py:689`). The lossy-upgrade regression checks the selected path (`:1245`).
2. **missing-in-scope, G1:** The printed retry cannot launch from the documented repository-root PowerShell workflow. It starts with bare `refdata.py` (`tools/refdata/refdata.py:691`), whereas documentation uses `python tools/refdata/refdata.py` (`docs/reference-data.md:100`). A read-only `refdata.py --help` probe returned `CommandNotFoundException`. The regression strips off the executable name and calls `main(argv)` directly (`:1342`, `:746`), bypassing this failure.
3. **missing-in-scope, G2, settled P3:** Option paths containing `$` or backticks are not preserved through PowerShell’s double-quoted argument parsing (`tools/refdata/refdata.py:691`). The direct-call regression also bypasses this. Retain the agreed next-repair-or-file disposition.
4. **present:** Newer databases receive checkout-update guidance before any copy is created; equal revisions retain the appropriate current-database guidance (`tools/refdata/refdata.py:680`). Regression cases cover both branches (`:1248`, `:1259`).
5. **present:** Missing sources and occupied destination names refuse before copying (`tools/refdata/refdata.py:677`, `:686`). Attempted-upgrade failures retain the cause and recovery instruction, including unverified copies and failed cleanup (`:700`, `:711`). Lossy-copy, cleanup, race, outage and TLS regressions cover these paths (`:1239`, `:1280`, `:1295`, `:1313`, `:1380`).
6. **present:** Recovery preserves the source and verifies stored destination contents. The successful-retry case checks both versions, proposed status, history and unchanged source records (`tools/refdata/refdata.py:1348`). Production upgrade compares both databases before declaring success (`:719`).
7. **present:** Regression evidence distinguishes the two repairs: the supplied runs report failures when `--options` is removed and when `>=` is restored. I inspected those tests but did not rerun the database-writing self-test under this read-only review.

Part 2: excellence, counterpart: the documented PowerShell authoring workflow

AutoIt behavioral parity and graphical `DESIGN.md` fidelity are not applicable to this authoring-machine feature. The concrete quality shortfalls are recovery usability:

1. **in-scope, G1:** Recovery requires the author to repair the command’s invocation. **Target:** after replacing only the destination placeholder, the complete printed command launches from the documented working directory and completes the upgrade. Exercise the actual PowerShell invocation rather than reconstructing arguments for `main()`.
2. **in-scope, G2, settled P3:** A supported option-file path can change during shell parsing. **Target:** PowerShell passes the original path byte-for-byte for spaces, `$` and backticks, demonstrated by one focused regression. Preserve the agreed disposition.

Gap list

1. **missing-in-scope / in-scope, G1:** Emit a runnable Python/script invocation and verify the complete printed retry through PowerShell; `tools/refdata/refdata.py:691`, `:1342`.
2. **missing-in-scope / in-scope, G2, settled P3:** Quote the option-file path literally for PowerShell and verify preservation; fix in the next repair cycle or file as agreed; `tools/refdata/refdata.py:691`.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: G1 (a runnable retry command) and G2 (round 1's P3, PowerShell-literal paths), as the Repair 7 item in D00 T06 §1, reviewed on `docs/reviews/00-workspace/D00-T06-s1-repair7.md`.
