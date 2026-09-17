<#
.SYNOPSIS
    Build any tool in the suite, or all of them.

.DESCRIPTION
    The one build command. Replaces reskit/Build-Resolute.ps1,
    reskit/Build-Extension.ps1 and reskit/Build-All.ps1, which D00 T01 §4
    removed: three near-identical scripts is the fourteen-copies failure
    AGENTS.md exists to prevent, arriving one script at a time. One of the
    three was also silently broken, deciding whether to build the launcher by
    testing for a `shell/` directory that does not exist.

    TARGETS
      Resolute      the launcher, built from the root through its CMake preset
      <Extension>   any directory under extensions/ holding a CMakeLists.txt,
                    built STANDALONE the way it ships, with its own project()
                    call and without the root ever being read

    The standalone extension path is deliberate and is not an implementation
    detail. D00 T01 §2 shipped a defect that only appeared there: flags set at
    the root never reach an extension its own script configures directly, and
    the independent review found it by building RegStudio that way. A build
    command that only ever built extensions through the root would not be able
    to see that class of defect at all.

    OUTPUT, one documented place
      Bin\<Config>\Resolute.exe          the launcher
      Bin\<Config>\System\<Tool>.exe     every extension
    where <Config> is Debug or Release. Nothing is written outside the
    repository and no absolute path is baked into any build file: the AutoIt
    suite under resolute_au3/ no longer builds because 13 .sni descriptors
    point at R:\Workspace\Resolute, which stopped existing.

    ARCHITECTURE
      x86-64 only. D00 T01 §1 recorded that as a dated default: ARM64 is out of
      scope until there is a machine to drive a test on, and i686 is outside
      the Windows 10 1809 floor's practical audience.

.PARAMETER Name
    The tool to build. Omit with -All.

.PARAMETER All
    Build the launcher and every extension.

.PARAMETER Config
    Debug or Release. Defaults to Release.

.EXAMPLE
    pwsh scripts/build.ps1 Resolute
    pwsh scripts/build.ps1 RegStudio -Config Debug
    pwsh scripts/build.ps1 -All
#>

[CmdletBinding(DefaultParameterSetName = 'One')]
param(
    [Parameter(ParameterSetName = 'One', Position = 0, Mandatory = $true)]
    [string]$Name,

    [Parameter(ParameterSetName = 'All', Mandatory = $true)]
    [switch]$All,

    [ValidateSet('Debug', 'Release')]
    [string]$Config = 'Release'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = Split-Path $PSScriptRoot -Parent

# CMake reads a backslash as an escape in the cache files it writes, so any
# tool path handed to it must use forward slashes. D00 T01 §2 learned this when
# CMakeRCCompiler.cmake failed to parse.
$RepoRootFwd = $RepoRoot -replace '\\', '/'

$Cmake = Join-Path $RepoRoot 'reskit\cmake\bin\cmake.exe'
$Ninja = Join-Path $RepoRoot 'reskit\ninja\ninja.exe'

# ── The toolchain has to be there before anything is built ───
#
# Failing by name here rather than letting cmake fail somewhere downstream:
# D00 T01 §1 made the locator report what it looked for and what fixes it, and
# a build command that dies with "command not found" undoes that.
function Assert-Toolchain {
    $missing = @()
    if (-not (Test-Path $Cmake)) { $missing += 'reskit\cmake\bin\cmake.exe' }
    if (-not (Test-Path $Ninja)) { $missing += 'reskit\ninja\ninja.exe' }
    $clang = Join-Path $RepoRoot 'reskit\llvm-mingw\bin\clang++.exe'
    if (-not (Test-Path $clang)) { $missing += 'reskit\llvm-mingw\bin\clang++.exe' }

    if ($missing.Count -gt 0) {
        Write-Host 'build: the portable toolchain is not installed' -ForegroundColor Red
        foreach ($m in $missing) { Write-Host "  missing: $m" -ForegroundColor Red }
        Write-Host '  fix    : pwsh scripts/bootstrap.ps1' -ForegroundColor Yellow
        exit 1
    }
}

# ── What the project defines ─────────────────────────────────
#
# Discovered rather than listed, so a tool added under extensions/ is built by
# -All without this script being edited. A hardcoded list is how the AutoIt
# tree ended up with descriptors nobody maintained.
function Get-Extensions {
    $dir = Join-Path $RepoRoot 'extensions'
    if (-not (Test-Path $dir)) { return @() }
    return @(Get-ChildItem -Path $dir -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName 'CMakeLists.txt') })
}

