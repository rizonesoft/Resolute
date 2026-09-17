---
schema_version: 1
id: quality-bar
domain: 07-quality
status: draft
title: "TODO-01 -- The Quality Bar"
depends_on: []
track: Q1
---

# TODO-01 -- The Quality Bar

> **Goal:** "Done" is a checklist a machine can run, not an opinion. The conformance profile says what a tool must be, the conformance check proves it per tool, and the ratchet makes sure the numbers only move one way.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Nothing here exists. This domain runs **early**, not late: the profile is what every tool is built against and what every intake is measured against, so it is a dependency of the framework's acceptance rather than a review of finished work. The AutoIt suite is the evidence for why: with no written bar, seven tools stored settings in a language-pack file, six wrote no log, four had no documentation directory, and four had no language pack, and none of that was visible as a defect because nothing said it should be otherwise. **Corrected 2026-09-17 by `§1`:** this read "five had no language pack". Re-measured, `resolute_au3/Resolute/Language/` holds ten tool directories plus `BuildSystem/`, so **four** of the fourteen tools have none: `Chromin`, `Edgemin`, `Watermin`, `Distro`. That is the same four the brainstorm record itself names, next to the figure five, and the three it then lists separately, `MemBoost`, `Ownership` and `Resolute`, have a pack containing English only. Four with none and three with one is the measurement; five with none was never true.

## Inputs

- [`docs/brainstorm/2026-09-16-completion-brainstorm.md`](../../docs/brainstorm/2026-09-16-completion-brainstorm.md) -- the measured conformance matrix the profile is derived from
- -> XREF: [`00-workspace/TODO-01 §3`](../00-workspace/TODO-01-toolchain-and-gates.md) -- the tidy baseline this domain ratchets
- -> XREF: [`01-framework/TODO-01 §1`](../01-framework/TODO-01-framework-core.md) -- the framework the profile mostly describes consuming correctly
- -> XREF: [`01-framework/TODO-02 §1`](../01-framework/TODO-02-design-system.md) -- the design contract the conformance check enforces
- -> XREF: [`00-workspace/TODO-04 §2`](../00-workspace/TODO-04-self-correction.md) -- the findings ledger, which is the ratchet idea applied to review rather than to code

## Outcome

- A written profile that says what a finished tool is, in terms a check can evaluate.
- A check that runs the profile against every tool and fails by name.
- A ratchet on warnings and static-analysis findings that only goes down.
- A standing smoke run over the whole suite.

**Adjacency:** list=applicable @ D07 T01 §3; document=applicable @ D07 T01 §1; settings=not-applicable (the quality tooling owns no user-facing settings); reporting=applicable @ D07 T01 §3; notifications=not-applicable (a local check notifies nobody); permissions=not-applicable (no role model in a developer gate); audit=applicable @ D07 T01 §2; exchange=not-applicable (nothing imports or exports here); reverse=not-applicable (a check changes nothing that needs undoing)

**Adjacency rationale:** Document anchors on §1 because the profile is the one artifact in this domain a person reads rather than runs, and a bar nobody can read is a bar nobody meets. Audit anchors on §2 because the ratchet is the project's memory of its own quality: the baseline file is the record that makes a regression visible rather than arguable.

## Implementation Order

| Order | Section | Deliverable                            | Depends On   | Status |
| :---: | :-----: | -------------------------------------- | ------------ | :----: |
|   1   |   §1    | The conformance profile                | --           |  [ ]   |
|   2   |   §2    | Warning and analysis ratchet           | D00 T01 §3   |  [ ]   |
|   3   |   §3    | Conformance check and its report       | §1           |  [ ]   |
|   4   |   §4    | Standing smoke run over the suite      | §3           |  [ ]   |

---

## 1. The Conformance Profile

> **Started:** 2026-09-17T18:57:58Z

