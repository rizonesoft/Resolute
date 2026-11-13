# Testing without interrupting

D00 T02 §10. The suite runs while the operator works. Anything that needs the desktop is fenced, and the fenced part runs only when nobody is using the desktop, or when the operator asks to watch it.

## The two runs

| Run | Command | When | Green means |
| --- | --- | --- | --- |
| Default | `ctest --preset debug` (and `ctest --preset release`) | any time; `scripts/check-all.ps1` runs both | every test passed and every case's census is clean: no window shown, no foreground taken, no mouse capture held, no window left behind |
| Fenced | `ctest --preset headful` | the quiet-hours window, or the night runner's idle signal | every fenced case passed with its windows on the monitor and DPI it declares, or skipped with a `SKIP` line that makes it debt |
| Fenced, visible | `ctest --preset headful-visible` | whenever the operator asks for it | every fenced case passed with its windows where it declares; nothing skips on the clock |

The default presets exclude the `headful` label, and the fenced presets include only it. Every test has a 120 second timeout, so a case that never returns (a modal loop nobody dismisses, a dispatch that blocks) fails by name instead of hanging the run.

## What CI runs, and what stays local

The full gate set runs on GitHub on every push, so the development machine runs only what covers the change in hand (operator decision 2026-11-12, `D00 T01 §10`). `python scripts/ci-status.py` reads the result for a commit.

| Workflow | Runs | When |
| --- | --- | --- |
| `gates` (`.github/workflows/gates.yml`) | `pwsh scripts/check-all.ps1`, unchanged, 24 gates: toolchain (advisory: it reports `current`, `behind` or `unknown` against the latest releases and does not fail the run), build Debug, build Release, tidy ratchet, ratchet self-test, conformance check, conformance self-test, tests debug, tests release, graph validate, graph self-test, plan --check, claims, claims self-test, fence-debt self-test, night-debt self-test, fence-inventory self-test, fence inventory, reviewers pin, scripts unit tests, agent tiers, agent tiers self-test, conformance profile, profile self-test | every push to `main`, and by hand (`gh workflow run gates`) |
| `plan-gates` (`.github/workflows/plan.yml`) | the Python gates and the plan projection check | a push that touches `scripts/`, `.conclave/`, `.claude/`, `AGENTS.md`, `todo/`, `tools/githooks/`, `.gitattributes` or the workflow itself |

These are not gates of `check-all` and have no line in its summary, on the runner or here. Each needs this machine, and each is run locally by the section that owes it:

| Check | Why it stays local | Command |
| --- | --- | --- |
| Fenced tests | the `headful` label needs an interactive display session with the monitor and DPI a case declares, and the fence's idle signal | `ctest --preset headful` (or `headful-visible`) |
| Smoke run | launches the built tools and drives their windows in the operator's session | `python scripts/smoke-run.py` |
| Elevated smoke | runs through the one consented scheduled task, which exists on this machine only | `pwsh tools/elevated-smoke.ps1 -Run` |
| Parity against the AutoIt suite | needs the shipped AutoIt tool and its runtime beside the C++ one, and changes real system state inside a fixture | the parity cases a ported tool's section names (`tests/parity/`) |
| Device tests | need the USB device or optical drive a section's `Needs:` line names | the command that section's checkpoint gives |
| The nightly run | collects night-owed debt on this machine's idle signal | see "The nightly run" below |

Proof that the `gates` workflow can fail is a manual dispatch with `prove_red` set, which adds one failing Catch2 case to the runner's working copy for that run only. Such a run is named `gates (red proof)` and `ci-status.py` never counts it.

A full local `pwsh scripts/check-all.ps1` (through `bosun run --`) is for phase closeout, a release, and reproducing a red CI run.

## The quick-start lane

The `quick-start` workflow (`.github/workflows/quick-start.yml`, `D00 T05 §3`) runs the README's quick start on every push to `main`, as a cold reader would: from an empty folder on a fresh runner, with no toolchain cache and no compile cache.

