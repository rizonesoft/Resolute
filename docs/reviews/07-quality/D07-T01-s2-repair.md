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
