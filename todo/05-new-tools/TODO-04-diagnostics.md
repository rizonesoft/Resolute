---
schema_version: 1
id: diagnostics
domain: 05-new-tools
status: draft
title: "TODO-04 -- Diagnostics and Forensics"
depends_on: [system-utilities]
track: P3
---

# TODO-04 -- Diagnostics and Forensics

> **Goal:** Eight tools that answer questions no Windows utility currently answers. Most of them are only possible because this is a suite: they compose enumerators and records that the other tools already own, which is exactly what a standalone utility cannot do.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** None of these exists. They are new development with no AutoIt counterpart and no parity check. What makes them affordable is that **the parts already exist by the time this file runs**: `D05 T01 §5` enumerates startup entries, services, tasks, and context menus; `D05 T03 §2` enumerates drivers; `D05 T03 §8` enumerates policy; `D02 T01 §4` writes a restore record for every change any tool makes. This file composes those. It must not re-enumerate anything, because a second enumerator is the duplication this whole rewrite exists to remove.

## Inputs

- -> XREF: [`02-repair-contract/TODO-01 §4`](../02-repair-contract/TODO-01-repair-contract.md) -- the restore records §2 reads across every tool
- -> XREF: [`05-new-tools/TODO-01 §5`](./TODO-01-intake-and-new-tools.md) -- the autoruns enumerators §1 composes
- -> XREF: [`05-new-tools/TODO-03 §1`](./TODO-03-system-utilities.md) -- the utilities whose enumerators and records this file reuses

## Outcome

- A user can answer "my machine was fine last week" with evidence rather than memory.
- Everything the suite has ever done to a machine is visible in one timeline, and undoable from there.
- A machine that will not sleep, wakes by itself, or takes minutes to boot can be explained.
- "Access denied" and "managed by your organization" stop being dead ends.
- No enumerator in this file is a second copy of one that already exists.

**Adjacency:** list=applicable @ D05 T04 §2; document=applicable @ D05 T04 §1; settings=applicable @ D05 T04 §1; reporting=applicable @ D05 T04 §5; notifications=not-applicable (these tools are opened deliberately when something is wrong, and none runs in the background uninvited); permissions=applicable @ D05 T04 §5; audit=applicable @ D05 T04 §2; exchange=applicable @ D05 T04 §1; reverse=applicable @ D05 T04 §2

**Adjacency rationale:** Document and exchange pair on §1 because a snapshot is a file a user keeps, compares against later, and may hand to somebody helping them, which makes its format an interface and its contents a privacy question. Audit and reverse pair on §2 because the repair history **is** the suite's audit trail, and the only thing that makes a timeline of past changes genuinely useful is being able to reverse one from it.

## Implementation Order

| Order | Section | Deliverable                                | Depends On             | Status |
| :---: | :-----: | ------------------------------------------ | ---------------------- | :----: |
|   1   |   §1    | System Change Journal                      | D05 T01 §5, D05 T03 §2 |  [ ]   |
|   2   |   §2    | Repair History                             | D02 T01 §4             |  [ ]   |
|   3   |   §3    | Sleep and Wake Diagnostics                 | D05 T01 §1             |  [ ]   |
|   4   |   §4    | Boot Time Analyzer                         | D05 T01 §1             |  [ ]   |
|   5   |   §5    | Why Is This Denied                         | D05 T03 §5, D05 T03 §8 |  [ ]   |
|   6   |   §6    | Pending Reboot Inspector                   | D05 T01 §1             |  [ ]   |
|   7   |   §7    | Activation and Network Share Diagnostics   | D05 T01 §1             |  [ ]   |

---

## 1. System Change Journal

"My machine was fine last week" is the most common sentence in any support conversation, and nothing on Windows can answer it. This tool records what the machine looked like and shows what changed since.

**Fidelity:** the snapshot list and the difference view, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user can find out what changed on their machine between two points in time. Consumer: the stored snapshots, and the difference view read from them.
**Treatment:** every source enumerated by the tool that already owns it, with this tool composing rather than re-implementing. Cheaper substitute that fails the checkpoint: a second set of enumerators inside this tool, which is the exact duplication that produced fourteen copies of one framework in the suite this replaces.
**Chrome:** consume the framework, and the enumerators from `D05 T01 §5`, `D05 T03 §2`, and `D05 T03 §8`. Write no enumerator of your own.
**Needs:** Windows host (build/test)

