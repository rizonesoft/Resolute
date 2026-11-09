<#
.SYNOPSIS
    Run every gate this repository owes, in one command.

.DESCRIPTION
    The command a push owes. Five gates that must each be remembered are five
    gates that get skipped under time pressure, so "did you run the checks" has
    one answer: this.

    THE GATES
      build       Debug and Release, through scripts/build.ps1
      tidy        clang-tidy over our translation units, ratcheted against
                  todo/.tidy-baseline by scripts/tidy-ratchet.py
      tests       the Catch2 suite
      validate    the TODO graph, its self-test, and the plan projection
      claims      the TODOs' measured claims, and the findings ledger

    ARCHITECTURE, not plural. D00 T01 §1 recorded x86-64 as the only
    architecture built, with i686 "noted and not wanted" against the Windows 10
    1809 floor. "Both" here means both CONFIGURATIONS, Debug and Release.

    THE RATCHET ONLY GOES DOWN. scripts/tidy-ratchet.py (D07 T01 section 2)
    fails when a target's finding count is above todo/.tidy-baseline, names
    the target and its findings, rewrites the baseline down when the count
    drops, and refuses a baseline raise the base revision does not authorize.

    THE TESTS GATE RUNS FOR REAL. D00 T02 §1 landed the Catch2 harness and
    deleted the "not present" tolerance this script shipped with. A failing
    test now fails the gate, and `ctest` is configured with noTestsAction=error
    so a suite that discovers nothing fails rather than reporting success over
    zero tests, which is the same defect in a quieter form.

    The Invoke-Gate -Tolerate switch is kept and currently unused. It exists
    for the next gate that legitimately cannot run yet, and its contract is
    that a tolerated gate reports "not present" and is counted separately from
    ok, never folded into it.

.PARAMETER SkipBuild
    Skip the build and tidy gates. For a documentation-only change, where the
    plan checks are the only ones that can fail.

.EXAMPLE
    pwsh scripts/check-all.ps1
    pwsh scripts/check-all.ps1 -SkipBuild
#>