function Get-OutputDir {
    param([string]$Configuration)
    return (Join-Path $RepoRoot "Bin\$Configuration")
}

# ── Keep the diagnostics, bound the output ───────────────────
#
# Piping a failed compile to Out-Null throws away the one thing the reader
# needs: ninja prints the failing command and the compiler's diagnostics on
# stdout. The full log is kept under build/logs/, which is gitignored, and a
# bounded excerpt is printed on failure. That is AGENTS.md's output discipline
# rather than an exception to it, and the independent review found the script
# reporting "compile failed" with nothing a reader could act on.
$LogDir = Join-Path $RepoRoot 'build\logs'

function Invoke-Logged {
    param([string]$LogName, [scriptblock]$Command)

    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    $log = Join-Path $LogDir "$LogName.log"
    & $Command 2>&1 | Tee-Object -FilePath $log | Out-Null
    $code = $LASTEXITCODE
    if ($code -ne 0) {
        Write-Host "  --- last 25 lines of $LogName.log ---" -ForegroundColor DarkYellow
        Get-Content $log -Tail 25 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkYellow }
        Write-Host "  --- full log: $log" -ForegroundColor DarkYellow
    }
    return $code
}

# ── The launcher ─────────────────────────────────────────────

function Build-Launcher {
    param([string]$Configuration)

    $preset = $Configuration.ToLowerInvariant()

    # `cmake --preset` looks for CMakePresets.json in the CURRENT directory, so
    # this has to run from the repository root or the launcher cannot be built
    # from anywhere else. Found by the independent review, which ran the script
    # from scripts/.
    Write-Host "  configuring Resolute ($Configuration)..." -ForegroundColor DarkGray
    Push-Location $RepoRoot
    try {
        $code = Invoke-Logged "Resolute-$Configuration-configure" { & $Cmake --preset $preset }
    }
    finally {
        Pop-Location
    }
    if ($code -ne 0) {
        Write-Host 'build: configure failed for Resolute' -ForegroundColor Red
        return $false
    }

    Write-Host "  compiling Resolute ($Configuration)..." -ForegroundColor DarkGray
    $code = Invoke-Logged "Resolute-$Configuration-build" { & $Cmake --build (Join-Path $RepoRoot "build\$preset") }
    if ($code -ne 0) {
        Write-Host 'build: compile failed for Resolute' -ForegroundColor Red
        return $false
    }

    # The root preset already sends the executable to Bin\<Config>, so there is
    # nothing to copy. Verified rather than assumed: a build command that
    # reports success without checking is what D00 T01 §1 and §2 each caught.
    $exe = Join-Path (Get-OutputDir $Configuration) 'Resolute.exe'
    if (-not (Test-Path $exe)) {
        Write-Host "build: Resolute.exe not found at $exe after a successful compile" -ForegroundColor Red
        return $false
    }
    return $true
}

# ── An extension, built the way it ships ─────────────────────