- [ ] Define the snapshot: startup entries, services, scheduled tasks, context menu entries, drivers, installed software, file associations, applied policy, and named registry areas. Done when: the format is documented and each source names the section that owns its enumerator.
- [ ] Take a snapshot without a perceptible wait. Done when: a full snapshot on a normal machine completes within a stated time, quoted, and the window stays responsive.
- [ ] Diff two snapshots into added, removed, and changed, per source. Done when: a fixture pair with one known change in each source produces exactly those differences and no others.
- [ ] Make the difference readable by somebody who is not an expert. Done when: a changed service renders as what changed in plain words, not as two raw property lists side by side.
- [ ] Bound the storage. Done when: a retention rule exists, a machine with many snapshots stays within a stated budget, and the oldest are pruned predictably.
- [ ] Treat the snapshot as a file that may leave the machine. Done when: the export states what it contains, the exclusion list names anything identifying, and the reasoning is recorded, as `D05 T03 §6` does for the system report.
- [ ] Take a snapshot automatically before any repair-contract run, if the user enables it. Done when: a fixture repair produces a before-snapshot and the setting controls it.
- [ ] Commit: `"change journal: snapshot the machine and show what changed"`

**Test checkpoint:** A full snapshot completes within the stated time with the window responsive, quoted. A fixture pair with one known change per source produces exactly those differences and no others. A changed service renders in plain words. The retention rule holds on a machine with many snapshots. No enumerator in this tool duplicates one from `D05 T01 §5`, `D05 T03 §2`, or `D05 T03 §8`, proven by search.

## 2. Repair History

Nobody else can build this. It exists only because every tool in this suite writes a restore record through one contract, which means the suite can show a user everything it has ever done to their machine, in one place, and let them reverse any of it.

**Fidelity:** the history timeline and the entry detail, against `DESIGN.md`.
**Job:** a user can see everything Resolute has done to this machine and undo any of it, long after the tool that did it was closed. Consumer: the restore records written by every tool, read back here.
**Treatment:** undo performed through the owning tool's contract items, not reimplemented here. Cheaper substitute that fails the checkpoint: this tool learning how to reverse each kind of change itself, which would make it a second implementation of every tool's undo.
**Chrome:** consume the framework and the repair contract. This tool reads records and invokes the contract; it never writes to the system directly.
**Needs:** Windows host (build/test)

- [ ] Define where restore records live so every tool writes to one discoverable place. Done when: the location is documented, `D02 T01 §4` is updated to use it, and records from three different tools are found by one scan.
- [ ] Render the history as a timeline: what tool, what action, what target, when, and whether it is still reversible. Done when: a fixture history from three tools renders completely.
- [ ] Undo a past run through the owning tool's contract. Done when: a repair performed by one tool is reversed from here and the result matches reversing it in that tool, compared value by value.
- [ ] Report honestly when a record can no longer be applied. Done when: a record whose target has since changed is shown as no longer reversible, with the reason, rather than failing at the moment the user tries.
- [ ] Make the history searchable and filterable by tool, date, and target. Done when: each filter narrows and clearing restores.
- [ ] Export the history as a transcript. Done when: the export matches the rendered timeline and is readable in a plain text editor.
- [ ] Respect the standalone rule: this tool reads records that exist, and reports plainly when no other Resolute tool is installed. Done when: it runs alone in an empty folder and says there is no history rather than failing.
- [ ] Commit: `"repair history: one timeline for everything the suite has done"`

**Test checkpoint:** Records from three different tools are found by one scan and render in one timeline. A repair is reversed from here and the result matches reversing it in the owning tool, compared value by value. A stale record is reported as no longer reversible with its reason. The tool runs standalone and reports an empty history rather than failing.

## 3. Sleep and Wake Diagnostics

`powercfg` already knows why a machine will not sleep and what woke it. It has never had a face, and the three questions it answers are among the most common and most infuriating a user has.

**Fidelity:** the diagnostic result and the wake-source list, against `DESIGN.md`.
**Job:** a user can find out why their machine will not sleep, what wakes it, and what is draining the battery while it is closed. Consumer: the power configuration, read back after any change.
**Treatment:** the findings explained in plain words, with the offending item named and actionable. Cheaper substitute that fails the checkpoint: rendering `powercfg` output verbatim, which is the same wall of text the user could already get.
**Chrome:** consume the framework and the repair contract for anything it changes.
**Needs:** Windows host (build/test)

