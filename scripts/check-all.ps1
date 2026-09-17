<#
.SYNOPSIS
    Run every gate this repository owes, in one command.

.DESCRIPTION
    The command a push owes. Five gates that must each be remembered are five
    gates that get skipped under time pressure, so "did you run the checks" has
    one answer: this.

    THE GATES
      build       Debug and Release, through scripts/build.ps1
      tidy        clang-tidy over our translation units, compared against
                  todo/.tidy-baseline
      tests       the Catch2 suite
      validate    the TODO graph, its self-test, and the plan projection
      claims      the TODOs' measured claims, and the findings ledger

    ARCHITECTURE, not plural. D00 T01 §1 recorded x86-64 as the only
    architecture built, with i686 "noted and not wanted" against the Windows 10
    1809 floor. "Both" here means both CONFIGURATIONS, Debug and Release.

    COMPARE, DO NOT RATCHET. The tidy gate fails when the finding count is
    above todo/.tidy-baseline. Rewriting the baseline down, naming which target
    regressed, and refusing a silent raise belong to D07 T01 §2.

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
$LogDir = Join-Path $RepoRoot 'build\logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$Cmake = Join-Path $RepoRoot 'reskit\cmake\bin\cmake.exe'
$ClangTidy = Join-Path $RepoRoot 'reskit\llvm-mingw\bin\clang-tidy.exe'
$Ctest = Join-Path $RepoRoot 'reskit\cmake\bin\ctest.exe'
$BaselineFile = Join-Path $RepoRoot 'todo\.tidy-baseline'

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
        [string]$TolerateWhen    # the condition that makes it tolerable
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

    [void]$results.Add([pscustomobject]@{
        Name = $Name; Status = if ($code -eq 0) { 'ok' } else { 'FAILED' }
        Seconds = [math]::Round($clock.Elapsed.TotalSeconds, 1)
        Log = $log; Detail = ''; Failed = ($code -ne 0)
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

# ── tidy, compared against the baseline ──────────────────────
#
# The count is unique (file, line, column, check) tuples with the path
# normalised, which is what todo/.tidy-baseline specifies and why it specifies
# it: a header diagnostic is reported once per translation unit that includes
# it, and the same header arrives under more than one spelling. Check names
# carry uppercase and dots, so the character class must too. D00 T01 §3 shipped
# a baseline of 52 instead of 59 by getting that one wrong.

function Get-TidyCount {
    param([string]$LogPath)
    $pattern = '^(?<file>.*?):(?<line>\d+):(?<col>\d+):\s+warning:\s+.*?\[(?<check>[A-Za-z0-9_.,-]+)\]\s*$'
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($text in (Get-Content $LogPath -ErrorAction SilentlyContinue)) {
        $m = [regex]::Match($text, $pattern)
        if (-not $m.Success) { continue }
        $file = $m.Groups['file'].Value -replace '\\', '/'
        try { $file = [System.IO.Path]::GetFullPath($file) -replace '\\', '/' } catch { }
        # A finding INSIDE a dependency is not ours, whichever translation
        # unit surfaced it. Filtering TUs by path is not enough once one of
        # our TUs includes a dependency's headers: D00 T02 §1 added tests/,
        # which includes Catch2, and 37 findings in catch2-src arrived in a
        # baseline that had never counted a dependency. Same by-construction
        # exemption the warning policy states, applied where the number is
        # actually computed.
        if ($file -match '/_deps/') { continue }
        $key = ($file.ToLowerInvariant() + '|' + $m.Groups['line'].Value + '|' +
                $m.Groups['col'].Value + '|' + $m.Groups['check'].Value)
        [void]$seen.Add($key)
    }
    return $seen.Count
}

if (-not $SkipBuild) {
    $tidyLog = Join-Path $LogDir 'gate-tidy.log'
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    $tidyStatus = 'ok'; $tidyDetail = ''; $tidyFailed = $false

    # EVERY compile database, not just the root's. RegStudio is commented out
    # of the root CMakeLists and builds standalone, so the root database does
    # not contain it and analysing only the root leaves an entire shipped
    # extension unchecked while the gate reports success. The independent
    # review of D00 T01 §5 found that: 0 RegStudio translation units in the
    # root database, and no database in its own build tree either.
    $databases = @(Join-Path $RepoRoot 'build\release\compile_commands.json')
    $extRoot = Join-Path $RepoRoot 'extensions'
    if (Test-Path $extRoot) {
        $databases += @(Get-ChildItem -Path $extRoot -Directory |
            ForEach-Object { Join-Path $_.FullName 'build\Release\compile_commands.json' })
    }
    $databases = @($databases | Where-Object { Test-Path $_ })

    if ($databases.Count -eq 0) {
        $tidyStatus = 'FAILED'; $tidyFailed = $true
        $tidyDetail = 'no compile database anywhere; the release build must run first'
        Set-Content -Path $tidyLog -Value $tidyDetail
    }
    else {
        $tus = @()
        foreach ($db in $databases) {
            $dir = Split-Path $db -Parent
            $tus += @((Get-Content $db -Raw | ConvertFrom-Json) |
                Where-Object { $_.file -notmatch '_deps' -and $_.file -notmatch '\.rc$' } |
                ForEach-Object { [pscustomobject]@{ File = $_.file; BuildDir = $dir } })
        }

        Remove-Item $tidyLog -ErrorAction SilentlyContinue
        # Track EVERY invocation's exit code. Ignoring them is how a gate comes
        # to report success on analysis that never ran: clang-tidy that fails to
        # configure or fails to parse emits errors and zero warnings, and a
        # counter that only counts warnings then reports 0, which is under any
        # baseline. The independent review reproduced exactly that.
        $failedRuns = 0
        foreach ($tu in $tus) {
            & $ClangTidy -p $tu.BuildDir --quiet $tu.File *>> $tidyLog
            if ($LASTEXITCODE -ne 0) { $failedRuns++ }
        }

        # An error diagnostic means the analysis did not complete over that
        # translation unit, so its warning count is not evidence of anything.
        $errorLines = @(Select-String -Path $tidyLog -Pattern 'clang-diagnostic-error|error: |Error while processing' `
            -ErrorAction SilentlyContinue)

        $count = Get-TidyCount -LogPath $tidyLog
        $baseline = $null
        foreach ($text in (Get-Content $BaselineFile)) {
            $t = $text.Trim()
            if ($t -and -not $t.StartsWith('#')) {
                if ($t -match '^count:\s*(\d+)$') { $baseline = [int]$Matches[1] }
                break
            }
        }

        if ($failedRuns -gt 0 -or $errorLines.Count -gt 0) {
            $tidyStatus = 'FAILED'; $tidyFailed = $true
            $tidyDetail = "analysis did not complete: $failedRuns of $($tus.Count) invocation(s) exited non-zero, $($errorLines.Count) error diagnostic(s). The finding count is not evidence until this is clean."
        }
        elseif ($null -eq $baseline) {
            $tidyStatus = 'FAILED'; $tidyFailed = $true
            $tidyDetail = "todo/.tidy-baseline has no 'count: <n>' line"
        }
        elseif ($count -gt $baseline) {
            $tidyStatus = 'FAILED'; $tidyFailed = $true
            $tidyDetail = "clang-tidy found $count finding(s), above the baseline of $baseline"
        }
        else {
            $tidyDetail = "$count finding(s), baseline $baseline, over $($tus.Count) TU(s) from $($databases.Count) database(s)"
        }
    }
    $clock.Stop()
    [void]$results.Add([pscustomobject]@{
        Name = 'tidy'; Status = $tidyStatus
        Seconds = [math]::Round($clock.Elapsed.TotalSeconds, 1)
        Log = $tidyLog; Detail = $tidyDetail; Failed = $tidyFailed
    })
}

# ── tests ────────────────────────────────────────────────────

# The not-present tolerance D00 T01 §5 left here is GONE, removed by
# D00 T02 §1 which landed the harness. A failing test now fails the gate.
Invoke-Gate -Name 'tests' -LogName 'gate-tests' -Command {
    & $Ctest --preset debug --output-on-failure
}

# ── validate, and the plan projection ────────────────────────

Invoke-Gate -Name 'graph validate' -LogName 'gate-validate' -Command {
    & python (Join-Path $RepoRoot 'scripts\todo-graph.py') validate
}
Invoke-Gate -Name 'graph self-test' -LogName 'gate-selftest' -Command {
    & python (Join-Path $RepoRoot 'scripts\todo-graph.py') self-test
}
Invoke-Gate -Name 'plan --check' -LogName 'gate-plan' -Command {
    & python (Join-Path $RepoRoot 'scripts\todo-graph.py') plan --check
}

# ── claims, and the findings ledger ──────────────────────────
#
# todo-claims.py exits non-zero on a stale claim AND on a fallen coverage
# floor, and both must fail here rather than print and be ignored. Registered
# by D00 T04 §1, which owns the checks and not this script.

Invoke-Gate -Name 'claims' -LogName 'gate-claims' -Command {
    & python (Join-Path $RepoRoot 'scripts\todo-claims.py')
}
Invoke-Gate -Name 'claims self-test' -LogName 'gate-claims-selftest' -Command {
    & python (Join-Path $RepoRoot 'scripts\todo-claims.py') --self-test
}
Invoke-Gate -Name 'findings ledger' -LogName 'gate-findings' -Command {
    & python (Join-Path $RepoRoot 'scripts\todo-findings.py') --check
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
    exit 1
}
$tolerated = @($results | Where-Object { $_.Status -eq 'not present' })
if ($tolerated.Count -gt 0) {
    Write-Host "check-all: $($results.Count) gate(s) ok, $($tolerated.Count) not present" -ForegroundColor Yellow
}
else {
    Write-Host "check-all: $($results.Count) gate(s) ok" -ForegroundColor Green
}
exit 0
