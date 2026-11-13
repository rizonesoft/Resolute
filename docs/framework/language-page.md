# The Language page

Every Resolute tool's Preferences dialog has a Language page, owned by the framework. This page specifies it control by control, so that `D01 T01 §7` can build it without inventing a control. It is half of `D01 T03 §3` (`todo/01-framework/TODO-03-framework-surfaces.md`); the other half, the contract for a tool's own pages, is [`tool-pages.md`](tool-pages.md).

A user runs the tool in their own language without hunting for a setting, and a translator who breaks a pack is told which file and why. So the tool starts in the Windows language when a pack for it exists, the list names every pack it found with its state, and a pack is treated as hand-edited input that may be wrong (`D01 T01 §4`).

The page sits in the shell [`preferences.md`](preferences.md) specifies and takes part in its Save, its dirty rule and its way out unchanged. Its messages go through the message layer in [`standard-window.md`](standard-window.md). Sizes are base values at 96 DPI. A specification cannot prove behaviour, so the page ends in a matrix ([below](#what-must-the-build-prove-row-by-row)) whose every row is a check `D01 T01 §7` runs.

## What does the AutoIt page have, and where does each part go?

Read from `resolute_au3/SDK/Concrete/ReBar/ReBar.au3`, every line printed from the file.

| AutoIt part | Source | Verdict |
| --- | --- | --- |
| Language tab and group | `ReBar.au3:1071-1072` | Kept as the Language page, under `Tab_Language`. |
| Flag icon and language name above the list | `ReBar.au3:1075-1077` | Changed. The flag is cut and the name stays, as the line saying which language the tool is showing. The name came from a table in the code (`:1389`), not from the pack, so a pack outside the table had none. |
| List with Language and Code columns, a flag per row | `ReBar.au3:1080-1092` | Changed. The list and both columns stay, a Translated column is added, and the flags are cut. The column titles "Language" and "Code" were typed into the code (`:1091-1092`), so they were English in every language; they get keys. |
| The flags, 35 icons compiled into each tool | `ReBar.au3:271`, `:1085-1089`, `:1389` | Cut. A language is not a country: the 35 packs hold `pt` and `pt-BR`, `zh-CN` and `zh-TW`, Arabic, Persian and Hindi. A pack a translator adds would have no flag beside neighbours that do, and 35 icons would ride in every standalone executable. Reversing costs one icon column. |
| English as a first row typed into the code | `ReBar.au3:1094-1096`, `:1103` | Changed. English is always offered, from the built-in text, but its row is built like every other. |
| The pack scan: every `.lng` file, its `Name` and `Code` read from `[Language]` | `ReBar.au3:1098-1119` | Kept, with a state per pack. The scan trusted every file: a pack that could not be read became a row with no name. `Encoding` was read and never used (`:1110`), and a debug `ConsoleWrite` ran per pack (`:1106`); both are cut. |
| The row selected at opening | `ReBar.au3:1121-1122` | A defect, fixed. The row was looked up by the flag's index (`:1121`) while rows were numbered by their position in the scan (`:1116`), so the two agreed only when all 35 packs were present in the table's order. The stored language's row is found by its code. |
| The note under the list | `ReBar.au3:1124`; `en.lng:177` | Reworded as `Label_Language_Message`, which now states the apply rule. |
| Choosing a language: mouse click only | `ReBar.au3:1520-1532` | A defect, fixed. Only `NM_CLICK` was handled, so a row reached with the arrow keys was highlighted but not chosen, and Save stayed disabled. Every way of moving the selection chooses. |
| Stored as `Language`, default `en` | `ReBar.au3:328`, `:1303` | Kept as the key. The default changes: with no stored value the tool uses the Windows language. |
| "Language Changed" prompt, OK or Cancel, before the value is written | `ReBar.au3:1299-1310`; `en.lng:182-183` | Cut. Save is already the user's decision; a second question about it is a step with no answer but OK. Its built-in text named another tool: "Complete Internet Repair should be restarted" (`resolute_au3/SDK/Concrete/ReBar/Includes/Localization.au3:118`). |
| "Closing" prompt, which closed the tool and did not start it again | `ReBar.au3:1344-1351`; `en.lng:184-185` | Changed into the restart note and its "Restart now" button ([below](#what-happens-after-a-language-is-saved)). |
| `MsgBox_Closing_Messag`, misspelled in the pack against the loader's `MsgBox_Closing_Message` | `en.lng:185`; `Localization.au3:120` | A defect: the pack's text never loaded. Cut with its prompt, under both spellings, so that neither ships in a pack ([strings](#which-strings-does-the-page-use)). |

## What is on the page?

One group, `Group_Language` ("Language"), holding four things from top to bottom.

| Element | What it is | Rule |
| --- | --- | --- |
| Showing-now line | `Label_Language_Showing` ("%{Program.Name} is showing %1."), where %1 is the name of the language the tool started with | Always present. It names the running tool's language, which is not always the chosen row. |
| Notes | The restart note, a stored-language note or a folder note, when one applies | Beneath the showing-now line, each specified below. At most one of each. |
| Language list | A list with three columns, described below | Fills the page's remaining height; scrolls when the rows do not fit. Its accessible name is `Group_Language`. |
| Detail line | One line under the list about the focused row: a part-translated pack's count, a disagreeing code, or why a pack cannot be used | Empty for a complete pack. Selectable and copyable, as [`preferences.md`](preferences.md#can-a-note-be-copied) rules. |
| Apply rule | `Label_Language_Message` ("Choose a language. This dialog changes at once. The rest of %{Program.Name} changes after it restarts.") | Always present, under the detail line, so the rule is on the surface. |

### What does the list hold?

| Column | Key | Holds |
| --- | --- | --- |
| Language | `Column_Language` ("Language") | The pack's own `Name` from its `[Language]` section, as written. The 35 Firemin packs write it as the language's own name, then its English name ("Deutsch - German"), so a user can find theirs whatever the dialog is showing. |
| Code | `Column_Code` ("Code") | The pack's file name without `.lng`, in monospace (`DESIGN.md` §4). The file name is the pack's identity: it is what `Language` stores. |
| Translated | `Column_Translated` ("Translated") | A percentage in digits ("100%", "82%"), or `Pack_Unusable` ("Cannot be used"). Never a bar or a colour alone. |

The rows, in this order:

1. **Use the Windows language.** `Row_Windows` ("Use the Windows language (%1)"), where %1 is the name of the language it resolves to now. When no pack matches any Windows display language it reads `Row_Windows_Fallback` ("Use the Windows language (English: there is no pack for %1)"), naming the first Windows display language. Its Code cell is empty and its Translated cell is that of the language it resolves to. This is the default.
2. **One row per language**, sorted by code, compared character by character without regard to case, so the order is the same in every language. English is always among them and can always be chosen: from `en.lng` when the tool has one that can be used, and from the built-in text when that file is missing or cannot be used. There is never a second English row. A damaged `en.lng` is still reported: the English row's detail line reads `Pack_English_Builtin` ("%1 cannot be used: %2. English is shown from the built-in text."), %1 the file name and %2 its reason, so the way back to English never depends on a file a translator can break.

A pack is found when its file is in the tool's language folder (`D01 T01 §4`) and ends in `.lng`. The folder is scanned each time the dialog opens, never while it is open: a translator who edits a pack closes and reopens Preferences to see it.

**Completeness** is the share of the strings this tool can show (the framework's keys and the tool's own, the built-in English set) that the language supplies, from the tool's pack or the language's common pack (`D01 T01 §4`). It is rounded down, so 100% means every string. English is 100%.

### How is a language chosen?

The list always has exactly one chosen row, except in the one case [below](#what-if-the-stored-language-cannot-be-used). Moving the selection chooses: a click, Up, Down, Home, End, Page Up, Page Down, and type-ahead, which matches the start of the Language cell or of the Code cell. There is no separate "select" step and no double-click.

A row whose pack cannot be used takes focus, so its reason can be read in the detail line, but cannot be chosen: the chosen row stays where it was, and the row is announced as unavailable.

## What does choosing do, and when?

The setting is `Language`, in the tool's settings section, written only by the framework's settings writer (`D01 T01 §2`).

| Value | Meaning |
| --- | --- |
| Empty, or the key absent | The Windows language. The default. |
| A code (`de`, `pt-BR`) | That pack, by file name. |

The page follows the three values [`preferences.md`](preferences.md) defines, with one difference, which is the reason this page exists:

| Value | For the language |
| --- | --- |
| Persisted | What `Language` holds in the settings file. |
| Effective | The language the tool loaded when it started. It does not change while the tool runs. |
| Edited | The chosen row. |

- **The dialog previews at once.** Choosing a row loads that language and redraws the Preferences dialog in it: the page list, every page, the buttons, the notes, and any message the dialog raises. It is announced as `Label_Preview` ("Previewing %1. Save to keep it."), the shell's own key. The tool's main window does not change. A pack is read whole before anything is redrawn, so the dialog is never half in one language.
- **Save stores it.** `Language` is written when the row was changed and differs from the file, by the shell's Save and its read-back, like every other key. Nothing on this page can fail validation: a pack that cannot be used cannot be chosen.
- **A restart applies it.** The language is the one setting the running tool cannot take on: after a confirmed save, where the stored language differs from the one the tool is showing and its pack can be used, the reconcile rule's action is the restart note, not a change. [`preferences.md`](preferences.md) says so in its reconcile rule, and names the preview as an action that is not a save.
- **Cancel and Discard undo the preview.** The dialog returns to the language it had at the baseline, as the shell rules for every preview.
- **The dialog opens in the stored language.** After a save, and at every later opening before the restart, the dialog shows the stored language while the main window shows the one it started with. The showing-now line and the restart note say which is which.
- **The dirty rule is the shell's.** The page is dirty when the chosen row's value differs from the persisted one. Choosing the German row while "Use the Windows language" is stored and resolves to German is a change (it pins the language), although nothing on screen moves.

A file the AutoIt tool wrote reads back the same: it holds `Language` only when the user chose one there (`ReBar.au3:1303`), and that choice is kept. With no stored value the AutoIt tool showed English (`ReBar.au3:328`) and this one shows the Windows language, when a pack for it exists. That change is deliberate: a tool that already speaks the user's language should not make them find a setting first.

## What happens after a language is saved?

When the stored language resolves to another language than the one the tool is showing, and that language's pack can be used, the page carries the restart note. It appears after the confirmed save that caused it, and at every later opening of the dialog until the tool restarts or the stored language is changed back.

| Part | Rule |
| --- | --- |
| Text | `Label_Language_Restart` ("%{Program.Name} is still showing %1. It will show %2 after it restarts."), %1 the effective language's name and %2 the stored one's. Selectable and copyable. |
| Button | `Button_Restart_Now` (`&Restart now`), beside the note. |
| While a task runs | The button is disabled while the tool's own action is running (the task the status bar shows; an update check alone does not count), with `Label_Restart_Busy` ("Available when the current task has finished.") beneath it. A restart in the middle of a repair could leave a system half changed. It is enabled again, announced, when the task ends. |
| An unrelated save | Changes nothing here: the main window keeps its language and the note stays. |
| Changing back | Saving the language the tool is showing removes the note: there is nothing to restart for. |

**Restart now with unsaved edits** goes through the shell's way out first, with its prompt and its three answers:

- **Save** saves. When the save succeeds the restart goes on. When it fails, or cannot be confirmed, the failure shows as the shell rules and nothing restarts.
- **Discard** drops the edits and undoes the previews. The restart goes on, into what the settings file holds.
- **Cancel** returns to the dialog. Nothing restarts.

If, after that, the stored language is the one the tool is showing (the user had chosen it back and saved), there is nothing to restart for: the note goes and the tool stays open.

**The restart itself** is the framework's (`D01 T01 §10`), and it never closes a tool it cannot reopen:

1. The running tool starts a second instance of its own executable, with the same working directory and the same command line, less any argument that asks for a one-time action (`D01 T01 §11`'s grammar says which), at the level the first is running at: an elevated tool restarts elevated, with no new consent prompt.
2. The second instance answers that it has started. It is not refused by the single-instance guard, and it waits for the first to exit before it reads the settings.
3. Only on that answer does the first run the framework's shutdown, which persists the settings, and exit. The Preferences dialog closes with it.

When Windows cannot start the second instance, or it has not answered within 10 seconds, the first stays open exactly as it was, any half-started second instance is ended, and a message says so through the message layer:

| Part | Value |
| --- | --- |
| Severity | Error |
| Summary | `Restart_Failed_Title` ("%{Program.Name} could not restart") |
| Body | `Restart_Failed_Body` ("Windows could not start %1: %2. Your language is saved and will show the next time you start %{Program.Name}."), %1 the executable's path in monospace and %2 the Windows reason, or `Restart_Failed_Timeout` ("it did not answer within 10 seconds") |
| Buttons | Close, the default |
| After | Focus returns to "Restart now". The note stays. The failure is logged. |

A shutdown that cannot write the settings is shutdown's own message (`D01 T03 §6`), as for File, Close.

## What if a pack is wrong?

Every text below is resolved in the language the dialog is showing, through the normal order (`D01 T01 §4`), and never read from the pack at fault: a pack that cannot be trusted to hold a name is not asked for its error message. The detail line and the notes are selectable and copyable.

| Case | In the list | Text |
| --- | --- | --- |
| A pack that cannot be read | Listed by its file name in the Language cell, with its code; Translated reads `Pack_Unusable`; the row cannot be chosen | Detail line: `Pack_Unusable_Detail` ("%1 cannot be used: %2."), %1 the file name in monospace, %2 one of the reasons below |
| An `en.lng` that cannot be read | The English row stays, at 100%, and can be chosen: it shows the built-in text | Detail line: `Pack_English_Builtin` ("%1 cannot be used: %2. English is shown from the built-in text.") |
| A pack missing strings | Listed normally with its percentage; can be chosen | Detail line: `Pack_Partial_Detail` ("%1 of %2 strings are translated. The rest show in English."). A missing string resolves through the language's common pack, then the built-in English (`D01 T01 §4`), so "the rest" are those neither pack holds |
| A pack whose `Code` disagrees with its file name | Listed under its file name; can be chosen; stored and loaded by its file name | Detail line: `Pack_Code_Mismatch` ("This pack calls itself %1, but its file is %2. It is used as %2.") |
| A stored language whose pack is gone or cannot be read | No row is chosen; focus starts on English. An unreadable pack is listed as in the first row of this table; a missing one is not listed. The dialog opens in the language the tool is showing | Note under the showing-now line: `Label_Language_Missing` ("%{Program.Name} is set to %1, but %2 cannot be used: %3."), %1 the stored code, %2 the file name, %3 a reason below or `Pack_Reason_Missing`. The note says nothing about which language is showing: the showing-now line above it does, and it is right in both cases below |
| A language folder that is empty, missing or unreadable | The list holds "Use the Windows language" and English | Note: `Label_Language_No_Packs` ("No language packs were found in %1."), or `Label_Language_Folder_Unreadable` ("The language folder %1 could not be read: %2."), %1 the folder's path in monospace, %2 the Windows reason |

The reasons a pack cannot be used, each named by the loader (`D01 T01 §4`):

| Reason | Key and text |
| --- | --- |
| An encoding the loader does not read | `Pack_Reason_Encoding` ("it is not saved in an encoding this tool reads") |
| The file ends part way through | `Pack_Reason_Truncated` ("the file is cut short") |
| No `[Language]` section, or no `Name` in it | `Pack_Reason_No_Language` ("it has no [Language] section with a Name") |
| A key written twice in one section | `Pack_Reason_Duplicate` ("the key %1 appears twice, on lines %2 and %3") |
| Windows refusing the read | `Pack_Reason_Unreadable` ("Windows could not read it: %1") |
| The file is not there | `Pack_Reason_Missing` ("the file is missing") |

### What if the stored language cannot be used?

There are two ways to get here, and they differ in what the tool is showing:

- **The pack was unusable when the tool started.** The tool started in English (`D01 T01 §4`), and the showing-now line says English.
- **The pack was lost while the tool was running** (its file deleted, its folder disconnected). The tool keeps the language it loaded at the start, because the effective language never changes while it runs, and the showing-now line names that language. It will start in English next time unless the pack is back.

In both, the dialog cannot open in the stored language, so it opens in the one the tool is showing, and no restart note appears: there is nothing a restart could load.

The stored value is left exactly as it is: an unedited control never rewrites its key (`preferences.md`), so a pack that comes back (a network folder reconnected, a file restored) works again at the next start with nothing lost. The page is not dirty. Choosing any row is an edit, and Save then stores that row's value.

A pack that turns bad between the scan and the click (a translator saving it half written) is caught when it is chosen: the row becomes "Cannot be used" with its reason, the chosen row stays where it was, and the dialog stays in the language it had.

## Which keys does the page answer?

The shell's keys ([`preferences.md`](preferences.md#which-keys-does-the-dialog-answer)) apply unchanged. The page adds:

| Key | Where | Does |
| --- | --- | --- |
| Tab, Shift+Tab | Page | A note with its button (the note, then "Restart now"), the list, the detail line when it holds text, then the shell's Save and Cancel. |
| Up, Down, Home, End, Page Up, Page Down | List | Move the selection, which chooses the row. |
| A letter or digit | List | Type-ahead: the next row whose Language or Code cell starts with what was typed, wrapping; typing stops matching after one second without a key. |
| Alt+R | Dialog, while the note shows | Restart now. |
| Ctrl+C | A note or the detail line | Copies it whole. |

Focus starts on the list, on the chosen row, when the page is shown.

## What is announced?

Through UI Automation (`DESIGN.md` §9), in the language the dialog is showing:

| Event | Announcement |
| --- | --- |
| A row takes focus | Its Language cell, its code, and its Translated cell in words: `Announce_Translated` ("%1 percent translated") or `Pack_Unusable`. A row that cannot be chosen adds its reason. |
| A row is chosen | `Label_Preview` with the language's name, once the dialog has redrawn. |
| A row that cannot be chosen is clicked or reached | `Pack_Unusable_Detail` for it. |
| The restart note appears or goes | The note's text; `Announce_Restart_Cleared` ("No restart is needed.") when it goes. |
| "Restart now" becomes enabled or disabled | Its name with its state, and `Label_Restart_Busy` when disabled. |

The list is a UI Automation list whose items expose the Selection Item pattern; a row that cannot be chosen reports itself not enabled.

## How does it scale, and what about right-to-left languages?

The page follows the user's density and the shell's scaling rule ([`preferences.md`](preferences.md#how-does-it-scale)): row height 28, 32 or 36, nothing clipped at the dialog's minimum size or at 200 percent text scaling. A Language cell too long for its column ends in an ellipsis with the whole name in a tooltip and in the row's accessible name (`D01 T02 §7`); the Code and Translated columns never shrink below their content. Under 600 wide, where the shell's page list is a picker, the list keeps all three columns.

Arabic, Persian and Hebrew are among the 35 packs (`ar`, `fa`, `iw`). Their text is shaped and read right to left and aligned to the leading edge of its control, and a path or number inside it stays left to right (`D01 T02 §7`). **The layout is not mirrored in this version:** the page list stays at the left and columns keep their order. That is a stated limit, owned by `D01 T02 §7`, not an oversight.

## Which strings does the page use?

All in `[Preferences]` unless marked. Every text above has a key here.

| Key | English | Verdict |
| --- | --- | --- |
| `Tab_Language` | Language | Kept, as the page name (`en.lng:165`) |
| `Group_Language` | Language | Kept, as the group and the list's name |
| `Label_Language_Message` | Choose a language. This dialog changes at once. The rest of %{Program.Name} changes after it restarts. | Reworded (`en.lng:177`): it named the Save button and said "(Restart Required)" |
| `Label_Language_Showing` | %{Program.Name} is showing %1. | New |
| `Column_Language`, `Column_Code`, `Column_Translated` | Language, Code, Translated | New; the first two were typed into the code |
| `Row_Windows` | Use the Windows language (%1) | New |
| `Row_Windows_Fallback` | Use the Windows language (English: there is no pack for %1) | New |
| `Pack_Unusable` | Cannot be used | New |
| `Pack_Unusable_Detail` | %1 cannot be used: %2. | New |
| `Pack_Partial_Detail` | %1 of %2 strings are translated. The rest show in English. | New |
| `Pack_English_Builtin` | %1 cannot be used: %2. English is shown from the built-in text. | New |
| `Pack_Code_Mismatch` | This pack calls itself %1, but its file is %2. It is used as %2. | New |
| `Pack_Reason_Encoding`, `Pack_Reason_Truncated`, `Pack_Reason_No_Language`, `Pack_Reason_Duplicate`, `Pack_Reason_Unreadable`, `Pack_Reason_Missing` | As the reasons table gives them | New |
| `Label_Language_Missing` | %{Program.Name} is set to %1, but %2 cannot be used: %3. | New |
| `Label_Language_No_Packs` | No language packs were found in %1. | New |
| `Label_Language_Folder_Unreadable` | The language folder %1 could not be read: %2. | New |
| `Label_Language_Restart` | %{Program.Name} is still showing %1. It will show %2 after it restarts. | New; replaces `MsgBox_Language_Message` |
| `Button_Restart_Now` | `&Restart now` | New; replaces the closing prompt |
| `Label_Restart_Busy` | Available when the current task has finished. | New |
| `Restart_Failed_Title`, `Restart_Failed_Body`, `Restart_Failed_Timeout`, in `[Messages]` | As the message table gives them | New |
| `Announce_Translated` | %1 percent translated | New |
| `Announce_Restart_Cleared` | No restart is needed. | New |
| `Label_Preview` | Previewing %1. Save to keep it. | The shell's, used as it is |
| `MsgBox_Language_Title`, `MsgBox_Language_Message` | | Cut (`en.lng:182-183`), with the prompt. For `D01 T03 §7`'s audit: no pack ships them |
| `MsgBox_Closing_Title`, `MsgBox_Closing_Messag`, `MsgBox_Closing_Message` | | Cut (`en.lng:184-185`, `Localization.au3:119-120`), with the prompt, under both spellings of the last. For `D01 T03 §7`'s audit: no pack ships any of the three |

## What must the build prove, row by row?

Every row is one behavioural check in `D01 T01 §7`, driven against the built dialog with fixture packs; where a row names the setting, the check reads the settings file back as well as the control.

| Element | Trigger | States | Result | Failure | Check in `D01 T01 §7` |
| --- | --- | --- | --- | --- | --- |
| First start | Start with no `Language` stored and a pack for the first Windows display language; then with none for any | Windows language with a pack; without | The tool shows that language; "Use the Windows language" is chosen and names it; without a pack it shows English and the row reads `Row_Windows_Fallback` | A Windows language list that cannot be read counts as no match: English | `language: the windows language is the default` |
| The list | Open the page with fixture packs, one complete, one at 82 percent, and no `en.lng` | Packs present | One row per pack sorted by code, each with its own name, code and percentage; English present once, at 100%; the stored row chosen and visible | A pack at fault is its own row below | `language: the list names every pack and always english` |
| Choosing by keyboard | Up, Down, Home, End, Page Up, Page Down; type "ja", then "ma" | Any row | Each key chooses the row it lands on; type-ahead reaches the Japanese row by its code and Magyar by its name | A row that cannot be chosen is skipped as the chosen row and announced | `language: every key that moves the selection chooses` |
| Preview | Choose another language | Complete pack; part-translated pack | The dialog redraws in it, page list and buttons included; the main window is unchanged; `Label_Preview` announced; Save enabled | A pack that fails to load when chosen: the row turns to "Cannot be used", the chosen row and the dialog's language stay | `language: choosing previews the dialog only` |
| Save | Choose a language; Save | Changed | `Language` reads back as the code; the main window is unchanged; the restart note names both languages | Save's failures, as the shell rules | `language: save stores the code and asks for a restart` |
| Pinning the Windows language | With `Language` empty and resolving to German, choose the German row; Save | | The page is dirty before Save; `Language` reads back `de`; no restart note | Save's failures | `language: pinning the resolved language is a change` |
| Back to the Windows language | With `Language` holding `de`, choose "Use the Windows language"; Save | | `Language` reads back empty | Save's failures | `language: the windows row stores an empty value` |
| Cancel and Discard | Choose a language; Cancel, then Discard | Previewing | The dialog returns to the baseline language; `Language` unchanged | None can occur: the baseline pack is already loaded | `language: discard undoes the preview` |
| Reopening before a restart | Save a new language; close; reopen Preferences | Stored differs from effective | The dialog opens in the stored language with the note; the showing-now line names the main window's language | A stored pack gone since: the dialog opens in the running language with `Label_Language_Missing` and no restart note | `language: the dialog opens in the stored language` |
| An unrelated save | With the note showing, change only Reduce memory; Save | | The main window's language is unchanged; the note is still there; `Language` unchanged | Save's failures | `language: an unrelated save keeps the pending restart` |
| Changing back | With the note showing, choose the effective language; Save | | The note goes, announced as `Announce_Restart_Cleared` | Save's failures | `language: saving the running language clears the note` |
| Restart now | Press it; Alt+R | Not dirty, no task | One instance running afterwards, started before the first exited, with the same arguments, showing the stored language in its main window | Windows refusing the start: the first stays open with `Restart_Failed_Body` naming the path and reason, no second process | `language: restart shows the stored language` |
| Restart that is not answered | Seed a second instance that never answers | | After 10 seconds the first is open as it was, the second is ended, and the message gives `Restart_Failed_Timeout` | The stated result is the failure presentation | `language: an unanswered restart leaves the tool open` |
| Restart with unsaved edits | Edit another setting; press Restart now; answer Save, then Discard, then Cancel, in three runs | Dirty | Save: the edit is read back, then the restart; Discard: the edit is not in the file, then the restart; Cancel: the dialog stays, nothing restarts | Save failing or unconfirmed (seeded): its failure shows and nothing restarts | `language: restart goes through the way out` |
| Restart with nothing to restart for | With the note showing, choose the effective language without saving; press Restart now; answer Save | Dirty | The save is read back, the note goes and the tool stays open | Save's failures | `language: no restart when the stored language is running` |
| Restart while a task runs | Start the tool's action; open the page with the note showing | A task running; then finished | The button is disabled with `Label_Restart_Busy`; it is enabled, announced, when the task ends | None can occur: the state follows the task | `language: restart waits for a running task` |
| A pack that cannot be read | Fixture packs: wrong encoding, cut short, no `[Language]`, a duplicate key, access denied | Each reason | Each is listed by file name as "Cannot be used"; the detail line names the file and that reason; clicking or reaching it does not choose it | The stated results are the failure presentations | `language: an unreadable pack is named and cannot be chosen` |
| A damaged English pack | A corrupt `en.lng` beside a usable German pack, Windows set to German; choose English; Save; restart | | One English row, at 100%, whose detail line names `en.lng` and its reason; choosing it previews English from the built-in text; `Language` reads back `en`; the restarted tool shows English | None can occur: the built-in text is compiled in | `language: english survives a damaged english pack` |
| A part-translated pack | A pack missing keys, one of which its common pack holds | 82 percent | The percentage counts the common pack's key as translated; the detail line gives the counts; the missing strings show in English and the common pack's in the language | None can occur: every key resolves to built-in English at worst | `language: missing strings fall back in order` |
| A code that disagrees | A pack `xx.lng` whose `Code` is `yy` | | Listed and stored as `xx`; the detail line states both | Save's failures | `language: the file name is the pack's identity` |
| A stored language that cannot be used at the start | Start with `Language` holding a code whose pack is missing; then unreadable | Missing; unreadable | The tool and the showing-now line show English; `Label_Language_Missing` names the code, file and reason; no row chosen; no restart note; the page not dirty; after an unrelated save `Language` reads back unchanged | The stated results are the failure presentations | `language: a lost pack is reported and its setting kept` |
| A pack lost while the tool runs | Start in German; delete `de.lng`; open Preferences | | The main window and the showing-now line are still German; the dialog opens in German; `Label_Language_Missing` names `de`, the file and `Pack_Reason_Missing`; no restart note; `Language` unchanged | The stated results are the failure presentations | `language: a pack lost mid-session keeps the running language` |
| No packs | An empty language folder; a missing one; an unreadable one | Each | The list holds the Windows row and English; the note names the folder, and the Windows reason when unreadable | The stated results are the failure presentations | `language: a missing folder still offers english` |
| A pack that turns bad while the dialog is open | Corrupt a listed pack after opening, then choose it | | The row turns to "Cannot be used" with its reason; the chosen row and the dialog's language stay | The stated result is the failure presentation | `language: a pack is checked again when chosen` |
| Copying a note | Tab to the detail line of an unreadable pack; Ctrl+C | A note showing | The clipboard holds the whole line, file name and reason included | The clipboard held by another program: `Message_Copy_Failed`, as the shell rules | `language: a pack's reason copies whole` |
| Announcements | Focus rows of each state; choose one; let the note appear and go | | Each announcement in the table above is raised once, read through UI Automation, and a row that cannot be chosen reports not enabled | None can occur: each announcement follows its event | `language: rows and notes are announced` |
| Scaling and right-to-left | The page at each density, at 560 wide and at 200 percent text scaling, in English and with an Arabic pack chosen | | Nothing is clipped; a long name ends in an ellipsis with a tooltip; Arabic text is shaped right to left with a path inside it left to right; the layout is not mirrored | None can occur: a name that does not fit is truncated by rule | `language: the page scales, and right-to-left text reads` |
