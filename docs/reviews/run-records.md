# Review-run records

schema: 1

Terminology, pinned. A run is one section's independent review, however many rounds it took; an engagement is the same thing counted for the report, so runs and engagements agree by construction. A round is one reviewer invocation against one candidate. The panel is the `panel` runner: Sol rounds 1-2 with an Opus sign-off at round 3 and Opus fix-loop rounds after, all at medium effort. Empty is outcome-based: an engagement is empty when every round came back empty, so a run that raised only refuted findings is not empty (the reviewer found things; they did not survive). The self side is ledger-derived: self equals the ledger's findings for the section minus the run's refs, and the coverage check (every independent mark claimed exactly once) is what validates the split, printed beside it in the report. Rounds that raised findings recorded only in review prose keep outcome findings with an empty ref list and a `#` comment naming the file; comments explain, refs count, and the two never mix.

One block per stamped section whose review reached an independent round. Checked by `scripts/todo-runs.py --check`, which cross-reads the per-section review files: every listed ref must resolve to an independent-marked finding heading, every `(independent)` mark must be listed by exactly one run, every review file must have a run block, `empty` must equal the rounds with outcome `empty`, and `refuted` must equal the listed refs whose disposition is refuted. Panel runs additionally re-read their round verdicts from the review file's panel sections, and every candidate must be a commit that exists.

Rounds here are independent rounds only; the review files' own `Rounds:` counts include the self pass and differ. Round candidates are the commits reviewed: explicit `--commit` shas for codex rounds, and for panel rounds the tree each round read (the pre-panel commit for round 1, each round's fix commit for the round after). Each round line carries the model, provider, exact version (`unresolved` when the invocation never pinned one), cost in tokens (`unresolved` when unrecorded; USD prices outside the record), latency, opportunity scope, review purpose, provenance, and the refs that round raised, so per-model yield and cost are queries. Findings described only in review prose, without a ref, are noted in `#` comments and counted nowhere.

run: D00-T01-S1
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 6bb635e provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T01-S1-F1, D00-T01-S1-F2
# round 1 also returned a third P2 against code already fixed in a later commit it had not read; a stale-candidate report, not a finding.
empty: 0
refuted: 0

run: D00-T01-S2
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 6062ecb provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T01-S2-F1
empty: 0
refuted: 0

run: D00-T01-S3
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: cbd5164 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T01-S3-F1
empty: 0
refuted: 0

run: D00-T01-S4
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: b87af92 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T01-S4-F1, D00-T01-S4-F2, D00-T01-S4-F3
empty: 0
refuted: 0

run: D00-T01-S5
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: e7d634f provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T01-S5-F1, D00-T01-S5-F2
empty: 0
refuted: 0

run: D00-T01-S6
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 0227f4b provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T01-S6-F1
empty: 0
refuted: 0

run: D00-T02-S1
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 35b0ef8 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T02-S1-F1
empty: 0
refuted: 0

run: D00-T02-S2
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 2536f52 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T02-S2-F1, D00-T02-S2-F2, D00-T02-S2-F3
empty: 0
refuted: 0

run: D00-T02-S3
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 0ea2877 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T02-S3-F1, D00-T02-S3-F2, D00-T02-S3-F3, D00-T02-S3-F4, D00-T02-S3-F5
# the round returned four; F1 carries the mark but the prose credits the operator's question. The record follows the mark; the tension is the file's, and the file is stamped.
empty: 0
refuted: 0

run: D00-T02-S4
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 18a9c6a provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T02-S4-F3, D00-T02-S4-F4, D00-T02-S4-F5, D00-T02-S4-F6
empty: 0
refuted: 0

run: D00-T02-S5
date: 2026-09-19
runner: panel
rounds: 5
round: 1 model: gpt-5.6-sol effort: medium outcome: findings candidate: 0f554fc provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T02-S5-F1, D00-T02-S5-F2, D00-T02-S5-F3, D00-T02-S5-F4, D00-T02-S5-F5
round: 2 model: gpt-5.6-sol effort: medium outcome: findings candidate: 9fa74b7 provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings: D00-T02-S5-F6, D00-T02-S5-F7, D00-T02-S5-F8, D00-T02-S5-F9
round: 3 model: opus effort: medium outcome: findings candidate: 73603b9 provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: sign-off provenance: reconstructed findings: D00-T02-S5-F10, D00-T02-S5-F11, D00-T02-S5-F12
round: 4 model: opus effort: medium outcome: findings candidate: 1de9d3c provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings: D00-T02-S5-F13, D00-T02-S5-F14, D00-T02-S5-F15
round: 5 model: opus effort: medium outcome: findings candidate: 96988df provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings: D00-T02-S5-F16
# round 5's F16 filed at the hard cap. Panel effort pinned medium.
empty: 0
refuted: 0

run: D00-T03-S1
date: 2026-09-17
runner: codex
rounds: 2
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: ffa97c3 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings:
round: 2 model: gpt-6-astra effort: high outcome: empty candidate: 8ba1f20 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings:
# round 1 raised two P2s recorded in prose only, before refs existed; see the review file. They are not counted in the dimensions.
empty: 1
refuted: 0

run: D00-T03-S2
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: empty candidate: 7d3ac0d provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings:
empty: 1
refuted: 0

