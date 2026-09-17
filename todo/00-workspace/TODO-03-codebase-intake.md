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
> **Current state (verified 2026-09-16):** `ExoSuite`, `RegStudio`, and `SDImage` are **separate repositories** under `github.com/rizonesoft`, checked out locally under `samples/` and **deliberately not tracked** by this repository: `/samples/` is gitignored. The subtree merge pulls from the remotes, so nothing depends on a local working copy. `deps/libvterm` is a **git submodule** pointing at `neovim/libvterm`, currently populated with 81 files. **Corrected 2026-09-17 after independent review:** an earlier draft called it the tree's *only* external dependency, which was wrong. `shared/lucide/CMakeLists.txt:9` also fetches `sammycage/lunasvg` v3.5.0 through `FetchContent` at configure time. ExoSuite is a working native C++23 application: `shared/exo-ui` is 6,865 lines of Direct2D and DirectWrite UI framework, `src/main.cpp` is a 573-line shell, `extensions/` holds `RegStudio` and `Console`, and `exokit/` is a working toolchain bootstrap pulling llvm-mingw 20251216, CMake 4.2.3, and Ninja 1.13.1. `Bin/Release/ExoSuite.exe` is 1,423,872 bytes, 1.36 MiB. **Corrected 2026-09-17:** it is **not** fully static. Rebuilding the merged tree produces a 1,380,352-byte executable plus `System/ExoUI.dll` and `System/Lucide.dll`, 3.9 MB in total. `D00 T01 §2` owns the correction. There is **no vcpkg**. There are **no tests**; `test_font.cpp` is a scratch file. The `README.md` still describes a Rust and Slint stack that commit `efdce6177` removed. The product name appears in 32 files; `exo::`, `EXOUI_API`, and `exo/` appear 108 times across 25 files.
>
> <!-- claim: exists shared/resolute-ui/include/resolute/theme.h -->
> <!-- claim: exists scripts/bootstrap.ps1 -->
> <!-- claim: lines src/main.cpp = 573 -->
> <!-- claim: count "llvm-mingw" toolchain.json = 4 -->
>
> **Corrected 2026-09-16** during `§1` validation, three claims in the paragraph above were wrong:
>
> - It said `deps/libvterm` **is vendored** in one sentence and **is a git submodule** in another. It is a submodule, and it is staged but **not committed** in the local checkout, so it is in neither the remote nor this repository.
> - It said the executable is **1.39 MB**. It is 1,423,872 bytes, which is 1.36 MiB.
> - The `shared/exo-ui` figure of 6,865 lines was measured on the **local working tree**, which carries ten source files the remote does not have. The remote's copy is materially smaller and older.

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
|   1   |   §1    | Subtree merge with history preserved | --         |  [x]   |
|   2   |   §2    | Rename the product to Resolute       | §1         |  [x]   |
|   3   |   §3    | Rename the library and the toolchain | §2         |  [x]   |
|   4   |   §4    | Correct the stale documentation      | §3         |  [x]   |

---

## 1. Subtree Merge With History Preserved

> **Started:** 2026-09-16T21:47:21Z

`exo-ui` is about to become the foundation of fourteen tools. How it got to be the shape it is will matter, and it is recoverable now and never again once the embedded repositories are discarded.

> [!CAUTION]
> **Blocked 2026-09-16: the remote is materially behind the local checkout, and merging from it would destroy work.**
>
> This section instructed "add the remotes, do not use the local checkouts". Validation found that instruction is unsafe as written. `samples/ExoSuite` carries **54 uncommitted entries** against `origin/main`:
>
> | Not in the remote at all | Why it matters |
> | --- | --- |
> | `extensions/Console/` | The entire Console extension, 1,762 lines. `§1` claims to preserve it in history, and the history does not have it |
> | `TODO-ux.md` | 66 done and 101 open UX items. `DESIGN.md` is derived from it and `D01 T02 §1` opens the file that routes all 101 of them |
> | Ten `shared/exo-ui` files | `animation`, `contentview`, `listview`, `popupmenu`, `typography`, headers and sources |
> | `docs/`, `todo/`, `installers/`, `resources/application.ico` | Including two of the six collisions this section plans to resolve |
>
> Twenty further tracked files are **modified** locally, including `src/main.cpp`, `src/ExoSuite.rc`, and most of `exo-ui`: `sidebar`, `statusbar`, `toolbar`, `export`, `icons`, `render`, `theme`, and `lucide`. `.gitmodules`, `deps/libvterm`, and the `extensions/regstudio` to `extensions/RegStudio` rename are **staged and uncommitted**.
>
> A merge from `exosuite/main` today produces an older, smaller codebase missing Console, missing the UX standard the design contract is built on, and missing a third of the UI library.
>
> **This is an operator decision, not an implementation choice.** The options are recorded in the item below. Nothing in this section may run until one is taken, because the failure is silent: the merge succeeds and the loss is only visible later.


**Build order.** Do these in order; a wrong order costs history that cannot be recovered afterwards.

