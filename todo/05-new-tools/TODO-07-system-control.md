---
schema_version: 1
id: system-control
domain: 05-new-tools
status: draft
title: "TODO-07 -- System Control and Configuration"
depends_on: [system-inspection]
frozen: true
track: P3
---

# TODO-07 -- System Control and Configuration

> **Goal:** Thirty tools covering the configuration surfaces Windows either hides, exposes badly, or has stopped serving. The first three answer needs that research on 2026-09-16 found documented and currently unmet.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** None of these exists. All are new development at `extensions/<Tool>/` per the source layout in `AGENTS.md`.
>
> **Three are backed by research rather than intuition.** Microsoft has retired `wushowhide.diagcab`, and even where it still runs, hidden updates reappear after a feature update or a metadata change; the official alternatives are Group Policy and Intune, neither available to a home user, against a backdrop of more than twenty major Windows 11 update problems during 2025 and a poor start to 2026. Microsoft identifies File Explorer as a performance bottleneck, and shell extensions are the usual crash cause: `ShellExView` already lists them well, so the gap is not the listing but the **method**, since every published guide reduces to disabling extensions by hand one at a time and restarting Explorer between each.

> [!CAUTION]
> **Several tools here change security posture.** `§3` manages Defender exclusions, `§4` surfaces a BitLocker recovery key, and `§5` alters privacy and telemetry settings. Each carries the rule established in `D05 T06`: elevation at the action, one log line, no bulk export of anything secret, and a refusal to make a change that weakens protection without saying plainly what it weakens.

## Inputs

- -> XREF: [`02-repair-contract/TODO-01 §4`](../02-repair-contract/TODO-01-repair-contract.md) -- the restore record every configuration change here consumes
- -> XREF: [`05-new-tools/TODO-06 §3`](./TODO-06-system-inspection.md) -- the reveal rule this file inherits for secrets
- -> XREF: [`03-launcher/TODO-01 §6`](../03-launcher/TODO-01-launcher.md) -- the symptom routing that makes these findable

## Outcome

- A user can stop a specific Windows update from installing, and have it stay stopped.
- A machine whose Explorer crashes can find the culprit without disabling extensions by hand.
- The configuration surfaces Windows hides behind policy editors and command lines have interfaces.
- Printing, search, and scheduled tasks have interfaces that explain a failure rather than restarting a service and hoping.
- Every change made by a tool in this file is recorded and reversible.

**Adjacency:** list=applicable @ D05 T07 §1; document=applicable @ D05 T07 §8; settings=applicable @ D05 T07 §6; reporting=applicable @ D05 T07 §2; notifications=applicable @ D05 T07 §1; permissions=applicable @ D05 T07 §3; audit=applicable @ D05 T07 §3; exchange=applicable @ D05 T07 §7; reverse=applicable @ D05 T07 §6

**Adjacency rationale:** Permissions and audit pair on §3 because that section weakens a security product on request, which is exactly the action that must be gated and recorded or not offered at all. Reverse anchors on §6 because the configuration editors there change things a user chose deliberately, so restoring the previous value matters more than in a repair that fixes something already broken.

## Implementation Order

| Order | Section | Deliverable                                       | Depends On     | Status |
| :---: | :-----: | ------------------------------------------------- | -------------- | :----: |
|   1   |   §1    | Update Blocker and Update History                 | D02 T01 §4     |  [ ]   |
|   2   |   §2    | Shell Extension Bisector and Explorer Performance | D05 T01 §5     |  [ ]   |
|   3   |   §3    | Defender Manager and Security Status              | D02 T01 §4     |  [ ]   |
|   4   |   §4    | BitLocker, Certificates, and Recovery             | §3             |  [ ]   |
|   5   |   §5    | Privacy and Telemetry Settings                    | D02 T01 §4     |  [ ]   |
|   6   |   §6    | Environment, Features, Power, and Locale          | D02 T01 §4     |  [ ]   |
|   7   |   §7    | Network Configuration Tools                       | D02 T01 §4     |  [ ]   |
|   8   |   §8    | Files, Boot, Audio, and Inventory                 | D02 T01 §4     |  [ ]   |
|   9   |   §9    | Printing, Search, and Scheduled Tasks             | D02 T01 §4, D05 T01 §5 |  [ ]   |

