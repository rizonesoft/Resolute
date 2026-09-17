# The Conformance Profile

**What a Resolute tool must be to be called finished.**

Owner: `D07 T01 §1`. Checked by `scripts/profile-check.py`. Evaluated against real tools by `D07 T01 §3`.

## Why this exists

The AutoIt suite had no written bar, and the result was not sloppiness. It was fourteen tools each solving the same problem privately and diverging: seven wrote their settings into a language-pack file, six wrote no log at all, four shipped no documentation, four shipped no language pack, and all fourteen disabled DPI awareness. None of it registered as a defect, because nothing said it should be otherwise.

A bar written after the work is a description of the work. This one is written first, so every section that follows is built against it and every intake is measured against it.

## How to read a clause

Every clause is one row, and every row is machine-checkable:

| Column | Meaning |
| --- | --- |
| **ID** | Stable address. Cite it when a tool fails. |
| **Kind** | `universal` applies to every tool. `repair` applies only to a tool that changes the user's system through the repair contract. |
| **Method** | How the clause is decided. One of `exists`, `absent`, `search`, `run`, `readback`, `capture`, `count`. A clause with no method is not a clause, it is an opinion. |
| **Clause** | What must be true. |
| **Evidence** | What is looked at to decide it. |
| **Owner** | The section that implements it, so a failure has an address rather than a complaint. |

**A clause is only in this document if a check could evaluate it.** That is the whole discipline: "the tool feels consistent" is not a clause, and "the tool contains no user-visible string literal, proven by search" is.

## Universal clauses

Every tool in the suite, ported or new.

| ID | Kind | Method | Clause | Evidence | Owner |
| --- | --- | --- | --- | --- | --- |
| C01 | universal | search | The tool contains no private implementation of a framework concern: startup, settings, logging, localization, update, preferences, About, DPI, or theme. | A search of the tool's own source finds no private definition of a concern the framework owns. | D01 T01 §1 |
| C02 | universal | absent | The tool defines no settings reader or writer of its own. | No settings read or write call exists outside the framework's settings source. | D01 T01 §2 |
| C03 | universal | readback | Settings are stored in an `.ini` written by the shared writer, and every value a surface shows is read back from what was written. | Write a value, restart the tool, read it back: it survives and matches. | D01 T01 §2 |
| C04 | universal | absent | The tool defines no log writer of its own. | No file-append or log-format call exists outside the framework's logging source. | D01 T01 §3 |
| C05 | universal | count | Every action the tool takes on the user's system produces exactly one log line. | Drive a known number of actions and count the lines: the counts reconcile. | D01 T01 §3 |
| C06 | universal | absent | The tool defines no localization loader of its own. | No pack parsing exists outside the framework's localization source. | D01 T01 §4 |
| C07 | universal | search | Every string that reaches a surface resolves through a language pack. | A search of the tool's own source finds no user-visible string literal. | D01 T01 §4 |
| C08 | universal | exists | The tool ships a language pack, and every pack file name follows the naming convention exactly, including the region casing. | The pack directory exists and is non-empty, and every file name matches the convention. | D08 T01 §3 |
| C09 | universal | exists | The tool ships its own documentation set. | The tool's documentation directory exists and is non-empty. | D08 T01 §1 |
| C10 | universal | exists | The tool declares an update short name, and the release produces the matching update file for it. | The short name is declared in the descriptor and the update file is produced by the release run. | D06 T01 §5 |
| C11 | universal | run | The tool shows an About page built from its descriptor rather than from its own copy of the same facts. | Drive About open: it renders and names this tool, and no tool-side About source exists. | D01 T01 §7 |
| C12 | universal | capture | Every surface renders correctly at 100, 125, 150, and 200 percent scaling. | A capture at each of the four scalings with nothing clipped, truncated, or misaligned. | D01 T01 §7 |
| C13 | universal | capture | Every surface renders correctly in both appearances. | A capture in each appearance. | D01 T01 §7 |
| C14 | universal | run | Placed alone in an empty directory with only its own files, the tool starts, localizes, shows About, and checks for updates. | A driven run in an empty directory on a machine with no suite install. | D01 T01 §9 |
| C15 | universal | run | The tool's **own persistence** stays in its own folder: settings, log, cache, language packs, and crash reports are written nowhere else. | A file-system trace of a session that performs no repair shows no write outside the tool's folder. | D01 T01 §9 |
| C16 | universal | run | The tool is one standalone executable and requires no other tool, and no suite-wide file, at runtime. | A driven run with every sibling tool absent. | D06 T01 §1 |
| C17 | universal | search | Every visual and interaction value comes from the design contract. The tool hardcodes none of them. | The token check finds no colour, size, or spacing literal in the tool's source. | D01 T02 §1 |
| C18 | universal | run | Every control reports its name, role, value, and state, and every surface is reachable without a mouse. | An automation tree walk naming each control, and a mouse-free drive of every surface. | D01 T02 §5 |
| C19 | universal | run | A crash is reported rather than silent, and a second launch does not produce a second instance. | A forced fault produces a report; a second launch raises the first window. | D01 T01 §10 |
| C20 | universal | run | The tool accepts the suite command-line grammar and returns the documented exit codes. | Each documented code is driven and observed. | D01 T01 §11 |
| C21 | universal | exists | The shipped executable and its installer are both signed through the documented procedure. | The signature verifies on both artifacts. | D06 T01 §3 |
| C22 | universal | absent | No source file carries a hardcoded copyright year or version. Both are generated at build time. | A search finds none, and every built artifact reports the same year. | D06 T01 §1 |
| C23 | universal | absent | The tool adds no file to a shared layer, and carries no file that belongs in one. | The source-layout check over the tool's directory and the shared layers. | D07 T01 §3 |
| C24 | universal | run | The tool builds clean at the project warning level, with static analysis at or below the recorded baseline. | A build with warnings as errors and a finding count compared against the baseline. | D00 T01 §3 |

