# Plan Audit -- 2026-09-16

Full audit of the TODO tree and the implementation plan against one question: **does this get the suite to 100 percent and ready for distribution, and can a much weaker executor actually run it?**

Every figure below is measured from the tree, not estimated.

## What was already sound

| Check | Result |
| --- | --- |
| `validate` | 0 fatal, 0 warning |
| `plan --check` | current, every section in exactly one phase |
| `self-test` | 393 cases, 0 failed |
| Micro-steps carrying a literal `Done when:` | **557 of 557** |
| Sections over 30 items, the spec's split threshold | none |
| Sections under 5 items | none |
| Dangling `DNN TNN §N` references | **none**; the four apparent ones are illustrative examples inside the format spec |
| Products with no owning domain | none |

Section sizing was healthy: only three sections exceeded 12 items, and the spec's own limit is 30.

## Faults found and fixed

### 1. Inno Setup was not in the plan

`D06 T01 §3` said "installer and portable edition" without naming a technology, while `resolute_au3/Resolute_setup.iss` and the per-tool `Setup.iss.txt` files already exist.

**Fixed.** `§3` is rewritten as *Installers: Per Tool and Whole Suite*, naming Inno Setup as kept, generating both the per-tool and the suite script from the release descriptors so thirty-nine `.iss` files are never hand-maintained, and requiring per-tool selection in the suite installer.

### 2. No silent or unattended install

Zero references anywhere. Every tool here is something an administrator would deploy across machines.

**Fixed.** `§3` now requires `/SILENT` and `/VERYSILENT` to complete unattended, honour a target directory and a tool selection, and return documented exit codes.

### 3. No migration from the AutoIt suite

The only upgrade coverage was upgrading over a previous **C++** version. Every existing user has AutoIt tools installed, and nothing said what happens on the day a C++ tool ships.

**Fixed.** New `D06 T01 §4`, *Migration From the AutoIt Suite*: detect the installed AutoIt version, migrate its settings including the `.lng` case, remove the old copy, and handle the consolidations, so a machine with `Chromin` ends up with `Firemin` and is told why. Proven on a virtual machine actually carrying the old suite.

### 4. No crash handling

All "crash" matches were the Crash Decoder tool or incidental prose. Nothing handled the suite's **own** failures, on tools that are frequently mid-way through changing a registry or an ACL.

**Fixed.** New `D01 T01 §10`. The load-bearing requirement is not the report: it is that **the repair contract's restore record is flushed before the process dies**, so a tool faulted mid-repair is still undoable, proven by undoing the wreckage from `Repair History`.

### 5. No single-instance guard

Zero references. Two copies of a repair tool operating on the same target simultaneously is a genuine hazard.

**Fixed.** Also `D01 T01 §10`, with the portable exception recorded as a dated decision rather than assumed, because a global mutex that blocks a technician's USB copy on a machine that has the suite installed is a plausible and annoying failure.

### 6. No command line and no exit codes

Zero real references. Every tool here is something an administrator would want to run across fifty machines from a script, and the plan gave them no way to.

**Fixed.** New `D01 T01 §11`: one argument grammar defined in the framework so no tool parses its own, five distinct documented exit codes, `--help` and `--version` generated from the tool descriptor, and a requirement that no destructive action runs unattended without an explicit authorising flag.

### 7. Build order blocks were unused

The format spec defines **Build order** as the mechanism for directing a cold agent through a section, and not one section used it.

**Fixed.** Added to the six highest-risk sections, chosen for where a wrong order costs real work or is destructive:

| Section | Why it needed one |
| --- | --- |
| `D00 T03 §1` | A subtree merge in the wrong order loses history unrecoverably. Stage 1 is now a safety branch |
| `D00 T01 §1` | Fifteen items over an existing working script; change one thing at a time |
| `D04 T01 §1` | The vertical slice decides whether the architecture is right; the baseline must be captured before any C++ exists |
| `D05 T05 §1` | Stage 1 is a **legal** precondition: record the clean-room statement before writing code |
| `D05 T05 §4` | Every stage before 4 is about not destroying the drive being rescued |
| `D05 T01 §3` | Media detection must precede any erase path, because which method is correct depends on it |

### 8. Renumbering broke references, then fixed them

Inserting the migration section pushed four `D06 T01` sections up by one, leaving stale inline references in four files.

All remapped and verified: `§8` is Licensing, `§5` is Update Files. This is exactly what the address-stability rule in `AGENTS.md` exists to prevent, and it was only safe because nothing in the tree is stamped.

## Gaps considered and deliberately not added

Recorded so they are not rediscovered as new ideas.

- **Telemetry.** Knowing which tools get used matters to the monetisation goal, but it is privacy-sensitive and belongs to a product decision rather than a plan gap. Not added.
- **Portable-mode detection.** `D01 T01 §2` already carries the portable and installed distinction, and `§10` now records the portable single-instance exception. Adequate.
- **First-run experience.** Covered adequately by the launcher's tool discovery and the conformance profile's standalone clause.
- **Update Impact Correlation.** Already deferred by decision 42; it needs the System Change Journal first.

## Where the plan stands after the audit

- **10 domains, 17 TODO files, 98 sections**, up from 93.
- **39 shipped products**, unchanged.
- `validate` 0 fatal 0 warning; `plan --check` current; `self-test` 393 green.

Every one of the seven faults above was a gap between what the plan said and what shipping the suite actually requires. None of them would have been caught by the validator, because all of them are absences rather than errors.
