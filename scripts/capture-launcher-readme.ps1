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

    The operator comes first (docs/testing.md, the fence). The driver
    watches every mouse and keyboard event through low-level hooks, which
    see whether Windows injected an event and the mark its sender gave it.
    It takes the desktop only after the operator has been idle for
    -IdleSeconds, counting from before that check, and before it launches
    anything. Its own events carry its mark: a one-pixel move and back
    before each shot, because Windows lets a background process bring a
    window to the front only after it sent the last input event, and which
    also proves the watch still sees input. Any other event from then on,
    or a watch that cannot be read, stands the whole run down: every
    process the driver started is ended with its children, nothing is
    published, and no later shot is attempted.

    Shots are written into a staging folder of this run's own inside
    -OutDir and published, all four together, only when every shot
    succeeded. A run that stands down removes its staging folder and
    leaves -OutDir as it found it.

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
    A drill: inject one unmarked input event at this stage of the first
    shot (positioning, theme, view, settling or capture), as an operator's
    touch would, so the stand-down can be proven.

.PARAMETER DrillFailQuery
    A drill: make the input watch unreadable from the first check after
    launch.
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

Add-Type @'
using System;
using System.Threading;
using System.Runtime.InteropServices;
public class Shot {
    [DllImport("user32.dll")] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr ctx);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
    [DllImport("user32.dll")] public static extern IntPtr SendMessageW(IntPtr h, uint msg, IntPtr w, IntPtr l);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
}
public class Idle {
    [StructLayout(LayoutKind.Sequential)] public struct LASTINPUTINFO { public uint cbSize; public uint dwTime; }
    [DllImport("user32.dll")] public static extern bool GetLastInputInfo(ref LASTINPUTINFO info);
    [DllImport("kernel32.dll")] public static extern uint GetTickCount();
}
// Every mouse and keyboard event, seen by low-level hooks on a thread of
// their own. An event is the operator's unless Windows marks it injected
// and it carries this driver's mark; the drill's touch is injected without
// the mark, so it counts as the operator's, as a real touch would.
public class Watch {
    public const long Mark = 0x52534C54;
    delegate IntPtr HookProc(int code, IntPtr w, IntPtr l);
    [StructLayout(LayoutKind.Sequential)] struct MSLL { public int x; public int y; public uint data; public uint flags; public uint time; public UIntPtr extra; }
    [StructLayout(LayoutKind.Sequential)] struct KBDLL { public uint vk; public uint scan; public uint flags; public uint time; public UIntPtr extra; }
    [StructLayout(LayoutKind.Sequential)] struct MSG { public IntPtr h; public uint m; public IntPtr w; public IntPtr l; public uint t; public int x; public int y; }
    [DllImport("user32.dll", SetLastError = true)] static extern IntPtr SetWindowsHookExW(int id, HookProc fn, IntPtr mod, uint tid);
    [DllImport("user32.dll")] static extern bool UnhookWindowsHookEx(IntPtr h);
    [DllImport("user32.dll")] static extern IntPtr CallNextHookEx(IntPtr h, int c, IntPtr w, IntPtr l);
    [DllImport("user32.dll")] static extern int GetMessageW(out MSG m, IntPtr h, uint a, uint b);
    [DllImport("user32.dll")] static extern bool PostThreadMessageW(uint tid, uint m, IntPtr w, IntPtr l);
    [DllImport("kernel32.dll")] static extern IntPtr GetModuleHandleW(string n);
    [DllImport("kernel32.dll")] static extern uint GetCurrentThreadId();
    static HookProc mouseProc, keyProc;
    static uint thread;
    static int operatorEvents, ownEvents;
    public static bool IsOperator(bool injected, ulong extra) { return !(injected && extra == (ulong)Mark); }
    static void Count(bool injected, ulong extra) {
        if (IsOperator(injected, extra)) Interlocked.Increment(ref operatorEvents); else Interlocked.Increment(ref ownEvents);
    }
    static IntPtr OnMouse(int c, IntPtr w, IntPtr l) {
        if (c >= 0) { var s = (MSLL)Marshal.PtrToStructure(l, typeof(MSLL)); Count((s.flags & 0x1) != 0, (ulong)s.extra); }
        return CallNextHookEx(IntPtr.Zero, c, w, l);
    }
    static IntPtr OnKey(int c, IntPtr w, IntPtr l) {
        if (c >= 0) { var s = (KBDLL)Marshal.PtrToStructure(l, typeof(KBDLL)); Count((s.flags & 0x10) != 0, (ulong)s.extra); }
        return CallNextHookEx(IntPtr.Zero, c, w, l);
    }
    public static bool Start() {
        var ready = new ManualResetEvent(false);
        bool ok = false;
        var t = new Thread(() => {
            thread = GetCurrentThreadId();
            mouseProc = OnMouse; keyProc = OnKey;
            IntPtr mod = GetModuleHandleW(null);
            IntPtr m = SetWindowsHookExW(14, mouseProc, mod, 0), k = SetWindowsHookExW(13, keyProc, mod, 0);
            ok = m != IntPtr.Zero && k != IntPtr.Zero;
            ready.Set();
            if (ok) { MSG msg; while (GetMessageW(out msg, IntPtr.Zero, 0, 0) > 0) { } }
            if (m != IntPtr.Zero) UnhookWindowsHookEx(m);
            if (k != IntPtr.Zero) UnhookWindowsHookEx(k);
        });
        t.IsBackground = true;
        t.Start();
        return ready.WaitOne(5000) && ok;
    }
    public static void Stop() { if (thread != 0) PostThreadMessageW(thread, 0x0012, IntPtr.Zero, IntPtr.Zero); }
    public static void ResetOperator() { Interlocked.Exchange(ref operatorEvents, 0); }
    public static int Operator { get { return Volatile.Read(ref operatorEvents); } }
    public static int Own { get { return Volatile.Read(ref ownEvents); } }
}
public class Touch {
    [StructLayout(LayoutKind.Sequential)] public struct MOUSEINPUT { public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr extra; }
    // type, then the union, whose widest member is MOUSEINPUT: 40 bytes on x64, the size SendInput checks.
    [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public MOUSEINPUT mi; }
    [DllImport("user32.dll", SetLastError = true)] public static extern uint SendInput(uint n, INPUT[] inputs, int size);
    // One-pixel move and back: the cursor ends where it was. Marked, it is
    // the driver's own; unmarked, it is the drill's stand-in for a touch.
    public static uint Nudge(bool marked) {
        IntPtr extra = marked ? (IntPtr)Watch.Mark : IntPtr.Zero;
        var a = new INPUT { type = 0, mi = new MOUSEINPUT { dx = 1, dy = 0, dwFlags = 0x0001, extra = extra } };
        var b = new INPUT { type = 0, mi = new MOUSEINPUT { dx = -1, dy = 0, dwFlags = 0x0001, extra = extra } };
        return SendInput(2, new INPUT[] { a, b }, Marshal.SizeOf(typeof(INPUT)));
    }
}
'@

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
    # True when the operator's event count moved after the baseline. A
    # watch that answered nothing is not "no input": the run cannot see the
    # operator, so it stands down.
    if ($null -eq $Baseline -or $null -eq $Now) { throw 'the input query failed, so the operator cannot be seen' }
    return ([int]$Now -ne [int]$Baseline)
}

