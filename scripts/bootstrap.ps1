<#
.SYNOPSIS
    Bootstrap the pinned C++ toolchain for Resolute.

.DESCRIPTION
    Reads toolchain.json, which is the only place a version, URL or hash is
    written, and populates reskit/ with llvm-mingw, CMake and Ninja.

    Three properties this script owes, each one a D00 T01 §1 item:

      * It DETECTS BEFORE IT DOWNLOADS, and detects the pinned version
        specifically. A directory holding some other release does not satisfy
        the check: that is the whole point of pinning, and accepting any
        present toolchain makes two machines disagree while both report success.
      * It VERIFIES THE HASH of everything it downloads and refuses to install
        on a mismatch, leaving reskit/ untouched.
      * It FAILS BY NAME. Every refusal says which component, what was found,
        what was wanted, and the command that fixes it.

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

# This script lives in scripts/; the toolchain is its sibling reskit/.
$RepoRoot   = Split-Path -Parent $PSScriptRoot
$ResKitRoot = Join-Path $RepoRoot 'reskit'
$Manifest   = Join-Path $RepoRoot 'toolchain.json'

if (-not (Test-Path $Manifest)) {
    Write-Host "bootstrap: toolchain.json is missing at $Manifest" -ForegroundColor Red
    Write-Host "  Nothing is pinned, so there is nothing to install. This file is the" -ForegroundColor DarkGray
    Write-Host "  single source of versions, URLs and hashes." -ForegroundColor DarkGray
    exit 1
}

try {
    $Pins = Get-Content $Manifest -Raw | ConvertFrom-Json
} catch {
    # A parser stack trace names the parser, not the problem. This script
    # promises to fail by name, and "toolchain.json is not valid JSON" is the
    # name. Found by self-review of D00 T01 §1.
    Write-Host "bootstrap: toolchain.json is not valid JSON" -ForegroundColor Red
    Write-Host "  file  : $Manifest" -ForegroundColor DarkGray
    Write-Host "  parser: $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "  Nothing was read, so nothing was changed." -ForegroundColor DarkGray
    exit 1
}
if (-not $Pins.components) {
    Write-Host "bootstrap: toolchain.json has no 'components' array" -ForegroundColor Red
    Write-Host "  file: $Manifest" -ForegroundColor DarkGray
    Write-Host "  There is nothing pinned, so there is nothing to act on." -ForegroundColor DarkGray
    exit 1
}

# Every component must declare the fields these scripts trust. An absent
# `reportsOwnVersion` reads as $null, which is falsy, which silently routes a
# component down the stamp-trust path: an optional field that changes what is
# believed about a binary. Found by self-review of D00 T01 §1.
$required = @('name','version','url','sha256','dir','probe','versionArgs','versionMatch','reportsOwnVersion')
foreach ($c in $Pins.components) {
    foreach ($f in $required) {
        if ($null -eq $c.PSObject.Properties[$f]) {
            Write-Host "bootstrap: toolchain.json component is missing a required field" -ForegroundColor Red
            Write-Host "  component: $(if ($c.name) { $c.name } else { '<unnamed>' })" -ForegroundColor DarkGray
            Write-Host "  missing  : $f" -ForegroundColor DarkGray
            Write-Host "  Every field is required. An absent one would be read as a" -ForegroundColor DarkGray
            Write-Host "  default, and these decide what is trusted about a binary." -ForegroundColor DarkGray
            exit 1
        }
    }
}

Write-Host "ResKit Bootstrap" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan
Write-Host "  pins dated $($Pins.pinned), $($Pins.components.Count) component(s)" -ForegroundColor DarkGray
Write-Host ""

New-Item -ItemType Directory -Force -Path $ResKitRoot | Out-Null

function Get-InstalledVersion {
    <#  The version a component REPORTS, not the directory it sits in. A folder
        name can say anything; the binary cannot. #>
    param($Component, [string]$Dir)

    $probe = Join-Path $Dir $Component.probe
    if (-not (Test-Path $probe)) { return $null }
    try {
        $out = & $probe @($Component.versionArgs) 2>&1 | Out-String
    } catch {
        return $null
    }
    if ($out -match $Component.versionMatch) { return $Matches[1] }
    return $null
}

function Test-PinnedVersion {
    <#  llvm-mingw reports a clang version, not its own release date, so its
        release cannot be read back from the binary. For that component the
        pinned marker is a stamp file this script writes after a verified
        install: the ONLY thing that can attest to which archive was unpacked. #>
    param($Component, [string]$Dir)

    $reported = Get-InstalledVersion -Component $Component -Dir $Dir
    if ($null -eq $reported) { return $false }   # cannot probe: not the pin
    if ($Component.reportsOwnVersion) {
        # Its own answer is authoritative; a stamp cannot override it.
        return ($reported -eq $Component.version)
    }
    $stamp = Join-Path $Dir '.pinned-version'
    return (Test-Path $stamp) -and ((Get-Content $stamp -Raw).Trim() -eq $Component.version)
}

