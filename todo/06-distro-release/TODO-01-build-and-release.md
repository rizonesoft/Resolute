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
> **Current state (verified 2026-09-16):** Nothing exists in C++. In the AutoIt tree, thirteen `.sni` descriptors drive `SDK/Distro.exe`, and every one of them hardcodes `R:\Workspace\Resolute\...`, a path that no longer exists, so that tree does not build from a clean checkout. All thirteen carry `Sign = 0`, `Compress = 0`, and `SignInstall = 0`. Signing happens through an existing procedure outside this repository, which this file documents rather than replaces. The update mechanism resolves `<UpdateServer>/<ShortName>.ru`, or `.ruz` on a beta build, but nothing in the tree generates those files. Copyright years in the AutoIt sources span 2022 to 2025 because they are typed by hand into fourteen scripts.

## Inputs

- [`resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.sni`](../../resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.sni) -- the shape of a release descriptor, and the record of what a distributed tool ships with
- -> XREF: [`04-tools-port/TODO-01 §1`](../04-tools-port/TODO-01-tool-ports.md) -- the ports this release ships
- -> XREF: [`08-docs-localization/TODO-01 §1`](../08-docs-localization/TODO-01-docs-and-localization.md) -- the documentation set every release includes

## Outcome

- One command produces the whole release set, for both architectures.
- Every shipped executable is signed through the documented procedure.
- Every tool ships as an installer and as a portable edition, install-tested on a clean machine.
- Every tool has an update file, generated rather than hand-written.
- The four retiring products announce their successors.
- The version rule is written down, including the build auto-increment convention.

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

## Verification

- [ ] `pwsh scripts/release.ps1` produces the whole set for both architectures
- [ ] The release refuses to build when any gate is not green
- [ ] Every artifact verifies as signed and no credential appears in any tracked file
- [ ] Install, uninstall, and upgrade are proven on a clean machine
- [ ] The consolidation announcement is verified against a real installed build
- [ ] `python scripts/todo-graph.py validate` clean
