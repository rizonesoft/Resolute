# Outcome transitions

One block per finding whose disposition is refuted, withdrawn, duplicate, or routed: final states deserve a sentence, but a finding that ends anywhere other than fixed or filed keeps its when, why, and evidence, quoted from the record that decided it. Each block carries `as-of:`, the commit whose tree holds the quoted record. Checked by `scripts/todo-findings.py --check`: every non-final ledger row has exactly one block, every block names a live row, the block's `to` agrees with the row's disposition, and the `as-of` resolves to a commit.

transition: D00-T04-S6-F3
date: 2026-09-19
from: raised
to: refuted
why: "writes are serial (one session owns the tree, so two reviews of one tree cannot run), a local symlink planter is outside every threat model this repo states, and the same `/tmp` shape is used by every panel command in the skill by design, so fixing one command would be incoherent."
evidence: "The sign-off round accepted the refutation and did not re-report." Scope note, quoted from the §9 record: "another session's contract rode the shared `/tmp` path", the cross-session variant, outside the one-tree scope above, which §9 closed with per-run directories.
as-of: 0a24c03

transition: D00-T03-S4-F3
date: 2026-09-17
from: raised
to: routed
why: "`TODO.md` devotes three phases and 51 mentions to hosting Control Panel applets" while "`git grep -i \"\\.cpl\"` over `todo/` returned **nothing**, so the Resolute plan has no coverage at all", and "whether the launcher should host third-party DLLs in its own elevated process is a product judgement, not an implementation detail."
evidence: "Filed as a decision on `D03 T01 §4` rather than as work" (target resolves: Windows System Locations), since "That section already plans to *open* Control Panel items by CLSID through the shell".
as-of: f75d6f1

transition: D07-T01-S1-F2
date: 2026-09-17
from: raised
to: routed
why: "That layout is owned by `D01 T01 §9`, which has not shipped. Stalling was not an option and guessing would have put a second, drifting copy of the layout in this document."
evidence: "So **standalone-ness is stated as behaviour and names no paths**" with "The cost is written down in both places", routed to `D01 T01 §9` in `a73addf` (resolves: Standalone Proof in an Empty Folder).
as-of: 235a71f

transition: D00-T04-S11-F4
date: 2026-09-19
from: raised
to: refuted
why: "The manifest faithfully reports chunk structure: the forged `diff --git` line is in the chunk and the rename pair sits in header position of its block, so body and manifest agree. F10's defect was manifest-body mismatch; nothing leaks here. Forgery only adds, the forged block stays visible, and input authenticity is §12's scope, not §11's."
evidence: "Driven probes yield `diff-files=real.md|fake.md` and `diff-files=real.md|x.md|y.md`, exactly as claimed", quoted from the §11 record; mechanics confirmed, conclusion refuted.
as-of: 3ee9e5f

transition: D00-T04-S11-F5
date: 2026-09-19
from: raised
to: refuted
why: "The residual clause concerns shapes the parser mishandles; forged blocks are parsed faithfully, so combined diffs stand as the sole residual and the three-way agreement holds on a true claim."
evidence: "Disproved with F4", sharing its probes; see the F4 transition above.
as-of: 3ee9e5f

transition: D00-T04-S12-F14
date: 2026-09-20
from: raised
to: refuted
why: "The candidate correctly excludes plan churn; the panel reviews implementation, not the ref block, and XREF bidirectionality is proven mechanically rather than from panel evidence."
evidence: "`633e32b` added both directions atomically and `validate` reports 0 fatal with reciprocity FATAL on one-sided", quoted from the §12 record; mechanics confirmed, conclusion refuted.
as-of: ef362d6

transition: D00-T04-S12-F16
date: 2026-09-20
from: raised
to: duplicate
why: "Round 4 restated round 3's stamp-checker gap verbatim; the gap is already owned and needs no second owner."
evidence: "Same gap as D00-T04-S12-F12, filed to `D00 T04 §21` item 2 in `2ccce2d`", recorded as duplicate of F12; see the F12 transition above.
as-of: ef362d6

transition: D00-T04-S16-F3
date: 2026-09-20
from: raised
to: duplicate
why: "The §16 Done evidence reintroduces it", the bare-counts pattern S15-PR4 already decided: Done notes quote candidate-time drives, bound outputs ride the stamp's Live proof.
evidence: "placeholders mark pre-commit unknowns honestly; exact bound outputs ride the stamp's Live proof", quoted from the S15-PR4 ledger row in docs/reviews/00-workspace/D00-T04-s15.md; the §16 instance matches the decided shape, so the rejection stands as the rule.
as-of: 6002a21
