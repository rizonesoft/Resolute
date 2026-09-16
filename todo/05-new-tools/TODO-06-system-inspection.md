---
schema_version: 1
id: system-inspection
domain: 05-new-tools
status: draft
title: "TODO-06 -- Inspection and Recovery Tools"
depends_on: [system-utilities]
frozen: true
track: P3
---

# TODO-06 -- Inspection and Recovery Tools

> **Goal:** Eleven tools that surface what Windows already knows and will not show you. Each answers a question a user genuinely has and no shipped Windows interface answers well, and each is built on the framework and the repair contract from its first commit.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** None of these exists. All are new development with no AutoIt counterpart and no parity check. Every tool here lives at `extensions/<Tool>/` per the source layout in `AGENTS.md` and builds as its own standalone executable.

> [!CAUTION]
> **Two tools in this file reveal stored secrets:** `§3` can recover a saved Wi-Fi key and `§7` shows entries from the Windows Credential Manager. Both are legitimate on a machine the user administers, and both are things Windows itself will show you through `netsh` or `rundll32`. That does not make them casual features.
>
> Each carries the same three requirements, written into its section: **elevation required at the reveal, one log line per reveal naming what was revealed, and no bulk export.** A tool that dumps every credential to a file is a credential-harvesting surface regardless of who wrote it, and this suite will not ship one.

## Inputs

- -> XREF: [`02-repair-contract/TODO-01 §4`](../02-repair-contract/TODO-01-repair-contract.md) -- the restore record every destructive tool here consumes
- -> XREF: [`05-new-tools/TODO-03 §1`](./TODO-03-system-utilities.md) -- the Restore Point Manager, which reads the same shadow copy store as `§1`
- -> XREF: [`03-launcher/TODO-01 §6`](../03-launcher/TODO-01-launcher.md) -- the symptom routing that makes fifty tools findable
- -> XREF: [`05-new-tools/TODO-07 §4`](./TODO-07-system-control.md) -- the configuration tools, which inherit §3's rule for revealing a secret

## Outcome

- A user can browse a shadow copy and retrieve a single previous version of a file.
- A user can find out why Windows itself is consuming disk space, as distinct from which of their files are large.
- A user can recover their own saved Wi-Fi key, diagnose the radio, and remove a user profile without breaking the machine.
- Broken icons and broken default apps have an obvious fix.
- Questions about the past that Windows records and never surfaces can be answered.
- No tool in this file exports a secret in bulk.

