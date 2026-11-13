## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T01:14:04Z
- Candidate: 853a8ae659335b5a70242b8de571f9c446211d36
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 853a8ae659335b5a70242b8de571f9c446211d36
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 733401becece18ef

1. **P1, plan, line 492:** The proof checks only that `Invoke-Run` refuses an already-held lock. It would pass if `Invoke-Run` acquired and immediately released the lock before readiness, leaving the original race intact. Add one sandbox case that attempts registration from inside an admitted run, before task launch, verifies refusal without changing registration state, and verifies acquisition succeeds after the run exits. Require this case to fail when the run releases its lock early.

2. **P2, plan, lines 484 and 492:** `-Remove` remains outside transaction coordination. At this commit, `Invoke-Remove` unregisters the task without acquiring the registration lock. It can therefore remove the task after registration’s readiness check but before commit, allowing registration to report success with no task present. Include removal in the same lock protocol, with a named busy refusal and one sandbox case proving removal during registration leaves the task untouched.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1 (a refused run does not show the run keeps the lock), a probe from another thread inside the admitted run and after it, failing on a run that releases early, in the section-correction commit that follows this record
- Planned: finding 2 (`-Remove` was outside the lock), removal under the same lock with a named refusal and a case that leaves the task in place, in the same commit
