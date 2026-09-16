<#
.SYNOPSIS
    Bootstrap ExoKit toolchain for ExoSuite.

.DESCRIPTION
    Downloads and installs the required C++ build tools into the exokit/ folder.
    Run this once before building ExoSuite.

.EXAMPLE
    .\exokit\Bootstrap-ExoKit.ps1
#>

param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$ExoKitRoot = $PSScriptRoot

Write-Host "ExoKit Bootstrap" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan

# Tool versions
$LlvmVersion = "20251216"
$CmakeVersion = "4.2.3"
$NinjaVersion = "1.13.1"

# Directories
$LlvmDir = Join-Path $ExoKitRoot "llvm-mingw"
$CmakeDir = Join-Path $ExoKitRoot "cmake"
$NinjaDir = Join-Path $ExoKitRoot "ninja"

# Download URLs
$LlvmUrl = "https://github.com/mstorsjo/llvm-mingw/releases/download/$LlvmVersion/llvm-mingw-$LlvmVersion-ucrt-x86_64.zip"
$CmakeUrl = "https://github.com/Kitware/CMake/releases/download/v$CmakeVersion/cmake-$CmakeVersion-windows-x86_64.zip"
$NinjaUrl = "https://github.com/ninja-build/ninja/releases/download/v$NinjaVersion/ninja-win.zip"

function Install-Tool {
    param(
        [string]$Name,
        [string]$Url,
        [string]$DestDir,
        [string]$ExtractPath
    )
    
    if ((Test-Path $DestDir) -and -not $Force) {
        Write-Host "  [SKIP] $Name already installed" -ForegroundColor DarkGray
        return
    }
    
    Write-Host "  [DOWNLOAD] $Name..." -ForegroundColor Yellow
    $tempZip = Join-Path $env:TEMP "$Name.zip"
    
    Invoke-WebRequest -Uri $Url -OutFile $tempZip -UseBasicParsing
    
    Write-Host "  [EXTRACT] $Name..." -ForegroundColor Yellow
    $tempExtract = Join-Path $env:TEMP "$Name-extract"
    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
    
    # Find the actual content (may be in a subfolder)
    $content = Get-ChildItem $tempExtract
    if ($content.Count -eq 1 -and $content[0].PSIsContainer) {
        $source = $content[0].FullName
    }
    else {
        $source = $tempExtract
    }
    
    if (Test-Path $DestDir) { Remove-Item $DestDir -Recurse -Force }
    Move-Item $source $DestDir -Force
    
    Remove-Item $tempZip -Force
    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
    
    Write-Host "  [OK] $Name installed" -ForegroundColor Green
}

# Install LLVM-MinGW
Write-Host ""
Write-Host "[1/3] LLVM-MinGW" -ForegroundColor Cyan
Install-Tool -Name "llvm-mingw" -Url $LlvmUrl -DestDir $LlvmDir

# Install CMake
Write-Host ""
Write-Host "[2/3] CMake" -ForegroundColor Cyan
Install-Tool -Name "cmake" -Url $CmakeUrl -DestDir $CmakeDir

# Install Ninja
Write-Host ""
Write-Host "[3/3] Ninja" -ForegroundColor Cyan
Install-Tool -Name "ninja" -Url $NinjaUrl -DestDir $NinjaDir

Write-Host ""
Write-Host "ExoKit bootstrap complete!" -ForegroundColor Green
Write-Host "Run '.\exokit\Init-ExoKit.ps1' to activate the toolchain." -ForegroundColor DarkGray
