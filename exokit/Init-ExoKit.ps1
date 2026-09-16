<#
.SYNOPSIS
    Initialize ExoKit portable toolchain for ExoSuite builds.

.DESCRIPTION
    Sets PATH to use ExoKit tools (LLVM-MinGW, CMake, Ninja) instead of
    system-installed versions. Run this before any build scripts.
    
    Only modifies environment if the tools are actually present.

.EXAMPLE
    . .\exokit\Init-ExoKit.ps1
    exokit\Build-All.ps1
#>

param(
    [switch]$Quiet
)

$ExoKitRoot = $PSScriptRoot

# Tool paths
$LlvmBin = Join-Path $ExoKitRoot "llvm-mingw\bin"
$CmakeBin = Join-Path $ExoKitRoot "cmake\bin"
$NinjaBin = Join-Path $ExoKitRoot "ninja"

# Build list of existing tool paths
$ToolPaths = @()

if (Test-Path (Join-Path $LlvmBin "clang.exe")) {
    $ToolPaths += $LlvmBin
}

if (Test-Path (Join-Path $CmakeBin "cmake.exe")) {
    $ToolPaths += $CmakeBin
}

if (Test-Path (Join-Path $NinjaBin "ninja.exe")) {
    $ToolPaths += $NinjaBin
}

# Prepend ExoKit paths to PATH
if ($ToolPaths.Count -gt 0) {
    $env:PATH = ($ToolPaths -join ";") + ";" + $env:PATH
    
    if (-not $Quiet) {
        Write-Host "ExoKit initialized ($($ToolPaths.Count) tools)" -ForegroundColor Green
        foreach ($p in $ToolPaths) {
            Write-Host "  $p" -ForegroundColor DarkGray
        }
    }
}
else {
    if (-not $Quiet) {
        Write-Host "ExoKit: No tools found (run Bootstrap-ExoKit.ps1 first)" -ForegroundColor Yellow
    }
}