---

## 1. Update Blocker and Update History

Microsoft retired the tool that did this, its replacement is an enterprise product, and hidden updates reappear anyway. Meanwhile 2025 carried more than twenty major update problems. This is the clearest documented gap the research found.

**Fidelity:** the update list and the block confirmation, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user can stop one update from installing and have it stay stopped, and can see what has already been installed. Consumer: the update state, read back after the block.
**Treatment:** the block re-asserted after the events that historically undo it. Cheaper substitute that fails the checkpoint: hiding an update once, which is precisely what `wushowhide` did and why it stopped working.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] List available and installed updates in `extensions/UpdateBlocker/` with title, KB number, size, and date. Done when: the list matches what Windows Update reports for the same machine.
- [ ] Block a specific update, as a repair-contract item so it is reversible. Done when: a blocked update does not install and unblocking restores it, both driven.
- [ ] **Re-assert the block after the events that historically break it.** Done when: the block survives a feature update and an update-metadata change, and this section records the mechanism used and why it outlasts `wushowhide`.
- [ ] Report when a block cannot be honoured. Done when: an update Windows installs regardless is reported as such rather than appearing blocked, because a false sense of control is worse than none.
- [ ] Show update history with what each update changed where Windows records it. Done when: history renders in `extensions/UpdateHistory/` and cross-references the `System Change Journal` where a snapshot spans the install.
- [ ] Offer to uninstall a specific update. Done when: uninstall is a contract item, verified by reading the update state back, and an update Windows will not let you remove says so.
- [ ] Commit: `"update blocker: stop one update, and have it stay stopped"`

**Test checkpoint:** The list matches Windows Update for the same machine. A blocked update does not install; unblocking restores it. The block survives a feature update and a metadata change, with the mechanism recorded. An unblockable update is reported rather than shown as blocked. Uninstall is verified by read-back.

## 2. Shell Extension Bisector and Explorer Performance

`ShellExView` lists shell extensions well and this does not compete with it. The gap is that every published fix reduces to "disable them one at a time and restart Explorer between each", which is a manual binary search a computer should run.

**Fidelity:** the bisection progress surface and the result, against `DESIGN.md`.
**Job:** a user whose Explorer crashes or hangs finds the responsible extension without doing the search by hand. Consumer: the extension state, read back, and Explorer's observed behaviour.
**Treatment:** an automated bisection that halves the candidate set each round. Cheaper substitute that fails the checkpoint: listing extensions and leaving the user to bisect, which is the state of the art this exists to replace.
**Chrome:** consume the framework, the repair contract, and the shell-extension enumerator from `D05 T01 §5`. Write no second enumerator.
**Needs:** Windows host (build/test)

- [ ] Implement bisection in `extensions/ShellBisector/`: disable half the non-Microsoft extensions, restart Explorer, ask whether the fault persists, narrow. Done when: a fixture set of sixteen with one deliberately faulty is narrowed in at most five rounds.
- [ ] Make every round reversible, through the repair contract. Done when: abandoning a bisection mid-run restores every extension to its starting state, asserted.
- [ ] Never leave the machine in a bisected state. Done when: the tool restores everything on exit unless the user explicitly keeps a finding, and a forced termination mid-round still restores, proven by killing it.
- [ ] Report the culprit with the software that owns it. Done when: the finding names the extension, its file, and the installed application it belongs to.
- [ ] Measure Explorer responsiveness in `extensions/ExplorerPerformance/`: folder open time, right-click menu time, and thumbnail generation. Done when: each is measured and compared against a stated expectation.
- [ ] Attribute slowness where the system allows. Done when: a deliberately slowed fixture handler is identified, or this section states plainly what could not be attributed and why.
- [ ] Commit: `"shell bisector: run the search the guides tell users to do by hand"`

**Test checkpoint:** A fixture set of sixteen extensions with one faulty is narrowed in at most five rounds. Abandoning mid-run restores every extension, asserted. Killing the process mid-round still restores. The finding names extension, file, and owning application. Explorer timings are measured against a stated expectation.

