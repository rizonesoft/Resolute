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
> **Current state (verified 2026-09-16):** Nothing exists in C++. In the AutoIt tree, thirteen `.sni` descriptors drive `SDK/Distro.exe`, and every one of them hardcodes `R:\Workspace\Resolute\...`, a path that no longer exists, so that tree does not build from a clean checkout. All thirteen carry `Sign = 0`, `Compress = 0`, and `SignInstall = 0`. Signing happens through an existing procedure outside this repository, which this file documents rather than replaces. The update mechanism resolves `<UpdateServer>/<ShortName>.ru`, or `.ruz` on a beta build, but nothing in the tree generates those files. Installers are built with **Inno Setup**, which is being kept: `resolute_au3/Resolute_setup.iss` is the existing suite script, and the per-tool `Setup.iss.txt` files under `Resolute/Docs/` are the per-tool equivalents. Copyright years in the AutoIt sources span 2022 to 2025 because they are typed by hand into fourteen scripts. The tree also carries **two licences with no recorded decision**: the AutoIt tools ship GPL v3, while `RegStudio` is MIT. `shared/lucide` ships **no licence file at all**, and ExoSuite has no root `LICENSE`.

## Inputs

- [`resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.sni`](../../resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.sni) -- the shape of a release descriptor, and the record of what a distributed tool ships with
- -> XREF: [`04-tools-port/TODO-01 §1`](../04-tools-port/TODO-01-tool-ports.md) -- the ports this release ships
- -> XREF: [`08-docs-localization/TODO-01 §1`](../08-docs-localization/TODO-01-docs-and-localization.md) -- the documentation set every release includes
- -> XREF: [`05-new-tools/TODO-05 §1`](../05-new-tools/TODO-05-recovery-and-imaging.md) -- the two GPL v3 ports whose attribution obligations §7 records

## Outcome

- One command produces the whole release set, for both architectures.
- Every shipped executable is signed through the documented procedure.
- Every tool ships as an Inno Setup installer and as a portable edition, install-tested on a clean machine, and the suite ships as one installer with per-tool selection.
- Both install silently for unattended deployment.
- A user upgrading from the AutoIt suite keeps their settings and ends up with one copy, not two.
- Every tool has an update file, generated rather than hand-written.
- The four retiring products announce their successors.
- The version rule is written down, including the build auto-increment convention.
- A repair can be promoted to its own named product for the cost of a descriptor, with no second codebase.
- Every shipped tool carries its licence and its third-party attributions, generated rather than maintained.

**Adjacency:** list=not-applicable (the release process holds no records a user browses); document=applicable @ D06 T01 §6; settings=not-applicable (the release reads the build configuration and owns none of its own); reporting=applicable @ D06 T01 §2; notifications=applicable @ D06 T01 §5; permissions=not-applicable (release runs on a developer machine with no role model); audit=applicable @ D06 T01 §6; exchange=applicable @ D06 T01 §5; reverse=applicable @ D06 T01 §3

**Adjacency rationale:** Reverse anchors on §3 because an installer that cannot cleanly uninstall is the one irreversible thing a release can ship, and it is only provable on a machine that has never had the suite. Exchange and notifications pair on §4 because the update file is both a published interface and the only channel to a user who already installed something, which is exactly what the retiring products need.

## Implementation Order

| Order | Section | Deliverable                                   | Depends On   | Status |
| :---: | :-----: | --------------------------------------------- | ------------ | :----: |
|   1   |   §1    | Release descriptors, portable by construction | D04 T01 §1   |  [ ]   |
|   2   |   §2    | One command builds the release set            | §1           |  [ ]   |
|   3   |   §3    | Installers: per tool and whole suite          | §2           |  [ ]   |
|   4   |   §4    | Migration from the AutoIt suite               | §3, D01 T01 §2 |  [ ]   |
|   5   |   §5    | Update files and consolidation announcements  | §2           |  [ ]   |
|   6   |   §6    | Version rule, changelog, and release checklist | §2          |  [ ]   |
|   7   |   §7    | Focused builds from one codebase              | §1, §5      |  [ ]   |
|   8   |   §8    | Licensing and attribution                     | --          |  [ ]   |

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

## 3. Installers: Per Tool and Whole Suite

**Inno Setup is kept.** `resolute_au3/Resolute_setup.iss` is the existing suite script and the per-tool `Setup.iss.txt` files are the per-tool equivalents, so this section adapts working scripts rather than choosing an installer.

Two shapes are needed, because the suite is distributed both ways: a user who wants one tool should not download thirty-nine, and a user who wants the suite should not run thirty-nine installers.

**Fidelity:** the installer's own pages, which are Inno Setup's. No custom installer UI.
**Job:** a user can install one tool or the whole suite, silently or interactively, and remove either cleanly. Consumer: the installed machine, compared against its pre-install state.
**Treatment:** both installer shapes generated from one declarative source, so a new tool appears in both without either script being hand-edited. Cheaper substitute that fails the checkpoint: thirty-nine hand-maintained `.iss` files, which drift the moment a tool is added.
**Chrome:** consume the release descriptors from §1. The installer scripts are generated, not authored per tool.
**Needs:** Windows host (build/test)


