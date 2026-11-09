## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T05:11:03Z
- Candidate: 06b9e1bdce6c4d3b32326d05429ae09a4e7af1ca
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: 06b9e1bdce6c4d3b32326d05429ae09a4e7af1ca
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: bae009f982b11c61

1. **P1: C24 can certify partial or changed analysis inputs.** [tidy-ratchet.py:641](/D:/GitHub/Resolute/scripts/tidy-ratchet.py:641) verifies build artifacts, but does not bind compile databases to that build. Analysis accepts any nonempty database, then hashes it only after analysis at line 737. Replacing a database with one translation unit before analysis, or changing it during analysis, can therefore produce accepted evidence for incomplete coverage. The read-only probe confirmed neither database enters `input_manifest()`. Require build-bound database hashes, verified before and after analysis, with refusal tests for replacement and partial coverage.

2. **P1: Version-shaped private DLL names still evade PE policy.** [conformance-check.py:338](/D:/GitHub/Resolute/scripts/conformance-check.py:338) accepts API-set names by syntax without establishing that they identify supported Windows contracts. New in-memory probes returned `problems=[]` for `api-ms-win-resolute-private-l1-1-0.dll` and `ext-ms-win-private-l99-99-99.dll`. This demonstrates that round 9’s repair remains incomplete for version-shaped names. Validate supported contracts and test fabricated version-shaped imports.

Read-only review; no files modified. Findings use source tracing and in-memory probes, not rerun builds.

HIGHEST: P1  
PLAN: gaps  
OVERALL: needs-attention

- Planned: gap 1 (compile databases hash-bound to the build record, verified before and after analysis) in d5e97619cde3fbe47a42ac2dc9adfe8e7b50cba7
- Planned: gap 2 (explicit observed API-set contract allowlist) in d5e97619cde3fbe47a42ac2dc9adfe8e7b50cba7

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T05:20:37Z
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: 06b9e1bdce6c4d3b32326d05429ae09a4e7af1ca
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: b66a842c8ed77ca2

adversarial: **needs-attention**

- **P3: A database replaced before build-record publication becomes trusted evidence.** [scripts/tidy-ratchet.py:1389](/D:/GitHub/Resolute/scripts/tidy-ratchet.py:1389) first captures database hashes after all targets finish building. Reproduction: replace the launcher database with one entry after launcher compilation while RegStudio builds, then let recording and analysis proceed. Both new hash checks accept the replacement, so omitted translation units escape analysis. A read-only, in-memory probe reduced the actual database from 162 entries to one: recording returned `0`, certified the partial database, and retained the unchanged source manifest. This is new evidence of a remaining pre-publication window in the plan finding’s repair. Capture each database after configuration and verify it remains unchanged through compilation and publication.

No files modified. Full builds and self-tests were not rerun.

HIGHEST: P3  
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T05:24:21Z
- Candidate: f8447da310e1f02561c05c499e510b1b68be7420
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: 06b9e1bdce6c4d3b32326d05429ae09a4e7af1ca
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 33
- Digest: de0f925302d729af

The candidate has **in-scope gaps**, chiefly in C24’s build-to-analysis binding. Reviewed HEAD matches `f8447da310e1f02561c05c499e510b1b68be7420`; the worktree remained clean. Verification here was source inspection and an in-memory probe. Builds and file-writing self-tests were not rerun.

**Part 1: completeness per need**