The document every other domain is measured against. It runs first because a bar written after the work is a description, not a standard.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. One count corrected, one open decision resolved with a recorded default, and an unfalsifiable checkpoint rewritten.**
>
> **The measured defect classes are eight, not seven, and one of the counts was wrong.** Every figure below was re-measured against `resolute_au3/` today rather than read from the brainstorm record, and the enumeration is what item 6 now maps clauses to:
>
> | # | Measured defect | Count | Measured by |
> | :-: | --- | :-: | --- |
> | 1 | Settings written into a `.lng` language-pack file | 7 of 14 | tools carrying `.lng` and no `.ini` string literal |
> | 2 | No logging at all | 6 of 14 | tools with no `Includes\Logging.au3` include |
> | 3 | No documentation set | 4 of 14 | directories absent from `resolute_au3/Resolute/Docs/` |
> | 4 | No language pack | **4** of 14 | directories absent from `resolute_au3/Resolute/Language/` |
> | 5 | Language pack naming and casing inconsistent | `zh-tw` against 3 x `zh-TW`; one `sv.ini` among `.lng` | listing every pack file |
> | 6 | DPI disabled | 14 of 14 | the existing `Res_HiDpi=N` claim, which holds |
> | 7 | Nothing ships signed | `Compress=0` 13/13, `Sign=0` 13/13, `SignInstall=0` 12/12 | every `.sni` |
> | 8 | Copyright year hand-typed and divergent | 4 distinct years across 14 tools | `Res_LegalCopyright` per script |
>
> **Two measured defects are deliberately NOT clauses**, stated here so a later reader does not think they were missed. The broken clean checkout, every `.sni` hardcoding `R:\Workspace\Resolute\...`, is a build-system defect owned by `D00 T01 §4` rather than something a tool can conform to. And the dead `SDK/Concrete/Rescue/` directory is housekeeping, owned by `D09 T01`.
>
> **Physical evidence for clause 2, found while measuring:** `resolute_au3/Resolute/Logging/` contains both `Ownership/` and `Ownerhip/`. A misspelled runtime directory sits beside the correct one because the logging path was typed by hand in fourteen places, which is the same root cause as seven tools writing settings to `.lng`. A clause that says "through the shared writer" is what makes that impossible rather than unlikely.
>
> **The open decision this section was told to wait for is resolved by scope, not by deciding it.** The brainstorm record says the standalone on-disk layout "needs reconciling **before** the conformance profile is written", because the profile has to assert where a standalone tool finds its own files. That layout is owned by `D01 T01 §9`, which has not shipped. Stalling was not an option and guessing the layout would have put a second, drifting copy of it in this document.
>
> So **the profile states standalone-ness as behaviour, never as paths**: a built tool alone in an empty directory starts, localizes, shows About, and checks for updates. That clause is true under the suite layout and under the `Doors/` layout both, so whichever `D01 T01 §9` chooses, this document does not need rewriting. **Cost of this default:** the profile cannot be used to check that a tool put its files in the agreed place, only that it works without anything outside its folder. `D01 T01 §9` owns closing that gap and `D07 T01 §3` owns checking it.
> -> XREF: D01 T01 §9 -- the standalone layout this profile deliberately does not name
>
> **The checkpoint could not fail and is rewritten.** It asked that the profile "states every clause in evaluable terms" and that a mapping "is quoted", both of which a careless author satisfies by asserting them. The profile is now a **parseable table** and `scripts/profile-check.py` evaluates it, so a clause with no owner, an owner that does not resolve to a real section, a clause not marked evaluable, or a measured defect class with no clause covering it each fail by name.