1. **Back out a safety branch first.** `git branch pre-intake` on `master`. Done when: `git branch --list pre-intake` prints it, so every later stage is revertable with one command.
2. **Add the remotes.** `git remote add exosuite https://github.com/rizonesoft/ExoSuite.git` and the same for `regstudio`. Done when: `git fetch exosuite` and `git fetch regstudio` both succeed. **Corrected 2026-09-16:** the original wording, "do not use the local checkouts", is unsafe while the precondition above is open, because the remote does not carry what the local checkout has.
3. **Merge ExoSuite first**, because RegStudio's authoritative copy is decided against what it brings. **Corrected 2026-09-16:** the branch is `main`, not `master`, and the mechanism is `git merge --allow-unrelated-histories exosuite/main`, **not** `git subtree`. Proven by experiment on a throwaway branch: a plain merge lands the tree at the root directly, needs no staging prefix and no move, and `git log -- shared/` shows `efdce61` and `09b1f92` afterwards. `git subtree` was specified to avoid a root-prefix collision that does not occur, and it would additionally establish an ongoing subtree relationship this one-time intake does not want. Done when: the tree lands and `git log -- shared/` shows `efdce6177`.
4. **Resolve the conflicts** from the table below. **Corrected 2026-09-16:** a merge conflicts on **three** files, not six: `.gitattributes`, `.gitignore`, and `README.md`. The other three entries are not git conflicts. `docs/extensions.md` and `todo/extensions/TODO-Console.md` are untracked in the source and so arrive only if the precondition above is resolved by committing them; `build/` is ignored on both sides. Done when: `git status` is clean and no file from the incoming tree has overwritten a repository file unexamined.
5. **Merge RegStudio**, then delete the duplicate under `extensions/`. Done when: exactly one RegStudio tree exists and `git log` over it shows `c9b8a0b`.
6. **Retire Console and the `libvterm` submodule** per the item below. Done when: `.gitmodules` is empty or gone and `git clone` without `--recursive` builds.
7. **Confirm `samples/` never enters the index.** Done when: `git ls-files samples` is empty.

- [x] **Resolve the precondition above before merging anything.** **Resolved 2026-09-17: option A, adapted.** The 52 real entries were committed in `samples/ExoSuite` as `fffd8b4`, excluding `test_font.exe` and `test_font.obj` which were gitignored as build output. The merge then took the **local** repository rather than the remote, so nothing was published to `github.com/rizonesoft/ExoSuite` on the operator's behalf; that push remains theirs to make. Done when: one option is taken and recorded here, with its date.

  | Option | What it costs |
  | --- | --- |
  | **A. Commit and push the local ExoSuite work first**, then merge from the remote as planned | The operator's call on their own repository. Preferred: the preserved history is then complete, which is the entire point of this section |
  | **B. Merge from the local repository path** instead of the remote | Keeps the uncommitted work only if it is committed locally first; untracked files still do not travel through a merge |
  | **C. Merge from the remote, then copy the missing work over** | Lands it without its history, which contradicts this file's Goal and its `audit` adjacency |

- [x] Take `ExoSuite` in with `git merge --allow-unrelated-histories`, landing its tree at the repository root alongside `resolute_au3/`. Merged at `ac97ed7` from `samples/ExoSuite` at `fffd8b4`. `git log -- shared/` reaches `efdce61` and `09b1f92`; the repository went from 12 commits to 348. Done when: `git log -- shared/` shows commits predating the merge, including `efdce6177` and `09b1f92ab`, and the merge is reproducible from a clean clone.
- [x] Resolve the measured root collisions, each deliberately rather than by whichever side git picks. **Three conflicted, as the corrected Build order predicted.** `.gitattributes`: kept LF normalisation and refused the incoming Git LFS rules, with the reason recorded in the file. `.gitignore`: merged the incoming C++ and toolchain rules, added the `reskit/` forms so both sides of the `§3` rename are covered, and dropped the stale `TODO.md` entry because ExoSuite brings a real one that `§4` reconciles. `README.md`: the repository's won. Done when: each is handled as below and none is left as a merge artifact.

  | Collision | Resolution |
  | --- | --- |
  | `todo/extensions/TODO-Console.md` | Console is not shipped; mark superseded and remove the directory |
  | `docs/extensions.md` | move into the repository's `docs/` |
  | `README.md` | the repository's wins; the incoming content is rewritten by §4 |
  | `.gitignore`, `.gitattributes` | merge the incoming rules into the repository's |
  | `build/` | ignored on both sides, no content to reconcile |

- [x] Retire the `Console` extension and the `deps/libvterm` submodule with it. Done at `e1f26a1`: `.gitmodules` removed, `deps/` gone, and `CMakeLists.txt` records why at the line where `add_subdirectory(extensions/Console)` stood. Done when: neither is built by any preset, `.gitmodules` is empty or removed, and a fresh clone **without** `--recursive` builds everything. Decided 2026-09-16: Console is not a shipped product, and it was `libvterm`'s only consumer, so the tree ends with **no submodule**. **Corrected 2026-09-17 after independent review:** an earlier draft of this line read "no external dependencies at all", which was wrong: `shared/lucide/CMakeLists.txt:9` still fetches `sammycage/lunasvg` v3.5.0 through `FetchContent`, so a fresh configure reaches the network. What retiring the submodule bought is the `--recursive` flag, not dependency freedom. `D00 T01 §2` owns the policy covering lunasvg and Catch2. Reversing this means restoring both, which git history makes cheap.
- [x] Preserve the retired source rather than deleting it. **Reachable at `ac97ed7:extensions/Console`**, measured at 1,762 lines, matching the figure this section recorded before the merge. Done when: `Console` and its 1,762 lines are reachable in history, and this section names the commit, so the decision is reversible on evidence rather than on memory.
- [x] Record the resulting root layout so later sections can rely on it. **Corrected 2026-09-17: `deps/` is gone**, because retiring Console removed the only external dependency. `installers/` did not arrive, having been empty. `.github/` and `.vscode/` did. Done when: the layout below is true and `AGENTS.md` agrees with it.

  ```
  CMakeLists.txt  CMakePresets.json
  src/          the launcher shell
  shared/       exo-ui and lucide, renamed by §3
  extensions/   the tools, each its own executable
  exokit/       the toolchain bootstrap, renamed reskit/ by §3
  resources/    application icons
  resolute_au3/ the frozen specification
  todo/ docs/ scripts/
  ```

  No `deps/`: retiring Console removed the `libvterm` submodule, so a clone **without `--recursive`** builds. **Corrected 2026-09-17 after independent review:** this is not the same as having no external dependencies. `shared/lucide/CMakeLists.txt:9` fetches `sammycage/lunasvg` v3.5.0 through `FetchContent`, so a fresh configure still reaches the network for third-party source. `D00 T01 §2` owns the dependency policy that must account for it.

