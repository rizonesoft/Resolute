# The Preferences dialog

Every Resolute tool has one Preferences dialog, owned by the framework. This page specifies its shell and four of its pages (General, Performance, Updates, Appearance) control by control, so that `D01 T01 §7` can build them without inventing a control. It is `D01 T03 §2` (`todo/01-framework/TODO-03-framework-surfaces.md`). The Language page and the contract for a tool's own pages are `D01 T03 §3`'s.

A user changes a setting once and trusts it was kept. So every control is bound to one setting key, written only by the framework's settings writer (`D01 T01 §2`), and a page never writes a key itself. The setting names are the AutoIt ones, because the settings file stays the AutoIt `.ini`: a file the AutoIt tool wrote reads back the same here.

The dialog is drawn with the form controls `D01 T02 §9` adds to the UI library, and its messages go through the message layer in [`standard-window.md`](standard-window.md). Sizes are base values at 96 DPI. A specification cannot prove behaviour, so the page ends in a matrix ([below](#what-must-the-build-prove-row-by-row)) whose every row is a check `D01 T01 §7` runs.

## What does the AutoIt dialog have, and where does each part go?

The AutoIt dialog is `_ShowPreferencesDlg` (`resolute_au3/SDK/Concrete/ReBar/ReBar.au3:989-1146`), a fixed 450 x 500 window that is not DPI-aware. Its strings load in the order set by `resolute_au3/SDK/Concrete/ReBar/Includes/Localization.au3:97-120`.

| AutoIt part | Source | Here |
| --- | --- | --- |
| Window, 450 x 500, caption only, always on top (`$WS_EX_TOPMOST`), the main window disabled while it is open | `ReBar.au3:1005`, `:1000` | A dialog modal to the tool's window, resizable, never topmost over other applications. |
| Tab strip: General, Performance, Language | `ReBar.au3:1011`, `:1013`, `:1035`, `:1071` | A page list at the left: General, Performance, Updates, Appearance, Language, then the tool's pages. A list, not tabs, because a tool may add pages and a tab strip of seven does not fit. |
| Logging group: enable checkbox, size input in KB, current-size label, Clear button | `ReBar.au3:1014-1027` | General, Logging, below. The size is entered in MB. |
| Priority group: label, combo of six English names, a 48 px icon that changes with the priority, save-above-high checkbox | `ReBar.au3:1036-1050` | Performance, Priority, below. The icon is cut: the combo already says the priority, and a second picture of it adds nothing. |
| Save-above-high checkbox labelled from `Button_Cancel` | `ReBar.au3:1048` reads index 17; `Localization.au3:110` loads `Checkbox_SaveRealtime` at 13 and `:114` `Button_Cancel` at 17 | A defect, not ported: the checkbox read "Cancel". It takes its own key. |
| Priority names and the unit "KB" as literals | `ReBar.au3:1041`, `:1022` | Not ported as literals: each is a pack string. |
| Memory group: reduce-memory checkbox | `ReBar.au3:1056-1059` | Performance, Memory, below. |
| Priority, save-above-high and reduce-memory disabled when the script is not compiled | `ReBar.au3:1062-1066` | Cut: a development-only branch. A built tool always has all three. |
| Language group: flag, name, list, note | `ReBar.au3:1071-1127` | `D01 T03 §3`. |
| Updated notice, hidden until a save, created with the priority label's text | `ReBar.au3:1130` reads index 12, `Label_SetPriority` | The saved notice, below. Its placeholder text was a defect and is not ported. |
| Save, disabled until something changes; Cancel | `ReBar.au3:1133-1141`, `__CheckPreferenceChange` at `:1238` | Save and Cancel, below, with the same rule. |
| Priority applied to the running process the moment the combo changes, before Save | `ReBar.au3:1177-1195` | Changed: a priority applies at Save, like every other setting, so Cancel leaves the process as it was. |
| Clear removes the whole log folder at once | `ReBar.au3:1149-1163`, `DirRemove` at `:1152` | Changed: clearing removes this tool's log files through the log writer, never a folder. |
| Startup default priority Above Normal; the dialog's own default Normal | `ReBar.au3:860` reads 3; `:1204` reads 2, `:1041` | One default: Normal. |
| Language-changed and close-now prompts on Save | `ReBar.au3:1295-1312`, `:1344-1352` | `D01 T03 §3`. |
| `MsgBox_Closing_Messag`, misspelled in the pack against the loader's `MsgBox_Closing_Message` | `resolute_au3/Resolute/Language/ReBar/en.lng:185`, `Localization.au3:120` | A defect: the pack's text never loaded. Handed to `D01 T03 §3`, which owns that prompt, and to `D01 T03 §7`'s string audit. |
| `Tab_Cache` | `en.lng:163`; no line of `Localization.au3:97-120` loads it | Cut: a dead key. No dialog ever built a Cache page, and none is invented to use it. |

## What does the shell hold?

| Part | Contents | Rule |
| --- | --- | --- |
| Title | `Window_Title` ("Preferences"), then the tool's display name | So a user with two tools open knows whose preferences these are. |
| Page list | General, Performance, Updates, Appearance, Language, then each page the tool adds, in the order it adds them | 200 wide at the left while the dialog is 600 wide or more. Narrower than that, the list becomes a page picker above the page: a combo labelled `Label_Page` ("Page"), holding the same pages under the same names, so the page has the dialog's full width. The dialog opens on General, or on the page a caller names. |
| Page | The chosen page's groups, each under a group heading | Scrolls vertically when the page is taller than the dialog; never horizontally. |
| Saved notice | `Label_Updated` ("Preferences saved"), at the left of the button row, with a check icon | Appears after a successful Save, stays until the next edit, and is announced. |
| Save | `Button_Save` (`&Save`) | Disabled until an edited value differs from the persisted one; the default button when enabled. |
| Cancel | `Button_Cancel` ("Cancel") | Always enabled. |

- **Size and place:** default 720 x 520, centred on the tool's window; minimum 560 x 420; resizable. The dialog's size and position are remembered per monitor, as the main window's are ([`standard-window.md`](standard-window.md), `D01 T01 §2`): `PreferencesPlacement`, holding left, top, width and height in base units relative to that monitor's work area, kept in the settings file's section for the monitor. It is written through the settings writer when the dialog closes by any way out, Cancel and Discard included: where a window sits is not a preference being edited, so it is not part of Save, the dirty rule or the prompt. The dialog reopens at its stored place when the tool's window is on that monitor. Otherwise (the tool is on another monitor, that monitor is gone, or the stored place lies off every monitor) it opens centred on the tool's window at the stored size. On every open, whichever case applies, the size is then clamped to the minimum and to the monitor's work area as it is now, and the position moved so the whole dialog, Save and Cancel included, lies inside that work area: a monitor whose resolution or scaling changed since the place was stored never leaves part of the dialog off the screen. If the placement cannot be written, the dialog closes all the same, the failure goes to the log, and the next open uses the last placement that was stored.
- **One dialog per tool:** asking for Preferences while it is open brings it forward, on the page it was on.
- **Three values, kept apart.** For every setting the dialog knows the persisted value (what the settings file holds), the effective value (what the tool is using now) and the edited value (what the control shows). Save is enabled when any edited value differs from its persisted value.
- **A control shows what the file holds.** When the dialog opens, and again after every successful Save, each control is set to its persisted value, so nothing is left looking unsaved. Where the effective value differs from the persisted one (a priority Windows refused, Realtime kept only for this session, logging that could not start), a note beside the control says what the tool is doing; the control never shows the effective value in place of the stored one.

### What does Save do?

1. It validates every control the user edited since the dialog opened or last saved, in page order, and only those. The first whose value is not allowed stops the save: nothing is written, the dialog moves to that page, focus goes to the control, and its error shows beneath it.
2. It writes the key of every edited control whose value differs from the file's, through the settings writer in one atomic write (`D01 T01 §2`), then reads the file back. A control the user did not edit never rewrites its key, so a stored value the control can only show approximately survives every save untouched.
3. Only when the file reads back as written does it reconcile the running tool with what was saved (the one rule below), show the saved notice and disable Save. The edited values become the new baseline. Saved and applied are two things: the notice means the file holds the values, and a setting that could not reach its target says so in a note beside its control.

**Reconciling, the one rule for when a setting is applied.** Every setting has a target: its persisted value, or a session override where the page names one (Realtime without Keep Realtime, which lasts until the tool closes or a different priority is saved). After every confirmed save, and at startup, the framework compares each setting's effective value with its target and acts only where the two differ. Nothing else applies a setting. So a save that changes one setting never disturbs another whose effective value already matches its target (a session-only Realtime keeps running), and a setting that could not reach its target earlier is tried again at every save without the user having to touch it (a log writer that could not start, a priority Windows refused): if it still cannot, its note stays and nothing new is reported.

A save whose write went through but whose read-back failed or differed leaves the save unconfirmed: the file may already hold the new values while the tool has not applied them. Until a save completes all three steps, the dialog counts as having unsaved changes whatever the file now holds: Save stays enabled, the way out asks, and the next Save writes every value of the unconfirmed save again, reads back, and then applies them all before it reports success. Discard leaves the file as it is and applies nothing; the tool takes the file's values at its next start.

| Outcome | Persisted | Effective | Edited | The user sees |
| --- | --- | --- | --- | --- |
| Save succeeds | The edited values | Each setting at its target, or carrying its note: a priority Windows refused, a Realtime kept only for this session, and logging that could not start are saved but not, or not only, what the tool is doing | Each control shows what the file holds; the new baseline | The saved notice, which says the preferences were saved and claims nothing about what is running; any such note beside its control; Save disabled |
| A value is not allowed | Unchanged | Unchanged, except a preview already showing | Unchanged | The control's error (`Error_Value_Range`), focus on it; no notice |
| The file cannot be written | Unchanged | Unchanged, except a preview already showing | Unchanged | The message layer's Error `Save_Failed` with the path and the Windows reason; Save stays enabled |
| The file reads back differently, or cannot be read back | What the file now holds, which may be the new values | Unchanged, except a preview already showing: nothing is applied | Unchanged | Error `Save_Unverified` with the path and, for a read that failed, the Windows reason; no saved notice; the save is unconfirmed, so Save stays enabled and the way out asks, even if the file is later found to match |
| Discard | Unchanged | The baseline, every preview undone | Dropped | The dialog closes |
| Cancel in the prompt | Unchanged | Unchanged, previews still showing | Unchanged | The prompt closes; the dialog stays |

### What happens on the way out?

Cancel, Esc and the caption's close button do the same thing. With no unsaved change the dialog closes at once. With one, it asks once through the message layer: `Unsaved_Title` ("Save your changes?"), with Save (the default), Discard and Cancel. When the last save could not be confirmed, the prompt's body is `Unsaved_Unconfirmed` ("Your last save could not be confirmed. The settings file may already hold these changes, and they may take effect the next time this tool starts."), so Discard is chosen knowing that.

- **Save** saves as above and closes when the save succeeds; when it fails, the failure shows and the dialog stays.
- **Discard** drops every edited value, undoes every preview so the tool looks as it did at the baseline, and closes.
- **Cancel** returns to the dialog with every edited value and every preview as it was.

A successful Save moves the baseline. So after preview, Save, a further preview and Discard, the tool shows what was saved, not what it showed before the dialog opened.

## What is on the General page?

One group, Logging (`Group_Logging`).

| Control | Pack key | Setting | Default | Rule |
| --- | --- | --- | --- | --- |
| Enable logging, a checkbox | `Checkbox_Enable_Logging` (`&Enable logging`) | `LoggingEnabled`, 1 or 0 | 1 | Unchecking it sets the size input back to its persisted value and disables it, so a half-typed or empty size is dropped, not validated: a disabled control is never validated and never written. Checking it again enables the input showing that persisted value. Clear stays enabled while there is a log to clear. |
| Keep the log under, a numeric input with the unit MB | `Label_Log_Limit` (`Keep the &log under`), new; unit `Unit_MB` ("MB"), new | `LoggingStorageSize`, in bytes | 5 MB (5242880, the AutoIt default at `ReBar.au3:866`) | An edit must be a whole number from 1 to 100; empty, zero, a fraction or a larger number is not allowed: `Error_Value_Range` ("Enter a whole number from %1 to %2."). The AutoIt suite stored kilobytes times 1024 (`ReBar.au3:1331`), so a file may hold a limit that is not a whole number of megabytes, or is over 100. Such a value is shown as it is, to two decimals (1536 KB shows 1.5), its exact bytes are kept apart from the number shown, and, being unedited, it is neither validated nor rewritten: it stays byte for byte through any save until the user types a new limit. |
| Current size, a label | `Label_Logging_Size` ("The log is using %1."), reworded | none | | The size of this tool's log files, in KB under 1 MB and MB above, refreshed when the page shows, every 2 seconds while it shows, and after a clear. "The log is empty." (`Label_Logging_Empty`, new) when there is none. When the folder cannot be read, `Label_Logging_Size_Unavailable` ("The log's size could not be read: %1"), new, with the Windows reason, and never "empty"; Clear log stays available and reports what it could not delete. |
| Clear log, a button, with a line beneath it | `Button_Logging_Clear` (`&Clear log`), reworded; `Label_Logging_Clear_Note` ("Deletes the log files now. This cannot be undone, and Cancel does not bring them back."), new | none | | Below. |

### What if logging cannot start?

Saving a setting and starting the log writer are two things, and the second can fail when the first succeeded: the log folder is not writable, or the disk is full. Then `LoggingEnabled` is saved as 1 (persisted), the writer is not running (effective), and beside the checkbox `Label_Logging_Not_Running` ("Logging is on but cannot write: %1"), new, gives the path and the Windows reason, with a warning icon, announced. The saved notice still shows, because the preferences were saved. By the reconcile rule the writer is tried again at every confirmed save, whatever that save changed, and also after a Clear log and at the next start; the note goes when it succeeds. The same note shows when the dialog opens on a tool in that state.

### What does Clear log do?

It asks nothing: a log is expendable, and the line beneath the button has already said the deletion is immediate and final (`DESIGN.md` §11). It is not part of Save or Cancel.

It goes through the log writer (`D01 T01 §3`), which closes its file, removes this tool's own log files and only those (never the folder, and never a file it did not write), and, when logging is enabled, opens a new file whose first line records the clear. The size label refreshes, and one of three results shows beside the button and is announced. When logging is enabled and the new file cannot be opened, the result still says what was deleted, and the not-running note below appears as well:

| Result | Text | When |
| --- | --- | --- |
| Cleared | `Label_Logging_Cleared` ("Log cleared: %1 freed."), reworded | Every file was removed |
| Nothing to clear | `Label_Logging_Nothing` ("There was no log to clear."), new | No log file existed |
| Partly cleared | `Label_Logging_Partial` ("%1 of %2 log files could not be deleted: %3"), new, with the first file's name and the Windows reason, the rest in the log | A file was held open by another program, or could not be deleted |

## What is on the Performance page?

Two groups.

### Priority (`Group_Priority`)

| Control | Pack key | Setting | Default | Rule |
| --- | --- | --- | --- | --- |
| Process priority, a combo | `Label_SetPriority` (`Process &priority`), reworded | `ProcessPriority`, 0 to 5 | 2, Normal | The six values below. |
| Keep Realtime after a restart, a checkbox with a warning line | `Checkbox_SaveRealtime` (`&Keep Realtime after a restart (not recommended)`), reworded; `Label_Realtime_Warning` ("Realtime can make Windows stop responding to the mouse and keyboard."), new | `SaveRealtime`, 1 or 0 | 0 | Enabled only while the combo shows Realtime. |

| Value | Stored | Win32 class | Pack key, new |
| --- | :-: | --- | --- |
| Low | 0 | `IDLE_PRIORITY_CLASS` | `Priority_Low` |
| Below normal | 1 | `BELOW_NORMAL_PRIORITY_CLASS` | `Priority_Below_Normal` |
| Normal | 2 | `NORMAL_PRIORITY_CLASS` | `Priority_Normal` |
| Above normal | 3 | `ABOVE_NORMAL_PRIORITY_CLASS` | `Priority_Above_Normal` |
| High | 4 | `HIGH_PRIORITY_CLASS` | `Priority_High` |
| Realtime | 5 | `REALTIME_PRIORITY_CLASS` | `Priority_Realtime` |

- **Why Normal is the default.** The AutoIt suite started at Above Normal (`ReBar.au3:860`) while its dialog treated Normal as the unchanged value (`:1204`), so a user who never opened Preferences ran above everything else on the machine without being told. A utility has no claim on more than its share until the user asks; the cost of changing this back is one constant.
- **When it applies.** By the reconcile rule: when the process's priority differs from its target after a confirmed save, the framework sets the priority class and reads it back from Windows. At startup `D01 T01 §1` does the same.
- **Realtime without the checkbox.** The process runs at Realtime for this session and the file stores High (4). After the save the combo shows High, as the file holds, with `Label_Realtime_Session` ("Running at Realtime until this tool closes; it will start at High.") beneath it for as long as that is so, announced, including when the dialog is opened again in the same session. Save is disabled, and closing straight after asks nothing. Beside the note, `Button_Realtime_End` (`Return to &High now`) ends it at once, outside Save: the framework sets the stored priority and reads it back from Windows; when Windows confirms it, the session override is cleared, so the target is the stored value again and no later save or reopening brings Realtime back, and the note and the button go, announced; when Windows refuses, the override, the note and the button stay, and the note adds the Windows reason.
- **When Windows refuses.** Realtime needs a privilege a standard user does not hold, and Windows then gives High without reporting an error; any other refusal leaves the priority as it was. After Save, the framework compares what it asked for with what Windows reports. The request is what is stored and shown, so the tool gets it whenever Windows will grant it (run elevated, for instance), and the note says what the tool is running at meanwhile. The same note shows when the dialog opens on a tool whose stored and actual priorities differ, and closing after such a save asks nothing:

| State | After a refusal |
| --- | --- |
| The process's priority | What Windows reports: High for a refused Realtime, the earlier priority otherwise |
| The stored value | What was asked for, capped by the Realtime rule above |
| The combo | What was asked for, which is what the file holds, so the edited and persisted values agree; beneath it `Label_Priority_Refused` ("Windows is running this tool at %1 instead of %2."), announced, for as long as the two differ |
| The dialog | Not dirty, by the one dirty rule: the edited value equals the persisted one. A later save of another setting leaves the stored priority as it is, and the reconcile rule asks Windows for it again because the effective priority still differs from the target; a second refusal changes nothing and the note stays |

### Memory (`Group_Memory`)

| Control | Pack key | Setting | Default | Rule |
| --- | --- | --- | --- | --- |
| Reduce memory use when Windows is short of memory, a checkbox | `Checkbox_ReduceMemory` (`&Reduce memory use when Windows is short of memory`), reworded | `ReduceMemory`, 1 or 0 | 1 | Below. |

When it is on, the tool checks how much of the system's physical memory is in use and, while that is above the threshold, trims its own working set (`EmptyWorkingSet` on itself), which gives memory back to Windows at the cost of the tool reloading pages when it is next used. The AutoIt suite checked every `ReduceEveryMill` (300 ms, `ReBar.au3:863`) against `MinSysMemoryPerc` (80 percent, `:864`); both stay settings in the file without a control, and `D01 T01 §1` owns the timer. Turning it off at Save stops the timer in this session; turning it on starts it.

## What is on the Updates page?

One group, Updates (`Group_Updates`, new).

| Control | Pack key | Setting | Default | Rule |
| --- | --- | --- | --- | --- |
| Check for updates, a combo | `Label_Update_Frequency` (`Check for &updates`), new | `UpdateFrequency`: `Startup`, `Daily`, `Weekly`, `Never` | `Daily` | Values `Update_Every_Start`, `Update_Daily`, `Update_Weekly`, `Update_Never`, new. |
| Last checked, a label | `Label_Update_Last` ("Last checked: %1"), `Label_Update_Never_Checked` ("Not checked yet."), new | `UpdateLastCheck`, read only here | | The date and time, in the user's locale, of the last check that completed: one that received an update response and parsed it as valid (`D01 T01 §5`). An unreachable server, an HTTP error and a malformed update file are failures and leave `UpdateLastCheck` as it was. Before any completed check: "Not checked yet." After a failed attempt the label keeps the last completed time and adds `Label_Update_Last_Failed` ("The check on %1 did not finish: %2"), new, until a check completes. |
| Check now, a button | `Button_Update_Now` (`Check &now`), new | none | | Runs the check `D01 T01 §5` owns, as Help, Check for updates does; disabled while one runs. |
| Skipped version, a label and a button, shown only when a version is skipped | `Label_Update_Skipped` ("You chose not to be told about version %1."), `Button_Update_Unskip` (`&Tell me again`), new | `UpdateSkipVersion`, written by the update dialog's don't-show-again choice (`D01 T03 §5`) | empty | The button clears the key at Save. |

- **The AutoIt setting.** The AutoIt suite had one switch, `CheckForUpdates`, holding a checkbox state: 4 to check at every start, 1 never (`ReBar.au3:859`, `:614`; `resolute_au3/SDK/Includes/Update.au3:139`). A settings file with that key and no `UpdateFrequency` reads as `Never` for 1 and `Daily` otherwise, and the first Save writes `UpdateFrequency`.
- **Why Daily is the default.** A check at every start contacts the server each time a tool opens, which a repair tool opened ten times in an hour does not need; daily still reaches a user within a day of a release. Cost of changing: one constant.
- **When it applies.** At Save: a check already scheduled is rescheduled or cancelled to match, and one already running is never interrupted.

## What is on the Appearance page?

One group, Appearance (`Group_Appearance`, new).

| Control | Pack key | Setting | Default | Rule |
| --- | --- | --- | --- | --- |
| Theme, a combo | `Label_Theme` (`&Theme`), new | `Theme`: `System`, `Light`, `Dark` | `System` | Values `Theme_System` ("Use the Windows setting"), `Theme_Light`, `Theme_Dark`, new. |
| Density, a combo | `Label_Density` (`&Density`), new | `Density`: `Compact`, `Normal`, `Spacious` | `Normal` | Values `Density_Compact`, `Density_Normal`, `Density_Spacious`, new. |

Both preview at once: choosing a value changes the tool's window and this dialog straight away, announced as `Label_Preview` ("Previewing %1. Save to keep it."), and it is kept only at Save. Discard and a closed tool return to the baseline.

## When does each setting take effect?

No setting on these pages needs a restart. The language, which does, is `D01 T03 §3`'s. "At Save" below means by the reconcile rule: after a confirmed save, and only when the setting's effective value differs from its target.

| Setting | Takes effect | In the running tool |
| --- | --- | --- |
| `LoggingEnabled` | At Save | Off: the log writer writes one last line saying logging was turned off, then stops. On: it opens its file and writes from the next line; when it cannot (the folder is not writable, the disk is full), the setting stays saved as on, the writer stays stopped, and the General page says so, below. |
| `LoggingStorageSize` | At Save | The log writer uses the new limit from the next line, and rotates at once when the file is already over it (`D01 T01 §3`). |
| `ProcessPriority`, `SaveRealtime` | At Save | The process's priority class is set and read back. |
| `ReduceMemory` | At Save | The trim timer starts or stops. |
| `UpdateFrequency` | At Save | A scheduled check is rescheduled or cancelled; a running one finishes. |
| `Theme`, `Density` | Previewed on change, kept at Save | The window and the dialog redraw. |

## What is announced?

Each of these raises a UI Automation notification with its text, and none is carried by colour alone (`DESIGN.md` §9): each has an icon or sits beside the control it concerns.

| Notice | Announced when |
| --- | --- |
| The saved notice, and its Realtime form | A save succeeds |
| A value that is not allowed, with its control's name | Save stops on it |
| Cleared, nothing to clear, partly cleared | Clear log finishes |
| Windows set another priority | A priority is refused |
| Previewing a theme or density | A preview is applied |
| Update check started and finished | Check now runs, through the status bar's task segment |

## Can a note be copied?

Yes, from the keyboard. Every inline note that carries a path, a file name, a Windows reason or a number is selectable text and a stop in the Tab order after the control it sits beside, and Ctrl+C on it copies the whole note, machine values in monospace as on screen (`DESIGN.md` §4). These are: the logging not-running note, the partly-cleared result, the size-unavailable note, the refused-priority note, the session-Realtime note, the failed-check note, and a value's range error. A save failure's path and reason are in the message layer, which copies as [`standard-window.md`](standard-window.md) says.

## Which keys does the dialog answer?

| Key | Where | Does |
| --- | --- | --- |
| Up, Down, Home, End | Page list | Chooses a page; the page shows at once. |
| Ctrl+Tab, Ctrl+Shift+Tab | Anywhere in the dialog | The next or previous page, wrapping, with focus kept in the page list. |
| Tab, Shift+Tab | Dialog | The page list (or the page picker when the dialog is narrow), then the page's controls top to bottom, each note after the control it sits beside, then Save, then Cancel, and round. |
| Alt and a control's access key | Dialog | Focuses the control, and toggles a checkbox. Access keys are unique within a page and never collide with `&Save`. |
| Space | A checkbox or a button | Toggles or presses. |
| F4, Alt+Down; Up, Down; a typed letter | A combo | Opens it; changes the selection; type-ahead. |
| Enter | A button focused | Presses that button: Enter on Cancel takes the way out, never Save. |
| Enter | Anywhere else but an open combo | Save, the default button, when it is enabled. |
| Esc | An open combo | Closes the combo, keeping the value. |
| Esc; Alt+F4 | Otherwise | The way out, as above. |

Focus starts on the page list when the dialog opens. After a failed save it goes to the control at fault, or to Save when the fault was the file.

## How does it scale?

The dialog follows the user's density (`D01 T02 §2`) for its row height (28, 32, 36 for Compact, Normal, Spacious) and group padding (`SpacingMD`, `SpacingLG`, `SpacingXL`); text and icon sizes do not change. At its minimum size, at every density, and at 200 percent text scaling, no control or label is clipped: a label that does not fit wraps, and a page taller than the dialog scrolls. Every control is a 24 x 24 target at least (`DESIGN.md` §9).

## Which strings does the dialog use?

Every string on these pages is a pack string in `[Preferences]`, except the message layer's own (`[Messages]`). `%1`, `%2` and `%3` are substitutions in the order given.

| Key | English | Verdict |
| --- | --- | --- |
| `Window_Title` | Preferences | Kept |
| `Tab_General`, `Tab_Performance`, `Tab_Language` | General, Performance, Language | Kept, as page names |
| `Tab_Updates`, `Tab_Appearance` | Updates, Appearance | New |
| `Tab_Cache` | | Cut: dead key |
| `Group_Logging`, `Group_Priority`, `Group_Memory` | Logging, Priority, Memory | Kept |
| `Group_Language` | Language | Kept, for `D01 T03 §3` |
| `Group_Updates`, `Group_Appearance` | Updates, Appearance | New |
| `Checkbox_Enable_Logging` | `&Enable logging` | Kept, gaining its access key |
| `Label_Log_Exceed` | Log size must not exceed : | Cut: replaced by `Label_Log_Limit` (a stray space before the colon, and a rule phrased as a warning) |
| `Label_Log_Limit` | `Keep the &log under` | New |
| `Unit_MB` | MB | New |
| `Label_Logging_Size` | The log is using %1. | Reworded from "Logging Size: %s KB" |
| `Label_Logging_Empty` | The log is empty. | New |
| `Label_Logging_Size_Unavailable` | The log's size could not be read: %1 | New |
| `Button_Logging_Clear` | `&Clear log` | Reworded from "Clear Logging" |
| `Label_Logging_Clear_Note` | Deletes the log files now. This cannot be undone, and Cancel does not bring them back. | New |
| `Label_Logging_Cleared` | Log cleared: %1 freed. | Reworded from "Logging cleared" |
| `Label_Logging_Nothing` | There was no log to clear. | New |
| `Label_Logging_Not_Running` | Logging is on but cannot write: %1 | New |
| `Label_Logging_Partial` | %1 of %2 log files could not be deleted: %3 | New |
| `Label_SetPriority` | `Process &priority` | Reworded from "Set process priority:" |
| `Priority_Low`, `Priority_Below_Normal`, `Priority_Normal`, `Priority_Above_Normal`, `Priority_High`, `Priority_Realtime` | Low, Below normal, Normal, Above normal, High, Realtime | New: literals in the AutoIt suite |
| `Checkbox_SaveRealtime` | `&Keep Realtime after a restart (not recommended)` | Reworded from "Save priority above high (not recommended)."; only Realtime is above High |
| `Label_Realtime_Warning` | Realtime can make Windows stop responding to the mouse and keyboard. | New |
| `Label_Realtime_Session` | Running at Realtime until this tool closes; it will start at High. | New |
| `Button_Realtime_End` | `Return to &High now` | New |
| `Label_Priority_Refused` | Windows is running this tool at %1 instead of %2. | New |
| `Checkbox_ReduceMemory` | `&Reduce memory use when Windows is short of memory` | Reworded from "Reduce memory on low memory systems." |
| `Label_Update_Frequency`, `Update_Every_Start`, `Update_Daily`, `Update_Weekly`, `Update_Never` | `Check for &updates`; Every time the tool starts, Once a day, Once a week, Never | New |
| `Label_Update_Last`, `Label_Update_Never_Checked` | Last checked: %1; Not checked yet. | New |
| `Label_Update_Last_Failed` | The check on %1 did not finish: %2 | New |
| `Label_Page` | Page | New |
| `Button_Update_Now` | `Check &now` | New |
| `Label_Update_Skipped`, `Button_Update_Unskip` | You chose not to be told about version %1.; `&Tell me again` | New |
| `Label_Theme`, `Theme_System`, `Theme_Light`, `Theme_Dark` | `&Theme`; Use the Windows setting, Light, Dark | New |
| `Label_Density`, `Density_Compact`, `Density_Normal`, `Density_Spacious` | `&Density`; Compact, Normal, Spacious | New |
| `Label_Preview` | Previewing %1. Save to keep it. | New |
| `Button_Save` | `&Save` | Kept, gaining its access key |
| `Button_Cancel` | Cancel | Kept |
| `Label_Updated` | Preferences saved | Reworded from "Preferences Updated" |
| `Error_Value_Range` | Enter a whole number from %1 to %2. | New |
| `Save_Failed`, in `[Messages]` | Your preferences could not be saved. | New; the body names the path and the Windows reason |
| `Save_Unverified`, in `[Messages]` | Your preferences were written but could not be confirmed. | New; the body names the path |
| `Unsaved_Title`, `Button_Discard`, in `[Messages]` | Save your changes?; `&Discard` | New |
| `Unsaved_Unconfirmed`, in `[Messages]` | Your last save could not be confirmed. The settings file may already hold these changes, and they may take effect the next time this tool starts. | New |
| `Label_Language_Message`, `MsgBox_Language_Title`, `MsgBox_Language_Message`, `MsgBox_Closing_Title`, `MsgBox_Closing_Messag` | | `D01 T03 §3`'s |

Every reworded or cut key goes to `D01 T03 §7`'s string audit.

## What must the build prove, row by row?

Every row is one behavioural check in `D01 T01 §7`, driven against the built dialog; where a row names a setting, the check reads the settings file back as well as the control.

| Element | Trigger | States | Result | Failure | Check in `D01 T01 §7` |
| --- | --- | --- | --- | --- | --- |
| Opening Preferences | File, Preferences; Ctrl+, | Closed, or already open | Opens on General with focus on the page list; a second request brings it forward | None can occur: the dialog is built from the framework's tables | `prefs: opens once, on General` |
| Page list | Click; Up, Down; Ctrl+Tab | Each page | The page shows; edits on other pages are kept | A tool page that fails to build is `D01 T03 §3`'s | `prefs: pages switch and keep edits` |
| Page picker | The dialog at its 560 minimum: click; F4; Up, Down; Ctrl+Tab | Narrower than 600 | The list is a combo named "Page" above the page, with the same pages; choosing one shows it; Ctrl+Tab still moves between pages | None can occur: the picker is built from the same page table | `prefs: the page list collapses to a picker when narrow` |
| Save | Click; Alt+S; Enter | Disabled until an edit differs | One atomic write, read back, values applied, the saved notice announced, Save disabled | The three save failures below | `prefs: save writes, reads back and applies` |
| A value that is not allowed | Save with the size input empty, 0, 2.5 or 101 | | Nothing written; the page shown; focus on the input; `Error_Value_Range` beneath it, announced | The stated result is the failure presentation | `prefs: a bad value stops the save` |
| A file that cannot be written | Save with the settings file read-only | | `Save_Failed` with the path; edits kept; file unchanged; Save enabled | The stated result is the failure presentation | `prefs: a refused write keeps the edits` |
| A write that cannot be confirmed | Save with the read-back made to differ, and with the read-back made to fail after the write went through; then Save again with reads working | | `Save_Unverified`; no saved notice; nothing applied to the running tool; Save enabled and the way out asks; the second Save writes again, reads back, applies every value, then shows the saved notice | The stated result is the failure presentation | `prefs: an unconfirmed write is not a success, and the retry applies it` |
| Leaving after an unconfirmed save | Save with the read-back made to fail after the write went through; take the way out; Discard; restart the tool | | The prompt's body is `Unsaved_Unconfirmed`; nothing is applied in this session; after the restart the tool runs with what the file holds | None can occur: the prompt always shows while a save is unconfirmed | `prefs: discard after an unconfirmed save is an informed choice` |
| An unrelated save | Elevated: save Realtime without Keep Realtime, then change only Reduce memory and Save. Separately: enable logging with its folder unwritable, make the folder writable, then change only Reduce memory and Save | | Windows still reports Realtime after the second save, because its effective value matches its session target; the log writer starts at the second save and its note goes, because it did not match | A setting that still cannot reach its target keeps its note; nothing new is reported | `prefs: a save reconciles only what differs from its target` |
| Ending a session Realtime | Elevated: save Realtime without Keep Realtime; press Return to High now; then change only Reduce memory and Save; close and reopen | | Windows reports High after the one press, after the unrelated save and after reopening; the note and the button are gone | Windows refusing the change: the note stays with the reason, and Realtime is still reported | `prefs: a session realtime ends on request and stays ended` |
| The way out with no change | Cancel; Esc; Alt+F4; caption close | Clean | Closes at once | None can occur | `prefs: a clean dialog closes at once` |
| The way out with a change | The same four | Dirty | The prompt; Save saves and closes, Discard drops and closes, Cancel returns | A failed Save from the prompt leaves the dialog open with its failure | `prefs: the unsaved prompt's three answers` |
| Enable logging | Click; Space; Alt+E | Checked, unchecked | The size input enables or disables; at Save `LoggingEnabled` is written and the log writer starts or stops | Save's failures; logging that cannot start, below | `prefs: logging turns off and on in the running tool` |
| Empty size, then logging off | Empty the size input, uncheck Enable logging, Save; then check it again | | The save succeeds with `LoggingEnabled` 0 and the size unchanged in the file; re-enabled, the input shows the persisted size | None can occur: a disabled control is not validated | `prefs: a disabled input is not validated` |
| Logging that cannot start | Save with logging on and the log folder not writable; Clear log with the folder not writable | | `LoggingEnabled` stays 1 in the file; the writer is not running; `Label_Logging_Not_Running` with the reason beside the checkbox, announced; no "saved" or "cleared" claim that logging continues | The stated result is the failure presentation | `prefs: logging that cannot start says so` |
| Log size | Type; paste | 1 to 100 | At Save `LoggingStorageSize` is written in bytes and the writer rotates a file already over the limit | A value not allowed, as above | `prefs: a smaller limit rotates the log at once` |
| A stored limit left alone | Open with `LoggingStorageSize` 1572864 (1536 KB), and again with 209715200 (200 MB); change only Reduce memory; Save | | The save succeeds; the input shows 1.5 and 200; `LoggingStorageSize` reads back byte for byte | None can occur: an unedited control is not validated or written | `prefs: an unedited limit is kept to the byte` |
| Current size | The page shown; every 2 seconds; after a clear | A log, none, or a folder that cannot be read | The size, or "The log is empty." | A folder that cannot be listed shows `Label_Logging_Size_Unavailable` with the reason, not "empty" | `prefs: the size label follows the log, and says when it cannot read it` |
| Clear log | Click; Space; Alt+C | Logging on or off; a log, or none; a file held open | Cleared, nothing to clear, or partly cleared, announced; logging carries on into a new file | Partly cleared names the file and the reason | `prefs: clear, with nothing to clear and with a held file` |
| Priority | Choose a value, then Save | Six values | The file holds the value and Windows reports the class, both read back, and again after a restart | A refusal, below | `prefs: priority reads back from the file and from Windows` |
| Realtime without the checkbox | Choose Realtime, leave the checkbox clear, Save; close; reopen | | Windows reports Realtime; the file holds 4; the combo shows High with `Label_Realtime_Session`; Save is disabled and closing asks nothing; reopened, the same; High after a restart | A refusal, below | `prefs: realtime is for the session unless kept` |
| A refused priority | Save Realtime with Keep Realtime as a standard user; then save an unrelated setting | | Windows reports High; the file holds 5; the combo shows Realtime with `Label_Priority_Refused` naming High; Save is disabled; the later save leaves the file's priority at 5 | The stated result is the failure presentation | `prefs: a refused priority is shown as it is, and stays as asked` |
| Keep Realtime | Click; Space; Alt+K | Enabled only with Realtime chosen | At Save `SaveRealtime` is written and Realtime survives a restart | Save's failures | `prefs: realtime kept across a restart` |
| Reduce memory | Click; Space; Alt+R | Checked, unchecked | At Save `ReduceMemory` is written and the trim timer starts or stops | Save's failures | `prefs: the memory trim starts and stops` |
| Update frequency | Choose a value, then Save | Four values; a file with only `CheckForUpdates` | `UpdateFrequency` written; a scheduled check rescheduled or cancelled | Save's failures | `prefs: update frequency reschedules, and reads the AutoIt key` |
| Check now | Click; Space; Alt+N | Disabled while a check runs | The check runs; Last checked updates | The update dialog's failure state (`D01 T03 §5`) | `prefs: check now is single-flight` |
| Last checked | Open before any check; after a completed check; after a check that met an HTTP error; after one that got a malformed update file | | "Not checked yet."; then the completed time; after each failure the completed time unchanged with `Label_Update_Last_Failed` naming the attempt, and `UpdateLastCheck` read back unchanged | The stated results are the failure presentations | `prefs: last checked means the last check that completed` |
| Skipped version | Click Tell me again, then Save | Shown only with a version skipped | `UpdateSkipVersion` cleared | Save's failures | `prefs: a skipped version can be unskipped` |
| Theme and density | Choose a value | Three values each | The window and the dialog change at once, announced; kept at Save | A value the scale lacks falls back to the default, logged | `prefs: previews apply, and save keeps them` |
| Preview, then Discard | Preview, Save, preview again, Discard | | The tool shows what was saved | None can occur | `prefs: discard returns to the last save` |
| Announcements | Each notice above | | Each raises a UI Automation notification with its text | None can occur | `prefs: every notice is announced` |
| Copying a note | Tab to the logging not-running note; Ctrl+C | A note showing | The clipboard holds the whole note, path and reason included | The clipboard held by another program: the note says "Could not copy" (`Message_Copy_Failed`) for two seconds | `prefs: an inline note copies whole` |
| Keyboard | Every key in the table above, and Enter with Cancel focused after an edit | | Every control reached and operated without a mouse; focus as stated; Enter on Cancel opens the unsaved prompt and saves nothing | None can occur | `prefs: keyboard reaches every control` |
| Density and size | The minimum size at each density, and 200 percent text | | Nothing clipped; every target at least 24 x 24 | A label that does not fit wraps | `prefs: nothing clips at the minimum size` |
| Remembered size and place | Move and resize, close with Cancel, reopen; reopen with the tool on another monitor, with the stored monitor disconnected, and with the same monitor's resolution reduced; reopen with a stored size under the minimum | | `PreferencesPlacement` read back from the file for that monitor; the dialog reopens there; with the monitor gone or the tool elsewhere, centred on the tool's window at the stored size; with the same monitor now at a lower resolution than the stored place needs, resized and moved so the whole dialog is inside the work area; no unsaved prompt for a move or resize alone | A placement that cannot be written: the dialog still closes, the failure is logged, the earlier placement is used | `prefs: the dialog remembers its size and place per monitor` |
