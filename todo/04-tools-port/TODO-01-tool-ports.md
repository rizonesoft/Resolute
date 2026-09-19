---
schema_version: 1
id: tool-ports
domain: 04-tools-port
status: draft
title: "TODO-01 -- Tool Ports"
depends_on: [framework-core, repair-contract]
frozen: true
track: P2
---

# TODO-01 -- Tool Ports

> **Goal:** Every existing tool runs on the C++ framework, doing exactly what its AutoIt counterpart did, proven by running both against the same fixture. Two consolidations land here: the four browser optimizers become one tool with a browser picker, and `USBRepair` and `DVDRepair` become Drive Repair.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** No tool has been ported. The AutoIt originals are in `resolute_au3/SDK/Concrete/`. Subtracting the 1,556-line framework that `ReBar` is, the real logic per tool is roughly: `Ownership` 77, `USBRepair` 147, `DVDRepair` 274, `PixRepair` 341, `BiosCodes` 960, `ComIntRep` 1,903. The four browser optimizers are byte-for-byte the same 2,389-line file, differing only in two version directives and three occurrences of a browser path. `Firemin` carries 35 language packs; `Chromin`, `Edgemin`, and `Watermin` carry none.

## Inputs

- [`resolute_au3/SDK/Concrete/`](../../resolute_au3/SDK/Concrete) -- every tool being ported, and the specification each is measured against
- -> XREF: [`00-workspace/TODO-02 §4`](../00-workspace/TODO-02-test-backbone.md) -- the parity driver every section here cites
- -> XREF: [`01-framework/TODO-01 §1`](../01-framework/TODO-01-framework-core.md) -- the framework every port consumes
- -> XREF: [`02-repair-contract/TODO-01 §1`](../02-repair-contract/TODO-01-repair-contract.md) -- the contract the repair tools consume
- -> XREF: [`03-launcher/TODO-01 §1`](../03-launcher/TODO-01-launcher.md) -- the launcher that discovers these tools
- -> XREF: [`05-new-tools/TODO-01 §1`](../05-new-tools/TODO-01-intake-and-new-tools.md) -- the intake contract, which reuses this file's porting pattern
- -> XREF: [`06-distro-release/TODO-01 §1`](../06-distro-release/TODO-01-build-and-release.md) -- the release that ships these ports
- -> XREF: D04 T02 §1 -- the Ownership inventory this slice builds from ([TODO-02](./TODO-02-ownership-complete.md))
- -> XREF: D04 T03 §1 -- the ComIntRep spec this section ordered ([TODO-03](./TODO-03-comintrep-complete.md))
- -> XREF: D04 T04 §1 -- the PixRepair spec this section builds ([TODO-04](./TODO-04-pixrepair-complete.md))
- -> XREF: D04 T05 §1 -- the BiosCodes spec this section builds ([TODO-05](./TODO-05-bioscodes-complete.md))
- -> XREF: [`09-au3-maintenance/TODO-01 §1`](../09-au3-maintenance/TODO-01-au3-maintenance.md) -- the AutoIt tool each port retires

## Outcome

- Every shipped tool has a C++ implementation that passes a parity check against its AutoIt counterpart.
- The six frozen tools produce byte-identical effects, proven per tool.
- Four browser tools become one; two drive tools become one.
- Every port lives at `extensions/<Tool>/`, builds as its own standalone executable, and consumes the framework and, where it repairs, the repair contract.
- No ported tool carries a private settings writer, log writer, or localization loader.

**Adjacency:** list=applicable @ D04 T01 §4; document=applicable @ D04 T01 §5; settings=applicable @ D04 T01 §1; reporting=applicable @ D04 T01 §2; notifications=applicable @ D04 T01 §3; permissions=applicable @ D04 T01 §2; audit=applicable @ D04 T01 §2; exchange=applicable @ D04 T01 §3; reverse=applicable @ D04 T01 §2

**Adjacency rationale:** Reverse, permissions, reporting, and audit all anchor on §2 because that is where the six frozen tools land, and those four are exactly what a destructive tool owes: refuse without the privilege, say what it did, be undoable, and leave a trail. Exchange anchors on §3 because the browser tool's settings file is the one users hand-edit when a browser is installed somewhere unusual, which is the single most common support case in that group.