- [x] Take `RegStudio` in from its remote, by `git subtree` rather than a root merge, because its layout is root-level and would collide. Its full 10-commit history is reachable and `c9b8a0b` is an ancestor of `HEAD`. The ExoSuite copy was removed first at `862cfb5`, byte-identical in `src/` and `CMakeLists.txt`, verified before removal. Measured 2026-09-16: `src/` and `CMakeLists.txt` are byte-identical between the standalone repository and the copy inside ExoSuite's `extensions/`, and only the standalone one carries history, latest `c9b8a0b`. Done when: one RegStudio tree remains, its history is present, and this section records the commit taken.
- [x] Confirm `samples/` stays out of the repository. `git ls-files samples` is empty and no embedded-repository warning appears. Done when: `/samples/` is gitignored, `git ls-files samples` is empty, and `git status` reports no embedded-repository warning. The local checkouts may stay on disk; they are working copies, not repository content.
- [x] Reconcile the two `.gitignore` files so the merged tree ignores `build/`, `Bin/`, and the bootstrapped toolchain directory. **A full release build leaves `git status` clean**, verified after building 52/52 targets. **Verified again 2026-09-17 by review, this time against a real bootstrap:** running `exokit/Bootstrap-ExoKit.ps1` downloaded the toolchain into `exokit/` and `git status` stayed clean, so the ignore rules hold for the directories rather than only for the build output. The rules are written for both `exokit/` and the `reskit/` name `§3` renames it to, so the rename cannot silently un-ignore 850 MB.
<!-- claim: absent exokit -->
<!-- claim: count "reskit/llvm-mingw" .gitignore = 1 -->
- [x] Record what was merged, from which source, and at which commit:

  | Source | Mechanism | Commit | Landed |
  | --- | --- | --- | --- |
  | `samples/ExoSuite` (local, in sync with `github.com/rizonesoft/ExoSuite`) | `git merge --allow-unrelated-histories` | `fffd8b4` | root |
  | `github.com/rizonesoft/RegStudio` | `git subtree add` | `c9b8a0bc51809b2d0805f874919b41f99347ce85` | `extensions/RegStudio` |

  ExoSuite was taken from the local checkout because the remote lacked 52 entries; `fffd8b4` is the commit that captured them and is identical in both once pushed.
- [x] Commit: `"intake: merge the exosuite codebase with its history"` -- landed as `ac97ed7`, with the four follow-on commits named in the items above.

**Test checkpoint:** The precondition above is resolved and the chosen option is recorded with its date. `git log -- shared/` shows pre-merge commits including `efdce6177` and `09b1f92ab`. `extensions/Console/` and `TODO-ux.md` are present at the merge commit, and so are the ten `shared/exo-ui` files, **checked at these exact paths** because their absence is the failure this section nearly shipped:

  ```
  include/exo/animation.h            src/animation.cpp
  include/exo/typography.h           src/typography.cpp
  include/exo/controls/contentview.h src/controls/contentview.cpp
  include/exo/controls/listview.h    src/controls/listview.cpp
  include/exo/controls/popupmenu.h   src/controls/popupmenu.cpp
  ```

  **Corrected 2026-09-17 by review:** the checkpoint previously named the five components without their paths, and re-verifying it produced three false MISSING results, because `contentview`, `listview`, and `popupmenu` live under `controls/` rather than beside the others. A checkpoint that cannot be executed the same way twice is not evidence; the paths are now written down. Console is checked at `ac97ed7`, not at `HEAD`, because `e1f26a1` deliberately retired it. `git ls-files samples` is empty and no embedded-repository warning appears. A full bootstrap and build leaves `git status` clean. Each merge's source remote and commit are quoted.

> **Verified:** 2026-09-17 | §1 | `git log -- shared/` reaches `efdce61` and `09b1f92` · `c9b8a0b` is an ancestor of `HEAD` · all ten `shared/exo-ui` files plus `extensions/Console` and `TODO-ux.md` present at `ac97ed7`, each checked at its exact path · `git ls-files samples` empty, no embedded-repository warning · real bootstrap exit 0 installing CMake 4.2.3, Ninja 1.13.1, clang 21.1.8 · `build/release` deleted and reconfigured, `grep -c samples CMakeCache.txt` = 0 · 52/52 targets · `ExoSuite.exe` 1,380,352 bytes plus two DLLs, 3.9 MB · `git status` clean after 850 MB of toolchain
> **Review:** round 1, candidate `ac97ed7` `862cfb5` `1b99463` `e1f26a1` `ffa97c3` `8ba1f20` -- `adversarial` approve · `consistency` approve after fixes (2) · `integration` approve after fix and filing (1) · `source-defect` approve · `design` not-applicable · `record` approve after fixes (1). Raw findings: docs/reviews/00-workspace/D00-T03-s1.md
> **Independent:** `codex review --commit ffa97c3` (gpt-6-astra, high) returned 2 P2 findings, both verified against source, both correct, both fixed in `8ba1f20`: the static-linking diagnosis named the SHARED targets when the application links `ExoUI_static` and the real dependency is the runtime `LoadLibraryW` in icons.cpp; and "no external dependencies at all" was false because lucide fetches lunasvg v3.5.0. Neither was argued. The skill's own invocation was corrected: `--commit` refuses a prompt. **Second pass:** `codex review --commit 8ba1f20` reviewed the fix commit itself, which the first pass could not have seen, and returned no actionable regressions, independently re-verifying all four added claims against that commit. The stamp commit `0dbfa56` remains unreviewed by design: it carries only this stamp.
> **CRUD:** not applicable (this section moves history between repositories and creates no user-facing data path)
> **Duration:** 25
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## 2. Rename the Product to Resolute

