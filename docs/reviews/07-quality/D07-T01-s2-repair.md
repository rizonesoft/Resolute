## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T01:55:57Z
- Candidate: e10ca946a3689924d55d52f057dbd46230279bd3
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: e10ca946a3689924d55d52f057dbd46230279bd3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 0e84315689fd0aae

1. **P2, plan, `scripts/tidy-ratchet.py:250`:** Rewrite-down handles only single-spaced arrows, although the parser accepts other spacing. Read-only reproduction: an authorized `5->9` passes initially, rewrites the count to 7, then refuses the unchanged rerun because authorization still says 9. Replace the matched numeric span rather than a literal spaced substring, and test accepted whitespace variants.

2. **P2, plan, `scripts/tidy-ratchet.py:877`:** End-to-end coverage tests analysis failure but omits persistence failures explicitly required by completion gap 3. Add `run()` cases injecting temporary-write and replacement failures, asserting failure and byte-identical original baseline, plus a readback-mismatch case asserting refusal.

HIGHEST: P2  
PLAN: gaps  
OVERALL: needs-attention

- Planned: gap 1 (span-exact ceiling adjustment at any arrow spacing) in ef51d951fd6d21b0a2315840c6749614786f36a2
- Planned: gap 2 (persistence failure cases: temp write, replace, readback) in ef51d951fd6d21b0a2315840c6749614786f36a2

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T02:00:18Z
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: e10ca946a3689924d55d52f057dbd46230279bd3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: 9ad6e05649902470

## adversarial: needs-attention

1. **P3, `scripts/tidy-ratchet.py:263`: Predictable temporary path follows existing links.** `tmp.write_text()` truncates whatever `todo/.tidy-baseline.tmp` references before replacement or readback. Reproduce in a disposable checkout by making that path a hard link to a sentinel file, then triggering rewrite-down. The sentinel is overwritten, and readback can still pass. This requires a planted link, hence P3. Use an exclusively created temporary file in the destination directory.

2. **P3, `scripts/tidy-ratchet.py:273`: Readback OS errors bypass the named refusal handler.** The read occurs outside the `try`, and `main()` catches only `Refusal`. An access or sharing failure after replacement therefore produces an uncaught exception after the baseline has changed. An in-memory probe injecting `PermissionError` confirmed it escapes unchanged. Include readback in the OS-error handling and identify that replacement already occurred. The persistence tests also omit this failure and call only `write_atomic()`, leaving the explicitly requested `run()` persistence-failure coverage absent.

No files were modified. Probes used mocks; the file-writing self-test was not run.

HIGHEST: P3
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T02:06:47Z
- Candidate: 63204f2098506fa854efc4567b396dc7a58f1c2c
- Effort: medium
- Writer model: muse-wonder-full-1.0
- Policy: e10ca946a3689924d55d52f057dbd46230279bd3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 32
- Digest: 3ce72e541ea757ff

The candidate still has two gaps. AutoIt parity and graphical fidelity are not applicable. I inspected the exact candidate and ran read-only, in-memory probes. No files changed; the file-writing self-test and combined gate were not rerun.

**Part 1: completeness**

1. **present:** Standalone invocation and combined-gate wiring, including base/analyzer overrides. Evidence: `scripts/tidy-ratchet.py:986`; `scripts/check-all.ps1:163`. `-SkipBuild` retains the self-test.
2. **present:** Expected coverage includes root and every extension; missing databases and empty targets refuse. Evidence: `scripts/tidy-ratchet.py:391`, `:419`, `:440`.
3. **present:** Failed analyzer invocations and error diagnostics refuse before baseline mutation. Evidence: `scripts/tidy-ratchet.py:451`, `:457`; preservation assertion at `:909`.
4. **present:** Malformed baselines reject missing, duplicate, unknown and inconsistent entries. Evidence: `scripts/tidy-ratchet.py:78`; self-test cases at `:623`.
5. **present:** Counting normalizes paths, deduplicates per target and globally, excludes dependency findings and preserves uppercase/dotted check names. Evidence: `scripts/tidy-ratchet.py:52`, `:64`, `:463`.
6. **present:** Raise authorization checks exact transitions against the comparison revision, including committed-ahead changes and new targets. Evidence: `scripts/tidy-ratchet.py:157`, `:490`; tests at `:738`, `:789`.
7. **present:** Equal counts preserve the file; decreases use atomic replacement and readback; authorized rewrites survive unchanged reruns. Evidence: `scripts/tidy-ratchet.py:260`, `:552`; tests at `:873`, `:893`, `:941`.
8. **present:** Offset regressions fail by target, with finding identities and a final summary retained in combined-gate output. Evidence: `scripts/tidy-ratchet.py:526`, `:542`; test at `:877`.
9. **present:** Resource collisions are scoped to executable resource namespaces, including transitive quoted headers and legal-reuse controls. Evidence: `scripts/tidy-ratchet.py:297`, `:330`; tests at `:703`. Read-only execution found the launcher and RegStudio namespaces.
10. **present:** Self-tests exercise counting, refusal paths, authorization, resource collisions, orchestration and persistence failures. Evidence: `scripts/tidy-ratchet.py:575`, `:840`, `:941`. The two gaps below lack regression coverage.
11. **missing-in-scope:** Preserve historical baseline audit records. `scripts/tidy-ratchet.py:247` adjusts every matching raise ceiling, including records already committed in the comparison baseline. Using the actual baseline, a normal reduction to total 168/root 121 changes `todo/.tidy-baseline:20` from historical `103 -> 169` to `103 -> 168`, retaining its September date and reason. The in-memory probe reproduced this.
12. **missing-in-scope:** Preserve actionable analyzer diagnostics on standalone invocation. `--log` defaults to `None` (`scripts/tidy-ratchet.py:991`), so `:413` discards captured output. A mocked configuration failure produced only the generic refusal at `:454`; its actual error disappeared.

**Part 2: excellence**

Counterpart: the predecessor’s inline PowerShell comparison and `scripts/profile-check.py`. The relevant `DESIGN.md:204` requirement is actionable refusal messaging.

1. **in-scope:** Rewrite-down corrupts historical attribution even though persistence is atomic. **Target:** committed historical raise lines remain byte-identical after a decrease; only newly introduced authorization ceilings may change, and unchanged reruns still pass. Add a regression using the current historical baseline. Evidence: Part 1, item 11.
2. **in-scope:** Standalone failure messages lose the analyzer’s cause, unlike the predecessor’s retained diagnostic log. **Target:** every analyzer failure exposes its diagnostic text or names a persisted log, including without `--log`; test both nonzero exits and error diagnostics. Evidence: Part 1, item 12.

No concrete counting or speed regression was established.

**Consolidated gap list**

1. **missing-in-scope; in-scope:** Preserve committed historical raise records during rewrite-down and cover this with a regression test, `scripts/tidy-ratchet.py:247`.
2. **missing-in-scope; in-scope:** Retain actionable analyzer diagnostics without `--log` and test that invocation path, `scripts/tidy-ratchet.py:413`.

COMPLETION: gaps

- Implemented: completion gap 1 (historical Raised lines byte-identical on rewrite) in dd6757b40664c5e6eb0934a7ba91bca11dcbace5
- Implemented: completion gap 2 (standalone runs keep build/logs/gate-tidy.log diagnostics) in dd6757b40664c5e6eb0934a7ba91bca11dcbace5
- Settled: second repair cycle runs on docs/reviews/07-quality/D07-T01-s2-repair2.md (dispatcher closes a record at its completion)
