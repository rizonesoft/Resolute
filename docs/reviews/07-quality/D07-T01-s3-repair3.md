# Review record: D07 T01 section 3, repair cycle 3

Continuation of [D07-T01-s3-repair2.md](D:/GitHub/Resolute/docs/reviews/07-quality/D07-T01-s3-repair2.md), whose completion review returned two in-scope reporting gaps and closed that record. Both fixed in `6fadf4f8bd839422e66b4188cc5b082e6cd887d8`; the repeated-validation optimization remains declined as reviewer-marked out of scope and nonblocking. Candidate for this cycle: `6fadf4f8bd839422e66b4188cc5b082e6cd887d8`.

## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T05:58:58Z
- Candidate: 6fadf4f8bd839422e66b4188cc5b082e6cd887d8
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: 8bf10da4fea2b765de0fbb1388d6f0a7bcd19e00
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 10
- Digest: 3f581f14eacba9c3

**plan: needs-attention.** One remaining gap:

- **Successful-gate report discoverability remains unaddressed.** Repair2 completion explicitly required the full-report location alongside advisory failures. In candidate `6fadf4f8`, [check-all.ps1:322](D:/GitHub/Resolute/scripts/check-all.ps1:322) prints successful-gate detail without its log path; [line 334](D:/GitHub/Resolute/scripts/check-all.ps1:334) prints that path only for failures. This is concrete evidence against the recorded settlement. Add the report location at the owning PowerShell reporting layer. Require the round to verify successful terminal output contains the advisory clause/tool and the readable report path, while preserving exit zero and NYE. Cover that behavior: the three current tests check regex matching only.

The moved-owner regression now exercises resolver invocation through matrix rendering. No additional gap found within this repair’s scope; declined items remain closed.

Verification: all three pattern tests passed. HEAD differs from the candidate only in the repair3 review record. No files modified; builds and file-writing self-tests were not run.

PLAN: gaps
OVERALL: needs-attention

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T06:29:24Z
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: 8bf10da4fea2b765de0fbb1388d6f0a7bcd19e00
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: 47f2702ab909a482

**adversarial: needs-attention**

- **P2: Repro check crashes on Python 3.11 after deleting deployed executables.** [scripts/conformance-check.py:839](D:/GitHub/Resolute/scripts/conformance-check.py:839) introduces `shutil.rmtree(..., onexc=...)`, unsupported by Python 3.11. Executable deletion occurs first at line 815. Reproduction: invoke `repro_check(Path.cwd())` under installed CPython 3.11.15, intercepting `Path.unlink` to prevent changes. It attempts both executable deletions, then raises `TypeError: rmtree() got an unexpected keyword argument 'onexc'`. Use the compatible `onerror` callback, or validate the required interpreter version before deleting anything.

Read-only probes only; no files modified. Full builds were not rerun.

HIGHEST: P2
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T06:47:04Z
- Effort: low
- Writer model: muse-wonder-full-1.0
- Policy: 8bf10da4fea2b765de0fbb1388d6f0a7bcd19e00
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: ebb4b2be60dfd817

**consistency: approve.** No new actionable findings within this lens.

Reviewed the candidate diff and prior records. All four wrapper tests passed. No files modified; full gates and builds were not rerun.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T07:02:07Z
- Candidate: 787d23ceb2ebf3f2b453277cb76435a6f65cee4f
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: 8bf10da4fea2b765de0fbb1388d6f0a7bcd19e00
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 28
- Digest: a2a2986ae6e050ac

The candidate has one remaining **in-scope test-quality gap**. The supplied run demonstrates the developer-facing behavior, but the new regression test does not protect it.

HEAD matches `787d23ce`; the worktree is clean. Review was read-only. All four wrapper tests passed; builds and file-writing self-tests were not rerun.

**Part 1: completeness per need**

| Developer need | Assessment |
| --- | --- |
| Run conformance through the combined gate | Present: [check-all.ps1:191](D:/GitHub/Resolute/scripts/check-all.ps1:191). |
| Inspect clauses, owners, budgets and totals | Present: [conformance-check.py:711](D:/GitHub/Resolute/scripts/conformance-check.py:711). |
| Distinguish enforced failures from open-owner advisories | Present: [conformance-check.py:683](D:/GitHub/Resolute/scripts/conformance-check.py:683). |
| See advisory failures and find their full report | Present: [check-all.ps1:324](D:/GitHub/Resolute/scripts/check-all.ps1:324), supported by the supplied candidate run. |
| Trust current build and analysis evidence | Present: [conformance-check.py:438](D:/GitHub/Resolute/scripts/conformance-check.py:438). |
| Prevent recurrence of the report-discoverability defect | **Missing-in-scope:** [test_check_all_patterns.py:51](D:/GitHub/Resolute/scripts/tests/test_check_all_patterns.py:51) checks source text, not reporting behavior. |
| Prove remaining runtime clauses | **Missing-out-of-scope:** assigned to their owners in the [Validated block](D:/GitHub/Resolute/todo/07-quality/TODO-01-quality-bar.md:148). |

**Part 2: excellence against the predecessor pattern**

- **Test quality, in scope:** the report-path test accepts a commented-out implementation. In an in-memory mutation, I commented out the entire path-appending statement at `check-all.ps1:324`; all four tests still passed. This is new evidence that the repair3 plan’s required behavior coverage remains incomplete. Exercise the actual PowerShell reporting code with a successful advisory result and assert the emitted tool, clause and full report path. Disabling the statement must fail that test.
- **Speed, out of scope:** repeated common-evidence validation remains the previously declined optimization. No new performance evidence warrants reopening it.
- **Failure quality and evidence binding:** no additional shortfall established within the validated scope.

**Consolidated gap list**

1. **In scope:** replace the source-presence assertion with a behavioral regression test for successful advisory reporting.
2. **Out of scope, nonblocking:** remaining runtime evaluators belong to their open owners; repeated-validation optimization remains declined.

COMPLETION: gaps

Settled 2026-11-09: completion test-quality gap fixed (report-path test now executes check-all.ps1's own report block under pwsh and asserts the emitted advisory line and report path; commenting the statement out is detected, verified by mutation probe). This record closed; continuation on D07-T01-s3-repair4.md.
