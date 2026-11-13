# The standard tool window

Every Resolute tool opens the same window. This page specifies it region by region, with its two menus and the one message layer every framework notice renders through, so that `D01 T01 §7` can build it without inventing a control. It is `D01 T03 §1` (`todo/01-framework/TODO-03-framework-surfaces.md`), held to `DESIGN.md` sections 1, 4, 8, 9 and 11.

A user who learns one tool has learned all of them, so the framework owns the whole window except one region, the content region, which belongs to the tool. A tool never adds a menu item, never draws a dialog or a message box, and never writes the status bar's framework regions. The framework gives it no call that would: the window, the menus and the message layer are built from the tool descriptor (`D01 T01 §1`) and the packs, and the only handle a tool receives is its content region's.

Sizes are base values at 96 DPI, scaled through `Dpi::Scale` at draw time, as everywhere in `docs/captures/house-style/contract.md`. Spacing names the `DESIGN.md` §5 tokens; text sizes name the §4 ramp.

A specification cannot prove behaviour, so it ends in an action and state matrix ([below](#what-must-the-build-prove-row-by-row)): one row per thing a user can act on, with its trigger, states, result, failure and the check `D01 T01 §7` runs to prove it. The menus are drawn with the menu bar and popup menu `D01 T02 §8` adds to the UI library.

## What does the AutoIt window have, and where does each part go?

The AutoIt window is built by `_StartCoreGui` (`resolute_au3/SDK/Concrete/ReBar/ReBar.au3:510-622`), 550 x 490 and not DPI-aware. Every part of it has a home here or a recorded verdict:

| AutoIt part | Source | Here |
| --- | --- | --- |
| Window, `$WS_OVERLAPPEDWINDOW`, title from `_GUIGetTitle` | `ReBar.au3:516`, `:381` | The caption, with a Direct2D title bar (`DESIGN.md` §8). The title no longer carries "Administrator ~": elevation moves to the status bar. |
| File and Help menus, populated: Preferences, Logging (open file, open folder), Close; Check for updates, Home, Downloads, Support, Issues, Donate, About | `ReBar.au3:525-547`, handlers `:549-560` | The menu bar, with the items below and no others. |
| A 16 px icon on most menu items (`$g_aMenuIcons`) | `ReBar.au3:531-547` | Cut. The items carry text, access key and accelerator; a column of small icons beside text adds nothing a reader uses, and the popup menu stays one type size throughout. |
| Heading icon, 64 px, click opens About | `ReBar.au3:562-568` | The heading block's icon, 48 px, click and Enter open About. |
| Heading icon's info tooltip: program version, AutoIt version, copyright | `ReBar.au3:563-566` | Remapped. The tooltip says "About <display name>", the button's purpose; the version and copyright are the About dialog's (`D01 T01 §7`, `D06 T01 §17`). The AutoIt version has no C++ counterpart and is cut. |
| Update animation over the icon | `ReBar.au3:569-571` | Cut from the heading. A running update check shows in the status bar's task slot. |
| Name and version label, 12 pt | `ReBar.au3:573-574` | The heading block's title line. |
| Subheading, `Label_Status_Welcome` formatted, rewritten with status during an update check | `ReBar.au3:575-577`, `:905`, `:914` | The heading block's subheading, which is the tool's purpose and never a status. Status goes to the status bar. |
| Open log file, which handed the log to its associated program (`_Logging_OpenFile`) | `SDK/Includes/Logging.au3:265-275`, `:269` | Kept in two places: File, Open log file opens the log in the tool's own log surface, and that surface's "Open in default app" (`D01 T03 §4`) hands the file to its associated program as the AutoIt item did. |
| Status list, a 125 px report list view docked at the bottom, written by `_Logging_EditWrite` | `ReBar.au3:579-594`, `SDK/Includes/Logging.au3:76-104` | The per-tool log surface, `D01 T03 §4`. The status bar shows its latest line. |
| Donate icon and label | `ReBar.au3:596-599` | Not in the window. Donate is cut on every surface by `D01 T03 §7` ([`string-audit.md`](string-audit.md#donate)). |
| `HotKeySet("{ESC}", "_MinimizeProgram")` | `ReBar.au3:506` | File, Minimize, with Esc as its accelerator. |
| Tool-added menus: ComIntRep's Maintenance, Troubleshoot and Tools (`ComIntRep.au3:620-622`), DVDRepair's and USBRepair's Troubleshoot and Tools (`DVDRepair.au3:532-533`, `USBRepair.au3:520-521`), Distro's Debug (`Distro.au3:580`) | | Not menus. Each tool's actions live in its content region, in the tool's own toolbar, specified by that tool's port file under `todo/04-tools-port/`. Debug is cut: no shipped tool has a debug menu. |
| Tool-added File items: `File_Reboot` (ComIntRep, DVDRepair, USBRepair), `File_Export*` and `File_Event_Log` (ComIntRep) | the tools' `[Menus]` packs | Content-region actions of those tools, as above. Reboot after a repair is the repair contract's offer (`D02 T01`), not a menu item. |

## What are the window's regions?

From top to bottom, five regions. Only the content region is the tool's.

| Region | Contents | Height | Resize |
| --- | --- | --- | --- |
| Caption | The tool's application icon (16 px), the title (the descriptor's display name), and minimize, maximize and close, drawn with Direct2D in the theme (`DESIGN.md` §8; built by `D01 T02 §4`). The rest of the bar is the drag region. | 32 at every density | Fixed height, matching the Windows caption whatever the density. The title truncates with an ellipsis and carries a tooltip with the full title when it does. |
| Menu bar | File and Help, text buttons left-aligned at `SpacingSM` from the edge. | 28, 32, 36 (Compact, Normal, Spacious) | Fixed height per density. Never wraps: two short labels always fit at the minimum width. |
| Heading block | The tool icon (48 px), its left and top offsets and its gap to the title all the density's padding (`SpacingMD`, `SpacingLG`, `SpacingXL` for Compact, Normal, Spacious); beside it the title line (Title, 20 px, SemiBold): the descriptor's display name and its version; under it the subheading (Body, 13 px, secondary text colour). | 72, 80, 96 | Fixed height. The title line truncates with an ellipsis and a tooltip. The subheading wraps to two lines, then truncates with an ellipsis and a tooltip. |
| Content region | The tool's own view. The framework draws nothing in it and lays nothing over it. | the rest | Takes all the height and width left. The tool lays out its own content inside it. |
| Status bar | The shared `StatusBar` control (`shared/resolute-ui/include/resolute/controls/statusbar.h`): state text, background-task slot, elevation indicator. | 24, 26, 30 (26 is `StatusBar::BASE_HEIGHT`); never under 24, so each acting segment is a 24 x 24 target at least (`DESIGN.md` §9) | Fixed height. Segments as below. |

- **The heading strings come from the descriptor and the tool's pack:** the title line is the descriptor's display name, a space, and its version as `major.minor.patch` (tag-derived, `D06 T01 §11`); the subheading is the key `Program_Purpose`, the one-line job of the tool (for BiosCodes, "Look up what your computer's beep codes mean."), resolved like every key (`D01 T01 §4`): the tool's pack in the chosen language, then the common pack, then the built-in English, so an incomplete translation shows the English purpose rather than nothing. Only when no level holds the key does the block show no subheading, keeping its height, and the key is then reported missing as `D01 T01 §4` reports every missing key.
- **Density** is the user's choice (`DESIGN.md` §5) and comes from `D01 T02 §2`'s density scale, which the menu bar, heading block and status bar read for the heights above; text sizes and icon sizes do not change with density, and the caption stays the Windows caption's height. At the minimum window size every region fits at every density with nothing clipped: 640 x 480 leaves the content region at least 280 tall at Spacious.
- **The window's size:** default 960 x 640, minimum 640 x 480, both base values; the framework enforces the minimum (`DESIGN.md` §5), remembers size, position and maximized state per monitor through the settings writer (`D01 T01 §2`), and restores onto a monitor that still exists or centres on the primary one. Windows 11 snap layouts work because the caption reports its maximize button to `WM_NCHITTEST` as `HTMAXBUTTON`.
- **Keyboard order** (`DESIGN.md` §9), top to bottom as the window reads: the menu bar is outside the Tab order, reached with Alt or F10 and left with Esc. Tab goes heading icon (a button labelled "About <display name>"), the content region (the tool's own order inside it), the status bar's state segment, its task segment while a task runs, its elevation segment, then back to the heading icon; Shift+Tab goes the same way backwards. Focus starts in the content region when the window opens.

## What is on the File menu?

Exactly these items, in this order. The framework builds the menu from this table; there is no call that adds, removes or reorders an item, so no tool can.

| Item | Pack key (`[Menus]`) | Accelerator | Enabled | Does | When it fails |
| --- | --- | --- | --- | --- | --- |
| Preferences | `File_Preferences` (`&Preferences`) | Ctrl+, | Always | Opens the Preferences dialog, `D01 T03 §2`, for this tool. | A Preferences dialog already open is brought forward rather than opened twice. |
| Logging, a submenu | `File_Logging` (`&Logging`) | | Always | Opens the two items below. | |
| Open log file | `File_Logging_Open_File` (`Open &log file`) | | When this tool's log file exists; otherwise disabled with the tooltip `File_Logging_Unavailable` | Opens the log file in the per-tool log surface, `D01 T03 §4`. | The surface opens anyway and states the failure inside itself (missing, unreadable or malformed, per `D01 T03 §4`), never a dialog. |
| Open log folder | `File_Logging_Open_Directory` (`Open log &folder`) | | While the log folder exists, whether or not the log file is still in it; otherwise disabled with `File_Logging_Folder_Unavailable` | Opens the log folder in File Explorer, with the log file selected when it is there and nothing selected when it is gone. | Explorer cannot be started or the folder is gone: Error `Log_Folder_Failed` ("The log folder could not be opened."), naming the path, selectable, so it can be pasted into Explorer. |
| (separator) | | | | | |
| Minimize | `File_Minimize` (`Mi&nimize`), new: `[Menus]` has no key for it today | Esc, when no menu or message is open | Always | Minimizes the window, as Esc did in the AutoIt suite (`ReBar.au3:506`). | |
| Close | `File_Close` (`&Close`) | Alt+F4 | Always | Closes the tool through the framework's shutdown (`D01 T01 §1`), which persists settings first. | Settings that cannot be written are shutdown's own message (`D01 T03 §6`, [`notices.md`](notices.md#what-if-settings-cannot-be-saved-at-closing)): try again, close anyway, or Cancel, which keeps the tool open. |

- **Accelerator text is the framework's, not the pack's.** The AutoIt value `&Close\tAlt+F4` (`resolute_au3/Resolute/Language/ReBar/en.lng:106`) carries its accelerator inside the string, so a translation could change or drop it. The pack value is the label alone; the framework draws the accelerator right-aligned from this table.
- **Disabled items stay visible and say why**, to every user: the arrow keys land on a disabled item (it cannot be chosen) and its reason shows as its tooltip on keyboard focus exactly as on hover, and the same reason is the item's UI Automation help text (`D01 T02 §8`). Open log file's reason is `File_Logging_Unavailable` ("There is no log file yet, or it was moved or deleted."), true on first run and after a deletion; Open log folder's is `File_Logging_Folder_Unavailable` ("The log folder does not exist."), true before the first log and after a deletion alike. A deleted log usually leaves its folder, so the folder item stays usable.
- **Every failure is said, never silent.** The AutoIt handlers wrote a `ShellExecute` failure to the status list and nowhere else (`SDK/Includes/Logging.au3:245-275`). Here a log file that cannot be opened is stated inside the log surface (`D01 T03 §4`), which is where the user asked to look, and only Open log folder, which leaves the tool for File Explorer, fails through the message layer with `Log_Folder_Failed`; each failure also writes a log line.
- Two value corrections, each for `D01 T03 §7`'s string audit: `File_Logging_Open_File` loses its stray capital ("Open log File" to "Open log file"), and `File_Logging_Open_Directory` says "folder", the Windows word.

## What is on the Help menu?

Exactly these items, in this order, built the same way.

| Item | Pack key (`[Menus]`) | Accelerator | Enabled | Target |
| --- | --- | --- | --- | --- |
| Help for this window | reserved for `D06 T01 §18` | F1, reserved | Owned by `D06 T01 §18` | The first item, reserved: `D06 T01 §18` owns F1 and context help, and adds this item with its key when it ships. Until then the item is absent and F1 does nothing; no other item takes F1. |
| Check for updates | `Help_Update` (`Check for &updates`); while a check runs, `Help_Update_Cancel` (`Cancel &update check`) | | Always. While a check runs the item is the way to stop it, whoever started it and whatever else is running | Runs the update check, `D01 T01 §5`; the result, or its failure, is one of the update notices, `D01 T03 §5` ([`update-notices.md`](update-notices.md)). While a check runs, cancels it: no notice, one log line. A second check cannot be started, because the item that would start it is the one that cancels. |
| (separator) | | | | |
| Rizonesoft Home | `Help_Home` (`%{Company.Name} &Home`) | | Always | `https://rizonesoft.com` in the default browser (`ReBar.au3:281`). |
| More Downloads | `Help_Downloads` (`More &Downloads`) | | Always | `https://rizonesoft.com/downloads/` (`ReBar.au3:284`). |
| Get Support | `Help_Support` (`&Get support`) | | Always | `https://rizonesoft.com/contact-us/` (`ReBar.au3:282`). |
| Report a problem | `Help_Issue` (`&Report a problem`) | | Always | `https://github.com/rizonesoft/Resolute/issues/new`, with the tool's short name and version in the issue title (`ReBar.au3:290` opened the list; a new issue is the action the label names). |
| (separator) | | | | |
| About | `Help_About` (`&About %{Program.Name}`, gaining its access key) | | Always | Opens the About dialog for the running tool's descriptor, built by `D01 T01 §7` from the descriptor and enriched by `D06 T01 §17`. |

- **The URLs are framework constants**, defined once in the framework at build time and shared by every tool, never typed in a tool: one support link that is right everywhere, not fourteen that rot separately.
- **A link that cannot open** (no default browser, or the browser refuses the URL) is the message layer's Error `Link_Open_Failed` ("The page could not be opened."), new in `[Messages]`, with the URL selectable and a "Copy link" action (`Link_Copy`), so the user can paste it where they browse.
- `Help_Issue` changes value and meaning: "Create an issue" assumes the reader knows the tracker; "Report a problem" names the action. `Help_Support` loses its capital. Both go to `D01 T03 §7`'s string audit.

## How does every notice reach the user?

Through one message layer: a framework dialog drawn with the UI library, never a Win32 `MessageBox` or `TaskDialog`. It is the only way any framework notice appears; `D01 T03 §5` and `§6` specify their notices as calls to it, and a tool reaches it only through the framework's notice calls.

A message has:

| Part | Rule |
| --- | --- |
| Window title | The tool's display name, so a user with several tools open knows which one is speaking. |
| Severity | Information, Warning or Error, shown by a themed Lucide icon (`info`, `triangle-alert`, `circle-x`) and named for screen readers by `Info_Title`, `Warning_Title` or `Error_Title`. Colour is never the only carrier: the icon shape differs. |
| Summary | In Subtitle (16 px, SemiBold): what happened, in the message's own key. Written to fit one line; a summary that does not fit the message's width (a long name in it, a longer language) wraps and is never cut. |
| Body | Body text (13 px), selectable and copyable; machine values (paths, codes, registry keys) in monospace (`DESIGN.md` §4). Long bodies scroll inside a maximum height of 320; width 480, both base. |
| Buttons | Right-aligned, `SpacingSM` apart. A button names its action ("Open download page", "Restart now"), and Cancel or Close is the way out. Sets: Close; one action or two, plus the way out, which is Cancel where declining stops something the user started and Close where the message asks nothing and declining changes nothing (the update notices, [`update-notices.md`](update-notices.md)). |
| Button labels | The ways out are the framework's, in `[Messages]`: `Button_Close` ("Close"), `Button_Cancel` ("Cancel"), and `Button_OK` ("OK") for an Information message that asks nothing. An action button's label is the calling notice's own key, specified with the notice in `D01 T03 §5` or `§6`. The AutoIt `Button_Ok` ("Ok", `[About]`, `en.lng:42`) is replaced by `Button_OK` here. |
| Default | Enter presses the default; Esc presses Cancel, or Close where there is no Cancel. The default is never the destructive action: when an action changes the system, Cancel is the default. |
| Focus | Opening a message puts focus on its default button. The caption's close button does what Esc does. Closing the message, by any button or key, returns focus to the control that was focused when it opened, or to the content region when that control is gone. |
| Copy | Ctrl+C copies the whole message as text: title, severity, summary, body. A copy button carries the same, labelled `Message_Copy` ("Copy message"). |

- **Modality:** modal to the tool's window, centred on it, and never topmost over other applications, never system-modal. The AutoIt boxes set `$MB_TOPMOST` or `$MB_SYSTEMMODAL` (`ReBar.au3:434`, `:441`, `:461`); a notice that covers the user's other work is cut.
- **No timeout.** The AutoIt boxes closed themselves after `$g_iMsgBoxTimeOut`; a message for someone whose machine is broken waits until they have read it (`DESIGN.md` §11).
- **Announced:** opening raises a UI Automation notification with the summary, and the dialog's name is its summary (`DESIGN.md` §9).
- **Logged:** every message writes one log line with its severity, its key and the button chosen.
- **The titles change:** `Info_Title` "Please Take Note" becomes "Information", `Warning_Title` "Warning!" becomes "Warning", and `Error_Title` "Oops! Something went wrong!" becomes "Error" (`en.lng:118-120`). `Error_Oops` ("Oops!", `en.lng:121`), which the AutoIt boxes used as their title (`ReBar.au3:434`, `:441`, `:461`), is cut: a user whose tool failed needs to know what failed, not a sound effect. Each verdict is recorded in `D01 T03 §7`'s string audit.
- **The dead calls are cut.** Eighteen `MsgBox(0, "")` lines across the AutoIt tools are commented-out debug output (`grep -rnE 'MsgBox\(\s*0\s*,\s*""' resolute_au3 --include=*.au3`, outside `samples/` and `todo/`, every one a comment), and the one live debug box, `MsgBox(0, "Error", $g_sSplashAniPath)` (`SDK/Includes/Splash.au3:50`), prints a file path as an error. None is ported; the splash itself is cut (`D01 T03 §7`, [`string-audit.md`](string-audit.md#the-splash-screen)), so there is no animation to look for and nothing to log.

## Which keys does the window answer?

The menus' own keys are the popup menu's (`D01 T02 §8`); the choices here are the window's. `D01 T02 §5` proves the whole path without a mouse.

| Key | Where | Does |
| --- | --- | --- |
| Alt, F10 | Anywhere in the window | Focuses the menu bar on File, with access keys underlined. |
| Alt+F, Alt+H | Anywhere | Opens File or Help. |
| Left, Right | Menu bar, or an open menu | Moves to the neighbouring title, opening its menu when one was open. |
| Up, Down, Home, End | Open menu | Moves between items. A disabled item can be landed on, shows its reason as a tooltip and in its help text, and cannot be chosen. |
| Right, Left | On Logging, or in its submenu | Opens or closes the submenu. |
| Enter, an item's access key | Open menu | Chooses the item. |
| Esc | Open submenu, open menu, menu bar | Closes one level: the submenu, then the menu, then leaves the bar for the control that was focused before. |
| Esc | A message is open | The message's Cancel or Close (the message layer above). |
| Esc | Nothing open | File, Minimize. Esc minimizes only when no menu or message is open, so closing a menu never minimizes the window. |
| Ctrl+, | The main window active | File, Preferences. |
| Alt+F4 | The main window active | File, Close. |
| Alt+F4 | A message or another framework dialog active | That dialog's caption close, which is its Esc: Cancel, or Close where there is no Cancel. It never closes the tool from inside a dialog. |
| F1 | Anywhere | Reserved for `D06 T01 §18`; nothing until it ships. |
| Tab, Shift+Tab | Window | Forward: heading icon, content region, state segment, task segment (while a task runs), elevation segment, then the heading icon again; Shift+Tab is the same order backwards. The menu bar is not in it. |
| Enter, Space | Heading icon focused | Opens About. |

## What does the status bar show?

The shared `StatusBar`, three segments, all written by the framework. A tool sets the state text through the framework's status call; it cannot write the other two.

| Segment | Shows | Rules |
| --- | --- | --- |
| Left: state | One line: what the tool is doing or last did. "Ready" (`Status_Ready`, new) when idle; otherwise the latest line the tool wrote to its log (`D01 T01 §3`), without its timestamp. | Truncates with an ellipsis and a tooltip. Clicking it, or Enter when focused, opens the log surface, `D01 T03 §4`. |
| Centre: background task | The one background task the framework runs (an update check) or the tool's long action: its name and the shared progress bar (`StatusBar::PROGRESS_HEIGHT`), determinate when the work knows its total, indeterminate otherwise. Empty when nothing runs. | A finished task is announced through UI Automation and leaves its result in the state text. |
| Right: elevation | A Lucide shield and a word. Elevated: `shield-check` and "Administrator" (`Status_Elevated`, new). Not elevated: `shield` and "Standard user" (`Status_Standard`, new). | The tooltip says what it means: `Status_Elevated_Tip` ("This tool is running with administrator rights.") or `Status_Standard_Tip` ("Actions that change your system will ask for administrator rights."). It never blocks content, and it replaces the AutoIt title's "Administrator ~" prefix (`SDK/Includes/Versioning.au3:120-121`). The launcher's own indicator is `D03 T02 §7`'s and follows this one. |

**Never in the status bar:** an error that needs the user to act (that is the message layer's), anything a tool's content owns, advertising or Donate, a clock.

### How does each segment change?

| Segment | State | Shows | Entered when | Left when |
| --- | --- | --- | --- | --- |
| State | Idle | "Ready" (`Status_Ready`) | The window opens with nothing written yet | The tool writes a line |
| State | Last line | The latest log line, without its timestamp | The tool writes to its log | The next line replaces it |
| Task | Empty | Nothing; the segment collapses to no width | No task runs | A task starts |
| Task | Running, determinate | The task's name (the caller's key) and the progress bar at its fraction | The task reports a total | It finishes, fails or is cancelled |
| Task | Running, indeterminate | The task's name and the moving progress bar | The task starts without a total | It reports a total, finishes, fails or is cancelled |
| Task | Done | Moves on (to the next running task, or empty); the state segment shows the task's result line ("Update check finished: you have the latest version.") | The task succeeds | Immediately |
| Task | Partly done | Moves on; the state segment shows the result with what did not complete ("3 of 4 items repaired; see the log.") | The task ends with some work undone | Immediately |
| Task | Cancelled | Moves on; the state segment shows "Cancelled" with the task's name (`Status_Cancelled`, new) | The user cancels | Immediately |
| Task | Failed | Moves on; the state segment shows the failure in one line, and a failure the user must act on also opens the message layer | The task fails | Immediately |
| Elevation | Administrator or Standard user | As above | The window opens | Never; elevation does not change while a process runs |

- **More than one task:** a tool's action and an update check can run together (Check for updates stays enabled while a tool's action runs). The task segment shows one of them: the one that started first and is still running. A task that starts while another is shown runs without the segment and is named in its tooltip ("Also running: Checking for updates"). When the shown task ends, the segment shows the next running task, oldest first, or empties when none runs. A task that ends while not shown never clears or changes the segment: its result line still goes to the state segment and its announcement is still raised.
- **The taskbar shows it too** (`DESIGN.md` §8): the task the segment shows drives the window's taskbar button through `ITaskbarList3`, owned by the framework's status layer (`D01 T01 §7`): normal progress at its fraction while it runs, indeterminate when it has no total; on success or cancellation the button clears at once; on failure it turns to the error state, and on partial completion to the paused state, each held at the task's last fraction (a full bar for a task that never had a total) until the window is next activated, then cleared. When the shown task ends and another runs, the button shows the next task's progress at once and drops the ended task's state.
- **Announced:** a task's start, its result line and a change of elevation each raise a UI Automation notification; progress is not announced at every step, only at its end.
- **Keyboard:** the state segment is focusable and opens the log surface with Enter; the task segment is focusable while a task runs and its Enter offers to cancel the task it is showing, by name, when that task can be cancelled (`Status_Cancel_Task`, new), never one it is not showing; the elevation segment is focusable for its tooltip and acts on nothing.
- **What the shared control offers and this window does not use:** the clickable segments are used as above, through `SetSegmentCommand`; the notification icons (`AddNotifyIcon`: spinner, success, warning) are not used, because the task segment's progress bar and the result line already say the same thing, and two signals for one state disagree when one lags; the slide-in notice (`ShowNotification`) is not used, because a message that disappears on a timer can be missed, and anything worth saying belongs in the state segment or the message layer.

## Which strings does the window add?

Every string this page introduces, with its pack section and English text; nothing on the page is drawn from a literal. `%{Program.Name}` is the descriptor's display name, substituted by the loader (`D01 T01 §4`).

| Key | Section | English | Used by |
| --- | --- | --- | --- |
| `File_Minimize` | `[Menus]` | `Mi&nimize` | File, Minimize |
| `File_Logging_Unavailable` | `[Menus]` | There is no log file yet, or it was moved or deleted. | Open log file's disabled reason |
| `File_Logging_Folder_Unavailable` | `[Menus]` | The log folder does not exist. | Open log folder's disabled reason |
| `Help_Update_Cancel` | `[Menus]` | `Cancel &update check` | Check for updates, while a check runs |
| `Heading_About` | `[Menus]` | About %{Program.Name} | The heading icon's accessible name and tooltip |
| `Status_Ready` | `[Status]`, new section | Ready | The state segment when idle |
| `Status_Cancelled` | `[Status]` | Cancelled: %1 | The state segment after a cancel; %1 is the task's name |
| `Status_Also_Running` | `[Status]` | Also running: %1 | The task segment's tooltip when a second task runs; %1 is that task's name |
| `Status_Cancel_Task` | `[Status]` | Cancel %1? | The task segment's Enter, for the task it shows |
| `Status_Cannot_Cancel` | `[Status]` | %1 cannot be stopped part way; it will finish on its own. | The task segment's tooltip for a task that cannot be cancelled |
| `Status_Elevated` | `[Status]` | Administrator | The elevation segment |
| `Status_Standard` | `[Status]` | Standard user | The elevation segment |
| `Status_Elevated_Tip` | `[Status]` | This tool is running with administrator rights. | The elevation segment's tooltip |
| `Status_Standard_Tip` | `[Status]` | Actions that change your system will ask for administrator rights. | The elevation segment's tooltip |
| `Button_OK`, `Button_Close`, `Button_Cancel` | `[Messages]` | OK, Close, Cancel | The message layer's ways out |
| `Message_Copy` | `[Messages]` | Copy message | The message's copy button |
| `Message_Copy_Failed` | `[Messages]` | Could not copy | The copy button when the clipboard is held |
| `Log_Folder_Failed` | `[Messages]` | The log folder could not be opened. | Open log folder's failure |
| `Link_Open_Failed` | `[Messages]` | The page could not be opened. | A Help link's failure |
| `Link_Copy` | `[Messages]` | Copy link | A Help link's failure, its action |

## What must the build prove, row by row?

Every row is one behavioural check in `D01 T01 §7`, named in the last column, driven against the built window: the trigger is performed, and the result or the failure is read back.

| Element | Trigger | States | Result | Failure | Check in `D01 T01 §7` |
| --- | --- | --- | --- | --- | --- |
| File, Preferences | Click; Alt+F, P; Ctrl+, | Always enabled | Preferences opens for this tool, focused | A second open brings the first forward | `window: preferences opens once` |
| File, Logging, Open log file | Click; Alt+F, L, L | Enabled when the log file exists, else disabled with its reason | The log surface opens on the file | Missing, unreadable or malformed: the surface opens and states it inside itself, no dialog | `window: open log file and its refusal` |
| A disabled menu item | Hover; arrow keys onto it | Disabled with a reason | The reason shows as a tooltip on hover and on keyboard focus, and is the item's help text; it cannot be chosen by click, Enter or access key | None can occur: the reason is the framework's table, present for every disabled item | `window: a disabled item says why, by mouse and by keyboard` |
| File, Logging, Open log folder | Click; Alt+F, L, F | Enabled while the folder exists, else disabled with `File_Logging_Folder_Unavailable` | Explorer opens on the folder, the log selected when it is there | Error `Log_Folder_Failed` with the path | `window: open log folder and its refusal` |
| The log items' availability | Open File, Logging on a first run, after the log is deleted with its folder kept, and with the folder removed | The three states | First run: both disabled with their own reasons. Log deleted: Open log file disabled with `File_Logging_Unavailable`, Open log folder enabled. Folder removed: both disabled with their own reasons. On a first run and after the folder is deleted, Open log folder's reason reads "The log folder does not exist." as its tooltip on keyboard focus and as its UI Automation help text | None can occur: availability is read when the menu opens | `window: the log items follow the file and the folder` |
| File, Minimize | Click; Alt+F, N; Esc with nothing open | Always | The window minimizes | None can occur: minimizing a window the process owns does not fail | `window: minimize, and Esc closes a menu first` |
| File, Close | Click; Alt+F, C; Alt+F4; caption close | Always | Shutdown runs and the window closes | A failed settings write is shutdown's message; the window closes on a retry that succeeds or on Close anyway, and stays on Cancel | `window: close persists settings` |
| Help, Check for updates | Click; Alt+H, U; the same again while the check runs | Idle; a check running | Idle: the check runs, and its result is one of the update notices. Running: the item reads `Help_Update_Cancel` and cancels the check, with no notice; a second check is never started | The update notices' failure presentations (`D01 T03 §5`) | `window: update check is single-flight` |
| Help, Home, Downloads, Support, Report a problem | Click; Alt+H and the access key | Always | The default browser opens the item's framework constant URL | Error `Link_Open_Failed`, URL selectable, "Copy link" | `window: help links open, and refuse without a browser` |
| Help, About | Click; Alt+H, A | Always | The About dialog for this tool's descriptor | None can occur: the descriptor is compiled into the tool; an About already open is brought forward | `window: about shows this tool's descriptor` |
| Heading icon | Click; Enter or Space when focused | Always | The About dialog; its accessible name and tooltip are `Heading_About` | As Help, About | `window: heading icon opens about` |
| Status, state segment | Click; Enter when focused | Always | The log surface opens | No log yet: the surface's empty state (`D01 T03 §4`) | `window: status opens the log` |
| Status, task segment | Enter when focused | Focusable only while a task runs | Offers to cancel the task it shows, by name | A task that cannot be cancelled says so in its tooltip | `window: task segment cancels` |
| Status, task segment with two tasks | Start a tool's action, then Check for updates, and let the check end first | Shows the tool's action throughout | The check's result line reaches the state segment; the segment keeps showing the action and its progress, then empties when the action ends | The check's failure is its update dialog's; the action's display is untouched | `window: overlapping tasks keep the shown one` |
| Message copy | Ctrl+C; "Copy message" | Always | The clipboard holds the title, severity, summary and body as text | The clipboard held by another program: the button says "Could not copy" (`Message_Copy_Failed`) for two seconds and the message stays | `window: a message copies whole` |
| Message buttons | Click; Enter; Esc; caption close; Alt+F4 | Default per the rules above | The button's action; focus returns; Alt+F4 acts as the caption close and the tool stays open | The action's own failure is its notice's (`D01 T03 §5`, `§6`); if the opener is gone, focus goes to the content region | `window: message keys, default and focus return` |
| Menu bar | Alt; F10; arrows; Esc | Always | Keyboard path as in the key table | None can occur: the menus are built from the framework's tables at startup | `window: keyboard reaches every item` |
| Maximize and restore | Caption button; double-click on the caption; Win+Up and Win+Down | Normal or maximized | The window maximizes to the monitor's work area and restores to its last normal bounds | Restored bounds now off every monitor: restored centred on the window's current monitor | `window: maximize and restore by every route` |
| Snap layouts | Hover the maximize button on Windows 11; Win+Z | Windows 11 | The snap layout flyout opens and a chosen layout places the window | Windows 10: no flyout, the button maximizes | `window: the maximize button reports itself for snap` |
| Remembered geometry | Close and reopen; reopen with that monitor disconnected | Per monitor | The window reopens at its size, position and maximized state; with its monitor gone, centred on the primary monitor at its size | A stored position off every monitor is not used | `window: geometry reads back, and recovers from a missing monitor` |
| Density | Change the density in Preferences, at the minimum window size | Compact, Normal, Spacious | Menu bar, heading block and status bar take their density heights; the heading icon's left and top offsets and its gap to the title measure the density's padding; every acting status segment's target measures at least 24 x 24; nothing is clipped | A density the settings file names but the scale lacks: Normal, with the value logged | `window: every density fits at the minimum size` |
| Taskbar progress | A task running, then succeeding, failing, ending part done, cancelled, or ending while another runs | As the status bar rules | Normal or indeterminate while running; cleared on success or cancel; error or paused held until the window is activated, then cleared, on a full bar for an indeterminate task; the next task's progress at once on a handoff | No taskbar button (Explorer not running): the status bar alone shows progress, and nothing fails | `window: the taskbar follows the shown task` |
| Window's Tab order | Tab and Shift+Tab from the window's first focus | With and without a running task | Heading icon, content, state, task (only while one runs), elevation, and back; Shift+Tab the reverse | None can occur: the order is fixed by the framework | `window: tab order follows the page` |
| Heading subheading | Open a tool whose chosen-language pack lacks `Program_Purpose` | Key in the common or English level, or in none | The English purpose shows; with no level holding it, no subheading and the key reported missing | Never a blank subheading while any level holds the key | `window: subheading falls back` |
| Tools adding menu items | A tool's code | Never | Impossible: the framework's interface for tools has no menu call | A tool that tries does not compile | `window: the tool interface exposes no menu` |
