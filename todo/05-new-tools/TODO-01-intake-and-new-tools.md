---
schema_version: 1
id: intake-and-new-tools
domain: 05-new-tools
status: draft
title: "TODO-01 -- Intake and New Tools"
depends_on: [framework-core, repair-contract, tool-ports]
track: P3
---

# TODO-01 -- Intake and New Tools

> **Goal:** Six programs from `samples/` become real products, and the new utilities join the suite. Every one of them arrives already conformant, through a repeatable intake contract, so no new tool ever joins a cleanup backlog. Complete Windows Repair becomes the suite's general repair library: any Windows repair without a clearly topical home lands there as an item rather than as a product.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Nothing here has started. The intake candidates live under `resolute_au3/samples/`: Complete Windows Repair (`ComWinRep/WinRepair.au3`, 2,028 lines, version 1.0.0.339, with its own build descriptor and documentation set), QuickErase (`QuickErase/QuickErace.au3`, 723 lines, and the filename is misspelled in the sample), WinClean (`WinClean/EvBeGone.au3`, 582 lines, plus `UDF/Services.au3`, `UDF/Resources.au3`, `UDF/SecureDelete.au3`), UUIDGen (209 lines), and Indicators (349 lines). SaveDesk is **not** a port: `samples/SaveDesk/` holds only a `[Research]/` directory of third-party material with no Rizonesoft source. The four new utilities have no source at all.

## Inputs

- [`resolute_au3/samples/ComWinRep/WinRepair.au3`](../../resolute_au3/samples) -- Complete Windows Repair, the flagship intake
- [`resolute_au3/samples/WinClean/UDF/Services.au3`](../../resolute_au3/samples) -- service control primitives; nothing in the framework does this yet and two new tools need it
- -> XREF: [`02-repair-contract/TODO-01 §1`](../02-repair-contract/TODO-01-repair-contract.md) -- the contract every repairing intake consumes from its first commit
- -> XREF: [`04-tools-port/TODO-01 §1`](../04-tools-port/TODO-01-tool-ports.md) -- the porting pattern this file reuses
- -> XREF: [`05-new-tools/TODO-02 §1`](./TODO-02-regstudio.md) -- RegStudio, the largest intake, measured against the contract §1 writes
- -> XREF: [`05-new-tools/TODO-03 §1`](./TODO-03-system-utilities.md) -- the nine new utilities, measured against the same contract
- -> XREF: [`05-new-tools/TODO-04 §1`](./TODO-04-diagnostics.md) -- the diagnostics, which compose §5's enumerators rather than writing their own
- -> XREF: [`05-new-tools/TODO-05 §3`](./TODO-05-recovery-and-imaging.md) -- the erase verification that proves §3's `QuickErase` claim

## Outcome

- An intake contract exists, and a tool that has been through it is conformant by construction.
- Complete Windows Repair ships as a first-class product.
- QuickErase, WinClean, UUIDGen, and Indicators ship.
- SaveDesk is built as new development against a researched concept.
- Startup entries, services, scheduled tasks, and context menu entries ship as one tool; the Hosts editor ships beside it.
- Service control lives in the framework, not in one tool.

**Adjacency:** list=applicable @ D05 T01 §5; document=applicable @ D05 T01 §2; settings=applicable @ D05 T01 §1; reporting=applicable @ D05 T01 §5; notifications=applicable @ D05 T01 §3; permissions=applicable @ D05 T01 §3; audit=applicable @ D05 T01 §3; exchange=applicable @ D05 T01 §4; reverse=applicable @ D05 T01 §5

**Adjacency rationale:** Reverse and list pair on §5 because the new utilities are mostly enable-and-disable surfaces over system state, and the whole reason they are safe to ship is that every change is listed and every change is undoable. Permissions, notifications, and audit converge on §3 because QuickErase and WinClean are the destructive intakes, and a secure delete that proceeds without privilege, without confirmation, or without a trail is the worst tool in the suite.

## Implementation Order

| Order | Section | Deliverable                                  | Depends On             | Status |
| :---: | :-----: | -------------------------------------------- | ---------------------- | :----: |
|   1   |   §1    | The intake contract, proven on UUIDGen       | D04 T01 §1             |  [ ]   |
|   2   |   §2    | Complete Windows Repair                      | §1, D02 T01 §1         |  [ ]   |
|   3   |   §3    | QuickErase and WinClean                      | §1, D02 T01 §4         |  [ ]   |
|   4   |   §4    | Indicators and SaveDesk                      | §1                     |  [ ]   |
|   5   |   §5    | The autoruns manager and the hosts editor    | §1, D02 T01 §4         |  [ ]   |

---