**Build order.** Adapt the working script before generating anything, so the generator has a known-good target to reproduce.

1. **Read `resolute_au3/Resolute_setup.iss` and record what it does.** Done when: its pages, tasks, and registry writes are listed, so nothing working is lost by accident.
2. **Hand-write one per-tool `.iss` for a single tool** and install-test it. Done when: it installs, runs, and uninstalls on a clean virtual machine.
3. **Turn that script into a template** driven by the release descriptor from `S1`. Done when: the same tool's installer is produced by the release command and is byte-comparable to the hand-written one, or the differences are explained.
4. **Generate for every tool.** Done when: adding a fixture tool produces its installer with no script edited.
5. **Build the suite installer** with per-tool selection on top of the same descriptors. Done when: a selection installs exactly those tools.
6. **Add silent and unattended support.** Done when: `/SILENT` and `/VERYSILENT` complete with no interaction and honour a target directory and a selection.
7. **Prove uninstall is a real reverse**, against a pre-install snapshot. Done when: no files, registry keys, services, or scheduled tasks remain.
8. **Prove the two shapes coexist last.** Done when: individual-then-suite neither duplicates nor orphans.

- [ ] Generate a per-tool Inno Setup script from that tool's release descriptor. Done when: a tool's `.iss` is produced by the release command with no hand editing, and adding a tool produces its installer with no script change.
- [ ] Generate the suite installer, with per-tool selection. Done when: a user can choose which tools to install, the default is a sensible set rather than all thirty-nine, and this section records what the default is and why.
- [ ] Produce a portable edition per tool that writes nothing outside its own folder. Done when: a file-system trace of a portable run shows no write outside it, quoted.
- [ ] Support **silent and unattended install**, because administrators deploy this across machines. Done when: `/SILENT` and `/VERYSILENT` both complete with no interaction, honour a target directory and a tool selection, and return a documented exit code.
- [ ] Sign every executable and every installer through the existing external procedure. Done when: the procedure is documented here, every artifact verifies, and no credential appears in any tracked file.
- [ ] Install-test on a machine that has never had the suite. Done when: install, run, and uninstall are each proven on a clean virtual machine with a snapshot, and the machine and snapshot are named.
- [ ] Prove the uninstall is a real reverse. Done when: after uninstall the machine has no leftover files, registry keys, services, or scheduled tasks, compared against the pre-install snapshot.
- [ ] Prove the two shapes coexist. Done when: installing a tool individually and then installing the suite does not duplicate it, and removing the suite does not orphan the individually installed copy.
- [ ] Commit: `"release: generated inno setup installers, per tool and whole suite"`

**Test checkpoint:** A per-tool `.iss` and the suite `.iss` are both generated by the release command with no hand editing, and adding a fixture tool produces its installer with no script change. `/SILENT` and `/VERYSILENT` complete unattended and return documented exit codes. A portable run writes nothing outside its folder, traced. Every artifact verifies as signed. Install, run, and uninstall are proven on a named clean virtual machine, with the post-uninstall comparison quoted. The individual-then-suite case is driven and neither duplicates nor orphans.

## 4. Migration From the AutoIt Suite

Every existing user has AutoIt tools installed. The day a C++ tool ships, that machine has two of something, and nothing in the plan said what happens.

This is the section that decides whether an upgrade feels like an upgrade or like a second product appearing beside the first.

**Fidelity:** the migration notice, reusing the framework's message dialog and the installer's own pages.
**Job:** a user upgrading from the AutoIt version keeps their settings and does not end up with two copies. Consumer: the migrated settings, read back, and the machine after the old version is removed.
**Treatment:** settings migrated and the old version removed by the installer, with the user told what happened. Cheaper substitute that fails the checkpoint: installing beside the old version and leaving the user to work out which is which, which is how a suite acquires a reputation for clutter.
**Chrome:** consume the framework's settings writer and its `.lng` migration from `D01 T01 §2`.
**Needs:** Windows host (build/test)

- [ ] Detect an installed AutoIt version of the same tool. Done when: the installer finds it on a fixture machine and reports the version found.
- [ ] Migrate its settings, including the `.lng` case for the seven tools that stored them wrongly. Done when: a fixture machine with AutoIt settings upgrades and every value survives, proven by readback.
- [ ] Remove the old version as part of the upgrade, or state plainly why not. Done when: the behaviour is one of those two, and a fixture upgrade leaves exactly one copy installed.
- [ ] Handle the consolidations, where the old tool has no direct successor. Done when: upgrading a machine with `Chromin` installed results in `Firemin`, the user is told why, and `Chromin` is removed; the same for `DVDRepair` into Drive Repair.
- [ ] Preserve anything the user would miss. Done when: this section lists what carries over beyond settings, such as logs and restore records, and what deliberately does not.
- [ ] Prove the path end to end on a machine that really has the old version. Done when: the AutoIt suite is installed on a clean virtual machine, upgraded, and the result is recorded with the snapshot named.
- [ ] Commit: `"release: migrate installs from the autoit suite"`

