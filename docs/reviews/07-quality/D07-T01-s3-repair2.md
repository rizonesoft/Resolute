# Review record: D07 T01 section 3, repair cycle 2

Continuation of [D07-T01-s3-repair.md](D:/GitHub/Resolute/docs/reviews/07-quality/D07-T01-s3-repair.md), whose completion review returned gaps and closed that record. All five in-scope gaps fixed in `95ebf9e950a1fdb7910bfd114e548408cc9aa8b9`; gap 6 declined as reviewer-marked out of scope. Candidate for this cycle: `95ebf9e950a1fdb7910bfd114e548408cc9aa8b9`.

## Plan review: none

- Writer: muse
- Run: 2026-11-09T05:34:15Z
- Candidate: 95ebf9e950a1fdb7910bfd114e548408cc9aa8b9
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: ea21439b7f1f676fd5ea7dfd65500ceec62d1d67
- Execution: invalid
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Skipped: astra (invalid terminal verdict)
- Lines: 1
- Digest: d0e98b1c73c67d0f

No reviewer returned a plan review. This pass is not an approval.

## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T05:36:06Z
- Candidate: 95ebf9e950a1fdb7910bfd114e548408cc9aa8b9
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: ea21439b7f1f676fd5ea7dfd65500ceec62d1d67
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 21
- Digest: c6408061dc403943

**plan: needs-attention.** The fixes target the correct owning layers, but the plan leaves these gaps:

1. **Configure-time evidence is optional.** [tidy-ratchet.py:1512](D:/GitHub/Resolute/scripts/tidy-ratchet.py:1512) uses `expect_dbs.get(rel, digest)`, so an absent expectation accepts the current database. Missing databases are also skipped during publication. Require complete configure-time hash coverage for the recorded targets. Probe omitted, incomplete and malformed `--expect-dbs`, and a database missing at capture or publication. Each must refuse without publishing replacement evidence.

2. **Ninja path parsing still mishandles spaces.** [tidy-ratchet.py:1498](D:/GitHub/Resolute/scripts/tidy-ratchet.py:1498) splits on whitespace before decoding Ninja escapes. A valid source such as `dir$ with$ spaces/a.cpp` becomes several tokens and falsely disagrees with the database. Add positive controls for absolute Windows paths, escaped spaces and literal dollar signs, alongside the same-basename refusal. Fix parsing in the build-record producer.

3. **The reporting repairs lack regression coverage.** The commit changes conformance behavior without adding conformance tests. Require:
   - C22 advisory PASS and FAIL details while the cell remains NYE and the advisory does not fail the gate.
   - Moved-owner resolver output reaching the rendered matrix with its destination, through the actual resolver/parsing path.
   - Owner resolution invoking `sys.executable` when literal `python` is unavailable.
   
   These should fail against the parent implementation and pass against the repaired candidate.

4. **The database tests do not exercise the PowerShell handoff.** The command-change fixture supplies a constructed hash directly to Python. It cannot prove `Capture-Db` captures both launcher and extension databases before compilation or passes their hashes correctly. The round should probe the complete configure, capture, compile and publication path, including a launcher database change while the extension builds. Require a named refusal and no replacement record. Also verify fixture cleanup after the self-test.

5. **Final evidence needs explicit candidate binding.** Current HEAD is `1ba7dbae`; its only difference from `95ebf9e9` is the repair2 review record. Record the exact candidate for each review and the full gate. If subsequent fixes or gate-generated baseline changes alter that candidate, verify those changes before stamping. The ordinary full gate does not run `--repro-check`; completion must identify valid two-clean-build evidence or rerun that checkpoint if the build changes invalidate it.

This was a read-only source and review-record inspection. No files were modified, and builds or file-writing tests were not run.

PLAN: gaps
OVERALL: needs-attention