param(
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = Split-Path $PSScriptRoot -Parent

# Every gate runs from the repository root, once, here.
#
# Two gates resolve paths against the CURRENT directory rather than an
# absolute one: `ctest --preset` looks for CMakePresets.json beside it, and
# `plan --check` reads its derived JSON under build/. Run from scripts/, both
# fail with the tree perfectly healthy.
#
# D00 T01 §5's review found exactly this for `cmake --preset` and it was fixed
# for the launcher build alone. D00 T02 §1 then reintroduced the same class
# with `ctest --preset`. Fixing it per-invocation is what allowed that, so it
# is fixed once for the whole script instead: a command whose promise is that
# it can always be run should not care where it is run from.
Push-Location $RepoRoot
$LogDir = Join-Path $RepoRoot 'build\logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$Cmake = Join-Path $RepoRoot 'reskit\cmake\bin\cmake.exe'
$Ctest = Join-Path $RepoRoot 'reskit\cmake\bin\ctest.exe'

# The TODO scripts are stdlib-only and run under any Python 3, but the name
# on PATH differs by install: `python` usually, `python3` on some, `py`
# as the Windows launcher fallback. Resolve once so a
# bare `python` that is missing (or shadowed by the Store stub) fails here
# with a name, not eight gates down with a confusing error.
$Python = @('python', 'python3', 'py') | ForEach-Object {
    Get-Command $_ -ErrorAction SilentlyContinue
} | Select-Object -First 1 -ExpandProperty Source
if (-not $Python) { throw 'check-all: no Python 3 on PATH (looked for python, python3, py)' }

$results = [System.Collections.ArrayList]::new()

# ── One gate, one line, detail only when it fails ────────────
#
# A run that dumps every passing gate's output is a run nobody reads, which is
# how a gate comes to be ignored. The full log is always written; only a failing
# gate prints an excerpt.
function Invoke-Gate {
    param(
        [string]$Name,
        [scriptblock]$Command,
        [string]$LogName,
        [switch]$Tolerate,       # report and do not fail the run
        [string]$TolerateWhen,   # the condition that makes it tolerable
        [string]$DetailPattern   # log lines matching this become the gate's Detail
    )

    $log = Join-Path $LogDir "$LogName.log"
    $clock = [System.Diagnostics.Stopwatch]::StartNew()

    $skipped = $false
    if ($Tolerate -and $TolerateWhen) {
        $skipped = $true
    }

    if ($skipped) {
        $clock.Stop()
        [void]$results.Add([pscustomobject]@{
            Name = $Name; Status = 'not present'; Seconds = 0.0; Log = $log
            Detail = $TolerateWhen; Failed = $false
        })
        return
    }

    try {
        & $Command 2>&1 | Tee-Object -FilePath $log | Out-Null
        $code = $LASTEXITCODE
    }
    catch {
        $_ | Out-String | Tee-Object -FilePath $log | Out-Null
        $code = 1
    }
    $clock.Stop()

    $detail = ''
    if ($DetailPattern) {
        # A passing gate that changed something (a rewritten baseline)
        # must say so where the developer is looking, not only in its
        # log: an invisible baseline rewrite is a change nobody commits
        # on purpose (D07 T01 section 2, repair2 completion gap 1).
        $detail = @((Get-Content $log -ErrorAction SilentlyContinue) |
            Where-Object { $_ -match $DetailPattern } |
            ForEach-Object { ($_ -replace '^tidy-ratchet: ', '').Trim() }) -join ' | '
    }
    [void]$results.Add([pscustomobject]@{
        Name = $Name; Status = if ($code -eq 0) { 'ok' } else { 'FAILED' }
        Seconds = [math]::Round($clock.Elapsed.TotalSeconds, 1)
        Log = $log; Detail = $detail; Failed = ($code -ne 0)
    })
}

Write-Host ''
Write-Host 'check-all: running every gate' -ForegroundColor Cyan
Write-Host ''

# ── build ────────────────────────────────────────────────────

if (-not $SkipBuild) {
    Invoke-Gate -Name 'build Debug' -LogName 'gate-build-debug' -Command {
        & pwsh -NoProfile -File (Join-Path $RepoRoot 'scripts\build.ps1') -All -Config Debug
    }
    Invoke-Gate -Name 'build Release' -LogName 'gate-build-release' -Command {
        & pwsh -NoProfile -File (Join-Path $RepoRoot 'scripts\build.ps1') -All -Config Release
    }
}

# -- tidy: the one-way ratchet (D07 T01 section 2) -------------
#
# scripts/tidy-ratchet.py owns this gate now: it runs clang-tidy over
# every compile database, counts unique findings per target and
# globally, compares against todo/.tidy-baseline, refuses a silent
# baseline raise against the base revision, rewrites the baseline
# down when the count drops, and refuses duplicate resource ids.
# The counting rule lives in todo/.tidy-baseline: unique
# (file, line, column, check) tuples, path normalised, analyzer
# check names keep their uppercase and dots (the 52-instead-of-59
# lesson from D00 T01 section 3).

if (-not $SkipBuild) {
    Invoke-Gate -Name 'tidy ratchet' -LogName 'gate-tidy-ratchet' -DetailPattern '^tidy-ratchet: ' -Command {
        & $Python (Join-Path $RepoRoot 'scripts\tidy-ratchet.py') --log (Join-Path $LogDir 'gate-tidy.log') --result-json (Join-Path $LogDir 'gate-tidy-result.json')
    }
}
Invoke-Gate -Name 'ratchet self-test' -LogName 'gate-ratchet-selftest' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\tidy-ratchet.py') --self-test
}

# -- conformance: the profile against every shipped tool (D07 T01 section 3) --
#
# Runs after build and ratchet because C24 consumes their current
# evidence (the ratchet's raw log, recounted per target). Skipped
# with the build; its self-test always runs. A clause fails here
# only when its owner section has shipped; open owners report
# not-yet-evaluable in the matrix, never a silent pass.

if (-not $SkipBuild) {
    Invoke-Gate -Name 'conformance check' -LogName 'gate-conformance' -DetailPattern '^conformance: \d+ clause|^conformance detail: .*\(advisory FAIL' -Command {
        & $Python (Join-Path $RepoRoot 'scripts\conformance-check.py') --tidy-log (Join-Path $LogDir 'gate-tidy.log') --tidy-result (Join-Path $LogDir 'gate-tidy-result.json')
    }
}
Invoke-Gate -Name 'conformance self-test' -LogName 'gate-conformance-selftest' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\conformance-check.py') --self-test
}

