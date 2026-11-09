<#
.SYNOPSIS
    Capture the README proof shots of the launcher, with provenance.

.DESCRIPTION
    D00 T05 §1. Launches a built launcher, sizes it to 1600x1000, sets the
    appearance and list view through the toolbar's own commands
    (WM_COMMAND IDC_TB_THEME / IDC_TB_VIEW_*), and captures each shot with
    scripts/capture-window.ps1 so every PNG carries the D00 T02 §3
    provenance sidecar. Four shots: Details and Large Icons, each in dark
    and light, all at the same size and state within a theme pair.

    Reproduce (from a clean checkout built per the README quick start):

      pwsh scripts/bootstrap.ps1
      pwsh scripts/build.ps1 Resolute
      pwsh scripts/capture-launcher-readme.ps1 -Visible `
          -Exe <checkout>\Bin\Release\Resolute.exe `
          -CaptureScript <checkout>\scripts\capture-window.ps1 `
          -OutDir docs\captures

    The driver kills only the launcher processes it started.

.PARAMETER Exe
    The built launcher to capture.

.PARAMETER CaptureScript
    The capture-window.ps1 that writes the shots and sidecars. Point it at
    the same checkout as -Exe so the sidecar records that checkout's
    revision and executable hash.

.PARAMETER OutDir
    Where the PNGs and sidecars land.

.PARAMETER Date
    File-name date prefix. Defaults to today.
#>
param(
    [string]$Exe = (Join-Path $PSScriptRoot '..\Bin\Release\Resolute.exe'),
    [string]$CaptureScript = (Join-Path $PSScriptRoot 'capture-window.ps1'),
    [string]$OutDir = (Join-Path $PSScriptRoot '..\docs\captures'),
    [string]$Date = (Get-Date -Format 'yyyy-MM-dd'),
    # Desktop interaction is explicit: without -Visible the driver
    # refuses, and even with it, it stands down while the operator is
    # active (docs/testing.md's stand-down rule).
    [switch]$Visible
)

$ErrorActionPreference = 'Stop'
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Shot {
    [DllImport("user32.dll")] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr ctx);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
    [DllImport("user32.dll")] public static extern IntPtr SendMessageW(IntPtr h, uint msg, IntPtr w, IntPtr l);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool attach);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
}
'@
[Shot]::SetThreadDpiAwarenessContext([IntPtr](-4)) | Out-Null

if (-not $Visible) {
    Write-Host 'capture-launcher-readme: refusing to run without -Visible.' -ForegroundColor Red
    Write-Host '  This driver takes the foreground to capture; run it visibly, when the desktop is free.' -ForegroundColor DarkGray
    exit 2
}

Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Idle {
    [StructLayout(LayoutKind.Sequential)] public struct LASTINPUTINFO { public uint cbSize; public uint dwTime; }
    [DllImport("user32.dll")] public static extern bool GetLastInputInfo(ref LASTINPUTINFO info);
    [DllImport("kernel32.dll")] public static extern uint GetTickCount();
    public static double IdleSeconds() {
        var info = new LASTINPUTINFO(); info.cbSize = (uint)System.Runtime.InteropServices.Marshal.SizeOf(info);
        if (!GetLastInputInfo(ref info)) return 0;
        return (GetTickCount() - info.dwTime) / 1000.0;
    }
}
'@

# Wait until the operator has been idle for at least 3 seconds (up to
# 60), so a capture never pulls focus out of active work.
function Wait-OperatorIdle([string]$What) {
    foreach ($i in 1..120) {
        if ([Idle]::IdleSeconds() -ge 3) { return }
        Start-Sleep -Milliseconds 500
    }
    throw "operator is active; stood down before $What (docs/testing.md stand-down rule)"
}

$Exe = (Resolve-Path $Exe).Path
$CaptureScript = (Resolve-Path $CaptureScript).Path
$WorkingDir = Split-Path (Split-Path $Exe -Parent) -Parent
$HostName = $env:COMPUTERNAME

function Take-Shot([string]$State, [string]$Mode, [int]$Presses, [int]$ViewCmd) {
    $name = "$Date-D00-T05-s1-launcher-$State-$Mode"
    $out = Join-Path $OutDir "$name.png"
    $proc = Start-Process -FilePath $Exe -WorkingDirectory $WorkingDir -PassThru
    try {
        $hwnd = [IntPtr]::Zero
        foreach ($i in 1..50) {
            Start-Sleep -Milliseconds 200
            $proc.Refresh()
            if ($proc.MainWindowHandle -ne [IntPtr]::Zero) { $hwnd = $proc.MainWindowHandle; break }
        }
        if ($hwnd -eq [IntPtr]::Zero) { throw "no main window for $name" }
        [Shot]::SetWindowPos($hwnd, [IntPtr]::Zero, 40, 40, 1600, 1000, 0x0040) | Out-Null
        Start-Sleep -Milliseconds 500
        # The launcher starts in System appearance; its theme command
        # cycles System, Dark, Light, so one press is dark, two light.
        foreach ($i in 1..$Presses) {
            [Shot]::SendMessageW($hwnd, 0x0111, [IntPtr]1030, [IntPtr]::Zero) | Out-Null
            Start-Sleep -Milliseconds 900
        }
        [Shot]::SendMessageW($hwnd, 0x0111, [IntPtr]$ViewCmd, [IntPtr]::Zero) | Out-Null
        Start-Sleep -Milliseconds 700
        Wait-OperatorIdle "taking the foreground for $name"
        $fg = [Shot]::GetForegroundWindow()
        $pidOut = 0
        $theirs = [Shot]::GetWindowThreadProcessId($fg, [ref]$pidOut)
        $mine = [Shot]::GetCurrentThreadId()
        $attach = $false
        if ($theirs -ne 0 -and $theirs -ne $mine) { $attach = [Shot]::AttachThreadInput($mine, $theirs, $true) }
        [Shot]::SetForegroundWindow($hwnd) | Out-Null
        if ($attach) { [Shot]::AttachThreadInput($mine, $theirs, $false) | Out-Null }
        Start-Sleep -Milliseconds 600
        $describes = "the launcher $State view, $Mode, at 1600 px wide: visual proof for the README (D00 T05 section 1)"
        $fixture = "launcher built from a clean checkout (Bin/Release/Resolute.exe); host $HostName; appearance $Mode set by $Presses theme-command press(es) from System; view set by WM_COMMAND $ViewCmd"
        $context = "pwsh scripts/capture-launcher-readme.ps1 -Exe $Exe -CaptureScript $CaptureScript -OutDir $OutDir (this shot: theme x$Presses, view $ViewCmd, then capture-window.ps1 -ProcessId <pid> -Out $out)"
        & pwsh -NoProfile -File $CaptureScript -ProcessId $proc.Id -Appearance $Mode -Out $out -Describes $describes -Fixture $fixture -LaunchContext $context -FixtureFiles 'none beside Bin/Release (launcher only build)'
        if ($LASTEXITCODE -ne 0) { throw "capture-window failed for $name with $LASTEXITCODE" }
        Write-Output "SHOT $name ok"
    } finally {
        if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force }
    }
}

# IDC_TB_VIEW_DETAILS = 1004, IDC_TB_VIEW_LARGE = 1001 (toolbar.h).
Take-Shot 'details' 'dark' 1 1004
Take-Shot 'details' 'light' 2 1004
Take-Shot 'large-icons' 'dark' 1 1001
Take-Shot 'large-icons' 'light' 2 1001
