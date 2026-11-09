---
schema_version: 1
id: au3-maintenance
domain: 09-au3-maintenance
status: draft
title: "TODO-01 -- AutoIt Suite Maintenance"
depends_on: []
track: M1
---

# TODO-01 -- AutoIt Suite Maintenance

> **Goal:** The AutoIt suite keeps working and keeps shipping for as long as the C++ rewrite takes, without becoming a second development effort. It is the specification and it is the product users currently have, and both of those need it to stay intact.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** The AutoIt suite is at `resolute_au3/` and ships today. `Distro` and the AutoIt `SDK/` go with it: `Distro` is the `.sni` builder that CMake, Ninja, and the release scripts replace, and `SDK/` becomes frozen specification rather than maintained code. Neither is ported and neither has a C++ successor. It did **not** build from a clean checkout: all thirteen `.sni` descriptors hardcoded `R:\Workspace\Resolute\...`, a directory that no longer exists. **Corrected 2026-11-09 (D09 T01 §1):** the descriptors now carry descriptor-relative paths and `Distro` persists and resolves them relatively, so the suite builds from a clean checkout; the build proof is recorded in §1. `SDK/Concrete/Rescue/` held only a `Distribution/338/` build output with no source, left behind when that tool was removed (deleted in D09 T01 §2). `SDK/Concrete/BiosCodes/Includes/Localization.au3.backup` was a stray file (removed in D09 T01 §2). `ReBar` declared a product page at `downloads/resolute/` although it is internal tooling (cleared in D09 T01 §2, Distro's with it). Framework-first sequencing means this suite ships for a long time yet, so it needs an owner rather than a freeze.
>
> <!-- claim: count "R:.Workspace.Resolute" resolute_au3/SDK/Concrete/*/*.sni = 0 -->
> <!-- claim: absent resolute_au3/SDK/Concrete/Rescue/Rescue.au3 -->
> <!-- claim: absent resolute_au3/SDK/Concrete/BiosCodes/Includes/Localization.au3.backup -->

## Inputs

- [`resolute_au3/SDK/Concrete/`](../../resolute_au3/SDK/Concrete) -- the shipping AutoIt suite
- [`resolute_au3/todo/README.md`](../../resolute_au3/todo/README.md) -- the archived AutoIt plan, superseded, kept for its per-tool analysis
- -> XREF: [`04-tools-port/TODO-01 §1`](../04-tools-port/TODO-01-tool-ports.md) -- the ports that retire these tools one by one

## Outcome

- The AutoIt suite builds from a clean checkout, so a fix can actually be shipped.
- Its known housekeeping defects are cleared.
- The scope of what will and will not be fixed here is written down.
- A tool is retired from this domain the day its C++ port ships.

**Adjacency:** list=not-applicable (maintenance holds no records a user browses); document=applicable @ D09 T01 §3; settings=not-applicable (no new settings surface is added to a suite being replaced); reporting=not-applicable (the suite's own reporting is frozen); notifications=not-applicable (nothing new notifies here); permissions=not-applicable (the suite's elevation behavior is frozen as-is); audit=not-applicable (git history is the audit for maintenance); exchange=not-applicable (nothing new is imported or exported); reverse=not-applicable (maintenance changes nothing on a user's system beyond what the suite already did)

**Adjacency rationale:** Almost everything here is not-applicable because this domain deliberately adds no capability: it keeps a suite alive that is being replaced. Document anchors on §3 because the one thing this domain genuinely owes is a written scope, so that a request to fix something in the AutoIt tree has a documented answer rather than a case-by-case one.

## Implementation Order

| Order | Section | Deliverable                                | Depends On   | Status |
| :---: | :-----: | ------------------------------------------ | ------------ | :----: |
|   1   |   §1    | Make the AutoIt suite buildable again      | --           |  [x]   |
|   2   |   §2    | Clear the housekeeping defects             | --           |  [x]   |
|   3   |   §3    | Maintenance scope and retirement procedure | §1           |  [x]   |
|   4   |   §4    | Distro reports compiler failure           | --           |  [x]   |
|   5   |   §5    | Stop logging the signing password in Distro | --           |  [ ]   |
|   6   |   §6    | Per-tool update URLs from Distro          | --           |  [ ]   |

---

## 1. Make the AutoIt Suite Buildable Again

> **Started:** 2026-11-09T10:33:21Z

A shipping product that cannot be built from its own repository cannot be fixed. This is first because everything else in this domain assumes a build exists.

**Needs:** Windows host (build/test)

- [x] Replace the hardcoded `R:\Workspace\Resolute\...` paths in all thirteen `.sni` descriptors with repository-relative equivalents, anchored at each descriptor's own directory. Done when: no descriptor under `resolute_au3/SDK/Concrete/*/*.sni` contains an absolute path, checked rather than eyeballed, and every one of the 91 rewritten values resolves from its descriptor directory to the intended target (the script beside it, `..\..\Resources\Icons\<Tool>.ico`, `..\..\..\Resolute\<Tool>.exe`, `Distribution\<build>\...`), with inputs and output destinations preserved.
- [x] Fix the writer that recreates the problem: `Distro` discovery (`resolute_au3/SDK/Concrete/Distro/Distro.au3` lines 1432 to 1515) writes absolute `[Environment]` paths on every scan. Done when: discovery persists the same descriptor-relative values, the `[Environment]` load resolves non-absolute values against the descriptor's directory at its one chokepoint, and a discovery-and-readback check over a copied descriptor proves the stored values stay relative and resolve. Cheaper substitute that fails the checkpoint: rewriting the thirteen files only, which the next Distro scan silently undoes.
- [x] Note the scope, measured 2026-09-16: **the `#AutoIt3Wrapper_` directives are already repository-relative and correct.** `Resolute.au3` emits to `..\..\..\Resolute.exe`, which resolves to `resolute_au3/Resolute.exe` after the move, and the tool scripts emit to `..\..\..\Resolute\<Tool>.exe`, which resolves into `resolute_au3/Resolute/`. Only the `.sni` descriptors carry absolute paths. Done when: this section confirms the directives were checked and left alone, so the fix is scoped to the descriptors rather than to every script.
- [x] Prove a clean-checkout build. Done when: a fresh clone into a different absolute path builds all thirteen tools to both architectures with no file edited, the path is recorded, and any tool that fails is repaired at the descriptor or builder layer before this section completes (a tool's frozen behavior is not changed to make it compile). **Both architectures is correct here** and is not the stale phrase `D00 T01 §4` removed from the C++ side: all thirteen descriptors set `CompileBoth=Y`, so the AutoIt suite really does ship a 32-bit and a 64-bit binary.
  -> XREF: D00 T01 §4 -- the C++ side's clean-checkout proof, and the path-length limit this one will meet

  > [!IMPORTANT]
  > **The clone path has to be short, and this is where that bites hardest.** `D00 T01 §4` proved the C++ tree at `R:\\resolute-cleancheck` and hit `Filename too long` on the first attempt. The longest tracked path in the repository is **165 characters** and every one of the worst offenders is under `resolute_au3/samples/`, which this domain owns. Against Windows' 260-character limit that leaves roughly 95 characters for the clone root, so a clone into a deep directory fails at **checkout**, before any build is attempted. Either keep the root short or set `git config core.longpaths true` on the clone.
- [x] Record which tools build and which do not. Done when: all thirteen are attempted at both architectures and the result per tool and architecture is recorded here.

  **Build record 2026-11-09 (clean clone `R:\resolute-cleancheck` at `702b8a7b`, AutoIt3Wrapper per descriptor directives, no file edited):** BiosCodes x86+x64 built; Chromin x86+x64 built; ComIntRep x86+x64 built; DVDRepair x86+x64 built; Edgemin x86+x64 built; Firemin x86+x64 built; MemBoost x86+x64 built; Ownership x86+x64 built; PixRepair x86+x64 built; ReBar x86+x64 built; Resolute x86+x64 built (outputs `resolute_au3\Resolute.exe`, `resolute_au3\Resolute_X64.exe`); USBRepair x86+x64 built; Watermin x86+x64 built. All thirteen descriptor tools built to both architectures. `Distro` itself also built x86+x64 (outputs `resolute_au3\SDK\Distro.exe`, `resolute_au3\SDK\Distro_X64.exe`); it has no `.sni` descriptor because it is the builder. Discovery-and-readback check over a copied descriptor at `R:\scratch\copied\BiosCodes`: stored `ScriptPath=BiosCodes.au3`, `Icon=..\Resources\Icons\BiosCodes.ico`, `OutFilePath=..\Resolute\BiosCodes.exe`, `DistributionPath=Distribution\338`, all relative, all resolving through the shipped `_ResolveDescriptorPath`; failures=0. **Corrected 2026-11-09 (completion review on `504f9c80`):** that harness wrote four keys by hand and did not run discovery. The executed discovery proof is the repair run below. Repair proof 2026-11-09: the shipped `Distro_X64.exe` built from `abb2e920` ran in the fresh clone `R:\resolute-repaircheck`; `BiosCodes.sni` was seeded with absolute `R:\Workspace\Resolute\...` `ScriptPath` and `Icon` values, and Distro's own startup discovery rewrote them to `BiosCodes.au3` and `..\..\Resources\Icons\BiosCodes.ico`. After discovery, all thirteen descriptors hold zero absolute `[Environment]` values, and all 91 values (thirteen tools times seven path keys) resolve from their descriptor directories with script and icon targets present (checker: checked=91, failures=0). The failed-read regression also ran against the shipped load block verbatim (`Distro.au3` lines 1849 to 1862 extracted unchanged): a missing descriptor file survives, the read error is captured, and the processing guard is not entered (exit 0). One qualification on the build record above: 'no file edited' means no preparatory manual edit; AutoIt3Wrapper updates version directives in the tool sources as part of compiling (the first clone shows fourteen modified `.au3` files after the build), which is the wrapper's normal behaviour on the shipped suite. Repair proofs added 2026-11-09 (repair plan review): all seven keys for all thirteen descriptors were compared against their exact intended destinations (script beside the descriptor, `..\..\Resources\Icons\<Tool>.ico`, `..\..\..\Resolute\<Tool>.exe` and `_X64`, Resolute itself to `resolute_au3\Resolute.exe`, distribution paths under `Distribution\<build>\`), in the shipped tree and in the discovery clone: 91 checks, 0 failures each. The resolver's UNC and root-relative cases run as exact-result assertions in the helper harness: they fail against the pre-repair resolver (exit 2) and pass against the repaired one (exit 0). The cleanup path ran with the shipped `_StartProcessing`, failed-read load block, and `_EndProcesssing` extracted verbatim over real GUI controls: controls disabled during processing, read error captured, list and Process button enabled again afterwards (exit 0). A cross-root path kept absolute now also writes a WARNING through Distro's visible logging (`_Logging_EditWrite`), not only the console. Repair2 proofs 2026-11-09: in a fresh clone at `R:\resolute-repair2`, every descriptor's seven `[Environment]` keys were seeded with sentinel values before Distro ran; Distro's own discovery replaced all of them, and all 91 values match destinations derived from a pre-build snapshot of each script's `#AutoIt3Wrapper_Res_Fileversion` (with the suite's own readback rule from `AutoIt3Script.au3`: AutoIncrement with First_Increment unset reads back build minus one): 91 checks, 0 failures, no sentinel left. The complete shipped `_ProcessSelectedSolution` ran verbatim in a harness over real GUI controls with the descriptor file missing: the read was attempted (a sentinel global came back as the failed read's scalar), the read error was captured (`readerror=1` in a diagnostic copy), no build operation was invoked, and `_EndProcesssing` re-enabled the solutions list and the Process button (exit 0). Removing the processing call from the harness makes the same predicate fail (read attempted=False), so the proof cannot pass on a skipped run. One correction to how this path reads: a failed read produces no dialog in the shipped code (the nearby `MsgBox` belongs to the not-enough-values branch); processing is silently skipped and cleanup runs, which is what the harness asserts. Repair3 proofs 2026-11-09: the lifecycle assertions now sit inside the processing invocation: `_SetAllOptionStates` and `_SetModules` are stubbed as tripwires that only the shipped `_StartProcessing` and `_EndProcesssing` call, and the predicate requires both to have fired during `_ProcessSelectedSolution(0)`; removing either lifecycle call from a harness copy makes the predicate fail (both flags False). The compiled cross-root run also completed: with `PortableEdition=0`, the shipped `Distro_X64.exe` moved its Concrete directory to `C:\Users\DerickPayne\AppData\Roaming\Rizonesoft\Distro\Concrete` (its own notice dialog names the move), discovery ran with the thirteen descriptors on `C:` and the icon targets on `R:`, all thirteen descriptors kept their absolute `R:` `Icon` values, and Distro's own log records `Warning: No descriptor-relative form for R:\resolute-repair2\resolute_au3\SDK\Resources\Icons\<Tool>.ico (different root); absolute path kept.` for each. The cross-root warning ran through the shipped `_Logging_EditWrite`: a `C:` descriptor base against an `R:` icon target kept the absolute path and wrote the WARNING line to Distro's log file (exit 0).
- [x] Commit: `"au3: make the autoit suite build from a clean checkout"`

**Test checkpoint:** No descriptor under `resolute_au3/SDK/Concrete/*/*.sni` contains an absolute path and all 91 values resolve from their descriptor directories, proven by check (the six descriptors under `resolute_au3/samples/` are out of scope and named as such). A fresh clone into a different absolute path builds all thirteen tools to both architectures with no file edited, and that path is quoted. The per-tool, per-architecture build result is recorded for all thirteen. The measured claim in the Current state block is updated in the same commit and `python scripts/todo-claims.py` holds.

> **Verified:** 2026-11-09 | §1 | No descriptor under `resolute_au3/SDK/Concrete/*/*.sni` contains an absolute path and all 91 values resolve from their descriptor directories (checker: checked=91, failures=0; exact destinations 91/91 in two trees). Fresh clone `R:\resolute-cleancheck` at `702b8a7b` built all thirteen tools to both architectures with no preparatory edit; per-tool record in this section. Distro discovery proven end to end (seeded absolute values rewritten relative by the shipped program; sentinels in a second clone all replaced, destinations matching a pre-build Fileversion snapshot 91/91). Failed-read path and cross-root warning executed (harness exits 0; retained readbacks and warnings under `docs/captures/d09-t01-s1-crossroot/`, checker tools=13 failures=0). `python scripts/todo-claims.py`: 116 hold, 0 stale. `python scripts/todo-graph.py validate`: 0 fatal.
> **Review:** rounds 1-3 on the base record (round 3 clean), repair rounds 1-2 (round 2 clean), repair2 rounds 1-2 (round 2 clean), repair3 rounds 1-2 (round 2 clean), repair4 round 1 clean, astra (`gpt-6-astra` via `codex`), candidates 319dca04(round 1) to b7950553(repair4 round 1) · Raw findings: docs/reviews/09-au3-maintenance/D09-T01-s1.md, D09-T01-s1-repair.md, D09-T01-s1-repair2.md, D09-T01-s1-repair3.md, D09-T01-s1-repair4.md
> **Completion:** astra (medium), candidate b79505535d575bec31cf1e13cca8767689fb94fb -- COMPLETION: complete · Repair records: D09-T01-s1-repair (candidate 1b4aecfa), D09-T01-s1-repair2 (candidate c918af7b), D09-T01-s1-repair3 (candidate 611d3e85), D09-T01-s1-repair4 (candidate b7950553)
> **Plan review:** astra (medium) -- six gaps folded into the section before building (record D09-T01-s1.md); repair, repair2, repair3 and repair4 plan passes each returned gaps that were dispositioned and closed in their cycles
> **CRUD:** not applicable (no records are created, read, updated or deleted for a user; the change is build descriptors and their one loader)
> **Resolved:** Distro compiler-failure propagation -> XREF: D09 T01 §4 (shipped 2026-11-09)
> **Deferred:** Signing password written to the Distro log -> XREF: D09 T01 §5
> **Duration:** 2026-11-09T10:33:21Z to 2026-11-09T12:04:46Z
> **Implementer:** muse (muse-wonder-1.0)

## 2. Clear the Housekeeping Defects

> **Started:** 2026-11-09T12:10:08Z

Small, known, and cheap. Each is recorded so it is not rediscovered later as a mystery.

- [x] Remove `resolute_au3/SDK/Concrete/Rescue/`, which holds only build output for a tool that no longer has source. Done when: the directory is gone and the removal is recorded here. **Corrected 2026-11-09:** the directory is untracked, ignored build output (`.gitignore` covers `**/SDK/Concrete/*/Distribution/`), so its removal is a recorded working-tree deletion, not a commit. **Corrected 2026-11-09 (plan review):** the commit that removed the tool does exist under the pre-move path: `e9b62590` (Remove Rescue application and Bin directory) deletes `SDK/Concrete/Rescue/Rescue.au3`, its descriptor and includes; today's cleanup removes only the ignored output that commit left behind.
- [x] Remove `resolute_au3/SDK/Concrete/BiosCodes/Includes/Localization.au3.backup`. Done when: it is gone, the measured claim in the Current state block flips from `exists` to `absent` in the same commit, and `python scripts/todo-claims.py` holds.
- [x] Clear the internal tools' product page URLs, since they are internal tooling rather than products. Done when: neither `ReBar.au3` nor `Distro.au3` advertises the Resolute product download page: both `$g_sUrlProgPage` values take the company home page form their own `HomePage` fields use, `ReBar`'s `$g_sUrlUpdate` fallback and the tracked `resolute_au3/SDK/www/update/ReBar.ru` `UpdateURL` take the same form, and the About destination (`SDK/Includes/About.au3` ShellExecute on `$g_sUrlProgPage`) and the update destination (`SDK/Includes/Update.au3:98`, the `.ru` `UpdateURL` overriding the fallback) are both verified by readback. The one producer that would rewrite `ReBar.ru` on a future Distro run (`Distro.au3:3305` writes every tool's `UpdateURL` from Distro's own global) is filed separately, not fixed here. -> XREF: D09 T01 §6
- [x] Decide whether `resolute_au3/samples/Resources/` should be tracked. Done when: the decision is recorded here and acted on. **Corrected 2026-11-09:** it is already tracked (180 files, tracked since the suite move `71caa37b`), so the open decision is whether to keep it tracked, not whether to start. Decision recorded 2026-11-09: keep it tracked, because the sample tools are source examples whose icon and resource references must resolve from a clean checkout; untracking would break the samples to save repository size this project has not asked to save.
- [x] Commit: `"au3: clear the known housekeeping defects"`

**Build record 2026-11-09:** fresh clone `R:\resolute-housecheck` at `4e1ce4b2`, AutoIt3Wrapper per tool, both architectures: BiosCodes, Chromin, ComIntRep, DVDRepair, Edgemin, Firemin, MemBoost, Ownership, PixRepair, ReBar, USBRepair, Watermin each created x86 and x64 outputs with no failed lines; Distro created `resolute_au3\SDK\Distro.exe` and `Distro_X64.exe`; Resolute created `resolute_au3\Resolute.exe` and `Resolute_X64.exe`. Same coverage and success as §1. `Rescue/` and `Localization.au3.backup` are absent from the clone, as they are from this tree. Exit-code record 2026-11-09 (repair): the run was repeated in fresh clone `R:\resolute-housecheck2` at `2721e559` (the implementation candidate `4e1ce4b2` plus only TODO and review-record changes: `git diff 4e1ce4b2..2721e559` touches `todo/09-au3-maintenance/TODO-01-au3-maintenance.md` and `docs/reviews/09-au3-maintenance/D09-T01-s2.md`, so the built sources are identical) with the command `AutoIt3.exe AutoIt3Wrapper.au3 /in <Tool>.au3` per tool from its descriptor directory; every wrapper process exited 0 and created both architecture outputs (14 tools including Distro, 28 programs): BiosCodes 0, Chromin 0, ComIntRep 0, Distro 0, DVDRepair 0, Edgemin 0, Firemin 0, MemBoost 0, Ownership 0, PixRepair 0, ReBar 0, Resolute 0, USBRepair 0, Watermin 0.

**Test checkpoint:** `Rescue/` and the stray `.backup` file are absent. `ReBar` and `Distro` advertise no product download page, in their About and update destinations alike (verified by readback of both call sites). The `samples/Resources/` decision is recorded and acted on. After the changes, a fresh clone at the final candidate builds all thirteen tools to both architectures (the §1 coverage), with candidate, command and exit results recorded here; 'unchanged' means the same coverage succeeding, and AutoIt3Wrapper's version-directive increments during compilation are expected, as §1 recorded.

> **Verified:** 2026-11-09 | §2 | `Rescue/` and `Localization.au3.backup` absent from this tree and from the proof clones (Test-Path). `ReBar` and `Distro` advertise no product download page in About or update destinations (readback of `About.au3` and `Update.au3:98` call sites; `ReBar.ru` now `https://rizonesoft.com/`). Post-change build: fresh clone `R:\resolute-housecheck2` at `2721e559` (implementation `4e1ce4b2` plus document-only changes), wrapper command per tool recorded, all 14 wrapper processes exit 0, 28 programs created. `python scripts/todo-claims.py`: 116 hold, 0 stale. `python scripts/todo-graph.py validate`: 0 fatal.
> **Review:** round 1 clean on the base record, repair round 1 clean, astra (`gpt-6-astra` via `codex`), candidates 2721e559(round 1) and 0fe682ef(repair round 1) · Raw findings: docs/reviews/09-au3-maintenance/D09-T01-s2.md, D09-T01-s2-repair.md
> **Completion:** astra (medium), candidate 0fe682ef -- in-scope gaps closed (build command and exits recorded; Current state corrected); the one remaining item is out of scope and filed at §6 · Repair records: D09-T01-s2-repair (candidate 0fe682ef)
> **Plan review:** astra (medium) -- five gaps folded into the section before building (record D09-T01-s2.md); repair plan pass returned one P3, corrected in the candidate
> **CRUD:** not applicable (housekeeping deletions and URL values; no user records)
> **Deferred:** Distro writes every tool's UpdateURL from its own global -> XREF: D09 T01 §6
> **Duration:** 2026-11-09T12:10:08Z to 2026-11-09T12:27:51Z
> **Implementer:** muse (muse-wonder-1.0)

## 3. Maintenance Scope and Retirement Procedure

> **Started:** 2026-11-09T12:30:23Z

Without a written scope, every request to fix something in the AutoIt tree is argued from scratch, and the rewrite quietly becomes two projects.

- [x] Write the scope: what will be fixed here, what will not, and why. Done when: it states that only defects affecting users of the shipping suite are in scope, and that the conformance campaign is not. Buildability of the suite (§1) and release-security defects in the builder (§5) are named in scope as well, and enhancements are routed to the tool's C++ port or, for a capability no port has, through `add-todo` to the domain that will own it in C++, never built in AutoIt.
- [x] State explicitly that `resolute_au3/` is otherwise read-only, because it is the specification the ports are measured against. Done when: the statement is here and `AGENTS.md` agrees with it.
- [x] Write the retirement procedure: what happens to an AutoIt tool the day its C++ port ships. Done when: the procedure gives a concrete disposition for the update file, the download page, and the source, names who performs and who verifies each, names `D06 T01 §5` as the owner of the announcement, and distinguishes a same-name replacement (the C++ successor keeps the tool's name) from a consolidation (the tool folds into another product).
- [x] Cover the tools that retire with **no successor**, which is a different case. Done when: `Distro` and `ReBar` are both named. `Distro` is the AutoIt `.sni` builder and is replaced by CMake, Ninja, and the release scripts rather than ported, so it ends when the last AutoIt tool does. `ReBar` does not retire so much as become the C++ framework, and AutoIt ReBar changes end when the C++ framework ships its first tool port; its source stays as specification afterwards. Neither gets a consolidation announcement, because neither had users to announce to.
- [x] Record what `Distro` contributed before it goes. Done when: this section notes that its `.sni` module model, meaning the Portable, Installation, and UpdateFile flags, is what `D06 T01 §1` reproduces as declarative release descriptors, so the concepts survive even though the tool does not. The claim is reconciled with `D06 T01 §1` as written: its Outcome carries the portable edition and the generated update file; reproducing the flag model is the recorded intent this section states, not a contract `D06 T01 §1`'s checklist spells out flag for flag.
- [x] Decide and record how a defect found in the AutoIt tree that also affects the port is handled. Done when: the answer is dated, says which tree gets fixed first, states that a correction may never change a frozen tool's system effect and how a request that would do so is resolved, and assigns the port-side correction and its parity verification to an owner.
- [x] Commit: `"au3: maintenance scope and the retirement procedure"`


### The scope, written 2026-11-09

In scope for this domain, and nothing else:

- A defect that affects users of the shipping AutoIt suite: wrong behaviour, a crash, a broken download or update path. The fix lands in the AutoIt tree, because that is what users run today.
- The suite's buildability: descriptors, the builder, and anything that stops a clean checkout compiling (§1).
- Release-security defects in the builder: credentials, signing, and update metadata (§5 is the standing example).
- Housekeeping that keeps the tree honest: orphan output, stray files, wrong metadata (§2).

Out of scope:

- The conformance campaign. Comparing the trees belongs to D07; this domain does not run it.
- Enhancements. A request to make an AutoIt tool do something new goes to the tool's C++ port. For a capability no port has yet, it is filed through `add-todo` to the domain that will own it in C++, and it is never built in AutoIt. Building it here is how the rewrite quietly becomes two projects.
- The frozen behaviours. What `Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair` and `BiosCodes` compute and write does not change here, for any reason short of the operator deciding otherwise in writing.

`resolute_au3/` is otherwise read-only, because it is the specification the ports are measured against; changing it changes what the port is measured against. `AGENTS.md` says the same, and the two must not drift: this section is the long form, `AGENTS.md` is the standing rule.

### Retirement procedure

The day a tool's C++ port ships, its AutoIt counterpart retires. Three things have a disposition, each with a performer and a verifier:

- **Update file.** For a same-name replacement, the tool's `.ru` (and `.ruz` preview feed) on the update server is replaced by the C++ release's update file in the same step as the release, so an AutoIt user is offered the successor, not silence. For a consolidation, the retired tool's update file carries a final announcement release pointing at the consolidating product, and that terminal announcement feed is retained, not deleted: a user who was offline for the announcement cycle still reaches the successor when they next check. `D06 T01 §5` owns the retention. `D06 T01 §5` owns update files and the announcement; this domain hands it the retirement date and verifies the file that lands by reading it back.
- **Download page.** For a same-name replacement, the page stays and now serves the C++ build. For a consolidation, the page is replaced by the announcement and a pointer to the consolidating product; it is not left advertising a download that no longer exists. The release work under D06 performs the change; this domain verifies the page no longer offers the AutoIt download.
- **Source.** The AutoIt source stays in `resolute_au3/` as specification. It is not deleted, and it receives no further changes except through this domain for a defect that still affects users who have not upgraded. This domain performs the retirement marking: on the release day it marks the tool retired in the tool's TODO file, and it verifies its own marking by readback (the marker is present, the source tree is untouched, and the tool's parity claims still resolve). The release work under D06 performs the update-file and download-page changes above; this domain verifies those by the same readback. Parity keeps measuring against it, which is why it stays.

A tool with no successor is a different case. `Distro` ends when the last AutoIt tool retires: it is replaced by CMake, Ninja and the release scripts, it is never ported, and nobody announces it because nobody outside this project runs it. `ReBar` becomes the C++ framework in `src/framework/`; AutoIt ReBar changes end when the framework ships its first tool port, and its source stays as specification afterwards. Neither gets a consolidation announcement, because neither had users to announce to.

What `Distro` contributed survives it: the per-tool `.sni` descriptor whose module switches (`Distribute`, `Portable`, `Installation`, `UpdateFile`) declare what a release contains. `D06 T01 §1` is where the C++ release descriptors reproduce those ideas declaratively (portable by construction, generated update files), so the concepts carry over even though the tool does not.

### Shared-defect policy, decided 2026-11-09

A defect found in the AutoIt tree that also affects the C++ port is fixed in AutoIt first when users of the shipping suite are affected, because that is the tree they run. The port-side correction is filed the same day to the section that owns the behaviour in C++, with the AutoIt fix named as its source, and it is verified by the parity proof that port owes (D07). If the only correct fix would change a frozen tool's system effect, the AutoIt side does not change: the effect is the specification. The request is recorded here with the reason, the port implements the decided behaviour, and the operator is named as the only authority who can move a frozen effect.

**Test checkpoint:** The scope states what is in and out with a reason. `AGENTS.md` and this section agree that `resolute_au3/` is otherwise read-only. The retirement procedure covers update file, download page, and source, naming its owner. The shared-defect policy is dated.

> **Verified:** 2026-11-09 | §3 | The scope, retirement procedure, and shared-defect policy are written in this section (scope text, Retirement procedure, policy dated 2026-11-09) and read back against their checkpoints: scope in/out with reasons including buildability and release-security; AGENTS.md line 137 and the section state the same read-only rule; procedure dispositions cover update file (.ru/.ruz, terminal feed retained), download page, and source, each with performer and verifier and D06 T01 §5 as announcement owner; Distro contribution reconciled with D06 T01 §1. `python scripts/todo-graph.py validate`: 0 fatal. `python scripts/todo-claims.py`: 116 hold, 0 stale.
> **Review:** rounds 1-3 on the base record (round 3 clean), repair round 1 clean, astra (`gpt-6-astra` via `codex`), candidates cb1539e5(round 3) and 853d9042(repair round 1) · Raw findings: docs/reviews/09-au3-maintenance/D09-T01-s3.md, D09-T01-s3-repair.md
> **Completion:** astra (medium), candidate 853d90428d31ed5a666d21367e0eeb1d6066cf4c -- COMPLETION: complete · Repair records: D09-T01-s3-repair (candidate 853d9042)
> **Plan review:** astra (medium) -- four gaps folded into the section before writing (record D09-T01-s3.md); repair plan pass clean
> **CRUD:** not applicable (the section writes policy prose; no records change hands)
> **Duration:** 2026-11-09T12:30:23Z to 2026-11-09T12:38:54Z
> **Implementer:** muse (muse-wonder-1.0)


## 4. Distro Reports Compiler Failure

> **Started:** 2026-11-09T12:45:33Z

`D09 T01 §1` proved the suite builds, but `Distro` itself cannot currently say so: `_BuildSelected` drains the compiler's output without checking its result, then emits its final message and sets progress to 100, and batch processing continues into downstream operations. A failed compile therefore looks like success to the person shipping a fix. This is builder behaviour, not a tool's frozen behaviour, so it is in scope for this domain.

-> SOURCE: D09 T01 §1 completion review on `504f9c80`, gap 4 (missing-out-of-scope)
-> XREF: D09 T01 §1 -- the clean-checkout build this makes trustworthy from inside Distro

- [x] Make `_BuildSelected` (`resolute_au3/SDK/Concrete/Distro/Distro.au3`) check the compiler result for each architecture it invokes, and return the verdict. Done when: the wrapper output is accumulated for the whole invocation; per-architecture success is decided from that invocation's own compiler results (the `Aut2exe.exe ended... rc:N` line and the `Created program:` line for each expected output, expected outputs read from the script's `#AutoIt3Wrapper_OutFile`, `#AutoIt3Wrapper_OutFile_X64` and `#AutoIt3Wrapper_Compile_both` directives the way discovery reads them at `Distro.au3:1451`) plus verification that each expected output was newly produced by this invocation (modification time at or after the build start, so a retained binary from an earlier build cannot mask a failure); the wrapper process exit value is captured reliably and preserved into a variable before any other call can overwrite it (never read after unrelated calls, and a sentinel or unreadable value counts as failure, not success); and any missing per-architecture result, any failed architecture, or a nonzero wrapper exit makes the solution verdict false even when old binaries exist. A nonzero compiler exit is recorded as a failure for that solution and architecture, naming the tool, instead of being drained and discarded.
- [x] Give every non-compile failure an explicit false verdict. Done when: the missing-script branch, the missing AutoIt/wrapper branch (`Distro.au3:1948-1975`, which already logs the missing component), and a failed `Run` of the wrapper each return false and suppress downstream operations; the report names the actual missing component or the launch error, and no compiler exit value is invented for a compilation that never started.
- [x] Stop the success path on failure. Done when: after a failed compile, Distro does not emit its final success message and does not continue into compress, sign, or distribute operations for it: in the Process flow (Case 99, `Distro.au3:1892-1900`), when Build was among the checked actions and its verdict is false, every downstream checked action for that solution is skipped.
- [x] Complete the failure UI without the success percentage. Done when: a failed build leaves its running state through a failure-completion path separate from the progress-100 call (the error icon, red cell colour, checkbox and standalone cleanup that `_UpdateSoloProcess` at `Distro.au3:3353-3378` currently performs only inside its 100 branch), the progress bar is never drawn to 100 for the failed solution, and a successful build's messages, progress and terminal handling are unchanged.
- [x] Report the failure where the operator looks. Done when: the failure appears in Distro's status list and log as one `ERROR` line per failed architecture naming the tool, the architecture and the compiler's exit value, in the existing logging format (so the existing error counter, error final message and red cell follow from it), and a successful build's messages and progress are unchanged.
- [x] Prove both directions, downstream gate included. Done when, in a clone with retained old binaries in place: a seeded broken script (syntax error) driven through Distro's Process action with downstream actions checked is reported failed per architecture with no success message, the failure never reaches progress 100, and downstream artifacts are read back unchanged; a partial failure (one architecture failing while the other succeeds, for example the x64 output locked against overwrite) is reported for the failed architecture only and still fails the solution; and an unmodified tool driven the same way builds, reports success, and both expected outputs are verified as produced by that invocation, not merely present.
- [x] Commit: `"au3: report compiler failure in Distro"`

**Test checkpoint:** Driven run with evidence: in a clone, a seeded syntax-error script driven through Distro's Process action with downstream actions checked is reported failed (status and log quoted, per architecture), never reaches progress 100, and its downstream artifacts read back unchanged; a one-architecture failure against retained old binaries is reported for that architecture; a clean tool still reports success with both outputs verified fresh from that invocation. `Au3Check.exe -q Distro.au3` exits 0. No tool's frozen behaviour changes.

> **Verified:** 2026-11-09 | §4 | In clone R:\resolute-s4check (Distro rebuilt from the candidate, driven through its GUI Process action on BiosCodes with Build, Compress and Create Update File checked): clean run logs "Finished: Finished building Beep Codes Viewer." with both outputs created fresh and downstream sections running; seeded syntax error with retained outputs logs one "Build failed for 'Beep Codes Viewer' (<arch>): no compiler result was reported for this architecture." per architecture and "Finished with (17) errors!", no downstream sections, and BiosCodes.exe, BiosCodes_X64.exe and SDK\www\update\BiosCodes.ru hashes and mtimes identical before and after; x64 output path replaced by a directory logs only "(x64): the expected output was not created" with downstream gated. The missing-wrapper repair was proven by a harness executing the shipped branch segment verbatim (both present selects the run path, AutoIt missing the AutoIt message, wrapper missing the wrapper-path message); the rename-the-installed-wrapper run was denied by the Program Files ACL in this non-elevated session. `Au3Check.exe -q Distro.au3` exits 0. `python scripts/todo-graph.py validate`: 0 fatal. `python scripts/todo-claims.py`: 116 hold, 0 stale.
> **Review:** rounds 4-5 on the base record (rounds 1-3 returned no valid verdict and do not count; round at position 1 found one P2, fixed in b4b529d6; round at position 2 clean), repair round 1 clean, astra (`gpt-6-astra` via `codex`), candidates b4b529d6 (position 2) and 50e8a90e (repair round 1) · Raw findings: docs/reviews/09-au3-maintenance/D09-T01-s4.md, D09-T01-s4-repair.md
> **Completion:** astra (medium), candidate b4b529d6d00e8e416708d34604216cc3a0ae06cb: COMPLETION: gaps (one missing-in-scope item), closed by the repair record · Repair records: D09-T01-s4-repair (candidate 50e8a90e0f9790a6d1c02c9beccb155e546223e0, COMPLETION: complete)
> **Plan review:** astra (medium): five gaps folded into the section before writing (record D09-T01-s4.md); repair plan pass clean
> **CRUD:** not applicable (the builder reports build results; no records change hands)
> **Duration:** 2026-11-09T12:45:33Z to 2026-11-09T13:15:47Z
> **Implementer:** muse (muse-wonder-1.0)


## 5. Stop Logging the Signing Password in Distro

> **Started:** 2026-11-09T13:21:12Z

`_RunSignCommand` (`resolute_au3/SDK/Concrete/Distro/Distro.au3`) masks the certificate password on one line (`Password: ******`) and then writes the full signing command, which contains `/p <password>` in plain text, to Distro's log on the next. The log is the file a maintainer attaches to a bug report, so the password reaches wherever the log goes. This predates `D09 T01 §1`; that section's repair completion review found it. No credential value was read while filing this.

-> SOURCE: D09 T01 §1 repair completion review on `1b4aecfa`, Part 2 item 1 (out-of-scope)
-> XREF: D09 T01 §1 -- the section whose review found this

- [x] Remove the password from the logged command. Done when: the log line for the signing command shows the command shape with the password masked (the same mask as the `Password:` line), and the real command passed to `_ProcessEx_RunCommand` is unchanged.
- [x] Search Distro and its includes for any other place a password or certificate secret reaches a log, a console line, or a command-line echo. Done when: every hit is listed here and either fixed the same way or named as not a secret with its reason.
- [x] Prove it. Done when: a driven `_RunSignCommand` with a dummy password writes a log containing the mask and not the dummy password, quoted from the log. The readback must show the complete masked `Command:` line (deleting the command log entirely does not pass, because the `Password:` line alone already contains a mask), and the harness must assert exactly one `_ProcessEx_RunCommand` invocation whose command and working directory are byte-for-byte identical to what the pre-change function passes with identical dummy inputs. The function is extracted from the reviewed candidate by script, and the regression test is retained under `docs/captures/d09-t01-s5-signing/`, failing against the pre-change source and passing against the candidate.
- [x] Record the tracked signing files' disposition. Done when: this section states whether the tracked `resolute_au3/SDK/Signing/` files (`Signing.ini`, `Rizonesoft(test).pfx`, `Rizonesoft(test).cer`, `create.cmd`, `sign.cmd`) are intentional public test fixtures and where operational credentials belong, established without recording any credential value (a boolean comparison or a certificate subject readback, never the value).
- [x] Commit: `"au3: stop logging the signing password in Distro"`

**Disposition of the tracked signing files, recorded 2026-11-09:** the tracked files under `resolute_au3/SDK/Signing/` split in two. `create.cmd`, `sign.cmd`, `Rizonesoft(test).cer` and `Rizonesoft(test).pfx` are an intentional public test fixture: `create.cmd` generates the certificate with `makecert.exe -r` (self-signed), its subject and issuer are both `CN=Rizonesoft.com(Test)` (read back 2026-11-09, valid 2017 to 2040), and the password in the tracked `sign.cmd` sample opens that `.pfx` (verified by boolean import test only). `Signing.ini` is different: its `Password` value does not open the test `.pfx` and does not match the `sign.cmd` sample (both verified by boolean tests only, no value recorded), so it is treated as an operational certificate password sitting in a tracked file, which AGENTS.md forbids (credentials are supplied to the build from outside the repository). Removing it from the working tree does not remove it from git history, and rotating it is a credential action for the operator, so this section does not touch it: the exposure is recorded here and filed to `D06 T01 §3`, which already owns the release-side requirement that no credential appears in any tracked file, for removal and rotation with the operator. Operational credentials belong outside tracked files; the test fixture stays tracked so the signing path remains exercisable, and it is never the operational certificate.

**Test checkpoint:** Driven run with evidence: the Distro log from a signing run with a dummy password contains `******` and does not contain the dummy password, the complete masked `Command:` line is quoted, and the executed command and working directory are byte-for-byte the pre-change ones, proven by the retained regression test under `docs/captures/d09-t01-s5-signing/` (fails on the pre-change source, passes on the candidate). The signing command that executes is unchanged. `Au3Check.exe -q Distro.au3` exits 0.


## 6. Per-Tool Update URLs from Distro

Every tool declares its own update destination, but `Distro`'s `_CreateUpdateFiles` (`resolute_au3/SDK/Concrete/Distro/Distro.au3:3305`) writes every tool's `UpdateURL` from Distro's own `$g_sUrlUpdate` global, so all tools' `.ru` files name the one suite update directory regardless of what the tool declares. For the product tools that happens to be near enough to go unnoticed; for an internal tool it re-advertises the product update page that `D09 T01 §2` cleared from the tracked metadata. The producer should write the producing tool's declared update destination, the way the rest of the update file is per-tool data.

-> SOURCE: D09 T01 §2 plan review on `c4dd27db`, gap 2 (producing configuration)
-> XREF: D09 T01 §2 -- the housekeeping section that cleared the tracked metadata this producer would rewrite

- [ ] Make `_CreateUpdateFiles` take the update destination from the producing tool's own declaration (its script globals as discovery reads them, or a descriptor value discovery persists), not from Distro's global. Done when: the written `UpdateURL` differs per tool exactly as the tools declare, and Distro's own global is no longer the source.
- [ ] Regenerate or correct the tracked `resolute_au3/SDK/www/update/*.ru` files from the corrected producer. Done when: each `.ru` `UpdateURL` matches its tool's declaration, verified per tool.
- [ ] Prove it. Done when: a driven update-file creation for two tools with different declared update destinations writes two different, correct `UpdateURL` values, quoted from the files.
- [ ] Commit: `"au3: write per-tool update URLs in Distro"`

**Test checkpoint:** Driven run with evidence: two tools' `.ru` files carry their own declared `UpdateURL` values. `Au3Check.exe -q Distro.au3` exits 0. No tool's frozen behaviour changes.

## Verification

- [ ] The AutoIt suite builds from a clean checkout at a different absolute path
- [ ] No `.sni` descriptor contains an absolute path
- [ ] The known housekeeping defects are cleared
- [ ] The maintenance scope is written and `AGENTS.md` agrees with it
- [ ] `python scripts/todo-graph.py validate` clean