## Implementation Order

| Order | Section | Deliverable                                  | Depends On                 | Status |
| :---: | :-----: | -------------------------------------------- | -------------------------- | :----: |
|   1   |   §1    | Vertical slice: Ownership end to end         | D01 T01 §9, D02 T01 §4, D00 T02 §4, D04 T02 §1 |  [ ]   |
|   2   |   §2    | The remaining frozen tools: ComIntRep, PixRepair | §1, D04 T03 §1, D04 T03 §2, D04 T04 §1, D04 T04 §2 |  [ ]   |
|   3   |   §3    | Browser optimizer: four tools into one       | §1                         |  [ ]   |
|   4   |   §4    | Drive Repair: USBRepair and DVDRepair merged | §2                         |  [ ]   |
|   5   |   §5    | MemBoost and BiosCodes                       | §2, D04 T05 §1, D04 T05 §2 |  [ ]   |

---

## 1. Vertical Slice: Ownership End to End

`Ownership` is roughly 77 lines of real logic on top of 1,556 lines of framework, which makes it the cheapest possible proof that the framework and the repair contract actually work together on a real product. If the architecture is wrong, it is wrong here, cheaply.

**Fidelity:** the Ownership main window and its result list, against `docs/captures/house-style/` and a pre-change capture of the shipped build.
**Job:** a user can add or remove the "Take Ownership" context-menu entry, see exactly what changed, and put it back. Consumer: the `HKCR` shell keys, read back by the verify step.

> [!IMPORTANT]
> **Corrected 2026-09-17 by `D00 T02 §4`, which read the source while building the parity driver. This section described behaviour the tool does not have.**
>
> It read "a user can take ownership of a path" and "Consumer: the filesystem ACLs". **`Ownership.exe` never calls `takeown` or `icacls`.** Its entire system effect is writing four registry trees:
>
> ```
> HKCR\*\shell\runas          HKCR\Directory\shell\runas
> HKCR\dllfile\shell\runas    HKCR\Drive\shell\runas
>   \command = cmd.exe /c takeown /f "%1" /r /d y && icacls "%1" /grant administrators:F /t
> ```
>
> It is a **context-menu installer**. The `takeown` runs later, when a user right-clicks something, in a process this tool never starts. The only `Run` and `ShellExecute` calls in the source open URLs and relaunch the 64-bit build.
>
> **The measurement in `§2` already said so.** `Ownership` is **2 net functions and 77 net lines**, which is a registry writer rather than an ACL engine, and that figure was recorded without anybody asking what it implied.
>
> **What this changes for this section.** Parity is a **registry** comparison, not a filesystem ACL comparison. The reverse is deleting four key trees, not restoring owners. The freeze check pins what the tool writes to `HKCR`, including the exact `\command` string, because that string is what eventually runs against a user's files. And the elevation requirement is real and is the tool's own: `HKCR` writes need admin, which is why `D01 T01 §6`'s guard matters here.
>
> **What it does not change.** The vertical slice is still the right first port and is still cheap, and `D00 T02 §2`'s `RegistryFixture` is the right disposable target for it. That fixture's **`FileTreeFixture`** half was justified in `§2`'s stamp as carrying "the exact values `D04 T01 §1` compares", which was wrong in the same way; it remains useful for the tools that do touch ACLs, `PixRepair` and `ComIntRep` among them.
**Treatment:** the prior owner and ACL recorded before the change, so undo restores what was actually there. Cheaper substitute that fails the checkpoint: a reverse that sets ownership to the current user or to `TrustedInstaller` by convention.
**Chrome:** consume the framework and the repair contract. Do not keep a private copy of either.
**Needs:** Windows host (build/test)


**Build order.** This slice decides whether the framework and the contract are right. Capture the baseline **before** writing any C++, because the shipped tool is the only source of truth for what it does.

