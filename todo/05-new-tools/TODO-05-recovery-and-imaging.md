---
schema_version: 1
id: recovery-and-imaging
domain: 05-new-tools
status: draft
title: "TODO-05 -- Recovery and Imaging"
depends_on: [system-utilities]
frozen: true
track: P3
---

# TODO-05 -- Recovery and Imaging

> **Goal:** A file recovery engine and a rescue imager, both **implemented from published specifications rather than ported**, so the suite owns what it ships and licenses it freely. The recovery engine also proves that `QuickErase` did what it claimed, and the imager rescues a failing drive rather than competing with the tools that write to healthy ones.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Both are **third-party GPL v3 C# projects**, not Rizonesoft code.
>
> `samples/Undelete/Source/` is **Kickass Undelete 1.5.5** by Kevin Leach, dated 2018-12-10: 105 C# files across `FileSystems`, `GuiComponents`, `KickassUndelete`, and a test project, licensed GPL v3.
>
> `samples/SDImage/` is **SD Imager**, `AssemblyCompany("OS IT Consult")`, `AssemblyCopyright("Copyright © OS IT Consult, 2013")`, a C# WinForms prototype licensed GPL v3. The repository's git history is Rizonesoft's, but the code is not.
>
> Neither can consume the shared framework as it stands, because both are C# and the framework is C++23.
>
> **SD Imager's provenance is unresolved.** The assembly metadata says OS IT Consult while the repository sits at `github.com/rizonesoft/SDImage`, which is suggestive but not conclusive. Until it is settled the code is treated as third-party, which costs nothing here because raw disk access is roughly fifty lines of Win32 and is written from scratch faster than it is ported.
>
> Neither sample is in this repository: `/samples/` is gitignored. For the clean-room requirement that is a feature rather than an inconvenience, because the source the implementer must not read is not in the tree to be read.

> [!CAUTION]
> **Neither tool is ported. Both are implemented from specification.**
>
> A port is a derivative work: translating C# into C++ does not reset a licence, any more than translating a novel creates a new copyright. Copyright protects **expression**, not facts or functionality, and a file system's on-disk layout is a documented fact. A parser written from the FAT32 specification and the NTFS documentation owes nothing to anyone's implementation of one.
>
> **The discipline that makes this true: whoever writes the C++ does not read the C#.** The samples establish that the feature is achievable and what a good surface looks like. They are not a source to work from, and `§1` and `§4` each carry that as a checklist item with a checkpoint.
>
> This is not a workaround. It is the ordinary way a clean implementation is made, and it is what leaves the result free to license.

## Inputs

- Kickass Undelete, publicly available. **Reference only, and not for the implementer**: evidence the feature is achievable and a guide to what a surface should offer. **Deliberately not in this repository**, because `/samples/` is gitignored, which is what keeps GPL v3 source out of a tree whose engine must owe it nothing
- `github.com/rizonesoft/SDImage`, on the same terms
- The FAT32 specification and the published NTFS on-disk documentation, which are what `§1` is actually written from
- -> XREF: [`05-new-tools/TODO-01 §3`](./TODO-01-intake-and-new-tools.md) -- `QuickErase`, whose claim §3 verifies
- -> XREF: [`05-new-tools/TODO-03 §3`](./TODO-03-system-utilities.md) -- Disk Health, which §4 composes with
- -> XREF: [`06-distro-release/TODO-01 §8`](../06-distro-release/TODO-01-build-and-release.md) -- the licensing and attribution rules these ports must satisfy

## Outcome

- A user can recover a deleted file, and a user who securely erased a drive can prove nothing remains.
- A failing drive can be imaged before it stops responding, at the moment Disk Health says it is dying.
- Both tools are owned outright, implemented from documented formats, and licensed at the suite's discretion.
- Neither carries a private file system parser or drive access layer that another tool duplicates.

