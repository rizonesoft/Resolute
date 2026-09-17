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

    A GATE THAT CANNOT RUN YET. The Catch2 suite arrives with D00 T02 §1. Until
    then the tests gate reports "not present" and does NOT fail the run, and
    that tolerance is removed by the section that lands the harness. Reporting
    a gate as passed when it never ran would be worse than not having it.

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

    $db = Join-Path $RepoRoot 'build\release\compile_commands.json'
    if (-not (Test-Path $db)) {
        $tidyStatus = 'FAILED'; $tidyFailed = $true
        $tidyDetail = "no compile database at $db; the release build must run first"
        Set-Content -Path $tidyLog -Value $tidyDetail
    }
    else {
        $tus = (Get-Content $db -Raw | ConvertFrom-Json) |
            Where-Object { $_.file -notmatch '_deps' -and $_.file -notmatch '\.rc$' } |
            ForEach-Object { $_.file }

        Remove-Item $tidyLog -ErrorAction SilentlyContinue
        foreach ($tu in $tus) {
            & $ClangTidy -p (Join-Path $RepoRoot 'build\release') --quiet $tu *>> $tidyLog
        }

        $count = Get-TidyCount -LogPath $tidyLog
        $baseline = $null
        foreach ($text in (Get-Content $BaselineFile)) {
            $t = $text.Trim()
            if ($t -and -not $t.StartsWith('#')) {
                if ($t -match '^count:\s*(\d+)$') { $baseline = [int]$Matches[1] }
                break
            }
        }
        if ($null -eq $baseline) {
            $tidyStatus = 'FAILED'; $tidyFailed = $true
            $tidyDetail = "todo/.tidy-baseline has no 'count: <n>' line"
        }
        elseif ($count -gt $baseline) {
            $tidyStatus = 'FAILED'; $tidyFailed = $true
            $tidyDetail = "clang-tidy found $count finding(s), above the baseline of $baseline"
        }
        else {
            $tidyDetail = "$count finding(s), baseline $baseline"
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

$testsDir = Join-Path $RepoRoot 'tests'
Invoke-Gate -Name 'tests' -LogName 'gate-tests' `
    -Tolerate:(-not (Test-Path $testsDir)) `
    -TolerateWhen:$(if (Test-Path $testsDir) { '' } else { 'tests/ does not exist; D00 T02 §1 lands the harness and removes this tolerance' }) `
    -Command {
        & $Cmake --build (Join-Path $RepoRoot 'build\debug') --target test
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

# ── Report ───────────────────────────────────────────────────

Write-Host ''
foreach ($r in $results) {
    $colour = if ($r.Failed) { 'Red' } elseif ($r.Status -eq 'not present') { 'Yellow' } else { 'Green' }
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
