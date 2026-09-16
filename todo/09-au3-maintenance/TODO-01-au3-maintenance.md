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
> **Current state (verified 2026-09-16):** The AutoIt suite is at `resolute_au3/` and ships today. It does **not** build from a clean checkout: all thirteen `.sni` descriptors hardcode `R:\Workspace\Resolute\...`, a directory that no longer exists. `SDK/Concrete/Rescue/` holds only a `Distribution/338/` build output with no source, left behind when that tool was removed. `SDK/Concrete/BiosCodes/Includes/Localization.au3.backup` is a stray file. `ReBar` declares a product page at `downloads/resolute/` although it is internal tooling. Framework-first sequencing means this suite ships for a long time yet, so it needs an owner rather than a freeze.

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

---

## 1. Make the AutoIt Suite Buildable Again

A shipping product that cannot be built from its own repository cannot be fixed. This is first because everything else in this domain assumes a build exists.

**Needs:** Windows host (build/test)

- [ ] Replace the hardcoded `R:\Workspace\Resolute\...` paths in all thirteen `.sni` descriptors with repository-relative equivalents. Done when: no descriptor contains an absolute path, checked rather than eyeballed.
- [ ] Note the scope, measured 2026-09-16: **the `#AutoIt3Wrapper_` directives are already repository-relative and correct.** `Resolute.au3` emits to `..\..\..\Resolute.exe`, which resolves to `resolute_au3/Resolute.exe` after the move, and the tool scripts emit to `..\..\..\Resolute\<Tool>.exe`, which resolves into `resolute_au3/Resolute/`. Only the `.sni` descriptors carry absolute paths. Done when: this section confirms the directives were checked and left alone, so the fix is scoped to the descriptors rather than to every script.
- [ ] Prove a clean-checkout build. Done when: a fresh clone into a different absolute path builds at least one tool to both architectures with no file edited, and the path is recorded.
- [ ] Record which tools build and which do not. Done when: all thirteen are attempted and the result per tool is recorded here.
- [ ] Commit: `"au3: make the autoit suite build from a clean checkout"`

**Test checkpoint:** No `.sni` contains an absolute path, proven by check. A fresh clone into a different absolute path builds at least one tool to both architectures with no file edited, and that path is quoted. The per-tool build result is recorded for all thirteen.

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
- [ ] Write the retirement procedure: what happens to an AutoIt tool the day its C++ port ships. Done when: the procedure covers the update file, the download page, and the source, and names `D06 T01 §4` as the owner of the announcement.
- [ ] Decide and record how a defect found in the AutoIt tree that also affects the port is handled. Done when: the answer is dated, and says which tree gets fixed first.
- [ ] Commit: `"au3: maintenance scope and the retirement procedure"`

**Test checkpoint:** The scope states what is in and out with a reason. `AGENTS.md` and this section agree that `resolute_au3/` is otherwise read-only. The retirement procedure covers update file, download page, and source, naming its owner. The shared-defect policy is dated.

## Verification

- [ ] The AutoIt suite builds from a clean checkout at a different absolute path
- [ ] No `.sni` descriptor contains an absolute path
- [ ] The known housekeeping defects are cleared
- [ ] The maintenance scope is written and `AGENTS.md` agrees with it
- [ ] `python scripts/todo-graph.py validate` clean