- [ ] Report what is currently preventing sleep, naming the process or driver. Done when: a fixture request holding the machine awake is named and explained.
- [ ] Report what last woke the machine, and the history of wake sources. Done when: both render and a machine with no wake history says so rather than rendering empty.
- [ ] List devices permitted to wake the machine, and make that permission changeable as a repair-contract item. Done when: disabling a device's wake permission is undoable and verified by reading the setting back.
- [ ] Surface wake timers, including scheduled tasks configured to wake the machine. Done when: a fixture wake timer is listed with the task that owns it.
- [ ] Summarize the battery and standby behaviour where the system provides it. Done when: the summary renders on a laptop and reports plainly that it is unavailable on a desktop.
- [ ] Explain each finding in plain words. Done when: every finding carries a sentence a non-expert can act on, and the raw value remains available.
- [ ] Commit: `"sleep and wake: explain why it will not sleep and what wakes it"`

**Test checkpoint:** A fixture request holding the machine awake is named and explained. Last-wake and wake history render, and an empty history says so. Disabling a device's wake permission is undoable and verified by read-back. A fixture wake timer is listed with its owning task. Every finding carries an actionable sentence with the raw value still available.

## 4. Boot Time Analyzer

Task Manager grades startup apps "High", "Medium", or "Low" and says nothing about drivers or services. Real boot tracing exists but is developer-grade. In between is where every user with a slow machine actually lives.

**Fidelity:** the boot timeline and the contributor list, against `DESIGN.md`.
**Job:** a user can find out what is making their machine slow to start, with numbers rather than adjectives. Consumer: the boot records the system already keeps.
**Treatment:** measurements taken from what Windows already records, with the limits of that data stated. Cheaper substitute that fails the checkpoint: presenting an invented score, which is what makes existing startup advice untrustworthy.
**Chrome:** consume the framework, and the autoruns enumerators for anything it offers to disable.
**Needs:** Windows host (build/test)

- [ ] Report total boot time and its phases from the records Windows keeps. Done when: figures render for the last several boots and are compared against an independent measurement.
- [ ] Attribute time to specific services, drivers, and startup applications. Done when: a deliberately slowed fixture service is identified as a contributor with a figure.
- [ ] State plainly what cannot be measured without deeper tracing. Done when: the limits are on the surface, so a user is not misled into thinking the list is exhaustive.
- [ ] Offer to disable a contributor through the autoruns manager's contract items rather than implementing disabling here. Done when: the offer routes to that tool's item and the undo is that tool's.
- [ ] Show boot time over time, so a user can tell whether it is getting worse. Done when: a history renders and a machine with one recorded boot says so.
- [ ] Commit: `"boot analyzer: attribute slow startup with real numbers"`

**Test checkpoint:** Boot time and phases render for the last several boots, compared against an independent measurement. A deliberately slowed fixture service is identified with a figure. The measurement limits are stated on the surface. Disabling routes to the autoruns manager's contract item, proven by search showing no disable logic here.

## 5. Why Is This Denied

Windows says access is denied, or that a setting is managed, and then refuses to say why. Six different mechanisms can produce that, and no tool checks all six.

**Fidelity:** the explanation surface, against `DESIGN.md`.
**Job:** a user pointed at a file, folder, or blocked setting learns the actual reason and what would change it. Consumer: the composed answer, drawn from the mechanisms that already have owners.
**Treatment:** every mechanism checked and the responsible one named. Cheaper substitute that fails the checkpoint: reporting the ACL, which is only one of six answers and is the one users have already looked at.
**Chrome:** consume the ownership logic, the file-lock logic from `D05 T03 §5`, and the policy logic from `D05 T03 §8`. Implement none of them again.
**Needs:** Windows host (build/test)

- [ ] Check each mechanism for a given target: ownership, an explicit deny entry, inherited permissions, integrity level, a policy restriction, an edition limitation, and an in-use lock. Done when: all seven are checked and a fixture for each produces the correct attribution.
- [ ] Name the responsible mechanism rather than listing all of them. Done when: a fixture blocked by a deny entry names that, and one blocked by a lock names the holding process.
- [ ] Say what would change it, and whether this suite can do it. Done when: each explanation names the tool and action that would resolve it, or states plainly that it cannot be resolved.
- [ ] Handle the case where more than one mechanism applies. Done when: a fixture blocked by two mechanisms reports both in the order they would need resolving.
- [ ] Change nothing. Done when: this tool has no write path at all, proven by search, and resolution is always a hand-off to the owning tool.
- [ ] Commit: `"why is this denied: name the mechanism, not the symptom"`