## 1. The Intake Contract, Proven on UUIDGen

The whole point of doing the framework first is that a new tool should be cheap and correct from its first commit. This section writes that procedure down and proves it on the smallest possible candidate.

**Fidelity:** the UUIDGen main window; new build against the framework's standard window, no AutoIt baseline required beyond its sample.
**Job:** a maintainer can bring a sample program into the suite and have it be conformant on its first commit. Consumer: the intake contract document, and UUIDGen as its proof.
**Treatment:** the contract is proven by running it, not by writing it. Cheaper substitute that fails the checkpoint: publishing the contract and declaring it proven because it reads well.
**Chrome:** consume the framework. UUIDGen changes nothing on a system and does not consume the repair contract.
**Needs:** C++ toolchain (compile)

- [ ] Write the intake contract as a document: what a candidate must have before it starts, what the framework supplies, what the tool must supply, and what it owes before it can ship. Done when: the document exists and names the conformance profile as its acceptance test.
- [ ] Require the tool descriptor, a documentation set, an update short name, and an English language pack as intake minimums. Done when: a candidate missing any of them fails the contract by name.
- [ ] Prove it on UUIDGen, at 209 lines the cheapest candidate in the set. Done when: UUIDGen ships conformant and the elapsed effort is recorded here as the intake baseline.
- [ ] Record what the contract missed. Done when: anything UUIDGen needed that the contract did not anticipate is added to the contract in the same commit.
- [ ] Commit: `"intake: the intake contract, proven on uuidgen"`

**Test checkpoint:** UUIDGen builds for both architectures, runs standalone in an empty folder, passes the conformance check, and renders localized. A candidate missing a documentation set fails the contract by name. The intake effort baseline is recorded.

## 2. Complete Windows Repair

The flagship intake, and the largest. It arrives with its own documentation set and a `Doors/` runtime layout that is arguably better than the shipped suite's, which makes it the right place to settle the standalone layout question.

**Fidelity:** the Complete Windows Repair main window, against its shipped 1.0.0.339 build and `docs/captures/house-style/`.
**Job:** a user can repair a broken Windows installation, see what was attempted, and undo it. Consumer: the system state, read back by verify.
**Treatment:** every repair declared as a repair-contract item, so diagnose, verify, and undo come for free. Cheaper substitute that fails the checkpoint: porting the tool's own repair loop, which is how the suite grew seven of them.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] Enumerate what the sample repairs and record the list here with its source locations. Done when: the list is complete and each entry names the function that performs it.
- [ ] Reconcile the `Doors/` layout against the framework's standalone layout. Done when: one layout is chosen, recorded with its cost, and `D01 T01 §9` is named as the owner of the decision.
- [ ] Import the repairs from `WinPower.au3` that belong here: `_RepairFontRegistrations`, `_ResetTcpipAll`, `_RebuildWMI`. Done when: all three are declared items and `_ResetTcpipAll` reuses the ComIntRep implementation rather than becoming a second one.
- [ ] Restore the Windows Update reset scripts from git history at `8d7469a^` and evaluate them as repair items. Done when: each is either a declared item or explicitly rejected with a reason.
- [ ] Add the six routed repairs as declared items: Windows Search and indexing, audio, Store and UWP app re-registration, print spooler, font registration, and WinSxS component cleanup. Done when: all six are contract items with a diagnose, a verify, and an honest reversibility answer. Source for font registration: `_RepairFontRegistrations` in `resolute_au3/samples/WinPower 0.0.3.325922/WinPower.au3:229`.
- [ ] Give WinSxS cleanup the treatment its irreversibility demands. Done when: it states on the surface that superseded components cannot be restored afterwards, and the confirmation names what will be removed.
- [ ] Record that this tool is the suite's **general repair library**. Done when: this section states that any Windows repair without a clearly topical home becomes a CWR item, and names the two exceptions already assigned: network repairs to `ComIntRep` and drive repairs to Drive Repair.
- [ ] Prove every repair has a reverse, or states on the surface that it does not and what to do instead. Done when: each item carries one of those two.
- [ ] Account for the surface. Done when: the account covers the whole window and each deferral resolves.
- [ ] Commit: `"comwinrep: complete windows repair on the repair contract"`

**Test checkpoint:** Every repair is a declared contract item, with the enumeration quoted. A fixture run followed by undo restores the pre-run state. `_ResetTcpipAll` resolves to one implementation shared with ComIntRep, proven by reference. The rendered surface is captured and compared.

## 3. QuickErase and WinClean

The two destructive intakes. A secure delete is the one tool in this suite with no undo by definition, which raises the bar on confirmation and on saying so plainly.

