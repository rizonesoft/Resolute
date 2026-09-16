---
schema_version: 1
id: repair-contract
domain: 02-repair-contract
status: draft
title: "TODO-01 -- Repair Contract"
depends_on: [framework-core]
frozen: true
track: F2
---

# TODO-01 -- Repair Contract

> **Goal:** The second shared layer. Every tool that changes a user's system does it through one contract: diagnose what is actually wrong, report it per item, repair only what applies, verify the change landed, and be able to undo it. Written once, so that "can this be undone" has the same answer everywhere.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Nothing of this exists in C++ and nothing of it is shared in AutoIt. Seven AutoIt tools walk roughly this shape privately and to different standards. `ComIntRep` is the most complete at roughly 1,903 lines of real logic and is the reference for what the contract should be; `Ownership` implements roughly 77 lines and has no reverse at all. No tool in the suite records prior state before changing it, so no tool can undo what it did. None verifies a change landed rather than trusting a return code.

## Inputs

- [`resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.au3`](../../resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.au3) -- the reference implementation; the contract is extracted from what this tool does well
- [`resolute_au3/SDK/Concrete/Ownership/Ownership.au3`](../../resolute_au3/SDK/Concrete/Ownership/Ownership.au3) -- the thinnest consumer, and the vertical slice that proves the contract
- -> XREF: [`01-framework/TODO-01 §1`](../01-framework/TODO-01-framework-core.md) -- the framework this layer sits on
- -> XREF: [`04-tools-port/TODO-01 §2`](../04-tools-port/TODO-01-tool-ports.md) -- the six frozen tools that consume this contract
- -> XREF: [`05-new-tools/TODO-01 §1`](../05-new-tools/TODO-01-intake-and-new-tools.md) -- the new tools, which consume it from their first commit
- -> XREF: [`05-new-tools/TODO-02 §4`](../05-new-tools/TODO-02-regstudio.md) -- RegStudio's editing path, which is the contract's most exposed consumer

## Outcome

- A repair tool declares what it can repair and the contract runs it, rather than each tool writing its own loop.
- Nothing is changed without the prior state being recorded first.
- Every change is verified by reading it back, never by trusting a return code.
- Every run can be undone, or says plainly and on the surface that it cannot and what to do instead.
- Every action and every refusal writes exactly one log line.
- A user can carry the result away as a file.

