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

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:45:26Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: 6531f5efccc44772622b41b9b0304465899e4c69
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 48c7433bfacd8919

### consistency: approve

No actionable consistency findings in the candidate diff. Review was read-only; elevated operations were not run.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:47:33Z
- Candidate: feb5c64c36f866eecb189fe96981c4a16e7c7319
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 6531f5efccc44772622b41b9b0304465899e4c69
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 56
- Digest: c07951b61ba76915

The feature still has recovery and registration-validation gaps. AutoIt parity and visual `DESIGN.md` requirements are not applicable to this repository tooling. No files were modified; elevated operations were not run.

**Part 1: completeness**

1. **present:** Command interface and invalid-mode refusal. Registration, replacement, run, removal, readiness, readback and self-test are dispatched in `tools/elevated-smoke.ps1:1050`. Custom controls, tooltips, focus order, themes and DPI layouts do not apply.

2. **present:** Consent-once registration, account validation and protection against accidental replacement. See `tools/elevated-smoke.ps1:716` and `:865`; recorded registration evidence is in `todo/07-quality/TODO-01-quality-bar.md:342`.

3. **present:** Launch-time trust checks, pinned driver verification and named refusals. `Get-RunRefusals` feeds both readiness and launch at `tools/elevated-smoke.ps1:913`. Descriptor tests start at `:612`; recorded trust readback is at `todo/07-quality/TODO-01-quality-bar.md:354`.

4. **missing-in-scope:** Every successful registration path must perform the promised security readback. Plain `-Register` returns success solely from definition and hash matching at `tools/elevated-smoke.ps1:870`; registration from an elevated shell returns at `:883`. Both bypass the task-security validation at `:905`. An existing registration with unsuitable task permissions can therefore report success. Use the same final validation for every registration entry and test that a security refusal prevents success.

5. **present:** Collecting admission, report validation and bounded waiting. `tools/elevated-smoke.ps1:110` rejects stale/non-pass reports and nonzero results; `:972` implements acknowledgement and completion waits. Actual admission refusal, successful smoke and timeout cleanup are recorded at `todo/07-quality/TODO-01-quality-bar.md:347`, `:348` and `:350`.

6. **present:** Removal stops running or queued work, unregisters the task and checks absence. See `tools/elevated-smoke.ps1:1021`. This reverses task registration; retained files and ownership changes have documented limitations at `docs/testing.md:85`.

7. **missing-in-scope:** Failed replacement cannot reliably restore the previous task. `tools/elevated-smoke.ps1:822` calls `Register-ScheduledTask -XmlText`, but the installed cmdlet exposes `-Xml`, with no `XmlText` alias. I verified this through read-only command metadata. Every rollback that attempts task restoration hits parameter binding failure. Correct the parameter and exercise the actual restoration call through one focused regression case.

8. **missing-in-scope:** A late registration failure can leave the new Python runtime paired with restored old registration data. `Switch-Runtime` deletes the previous runtime at `tools/elevated-smoke.ps1:369`, but registration then performs hashing and log writes at `:811`. A full disk or locked log can throw after that deletion. The outer rollback restores task and hashes but not the old runtime (`:819`). Retain the old runtime until all failure-producing transaction work finishes, or make post-commit reporting unable to trigger rollback. Test one late-write failure.

9. **present:** Persistent task, hashes, protected runtime and per-run manifest are consumed on subsequent runs. Paths are declared at `tools/elevated-smoke.ps1:49`; readiness reads them at `:913`, and the manifest is populated at `:950`. Transactional recovery remains incomplete for the reasons above.

10. **present:** Self-test failures now propagate to a nonzero result. The shared failure list is initialized at `tools/elevated-smoke.ps1:474` and checked at `:642`. The deliberately broken owner-rule run is recorded at `todo/07-quality/TODO-01-quality-bar.md:354`.

11. **missing-out-of-scope:** Closing or killing the caller can leave its elevated smoke running. Already owned by quality section **D07 T01 §10**, at `todo/07-quality/TODO-01-quality-bar.md:418`.

12. **missing-out-of-scope:** Wrapper and registration consoles still appear during operation. Already owned by **D07 T01 §10**, at `todo/07-quality/TODO-01-quality-bar.md:422`.

13. **missing-out-of-scope:** The live injected-failure rollback proof has not been completed. Its comparison helper and recorded self-tests do not establish restoration through Task Scheduler. The consented drill is explicitly assigned to **D07 T01 §10**, at `todo/07-quality/TODO-01-quality-bar.md:423`.

**Part 2: excellence**

Counterpart: **none in `resolute_au3/`**. No frozen tool behavior changes. `DESIGN.md` visual requirements do not apply; operational safety, truthful feedback and recovery remain applicable.

1. **in-scope:** Registration success is weaker than readiness validation. Target: every successful registration exit passes the task-security, definition, directory and pin checks, regardless of entry path. Evidence: `tools/elevated-smoke.ps1:870`, `:883`, `:905`.

2. **in-scope:** Task rollback invokes an unsupported parameter. Target: a failed replacement restores the previous task definition and reports any restoration failure accurately. Evidence: `tools/elevated-smoke.ps1:822`.

3. **in-scope:** Late logging failure can invalidate the claimed runtime rollback. Target: one injected post-swap write failure leaves either the complete previous registration or an explicitly committed complete new registration, never mixed state. Evidence: `tools/elevated-smoke.ps1:369`, `:810`, `:819`.

4. **out-of-scope:** Elevated work survives caller termination. Target: terminate the driver and children within 30 seconds, as already specified by D07 T01 §10.

5. **out-of-scope:** Infrastructure consoles interrupt the unattended experience. Target: zero wrapper-console appearances while preserving the smoke tool windows, as already specified by D07 T01 §10.

6. **out-of-scope:** Recovery lacks its scheduled live proof. Target: quote the injected failure, unchanged-state readback and subsequent ready registration from the §10 consented drill.

**Consolidated gaps**

1. **missing-in-scope / in-scope:** Apply complete security readback to every successful registration path, `tools/elevated-smoke.ps1:870`.
2. **missing-in-scope / in-scope:** Replace unsupported `-XmlText` and verify actual task restoration, `tools/elevated-smoke.ps1:822`.
3. **missing-in-scope / in-scope:** Preserve transaction consistency when logging fails after runtime replacement, `tools/elevated-smoke.ps1:810`.
4. **missing-out-of-scope / out-of-scope:** End elevated smoke with its caller, already filed in D07 T01 §10.
5. **missing-out-of-scope / out-of-scope:** Suppress infrastructure consoles, already filed in D07 T01 §10.
6. **missing-out-of-scope / out-of-scope:** Complete the live rollback drill, already filed in D07 T01 §10.

COMPLETION: gaps

- Implemented: gap 1 (a registration could report success without the task-security readback) on the repair record `docs/reviews/07-quality/D07-T01-s7-repair3.md`
- Implemented: gap 2 (the rollback restored the task with a parameter the cmdlet does not have) on the same repair record
- Implemented: gap 3 (a failure after the runtime swap could leave the new runtime under restored registration data) on the same repair record
- Filed: D07 T01 §10 (the elevated task outlives a closed caller; already that section's first item)
- Filed: D07 T01 §10 (the wrapper and the registration show a console window; item added 2026-11-13)
- Filed: D07 T01 §10 (the live rollback drill; item "Prove the rollback at this registration")
