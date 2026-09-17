<#
.SYNOPSIS
    Report every resolved toolchain component, and fail by name when one is missing.

.DESCRIPTION
    Answers one question: can this machine build Resolute right now, and if not,
    exactly which component is wrong and what fixes it.

    A check that says "toolchain not found" costs the reader a search. This one
    names the component, where it looked, what it found, what was wanted, and
    the command that repairs it. D00 T01 §1 requires that, and the reason is
    that this is the first script a new machine runs and the first one that can
    fail on it.

    Resolution order is fixed and reported: reskit/ first, then PATH. A
    repository-scoped component always wins over a machine-installed one of the
    same version, so two checkouts on one machine cannot silently differ.

.EXAMPLE
    pwsh scripts/cpp-env.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$RepoRoot   = Split-Path -Parent $PSScriptRoot
$ResKitRoot = Join-Path $RepoRoot 'reskit'
$Manifest   = Join-Path $RepoRoot 'toolchain.json'

if (-not (Test-Path $Manifest)) {
    Write-Host "cpp-env: toolchain.json is missing at $Manifest" -ForegroundColor Red
    Write-Host "  Nothing is pinned, so nothing can be checked." -ForegroundColor DarkGray
    exit 1
}

try {
    $Pins = Get-Content $Manifest -Raw | ConvertFrom-Json
} catch {
    # A parser stack trace names the parser, not the problem. This script
    # promises to fail by name, and "toolchain.json is not valid JSON" is the
    # name. Found by self-review of D00 T01 §1.
    Write-Host "cpp-env: toolchain.json is not valid JSON" -ForegroundColor Red
    Write-Host "  file  : $Manifest" -ForegroundColor DarkGray
    Write-Host "  parser: $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "  Nothing was read, so nothing was changed." -ForegroundColor DarkGray
    exit 1
}
if (-not $Pins.components) {
    Write-Host "cpp-env: toolchain.json has no 'components' array" -ForegroundColor Red
    Write-Host "  file: $Manifest" -ForegroundColor DarkGray
    Write-Host "  There is nothing pinned, so there is nothing to act on." -ForegroundColor DarkGray
    exit 1
}

Write-Host "Resolute C++ environment" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host "  pins dated $($Pins.pinned); resolution order: reskit/ then PATH" -ForegroundColor DarkGray
Write-Host ""

$problems = @()

foreach ($c in $Pins.components) {
    $dir    = Join-Path $ResKitRoot $c.dir
    $probe  = Join-Path $dir $c.probe
    $source = 'reskit'

    if (-not (Test-Path $probe)) {
        # Fall back to PATH, and say so: a machine-installed component is not
        # the same guarantee as a pinned one, and the report must not pretend
        # otherwise.
        $leaf = Split-Path $c.probe -Leaf
        $onPath = Get-Command $leaf -ErrorAction SilentlyContinue
        if ($onPath) {
            $probe  = $onPath.Source
            $source = 'PATH'
        } else {
            $problems += [pscustomobject]@{
                Name   = $c.name
                Reason = "not found"
                Looked = "$probe, then '$leaf' on PATH"
                Found  = "nothing"
                Wanted = $c.version
            }
            Write-Host ("  {0,-12} MISSING" -f $c.name) -ForegroundColor Red
            continue
        }
    }

    $reported = $null
    try {
        $out = & $probe @($c.versionArgs) 2>&1 | Out-String
        if ($out -match $c.versionMatch) { $reported = $Matches[1] }
    } catch {
        $reported = $null
    }

    # The probe must have answered. A component that cannot say what it is
    # cannot be accepted as the pin, whatever a file next to it claims.
    if ($null -eq $reported) {
        $pinnedOk = $false
    }
    elseif ($c.reportsOwnVersion) {
        # cmake and ninja report their real version, so that IS the answer.
        # A stamp cannot rescue a binary that reports something else.
        $pinnedOk = ($reported -eq $c.version)
    }
    elseif ($source -eq 'reskit') {
        # llvm-mingw reports a clang version, never its own release, so the
        # stamp bootstrap wrote after a verified install is the only attestation
        # available. It is trusted ONLY for the repository copy: reading it for
        # an executable that resolved from PATH let an unrelated binary pass on
        # the strength of a stamp belonging to something else. Found by the
        # independent review of 6bb635e, which reproduced it.
        $stamp = Join-Path $dir '.pinned-version'
        $pinnedOk = (Test-Path $stamp) -and ((Get-Content $stamp -Raw).Trim() -eq $c.version)
    }
    else {
        # From PATH, with no way to identify the release. Not the pin.
        $pinnedOk = $false
    }

    $shown = if ($reported) { $reported } else { 'unknown' }
    if ($pinnedOk) {
        Write-Host ("  {0,-12} {1,-10} {2,-7} {3}" -f $c.name, $shown, $source, $probe) -ForegroundColor Green
    } else {
        Write-Host ("  {0,-12} {1,-10} {2,-7} NOT THE PIN ({3})" -f $c.name, $shown, $source, $c.version) -ForegroundColor Yellow
        $problems += [pscustomobject]@{
            Name   = $c.name
            Reason = "present but not the pinned version"
            Looked = $probe
            Found  = $shown
            Wanted = $c.version
        }
    }
}

Write-Host ""

if ($problems.Count -eq 0) {
    Write-Host "All $($Pins.components.Count) component(s) resolve at the pinned version." -ForegroundColor Green
    exit 0
}

Write-Host "$($problems.Count) component(s) are not usable:" -ForegroundColor Red
foreach ($p in $problems) {
    Write-Host ""
    Write-Host "  $($p.Name): $($p.Reason)" -ForegroundColor Red
    Write-Host "    looked in : $($p.Looked)" -ForegroundColor DarkGray
    Write-Host "    found     : $($p.Found)" -ForegroundColor DarkGray
    Write-Host "    wanted    : $($p.Wanted)" -ForegroundColor DarkGray
}
Write-Host ""
Write-Host "  Fix: pwsh scripts/bootstrap.ps1" -ForegroundColor Yellow
Write-Host "       add -Replace if a different version is in the way." -ForegroundColor DarkGray
exit 1