**Fidelity:** each tool's main window against the framework's standard window; the confirmation reuses the framework's message dialog.
**Job:** a user can securely erase files, or clean a system, and cannot do either by accident. Consumer: the filesystem, read back after the action.
**Treatment:** the erase method chosen by **drive type**, and confirmation naming exactly what will be destroyed with an explicit statement that this action has no reverse. Cheaper substitute that fails the checkpoint: overwriting regardless of media, which is what most free shredders do and which does not reliably erase anything on an SSD.
**Chrome:** consume the framework and the repair contract. WinClean's service operations consume the promoted service primitives.
**Needs:** Windows host (build/test)


**Build order.** Media detection comes before any erase path, because which method is correct depends on it.

1. **Promote `samples/WinClean/UDF/Services.au3` into the framework** as service primitives. Done when: the framework exposes start, stop, pause, resume, and start-mode, and no tool implements them privately.
2. **Build media detection first.** Magnetic, SATA solid state, NVMe, or unknown. Done when: each is correctly identified on a driven run and unknown is reported rather than assumed.
3. **Port the eight overwrite patterns unchanged** from `resolute_au3/samples/QuickErase/QuickErace.au3`, for magnetic media only. Done when: the patterns are compared against the original and match byte for byte.
4. **Add the firmware erase path** for solid state: ATA Secure Erase and NVMe Sanitize. Done when: each is exercised and the surface states which method was used.
5. **Add the multi-pass refusal on solid state**, with its explanation and override. Done when: the refusal fires, the override is logged, and the reasoning is on the surface.
6. **Add confirmation and the no-reverse statement** before wiring any action to a button. Done when: the confirmation names count, size, and paths, and declining performs nothing.
7. **Port WinClean's cleanups** as repair-contract items, each declaring its reversibility honestly. Done when: each is a declared item and none writes outside the contract's loop.

- [ ] Promote `samples/WinClean/UDF/Services.au3` into the framework as service-control primitives. Done when: the framework exposes start, stop, pause, resume, and start-mode operations, and no tool implements them privately.
- [ ] Port QuickErase, correcting the misspelled source filename on intake. Done when: it builds, and the file is named for the product.
- [ ] Detect the media type of the target: magnetic, SATA solid state, or NVMe. Done when: each is correctly identified on a driven run and an indeterminate result is reported as unknown rather than assumed.
- [ ] **Choose the erase method by media type.** On magnetic media, overwrite. On solid state, use the drive's own firmware erase, ATA Secure Erase or NVMe Format and Sanitize, because wear levelling means an overwrite lands in a different physical block and leaves the original where no read can reach it. Done when: each path is exercised and the surface states which method was used and why.
- [ ] Refuse to run a multi-pass overwrite on solid state without an explicit override. Done when: the refusal explains that additional passes add wear without adding erasure, and the override is recorded in the log and the transcript. Cheaper substitute that fails the checkpoint: running the requested passes silently, which costs the drive real life and achieves nothing.
- [ ] Record what the shipped AutoIt passes actually are, and keep them. Done when: `DoD-5220-22-M`, its `-E` and `-ECE` variants, Schneier, German, Canadian, Russian, and `AR380` are all preserved for magnetic media, with their patterns unchanged from `QuickErace.au3`.
- [ ] State what single-file erasure cannot guarantee on any media. Done when: the surface names copies the file system may hold elsewhere, such as shadow copies, journals, and previously allocated blocks, before the user commits.
- [ ] Handle the case where firmware erase is unavailable or refused by the drive. Done when: it is reported as a named outcome rather than silently falling back to overwriting.
- [ ] Confirm every destructive action by naming what will be destroyed: count, total size, and the paths. Done when: the confirmation names all three and declining performs nothing, asserted.
- [ ] State on the surface that a secure erase has no reverse, before the user commits. Done when: the statement appears where the user sees it, captured.
- [ ] Prove the erase against a fixture tree rather than a real user path. Done when: the assertion runs entirely inside the fixture root and a path outside it is refused.
- [ ] Port WinClean, with each cleanup declared as a repair-contract item so it inherits diagnose and undo where an undo exists. Done when: each item declares its reversibility honestly.
- [ ] Decide and record whether QuickErase and WinClean stay separate products given their overlapping secure-delete capability. Done when: the decision is dated with its cost of changing.
- [ ] Commit: `"quickerase, winclean: the destructive intakes"`

**Test checkpoint:** Service primitives live in the framework and no tool implements them privately, proven by search. A destructive confirmation names count, size, and paths; declining performs nothing. The no-reverse statement is captured on the surface. The erase assertion runs inside the fixture root and refuses a path outside it. Each media type is detected on a driven run and the surface states the method used; a multi-pass request on solid state is refused with its explanation, and the override is logged. The eight preserved overwrite patterns are compared against `QuickErace.au3` and match.