**Test checkpoint:** A fixture machine with an installed AutoIt tool is detected and its version reported. Settings migrate with every value surviving, proven by readback, including the `.lng` case. A fixture upgrade leaves exactly one copy installed. A machine with `Chromin` ends up with `Firemin`, told why, with `Chromin` removed. The full path is proven on a named clean virtual machine carrying the real AutoIt suite.

## 5. Update Files and Consolidation Announcements

The channel to every user who already installed something. Four products are retiring into two, and this is the only way those users find out.

**Needs:** C++ toolchain (compile)

- [ ] Generate `<ShortName>.ru` and `.ruz` per tool from the release build. Done when: every shipped tool has both, generated rather than hand-written, and the values match the built artifacts.
- [ ] Generate the announcement files for the four retiring products: `Chromin`, `Edgemin`, `Watermin`, and `DVDRepair`. Done when: each carries a build above any shipped build, a `UpdateURL` pointing at its successor, and a `Successor` naming it.
- [ ] Verify the announcement end to end against a real installed build. Done when: an installed AutoIt `Chromin` polls the generated file and shows the consolidation message, captured.
- [ ] Keep the files backward compatible. Done when: a shipped AutoIt build parses a generated file carrying the new `Successor` key without error, proven by driving one.
- [ ] Record the retirement policy: how long the announcement files stay published. Done when: the policy is dated with its cost of changing.
- [ ] Commit: `"release: generated update files and consolidation announcements"`

**Test checkpoint:** Every shipped tool has generated `.ru` and `.ruz` matching its artifacts. An installed AutoIt `Chromin` polls the generated file and shows the consolidation message, captured. A shipped AutoIt build parses a file carrying `Successor` without error. The retirement policy is dated.

## 6. Version Rule, Changelog, and Release Checklist

**Needs:** C++ toolchain (compile)

- [ ] Write the version rule, including that the descriptor build number sits one behind the source because of auto-increment. Done when: the rule explains the current spread rather than declaring it wrong, and says what a C++ port does to a tool's version.
- [ ] Decide and record what version a ported tool ships at. Done when: the decision is dated with its cost, and covers both the ports and the new tools.
- [ ] Generate the changelog from commits rather than maintaining it by hand. Done when: a release produces a per-tool changelog and each entry traces to a commit.
- [ ] Write the release checklist as a procedure somebody else could run. Done when: a second person follows it end to end and their result is recorded.
- [ ] Commit: `"release: version rule, changelog, and checklist"`

**Test checkpoint:** The version rule explains the current spread and the auto-increment convention. A release produces a per-tool changelog whose entries trace to commits. A second person runs the checklist end to end and the result is recorded.

## 7. Focused Builds From One Codebase

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

## 8. Licensing and Attribution

The tree currently carries two licences with no recorded decision, and ships third-party code with no licence file at all. Both are distribution defects today, and both get harder to fix with every tool added.

**Needs:** C++ toolchain (compile)

- [ ] Record the licence policy: **the framework is MIT, the tools are GPL v3.** Done when: the policy is written with its reasoning, namely that MIT code may be included in GPL work while the reverse is not true, so a permissive framework can serve tools under either licence and a GPL framework could not.
- [ ] Record **what Rizonesoft owns and can therefore license at will**: ExoSuite and its UI library, RegStudio, and the AutoIt suite are all Rizonesoft copyright. Done when: the policy states that the licence on owned code is a choice rather than a constraint, so `RegStudio` sitting at MIT is a decision to make, not an inconsistency to repair.
- [ ] Record what is **genuinely binding**, because after `D05 T05` chose to implement rather than port, very little is. Done when: the list names Lucide as ISC requiring its notice to ship, and the four AutoIt community UDFs below as unclear and avoided. Record that the recovery engine and the drive access layer are implemented from published specifications and the Win32 API, carry no third-party copyright, and are therefore the suite's to license.
- [ ] Deal with the unlicensed AutoIt community UDFs by **not porting them**. Done when: `CompInfo.au3` (Jarvis Stubblefield), `FFLabels.au3` and `GUICtrlFFLabel.au3` (Brian J Christy, G. Sandler), and `SSLG.au3` (an AutoIt forum post) are each confirmed reimplemented from the underlying Win32 or WMI rather than ported line by line, and this section records that. Cheaper substitute that fails the checkpoint: porting them and hoping, given that a forum post with no stated licence is all rights reserved by default.
- [ ] Decide the contributor licence position **before the repository takes its first external contribution**. Done when: the decision is dated with its reasoning. Copyleft on owned code costs the holder nothing, because a sole copyright holder may relicense at will; that freedom ends the moment an outside contribution arrives under GPL v3, since the patch is its author's copyright. A contributor licence agreement preserves it and is effectively impossible to retrofit.
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
- [ ] Install, uninstall, and upgrade are proven on a clean machine, silently and interactively
- [ ] A machine carrying the real AutoIt suite upgrades cleanly, with settings preserved and one copy left
- [ ] The consolidation announcement is verified against a real installed build
- [ ] `python scripts/todo-graph.py validate` clean
