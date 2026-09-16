<#
.SYNOPSIS
    Build all ExoSuite components (shell + extensions).

.DESCRIPTION
    Builds ExoSuite shell and all extensions with progress display.
    Output goes to Bin/Release/ for shell and Bin/Release/System/ for extensions.

.EXAMPLE
    .\exokit\Build-All.ps1 -Release
#>

param(
    [switch]$Release
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent

# Initialize ExoKit if available
$ExoKitInit = Join-Path $RepoRoot "exokit\Init-ExoKit.ps1"
if (Test-Path $ExoKitInit) {
    . $ExoKitInit -Quiet
}

$OutputDir = Join-Path $RepoRoot "Bin\Release"
$SystemDir = Join-Path $OutputDir "System"

# Ensure output directories exist
New-Item -ItemType Directory -Force -Path $OutputDir, $SystemDir | Out-Null

$BuildType = if ($Release) { "Release" } else { "Debug" }

# Count components
$ShellDir = Join-Path $RepoRoot "shell"
$ExtensionsDir = Join-Path $RepoRoot "extensions"
$Extensions = @()
if (Test-Path $ExtensionsDir) {
    $Extensions = Get-ChildItem -Path $ExtensionsDir -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName "CMakeLists.txt") }
}

$HasShell = Test-Path (Join-Path $ShellDir "CMakeLists.txt")
$TotalSteps = ($HasShell ? 1 : 0) + $Extensions.Count + 1  # Shell + extensions + final step

$CurrentStep = 1

# Build shell (if exists)
if ($HasShell) {
    Write-Host "[$CurrentStep/$TotalSteps] Compiling ExoSuite shell ($BuildType)..." -ForegroundColor Cyan
    
    $BuildDir = Join-Path $ShellDir "build"
    if (-not (Test-Path $BuildDir)) {
        New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
    }
    
    Push-Location $BuildDir
    cmake .. -G Ninja -DCMAKE_BUILD_TYPE=$BuildType -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
    ninja
    Pop-Location
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Shell build failed!" -ForegroundColor Red
        exit 1
    }
    
    if ($Release) {
        $ShellExe = Get-ChildItem -Path $BuildDir -Filter "ExoSuite.exe" | Select-Object -First 1
        if ($ShellExe) {
            Copy-Item $ShellExe.FullName -Destination $OutputDir -Force
        }
    }
    $CurrentStep++
}

# Build extensions
foreach ($Ext in $Extensions) {
    Write-Host "[$CurrentStep/$TotalSteps] Compiling $($Ext.Name) ($BuildType)..." -ForegroundColor Cyan
    
    $ExtPath = $Ext.FullName
    $BuildDir = Join-Path $ExtPath "build"
    if (-not (Test-Path $BuildDir)) {
        New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
    }
    
    Push-Location $BuildDir
    cmake .. -G Ninja -DCMAKE_BUILD_TYPE=$BuildType -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
    ninja
    Pop-Location
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "$($Ext.Name) build failed!" -ForegroundColor Red
        exit 1
    }
    
    # Copy built exe to System folder
    if ($Release) {
        $BuiltExe = Get-ChildItem -Path $BuildDir -Filter "*.exe" -Exclude "*.dir" | Select-Object -First 1
        if ($BuiltExe) {
            Copy-Item $BuiltExe.FullName -Destination $SystemDir -Force
        }
    }
    
    $CurrentStep++
}

Write-Host "[$CurrentStep/$TotalSteps] Done! Output: Bin\Release\" -ForegroundColor Green
Write-Host ""
if ($HasShell) {
    Write-Host "  Shell:      Bin\Release\ExoSuite.exe" -ForegroundColor DarkGray
}
if ($Extensions.Count -gt 0) {
    Write-Host "  Extensions: Bin\Release\System\" -ForegroundColor DarkGray
}
