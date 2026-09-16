---
schema_version: 1
id: system-utilities
domain: 05-new-tools
status: draft
title: "TODO-03 -- New System Utilities"
depends_on: [intake-and-new-tools, repair-contract]
frozen: true
track: P3
---

# TODO-03 -- New System Utilities

> **Goal:** Nine new tools that fill the gaps the ported suite leaves, every one of them built on the framework and the repair contract from its first commit, so none of them ever joins a cleanup backlog. The first of them makes every other tool in the suite safer.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** None of these exists in any form. They are new development, not intakes, and none of them has AutoIt source to port or a parity check to satisfy. `resolute_au3/SDK/Includes/CompInfo.au3` is the only prior art in the repository and is relevant to §6 alone. Every section here depends on the repair contract already shipping, because each tool's whole safety story is the contract's restore record and undo.

## Inputs

- [`resolute_au3/SDK/Includes/CompInfo.au3`](../../resolute_au3/SDK/Includes/CompInfo.au3) -- the existing machine-information helper, prior art for §6
- -> XREF: [`02-repair-contract/TODO-01 §4`](../02-repair-contract/TODO-01-repair-contract.md) -- the restore record and undo every tool here consumes
- -> XREF: [`05-new-tools/TODO-01 §1`](./TODO-01-intake-and-new-tools.md) -- the intake contract these tools are measured against

## Outcome

- Every repair in the suite can be preceded by a restore point, and that point can be browsed and used.
- A driver can be rolled back to exactly what was there before.
- A user can find out whether their disk is dying, and why their machine crashed.
- A file that will not delete can be unlocked, and a user can say what is holding it.
- A support conversation starts with one attached file rather than twenty questions.

**Adjacency:** list=applicable @ D05 T03 §1; document=applicable @ D05 T03 §6; settings=applicable @ D05 T03 §7; reporting=applicable @ D05 T03 §4; notifications=applicable @ D05 T03 §3; permissions=applicable @ D05 T03 §5; audit=applicable @ D05 T03 §2; exchange=applicable @ D05 T03 §6; reverse=applicable @ D05 T03 §1

**Adjacency rationale:** Reverse and list both anchor on §1 because a restore point is the suite's deepest undo and it is only useful if a user can find the right one without opening it, which is exactly the failure mode Windows' own restore UI has. Document and exchange pair on §6 because the system report is the one artifact here that leaves the machine entirely: it is written to be read by a stranger, which makes what it does **not** contain as important as what it does.

## Implementation Order

| Order | Section | Deliverable                                | Depends On         | Status |
| :---: | :-----: | ------------------------------------------ | ------------------ | :----: |
|   1   |   §1    | Restore Point Manager                      | D02 T01 §4         |  [ ]   |
|   2   |   §2    | Driver Manager: backup and rollback        | §1                 |  [ ]   |
|   3   |   §3    | Disk Health                                | D05 T01 §1         |  [ ]   |
|   4   |   §4    | Crash Decoder                              | D05 T01 §1         |  [ ]   |
|   5   |   §5    | File Unlocker                              | D05 T01 §1         |  [ ]   |
|   6   |   §6    | System Report                              | D05 T01 §1         |  [ ]   |
|   7   |   §7    | Battery Health, Boot Options, File Associations | §1            |  [ ]   |

---

## 1. Restore Point Manager

This is infrastructure before it is a tool. Every repair-contract run in the suite gains the option to create a restore point first, which is a second undo layer beneath the per-item restore record, and it is the only thing that helps when a repair breaks something the record cannot describe: a driver that will not load, a service that will not start.

**Fidelity:** the restore point list and the creation dialog, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user can take a restore point before a risky change, find the right one afterwards, and use it. Consumer: the Volume Shadow Copy store, read back by the list.
**Treatment:** points shown with what they cover and when they were taken, so one can be chosen without guessing. Cheaper substitute that fails the checkpoint: a list of dates, which is what Windows' own interface offers and why nobody trusts it.
**Chrome:** consume the framework and the repair contract. The creation offer is added to the contract's run loop, not to each tool.
**Needs:** Windows host (build/test)