# ── tests ────────────────────────────────────────────────────

# The not-present tolerance D00 T01 §5 left here is GONE, removed by
# D00 T02 §1 which landed the harness. A failing test now fails the gate.
Invoke-Gate -Name 'tests debug' -LogName 'gate-tests-debug' -Command {
    & $Ctest --preset debug --output-on-failure
}
# D00 T01 §8: the same suite under release, where asserts compile out and
# the optimizer runs, so a debug-only pass cannot gate the tree. Each preset
# is its own gate: one green run never covers the other.
Invoke-Gate -Name 'tests release' -LogName 'gate-tests-release' -Command {
    & $Ctest --preset release --output-on-failure
}

# ── validate, and the plan projection ────────────────────────

Invoke-Gate -Name 'graph validate' -LogName 'gate-validate' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\todo-graph.py') validate
}
Invoke-Gate -Name 'graph self-test' -LogName 'gate-selftest' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\todo-graph.py') self-test
}
Invoke-Gate -Name 'plan --check' -LogName 'gate-plan' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\todo-graph.py') plan --check
}

# ── claims, review-dispatch, and run-guard ───────────────────
#
# todo-claims.py exits non-zero on a stale claim AND on a fallen coverage
# floor, and both must fail here rather than print and be ignored. Registered
# by D00 T04 §1, which owns the checks and not this script.

Invoke-Gate -Name 'claims' -LogName 'gate-claims' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\todo-claims.py')
}
Invoke-Gate -Name 'claims self-test' -LogName 'gate-claims-selftest' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\todo-claims.py') --self-test
}
# The fence's debt check: every fenced case ends green or night-owed
# (D00 T02 §10).
Invoke-Gate -Name 'fence-debt self-test' -LogName 'gate-fence-debt-selftest' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\fence-debt.py') --self-test
}
Invoke-Gate -Name 'night-debt self-test' -LogName 'gate-night-debt-selftest' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\todo-night-debt.py') --self-test
}
# The fenced inventory reconciles both ways: every discovered [headful]
# test has a focus-audit row, and every fenced row names a discovered test
# (D00 T02 section 12).
Invoke-Gate -Name 'fence-inventory self-test' -LogName 'gate-fence-inventory-selftest' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\fence-inventory.py') --self-test
}
Invoke-Gate -Name 'fence inventory' -LogName 'gate-fence-inventory' -Command {
    $list = Join-Path $LogDir 'headful-list.txt'
    & $Ctest --test-dir (Join-Path $RepoRoot 'build\debug') -N -L headful | Out-File -FilePath $list -Encoding utf8
    & $Python (Join-Path $RepoRoot 'scripts\fence-inventory.py') --list $list
}
# The review wiring (.conclave/reviewers.toml, max medium effort) and
# unit tests for review-dispatch.py, dispatch_hook.py, and run-guard.py.
Invoke-Gate -Name 'reviewers pin' -LogName 'gate-reviewers-pin' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\review-dispatch.py') --check-pin
}
Invoke-Gate -Name 'scripts unit tests' -LogName 'gate-scripts-unittests' -Command {
    & $Python -m unittest discover -s (Join-Path $RepoRoot 'scripts\tests')
}
Invoke-Gate -Name 'agent tiers' -LogName 'gate-agent-tiers' -Command {
    & node (Join-Path $RepoRoot 'scripts\verify-agent-tiers.mjs')
}

# The conformance profile is a contract other domains are measured against, so
# a clause whose owner section was renumbered away would otherwise dangle with
# nothing noticing. This checks the DOCUMENT; D07 T01 §3 checks tools against
# it, and the two are separate because a broken profile makes every tool result
# meaningless and has to be visible on its own. D07 T01 §1.
Invoke-Gate -Name 'conformance profile' -LogName 'gate-profile' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\profile-check.py')
}
Invoke-Gate -Name 'profile self-test' -LogName 'gate-profile-selftest' -Command {
    & $Python (Join-Path $RepoRoot 'scripts\profile-check.py') --self-test
}