> **Started:** 2026-09-16T22:31:00Z

ExoSuite is not a second product. It is the Resolute launcher, and leaving the old name in the tree makes every later reader wonder whether there are two things.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Four corrections, recorded here rather than absorbed silently.**
>
> **The count moved.** This section said 32 files. Measured today with `git grep -il exosuite` over tracked files: **29**. The figure was taken on 2026-09-16, before `ac97ed7` retired Console and before the review added its findings file.
>
> **The identity values are not a choice to invent.** The shipping AutoIt product declares them, and `AGENTS.md` makes `resolute_au3/` the source of truth for target behaviour:
>
> | Field | Value | Source |
> | --- | --- | --- |
> | ProductName | `Resolute` | `#AutoIt3Wrapper_Res_Field=ProductName|Resolute` |
> | FileDescription | `Resolute Power Tools` | `#AutoIt3Wrapper_Res_Description` |
> | CompanyName | `Rizonesoft` | `#AutoIt3Wrapper_Res_Field=CompanyName|Rizonesoft` |
> | Copyright | `Copyright (c) <year> Rizonesoft` | the launcher builds it from `@YEAR` at runtime |
>
> The AutoIt launcher generates its year rather than typing it, which is what this section's "generated rather than typed" means. **Dated default 2026-09-17:** the C++ build generates the year at *configure* time through CMake, not at runtime, so a binary states the year it was built. Cost of changing: one `configure_file` line.
>
> **The application icon is the existing ExoSuite artwork, renamed.** **Operator decision 2026-09-17, overriding this session's default.** Validation had proposed copying `resolute_au3/SDK/Resources/Icons/Resolute.ico`, the shipping AutoIt launcher's icon, on the reasoning that the C++ launcher should inherit the identity of the product it replaces. The operator chose instead to keep the ExoSuite artwork and make it Resolute's. That is the better call for a reason the default missed: the AutoIt icon belongs to the tool being retired, while the ExoSuite artwork was drawn for this codebase and its Direct2D surface. `resources/ExoSuite.ico` is renamed to `resources/icons/Resolute.ico` with `git mv`, so the artwork keeps its history. The AutoIt icon stays where it is and is not copied. Cost of changing: one file swap, since nothing but the `.rc` names it.
>
> **Icons live in `resources/icons/`.** **Operator decision 2026-09-17.** They were loose in `resources/`, which is fine for four files and wrong for what is coming: `DESIGN.md` makes the application icon the one deliberate exception to the shared-library rule, so **every tool owns one**, and eighty tools' icons loose beside the build resources is a directory nobody can read. The convention is one flat directory keyed by product name, `resources/icons/<Product>.ico`, with `application.ico` as the generic fallback. Flat rather than per-tool subdirectories, because a tool has one icon and a directory per tool would be four-fifths empty. The `.rc` reaches it through a single CMake variable, `RESOLUTE_RESOURCE_DIR`, so moving the directory again costs one line.
>
> **`src/ExoSuite.rc` has no `VS_VERSION_INFO` block at all.** Measured 2026-09-17: the file is five lines and declares two icons and nothing else. So company and copyright are *absent*, not wrong, and this section adds the block rather than editing one.

<!-- claim: absent shared/exo-ui -->
<!-- claim: absent todo/extensions -->
<!-- claim: count "\n- \[ \]" TODO.md = 348 -->
<!-- claim: count "\n- \[ \]" TODO-ux.md = 101 -->
<!-- claim: count "RESEXT" docs/extensions.md = 16 -->
<!-- claim: count "RESEXT" src/main.cpp = 6 -->
<!-- claim: absent resources/ExoSuite.ico -->
<!-- claim: exists resources/icons/Resolute.ico -->
<!-- claim: exists resources/icons/application.ico -->

