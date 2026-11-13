# The log surface

Every Resolute tool has one log surface, owned by the framework: a window that shows what the tool wrote to its log file, as it writes it. This page specifies it control by control, so that `D01 T01 §7` can build it and `D01 T01 §3` can feed it without inventing a control. It is `D01 T03 §4` (`todo/01-framework/TODO-03-framework-surfaces.md`).

A user watches what a tool is doing to their machine, goes back to the line that went wrong, and copies it to search for. So the surface shows the file itself, never a summary of it, marks each line with its level by a rule that cannot guess, lets the user stop the view scrolling away from what they are reading, and copies a line exactly as the file holds it.

The surface is reached from File, Logging, Open log file and from the status bar's state segment, both specified in [`standard-window.md`](standard-window.md), and it shares Clear log with the General page in [`preferences.md`](preferences.md). Its list is the framework's virtualized list (`D01 T02 §3`). Sizes are base values at 96 DPI. A specification cannot prove behaviour, so the page ends in a matrix ([below](#what-must-the-build-prove-row-by-row)) whose every row is a check `D01 T01 §7` runs.

## What does the AutoIt list have, and where does each part go?

Read from `resolute_au3/SDK/Concrete/ReBar/ReBar.au3` and `resolute_au3/SDK/Includes/Logging.au3`, every line printed from the file.

| AutoIt part | Source | Verdict |
| --- | --- | --- |
| Status list: one column, docked at the bottom of every tool window, Courier New | `ReBar.au3:579-587` | Changed. The list becomes this surface, a window of its own that can stay open beside the tool, and the status bar shows the latest line ([`standard-window.md`](standard-window.md)). Monospace stays (`DESIGN.md` §4). |
| Seven line icons: information, complete, cross, exclamation, a smiley, a skull, a snowman | `ReBar.au3:270`, `:742-748` | Changed to five statuses with themed icons ([below](#which-levels-does-a-line-have)). The skull and the snowman are cut. |
| `_Logging_EditWrite`: splits a message into lines, skips blank ones, adds each to the list and to the file | `Logging.au3:76-126` | Kept as the writer's job (`D01 T01 §3`): one line per action, to the file, with the surface told of it. |
| The list always jumps to the newest line | `Logging.au3:107-108` | A defect, fixed. A user reading an earlier line while the tool worked had it scrolled away at every new line. Following can be paused ([below](#how-does-the-view-follow-new-lines)). |
| A time stamp built for the list and never shown | `Logging.au3:81`, `:89`, `:100` | Cut. The value was computed and the list item was written without it. The surface shows the line as the file holds it, time stamp included. |
| A sub-item and a custom image index, the fourth and fifth parameters | `Logging.au3:76`, `:99`, `:103` | Cut. No caller passes either ([below](#can-a-caller-choose-an-icon)). |
| `_DetermineLogImage`: the icon chosen by searching the line's text for words | `Logging.au3:130-165`, `:488-560` | Cut ([below](#why-is-the-level-never-guessed-from-the-text)). |
| The error count, raised whenever a line's text looked like an error | `Logging.au3:150` | Changed. The count behind the closing line (`:186-189`) comes from the lines written at the error level (`D01 T01 §3`). |
| The Critical skull, reached only by finding "Critical:" or "FOUND" in a line | `Logging.au3:151-152`, `:549-560` | Cut with the search. No level asks for it: `_Logging_SetLevel` has no such case (`:284-299`). |
| The December snowman: a finished line got a snowman icon in month 12 | `Logging.au3:153-159` | Cut. A tool repairing someone's machine does not change its icons by the calendar. |
| `__Logging_ValidateRegistry` | `Logging.au3:504-515` | Cut. Defined and never called (counted: no call in `resolute_au3/` outside `samples/`). |
| `_Logging_SetLevel`: plain, ERROR, WARNING, SUCCESS, FINISHED, each a prefix from the pack | `Logging.au3:284-299`; `SDK/Includes/Localization.au3:158-161` | Kept as the five levels. Two callers passed `1` as the level (`:251`, `:258`), which matches no case, so the function returned nothing and the line written was not the message; a level is now a named value the compiler checks. |
| `_Logging_Start` empties the list and disables the File log items while an action runs | `Logging.au3:310-311` | Changed. The list showed only the current action while the file kept everything; the surface shows the file. The File items are never disabled for a running action. |
| `_Logging_End` and `_Logging_FinalMessage`: a closing line, and the sub-heading turned red or green | `Logging.au3:168-201` | Changed. The closing line stays a line at the finished or error level; the result reaches the user through the status bar's state segment ([`standard-window.md`](standard-window.md)), not a colour. |
| Open log file and open log folder handlers | `Logging.au3:245-281` | Kept: the folder as File, Logging, Open log folder ([`standard-window.md`](standard-window.md)), the file as "Open in default app" here. |
| `__Logging_Clear`: empties the list, leaves the file | `Logging.au3:351-357` | Changed. Clear log deletes the log files and says so ([`preferences.md`](preferences.md#what-does-clear-log-do)). |
| A log file that cannot be opened: writing stops silently | `Logging.au3:328-333` | A defect, fixed. The surface says logging cannot write, with the reason ([below](#what-if-nothing-new-is-being-recorded)). |
| Rotation: a file at its limit is deleted whole | `Logging.au3:460-474` | The writer's (`D01 T01 §3`). The surface follows a rotation and says it happened. |

## What is the surface?

A window of the framework's, titled `Log_Title` ("%{Program.Name} log"), with three regions.

| Part | Rule |
| --- | --- |
| One per tool | A second request (the menu item, or the status bar) brings the open one forward. It shows this tool's log and no other's. |
| Not modal | The tool's window stays usable. The surface is owned by it: it stays above the tool's window, is minimized with it, and closes with it. It has no taskbar button of its own. |
| Opens | At the newest line, following, with focus on the list. |
| Closes | Esc, the caption's close button, Ctrl+W. Esc with focus in a find box that holds text empties the box first; from anywhere else it closes the surface, whether or not a search is set. Closing changes nothing: logging goes on, and a filter or a paused view is not remembered. |
| Size and place | Default 760 x 480, centred on the tool's window; minimum 480 x 320; resizable. Remembered per monitor as the Preferences dialog's is ([`preferences.md`](preferences.md#what-does-the-shell-hold)): `LogPlacement`, holding left, top, width and height in base units relative to that monitor's work area, written through the settings writer (`D01 T01 §2`) when the surface closes, and when the tool closes with it open. It reopens there when the tool's window is on that monitor; otherwise, or when that monitor is gone, centred on the tool's window at the stored size; and always moved and resized to lie inside the current work area. A place that cannot be written does not stop the window closing: the failure goes to the log and the earlier place is used next time. |

| Region | Holds, left to right |
| --- | --- |
| Toolbar | Find box; level filter; Follow; Copy; Open in default app |
| List | The log's lines, one per row, in monospace, each with its level icon. Banners sit above the first row when one applies. |
| Footer | The line count; the log file's path, in monospace, selectable and copyable; the log's size (`Label_Logging_Size`, as on the General page); Clear log with its line |

The toolbar and the footer are single rows. Under 640 wide the toolbar's buttons show their icons alone, each keeping its name as tooltip and accessible name, and the footer's path ends in an ellipsis with the whole path in its tooltip and on the clipboard when copied.

## Which levels does a line have?

Five, the AutoIt five, each shown by an icon whose shape differs and by the line's own first word, never by colour alone (`DESIGN.md` §3).

| Level | AutoIt | Icon (Lucide) | The line's prefix, from the pack | Name for screen readers |
| --- | --- | --- | --- | --- |
| Information | plain | `info`, in the muted text colour | none | `Log_Level_Information` ("Information") |
| Success | `SUCCESS` | `circle-check` | `Level_Success` ("Success:") | `Log_Level_Success` ("Success") |
| Warning | `WARNING` | `triangle-alert` | `Level_Warning` ("Warning:") | `Log_Level_Warning` ("Warning") |
| Error | `ERROR` | `circle-x` | `Level_Error` ("Error:") | `Log_Level_Error` ("Error") |
| Finished | `FINISHED` | `flag` | `Level_Finished` ("Finished:") | `Log_Level_Finished` ("Finished") |

A line's text is drawn in the ordinary text colour at every level; only the icon takes the status colour (`DESIGN.md` §3), so a line stays readable and a level stays recognizable in high contrast.

**How a line's level is known:**

- **A line written while the surface is open** has the level the writer was given for it (`D01 T01 §3`). Nothing is worked out.
- **A line read from the file** has the level whose prefix its message starts with, after the time stamp: the prefix in the language the tool is showing, or the built-in English one. A line with neither is Information.
- **The limit, stated:** the file records a level only as that prefix, which is the AutoIt format the writer keeps. So a line written while the tool ran in a third language is read back as Information, with its text intact, and a plain message that itself begins with "Error:" is read back as an error, because that is what the file says. Neither is a guess: the rule looks at one fixed place for one of eight exact strings.
- **A level the surface does not know** (a future writer's, or a damaged value) is drawn as Information, never as a blank row.

### Why is the level never guessed from the text?

Because the AutoIt list did, and was wrong in both directions. `_DetermineLogImage` searched every line for words: "success", "OK!" or "Initiated" anywhere made it a success; "Access is denied" or "blocked" a warning; "error " or "failed" an error; "FOUND" a critical (`Logging.au3:488-560`). Success was tested first (`:137-139`), so a line reading "Error: the service was not successfully stopped" got the success tick. The same search raised the error count (`:150`), so the closing line's "2 errors" counted prose. The search is cut whole, with the lists of words: a level is what the writer was told, or the prefix the writer wrote.

### Can a caller choose an icon?

No. `_Logging_EditWrite` took a sub-item and an image index as its fourth and fifth parameters (`Logging.au3:76`), and nothing used them: of the 277 calls to it in `resolute_au3/` outside `samples/` and `todo/`, none passes a fourth or a fifth argument (counted by a script that splits each call's arguments at the top-level commas). Both are cut. The writer's call takes a level (`D01 T01 §3`) and nothing that picks an icon, so two tools cannot mark the same event differently.

### What else is drawn?

A line made only of hyphens, which the AutoIt writer put around each action (`Logging.au3:177`, `:317`), is drawn as a thin rule across the row. It is still a line: it can be selected, and it copies as its hyphens.

## How are lines selected and copied?

| Action | How | Result |
| --- | --- | --- |
| Select one line | Click; Up, Down, Home, End, Page Up, Page Down | That line is selected and focused. |
| Select several | Ctrl+click; Shift+click; Shift with the keys above; Ctrl+A for every line the list is showing | A range, or separate lines. |
| Copy | Ctrl+C; the Copy button (`Log_Copy`, `Cop&y`); Copy in the list's context menu (right-click, Shift+F10, the Menu key), beside Select all | The selected lines go to the clipboard in file order, each exactly as the file holds it, time stamp and prefix included, each ended by a carriage return and line feed. Nothing is trimmed, reflowed or translated. The footer reads `Log_Copied` ("%1 lines copied."), announced. |
| Copy with nothing selected | The button and the menu item are disabled, with `Log_Copy_None` ("Select the lines to copy.") as tooltip and help text | Ctrl+C does nothing. |
| A copy that fails | The clipboard is held by another program, or Windows refuses a copy that large | The footer reads `Log_Copy_Failed` ("The lines could not be copied: %1"), with the Windows reason; the selection stays, so it can be tried again. |

With a filter on, "every line the list is showing" is every line that passes it, and copy copies those.

## How does the view follow new lines?

`Log_Follow` (`&Follow`), a toggle in the toolbar, on when the surface opens.

- **Following:** each new line scrolls the list so the newest is in view. The selection does not move.
- **Paused by reading.** Anything that takes the view off the newest line pauses following: the wheel, the scroll bar, Page Up, Home, or Up from the last line. The toggle shows off. Nothing scrolls while paused, whatever the tool writes.
- **What arrived meanwhile:** the toggle carries a count, `Log_New_Lines` ("%1 new"), growing with each line written while paused.
- **Resumed** by the toggle (click, Space, Alt+F), by End, or by scrolling to the bottom. The view goes to the newest line and the count goes.
- **With a filter on,** following and the count apply to the lines that pass it.

## How is a line found?

Two controls narrow the list. Both apply together.

| Control | Rule |
| --- | --- |
| Find box, `Log_Find` (placeholder "Find in log"), Ctrl+F | The list shows only the lines that contain the typed text, compared without regard to case. The text is plain: no pattern characters. The list narrows 200 milliseconds after the last key. Esc in the box, or its clear button, empties it. |
| Level filter, a combo named `Log_Filter` ("Show") | `Log_Filter_All` ("All lines"), the default; `Log_Filter_Warnings` ("Warnings and errors"); `Log_Filter_Errors` ("Errors"). |

The footer's count reads `Log_Count` ("%1 lines"), or `Log_Count_Filtered` ("%1 of %2 lines") while either control narrows the list, announced when it settles. A search runs off the UI thread; while it runs the footer reads `Log_Finding` ("Finding...") and the window answers every key, and typing more starts the search again. When nothing matches, the list's place holds `Log_No_Match` ("No line matches.") with `Log_Show_All` (`Show &all lines`), which empties the box and sets the filter to all.

## What does Clear log do here?

Exactly what it does on the General page, through the same call (`D01 T01 §3`): [`preferences.md`](preferences.md#what-does-clear-log-do) is the specification, and this surface adds nothing to it. The button is `Button_Logging_Clear` (`&Clear log`) in the footer, with the same line beside it, `Label_Logging_Clear_Note`, which says before the press that the files are deleted now and cannot be brought back; it asks nothing. One of the same three results replaces the line and is announced: `Label_Logging_Cleared`, `Label_Logging_Nothing` or `Label_Logging_Partial`. Afterwards the list shows what is on disk, never what the clear was meant to do: the surface reads the current log file again. When the file was deleted, the list is empty, or, with logging on, holds the new file's first line, which records the clear. When the current file could not be deleted (the partly-cleared result names it), its lines are still in the list, because they are still in the file. A clear made from the General page while the surface is open does the same here.

## What does the surface show when there are no lines?

In the list's place, centred, each with its key:

| State | Text | Next step |
| --- | --- | --- |
| Nothing logged yet: logging is on and the writer has not written | `Log_Empty` ("Nothing has been logged yet. %{Program.Name} writes here as it works.") | None needed |
| Logging is off and there is no log | `Log_Off` ("Logging is turned off, so nothing is being recorded.") | `Log_Open_Preferences` (`Open &Preferences`), which opens the General page |
| No line matches | `Log_No_Match`, above | `Log_Show_All` |

## What if nothing new is being recorded?

A log with lines in it looks current. When it is not, a banner above the first row says so for as long as it is so, and the lines already in the file stay readable beneath it.

| State | Banner | Next step |
| --- | --- | --- |
| Logging is off | Information: `Log_Off` | `Log_Open_Preferences` |
| Logging is on but the writer cannot write (the disk is full, the folder refuses the write, the file is locked) | Warning: `Label_Logging_Not_Running` ("Logging is on but cannot write: %1"), the General page's key, with the path in monospace and the Windows reason, selectable and copyable | `Log_Try_Again` (`&Try again`), which asks the writer to try now |

The writer tells the surface when it stops being able to write and when it recovers (`D01 T01 §3`), so the banner appears while the surface is open, at the moment recording stops, and goes, announced as `Log_Recording_Again` ("Logging is working again."), when a write succeeds, whether by Try again or by the tool's next line. Try again that fails leaves the banner with the new reason.

## What if the log file is wrong?

Stated in the surface, where the user asked to look, never in a dialog. Every text is selectable and copyable.

| Failure | When | In the surface | Next step |
| --- | --- | --- | --- |
| Missing | The file the writer is using is not there: deleted or moved, before the surface opened or while it is open | The list empties and its place holds `Log_Missing` ("The log file %1 is not there. It is created again when %{Program.Name} next writes to it."), %1 the path | `File_Logging_Open_Directory` (`Open log &folder`), which does what the File menu's item does. When the writer next writes, the surface shows the new file |
| Unreadable | Windows refuses the read (no permission, a lock) | The list's place holds `Log_Unreadable` ("The log file %1 could not be read: %2"), with the Windows reason. The writer may still be writing; this is about reading | `Log_Try_Again`, which reads again; `Open log &folder` |
| Malformed | Bytes that are not text in the log's encoding (`D01 T01 §3`), or a line longer than 8,192 characters | Everything that can be read is shown. A line with bytes that do not decode shows them as the replacement character and carries a `file-warning` icon in place of its level's; a line over the limit is cut on screen at 8,192 characters with `Log_Line_Cut` ("line cut here") at its end. A banner reads `Log_Malformed` ("%1 lines in this log are damaged or too long to show whole. They are marked.") | `Log_Open_External`, to see the file whole |

A line cut on screen still copies whole. A line with bytes that do not decode copies as it is shown, because a text clipboard cannot hold them; the banner's next step is the way to the bytes.

## How does a large log open?

A log is kept under the limit on the General page: 5 MB by default, up to 100 MB when typed there, and more when an AutoIt settings file held a larger limit, which stays in force ([`preferences.md`](preferences.md#what-is-on-the-general-page)). The surface behaves the same at every size (`DESIGN.md` §10):

- **Nothing is read on the UI thread.** The window opens at once.
- **The newest lines come first.** The end of the file is read and shown, following; the rest is indexed towards the start in the background while the footer reads `Log_Reading` ("Reading the log: %1%"), announced once at the start and once at the end. Scrolling, selecting, copying what is shown and closing all work meanwhile; finding and the level filter search what has been indexed and finish as the index does.
- **Only what is on screen is held as text.** The list is virtualized (`D01 T02 §3`): the surface keeps where each line starts, not every line, so a log of any allowed size does not cost its size again in memory.
- **A read that fails part way** becomes the unreadable state above, with what was read discarded.
- **A read or a search belongs to one file.** A rotation, a clear, or the file going missing ends every read, index and search still running for the file that was showing; whatever they deliver afterwards is thrown away, never added to the list. The list then holds rows from the file now on disk and no other.

## What happens while the surface is open?

| Event | The surface |
| --- | --- |
| The writer adds a line | The line is appended with the writer's level. The file is not read again. The count and the size update. |
| The writer rotates the file at its limit | The list starts again with the new file, following; the footer reads `Log_Rotated` ("The log reached its limit and was started again.") until the surface closes, announced. A selection in the old lines is dropped. |
| The log is cleared, here or on the General page | As [above](#what-does-clear-log-do-here). |
| The writer stops, or recovers | The banner [above](#what-if-nothing-new-is-being-recorded). |
| The file disappears, or cannot be read | The failures [above](#what-if-the-log-file-is-wrong). |
| Logging is turned off or on in Preferences | The off banner appears or goes with the confirmed save. |

## What does "Open in default app" do?

It hands the log file to the program Windows opens `.log` files with, as the AutoIt item did (`Logging.au3:269`).

| Part | Rule |
| --- | --- |
| Control | `Log_Open_External` (`&Open in default app`), in the toolbar; Ctrl+Shift+O anywhere in the surface. |
| Enabled | While the log file exists. Otherwise disabled with `File_Logging_Unavailable` ("There is no log file yet, or it was moved or deleted."), the File menu's reason, as tooltip and help text, on hover and on keyboard focus. |
| Success | The file opens in that program. One line is written to the log (`Showing_File`, reworded: "Opened the log in its default program."). The surface stays open. |
| The file gone at the press | The missing state above. |
| No program is set for `.log` files | A banner: `Log_No_Program` ("Windows has no program set to open .log files."), with `Open log &folder`. |
| Windows refuses the launch | A banner: `Log_Open_External_Failed` ("Windows could not open %1: %2"), the path in monospace and the Windows reason, selectable and copyable, with `Open log &folder`. |

Each failure also writes one log line. A banner from this action goes at the next successful press or when the surface closes.

## Which keys does the surface answer?

| Key | Where | Does |
| --- | --- | --- |
| Tab, Shift+Tab | Surface | Find box, level filter, Follow, Copy, Open in default app, a banner's text then its button, the list, the footer's path, Clear log, then the text beside it (its line, or its result once pressed, and any copy or rotation message the footer is showing), and round. Every text in the surface that carries a path, a file name, a Windows reason or a count is a stop, as [`preferences.md`](preferences.md#can-a-note-be-copied) rules. |
| Up, Down, Home, End, Page Up, Page Down | List | Move the focus and the selection; with Shift, extend it. End also resumes following. |
| Ctrl+A | List | Selects every line the list is showing. |
| Ctrl+C | List; a banner; the footer's path; the footer's result or message; a state's text in the list's place | Copies the selected lines, or that text whole. |
| Shift+F10, the Menu key | List | The context menu: Copy, Select all. |
| Ctrl+F | Surface | Focus to the find box, its text selected. |
| Esc | Focus in the find box, with text in it | Empties it. |
| Esc | Focus anywhere else, or in an empty find box | Closes the surface, whether or not a search is set. |
| Ctrl+W | Surface | Closes the surface. |
| Ctrl+Shift+O | Surface | Open in default app. |
| Alt+F, Alt+Y, Alt+C, Alt+O, Alt+T, Alt+P, Alt+A | Surface | Follow, Copy, Clear log, Open in default app, Try again, Open Preferences, Show all lines, when each is showing. |
| Left, Right; Shift+wheel | List | Scroll a long line sideways. |

Clear log keeps the General page's label and key, `&Clear log`, so Copy's access key is Y (`Cop&y`) and the two never share one. Ctrl+C is always copy.

## What is announced?

Through UI Automation (`DESIGN.md` §9):

| Event | Announcement |
| --- | --- |
| A line takes focus | Its level's name, then the line's text. A marked line adds `Log_Line_Damaged` ("damaged") or `Log_Line_Cut`. |
| Following pauses or resumes | `Log_Follow_Paused` ("Following paused."); `Log_Follow_Resumed` ("Following the newest line."). |
| A find or filter settles | The count, `Log_Count_Filtered` or `Log_Count`. |
| Copy | `Log_Copied`, or `Log_Copy_Failed`. |
| Clear log | Its result. |
| A banner appears or goes | Its text; `Log_Recording_Again` when the cannot-write banner goes. |
| The read starts and ends | `Log_Reading` once at each. |
| A rotation | `Log_Rotated`. |

**Not announced:** each new line. A tool can write many a second, and the status bar already announces a task's start and its result ([`standard-window.md`](standard-window.md)). A user who wants every line reads the list, where each is announced as focus reaches it.

The list is a UI Automation list supporting multiple selection; each row's name is its level's name and its text.

## How does it scale?

The list's row height and the toolbar's and footer's follow the user's density (`D01 T02 §2`); the text size does not change. Lines are never wrapped, because a log is compared line against line: a line longer than the list scrolls sideways, and the horizontal scroll bar appears only then. At the minimum size, at every density and at 200 percent text scaling, no control is clipped: the toolbar's buttons fall back to icons as [above](#what-is-the-surface), and every target is at least 24 x 24 (`DESIGN.md` §9). A line in a right-to-left language is shaped and read right to left after its time stamp, which stays left to right, and a path inside it stays left to right (`D01 T02 §7`); the layout is not mirrored, the limit [`language-page.md`](language-page.md#how-does-it-scale-and-what-about-right-to-left-languages) states.

## Which strings does the surface use?

In a new `[Log]` section unless marked. Every text above has a key here.

| Key | English | Verdict |
| --- | --- | --- |
| `Log_Title` | %{Program.Name} log | New |
| `Level_Error`, `Level_Warning`, `Level_Success`, `Level_Finished`, in `[Logging]` | Error:, Warning:, Success:, Finished: | Kept (`Localization.au3:158-161`): the prefixes the writer writes |
| `Log_Level_Information`, `Log_Level_Success`, `Log_Level_Warning`, `Log_Level_Error`, `Log_Level_Finished` | Information, Success, Warning, Error, Finished | New |
| `Log_Find` | Find in log | New |
| `Log_Filter`, `Log_Filter_All`, `Log_Filter_Warnings`, `Log_Filter_Errors` | Show, All lines, Warnings and errors, Errors | New |
| `Log_Follow` | `&Follow` | New |
| `Log_New_Lines` | %1 new | New |
| `Log_Follow_Paused`, `Log_Follow_Resumed` | Following paused. Following the newest line. | New |
| `Log_Copy` | `Cop&y` | New |
| `Log_Copy_None` | Select the lines to copy. | New |
| `Log_Copied` | %1 lines copied. | New |
| `Log_Copy_Failed` | The lines could not be copied: %1 | New |
| `Log_Select_All` | Select all | New, the context menu's |
| `Log_Count`, `Log_Count_Filtered` | %1 lines; %1 of %2 lines | New |
| `Log_Finding` | Finding... | New |
| `Log_No_Match` | No line matches. | New |
| `Log_Show_All` | `Show &all lines` | New |
| `Log_Empty` | Nothing has been logged yet. %{Program.Name} writes here as it works. | New |
| `Log_Off` | Logging is turned off, so nothing is being recorded. | New |
| `Log_Open_Preferences` | `Open &Preferences` | New |
| `Log_Try_Again` | `&Try again` | New |
| `Log_Recording_Again` | Logging is working again. | New |
| `Log_Missing` | The log file %1 is not there. It is created again when %{Program.Name} next writes to it. | New; replaces `File_Not_Found` |
| `Log_Unreadable` | The log file %1 could not be read: %2 | New |
| `Log_Malformed` | %1 lines in this log are damaged or too long to show whole. They are marked. | New |
| `Log_Line_Cut`, `Log_Line_Damaged` | line cut here; damaged | New |
| `Log_Reading` | Reading the log: %1% | New |
| `Log_Rotated` | The log reached its limit and was started again. | New |
| `Log_Open_External` | `&Open in default app` | New |
| `Log_No_Program` | Windows has no program set to open .log files. | New |
| `Log_Open_External_Failed` | Windows could not open %1: %2 | New; replaces `Showing_Error` |
| `Showing_File`, in `[Logging]` | Opened the log in its default program. | Reworded (`Localization.au3:139`: "Showing '%s' log File.") |
| `Label_Logging_Not_Running`, `Label_Logging_Size`, `Label_Logging_Clear_Note`, `Label_Logging_Cleared`, `Label_Logging_Nothing`, `Label_Logging_Partial`, in `[Preferences]` | As [`preferences.md`](preferences.md#which-strings-does-the-dialog-use) gives them | The General page's, used as they are |
| `File_Logging_Open_Directory`, `File_Logging_Unavailable`, in `[Menus]` | As [`standard-window.md`](standard-window.md#which-strings-does-the-window-add) gives them | The File menu's, used as they are |
| `File_Not_Found`, `Showing_Error`, `Opening_File`, in `[Logging]` | | Cut (`Localization.au3:138`, `:140`, `:141`): "Could not find the '%s' log File", "Something went wrong: Process ID: %s", which printed a process number as an explanation, and "Opening the log File". For `D01 T03 §7`'s audit |

The open-folder keys in `[Logging]` (`Opening_Directory`, `Directory_Not_Found`, `Showing_Directory`, `Localization.au3:142-144`) belong to File, Logging, Open log folder and are `D01 T03 §7`'s to rule on with it.

## What must the build prove, row by row?

Every row is one behavioural check in `D01 T01 §7`, driven against the built surface with fixture logs; where a row names the file, the clipboard or the settings, the check reads that back as well as the list.

| Element | Trigger | States | Result | Failure | Check in `D01 T01 §7` |
| --- | --- | --- | --- | --- | --- |
| Opening | File, Logging, Open log file; the status bar's state segment by click and by Enter; each a second time | Closed; already open | The surface opens at the newest line, following, focus on the list; a second request brings the same window forward | A log that cannot be read: the surface opens anyway in its failure state, as the rows below | `log: opens once, at the newest line` |
| Not modal, and owned | With the surface open, use the tool's window; minimize and restore the tool; close the tool | Open | The tool's window answers; the surface is minimized and restored with it and closes with it | None can occur: ownership is the window's own | `log: the surface stays beside the tool` |
| Size and place | Move and resize; close; reopen; restart the tool and reopen; reopen with the tool on another monitor and with the stored monitor gone; reopen with a stored size under the minimum | | `LogPlacement` reads back from the settings file for that monitor; the surface reopens there, after a restart too; with the monitor gone, centred on the tool's window and inside the work area; never under the minimum | A place that cannot be written (seeded): the surface still closes, the failure is in the log, and the earlier place is used at the next open | `log: the surface remembers its place per monitor` |
| Levels of written lines | Have the fixture tool write one line at each level while the surface is open | Five levels | Each row shows its level's icon and its prefix; each row's accessible name starts with its level's name | A level the surface does not know (seeded): drawn as Information, not blank | `log: a written line shows the level it was given` |
| Levels of lines read back | Open a fixture file holding a line with each prefix in English, each in the language showing, one in a third language, and one with no prefix | | English and current-language prefixes give their levels; the third-language line and the plain line are Information; every line's text is intact | None can occur: a line with no known prefix is Information | `log: a line read back takes its prefix's level` |
| No guessing | Write plain lines containing "error", "failed", "success", "blocked" and "FOUND", and an error line containing "successfully" | | Each plain line is Information; the error line is Error; the error count the writer reports is 1 | None can occur: no text is searched | `log: a word in a line never sets its level` |
| The hyphen rule | A fixture line of 90 hyphens | | Drawn as a rule; selectable; copies as its 90 hyphens | None can occur: it is a line like any other | `log: a hyphen line draws as a rule and copies as text` |
| Selecting | Click; Ctrl+click; Shift+click; Shift+Down; Ctrl+A; the context menu's Select all | | The selection each gesture describes, read through UI Automation | None can occur: selection changes nothing | `log: lines select singly, in ranges and all` |
| Copy | Select three lines apart; Ctrl+C; the button; the context menu | Selection; none | The clipboard holds those lines in file order, byte for byte against the fixture file, each ended by CR LF; `Log_Copied` in the footer. With none selected the button and item are disabled with `Log_Copy_None` | The clipboard held by another program (seeded): `Log_Copy_Failed` with the reason, the selection kept | `log: copy is the file's own text` |
| Following | Write lines with the surface open | Following | The newest line is in view after each; the selection does not move | None can occur: a line added cannot fail to scroll | `log: the view follows the newest line` |
| Pausing | Scroll up by wheel, by Page Up, and by Up from the last line; write five lines | Paused | The view does not move; the toggle shows off and reads `Log_New_Lines` with 5; `Log_Follow_Paused` announced | None can occur: pausing only stops scrolling | `log: reading pauses following` |
| Resuming | The toggle by click, Space and Alt+F; End; scrolling to the bottom | Paused | The newest line is in view, the count is gone, `Log_Follow_Resumed` announced | None can occur: resuming only scrolls | `log: following resumes on request` |
| Finding | Ctrl+F; type text in a different case from the line's; type text that matches nothing; Esc | Matches; none | Only matching lines show, case ignored; the footer reads `Log_Count_Filtered`; with none, `Log_No_Match` and Show all lines, which restores every line; Esc in the box empties it and a second Esc closes the surface; with a search set and focus in the list, one Esc closes the surface | None can occur: a search reads only the index | `log: find narrows the list without regard to case` |
| Level filter | Choose Warnings and errors, then Errors, with a find text set as well | Each choice | Only lines of those levels that also contain the text; following and the new-line count apply to them; Ctrl+A and copy take only those | None can occur: the filter reads levels already known | `log: the level filter and find apply together` |
| Clear log | Press it; Alt+C | A log present; none; the current file held open by another program without delete sharing, with logging on and with it off | Deleted: the same results as the General page's check, in the footer; the list is empty or holds the new file's first line; the files are gone, checked on disk. Held open: `Label_Logging_Partial` naming the file and reason, and the list still holds that file's lines, compared with the file on disk | The partial result is the failure presentation; the list always matches the disk | `log: clear log is the general page's clear` |
| Cleared from Preferences | With the surface open, press Clear log on the General page: with logging on, with logging off, and with the current file held open without delete sharing | Each | The surface's list matches the disk afterwards: with logging on, the new file's first line; with logging off, empty; with the file held open, that file's lines still there | The partial result shows on the General page, as its own check proves | `log: a clear elsewhere reaches the open surface` |
| Nothing logged yet | Open the surface on a first run with logging on | No file | `Log_Empty` in the list's place; the first line written replaces it | None can occur: the state is the absence of lines | `log: an empty log says so` |
| Logging off | Turn logging off and save, with a log present; then with none | Lines; none | With lines: they stay readable under the `Log_Off` banner; with none: `Log_Off` in the list's place; Open Preferences opens the General page | None can occur: the banner follows the setting | `log: logging off is stated above the old lines` |
| Logging that cannot write | With the surface open, make the log folder refuse writes and have the tool write; then fill the disk (seeded); then restore and press Try again | Stopped; recovered | The warning banner appears at that moment with the path and reason, the earlier lines still readable; Try again while still failing keeps it with the reason; after restoring, it goes, `Log_Recording_Again` is announced, and the next line appears | The stated results are the failure presentations | `log: a writer that stops is said at once` |
| Missing file | Delete the log file before opening; and while open; then have the tool write | Missing | `Log_Missing` with the path and Open log folder, which opens the folder; the next write shows the new file | Open log folder failing is the File menu's message (`Log_Folder_Failed`) | `log: a missing file is stated, with the folder offered` |
| Unreadable file | Deny read access to the log file; open; restore access; Try again | Unreadable | `Log_Unreadable` with the path and the Windows reason; Try again shows the log | Try again while still denied: the same state with the reason | `log: an unreadable file is stated, with try again` |
| Malformed file | A fixture log with bytes that do not decode on two lines and one line of 20,000 characters | | Every other line shows; the two show replacement characters and the `file-warning` icon; the long line is cut at 8,192 with `Log_Line_Cut`; the banner counts 3; copying the long line gives all 20,000 characters | The stated results are the failure presentations | `log: a damaged log shows what can be read` |
| A slow read | Delay the fixture file's read by five seconds; open; scroll, select and resize during it | Reading | The window opens at once with the newest lines; the footer reads `Log_Reading`; every key and repaint is answered throughout | A read that fails after the delay: the unreadable state | `log: a slow read never freezes the window` |
| A log above 100 MB | A fixture log of 120 MB, the limit set to 200 MB in the file; open; scroll to the start; find a text present once; filter to errors; Ctrl+A and copy 1,000 lines | Large | The window answers throughout; the found line and the filtered count are right against the fixture; the process's memory grows by less than the file's size | A copy too large for the clipboard: `Log_Copy_Failed`, the selection kept | `log: a log over the edit limit opens, finds and filters` |
| A line written while open | Have the tool write a line | Open | The row appears with the writer's level; the count and size update; the file is not read again (counted reads) | None can occur: the writer pushes the line | `log: a new line arrives without a reread` |
| A rotation | Set a small limit; write past it with the surface open | | The list starts again with the new file, following; `Log_Rotated` in the footer, announced | None can occur: the writer reports its own rotation | `log: a rotation is followed and said` |
| A rotation during a slow read | Delay the read of an existing fixture log; with the surface open and still reading, write past the limit so the writer rotates; release the delayed read; the same with a search in flight and with a clear in place of the rotation | Reading; finding | Only the replacement file's rows are in the list; none of the old file's lines or counts appear after the release; the footer's count matches the new file | None can occur: results for a file no longer showing are discarded | `log: a late read never reaches a newer file` |
| Open in default app | Click; Alt+O; Ctrl+Shift+O | File present; absent | Present: the associated program is started with the log's path (a fixture association), and one log line is written. Absent: disabled with `File_Logging_Unavailable` on hover and focus | The row below | `log: open in default app hands the file over` |
| Open in default app, failing | Remove the `.log` association (seeded); make the launch fail (seeded); delete the file between enable and press | Each | `Log_No_Program` with Open log folder; `Log_Open_External_Failed` with the path and reason, copyable; the missing state. One log line each | The stated results are the failure presentations | `log: each way the hand-over fails is stated` |
| Keyboard | Tab round the surface; every key in the keys table | | The Tab order is the table's; every control is operated without a mouse; after a partly-cleared Clear log, Tab reaches the result and Ctrl+C puts its file name and Windows reason on the clipboard; Copy and Clear log answer different access keys | None can occur: every control is the framework's | `log: every control is reached by keyboard` |
| Announcements | Focus lines of each level and a marked line; pause, resume, find, copy, clear; raise and clear each banner; write 50 lines quickly | | Each announcement in the table is raised once; the 50 lines raise none | None can occur: each announcement follows its event | `log: states are announced and new lines are not` |
| Scaling | The surface at each density, at 480 x 320, under 640 wide and at 200 percent text scaling, with a line of 400 characters and a right-to-left line | | Nothing clipped; the toolbar falls back to icons with their names; the long line scrolls sideways and is not wrapped; the right-to-left line reads right to left after its time stamp | None can occur: sizes are the host's | `log: the surface scales, and long lines scroll` |
