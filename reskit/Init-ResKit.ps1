<#
.SYNOPSIS
    Initialize ResKit portable toolchain for Resolute builds.

.DESCRIPTION
    Sets PATH to use ResKit tools (LLVM-MinGW, CMake, Ninja) instead of
    system-installed versions. Run this before any build scripts.
    
    Only modifies environment if the tools are actually present.

.EXAMPLE
    . .\reskit\Init-ResKit.ps1
    pwsh scripts\build.ps1 -All
#>

param(
    [switch]$Quiet
)

$ResKitRoot = $PSScriptRoot

# Tool paths
$LlvmBin = Join-Path $ResKitRoot "llvm-mingw\bin"
$CmakeBin = Join-Path $ResKitRoot "cmake\bin"
$NinjaBin = Join-Path $ResKitRoot "ninja"

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

# Prepend ResKit paths to PATH
if ($ToolPaths.Count -gt 0) {
    $env:PATH = ($ToolPaths -join ";") + ";" + $env:PATH
    
    if (-not $Quiet) {
        Write-Host "ResKit initialized ($($ToolPaths.Count) tools)" -ForegroundColor Green
        foreach ($p in $ToolPaths) {
            Write-Host "  $p" -ForegroundColor DarkGray
        }
    }
}
else {
    if (-not $Quiet) {
        Write-Host "ResKit: No tools found (run scripts\bootstrap.ps1 first)" -ForegroundColor Yellow
    }
}