- [x] Rename the application and its artifacts: `ExoSuite.exe` to `Resolute.exe`, `src/ExoSuite.rc` to match, and the window class, title, and resource strings with it. Done when: the built executable is `Resolute.exe` and no window or resource string says ExoSuite.
- [x] Update the build scripts that name the product. Done when: `Build-ExoSuite.ps1` is renamed and every script referencing the old product name is updated.
- [x] Check the files carrying the product name and resolve each. **Corrected 2026-09-17:** the count read 32 and is **29** today, and the Done-when as written was unbuildable. It named only the brainstorm record and commit messages as legitimate survivors, which would require rewriting the intake record itself. Done when: every occurrence outside the survivor set below is resolved, and the survivor set is exactly:

  | Kept | Occurrences | Why it must not be rewritten |
  | --- | ---: | --- |
  | `.gitattributes` | 1 | states that ExoSuite carried Git LFS rules at intake, a fact about the merge |
  | `.gitignore` | 2 | two comments on where the C++ ignore rules came from |
  | `docs/brainstorm/2026-09-16-completion-brainstorm.md` | 17 | the decision record, written when the name was current |
  | `docs/captures/ui-automation-spike.md` | 3 | a dated spike record |
  | `docs/reviews/00-workspace/D00-T03-s1.md` | 9 | the `§1` review, same reason |
  | `todo/00-workspace/INDEX.md` | 2 | the intake TODO's own title, which is accurate: the work intakes the ExoSuite codebase |
  | `todo/00-workspace/TODO-01-toolchain-and-gates.md` | 4 | names where the bootstrap came from, plus this section's own repointing notes |
  | `todo/00-workspace/TODO-03-codebase-intake.md` | self | **this file.** It documents merging a repository *named* ExoSuite; renaming those references would make the record false. The count is deliberately not given: a file that tabulates its own occurrences changes that count by tabulating them, so any figure here is stale the moment it is written |
  | `todo/01-framework/TODO-02-design-system.md` | 1 | this section's repointing note |
  | `todo/05-new-tools/TODO-02-regstudio.md` | 1 | quotes the pre-intake duplicate state for the record |
  | `todo/06-distro-release/TODO-01-build-and-release.md` | 2 | a copyright-ownership fact about the codebase |
  | `todo/implementation-plan.md` | 3 | describes the intake and states that the name is **not** kept |
  | commit messages | n/a | history is not editable and must not be |

  And three that belong to `§4`, left untouched here rather than renamed:

  | Routed | Occurrences | Owner |
  | --- | ---: | --- |
  | `TODO-ux.md` | 1 | `D00 T03 §4` reconciles it; `D01 T02 §1` opens the file that routes its 101 open items |
  | `TODO.md` | 19 | `D00 T03 §4` reconciles it |
  | `docs/extensions.md` | 7 | `D00 T03 §4` records the architecture and the extension model |

  Cheaper substitute that fails the checkpoint: a tree-wide search-and-replace, which satisfies the letter by falsifying the intake record and the commit history's own subject lines.

- [x] Route the documentation carrying the old name to the section that owns it rather than rewriting it here. **Added 2026-09-17:** `TODO.md` (19), `TODO-ux.md` (1), and `docs/extensions.md` (7) all carry the product name, and all three are `D00 T03 §4`'s to reconcile, not this section's to rename. Done when: this section leaves all three untouched and `§4` names them.

- [x] Fix the stale absolute path this rename exposes. **Found 2026-09-17 while counting:** `.vscode/settings.json` sets `cmake.sourceDirectory` to `R:/GitHub/ExoSuite/extensions/regstudio`, a path that does not exist on this machine, verified. It is broken independently of the rename. Done when: the setting points at a path inside this repository or is removed, and the reason is recorded.
- [x] Give the application the Rizonesoft identity: the Resolute application icon, company, and copyright, generated rather than typed. The values and the icon path are fixed in the block above, taken from the shipping product rather than invented. Done when: the built executable reports ProductName `Resolute`, CompanyName `Rizonesoft`, and FileDescription `Resolute Power Tools`, read back **from the built binary** rather than from the source that produced it, and the copyright year is generated at configure time rather than typed. Cheaper substitute that fails the checkpoint: typing the current year into the `.rc`, which is correct today and silently wrong every January.
- [x] Commit: `"intake: rename the application to resolute"`

**Test checkpoint:** The build produces `Resolute.exe` and no `ExoSuite.exe`. No window title, resource string, or build script says ExoSuite. The built binary's version resource is read back and reports ProductName `Resolute`, CompanyName `Rizonesoft`, FileDescription `Resolute Power Tools`, and a copyright year equal to the year the build ran, proven by reading the binary rather than the `.rc`. `.vscode/settings.json` names no path outside this repository. `git grep -il exosuite` returns **only** the six survivors tabulated above, and the list is quoted in full so an extra entry is visible rather than absorbed into a count.

> **Verified:** 2026-09-17 | §2 | build produces `Resolute.exe` and no `ExoSuite.exe`, both presets, 52/52 each · version resource read back **from the binary**: ProductName `Resolute`, CompanyName `Rizonesoft`, FileDescription `Resolute Power Tools`, `Copyright (c) 2026 Rizonesoft`, year equal to the build year · the year is generated, proven both ways: `src/Resolute.rc.in` contains no `20xx` literal and the generated `build/release/src/Resolute.rc` contains 2026 · `git grep -in exosuite` returns 0 hits across `src/ exokit/ shared/ extensions/ CMakeLists.txt CMakePresets.json .github/ .vscode/` · `.vscode/settings.json` names no path outside the repository
> **Review:** round 1, candidate `7d3ac0d` plus the follow-up fix -- `adversarial` approve · `consistency` approve after fix (1) · `integration` approve · `source-defect` approve · `design` not-applicable · `record` approve. Raw findings: docs/reviews/00-workspace/D00-T03-s2.md
> **Independent:** `codex review --commit 7d3ac0d` (gpt-6-astra, high) found **no actionable regressions**, and independently ran both self-test suites and the claims checker. It did not find F1, the duplicate `IDI_APPFALLBACK`, which is invisible to a diff reader because the redefinition is legal and the file it duplicates is one the diff also touches. Found by self-review instead, and fixed.
> **CRUD:** not applicable (this section renames build artifacts and writes no user-facing data)
> **Duration:** 9
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## 3. Rename the Library and the Toolchain

