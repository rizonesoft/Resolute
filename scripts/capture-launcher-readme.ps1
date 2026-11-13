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
      pwsh scripts/capture-launcher-readme.ps1 -Visible

    Each sidecar records the exact command that produced it, runnable as
    written.

    The operator comes first (docs/testing.md, the fence). The driver takes
    the desktop only after the operator has been idle for -IdleSeconds, and
    before it launches anything. It then sends one input event of its own
    (a one-pixel move and back), because Windows lets a background process
    bring a window to the front only after it sent the last input event; from then on any input, or an input query
    that fails, stands the whole run down: every process the driver started
    is ended with its children, the interrupted shot's files are removed,
    and no later shot is attempted.

    The driver ends only the processes it started.

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

.PARAMETER SelfTest
    Check the driver's own rules (the recorded command, the input rule)
    without touching the desktop.

.PARAMETER DrillInterruptAt
    A drill: inject one input event at this stage of the first shot
    (positioning, theme, view, settling or capture), as an operator's touch
    would, so the stand-down can be proven.

.PARAMETER DrillFailQuery
    A drill: make the input query fail from the first check after launch.
#>
param(
    [string]$Exe = (Join-Path $PSScriptRoot '..\Bin\Release\Resolute.exe'),
    [string]$CaptureScript = (Join-Path $PSScriptRoot 'capture-window.ps1'),
    [string]$OutDir = (Join-Path $PSScriptRoot '..\docs\captures'),
    [string]$Date = (Get-Date -Format 'yyyy-MM-dd'),
    # Desktop interaction is explicit: without -Visible the driver
    # refuses, and even with it, it stands down while the operator is
    # active (docs/testing.md's stand-down rule).
    [switch]$Visible,
    # The established collection threshold (docs/testing.md): the
    # operator must be idle this long before the driver takes the
    # desktop, and input resuming at any point stands the run down.
    [int]$IdleSeconds = 120,
    [int]$IdleWaitSeconds = 600,
    [int]$CaptureTimeoutSeconds = 120,
    [switch]$SelfTest,
    [ValidateSet('', 'positioning', 'theme', 'view', 'settling', 'capture')][string]$DrillInterruptAt = '',
    [switch]$DrillFailQuery
)

$ErrorActionPreference = 'Stop'

# ---- the rules, testable without a desktop ---------------------------------

function ConvertTo-Quoted([string]$Text) {
    # One argument in single quotes, an apostrophe doubled.
    return "'" + $Text.Replace("'", "''") + "'"
}

function Get-ReproductionCommand([string]$Driver, [string]$Exe, [string]$CaptureScript, [string]$OutDir, [string]$Date) {
    # The line a sidecar records: runnable as written, from any directory,
    # with every path one quoted argument and the date that names the files.
    return "pwsh -NoProfile -File $(ConvertTo-Quoted $Driver) -Visible -Exe $(ConvertTo-Quoted $Exe) -CaptureScript $(ConvertTo-Quoted $CaptureScript) -OutDir $(ConvertTo-Quoted $OutDir) -Date $Date"
}

function Test-InputResumed($Baseline, $Now) {
    # True when the operator's last-input tick moved after the baseline. A
    # query that answered nothing is not "no input": the run cannot see the
    # operator, so it stands down.
    if ($null -eq $Baseline -or $null -eq $Now) { throw 'the input query failed, so the operator cannot be seen' }
    return ([uint32]$Now -ne [uint32]$Baseline)
}

