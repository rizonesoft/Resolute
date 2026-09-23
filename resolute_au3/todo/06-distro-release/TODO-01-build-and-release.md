---
schema_version: 1
id: build-and-release
domain: 06-distro-release
status: draft
title: "TODO-01 -- Build and Release"
depends_on: []
track: R1
---

# TODO-01 -- Build and Release

> **Goal:** A release of Resolute Power Tools is produced by a repeatable procedure from a clean checkout: every tool built to both architectures, signed, packaged into the installer and the portable edition, versioned consistently, and checked against a list before it ships. Today the procedure lives in one developer's habits and one machine's directory layout.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Builds run through `SDK/Distro.exe` against a `.sni` descriptor per tool. There are 13 `.sni` files under `SDK/Concrete/*/`; `SDK/Concrete/Distro/` has `Distro.au3` but no descriptor of its own. Every one of the 13 hardcodes `ScriptPath=R:\Workspace\Resolute\...` plus absolute `Icon`, `OutFilePath`, `OutFileX64Path`, and `DistributionPath` values, none of which match this checkout at `R:\conclave\projects\Resolute`. `Resolute.sni` sets `Sign=0` and points `CertificateSet` at `Signing\Signing.ini`; `SDK/Signing/` exists in the tree. `Resolute_setup.iss` is an Inno Setup script at the repository root, last touched 2025-03-15. Tool versions have drifted apart: `Resolute` 23.2.0.857, `Firemin` 12.2.1.9558, `Chromin`/`Edgemin`/`Watermin` 11.8.3.8534, `BiosCodes` 11.3.1.1994, down to `Ownership` 11.1.1.869. `Distribution/` output directories are gitignored. There is no release checklist and no changelog procedure in the repository.

## Inputs

- [`SDK/Concrete/Resolute/Resolute.sni`](../../SDK/Concrete/Resolute/Resolute.sni) -- the descriptor shape all 13 repeat, including its `[Modules]`, `[Signing]`, and `[Distribute]` sections
- [`Resolute_setup.iss`](../../Resolute_setup.iss) -- the Inno Setup installer script §4 owns
- [`Resolute/Docs/Resolute/Changes.txt`](../../Resolute/Docs/Resolute/Changes.txt) -- the changelog §5 makes part of the procedure
- -> XREF: [`00-workspace/TODO-01 §3`](../00-workspace/TODO-01-toolchain-and-gates.md) -- the one-command build this file's release procedure calls, and the `.sni` path repair it depends on
- -> XREF: [`07-quality/TODO-01 §3`](../07-quality/TODO-01-quality-bar.md) -- the suite smoke run the release checklist requires before shipping
- -> XREF: [`08-docs-localization/TODO-01 §1`](../08-docs-localization/TODO-01-docs-and-localization.md) -- the per-tool documentation a release ships

## Outcome

- Every tool, including `Distro` itself, has a build descriptor that resolves from the repository root.
- One command produces a complete, signed release set from a clean checkout.
- The installer and the portable edition are built from the same outputs and both are install-tested.
- Version numbers across the suite follow a stated rule, and a release cannot ship with a version that contradicts its changelog.

**Adjacency:** list=not-applicable (a build procedure holds no records a user browses; the release artifacts are files on disk); document=applicable @ D06 T01 §5; settings=applicable @ D06 T01 §1; reporting=applicable @ D06 T01 §2; notifications=not-applicable (nothing here notifies a user; a release announcement is outside this repository); permissions=applicable @ D06 T01 §4; audit=applicable @ D06 T01 §5; exchange=applicable @ D06 T01 §3; reverse=applicable @ D06 T01 §4

**Adjacency rationale:** Settings is §1 because the `.sni` files are the build's settings surface and they are the file class most often hand-edited in this repository, which is exactly how they came to carry one developer's drive letter. Permissions and reverse both land on §4: an installer needs elevation, and the reverse of an install is an uninstall that leaves nothing behind, which is the part nobody tests until a user complains. Exchange is §3 because signing consumes a certificate produced elsewhere and the release set is what leaves this repository. Document and audit pair on §5: the changelog is both the document a user reads and the record of what a given version contained.

## Implementation Order

| Order | Section | Deliverable                                  | Depends On | Status |
| :---: | :-----: | -------------------------------------------- | ---------- | :----: |
|   1   |   §1    | Complete and portable build descriptors      | D00 T01 §4 |  [ ]   |
|   2   |   §2    | One command builds the whole release set     | §1, D00 T01 §5 |  [ ]   |
|   3   |   §3    | Signing the release set                      | §2         |  [ ]   |
|   4   |   §4    | Installer and portable edition, install-tested | §2       |  [ ]   |
|   5   |   §5    | Version rule, changelog, and release checklist | §3, §4   |  [ ]   |

