# Review-run records

One block per stamped section whose review reached an independent round.
Checked by `scripts/todo-runs.py --check`, which cross-reads the per-section
review files: every `findings` ref must resolve to a finding heading, every
`(independent)` mark must be listed by exactly one run, `empty` must equal the
rounds with outcome `empty`, and `refuted` must equal the listed refs whose
disposition is refuted. Panel runs additionally re-read their round verdicts
from the review file's panel sections.

Rounds here are independent rounds only; the review files' own `Rounds:`
counts include the self pass and differ. Round candidates are the commits
reviewed: explicit `--commit` shas for codex rounds, and for panel rounds the
tree each round read (the pre-panel commit for round 1, each round's fix
commit for the round after). `findings` lists exactly the refs carrying an
`(independent)` mark; findings described only in review prose, without a ref,
are noted in `#` comments and counted nowhere.

run: D00-T01-S1
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 6bb635e
findings: D00-T01-S1-F1, D00-T01-S1-F2
# round 1 also returned a third P2 against code already fixed in a later
# commit it had not read; a stale-candidate report, not a finding.
empty: 0
refuted: 0

run: D00-T01-S2
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 6062ecb
findings: D00-T01-S2-F1
empty: 0
refuted: 0

run: D00-T01-S3
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: cbd5164
findings: D00-T01-S3-F1
empty: 0
refuted: 0

run: D00-T01-S4
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: b87af92
findings: D00-T01-S4-F1, D00-T01-S4-F2, D00-T01-S4-F3
empty: 0
refuted: 0

run: D00-T01-S5
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: e7d634f
findings: D00-T01-S5-F1, D00-T01-S5-F2
empty: 0
refuted: 0

run: D00-T01-S6
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 0227f4b
findings: D00-T01-S6-F1
empty: 0
refuted: 0

run: D00-T02-S1
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 35b0ef8
findings: D00-T02-S1-F1
empty: 0
refuted: 0

run: D00-T02-S2
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 2536f52
findings: D00-T02-S2-F1, D00-T02-S2-F2, D00-T02-S2-F3
empty: 0
refuted: 0

run: D00-T02-S3
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 0ea2877
findings: D00-T02-S3-F1, D00-T02-S3-F2, D00-T02-S3-F3, D00-T02-S3-F4, D00-T02-S3-F5
# the round returned four; F1 carries the mark but the prose credits the
# operator's question. The record follows the mark; the tension is the
# file's, and the file is stamped.
empty: 0
refuted: 0

run: D00-T02-S4
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 18a9c6a
findings: D00-T02-S4-F3, D00-T02-S4-F4, D00-T02-S4-F5, D00-T02-S4-F6
empty: 0
refuted: 0

run: D00-T02-S5
date: 2026-09-19
runner: panel
rounds: 5
round: 1 model: gpt-5.6-sol effort: medium outcome: findings candidate: 0f554fc
round: 2 model: gpt-5.6-sol effort: medium outcome: findings candidate: 9fa74b7
round: 3 model: opus effort: medium outcome: findings candidate: 73603b9
round: 4 model: opus effort: medium outcome: findings candidate: 1de9d3c
round: 5 model: opus effort: medium outcome: findings candidate: 96988df
findings: D00-T02-S5-F1, D00-T02-S5-F2, D00-T02-S5-F3, D00-T02-S5-F4, D00-T02-S5-F5, D00-T02-S5-F6, D00-T02-S5-F7, D00-T02-S5-F8, D00-T02-S5-F9, D00-T02-S5-F10, D00-T02-S5-F11, D00-T02-S5-F12, D00-T02-S5-F13, D00-T02-S5-F14, D00-T02-S5-F15, D00-T02-S5-F16
# round 1: F1-F5; round 2: F6-F9; round 3: F10-F12; round 4: F13-F15;
# round 5: F16, filed at the hard cap. Panel effort pinned medium.
empty: 0
refuted: 0

run: D00-T03-S1
date: 2026-09-17
runner: codex
rounds: 2
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: ffa97c3
round: 2 model: gpt-6-astra effort: high outcome: empty candidate: 8ba1f20
findings:
# round 1 raised two P2s recorded in prose only, before refs existed; see
# the review file. They are not counted in the dimensions.
empty: 1
refuted: 0

run: D00-T03-S2
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: empty candidate: 7d3ac0d
findings:
empty: 1
refuted: 0

run: D00-T03-S3
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: empty candidate: 68c7ea9
findings:
empty: 1
refuted: 0

run: D00-T03-S4
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: empty candidate: 74caddc
findings:
empty: 1
refuted: 0

run: D00-T04-S1
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: f875758
findings: D00-T04-S1-F1, D00-T04-S1-F2, D00-T04-S1-F3, D00-T04-S1-F4
empty: 0
refuted: 0

run: D00-T04-S2
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 43a299a
findings: D00-T04-S2-F1, D00-T04-S2-F2
empty: 0
refuted: 0

run: D00-T04-S3
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 6fb88f3
findings: D00-T04-S3-F1, D00-T04-S3-F2, D00-T04-S3-F3
empty: 0
refuted: 0

run: D00-T04-S4
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 390b560
findings: D00-T04-S4-F1, D00-T04-S4-F2, D00-T04-S4-F3
empty: 0
refuted: 0

run: D00-T04-S5
date: 2026-09-17
runner: codex
rounds: 1
round: 1 model: gpt-6-astra effort: high outcome: empty candidate: 625f3dc
findings:
empty: 1
refuted: 0

run: D00-T04-S6
date: 2026-09-19
runner: panel
rounds: 4
round: 1 model: gpt-5.6-sol effort: medium outcome: findings candidate: 6cd4676
round: 2 model: gpt-5.6-sol effort: medium outcome: findings candidate: 11e6de7
round: 3 model: opus effort: medium outcome: findings candidate: f0c3db3
round: 4 model: opus effort: medium outcome: empty candidate: 79979a6
findings: D00-T04-S6-F1, D00-T04-S6-F2, D00-T04-S6-F3, D00-T04-S6-F4, D00-T04-S6-F5, D00-T04-S6-F6
# round 1: F1-F2; round 2: F3-F5; round 3: F6; round 4: empty.
# F3 is the tree's first refuted independent finding.
empty: 1
refuted: 1

run: D07-T01-S1
date: 2026-09-17
runner: codex
rounds: 2
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: a73addf
round: 2 model: gpt-5.6-sol effort: high outcome: findings candidate: 235a71f
findings: D07-T01-S1-F4, D07-T01-S1-F5, D07-T01-S1-F6, D07-T01-S1-F7, D07-T01-S1-F8, D07-T01-S1-F9, D07-T01-S1-F10
# round 1: F4-F6 (two P2 plus the regression-test request); round 2 read
# the stamp commit itself: F7-F10.
empty: 0
refuted: 0