**Adjacency:** list=applicable @ D05 T05 §2; document=applicable @ D05 T05 §3; settings=not-applicable (these tools own no settings beyond the framework's); reporting=applicable @ D05 T05 §3; notifications=applicable @ D05 T05 §4; permissions=applicable @ D05 T05 §1; audit=applicable @ D05 T05 §3; exchange=applicable @ D05 T05 §4; reverse=not-applicable (recovery and imaging both write to a destination the user chose; neither modifies the source, which §1 makes structural)

**Adjacency rationale:** Permissions anchors on §1 because raw volume access is the most privileged thing in the entire suite, and an engine that can read a raw disk is one mistake away from being an engine that writes to one. Document, reporting, and audit converge on §3 because an erase-verification result is a claim a user may rely on or show to somebody else, which makes how it is worded and what it refuses to claim the whole substance of the section.

## Implementation Order

| Order | Section | Deliverable                                | Depends On     | Status |
| :---: | :-----: | ------------------------------------------ | -------------- | :----: |
|   1   |   §1    | The recovery engine, read-only by design   | D05 T01 §1     |  [ ]   |
|   2   |   §2    | Undelete                                   | §1             |  [ ]   |
|   3   |   §3    | Erase verification                         | §1, D05 T01 §3 |  [ ]   |
|   4   |   §4    | Rescue imaging                             | D05 T03 §3     |  [ ]   |

---

## 1. The Recovery Engine, Read-Only By Design

A file system's on-disk layout is documented and its structures are facts. A deleted MFT record is one whose in-use flag is clear; a deleted FAT directory entry begins with `0xE5`. None of that belongs to anyone, and this section implements it from the specifications rather than from somebody's C#.

It also makes the engine structurally incapable of writing to the volume it reads.

**Fidelity:** no surface of its own; §2 and §3 render what this produces.
**Needs:** C++ toolchain (compile)


**Build order.** Stage 1 is a legal precondition, not a preference. Do not begin stage 3 until stage 1 is recorded.

1. **Record the clean-room statement before writing code.** Name who implements the engine and confirm they have not opened `samples/Undelete/`. Done when: the statement is in this section, dated, and the named person has not read the original.
2. **Gather the specifications.** The FAT32 specification and the published NTFS on-disk documentation. Done when: each is cited here by title, so the implementation has a stated source that is not somebody's code.
3. **Build the volume reader first, read-only.** Done when: it opens a volume and refuses to expose any write path, proven by search for write calls.
4. **Implement FAT before NTFS**, because FAT is simpler and proves the fixture machinery. Done when: a FAT fixture image enumerates its deleted entries headlessly.
5. **Implement NTFS.** Done when: an NTFS fixture image enumerates entries whose MFT in-use flag is clear.
6. **Add recoverability classification last**, because it depends on both parsers. Done when: fully recoverable, partially overwritten, and unrecoverable are distinguishable on fixtures.
7. **Prove nothing from the original is present.** Done when: `git grep` finds no file, identifier, or comment traceable to `samples/Undelete/`.

- [ ] Name the specifications this engine is written from, and the formats it supports. Done when: each supported format cites the published documentation it was implemented against, and a fixture image of each enumerates its deleted entries.
- [ ] **Record the clean-room discipline and who held it.** Done when: this section states that the implementer did not read the Kickass Undelete source, names who wrote the engine, and confirms no file from it is referenced by, included in, or copied into the build. The gitignored `samples/` tree makes this easy to hold and easy to demonstrate. Cheaper substitute that fails the checkpoint: consulting the original "just for the tricky parts", which is precisely where a derivative-work claim would land.
- [ ] Make the engine **physically unable to write to the source volume.** Done when: it opens the volume read-only, exposes no write path, and a search proves no write call exists. Cheaper substitute that fails the checkpoint: a write path guarded by a flag, which is one mistake away from destroying the data the user is trying to recover.
- [ ] Recover to a destination on a different volume, and refuse a destination on the source. Done when: a same-volume destination is refused by name, because writing recovered data onto the volume being recovered from overwrites what has not been recovered yet.
- [ ] Report recoverability honestly per entry. Done when: fully recoverable, partially overwritten, and unrecoverable are distinguishable, and a partially overwritten fixture is not reported as recoverable.
- [ ] Guard raw volume access behind the framework's elevation check, at the call. Done when: an unelevated scan is refused by name and nothing is opened.
- [ ] Confirm the result is unencumbered. Done when: the engine carries no third-party copyright notice, `D06 T01 §8` records it as owned code, and the licence it ships under is the suite's choice rather than an inherited obligation.
- [ ] Add engine assertions against committed fixture images, with no physical disk. Done when: each supported format asserts headlessly.
- [ ] Commit: `"recovery engine: clean-room file system parser, read-only"`

**Freeze check:** What the engine reports as recoverable is frozen once shipped, because a user deletes data on the strength of it. Evidence is a fixture image per format producing an identical entry list across changes. Fixture source: `tests/fixtures/volumes/`.

**Test checkpoint:** Each supported format cites the specification it was implemented from and enumerates its deleted entries from a committed fixture image, headlessly. The clean-room statement names the implementer, and no file from `samples/Undelete/` appears in the build, proven by search. No write call exists in the engine, proven by search. A same-volume destination is refused by name. A partially overwritten fixture is not reported as recoverable. An unelevated scan is refused.

## 2. Undelete

The straightforward half, once §1 exists. It competes with well-established free tools, so it earns its place by being the one already installed when the user needs it, and by being honest about what it cannot do.

**Fidelity:** the scan result list, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user who deleted something can get it back, or find out plainly that they cannot. Consumer: the recovered files at the destination, verified after writing.
**Treatment:** recoverability stated per file before the user commits, including the partially-overwritten case. Cheaper substitute that fails the checkpoint: listing every entry as recoverable and letting the user discover the truth after the scan finishes.
**Chrome:** consume the framework and the shared virtualized list. The engine is §1's; this tool adds no parsing.
**Needs:** Windows host (build/test)

- [ ] Scan a volume and render results through the shared virtualized list. Done when: a fixture image with many entries scrolls smoothly and the scan leaves the window responsive.
- [ ] Filter by name, type, size, and recoverability. Done when: each filter narrows and clearing restores.
- [ ] Recover selected files and verify each after writing. Done when: recovered content is compared against the fixture original byte for byte, and a failed write is reported per file rather than as a batch result.
- [ ] Tell the user the one thing that actually matters, before they scan. Done when: the surface states that continuing to use the drive reduces what can be recovered, where they will read it rather than in documentation.
- [ ] Account for the surface. Done when: every control is working or deferred to a named section.
- [ ] Commit: `"undelete: recover deleted files, honestly"`

**Test checkpoint:** A fixture image with many entries scrolls smoothly with the window responsive. Each filter narrows and restores. Recovered content matches the fixture original byte for byte, and a failed write is reported per file. The continued-use warning appears on the surface, captured.

## 3. Erase Verification

The reason this port is worth making. `QuickErase` claims a file is unrecoverable; this proves it. No comparable suite ships a secure-erase tool that can verify its own claim, and running the recovery engine over an erased target is the only honest way to make one.

**Fidelity:** the verification result, against `DESIGN.md`. Presented as a report rather than a file list, because the useful outcome is a finding, not a set of entries.
**Job:** a user who erased something can confirm it is gone, or learn that it is not. Consumer: the verification report, which the user may rely on or show to somebody else.
**Treatment:** the finding stated with its limits, because a verification that overstates is worse than none. Cheaper substitute that fails the checkpoint: reporting "securely erased" from the absence of recoverable entries, which the engine cannot actually establish.
**Chrome:** consume the framework and the §1 engine. Add no second scanner.
**Needs:** Windows host (build/test)

- [ ] Scan a target after a `QuickErase` run and report what, if anything, the engine can still find. Done when: an erased fixture reports nothing recoverable and a deliberately non-erased control reports its entries.
- [ ] Offer verification directly from `QuickErase` after an erase. Done when: the hand-off works and the result names the erase run it verifies.
- [ ] **State the limits of the claim plainly.** Done when: the report says what was checked, by what method, and what this cannot establish, naming at least the remapped-sector case and the SSD wear-levelling case, where data can survive in blocks no file system read will ever reach.
- [ ] Carry the erase method through from `QuickErase`, because the honest claim differs by method. Done when: a report on an overwritten magnetic target and one on a firmware-erased solid state target state different findings, and a report on an **overwritten** solid state target says plainly that a file system scan cannot establish erasure there.
- [ ] Never report a bare "securely erased". Done when: every result is phrased as what was and was not found by a stated method, proven by there being no such string in the surface.
- [ ] Export the verification as a transcript. Done when: it is written atomically, read back, and carries the same limits the surface states.
- [ ] Log every verification. Done when: each writes one line naming the target and the outcome.
- [ ] Commit: `"erase verification: prove what quickerase claimed"`

**Freeze check:** What this reports and refuses to report is frozen once shipped, because a user may make a disclosure decision on it. Evidence is an erased fixture and a control fixture producing identical findings and identical limit statements across changes.

**Test checkpoint:** An erased fixture reports nothing recoverable; a non-erased control reports its entries. The hand-off from `QuickErase` names the run and the method it verifies. The report names the remapped-sector and SSD wear-levelling limits, and an overwritten solid state target is reported as not establishable by scan. No "securely erased" phrasing exists in the surface, proven by search. The transcript carries the same limits.

## 4. Rescue Imaging

Tools that write images to healthy drives are numerous and good. Reading an image **off** a drive that is failing is a different job, far less served on Windows, and it is the one that matters at the moment Disk Health says the disk is dying.

**Fidelity:** the imaging surface and its progress, against `DESIGN.md`.
**Job:** a user with a failing drive can get an image of it before it stops responding. Consumer: the image file, verified after writing.
**Treatment:** **the read strategy is the product.** Good regions are read fast and first, damaged regions are returned to afterwards under a bounded retry budget, because naive retrying accelerates a failing drive's death and can lose everything not yet read. Cheaper substitute that fails the checkpoint: a straight block copy that aborts on the first read error, or one that retries a bad sector indefinitely, which are the two ways a rescue tool destroys what it exists to save.
**Chrome:** consume the framework and the shared progress surface. Compose with Disk Health rather than re-reading SMART.
**Needs:** Windows host (build/test)


**Build order.** Every stage before 4 is about not destroying the drive you are trying to save. Build the strategy before the speed.

1. **Build the read-only source reader**, against `CreateFile` on `\\.\PhysicalDriveN`. Done when: it reads a fixture drive and no write path to the source exists, proven by search.
2. **Build the region map**, which records what has and has not been read. Done when: a partial run writes a map that a later run can resume from.
3. **Implement the fast first pass**, copying every readable region with **no** retries. Done when: a fixture with unreadable regions completes the first pass before any retry is attempted, observable in the log.
4. **Implement the bounded retry pass** over the gaps. Done when: the budget is configurable, visible on the surface, and exhausting it continues the run rather than stalling.
5. **Measure total re-reads** against a stated ceiling. Done when: a fixture run's re-read count is quoted and under the ceiling.
6. **Add resumability.** Done when: an interrupted run restarts from its map and does not re-read completed regions.
7. **Add the write-back path last**, because it is the only destructive one. Done when: the confirmation names letter, label, and size, and the destination can never be the source.

- [ ] Image a source drive to a file, reading read-only and never writing to the source. Done when: no write path to the source exists, proven by search, and the source is byte-identical after a run.
- [ ] Record the read strategy as a design decision with its reasoning. Done when: this section states the phase order, the retry bounds, and why unbounded retrying is refused, so a later change cannot quietly weaken it.
- [ ] Implement the read strategy explicitly, in phases: a fast first pass that copies every readable region without retrying, then a second pass over the gaps, then bounded retries on what remains. Done when: the phases are documented, and a fixture with unreadable regions shows the first pass completing before any retry is attempted.
- [ ] Bound the retry budget per region and overall, and make it visible. Done when: the budget is stated on the surface, a fixture exhausts it, and the run continues rather than stalling. Cheaper substitute that fails the checkpoint: unlimited retries, which is how a marginal drive is pushed over the edge while the user watches a progress bar that is not moving.
- [ ] Minimise stress on a failing drive. Done when: the section records what was done to avoid it, and a fixture run is measured for total re-reads against a stated ceiling.
- [ ] Make the run resumable. Done when: an interrupted run restarts from its map rather than from the beginning, because re-reading a dying drive from zero is the most expensive thing the tool could do.
- [ ] Record every unreadable region and continue. Done when: a fixture with deliberately unreadable regions produces a complete image with those regions recorded and zero-filled, and the run completes.
- [ ] Produce a map of what could not be read. Done when: the map ships beside the image and names each unreadable region by offset and length.
- [ ] Offer imaging from Disk Health when a drive reports failing. Done when: the hand-off works and carries the drive identity across.
- [ ] Verify the image after writing. Done when: readable regions are compared against the source and any mismatch is reported.
- [ ] Support writing an image back to a drive, with a confirmation naming the destination by letter, label, and size. Done when: the confirmation names all three, declining performs nothing, and the destination is never the source.
- [ ] State plainly that writing an image destroys everything on the destination. Done when: that statement is on the surface before the user commits.
- [ ] Implement raw drive access from the Win32 API rather than porting it. Done when: the access layer is written against `CreateFile` on `\\.\PhysicalDriveN` and the documented IOCTLs, and no file from `samples/SDImage/` appears in the build, proven by search. At roughly fifty lines this is faster than porting regardless of who owns the original.
- [ ] Resolve SD Imager's provenance, or record that it remains unresolved. Done when: either the rights are established and recorded in `D06 T01 §8`, or this section states that the question was left open and made moot by implementing from Win32.
- [ ] Commit: `"rescue imaging: image a failing drive, bad sectors and all"`

**Freeze check:** What is written to a destination drive is frozen once shipped, because a mistake destroys a user's data. Evidence is a fixture image written to a fixture target producing a byte-identical result across changes.

**Test checkpoint:** No write path to the source exists, proven by search, and the source is byte-identical after a run. No file from `samples/SDImage/` appears in the build, proven by search. On a fixture with unreadable regions the fast first pass completes before any retry is attempted, the retry budget is exhausted without stalling the run, and total re-reads are measured against the stated ceiling, all quoted. An interrupted run resumes from its map. The unreadable map names each region by offset and length. The Disk Health hand-off carries the drive identity. A write confirmation names letter, label, and size, and declining does nothing.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with the recovery and imaging suites reporting
- [ ] The recovery engine and the imaging path contain no write call to their source, both proven by search
- [ ] Neither tool includes or references any file from `samples/Undelete/` or `samples/SDImage/`, proven by search
- [ ] The clean-room statement names who implemented the recovery engine and what they worked from
- [ ] The erase verification surface contains no unqualified "securely erased" claim
- [ ] Every freeze check in this file ran and passed
- [ ] `python scripts/todo-graph.py validate` clean