function Invoke-SelfTest {
    $failures = @()
    function Check([string]$Name, [bool]$Ok) {
        if ($Ok) { Write-Host "PASS $Name" } else { Write-Host "FAIL $Name"; $script:selfFailures += $Name }
    }
    $script:selfFailures = @()
    $odd = "R:\a folder\it's here\Resolute.exe"
    $line = Get-ReproductionCommand 'D:\x y\capture-launcher-readme.ps1' $odd 'D:\x y\capture-window.ps1' 'R:\out dir' '2026-11-13'
    $tokens = $null; $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($line, [ref]$tokens, [ref]$errors)
    $command = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true)
    $elements = @($command.CommandElements)
    $exeAt = [array]::IndexOf(@($elements | ForEach-Object { "$_" }), '-Exe')
    $exeValue = if ($exeAt -ge 0 -and $exeAt + 1 -lt $elements.Count) { $elements[$exeAt + 1].SafeGetValue() } else { $null }
    Check 'the recorded command parses as one command' ($errors.Count -eq 0 -and $null -ne $command)
    Check 'the recorded command carries -Visible and -Date' ((@($elements | ForEach-Object { "$_" }) -contains '-Visible') -and (@($elements | ForEach-Object { "$_" }) -contains '-Date'))
    Check 'a path with a space and an apostrophe stays one argument, unchanged' ($exeValue -eq $odd)
    Check 'an unchanged tick is not a resumption' (-not (Test-InputResumed 100 100))
    Check 'a tick that moved is a resumption' (Test-InputResumed 100 101)
    $threw = $false
    try { $null = Test-InputResumed 100 $null } catch { $threw = $true }
    Check 'a failed input query is a stand-down, not "no input"' $threw
    $threw = $false
    try { $null = Test-InputResumed $null 100 } catch { $threw = $true }
    Check 'a missing baseline is a stand-down' $threw
    if ($script:selfFailures.Count) { Write-Host ("self-test: FAIL " + ($script:selfFailures -join ', ')); return 1 }
    Write-Host 'self-test: all pass'
    return 0
}

if ($SelfTest) { exit (Invoke-SelfTest) }

# ---- the desktop -------------------------------------------------------------

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
public class Idle {
    [StructLayout(LayoutKind.Sequential)] public struct LASTINPUTINFO { public uint cbSize; public uint dwTime; }
    [DllImport("user32.dll")] public static extern bool GetLastInputInfo(ref LASTINPUTINFO info);
    [DllImport("kernel32.dll")] public static extern uint GetTickCount();
}
public class Touch {
    [StructLayout(LayoutKind.Sequential)] public struct MOUSEINPUT { public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr extra; }
    // type, then the union, whose widest member is MOUSEINPUT: 40 bytes on x64, the size SendInput checks.
    [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public MOUSEINPUT mi; }
    [DllImport("user32.dll", SetLastError = true)] public static extern uint SendInput(uint n, INPUT[] inputs, int size);
    // One-pixel move and back: the cursor ends where it was, and the
    // last-input tick moves exactly as an operator's touch moves it.
    public static uint Nudge() {
        var a = new INPUT { type = 0, mi = new MOUSEINPUT { dx = 1, dy = 0, dwFlags = 0x0001 } };
        var b = new INPUT { type = 0, mi = new MOUSEINPUT { dx = -1, dy = 0, dwFlags = 0x0001 } };
        return SendInput(2, new INPUT[] { a, b }, Marshal.SizeOf(typeof(INPUT)));
    }
}
'@
[Shot]::SetThreadDpiAwarenessContext([IntPtr](-4)) | Out-Null

if (-not $Visible) {
    Write-Host 'capture-launcher-readme: refusing to run without -Visible.' -ForegroundColor Red
    Write-Host '  This driver takes the foreground to capture; run it visibly, when the desktop is free.' -ForegroundColor DarkGray
    exit 2
}

$script:QueryFails = $false
function Get-InputTick {
    # The operator's last-input tick, or $null when it cannot be read.
    if ($script:QueryFails) { return $null }
    $info = New-Object Idle+LASTINPUTINFO
    $info.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($info)
    if (-not [Idle]::GetLastInputInfo([ref]$info)) { return $null }
    return $info.dwTime
}

function Get-IdleSeconds {
    $tick = Get-InputTick
    if ($null -eq $tick) { return -1 }
    return ([Idle]::GetTickCount() - $tick) / 1000.0
}

$script:Baseline = $null
function Assert-NoInput([string]$What) {
    # Any input since the baseline, or no way to tell, stands the run down.
    try {
        $resumed = Test-InputResumed $script:Baseline (Get-InputTick)
    } catch {
        throw "stood down during ${What}: $($_.Exception.Message) (docs/testing.md stand-down rule)"
    }
    if ($resumed) { throw "stood down during ${What}: operator input resumed (docs/testing.md stand-down rule)" }
}