**Adjacency:** list=applicable @ D02 T01 §5; document=applicable @ D02 T01 §5; settings=not-applicable (the contract owns no settings of its own; the framework's writer holds everything); reporting=applicable @ D02 T01 §3; notifications=applicable @ D02 T01 §3; permissions=applicable @ D02 T01 §2; audit=applicable @ D02 T01 §6; exchange=applicable @ D02 T01 §4; reverse=applicable @ D02 T01 §4

**Adjacency rationale:** Reverse and exchange both anchor on §4 because a restore record is simultaneously the undo mechanism and a file that outlives the process, may be carried to another machine, and may be hand-edited, which makes it untrusted input on the way back in. List and document pair on §5 because the result of a repair run is the one artifact a user genuinely wants to keep and carry to whoever is helping them.

## Implementation Order

| Order | Section | Deliverable                                | Depends On     | Status |
| :---: | :-----: | ------------------------------------------ | -------------- | :----: |
|   1   |   §1    | The repair item and the run loop           | D01 T01 §1     |  [ ]   |
|   2   |   §2    | Diagnose before repair                     | §1             |  [ ]   |
|   3   |   §3    | Per-item result and the surface            | §1             |  [ ]   |
|   4   |   §4    | Restore record and undo                    | §1             |  [ ]   |
|   5   |   §5    | Transcript the user can carry              | §3             |  [ ]   |
|   6   |   §6    | One log line per action and per refusal    | §3, §4         |  [ ]   |

---

## 1. The Repair Item and the Run Loop

The contract's whole value is that a tool declares items and the loop does the rest. If a tool can write its own loop, the contract is advisory, and an advisory contract is how the AutoIt suite ended up with seven different answers to the same question.

**Fidelity:** no surface of its own. The loop orchestrates; §3 owns the surface.
**Needs:** C++ toolchain (compile)

- [ ] Define the repair item: a name, a localization key, a diagnose function, a repair function, a verify function, and a declared reversibility. Done when: an item carrying no reversibility answer fails to compile or fails a startup assertion.
- [ ] Implement the run loop: diagnose all, repair the applicable, verify each, and record every outcome. Done when: a fixture tool declaring four items produces four outcomes with no tool-side loop.
- [ ] Make the loop the only path. Done when: nothing in the contract lets a tool repair an item outside the loop, and this section names how that is enforced.
- [ ] Guard every repair with the framework's elevation check, at the item rather than at startup. Done when: an unelevated run refuses per item and changes nothing.
- [ ] Add assertions for the loop over a fixture item set, including the mixed case where some items apply and some do not. Done when: three assertions run.
- [ ] Commit: `"repair: the repair item and the run loop"`

**Test checkpoint:** A fixture tool with four declared items produces four outcomes through the shared loop with no tool-side loop code. An item lacking a reversibility answer is rejected. An unelevated run refuses per item and the fixture is unchanged. All quoted.

## 2. Diagnose Before Repair

Presenting a user with a checklist and letting them guess is the current behavior, and it is how a repair tool fixes one machine and breaks another. Diagnosing first means only the applicable repairs are offered.

**Fidelity:** the result list, against `docs/captures/house-style/`.
**Job:** a user is offered only the repairs that apply to their machine, instead of a checklist they have to guess at. Consumer: the diagnosis shown per item, and the repair set that follows from it.
**Treatment:** every item diagnosed before anything is offered, with diagnose provably read-only. Cheaper substitute that fails the checkpoint: offering every repair always and letting the user decide, which is how a repair tool fixes one machine and breaks another.
**Chrome:** consume the framework's standard window and list surface.
**Needs:** C++ toolchain (compile)

- [ ] Run every item's diagnose function before anything is offered, and record what each found. Done when: a fixture where two of four items apply offers exactly two.
- [ ] Make diagnose read-only, provably. Done when: a diagnose pass over the fixture leaves it byte-identical, asserted.
- [ ] Let a user override the diagnosis and run an item anyway, with a stated consequence. Done when: the override is available, and choosing it is recorded in the result and the log.
- [ ] Handle a diagnose that cannot determine an answer as its own outcome, distinct from applies and does-not-apply. Done when: three states are representable and the surface shows which.
- [ ] Add assertions for the applicable subset, the read-only guarantee, and the unknown state. Done when: three assertions run.
- [ ] Commit: `"repair: diagnose before offering a repair"`

**Test checkpoint:** A fixture where two of four items apply offers exactly two. A diagnose pass leaves the fixture byte-identical, asserted. The unknown state renders distinctly. An override is recorded in both result and log. All quoted.

## 3. Per-Item Result and the Surface

A repair run that reports "done" tells a user nothing and tells a support reader less. Per item, with a reason, is the difference between a tool people trust and a tool people run twice hoping.

**Fidelity:** the result list, against `docs/captures/house-style/`.
**Job:** a user can see exactly what was attempted, what changed, and what did not. Consumer: the result list on the surface, and the transcript in §5.
**Treatment:** each item carries its own outcome and reason, and the counts reconcile against the item set. Cheaper substitute that fails the checkpoint: a progress bar and a final success message, which is what makes a partial failure invisible.
**Chrome:** consume the framework's standard window and message layer. Do not build a second result control.
**Needs:** C++ toolchain (compile)

- [ ] Define the outcome set: repaired, already correct, skipped, refused, failed, each with a reason. Done when: every outcome carries a localization key and no outcome renders as bare English.
- [ ] Render the result list through the framework's standard surface. Done when: a mixed run renders one row per item and the counts add up to the item set size.
- [ ] Verify each repair by reading the effect back, and report a repair whose verify failed as failed rather than repaired. Done when: a fixture item whose repair is deliberately made ineffective reports failed, not repaired.
- [ ] Account for the surface: every control on the result list is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Add assertions for the outcome set, the reconciliation, and the failed-verify case. Done when: three assertions run.
- [ ] Commit: `"repair: per-item results that reconcile"`

**Test checkpoint:** A mixed fixture run renders one row per item with counts reconciling to the item set. An item whose repair is made ineffective reports failed rather than repaired. The rendered list is captured under `docs/captures/runs/` and compared against the house-style capture.

## 4. Restore Record and Undo

The part users actually need and the part nobody builds. A repair with no reverse is a support call, and the AutoIt suite has seven of them.

**Fidelity:** the undo confirmation, reusing the framework's message dialog. No new dialog.
**Job:** a user can put back what a repair changed. Consumer: the restore record on disk, read back by the undo path.
**Treatment:** the prior state captured per item before the change, so undo restores what was actually there rather than a guess at a default. Cheaper substitute that fails the checkpoint: restoring to a convention such as the current user or a documented default value.
**Chrome:** consume the framework's settings writer for record location and its logging for the trail.
**Needs:** Windows host (build/test)

- [ ] Capture prior state per item before any change, into a restore record beside the log. Done when: a fixture run writes a record naming every target and its prior value and type.
- [ ] Implement undo for a whole run, restoring from the record. Done when: a fixture run followed by undo leaves the fixture identical to its pre-run state, compared value by value and type by type.
- [ ] Treat the record as untrusted on the way back in: a truncated, corrupt, or foreign record is refused before a single write. Done when: a deliberately corrupted record produces the refusal and the fixture is byte-identical afterwards.
- [ ] Make undo all-or-nothing, or state plainly on the surface and in the log that it is not and what the user must do after a partial undo. Done when: the behavior is one of those two and the checkpoint proves which.
- [ ] Give records a findable identity: what run they came from, what they cover, and when. Done when: a user with several records can pick one without opening it, captured.
- [ ] Handle the irreversible item honestly: the contract refuses to let it claim a reverse, and the surface says so before the user commits. Done when: a fixture item declared irreversible shows the statement on the surface, not only in the documentation.
- [ ] Commit: `"repair: restore records and a real undo"`

**Freeze check:** The contract changes no tool's repair effect. What changes is that the prior state is recorded first. Evidence is a fixture run before and after the change producing byte-identical effects. Fixture source: `tests/fixtures/`.

**Test checkpoint:** A fixture run followed by undo restores every value and type, asserted. A corrupted record is refused with the fixture byte-identical afterwards. An irreversible item states so on the surface. The record list is captured. All quoted.

## 5. Transcript the User Can Carry

A repair result is the one thing in this suite a user genuinely wants to keep: to send to a forum, to attach to a support mail, to compare after a reboot.

**Fidelity:** the export dialog, reusing the framework's file dialog. No new dialog.
**Job:** a user can save what happened and hand it to somebody who can help. Consumer: the saved file, read back.
**Treatment:** a real export written atomically and read back before success is reported. Cheaper substitute that fails the checkpoint: a copy-to-clipboard button presented as an export.
**Chrome:** consume the framework's file helpers and message layer.
**Needs:** C++ toolchain (compile)

- [ ] Define the transcript: what ran, what each item found, what was done, what was verified, and the machine and version context. Done when: the format is documented and a fixture run produces one.
- [ ] Write it atomically and read it back before reporting success. Done when: an export to a read-only location reports failure rather than claiming success.
- [ ] Keep the transcript legible without the tool. Done when: it opens readably in a plain text editor, captured.
- [ ] Carry the restore record's identity so a reader can tell which undo belongs to which run. Done when: the transcript names its record and the link is asserted.
- [ ] Commit: `"repair: a transcript the user can carry away"`

**Test checkpoint:** A fixture run exports a transcript whose content matches the rendered result list. An export to a read-only target reports failure. The file opens readably in a plain text editor, captured. The transcript names its restore record.

## 6. One Log Line Per Action and Per Refusal

The audit trail. The AutoIt suite has six tools that write nothing at all, so this is the section that makes "what did this tool do to my machine" answerable.

**Fidelity:** no surface of its own. The log is written, not displayed; the framework's viewer displays it.
**Needs:** C++ toolchain (compile)

- [ ] Log every repair, every skip, every refusal, and every undo through the framework's action log. Done when: a mixed fixture run produces exactly one line per item and the line names the item and its target.
- [ ] Make the log line and the surface result agree. Done when: a driven run's lines and rendered rows are compared and match, quoted.
- [ ] Log the undo as its own action, not as a repair. Done when: a run followed by undo produces distinguishable lines, asserted.
- [ ] Prove no action can bypass the log. Done when: this section names the enforcement and an assertion covers it.
- [ ] Commit: `"repair: one log line per action and per refusal"`

**Test checkpoint:** A mixed fixture run produces exactly one line per item, each naming item and target. Lines and rendered rows are compared and agree. Undo lines are distinguishable from repair lines. All quoted.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with the repair-contract suites reporting
- [ ] A fixture run followed by undo restores every value and type exactly
- [ ] A corrupted restore record is refused with nothing written
- [ ] Every freeze check in this file ran and passed, quoted in the covering stamp
- [ ] No fixture residue remains after a full run
- [ ] `python scripts/todo-graph.py validate` clean
