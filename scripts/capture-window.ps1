<#
.SYNOPSIS
    Capture a window to PNG, with the metadata that makes the capture evidence.

.DESCRIPTION
    D00 T02 §3. Every UI section in this plan carries a `Fidelity:` line naming
    an artifact it must match, and a capture nobody can reproduce is a
    screenshot rather than a baseline.

    So this writes two files: the PNG, and a `.txt` sidecar recording what was
    captured, from which binary, at what scaling, on what Windows build, and
    when. A capture whose provenance is unknown cannot be restaked.

    THIS SCRIPT SENDS NO INPUT. An earlier version drove menus with
    SetForegroundWindow plus SendKeys. SetForegroundWindow silently FAILS when
    called from a background process, so the keystrokes went to whichever
    application happened to own the foreground, which on this machine was an
    unrelated editor. Synthetic input is not a capture strategy on a machine
    somebody is using, and the capability is removed rather than gated: a
    surface behind a menu is opened by the operator, and this script attaches
    to the window that results.

    IT FAILS CLOSED. If the target does not own the foreground at the moment of
    capture, it refuses rather than copying whatever is on top of it. A capture
    of an overlapping window filed as the target's evidence is worse than no
    capture.

    IT KILLS ONLY WHAT IT STARTED. Processes matching the target are recorded
    BEFORE launching, and only a process that appeared afterwards is ever
    stopped. An AutoIt tool launches a 32-bit stub that relaunches the _X64
    build and exits, so the process to capture is often not the one started;
    that fallback must never reach an instance the operator already had open.

.PARAMETER Path
    Executable to launch. One of -Path or -WindowTitle is required.

.PARAMETER WorkingDirectory
    Working directory for the launch.

.PARAMETER WindowTitle
    Title, or title fragment, of the window to capture.

.PARAMETER ProcessId
    The process whose main window to capture, for a caller that started it
    and knows exactly which one it means: a title fragment can also match
    the operator's own windows (D00 T02 §10).

.PARAMETER Out
    Destination PNG. The sidecar is written beside it with a .txt extension.

.PARAMETER Describes
    One line saying what this capture is authoritative for.

.PARAMETER WaitSeconds
    How long to let the window settle before capturing. Default 5.

.PARAMETER KeepOpen
    Leave a launched process running after the capture.

.EXAMPLE
    pwsh scripts/capture-window.ps1 -Path .\Bin\Release\Resolute.exe `
        -WindowTitle Resolute -Out docs/captures/runs/launcher.png `
        -Describes 'The launcher main window, running.'
#>

param(
    [string]$Path,
    [string]$WorkingDirectory,
    [string]$WindowTitle,
    [int]$ProcessId = 0,
    [Parameter(Mandatory = $true)][string]$Out,
    [string]$Describes = '',

    # The appearance the captured window shows. An application can override
    # the system setting, so matrix captures state it; without it the
    # sidecar records the system setting, labelled as such (D00 T02 §9).
    [ValidateSet('', 'light', 'dark')]
    [string]$Appearance = '',
    [int]$WaitSeconds = 5,
    [switch]$KeepOpen
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Neither given means "enumerate every window and take the first", which can
# foreground and save an unrelated application. Refused before anything is
# enumerated.
if (-not $Path -and -not $WindowTitle -and -not $ProcessId) {
    Write-Host "capture-window: give -Path, -WindowTitle, -ProcessId, or a combination." -ForegroundColor Red
    Write-Host "  Without a target this would capture whichever window came first." -ForegroundColor Red
    exit 2
}

Add-Type -AssemblyName System.Drawing

if (-not ('Win32Capture' -as [type])) {
    Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Win32Capture {
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr hWnd, int attribute, out RECT value, int size);
    [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern IntPtr MonitorFromWindow(IntPtr hWnd, uint flags);
    [DllImport("shcore.dll")] public static extern int GetDpiForMonitor(IntPtr hMon, int type, out uint x, out uint y);
    [DllImport("user32.dll")] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }
}
'@
}

