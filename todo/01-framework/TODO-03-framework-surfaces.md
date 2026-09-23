---
schema_version: 1
id: framework-surfaces
domain: 01-framework
status: draft
title: "TODO-03 -- Framework Surface Specification"
depends_on: []
track: F1
---

# TODO-03 -- Framework Surface Specification

> **Goal:** Every framework surface is specified control by control before it is built: the standard window and its menus, the Preferences dialog page by page, the log surface, the update dialog, and every message the framework can show. `D01 T01` builds from this file; nothing it renders is invented at build time.

> [!IMPORTANT]
> **Current state:** Nothing exists in C++. The AutoIt framework is `resolute_au3/SDK/Concrete/ReBar/ReBar.au3` (1,556 lines) plus `resolute_au3/SDK/Includes/`: a standard window with itemless File/Help menu stubs, a heading block, a status list, a donate strip, and an update animation; a 450x500 3-tab Preferences dialog; an About dialog; a two-form Update dialog; a splash screen; a Donate dialog; and a `MsgBox` inventory across the [Messages], [Messages2], [Preferences], and [Donate] pack sections. Strings live in `resolute_au3/Resolute/Language/ReBar/en.lng` and per-tool packs (UTF-16). The About dialog itself is already specified in `D01 T01 §12`; this file specifies everything around it.

<!-- claim: exists resolute_au3/SDK/Concrete/ReBar/ReBar.au3 -->
<!-- claim: exists resolute_au3/SDK/Includes/Update.au3 -->
<!-- claim: exists resolute_au3/SDK/Includes/Donate.au3 -->
<!-- claim: exists resolute_au3/SDK/Includes/Splash.au3 -->

## Inputs

- [`resolute_au3/SDK/Concrete/ReBar/ReBar.au3`](../../resolute_au3/SDK/Concrete/ReBar/ReBar.au3) -- the framework window, menus, and Preferences dialog
- [`resolute_au3/SDK/Includes/`](../../resolute_au3/SDK/Includes) -- `Update.au3` (two-form dialog), `Donate.au3`, `Splash.au3`, `Logging.au3` (levels and the status list contract)
- [`DESIGN.md`](../../DESIGN.md) -- the contract every kept surface is rebuilt under; the AutoIt windows are behavior reference only
- -> XREF: [`01-framework/TODO-01 §7`](./TODO-01-framework-core.md) -- the build that consumes this specification

## Outcome

- Every AutoIt framework control and message is kept, cut with a dated reason, or remapped to a named new home, and the account is complete.
- Every C++ framework surface names its controls, its strings with their pack source, its states, and its empty and failure presentations.
- The string audit is recorded: every dead key, duplicate key, typo, and tone violation found in the framework pack sections carries a verdict.