function Invoke-SelfTest {
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
    Check 'an unchanged count is not a resumption' (-not (Test-InputResumed 0 0))
    Check 'a count that moved is a resumption' (Test-InputResumed 0 1)
    $threw = $false
    try { $null = Test-InputResumed 0 $null } catch { $threw = $true }
    Check 'a failed input query is a stand-down, not "no input"' $threw
    $threw = $false
    try { $null = Test-InputResumed $null 0 } catch { $threw = $true }
    Check 'a missing baseline is a stand-down' $threw
    Check "the driver's own marked injected event is not the operator's" (-not [Watch]::IsOperator($true, [Watch]::Mark))
    Check 'an event Windows did not inject is the operator''s, whatever its mark' ([Watch]::IsOperator($false, [Watch]::Mark))
    Check 'an injected event without the mark (the drill, or other software) is the operator''s' ([Watch]::IsOperator($true, 0))
    if ($script:selfFailures.Count) { Write-Host ("self-test: FAIL " + ($script:selfFailures -join ', ')); return 1 }
    Write-Host 'self-test: all pass'
    return 0
}

if ($SelfTest) { exit (Invoke-SelfTest) }

# ---- the desktop -------------------------------------------------------------

[Shot]::SetThreadDpiAwarenessContext([IntPtr](-4)) | Out-Null

if (-not $Visible) {
    Write-Host 'capture-launcher-readme: refusing to run without -Visible.' -ForegroundColor Red
    Write-Host '  This driver takes the foreground to capture; run it visibly, when the desktop is free.' -ForegroundColor DarkGray
    exit 2
}

function Get-IdleSeconds {
    $info = New-Object Idle+LASTINPUTINFO
    $info.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($info)
    if (-not [Idle]::GetLastInputInfo([ref]$info)) { return -1 }
    return ([Idle]::GetTickCount() - $info.dwTime) / 1000.0
}

$script:QueryFails = $false
function Get-OperatorEvents {
    # The operator's events since admission, or $null when the watch cannot be read.
    if ($script:QueryFails) { return $null }
    return [Watch]::Operator
}

function Assert-NoInput([string]$What) {
    # Any operator event since admission, or no way to tell, stands the run down.
    try {
        $resumed = Test-InputResumed 0 (Get-OperatorEvents)
    } catch {
        throw "stood down during ${What}: $($_.Exception.Message) (docs/testing.md stand-down rule)"
    }
    if ($resumed) { throw "stood down during ${What}: operator input resumed (docs/testing.md stand-down rule)" }
}

function Wait-Checked([int]$Milliseconds, [string]$What) {
    # Checked before the wait and after every step of it, so the caller's
    # next desktop action never follows an unchecked interval.
    Assert-NoInput $What
    $steps = [Math]::Max(1, [int]($Milliseconds / 200))
    foreach ($i in 1..$steps) {
        Start-Sleep -Milliseconds 200
        Assert-NoInput $What
    }
}