- [x] Write the profile covering: consumes the framework, no private settings or log or localization code, settings in an `.ini` through the shared writer, one log line per action, every surface string from a pack, a documentation set, an update short name and file, an About page, DPI correct at four scalings, both appearances, and standalone in an empty folder. Done when: every clause is stated so that a check could evaluate it.
  **Done 2026-09-17.** [`docs/conformance-profile.md`](../../docs/conformance-profile.md) carries **32 clauses**, 24 universal and 8 repair-only, each one a table row with a `Method` from a closed set of seven, an `Evidence` cell naming what is looked at, and an `Owner` section. Every item on the list above is a clause: framework consumption `C01`, no private settings, log or localization code `C02` `C04` `C06`, settings through the shared writer `C03`, one log line per action `C05`, strings from a pack `C07`, a documentation set `C09`, update short name and file `C10`, About `C11`, four scalings `C12`, both appearances `C13`, standalone `C14`. **"Evaluable" is mechanical rather than asserted**: a clause whose method is not in the closed set fails the check by name.
- [x] Adopt [`DESIGN.md`](../../DESIGN.md) by reference rather than restating it. Done when: the profile names the contract as the source for every visual and interaction clause, and the check evaluates against it. Cheaper substitute: copying the design rules into the profile, which creates a second record that drifts.
  **Done 2026-09-17.** `C17` adopts the contract by reference and the profile restates no value from it. The cheaper substitute is not merely avoided, it is **made impossible**: `scripts/profile-check.py` scans the whole document, prose included, and fails on any hex colour or pixel size. Driven, a planted accent and gutter produced two named failures.
- [x] Add the clauses that apply only to a repair tool: consumes the repair contract, records prior state, verifies by read-back, and has a reverse or says it does not. Done when: the profile distinguishes the two tool kinds.
  **Done 2026-09-17.** `C25` to `C33` in their own table, each `Kind: repair`, covering the contract `C25`, diagnose first `C26`, prior state `C27`, read-back verification `C28`, a reverse or a stated reason there is none `C29`, one log line per action and per refusal `C30`, elevation checked at the action `C31`, a carryable transcript `C32`, and `C33`, that every write outside the tool's own folder is a **declared repair target and nothing else**, added by the independent review. The check fails if either kind has no clauses, so the distinction cannot quietly collapse. The profile also says **why** the split exists: a tool that reads and reports owes none of this, and holding it to a restore record it has no use for makes a profile people argue with rather than meet.
- [x] Require standalone-ness explicitly. Done when: the profile states that a built tool alone in an empty directory must start, localize, show About, and check for updates.
  **Done 2026-09-17.** `C14` states exactly that, `C15` adds that it writes nothing outside its own folder, and `C16` adds that it needs no sibling tool and no suite-wide file at runtime. All three are stated as **behaviour and name no paths**, which is what lets this document survive whichever layout `D01 T01 §9` chooses. The cost of that is written in the profile rather than left to be discovered.
- [x] Make each clause cite its owner section. Done when: every clause names the section that implements it, so a failure has an address.
  **Done 2026-09-17.** All 32 clauses carry an owner, across **23 distinct sections** in five domains. And the address is real rather than well-formed: the check resolves every owner through `todo-graph.py resolve`, the same front door the skills use, so a clause pointing at a section that does not exist fails by name. Driven: `D08 T01 §77` was refused. This is the `§4` lesson of `D00 T02` applied deliberately, that a reference in valid form pointing at nothing reads as an address and is not one.
- [x] Derive the profile from the measured AutoIt gaps rather than from taste. Done when: each of the **eight** measured defect classes maps to a clause that would have caught it. **Corrected 2026-09-17:** this read "seven", a figure that appears nowhere in the source it points at. The brainstorm record lists ten bullets under "Defects found while measuring", of which one is explicitly not a defect, two are not per-tool conformance defects, and the remaining eight are the classes tabled above. The count is derived rather than quoted, and `scripts/profile-check.py` fails if any of the eight has no clause.
  **Done 2026-09-17.** All eight map, and the mapping is **printed by the check** rather than asserted in prose: `D1 -> C02, C03` · `D2 -> C04, C05` · `D3 -> C09` · `D4 -> C07, C08` · `D5 -> C08` · `D6 -> C12` · `D7 -> C21` · `D8 -> C22`. A defect citing a clause that is not in the profile fails by name, driven by renaming `C21`.
