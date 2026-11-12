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
