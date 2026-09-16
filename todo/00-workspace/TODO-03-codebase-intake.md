---
schema_version: 1
id: codebase-intake
domain: 00-workspace
status: draft
title: "TODO-03 -- ExoSuite Codebase Intake"
depends_on: []
track: W1
---

# TODO-03 -- ExoSuite Codebase Intake

> **Goal:** The working C++23 codebase at `samples/ExoSuite` becomes the Resolute C++ tree: history preserved, product renamed, library and toolchain renamed, and the stale documentation corrected. After this file, `src/` is real and the rest of the plan builds on something that already compiles.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** `ExoSuite`, `RegStudio`, and `SDImage` are **separate repositories** under `github.com/rizonesoft`, checked out locally under `samples/` and **deliberately not tracked** by this repository: `/samples/` is gitignored. The subtree merge pulls from the remotes, so nothing depends on a local working copy. `deps/libvterm` is a **git submodule** pointing at `neovim/libvterm`, currently populated with 81 files, and is the tree's only external dependency. ExoSuite is a working native C++23 application: `shared/exo-ui` is 6,865 lines of Direct2D and DirectWrite UI framework, `src/main.cpp` is a 573-line shell, `extensions/` holds `RegStudio` and `Console`, and `exokit/` is a working toolchain bootstrap pulling llvm-mingw 20251216, CMake 4.2.3, and Ninja 1.13.1. `Bin/Release/ExoSuite.exe` is 1.39 MB fully static. There is **no vcpkg**; `deps/libvterm` is vendored. There are **no tests**; `test_font.cpp` is a scratch file. The `README.md` still describes a Rust and Slint stack that commit `efdce6177` removed. The product name appears in 32 files; `exo::`, `EXOUI_API`, and `exo/` appear 108 times across 25 files.

## Inputs

- `github.com/rizonesoft/ExoSuite` -- the codebase being taken in, including `shared/exo-ui` and the `exokit/` toolchain bootstrap. Checked out locally under `samples/`, which is gitignored
- `github.com/rizonesoft/RegStudio` -- merged alongside it
- -> XREF: [`00-workspace/TODO-01 §1`](./TODO-01-toolchain-and-gates.md) -- the toolchain hardening that follows this intake
- -> XREF: [`01-framework/TODO-01 §7`](../01-framework/TODO-01-framework-core.md) -- the framework that adopts this UI layer
- -> XREF: [`05-new-tools/TODO-02 §1`](../05-new-tools/TODO-02-regstudio.md) -- RegStudio, which arrives as an extension and whose duplicate copy §1 reconciles

## Outcome

- The C++ tree lives at `src/` and `shared/` in this repository, with its commit history intact.
- Nothing is named for a product that no longer exists.
- The toolchain bootstrap runs from the repository root.
- The documentation describes the stack that is actually there.

**Adjacency:** list=not-applicable (a codebase intake holds no records a user browses); document=applicable @ D00 T03 §4; settings=not-applicable (no user-facing settings are introduced by a move); reporting=not-applicable (nothing here reports to a user); notifications=not-applicable (a one-time intake notifies nobody); permissions=not-applicable (no role model in a source move); audit=applicable @ D00 T03 §1; exchange=not-applicable (nothing is imported or exported at runtime); reverse=not-applicable (git history is the reverse for a source move)

**Adjacency rationale:** Audit anchors on §1 because preserving commit history **is** the audit trail for a library fourteen tools will depend on, and it is the one thing in this file that cannot be recovered later if it is skipped. Document anchors on §4 because the README currently describes a stack that was deleted, which is worse than no README for anyone approaching the code cold.

## Implementation Order

| Order | Section | Deliverable                          | Depends On | Status |
| :---: | :-----: | ------------------------------------ | ---------- | :----: |
|   1   |   §1    | Subtree merge with history preserved | --         |  [ ]   |
|   2   |   §2    | Rename the product to Resolute       | §1         |  [ ]   |
|   3   |   §3    | Rename the library and the toolchain | §2         |  [ ]   |
|   4   |   §4    | Correct the stale documentation      | §3         |  [ ]   |

---

## 1. Subtree Merge With History Preserved

`exo-ui` is about to become the foundation of fourteen tools. How it got to be the shape it is will matter, and it is recoverable now and never again once the embedded repositories are discarded.


**Build order.** Do these in order; a wrong order costs history that cannot be recovered afterwards.

