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
|   1   |   §1    | Vertical slice: Ownership end to end         | D01 T01 §9, D02 T01 §4, D00 T02 §4 |  [ ]   |
|   2   |   §2    | The five remaining frozen tools              | §1                         |  [ ]   |
|   3   |   §3    | Browser optimizer: four tools into one       | §1                         |  [ ]   |
|   4   |   §4    | Drive Repair: USBRepair and DVDRepair merged | §2                         |  [ ]   |
|   5   |   §5    | MemBoost and BiosCodes                       | §2                         |  [ ]   |

---

## 1. Vertical Slice: Ownership End to End

`Ownership` is roughly 77 lines of real logic on top of 1,556 lines of framework, which makes it the cheapest possible proof that the framework and the repair contract actually work together on a real product. If the architecture is wrong, it is wrong here, cheaply.

**Fidelity:** the Ownership main window and its result list, against `docs/captures/house-style/` and a pre-change capture of the shipped build.
**Job:** a user can take ownership of a path, see exactly what changed, and put it back. Consumer: the filesystem ACLs, read back by the verify step.
**Treatment:** the prior owner and ACL recorded before the change, so undo restores what was actually there. Cheaper substitute that fails the checkpoint: a reverse that sets ownership to the current user or to `TrustedInstaller` by convention.
**Chrome:** consume the framework and the repair contract. Do not keep a private copy of either.
**Needs:** Windows host (build/test)

- [ ] Capture the shipped AutoIt `Ownership` first: a driven run against the fixture tree with its effects and window recorded. Done when: the baseline is committed.
- [ ] Port the tool to `extensions/Ownership/` as framework plus repair contract plus its own items, and nothing else. Done when: it builds as its own standalone executable and the source contains no settings, log, localization, or loop code.
- [ ] Prove parity: both implementations run against the same fixture tree and the parity driver reports no difference. Done when: the parity report is quoted and shows zero differing fields.
- [ ] Prove the reverse: a takeover followed by undo restores every path's owner and ACL, compared entry by entry. Done when: the assertion compares owner and ACL before and after.
- [ ] Prove the refusal: a path the process cannot touch is refused by name, leaving every other path in the batch accounted for. Done when: a deny-ACE fixture produces the refusal and the batch counts reconcile.
- [ ] Account for the surface: every control is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Record what the slice proved and what it did not. Done when: this section states which framework and contract assumptions are now evidence rather than intention.
- [ ] Commit: `"ownership: port to the framework and the repair contract"`

**Freeze check:** What `Ownership` grants on takeover does not change. Evidence is the parity report showing zero differing fields against the shipped AutoIt build on `tests/fixtures/filetree/`.

**Test checkpoint:** The parity driver reports zero differing fields between the C++ and AutoIt implementations on the same fixture tree, quoted. Takeover followed by undo restores every owner and ACL, asserted. A deny-ACE path is refused by name with the batch reconciling. The rendered window is compared against the pre-change capture.

## 2. The Five Remaining Frozen Tools

`ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, and `BiosCodes`. With the slice proven this should be repetitive, and if it is not, the seam in `D02 T01 §1` was drawn in the wrong place.

**Fidelity:** each tool's main window and result list against its own pre-change capture and `docs/captures/house-style/`.
**Job:** each tool does what it did before, with a reverse and a trail it did not have. Consumer: the system state each changes, read back by verify.
**Treatment:** each proven against its own fixture, not inferred from `Ownership`. Cheaper substitute that fails the checkpoint: porting all five and declaring them proven because the slice worked.
**Chrome:** consume the framework and the repair contract. No private copies.
**Needs:** Windows host (build/test)

- [ ] Capture each shipped AutoIt tool first, with its effects on its fixture and its window. Done when: five baselines are committed.
- [ ] Port each to `extensions/<Tool>/` as framework plus contract plus items. Done when: each builds as its own standalone executable and none of the five contains settings, log, localization, or loop code.
- [ ] Prove parity per tool. Done when: five parity reports each show zero differing fields, all quoted.
- [ ] Prove the reverse per tool, or state plainly which actions have none and what the user should do instead, on the surface. Done when: each of the five carries one of those two and the checkpoint proves which.
- [ ] Prove the elevation refusal per tool. Done when: five unelevated assertions each show the action refused by name, nothing changed, one log line.
- [ ] Account for each surface. Done when: five accounts are written and each deferral resolves.
- [ ] Commit: `"system tools: port the five remaining frozen tools"`

**Freeze check:** No tool's effect changes. Evidence is five parity reports with zero differing fields against the shipped AutoIt builds on their own fixtures.

**Test checkpoint:** Five parity reports show zero differing fields, all quoted. Five reverse behaviors are proven or their absence stated on the surface. Five unelevated refusals each produce one log line. All five rendered surfaces compared against their captures.

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

**Freeze check:** `MemBoost`'s trim path does not change. Evidence is the parity report with zero differing fields on the trim fixture.

**Test checkpoint:** `MemBoost` parity reports zero differing fields. `BiosCodes` writes a log line per lookup, exports a file matching the rendered result, and fails visibly on a read-only target. The filter narrows and restores. `MemBoost` statistics are compared against an independent measurement with the method recorded.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with every port's suite reporting
- [ ] Every ported tool has a parity report with zero differing fields, quoted in its stamp
- [ ] No ported tool contains a private settings writer, log writer, or localization loader
- [ ] Every freeze check in this file ran and passed
- [ ] Every ported tool runs standalone in an empty folder
- [ ] `python scripts/todo-graph.py validate` clean