> **Started:** 2026-09-16T22:42:10Z

The count grows with every tool that includes a header. This is the cheapest this change will ever be.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Four corrections.**
>
> **The count moved, and by more than drift.** This section said 108 occurrences across 25 files, measured 2026-09-16 against the pre-merge tree. Measured today across `exo::`, `EXOUI_API`, `exo/`, `exo-ui`, and `ExoUI`: **214 occurrences across 39 files**. The 39 includes prose; the code is **28 files** under `src/` and `shared/`. `extensions/` carries **none**, so RegStudio does not consume the UI library yet and the blast radius is smaller than the raw count suggests.
>
> **One match is a false positive and is excluded.** `resolute_au3/samples/ComWinRep/~Samples/Windows Repair KIT/Rescue/system` is a **binary Windows registry hive** that happens to contain the byte sequence. `AGENTS.md` makes `resolute_au3/` read-only outside the maintenance domain, so it is not touched.
>
> **`D00 T01 §1` names the toolchain directory three different ways**, and it depends on this section, so this section's choice settles it. Measured 2026-09-17: its Build order says `reskit/`, two of its items say `.toolchain/`, and its Inputs say `exokit/`. `.gitignore` already anticipates `reskit/`. **`reskit/` wins** and `D00 T01 §1` is corrected to match, because a section cannot harden a directory it cannot name consistently.
>
> **The split between `reskit/` and `scripts/` was left to the implementer, so it is decided here.** Items 2 and 3 together are ambiguous: item 2 renames `exokit/` "and its scripts with it", while item 3 moves the bootstrap to `scripts/bootstrap.ps1`. **Dated default 2026-09-17**, consistent with `AGENTS.md` describing `reskit/` as "gitignored except for its scripts":
>
> | Path | Holds | Tracked |
> | --- | --- | --- |
> | `scripts/bootstrap.ps1` | the one entry point that downloads the toolchain. `D00 T01 §1` hardens **this** file | yes |
> | `reskit/llvm-mingw`, `reskit/cmake`, `reskit/ninja` | the downloaded toolchain | no, gitignored |
> | `reskit/Init-ExoKit.ps1`, `reskit/Build-*.ps1` | the environment and build helpers | yes |
>
> There is **one** copy of the download logic, in `scripts/bootstrap.ps1`. The old `Bootstrap-ExoKit.ps1` is moved rather than copied, so no second copy can drift. Cost of changing: the paths are computed from `$PSScriptRoot`, so moving either directory is a one-line edit.

- [x] Rename `shared/exo-ui` to `shared/resolute-ui`, the `exo::` namespace to `rui::`, the `EXOUI_API` macro to `RESUI_API`, and the `exo/` include prefix to `resolute/`. **Added 2026-09-17:** the CMake targets `ExoUI` and `ExoUI_static` are renamed to `ResoluteUI` and `ResoluteUI_static` too, because the Done-when says *no identifier* carries the old name and a target name is an identifier. Done when: the tree builds and no identifier or path carries the old name. Recorded as a dated default: these exact names are a choice, and changing them later costs more the longer it waits.
- [x] Rename `exokit/` to `reskit/` and its scripts with it. Done when: the bootstrap runs from the new path and no script references the old one.
- [x] Move the toolchain bootstrap so it runs from the repository root. Done when: `pwsh scripts/bootstrap.ps1` bootstraps the toolchain, and `D00 T01 §1` hardens what this section moves.
- [x] Verify the rename changed names only. **Made falsifiable 2026-09-17:** "byte-comparable" cannot be asserted after the fact without a recorded before, so the pre-rename fingerprints are written down here first, measured immediately before the rename began:

  | Artifact | Bytes | SHA-256, first 16 |
  | --- | ---: | --- |
  | `Bin/Release/Resolute.exe` | 1,381,376 | `94B62BC22E2295AF` |
  | `Bin/Release/System/ExoUI.dll` | 898,048 | `EB2E7EFAAC96C6C0` |
  | `Bin/Release/System/Lucide.dll` | 1,717,760 | `F589E28B75293D74` |

  Done when: the post-rename sizes are compared against these three and every difference is explained by a named cause. Cheaper substitute that fails the checkpoint: observing that the build still succeeds, which proves the code compiles and says nothing about whether the rename changed behaviour.

  **Result 2026-09-17. All three artifacts are identical in size, to the byte:**

  | Artifact | Before | After | Delta |
  | --- | ---: | ---: | ---: |
  | `Resolute.exe` | 1,381,376 | 1,381,376 | 0 |
  | `ExoUI.dll` to `ResoluteUI.dll` | 898,048 | 898,048 | 0 |
  | `Lucide.dll` | 1,717,760 | 1,717,760 | 0 |

  **The hashes differ, and the named cause is not the rename: this build is not reproducible.** `Lucide.dll` is the control. Its sources were never touched by this section, `git status shared/lucide/` is empty, and its hash changed anyway. Two consecutive clean builds of identical sources were then compared directly: `8B25CFEE72714F28` and `08C187347BF55A19`, same size both times. A build that cannot reproduce its own output twice in a row cannot be used to attribute a hash difference to a source change, so **byte-comparison is the wrong instrument here** and the section's original wording asked for something this toolchain cannot supply.

  **What proves the rename instead, and can fail:** the exported symbol table, read with `llvm-nm --extern-only --defined-only` on `ResoluteUI.dll`.

  ```
  213  _ZN3rui        the new namespace
    0  _ZN3exo        the old one
  1429               total exported symbols, so the instrument is reading something
  ```

  The third line is the falsifiability check: a count of zero for the old namespace means nothing unless the same command demonstrably finds symbols, which it does. `strings` over both shipped binaries also returns 0 for `_ZN3exo`, `exo-ui`, and `EXOUI`.
