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
> **Current state (verified 2026-09-16):** The AutoIt suite is at `resolute_au3/` and ships today. `Distro` and the AutoIt `SDK/` go with it: `Distro` is the `.sni` builder that CMake, Ninja, and the release scripts replace, and `SDK/` becomes frozen specification rather than maintained code. Neither is ported and neither has a C++ successor. It did **not** build from a clean checkout: all thirteen `.sni` descriptors hardcoded `R:\Workspace\Resolute\...`, a directory that no longer exists. **Corrected 2026-11-09 (D09 T01 §1):** the descriptors now carry descriptor-relative paths and `Distro` persists and resolves them relatively, so the suite builds from a clean checkout; the build proof is recorded in §1. `SDK/Concrete/Rescue/` holds only a `Distribution/338/` build output with no source, left behind when that tool was removed. `SDK/Concrete/BiosCodes/Includes/Localization.au3.backup` is a stray file. `ReBar` declares a product page at `downloads/resolute/` although it is internal tooling. Framework-first sequencing means this suite ships for a long time yet, so it needs an owner rather than a freeze.
>
> <!-- claim: count "R:.Workspace.Resolute" resolute_au3/SDK/Concrete/*/*.sni = 0 -->
> <!-- claim: absent resolute_au3/SDK/Concrete/Rescue/Rescue.au3 -->
> <!-- claim: exists resolute_au3/SDK/Concrete/BiosCodes/Includes/Localization.au3.backup -->

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
|   1   |   §1    | Make the AutoIt suite buildable again      | --           |  [ ]   |
|   2   |   §2    | Clear the housekeeping defects             | --           |  [ ]   |
|   3   |   §3    | Maintenance scope and retirement procedure | §1           |  [ ]   |
|   4   |   §4    | Distro reports compiler failure           | --           |  [ ]   |

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

  **Build record 2026-11-09 (clean clone `R:\resolute-cleancheck` at `702b8a7b`, AutoIt3Wrapper per descriptor directives, no file edited):** BiosCodes x86+x64 built; Chromin x86+x64 built; ComIntRep x86+x64 built; DVDRepair x86+x64 built; Edgemin x86+x64 built; Firemin x86+x64 built; MemBoost x86+x64 built; Ownership x86+x64 built; PixRepair x86+x64 built; ReBar x86+x64 built; Resolute x86+x64 built (outputs `resolute_au3\Resolute.exe`, `resolute_au3\Resolute_X64.exe`); USBRepair x86+x64 built; Watermin x86+x64 built. All thirteen descriptor tools built to both architectures. `Distro` itself also built x86+x64 (outputs `resolute_au3\SDK\Distro.exe`, `resolute_au3\SDK\Distro_X64.exe`); it has no `.sni` descriptor because it is the builder. Discovery-and-readback check over a copied descriptor at `R:\scratch\copied\BiosCodes`: stored `ScriptPath=BiosCodes.au3`, `Icon=..\Resources\Icons\BiosCodes.ico`, `OutFilePath=..\Resolute\BiosCodes.exe`, `DistributionPath=Distribution\338`, all relative, all resolving through the shipped `_ResolveDescriptorPath`; failures=0. **Corrected 2026-11-09 (completion review on `504f9c80`):** that harness wrote four keys by hand and did not run discovery. The executed discovery proof is the repair run below. Repair proof 2026-11-09: the shipped `Distro_X64.exe` built from `abb2e920` ran in the fresh clone `R:\resolute-repaircheck`; `BiosCodes.sni` was seeded with absolute `R:\Workspace\Resolute\...` `ScriptPath` and `Icon` values, and Distro's own startup discovery rewrote them to `BiosCodes.au3` and `..\..\Resources\Icons\BiosCodes.ico`. After discovery, all thirteen descriptors hold zero absolute `[Environment]` values, and all 91 values (thirteen tools times seven path keys) resolve from their descriptor directories with script and icon targets present (checker: checked=91, failures=0). The failed-read regression also ran against the shipped load block verbatim (`Distro.au3` lines 1849 to 1862 extracted unchanged): a missing descriptor file survives, the read error is captured, and the processing guard is not entered (exit 0). One qualification on the build record above: 'no file edited' means no preparatory manual edit; AutoIt3Wrapper updates version directives in the tool sources as part of compiling (the first clone shows fourteen modified `.au3` files after the build), which is the wrapper's normal behaviour on the shipped suite. Repair proofs added 2026-11-09 (repair plan review): all seven keys for all thirteen descriptors were compared against their exact intended destinations (script beside the descriptor, `..\..\Resources\Icons\<Tool>.ico`, `..\..\..\Resolute\<Tool>.exe` and `_X64`, Resolute itself to `resolute_au3\Resolute.exe`, distribution paths under `Distribution\<build>\`), in the shipped tree and in the discovery clone: 91 checks, 0 failures each. The resolver's UNC and root-relative cases run as exact-result assertions in the helper harness: they fail against the pre-repair resolver (exit 2) and pass against the repaired one (exit 0). The cleanup path ran with the shipped `_StartProcessing`, failed-read load block, and `_EndProcesssing` extracted verbatim over real GUI controls: controls disabled during processing, read error captured, list and Process button enabled again afterwards (exit 0). A cross-root path kept absolute now also writes a WARNING through Distro's visible logging (`_Logging_EditWrite`), not only the console.
- [x] Commit: `"au3: make the autoit suite build from a clean checkout"`

**Test checkpoint:** No descriptor under `resolute_au3/SDK/Concrete/*/*.sni` contains an absolute path and all 91 values resolve from their descriptor directories, proven by check (the six descriptors under `resolute_au3/samples/` are out of scope and named as such). A fresh clone into a different absolute path builds all thirteen tools to both architectures with no file edited, and that path is quoted. The per-tool, per-architecture build result is recorded for all thirteen. The measured claim in the Current state block is updated in the same commit and `python scripts/todo-claims.py` holds.

## 2. Clear the Housekeeping Defects

Small, known, and cheap. Each is recorded so it is not rediscovered later as a mystery.

- [ ] Remove `resolute_au3/SDK/Concrete/Rescue/`, which holds only build output for a tool that no longer has source. Done when: the directory is gone and the removal names the commit that removed the tool.
- [ ] Remove `resolute_au3/SDK/Concrete/BiosCodes/Includes/Localization.au3.backup`. Done when: it is gone.
- [ ] Clear `ReBar`'s product page URL, since it is internal tooling rather than a product. Done when: it no longer advertises a download page.
- [ ] Decide whether `resolute_au3/samples/Resources/` should be tracked; it is 180 files and has never been. Done when: the decision is recorded and acted on.
- [ ] Commit: `"au3: clear the known housekeeping defects"`

**Test checkpoint:** `Rescue/` and the stray `.backup` file are absent. `ReBar` advertises no download page. The `samples/Resources/` decision is recorded and acted on. The tree builds unchanged afterwards.

## 3. Maintenance Scope and Retirement Procedure

Without a written scope, every request to fix something in the AutoIt tree is argued from scratch, and the rewrite quietly becomes two projects.

- [ ] Write the scope: what will be fixed here, what will not, and why. Done when: it states that only defects affecting users of the shipping suite are in scope, and that the conformance campaign is not.
- [ ] State explicitly that `resolute_au3/` is otherwise read-only, because it is the specification the ports are measured against. Done when: the statement is here and `AGENTS.md` agrees with it.
- [ ] Write the retirement procedure: what happens to an AutoIt tool the day its C++ port ships. Done when: the procedure covers the update file, the download page, and the source, and names `D06 T01 §5` as the owner of the announcement.
- [ ] Cover the tools that retire with **no successor**, which is a different case. Done when: `Distro` and `ReBar` are both named. `Distro` is the AutoIt `.sni` builder and is replaced by CMake, Ninja, and the release scripts rather than ported, so it ends when the last AutoIt tool does. `ReBar` does not retire so much as become the C++ framework. Neither gets a consolidation announcement, because neither had users to announce to.
- [ ] Record what `Distro` contributed before it goes. Done when: this section notes that its `.sni` module model, meaning the Portable, Installation, and UpdateFile flags, is what `D06 T01 §1` reproduces as declarative release descriptors, so the concepts survive even though the tool does not.
- [ ] Decide and record how a defect found in the AutoIt tree that also affects the port is handled. Done when: the answer is dated, and says which tree gets fixed first.
- [ ] Commit: `"au3: maintenance scope and the retirement procedure"`

**Test checkpoint:** The scope states what is in and out with a reason. `AGENTS.md` and this section agree that `resolute_au3/` is otherwise read-only. The retirement procedure covers update file, download page, and source, naming its owner. The shared-defect policy is dated.


## 4. Distro Reports Compiler Failure

`D09 T01 §1` proved the suite builds, but `Distro` itself cannot currently say so: `_BuildSelected` drains the compiler's output without checking its result, then emits its final message and sets progress to 100, and batch processing continues into downstream operations. A failed compile therefore looks like success to the person shipping a fix. This is builder behaviour, not a tool's frozen behaviour, so it is in scope for this domain.

-> SOURCE: D09 T01 §1 completion review on `504f9c80`, gap 4 (missing-out-of-scope)
-> XREF: D09 T01 §1 -- the clean-checkout build this makes trustworthy from inside Distro

- [ ] Make `_BuildSelected` (`resolute_au3/SDK/Concrete/Distro/Distro.au3`) check the compiler result for each architecture it invokes. Done when: a nonzero compiler exit is recorded as a failure for that solution and architecture, naming the tool, instead of being drained and discarded.
- [ ] Stop the success path on failure. Done when: after a failed compile, Distro does not emit its final success message, does not set progress to 100 for that solution, and does not continue into compress, sign, or distribute operations for it.
- [ ] Report the failure where the operator looks. Done when: the failure appears in Distro's status list and log with the compiler's exit value, in the existing logging format, and a successful build's messages and progress are unchanged.
- [ ] Prove both directions. Done when: a seeded broken script (syntax error) driven through Distro is reported as failed with no success message, and an unmodified tool still builds and reports success.
- [ ] Commit: `"au3: report compiler failure in Distro"`

**Test checkpoint:** Driven run with evidence: a seeded syntax-error script is reported failed by Distro (status and log quoted) and a clean tool still reports success. `Au3Check.exe -q Distro.au3` exits 0. No tool's frozen behaviour changes.

## Verification

- [ ] The AutoIt suite builds from a clean checkout at a different absolute path
- [ ] No `.sni` descriptor contains an absolute path
- [ ] The known housekeeping defects are cleared
- [ ] The maintenance scope is written and `AGENTS.md` agrees with it
- [ ] `python scripts/todo-graph.py validate` clean