# ── toolchain currency, ADVISORY ─────────────────────────────
#
# A pin that has fallen behind is information, not a failure. The build is
# reproducible either way, which is the entire point of pinning, so a stale
# pin must never stop a push. D00 T01 §6.
#
# But "could not reach the API" is reported as its own thing, because an
# unreachable network is not a current pin and saying so would be a check
# claiming success for work it never did. Exit 2 means unknown.

$tcLog = Join-Path $LogDir 'gate-toolchain.log'
$tcClock = [System.Diagnostics.Stopwatch]::StartNew()
& pwsh -NoProfile -File (Join-Path $RepoRoot 'scripts\toolchain-latest.ps1') *> $tcLog
$tcCode = $LASTEXITCODE
$tcClock.Stop()

# Computed separately rather than inside the switch: `'x', (a) -join ';'`
# joins across the comma, which collapsed both values into one string and
# printed "unknown; System.Object[]" the first time this was written.
$tcBehind = @(Select-String -Path $tcLog -Pattern 'is behind, pinned' -ErrorAction SilentlyContinue |
    ForEach-Object { $_.Line.Trim() -replace '^toolchain-latest: ', '' })

$tcStatus = switch ($tcCode) {
    0       { 'ok' }
    1       { 'behind' }
    2       { 'unknown' }
    default { 'unknown' }
}
# A pin confirmed behind is reported even when another lookup failed, because
# it is a fact the check established. D00 T01 §6's independent review.
$tcDetail = switch ($tcCode) {
    0       { 'all pins current' }
    1       { $tcBehind -join '; ' }
    2       { (@('upstream unreachable; currency not checked, not current') + $tcBehind) -join '; ' }
    default { "toolchain-latest exited $tcCode" }
}
[void]$results.Add([pscustomobject]@{
    Name = 'toolchain'; Status = $tcStatus
    Seconds = [math]::Round($tcClock.Elapsed.TotalSeconds, 1)
    Log = $tcLog; Detail = $tcDetail; Failed = $false
})


# ── Report ───────────────────────────────────────────────────

Write-Host ''
foreach ($r in $results) {
    $colour = if ($r.Failed) { 'Red' }
              elseif ($r.Status -eq 'not present' -or $r.Status -eq 'behind') { 'Yellow' }
              elseif ($r.Status -eq 'unknown') { 'DarkYellow' }
              else { 'Green' }
    $secs = $r.Seconds.ToString('0.0', [System.Globalization.CultureInfo]::InvariantCulture)
    $line = '  {0,-18} {1,-12} {2,6}s' -f $r.Name, $r.Status, $secs
    if ($r.Detail) { $line += "  $($r.Detail)" }
    # An advisory finding on a passing gate names its full report, or the developer is told something is wrong with nowhere to read it (D07 T01 section 3, repair3 plan).
    if ($r.Detail -match 'advisory') { $line += "  (full report: $($r.Log))" }
    Write-Host $line -ForegroundColor $colour
}

$failed = @($results | Where-Object { $_.Failed })

# Detail for failing gates only. A passing gate's output stays in its log.
foreach ($r in $failed) {
    Write-Host ''
    Write-Host "  --- $($r.Name): last 25 lines of $(Split-Path $r.Log -Leaf) ---" -ForegroundColor DarkYellow
    Get-Content $r.Log -Tail 25 -ErrorAction SilentlyContinue |
        ForEach-Object { Write-Host "  $_" -ForegroundColor DarkYellow }
    Write-Host "  --- full log: $($r.Log)" -ForegroundColor DarkYellow
}

Write-Host ''
if ($failed.Count -gt 0) {
    Write-Host "check-all: $($failed.Count) of $($results.Count) gate(s) FAILED" -ForegroundColor Red
    Pop-Location
    exit 1
}
$tolerated = @($results | Where-Object { $_.Status -eq 'not present' })
if ($tolerated.Count -gt 0) {
    Write-Host "check-all: $($results.Count) gate(s) ok, $($tolerated.Count) not present" -ForegroundColor Yellow
}
else {
    Write-Host "check-all: $($results.Count) gate(s) ok" -ForegroundColor Green
}
Pop-Location
exit 0