## 3. Defender Manager and Security Status

Windows Defender's exclusion list is where malware hides and where legitimate software gets wrongly blocked, and Windows surfaces it three levels deep in a settings app that changes shape every release.

**Fidelity:** the status surface and the exclusion confirmation, against `DESIGN.md`.
**Job:** a user can see what their security software is actually doing and change an exclusion knowingly. Consumer: the Defender configuration, read back after any change.
**Treatment:** every change that weakens protection stated in those terms before it is made. Cheaper substitute that fails the checkpoint: presenting an exclusion as a neutral setting, which is how a support article turns into a malware persistence technique.
**Chrome:** consume the framework, its elevation guard, and the repair contract.
**Needs:** Windows host (build/test)

- [ ] Report Defender status in `extensions/DefenderManager/`: real-time protection, cloud protection, tamper protection, and definition age. Done when: each renders and is verified against the system.
- [ ] Say why protection is off where the system records it, distinguishing user choice, policy, and a third-party product taking over. Done when: all three are distinguishable and a fixture of each is attributed correctly.
- [ ] List exclusions with what added them where that is recorded. Done when: paths, extensions, and processes all render.
- [ ] **State plainly what an exclusion gives up**, before it is added. Done when: the confirmation says the excluded path will not be scanned, and adding is a contract item so it is reversible.
- [ ] Flag exclusions that look wrong. Done when: an exclusion covering a whole drive, a user profile root, or a system directory is flagged with its reasoning.
- [ ] Report the wider security posture in `extensions/SecurityStatus/`: firewall state, UAC level, SmartScreen, and Core Isolation. Done when: each renders and a machine with any of them off explains the consequence.
- [ ] Commit: `"defender manager: see what your security software is doing"`

**Test checkpoint:** Defender status renders and is verified against the system. User choice, policy, and third-party takeover are distinguishable on fixtures. An exclusion states what it gives up before being added and is reversible. A whole-drive exclusion is flagged. Security posture renders with consequences stated.

## 4. BitLocker, Certificates, and Recovery

Three tools for the moments a machine is least recoverable: an encrypted drive with a missing key, a broken certificate chain, and a recovery environment that is not there when it is needed.

**Fidelity:** each tool's surface, against `DESIGN.md`.
**Job:** a user can find their recovery key before they need it, see why HTTPS is failing, and confirm their machine can still repair itself. Consumer: the BitLocker configuration, the certificate stores, and the recovery partition, all read directly.
**Treatment:** the recovery key **located**, never displayed casually or exported. Cheaper substitute that fails the checkpoint: printing every recovery key to a file, which converts a disk-encryption tool into a way to defeat disk encryption.
**Chrome:** consume the framework, its elevation guard, and its logging.
**Needs:** Windows host (build/test)

- [ ] Report BitLocker status per volume in `extensions/BitLockerStatus/`: protection state, method, and where the recovery key is escrowed. Done when: each renders and a volume with no escrow is flagged, because that is the dangerous case.
- [ ] Gate, log, and limit any key reveal exactly as `D05 T06 §3` requires. Done when: an unelevated reveal is refused by name, one log line names the volume and not the key, and no export-all path exists, proven by search.
- [ ] Inspect the certificate stores in `extensions/CertificateManager/`: expired roots, untrusted intermediates, and anything that would break HTTPS. Done when: a fixture expired root is flagged with what it affects.
- [ ] Hand off to `ComIntRep`'s pre-flight where a certificate fault is the real cause. Done when: the hand-off works and carries the finding.
- [ ] Report the recovery environment in `extensions/RecoveryManager/`: whether WinRE is present, enabled, and reachable. Done when: a machine with a broken or missing WinRE is reported as such, which most users discover only when they need it.
- [ ] Create a recovery drive, with what it will erase named first. Done when: the confirmation names the target by letter, label, and size, and declining performs nothing.
- [ ] Commit: `"bitlocker, certificates, and recovery: the tools you need before you need them"`

**Freeze check:** What recovery drive creation writes to a target is frozen once shipped, because it erases that target. Evidence is a fixture target compared before and after against its recorded state. Fixture source: `tests/fixtures/drives/`.