1. **Capture the AutoIt baseline first.** Run `resolute_au3/Resolute/Ownership.exe` against `tests/fixtures/filetree/` and record its effects and window. Done when: the baseline is committed under `docs/captures/` and the parity record exists for the AutoIt side.
2. **Enumerate what the tool does** from `resolute_au3/SDK/Concrete/Ownership/Ownership.au3`, ignoring the roughly 1,556 framework lines and reading only its real logic. Done when: every action it performs is listed with its source line.
3. **Declare those actions as repair-contract items**, with no loop of their own. Done when: the tool compiles and `D02 T01 §1`'s loop runs them.
4. **Run the parity driver** and fix differences until it reports zero. Done when: the parity report shows no differing fields, quoted.
5. **Prove the reverse**, which the AutoIt tool never had, so it has no baseline. Done when: takeover then undo restores every owner and ACL, asserted.
6. **Prove the refusal** with a deny-ACE fixture. Done when: the path is refused by name and the batch counts still reconcile.
7. **Record what the slice proved** before porting anything else. Done when: this section states which framework and contract assumptions are now evidence, so `§2` starts from fact.

- [ ] Capture the shipped AutoIt `Ownership` first: a driven run against the fixture tree with its effects and window recorded. Done when: the baseline is committed.
  -> XREF: D00 T02 §2 -- the disposable file tree this runs against, which reads back owner SIDs and DACL entry counts for exactly this comparison

  **What the fixture store gives this section, and what it does not**, recorded 2026-09-17 when `D00 T02 §2` shipped: `FileTreeFixture` creates a tree this process owns, with declared ACLs, and reads the owner back as a SID string, which is the before-and-after comparison this port needs. It runs **unelevated**. What it does not solve is taking ownership of an object owned by somebody else, which needs `SeTakeOwnershipPrivilege`; that half of this section needs its own arrangement rather than assuming the fixtures cover it.
- [ ] Port the tool to `extensions/Ownership/` as framework plus repair contract plus its own items, and nothing else. Done when: it builds as its own standalone executable and the source contains no settings, log, localization, or loop code.
- [ ] Prove parity: both implementations run against the same fixture tree and the parity driver reports no difference. Done when: the parity report is quoted and shows zero differing fields.
  -> XREF: D00 T02 §4 -- the parity instrument this inherits, and the section that deferred the first cross-implementation pair to this item

  **This item inherits work, recorded 2026-09-17 when `D00 T02 §4` shipped.** That section built the record format, the snapshot driver and the field-by-field comparison, and **deliberately did not produce the first cross-implementation pair**, because doing so was circular: no C++ `Ownership` existed, and `§4` is listed among this section's own unmet dependencies. It also could not be driven, since no AutoIt tool in the suite parses a command line, and running one writes `HKCR` on the developer's machine.

  **So the first AutoIt-side parity record is this item's to produce**, and the first item of this section is where it is captured. The instrument is already proven against real registry and filesystem state, so what remains here is running it around two implementations rather than building it. The snapshot is taken from **outside** the run, which is why an AutoIt binary that exposes nothing needs no cooperation to be measured.
- [ ] Prove the reverse: installing the context-menu entry followed by undo leaves `HKCR` exactly as it was, compared key by key and value by value. **Corrected 2026-09-17:** this said "restores every path's owner and ACL", which is not what the tool touches. Done when: the assertion compares the four `HKCR` subtrees before and after, including the `\command` string, and a `RegistryFixture` gives it a disposable target.
- [ ] Prove the refusal: a path the process cannot touch is refused by name, leaving every other path in the batch accounted for. Done when: a deny-ACE fixture produces the refusal and the batch counts reconcile.
- [ ] Account for the surface: every control is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Record what the slice proved and what it did not. Done when: this section states which framework and contract assumptions are now evidence rather than intention.
- [ ] Commit: `"ownership: port to the framework and the repair contract"`

**Freeze check:** What `Ownership` writes to `HKCR` does not change, **including the exact `\command` string**, because that string is what eventually runs against a user's files and a change to it changes what happens to them. **Corrected 2026-09-17:** this read "what `Ownership` grants on takeover" against a file tree fixture, and the tool grants nothing at run time. Evidence is the parity report showing zero differing fields against the shipped AutoIt build over the four `HKCR` subtrees.

**Test checkpoint:** The parity driver reports zero differing fields between the C++ and AutoIt implementations on the same fixture tree, quoted. Takeover followed by undo restores every owner and ACL, asserted. A deny-ACE path is refused by name with the batch reconciling. The rendered window is compared against the pre-change capture.

## 2. The Remaining Frozen Tools: ComIntRep and PixRepair

