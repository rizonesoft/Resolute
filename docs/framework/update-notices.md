# The update notices

Every Resolute tool checks for a newer version the same way and says what it found through the same four notices, owned by the framework. This page specifies them part by part, so that `D01 T01 §5` can build the check and `D01 T01 §7` can prove the notices without inventing a control or a string. It is `D01 T03 §5` (`todo/01-framework/TODO-03-framework-surfaces.md`).

A user learns that a newer version exists and reaches it in one press; a user who asked gets an answer either way; and a user of a product that has been folded into another learns where it went. So the notices report and link. They never download, never install, and never open a page the user did not ask for.

The notices are messages of the one message layer in [`standard-window.md`](standard-window.md#how-does-every-notice-reach-the-user), not a dialog of their own: its window, severity icons, copy, focus, keyboard and logging all apply unchanged. The settings they read and write are the Updates page's in [`preferences.md`](preferences.md#what-is-on-the-updates-page). A specification cannot prove behaviour, so the page ends in a matrix ([below](#what-must-the-build-prove-row-by-row)) whose every row is a check `D01 T01 §7` runs against a fixture update server.

## What does the AutoIt dialog have, and where does each part go?

Read from `resolute_au3/SDK/Includes/Update.au3`, every line printed from the file.

| AutoIt part | Source | Verdict |
| --- | --- | --- |
| The check: the update file downloaded to a temporary file | `Update.au3:76-88` | Kept as the check `D01 T01 §5` builds. The file's format stays, so shipped builds keep working. |
| The wait: a loop sleeping 250 ms until the download ends, on the tool's own thread, with no limit | `Update.au3:79-81` | A defect, fixed. A server that never answered froze the tool for as long as it took. The check runs off the UI thread, can be cancelled, and gives up after a stated time ([below](#what-happens-while-a-check-runs)). |
| A download that fails: nothing at all is shown | `Update.au3:90`, `:200` | A defect, fixed. When the bytes read and the file's size disagreed, the function fell through without a word, even when the user had asked. A check the user asked for always answers. |
| Update-available form: a window of its own, always on top | `Update.au3:109-148` | Changed into the update-available notice, a message. Always on top (`:119`) is cut, as it is for every message. |
| Its icon, clickable, and a clickable build number | `Update.au3:124-125`, `:135`, `:143-144` | Cut. Two unlabeled click targets did what the button does. The button is the one way to the page. A third handler was attached to a control that was never created (`:145`). |
| "Current Build" and "Update Build", whole numbers in red and blue | `Update.au3:128-136` | Changed to "Installed version" and "Available version", in the ordinary text colour and monospace. The colours are cut: red said nothing was wrong. |
| "Read more" button, opening the link the server sent | `Update.au3:140`, `:146`, `:221-223`; the link read at `:98` | Changed. The label names the action, "Open download page" (`DESIGN.md` §11). The link was opened whatever it was; it is now checked first ([below](#which-page-does-the-button-open)). |
| No way out but the caption's close button | `Update.au3:122` | Changed. The notice has Close. |
| The generic form, for "latest" and for "error", shown only when the user asked | `Update.au3:150-196` | Changed into two notices with their own summaries. "Latest" and "error" shared one form told apart by colour and icon (`:155`, `:165`). |
| "Error" decided by a missing `LatestBuild` | `Update.au3:161` | Changed. A file with no build number was the only failure ever shown, under a line about the Internet connection whatever the cause. The failures are told apart ([below](#what-are-the-notices)). |
| Titles "Congratulations!" and "Something went wrong!" | `en.lng:189-190` | Cut. Having the latest version is not an achievement, and the second names nothing. Each notice's summary says what happened. |
| "Do not check for updates at startup" checkbox, on both forms | `Update.au3:138-139`, `:188-189`, `:210-212` | Changed into "Skip this version". The checkbox showed and wrote `CheckForUpdates`, the switch that decides whether the tool checks at all (`ReBar.au3:614`), and it wrote it whenever either form closed, by any way out. Ticking it on one notice turned every later check off. How often to check is the Updates page's. |
| A setting written straight to the file | `Update.au3:212` | Changed. Every write goes through the settings writer and is read back (`D01 T01 §2`). |

## When does a check run, and who asked?

A check has one of two callers, and the notices behave differently for each.

| Caller | When | Its manner |
| --- | --- | --- |
| The user | Help, Check for updates ([`standard-window.md`](standard-window.md#what-is-on-the-help-menu)); Check now on the Updates page | **It always answers.** Whatever the outcome, a notice says so. |
| The schedule | Once the main window is showing, when a check is due by `UpdateFrequency` (every start, daily, weekly) and `UpdateLastCheck` | **It speaks only when there is something to act on.** It opens a notice for a newer version the user has not skipped, and for a successor not yet shown. Otherwise it leaves one line in the status bar and one in the log, and opens nothing. |

A scheduled check never delays the window, never runs when `UpdateFrequency` is `Never`, and its notice never appears before the main window or over another application.

## What happens while a check runs?

| Part | Rule |
| --- | --- |
| Where it runs | Off the UI thread. The tool is usable throughout, whoever asked. |
| How it shows | As a task of the status bar, named `Update_Task` ("Checking for updates"), indeterminate ([`standard-window.md`](standard-window.md#how-does-each-segment-change)). There is no progress window. |
| One at a time | While a check runs, Help, Check for updates and Check now are disabled with `Help_Update_Running`, as the window rules. |
| Cancel | The task segment's cancel ends it. A cancelled check shows no notice, writes one log line and records nothing. |
| Time limit | A check that has not finished after 15 seconds is ended as a failure, "timed out". |
| What it sends | One `https` request for the tool's update file, and nothing else: no identifier, no version, no language, nothing about the machine or the user, in the address or in a header the tool adds. |
| What it trusts | Nothing but the shape of the answer. The file is read as an update file or refused (`D01 T01 §5`); a value from it is shown only where this page says, as plain text, and a link from it is used only as [below](#which-page-does-the-button-open). |

## What are the notices?

Four. Each is one call to the message layer; the window's title is the tool's name, as for every message.

### A newer version is available

| Part | Value |
| --- | --- |
| Severity | Information |
| Summary | `Update_Available_Title` ("Version %1 of %{Program.Name} is available"), %1 the available version |
| Body | `Label_Build_Current` ("Installed version:") and `Label_Build_Update` ("Available version:"), each followed by its version in monospace, selectable; then `Update_Opens_Site` ("The download page opens on %1 in your browser."), %1 the host that will open |
| Buttons | `Button_Update` (`&Open download page`), the default; `Button_Update_Skip` (`&Skip this version`); `Button_Close` |
| Shown | To the user who asked: always. By the schedule: unless `UpdateSkipVersion` holds this version |
| After a skip | When the user asked and this version is the skipped one, the body adds `Update_Skipped_Note` ("You chose not to be told about this version automatically.") and Skip this version is not offered |

- **Open download page** opens the page in the browser and closes the notice. Nothing is downloaded by the tool.
- **Skip this version** writes this version to `UpdateSkipVersion` through the settings writer, reads it back, and closes the notice. Scheduled checks then say nothing about this version, and speak again when a newer one appears. It never turns checking off, and it is undone on the Updates page (`Button_Update_Unskip`). When the write cannot be confirmed, the version is not skipped and the message layer says `Update_Skip_Failed` ("Your choice could not be saved: %1"), with the settings file's path and the Windows reason, with Close.
- **Close**, Esc and the caption's close button leave everything as it was. A scheduled check will say it again when it next runs.

**Versions** are compared as `D06 T01 §11` defines them, a preview being older than the release it leads to. When the update file carries only the AutoIt build number, the build numbers are compared (`D01 T01 §5`) and the rows show them as `Update_Build_Number` ("build %1"). The notice shows what was compared, never a version it worked out.

### This is the latest version

| Part | Value |
| --- | --- |
| Severity | Information |
| Summary | `Label_Message_Latest` ("You have the latest version of %{Program.Name}.") |
| Body | `Label_Build_Current` and the installed version. When the installed version is newer than the published one (a preview build), `Update_Newer_Than_Published` ("The newest published version is %1.") |
| Buttons | `Button_Close`, the default |
| Shown | Only to the user who asked. The schedule leaves `Update_Result_Latest` ("Update check finished: you have the latest version.") in the status bar's state segment and the log |

### The check did not finish

| Part | Value |
| --- | --- |
| Severity | Error |
| Summary | `Update_Failed_Title` ("The update check did not finish") |
| Body | One of the four reasons below, then `Update_Failed_Unchanged` ("%{Program.Name} is unchanged. You have version %1.") |
| Buttons | `Button_Update_Retry` (`&Try again`), the default; `Button_Update_Page` (`&Open download page`), which opens the tool's own page from its descriptor, so the user can look for themselves; `Button_Close` |
| Shown | Only to the user who asked. The schedule leaves `Update_Result_Failed` ("Update check did not finish: %1") in the state segment and the log, and the Updates page shows it beside Last checked ([`preferences.md`](preferences.md#what-is-on-the-updates-page)) |

| Failure | Body |
| --- | --- |
| No connection: the name does not resolve, or no route | `Label_Message_Error` ("The latest version could not be looked up.") and `Label_Message_Internet` ("Check your Internet connection and try again.") |
| The server refused or failed: any answer but success | `Update_Failed_Server` ("The update server answered with an error (%1)."), %1 the status |
| The answer is not an update file: cut short, not text, no `[Update]` section, no version or build in it | `Update_Failed_File` ("The update server's answer could not be read.") |
| Timed out | `Update_Failed_Timeout` ("The update server did not answer within 15 seconds.") |

A failure never reads as "latest": the three outcomes have three summaries and two severities, and `UpdateLastCheck` is left as it was, so the Updates page does not claim a check that did not complete.

### The product has moved

The consolidation announcement, for a tool whose update file carries `Successor`: [below](#what-does-a-retired-product-say).

## Which page does the button open?

A link in the update file is the server's word, so it is checked before it is used.

| Rule | Detail |
| --- | --- |
| What is allowed | A link that is `https`, whose host is the host of the tool's own product page in its descriptor (`D01 T01 §1`) or a name under it, and that carries no user name, password or port. The live files meet it (`resolute_au3/SDK/www/update/Firemin.ru`: `https://rizonesoft.com/downloads/firemin/`). |
| A link that is not allowed, or is missing | Refused. One log line names it. The button opens the descriptor's product page instead, and the notice is otherwise unchanged. |
| What the user is told | `Update_Opens_Site` names the host that will open, before the press. |
| At whose level | The browser is started as the signed-in user, never with the tool's administrator rights, when the tool is elevated (`D01 T01 §7`). A repair tool runs elevated; a browser it started must not. |
| A page that cannot be opened | The window's Error `Link_Open_Failed`, with the link selectable and its "Copy link" action ([`standard-window.md`](standard-window.md#what-is-on-the-help-menu)). The update notice has closed; the choice is not lost, because nothing was recorded by opening. It never falls back to starting the browser elevated. |

## What does a check record?

| Setting | Written when | By |
| --- | --- | --- |
| `UpdateLastCheck` | A check completes: an answer arrived and was read as an update file, whatever it said | The check, for either caller |
| `UpdateSkipVersion` | Skip this version is pressed | The notice |
| `UpdateSuccessorShown` | The announcement below has been shown and closed | The notice |

Each goes through the settings writer and is read back (`D01 T01 §2`). **A record that cannot be written never changes what the user is shown:**

- **`UpdateLastCheck`:** the result is shown as it is, because it is true. The failure goes to the log. The Updates page goes on showing the time the file holds, and the next scheduled check is due as that time says, so it runs again at the next start that is due. Nothing is raised about it: a notice about bookkeeping would interrupt for something the user cannot act on, and the settings writer's own failure is reported where the user saves settings.
- **`UpdateSkipVersion`:** `Update_Skip_Failed`, above. The user chose something that did not happen, so they are told.
- **`UpdateSuccessorShown`:** logged. The announcement is shown again at the next scheduled check, which errs towards telling.

## What does a retired product say?

Four products are folded into others (decision 12, `docs/brainstorm/2026-09-16-completion-brainstorm.md`). A retired product's update file stays published and gains a `Successor` key, the successor's display name and nothing more; the sentence around it comes from the user's language pack.

| Part | Value |
| --- | --- |
| Who sees it | Any tool built on this framework whose update file carries a usable `Successor`, whatever version it is |
| Severity | Information |
| Summary | `Update_Successor_Title` ("%{Program.Name} is now part of %1"), %1 the successor's name |
| Body | `Update_Successor_Body` ("%{Program.Name} is no longer updated on its own. New versions are published as part of %1."), then `Update_Opens_Site` |
| Buttons | `Button_Update_Successor` (`&Open the %1 page`), the default, under the link rules above; `Button_Close` |
| Before anything else | It replaces the update-available notice. A tool with a successor never shows both, and Skip this version is not offered: there is no later version of this product to wait for |
| The name is checked | It is used only when it is 1 to 64 characters with no control character or line break, and it is drawn as plain text. A name that fails is ignored with one log line, and the file is treated as an ordinary update file |
| Shown once by itself | A scheduled check shows it when `UpdateSuccessorShown` does not hold this successor's name. Closing it by any way out, the button included, writes the name there. A different successor later is shown again |
| Always when asked | A check the user asked for shows it every time |

**What the four AutoIt products show.** Chromin, Edgemin, Watermin and DVDRepair are AutoIt builds, and their dialog takes its text from their own language packs (`Update.au3:126`), which have no such sentence. They show their existing "update available" form, and its button takes the user to the successor's page, because the file's build number is raised and its link points there. That page is where they are told, which `D06 T01 §5` owns. The announcement above is for tools built on this framework.

## Which keys, announcements and sizes apply?

The message layer's, with nothing added ([`standard-window.md`](standard-window.md#how-does-every-notice-reach-the-user)):

- **Keyboard.** Enter presses the default, Esc presses Close, Tab moves between the buttons, each button answers its access key, and Ctrl+C copies the whole notice. Focus opens on the default and returns to where it was.
- **Announced.** A notice's summary is raised when it opens. A scheduled check's result line is raised with the task's end, as the status bar rules.
- **Scaling and density.** The message's, at its 480 width; a long successor name wraps in the summary and in its button, and is never cut.
- **Right-to-left text.** As [`language-page.md`](language-page.md#how-does-it-scale-and-what-about-right-to-left-languages) states; a version and a host stay left to right.

**One change to the message layer.** Its button sets read "action plus Cancel; two actions plus Cancel". A notice that asks nothing has nothing to cancel, so [`standard-window.md`](standard-window.md#how-does-every-notice-reach-the-user) now says the way out beside actions is Close where declining changes nothing, and Cancel where it stops something. These notices use Close.

## What is logged?

One line per check and one per choice, through the log writer (`D01 T01 §3`), beside the line the message layer writes for every message:

| Event | Level | Line |
| --- | --- | --- |
| A newer version found | Information | `Update_Log_Available` ("Update check: version %1 is available; version %2 is installed.") |
| Latest | Success | `Update_Result_Latest` |
| Failed | Warning | `Update_Result_Failed`, with the reason |
| Cancelled | Information | `Update_Log_Cancelled` ("Update check cancelled.") |
| A version skipped | Information | `Update_Log_Skipped` ("Version %1 will not be announced automatically.") |
| A link refused | Warning | `Update_Log_Link_Refused` ("The update file's link was not used: %1") |
| A successor announced | Information | `Update_Log_Successor` ("%{Program.Name} is now part of %1.") |
| A successor's name refused | Warning | `Update_Log_Successor_Refused` ("The update file's successor name was not used.") |
| A record that could not be written | Warning | `Update_Log_Record_Failed` ("%1 could not be saved: %2") |

## Which strings do the notices use?

In `[Update]` unless marked. Every text above has a key here.

| Key | English | Verdict |
| --- | --- | --- |
| `Label_Message_Latest` | You have the latest version of %{Program.Name}. | Reworded (`en.lng:192`) |
| `Label_Message_Error` | The latest version could not be looked up. | Reworded (`en.lng:193`) |
| `Label_Message_Internet` | Check your Internet connection and try again. | Reworded (`en.lng:194`): "Please" and the capitals go |
| `Label_Build_Current` | Installed version: | Reworded from "Current Build:" (`en.lng:195`) |
| `Label_Build_Update` | Available version: | Reworded from "Update Build:" (`en.lng:196`) |
| `Button_Update` | `&Open download page` | Reworded from "Read more" (`en.lng:198`) |
| `Update_Available_Title` | Version %1 of %{Program.Name} is available | New; replaces `Window_Title_Available` and `Label_Message_Update` |
| `Update_Opens_Site` | The download page opens on %1 in your browser. | New |
| `Button_Update_Skip` | `&Skip this version` | New; replaces `CheckBox_NoUpdate` |
| `Update_Skipped_Note` | You chose not to be told about this version automatically. | New |
| `Update_Skip_Failed`, in `[Messages]` | Your choice could not be saved: %1 | New |
| `Update_Build_Number` | build %1 | New |
| `Update_Newer_Than_Published` | The newest published version is %1. | New |
| `Update_Failed_Title` | The update check did not finish | New; replaces `Window_Title_Error` |
| `Update_Failed_Unchanged` | %{Program.Name} is unchanged. You have version %1. | New |
| `Update_Failed_Server`, `Update_Failed_File`, `Update_Failed_Timeout` | As the failures table gives them | New |
| `Button_Update_Retry` | `&Try again` | New |
| `Button_Update_Page` | `&Open download page` | New: the same label, for the tool's own page |
| `Update_Task` | Checking for updates | New |
| `Update_Result_Latest`, `Update_Result_Failed` | Update check finished: you have the latest version. Update check did not finish: %1 | New |
| `Update_Successor_Title`, `Update_Successor_Body` | As the announcement gives them | New |
| `Button_Update_Successor` | `&Open the %1 page` | New |
| `Update_Log_Available`, `Update_Log_Cancelled`, `Update_Log_Skipped`, `Update_Log_Link_Refused`, `Update_Log_Successor`, `Update_Log_Successor_Refused`, `Update_Log_Record_Failed` | As the log table gives them | New |
| `Button_Close`, in `[Messages]` | Close | The message layer's. The `[Update]` copy (`en.lng:199`) is cut as a duplicate |
| `Help_Update_Running`, in `[Menus]`; `Link_Open_Failed`, `Link_Copy`, in `[Messages]` | As [`standard-window.md`](standard-window.md#which-strings-does-the-window-add) gives them | The window's, used as they are |
| `Window_Title_Available`, `Window_Title_Congratulations`, `Window_Title_Error`, `Label_Message_Update`, `CheckBox_NoUpdate` | | Cut (`en.lng:188-191`, `:197`). A message's title is the tool's name; "Congratulations!" and "Something went wrong!" go with the forms; the checkbox goes with its mislabeled switch. For `D01 T03 §7`'s audit |

## What must the build prove, row by row?

Every row is one behavioural check in `D01 T01 §7`, driven against the built tool and a fixture update server; where a row names a setting or a log line, the check reads the settings file and the log back as well as the notice.

| Element | Trigger | States | Result | Failure | Check in `D01 T01 §7` |
| --- | --- | --- | --- | --- | --- |
| A check the user asked for | Help, Check for updates; Check now on the Updates page | Newer; latest; failing | A notice in every case: update available, latest, or did not finish | The failure rows below | `update: a check the user asked for always answers` |
| A scheduled check | Start the tool with a check due, the server giving latest, then failing | Latest; failing | No notice; the state segment and the log carry `Update_Result_Latest` or `Update_Result_Failed`; the window is usable before the check ends | The stated results are the quiet presentations | `update: a scheduled check is quiet unless there is news` |
| The schedule | Start with `UpdateFrequency` at each value and `UpdateLastCheck` an hour, two days and eight days old | Startup; Daily; Weekly; Never | A check runs exactly when due; never for `Never`; `UpdateLastCheck` reads back as the completion time | A server that fails: `UpdateLastCheck` unchanged, so the check is due again | `update: checks run when the frequency says` |
| While it runs | Start a check against a slow server; use the tool; open Help | Running | The tool answers; the task segment reads `Update_Task`; Check for updates and Check now are disabled with `Help_Update_Running` | None can occur: the check holds no UI thread | `update: a running check never blocks the tool` |
| Cancel | Cancel the task from the status bar | Running | No notice; `Update_Log_Cancelled`; `UpdateLastCheck` unchanged; the items are enabled again | None can occur: a cancel records nothing | `update: a cancelled check says nothing` |
| What it sends | Capture the fixture server's request | | One `https` request for the update file; no query, no added header carrying a version, language, machine or user | None can occur: the request is fixed | `update: the check sends nothing about the user` |
| Update available | A server file with a newer version | Asked; scheduled | The notice with both versions in monospace, the host that will open, Open download page as the default, Skip this version and Close; `Update_Log_Available` | A file with no usable version: the not-an-update-file failure | `update: a newer version is announced with both versions` |
| Version comparison | Files with a newer release, a newer preview, the same version, an older one, and only a build number | Each | Newer: the notice. Same or older: latest, with `Update_Newer_Than_Published` when installed is newer. Build number only: compared as numbers and shown as `Update_Build_Number` | None can occur: every pair compares | `update: versions compare by the release scheme` |
| Open download page | Press it; Enter; Alt+O | An allowed link | The browser opens that link; the notice closes; nothing is downloaded by the tool | The browser cannot be started: `Link_Open_Failed` with the link and Copy link | `update: the button opens the page and downloads nothing` |
| A link that is not allowed | Server files whose link is `http`, on another host, carries a user name, is a file path, or is missing | Each | `Update_Opens_Site` names the descriptor's host; the button opens the descriptor's page; `Update_Log_Link_Refused` names the refused link | The stated results are the refusal's presentation | `update: only an https link on the tool's own site is used` |
| At the user's level | An elevated fixture tool; Open download page | Elevated | The browser process runs without elevation | Starting it that way fails (seeded): `Link_Open_Failed`, and no elevated browser is started | `update: an elevated tool opens the page unelevated` |
| Skip this version | Press it; Alt+S; then let a scheduled check find the same version, then a newer one; then ask | | `UpdateSkipVersion` reads back as that version; the scheduled check is quiet for it and announces the newer one; asking shows it with `Update_Skipped_Note` and no Skip button; `UpdateFrequency` is unchanged | The write cannot be confirmed (seeded): `Update_Skip_Failed` with the path and reason, the key unchanged, the next scheduled check announces it | `update: skip silences one version and nothing else` |
| Close | Close; Esc; the caption's close button | | Nothing written; the next scheduled check announces it again | None can occur: closing records nothing | `update: closing a notice changes nothing` |
| Latest | Ask, with the server giving the installed version | | The latest notice with the installed version; Close the default; `Update_Result_Latest` in the log | A failing check never shows this notice, as the rows below | `update: latest is said only when it was checked` |
| No connection | Ask with the fixture host unresolvable | | The failed notice with `Label_Message_Error`, `Label_Message_Internet` and the installed version; severity Error; `UpdateLastCheck` unchanged | The stated result is the failure presentation | `update: no connection is not reported as latest` |
| Server error | Ask with the server answering 404, then 500 | | `Update_Failed_Server` with the status | The stated result is the failure presentation | `update: a server error names its status` |
| Not an update file | Ask with an answer cut short, a page of HTML, and a file with no `[Update]` section | Each | `Update_Failed_File`; nothing from the answer is shown | The stated result is the failure presentation | `update: an unreadable answer is refused whole` |
| Timed out | Ask with a server that never answers | | After 15 seconds `Update_Failed_Timeout`; the tool usable throughout | The stated result is the failure presentation | `update: a silent server ends at the limit` |
| Try again | On the failed notice, with the server now answering | | The notice closes and a new check runs, ending in its own notice | The check failing again: the failed notice again | `update: try again runs the check again` |
| The failed notice's page button | Press `Button_Update_Page` | | The descriptor's product page opens, unelevated | `Link_Open_Failed` | `update: a failed check still offers the tool's page` |
| Recording the check | Ask with the settings file read-only (seeded), the server giving latest | | The latest notice as normal; `Update_Log_Record_Failed`; the Updates page still shows the earlier time; the saved value unchanged; a scheduled check is due at the next start | The stated results are the failure presentation | `update: a result is shown even when it cannot be recorded` |
| The announcement | A server file with `Successor` and a higher build | Scheduled; asked | The announcement, not update available: summary and body naming the successor, its page button, Close, no Skip; `Update_Log_Successor` | A link not allowed: the descriptor's page, as the link row | `update: a retired product names its successor` |
| Shown once | Close the announcement; start again with a check due; then ask; then change the file's successor | | `UpdateSuccessorShown` reads back as the name; the next scheduled check is quiet; asking shows it; a different name is shown by the schedule again | The record cannot be written (seeded): logged, and the next scheduled check shows it again | `update: the announcement is shown once by itself` |
| A successor name that is not usable | Files whose `Successor` is empty, 200 characters long, or holds a line break | Each | No announcement; the file is treated as an ordinary update file; `Update_Log_Successor_Refused` | The stated results are the refusal's presentation | `update: a bad successor name is ignored` |
| In two languages | The update-available notice and the announcement with an English and a German pack | | Every sentence comes from the pack; only the version, the host and the successor's name come from elsewhere | A key missing from the pack shows its English, as every string does | `update: the notices speak the user's language` |
| Keyboard and announcement | Open each notice by keyboard; Tab; each access key; Ctrl+C | | The default has focus; every button is reached; the summary is announced once; the clipboard holds the whole notice | None can occur: the notices are the message layer's | `update: the notices are the message layer's` |