**Test checkpoint:** BitLocker status renders per volume with unescrowed volumes flagged. A key reveal is gated, logged without the key, and has no export-all path, proven by search. An expired root is flagged with what it affects. A broken WinRE is reported. Recovery drive creation names the target by letter, label, and size.

## 5. Privacy and Telemetry Settings

The research found forced diagnostics and telemetry among the things Microsoft is not addressing. This is also the most politically loaded tool in the suite and the one most likely to be wrong next year, so it is built to be honest rather than opinionated.

**Fidelity:** the settings surface, against `DESIGN.md`.
**Job:** a user can see what their machine reports and change it, understanding what each change costs. Consumer: the privacy configuration, read back after any change.
**Treatment:** every setting stating what turning it off actually loses. Cheaper substitute that fails the checkpoint: a list of toggles with a "harden everything" button, which is how a privacy tool breaks Windows Update and search for people who did not know what they were agreeing to.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] List the settings in `extensions/PrivacySettings/` with their current state and where each is controlled. Done when: user setting, policy, and unavailable-on-this-edition are distinguishable.
- [ ] **State the cost of each change** before it is made. Done when: every setting says what stops working, and anything that affects Windows Update or search says so prominently.
- [ ] Make every change a repair-contract item. Done when: undo restores the previous value exactly, asserted.
- [ ] Refuse to offer changes that break the machine. Done when: settings known to break Update, activation, or search are either not offered or carry an explicit warning, and this section records which and why.
- [ ] Keep the tool current rather than opinionated. Done when: the setting list is data rather than code, so a Windows release that moves a setting is a data change.
- [ ] Commit: `"privacy settings: state what each change costs"`

**Test checkpoint:** Settings render with user, policy, and edition-unavailable distinguishable. Every change states its cost before being made. Undo restores the previous value exactly, asserted. Settings that break Update, activation, or search are refused or warned, with the list recorded. The setting list is data, proven by adding one without a code change.

## 6. Environment, Features, Power, and Locale

Four configuration surfaces Windows ships with interfaces that are worse than no interface: a two-line environment variable box, an optional-features list that gives no progress, a power plan editor buried in legacy Control Panel, and a locale system whose failure mode is unreadable text.

**Fidelity:** each tool's surface, against `DESIGN.md`.
**Job:** a user can edit these without fighting the interface or resorting to a command line. Consumer: each configuration, read back after the change.
**Treatment:** each change made through the repair contract, because these are settings a user chose deliberately and losing one is worse than a failed repair. Cheaper substitute that fails the checkpoint: editing `PATH` with no backup, which is a well-known way to make a machine unusable.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] Build `extensions/EnvironmentEditor/` with one row per entry, reorderable, and duplicate and missing-path detection. Done when: a broken `PATH` entry is flagged, editing is undoable, and the prior value is recorded before any write.
- [ ] Build `extensions/WindowsFeatures/` over optional components, with real progress. Done when: enabling and disabling a feature both report progress and verify by reading the feature state back.
- [ ] Build `extensions/PowerPlans/` covering plans and the settings Windows hides from the modern interface. Done when: a hidden setting is exposed and changing it verifies by read-back.
- [ ] Build `extensions/LocaleFixer/` for the mojibake case: system locale, ANSI code page, and the legacy Unicode setting. Done when: a machine displaying unreadable text in legacy applications is diagnosed and the responsible setting named.
- [ ] Make every change in all four reversible through the contract. Done when: four undo assertions run.
- [ ] Commit: `"environment, features, power, and locale editors"`

**Test checkpoint:** A broken `PATH` entry is flagged and editing is undoable with the prior value recorded. Feature enable and disable both report progress and verify by read-back. A hidden power setting is exposed and verified. A mojibake machine is diagnosed and the setting named. Four undo assertions run.

## 7. Network Configuration Tools

`ComIntRep` repairs the stack and `Wi-Fi Diagnostics` covers the radio. These four cover the configuration between them, which Windows exposes only through `netsh` and a Control Panel page that has not changed since Windows 7.