- [ ] Commit: `"quality: the conformance profile"`

**Test checkpoint:** `python scripts/profile-check.py` passes against `docs/conformance-profile.md` and is driven to **fail** in each of its four ways: a clause with no owner, an owner reference that does not resolve to a real section, a clause not stated in evaluable terms, and a measured defect class no clause covers. Every one of the eight measured AutoIt defect classes maps to at least one clause, printed by the check rather than asserted in prose. The profile distinguishes universal clauses from repair-tool clauses, requires standalone-ness as behaviour, and adopts `DESIGN.md` by reference with no design value restated. All outputs quoted.

**Corrected 2026-09-17:** the previous checkpoint asked that clauses be "stated in evaluable terms" and that a mapping "is quoted", which a careless author satisfies by asserting both. Every clause of it is now something a script decides.

## 2. Warning and Analysis Ratchet

**Needs:** C++ toolchain (compile)

The compiler side of this is already at zero: `D00 T01 §3` fixed all 13 warnings rather than baselining them, so `-Werror` is on with nothing suppressed and there is no compiler-warning baseline to ratchet. What this section ratchets is the **analysis** count, `todo/.tidy-baseline`, which starts at 169. **Corrected 2026-09-17 by `§1`:** this read 59, the figure on the day `D00 T01 §3` wrote the file. The baseline has since been raised twice with attribution recorded in it, 59 to 103 when `RegStudio` came under analysis and 103 to 169 when the toolchain moved to clang 23 and new checks fired, and the file itself is the authority rather than this sentence.
-> XREF: D00 T01 §3 -- the gate and the baseline this section ratchets

> [!IMPORTANT]
> **Read `todo/.tidy-baseline` before writing the counter.** It records the exact reproduction procedure, and two traps that produce a plausible wrong number rather than an error. The second one already cost `D00 T01 §3` a round: `clang-analyzer` checks are spelled `clang-analyzer-security.ArrayBound`, with uppercase letters and dots, so a check-name character class of `[a-z0-9.-]+` silently drops every analyzer finding. That is how the baseline was first recorded as 52 instead of 59.

- [ ] Record the per-target baseline for compiler warnings and static-analysis findings. Done when: the baseline file exists and the combined gate compares against it. **The analysis baseline already exists** at `todo/.tidy-baseline`, written by `D00 T01 §3` at 59; this item adds the per-target split and the comparison.
- [ ] Make the ratchet one-way. Done when: a count above the baseline fails, a count equal passes, and a count below rewrites the baseline down in the same commit.
- [ ] Report which target regressed, not just that something did. Done when: a deliberate regression names the target and the finding.
- [ ] Prevent a silent baseline raise. Done when: raising a baseline requires an explicit recorded reason and the check names it.
- [ ] Commit: `"quality: a ratchet that only goes down"`

**Test checkpoint:** A count above the baseline fails and names the target and finding. A count equal passes. A count below rewrites the baseline down. A raise without a recorded reason is refused. All four quoted.

## 3. Conformance Check and Its Report

