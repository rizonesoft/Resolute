# The splash, Donate and the string audit

This page records two removals and one audit. The splash screen and every Donate surface are cut, each with its reason and what reversing would cost. Then every key of the framework's language pack is ruled on, one by one: keep, fix or cut. It is `D01 T03 §7` (`todo/01-framework/TODO-03-framework-surfaces.md`), and it closes the work of `§1` to `§6`, whose pages already ruled on most of these keys.

A tool for a broken machine opens at once and asks for nothing. And a suite that speaks 35 languages should not ship a typo, a joke or a dead string in any of them. The first is why two surfaces go; the second is why every key is accounted for here, so that the packs `D08 T01 §2` composes carry no string nobody decided on.

## What is cut, and why?

Read from the source, every line printed from the file.

### The splash screen

| Part | Source | What it did |
| --- | --- | --- |
| The window: 250 x 150, a cursor animation, a message and a progress bar | `resolute_au3/SDK/Includes/Splash.au3:47-72` | Shown before the tool's own window |
| Eight steps, each updating the message | `resolute_au3/SDK/Concrete/ReBar/ReBar.au3:480-497`, closed at `:607`; `en.lng:125-132` | "Initializing", "Loading Localizations", "Setting Resources" and five more |
| A pause after every message | `Splash.au3:79-82`; the pause set at `ReBar.au3:479` | `Sleep($g_iSplashDelay)`, 100 ms a step: the tool waited so that its own waiting message could be read |
| A debug box when the animation file is missing | `Splash.au3:49-51` | `MsgBox(0, "Error", <path>)`: a file path shown as an error, then the splash went on without its icon |

**Verdict: cut, with its eight `Loading_*` keys.**

