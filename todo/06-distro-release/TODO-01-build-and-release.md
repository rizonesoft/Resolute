---
schema_version: 1
id: build-and-release
domain: 06-distro-release
status: draft
title: "TODO-01 -- Build and Release"
depends_on: [tool-ports]
track: R1
---

# TODO-01 -- Build and Release

> **Goal:** A release is produced by a procedure rather than by habit: one command builds the whole set, every tool is signed, every tool ships as an installer and a portable edition, every tool gets its update file, and the four retiring products tell their users where they went.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Nothing exists in C++. In the AutoIt tree, thirteen `.sni` descriptors drive `SDK/Distro.exe`, and every one of them hardcodes `R:\Workspace\Resolute\...`, a path that no longer exists, so that tree does not build from a clean checkout. All thirteen carry `Sign = 0`, `Compress = 0`, and `SignInstall = 0`. Signing happens through an existing procedure outside this repository, which this file documents rather than replaces. The update mechanism resolves `<UpdateServer>/<ShortName>.ru`, or `.ruz` on a beta build, but nothing in the tree generates those files. Copyright years in the AutoIt sources span 2022 to 2025 because they are typed by hand into fourteen scripts. The tree also carries **two licences with no recorded decision**: the AutoIt tools ship GPL v3, while `RegStudio` is MIT. `shared/lucide` ships **no licence file at all**, and ExoSuite has no root `LICENSE`.

## Inputs

- [`resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.sni`](../../resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.sni) -- the shape of a release descriptor, and the record of what a distributed tool ships with
- -> XREF: [`04-tools-port/TODO-01 §1`](../04-tools-port/TODO-01-tool-ports.md) -- the ports this release ships
- -> XREF: [`08-docs-localization/TODO-01 §1`](../08-docs-localization/TODO-01-docs-and-localization.md) -- the documentation set every release includes
- -> XREF: [`05-new-tools/TODO-05 §1`](../05-new-tools/TODO-05-recovery-and-imaging.md) -- the two GPL v3 ports whose attribution obligations §7 records

## Outcome

- One command produces the whole release set, for both architectures.
- Every shipped executable is signed through the documented procedure.
- Every tool ships as an installer and as a portable edition, install-tested on a clean machine.
- Every tool has an update file, generated rather than hand-written.
- The four retiring products announce their successors.
- The version rule is written down, including the build auto-increment convention.
- A repair can be promoted to its own named product for the cost of a descriptor, with no second codebase.
- Every shipped tool carries its licence and its third-party attributions, generated rather than maintained.

**Adjacency:** list=not-applicable (the release process holds no records a user browses); document=applicable @ D06 T01 §5; settings=not-applicable (the release reads the build configuration and owns none of its own); reporting=applicable @ D06 T01 §2; notifications=applicable @ D06 T01 §4; permissions=not-applicable (release runs on a developer machine with no role model); audit=applicable @ D06 T01 §5; exchange=applicable @ D06 T01 §4; reverse=applicable @ D06 T01 §3

**Adjacency rationale:** Reverse anchors on §3 because an installer that cannot cleanly uninstall is the one irreversible thing a release can ship, and it is only provable on a machine that has never had the suite. Exchange and notifications pair on §4 because the update file is both a published interface and the only channel to a user who already installed something, which is exactly what the retiring products need.

## Implementation Order

| Order | Section | Deliverable                                   | Depends On   | Status |
| :---: | :-----: | --------------------------------------------- | ------------ | :----: |
|   1   |   §1    | Release descriptors, portable by construction | D04 T01 §1   |  [ ]   |
|   2   |   §2    | One command builds the release set            | §1           |  [ ]   |
|   3   |   §3    | Installer and portable edition, install-tested | §2          |  [ ]   |
|   4   |   §4    | Update files and consolidation announcements  | §2           |  [ ]   |
|   5   |   §5    | Version rule, changelog, and release checklist | §2          |  [ ]   |
|   6   |   §6    | Focused builds from one codebase              | §1, §4      |  [ ]   |
|   7   |   §7    | Licensing and attribution                     | --          |  [ ]   |

---

## 1. Release Descriptors, Portable by Construction

Thirteen descriptors pointing at a directory that no longer exists is the clearest possible argument for making a path impossible to hardcode.

**Needs:** C++ toolchain (compile)