**Fidelity:** each tool's surface, against `DESIGN.md`.
**Job:** a user can see and change the network configuration that decides where their traffic goes. Consumer: the network configuration, read back after the change.
**Treatment:** rule and adapter changes made through the repair contract, because a wrong firewall rule can remove a machine from the network it is being fixed over. Cheaper substitute that fails the checkpoint: applying a rule with no undo on a machine reached remotely.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] Build `extensions/FirewallRules/` listing rules with program, direction, profile, and what created them. Done when: the list matches what the system reports and a rule's owning program is named where recorded.
- [ ] Flag rules that look wrong. Done when: an inbound allow-any rule is flagged with its reasoning.
- [ ] Build `extensions/AdapterManager/` covering adapter state, binding order, and interface metrics. Done when: changing a metric verifies by read-back and is undoable.
- [ ] Build `extensions/DNSSelector/`, measuring resolver latency from this machine and offering to switch. Done when: measurements are taken from the actual machine rather than quoted, and switching is undoable.
- [ ] Build `extensions/ProxyInspector/`, reporting system proxy, per-application proxy, PAC scripts, and VPN state. Done when: a machine behind a proxy reports all of it and the source of each is named.
- [ ] Protect the remote case. Done when: a change that would break the connection the tool is being used over is warned about before it is applied, and this section records how that is detected.
- [ ] Commit: `"network configuration: firewall, adapters, dns, and proxy"`

**Freeze check:** What a rule or adapter change writes is frozen once shipped, because a wrong one removes a machine from the network it is being repaired over. Evidence is a fixture configuration round-tripped through change and undo, compared field by field. Fixture source: `tests/fixtures/network/`.

**Test checkpoint:** The firewall list matches the system with owning programs named. An inbound allow-any rule is flagged. A metric change verifies by read-back and is undoable. DNS latency is measured from the machine, not quoted. A proxied machine reports every layer with its source. A connection-breaking change is warned about first.

## 8. Files, Boot, Audio, and Inventory

Nine smaller tools, grouped because each is one surface over one thing, and separating them into nine sections would be ceremony.

**Fidelity:** each tool's surface, against `DESIGN.md`.
**Job:** the remaining everyday gaps have an interface. Consumer: each underlying configuration, read back after any change.
**Treatment:** the ones that change something go through the repair contract; the ones that only report have no write path at all. Cheaper substitute that fails the checkpoint: a reporting tool that grows a fix button without growing an undo.
**Chrome:** consume the framework, and the repair contract only where a tool changes something.
**Needs:** Windows host (build/test)

- [ ] `extensions/LinkManager/`: create and inspect junctions, symlinks, and hard links, which Windows offers only through `mklink`. Done when: each type is created and identified, and a broken link is reported as broken.
- [ ] `extensions/PermissionsCopier/`: copy an ACL from one path to another, with a preview. Done when: the preview lists every change before applying and the apply is undoable.
- [ ] `extensions/HashVerifier/`: compute and compare file hashes against an expected value. Done when: a matching and a mismatching file are each reported clearly.
- [ ] `extensions/LongPathEnabler/`: report and set the long-path setting, including the manifest requirement most guides omit. Done when: the setting is changed, verified by read-back, and the surface states that applications must opt in too.
- [ ] `extensions/BootManager/`: boot entries, order, and timeout, as contract items. Done when: a change verifies by read-back and undo restores the entry exactly.
- [ ] `extensions/PageFileManager/`: page file location and size per volume. Done when: a change verifies by read-back and states that it needs a restart.
- [ ] `extensions/AudioDevices/`: default device per role, per-application routing, and devices Windows has hidden. Done when: a hidden device is surfaced and setting a default verifies by read-back.
- [ ] `extensions/ColorProfiles/`: profiles per display, with association and reset. Done when: association and reset both verify by read-back.
- [ ] `extensions/SoftwareInventory/`: installed software with version, publisher, size, and install date, exportable into the System Report. Done when: the list matches what the system reports and the export feeds `D05 T03 §6`.
- [ ] Commit: `"link, permissions, hash, boot, page file, audio, colour, and inventory tools"`

**Freeze check:** What `BootManager` writes to the boot configuration is frozen once shipped, because a mistake there costs the user their machine. Evidence is a fixture boot entry changed and undone, reproducing the original exactly, entry for entry. Fixture source: `tests/fixtures/boot/`.