function Send-OwnInput([string]$What) {
    # The driver's marked move and back. It must be seen by the watch,
    # which proves the hooks are still alive; it leaves the driver as the
    # sender of the last input event, which Windows asks of a process
    # bringing a window forward.
    $seen = [Watch]::Own
    if ([Touch]::Nudge($true) -ne 2) { throw "stood down during ${What}: the driver's own input event could not be sent" }
    $deadline = [DateTime]::UtcNow.AddSeconds(2)
    while ([Watch]::Own -lt $seen + 2) {
        if ([DateTime]::UtcNow -gt $deadline) { throw "stood down during ${What}: the input watch did not see the driver's own event, so it cannot see the operator" }
        Start-Sleep -Milliseconds 20
    }
    Assert-NoInput $What
}

$script:Drilled = $false
function Invoke-Drill([string]$Stage) {
    # The drill's one touch, once, at the stage it names: injected without the mark.
    if ($script:Drilled) { return }
    if ($DrillInterruptAt -eq $Stage) {
        $script:Drilled = $true
        if ([Touch]::Nudge($false) -ne 2) { throw "the drill could not inject its input at $Stage" }
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
# This run's own staging folder, on the same volume as -OutDir so
# publishing is a rename; nothing outside it is written until every shot
# succeeded.
$Staging = Join-Path $OutDir (".capture-staging-$PID-" + [Guid]::NewGuid().ToString('N').Substring(0, 8))
$script:Shots = @()

function Take-Shot([string]$State, [string]$Mode, [int]$Presses, [int]$ViewCmd) {
    $name = "$Date-D00-T05-s1-launcher-$State-$Mode"
    $out = Join-Path $Staging "$name.png"
    $proc = $null
    $cap = $null
    try {
        Assert-NoInput "the launch of $name"
        $proc = Start-Process -FilePath $Exe -WorkingDirectory $WorkingDir -PassThru
        if ($DrillFailQuery) { $script:QueryFails = $true }
        $hwnd = [IntPtr]::Zero
        foreach ($i in 1..50) {
            Wait-Checked 200 'the launch'
            $proc.Refresh()
            if ($proc.MainWindowHandle -ne [IntPtr]::Zero) { $hwnd = $proc.MainWindowHandle; break }
        }
        if ($hwnd -eq [IntPtr]::Zero) { throw "no main window for $name" }
        Assert-NoInput 'positioning'
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
        Send-OwnInput 'foreground settling'
        [Shot]::SetForegroundWindow($hwnd) | Out-Null
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
        Assert-NoInput "the capture of $name"
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
        $script:Shots += $name
        Write-Output "SHOT $name ok"
    } finally {
        # Everything this shot started ends before anything else happens, so
        # nothing it started can write after the run cleans up.
        Stop-Tree $cap
        Stop-Tree $proc
    }
}

function Publish-Shots {
    # Every shot succeeded: move the set out of staging, replacing earlier files of the same names.
    foreach ($name in $script:Shots) {
        foreach ($ext in '.png', '.txt') {
            [System.IO.File]::Move((Join-Path $Staging "$name$ext"), (Join-Path $OutDir "$name$ext"), $true)
        }
    }
}

if (-not [Watch]::Start()) {
    Write-Host 'stood down before launching anything: the input watch could not be installed, so the operator cannot be seen' -ForegroundColor Yellow
    exit 3
}
$code = 0
try {
    # Admission: the operator's count is cleared, then the idle time is
    # read. An event after the clearing either shows in the idle time (and
    # admission waits on) or is counted, so no event falls between the two.
    $admitted = $false
    foreach ($i in 1..([Math]::Max(1, $IdleWaitSeconds * 2))) {
        [Watch]::ResetOperator()
        if ((Get-IdleSeconds) -ge $IdleSeconds) { $admitted = $true; break }
        Start-Sleep -Milliseconds 500
    }
    if (-not $admitted) {
        Write-Host "stood down before launching anything: the operator was not idle for ${IdleSeconds}s within ${IdleWaitSeconds}s (docs/testing.md stand-down rule)" -ForegroundColor Yellow
        exit 3
    }
    New-Item -ItemType Directory -Path $Staging | Out-Null
    try {
        Send-OwnInput 'admission'
        # IDC_TB_VIEW_DETAILS = 1004, IDC_TB_VIEW_LARGE = 1001 (toolbar.h).
        Take-Shot 'details' 'dark' 1 1004
        Take-Shot 'details' 'light' 2 1004
        Take-Shot 'large-icons' 'dark' 1 1001
        Take-Shot 'large-icons' 'light' 2 1001
        Publish-Shots
        Write-Output "published $($script:Shots.Count) shots to $OutDir"
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host "no further shot was attempted, nothing was published, and every process the driver started was ended" -ForegroundColor Yellow
        $code = 3
    } finally {
        Remove-Item -LiteralPath $Staging -Recurse -Force
    }
} finally {
    [Watch]::Stop()
}
exit $code
