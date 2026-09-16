<#
.SYNOPSIS
    Build a single extension.

.DESCRIPTION
    Builds a specific extension to Bin/Release/System/.

.PARAMETER Name
    Name of the extension (folder name in extensions/).

.EXAMPLE
    .\exokit\Build-Extension.ps1 -Name regstudio
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [switch]$Release
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent

# Initialize ExoKit if available
$ExoKitInit = Join-Path $RepoRoot "exokit\Init-ExoKit.ps1"
if (Test-Path $ExoKitInit) {
    . $ExoKitInit -Quiet
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
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=$BuildType -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
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
$BuiltExe = Get-ChildItem -Path $BuildDir -Filter "*.exe" -Exclude "*.dir" | Select-Object -First 1
if ($BuiltExe) {
    Copy-Item $BuiltExe.FullName -Destination $SystemDir -Force
    Write-Host "[3/3] Done! Output: Bin\Release\System\$($BuiltExe.Name)" -ForegroundColor Green
}
else {
    Write-Host "[3/3] Warning: No .exe found in build output" -ForegroundColor Yellow
}