---

## 1. Complete and Portable Build Descriptors

`D00 T01 §4` removes the hardcoded drive letter from the 13 existing descriptors. This section finishes the job: the missing descriptor, the sections that are inconsistent between tools, and the rule that keeps a new tool from being added without one.

- [ ] Add `SDK/Concrete/Distro/Distro.sni` so the builder itself is built by the same procedure as everything else. Done when: `pwsh scripts/build.ps1 Distro` produces both architectures. Cheaper substitute: leaving the builder as the one tool built by hand, which is how its build breaks unnoticed.
- [ ] Compare the `[Modules]`, `[Signing]`, and `[Distribute]` sections across all 14 descriptors and record every difference with whether it is deliberate. Done when: the comparison table is in the commit body and each difference is marked deliberate or a defect.
- [ ] Normalize the defects found, leaving the deliberate differences alone and annotated. Done when: a second run of the comparison shows only the annotated differences.
- [ ] Confirm every file each `[Distribute]` section names actually exists, including the `Docs` and `Language` paths. Done when: a checker reports zero missing files, or the missing ones are filed with an owner. Source: `Resolute.sni`'s `[Distribute]` names `Docs\Resolute\Changes.txt`, `Readme.txt`, `License.txt`, and `Language\Resolute\en.lng`.
- [ ] Add the rule and its check: a tool directory under `SDK/Concrete/` without a `.sni` fails the gate. Done when: a scratch directory with no descriptor makes `scripts/check-all.ps1` exit 1 naming it.
- [ ] Commit: `"distro: give every tool a complete, repository-relative build descriptor"`

**Test checkpoint:** `pwsh scripts/build.ps1 Distro` produces both architectures. The distribute-file checker reports zero missing files across all 14 descriptors. A scratch tool directory with no `.sni` makes `scripts/check-all.ps1` exit 1 naming it. All three outputs are quoted in the commit body.

## 2. One Command Builds the Whole Release Set

Fourteen tools times two architectures is 28 executables, plus documentation and language files. Done by hand, a release ships with one tool a build behind and nobody notices for a month.

**Needs:** AutoIt3 toolchain (compile)

- [ ] Add `scripts/release.ps1` building every tool to both architectures from a clean checkout and collecting the outputs into a staging directory. Done when: one invocation produces all 28 executables plus the files each `[Distribute]` section names. Cheaper substitute: a script that builds and leaves the outputs where they land, so the release set is assembled by hand afterwards.
- [ ] Fail the release build on the first tool that does not build, and report which, rather than producing a partial set that looks complete. Done when: a deliberately broken tool stops the run and names itself.
- [ ] Produce a manifest: every artifact with its version, size, architecture, and hash. Done when: the manifest covers all 28 executables and is written into the staging directory.
- [ ] Make the build reproducible enough to compare: two runs from the same commit produce manifests differing only in fields that legitimately vary, and the section names which those are. Done when: two runs are compared and the differing fields are listed and explained.
- [ ] Require the gates before staging: `scripts/check-all.ps1` must pass, and the release script refuses to stage when it does not. Done when: a deliberately introduced Au3Check warning makes the release script refuse with the gate named.
- [ ] Commit: `"distro: build the whole release set with one command"`

**Test checkpoint:** `pwsh scripts/release.ps1` from a clean checkout produces 28 executables and a manifest naming each with version, architecture, size, and hash, quoted in part. A deliberately broken tool stops the run and names itself. A new Au3Check warning makes the script refuse before staging, naming the gate. All three outputs are quoted in the commit body.

## 3. Signing the Release Set

`Resolute.sni` carries `Sign=0` and a `CertificateSet` pointing at `Signing\Signing.ini`. Unsigned executables that perform system repairs will be blocked, quarantined, or simply distrusted, so signing is not a finishing touch here.

**Needs:** Signing certificate (release)

- [ ] Record what signing needs: which certificate, where it comes from, how it is supplied to the build, and what must never be committed. Done when: the requirements are written here and no credential or certificate path appears in a tracked file.
- [ ] Wire signing into `scripts/release.ps1` behind a switch, so an unsigned developer build and a signed release build are the same procedure with one difference. Done when: both modes run and the manifest records which was used.
- [ ] Verify every artifact after signing rather than trusting the signing call: check each executable's signature and report per artifact. Done when: all 28 are verified and one deliberately unsigned artifact is reported as such.
- [ ] Refuse to produce a release-marked set when any artifact is unsigned. Done when: the refusal names the artifacts and exits non-zero.
- [ ] Record the failure path: what happens when the certificate is unavailable or expired, and what the operator does. Done when: the procedure is written and the unavailable-certificate case is exercised.
- [ ] Commit: `"distro: sign the release set and verify every artifact"`