# Per-monitor DPI aware from here on, before anything is measured. Without it
# this thread reads virtualized coordinates on a scaled monitor: the window's
# rectangle, the screen copy, and the monitor's DPI all come back at 96, so a
# capture on a 150% monitor was saved at two thirds of its size and labelled
# 100% (found by D00 T02 §10's first 150% captures). A DPI-unaware target is
# still reported as bitmap-scaled: its window DPI stays 96 below the monitor's.
[void][Win32Capture]::SetThreadDpiAwarenessContext([IntPtr]::new(-4))   # PER_MONITOR_AWARE_V2

function Get-Matching {
    param([string]$Stem)
    $all = @(Get-Process | Where-Object { $_.MainWindowHandle -ne 0 })
    if ($Stem) { $all = @($all | Where-Object { $_.ProcessName -like "$Stem*" }) }
    if ($WindowTitle) { $all = @($all | Where-Object { $_.MainWindowTitle -like "*$WindowTitle*" }) }
    if ($ProcessId) { $all = @($all | Where-Object { $_.Id -eq $ProcessId }) }
    return $all
}

$ours = $null          # the process THIS invocation started, if any
$target = $null

if ($Path) {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($Path)

    # Snapshot first. Anything already running is the operator's and is never
    # a candidate for the fallback and never stopped.
    $preexisting = @(Get-Matching -Stem $stem | Select-Object -ExpandProperty Id)

    $startArgs = @{ FilePath = $Path; PassThru = $true }
    if ($WorkingDirectory) { $startArgs['WorkingDirectory'] = $WorkingDirectory }
    $launched = Start-Process @startArgs
    Start-Sleep -Seconds $WaitSeconds

    if (-not $launched.HasExited -and $launched.MainWindowHandle -ne 0) {
        $target = $launched
        $ours = $launched
    }
    else {
        # The stub relaunched. Only a process that was NOT running before is
        # eligible, so a pre-existing instance can be neither captured nor
        # killed by mistake.
        $appeared = @(Get-Matching -Stem $stem | Where-Object { $preexisting -notcontains $_.Id })
        $target = $appeared | Select-Object -First 1
        $ours = $target
        if (-not $target) {
            Write-Host "capture-window: nothing new appeared after launching $Path" -ForegroundColor Red
            if (@(Get-Matching -Stem $stem).Count -gt 0) {
                Write-Host "  An instance was already running and is deliberately left alone." -ForegroundColor Yellow
                Write-Host "  Close it, or attach with -WindowTitle and no -Path." -ForegroundColor Yellow
            }
            exit 1
        }
    }
}
else {
    $target = Get-Matching -Stem $null | Select-Object -First 1
}

if (-not $target) {
    Write-Host "capture-window: no window found" -ForegroundColor Red
    if ($WindowTitle) { Write-Host "  title filter: '$WindowTitle'" -ForegroundColor Red }
    exit 1
}

function Stop-Ours {
    if ($ours -and -not $KeepOpen) { $ours | Stop-Process -Force -ErrorAction SilentlyContinue }
}

$hwnd = $target.MainWindowHandle
[void][Win32Capture]::ShowWindow($hwnd, 9)          # SW_RESTORE
Start-Sleep -Milliseconds 900

# Fail closed. SetForegroundWindow is not called: Windows refuses it from a
# background process, and calling it and ignoring the result is what made the
# earlier version unsafe. If the window is not in front, say so and stop.
$foreground = [Win32Capture]::GetForegroundWindow()
if ($foreground -ne $hwnd) {
    Write-Host "capture-window: '$($target.MainWindowTitle)' does not own the foreground." -ForegroundColor Red
    Write-Host "  Capturing now would save whatever is on top of it." -ForegroundColor Red
    Write-Host "  Bring the window to the front and re-run, or use -KeepOpen and attach." -ForegroundColor Yellow
    Stop-Ours
    exit 3
}

