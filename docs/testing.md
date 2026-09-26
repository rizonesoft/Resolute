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