- **Reason.** A tool that starts instantly has nothing to splash over (`DESIGN.md` §10), and this splash made startup slower to justify itself: about 0.8 seconds of deliberate pauses. Its messages describe a startup sequence a user should never perceive, and "Setting Resources" tells nobody anything.
- **What a slow start shows instead.** The tool's own window, at once. Nothing is added in the splash's place.
- **Reversal cost.** One window and one block of eight keys. Nothing else depends on it.
- **A consequence elsewhere.** [`standard-window.md`](standard-window.md#how-does-every-notice-reach-the-user) said a missing splash animation is a log line. With the splash cut there is no animation to look for, so that sentence now says nothing is checked and nothing logged.

### Donate

Four surfaces, one decision.

| Surface | Source | What it did |
| --- | --- | --- |
| The Donate dialog, always on top, raised while the tool was closing | `resolute_au3/SDK/Includes/Donate.au3:67-117`; raised at `ReBar.au3:952-956` | The first time a tool was closed on a computer, and again after each new build, closing did not close: it opened a request for money. The dialog's own close then ended the tool (`Donate.au3:139-145`) |
| What it remembered | `ReBar.au3:954-955` | It wrote a `[Donate]` section to the settings file holding `DonateName`, the computer's name, and `DonateBuild` |
| The strip in the main window: an icon and a line asking for $10 | `ReBar.au3:596-605`; `en.lng:60` | Always visible, in every tool |
| Help, "Donate a little something" | `ReBar.au3:545`, `:559`; `en.lng:113` | Opened the PayPal page |
| Two tips in About | `en.lng:34-35` | "Donate to our Cause" and a message whose line breaks are typed as `\rn` and so showed as text |

**Verdict: all four cut, with the three `[Donate]` keys, `Help_Donate`, `Tip_Title_Donate` and `Tip_Message_Donate`.**

- **Reason.** A request for money is not something a system utility does, least of all at the moment a user who has just repaired something is trying to leave. A tool that interrupts its own exit to ask teaches its user to distrust the next dialog it shows, which in this suite may be the one that matters.
- **Where support lives.** In About, as links (`D06 T01 §17`), where a user who wants to support the publisher can find the way and nobody else is asked.
- **The settings file.** Nothing writes a `[Donate]` section or a computer's name again, and nothing reads one. A section an AutoIt tool left behind is left exactly as it is: the settings file stays readable by the AutoIt tool, and removing another program's data is not this tool's to do.
- **Reversal cost.** One dialog, one strip, one menu item, two tips and six keys. The menu item's place is noted in [`standard-window.md`](standard-window.md#what-is-on-the-help-menu), which no longer lists it.

## How is the audit read?

The pack is `resolute_au3/Resolute/Language/ReBar/en.lng`. It holds 173 key lines: 5 in two header sections that describe the pack, and 168 in ten sections of strings (`[Messages2]` is present and empty). One key, `Tip_Twitter`, is in `[About]` twice, so the ten sections hold 167 distinct keys. Every one is below, once.

| Verdict | Means |
| --- | --- |
| Keep | The key and its English stay. |
| Fix | The key stays and its English changes to the text quoted. **Fix (kept)** leaves the meaning alone (a typo, a capital, punctuation, an access key), so the 34 other languages keep their translations. **Fix (dropped)** changes what the string says, so existing translations are dropped and the key shows English until it is translated again: an old sentence must never sit under a new meaning. |
| Cut | The key ships in no pack, in any language. |

The **Owner** column names the page that specifies the string's use. Where it names another page, that page's strings table gives the same text, word for word. An ampersand marks an access key and is part of the text. Keys that the six pages add are not here: this audit rules on the AutoIt keys, and each new key is in its own page's strings table. `D08 T01 §2` composes the shipped packs from both.

## The header sections

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `[Main]` `Product` | ReBar Framework | Fix (kept): the framework's name in the suite, "Resolute Framework". Not shown to users | `D08 T01 §2` |
| `[Main]` `Version` | 8 | Keep, as the pack format's version | `D08 T01 §2` |
| `[Language]` `Name` | English | Keep. The Language page shows it | [`language-page.md`](language-page.md) |
| `[Language]` `Code` | en | Keep. It must agree with the file's name, which is the pack's identity | [`language-page.md`](language-page.md) |
| `[Language]` `Encoding` | Unicode (UTF-16) LE BOM | Cut. Read and never used (`ReBar.au3:1110`); a file's encoding is what its bytes are, and a line that can disagree with them is a second source | This audit |

## `[Translations]`

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `About`, `Custom`, `Donate`, `Logging`, `Menus`, `Messages`, `Messages2`, `Preferences`, `Update`, `Versioning` | Each its own name | Cut, all ten. Dead: no line of the AutoIt source reads the section (searched for `"Translations"` in `resolute_au3/SDK`, no hit). A list of section names is not a string | This audit |

## `[About]`

The About dialog is built by `D06 T01 §17`, which decides the final text of every row kept here.

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `Window_Title` | About %{Program.Name} | Keep | `D06 T01 §17` |
| `Label_Version` | Version | Keep | `D06 T01 §17` |
| `Label_AutoIt` | Build with AutoIt version | Cut. The tool is not built with AutoIt, and "Build" was "Built" | This audit |
| `Label_Copyright` | Copyright | Keep | `D06 T01 §17` |
| `Tip_Title_Donate` | Donate to our Cause | Cut, with Donate | This audit |
| `Tip_Message_Donate` | When you donate, you help keep our software free... | Cut, with Donate. Its line breaks were typed as `\rn` | This audit |
| `Label_Home` | Homepage | Keep | `D06 T01 §17` |
| `Label_License` | License | Keep | `D06 T01 §17` |
| `Label_Support` | Get Support | Fix (kept): "Get support", as `Help_Support` | `D06 T01 §17` |
| `Tip_Title_Country` | Made in South Africa | Keep | `D06 T01 §17` |
| `Tip_Message_Country` | %{Program.Name} was born in South Africa. | Keep | `D06 T01 §17` |
| `Label_Contributors` | Contributors | Keep | `D06 T01 §17` |
| `Button_Ok` | Ok | Cut. Replaced by `Button_OK` ("OK") in `[Messages]`, one OK for every dialog | [`standard-window.md`](standard-window.md) |
| `Label_RAM` | (RAM) %d MB FREE OF %d MB (%d%) | Cut. About says what the tool is, not how much memory the computer has free, and it said it in capitals | This audit |
| `Label_HDD` | (%s) %.2f GB FREE OF %.2f GB (%d%) | Cut, with `Label_RAM` | This audit |
| `Tip_Twitter` | Follow us on Twitter. | Cut. Dead: no loader reads it. It is in the pack twice (`en.lng:45`, `:47`); both lines go | This audit |
| `Tip_Facebook` | Like us on Facebook. | Cut. A request to be liked is promotion, not support; it goes the way Donate goes | This audit |
| `Tip_Reddit` | Read about us on Reddit. | Cut. Dead: no loader reads it | This audit |
| `Tip_LinkedIn` | Connect with us on LinkedIn. | Cut. Dead: no loader reads it | This audit |
| `Tip_GitHub` | %{Program.Name} on GitHub. | Keep. It is where the source and the issue tracker are | `D06 T01 §17` |
| `Tip_WhatsApp` | Chat with us on WhatsApp. | Cut. Dead: no loader reads it | This audit |

## `[Custom]`

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `Label_Status_Welcome` | Welcome | Cut. The heading's second line is the tool's purpose, from its descriptor, and never a greeting or a status | [`standard-window.md`](standard-window.md) |
| `Label_Status_Updates` | Checking for Updates | Cut. Replaced by `Update_Task` ("Checking for updates"), the status bar's task | [`update-notices.md`](update-notices.md) |

## `[Donate]`

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `Label_Heading` | How about a small donation to keep our software forever free? | Cut, with Donate | This audit |
| `Label_Message` | Click on the PayPal button below, choose an amount... | Cut, with Donate | This audit |
| `Label_Donate` | Would you consider a small gift of $10... | Cut, with Donate | This audit |

## `[Logging]`

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `Finished` | Finished | Cut. The finished level's prefix, `Level_Finished`, says it; this second copy also fed the icon search | [`log-surface.md`](log-surface.md) |
| `success` | success | Cut. One of the words the list searched lines for to pick an icon; the search is cut whole | [`log-surface.md`](log-surface.md) |
| `Response_Received` | Response Received | Cut, with the search | [`log-surface.md`](log-surface.md) |
| `Successfully` | Successfully | Cut, with the search | [`log-surface.md`](log-surface.md) |
| `OK` | OK! | Cut, with the search | [`log-surface.md`](log-surface.md) |
| `Registration_succeeded` | Registration succeeded | Cut, with the search | [`log-surface.md`](log-surface.md) |
| `Initiated` | Initiated | Cut, with the search | [`log-surface.md`](log-surface.md) |
| `Error` | error | Cut, with the search | [`log-surface.md`](log-surface.md) |
| `Failed` | failed | Cut, with the search | [`log-surface.md`](log-surface.md) |
| `Access_Denied` | Access is denied | Cut, with the search | [`log-surface.md`](log-surface.md) |
| `No_Operation_Performed` | No operation can be performed | Cut, with the search | [`log-surface.md`](log-surface.md) |
| `VERSION` | VERSION | Cut. It headed each log with the logging module's own version, in capitals; the header names the tool and its version | This audit |
| `File_Not_Found` | Could not find the '%s' log File. | Cut. Replaced by `Log_Missing` | [`log-surface.md`](log-surface.md) |
| `Showing_File` | Showing '%s' log File. | Fix (dropped): "Opened the log in its default program." | [`log-surface.md`](log-surface.md) |
| `Showing_Error` | Something went wrong: Process ID: %s | Cut. Replaced by `Log_Open_External_Failed`; it printed a process number as an explanation | [`log-surface.md`](log-surface.md) |
| `Opening_File` | Opening the log File. | Cut. Narration of an action that takes one line | [`log-surface.md`](log-surface.md) |
| `Opening_Directory` | Opening the log Folder... | Cut. Narration, as `Opening_File` | This audit |
| `Directory_Not_Found` | Could not find the '%s' log Directory. | Cut. Replaced by `File_Logging_Folder_Unavailable` and `Log_Folder_Failed` | [`standard-window.md`](standard-window.md) |
| `Showing_Directory` | Showing '%s' log Directory. | Cut. Opening a folder in File Explorer needs no line saying it opened | This audit |
| `Bool_Yes` | Yes | Cut. Used only for the two header lines cut below | This audit |
| `Bool_No` | No | Cut, with `Bool_Yes` | This audit |
| `Info_Date` | Date: | Keep, in the log's header | `D01 T01 §3` |
| `Info_Program` | Program: | Keep, in the log's header | `D01 T01 §3` |
| `Info_Program_Path` | Program Path: | Fix (kept): "Program path:" | `D01 T01 §3` |
| `Info_Compiled` | Compiled: | Cut. An AutoIt script can run uncompiled; this tool cannot | This audit |
| `Info_AutoIt_Version` | AutoIt Version: | Cut. AutoIt only | This audit |
| `Info_AutoIt_64Bit` | AutoIt 64-Bit Version: | Cut. AutoIt only | This audit |
| `Info_Windows_Version` | Windows Version: | Fix (kept): "Windows version:" | `D01 T01 §3` |
| `Info_System_Type` | System Type: | Fix (kept): "System type:" | `D01 T01 §3` |
| `Info_Memory` | Memory (RAM): | Keep, in the log's header | `D01 T01 §3` |
| `Info_ProgramFiles` | Program Files Directory: | Fix (kept): "Program Files folder:" | `D01 T01 §3` |
| `Info_Windows_Directory` | Windows Directory: | Fix (kept): "Windows folder:" | `D01 T01 §3` |
| `Level_Error` | Error: | Keep: the prefix the writer writes | [`log-surface.md`](log-surface.md) |
| `Level_Warning` | Warning: | Keep | [`log-surface.md`](log-surface.md) |
| `Level_Success` | Success: | Keep | [`log-surface.md`](log-surface.md) |
| `Level_Finished` | Finished: | Keep | [`log-surface.md`](log-surface.md) |

## `[Menus]`

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `File` | &File | Keep | [`standard-window.md`](standard-window.md) |
| `File_Preferences` | &Preferences | Keep | [`standard-window.md`](standard-window.md) |
| `File_Logging` | &Logging | Keep | [`standard-window.md`](standard-window.md) |
| `File_Logging_Open_File` | Open &log File | Fix (kept): "Open &log file" | [`standard-window.md`](standard-window.md) |
| `File_Logging_Open_Directory` | Open log &Directory | Fix (kept): "Open log &folder", the Windows word | [`standard-window.md`](standard-window.md) |
| `File_Close` | &Close\tAlt+F4 | Fix (kept): "&Close". The accelerator is the framework's to draw, so it leaves the string, and each translation loses the same suffix | [`standard-window.md`](standard-window.md) |
| `Help` | &Help | Keep | [`standard-window.md`](standard-window.md) |
| `Help_Update` | Check for &updates | Keep | [`standard-window.md`](standard-window.md) |
| `Help_Home` | %{Company.Name} &Home | Keep | [`standard-window.md`](standard-window.md) |
| `Help_Downloads` | More &Downloads | Keep | [`standard-window.md`](standard-window.md) |
| `Help_Support` | &Get Support | Fix (kept): "&Get support" | [`standard-window.md`](standard-window.md) |
| `Help_Issue` | Create an &issue | Fix (dropped): "&Report a problem" | [`standard-window.md`](standard-window.md) |
| `Help_Donate` | Donate a &little something | Cut, with Donate. It also carried a trailing space | This audit |
| `Help_About` | About %{Program.Name} | Fix (kept): "&About %{Program.Name}", gaining its access key | [`standard-window.md`](standard-window.md) |
| `Debug` | &Debug | Cut. A menu of the suite's build tool, not of any tool a user runs | [`standard-window.md`](standard-window.md) |

## `[Messages]`

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `Info_Title` | Please Take Note | Fix (dropped): "Information" | [`standard-window.md`](standard-window.md) |
| `Warning_Title` | Warning! | Fix (kept): "Warning" | [`standard-window.md`](standard-window.md) |
| `Error_Title` | Oops! Something went wrong! | Fix (dropped): "Error" | [`standard-window.md`](standard-window.md) |
| `Error_Oops` | Oops! | Cut. A user whose tool failed needs to know what failed | [`standard-window.md`](standard-window.md) |
| `Singleton` | Another occurence of %{Program.Name} is already running. | Fix (kept): "%{Program.Name} is already running." | [`notices.md`](notices.md) |
| `Compatible` | %{Program.Name} is not compatable with your version of windows... | Fix (dropped): "%{Program.Name} needs %1 or later" | [`notices.md`](notices.md) |
| `Compatible_Bit` | Unfortuantely %{Program.Name} 32 Bit is not compatible... | Cut. x86-64 is the only architecture | [`notices.md`](notices.md) |
| `Loading_Initializing`, `Loading_Localizations`, `Loading_Resources`, `Loading_WorkingDirectories`, `Loading_Logging`, `Loading_Configuration`, `Loading_Shortcuts`, `Loading_Interface` | Initializing %{Program.Name}; Loading Localizations; and six more | Cut, all eight, with the splash | This audit |
| `Ping_Check_Connection` | Checking Internet Connection. | Cut. No framework surface tests the connection: the update check reports its own failure ([`update-notices.md`](update-notices.md)). Used only by the suite's build tool | This audit |
| `Ping_Response` | Response Received in %s milliseconds. | Cut, with `Ping_Check_Connection` | This audit |
| `Ping_Host_Offline` | Host is Offline. | Cut, with `Ping_Check_Connection` | This audit |
| `Ping_Host_Unreachable` | Host is Unreachable. | Cut, with `Ping_Check_Connection` | This audit |
| `Ping_Host_Bad` | Bad Destination. | Cut, with `Ping_Check_Connection` | This audit |
| `Ping_Host_No_Internet` | No Internet Connection. | Cut, with `Ping_Check_Connection` | This audit |
| `Global_Errors` | Finished with (%02i) %s! | Cut. The closing line of a run is the repair contract's result, which counts items by outcome (`D02 T01 §3`), not "errors" found by searching the log | This audit |
| `Global_Errors_Error` | error | Cut. A plural made by gluing a word on cannot be translated | This audit |
| `Global_Errors_Errors` | errors | Cut, with `Global_Errors_Error` | This audit |
| `Global_Finished` | Completed selected task. | Cut, with `Global_Errors` | This audit |
| `Global_File` | file | Cut. A glued plural, used only by the suite's build tool | This audit |
| `Global_Files` | files | Cut, with `Global_File` | This audit |
| `RegisterDll_Success` | RegSvr32.exe > '%s' registration succeeded. | Fix (dropped): "registered %1.", a line at the success level | This audit |
| `RegisterDll_Error_01` | RegSvr32.exe > '%s' To register a module, you must provide a binary name. | Cut. A caller's mistake that a declared repair item cannot make | This audit |
| `RegisterDll_Error_02` | RegSvr32.exe > '%s' Specified module not found. | Fix (dropped): "could not register %1: the file was not found." | This audit |
| `RegisterDll_Error_03` | RegSvr32.exe > '%s' Module loaded but entry-point DllRegisterServer was not found. | Fix (dropped): "could not register %1: it has no DllRegisterServer entry point." | This audit |
| `RegisterDll_Error_04` | RegSvr32.exe > '%s' Error number: 0x80070005 | Fix (dropped): "could not register %1: %2", %2 Windows' reason in words with its code, ending with what was needed as the registry lines do | This audit |
| `Registry_Write_Error` | Could not write to '%s' | Fix (dropped): "could not write the value %2 in %1: %3" | [`notices.md`](notices.md) |
| `Registry_Error_01` | Unable to open requested key. | Fix (dropped): "could not open the key %1: %2" | [`notices.md`](notices.md) |
| `Registry_Error_02` | Unable to open requested main key. | Fix (dropped): "the part of the registry that holds %1 is not available: %2" | [`notices.md`](notices.md) |
| `Registry_Error_03` | Unable to open requested value. | Fix (dropped): "could not read the value %2 in %1: %3" | [`notices.md`](notices.md) |
| `Registry_Error_04` | Value type not supported. | Fix (dropped): "the value %2 in %1 is of a type this action does not handle (%3)" | [`notices.md`](notices.md) |
| `Registry_Error_05` | Unable to delete requested value. | Fix (dropped): "could not delete the value %2 from %1: %3" | [`notices.md`](notices.md) |
| `Registry_Error_06` | Unable to delete requested key/value. | Fix (dropped): "could not delete the key %1: %2" | [`notices.md`](notices.md) |

The four `RegisterDll` lines are written by a repair item that registers a library, through the log writer, one line per action (`D02 T01 §6`). Like the registry lines they begin in lower case because the writer puts the level's prefix first, they name their target, the library's full path, in the line, and an access failure ends with `Registry_Need_Admin` or `Registry_Need_Owner` ([`notices.md`](notices.md#what-does-a-registry-failure-say-in-the-log)). What a tool registers, and when, is its own and is not changed by what the line is called.

## `[Messages2]`

Present and empty in the framework pack. The launcher's own pack fills it, and its nine `ExecuteTool_*` keys are ruled on in [`notices.md`](notices.md#what-does-the-launcher-log-for-a-launch): three reworded, six cut.

## `[Preferences]`

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `Window_Title` | Preferences | Keep | [`preferences.md`](preferences.md) |
| `Tab_General` | General | Keep, as a page name | [`preferences.md`](preferences.md) |
| `Tab_Cache` | Cache | Cut. Dead: no dialog ever built a Cache page | [`preferences.md`](preferences.md) |
| `Tab_Performance` | Performance | Keep, as a page name | [`preferences.md`](preferences.md) |
| `Tab_Language` | Language | Keep, as a page name | [`language-page.md`](language-page.md) |
| `Group_Logging` | Logging | Keep | [`preferences.md`](preferences.md) |
| `Group_Priority` | Priority | Keep | [`preferences.md`](preferences.md) |
| `Group_Memory` | Memory | Keep | [`preferences.md`](preferences.md) |
| `Group_Language` | Language | Keep | [`language-page.md`](language-page.md) |
| `Checkbox_Enable_Logging` | Enable logging | Fix (kept): "&Enable logging", gaining its access key | [`preferences.md`](preferences.md) |
| `Label_Log_Exceed` | Log size must not exceed : | Cut. Replaced by `Label_Log_Limit` | [`preferences.md`](preferences.md) |
| `Label_Logging_Size` | Logging Size: %s KB | Fix (dropped): "The log is using %1." | [`preferences.md`](preferences.md) |
| `Button_Logging_Clear` | Clear Logging | Fix (kept): "&Clear log" | [`preferences.md`](preferences.md) |
| `Label_SetPriority` | Set process priority: | Fix (kept): "Process &priority" | [`preferences.md`](preferences.md) |
| `Checkbox_SaveRealtime` | Save priority above high (not recommended). | Fix (dropped): "&Keep Realtime after a restart (not recommended)" | [`preferences.md`](preferences.md) |
| `Checkbox_ReduceMemory` | Reduce memory on low memory systems. | Fix (dropped): "&Reduce memory use when Windows is short of memory" | [`preferences.md`](preferences.md) |
| `Label_Language_Message` | Select the language you prefer and press the %s button to continue. (Restart Required) | Fix (dropped): "Choose a language. This dialog changes at once. The rest of %{Program.Name} changes after it restarts." | [`language-page.md`](language-page.md) |
| `Button_Save` | Save | Fix (kept): "&Save", gaining its access key | [`preferences.md`](preferences.md) |
| `Button_Cancel` | Cancel | Keep. One Cancel for every dialog: the key is read from `[Messages]`, and each translation moves with it | [`preferences.md`](preferences.md) |
| `Label_Updated` | Preferences Updated | Fix (kept): "Preferences saved" | [`preferences.md`](preferences.md) |
| `Label_Logging_Cleared` | Logging cleared | Fix (dropped): "Log cleared: %1 freed." | [`preferences.md`](preferences.md) |
| `MsgBox_Language_Title` | Language Changed | Cut, with its prompt | [`language-page.md`](language-page.md) |
| `MsgBox_Language_Message` | The selected language has changed... | Cut, with its prompt. Replaced by `Label_Language_Restart` | [`language-page.md`](language-page.md) |
| `MsgBox_Closing_Title` | Closing %{Program.Name} | Cut, with its prompt | [`language-page.md`](language-page.md) |
| `MsgBox_Closing_Messag` | Would you like to close %{Program.Name} now? | Cut, with its prompt. Misspelled against the loader's `MsgBox_Closing_Message`, so the pack's text never loaded; neither spelling ships | [`language-page.md`](language-page.md) |

## `[Update]`

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `Window_Title_Available` | Update available | Cut. A message's title is the tool's name; replaced by `Update_Available_Title` | [`update-notices.md`](update-notices.md) |
| `Window_Title_Congratulations` | Congratulations! | Cut. Having the latest version is not an achievement | [`update-notices.md`](update-notices.md) |
| `Window_Title_Error` | Something went wrong! | Cut. Replaced by `Update_Failed_Title` | [`update-notices.md`](update-notices.md) |
| `Label_Message_Update` | There is a new version of '%{Program.Name}' available. | Cut. Replaced by `Update_Available_Title` | [`update-notices.md`](update-notices.md) |
| `Label_Message_Latest` | You are using the latest version of '%{Program.Name}'. | Fix (kept): "You have the latest version of %{Program.Name}." | [`update-notices.md`](update-notices.md) |
| `Label_Message_Error` | Information about the latest version of '%{Program.Name}' could not be retrieved. | Fix (dropped): "The latest version could not be looked up." | [`update-notices.md`](update-notices.md) |
| `Label_Message_Internet` | Please check your Internet Connection and try again. | Fix (kept): "Check your Internet connection and try again." | [`update-notices.md`](update-notices.md) |
| `Label_Build_Current` | Current Build: | Fix (dropped): "Installed version:" | [`update-notices.md`](update-notices.md) |
| `Label_Build_Update` | Update Build: | Fix (dropped): "Available version:" | [`update-notices.md`](update-notices.md) |
| `CheckBox_NoUpdate` | Do not check for updates at startup. | Cut. Replaced by `Button_Update_Skip`; the checkbox wrote a switch it did not name | [`update-notices.md`](update-notices.md) |
| `Button_Update` | Read more | Fix (dropped): "&Open download page" | [`update-notices.md`](update-notices.md) |
| `Button_Close` | Close | Keep. One Close for every dialog: the key is read from `[Messages]`, and each translation moves with it | [`update-notices.md`](update-notices.md) |

## `[Versioning]`

| Key | English | Verdict | Owner |
| --- | --- | --- | --- |
| `Administrator` | Administrator | Cut. It was glued into the window's caption; the caption is the tool's name, and elevation is the status bar's `Status_Elevated` | [`standard-window.md`](standard-window.md) |
| `Build` | Build | Cut. Versions are shown as versions (`D06 T01 §11`), never as a word glued to a number | This audit |
| `AutoIt_Version` | using AutoIt version %{AutoIt.Version} | Cut. AutoIt only | This audit |
| `Bit` | Bit | Cut. x86-64 is the only architecture | This audit |

## What does the audit add up to?

| | Keys |
| --- | --- |
| Distinct keys in the ten sections | 167 |
| Keep | 33 |
| Fix (kept) | 20 |
| Fix (dropped) | 25 |
| Cut | 89 |
| Header keys, in a table of their own | 5 |

More than half the pack goes: 89 of 167. Most of what goes was never a sentence a user needed: ten section names, eleven words for a search that guessed, eight messages for a splash that waited to be read, and six strings asking for money.

## What must the builds prove?

Each row is one check in the section named in its last column, which carries the item.

| Element | Trigger | Result | Failure | Check |
| --- | --- | --- | --- | --- |
| No splash | Start a fixture tool and record its windows from process start | The first window shown is the tool's own; no other window appears first; no pause is added to startup for a message | A window shown before the tool's own fails the check | `D01 T01 §1`: `startup: the tool's window is its first surface` |
| No Donate at closing | Close a tool for the first time on a clean profile, and again after a version change | The tool closes; no dialog is raised but shutdown's own notice when a save fails | Any dialog at closing with nothing failed fails the check | `D01 T01 §1`: `shutdown: closing asks for nothing` |
| Nothing written about Donate | Compare the settings file before a first run and after closing; then run with a file that holds an AutoIt `[Donate]` section | No `[Donate]` section is created and the computer's name appears nowhere in the file; an existing section is byte for byte as it was | A section created, or an existing one changed, fails the check | `D01 T01 §1`: `settings: nothing about donate is written or removed` |
| No Donate surface | Walk the window, both menus and About through UI Automation, invoking every link and every element that can be pressed, with link opening captured; and search the built executable and its English pack | No element asks for money or a gift, by any wording; nothing invoked opens a payment or donation address; the executable and the pack hold no payment address (the AutoIt one was a PayPal link, `ReBar.au3:292`) and none of the six cut keys; Help holds the items [`standard-window.md`](standard-window.md#what-is-on-the-help-menu) lists and no other | The AutoIt strip kept under any text (its label opened PayPal, `ReBar.au3:596-605`) fails the check by the address it opens, whatever it says | `D01 T01 §7`: `window: no donate surface exists` |
| Cut keys | Run the pack check over every composed pack, in every language | No key this audit cuts is present | Shown failing on a fixture pack that carries `Compatible_Bit` | `D08 T01 §2`: `packs: a cut key ships in no language` |
| Fixed keys, in English | Compare the composed English pack with this audit and the six pages | Every fixed key carries its fixed text; every key a page adds is present with that page's text | Shown failing on a fixture pack holding the old English of a fixed key | `D08 T01 §2`: `packs: english carries every fix` |
| Fixed keys, in the other languages | Run the pack check over a composed German pack | A fix marked kept still has its translation; a fix marked dropped has none, so the key shows English | Shown failing on a fixture German pack that still translates a reworded key | `D08 T01 §2`: `packs: a reworded key drops its old translation` |