- **No command is typed into the workflow.** `python scripts/quickstart.py run` reads the first `powershell` block under "## Quick start" in `README.md` and runs its lines word for word, in order, in one PowerShell 7 session. A README whose heading or block is gone fails the lane by name, and a command that no longer works fails it at that command, naming it.
- **The clone is the pushed commit.** The README's `git clone` line takes the head of `main`, which is a newer commit when a second push lands first. The workflow points git, for that one address, at a bare copy whose `main` is the pushed commit, so the line runs as written and gets that commit; the runner compares the two and refuses before bootstrap if they differ.
- **Every preset is built.** When the last command has passed, the runner reads `CMakePresets.json` in the clone and fails naming any configure preset whose build tree holds no build.
- **The pins are checked on every run.** With nothing cached, `scripts/bootstrap.ps1` downloads each component `toolchain.json` pins and refuses one whose SHA-256 differs, naming it.
- **Nothing it starts is left running.** The session runs in a job object the runner owns (`scripts/lib/win_job.py`), ended when the run returns: finished, failed or timed out.

`python scripts/ci-status.py` owes this lane for every commit that carries its workflow file, so a commit is green only when `gates` and `quick-start` both are. It takes far longer than `gates`, because nothing is cached; work on the next row goes on while it runs.

Proof that a wrong pin fails the lane is a manual dispatch with `prove_wrong_pin` set, which changes one pinned hash in the clone for that run only. Such a run is named `quick-start (red proof)`, and `ci-status` never counts it.

### What a first run needs

Two facts about a first run are worked out from the tree by `python scripts/quickstart.py facts`, printed into the lane's summary, and fail the lane when either stops being true:

- **`.env` does not apply.** No `.env` file is tracked, and no script or build file names one or loads one. Every setting is a script parameter, listed in the README's Configuration section.
- **A first run takes from outside the clone only what is pinned:** the components `toolchain.json` pins by SHA-256, downloaded by `scripts/bootstrap.ps1`, and two sources CMake fetches at a pinned commit, Catch2 (`tests/CMakeLists.txt`) and Lucide (`shared/lucide/CMakeLists.txt`). Nothing else seeds it: no data, account, service or earlier build.

Every tracked file that reaches the network is recorded in `FETCHERS` in `scripts/quickstart.py` with what it is to a first run. A new one fails the check until it is recorded there, and so does a `FetchContent_Declare` pinned to a tag and not a full commit hash.

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

A capture's image and sidecar are two files, and Windows cannot replace two files at once, so a pair is bound by content: the sidecar records `image sha256` of its image (`D00 T02 §13`). Before trusting a pair, a reader runs `pwsh scripts/capture-window.ps1 -Verify <png>`, which exits 0 only when the image is the one its sidecar describes; a mismatch, a missing file, or a sidecar written before pairs were bound is refused by name.

A collecting case also needs the operator away at its own start (no input for 120 seconds, `fence::kCollectIdleMs`). Every case runs in its own process, so when the operator comes back, the case in progress stands down on the input and every later case skips as `the operator is active ...; re-queued`, rather than taking a fresh baseline and the desktop with it.

Placement tags: `[place:primary]` puts the case's windows on the primary monitor; `[place:dpi96]` and `[place:dpi144]` put them on the monitor at that DPI, because the case proves rendering at that scale. A case whose monitor is not attached skips with `hardware absent`, and the night runner re-probes it. `tests/focus-audit.md` gives each fenced case's reason.

## Elevated smoke: three routes, one consent model

Elevation is a process token a child inherits from its parent, never from another window on the desktop. That one fact decides which route an elevated smoke run takes:

- **Manual runs** start from an elevated terminal. Children of that terminal inherit its token, `scripts/smoke-run.py` sees it is already elevated, and no prompt ever appears.
- **Unattended runs** use the `\Resolute\ElevatedSmoke` scheduled task (`tools/elevated-smoke.ps1`). A nightly parent or an unattended run's session is not a child of an elevated terminal, so one left open cannot help it; the task is registered once (`-Register`, one consent prompt, highest privilege, interactive logon) and later runs start it with `-Run` and no prompt. The task runs the driver collecting (`RESOLUTE_IDLE_COLLECT=1`), never with `--visible`, so the fence and its stand-down on operator input still apply.
- **Attended one-offs** use `python scripts/smoke-run.py --elevate`, which relaunches through the shell consent prompt each time (D07 T01 §5).

