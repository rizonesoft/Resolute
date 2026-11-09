## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T14:03:53Z
- Candidate: c75c32b4bae61ef08130fd4863699a4fab71f3e5
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: c75c32b4bae61ef08130fd4863699a4fab71f3e5
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: f7cdf68607332bb1

1. **P2, plan:** The shell-free runner has no specified launch-failure path. Copying the existing runner’s drain loop leaves a failed `Run()` without an explicit diagnostic, whereas the shell previously supplied child error output. Specify immediate launch-error handling that reports failure without logging the secret-bearing command, and test a missing executable.

2. **P2, plan:** The regression cases do not exercise the new backslash-escaping logic. Add passwords with trailing backslashes and backslashes immediately before embedded quotes, asserting exact `/p` argument readback and clean logs. Also run the fake executable from a path containing spaces to verify the newly introduced full-path invocation.

3. **P2, plan:** Updating the search inventory alone leaves §5’s acceptance criteria and checkpoint describing `_ProcessEx_RunCommand`, the old executed command, and proof through the shell runner. Explicitly reconcile those statements with the shell-free implementation and record fresh evidence for the repaired candidate.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention


- Planned: all three plan gaps folded into the repair before writing (2026-11-09). Gap 1: the shell-free runner reports a failed Run() immediately with an ERROR line naming only the launch error (never the secret-bearing command), and the regression test covers a missing executable. Gap 2: the test adds passwords with a trailing backslash and with a backslash immediately before an embedded quote (exact /p argument readback, clean log), and the fake signtool is built into a path containing spaces. Gap 3: D09 T01 section 5's item and checkpoint wording are reconciled to the shell-free runner in the repair commit, with fresh evidence recorded for the repaired candidate.