| Developer need | Assessment |
| --- | --- |
| Run conformance through the combined gate | **Present:** [check-all.ps1:190](D:/GitHub/Resolute/scripts/check-all.ps1:190). |
| See tool/clause results, owners, budgets and suite total | **Present:** [conformance-check.py:682](D:/GitHub/Resolute/scripts/conformance-check.py:682). Reporting omissions below remain. |
| Reconcile inventory, enforce artifact policy, detect layout and duplicate-subject violations | **Present within the explicitly narrowed §3 contract:** [conformance-check.py:581](D:/GitHub/Resolute/scripts/conformance-check.py:581). |
| Trust that analysis describes the successful build | **Missing-in-scope:** database publication compares source **basenames**, ignoring compiler commands, directories and full source identity. [tidy-ratchet.py:1425](D:/GitHub/Resolute/scripts/tidy-ratchet.py:1425). |
| Receive the promised advisory C22 search | **Missing-in-scope:** an open owner causes `continue` before its evaluator runs. C22 has an evaluator but produces no source-search evidence while open, contrary to the checked item saying “reported, owner open.” [conformance-check.py:665](D:/GitHub/Resolute/scripts/conformance-check.py:665), [section:169](D:/GitHub/Resolute/todo/07-quality/TODO-01-quality-bar.md:169). Keep NYE, but report the advisory result. |
| Find the replacement owner when a section moved | **Missing-in-scope:** resolver output is discarded, retaining only exit code 5. The matrix repeats the old owner rather than naming where work moved, as promised. [conformance-check.py:142](D:/GitHub/Resolute/scripts/conformance-check.py:142). |
| Prove runtime standalone behavior and remaining profile clauses | **Missing-out-of-scope:** explicitly assigned to their open owners by the Validated block. These are not §3 completion blockers. |
| Check reproducibility | **Present:** [conformance-check.py:759](D:/GitHub/Resolute/scripts/conformance-check.py:759). Independent-machine/path reproducibility is beyond the stated two-clean-build checkpoint. |

**Part 2: excellence against the predecessor pattern**

- **Evidence binding, in scope:** the central repair remains incomplete. My in-memory probe appended `-DREVIEW_CHANGED_CONFIGURATION=1` to all **162** launcher compile commands. Build-record publication returned **0** and accepted their hashes. Publication was intercepted, so nothing was written. A database changed after compilation but before publication can therefore certify analysis under different preprocessor conditions. Later hash checks preserve that mismatch rather than detect it. Capture each database after configuration and verify its bytes through compilation and publication.
- **Test quality, in scope:** the new refusal test changes source names entirely; it does not exercise changed commands or distinct paths sharing a basename. It therefore misses the demonstrated defect. [tidy-ratchet.py:1338](D:/GitHub/Resolute/scripts/tidy-ratchet.py:1338). Add those cases with an unchanged positive control.
- **Test hygiene, in scope:** that same new test allocates its temporary directory **after** the cleanup loop, leaving it behind on every self-test invocation, including the combined gate. [tidy-ratchet.py:1336](D:/GitHub/Resolute/scripts/tidy-ratchet.py:1336).
- **Failure quality, in scope:** unlike `profile-check.py`, owner resolution launches literal `python` rather than `sys.executable`. This defeats the combined gate’s `python3`/`py` fallback and can produce an uncaught launch error. [conformance-check.py:143](D:/GitHub/Resolute/scripts/conformance-check.py:143), [profile-check.py:94](D:/GitHub/Resolute/scripts/profile-check.py:94).
- **Speed, out-of-scope improvement:** C24 rereads the common log and rehashes the complete input tree separately for each tool. Validate shared evidence once per invocation. No measured performance regression is claimed. [conformance-check.py:456](D:/GitHub/Resolute/scripts/conformance-check.py:456).

**Consolidated gap list**

1. Bind the actual compile database through compilation and publication; add command-change and same-basename regression cases.
2. Report C22 advisory findings while preserving NYE.
3. Report moved-owner destinations.
4. Clean up the newly added ratchet fixture.
5. Use the running Python interpreter for owner resolution.
6. Optional, outside scope: avoid repeated common-evidence validation.

COMPLETION: gaps

Settled 2026-11-09: completion gaps 1-5 fixed (configure-time DB capture via build.ps1 Capture-Db + --expect-dbs, full-path DB/ninja comparison with ninja $: unescaping, positive/command-change/same-basename cases, C22 advisory reporting, moved-owner destination, fixture inside cleanup, sys.executable). Gap 6 declined as reviewer-marked out-of-scope. This record closed; continuation on D07-T01-s3-repair2.md.
