# A tool's own Preferences pages

A Resolute tool adds its settings to the framework's Preferences dialog by declaring a page. It never builds a dialog, lays out a control or writes a setting itself. This page is that contract, exact enough that two tools' pages cannot differ in shape, so that `D01 T01 §7` can build the host and a tool author can write a page from it. It is half of `D01 T03 §3` (`todo/01-framework/TODO-03-framework-surfaces.md`); the other half is [`language-page.md`](language-page.md).

The AutoIt suite had no such contract. Each tool that wanted a setting of its own copied the framework's dialog and edited the copy, which is how fourteen tools came to carry fourteen dialogs. Here a tool page is data handed to one host.

A tool page lives in the shell [`preferences.md`](preferences.md) specifies. Sizes are base values at 96 DPI. A specification cannot prove behaviour, so the page ends in a matrix ([below](#what-must-the-build-prove-row-by-row)) whose every row is a check `D01 T01 §7` runs against fixture tools.

## How does a tool declare a page?

A tool hands the host one declaration per page while it starts, before its window is shown. The declaration type and the call that takes it live in `src/framework/ui/Preferences.h` (`D01 T01 §7` names them); a tool adds no file to the framework.

| Part | Holds | Rule |
| --- | --- | --- |
| Page id | A short name in ASCII letters and digits (`Cleaning`) | Unique among the tool's pages. It names the page's string section and appears in log lines. Never shown. |
| Title | A string key | The page's name in the page list and as its heading. |
| Groups | One or more, each a heading key and a list of controls | A group is a heading and the controls under it, drawn as the framework's groups are. A page with one group may leave the heading out. |
| Controls | From the closed set below | In the order declared, one per row. |
| Functions | The tool's check, apply and action functions, where the controls below call for them | The only code in a declaration. Everything else is values. |

**Where pages go:** after the framework's five (General, Performance, Updates, Appearance, Language), in the order the tool declares them. A tool cannot place a page among the framework's, replace one, or add a control to one. A tool with no declaration has no extra page, and nothing else changes.

**Who lays it out:** the host. A page is a single column: each control's label, the control, then its note or error beneath. A tool gives no position, size, colour, font or spacing (`DESIGN.md`); there is nothing in the declaration that could hold one.

## Which controls can a page hold?

Six, and no others. Each is the framework's form control (`D01 T02 §9`), so it looks and behaves like its neighbour on a framework page.

| Control | Declares | Stores |
| --- | --- | --- |
| Checkbox | Label key; setting key; default; the two stored values, `1` and `0` unless the tool names others | One of its two values. A tool keeps its AutoIt file readable by naming the values that file used (the AutoIt checkboxes wrote 1 and 4). |
| Combo | Label key; setting key; default; its choices, each a stored value and a label key | The chosen choice's stored value. |
| Number input | Label key; setting key; default; lowest and highest allowed whole number; an optional unit key shown after the box | The number in decimal digits. |
| Text input | Label key; setting key; default; longest allowed length in characters; whether empty is allowed | The text as typed. |
| Action button | Label key; the tool's action function; an optional confirmation ([below](#what-does-an-action-button-do)) | Nothing. It is not a setting. |
| Note | A string key | Nothing. Static text, selectable and copyable. |

Every control that stores a value also declares:

| Part | Rule |
| --- | --- |
| Setting key | A key in the tool's settings section, the same section the framework's keys are in, as the AutoIt file had them. It must not be a key the framework owns (those on the framework's pages, and `Language`), and no two controls of one tool may share a key. |
| Default | The value used when the key is absent. It must itself be allowed. |
| Enabled when | Optionally, another control on the same page and the values of it for which this one is enabled ("enabled while that checkbox is checked"). A disabled control keeps its value and is not validated. |
| Takes effect | One of three, which decides what happens after a save ([below](#when-does-a-tool-setting-take-effect)). |
| Hint | Optionally, a string key for one line of help beneath the control. |

A label's access key is the letter after `&` in its text, as on the framework's pages. A file or folder picker, a list, a slider and a colour well are not in the set: a tool that needs one asks for it in `D01 T02 §9`, where it becomes a control every tool can use, and until then uses a text input.

## Where do a tool page's strings come from?

From the tool's language pack, section `[Preferences.<page id>]`, resolved as every string is (`D01 T01 §4`): the tool's pack, the language's common pack, then the built-in English. A tool declares each key with its English text, which is that built-in text, so a pack that lacks the key shows English and never a blank or the key's name. A tool page's keys cannot collide with the framework's, which are in `[Preferences]`.

## How does a tool page take part in Save?

Exactly as a framework page does. The shell's rules in [`preferences.md`](preferences.md#what-does-save-do) apply to a tool's controls with nothing added and nothing left out:

- **Three values.** Each control has a persisted value (the file's), an edited value (on screen) and an effective value (what the tool is using).
- **The dirty rule.** A control is dirty when the user has edited it and its value now differs from the persisted one; a control the user has not touched is never dirty, whatever it shows. The dialog is dirty when any control is, a tool's controls included. Save is enabled then, and the way out asks.
- **Save writes edited controls only.** A control the user did not edit is neither validated nor written, so a stored value survives every save untouched.
- **One write.** A tool's keys go in the same atomic write and read-back as the framework's (`D01 T01 §2`). A tool never writes its own settings from a page, and its functions are never asked to.
- **The way out.** Cancel, Esc, the caption's close button and Discard treat a tool's edits as they treat the framework's.

### What if the file holds a value the declaration does not allow?

A settings file is hand-editable, so a number can be out of range and a combo's value can be one no choice has. The control then shows its default, with a note beneath it: `Label_Stored_Invalid` ("The settings file holds %1 here, which is not allowed. %{Program.Name} is using %2."), %1 the stored text in monospace and %2 the default as the control shows it. The tool is given the default. The stored value is left as it is, because an unedited control never rewrites its key; it is replaced only when the user edits the control and saves. Until then the control is not dirty, although it shows a value the file does not hold: opening the dialog and touching nothing leaves Save disabled and the way out silent. Any edit of that control makes it dirty, one that ends on the default shown included, because that value is not the one in the file; saving then writes it and the note goes.

## How is a value checked?

At Save, in the shell's first step, for edited and enabled controls only, in page order then control order.

1. **The host checks the declaration's limits.** A number outside its range or not a whole number: `Error_Value_Range` ("Enter a whole number from %1 to %2."), the shell's key. A text longer than allowed: `Error_Text_Length` ("Enter no more than %1 characters."). An empty text where empty is not allowed: `Error_Text_Empty` ("Enter a value."). A combo and a checkbox cannot hold a value that is not allowed.
2. **Then the tool's check runs, when the page declares one.** It is given the page's values as they would be saved and returns nothing, or one control and a reason: a string key from the tool's pack with its arguments. It must not change anything and must return at once; it is a question, not an action.

The first failure stops the save, as on every page: nothing is written, the dialog moves to that page, focus goes to the control, and the reason shows beneath it in the error state (`D01 T02 §9`), announced. The error clears when the control is edited. There is one presentation for every refused value in every tool, which is the point of the contract.

A tool's check that fails to run (it throws) is not a refusal of the value: the save stops, and a message through the message layer says `Page_Check_Failed` ("%1 could not check its settings: %2. Nothing was saved."), %1 the page's title, with Close; the failure is logged.

## When does a tool setting take effect?

Each control declares one of three, and the host does the rest by the shell's reconcile rule ([`preferences.md`](preferences.md#what-does-save-do)):

| Takes effect | Declares | After a confirmed save |
| --- | --- | --- |
| When used | Nothing more | Nothing to do: the tool reads the setting the next time it needs it. |
| At Save | An apply function, and a function that reports the effective value | Where the effective value differs from the stored one, the host calls the tool's apply function for that setting, then asks for the effective value again. |
| After a restart | Nothing more | The host shows `Label_Effect_Restart` ("Takes effect the next time %{Program.Name} starts.") beneath the control whenever the stored value differs from the one the tool started with. No tool writes its own restart note. |

**When apply fails** (the function reports a reason, or the effective value still differs afterwards): the setting stays saved, and a note beneath the control says `Label_Apply_Failed` ("Saved, but %{Program.Name} could not apply it: %1"), %1 the tool's reason. The saved notice still shows, because the file holds the value; saved and applied are two things, as on the framework's pages. By the reconcile rule the host tries again after every later confirmed save and the tool applies its settings itself when it next starts; the note goes when the effective value matches. A save that changes another setting never calls apply for one whose effective value already matches.

## What does an action button do?

It runs something the tool offers beside its settings: "Clear the cache now", "Test the connection". It is not a setting and not part of Save.

| Part | Rule |
| --- | --- |
| When it runs | At once, when pressed. It is one of the actions that are not saves: the dirty rule does not see it, and Cancel and Discard do not undo it. |
| What it sees | The saved settings, never the edits on screen. A button whose result depends on a setting on the same page says so in its hint. |
| Confirmation | A declaration may give a confirmation: a summary key, a body key, the action's own button label, and an impact function ([below](#what-does-a-confirmation-say)). The host then asks first through the message layer, with Cancel as the default, as [`standard-window.md`](standard-window.md) rules for an action that changes the system. An action that changes anything outside the dialog must declare one, and its body must say what cannot be undone. |
| Who owns the run | The tool, through the framework's status layer, not the dialog. An action runs as a task ([`standard-window.md`](standard-window.md#how-does-each-segment-change)), named by the button's label: the status bar's task segment shows it, the taskbar button shows it, and it is announced as every task is. |
| While it runs | The button is disabled and reads `Label_Action_Running` ("Working..."). The state comes from the task, so it is the same however the page is reached: closing Preferences does not stop the action, and reopening while it runs shows the button disabled and reading `Label_Action_Running` until the task ends. One press starts one run, and there is no way to start a second while the first runs. The dialog stays responsive throughout. |
| Elevation | Checked at the action, by the tool, through the framework's guard (`D01 T01 §6`). An action that needs rights the tool does not have fails with that reason; a page never raises a consent prompt by being opened. |
| Success | The task's result line goes to the status bar's state segment and to the log, with the task's announcement, whether or not Preferences is open. When the page is showing, the same text also appears in a note beside the button (a string key and arguments from the tool), selectable and copyable; it stays until the page is left or the button is pressed again. |
| Failure | The same, in the failed form: `Label_Action_Failed` ("%1 did not finish: %2"), %1 the button's label without its access key and %2 the tool's reason, in the state segment and the log always, and in the note beside the button when the page is showing. The button is enabled again. |

### What does a confirmation say?

What the action will affect, in numbers, before it asks (`DESIGN.md` §11). The tool's sentence alone ("Cached pages are deleted") is not a confirmation, so a confirmation always comes with an impact function, and the host builds the message from what it returns:

| Step | Rule |
| --- | --- |
| Working it out | Pressing the button calls the tool's impact function off the UI thread; the button is disabled and reads `Label_Action_Running` meanwhile. The function returns the places affected (paths, registry keys or names), how many items, and their total size where size has a meaning. It changes nothing. |
| The message | Warning. Summary: the tool's summary key. Body: `Confirm_Impact` ("This affects %1 items (%2) in:"), or `Confirm_Impact_Count` ("This affects %1 items in:") when there is no size, then the places, one per line in monospace, at most ten with `Confirm_Impact_More` ("and %1 more"), then the tool's own body sentence, which says what cannot be undone. Buttons: the action's own label, and Cancel, the default. Counts and sizes are formatted for the user's locale. |
| Cancel | Nothing has changed, the button is enabled again, and nothing is logged as done. |
| Nothing to affect | An impact of no items asks nothing and runs nothing: the note beside the button reads `Label_Action_Nothing` ("There is nothing to do."). |
| An impact that cannot be worked out | The function reports a reason (a folder that cannot be read, a profile that has gone). No confirmation is shown for an impact nobody could state, and the action does not run: the note reads `Label_Action_Failed` with that reason, and the button is enabled again. |
| Closing Preferences while it is worked out | Cancels the preparation. Nothing runs, no confirmation is left waiting, and reopening shows the button enabled. An action only ever runs after its confirmation's own button is pressed. Once the message is showing, it is modal, so the dialog cannot be closed from under it. |
| What ran | The action is given the impact the user confirmed, and acts on those places only. |

## What if a declaration is wrong?

A declaration is checked once, when the tool hands it over. One that fails is refused whole: the host builds none of its controls.

| Refused when | Reason key |
| --- | --- |
| A control kind outside the six | `Page_Refused_Control` ("it uses a control this dialog does not have") |
| A setting key used by two controls, or one the framework owns | `Page_Refused_Key` ("the setting %1 is used twice or belongs to the framework") |
| A string key with no built-in English text | `Page_Refused_String` ("the text %1 is missing") |
| Two controls on the page with the same access key, or one that takes the shell's (Save's) | `Page_Refused_Access_Key` ("two controls share the access key %1") |
| A default the control's own limits do not allow, or an "enabled when" that names a control not on the page | `Page_Refused_Value` ("the control %1 is declared with a value it does not allow") |
| A control that takes effect at Save without both of its functions, an action button without its function, or a confirmation without its impact function | `Page_Refused_Function` ("the control %1 has nothing to run") |
| A page id that is empty, not ASCII letters and digits, or used twice | `Page_Refused_Id` ("its name is not usable") |

A refused page is not dropped. It is listed in the page list, under its title when that resolves and under its id when it does not, and it shows `Page_Refused_Title` ("This page cannot be shown") with `Page_Refused_Body` ("%1 declared it wrongly: %2. Its settings are unchanged."), %1 the tool's name and %2 the reason, selectable and copyable. The refusal is logged with the page id and the reason. The tool's stored settings are not touched, and the tool reads them as it always does. So a tool's settings never vanish silently, and the fault is found the first time anyone opens Preferences.

It should be found sooner. The host's check is one function that takes a declaration and returns the refusals, with no window; **each tool's own test suite calls it for every page the tool declares** and fails when it returns any (`D01 T01 §7` names the function and builds the fixture that shows the test failing on a refused page). A refused page is then a red test, not a released tool.

## Which keys, announcements and sizes apply?

The shell's, with nothing added: [`preferences.md`](preferences.md#which-keys-does-the-dialog-answer) for the keys, [what is announced](preferences.md#what-is-announced), and [how it scales](preferences.md#how-does-it-scale).

- **Keyboard.** Tab moves through a page's controls in declared order, each note and error after the control it belongs to, an action's note after its button. Every control is reached and operated without a mouse, because every control is the framework's.
- **Announced.** A control's name is its label; its state and value come from its UI Automation pattern (`D01 T02 §9`). An error, an apply note, a stored-value note, an action's start and its result are each announced once when they appear.
- **Density and scaling.** Row height and group padding follow the user's density. A label that does not fit wraps and is never cut; a page taller than the dialog scrolls; nothing is clipped at the dialog's minimum size or at 200 percent text scaling. A tool cannot opt out, because it gives no sizes.
- **Right-to-left packs.** A tool page's text is shaped as [`language-page.md`](language-page.md#how-does-it-scale-and-what-about-right-to-left-languages) says; the same limit applies.

## What does a page look like, declared?

A worked example: a browser tool's page with one of each control. The names are illustrative; `D01 T01 §7` fixes the type.

```cpp
PreferencesPage{
    .id = "Cleaning",
    .title = {"Title", "Cleaning"},
    .groups = {{
        .heading = {"Group_Cache", "Cache"},
        .controls = {
            Checkbox{.label = {"Checkbox_Clear_On_Exit", "&Clear the cache when the browser closes"},
                     .key = "ClearOnExit", .defaultValue = "0", .effect = Effect::WhenUsed},
            NumberInput{.label = {"Input_Keep_Days", "&Keep history for"}, .unit = {"Unit_Days", "days"},
                        .key = "KeepDays", .defaultValue = 30, .lowest = 1, .highest = 365,
                        .enabledWhen = {"ClearOnExit", {"1"}}, .effect = Effect::WhenUsed},
            Combo{.label = {"Combo_Profile", "&Profile"}, .key = "Profile", .defaultValue = "default",
                  .choices = {{"default", {"Profile_Default", "The default profile"}},
                              {"all", {"Profile_All", "Every profile"}}},
                  .effect = Effect::AtSave},
            TextInput{.label = {"Input_Extra_Folder", "&Extra folder to clear"}, .key = "ExtraFolder",
                      .defaultValue = "", .longest = 260, .emptyAllowed = true, .effect = Effect::WhenUsed},
            ActionButton{.label = {"Button_Clear_Now", "Clear the cache &now"},
                         .confirm = {{"Confirm_Clear_Title", "Clear the cache?"},
                                     {"Confirm_Clear_Body", "Cached pages are deleted and cannot be restored."},
                                     {"Button_Clear", "Clear the cache"},
                                     &CacheImpact},   // returns the cache folders, the file count and their size
                         .run = &ClearCacheNow},
            Note{.text = {"Note_Profiles", "Profiles are read when the browser starts."}},
        },
    }},
    .check = &CheckCleaningPage,          // refuses an ExtraFolder that does not exist, with its reason
    .apply = &ApplyCleaningSetting,       // called for Profile, which takes effect at Save
    .effective = &EffectiveCleaningValue,
}
```

Each `{"Key", "English"}` pair is a string key with its built-in English text. Pressing "Clear the cache now" first shows, from `CacheImpact`: "This affects 1,204 items (86.3 MB) in:", the profile's cache folder in monospace, then "Cached pages are deleted and cannot be restored.", with Cancel as the default. The page stores four keys in the tool's settings section, is validated and saved by the shell, and draws nothing itself.

## Which strings does the host add?

All in `[Preferences]` unless marked. A tool's own strings are in its `[Preferences.<page id>]` sections.

| Key | English | Verdict |
| --- | --- | --- |
| `Error_Value_Range` | Enter a whole number from %1 to %2. | The shell's, used as it is |
| `Error_Text_Length` | Enter no more than %1 characters. | New |
| `Error_Text_Empty` | Enter a value. | New |
| `Label_Stored_Invalid` | The settings file holds %1 here, which is not allowed. %{Program.Name} is using %2. | New |
| `Label_Effect_Restart` | Takes effect the next time %{Program.Name} starts. | New |
| `Label_Apply_Failed` | Saved, but %{Program.Name} could not apply it: %1 | New |
| `Label_Action_Running` | Working... | New |
| `Label_Action_Failed` | %1 did not finish: %2 | New |
| `Label_Action_Nothing` | There is nothing to do. | New |
| `Confirm_Impact`, in `[Messages]` | This affects %1 items (%2) in: | New |
| `Confirm_Impact_Count`, in `[Messages]` | This affects %1 items in: | New |
| `Confirm_Impact_More`, in `[Messages]` | and %1 more | New |
| `Page_Check_Failed`, in `[Messages]` | %1 could not check its settings: %2. Nothing was saved. | New |
| `Page_Refused_Title` | This page cannot be shown | New |
| `Page_Refused_Body` | %1 declared it wrongly: %2. Its settings are unchanged. | New |
| `Page_Refused_Control`, `Page_Refused_Key`, `Page_Refused_String`, `Page_Refused_Access_Key`, `Page_Refused_Value`, `Page_Refused_Function`, `Page_Refused_Id` | As the refusal table gives them | New |

No AutoIt key is kept, reworded or cut here: the AutoIt suite had no tool-page contract to take strings from.

## What must the build prove, row by row?

Every row is one behavioural check in `D01 T01 §7`. Two fixture tools exist for them: one declares a page with every control kind, an action whose effect and whose failure can both be driven, and a setting of each "takes effect" kind; the other declares one page per refusal.

| Element | Trigger | States | Result | Failure | Check in `D01 T01 §7` |
| --- | --- | --- | --- | --- | --- |
| A declared page | Start the fixture tool; open Preferences | One page, two pages, none | The tool's pages follow Language in declared order; the five framework pages are unchanged, compared with a tool that declares none | A wrong declaration is the refused-page row below | `toolpage: pages follow language in declared order` |
| Layout | Show the fixture page at each density, at the dialog's minimum size and at 200 percent text scaling | | One column in declared order; group headings as the framework's; a long label wraps; nothing clipped; the page scrolls when taller | None can occur: the host owns every size | `toolpage: the host lays the page out` |
| Checkbox | Click; Space; its access key; Save | Default values; named values 1 and 4 | The setting reads back as the declared stored value for each state | Save's failures, as the shell rules | `toolpage: a checkbox stores its declared values` |
| Combo | Open; arrow; type-ahead; Save | Each choice | The setting reads back as the chosen choice's stored value | Save's failures | `toolpage: a combo stores its choice's value` |
| Number input | Type an allowed number; then 0, a fraction, one over the highest; Save | In range; out of range | In range: read back in decimal digits. Out of range: the save stops, focus on the control, `Error_Value_Range` beneath it, nothing written | The stated result is the failure presentation | `toolpage: a number is held to its range` |
| Text input | Type; paste; leave empty where empty is refused; exceed the length; Save | Allowed; empty; too long | Allowed: read back as typed. Otherwise the save stops with `Error_Text_Empty` or `Error_Text_Length`, nothing written | The stated result is the failure presentation | `toolpage: a text is held to its length` |
| Enabled when | Uncheck the controlling checkbox; put a refused value in the dependent control first | Enabled; disabled | The dependent control is disabled, keeps its value, is not validated and is not written | None can occur: a disabled control is skipped | `toolpage: a disabled control is not checked or written` |
| The tool's check | Save a value the tool's check refuses; then one it accepts | Refused; accepted | Refused: the save stops, focus on the control the tool named, its reason beneath it, nothing written, the framework's own edits unwritten too. Accepted: all read back | A check that throws: `Page_Check_Failed` with the page's title, nothing saved, logged | `toolpage: the tool's check refuses in the shared form` |
| Dirty and the way out | Edit a tool control; Cancel; answer Discard, then Cancel, then Save | Dirty | The shell's prompt appears for a tool edit as for a framework one; each answer does what the shell rules | Save's failures | `toolpage: a tool edit takes part in the way out` |
| An unedited stored value | Open with a number out of range and a combo value no choice has in the file; touch nothing and take the way out; reopen, change another setting and Save; then retype the number's shown default and Save | | Each shows its default with `Label_Stored_Invalid` naming the stored text; the tool is given the default; untouched, Save is disabled and the dialog closes without asking; after the unrelated save both keys read back unchanged; after the retyped default the page is dirty, the number reads back as the default and its note is gone | None can occur: an unedited control is never dirty and writes nothing | `toolpage: a stored value that is not allowed is kept and reported` |
| Takes effect at Save | Change the setting; Save; then change only another setting and Save | Apply succeeding | The tool's apply runs once for the first save and not for the second; the effective value reported matches | Apply failing (seeded): `Label_Apply_Failed` with the tool's reason beneath the control, the saved notice still shown, and apply tried again at the next save | `toolpage: apply runs only where effective differs` |
| Takes effect after a restart | Change the setting; Save; reopen | | `Label_Effect_Restart` beneath the control while the stored value differs from the one the tool started with; gone after a restart | Save's failures | `toolpage: a restart setting says so` |
| Action button | Click; Space; its access key | Idle; running | The action runs once at once as a task; the status bar's task segment names it; the button is disabled and reads `Label_Action_Running`; the tool's result appears in the note and in the state segment, announced; the dirty state is unchanged and Cancel does not undo it | The action failing (seeded): `Label_Action_Failed` with the tool's reason in the note and the state segment, the button enabled again, logged | `toolpage: an action runs at once and reports` |
| An action that outlives the dialog | Start the fixture's slow action; close Preferences; reopen it while the action runs; press the button's access key; close again and let the action end | Running, dialog closed; reopened | One run only: on reopening the button is disabled and reads `Label_Action_Running`, and the key starts nothing; with Preferences closed the result line is in the state segment and the log, and the task's announcement is raised | The action failing with Preferences closed (seeded): the failed line is in the state segment and the log | `toolpage: an action survives closing the dialog` |
| Action confirmation | Press an action that declares one; Enter; then press it again and choose its button | | The message names the fixture's own places, count and size above the tool's sentence, with Cancel as the default; Enter changes nothing on the system and the button is enabled again; the action's button runs it on exactly those places | The action's own failure, as the action row above | `toolpage: a confirmation names what it affects and defaults to cancel` |
| An impact that cannot be worked out | Make the fixture's target folder unreadable; press the button | | No confirmation is shown and the action does not run; the note gives `Label_Action_Failed` with the reason; the button is enabled again | The stated result is the failure presentation | `toolpage: no confirmation without a stated impact` |
| Nothing to affect | Empty the fixture's target; press the button | | No message; the note reads `Label_Action_Nothing`; nothing runs | None can occur: an empty impact asks nothing | `toolpage: an empty impact does nothing` |
| Closing while the impact is worked out | Delay the fixture's impact function; press the button; close Preferences; reopen | Preparing | The preparation is cancelled; nothing is deleted; no message appears then or on reopening; the button is enabled and one press starts one new preparation | None can occur: an action runs only from its confirmation | `toolpage: closing cancels an unconfirmed action` |
| A refused page | Start the second fixture tool, one page per refusal; open Preferences | Each of the seven refusals, a confirmation without an impact function among them | Each page is listed, shows `Page_Refused_Title` and its reason, builds no control, and leaves the tool's settings file byte for byte; the refusal is in the log | The stated results are the failure presentations | `toolpage: a wrong declaration is shown, not dropped` |
| The declaration check | Run the host's check function on every fixture declaration, with no window | Valid; each refusal | Valid: no refusals. Each wrong one: its refusal, the same as the page shows. A test built on it fails on a refused page | None can occur: the function is the one the host uses | `toolpage: a tool's tests catch a refused page` |
| Strings | Show the fixture page with a pack that translates some keys, and with none | | Translated keys show from the pack; the rest show their declared English; nothing is blank and no key name shows | None can occur: every key has built-in English, or the page is refused | `toolpage: every string resolves or shows english` |
| Keyboard and announcements | Tab through the fixture page; raise an error, an apply note and an action result | | Tab order is the declared order with each note after its control; every control is operated by keyboard; each note is announced once and read through UI Automation | None can occur: the controls are the framework's | `toolpage: a tool page is reachable and announced` |
