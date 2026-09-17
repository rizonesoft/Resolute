<#
.SYNOPSIS
    Build a single extension.

.DESCRIPTION
    Builds a specific extension to Bin/Release/System/.

.PARAMETER Name
    Name of the extension (folder name in extensions/).

.EXAMPLE
    .\reskit\Build-Extension.ps1 -Name regstudio
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [switch]$Release
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent
# CMake reads a backslash as an escape in the cache files it writes, so any
# tool path handed to it must use forward slashes. $RepoRoot is a Windows
# path; this is the same value with separators CMake can store.
$RepoRootFwd = $RepoRoot -replace '\\', '/'

# Initialize ResKit if available
$ResKitInit = Join-Path $RepoRoot "reskit\Init-ResKit.ps1"
if (Test-Path $ResKitInit) {
    . $ResKitInit -Quiet
}

$ExtPath = Join-Path $RepoRoot "extensions\$Name"
if (-not (Test-Path $ExtPath)) {
    Write-Host "Extension not found: $Name" -ForegroundColor Red
    exit 1
}

$CmakeLists = Join-Path $ExtPath "CMakeLists.txt"
if (-not (Test-Path $CmakeLists)) {
    Write-Host "No CMakeLists.txt found for $Name" -ForegroundColor Red
    exit 1
}

$SystemDir = Join-Path $RepoRoot "Bin\Release\System"
New-Item -ItemType Directory -Force -Path $SystemDir | Out-Null

$BuildType = if ($Release) { "Release" } else { "Debug" }
$BuildDir = Join-Path $ExtPath "build"

Write-Host "[1/3] Configuring $Name ($BuildType)..." -ForegroundColor Cyan

if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
}

Push-Location $BuildDir
cmake .. -G Ninja "-DCMAKE_BUILD_TYPE=$BuildType" -DCMAKE_C_COMPILER="$RepoRootFwd/reskit/llvm-mingw/bin/clang.exe" -DCMAKE_CXX_COMPILER="$RepoRootFwd/reskit/llvm-mingw/bin/clang++.exe" -DCMAKE_RC_COMPILER="$RepoRootFwd/reskit/llvm-mingw/bin/llvm-windres.exe" -DCMAKE_MAKE_PROGRAM="$RepoRootFwd/reskit/ninja/ninja.exe"
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    Write-Host "CMake configure failed!" -ForegroundColor Red
    exit 1
}

Write-Host "[2/3] Compiling $Name..." -ForegroundColor Cyan
ninja
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Copy built exe to System folder
# Search the build directory AND the extension's own bin/, because an
# extension may set CMAKE_RUNTIME_OUTPUT_DIRECTORY: RegStudio sends its
# executable to extensions/RegStudio/bin. Looking only in the build directory
# made this script warn "No .exe found" immediately after linking one, which
# teaches the reader to ignore its output. D00 T01 §2.
$SearchDirs = @($BuildDir, (Join-Path $ExtPath 'bin')) | Where-Object { Test-Path $_ }
$BuiltExe = $SearchDirs |
    ForEach-Object { Get-ChildItem -Path $_ -Filter "*.exe" -File -ErrorAction SilentlyContinue } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if ($BuiltExe) {
    Copy-Item $BuiltExe.FullName -Destination $SystemDir -Force
    Write-Host "[3/3] Done! Output: Bin\Release\System\$($BuiltExe.Name)" -ForegroundColor Green
}
else {
    Write-Host "[3/3] Warning: No .exe found in build output" -ForegroundColor Yellow
}