- [ ] Declare each tool's release content: executables, documentation set, language packs, and any runtime assets. Done when: every shipped tool has a declaration and it is derived from the build rather than maintained separately.
- [ ] Make an absolute path impossible. Done when: a declaration containing one fails the release build with a named message, and this section names the enforcement.
- [ ] Generate the copyright year at build time rather than storing it. Done when: no source file contains a hardcoded year and the built executables all report the same one.
- [ ] Carry the per-tool independence: each declaration produces a self-contained set that needs no other tool. Done when: each set is checked for references outside its own folder.
- [ ] Commit: `"release: declarative, path-portable release descriptors"`

**Test checkpoint:** Every shipped tool has a release declaration derived from the build. A declaration with an absolute path fails with a named message. No source contains a hardcoded copyright year and all built executables report the same one. Each release set is self-contained, proven by check.

## 2. One Command Builds the Release Set

**Needs:** C++ toolchain (compile)

- [ ] `scripts/release.ps1` builds every shipped tool for both architectures in release configuration. Done when: one invocation produces the whole set and names each artifact.
- [ ] Refuse to produce a release when the gates are not green. Done when: a deliberate warning makes the release command refuse with a named message, and the refusal names which gate failed.
- [ ] Report the set legibly: one line per tool with its version, architectures, and artifact sizes. Done when: a full run's report is quoted.
- [ ] Make the run reproducible. Done when: two runs from the same commit produce identical artifacts, or this section records exactly which bytes differ and why.
- [ ] Commit: `"release: one command builds the whole release set"`

**Test checkpoint:** One invocation produces the whole set for both architectures with a per-tool report, quoted. A deliberate warning makes it refuse and name the failing gate. Two runs from one commit are compared and any difference is explained.

## 3. Installer and Portable Edition, Install-Tested

**Needs:** Windows host (build/test)

- [ ] Produce an installer and a portable edition per tool. Done when: both exist for every shipped tool and the portable edition writes nothing outside its own folder, traced.
- [ ] Sign every executable and every installer through the existing external procedure. Done when: the procedure is documented here, every artifact verifies, and no credential appears in any tracked file.
- [ ] Install-test on a machine that has never had the suite. Done when: install, run, and uninstall are each proven on a clean virtual machine with a snapshot, and the machine and snapshot are named.
- [ ] Prove the uninstall is a real reverse. Done when: after uninstall the machine has no leftover files, registry keys, or services, compared against the pre-install snapshot.
- [ ] Upgrade-test over a previously installed version. Done when: an upgrade preserves user settings and the check is quoted.
- [ ] Commit: `"release: installer and portable edition, install-tested"`

**Test checkpoint:** Both editions exist per tool; the portable edition writes nothing outside its folder, traced. Every artifact verifies as signed. Install, run, uninstall, and upgrade are each proven on a named clean virtual machine. The post-uninstall comparison against the pre-install snapshot is quoted.

## 4. Update Files and Consolidation Announcements

The channel to every user who already installed something. Four products are retiring into two, and this is the only way those users find out.

**Needs:** C++ toolchain (compile)

- [ ] Generate `<ShortName>.ru` and `.ruz` per tool from the release build. Done when: every shipped tool has both, generated rather than hand-written, and the values match the built artifacts.
- [ ] Generate the announcement files for the four retiring products: `Chromin`, `Edgemin`, `Watermin`, and `DVDRepair`. Done when: each carries a build above any shipped build, a `UpdateURL` pointing at its successor, and a `Successor` naming it.
- [ ] Verify the announcement end to end against a real installed build. Done when: an installed AutoIt `Chromin` polls the generated file and shows the consolidation message, captured.
- [ ] Keep the files backward compatible. Done when: a shipped AutoIt build parses a generated file carrying the new `Successor` key without error, proven by driving one.
- [ ] Record the retirement policy: how long the announcement files stay published. Done when: the policy is dated with its cost of changing.
- [ ] Commit: `"release: generated update files and consolidation announcements"`

**Test checkpoint:** Every shipped tool has generated `.ru` and `.ruz` matching its artifacts. An installed AutoIt `Chromin` polls the generated file and shows the consolidation message, captured. A shipped AutoIt build parses a file carrying `Successor` without error. The retirement policy is dated.

## 5. Version Rule, Changelog, and Release Checklist

**Needs:** C++ toolchain (compile)

- [ ] Write the version rule, including that the descriptor build number sits one behind the source because of auto-increment. Done when: the rule explains the current spread rather than declaring it wrong, and says what a C++ port does to a tool's version.
- [ ] Decide and record what version a ported tool ships at. Done when: the decision is dated with its cost, and covers both the ports and the new tools.
- [ ] Generate the changelog from commits rather than maintaining it by hand. Done when: a release produces a per-tool changelog and each entry traces to a commit.
- [ ] Write the release checklist as a procedure somebody else could run. Done when: a second person follows it end to end and their result is recorded.
- [ ] Commit: `"release: version rule, changelog, and checklist"`