**Test checkpoint:** All seven mechanisms are checked, with a fixture per mechanism producing the correct attribution. A deny-entry fixture and a lock fixture each name the right cause. Each explanation names the resolving tool or states that it cannot be resolved. A two-mechanism fixture reports both in resolution order. The tool has no write path, proven by search.

## 6. Pending Reboot Inspector

Windows demands a restart, the user restarts, and Windows demands a restart again. The flags that cause this are scattered, obscure, and sometimes stale.

**Fidelity:** the pending-operation list, against `DESIGN.md`.
**Job:** a user can find out what is demanding a restart, and clear a flag that is left over from something long finished. Consumer: the pending-operation state, read back after any change.
**Treatment:** each flag named with what set it, and clearing offered only where it is genuinely stale. Cheaper substitute that fails the checkpoint: clearing every flag on request, which can leave a half-applied update permanently unfinished.
**Chrome:** consume the framework and the repair contract.
**Needs:** Windows host (build/test)

- [ ] Check every source of a pending restart, including pending file rename operations, component servicing, and update state. Done when: each source is listed here with its location, and a fixture for each is detected.
- [ ] Name what set each flag where the system records it. Done when: a fixture flag renders with its origin, and one with no recorded origin says so.
- [ ] Distinguish a genuine pending operation from a stale flag. Done when: the distinction is made on evidence, and this section records how.
- [ ] Offer to clear only the stale ones, as a repair-contract item. Done when: clearing is undoable, and a genuine pending operation is refused with the reason.
- [ ] Commit: `"pending reboot: name what is demanding a restart"`

**Test checkpoint:** Every pending-restart source is listed with its location and detected against a fixture. A fixture flag renders with its origin. Stale and genuine are distinguished on stated evidence. Clearing a stale flag is undoable; clearing a genuine one is refused with the reason.

## 7. Activation and Network Share Diagnostics

Two small tools, grouped because each is a single explanatory surface over one opaque system facility.

**Fidelity:** each tool's result surface, against `DESIGN.md`.
**Job:** a user can find out why Windows says it is not activated, and why a network share will not connect. Consumer: the licensing state and the share connection attempt, both read directly.
**Treatment:** error codes decoded into plain words with the likely cause named. Cheaper substitute that fails the checkpoint: showing the raw code, which the user already has and cannot act on.
**Chrome:** consume the framework. Neither tool changes anything, so neither consumes the repair contract.
**Needs:** Windows host (build/test)

- [ ] Report the activation state, licence type, and any grace period. Done when: all three render and a machine in each state is driven.
- [ ] Decode activation error codes into plain words with a likely cause. Done when: a fixture set of common codes each render an explanation, and an unknown code says so rather than guessing.
- [ ] Never handle, display, or store a product key. Done when: this section records that as a rule and a search proves no key is read or written. Cheaper substitute that fails the checkpoint: displaying the key as a convenience, which turns a diagnostic into a credential leak.
- [ ] Diagnose a failing share connection across its real causes: name resolution, the protocol version negotiated, credentials, network discovery, and the firewall. Done when: a fixture failure in each category is attributed correctly.
- [ ] Say which step failed and what would change it. Done when: each result names the failing step and an action, rather than reporting that the connection failed.
- [ ] Commit: `"activation and share diagnostics: decode the opaque failures"`

**Test checkpoint:** Activation state, licence type, and grace period render across driven machines. Common error codes each decode; an unknown one says so. No product key is read or written, proven by search. A fixture share failure in each category is attributed correctly and names the failing step with an action.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with every diagnostic suite reporting
- [ ] No enumerator in this file duplicates one owned by another section, proven by search
- [ ] `§5` and the two tools in `§7` have no write path at all
- [ ] Every tool in this file passes the conformance check and runs standalone in an empty folder
- [ ] Snapshot and report exports carry a recorded exclusion list for anything identifying
- [ ] `python scripts/todo-graph.py validate` clean
