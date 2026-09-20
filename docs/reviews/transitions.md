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

transition: D00-T04-S17-F2
date: 2026-09-20
from: raised
to: refuted
why: "The item's quoted string is the message core; the parenthetical is the section address": every section ship commit appends the ref parenthetical, so the appended ` (D00 T04 §17)` follows convention rather than breaking the item.
evidence: "`c33cb6e` 'workspace: blinded-run checker defects (D00 T04 §16)'" and "`d0b5690` 'workspace: run-record vocabulary and evidence follow-ups (D00 T04 §15)'", quoted from the commit subjects; no panel has flagged the shape.
as-of: 0cffc14

transition: D00-T04-S19-F2
date: 2026-09-20
from: raised
to: refuted
why: "the matcher was mirror-exact with parse_todo (same opener test, same lowercase-x done test), so no disagreement existed; the panel never saw the parser."
evidence: "one checklist_state called by both parser and rule, so drift is impossible rather than tested-for, with 4 semantic pins", landed in 1cfd083; "zero live [X] occurrences, grepped 2026-09-20" for the uppercase residue.
as-of: 1cfd083

transition: D00-T04-S21-F10
date: 2026-09-20
from: raised
to: duplicate
why: "Round-1 A2 restates F4 (filed to D00 T04 §24 before round 1): a pasted-but-unrun PASS still attests. No new defect; the §24 item owns it."
evidence: "Same checker-evidence gap as D00-T04-S21-F4, filed to `D00 T04 §24` in `81c4fd78`", recorded as duplicate of F4; see the §24 item carrying the Done and checkpoint clause.
as-of: 68e77a1

transition: D00-T04-S21-F16
date: 2026-09-20
from: raised
to: duplicate
why: "Round-2 R restates F4 a third time (independent F4, round-1 A2): a forged PASS still attests while item 4's Done reads complete. The Done names the residual and its owner since R1; the item's letter is met and run-witnessing is the filed strengthening. No new defect."
evidence: "Same checker-evidence gap as D00-T04-S21-F4", recorded as duplicate of F4; the §24 item owns run-witnessing.
as-of: 4be7d03

transition: D00-T04-S21-F17
date: 2026-09-20
from: raised
to: refuted
why: "Honest flows cannot produce it (fence titles are skill-fixed keys; paths never enter `titles=`); a forger who can inject titles can forge `commits=` directly, gaining no privilege; garbage claims fail closed downstream (unresolvable or uncovered, exit 1). No exploitable defect."
evidence: "a forger who can inject titles can forge `commits=` directly, gaining no privilege", quoted from the F17 record; mechanics confirmed, conclusion refuted.
as-of: 26e0612e

transition: D00-T04-S21-F18
date: 2026-09-20
from: raised
to: duplicate
why: "Round-3 A2 restates F4 a fourth time. The panel acknowledges the D00 T04 §24 filing and asks for more; the §24 item owns run-witnessing. No new defect."
evidence: "Same checker-evidence gap as D00-T04-S21-F4", recorded as duplicate of F4.
as-of: 26e0612e

transition: D00-T04-S21-F35
date: 2026-09-20
from: raised
to: refuted
why: "Round-5 R2 reads the §24 debt item's 'seven stale evidence cites' against its six enumerated paths and calls the enumeration one short. Re-driven: the sweep fires 7 failure lines over 6 paths (`cpp-env.ps1` cited twice, D00 T01 §1 lines 152 and 155), so the count was always cites, not paths, and the enumeration is complete."
evidence: "The count stands; the item now reads 'seven stale evidence cites over six paths' with the double cite named", clarified in 624a83b; the F35 record carries the re-drive.
as-of: da5a00a4

transition: D00-T04-S22-F7
date: 2026-09-20
from: raised
to: refuted
why: "Round-2 R1 reads the record's `Attestation:` line as a claim that the attest file exists mid-review. The skill emits the attestation only after step 9 completes (stamp written, `Live proof` quoted, ledger regenerated), because attesting earlier binds bytes a later step rewrites; creating the file mid-review to satisfy the reading would fabricate evidence. The line is a locator for the owed file, not an existence claim."
evidence: "That is the skill's own ordering, not a defect", the F7 record carries the refutation; as-of binds the round-2 fix commit, the state the refutation reads.
as-of: 3b7ed181