**Adjacency:** list=applicable @ D01 T03 §4; document=not-applicable (framework surfaces produce no document a user carries); settings=applicable @ D01 T03 §2; reporting=applicable @ D01 T03 §4; notifications=applicable @ D01 T03 §5; permissions=applicable @ D01 T03 §6; audit=applicable @ D01 T03 §4; exchange=applicable @ D01 T03 §3; reverse=not-applicable (the framework changes nothing on a user's system; the repair contract owns undo)

**Adjacency rationale:** Settings anchors on §2 because the Preferences pages are the framework's own settings surface. List, reporting, and audit converge on §4 because the log surface is all three: the rows a user browses, the report of what happened, and the trail support reads back. Notifications anchors on §5 where the update announcement speaks to a user who asked for nothing, and permissions on §6 where refusal names what was needed. Exchange anchors on §3 because a language pack is a hand-edited file handed back, with an encoding and a missing-key story. Document and reverse stay not-applicable.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Standard window, menus, and message layer | -- |  [ ]   |
|   2   |   §2    | Preferences shell, General, and Performance | -- |  [ ]   |
|   3   |   §3    | Preferences Language page and tool-page contract | -- |  [ ]   |
|   4   |   §4    | Per-tool log surface | -- |  [ ]   |
|   5   |   §5    | Update dialog and announcement | -- |  [ ]   |
|   6   |   §6    | Refusal, crash, singleton, and shutdown notices | -- |  [ ]   |
|   7   |   §7    | Splash, Donate, and the string audit | -- |  [ ]   |

---

## 1. Standard Window, Menus, and Message Layer

The window every tool opens: the Direct2D caption and status bar per `D01 T02 §4`, the File and Help menus, the heading block, and the single message layer every notice in §§5-6 renders through. The AutoIt framework defines itemless File/Help menu stubs (`ReBar.au3:525-526`); the item contract below comes from the Resolute usage plus the `[Menus]` pack keys. Tools add no menu items and draw no dialog of their own: a second menu item or message box is a defect per `DESIGN.md` §1.

**Fidelity:** the standard window, against `DESIGN.md` sections 8 and 11.
**Job:** a user who learns one tool has learned all of them. Consumer: every tool window `D01 T01 §7` builds.
**Treatment:** the framework owns the bar, the menus, and the message layer whole; tools own their content region only. Cheaper substitute that fails the checkpoint: letting tools append menu items, which is how fourteen File menus drift apart.
**Chrome:** consume the shared window frame, popup menu, and status bar. No tool-drawn caption, menu, or dialog.

- [ ] Specify the window regions: caption with title and window controls, menu bar, heading block (tool icon, name plus version, subheading), content region owned by the tool, and status bar. Done when: every region names its contents and its resize behavior, and the heading strings name their descriptor source (`D01 T01 §1`).
- [ ] Specify the File menu whole: Preferences, the Logging submenu (open log file, open log directory), Minimize, and Close with Alt+F4, each with its pack key, enabled states, and accelerator. Done when: no tool can add, remove, or reorder an item, because the framework exposes no way to.
- [ ] Specify the Help menu whole: update check, publisher home, downloads, support, issue creation, and About (`D06 T01 §17`, moved from `D01 T01 §12` on 2026-09-23), each with its pack key and target; the Donate item carries the §7 verdict. Done when: every item names its target and the About entry opens the §12 dialog for the running tool's descriptor. Cheaper substitute that fails the checkpoint: a Help menu whose URLs live in each tool, which is how fourteen support links rot separately.
- [ ] Specify the message layer: severity titles (`Info_Title`, `Warning_Title`, `Error_Title`), button sets, default buttons, modality and topmost rules, and the selectable-copyable message body per `DESIGN.md` §4. Done when: every notice in §§5-6 renders through it with no other path, and the dead `MsgBox(0, "")` calls are cut as debug residue.
- [ ] Specify the status bar: regions (state text, elevation indicator per `D03 T02 §7`, background-task slot), truncation with tooltip, and what never appears there. Done when: every region is named and the elevation states are specified.
- [ ] Commit: `"framework-spec: standard window, menus, and message layer"`

**Test checkpoint:** Every window region names contents and resize behavior; both menus name every item with key, states, and target; the message layer names titles, buttons, and modality with the dead calls cut; the status bar names every region. The `D01 T01 §7` checklist can be built from this section with no invented control. Cheaper substitute that fails the checkpoint: menus without the no-tool-items rule, which specifies today and drifts tomorrow.

-> XREF: D01 T01 §7 -- the build that consumes this window spec

## 2. Preferences Shell, General, and Performance

The 450x500 Preferences dialog (`ReBar.au3:1005-`, dialog title from `[Preferences] Window_Title`), owned by the framework and hosting one page per tool. This section specifies the shell (tabs, Save/Cancel, notices) plus the General page (logging group) and the Performance page (priority group, memory group). The Language page is §3.

**Fidelity:** the Preferences dialog, against `DESIGN.md`; rebuilt, not reproduced: the AutoIt dialog is not DPI-aware.
**Job:** a user changes a setting once and trusts it persisted. Consumer: the dialog `D01 T01 §7` builds and the settings writer it drives.
**Treatment:** one dialog, framework pages plus tool pages through a contract, every control bound to a setting key. Cheaper substitute that fails the checkpoint: pages that write their own keys, which recreates the fourteen-writers failure inside one dialog.
**Chrome:** consume the framework dialog, tab, input, combo, checkbox, and button controls. No page draws its own Save.

- [ ] Specify the shell: tab strip with General, Performance, Language, and tool pages; Save and Cancel with their pack keys; the updated notice (`Label_Updated`) and its presentation; and dirty-state behavior (what prompts, what applies silently). Done when: every element is named and the dirty rule is exact.
- [ ] Specify the General page logging group: the enable checkbox, the size input with its unit and range, the current-size label, and the Clear button with its cleared notice (`Label_Logging_Cleared`). Done when: every control names its setting key, and clearing asks nothing (logs are expendable) while reporting what it did.
- [ ] Specify the Performance page priority group: the priority combo with its six values (Low, Below Normal, Normal, Above Normal, High, Realtime) and default Normal, and the save-above-high checkbox with its not-recommended warning intact. Done when: every value names its Win32 priority class and the warning text names its pack key.
- [ ] Specify the Performance page memory group: the reduce-memory checkbox with its low-memory-systems scope. Done when: the control names its key and the behavior it toggles is stated exactly.
- [ ] Record the dead `Tab_Cache` key: the pack carries it and no dialog builds it. Done when: it is cut with the reason (dead key, no surface ever read it) rather than resurrected. Cheaper substitute that fails the checkpoint: building a Cache page to use the key, which invents a feature to fill a hole.
- [ ] Commit: `"framework-spec: preferences shell, general, and performance"`

**Test checkpoint:** The shell names tabs, buttons, notices, and the dirty rule; all three groups name every control with key and behavior; the priority values map to Win32 classes; the dead Cache key is cut with reason. The `D01 T01 §7` checklist can be built from this section with no invented control. Cheaper substitute that fails the checkpoint: groups without setting keys, which ships a dialog that displays settings it cannot store.

-> XREF: D01 T01 §7 -- the build that consumes this preferences spec

## 3. Preferences Language Page and Tool-Page Contract

The Language page (flag icon, selected-language label, language list, restart note: `ReBar.au3:1072-1127`) plus the contract every tool page follows to appear in the framework dialog. Packs are untrusted hand-edited input per the `D01 T01 §4` exchange rationale; this section specifies what the page does with malformed ones.

**Fidelity:** the Language page and tool pages, against `DESIGN.md`; rebuilt, not reproduced.
**Job:** a user runs the suite in their language, and a tool adds its settings without touching the dialog. Consumer: the page `D01 T01 §7` builds and the pack loader it drives.
**Treatment:** selection applies to the dialog at once and to the tool after restart, stated on the surface. Cheaper substitute that fails the checkpoint: applying some strings at once and others at restart without saying which, which reads as a bug in every language.
**Chrome:** consume the framework dialog, list, and label controls. Tool pages render through the contract, never as custom drawing.

- [ ] Specify the Language page: the list with flag, name, and completeness; the current-selection header; the restart note with its pack key; and the apply rule (dialog now, tool at restart). Done when: every element is named and the apply rule is stated on the surface text, not just here.
- [ ] Specify the language-changed notice (`MsgBox_Language_Title`, `MsgBox_Language_Message`) through the §1 message layer: title, body, buttons, and when it shows versus silently applying. Done when: the trigger rule is exact.
- [ ] Specify the malformed-pack presentations: a pack that fails to parse, a pack missing keys, and an empty language directory each render a stated result naming the pack, and the page always offers a working language. Done when: all three name their text with pack sources (from the fallback language, never the broken pack). Cheaper substitute that fails the checkpoint: falling back silently, which leaves a translator staring at English with no error.
- [ ] Specify the tool-page contract: how a tool declares its page (title, controls, keys), control shapes allowed, validation and error presentation, and the page's position after the framework pages. Done when: the contract is exact enough that two tools' pages cannot diverge in shape.
- [ ] Commit: `"framework-spec: language page and tool-page contract"`

**Test checkpoint:** The page names list, header, note, and the apply rule; the changed notice names title, body, buttons, and trigger; all three malformed presentations name text from the fallback language; the tool-page contract fixes shape, validation, and position. The `D01 T01 §7` checklist can be built from this section with no invented control. Cheaper substitute that fails the checkpoint: a tool-page contract without validation, which ships fourteen error presentations.

-> XREF: D01 T01 §7 -- the build that consumes this language-page spec

## 4. Per-Tool Log Surface

The status list every tool window carries (`ReBar.au3:563-`, single column, state icons): the live view of what the tool is doing. Levels come from `_Logging_SetLevel` (plain, ERROR, WARNING, SUCCESS, FINISHED with `[Logging]` prefixes 32-35) plus `_DetermineLogImage` sniffing and custom image indices. This section maps all of it to named statuses with icons, and specifies selection, copy, clearing, and the empty state.

**Fidelity:** the log surface, against `DESIGN.md` §4 (monospace, selectable, copyable).
**Job:** a user watches what the tool does and copies what they need to search for. Consumer: the surface `D01 T01 §3` builds.
**Treatment:** one line per action with a level, rendered with icon plus text, never color alone. Cheaper substitute that fails the checkpoint: color-only levels, which fail `DESIGN.md` §3 for a meaningful share of users.
**Chrome:** consume the framework list surface. No tool implements its own log view.

- [ ] Map the levels: plain, ERROR, WARNING, SUCCESS, and FINISHED each become a named status with icon, text treatment, and prefix source; the `_DetermineLogImage` sniffing rule is either specified exactly or cut with reason (recorded direction: cut, because content sniffing mislabels lines containing the words "error" or "success" in prose). Done when: every level names its status and the sniffing verdict is recorded.
- [ ] Specify the custom-image rule: which calls may pass an explicit index, what each used index means, and the fallback for an unknown index. Done when: the rule is exact and an unknown index renders the plain status, never a blank.
- [ ] Specify the reading behaviors: selection and copy of one or many lines, follow-tail with its toggle and pause rule, clearing with its notice, and the empty state naming its pack key. Done when: every behavior is named and copy preserves the line text exactly.
- [ ] Specify the failure presentations: the log file missing, unreadable, or malformed each render a stated result in the surface, never a dialog. Done when: all three name their text with pack sources. Cheaper substitute that fails the checkpoint: a dialog per failure, which interrupts the user to report that a log is missing.
- [ ] Commit: `"framework-spec: per-tool log surface"`

**Test checkpoint:** All five levels map to named statuses with the sniffing verdict recorded; the custom-image rule names fallback; selection, copy, follow, clearing, and empty are all specified; all three failure presentations name their text. The `D01 T01 §3` checklist can be built from this section with no invented control. Cheaper substitute that fails the checkpoint: levels without the sniffing verdict, which ports a mislabeling bug by silence.

-> XREF: D01 T01 §3 -- the build that consumes this log spec

## 5. Update Dialog and Announcement

The two-form Update dialog (`Update.au3:118` update-available form, `:173` generic message form) plus the consolidation announcement `D01 T01 §5` sends to users of retiring products. Builds become tag-derived versions per `D06 T01 §11`; the dialog compares versions, not build numbers.

**Fidelity:** the update dialog and announcement, against `DESIGN.md` §11; rebuilt, not reproduced.
**Job:** a user learns an update exists and reaches it; a user of a retiring product learns its successor. Consumer: the dialog `D01 T01 §5` builds and the opened release page.
**Treatment:** the dialog reports and links; it never downloads or installs silently. Cheaper substitute that fails the checkpoint: a dialog that downloads on Open, which turns a notice into an action the user did not take.
**Chrome:** consume the framework dialog and message layer. No second update surface per tool.

- [ ] Specify the update-available form: icon, message (`Label_Message_Update`), current and update version rows (`Label_Build_Current`, `Label_Build_Update`, relabeled from Build), the no-show checkbox (`CheckBox_NoUpdate`), and the action button opening the release page in the browser. Done when: every control is named, the button label decision is recorded (relabel from "Read more" to "Open download page", because the label must name the action per `DESIGN.md` §11), and versions compare per the `D06 T01 §11` scheme.
- [ ] Specify the generic message form: icon, title variants (congratulations, error), message body, second body line, no-show checkbox, and Close. Done when: every control is named and each title variant names the condition that shows it.
- [ ] Specify the three check outcomes as surfaces: update found (form one), already latest (`Label_Message_Latest`), and check failed (`Label_Message_Error` plus `Label_Message_Internet`), each with its trigger, presentation, and log line. Done when: all three are named and a failed check never renders as latest. Cheaper substitute that fails the checkpoint: latest and failed sharing a presentation, which tells an offline user they are current.
- [ ] Specify the consolidation announcement: which users see it, its title and body naming the successor with pack sources, its action opening the successor page, and its show-once rule. Done when: the audience rule, the content, and the dismissal rule are all exact.
- [ ] Commit: `"framework-spec: update dialog and announcement"`

**Test checkpoint:** Both forms name every control with the button relabel recorded; all three check outcomes name trigger, presentation, and log line; the announcement names audience, content, and dismissal. The `D01 T01 §5` checklist can be built from this section with no invented control or string. Cheaper substitute that fails the checkpoint: outcomes without log lines, which announce to the user and hide from support.

-> XREF: D01 T01 §5 -- the build that consumes this update spec

## 6. Refusal, Crash, Singleton, and Shutdown Notices

Every framework notice that is not the update dialog: elevation refusal (`D01 T01 §6`), crash report and single-instance (`D01 T01 §10`), incompatibility, launch-tool failures from `[Messages2]`, registry errors, and the shutdown persist. All render through the §1 message layer. Tone follows `DESIGN.md` §11: plain words for someone whose machine is broken.

**Fidelity:** the framework notices, against `DESIGN.md` §11; message layer, no new dialog.
**Job:** a user who cannot do something learns what was needed; a user whose tool died learns what survived. Consumer: the notices `D01 T01 §6` and `§10` show.
**Treatment:** every refusal names the action and what it needed; every crash names what was preserved. Cheaper substitute that fails the checkpoint: "Access denied" and "Something went wrong", which name neither the need nor the salvage.
**Chrome:** consume the §1 message layer only. No notice draws its own window.

- [ ] Specify the elevation refusal: action name, needed privilege, and next step, with pack keys; the declined-elevation outcome returning to the window with one log line. Done when: the text rule is exact (never a bare "Access denied") and the outcome is specified as non-error.
- [ ] Specify the crash report: what it says, the report contents and location, the restore-record pointer for repair tools, and the restart offer with its buttons. Done when: every element is named and the report path rule is stated.
- [ ] Specify the singleton notice (`Singleton`) and the incompatibility notice (`Compatible`): exact texts, when each shows, and the support-link target of the latter. Done when: both name their keys, and `Compatible_Bit` is cut with reason (x86-64 is the only architecture per `D00 T01 §1`, so a 32-bit notice can never show; its "Unfortuantely" typo dies with it).
- [ ] Specify the launch-tool failure texts from `[Messages2]`: success with process id, ShellExecute failure with code, and the missing executable. Done when: the AWOL wording (`ExecuteTool_08`) is replaced with "Error: the executable is missing from its expected location (%s)." and the alarms line (`ExecuteTool_09`) is cut, both per `DESIGN.md` §11 with the reason recorded (a user whose tool vanished needs a path, not a joke).
- [ ] Specify the registry error texts (`Registry_Write_Error`, `Registry_Error_01` through `_06`) and the shutdown-persist failure: each names action, target, and need. Done when: every text names its key and no two share one message. Cheaper substitute that fails the checkpoint: one "registry error" string with the code interpolated, which localizes once and explains never.
- [ ] Commit: `"framework-spec: refusal, crash, singleton, shutdown"`

**Test checkpoint:** Refusal, crash, singleton, incompatibility, all three launch outcomes, all seven registry texts, and shutdown each name exact text with keys; the Bit notice, the AWOL wording, and the alarms line carry recorded verdicts. The `D01 T01 §6` and `§10` checklists can be built from this section with no invented string. Cheaper substitute that fails the checkpoint: texts without the tone verdicts, which ports jokes and typos into the new suite.

-> XREF: D01 T01 §6 -- the build that consumes this notice spec

## 7. Splash, Donate, and the String Audit

Two verdicts and an audit. The splash screen (`Splash.au3`: message label plus progress bar, driven by the `Loading_*` keys) and the Donate dialog (`Donate.au3`: heading, PayPal message, banner) plus the main-window donate strip (`ReBar.au3:581-`) each get keep or cut with reason. Then the framework pack sections are audited key by key for dead keys, duplicates, typos, and tone, and every finding carries a verdict.

**Fidelity:** no surface of its own; this section removes surfaces and cleans strings.
**Job:** the suite ships no nag, no pointless splash, and no string that embarrasses it in 35 languages. Consumer: the startup path `D01 T01 §1` builds and the packs `D08 T01 §2` composes.
**Treatment:** cut with a recorded reason and reversal cost; a cut without either is a grudge, not a decision. Cheaper substitute that fails the checkpoint: cutting Donate in prose here while its keys ship in every pack.
**Chrome:** none; this section deletes chrome.

- [ ] Verdict the splash screen and its `Loading_*` keys. Done when: the recorded direction cuts both with reason (a tool that starts instantly per `DESIGN.md` §10 has nothing to splash over; the keys describe a startup sequence the user should never perceive) and the reversal cost is stated (one dialog, one key block).
- [ ] Verdict the Donate dialog, the main-window donate strip, and the About donate tips. Done when: the recorded direction cuts all three with reason (a donation nag is not distribution-ready behavior for system utilities; support links live in About per `D01 T01 §12`) and the reversal cost is stated; the `[Donate]` keys are cut from the packs in the same verdict, not left orphaned. Cheaper substitute that fails the checkpoint: cutting the dialog while its strip stays in the window, which is how a decision becomes half-true.
- [ ] Audit the framework pack sections key by key (`[About]`, `[Donate]`, `[Menus]`, `[Messages]`, `[Messages2]`, `[Preferences]`, `[Update]`): dead keys, the duplicate `Tip_Twitter`, typos, and tone violations each carry keep, fix, or cut. Done when: the audit names every finding with its verdict, and the fixed strings are quoted (the About dialog rows defer to `D01 T01 §12` for their final text).
- [ ] Commit: `"framework-spec: splash, donate, and the string audit"`

**Test checkpoint:** Splash, Donate dialog, donate strip, and donate tips each carry a recorded verdict with reason and reversal cost; the key audit names every finding with keep, fix (quoted), or cut; no cut key ships in a pack. The `D01 T01 §1` startup path and the `D08 T01 §2` pack composition can be built from this section with no undecided string. Cheaper substitute that fails the checkpoint: an audit that lists findings without verdicts, which is a second backlog rather than a decision.

-> XREF: D01 T01 §1 -- the startup path this verdict constrains

## Verification

- [ ] Every AutoIt framework control and message carries keep, cut with reason, or remapped to a named home
- [ ] Every specified surface names its controls, strings with pack sources, states, and empty and failure presentations
- [ ] The string audit names every finding with keep, fix quoted, or cut, and no cut key ships
- [ ] Every `D01 T01` build section can be built from its spec section with no invented control or string
- [ ] `python scripts/todo-graph.py validate` clean