**Adjacency:** list=applicable @ D05 T06 §1; document=applicable @ D05 T06 §6; settings=not-applicable (these tools own no settings beyond the framework's); reporting=applicable @ D05 T06 §2; notifications=not-applicable (each is opened deliberately when something is wrong); permissions=applicable @ D05 T06 §3; audit=applicable @ D05 T06 §3; exchange=applicable @ D05 T06 §1; reverse=applicable @ D05 T06 §4

**Adjacency rationale:** Permissions and audit pair on §3 because that is where the suite's rule about revealing a secret is established, and the rule is only real if the reveal is both gated and recorded. List and exchange pair on §1 because a shadow copy is a store a user browses and pulls a file out of, which makes retrieval an export with a destination and an overwrite question. Reverse anchors on §4 because removing a user profile is the single least reversible thing in this file.

## Implementation Order

| Order | Section | Deliverable                                  | Depends On         | Status |
| :---: | :-----: | -------------------------------------------- | ------------------ | :----: |
|   1   |   §1    | Shadow Copy Browser                          | D05 T03 §1         |  [ ]   |
|   2   |   §2    | Windows Disk Space                           | D05 T01 §1         |  [ ]   |
|   3   |   §3    | Wi-Fi Diagnostics                            | D05 T01 §1         |  [ ]   |
|   4   |   §4    | Profile Manager                              | D02 T01 §4         |  [ ]   |
|   5   |   §5    | Icon Cache and Default Apps Repair           | D02 T01 §4         |  [ ]   |
|   6   |   §6    | Resource History and USB Device History      | D05 T01 §1         |  [ ]   |
|   7   |   §7    | Credential, Display, and Connection Viewers  | §3                 |  [ ]   |

---

## 1. Shadow Copy Browser

Windows keeps Volume Shadow Copies containing previous versions of a user's files, and the built-in Previous Versions tab is unreliable and frequently empty on machines where snapshots plainly exist. The data is there; the interface is not.

**Fidelity:** the snapshot list and the file browser, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user can look inside a snapshot and retrieve one file from it. Consumer: the retrieved file at its destination, verified after writing.
**Treatment:** the snapshot mounted read-only and browsed like a folder, with retrieval writing elsewhere. Cheaper substitute that fails the checkpoint: showing that snapshots exist without letting the user open one, which is the built-in interface's failure.
**Chrome:** consume the framework and the shared virtualized list. Read the same store as `D05 T03 §1` rather than a second enumerator.
**Needs:** Windows host (build/test)

- [ ] List every shadow copy with its volume, date, and origin, in `extensions/ShadowBrowser/`. Done when: a machine with snapshots lists them all and one with none says so rather than rendering empty.
- [ ] Mount a snapshot read-only and browse it. Done when: a snapshot's directory tree renders and no write path to the snapshot exists, proven by search.
- [ ] Retrieve a file to a destination the user chooses. Done when: the retrieved content matches the snapshot copy byte for byte, and an existing destination file is never silently overwritten.
- [ ] Compare a snapshot copy against the live file. Done when: a changed file shows that it differs and an unchanged one shows that it does not.
- [ ] Never delete a snapshot. Done when: this tool has no delete path at all, proven by search, because deleting the wrong snapshot destroys the only copy of something.
- [ ] Report honestly when shadow copies are disabled. Done when: the surface says so, explains the consequence, and points at `D05 T03 §1` to enable protection.
- [ ] Commit: `"shadow browser: open what previous versions will not"`

**Test checkpoint:** A machine with snapshots lists them with volume, date, and origin; one without says so. A snapshot browses and no write path to it exists, proven by search. A retrieved file matches byte for byte and never silently overwrites. The tool has no snapshot delete path, proven by search.

## 2. Windows Disk Space

Not a disk analyser. Those exist and are good. This answers the different question: **why is Windows itself consuming eighty gigabytes**, which no file-size treemap explains because the space is spread across component stores, caches, and reserved regions.

**Fidelity:** the space breakdown and the cleanup confirmation, against `DESIGN.md`.
**Job:** a user can see what Windows is holding and recover the parts that are safe to recover. Consumer: the freed space, measured before and after.
**Treatment:** each category explained in plain words with its risk stated, because some of these are genuinely unsafe to remove. Cheaper substitute that fails the checkpoint: a list of sizes with a delete button, which is how somebody removes `Windows.old` on day nine and loses their rollback.
**Chrome:** consume the framework and the repair contract for anything it removes.
**Needs:** Windows host (build/test)

- [ ] Measure each category in `extensions/WindowsDiskSpace/`: component store, hibernation file, page file, `Windows.old`, Reserved Storage, delivery optimisation cache, and update cache. Done when: each renders with a size verified against an independent measurement.
- [ ] Explain each in plain words, with what is lost by removing it. Done when: `Windows.old` states that removing it ends the ability to roll back the last feature update, on the surface, before the user commits.
- [ ] State the deadline where one exists. Done when: `Windows.old` shows the date Windows will remove it automatically.
- [ ] Make each removal a repair-contract item with an honest reversibility answer. Done when: every category declares whether it can be undone, and most honestly declare that they cannot.
- [ ] Use the supported mechanism for each category rather than deleting files directly. Done when: the component store uses the documented cleanup path and this section names what was used per category.
- [ ] Measure the space actually recovered. Done when: before and after figures are reported and match the reclaimed total.
- [ ] Commit: `"windows disk space: explain what windows is holding"`

**Test checkpoint:** Every category renders with a size verified independently. `Windows.old` states the rollback consequence and its automatic removal date on the surface. Each removal is a declared contract item with an honest reversibility answer. Recovered space is measured before and after and matches the reported total.

## 3. Wi-Fi Diagnostics

`ComIntRep` repairs the network stack and never touches the radio. This covers the layer beneath it, including the single most searched Windows networking task: recovering the key for a network the machine already knows.

**Fidelity:** the network list and the reveal confirmation, against `DESIGN.md`.
**Job:** a user can see their saved networks, recover their own key, and find out why a connection will not hold. Consumer: the wireless configuration, read directly.
**Treatment:** the reveal gated, recorded, and one network at a time. Cheaper substitute that fails the checkpoint: a button that exports every saved key to a file, which turns a diagnostic into a harvesting tool.
**Chrome:** consume the framework, its elevation guard, and its logging.
**Needs:** Windows host (build/test)

- [ ] List saved networks with their security type, band, and last connection, in `extensions/WiFiDiagnostics/`. Done when: the list matches what the system reports for the same machine.
- [ ] **Gate the key reveal behind the framework's elevation guard**, at the reveal itself. Done when: an unelevated reveal is refused by name and no key is read.
- [ ] **Log every reveal, one line, naming the network.** Done when: a driven reveal produces exactly one line and the line names the network but never the key.
- [ ] **Refuse bulk export.** Done when: the tool reveals one network at a time on explicit request, has no export-all path, proven by search, and this section records the rule.
- [ ] Report signal quality, band, and channel for the current connection. Done when: all three render and a machine with no wireless adapter says so rather than rendering empty.
- [ ] Diagnose why a connection fails, across authentication, DHCP, DNS, and driver state. Done when: a fixture failure in each category is attributed correctly and names the failing step.
- [ ] Hand off to `ComIntRep` when the fault is above the radio. Done when: the hand-off works and carries what was already diagnosed.
- [ ] Commit: `"wifi diagnostics: the layer below the network stack"`

**Test checkpoint:** The saved-network list matches the system's for the same machine. An unelevated reveal is refused by name with no key read. A driven reveal writes exactly one log line naming the network and not the key. No export-all path exists, proven by search. A fixture failure in each diagnostic category is attributed correctly.

## 4. Profile Manager

Removing a Windows user profile correctly means the folder, the `ProfileList` registry entry, and the SID all going together. Doing it wrong leaves a machine that silently creates a temporary profile at every logon, which is one of the more miserable Windows failures to diagnose.

**Fidelity:** the profile list and the removal confirmation, against `DESIGN.md`.
**Job:** a user can see every profile on the machine, identify orphans, and remove one without breaking logon. Consumer: the profile store and the registry, read back after the change.
**Treatment:** all three parts removed together, or nothing removed. Cheaper substitute that fails the checkpoint: deleting the folder, which is exactly what produces the temporary-profile failure.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] List every profile in `extensions/ProfileManager/` with its account, SID, path, size, and last use. Done when: the list matches `ProfileList` and the profile directory, compared entry by entry.
- [ ] Identify orphans: a profile whose account no longer exists. Done when: a fixture orphan is flagged with its reasoning and a live profile is not.
- [ ] Make removal atomic across folder, registry entry, and SID. Done when: a fixture removal takes all three, and a removal that cannot complete takes none, proven by interrupting it.
- [ ] Capture prior state through the repair contract before removing. Done when: the record names the profile path, the registry entry, and the SID.
- [ ] Refuse to remove a profile in use, or the last administrator. Done when: both are refused by name and nothing changes.
- [ ] State plainly that the user's files go with it. Done when: the confirmation names the profile path and its size, and declining performs nothing.
- [ ] Commit: `"profile manager: remove a profile without breaking logon"`

