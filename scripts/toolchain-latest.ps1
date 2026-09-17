<#
.SYNOPSIS
    Report each toolchain pin against the latest upstream release.

.DESCRIPTION
    A pin with no expiry is how a project quietly ships a two-year-old
    compiler: the bootstrap keeps working, so nothing ever says the pin is old.
    D00 T01 §6 opened with llvm-mingw about nine months behind, found by asking
    rather than by anything noticing.

    ADVISORY, NEVER AUTOMATIC. This script reports. It does not edit
    toolchain.json and has no write path to it. An unattended bump of a
    compiler can break a build nobody is watching, and the reproducibility a
    pin buys is worth more than being current by a few days. The decision to
    move a pin is a person's, and D00 T01 §6 is what that decision looks like
    written down.

    EXIT CODES, and why "cannot reach" is not "behind":
      0  every pin is current
      1  at least one pin is behind, named with both versions
      2  the upstream API could not be reached
      3  toolchain.json could not be read or parsed

    Exit 2 is separate deliberately. Reporting an unreachable network as a
    stale pin asserts something the check never established, which is the
    defect D00 T04 §5 fixed in the adjacency advisory. Reporting it as
    "current" would be worse: that is a check claiming success for work it
    never did, which this file has now caught five times.

.PARAMETER TimeoutSec
    Per-request timeout. Default 20.

.EXAMPLE
    pwsh scripts/toolchain-latest.ps1
#>

param(
    [int]$TimeoutSec = 20
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = Split-Path $PSScriptRoot -Parent
$ManifestPath = Join-Path $RepoRoot 'toolchain.json'

# Where each component's releases live, and how to read a version out of a tag.
# Kept here rather than in toolchain.json because that file is the PIN, and a
# pin should not carry instructions for how to stop being one.
$Upstream = @{
    'llvm-mingw' = @{ Repo = 'mstorsjo/llvm-mingw'; Strip = $false }
    'cmake'      = @{ Repo = 'Kitware/CMake';       Strip = $true  }
    'ninja'      = @{ Repo = 'ninja-build/ninja';   Strip = $true  }
}

if (-not (Test-Path $ManifestPath)) {
    Write-Host "toolchain-latest: toolchain.json not found at $ManifestPath" -ForegroundColor Red
    exit 3
}
try {
    $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "toolchain-latest: toolchain.json could not be parsed" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    exit 3
}
if (-not $manifest.components) {
    Write-Host "toolchain-latest: toolchain.json has no 'components' array" -ForegroundColor Red
    exit 3
}

# Compare as version numbers where both sides look like versions, and as plain
# strings otherwise. llvm-mingw tags a date, 20260908, which sorts correctly as
# a string and would be mangled by a version parse.
function Test-Behind {
    param([string]$Pinned, [string]$Latest)
    if ($Pinned -eq $Latest) { return $false }
    $p = $null; $l = $null
    if ([version]::TryParse($Pinned, [ref]$p) -and [version]::TryParse($Latest, [ref]$l)) {
        return ($p -lt $l)
    }
    return ([string]::Compare($Pinned, $Latest, [System.StringComparison]::Ordinal) -lt 0)
}

$behind = [System.Collections.ArrayList]::new()
$unreachable = [System.Collections.ArrayList]::new()
$rows = [System.Collections.ArrayList]::new()

foreach ($component in $manifest.components) {
    $name = $component.name
    $pinned = $component.version

    if (-not $Upstream.ContainsKey($name)) {
        [void]$rows.Add([pscustomobject]@{
            Name = $name; Pinned = $pinned; Latest = '(no upstream configured)'; State = 'unknown' })
        continue
    }

    $repo = $Upstream[$name].Repo
    $api = "https://api.github.com/repos/$repo/releases/latest"
    try {
        $release = Invoke-RestMethod -Uri $api -TimeoutSec $TimeoutSec -Headers @{
            'Accept'     = 'application/vnd.github+json'
            'User-Agent' = 'resolute-toolchain-latest'
        }
    }
    catch {
        [void]$unreachable.Add($name)
        [void]$rows.Add([pscustomobject]@{
            Name = $name; Pinned = $pinned; Latest = '(unreachable)'; State = 'unreachable' })
        continue
    }

    $tag = [string]$release.tag_name
    $latest = if ($Upstream[$name].Strip) { $tag -replace '^v', '' } else { $tag }

    if (Test-Behind -Pinned $pinned -Latest $latest) {
        [void]$behind.Add([pscustomobject]@{ Name = $name; Pinned = $pinned; Latest = $latest })
        [void]$rows.Add([pscustomobject]@{
            Name = $name; Pinned = $pinned; Latest = $latest; State = 'behind' })
    }
    else {
        [void]$rows.Add([pscustomobject]@{
            Name = $name; Pinned = $pinned; Latest = $latest; State = 'current' })
    }
}

Write-Host ''
Write-Host 'toolchain-latest: pins against upstream' -ForegroundColor Cyan
Write-Host ''
foreach ($r in $rows) {
    $colour = switch ($r.State) {
        'behind'      { 'Yellow' }
        'unreachable' { 'DarkYellow' }
        'unknown'     { 'DarkGray' }
        default       { 'Green' }
    }
    Write-Host ('  {0,-12} pinned {1,-10} latest {2,-12} {3}' -f $r.Name, $r.Pinned, $r.Latest, $r.State) -ForegroundColor $colour
}
Write-Host ''

if ($unreachable.Count -gt 0) {
    Write-Host "toolchain-latest: could not reach upstream for $($unreachable -join ', '). Currency is UNKNOWN, not current." -ForegroundColor DarkYellow
    exit 2
}
if ($behind.Count -gt 0) {
    foreach ($b in $behind) {
        Write-Host "toolchain-latest: $($b.Name) is behind, pinned $($b.Pinned), latest $($b.Latest)" -ForegroundColor Yellow
    }
    Write-Host 'Moving a pin is a decision, not an update. See D00 T01 §6.' -ForegroundColor Yellow
    exit 1
}
Write-Host "toolchain-latest: all $($rows.Count) pin(s) current" -ForegroundColor Green
exit 0