> [!IMPORTANT]
> **Groomed 2026-09-17. This section claimed five tools and owns two, because three of them are ported by its own dependents.**
>
> It read "`ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, and `BiosCodes`" and asked that each be ported "as its own standalone executable". But `§4` merges `USBRepair` and `DVDRepair` into **one** tool with the device type as data, and `§5` ports `BiosCodes`. Both of those sections **depend on this one**, so as written this section would build five executables and its own dependents would then delete two of them and rebuild a third.
>
> That is not a scheduling preference, it is a contradiction: `§2` says two standalone executables and `§4` says one merged tool, about the same two tools. Resolved toward `§4` and `§5`, which are the later and more specific decisions and each carry their own Fidelity, Job and Treatment reasoning for the shape they build.
>
> **The dependency on this section still holds and is worth keeping.** `ComIntRep` is by a distance the largest thing in this domain, so proving the framework and the repair contract against it before `§4` and `§5` run is the point of the ordering, rather than the porting of their tools.

`ComIntRep` and `PixRepair`. With the slice proven this should be repetitive, and if it is not, the seam in `D02 T01 §1` was drawn in the wrong place.

**`ComIntRep` is specified before it is built.** Measured 2026-09-17 against `resolute_au3/SDK/Concrete/`, netting out the 58 functions every tool inherits from its copy of `ReBar`:

| tool | net functions | net lines |
| --- | ---: | ---: |
| `Ownership`, the slice | 2 | 77 |
| `USBRepair` | 12 | 147 |
| `DVDRepair` | 14 | 274 |
| `PixRepair` | 19 | 341 |
| `BiosCodes` | 28 | 960 |
| **`ComIntRep`** | **83** | **1,903** |

`ComIntRep` is four times the next largest and forty times the vertical slice. `AGENTS.md` is explicit that anything larger than a one-surface utility gets its own TODO file first, and on this evidence it is the one tool in this domain that clearly qualifies. `PixRepair` sits in the same band as the tools the other sections size honestly, so it is built from the items here.

**Fidelity:** each tool's main window and result list against its own pre-change capture and `docs/captures/house-style/`.
**Job:** each tool does what it did before, with a reverse and a trail it did not have. Consumer: the system state each changes, read back by verify.
**Treatment:** each proven against its own fixture, not inferred from `Ownership`. Cheaper substitute that fails the checkpoint: porting both and declaring them proven because the slice worked.
**Chrome:** consume the framework and the repair contract. No private copies.
**Needs:** Windows host (build/test)

- [x] **Specify** `ComIntRep` in its own TODO file before building it. Required scope: every repair it performs enumerated from `resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.au3` with its source line; which repairs are reversible and which are not; the component and internet repair areas it touches; and the freeze check below, which transfers to that file because that is where the writing happens. Done when: the file exists, validates, and its sections appear in the plan. Done: `D04 T03` authored, validated, and planned; the freeze check transfers to its Outcome and §1 verdicts.
- [ ] Capture each shipped AutoIt tool first, with its effects on its fixture and its window. Done when: two baselines are committed.
- [ ] Port `PixRepair` to `extensions/PixRepair/` as framework plus contract plus items. Done when: it builds as its own standalone executable and contains no settings, log, localization, or loop code.
- [ ] Prove parity per tool, `ComIntRep` through its own spec's sections and `PixRepair` here. Done when: two parity reports each show zero differing fields, both quoted.
- [ ] Prove the reverse per tool, or state plainly which actions have none and what the user should do instead, on the surface. Done when: each carries one of those two and the checkpoint proves which.
- [ ] Prove the elevation refusal per tool. Done when: two unelevated assertions each show the action refused by name, nothing changed, one log line.
- [ ] Account for each surface. Done when: two accounts are written and each deferral resolves.
- [ ] Commit: `"system tools: port comintrep and pixrepair"`

**Freeze check:** Neither tool's effect changes. Evidence is two parity reports with zero differing fields against the shipped AutoIt builds on their own fixtures. **The `ComIntRep` half transfers to its spec**, which is where its repairs are declared.
-> XREF: D04 T01 §4 -- ports `USBRepair` and `DVDRepair`, merged, which this section no longer does
-> XREF: D04 T01 §5 -- ports `BiosCodes`, which this section no longer does

