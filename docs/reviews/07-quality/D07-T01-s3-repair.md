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