- [x] Commit: `"intake: rename the ui library and the toolchain"`

**Test checkpoint:** The tree builds after the rename, both presets, and `git grep -iE "exo::|EXOUI_API|exo/|exo-ui|ExoUI|exokit|ExoKit"` returns **no hits** under `src/`, `shared/`, `extensions/`, `scripts/`, `reskit/`, `CMakeLists.txt`, and `CMakePresets.json`. `pwsh scripts/bootstrap.ps1` bootstraps the toolchain from the repository root and a second run downloads nothing. `shared/exo-ui/` and `exokit/` no longer exist as paths. The rebuilt artifacts are compared against the three fingerprints recorded above and every difference is explained by a named cause. `todo-claims.py` passes, which it cannot do unless the claims naming `shared/exo-ui/` and `exokit/` were updated with the rename.

> **Verified:** 2026-09-17 | §3 | `git grep -inE "[A-Za-z_]*exo[A-Za-z_]*"` over `src shared extensions scripts reskit CMakeLists.txt CMakePresets.json` returns **none** · `shared/exo-ui` and `exokit` no longer exist · both presets build 52/52 · exported symbols: 213 `_ZN3rui`, 0 `_ZN3exo`, 1429 total, so the instrument demonstrably reads something · **driven run**: window created titled `Resolute` with child classes `ResoluteListView`, `ResoluteSidebar`, `ResoluteStatusBar`, `ResoluteToolbar` live · `pwsh scripts/bootstrap.ps1` runs from the repository root, 3 SKIP, 0.6s · all three artifacts identical in size to the pre-rename fingerprints recorded before the rename began
> **Review:** round 1, candidate `68c7ea9` plus the follow-up fix -- `adversarial` approve · `consistency` approve after fix (1) · `integration` approve · `source-defect` approve · `design` advisory · `record` approve. Raw findings: docs/reviews/00-workspace/D00-T03-s3.md
> **Independent:** `codex review --commit 68c7ea9` (gpt-6-astra, high) found **no actionable regressions** and confirmed the rename applies consistently across CMake targets, export macros, includes, and toolchain paths. It did not find F1 and said plainly it did not rebuild or run the application. Both misses share a shape: the surviving identifiers sit on lines that are internally consistent, so only a search for the old prefix in any spelling finds them.
> **CRUD:** not applicable (this section renames identifiers and paths and writes no user-facing data)
> **Duration:** 10
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## 4. Correct the Stale Documentation

> **Started:** 2026-09-16T22:52:46Z

Anyone approaching this code cold is told nothing at all, and the one document that does explain the architecture teaches a resource name that no longer exists.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Three corrections.**
>
> **This section's opening premise was false.** It said the README describes a Rust and Slint stack deleted in `efdce6177`. Measured today: `README.md` is **two lines**, `# Resolute` and a blank, and `grep -icE "rust|slint|cargo"` returns **0**. The ExoSuite README that did describe that stack lost the merge conflict at `ac97ed7`, where `§1` recorded "README.md: the repository's won". So the wrong-stack problem was solved by `§1` as a side effect, and what remains is an empty file.
>
> That matters for more than accuracy: the checkpoint said "no sentence describes Rust, Slint, or Cargo", which a two-line file passes **trivially and unfalsifiably**. The checkpoint is rewritten below to assert what the README must contain rather than what it must not.
>
> **`docs/extensions.md` is stale from `§3`, not only from `§2`.** It teaches `FindResourceW(hMod, "EXOEXT", RT_RCDATA)`, and `§3` renamed that resource to `RESEXT` after confirming it had zero producers. A document that teaches a discovery contract by its old name is worse than no document, because an extension author would follow it and produce an executable the launcher silently ignores. It also names `ExoUI.dll` and `Console.exe`, and Console was retired at `e1f26a1`.
>
> **Item 4 was mis-sized and double-owned.** It asks to reconcile `TODO.md` and `TODO-ux.md`. Measured: **348 open items** in `TODO.md` and **101** in `TODO-ux.md`. `TODO-ux.md` is already owned: `D01 T02 §1` opens the file and that TODO's Verification block requires every open item in it to be shipped, routed, or superseded. Two sections owning one reconciliation is how it gets done twice or not at all. **This section owns `TODO.md` and records that `D01 T02 §1` owns `TODO-ux.md`.**

- [x] Write the README, which is two lines today. **Corrected 2026-09-17:** the item said "rewrite ... Done when: no sentence describes Rust, Slint, or Cargo", and that is already true of a file containing only a title, so it could not fail. Done when: the README names the language standard, the UI stack, the toolchain, the build system, and how to build from a clean clone in commands a reader can run, **and** a reader who follows it reaches a built `Resolute.exe` without consulting anything else. Cheaper substitute that fails the checkpoint: a feature list, which reads well and does not get anybody to a build.

- [x] State the linking position accurately rather than aspirationally. **Added 2026-09-17:** `AGENTS.md` and the plan both describe static linking as the goal, and the release preset still ships `System/ResoluteUI.dll` and `System/Lucide.dll` beside the executable, measured today. Done when: the README says what is true now and names `D00 T01 §2` as the owner of making it static. Cheaper substitute: writing "statically linked" because the plan says so, which makes the README wrong on the day it is written.
- [x] Record the architecture: the UI library, the application shell, and the extension model where a tool builds as a standalone executable. Done when: a reader can tell which layer owns what.