The task's trust boundary is that nothing it runs elevated is read from a place another account can write. This checkout grants Modify to Authenticated Users, and so, measured on 2026-11-13, did the machine's own Python folder and the task's folder under `C:\ProgramData` as first created, so a fixed argument list bounds nothing by itself. Four things hold the boundary:

- **The directory.** `C:\ProgramData\Resolute\ElevatedSmoke` is written only by Administrators and SYSTEM. Registration sets that on the directory itself with inheritance from `ProgramData` cut (a new folder there lets ordinary users create files in it), removes anything it did not put there, and rebuilds the run directory.
- **The drivers.** Registration records the SHA-256 of `scripts/smoke-run.py` and `scripts/conformance-check.py` in `trusted-hashes.txt` in that directory. Before each run the wrapper verifies the checkout bytes against those hashes, stages them into the directory, verifies the copies, and executes only the copies with `python -I` and `RESOLUTE_SMOKE_ROOT` naming the checkout under test, so no checkout path (its modules, import shadowing, or a swap after verification) supplies code. Registration refuses a driver that is on disk with CRLF line endings, because git never writes those for these paths and a pin taken over them breaks the next time git rewrites the file.
- **Python.** The task runs the repository's pinned Python (`reskit/python`), copied into that directory at registration, never the machine's own `python`.
- **The tools under test.** They change with every build, so they cannot be pinned at registration. `-Run`, as the operator, records the SHA-256 of each executable about to be tested under `HKCU\Software\Resolute\ElevatedSmoke\Manifest` (the operator's own hive, refused if another principal can write the key). The elevated driver copies each executable into the directory, verifies the copy against that record, and launches the copy; a tool that is missing from the record, or changed after it, gets `refused` rows and is not launched. A copy in a directory nobody else can write has no planted DLL beside it, and each tool is one self-contained executable by the suite's own rule.

The action itself runs Windows PowerShell by its full path with the protected directory as its working directory. Editing either driver after registration buys a named refusal and a re-registration prompt, never silent elevated execution of new code. `RunAsInvoker` is never used: it does not elevate, so it cannot prove an elevated step.

`tools/elevated-smoke.ps1 -Readback` prints what the boundary rests on as it is now: the task's principal, action and security descriptor, who can write each pinned driver, and who owns the directory and its parent. A registration is one transaction: the new Python and the new pinned hashes are written beside the live ones, the task is registered, both are switched in with the previous ones kept, and the same readiness list a run is refused on is asked last. A failure at any step, a refusal by that list included, puts back the previous task, pinned hashes and Python, the directory's owner and permissions, and the owner of the folder that holds it. `tools/elevated-smoke.ps1 -SelfTest` runs that transaction for real in a sandbox (a throwaway limited task and a temporary directory), failing it after every step and reading the previous registration back. A registration that never reaches its commit, because its process was killed or the machine restarted, leaves a journal, `registration.journal`, written before anything it describes changed and saying only what was there before. While it is there `-Check` and `-Run` refuse with "an interrupted registration was found" and start nothing, and the next `-Register` recovers it first: the kept copies go back, a task that did not exist before is removed, the previous task definition is restored, the result is read back against the journal, and only then does the journal go (or the whole directory, when there was none before). A recovery that cannot finish says so and leaves the journal and the kept copies for the next attempt. A journal is read only in a directory that passes its own checks and when Administrators or SYSTEM own it; any other is removed unread. A recovery, unlike the rollback of a registration that failed in its own process, leaves the directory's owner and permissions and its parent's owner as the interrupted registration set them: a registration only ever tightens them, and a recovery does not reopen a directory on the word of a file inside it. Registrations, recoveries, runs and removals take turns under one machine-wide lock that the system releases when its holder dies: a registration started during another, or during a run, is refused, and a run or a removal started during a registration is refused before it changes anything. What it does not restore: the run directory's staged copies (the next run stages them again), Administrators' ownership of the files inside the directory, and any entry registration removed as unexpected, which is gone and is named when that happens. `tools/elevated-smoke.ps1 -Register -Replace -ProveRollback` proves the restoration at a registration: the elevated copy first fails on purpose, reads the previous state back and refuses to go on if anything differs. What the elevated copy says is kept in `register-log.txt` in the protected directory and printed by `-Register`.

One exposure remains and is accepted: the driver writes its report and captures under `build/smoke` in the checkout, as every smoke run does, so an account that can write the checkout could redirect those files (a report and PNG captures, never code) to another folder. Reversing that would mean a second report location for elevated runs and a copy back, which nothing has needed yet.

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
| 02:00 to 06:50 local | Night | both halves at main's head, then the debt |
| otherwise, unlocked and idle 10 minutes | Collect | the debt only, each fenced case standing down on input |
| otherwise | none | nothing; it exits |

`-Mode Manual` runs both halves and the debt at any hour; the fenced cases still gate themselves (`tests/fence.h`), so a manual run by day proves the plumbing without taking the desktop.

### What a run does

1. Takes `build/nightly/.lock` exclusively; a second run exits at once.
2. Probes the session: lock state, idle time, and every monitor's size and DPI, read per-monitor aware (unaware, every DPI reads 96).
3. Builds each commit it tests in its own git worktree under `build/nightly/wt/<sha>/`, with the toolchain linked in. It never builds in, or writes to, the working tree the writer uses; everything it writes is ignored scratch under `build/nightly/`.
4. Default half: `ctest --preset debug -V` at main's head. Green means every test passed and every census is clean.
5. Fenced half: `ctest --preset headful -V` at main's head, skipped as a whole when the session is locked (a locked desktop cannot show windows; the skip is logged and the run goes on). Green means every case passed on its declared monitor and DPI, or skipped with a reason: outside the window, operator input, or `hardware absent` when a declared DPI has no monitor.
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

Each rule's drill, from D00 T02 §11's runs (build/nightly/<id>/ is ignored scratch; the quotes are the record):

| Rule | Drill | Result |
| --- | --- | --- |
| Candidate binding | a `Night-verified:` line for another candidate beside an owed case | `night-debt: 1 open`: it cleared nothing |
| Retry | run `20260927-031026`: one case that cannot run, one real case | attempt 1 `"Drill no such fenced case" Not Run; "The popup menu returns the command the keyboard chooses" Passed`; attempt 2 ran only the first |
| Second red | run `20260927-024103`: a case red in both executed attempts | `REOPEN D00 T02 §10 through audit stance: "Drill no such fenced case" red twice at candidate 2ff3bf4d...` |
| Incomplete attempt | run `20260927-035629`: an attempt ctest could not finish | `candidate 2ff3bf4d attempt 1: incomplete, ctest exit 8; the debt stays owed`, and no reopen |
| Interruption | D00 T02 §10's stand-down drills, and the scheduled run `20260927-020508` | `SKIP "..." the operator is active (last input 0 s ago, under the 120 s a collecting case needs); re-queued` for every fenced case |
| Hardware absent | a launcher case declared at 192 DPI | `SKIP "Launcher capture, dark at 150 percent" hardware absent: no monitor at 192 DPI; re-probed each night`, no window opened |
| One writer | a second run started beside a first | it exited at once; one run directory made |
| No orphans | `ctest --preset headful-visible -R "Launcher capture, dark at 150 percent" --timeout 3` | `***Timeout 3.09 sec`, then no launcher and no capture process running |

### Logs and the report

Each run has a unique id, `YYYYMMDD-HHMMSS`, and its own directory: `build/nightly/<id>/run.log`, `default.log`, `full.log`, `debt-<sha>-a<attempt>.log`, and the build logs. The report is `build/nightly/<id>/report.md`, copied to the fixed path `build/nightly/morning-report.md`, which is the file to read first; `build/nightly/latest.txt` names the latest run. A worked example:

```
# Nightly report 20260927-020500

mode Night; main 74dba449...; started 2026-09-27 02:05:00; idle 13200s; session unlocked
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
