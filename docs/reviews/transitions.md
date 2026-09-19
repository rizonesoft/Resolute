# Outcome transitions

One block per finding whose disposition is refuted, withdrawn, duplicate, or routed: final states deserve a sentence, but a finding that ends anywhere other than fixed or filed keeps its when, why, and evidence, quoted from the record that decided it. Checked by `scripts/todo-findings.py --check`: every non-final ledger row has exactly one block, every block names a live row, and the block's `to` agrees with the row's disposition.

transition: D00-T04-S6-F3
date: 2026-09-19
from: raised
to: refuted
why: "writes are serial (one session owns the tree, so two reviews of one tree cannot run), a local symlink planter is outside every threat model this repo states, and the same `/tmp` shape is used by every panel command in the skill by design, so fixing one command would be incoherent."
evidence: "The sign-off round accepted the refutation and did not re-report." Scope note, quoted from the §9 record: "another session's contract rode the shared `/tmp` path" — the cross-session variant, outside the one-tree scope above, which §9 closed with per-run directories.

transition: D00-T03-S4-F3
date: 2026-09-17
from: raised
to: routed
why: "`TODO.md` devotes three phases and 51 mentions to hosting Control Panel applets" while "`git grep -i \"\\.cpl\"` over `todo/` returned **nothing**, so the Resolute plan has no coverage at all", and "whether the launcher should host third-party DLLs in its own elevated process is a product judgement, not an implementation detail."
evidence: "Filed as a decision on `D03 T01 §4` rather than as work" (target resolves: Windows System Locations), since "That section already plans to *open* Control Panel items by CLSID through the shell".

transition: D07-T01-S1-F2
date: 2026-09-17
from: raised
to: routed
why: "That layout is owned by `D01 T01 §9`, which has not shipped. Stalling was not an option and guessing would have put a second, drifting copy of the layout in this document."
evidence: "So **standalone-ness is stated as behaviour and names no paths**" with "The cost is written down in both places", routed to `D01 T01 §9` in `a73addf` (resolves: Standalone Proof in an Empty Folder).