**Test checkpoint:** `ComIntRep` has an authored TODO file that validates and appears in the plan. Two parity reports show zero differing fields, both quoted. Two reverse behaviors are proven or their absence stated on the surface. Two unelevated refusals each produce one log line. Both rendered surfaces compared against their captures.


## 3. Browser Optimizer: Four Tools Into One

Four byte-identical 2,389-line scripts become one tool with a browser picker. `Firemin` is the surviving brand and carries its 35 language packs forward.

**Fidelity:** the Firemin main window against its pre-change capture; the browser picker is a new surface with no baseline.
**Job:** a user can reduce their browser's memory footprint and see that it happened, for any supported browser. Consumer: the optimization result on the surface, and the log.
**Treatment:** browsers declared as data, so adding one is a table entry. Cheaper substitute that fails the checkpoint: a branch per browser, which is four copies with extra steps.
**Chrome:** consume the framework. The optimizer is not a repair tool and does not consume the repair contract.
**Needs:** Windows host (build/test)

- [ ] Capture each of the four shipped tools first, against its own running browser, with before and after memory figures. Done when: four baselines are committed.
- [ ] Declare each browser as data: display name, process name, default install path, settings key. Done when: all four are table entries and the default paths match what each AutoIt script uses today, line for line.
- [ ] Keep the user override working: the browser path is read from settings with the declared default as fallback. Done when: a fixture override is honored and an absent key falls back.
- [ ] Treat the settings file as hand-editable: a path that does not exist produces a named message and a log line, not a silent no-op. Done when: a fixture pointing at a nonexistent executable produces both.
- [ ] Prove the optimization behavior matches per browser, recording before and after figures against each baseline. Done when: four pairs of figures are quoted and this section states what counts as comparable.
- [ ] Log every optimization, including interval-triggered ones, with trigger, browser, processes, and memory before and after. Done when: one line carries all five, quoted. Cheaper substitute that fails the checkpoint: logging only the button press, which leaves every automatic optimization invisible.
- [ ] State the reverse honestly: the reverse of trimming a working set is that the browser pages memory back in on its own. Done when: that statement is on the surface, not only in the documentation.
- [ ] Commit: `"firemin: one optimizer with a browser picker"`

**Test checkpoint:** Four pairs of before and after figures are quoted against their baselines. A fixture override is honored; an absent key falls back; a nonexistent path produces a named message and one log line. An interval-triggered optimization produces a log line carrying all five fields. The reverse statement appears on the surface, captured.

## 4. Drive Repair: USBRepair and DVDRepair Merged

Two tools with near-identical shape become one. Neither can be fully proven without hardware, which is what the `Needs:` line is for: the row makes progress on the no-device path and parks on the rest.

**Fidelity:** the Drive Repair main window, against the `USBRepair` and `DVDRepair` pre-change captures and `docs/captures/house-style/`.
**Job:** a user can repair a drive, see what was attempted, and be told clearly when no suitable drive is present. Consumer: the drive state, read back after the action.
**Treatment:** the no-device case handled as a first-class outcome, and every action verified against the drive after it runs. Cheaper substitute that fails the checkpoint: reporting success because a command returned zero.
**Chrome:** consume the framework and the repair contract.
**Needs:** USB device (drive test)

- [ ] Enumerate the actions both AutoIt tools perform and record them here with their source locations. Done when: both lists are complete and each entry names its function.
- [ ] Handle the no-device case: a named message, a log line, no action attempted. Done when: driven on a host with no removable and no optical drive, it produces the message and changes nothing. This part needs no device and is proven first.
- [ ] Port both action sets into one tool with the device type as data. Done when: both sets are present and the tool detects which device types are attached.
- [ ] Confirm before every destructive drive action, naming the drive by letter, label, and size. Done when: the confirmation names all three and declining performs nothing.
- [ ] Prove parity for the USB actions against the shipped `USBRepair`. Done when: the parity report is quoted.
- [ ] Prove parity for the optical actions against the shipped `DVDRepair`, or record the leg as not run with its reason. Done when: either the report is quoted or the reason is recorded and this row does not stamp.
- [ ] State plainly which actions have no reverse, on the surface. Done when: each irreversible action carries that statement where the user sees it.
- [ ] Commit: `"drive repair: merge usbrepair and dvdrepair"`