run: D00-T03-S3
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: empty candidate: 68c7ea9 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings:
empty: 1
refuted: 0

run: D00-T03-S4
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: empty candidate: 74caddc provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings:
empty: 1
refuted: 0

run: D00-T04-S1
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: f875758 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T04-S1-F1, D00-T04-S1-F2, D00-T04-S1-F3, D00-T04-S1-F4
empty: 0
refuted: 0

run: D00-T04-S2
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 43a299a provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T04-S2-F1, D00-T04-S2-F2
empty: 0
refuted: 0

run: D00-T04-S3
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 6fb88f3 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T04-S3-F1, D00-T04-S3-F2, D00-T04-S3-F3
empty: 0
refuted: 0

run: D00-T04-S4
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 390b560 provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T04-S4-F1, D00-T04-S4-F2, D00-T04-S4-F3
empty: 0
refuted: 0

run: D00-T04-S5
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: empty candidate: 625f3dc provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings:
empty: 1
refuted: 0

run: D00-T04-S6
date: 2026-09-19
runner: panel
rounds: 4
round: 1 model: gpt-5.6-sol effort: medium outcome: findings candidate: 6cd4676 provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T04-S6-F1, D00-T04-S6-F2
round: 2 model: gpt-5.6-sol effort: medium outcome: findings candidate: 11e6de7 provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings: D00-T04-S6-F3, D00-T04-S6-F4, D00-T04-S6-F5
round: 3 model: opus effort: medium outcome: findings candidate: f0c3db3 provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: sign-off provenance: reconstructed findings: D00-T04-S6-F6
round: 4 model: opus effort: medium outcome: empty candidate: 79979a6 provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings:
# F3 is the tree's first refuted independent finding.
empty: 1
refuted: 1

run: D00-T04-S7
date: 2026-09-19
runner: panel
rounds: 4
round: 1 model: gpt-5.6-sol effort: medium outcome: findings candidate: e44b137 provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T04-S7-F1, D00-T04-S7-F2, D00-T04-S7-F3, D00-T04-S7-F4, D00-T04-S7-F5
round: 2 model: gpt-5.6-sol effort: medium outcome: empty candidate: 2a184a9 provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings:
round: 3 model: opus effort: medium outcome: findings candidate: 2a184a9 provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: sign-off provenance: reconstructed findings: D00-T04-S7-F6, D00-T04-S7-F7
round: 4 model: opus effort: medium outcome: empty candidate: 091262f provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings:
# round 1: F1-F5; round 2: empty; round 3: F6-F7; round 4: empty.
empty: 2
refuted: 0

run: D00-T04-S9
date: 2026-09-19
runner: panel
rounds: 6
round: 1 model: gpt-5.6-sol effort: medium outcome: findings candidate: 2b4b493 provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T04-S9-F1, D00-T04-S9-F2, D00-T04-S9-F3
round: 2 model: gpt-5.6-sol effort: medium outcome: error candidate: e8ee5e8 provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings: D00-T04-S9-F4
round: 3 model: gpt-5.6-sol effort: medium outcome: findings candidate: 965df5f provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings: D00-T04-S9-F5
round: 4 model: opus effort: medium outcome: findings candidate: 41bdbc1 provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: sign-off provenance: reconstructed findings: D00-T04-S9-F6, D00-T04-S9-F7
round: 5 model: opus effort: medium outcome: findings candidate: bbaaad5 provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings: D00-T04-S9-F8, D00-T04-S9-F9
round: 6 model: opus effort: medium outcome: findings candidate: 9495dab provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings: D00-T04-S9-F10, D00-T04-S9-F11
# round 2 is the voided attempt: another session's contract rode the prompt, so its contract-judging verdicts are void, but its diff chunk was intact and F4 verified independently. Panel sections number the five usable rounds.
empty: 0
refuted: 0

run: D00-T04-S10
date: 2026-09-19
runner: panel
rounds: 3
round: 1 model: gpt-5.6-sol effort: medium outcome: findings candidate: f118e30 provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: recorded findings: D00-T04-S10-F1, D00-T04-S10-F2, D00-T04-S10-F3, D00-T04-S10-F4
round: 2 model: gpt-5.6-sol effort: medium outcome: findings candidate: 986d912 provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: recorded findings: D00-T04-S10-F5, D00-T04-S10-F6, D00-T04-S10-F7, D00-T04-S10-F8
round: 3 model: opus effort: medium outcome: findings candidate: 0ab7076 provider: claude version: unresolved cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: sign-off provenance: recorded findings: D00-T04-S10-F9
empty: 0
refuted: 0

run: D07-T01-S1
date: 2026-09-17
runner: codex
rounds: 2
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: a73addf provider: codex version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D07-T01-S1-F4, D07-T01-S1-F5, D07-T01-S1-F6
round: 2 model: gpt-5.6-sol effort: high outcome: findings candidate: 235a71f provider: codex version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: full-scope purpose: stamp-review provenance: reconstructed findings: D07-T01-S1-F7, D07-T01-S1-F8, D07-T01-S1-F9, D07-T01-S1-F10
# round 1: two P2 plus the regression-test request; round 2 read the stamp commit itself.
empty: 0
refuted: 0