function Build-Extension {
    param([string]$ExtName, [string]$Configuration)

    $extPath = Join-Path $RepoRoot "extensions\$ExtName"
    $buildDir = Join-Path $extPath "build\$Configuration"

    New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

    Write-Host "  configuring $ExtName ($Configuration)..." -ForegroundColor DarkGray
    Push-Location $buildDir
    try {
        # --no-warn-unused-cli: an extension that declares only CXX leaves
        # CMAKE_C_COMPILER unused, and CMake says so on every configure. A
        # build command that prints a warning nobody can act on is a build
        # command whose output stops being read.
        $code = Invoke-Logged "$ExtName-$Configuration-configure" {
            & $Cmake "$extPath" -G Ninja --no-warn-unused-cli `
                "-DCMAKE_BUILD_TYPE=$Configuration" `
                "-DCMAKE_C_COMPILER=$RepoRootFwd/reskit/llvm-mingw/bin/clang.exe" `
                "-DCMAKE_CXX_COMPILER=$RepoRootFwd/reskit/llvm-mingw/bin/clang++.exe" `
                "-DCMAKE_RC_COMPILER=$RepoRootFwd/reskit/llvm-mingw/bin/llvm-windres.exe" `
                "-DCMAKE_MAKE_PROGRAM=$RepoRootFwd/reskit/ninja/ninja.exe"
        }
        if ($code -ne 0) {
            Write-Host "build: configure failed for $ExtName" -ForegroundColor Red
            return $false
        }

        Write-Host "  compiling $ExtName ($Configuration)..." -ForegroundColor DarkGray
        $code = Invoke-Logged "$ExtName-$Configuration-build" { & $Cmake --build . }
        if ($code -ne 0) {
            Write-Host "build: compile failed for $ExtName" -ForegroundColor Red
            return $false
        }
    }
    finally {
        Pop-Location
    }

    # Search ONLY this configuration's own build tree. The previous version also
    # searched the extension's source-tree bin\ and took whichever executable
    # was newest, and the independent review showed what that costs: RegStudio
    # wrote every configuration to one path, so building Release, then Debug,
    # then Release again left the Debug binary in place, up to date as far as
    # ninja was concerned, and it was deployed as Release. The two files were
    # byte-identical.
    #
    # The extension now writes to its build tree (extensions/<T>/build/<Config>),
    # so scoping the search to that tree makes cross-configuration contamination
    # impossible rather than unlikely. Looking in a shared directory and sorting
    # by timestamp is a guess; looking in exactly one place is an answer.
    $built = Get-ChildItem -Path $buildDir -Filter '*.exe' -File -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $built) {
        Write-Host "build: no .exe found for $ExtName after a successful compile" -ForegroundColor Red
        return $false
    }

    # Deploy into the configuration that was actually built. The old script
    # hardcoded Bin\Release\System, so a Debug build landed in the Release tree.
    $systemDir = Join-Path (Get-OutputDir $Configuration) 'System'
    New-Item -ItemType Directory -Force -Path $systemDir | Out-Null
    Copy-Item $built.FullName -Destination $systemDir -Force
    return $true
}

# ── Dispatch ─────────────────────────────────────────────────

Assert-Toolchain

$extensions = Get-Extensions
$results = [ordered]@{}

if ($All) {
    $targets = @('Resolute') + @($extensions | ForEach-Object { $_.Name })
}
else {
    $known = @('Resolute') + @($extensions | ForEach-Object { $_.Name })
    $match = $known | Where-Object { $_ -ieq $Name } | Select-Object -First 1
    if (-not $match) {
        Write-Host "build: unknown tool '$Name'" -ForegroundColor Red
        Write-Host "  known targets: $($known -join ', ')" -ForegroundColor Yellow
        Write-Host '  or build everything with: pwsh scripts/build.ps1 -All' -ForegroundColor Yellow
        exit 2
    }
    $targets = @($match)
}

Write-Host "building $($targets.Count) target(s), $Config, x86-64" -ForegroundColor Cyan

foreach ($t in $targets) {
    if ($t -ieq 'Resolute') {
        $results[$t] = Build-Launcher -Configuration $Config
    }
    else {
        $results[$t] = Build-Extension -ExtName $t -Configuration $Config
    }
}

# ── Report every target and its result ───────────────────────

Write-Host ''
$failed = 0
foreach ($t in $results.Keys) {
    if ($results[$t]) {
        $where = if ($t -ieq 'Resolute') { "Bin\$Config\$t.exe" } else { "Bin\$Config\System\$t.exe" }
        Write-Host ("  {0,-16} OK      {1}" -f $t, $where) -ForegroundColor Green
    }
    else {
        Write-Host ("  {0,-16} FAILED" -f $t) -ForegroundColor Red
        $failed++
    }
}

Write-Host ''
if ($failed -gt 0) {
    Write-Host "build: $failed of $($results.Count) target(s) failed ($Config)" -ForegroundColor Red
    exit 1
}
Write-Host "build: $($results.Count) target(s) built, $Config, output under Bin\$Config\" -ForegroundColor Green
exit 0