**Freeze check:** What either tool does to a drive does not change. Evidence is the recorded action lists before and after, plus parity reports per device type.

**Test checkpoint:** On a host with no removable or optical drive, the tool produces the named no-device message, writes one log line, and changes nothing. With a USB device attached, the confirmation names letter, label, and size, and the parity report is quoted. The optical leg is either proven or recorded as not run with its reason, and the row does not stamp until it has been.

## 5. MemBoost and BiosCodes

The two tools that consume the framework but not the repair contract: one trims memory, one looks up a code. Both currently write no log at all.

**Fidelity:** each tool's main window against its own pre-change capture.
**Job:** a user can trim system memory, or look up a beep code and carry the answer to the machine that is beeping. Consumer: the trim effect read back, and the exported lookup result.
**Treatment:** MemBoost's trim path frozen and proven by parity; BiosCodes gaining the log and the export it has never had. Cheaper substitute that fails the checkpoint: a clipboard button presented as an export.
**Chrome:** consume the framework. Neither tool consumes the repair contract, because neither repairs anything.
**Needs:** Windows host (build/test)

- [ ] Capture both shipped tools first, with their effects and windows. Done when: two baselines are committed.
- [ ] Port `MemBoost` with its trim path frozen. Done when: the parity report against the shipped build shows zero differing fields on the trim fixture.
- [ ] Port `BiosCodes`, adding the logging it has never had. Done when: a driven lookup writes a log line naming the code.
- [ ] Give `BiosCodes` the export its users need: save the looked-up result as a file, written atomically and read back. Done when: the saved content matches the rendered result and a read-only target reports failure.
- [ ] Make the `BiosCodes` list findable: filter by manufacturer and by code fragment. Done when: a driven filter narrows and clearing restores.
- [ ] Prove `MemBoost`'s statistics are measured rather than estimated. Done when: the reported figures are compared against an independent measurement and the method is recorded.
- [ ] Account for both surfaces. Done when: two accounts are written and each deferral resolves.
- [ ] Commit: `"memboost, bioscodes: port to the framework"`

> [!IMPORTANT]
> **Groomed 2026-09-17: a question for the operator about `BiosCodes`, not a change.**
>
> `AGENTS.md` lists six tools whose behaviour is frozen because they "change a user's system in ways that are hard to undo": `Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, and **`BiosCodes`**. This section says the opposite about the same tool, that it "looks up a code" and that it does not consume the repair contract "because neither repairs anything", and this section is right.
>
> Measured in `resolute_au3/SDK/Concrete/BiosCodes/BiosCodes.au3`: **no `RegWrite`, no `RegDelete`, no `FileWrite`, no `FileDelete`**. The only writes are 10 `IniWrite` calls, which are its own settings file. For contrast `ComIntRep`, which belongs on that list, carries 4 `RegDelete`, 7 `FileDelete`, 24 `FileWrite` and 1 `FileCopy`.
>
> So `BiosCodes` appears to be on the frozen list for the same reason `AGENTS.md` already records `ReBar` being wrongly placed by the archived AutoIt plan: inherited rather than checked. **Not acted on here.** `AGENTS.md` is the contract, changing it is an operator decision, and a frozen tool that turns out not to need freezing costs only a parity check nobody needed. Flagged so the decision is made deliberately rather than by a port quietly skipping a freeze check.

**Freeze check:** `MemBoost`'s trim path does not change. Evidence is the parity report with zero differing fields on the trim fixture. **`BiosCodes` carries no freeze check here**, which is consistent with this section's own reading and inconsistent with `AGENTS.md`'s frozen list; see the note above, which is where that is to be resolved.

**Test checkpoint:** `MemBoost` parity reports zero differing fields. `BiosCodes` writes a log line per lookup, exports a file matching the rendered result, and fails visibly on a read-only target. The filter narrows and restores. `MemBoost` statistics are compared against an independent measurement with the method recorded.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with every port's suite reporting
- [ ] Every ported tool has a parity report with zero differing fields, quoted in its stamp
- [ ] No ported tool contains a private settings writer, log writer, or localization loader
- [ ] Every freeze check in this file ran and passed
- [ ] Every ported tool runs standalone in an empty folder
- [ ] `python scripts/todo-graph.py validate` clean