- [ ] Create a restore point, named for what is about to happen. Done when: a point created before a fixture repair carries that repair's name, verified by reading it back.
- [ ] List existing points with date, type, and size where available. Done when: the list renders and a user can distinguish a manual point from an automatic one.
- [ ] Offer restore-point creation from the repair contract's run loop, as an opt-in the user controls. Done when: a fixture repair offers it, declining proceeds without one, and the choice is logged.
- [ ] Report honestly when System Protection is disabled. Done when: on a machine with it off, the tool says so, explains the consequence, and offers to enable it rather than failing silently. Cheaper substitute that fails the checkpoint: a greyed-out button with no explanation, which is the single most common complaint about the built-in interface.
- [ ] Trigger a restore, with a plain statement of what it will and will not undo. Done when: the confirmation states that personal files are untouched and installed programs may be affected, and declining performs nothing.
- [ ] Log every point created and every restore triggered. Done when: each produces one line naming the point.
- [ ] Account for the surface. Done when: every control is working or deferred to a named section.
- [ ] Commit: `"restore points: create, browse, and restore"`

**Freeze check:** What a restore actually reverts is Windows' behaviour, not this tool's, and this tool must not appear to promise more. Evidence is the confirmation text, checked against what a restore genuinely does.

**Test checkpoint:** A point created before a fixture repair carries that repair's name, read back. The list distinguishes manual from automatic points, captured. A fixture repair offers creation and declining proceeds without one, both driven. With System Protection disabled, the tool explains and offers to enable it. One log line per point and per restore.

## 2. Driver Manager: Backup and Rollback

Drivers break Windows more often than anything else this suite touches, and `pnputil` is the only built-in answer.

> [!IMPORTANT]
> **This tool backs up and rolls back. It never updates.** Driver updaters sit next door to scareware, and shipping one would attach that reputation to the whole suite. Recorded 2026-09-16 as a product decision, not a scope limit to be relaxed quietly.

**Fidelity:** the driver list and the rollback confirmation, against `DESIGN.md`.
**Job:** a user can record their working drivers, and put one back after an update breaks it. Consumer: the driver store, read back after the action.
**Treatment:** the prior driver package captured before any change, so rollback restores the exact version that worked. Cheaper substitute that fails the checkpoint: relying on Windows' own rollback, which keeps only one previous version and only sometimes.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] Enumerate installed drivers with their version, date, provider, and signing state. Done when: the list matches `pnputil /enum-drivers` for the same machine, compared entry by entry.
- [ ] Back up a driver package so it can be reinstalled. Done when: a backed-up driver is reinstalled on the same machine and the device reports the restored version.
- [ ] Roll back a device to a recorded package as a repair-contract item. Done when: the rollback is a declared item with prior state captured and undo available.
- [ ] Verify by reading the device state back, never by trusting the install call. Done when: a deliberately suppressed install reports failed rather than succeeded.
- [ ] Surface devices reporting a problem, with their Device Manager error code. Done when: a device in an error state is listed with its code and the code is explained in plain words.
- [ ] Refuse by name without the privilege, and log every backup and rollback. Done when: an unelevated rollback is refused naming the device, and each action writes one line.
- [ ] State plainly that a rollback may require a restart, before the user commits. Done when: the statement appears on the surface.
- [ ] Commit: `"drivers: back up and roll back, never update"`

**Freeze check:** What this tool installs is the package it captured, unchanged. Evidence is a backup and restore cycle against a fixture driver producing an identical package hash.

**Test checkpoint:** The enumeration matches `pnputil /enum-drivers` entry by entry. A backed-up driver reinstalls and the device reports the restored version. A suppressed install reports failed. A device in an error state shows its code with a plain-words explanation. An unelevated rollback is refused by name.

## 3. Disk Health

Nothing in the suite answers the question a worried user actually has. Drive Repair handles removable media and PixRepair handles the screen; the disk holding everything they own has no owner.

**Fidelity:** the drive list and the health detail, against `DESIGN.md`.
**Job:** a user can find out whether their disk is failing, and act before it does. Consumer: the SMART data and the file system, read directly.
**Treatment:** SMART attributes interpreted into a plain-words verdict, with the raw values still available. Cheaper substitute that fails the checkpoint: a green or red light with no attributes, which a user cannot act on or verify.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] Enumerate physical drives with model, size, interface, and type. Done when: the list matches what Disk Management reports for the same machine.
- [ ] Read SMART attributes and present the ones that predict failure, in plain words, with raw values available. Done when: reallocated sectors, pending sectors, and power-on hours each render with an explanation.
- [ ] Give an overall verdict that is honest about uncertainty. Done when: the verdict distinguishes healthy, warning, failing, and unknown, and `unknown` is used when SMART is unavailable rather than reporting healthy.
- [ ] Run a `chkdsk` scan and show its progress and result. Done when: a read-only scan completes with its output rendered, and the window stays responsive throughout.
- [ ] Treat a repair scan as destructive: confirm, name the drive by letter, label, and size, and state that it may require a restart. Done when: the confirmation names all three and declining performs nothing.
- [ ] State plainly that a failing disk needs replacing, not repairing. Done when: a failing verdict says so on the surface, because no software fixes a dying drive.
- [ ] Commit: `"disk health: smart attributes and chkdsk"`