- [x] Correct `docs/extensions.md`, which `§3` invalidated. **Added 2026-09-17:** it documents the discovery contract as `EXOEXT`, and `§3` renamed it to `RESEXT`. It also names `ExoUI.dll`, now `ResoluteUI.dll`, and `Console.exe`, retired at `e1f26a1`. Done when: the document names `RESEXT`, the current library file, no retired extension, and an extension author following it produces an executable the launcher actually discovers. Cheaper substitute that fails the checkpoint: renaming the strings without re-reading the walkthrough, which leaves a diagram describing a scan that no longer happens.
- [x] State what the codebase does **not** have, so no later section assumes it. Done when: the absence of tests, of vcpkg, and of the non-UI framework layers is written down.
- [x] Reconcile `TODO.md` against this plan. **Narrowed 2026-09-17:** the item covered `TODO-ux.md` too, which `D01 T02 §1` already owns through its own Verification block. Two owners for one reconciliation is how it happens twice or not at all. Done when: `TODO.md`'s 348 open items are accounted for as a whole, anything still wanted is named and routed with an owning section, and the file is marked superseded with the date and what superseded it. Cheaper substitute that fails the checkpoint: deleting it, which discards the ideas without anybody deciding they were not wanted.

- [x] Record `TODO-ux.md` as the UX standard and name its owner, without reconciling it here. Done when: the file says at its head that it is the UX standard the suite is held to and that `D01 T02 §1` routes its open items, and this section does not tick anything on its behalf.
- [x] Remove `todo/extensions/TODO-Console.md` and its directory. **Filed 2026-09-17 by `§3`'s validation:** `§1`'s collision table prescribed "mark superseded and remove the directory", `§1` is stamped, and the file is still there. It arrived through `fffd8b4` after the precondition was resolved by committing the untracked files, which is the path `§1` predicted but nobody then applied the prescribed resolution. Console itself was retired at `e1f26a1`, so its TODO now describes an extension the tree does not build. Done when: `todo/extensions/` does not exist and the Console decision is recorded where a reader will find it.
- [x] Clear the remaining Slint traces in editor configuration, not only in prose. **Filed 2026-09-17 by `§2`, which touched the file but did not own this:** `.vscode/settings.json` still maps `*.slint` to the `slint` language, though `efdce6177` deleted that stack. Done when: the association is gone and no tracked file outside the historical record configures a Slint toolchain.
- [x] Commit: `"intake: correct the documentation to the stack that exists"`

**Test checkpoint:** The README names C++23, Direct2D and DirectWrite, llvm-mingw, CMake with Ninja, and carries build commands that a reader can run from a clean clone to reach `Resolute.exe`; the commands are executed and quoted rather than assumed. It states the shipped set as it is today, DLLs included, and names `D00 T01 §2` as the owner of making it static. The absence of tests, vcpkg, `src/framework/`, and `src/repair/` is stated, each verified absent. `docs/extensions.md` names `RESEXT` and `ResoluteUI.dll` and no retired extension. `git grep -i exoext` returns **exactly one** hit outside the brainstorm, the reviews, and this file: the rename note in `docs/extensions.md` itself, which names the old resource deliberately so an extension author can tell why an executable embedding it is not listed. A document that changes a discovery contract silently is the failure this guards against. `TODO.md` is marked superseded with its date and successor, and anything still wanted from its 348 open items is named with an owning section. `TODO-ux.md` says `D01 T02 §1` owns it. `todo/extensions/` does not exist. `.vscode/settings.json` configures no Slint toolchain.

> **Verified:** 2026-09-17 | §4 | the README's build commands run **verbatim** from a deleted `build/` and `Bin/`: `pwsh scripts/bootstrap.ps1` 3 SKIP, `. .\reskit\Init-ResKit.ps1` 3 tools, `cmake --preset release`, `cmake --build --preset release` 52/52, reaching `Bin/Release/Resolute.exe` · README names C++23, Direct2D, DirectWrite, llvm-mingw, Ninja, and the section that owns the static-linking gap · the absences it states are each verified on disk: `tests`, vcpkg, `src/framework/`, `src/repair/`, `LICENSE` · `docs/extensions.md` names `RESEXT` 16 times against `src/main.cpp`'s 6, and no retired extension · `TODO.md` superseded with its one uncovered idea routed · `todo/extensions/` gone · 0 Slint references in tracked config
> **Review:** round 1, candidate `74caddc` plus the follow-up fix -- `adversarial` approve · `consistency` approve · `integration` approve · `source-defect` approve · `design` not-applicable · `record` approve after fix (1). Raw findings: docs/reviews/00-workspace/D00-T03-s4.md
> **Independent:** `codex review --commit 74caddc` (gpt-6-astra, high) found **no actionable regressions** and confirmed validation, claims, both self-tests, and plan freshness passed. It did not find F1 or F2, both invisible to a diff reader: a header stating its own file's line count reads as correct prose, and is wrong only *because* the line was added.
> **CRUD:** not applicable (this section writes documentation and no user-facing data path)
> **Duration:** 7
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## Verification

- [ ] `git log -- shared/` shows the pre-merge history
- [ ] No `.git` directory remains under `samples/` and no embedded-repository warning appears
- [ ] The build produces `Resolute.exe` and nothing carries the ExoSuite, exo, or ExoKit names
- [ ] The toolchain bootstraps from the repository root and the build is clean afterwards
- [ ] The README describes the stack that is actually present
- [ ] `python scripts/todo-graph.py validate` clean