function Wait-Checked([int]$Milliseconds, [string]$What) {
    $steps = [Math]::Max(1, [int]($Milliseconds / 200))
    foreach ($i in 1..$steps) {
        Assert-NoInput $What
        Start-Sleep -Milliseconds 200
    }
}

$script:Drilled = $false
function Invoke-Drill([string]$Stage) {
    # The drill's one touch, once, at the stage it names.
    if ($script:Drilled) { return }
    if ($DrillInterruptAt -eq $Stage) {
        $script:Drilled = $true
        if ([Touch]::Nudge() -ne 2) { throw "the drill could not inject its input at $Stage" }
        Write-Host "drill: one input event injected at $Stage"
    }
}

function Stop-Tree([System.Diagnostics.Process]$Process) {
    # The process and every child it started; then wait until it is gone,
    # so nothing it started can write after the caller cleans up.
    if ($null -eq $Process) { return }
    try { if ($Process.HasExited) { return } } catch { return }
    & taskkill.exe /T /F /PID $Process.Id 2>&1 | Out-Null
    $null = $Process.WaitForExit(10000)
}

$Exe = (Resolve-Path $Exe).Path
$CaptureScript = (Resolve-Path $CaptureScript).Path
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$OutDir = (Resolve-Path $OutDir).Path
$WorkingDir = Split-Path (Split-Path $Exe -Parent) -Parent
$HostName = $env:COMPUTERNAME
$DriverPath = $PSCommandPath

function Take-Shot([string]$State, [string]$Mode, [int]$Presses, [int]$ViewCmd) {
    $name = "$Date-D00-T05-s1-launcher-$State-$Mode"
    $out = Join-Path $OutDir "$name.png"
    $sidecar = [System.IO.Path]::ChangeExtension($out, '.txt')
    $proc = $null
    $cap = $null
    try {
        $proc = Start-Process -FilePath $Exe -WorkingDirectory $WorkingDir -PassThru
        if ($DrillFailQuery) { $script:QueryFails = $true }
        $hwnd = [IntPtr]::Zero
        foreach ($i in 1..50) {
            Wait-Checked 200 'the launch'
            $proc.Refresh()
            if ($proc.MainWindowHandle -ne [IntPtr]::Zero) { $hwnd = $proc.MainWindowHandle; break }
        }
        if ($hwnd -eq [IntPtr]::Zero) { throw "no main window for $name" }
        [Shot]::SetWindowPos($hwnd, [IntPtr]::Zero, 40, 40, 1600, 1000, 0x0040) | Out-Null
        Invoke-Drill 'positioning'
        Wait-Checked 500 'positioning'
        # The launcher starts in System appearance; its theme command
        # cycles System, Dark, Light, so one press is dark, two light.
        foreach ($i in 1..$Presses) {
            [Shot]::SendMessageW($hwnd, 0x0111, [IntPtr]1030, [IntPtr]::Zero) | Out-Null
            Invoke-Drill 'theme'
            Wait-Checked 900 'the theme change'
        }
        [Shot]::SendMessageW($hwnd, 0x0111, [IntPtr]$ViewCmd, [IntPtr]::Zero) | Out-Null
        Invoke-Drill 'view'
        Wait-Checked 700 'the view change'
        $fg = [Shot]::GetForegroundWindow()
        $pidOut = 0
        $theirs = [Shot]::GetWindowThreadProcessId($fg, [ref]$pidOut)
        $mine = [Shot]::GetCurrentThreadId()
        $attach = $false
        if ($theirs -ne 0 -and $theirs -ne $mine) { $attach = [Shot]::AttachThreadInput($mine, $theirs, $true) }
        [Shot]::SetForegroundWindow($hwnd) | Out-Null
        if ($attach) { [Shot]::AttachThreadInput($mine, $theirs, $false) | Out-Null }
        Invoke-Drill 'settling'
        Wait-Checked 600 'foreground settling'
        $describes = "the launcher $State view, $Mode, at 1600 px wide: visual proof for the README (D00 T05 section 1)"
        $fixture = "launcher built from a clean checkout (Bin/Release/Resolute.exe); host $HostName; appearance $Mode set by $Presses theme-command press(es) from System; view set by WM_COMMAND $ViewCmd"
        $context = Get-ReproductionCommand $DriverPath $Exe $CaptureScript $OutDir $Date
        # Each argument handed over as one argument, whatever spaces it holds:
        # Start-Process joins an argument list with spaces and splits a path
        # like "replay dir with spaces" into words.
        $info = [System.Diagnostics.ProcessStartInfo]::new((Get-Process -Id $PID).Path)
        foreach ($a in @('-NoProfile', '-File', $CaptureScript, '-ProcessId', "$($proc.Id)", '-Appearance', $Mode, '-Out', $out, '-Describes', $describes, '-Fixture', $fixture, '-LaunchContext', $context, '-FixtureFiles', 'none beside Bin/Release (launcher only build)')) { $info.ArgumentList.Add($a) }
        $info.UseShellExecute = $false
        $cap = [System.Diagnostics.Process]::Start($info)
        Invoke-Drill 'capture'
        $deadline = [DateTime]::UtcNow.AddSeconds($CaptureTimeoutSeconds)
        while (-not $cap.WaitForExit(200)) {
            Assert-NoInput "the capture of $name"
            if ([DateTime]::UtcNow -gt $deadline) { throw "the capture of $name did not finish within ${CaptureTimeoutSeconds}s" }
        }
        # Input that arrived as the capture finished counts too.
        Assert-NoInput "the capture of $name"
        if ($cap.ExitCode -ne 0) { throw "capture-window failed for $name with $($cap.ExitCode)" }
        Write-Output "SHOT $name ok"
    } catch {
        # Everything this shot started ends first, then its files go, so
        # nothing can write them back; the error ends the run.
        Stop-Tree $cap
        Stop-Tree $proc
        foreach ($f in $out, $sidecar) { if (Test-Path -LiteralPath $f) { Remove-Item -LiteralPath $f -Force } }
        throw
    } finally {
        Stop-Tree $cap
        Stop-Tree $proc
    }
}

