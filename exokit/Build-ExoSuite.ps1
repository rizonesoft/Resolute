<#
.SYNOPSIS
    Build ExoSuite main application.

.DESCRIPTION
    Builds ExoSuite to Bin/Release/ExoSuite.exe with progress display.

.EXAMPLE
    .\exokit\Build-ExoSuite.ps1 -Release
#>

param(
    [switch]$Release
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent

# Initialize ExoKit
$ExoKitInit = Join-Path $RepoRoot "exokit\Init-ExoKit.ps1"
if (Test-Path $ExoKitInit) {
    . $ExoKitInit -Quiet
}

if (-not (Test-Path (Join-Path $RepoRoot "CMakeLists.txt"))) {
    Write-Host "Error: Root CMakeLists.txt not found." -ForegroundColor Red
    exit 1
}

$BuildType = if ($Release) { "Release" } else { "Debug" }
$BuildDir = Join-Path $RepoRoot "build\$($BuildType.ToLower())"

Write-Host "[1/3] Configuring ExoSuite ($BuildType)..." -ForegroundColor Cyan

if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
}

Push-Location $BuildDir
$cmakeResult = & cmake $RepoRoot -G Ninja "-DCMAKE_BUILD_TYPE=$BuildType" "-DCMAKE_C_COMPILER=clang" "-DCMAKE_CXX_COMPILER=clang++" 2>&1
$cmakeExit = $LASTEXITCODE
$cmakeResult | Out-Host
if ($cmakeExit -ne 0) {
    Pop-Location
    Write-Host "CMake configure failed!" -ForegroundColor Red
    exit 1
}

Write-Host "[2/3] Compiling ExoSuite..." -ForegroundColor Cyan
$ninjaResult = & ninja 2>&1
$ninjaExit = $LASTEXITCODE
$ninjaResult | Out-Host
Pop-Location

if ($ninjaExit -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "[3/3] Done! Output: Bin\$BuildType\ExoSuite.exe" -ForegroundColor Green