**Test checkpoint:** The drive list matches Disk Management. Three failure-predicting attributes render with plain-words explanations. Unavailable SMART reports unknown rather than healthy. A read-only scan completes with the window responsive. A repair scan confirms by letter, label, and size. A failing verdict states that replacement is the answer.

## 4. Crash Decoder

The sibling to `BiosCodes`, and it completes a story the suite half-tells: `BiosCodes` is for a machine that will not POST, this is for one that boots and then dies.

**Fidelity:** the crash list and the decoded detail, against `DESIGN.md` and the `BiosCodes` surface it parallels.
**Job:** a user can find out why their machine crashed and carry the answer to somebody who can help. Consumer: the minidump files, and the exported result.
**Treatment:** the stop code decoded into plain words with the implicated driver named where the dump allows. Cheaper substitute that fails the checkpoint: showing the hexadecimal stop code, which the user could already read off the blue screen.
**Chrome:** consume the framework. This tool changes nothing, so it does not consume the repair contract.
**Needs:** Windows host (build/test)

- [ ] Find and list crash dumps with their date, stop code, and dump type. Done when: a fixture dump directory renders completely and an empty one reports no crashes rather than an error.
- [ ] Decode the stop code into a plain-words explanation. Done when: a fixture set of common stop codes each render an explanation, and an unknown code says so rather than guessing.
- [ ] Name the implicated driver or module where the dump allows it. Done when: a fixture dump naming a driver renders it, and one that does not says the cause could not be determined.
- [ ] Export the decoded result as a file, written atomically and read back. Done when: the saved content matches the rendered result and a read-only target reports failure.
- [ ] Handle a corrupt or truncated dump. Done when: it is reported as unreadable rather than crashing the tool, driven against a deliberately truncated fixture.
- [ ] Commit: `"crash decoder: read and explain minidumps"`

**Test checkpoint:** A fixture dump directory renders completely; an empty one reports no crashes. Common stop codes each render an explanation and an unknown one says so. A dump naming a driver renders it. The export matches the rendered result and fails visibly on a read-only target. A truncated dump is reported unreadable.

## 5. File Unlocker

Windows tells a user their file is open in another program and then refuses to say which. This tool answers that, and it is the kind of small thing people remember a suite for.

**Fidelity:** the holder list and the action confirmation, against `DESIGN.md`.
**Job:** a user can find out what is holding a file and deal with it. Consumer: the process handle table, and the file system after the action.
**Treatment:** the holding processes named, with the user choosing what to do. Cheaper substitute that fails the checkpoint: force-closing handles without saying whose they are, which can lose a user's unsaved work.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] Find every process holding a handle to a given file or folder. Done when: a fixture file held open by a known process lists that process with its name, identifier, and path.
- [ ] Offer to close the handle or end the process, as separate choices with different consequences stated. Done when: both are available, each states its risk, and declining performs nothing.
- [ ] Warn before ending a process that may have unsaved work. Done when: the warning names the process and appears before the action, not after.
- [ ] Add the stubborn-file cases as a second surface: paths too long, and names Windows will not accept. Done when: a fixture with an over-long path and one with a reserved name are both handled, and this section records the mechanism used.
- [ ] Refuse by name without the privilege. Done when: an unelevated attempt against a protected process is refused naming the process.
- [ ] Log every handle closed and every process ended. Done when: each writes one line naming the file and the process.
- [ ] Commit: `"file unlocker: name what is holding a file, and free it"`

**Test checkpoint:** A fixture file held open lists the holding process with name, identifier, and path. Close-handle and end-process are separate choices with stated risks, and declining does nothing. An over-long path and a reserved name are both handled. An unelevated attempt on a protected process is refused by name. One log line per action.

## 6. System Report