**Test checkpoint:** Each link type is created and identified and a broken link is reported. The permissions preview lists every change before applying and is undoable. Matching and mismatching hashes are both reported clearly. Long path is set, verified, and the opt-in requirement stated. Boot, page file, audio, and colour changes each verify by read-back. The inventory matches the system and feeds the System Report.

## 9. Printing, Search, and Scheduled Tasks

Three surfaces where Windows ships an interface so poor that the usual advice is to avoid it. Printing is split across three separate places, Task Scheduler is legendarily unusable, and search failure is a top-ranked complaint with no interface that explains it.

**Fidelity:** each tool's surface, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user whose printer will not print, whose search finds nothing, or who needs to see and edit a scheduled task can do so without three Control Panel pages or a management console. Consumer: the print subsystem, the index, and the task store, each read back after any change.
**Treatment:** each tool diagnoses before it offers to change anything, because all three of these fail for several unrelated reasons and a blind fix is as likely to make things worse. Cheaper substitute that fails the checkpoint: a restart-the-service button labelled as a repair, which is the whole of most published printing advice.
**Chrome:** consume the framework and the repair contract. Take scheduled-task enumeration from `D05 T01 §5` rather than writing a second one.
**Needs:** Windows host (build/test)

- [ ] Build `extensions/PrinterManager/`: printers, queues, drivers, and ports in one place, with the stuck-job case handled. Done when: a stuck queue is cleared, verified by reading the queue back, and the spooler restart it needs is part of the operation rather than a separate instruction.
- [ ] Diagnose why a printer will not print across its real causes: spooler state, driver, port, offline status, and a queue blocked by one failed job. Done when: a fixture failure in each category is attributed correctly and names the failing step.
- [ ] Remove a printer and its driver together. Done when: removal takes the queue, the printer, and the driver package, and a driver still in use by another printer is refused by name.
- [ ] Build `extensions/SearchManager/`: index status, size, what is indexed, and what is excluded. Done when: each renders and a machine mid-rebuild reports progress rather than appearing broken.
- [ ] Answer the question users actually ask, which is why a specific file is not found. Done when: a file outside the indexed locations, one excluded by type, and one in a location the indexer cannot read are each diagnosed distinctly.
- [ ] Rebuild the index as a repair-contract item, stating what it costs. Done when: the confirmation says search will be incomplete until the rebuild finishes and gives an estimate, because a silent multi-hour rebuild is how a repair looks like a break.
- [ ] Build `extensions/TaskManager/` over scheduled tasks: view, create, edit, enable, and disable, with the triggers and conditions Task Scheduler buries. Done when: a task is created, its trigger fires, and editing it verifies by reading the task back.
- [ ] Make every task change a contract item. Done when: undo restores the task definition exactly, asserted against a fixture task.
- [ ] Flag tasks that look wrong. Done when: a task running from a temporary directory, or one whose executable no longer exists, is flagged with its reasoning.
- [ ] Commit: `"printer, search, and scheduled task managers"`

**Freeze check:** What `TaskManager` writes to a task definition is frozen once shipped, because a malformed definition can stop a task a machine depends on. Evidence is a fixture task round-tripped through edit and undo, compared field by field. Fixture source: `tests/fixtures/tasks/`.

**Test checkpoint:** A stuck print queue is cleared and verified by read-back. A fixture printing failure in each category is attributed correctly. Driver removal refuses a driver still in use, by name. Index status renders and a rebuild reports progress. Three distinct not-found causes are diagnosed distinctly. A created task's trigger fires and editing verifies by read-back. Undo restores a task definition exactly, asserted. A task running from a temporary directory is flagged.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with every suite in this file reporting
- [ ] Every tool here passes the conformance check and runs standalone in an empty folder
- [ ] Every tool that changes the system does so through the repair contract, with a working undo
- [ ] No tool here exports a secret in bulk, proven by search
- [ ] Every change that weakens security, or that could break the connection it is made over, is stated before it is applied
- [ ] Every freeze check in this file ran and passed, covering recovery drive creation, network changes, boot entries, and task definitions
- [ ] `python scripts/todo-graph.py validate` clean