1. **Back out a safety branch first.** `git branch pre-intake` on `master`. Done when: `git branch --list pre-intake` prints it, so every later stage is revertable with one command.
2. **Add the remotes, do not use the local checkouts.** `git remote add exosuite https://github.com/rizonesoft/ExoSuite.git` and the same for `regstudio`. Done when: `git fetch exosuite` and `git fetch regstudio` both succeed.
3. **Merge ExoSuite first**, because RegStudio's authoritative copy is decided against what it brings. `git subtree add --prefix=. exosuite master` is wrong here: use a staging prefix, then move, because a root-prefix subtree collides. Done when: the tree lands and `git log -- shared/` shows `efdce6177`.
4. **Resolve the six collisions** from the table below, one commit each. Done when: `git status` is clean and no file from the incoming tree has overwritten a repository file unexamined.
5. **Merge RegStudio**, then delete the duplicate under `extensions/`. Done when: exactly one RegStudio tree exists and `git log` over it shows `c9b8a0b`.
6. **Retire Console and the `libvterm` submodule** per the item below. Done when: `.gitmodules` is empty or gone and `git clone` without `--recursive` builds.
7. **Confirm `samples/` never enters the index.** Done when: `git ls-files samples` is empty.

- [ ] Take `ExoSuite` in through `git subtree`, **from its remote rather than a local path**, landing its tree at the repository root alongside `resolute_au3/`. Done when: `git log -- shared/` shows commits predating the merge, including `efdce6177` and `09b1f92ab`, and the merge is reproducible on a machine with no local checkout.
- [ ] Resolve the six measured root collisions, each deliberately rather than by whichever side git picks. Done when: each is handled as below and none is left as a merge artifact.

  | Collision | Resolution |
  | --- | --- |
  | `todo/extensions/TODO-Console.md` | Console is not shipped; mark superseded and remove the directory |
  | `docs/extensions.md` | move into the repository's `docs/` |
  | `README.md` | the repository's wins; the incoming content is rewritten by §4 |
  | `.gitignore`, `.gitattributes` | merge the incoming rules into the repository's |
  | `build/` | ignored on both sides, no content to reconcile |

- [ ] Retire the `Console` extension and the `deps/libvterm` submodule with it. Done when: neither is built by any preset, `.gitmodules` is empty or removed, and a fresh clone **without** `--recursive` builds everything. Decided 2026-09-16: Console is not a shipped product, and it was `libvterm`'s only consumer, so the tree ends with **no external dependencies at all**. Reversing this means restoring both, which git history makes cheap.
- [ ] Preserve the retired source rather than deleting it. Done when: `Console` and its 1,762 lines are reachable in history, and this section names the commit, so the decision is reversible on evidence rather than on memory.
- [ ] Record the resulting root layout so later sections can rely on it. Done when: the layout below is true and `AGENTS.md` agrees with it.

  ```
  CMakeLists.txt  CMakePresets.json
  src/          the launcher shell
  shared/       resolute-ui, lucide
  extensions/   the tools, each a standalone executable
  deps/         third-party source
  reskit/       the bootstrapped toolchain
  resources/    application icons
  resolute_au3/ the frozen specification
  todo/ docs/ scripts/
  ```

- [ ] Take `RegStudio` in from its remote the same way. Measured 2026-09-16: `src/` and `CMakeLists.txt` are byte-identical between the standalone repository and the copy inside ExoSuite's `extensions/`, and only the standalone one carries history, latest `c9b8a0b`. Done when: one RegStudio tree remains, its history is present, and this section records the commit taken.
- [ ] Confirm `samples/` stays out of the repository. Done when: `/samples/` is gitignored, `git ls-files samples` is empty, and `git status` reports no embedded-repository warning. The local checkouts may stay on disk; they are working copies, not repository content.
- [ ] Reconcile the two `.gitignore` files so the merged tree ignores `build/`, `Bin/`, and the bootstrapped toolchain directory. Done when: a full bootstrap and build leaves `git status` clean.
- [ ] Record what was merged, from which remote, and at which commit. Done when: each subtree names its remote URL and source commit, so the merge can be repeated or audited later.
- [ ] Commit: `"intake: merge the exosuite codebase with its history"`

**Test checkpoint:** `git log -- shared/` shows pre-merge commits including `efdce6177`, and the merge is reproduced on a machine with no local `samples/` checkout. `git ls-files samples` is empty and no embedded-repository warning appears. A full bootstrap and build leaves `git status` clean. Each subtree's remote and source commit are quoted.