## 4. Indicators and SaveDesk

One small port and one genuinely new build. SaveDesk is the only candidate in this plan with no Rizonesoft source behind it, and saying so keeps it from being estimated like a port.

**Fidelity:** each tool's main window against the framework's standard window. SaveDesk is a new build with no baseline.
**Job:** a user can see their indicator state at a glance, and can put their desktop icons back where they were after a resolution change. Consumer: the rendered surfaces, and the saved layout read back on restore.
**Treatment:** SaveDesk's restore proven as a real reverse against recorded positions. Cheaper substitute that fails the checkpoint: restoring icons to a grid, which is a tidy-up rather than a restore.
**Chrome:** consume the framework. SaveDesk consumes the repair contract for its restore record.
**Needs:** Windows host (build/test)

- [ ] Port Indicators through the intake contract. Done when: it ships conformant.
- [ ] Record that SaveDesk is new development, not a port, with what the `[Research]/` material does and does not provide. Done when: the statement is here and the estimate reflects it.
- [ ] Build SaveDesk: save and restore desktop icon layout, per resolution. Done when: a layout is saved, the resolution is changed, the layout is restored, and the icons return to their recorded positions.
- [ ] Make saved layouts findable and identifiable. Done when: a user with several can pick one without opening it, captured.
- [ ] Prove the restore is genuinely a reverse. Done when: save, disturb, restore returns every icon to its recorded position, asserted.
- [ ] Commit: `"indicators, savedesk: a port and a new build"`

**Test checkpoint:** Indicators passes the conformance check and runs standalone. SaveDesk saves a layout, survives a resolution change, and restores every icon to its recorded position, asserted and captured. The layout list is identifiable without opening entries.

## 5. The Autoruns Manager and the Hosts Editor

Startup entries, services, scheduled tasks, and shell context menu entries are the same tool four times: enumerate what the system runs, show what is enabled, toggle it, undo it. They ship as **one tool with four tabs**, because the question a user actually has is "what runs on my machine", and answering it across four separate downloads is worse rather than better.

The Hosts editor stays separate: it edits one file rather than enumerating system state, and grouping it here would be filing by convenience.

**Fidelity:** the manager's tabbed surface and the hosts editor, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user can see everything their system runs without being asked, and stop any of it reversibly. Consumer: the system state, read back by verify.
**Treatment:** one enumeration model over four sources, and every change declared as a repair-contract item. Cheaper substitute that fails the checkpoint: four tools that each write their own enable-and-disable logic, which is the duplication this whole rewrite exists to remove.
**Chrome:** consume the framework, the repair contract, and the service primitives from §3.
**Needs:** Windows host (build/test)

- [ ] Define one entry model covering all four sources: a name, a source, a command, an enabled state, and a publisher where one exists. Done when: all four sources populate the same model and the surface has no per-source branch.
- [ ] Build the startup tab. Done when: an entry is disabled, the machine is restarted, the entry did not run, and undo restores it.
- [ ] Build the services tab on the promoted service primitives. Done when: start, stop, and start-mode changes each verify by reading the service state back, and each is undoable.
- [ ] Build the scheduled tasks tab, which nothing in the suite covers today and where bloat and malware hide. Done when: a task is disabled and re-enabled, verified by reading the task state back.
- [ ] Build the context menu tab. Done when: an entry is removed, Explorer no longer offers it, and undo restores it exactly.
- [ ] Make every change a repair-contract item so the undo is the contract's. Done when: no tab writes outside the contract's loop, proven by search.
- [ ] Let a user find an entry across all four sources at once. Done when: one search narrows every tab and the result says which source each hit came from.
- [ ] Build the Hosts File Editor separately. Done when: an entry is added, name resolution reflects it, the file is written atomically, and the prior file is recoverable through the contract.
- [ ] Account for both surfaces. Done when: two accounts are written and each deferral resolves.
- [ ] Commit: `"autoruns manager and hosts editor"`

**Test checkpoint:** All four sources populate one entry model with no per-source branch in the surface, proven by search. Each tab performs a change, verifies by reading system state back, and restores through the contract's undo, all four asserted. One search narrows every tab and names each hit's source. The hosts editor writes atomically and its prior file is recoverable. Both surfaces captured under `docs/captures/runs/`.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with every new tool's suite reporting
- [ ] Every tool in this file passes the conformance check
- [ ] Every tool in this file runs standalone in an empty folder
- [ ] Service control exists once, in the framework
- [ ] Every destructive action confirms by naming what it will destroy
- [ ] `python scripts/todo-graph.py validate` clean
