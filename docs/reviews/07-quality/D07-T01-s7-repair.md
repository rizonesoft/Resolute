## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:21:38Z
- Candidate: f1a2479e7ba25df7398bb77727be2d3cc16c7dd6
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: f1a2479e7ba25df7398bb77727be2d3cc16c7dd6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 11
- Digest: 9e8618cb0a7bb700

1. **P1, plan, line 303:** Cleanup proves only that the task and Python driver stopped. It does not require terminating or checking the launched tool processes, which do not carry `smoke-run.py` in their command lines. Require whole-tree cleanup on timeout, interruption and removal, with one driven case proving a launched child also exits. §10 defers caller-death handling, not these existing cleanup paths.

2. **P2, plan, lines 297 and 318:** Registration rollback covers the task and hashes but omits the newly introduced Python runtime replacement. The candidate deletes the old runtime before renaming its replacement; a filesystem failure can leave the restored task without its runtime. Require retaining and restoring the previous runtime until replacement and readback succeed, with one injected replacement-failure test.

3. **P2, plan, lines 296, 305 and 317:** The contract does not explicitly require the task principal to match the account writing the HKCU manifest. Registration using another administrator’s credentials can select a different account and hive while passing the candidate’s definition comparison, which checks only run level and logon type. Require matching principal SIDs or a named refusal before registration/run, and one mismatch test.

4. **P2, plan, line 316:** The prescribed staging tests exercise `stage_tool()` only. They can pass while `real_tools()` ignores its refusal or launches the original executable. Require one refusal case through the consuming smoke path that asserts zero launches, five refused rows and a non-pass suite verdict; demonstrate that bypassing refusal makes it fail.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1 (P1), cleanup confirms the staged tools are gone as well as the driver, with self-test cases and a driven run whose wait expires while a tool is alive, in the section-correction commit that follows this record
- Planned: finding 2, the runtime swap keeps and restores the previous runtime, with an injected failing move, in the same commit
- Planned: finding 3, the task's principal must be the account that runs it, refused by name at registration and at run, with a mismatch case, in the same commit
- Planned: finding 4, a refusal case through the driver's main path asserting no launch, five refused rows and a non-pass verdict, failing when the refusal branch is bypassed, in the same commit

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:29:28Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: f1a2479e7ba25df7398bb77727be2d3cc16c7dd6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: a013c7024a5b4bbc

## adversarial: needs-attention

Findings are based on source inspection and live ACL readback. Exploit reproductions were not executed.

