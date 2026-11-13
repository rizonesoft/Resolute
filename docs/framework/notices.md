# The framework's other notices

Every Resolute tool refuses, fails and closes the same way, in words owned by the framework. This page specifies the notices that are not the update notices: the elevation refusal, the crash notice and its report, the single-instance and incompatibility notices, the shutdown notice, and two families of log lines, for a registry action that fails and for a tool the launcher starts. It is `D01 T03 §6` (`todo/01-framework/TODO-03-framework-surfaces.md`), written so the sections that build them invent no string.

These are read by someone whose machine is already broken (`DESIGN.md` §11). So a refusal names the action and what it needed, a crash says what happened to the computer before it says anything about the tool, and a failure in the log names its target in the same line, in words.

Every notice is a message of the one message layer in [`standard-window.md`](standard-window.md#how-does-every-notice-reach-the-user); none draws a window of its own. A specification cannot prove behaviour, so the page ends in a matrix ([below](#what-must-the-builds-prove-row-by-row)) whose every row is a check in the section that builds that notice.

## What did the AutoIt suite have, and where does each part go?

Every line printed from the file.

| AutoIt part | Source | Verdict |
| --- | --- | --- |
| Single instance: a system-modal box, "Another occurence of ... is already running", closing itself after a timeout, then the new process ended | `resolute_au3/SDK/Concrete/ReBar/ReBar.au3:433-437`; `en.lng:122` | Changed. A second start brings the first forward and says nothing; a notice shows only when that cannot be done. The typo is fixed. |
| At exit, a process with the tool's file name was looked up and closed | `ReBar.au3:966-972` | A defect, cut. `_TerminateProgram` closed whatever process `ProcessExists(@ScriptName)` returned, which need not be the one exiting. A tool ends itself and nothing else. |
| Incompatibility: Windows 2000, XP Embedded and Server 2003 refused, with a Yes or No question opening the support page | `ReBar.au3:440-450`; `en.lng:123` | Changed. The check is against the Windows the tool declares, the text names both versions, and the button names its action. "compatable" and "windows" are fixed. |
| A 32-bit tool on 64-bit Windows started its 64-bit twin, or asked to download it | `ReBar.au3:452-470`; `en.lng:124` | Cut. x86-64 is the only architecture (`D00 T01 §1`), so the notice can never show. `Compatible_Bit` goes, and its "Unfortuantely" with it. |
| Message boxes on top of everything, closing by themselves | `ReBar.au3:434`, `:441`, `:461` | Cut, as [`standard-window.md`](standard-window.md#how-does-every-notice-reach-the-user) rules for every message. |
| Shutdown: settings saved, with no check that they were | `ReBar.au3:943-950` | Changed. A save that fails at closing is said, with a way to try again and a way back ([below](#what-if-settings-cannot-be-saved-at-closing)). |
| Shutdown: the Donate dialog raised on the way out | `ReBar.au3:952-956` | `D01 T03 §7`'s to rule on. |
| Registry failures: an error line, then a second line beginning with a caret giving one of six reasons | `resolute_au3/SDK/Includes/Registry.au3:81-101`, `:131-157`; `en.lng:150-156` | Changed into one line each, naming action, target and reason ([below](#what-does-a-registry-failure-say-in-the-log)). The caret was a marker for the list's icon search (`resolute_au3/SDK/Includes/Logging.au3:143`), which is cut. The reasons named neither the key nor the cause. |
| The launcher's launch lines: up to six lines per start, the last two a joke | `resolute_au3/SDK/Concrete/Resolute/Resolute.au3:1571-1605`; `resolute_au3/SDK/Concrete/Resolute/Includes/Localization.au3:98-106` | Changed into one line per launch ([below](#what-does-the-launcher-log-for-a-launch)). |
| An elevation refusal | None | New. All fourteen AutoIt tools carry `#RequireAdmin` (counted in `resolute_au3/SDK/Concrete/`), so each asked at startup and never again; none could refuse an action. |
| A crash notice | None | New. `ReBar.au3` registers one exit handler (`:476`) and nothing for a fault; a tool that failed mid-repair left no word and no record. |

## What does a refused action say?

A tool checks for administrator rights at the action that needs them (`D01 T01 §6`). When they are missing the action does not start, nothing is changed, and this notice says so.

| Part | Value |
| --- | --- |
| Severity | Warning |
| Summary | `Refuse_Title` ("%1 needs administrator rights"), %1 the action's own name, as its button or menu item has it |
| Body | `Refuse_Body` ("Nothing was changed. %{Program.Name} is running without administrator rights."), then `Refuse_Body_Restart` ("To do this, restart it as administrator. %{Program.Name} closes and opens again, and Windows asks for permission.") |
| Buttons | `Button_Restart_Admin` (`&Restart as administrator`), the default; `Button_Cancel` |
| Never | A bare "Access denied", a code alone, or a refusal after part of the action has run |
| Logged | Once per refusal: `Refuse_Log` ("%1 was not started: it needs administrator rights."), at the warning level |

- **Cancel**, Esc and the caption's close button return to the tool, which stays usable for everything that does not need the rights.
- **Restart as administrator** is the framework's restart ([`language-page.md`](language-page.md#what-happens-after-a-language-is-saved), `D01 T01 §10`), asked for elevated: the second instance is started first, and this one closes only when it has answered. It follows that restart's rules: disabled with `Label_Restart_Busy` while the tool's own action runs, and through the shell's way out when Preferences has unsaved edits. The restarted tool opens as it normally does. It does not run the refused action: the user presses it again, now with the rights.

Three things can follow the press:

| Outcome | What the user sees |
| --- | --- |
| The user agrees to the Windows prompt and the second instance answers | The tool closes and the elevated one is there; the status bar reads Administrator |
| The user declines the Windows prompt | **Not an error.** The tool is exactly as it was. The state segment reads `Refuse_Declined` ("Administrator rights were not given. Nothing was changed."), one log line says the same at the information level, and no further message is raised: the user has just answered a question and does not need to be told their answer |
| Windows refuses (the account cannot be given the rights, a policy forbids it), or the second instance does not answer within 10 seconds of starting | Error: `Refuse_Restart_Failed_Title` ("%{Program.Name} could not restart as administrator"), body `Refuse_Restart_Failed_Body` ("%1. Nothing was changed, and %{Program.Name} is still open."), with Close. %1 is the Windows reason when Windows refused, and `Restart_Failed_Timeout` ("it did not answer within 10 seconds"), the Language page's text, when the second instance did not answer; that instance is then ended. The 10 seconds run from the moment Windows starts the second instance, never while its permission prompt is showing |

A tool whose manifest asks for administrator rights at startup never shows this notice; whether a tool does is `D01 T01 §6`'s decision.

## What does a crash say?

A tool that faults does not vanish. The framework's handler (`D01 T01 §10`) flushes the restore record of a repair in progress, writes a report, and a notice says what happened to the computer.

**Who shows it.** A process that has just faulted cannot be trusted to draw a window. It does three small things (flush, write, start), then ends: it starts a new instance of its own executable with a hand-over naming the report, and that instance shows the notice and nothing else. It has no main window ([below](#what-about-a-notice-with-no-window-behind-it)).

| Part | Value |
| --- | --- |
| Severity | Error |
| Summary | `Crash_Title` ("%{Program.Name} stopped working") |
| Body, first | What the computer holds: one of the four cases below. This comes before anything about the tool |
| Body, second | `Crash_Doing` ("It was doing: %1."), %1 the action's name, or `Crash_Doing_Nothing` ("It was not in the middle of anything.") |
| Body, third | `Crash_Report` ("A report was saved to %1. It stays on this computer."), %1 the report's path in monospace, selectable |
| Buttons | `Button_Crash_Restart` (`&Restart %{Program.Name}`), the default; `Button_Crash_Folder` (`&Open report folder`); `Button_Close` |

**The four cases**, chosen by what the repair contract knows (`D02 T01 §4`), never by guessing:

| Case | Text | When |
| --- | --- | --- |
| Nothing was being changed | `Crash_Changed_None` ("Nothing on this computer was being changed.") | No action was running, or the action running makes no change |
| Changed, recorded, and all of it can be undone | `Crash_Changed_Undo` ("%1 was part way through. Everything it had changed is recorded and can be undone: restart %{Program.Name} and choose Undo.") | A repair was running and every item it had changed has its prior state in the restore record |
| Changed, recorded, and some of it cannot be undone | `Crash_Changed_Partial` ("%1 was part way through. What it had changed is recorded, but %2 of those changes cannot be undone:"), then each such item on its own line, by the name the repair shows for it, then `Crash_Changed_Partial_Next` ("The rest can be undone: restart %{Program.Name} and choose Undo. Run the repair again to finish it.") | The record holds an item the contract marks irreversible. At most ten are listed, then `Crash_Changed_More` ("and %1 more, listed in the report") when a report was written, or `Crash_Changed_More_Record` ("and %1 more, listed in the repair's record") when it was not: the record exists in this case, and the restarted tool opens on it |
| Changed, and the record could not be written | `Crash_Changed_Unrecorded` ("%1 was part way through, and what it had changed could not be recorded. Run the repair again to finish it."), then where its last steps can be read: `Crash_Steps_Report` ("The report lists the last steps it logged.") when a report was written, `Crash_Steps_Log` ("Its last steps are in the log: %1"), the log file's path in monospace, when no report was written and the log writer was recording when the tool stopped; and `Crash_Steps_None` ("There is no record of the steps it completed, because logging was off or could not write.") when there is neither. A place is named only when the framework knows something was written there | The flush failed. Said plainly: this is the case that matters most. The notice never points to a report that does not exist |

**At the next start** the same four cases apply, in words for a tool that is already running and has opened on the interrupted run's record (`D02 T01 §4`): `Crash_Changed_Undo_Now` ("%1 was part way through when %{Program.Name} last stopped. Everything it had changed is recorded and can be undone: its record is open now, so choose Undo.") and `Crash_Changed_Partial_Now` (the partial case's first line and list, then "The rest can be undone: its record is open now, so choose Undo. Run the repair again to finish it."). The other two cases read as they do above, since neither mentions a restart. Recovery takes no further restart.

- **Restart** starts the tool as it is normally started: with its command line less any argument that asks for a one-time action (`D01 T01 §11`), as the Language page's restart does. It never repeats what the tool was doing when it stopped. A repair that was started from the command line is not run again; the tool opens, and the user decides. After a repair that changed something, the restarted tool opens on that run's record (`D02 T01 §4`), so Undo is one press away.
- **Open report folder** opens the folder in File Explorer with the report selected, at the user's level ([`update-notices.md`](update-notices.md#which-page-does-the-button-open)). The notice stays open. A folder that cannot be opened is `Crash_Folder_Failed`, below.
- **Close** ends the notice. Nothing restarts by itself.

### What is in the report?

A text file in the tool's log folder (`D01 T01 §3`), named `<short name>-crash-<date and time in UTC, yyyyMMdd-HHmmss>.txt`. The ten newest are kept and older ones are deleted when a new one is written.

| Field | Holds |
| --- | --- |
| Tool | Name, version, channel, the executable's path |
| Windows | Version and build, and whether the tool was running as administrator |
| When | Date and time, in UTC |
| Doing | The action in progress, by name, or none |
| Fault | The exception's code, and the module and offset where it was raised |
| Changes | Which of the four cases applies, the restore record's path when there is one, and every item that cannot be undone |
| Log | The last 50 lines of the tool's log |

**It never holds** the contents of a file, a registry value or a document, an environment variable, or anything the log does not already hold. **It is never sent anywhere:** the tool has no upload, and the notice says the report stays on the computer.

### What if the notice or the report cannot be made?

| Failure | Result |
| --- | --- |
| The report cannot be written (a full disk, a folder that refuses) | The notice is still shown, from what the hand-over carries. Its third line is `Crash_Report_Failed` ("A report could not be saved: %1"), and Open report folder is not offered |
| Neither the record nor the report can be written (one full disk causes both) | One consistent body: `Crash_Changed_Unrecorded`, then `Crash_Steps_Log` with the log's path when the log writer was recording, or `Crash_Steps_None` when logging was off or could not write, then `Crash_Report_Failed`. No line mentions a report as something to read, and Open report folder is not offered. A step's log line is written as the step is done (`D01 T01 §3`), so a log that was recording holds them; one that was not is never pointed to |
| The second instance cannot be started | Nothing can be shown then. At its next ordinary start the tool finds a report newer than `CrashNoticeShown` in its settings and shows the notice once the main window is up, with the summary `Crash_Title_Last` ("%{Program.Name} stopped working the last time it ran") and without Restart, since it is running. Its recovery lines are the next-start ones below, which ask for no restart |
| Restart fails | Error, with the summary `Restart_Failed_Title` ("%{Program.Name} could not restart"), the Language page's, and a body of its own, `Crash_Restart_Failed_Body` ("Windows could not start %1: %2."), %1 the executable's path in monospace and %2 the Windows reason, with Close. It says nothing about a language, which the Language page's body does. The crash notice stays open |
| The report folder cannot be opened | Error `Crash_Folder_Failed` ("The report folder could not be opened."), naming the folder's path, selectable, as File, Open log folder's failure does ([`standard-window.md`](standard-window.md#what-is-on-the-file-menu)). The crash notice stays open |
| `CrashNoticeShown` cannot be written | Logged. The notice is shown again at the next start, which errs towards telling |

## What happens when the tool is started twice?

A tool runs once per installation (`D01 T01 §10`, which also decides the portable exception).

**Usually nothing is said.** The second start finds the first, restores its window if it is minimized, brings it forward, and ends. The user sees the tool they asked for.

A notice shows only when the first cannot be brought forward, and it never offers to end the other instance: that is the user's to decide, in Task Manager, knowing what it may be in the middle of.

| Case | Notice |
| --- | --- |
| The first instance does not answer within 2 seconds | Information: `Singleton` ("%{Program.Name} is already running."), body `Singleton_Busy` ("It is not answering, so it could not be brought to the front. It may be working: look for it on the taskbar."), Close |
| The first instance belongs to another user's session | Information: `Singleton`, body `Singleton_Other_Session` ("It is running in another user's session on this computer, and only one copy can run at a time."), Close |

Each writes one log line. The second process then ends with the exit code `D01 T01 §11` gives a start that was not needed.

## What if Windows is too old?

Each tool declares the oldest Windows it supports (`D01 T01 §1`). Started on an older one, it shows this notice in place of its window and then ends.

| Part | Value |
| --- | --- |
| Severity | Error |
| Summary | `Compatible` ("%{Program.Name} needs %1 or later"), %1 the Windows the tool declares |
| Body | `Compatible_Body` ("This computer runs %1, so %{Program.Name} cannot start."), then `Update_Opens_Site`, the update notices' line naming the site the button opens |
| Buttons | `Button_Compatible_Support` (`&Open support page`); `Button_Close`, the default |

The support page is the framework's own constant, the one Help, Support opens ([`standard-window.md`](standard-window.md#what-is-on-the-help-menu)), opened at the user's level; a page that cannot be opened is `Link_Open_Failed` with its copyable link. Either button, Esc or the caption's close button ends the tool. Nothing is written to the system, and one line is written to the log when the log folder can be reached.

## What if settings cannot be saved at closing?

Closing persists what the tool keeps between runs (`D01 T01 §1`). When that write fails, the tool does not close silently and does not lose the choice for the user.

| Part | Value |
| --- | --- |
| Severity | Warning |
| Summary | `Shutdown_Save_Title` ("Your settings could not be saved") |
| Body | Which of two things happened, told apart as [`preferences.md`](preferences.md#what-does-save-do) tells them apart for Save. The write was refused: `Shutdown_Save_Body` ("%1 could not be written: %2. If you close now, %{Program.Name} forgets what it would have saved on closing, such as where its window was."). The write went through but could not be read back: `Shutdown_Save_Unconfirmed_Body` ("%1 was written but could not be checked: %2. It may already hold your settings."). In both, %1 is the settings file's path in monospace and %2 the Windows reason |
| Buttons | `Button_Try_Again` (`&Try again`), the default; `Button_Close_Anyway` (`Close &anyway`); `Button_Cancel` |

| Choice | Result |
| --- | --- |
| Try again | The write is made again and read back. When it succeeds the tool closes. When it fails the notice is shown again with the new reason |
| Close anyway | The tool closes and writes nothing more. After a refused write the settings file is as it was before closing began. After an unconfirmed one it is whatever the write left, which may be the new settings: the notice has said so, and nothing is promised |
| Cancel, Esc, the caption's close button | The tool stays open, exactly as it was, with everything it meant to save still in memory. Nothing is discarded by a key meant to back out |

- **During a restart** (the Language page's, or Restart as administrator) the first instance shows this notice before it exits. Cancel ends the restart too: the second instance, which is waiting for the first to exit, is ended, and the tool stays as it was. Close anyway lets the restart go on.
- **When Windows is ending the session** (sign-out, shutdown, restart) no notice can be answered. The write is tried once; a failure goes to the log; the tool never delays or blocks the session's end.
- Preferences are not at risk here: they were written, and read back, when Save was pressed ([`preferences.md`](preferences.md#what-does-save-do)).

## What does a registry failure say in the log?

One line, at the error level, written by the tool's action through the log writer (`D01 T01 §3`, `D02 T01 §6`). The writer puts the level's prefix first, so the texts begin in lower case. Each names the action, the target and the reason; none needs a second line.

| Key | The line, after "Error: " | When |
| --- | --- | --- |
| `Registry_Write_Error` | could not write the value %2 in %1: %3 | Setting a value fails |
| `Registry_Error_01` | could not open the key %1: %2 | A key cannot be opened or created |
| `Registry_Error_02` | the part of the registry that holds %1 is not available: %2 | The root of the path cannot be reached: a user's hive that is not loaded, a remote registry |
| `Registry_Error_03` | could not read the value %2 in %1: %3 | Reading a value fails, the value being absent included |
| `Registry_Error_04` | the value %2 in %1 is of a type this action does not handle (%3) | The value's type is not one the action reads or writes; %3 is the type's name |
| `Registry_Error_05` | could not delete the value %2 from %1: %3 | Deleting a value fails |
| `Registry_Error_06` | could not delete the key %1: %2 | Deleting a key fails |

- **The target** is the key's full path from its root (`HKEY_LOCAL_MACHINE\...`) and the value's name, with `(Default)` for the unnamed value, exactly as they would be typed.
- **The reason** is Windows' own message for the failure, in words, followed by its code in brackets. When the reason is that access was denied, the line ends with what was needed: `Registry_Need_Admin` ("This needs administrator rights.") when the tool is not running as administrator, and `Registry_Need_Owner` ("The key's permissions do not allow it, even for an administrator.") when it is.
- **What was written is never in the line.** The AutoIt line carried the value's data (`Registry.au3:94`); a log is copied into forums and support mail, and the data may be the user's.
- **Frozen behaviour is untouched.** This changes what a failure is called in the log. What a tool computes and writes to the registry, and when it gives up, are its own and stay as they are.

## What does the launcher log for a launch?

One line per launch, naming the tool (`D03 T01 §3`). What the launcher shows on its surface when a launch fails is `D03 T02 §7`'s; these are the lines in its log.

| Key | The line | Level | Verdict |
| --- | --- | --- | --- |
| `ExecuteTool_07` | %1 started (process %2). | Success | Reworded from "Success: %s should now be running. The process ID is: %s." |
| `ExecuteTool_06` | %1 could not be started from %2: %3 | Error | Reworded from "ShellExecute failed with error code: %s.": %2 the path, %3 Windows' reason in words with its code in brackets |
| `ExecuteTool_08` | %1: the executable is missing from its expected location (%2). | Error | Reworded from "The elusive executable file has gone AWOL from its expected location (%s)." A user whose tool vanished needs a path, not a joke. It gains the tool's name, so that the one line names the tool |
| `ExecuteTool_09` | | | Cut: "^ Sound the alarms and initiate a search party immediately!" |
| `ExecuteTool_01`, `ExecuteTool_04`, `ExecuteTool_05` | | | Cut: "Starting", "Searching for" and "Executing" narrated a start that now takes one line |
| `ExecuteTool_02`, `ExecuteTool_03` | | | Cut with `Compatible_Bit`: "Detecting Windows architecture" has one answer |

## What happens when nobody is watching?

A tool run unattended from a script (`D01 T01 §11`) has no window and must never wait for a button. **No notice on this page is shown in an unattended run.** Each has an unattended form: a line in the log, the same fact in the run's transcript, and an exit code a script can branch on. The texts are the notices' own, so the log reads the same either way.

| Notice | In an unattended run |
| --- | --- |
| A refused action | Nothing is shown and no restart is offered or made. `Refuse_Log` goes to the log and the transcript, nothing is changed, and the run ends with the refused-for-privilege code |
| A crash | The record is flushed and the report written as always. No second instance is started and no notice is shown. The process ends with the failed code, and the report's path is the last line of the transcript when it can still be written. The next attended start shows the notice with `Crash_Title_Last` |
| A second start | Nothing is shown. One log line, and the run ends with the code `D01 T01 §11` gives a run that could not start because the tool is already running; the first instance is not brought forward |
| Too old a Windows | Nothing is shown. `Compatible` and `Compatible_Body` go to the log and the transcript as one line, and the run ends with the failed code |
| Settings that cannot be saved at closing | Nothing is shown. The write is tried once; a failure goes to the log and the transcript (`Shutdown_Save_Body` or `Shutdown_Save_Unconfirmed_Body`); the process ends at once. The run's exit code stays the one its action earned: failing to save a window's place does not turn a successful repair into a failed one |

The registry lines and the launch lines are log lines already and are written the same in both.

## What about a notice with no window behind it?

Three notices can show when the tool has no main window: the crash notice from its fresh instance, the single-instance notice, and the incompatibility notice. The message layer's rules hold, with what a missing owner changes stated:

| Part | Rule |
| --- | --- |
| Title | The tool's name, as always |
| Place | Centred on the work area of the monitor the pointer is on |
| Taskbar | The notice has its own taskbar button with the tool's icon, since there is no window for it to belong to |
| On top | Never topmost. It comes to the front when it opens, as a newly started program does |
| Language | The stored language when its pack can be read, else English, as the tool itself would start |
| When it closes | The process ends |

## Which keys, announcements and sizes apply?

The message layer's, with nothing added ([`standard-window.md`](standard-window.md#how-does-every-notice-reach-the-user)): Enter presses the default, Esc presses Cancel or Close, each button answers its access key, Ctrl+C and the copy button copy the whole notice, the summary is announced when the notice opens, focus returns to where it was, and every message writes its log line with the button chosen. A long summary wraps. A list inside a body (the items that cannot be undone) scrolls with the body and is copied with it.

## Which strings do the notices use?

In `[Messages]` unless marked.

| Key | English | Verdict |
| --- | --- | --- |
| `Singleton` | %{Program.Name} is already running. | Reworded (`en.lng:122`): "Another occurence of" |
| `Singleton_Busy`, `Singleton_Other_Session` | As the single-instance table gives them | New |
| `Compatible` | %{Program.Name} needs %1 or later | Reworded (`en.lng:123`) |
| `Compatible_Body` | This computer runs %1, so %{Program.Name} cannot start. | New |
| `Button_Compatible_Support` | `&Open support page` | New |
| `Compatible_Bit` | | Cut (`en.lng:124`). For `D01 T03 §7`'s audit |
| `Refuse_Title`, `Refuse_Body`, `Refuse_Body_Restart`, `Refuse_Declined`, `Refuse_Log` | As the refusal gives them | New |
| `Button_Restart_Admin` | `&Restart as administrator` | New |
| `Refuse_Restart_Failed_Title`, `Refuse_Restart_Failed_Body` | As the outcomes table gives them | New |
| `Crash_Title`, `Crash_Title_Last`, `Crash_Doing`, `Crash_Doing_Nothing`, `Crash_Report`, `Crash_Report_Failed` | As the crash notice gives them | New |
| `Crash_Changed_None`, `Crash_Changed_Undo`, `Crash_Changed_Partial`, `Crash_Changed_Partial_Next`, `Crash_Changed_More`, `Crash_Changed_Unrecorded` | As the four cases give them | New |
| `Crash_Changed_Undo_Now`, `Crash_Changed_Partial_Now`, `Crash_Changed_More_Record`, `Crash_Steps_Report`, `Crash_Steps_Log`, `Crash_Steps_None` | As the crash notice gives them | New |
| `Button_Crash_Restart` | `&Restart %{Program.Name}` | New |
| `Button_Crash_Folder` | `&Open report folder` | New |
| `Crash_Restart_Failed_Body` | Windows could not start %1: %2. | New |
| `Crash_Folder_Failed` | The report folder could not be opened. | New |
| `Shutdown_Save_Title`, `Shutdown_Save_Body`, `Shutdown_Save_Unconfirmed_Body` | As the shutdown notice gives them | New |
| `Button_Try_Again` | `&Try again` | New |
| `Button_Close_Anyway` | `Close &anyway` | New |
| `Registry_Write_Error`, `Registry_Error_01` to `Registry_Error_06` | As the registry table gives them | Reworded (`en.lng:150-156`), every one |
| `Registry_Need_Admin`, `Registry_Need_Owner` | This needs administrator rights. The key's permissions do not allow it, even for an administrator. | New |
| `ExecuteTool_06`, `ExecuteTool_07`, `ExecuteTool_08`, in the launcher's `[Messages2]` | As the launch table gives them | Reworded |
| `ExecuteTool_01` to `ExecuteTool_05`, `ExecuteTool_09`, in the launcher's `[Messages2]` | | Cut. For `D01 T03 §7`'s audit |
| `Button_Cancel`, `Button_Close`; `Label_Restart_Busy`; `Restart_Failed_Title`, `Restart_Failed_Timeout`; `Update_Opens_Site`; `Link_Open_Failed` | As the pages that own them give them | Used as they are |

## What must the builds prove, row by row?

Every row is one behavioural check in the section named in its last column, which carries the item that runs its rows.

| Element | Trigger | States | Result | Failure | Check |
| --- | --- | --- | --- | --- | --- |
| A refused action | Without administrator rights, start an action that needs them | Not elevated | The notice names the action in its summary and says nothing was changed; the action's target is unchanged, compared; `Refuse_Log` once in the log | The stated result is the refusal's presentation | `D01 T01 §6`: `refusal: an action is refused by name before anything changes` |
| Cancel on the refusal | Cancel; Esc; the caption's close button | | The tool is usable; an action that needs no rights still runs | None can occur: cancelling does nothing | `D01 T01 §6`: `refusal: cancel leaves the tool usable` |
| Restart as administrator, agreed | Press it; agree to the prompt | | One instance afterwards, elevated, started before the first exited; the status bar reads Administrator; the refused action has not run | The row two below | `D01 T01 §6`: `refusal: restart as administrator hands over` |
| Restart as administrator, declined | Press it; decline the prompt | | No message; the tool as it was; `Refuse_Declined` in the state segment and once in the log at the information level | None can occur: a declined prompt is an answer | `D01 T01 §6`: `refusal: declining windows is not an error` |
| Restart as administrator, failing | Seed a start Windows refuses; then a second instance that never answers, with its prompt left showing for 20 seconds first | Refused; unanswered | `Refuse_Restart_Failed_Title`; the body carries the Windows reason for the refused start and `Restart_Failed_Timeout` by name for the unanswered one, whose second instance is ended; the tool still open and not elevated; the time limit did not run during the prompt | The stated result is the failure presentation | `D01 T01 §6`: `refusal: a failed restart leaves the tool open` |
| Restart while busy or with unsaved edits | Raise the refusal while the tool's action runs; and with Preferences open and dirty | | The button is disabled with `Label_Restart_Busy`; with unsaved edits the shell's prompt comes first and Cancel stops the restart | Save failing: no restart, as the shell rules | `D01 T01 §6`: `refusal: the restart follows the framework's rules` |
| A crash with nothing changing | Fault a fixture tool while idle | | A notice from a fresh instance, not the Windows crash dialog: `Crash_Changed_None`, `Crash_Doing_Nothing`, the report's path | The rows below | `D01 T01 §10`: `crash: an idle crash says nothing was changed` |
| A crash mid-repair, all of it undoable | Fault a fixture repair after two reversible items | | `Crash_Changed_Undo` naming the repair; the record covers both items; Restart opens the tool on that record and Undo restores the fixture, compared value by value | The record cannot be flushed: the unrecorded row | `D01 T01 §10`: `crash: an interrupted repair can be undone` |
| A crash mid-repair with an irreversible item | Fault a fixture repair after one reversible and one irreversible item | | `Crash_Changed_Partial` counting 1, the irreversible item listed by name, then what to do next; Undo after restart restores the reversible item only, and says so | The stated result is the honest presentation | `D01 T01 §10`: `crash: a change that cannot be undone is named` |
| A crash whose record could not be written | Fault a fixture repair with the record's folder refusing writes | | `Crash_Changed_Unrecorded` with `Crash_Steps_Report`; the report lists the last logged steps | The stated result is the failure presentation | `D01 T01 §10`: `crash: an unrecorded change is said plainly` |
| A crash that could write neither record nor report | Fault a fixture repair with both the record's folder and the report's refusing writes | | `Crash_Changed_Unrecorded`, `Crash_Steps_Log` naming the log's path, and `Crash_Report_Failed`; no line promises a report; no Open report folder; the log holds the steps the repair completed | The stated result is the failure presentation | `D01 T01 §10`: `crash: nothing is promised that was not written` |
| A crash with nothing written anywhere | The same, with logging turned off; and with the log folder refusing writes | Logging off; log not writing | `Crash_Steps_None` in place of `Crash_Steps_Log`; no path is named | The stated result is the failure presentation | `D01 T01 §10`: `crash: a missing log is not pointed to` |
| More irreversible items than fit, with no report | Fault a fixture repair after eleven irreversible items, the record written and the report refused | | Ten items listed, then `Crash_Changed_More_Record` counting 1; `Crash_Report_Failed`; no line refers to a report as readable | The stated result is the failure presentation | `D01 T01 §10`: `crash: an overflow points to the record when there is no report` |
| The report | Read the file a crash wrote | | Its name follows the rule; every field in the table is present; no file, registry or environment contents; an eleventh report deletes the oldest | The report cannot be written: `Crash_Report_Failed` in the notice, no Open report folder | `D01 T01 §10`: `crash: the report holds its fields and nothing else` |
| Restart after a crash | Start the tool with a command line that runs a repair; fault it; press Restart | | The tool opens with its window and the repair is not run again, checked against the fixture | Restart failing: `Restart_Failed_Title` with `Crash_Restart_Failed_Body`, which names the path and reason and no language; the notice still open | `D01 T01 §10`: `crash: restart never repeats the action` |
| Open report folder | Press it from an elevated crash | | Explorer opens the folder with the report selected, not elevated; the notice stays | Explorer cannot be started (seeded): `Crash_Folder_Failed` with the folder's path, selectable; the notice still open | `D01 T01 §10`: `crash: the report folder opens at the user's level` |
| No notice could be shown | Seed the second instance failing to start after a fixture repair faulted past a reversible item; then start the tool normally; then again | | The first start shows the notice with `Crash_Title_Last` and no Restart, after the main window; its recovery line is `Crash_Changed_Undo_Now`, with no word about restarting; the interrupted run's record is the one showing, and Undo restores the fixture with no further restart; `CrashNoticeShown` reads back; the second start shows nothing | The key cannot be written (seeded): shown again at the next start | `D01 T01 §10`: `crash: an unshown crash is told at the next start` |
| A second start | Start the tool twice; with the first minimized | | The first is restored and in front; the second ends with no notice | The rows below | `D01 T01 §10`: `singleton: a second start brings the first forward` |
| A first instance that does not answer | Start again with the first made to hang | | After 2 seconds `Singleton` with `Singleton_Busy`; no offer to end it; the first is untouched | The stated result is the failure presentation | `D01 T01 §10`: `singleton: a hung first instance is left alone` |
| A first instance in another session | Start in a second user's session | | `Singleton` with `Singleton_Other_Session` | The stated result is the failure presentation | `D01 T01 §10`: `singleton: another session's copy is named` |
| Too old a Windows | Start with the reported Windows version seeded below the declared one | | The notice in place of the window, naming both versions and the site; either button ends the tool; nothing written to the system | The support page cannot be opened: `Link_Open_Failed` | `D01 T01 §10`: `startup: an unsupported windows is named and the tool ends` |
| A notice with no window | Each of the three windowless notices | | Centred on the pointer's monitor; its own taskbar button; not topmost; in the stored language | A stored language that cannot be read: English | `D01 T01 §10`: `notices: a windowless notice has a taskbar button` |
| Shutdown, saved on retry | Close with the settings file locked; unlock; Try again | | The notice names the path and reason; after Try again the file reads back with the closing values and the tool has closed | The row below | `D01 T01 §10`: `shutdown: try again saves and closes` |
| Shutdown, still failing | Try again with the file still locked | | The notice again, with the reason | The stated result is the failure presentation | `D01 T01 §10`: `shutdown: a second failure is said again` |
| Shutdown, closed anyway after a refused write | Close with the settings file locked; Close anyway | Refused | The body is `Shutdown_Save_Body`; the tool closes; the file is byte for byte as before closing began | None can occur: nothing more is written | `D01 T01 §10`: `shutdown: close anyway leaves a refused file as it was` |
| Shutdown, a write that cannot be confirmed | Move the window; close with the write let through and the read-back made to fail (seeded); Close anyway; start again | Unconfirmed | The body is `Shutdown_Save_Unconfirmed_Body`, which does not claim the file is unchanged; after the restart the tool uses what the file holds, here the new placement | Try again with the read-back still failing: the notice again | `D01 T01 §10`: `shutdown: an unconfirmed save promises nothing` |
| Shutdown, cancelled | Cancel; Esc; the caption's close button; and Cancel during a Language restart | | The tool is open and unchanged; in the restart case the second instance is ended and one instance remains | None can occur: cancelling changes nothing | `D01 T01 §10`: `shutdown: cancel keeps the tool and ends a restart` |
| Windows ending the session | Send the session-end messages with the file locked | | No notice; one attempt; one log line; the process does not delay the end | The stated result is the failure presentation | `D01 T01 §10`: `shutdown: a session end is never blocked` |
| Unattended: a refused action | Run the fixture repair unattended without administrator rights | | No window at any moment; `Refuse_Log` in the log and the transcript; the refused-for-privilege code; the fixture unchanged | None can occur: an unattended run shows nothing | `D01 T01 §11`: `unattended: a refusal returns its code and shows nothing` |
| Unattended: a crash | Fault the fixture repair in an unattended run; then start the tool attended | | No window and no second instance; the report and the record written; the failed code; the attended start shows `Crash_Title_Last` | The report cannot be written: the failed code still, and the log says why | `D01 T01 §11`: `unattended: a crash writes its report and returns` |
| Unattended: settings that cannot be saved | Run the fixture repair unattended to success with the settings file locked | | No window; one attempt; the failure in the log and the transcript; the success code | None can occur: the run never waits | `D01 T01 §11`: `unattended: a failed save does not change the result` |
| Unattended: a second start, and too old a Windows | Run unattended with the tool already running; and with the Windows version seeded too low | Each | No window; one line each; the documented code each; the first instance not brought forward | None can occur: an unattended run shows nothing | `D01 T01 §11`: `unattended: startup refusals return codes` |
| Registry lines | Drive each of the seven failures against fixture keys: a denied write, a denied open, an unloaded hive, an absent value, an unhandled type, a denied value delete, a denied key delete | Each; elevated and not | One error line each, with the key's full path, the value's name, Windows' reason in words and its code; `Registry_Need_Admin` or `Registry_Need_Owner` on a denial; no second line; no value data | None can occur: every failure has its line | `D02 T01 §6`: `registry: a failure names action, target and reason in one line` |
| Launch lines | Launch a fixture tool; one whose start is refused; one whose executable is missing | Each | One line each naming the tool: the process id; the path and Windows' reason; the path | None can occur: every launch ends in one of the three | `D03 T01 §3`: `launch: one line per launch names the tool` |
