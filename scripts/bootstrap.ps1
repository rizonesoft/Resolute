<#
.SYNOPSIS
    Bootstrap everything a build of Resolute needs: the pinned SDK, then the
    pinned toolchain the SDK carries.

.DESCRIPTION
    Two steps, each owned by the file that holds its pin:

      1. scripts/sdk.ps1 puts Resolute-SDK at sdk/, at the commit sdk.json
         names.
      2. sdk/scripts/bootstrap.ps1 reads sdk/toolchain.json and populates
         sdk/reskit/ with llvm-mingw, CMake, Ninja, the pinned CPython and
         sccache, each checked against its SHA-256.

    The toolchain's versions, URLs and hashes moved to the SDK with the
    toolchain on 2026-11-15 (docs/plans/2026-11-15-app-split.md), so the
    launcher and every app build with the same one.

.EXAMPLE
    pwsh scripts/bootstrap.ps1
    pwsh scripts/bootstrap.ps1 -Force        # re-download even if present
    pwsh scripts/bootstrap.ps1 -Replace      # replace a non-pinned version
#>

param(
    [switch]$Force,
    [switch]$Replace
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot

& pwsh -NoProfile -File (Join-Path $PSScriptRoot 'sdk.ps1')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$inner = Join-Path $RepoRoot 'sdk\scripts\bootstrap.ps1'
if (-not (Test-Path $inner)) {
    Write-Host "bootstrap: sdk/ has no scripts/bootstrap.ps1 at $inner" -ForegroundColor Red
    Write-Host '  The pinned SDK commit does not carry the toolchain bootstrap. Check sdk.json.' -ForegroundColor DarkGray
    exit 1
}
$pass = @()
if ($Force) { $pass += '-Force' }
if ($Replace) { $pass += '-Replace' }
& pwsh -NoProfile -File $inner @pass
exit $LASTEXITCODE
