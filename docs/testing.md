# Testing without interrupting

D00 T02 §10. The suite runs while the operator works. Anything that needs the desktop is fenced, and the fenced part runs only when nobody is using the desktop, or when the operator asks to watch it.

## The two runs

| Run | Command | When | Green means |
| --- | --- | --- | --- |
| Default | `ctest --preset debug` (and `ctest --preset release`) | any time; `scripts/check-all.ps1` runs both | every test passed and every case's census is clean: no window shown, no foreground taken, no mouse capture held, no window left behind |
| Fenced | `ctest --preset headful` | the quiet-hours window, or the night runner's idle signal | every fenced case passed with its windows on the monitor and DPI it declares, or skipped with a `SKIP` line that makes it debt |
| Fenced, visible | `ctest --preset headful-visible` | whenever the operator asks for it | every fenced case passed with its windows where it declares; nothing skips on the clock |

The default presets exclude the `headful` label, and the fenced presets include only it. Every test has a 120 second timeout, so a case that never returns (a modal loop nobody dismisses, a dispatch that blocks) fails by name instead of hanging the run.

## The focus guard

`tests/main.cpp` runs every Catch2 session inside the focus guard (`tests/focus_guard.cpp`). A dedicated thread holds WinEvent hooks for foreground changes and window shows, so even a transient activation is seen when it happens. At the end of every case the guard takes a census of the windows the suite owns (the test process, plus any process a case starts and adopts, such as the launcher) and checks it against the case's tier.

- A violation prints `FOCUS-VIOLATION <case>: <what>` and the run exits 5, even when every assertion passed.
- Every case prints one summary line, `CENSUS <case> tier=<tier> shown=<n> foreground=<n> windows=<n> violations=<n>`.
- Every case writes its census to `build/<preset>/focus-census/<case>.log`: the tier, each event, and each window with its monitor, rectangle, iconic state, and the monitor's measured DPI. This is the foreground log a stamp quotes.

Default-tier windows come from `tests/ui_host.h`: hidden, and disabled so that nothing inside can activate them. The guard's first run caught why that matters: a list view's `SetFocus` on a click activated the hidden host, which took the foreground, and the operator's keystrokes would have gone to an invisible window.

## The fence

A headful case carries `[headful]` and a `[place:...]` tag, and opens with `RESOLUTE_HEADFUL_GATE()` (`tests/fence.h`). The gate decides once per case:

| Input | Decision |
| --- | --- |
| `RESOLUTE_HEADFUL=visible` | run, visibly, for the operator; never stops on input |
| `RESOLUTE_IDLE_COLLECT=1` | run: the night runner saw the session unlocked and idle past its threshold (D00 T02 §11 sets this) |
| 02:00 to 06:50 local | run |
| anything else | skip |

A collecting run (the last two rows) stops a case the moment operator input arrives: the case skips with `operator input resumed; re-queued`, and whatever it drove is dismissed first.

A capture case writes its PNG and sidecar under `build/<preset>/captures/`, never into `docs/captures/runs/`, so a re-run cannot overwrite or delete committed evidence. Publishing a capture is a deliberate step: look at it, copy the PNG and its sidecar into `docs/captures/runs/` under the matrix name, and commit them with the section they prove.

A collecting case also needs the operator away at its own start (no input for 120 seconds, `fence::kCollectIdleMs`). Every case runs in its own process, so when the operator comes back, the case in progress stands down on the input and every later case skips as `the operator is active ...; re-queued`, rather than taking a fresh baseline and the desktop with it.

Placement tags: `[place:primary]` puts the case's windows on the primary monitor; `[place:dpi96]` and `[place:dpi144]` put them on the monitor at that DPI, because the case proves rendering at that scale. A case whose monitor is not attached skips with `hardware absent`, and the night runner re-probes it. `tests/focus-audit.md` gives each fenced case's reason.

## Skips are debt

Every skip prints one machine-readable line:

```
SKIP "<test name>" <reason>
```

A section whose surface has fenced cases, and which ships outside the window, still stamps on a green default run. Its fenced cases become debt on the stamp:

```
ctest --preset headful -V > build/headful.log
python scripts/fence-debt.py --log build/headful.log --stamp
```

`fence-debt.py` prints the `Night-owed:` line the stamp records, taken from the SKIP lines rather than typed by hand, and fails when a fenced case in `tests/focus-audit.md` is neither green nor owed. D00 T02 §11 collects the debt at night, and a red night result reopens the section through review's audit stance.

One run can never be owed: a section that changes the fence itself proves it with one explicit headful pass, because a fence that has never run cannot certify itself through its own skips.

## The nightly run

D00 T02 §11. `tools/nightly.ps1` is the one governed run of the whole suite: the default half, the fenced half, and the collection of every section's night debt, while the operator is away, with a report where the morning finds it.

### Trigger