The support workflow made real: instead of twenty questions in a forum thread, the user attaches one file.

**Fidelity:** the report preview and the export, against `DESIGN.md`.
**Job:** a user can hand somebody everything they need to help, in one file, without being asked for it piece by piece. Consumer: the exported report, read by a stranger.
**Treatment:** the report assembled from the machine and from the suite's own logs, with the user shown exactly what it contains before it leaves. Cheaper substitute that fails the checkpoint: a report generated and saved without a preview, which is how a tool ends up leaking something the user did not intend to share.
**Chrome:** consume the framework. `resolute_au3/SDK/Includes/CompInfo.au3` is prior art for what to collect.
**Needs:** Windows host (build/test)

- [ ] Collect the machine facts: Windows build, hardware, drives, and installed Resolute tools with their versions. Done when: a generated report carries all four and each is verified against an independent source.
- [ ] Include recent errors and the suite's own logs, bounded in size. Done when: the report includes them and a machine with enormous logs still produces a report of reasonable size.
- [ ] **Show the user what the report contains before it is written.** Done when: the preview renders the full content and the user can cancel.
- [ ] Decide and record what is deliberately excluded. Done when: the exclusion list exists and names anything identifying, with its reasoning, because this file is written to be handed to a stranger.
- [ ] Write it atomically and read it back. Done when: an export to a read-only target reports failure rather than claiming success.
- [ ] Keep it readable without any tool. Done when: it opens legibly in a plain text editor, captured.
- [ ] Commit: `"system report: one file that answers the first twenty questions"`

**Test checkpoint:** A generated report carries build, hardware, drives, and tool versions, each verified independently. A machine with enormous logs still produces a reasonable report. The preview renders the full content and can be cancelled. The exclusion list names what is withheld and why. The file opens legibly in a plain text editor.

## 7. Battery Health, Boot Options, and File Associations

Three small tools grouped because each is a single surface over a single system facility, and separating them into three sections would be ceremony rather than clarity.

**Fidelity:** each tool's main window, against `DESIGN.md`.
**Job:** a laptop user can see whether their battery is worn, a user can reach safe mode without memorising `bcdedit`, and a user can repair a broken file association. Consumer: the battery report, the boot configuration, and the association registry entries.
**Treatment:** boot options and associations both go through the repair contract, because both are changes to a running system that must be reversible. Cheaper substitute that fails the checkpoint: a `bcdedit` frontend with no undo, which is a way to make a machine unbootable with one click.
**Chrome:** consume the framework, and the repair contract for the two that change anything.
**Needs:** Windows host (build/test)

- [ ] Build Battery Health over the system battery report: design capacity, full-charge capacity, cycle count, and wear percentage. Done when: all four render on a laptop and the tool reports plainly that there is no battery on a desktop.
- [ ] Build Boot Options covering safe mode, driver signature enforcement, and boot logging, each as a repair-contract item. Done when: each is a declared item with prior state captured and undo available.
- [ ] Make every boot change reversible and say so before committing. Done when: each change states what it does, that it needs a restart, and how to undo it if the machine will not boot. Done when: that recovery instruction is on the surface, not only in documentation.
- [ ] Build File Association Repair: show the current handler for an extension and restore the Windows default. Done when: a deliberately broken association is repaired and verified by reading the handler back.
- [ ] Make association changes undoable through the contract. Done when: a repair followed by undo returns the handler to exactly what it was.
- [ ] Account for all three surfaces. Done when: three accounts are written and each deferral resolves.
- [ ] Commit: `"battery health, boot options, and file associations"`

**Freeze check:** What Boot Options writes to the boot configuration is frozen from the moment it ships, because a mistake there costs the user their machine. Evidence is a fixture boot-configuration change and undo reproducing the original entry exactly.

**Test checkpoint:** Battery Health renders four values on a laptop and reports no battery on a desktop. Each boot option is a declared contract item with undo, and each states its restart requirement and recovery path on the surface. A deliberately broken association is repaired and verified by read-back, and undo restores the previous handler exactly.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with every new tool's suite reporting
- [ ] Every tool in this file passes the conformance check and runs standalone in an empty folder
- [ ] Every tool that changes the system does so through the repair contract, with a working undo
- [ ] The Driver Manager contains no update path, proven by search
- [ ] Every freeze check in this file ran and passed
- [ ] `python scripts/todo-graph.py validate` clean
