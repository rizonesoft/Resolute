## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T10:14:15Z
- Candidate: f2b50b8b7eb98c36012fef72c7708d340606ae06
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: f2b50b8b7eb98c36012fef72c7708d340606ae06
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 5bb9bbff91c67773

1. **P1, `todo/00-workspace/TODO-06-reference-data.md:90`: The TLS refusal test fails before reaching the connection it must prove.** Giving the author’s option file an unrelated CA makes restore fail at `s.exists()` and upgrade fail at its initial source connection. Neither reaches the restricted option file, so removing TLS settings from that file cannot make this refusal test fail as required. Keep the author connection valid and introduce the invalid CA specifically into the restricted connection during the test. Prove restore and upgrade reach that connection, refuse certificate verification, remove the temporary account and destination database, and preserve the source. Require this test to fail when restricted-connection TLS settings are dropped.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: the TLS refusal is driven through the restricted connection alone, the author's connection staying valid (P1), in the corrected Repair 2 restore item.
