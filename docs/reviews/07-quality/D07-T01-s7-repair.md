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