**Test checkpoint:** The version rule explains the current spread and the auto-increment convention. A release produces a per-tool changelog whose entries trace to commits. A second person runs the checklist end to end and the result is recorded.

## 6. Focused Builds From One Codebase

A landing page for "fix windows search" earns traffic that a page for a general repair tool does not. This section makes it possible to ship that page a focused product without a second codebase, so the suite gains marketing surface without regaining the duplication this rewrite exists to remove.

It exists before it is needed deliberately: built once, promoting any repair to its own product later costs a descriptor rather than a project.

**Needs:** C++ toolchain (compile)

- [ ] Define a focused build descriptor: the product name, short name, icon, update short name, and the set of repair items it exposes. Done when: the descriptor carries values only, and two descriptors over the same source produce two differently-named executables.
- [ ] Produce a focused build from an existing tool's source with no source change. Done when: a focused build of one Complete Windows Repair item builds, runs, and exposes only that item, proven by driving it.
- [ ] Give each focused build its own update file and documentation set, generated rather than written. Done when: both are produced by the release command and neither is maintained by hand.
- [ ] Make the relationship honest on the surface. Done when: a focused build's About names the suite it belongs to and the full tool it is drawn from, so a user is never misled into thinking they have found six unrelated programs. Cheaper substitute that fails the checkpoint: shipping the same binary under six unrelated identities, which is how a suite acquires a shovelware reputation.
- [ ] Keep the item set the only difference. Done when: a focused build and its parent are compared and differ only in descriptor values and exposed items, with any other difference explained.
- [ ] Record the promotion rule. Done when: this section states that a repair is promoted to a focused build on measured traffic rather than on expectation, and names who decides.
- [ ] Commit: `"release: focused builds from one codebase"`

**Test checkpoint:** Two descriptors over one source produce two differently-named executables. A focused build exposes only its declared item, proven by driving it. Its update file and documentation set are generated by the release command. Its About names the suite and the parent tool, captured. A focused build and its parent differ only in descriptor values and exposed items, with any other difference explained.

## 7. Licensing and Attribution

The tree currently carries two licences with no recorded decision, and ships third-party code with no licence file at all. Both are distribution defects today, and both get harder to fix with every tool added.

**Needs:** C++ toolchain (compile)

- [ ] Record the licence policy: **the framework is MIT, the tools are GPL v3.** Done when: the policy is written with its reasoning, namely that MIT code may be included in GPL work while the reverse is not true, so a permissive framework can serve tools under either licence and a GPL framework could not.
- [ ] Resolve the existing inconsistency. Done when: `RegStudio`, currently MIT, either moves to GPL v3 with the tools or is recorded as a deliberate exception with its reasoning.
- [ ] Give the repository and the framework their own licence files. Done when: a root `LICENSE` exists and `shared/resolute-ui` carries MIT.
- [ ] Ship every third-party licence the tree depends on. Done when: `shared/lucide` carries the ISC licence and its copyright notice, which it does not today, and any other third-party component is checked the same way.
- [ ] Record the attribution obligations that the ports carry. Done when: the list names Kickass Undelete and Kevin Leach for `D05 T05 §1`, and SD Imager and OS IT Consult for `D05 T05 §4`, each with what must appear where.
- [ ] Make every shipped tool carry its licence, its attributions, and the full text. Done when: each release set includes them, generated rather than maintained by hand, and a tool missing one fails the release.
- [ ] Verify rather than assume. Done when: a check lists every tool with its licence and its third-party attributions, and the report is quoted.
- [ ] Commit: `"release: licence policy, attributions, and the missing licence files"`

**Test checkpoint:** The licence policy is recorded with its reasoning. A root `LICENSE` exists, `shared/resolute-ui` carries MIT, and `shared/lucide` carries ISC with its copyright notice. Every release set includes its licence and attributions, generated. A tool with a missing licence fails the release, proven deliberately. The verification report is quoted.

## Verification

- [ ] `pwsh scripts/release.ps1` produces the whole set for both architectures
- [ ] The release refuses to build when any gate is not green
- [ ] Every artifact verifies as signed and no credential appears in any tracked file
- [ ] Install, uninstall, and upgrade are proven on a clean machine
- [ ] The consolidation announcement is verified against a real installed build
- [ ] `python scripts/todo-graph.py validate` clean