## Repair-tool clauses

These apply **in addition** to every universal clause, and only to a tool that changes the user's system through the repair contract.

The distinction matters because a tool that reads and reports owes none of this, and holding it to a restore record it has no use for would make the profile something people argue with rather than meet.

| ID | Kind | Method | Clause | Evidence | Owner |
| --- | --- | --- | --- | --- | --- |
| C25 | repair | search | The tool consumes the repair contract and implements no run loop, result list, or progress surface of its own. | A search of the tool's source finds no private loop or result surface. | D02 T01 §1 |
| C26 | repair | run | Every repair diagnoses before it repairs, and reports what it found before changing anything. | A driven diagnose pass whose reported counts reconcile with the items offered. | D02 T01 §2 |
| C27 | repair | readback | Every repair records the prior state before it changes anything. | The restore record exists and names the prior value for each item acted on. | D02 T01 §4 |
| C28 | repair | readback | Every repair verifies its effect by reading the system back, never by trusting the call that made it. | The verify step reads the changed object and asserts the new value. | D02 T01 §2 |
| C29 | repair | run | Every repair has a reverse, or states that it has none and why. | The reverse is driven and restores the prior state, or the declaration exists and gives the reason. | D02 T01 §4 |
| C30 | repair | run | Every action and every refusal produces exactly one log line. | Both paths driven, both counted. | D02 T01 §6 |
| C31 | repair | run | Elevation is checked at the action, not only at startup, and the refusal is proven. | An unelevated run reaches the action and is refused by name, with the batch still reconciling. | D01 T01 §6 |
| C32 | repair | exists | The user can carry the result away as a transcript. | The transcript is exported and read back. | D02 T01 §5 |
| C33 | repair | run | Every write the tool makes outside its own folder is a declared repair target, and nothing else. | A file-system trace of a repair run: every path written appears in the tool's declared items, and no path outside them is touched. | D02 T01 §1 |

### Why C15 is about persistence and not about writes

**A repair tool's whole purpose is writing outside its own folder**, and an earlier draft of C15 read "the tool writes nothing outside its own folder", which would have made every repair tool non-conformant by construction.

`ComIntRep` restores the hosts file at `%WindowsDir%\System32\drivers\etc\hosts`, taking a `.bak` beside it first. That effect is **frozen**: `AGENTS.md` says what these six tools compute and write does not change, because the effect lands on somebody's machine. A clause forbidding it would have forced a choice between a tool that fails the bar and a tool that changed a frozen behaviour, and both are wrong.