$rect = New-Object Win32Capture+RECT
# The frame DWM draws, not the window rectangle: on Windows 10 and 11 the
# rectangle includes invisible resize borders, and copying it saves a strip
# of whatever sits behind the window (the operator's other windows) into a
# committed capture. Found by D00 T02 §10's launcher captures.
$framed = [Win32Capture]::DwmGetWindowAttribute($hwnd, 9, [ref]$rect, [System.Runtime.InteropServices.Marshal]::SizeOf($rect)) -eq 0   # DWMWA_EXTENDED_FRAME_BOUNDS
if (-not $framed -and -not [Win32Capture]::GetWindowRect($hwnd, [ref]$rect)) {
    Write-Host "capture-window: could not read the window rect" -ForegroundColor Red
    Stop-Ours
    exit 1
}
$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top
if ($width -le 0 -or $height -le 0) {
    Write-Host "capture-window: the window has no area ($width x $height)" -ForegroundColor Red
    Stop-Ours
    exit 1
}

$bitmap = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
$graphics.Dispose()

$outDir = Split-Path $Out -Parent
if ($outDir -and -not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
$bitmap.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()

# TWO DPI FIGURES, because for a DPI-unaware window they differ and reporting
# only the first is misleading. GetDpiForWindow returns the window's LOGICAL
# dpi, which is 96 for a DPI-unaware process even on a 150% display, so the
# AutoIt captures this helper supports were labelled "100% scaling" while being
# bitmap-stretched by Windows. The monitor figure is what the image was
# actually rendered at. Found by the independent review of D00 T02 §3.
$windowDpi = [Win32Capture]::GetDpiForWindow($hwnd)
$monitor = [Win32Capture]::MonitorFromWindow($hwnd, 2)   # NEAREST
$monX = 0; $monY = 0
[void][Win32Capture]::GetDpiForMonitor($monitor, 0, [ref]$monX, [ref]$monY)
$dpiAware = ($windowDpi -eq $monX)

$sourcePath = if ($ours) { $target.Path } elseif ($Path) { (Resolve-Path $Path).Path } else { $target.Path }
$sidecar = [System.IO.Path]::ChangeExtension($Out, '.txt')
# The appearance the capture shows (D00 T02 §9: the light-by-dark matrix),
# read from the setting apps follow; unknown when the value is absent.
$appearanceLine = if ($Appearance) {
    "$Appearance  (stated by the caller)"
} else {
    # Strict mode: an absent value or key must not throw before the fallback.
    $personalize = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -ErrorAction SilentlyContinue
    $appsLight = if ($personalize -and $personalize.PSObject.Properties.Name -contains 'AppsUseLightTheme') { $personalize.AppsUseLightTheme } else { $null }
    $system = if ($null -eq $appsLight) { 'unknown' } elseif ($appsLight -eq 0) { 'dark' } else { 'light' }
    "$system  (the system app setting; the application may override it: pass -Appearance)"
}
@(
    "capture       : $(Split-Path $Out -Leaf)"
    "describes     : $Describes"
    "window title  : $($target.MainWindowTitle)"
    "source binary : $sourcePath"
    "file version  : $(if ($sourcePath -and (Test-Path $sourcePath)) { (Get-Item $sourcePath).VersionInfo.FileVersion } else { 'unknown' })"
    "size          : $width x $height px"
    "monitor dpi   : $monX  ($([math]::Round($monX / 96.0 * 100))% scaling) -- what the image was rendered at"
    "window dpi    : $windowDpi  (logical dpi the process sees)"
    "dpi aware     : $dpiAware$(if (-not $dpiAware) { '  -- Windows bitmap-scales this window' })"
    "appearance    : $appearanceLine"
    "windows build : $([System.Environment]::OSVersion.Version.ToString())"
    "captured      : $(Get-Date -Format 'yyyy-MM-dd')"
    ""
    "Reproduce with scripts/capture-window.ps1. Where this capture and"
    "DESIGN.md disagree, the contract wins and this capture is restaked."
) | Set-Content -Path $sidecar -Encoding UTF8

Write-Host ("captured {0}  {1}x{2}  monitor {3} dpi, window {4} dpi, aware={5}" -f `
    (Split-Path $Out -Leaf), $width, $height, $monX, $windowDpi, $dpiAware) -ForegroundColor Green

Stop-Ours
exit 0
