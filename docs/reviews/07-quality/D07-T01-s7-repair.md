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
