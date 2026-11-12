## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:39:51Z
- Candidate: 6531f5efccc44772622b41b9b0304465899e4c69
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 6531f5efccc44772622b41b9b0304465899e4c69
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 03041902443e843c

1. **P2, line 336:** The recovery instruction cannot remove all the stated residue. Registration changes ownership of `C:\ProgramData\Resolute`, but the documented recovery deletes only its `ElevatedSmoke` child. Require the rollback message and documentation to distinguish removed artifacts from retained parent ownership, and state explicitly when the original ownership cannot be restored.

2. **P2, line 336:** The rollback repair’s `Done when:` checks code order and explanatory text, not restoration. It can pass while a failed replacement leaves the previous task or hashes unrestored. Add one injected failure through `Invoke-RegisterElevated` after registration changes state but before the runtime swap, then read back the previous task definition, pinned hashes and runtime. Require that case to fail when restoration is bypassed. The isolated `Switch-Runtime` test at line 325 does not exercise this transaction.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1, the rollback restores the directory's owner and permissions and the parent's owner (which is now changed only when untrusted), and its message and the documentation say exactly what is and is not restored, in the section-correction commit that follows this record
- Planned: finding 2, a registration failed on purpose and read back field by field (`-Register -ProveRollback`), with the comparison self-tested here; its driven run needs a consent prompt and is an item of D07 T01 §10, in the same commit

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:43:30Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 6531f5efccc44772622b41b9b0304465899e4c69
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: 871e976cf376d38d

### adversarial: needs-attention

1. **P1: `-Run` bypasses the new task-security refusal.** `tools/elevated-smoke.ps1:904` checks directory permissions and task definition, but never calls `Get-TaskSecurityRefusals` before `Start-ScheduledTask` at line 935. Reproduction: on a Windows installation where `\Resolute\ElevatedSmoke` grants another account task-write permission, leave its action and pinned files unchanged. `-Check` refuses that task, but direct `-Run` proceeds to launch it. This passes a task the stated security boundary requires refusing. Apply the security check in the launch path itself.

2. **P2: An elevated caller silently skips `-ProveRollback`.** `tools/elevated-smoke.ps1:849` returns directly through `Invoke-RegisterElevated`; the proof runs only through the separate `-RegisterElevated` dispatcher at line 1021. Reproduction: from an administrator PowerShell terminal, run `tools/elevated-smoke.ps1 -Register -Replace -ProveRollback`. It performs real registration without injecting a failure or comparing restored state. Route both registration entry paths through the proof when requested.

These findings are based on source inspection. No task registration, ACL changes or elevated runs were performed.

HIGHEST: P1
OVERALL: needs-attention

## Writer note: round 1 findings fixed

- Fixed: finding 1 (P1, `-Run` did not call the task-security check that `-Check` has). The cause was two lists of reasons, one per mode. There is now one, `Get-RunRefusals`, which `-Check` reports and `-Run` refuses on, so the launch path cannot lack a check the readiness answer has; the self-test covers a reason from the list stopping a run and both modes reading it.
- Fixed: finding 2 (P2, `-Register -ProveRollback` from a shell already elevated skipped the proof). Both entries now go through `Invoke-ElevatedRegistration`, which runs the proof first when asked. `tools/elevated-smoke.ps1 -SelfTest`: 37 PASS, all pass; `-Check` ready; `-Readback` trusted.