## 2. Rename the Product to Resolute

ExoSuite is not a second product. It is the Resolute launcher, and leaving the old name in the tree makes every later reader wonder whether there are two things.

- [ ] Rename the application and its artifacts: `ExoSuite.exe` to `Resolute.exe`, `src/ExoSuite.rc` to match, and the window class, title, and resource strings with it. Done when: the built executable is `Resolute.exe` and no window or resource string says ExoSuite.
- [ ] Update the build scripts that name the product. Done when: `Build-ExoSuite.ps1` is renamed and every script referencing the old product name is updated.
- [ ] Check the 32 files carrying the product name and resolve each. Done when: the only remaining occurrences are historical references in the brainstorm record and in commit messages, which are deliberately left alone.
- [ ] Give the application the Rizonesoft identity: the Resolute application icon, company, and copyright, generated rather than typed. Done when: the built executable reports them and the copyright year is generated.
- [ ] Commit: `"intake: rename the application to resolute"`

**Test checkpoint:** The build produces `Resolute.exe`. No window title, resource string, or build script says ExoSuite. The executable reports the Rizonesoft company and a generated copyright year. A search for the old product name returns only historical references, quoted.

## 3. Rename the Library and the Toolchain

108 occurrences across 25 files today, and it grows with every tool that includes a header. This is the cheapest this change will ever be.

- [ ] Rename `shared/exo-ui` to `shared/resolute-ui`, the `exo::` namespace to `rui::`, the `EXOUI_API` macro to `RESUI_API`, and the `exo/` include prefix to `resolute/`. Done when: the tree builds and no identifier or path carries the old name. Recorded as a dated default: these exact names are a choice, and changing them later costs more the longer it waits.
- [ ] Rename `exokit/` to `reskit/` and its scripts with it. Done when: the bootstrap runs from the new path and no script references the old one.
- [ ] Move the toolchain bootstrap so it runs from the repository root. Done when: `pwsh scripts/bootstrap.ps1` bootstraps the toolchain, and `D00 T01 §1` hardens what this section moves.
- [ ] Verify the rename changed names only. Done when: the built executable is byte-comparable to the pre-rename build except for embedded strings, or the differences are explained.
- [ ] Commit: `"intake: rename the ui library and the toolchain"`

**Test checkpoint:** The tree builds after the rename and no identifier, path, or script carries `exo` or `ExoKit`. The bootstrap runs from the repository root. The rebuilt executable is compared against the pre-rename build and every difference is explained.

## 4. Correct the Stale Documentation

The README describes a Rust and Slint stack that was deleted in `efdce6177`. Anyone approaching this code cold is told the wrong language, the wrong UI framework, and the wrong build system.

- [ ] Rewrite the README to describe what is there: C++23, Direct2D and DirectWrite, a repository-scoped llvm-mingw toolchain, CMake presets with Ninja, and static linking. Done when: no sentence describes Rust, Slint, or Cargo.
- [ ] Record the architecture: the UI library, the application shell, and the extension model where a tool builds as a standalone executable. Done when: a reader can tell which layer owns what.
- [ ] State what the codebase does **not** have, so no later section assumes it. Done when: the absence of tests, of vcpkg, and of the non-UI framework layers is written down.
- [ ] Reconcile `TODO.md` and `TODO-ux.md` against this plan. Done when: work still wanted is routed through `add-todo` and the rest is marked superseded, with `TODO-ux.md` recorded as the UX standard the suite is held to.
- [ ] Commit: `"intake: correct the documentation to the stack that exists"`

**Test checkpoint:** The README describes C++23, Direct2D, llvm-mingw, CMake, and static linking, with no mention of Rust, Slint, or Cargo. The absence of tests, vcpkg, and the non-UI framework layers is stated. Every item in `TODO.md` and `TODO-ux.md` is either routed or marked superseded.

## Verification

- [ ] `git log -- shared/` shows the pre-merge history
- [ ] No `.git` directory remains under `samples/` and no embedded-repository warning appears
- [ ] The build produces `Resolute.exe` and nothing carries the ExoSuite, exo, or ExoKit names
- [ ] The toolchain bootstraps from the repository root and the build is clean afterwards
- [ ] The README describes the stack that is actually present
- [ ] `python scripts/todo-graph.py validate` clean