So the confinement clause is about **persistence the framework owns**, which is what the AutoIt defects were actually about: a settings file in the wrong place, a log at a shared root, a language pack the tool cannot find alone. C15 is traced on a session that performs no repair, so it measures exactly that.

Repair writes are not exempt, they are **governed instead**, and more strictly: C33 requires every path written outside the folder to be a declared repair target, C27 requires the prior state recorded first, C28 requires the effect read back, C29 requires a reverse or a stated reason there is none, and C30 requires a log line. A repair tool therefore owes more about its outside writes than a read-only tool owes about having none.

## What each measured defect maps to

The profile is derived from what the AutoIt suite actually did, not from taste. Every figure was re-measured against `resolute_au3/` on 2026-09-17.

**A clause that closes none of these is a preference.** A defect that no clause closes is a hole, and `scripts/profile-check.py` fails on either.

| Defect | What was measured | Closed by |
| --- | --- | --- |
| D1 | 7 of 14 tools store settings in a `.lng` language-pack file: `ComIntRep`, `DVDRepair`, `Ownership`, `PixRepair`, `ReBar`, `USBRepair`, `Resolute`. | C02, C03 |
| D2 | 6 of 14 tools write no log at all: `BiosCodes`, `Chromin`, `Edgemin`, `Firemin`, `MemBoost`, `Watermin`. | C04, C05 |
| D3 | 4 of 14 tools ship no documentation set: `Distro`, `Edgemin`, `MemBoost`, `Watermin`. | C09 |
| D4 | 4 of 14 tools ship no language pack: `Chromin`, `Distro`, `Edgemin`, `Watermin`. | C07, C08 |
| D5 | Pack naming diverges: one `zh-tw` against three `zh-TW`, and one `sv.ini` among otherwise uniform `.lng` files. | C08 |
| D6 | 14 of 14 tools disable DPI awareness, so the whole suite renders bitmap-scaled on a high-resolution display. | C12 |
| D7 | Nothing ships signed: `Compress=0` and `Sign=0` in all 13 descriptors, `SignInstall=0` in all 12 that declare it. | C21 |
| D8 | Copyright years span four distinct values across 14 hand-typed scripts. | C22 |

### The defect that is not in the table

`resolute_au3/Resolute/Logging/` contains both `Ownership/` and `Ownerhip/`.

A misspelled runtime directory sits beside the correct one, because the logging path was typed by hand in fourteen places and one of them was typed wrong. It is not a defect class of its own. It is D1 and D2 with the mechanism made visible: **the cost of a copied path is not that it is inelegant, it is that one copy will differ and nothing will notice.** C02 and C04 exist to make that impossible rather than unlikely.

## What this profile does not specify

Two things are deliberately absent, and naming them here is what stops a later section adding a second, drifting copy.

**Design values.** Every colour, size, spacing, weight, and motion value lives in [`DESIGN.md`](../DESIGN.md), and C17 adopts that contract by reference. This document restates none of them, and `scripts/profile-check.py` fails if one appears here. A profile that copied the numbers would become a second source of truth, and the two would disagree the first time either moved.

**The standalone on-disk layout.** C14, C15, and C16 state standalone-ness as **behaviour**: alone in an empty directory, the tool works and writes nothing outside its folder. They name no paths.

That is deliberate and it has a cost. The shipped suite puts `Language/<Tool>/`, `Logging/`, and `Docs/<Tool>/` at a shared root, while the Complete Windows Repair intake keeps everything in one folder beside the executable. The two have not been reconciled, and `D01 T01 §9` owns choosing. Stating the clause as behaviour means it is true under either layout, so that decision cannot invalidate this document. What the profile therefore **cannot** check is whether a tool put its files in the agreed place, only that it needs nothing outside its own folder. `D01 T01 §9` closes that gap and `D07 T01 §3` turns the chosen layout into a check.

## Exceptions

A tool that cannot meet a clause does not quietly fail it. It carries a dated exception naming the clause, the reason, and the section that will close it.

An exception with no closing section is not an exception, it is a defect with better manners.
