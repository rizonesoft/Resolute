<#
.SYNOPSIS
    Put the pinned Resolute-SDK at sdk/, or say why it is not there.

.DESCRIPTION
    The UI library, the icon set, the CMake policies and the toolchain live in
    their own repository, Resolute-SDK (operator decision 2026-11-15,
    docs/plans/2026-11-15-app-split.md). sdk.json is the only place this
    repository names it: the repository address and the commit it builds
    against. This script makes sdk/ be that commit.

    sdk/ is one of two things:

      a clone   made here from sdk.json's repository and checked out at its
                commit. What CI and a fresh machine get. A clone at another
                commit is moved to the pin.

      a link    a directory junction to a checkout the developer already has,
                named by the RESOLUTE_SDK_DIR environment variable. One
                checkout and one 2 GB toolchain then serve the launcher and
                every app on the machine. A linked checkout is never moved
                by this script, because it may hold work in progress: when
                its commit is not the pin, that is reported by name, and
                -Check fails on it.

    Nothing is deleted. A sdk/ that is neither of the two is reported and
    left alone.

.PARAMETER Check
    Change nothing. Exit 0 when sdk/ is present at the pinned commit with a
    clean tree, 1 otherwise, naming what differs. What a gate runs.

.EXAMPLE
    pwsh scripts/sdk.ps1
    pwsh scripts/sdk.ps1 -Check
#>

param(
    [switch]$Check
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PinFile  = Join-Path $RepoRoot 'sdk.json'
$SdkDir   = Join-Path $RepoRoot 'sdk'

function Fail([string]$Message, [string[]]$Detail = @()) {
    Write-Host "sdk: $Message" -ForegroundColor Red
    foreach ($d in $Detail) { Write-Host "  $d" -ForegroundColor DarkGray }
    exit 1
}

if (-not (Test-Path $PinFile)) { Fail "sdk.json is missing at $PinFile" @('It names the SDK repository and the commit this repository builds against.') }
try { $Pin = Get-Content $PinFile -Raw | ConvertFrom-Json } catch { Fail 'sdk.json is not valid JSON' @("parser: $($_.Exception.Message)") }
foreach ($field in 'repository', 'commit') {
    if ($null -eq $Pin.PSObject.Properties[$field] -or -not $Pin.$field) { Fail "sdk.json has no '$field'" }
}
if ($Pin.commit -notmatch '^[0-9a-f]{40}$') { Fail "sdk.json's commit is not a full 40-character hash" @("found: $($Pin.commit)", 'A branch or a tag can move; a pin cannot.') }

function Get-Head([string]$Dir) {
    $head = (& git -C $Dir rev-parse HEAD 2>$null)
    if ($LASTEXITCODE -ne 0) { return $null }
    return "$head".Trim()
}

function Test-Link([string]$Dir) {
    $item = Get-Item -LiteralPath $Dir -Force
    return [bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

# ── sdk/ is absent: link or clone ────────────────────────────
if (-not (Test-Path -LiteralPath $SdkDir)) {
    if ($Check) { Fail 'sdk/ is not present' @('fix: pwsh scripts/sdk.ps1') }
    $local = $env:RESOLUTE_SDK_DIR
    if ($local) {
        if (-not (Test-Path -LiteralPath (Join-Path $local 'cmake\ResoluteSdk.cmake'))) {
            Fail "RESOLUTE_SDK_DIR names $local, which is not a Resolute-SDK checkout" @('Unset it to clone the pinned SDK, or point it at the checkout.')
        }
        New-Item -ItemType Junction -Path $SdkDir -Target $local | Out-Null
        Write-Host "sdk: linked sdk/ to $local (RESOLUTE_SDK_DIR)" -ForegroundColor Green
    }
    else {
        Write-Host "sdk: cloning $($Pin.repository)" -ForegroundColor Yellow
        & git clone --quiet $Pin.repository $SdkDir
        if ($LASTEXITCODE -ne 0) { Fail "could not clone $($Pin.repository)" }
        & git -C $SdkDir checkout --quiet --detach $Pin.commit
        if ($LASTEXITCODE -ne 0) { Fail "the clone has no commit $($Pin.commit)" @('sdk.json pins a commit the repository does not hold.') }
        Write-Host "sdk: sdk/ is a clone at $($Pin.commit)" -ForegroundColor Green
    }
}

# ── sdk/ is present: is it the pin ───────────────────────────
$linked = Test-Link $SdkDir
$head = Get-Head $SdkDir
if (-not $head) { Fail 'sdk/ is present and is not a git checkout' @("path: $SdkDir", 'Nothing was changed. Move it aside and run this again.') }
if (-not (Test-Path -LiteralPath (Join-Path $SdkDir 'cmake\ResoluteSdk.cmake'))) { Fail 'sdk/ is a git checkout and is not Resolute-SDK' @("path: $SdkDir", 'Nothing was changed.') }

$kind = if ($linked) { 'link' } else { 'clone' }
if ($head -ne $Pin.commit) {
    if ($linked) {
        # Never moved: the developer's checkout may hold work in progress.
        $say = "the linked SDK checkout is at $head, sdk.json pins $($Pin.commit)"
        if ($Check) { Fail $say @('Check out the pin there, or bump sdk.json to the commit being built against.') }
        Write-Host "sdk: WARNING: $say" -ForegroundColor Yellow
        Write-Host '  The build uses the linked checkout as it is. Bump sdk.json before this is pushed.' -ForegroundColor DarkGray
        exit 0
    }
    if ($Check) { Fail "sdk/ is at $head, sdk.json pins $($Pin.commit)" @('fix: pwsh scripts/sdk.ps1') }
    & git -C $SdkDir fetch --quiet origin
    if ($LASTEXITCODE -ne 0) { Fail "could not fetch $($Pin.repository)" }
    & git -C $SdkDir checkout --quiet --detach $Pin.commit
    if ($LASTEXITCODE -ne 0) { Fail "could not check out $($Pin.commit) in sdk/" @('A local change in sdk/ may be in the way. Nothing was discarded.') }
    Write-Host "sdk: sdk/ moved to the pinned commit $($Pin.commit)" -ForegroundColor Green
    exit 0
}

if ($Check) {
    $dirty = @(& git -C $SdkDir status --porcelain)
    if ($dirty.Count -gt 0) { Fail "sdk/ is at the pin and has $($dirty.Count) uncommitted change(s)" @('What is built is then not what sdk.json names.') }
}
Write-Host "sdk: sdk/ is the pinned commit $($Pin.commit) ($kind)" -ForegroundColor Green
exit 0