**Freeze check:** What a removal deletes is frozen once shipped, because it takes a user's files. Evidence is a fixture profile removed and compared against its recorded state, entry by entry.

**Test checkpoint:** The profile list matches `ProfileList` and the profile directory entry by entry. A fixture orphan is flagged with reasoning; a live profile is not. An interrupted removal takes nothing, proven by interrupting it. A profile in use and the last administrator are both refused by name. The confirmation names path and size.

## 5. Icon Cache and Default Apps Repair

Two small tools for two classic annoyances whose fixes are obscure enough that people reinstall Windows over them.

**Fidelity:** each tool's surface, against `DESIGN.md`.
**Job:** a user with blank or wrong icons, or with a broken default browser, has an obvious fix. Consumer: the caches and the association registry, read back after the change.
**Treatment:** both changes made through the repair contract so both are undoable, because a default-apps reset changes things a user chose deliberately. Cheaper substitute that fails the checkpoint: resetting every association to the Windows default without recording what was there.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] Rebuild the icon and thumbnail caches in `extensions/IconCacheRepair/`, restarting Explorer as part of the operation. Done when: a machine with a deliberately corrupted cache renders correct icons afterwards, captured before and after.
- [ ] Warn that Explorer will restart, and what that closes. Done when: the warning appears before the user commits.
- [ ] Repair default apps and protocol handlers in `extensions/DefaultAppsRepair/`, covering `http`, `https`, `mailto`, and the common file types. Done when: a deliberately broken handler is repaired and verified by reading it back.
- [ ] Capture prior handlers before changing them. Done when: undo restores each handler to exactly what it was, asserted.
- [ ] Repair only what is broken, not everything. Done when: a handler the user deliberately set to a third-party application is left alone unless explicitly selected.
- [ ] Commit: `"icon cache and default apps: two obscure fixes made obvious"`