function Assert-InsideResKit {
    <#  Every Remove-Item in this script deletes a path built from a `dir` value
        in toolchain.json. That file is tracked and trusted, but a destructive
        operation driven by a config value with no bounds check is exactly what
        AGENTS.md means by an unconfirmed destructive path: `"dir": "../.."`
        would recursively delete the repository. Found by self-review of
        D00 T01 §1. #>
    param([string]$Path, [string]$Component)

    $full = [System.IO.Path]::GetFullPath($Path)
    $root = [System.IO.Path]::GetFullPath($ResKitRoot)
    if (-not $full.StartsWith($root + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "bootstrap: refusing to touch a path outside reskit/" -ForegroundColor Red
        Write-Host "  component: $Component" -ForegroundColor DarkGray
        Write-Host "  resolved : $full" -ForegroundColor DarkGray
        Write-Host "  reskit   : $root" -ForegroundColor DarkGray
        Write-Host "  Fix the 'dir' value in toolchain.json. Nothing was changed." -ForegroundColor DarkGray
        exit 1
    }
}

$installed = 0
$skipped   = 0
$i         = 0

foreach ($c in $Pins.components) {
    $i++
    $dir = Join-Path $ResKitRoot $c.dir
    Assert-InsideResKit -Path $dir -Component $c.name
    Write-Host "[$i/$($Pins.components.Count)] $($c.name) $($c.version)" -ForegroundColor Cyan

    if ((Test-Path $dir) -and -not $Force) {
        if (Test-PinnedVersion -Component $c -Dir $dir) {
            Write-Host "  [SKIP] pinned version already present" -ForegroundColor DarkGray
            $skipped++
            continue
        }

        # Present, but NOT the pin. Silence here is what makes two machines
        # disagree while both report success.
        $found = Get-InstalledVersion -Component $c -Dir $dir
        $hasStamp = Test-Path (Join-Path $dir '.pinned-version')
        $foundText = if (-not $hasStamp) {
            # No stamp means this install was not made by a verified run of this
            # script, so its provenance is unknown. Saying "found 21.1.8" would
            # be worse than saying nothing: 21.1.8 is the clang version, not the
            # llvm-mingw release, and the two are not comparable.
            if ($found) {
                "an install with no verified-provenance stamp (its $($c.name) reports $found)"
            } else {
                "an install with no verified-provenance stamp"
            }
        } elseif ($found) { $found } else { 'an unrecognised build' }
        if (-not $Replace) {
            Write-Host "  [STOP] $($c.name) is present but is not the pinned version" -ForegroundColor Red
            Write-Host "         found:  $foundText" -ForegroundColor Red
            Write-Host "         wanted: $($c.version)" -ForegroundColor Red
            Write-Host "         Re-run with -Replace to overwrite it, or delete $dir" -ForegroundColor DarkGray
            Write-Host "         Decided 2026-09-17: report and stop rather than replace" -ForegroundColor DarkGray
            Write-Host "         silently. An unasked-for replacement discards a toolchain" -ForegroundColor DarkGray
            Write-Host "         somebody may have put there deliberately, and the cost of" -ForegroundColor DarkGray
            Write-Host "         being wrong is higher than one extra flag." -ForegroundColor DarkGray
            exit 1
        }
        # NOT deleted here. The old install stays until a replacement has been
        # downloaded, hash-verified and extracted, because a network failure or
        # a hash mismatch between the delete and the install would destroy a
        # working toolchain while the abort message claimed reskit/ was
        # unchanged. That message was a lie for exactly this window. Found by
        # the independent review of 6bb635e, which reproduced the loss.
        Write-Host "  [REPLACE] found $foundText, wanted $($c.version)" -ForegroundColor Yellow
    }

    Write-Host "  [DOWNLOAD] $($c.url.Split('/')[-1])" -ForegroundColor Yellow
    $tempZip = Join-Path $env:TEMP "reskit-$($c.name).zip"
    if (Test-Path $tempZip) { Remove-Item $tempZip -Force }
    Invoke-WebRequest -Uri $c.url -OutFile $tempZip -UseBasicParsing

    Write-Host "  [VERIFY] sha256" -ForegroundColor Yellow
    $actual = (Get-FileHash $tempZip -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $c.sha256.ToLower()) {
        Remove-Item $tempZip -Force
        Write-Host "  [ABORT] $($c.name) hash mismatch. Nothing was installed." -ForegroundColor Red
        Write-Host "          expected: $($c.sha256)" -ForegroundColor Red
        Write-Host "          actual:   $actual" -ForegroundColor Red
        Write-Host "          The archive at that URL is not the archive this" -ForegroundColor DarkGray
        Write-Host "          repository pinned. Either the release was re-cut in" -ForegroundColor DarkGray
        Write-Host "          place, or the download is not what it claims to be." -ForegroundColor DarkGray
        Write-Host "          reskit/ is unchanged." -ForegroundColor DarkGray
        exit 1
    }

    Write-Host "  [EXTRACT]" -ForegroundColor Yellow
    $tempExtract = Join-Path $env:TEMP "reskit-$($c.name)-extract"
    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

    # The content may sit in a single wrapper directory, or at the archive root.
    $content = Get-ChildItem $tempExtract
    $source = if ($content.Count -eq 1 -and $content[0].PSIsContainer) {
        $content[0].FullName
    } else {
        $tempExtract
    }

    # Everything above succeeded, so the replacement exists and is verified.
    # Only now does the old install go, and the window between the two is one
    # rename rather than a download.
    Assert-InsideResKit -Path $dir -Component $c.name
    if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
    Move-Item -Path $source -Destination $dir -Force

    # Written only after a verified install, so it attests to what was unpacked
    # rather than to what somebody typed.
    Set-Content -Path (Join-Path $dir '.pinned-version') -Value $c.version -NoNewline -Encoding utf8

    Remove-Item $tempZip -Force
    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
    Write-Host "  [OK] installed" -ForegroundColor Green
    $installed++
}

Write-Host ""
Write-Host "ResKit bootstrap complete: $installed installed, $skipped already pinned." -ForegroundColor Green
Write-Host "Run '.\reskit\Init-ResKit.ps1' to put the toolchain on PATH." -ForegroundColor DarkGray
Write-Host "Run 'pwsh scripts/cpp-env.ps1' to check what resolves." -ForegroundColor DarkGray