# Admission: idle past the threshold, and a baseline, before anything is
# launched. The baseline is never taken again: input at any later point is
# the operator, and ends the run.
$admitted = $false
foreach ($i in 1..([Math]::Max(1, $IdleWaitSeconds * 2))) {
    if ((Get-IdleSeconds) -ge $IdleSeconds) { $admitted = $true; break }
    Start-Sleep -Milliseconds 500
}
if (-not $admitted) {
    Write-Host "stood down before launching anything: the operator was not idle for ${IdleSeconds}s within ${IdleWaitSeconds}s (docs/testing.md stand-down rule)" -ForegroundColor Yellow
    exit 3
}
# Windows lets a background process bring a window to the front only when it
# sent the last input event (measured 2026-11-13: SetForegroundWindow from
# this driver returned false until it had sent one). So the driver sends one
# event of its own, a one-pixel move and back that leaves the cursor where it
# was, after admission and before the baseline: the baseline is that event,
# the operator has been idle past the threshold, and any input after it is
# the operator's and stands the run down as before.
if ([Touch]::Nudge() -ne 2) {
    Write-Host 'stood down before launching anything: the input event that lets the driver take the foreground could not be sent' -ForegroundColor Yellow
    exit 3
}
Start-Sleep -Milliseconds 100
$script:Baseline = Get-InputTick
if ($null -eq $script:Baseline) {
    Write-Host 'stood down before launching anything: the input query failed, so the operator cannot be seen' -ForegroundColor Yellow
    exit 3
}

try {
    # IDC_TB_VIEW_DETAILS = 1004, IDC_TB_VIEW_LARGE = 1001 (toolbar.h).
    Take-Shot 'details' 'dark' 1 1004
    Take-Shot 'details' 'light' 2 1004
    Take-Shot 'large-icons' 'dark' 1 1001
    Take-Shot 'large-icons' 'light' 2 1001
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host 'no further shot was attempted; every process the driver started was ended' -ForegroundColor Yellow
    exit 3
}
