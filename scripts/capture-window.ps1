<#
.SYNOPSIS
    Capture a window to PNG, with the metadata that makes the capture evidence.

.DESCRIPTION
    D00 T02 §3. Every UI section in this plan carries a `Fidelity:` line naming
    an artifact it must match, and a capture nobody can reproduce is a
    screenshot rather than a baseline.

    So this writes two files for every capture: the PNG, and a `.txt` sidecar
    recording what was captured, from which binary, at what DPI, on what
    Windows build, and when. A capture whose provenance is unknown cannot be
    restaked when the contract changes, which DESIGN.md requires it to be.

    DPI IS RECORDED BECAUSE IT IS A DEVIATION, NOT AN ACCIDENT. The AutoIt
    windows are not DPI-aware, so a capture taken at 150 percent shows the
    bitmap stretching Windows applies to them. That is the shipped behaviour
    and is exactly what DESIGN.md says the C++ suite deliberately changes, so
    the capture records the DPI it was taken at rather than pretending there is
    one true rendering.

.PARAMETER Path
    Executable to launch. Omit to attach to an already-running window.

.PARAMETER WorkingDirectory
    Working directory for the launch.

.PARAMETER WindowTitle
    Title, or title fragment, of the window to capture. Required when
    attaching, optional when launching.

.PARAMETER Out
    Destination PNG. The sidecar is written beside it with a .txt extension.

.PARAMETER Describes
    One line saying what this capture is authoritative for. Written into the
    sidecar.

.PARAMETER WaitSeconds
    How long to let the window settle before capturing. Default 5.

.PARAMETER KeepOpen
    Leave the process running after the capture, for capturing a second window
    from the same instance.

.EXAMPLE
    pwsh scripts/capture-window.ps1 -Path .\BiosCodes.exe -WindowTitle 'Beep Codes' `
        -Out docs/captures/house-style/tool-window.png `
        -Describes 'The standard tool window every AutoIt tool draws'
#>

param(
    [string]$Path,
    [string]$WorkingDirectory,
    [string]$WindowTitle,
    [Parameter(Mandatory = $true)][string]$Out,
    [string]$Describes = '',
    [int]$WaitSeconds = 5,
    [switch]$KeepOpen,

    # Keystrokes sent to the window before capturing, for surfaces reached
    # through a menu. The AutoIt windows expose almost nothing to UI
    # Automation, established by the spike in docs/captures/, so a menu is
    # opened the way a user opens it.
    [string]$SendKeys = '',

    # Title of the window to capture AFTER the keystrokes, when they open a
    # dialog. Without this the capture would take the parent window again.
    [string]$ThenCapture = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Drawing

# ForegroundWindow plus a screen copy, rather than PrintWindow. PrintWindow
# misses DWM-composited chrome on some windows and returns a black bitmap on
# others; copying what is actually on screen captures what a user sees, which
# is what a house-style baseline is for.
if (-not ('Win32Capture' -as [type])) {
    Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Win32Capture {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr hWnd);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }
}
'@
}

function Get-TargetProcess {
    if ($Path) {
        $args = @{ FilePath = $Path; PassThru = $true }
        if ($WorkingDirectory) { $args['WorkingDirectory'] = $WorkingDirectory }
        $launched = Start-Process @args
        Start-Sleep -Seconds $WaitSeconds

        # An AutoIt tool launches a 32-bit stub that relaunches the _X64 build
        # and exits, so the process to capture is not always the one started.
        # Found while capturing for D00 T02 §3.
        if ($launched.HasExited) {
            $stem = [System.IO.Path]::GetFileNameWithoutExtension($Path)
            $candidates = @(Get-Process | Where-Object {
                $_.ProcessName -like "$stem*" -and $_.MainWindowHandle -ne 0 })
        }
        else {
            $candidates = @($launched)
        }
    }
    else {
        $candidates = @(Get-Process | Where-Object { $_.MainWindowHandle -ne 0 })
    }

    if ($WindowTitle) {
        $candidates = @($candidates | Where-Object { $_.MainWindowTitle -like "*$WindowTitle*" })
    }
    return ($candidates | Select-Object -First 1)
}

$target = Get-TargetProcess
if (-not $target) {
    Write-Host "capture-window: no window found" -ForegroundColor Red
    if ($WindowTitle) { Write-Host "  title filter: '$WindowTitle'" -ForegroundColor Red }
    if ($Path) { Write-Host "  launched    : $Path" -ForegroundColor Red }
    exit 1
}

$hwnd = $target.MainWindowHandle
[void][Win32Capture]::ShowWindow($hwnd, 9)          # SW_RESTORE
[void][Win32Capture]::SetForegroundWindow($hwnd)
Start-Sleep -Milliseconds 800

if ($SendKeys) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait($SendKeys)
    Start-Sleep -Seconds 2

    if ($ThenCapture) {
        $dialog = Get-Process | Where-Object {
            $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -like "*$ThenCapture*"
        } | Select-Object -First 1
        if (-not $dialog) {
            Write-Host "capture-window: '$ThenCapture' did not appear after the keystrokes" -ForegroundColor Red
            if (-not $KeepOpen -and $Path) { $target | Stop-Process -Force -ErrorAction SilentlyContinue }
            exit 1
        }
        $hwnd = $dialog.MainWindowHandle
        [void][Win32Capture]::SetForegroundWindow($hwnd)
        Start-Sleep -Milliseconds 600
    }
}

$rect = New-Object Win32Capture+RECT
if (-not [Win32Capture]::GetWindowRect($hwnd, [ref]$rect)) {
    Write-Host "capture-window: could not read the window rect" -ForegroundColor Red
    exit 1
}
$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top
if ($width -le 0 -or $height -le 0) {
    Write-Host "capture-window: the window has no area ($width x $height)" -ForegroundColor Red
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

# The sidecar. A capture without provenance cannot be restaked.
$dpi = [Win32Capture]::GetDpiForWindow($hwnd)
$sourcePath = if ($Path) { (Resolve-Path $Path).Path } else { $target.Path }
$sidecar = [System.IO.Path]::ChangeExtension($Out, '.txt')
@(
    "capture      : $(Split-Path $Out -Leaf)"
    "describes    : $Describes"
    "window title : $($target.MainWindowTitle)"
    "source binary: $sourcePath"
    "file version : $(if ($sourcePath -and (Test-Path $sourcePath)) { (Get-Item $sourcePath).VersionInfo.FileVersion } else { 'unknown' })"
    "size         : $width x $height px"
    "window dpi   : $dpi  ($([math]::Round($dpi / 96.0 * 100))% scaling)"
    "windows build: $([System.Environment]::OSVersion.Version.ToString())"
    "captured     : $(Get-Date -Format 'yyyy-MM-dd')"
    ""
    "Reproduce with scripts/capture-window.ps1. Where this capture and"
    "DESIGN.md disagree, the contract wins and this capture is restaked."
) | Set-Content -Path $sidecar -Encoding UTF8

Write-Host ("captured {0}  {1}x{2} @ {3} dpi" -f (Split-Path $Out -Leaf), $width, $height, $dpi) -ForegroundColor Green

if (-not $KeepOpen -and $Path) {
    $target | Stop-Process -Force -ErrorAction SilentlyContinue
}
exit 0