**Test checkpoint:** A corrupted icon cache renders correctly after repair, captured before and after, with the Explorer restart warned about beforehand. A broken protocol handler is repaired and verified by read-back, and undo restores it exactly. A deliberately chosen third-party handler is left alone.

## 6. Resource History and USB Device History

Two tools answering questions about the past. Windows records both and surfaces neither.

**Fidelity:** each tool's list and detail, against `DESIGN.md`.
**Job:** a user can find out what was consuming the machine when they were not watching, and what has ever been plugged into it. Consumer: the recorded history, read back.
**Treatment:** the resource recorder costing less than what it measures. Cheaper substitute that fails the checkpoint: a sampler heavy enough to appear in its own results.
**Chrome:** consume the framework. Neither tool changes the system, so neither consumes the repair contract.
**Needs:** Windows host (build/test)

- [ ] Record process CPU, disk, and memory over time in `extensions/ResourceHistory/`, at an interval the user controls. Done when: a recorded period renders per process and the recorder's own cost is measured and quoted.
- [ ] Make the recorder optional and off by default. Done when: it is enabled explicitly, its storage is bounded, and disabling it stops all recording.
- [ ] Answer the question the tool exists for. Done when: selecting a time range names what was consuming the machine during it.
- [ ] List every USB device ever connected in `extensions/USBHistory/`, with description, serial where present, and first and last connection. Done when: a machine's list is cross-checked against its registry entries.
- [ ] Explain what the record can and cannot establish. Done when: the surface states that a device with no serial cannot be distinguished from another of the same model.
- [ ] Neither tool writes to the system. Done when: neither has a write path, proven by search.
- [ ] Commit: `"resource and usb history: what windows records and hides"`

**Test checkpoint:** A recorded period renders per process, with the recorder's own cost measured and quoted. The recorder is off by default, bounded, and stops fully when disabled. Selecting a range names the consumer. The USB list is cross-checked against registry entries. Neither tool has a write path, proven by search.

## 7. Credential, Display, and Connection Viewers

Three read-only inspectors, grouped because each is a single surface over one thing Windows knows and reports badly.

**Fidelity:** each tool's surface, against `DESIGN.md`.
**Job:** a user can see their stored credentials, their display configuration, and what their machine is connected to. Consumer: the credential store, the display configuration, and the connection table, all read directly.
**Treatment:** the credential viewer held to the same rule as `§3`: gated, recorded, one at a time, never bulk. Cheaper substitute that fails the checkpoint: a credential list that shows every secret at once, which is a harvesting surface however it is labelled.
**Chrome:** consume the framework, its elevation guard, and its logging. All three are read-only.
**Needs:** Windows host (build/test)

- [ ] List stored credentials in `extensions/CredentialViewer/` by target, type, and user, **without revealing any secret by default**. Done when: the list renders with every secret masked.
- [ ] **Gate, log, and limit the reveal**, exactly as `§3` requires. Done when: an unelevated reveal is refused by name, a driven reveal writes one log line naming the target but not the secret, and no reveal-all path exists, proven by search.
- [ ] Report which credentials are causing repeated sign-in prompts, where the system records it. Done when: a stale credential is identified with its reasoning.
- [ ] Report display configuration in `extensions/DisplayInfo/`: connected monitors, resolution, refresh rate, connection type, colour profile, and EDID identity. Done when: each renders for a multi-monitor machine and is verified against the system.
- [ ] Report active connections in `extensions/ConnectionViewer/` with the owning process, its path, and its publisher. Done when: a known connection resolves to the right process and its signature state is shown.
- [ ] Compose rather than re-enumerate. Done when: the connection viewer names a process's startup entry by asking the autoruns enumerator from `D05 T01 §5`, and implements no second one, proven by search.
- [ ] None of the three writes to the system. Done when: no write path exists in any of them, proven by search.
- [ ] Commit: `"credential, display, and connection viewers"`

**Test checkpoint:** The credential list renders with every secret masked. An unelevated reveal is refused by name; a driven reveal writes one log line naming the target and not the secret; no reveal-all path exists, proven by search. Display configuration is verified against the system on a multi-monitor machine. A known connection resolves to the right process with its signature state. None of the three has a write path, proven by search.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with every suite in this file reporting
- [ ] Every tool here passes the conformance check and runs standalone in an empty folder
- [ ] No tool in this file exports a secret in bulk, proven by search across all of them
- [ ] Every reveal of a secret is gated by elevation and produces exactly one log line
- [ ] The read-only tools have no write path, proven by search
- [ ] Every freeze check in this file ran and passed
- [ ] `python scripts/todo-graph.py validate` clean