`pwsh tools/nightly.ps1 -Register` creates the `\Resolute\Nightly` scheduled task: it runs as the signed-in user (interactive, no stored password, only while signed in, because the fenced half needs that user's desktop), daily at 02:05 and whenever the session goes idle for 10 minutes. `pwsh tools/nightly.ps1 -Unregister` removes it. At each start the script decides what it is:

| When | Mode | Runs |
| --- | --- | --- |
| 02:00 to 06:50 local | Night | both halves at master's head, then the debt |
| otherwise, unlocked and idle 10 minutes | Collect | the debt only, each fenced case standing down on input |
| otherwise | none | nothing; it exits |

`-Mode Manual` runs both halves and the debt at any hour; the fenced cases still gate themselves (`tests/fence.h`), so a manual run by day proves the plumbing without taking the desktop.

### What a run does

1. Takes `build/nightly/.lock` exclusively; a second run exits at once.
2. Probes the session: lock state, idle time, and every monitor's size and DPI, read per-monitor aware (unaware, every DPI reads 96).
3. Builds each commit it tests in its own git worktree under `build/nightly/wt/<sha>/`, with the toolchain linked in. It never builds in, or writes to, the working tree the writer uses; everything it writes is ignored scratch under `build/nightly/`.
4. Default half: `ctest --preset debug -V` at master's head. Green means every test passed and every census is clean.
5. Fenced half: `ctest --preset headful -V` at master's head, skipped as a whole when the session is locked (a locked desktop cannot show windows; the skip is logged and the run goes on). Green means every case passed on its declared monitor and DPI, or skipped with a reason: outside the window, operator input, or `hardware absent` when a declared DPI has no monitor.
6. Debt: `python scripts/todo-graph.py query night-debt --json`, then each owed case run at the candidate it was reviewed at, in that candidate's worktree.
7. Writes the report.

### Tiers and debt

The DAY tier is the default half; a section flips its row on a DAY-green run at any hour. The NIGHT tier is the fenced half; what a section could not run becomes debt on its stamp, and debt clears only by collection, never by waiting:

```
> **Night-owed:** candidate <full sha> | "<case>" (<reason>); "<case>" (<reason>)
> **Night-owed:** none
> **Night-verified:** YYYY-MM-DD | candidate <sha> | run <run id> | "<case>"; "<case>"
```

`query night-debt` derives the open debt from these lines at query time (`scripts/todo-night-debt.py`): owed cases minus verified ones, each with its section, placement intent from `tests/focus-audit.md`, candidate, and age in nights. The runner never edits a tracked file: it lists the `Night-verified:` lines to append and the findings to file, and Claude Code records them at its next section boundary.

### The collector's rules

- **Candidate binding.** Debt is collected at the commit the section was reviewed at, built in that commit's worktree; a green run of any other commit clears nothing, and a `Night-verified:` line names its candidate.
- **Retry.** A red case is run once more in the same run; both attempts are logged (`debt-<sha>-a1.log`, `-a2.log`).
- **Second red.** Red twice reopens the section through review's audit stance: the report lists it as `REOPEN ... red twice at candidate <sha>`, for Claude Code to file.
- **Interruption.** Operator input stands the case in progress down (`operator input resumed; re-queued`) and every later case skips until the operator has been away 120 seconds; a skip is never red and never retried, and the debt stays owed.
- **Hardware absent.** A case whose declared DPI has no monitor skips `hardware absent` and stays owed; every run re-probes, so it collects the night the monitor is back.
- **Age.** Age in nights is information in the report, never an escalation.
- **One writer.** The run owns only its worktrees and `build/nightly/`; it never builds over the writer's work and never commits.
- **No orphans.** Every process a fenced case starts (the launcher, a capture, the flasher) runs in a job object killed with the test process, so a case ctest kills at its timeout leaves nothing running.

### Logs and the report

Each run has a unique id, `YYYYMMDD-HHMMSS`, and its own directory: `build/nightly/<id>/run.log`, `default.log`, `full.log`, `debt-<sha>-a<attempt>.log`, and the build logs. The report is `build/nightly/<id>/report.md`, copied to the fixed path `build/nightly/morning-report.md`, which is the file to read first; `build/nightly/latest.txt` names the latest run. A worked example:

```
# Nightly report 20260927-020500

mode Night; master 74dba449...; started 2026-09-27 02:05:00; idle 13200s; session unlocked
probe: monitor \.\DISPLAY1 2560x1440 dpi 144 primary; monitor \.\DISPLAY2 1920x1080 dpi 96

## Halves at 74dba4493a2b
default half: passed 99, failed 0, skipped-with-reason 0, focus violations 0
fenced half: passed 9, failed 0, skipped-with-reason 0, focus violations 0

## Night debt: 1 open before this run
candidate abcdef12 attempt 1: "Launcher capture, dark at 150 percent" Passed

## For Claude Code to record
- append to D00 T02 §3: > **Night-verified:** 2026-09-27 | candidate abcdef12... | run 20260927-020500 | "Launcher capture, dark at 150 percent"

## Open debt (before the lines above are recorded)
    night-debt: 1 open
```