- [ ] Implement the check so it evaluates the profile against every shipped tool. Done when: it produces one row per tool per clause.
- [ ] Fail by name. Done when: a tool missing a documentation set is named with the clause it failed and the section that owns it.
- [ ] Check that **no repair has two homes**. Done when: every repair-contract item declared anywhere in the suite is checked for a duplicate subject in another tool, and a deliberate duplicate fails the check by name. This is the settings-path defect in a new place: one repair in two tools diverges the first time either is touched.
- [ ] Decide whether the release build must be **reproducible**, and record the decision either way. **Filed 2026-09-17 by `D00 T03 §3`, which measured it:** two consecutive clean builds of identical sources produced `Lucide.dll` at `8B25CFEE72714F28` and `08C187347BF55A19`, the same size both times. Nothing in the tree asks for reproducibility today, so this is not yet a defect, but it has two concrete costs. A signed release cannot be independently confirmed to come from the tagged source, which matters for a suite of system utilities that run elevated. And byte-comparison is unavailable as a verification instrument, which `D00 T03 §3` discovered when its own checkpoint asked for it and had to fall back to comparing exported symbols. Done when: the decision is dated, states whether reproducibility is wanted, and if it is, names the mechanism, most likely `-Wl,--no-insert-timestamp` plus `-ffile-prefix-map` for embedded paths, with a check that builds twice and compares. Cheaper substitute that fails the checkpoint: declaring the build reproducible because the sizes match, which is exactly the evidence that turned out not to mean it.
- [ ] Enforce a **per-tool size budget**, because the suite's size claim is a product promise and an unchecked promise decays. Done when: each tool's executable is measured at release, compared against a recorded budget, and a tool exceeding it fails the check by name. **Measure the shipped set, not the executable.** Corrected 2026-09-17: the `release` preset currently produces `Resolute.exe` at 1,381,376 bytes **plus** `System/ExoUI.dll` and `System/Lucide.dll`, 4,074,176 bytes in total, because the UI libraries are declared `SHARED`. `D00 T01 §2` owns making the default build static; until it does, a budget measured on the executable alone would report 1.32 MiB for a tool that actually ships 3.9 MB.
- [ ] Report the whole-suite total alongside it. Done when: the release report states the per-tool sizes and their sum, so the claim can be stated from measurement rather than estimate.
- [ ] Record what the budget buys. Done when: this section states that a competing suite of roughly twenty tools commonly exceeds 200 MB, so the comparison the claim rests on is written down rather than assumed.
- [ ] Check the **source layout** declared in `AGENTS.md` still holds. Done when: no file under `src/framework/` or `src/repair/` was added by a tool, no tool carries a file that belongs to a shared layer, and a deliberate violation fails the check by name. Cheaper substitute: trusting review, which is how a shared layer acquires a tool-specific special case.
- [ ] Include the standalone clause by actually running the tool in an empty directory. Done when: a tool that reaches outside its folder fails the check, proven by a deliberate regression.
- [ ] Make the report readable as a matrix. Done when: the full report renders as tools by clauses and is quoted here.
- [ ] Wire it into the combined gate. Done when: a conformance failure fails `scripts/check-all.ps1`.
- [ ] Commit: `"quality: the conformance check"`

**Test checkpoint:** The check produces a tool-by-clause matrix, quoted. A tool missing a documentation set is named with its clause and owner section. A tool that writes outside its folder fails the standalone clause. A conformance failure fails the combined gate.

## 4. Standing Smoke Run Over the Suite

- [ ] Drive every shipped tool through start, main surface, About, preferences, and exit. Done when: every tool is covered and a crash in any one is reported without stopping the run.
- [ ] Capture each tool's main surface on every run. Done when: the capture set is produced and compared against the previous run.
- [ ] Report the run as one artifact. Done when: a full run produces a single report naming every tool and its result, quoted.
- [ ] Make a smoke failure actionable. Done when: a failure names the tool, the step, and the captured state at failure.
- [ ] Commit: `"quality: a standing smoke run over the whole suite"`

**Test checkpoint:** A full smoke run covers every shipped tool through five steps each and produces one report, quoted. A deliberately broken tool is reported without stopping the run, naming tool, step, and captured state.

## Verification

- [ ] The conformance profile states every clause in evaluable terms with an owner per clause
- [ ] `pwsh scripts/check-all.ps1` includes the conformance check and the ratchet
- [ ] Every shipped tool passes every clause of the profile, or has a recorded exception
- [ ] A smoke run covers every shipped tool and produces one report
- [ ] `python scripts/todo-graph.py validate` clean