1. **P1: Registration preserves an untrusted directory owner.** `tools/elevated-smoke.ps1:541-553` replaces the directory’s DACL but never sets or validates its owner. An owner retains permission to change the DACL. [Microsoft documentation](https://learn.microsoft.com/en-us/windows/win32/secauthz/owner-of-a-new-object). **Reproduce:** before first registration, an ordinary second account creates `C:\ProgramData\Resolute\ElevatedSmoke`. The parent’s live ACL permits Users to create directories. The operator then registers normally. The original owner can subsequently grant itself write access and plant a DLL beside the protected Python executable before the next run. Registration accepts a directory whose protection that account can undo, allowing elevated execution without changing either pinned driver. Establish trusted ownership, including protection against replacement through untrusted ancestors.

2. **P2: A valid checkout path containing an apostrophe breaks the registered action.** `tools/elevated-smoke.ps1:141-144` interpolates `$Base` directly into single-quoted PowerShell source without escaping it. **Reproduce:** register a checkout at `D:\Derick's Projects\Resolute`, then invoke `-Run`. The generated `Join-Path 'D:\Derick's Projects\Resolute'` expressions terminate their string prematurely, so the scheduled action fails to parse and smoke never starts. Definition readback compares the same malformed string and accepts it. Escape embedded quotes or pass the path as data.

HIGHEST: P1
OVERALL: needs-attention

## Writer note: round 1 findings fixed

- Fixed: finding 1 (P1, the directory's owner was never set, and an owner can rewrite the ACL). Registration gives Administrators ownership of the directory, everything in it and its parent, and `-Run`, `-Check` and registration refuse an untrusted owner, an extra writer on the directory, or anyone else able to delete or re-permission inside the parent. Read back after a real registration: every entry owned by `BUILTIN\Administrators`, `-Check` ready.
- Fixed: finding 2 (P2, an apostrophe in the checkout path broke the action). Every embedded path is escaped for single-quoted PowerShell; the self-test parses the action built for `D:\Derick's Projects\Resolute` with no errors. `tools/elevated-smoke.ps1 -SelfTest`: 31 PASS, all pass.

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:33:04Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: f1a2479e7ba25df7398bb77727be2d3cc16c7dd6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 18a79feed50135a3

## consistency: approve

No actionable consistency findings in the scoped candidate. Static review only; no files modified or elevated tasks run.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:36:41Z
- Candidate: 43740dde3fe81b3eb57142ceca43cfd8d57b54fd
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: f1a2479e7ba25df7398bb77727be2d3cc16c7dd6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 49
- Digest: 2cff45a53c9d876c

Part 1: completeness

1. **present:** CLI entry points for registration, replacement, checking, running and removal, with invalid mode combinations refused. Evidence: `tools/elevated-smoke.ps1:31`, `:843`. Graphical controls, tooltips, focus order, themes and DPI do not apply to this section.

2. **present:** One-consent registration, same-account enforcement, interactive highest-privilege execution, and preservation of a mismatched registration unless `-Replace` is supplied. Evidence: `tools/elevated-smoke.ps1:559`, `:672`.

3. **present:** Driver pinning, protected runtime, staged executable verification and refusal before launch. Missing manifests, missing entries, changed executables and staging I/O errors have named refusals. Evidence: `tools/elevated-smoke.ps1:139`, `:594`; `scripts/smoke-run.py:1296`, `:1330`. The two tests in `scripts/tests/test_smoke_staging.py` exercise the consuming path.

4. **missing-in-scope:** Required registration security evidence is incomplete. Registration neither prints the driver files’ write principals nor reads back the task security descriptor to establish its permitted principals. The quoted evidence also omits those results. This is missing verification, not a demonstrated permission bypass. Evidence: `tools/elevated-smoke.ps1:629`, `:704`; section contract at `todo/07-quality/TODO-01-quality-bar.md:296`.

5. **present:** Collecting admission, environment contamination refusal, bounded acknowledgement/completion waits, and validation of a fresh passing report and scheduler result. Evidence: `tools/elevated-smoke.ps1:139`, `:726`. The section records both idle-admission refusal and a successful non-elevated invocation.

6. **present:** Timeout cleanup and removal stop running or queued tasks and inspect remaining processes. Evidence: `tools/elevated-smoke.ps1:361`, `:800`, `:814`. The section records a timeout with RegStudio alive followed by confirmed cleanup.

7. **missing-out-of-scope:** Closing or killing the caller bypasses its `finally` cleanup; the elevated task can continue after its initiating session ends. Already filed under **D07 T01 §10**, `todo/07-quality/TODO-01-quality-bar.md:400`.

8. **present:** Persisted hashes and the HKCU executable manifest have readers, and `-Check` checks the registered definition, driver hashes, runtime presence and directory protection. Evidence: `tools/elevated-smoke.ps1:74`, `:712`, `:740`; `scripts/smoke-run.py:1296`.

9. **missing-in-scope:** Registration rollback does not cover all state it changes. It changes directory permissions and parent ownership, rebuilds the run directory, and replaces the runtime, but rollback restores only task XML, hashes and selected created paths. For example, a copy failure after ownership changes leaves those changes behind; a failure after the successful runtime swap cannot restore the discarded old runtime. These residual changes have no documented reverse. Evidence: [elevated-smoke.ps1:590](D:/Resolute/tools/elevated-smoke.ps1:590), `:636`, `:647`.

10. **present:** Removal unregisters the task and confirms absence, with named already-absent, access-denied and scheduler-read failures. Evidence: `tools/elevated-smoke.ps1:814`. This establishes task removal, not complete removal of persisted files, registry values or permission changes.

11. **missing-in-scope:** The PowerShell self-test cannot reliably fail its command. `Invoke-SelfTest` initializes local `$failures`, while `Check` appends to `$script:failures`; the final decision reads the unchanged local array. A file-free reproduction of those scopes returned `0` after a forced failed assertion. Evidence: [elevated-smoke.ps1:409](D:/Resolute/tools/elevated-smoke.ps1:409), `:411`, `:551`. Consequently, the recorded “all pass” result is insufficient proof that these checks enforce their contract.

12. **present:** Operator documentation explains the three elevation routes, consent renewal and trust boundary. Evidence: `docs/testing.md:68`. Successful elevated execution is supported by the section’s recorded real runs; I did not repeat registration or desktop-driving tests during this read-only review.

Part 2: excellence

Counterpart: **none**. This is repository tooling, so AutoIt behavioral parity and the graphical rendering requirements of `DESIGN.md` are not applicable.

1. **in-scope:** Failure reporting is weaker than the machine-verifiable quality goal because failed assertions can produce a successful self-test exit. **Target:** forcing one existing assertion false produces a nonzero exit and no “all pass” summary.

2. **in-scope:** Registration recovery is incomplete across its filesystem, ownership and runtime changes. **Target:** an ordinary copy or replacement failure preserves the previous usable registration and restores changed state, or precisely reports any irreversible residue and its recovery procedure.

3. **in-scope:** The security boundary lacks the registration readbacks expressly required by the contract. **Target:** record the actual task security descriptor and driver write principals, and verify the task’s allowed principals against the stated boundary.

4. **out-of-scope:** The task outlives a closed initiating session. **Target:** stop the driver and its descendants within 30 seconds of caller termination, as already assigned to **D07 T01 §10**.

5. **out-of-scope:** The wrapper and elevated registration can display a console window during unattended operation. The issue is already recorded under **D07 T01 §10**. **Target:** a driven run shows only the intended tool windows, with no wrapper console or flash. Evidence: `tools/elevated-smoke.ps1:164`, `:695`; `todo/07-quality/TODO-01-quality-bar.md:417`.

Consolidated gaps

1. **missing-in-scope / in-scope:** Fix self-test failure aggregation so failed assertions fail the command.
2. **missing-in-scope / in-scope:** Complete registration rollback and document recovery for residual persisted state.
3. **missing-in-scope / in-scope:** Supply and verify the required task-security and driver-write-principal readbacks.
4. **missing-out-of-scope / out-of-scope:** End elevated execution when its caller ends, already owned by D07 T01 §10.
5. **out-of-scope:** Eliminate wrapper and registration console windows, already owned by D07 T01 §10.

COMPLETION: gaps

- Implemented: gap 1 (the self-test's failures were counted in a list its verdict never read) on the repair record `docs/reviews/07-quality/D07-T01-s7-repair2.md`
- Implemented: gap 2 (registration rollback did not cover everything it changes) on the same repair record
- Implemented: gap 3 (the task security and driver write-principal readbacks were missing) on the same repair record
- Filed: D07 T01 §10 (the elevated task outlives a closed caller; already that section's first item)
- Filed: D07 T01 §10 (the wrapper and the registration show a console window; item added 2026-11-13)
