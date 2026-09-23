RECEIPT sha=104a5018207aaeefb54a67d8f8743c10496cbe34827422f31f0468c44465e7ea end=PANEL-519295f1f1d63675 nonce=4d2e628355daefb4

**adversarial: approve**

**consistency: needs-attention (1)**
1. scripts/todo-runs.py:1260 — the conflict message ends `pass exactly one`, which contradicts the usage string it prints on the same line (`[--check] [--report | --export]`, both optional) and the code at scripts/todo-runs.py:1309, where neither flag is the default summary mode; the wrong rule is carried verbatim into the section's evidence at todo/00-workspace/TODO-04-self-correction.md:735 (`--report and --export conflict, pass exactly one` quoted as the driven output).

**integration: approve**

**record: needs-attention (2)**
1. docs/reviews/run-records.md:305-306 — the `#` note enumerates three stamp attempts while the round line carries a single `cost: 132909tokens latency: 424s`, and nothing on either line says the figures belong to the HOLDS attempt rather than the three-attempt total; the contract requires "the HOLDS attempt's model/effort/cost/latency", so the record as written does not distinguish the two readings.
2. docs/reviews/run-records.md:305 — `provenance: reconstructed` points a reader at "the review file and the run file's stamp record", but the review file docs/reviews/00-workspace/D00-T04-s15.md stops at stamp attempt 2 under the HOLDS-tree rule and holds neither 132909tokens nor 424s, and the run file docs/phase-runs/2026-09-20-phase-0.md is untracked at this candidate, so the reconstructed figures resolve to no committed source in the repository.