**Test checkpoint:** With the certificate available, `pwsh scripts/release.ps1 -Sign` produces 28 signed artifacts, each verified, with the verification output quoted. With the certificate absent, the script refuses and names what is missing. A deliberately unsigned artifact is reported and blocks the release-marked set. This row does not stamp until it has run with a real certificate.

## 4. Installer and Portable Edition, Install-Tested

`Resolute_setup.iss` builds the installer and `PortableEdition=1` selects the portable behavior at runtime. Neither has a test, so the first person to find out that an install is broken is a user.

**Needs:** Windows host (build/test)

- [ ] Build the installer from the staged release set rather than from whatever is lying in the working tree. Done when: `Resolute_setup.iss` consumes the staging directory and the installer's file list matches the manifest.
- [ ] Produce the portable edition from the same staged set, with `PortableEdition=1` and its settings beside the executable. Done when: the portable set runs from a directory with no installation and writes its settings there.
- [ ] Install-test on a clean target: install, launch the launcher, launch one tool from it, and confirm settings and logs land where the edition says they should. Done when: all four steps pass and the paths are recorded.
- [ ] Uninstall-test as the reverse: uninstall, and confirm what remains is only what the user would expect to keep, with anything left behind named deliberately. Done when: the remaining file and registry list is recorded and each entry is deliberate.
- [ ] Prove the elevation path: the installer requests elevation, and declining it leaves the system unchanged. Done when: a declined install leaves no files and no registry entries.
- [ ] Record the upgrade case: installing over an existing version preserves the user's settings. Done when: a settings value set before the upgrade is read back after it.
- [ ] Commit: `"distro: build and install-test the installer and the portable edition"`

**Test checkpoint:** On a clean target, the installer installs from the staged set, the launcher starts, one tool launches from it, and settings and logs land at the recorded paths. Uninstalling leaves only the named, deliberate residue. A declined elevation leaves nothing behind. An upgrade preserves a settings value set beforehand. All five results are quoted in the commit body.

## 5. Version Rule, Changelog, and Release Checklist

Tool versions in this suite span 11.1.1.869 to 23.2.0.857, and the `.sni` version and the script's own version directive differ by one build during development by convention that is written down nowhere. A release that ships a version contradicting its changelog is the kind of error that is discovered by a user asking which version fixed their bug.

- [ ] Write the version rule: what each field means, when each is bumped, why the tools do not share a number, and the expected one-build drift between a `.sni` `Version=` and the script's `#AutoIt3Wrapper_Res_Fileversion`. Done when: the rule is in `docs/release/versioning.md` and explains the current spread rather than declaring it wrong.
- [ ] Reconcile the two version sources at release time: the release build refuses when a tool's `.sni` version and its compiled resource version disagree by more than the rule allows. Done when: a deliberate mismatch makes the release build refuse and name the tool.
- [ ] Make the changelog part of the procedure: `Resolute/Docs/<Tool>/Changes.txt` gains an entry for the version being released, and the release build refuses when the version being built has no entry. Done when: a tool with no changelog entry for its version blocks the release and names itself.
- [ ] Write the release checklist as a runnable document: gates green, release set built, signed, installed, uninstalled, smoke run passed, changelogs current, manifest archived. Done when: `docs/release/checklist.md` exists and every item names the command or artifact that satisfies it.
- [ ] Archive the manifest with the release so a shipped artifact can be traced back to its commit. Done when: the manifest records the commit hash and is stored with the release set.
- [ ] Commit: `"distro: state the version rule and make the release checklist runnable"`

**Test checkpoint:** A deliberate version mismatch between a `.sni` and its script's resource version makes the release build refuse and name the tool. A tool whose `Changes.txt` lacks an entry for the version being built blocks the release. `docs/release/checklist.md` exists with a command or artifact named for every item, and the archived manifest carries the commit hash. All outputs are quoted in the commit body.

## Verification

- [ ] `pwsh scripts/release.ps1` from a clean checkout produces the full staged set and its manifest
- [ ] Every artifact in the release set is signed and verified
- [ ] The installer and the portable edition are both install-tested, including the uninstall and the declined-elevation paths
- [ ] `docs/release/checklist.md` and `docs/release/versioning.md` exist and every checklist item names its command or artifact
- [ ] `python scripts/todo-graph.py validate` clean
