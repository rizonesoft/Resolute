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
    succeeded, and all or nothing: a publication that fails puts back
    every earlier file it moved aside. A run that stands down removes its
    staging folder and leaves -OutDir as it found it.

    Every command sent to the launcher has a deadline, so a launcher that
    stops answering stands the run down. The driver puts itself in a job
    that ends every process it started when the driver ends, however it
    ends; processes that were running before it are never touched.

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
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll", SetLastError = true)] public static extern IntPtr SendMessageTimeoutW(IntPtr h, uint msg, IntPtr w, IntPtr l, uint flags, uint timeoutMs, out UIntPtr result);
}
// A window whose thread never answers: the self-test's stand-in for a launcher that stopped responding.
public class Hung {
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr CreateWindowExW(uint ex, string cls, string name, uint style, int x, int y, int w, int h, IntPtr parent, IntPtr menu, IntPtr inst, IntPtr param);
    [DllImport("user32.dll")] static extern bool DestroyWindow(IntPtr h);
    public static IntPtr Start(int blockMs) {
        IntPtr made = IntPtr.Zero;
        var ready = new ManualResetEvent(false);
        var t = new Thread(() => {
            made = CreateWindowExW(0, "STATIC", "hung", 0, 0, 0, 10, 10, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero);
            ready.Set();
            Thread.Sleep(blockMs);   // no message pump: every message sent to it waits
            DestroyWindow(made);
        });
        t.IsBackground = true;
        t.Start();
        ready.WaitOne(5000);
        return made;
    }
}
// The driver's lifetime: a job the driver puts itself in before it starts
// anything, which ends every process in it when its last handle closes, that
// is, when the driver ends, however it ends. Processes started before the
// driver are never in it.
public class Lifetime {
    [StructLayout(LayoutKind.Sequential)] struct BASIC { public long a, b; public uint flags; public UIntPtr min, max; public uint active; public UIntPtr affinity; public uint priority, sched; }
    [StructLayout(LayoutKind.Sequential)] struct IO { public ulong a, b, c, d, e, f; }
    [StructLayout(LayoutKind.Sequential)] struct EXTENDED { public BASIC basic; public IO io; public UIntPtr procMem, jobMem, peakProc, peakJob; }
    [DllImport("kernel32.dll", SetLastError = true)] static extern IntPtr CreateJobObjectW(IntPtr attrs, string name);
    [DllImport("kernel32.dll", SetLastError = true)] static extern bool SetInformationJobObject(IntPtr job, int cls, ref EXTENDED info, int size);
    [DllImport("kernel32.dll", SetLastError = true)] static extern bool AssignProcessToJobObject(IntPtr job, IntPtr process);
    [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
    static IntPtr job;   // held for the driver's whole life, never closed by it
    public static string Bind() {
        job = CreateJobObjectW(IntPtr.Zero, null);
        if (job == IntPtr.Zero) return "CreateJobObject failed with " + Marshal.GetLastWin32Error();
        var info = new EXTENDED();
        info.basic.flags = 0x2000;   // JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
        if (!SetInformationJobObject(job, 9, ref info, Marshal.SizeOf(typeof(EXTENDED)))) return "SetInformationJobObject failed with " + Marshal.GetLastWin32Error();
        if (!AssignProcessToJobObject(job, GetCurrentProcess())) return "AssignProcessToJobObject failed with " + Marshal.GetLastWin32Error();
        return null;
    }
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

function Send-Command([IntPtr]$Hwnd, [int]$Command, [string]$What, [int]$TimeoutMs = 5000) {
    # WM_COMMAND, bounded: a launcher that stopped answering stands the run
    # down instead of holding the driver where no input check or deadline can act.
    $result = [UIntPtr]::Zero
    $answered = [Shot]::SendMessageTimeoutW($Hwnd, 0x0111, [IntPtr]$Command, [IntPtr]::Zero, 0x0002, [uint32]$TimeoutMs, [ref]$result)   # SMTO_ABORTIFHUNG
    if ($answered -eq [IntPtr]::Zero) { throw "stood down during ${What}: the launcher did not answer command $Command within $($TimeoutMs / 1000) s" }
}

$script:PublishHook = $null   # the self-test's seam: called after each new file is moved in

function Write-Journal([string]$Staging, [object[]]$Entries, [bool]$Complete) {
    $journal = Join-Path $Staging 'publish.json'
    @{ files = $Entries; complete = $Complete } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$journal.tmp" -Encoding utf8
    [System.IO.File]::Move("$journal.tmp", $journal, $true)
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

function Set-Position([IntPtr]$Hwnd, [int]$X, [int]$Y, [int]$Width, [int]$Height, [string]$What, [int]$TimeoutMs = 5000) {
    # Asked, not waited on: SWP_ASYNCWINDOWPOS posts the request to the
    # launcher's thread instead of blocking on it. The driver then waits, as
    # every wait does, checking operator input, until the window reports the
    # size it was asked for, and stands the run down when it has not by the deadline.
    [void][Shot]::SetWindowPos($Hwnd, [IntPtr]::Zero, $X, $Y, $Width, $Height, 0x4040)   # SWP_ASYNCWINDOWPOS | SWP_SHOWWINDOW
    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
    while ($true) {
        Assert-NoInput $What
        $rect = New-Object Shot+RECT
        if ([Shot]::GetWindowRect($Hwnd, [ref]$rect) -and ($rect.Right - $rect.Left) -eq $Width -and ($rect.Bottom - $rect.Top) -eq $Height) { return }
        if ([DateTime]::UtcNow -gt $deadline) { throw "stood down during ${What}: the launcher did not take its position within $($TimeoutMs / 1000) s" }
        Start-Sleep -Milliseconds 50
    }
}

function Publish-Set([string]$Staging, [string]$OutDir, [string[]]$Files) {
    # All or nothing. A journal names every file of the set and whether an
    # earlier file of that name is live, before anything moves. Every earlier
    # file is moved aside inside the staging folder, the new files are moved
    # in, every published file is read back against its staged hash, and the
    # journal is marked complete. A failure at any step removes the new files
    # and puts every aside file back; a file that cannot be put back is named
    # with where it is, and the caller keeps the staging folder that holds it.
    # A publication cut short with no chance to run this undo is recovered by
    # Restore-Interrupted at the driver's next start, from the journal.
    $aside = Join-Path $Staging 'aside'
    New-Item -ItemType Directory -Force -Path $aside | Out-Null
    $hashes = @{}
    foreach ($f in $Files) { $hashes[$f] = (Get-FileHash -LiteralPath (Join-Path $Staging $f)).Hash }
    $entries = @($Files | ForEach-Object { @{ name = $_; earlier = (Test-Path -LiteralPath (Join-Path $OutDir $_)) } })
    Write-Journal $Staging $entries $false
    $movedAside = [System.Collections.Generic.List[string]]::new()
    $movedIn = [System.Collections.Generic.List[string]]::new()
    # From the first move until publication or its undo has finished, the
    # staging folder holds the only copy of an earlier file, so the caller
    # keeps it whatever happens next.
    $script:KeepStaging = $true
    try {
        foreach ($f in $Files) {
            $live = Join-Path $OutDir $f
            if (Test-Path -LiteralPath $live) { [System.IO.File]::Move($live, (Join-Path $aside $f)); $movedAside.Add($f) }
        }
        foreach ($f in $Files) {
            [System.IO.File]::Move((Join-Path $Staging $f), (Join-Path $OutDir $f))
            $movedIn.Add($f)
            if ($script:PublishHook -and (& $script:PublishHook $OutDir $movedIn.Count) -eq 'stop') { return }   # the self-test's stand-in for the driver ending here
        }
        foreach ($f in $Files) {
            if ((Get-FileHash -LiteralPath (Join-Path $OutDir $f)).Hash -ne $hashes[$f]) { throw "$f read back differently from what was staged" }
        }
        Write-Journal $Staging $entries $true
    } catch {
        $why = $_.Exception.Message
        # Each step of the undo reports instead of throwing, so one that
        # fails cannot skip the rest or the decision to keep the staging folder.
        $stuck = @()
        foreach ($f in $movedIn) {
            try { [System.IO.File]::Delete((Join-Path $OutDir $f)) } catch { $stuck += $f }
        }
        $lost = @()
        foreach ($f in $movedAside) {
            try { [System.IO.File]::Move((Join-Path $aside $f), (Join-Path $OutDir $f)) } catch { $lost += $f }
        }
        if ($stuck -or $lost) {
            $parts = @()
            if ($stuck) { $parts += "the new $($stuck -join ', ') could not be removed" }
            if ($lost) { $parts += "the earlier $($lost -join ', ') could not be put back and are in $aside" }
            throw "publication failed ($why), and $($parts -join '; '); the staging folder is kept, and the next run puts the earlier files back"
        }
        $script:KeepStaging = $false
        throw "publication failed, nothing was published, and the earlier files are as they were: $why"
    }
    Remove-Item -LiteralPath $aside -Recurse -Force
    $script:KeepStaging = $false
}

function Restore-Interrupted([string]$OutDir) {
    # A staging folder whose run is gone: its journal says what to do. Not
    # complete: every earlier file it moved aside goes back, and every new
    # file it moved in where no earlier file was is removed. Complete, or no
    # journal (publication never began): the folder is only removed. A
    # staging folder whose run is alive is left alone.
    $said = @()
    foreach ($dir in @(Get-ChildItem -LiteralPath $OutDir -Directory -Force -Filter '.capture-staging-*')) {
        if ($dir.Name -notmatch '^\.capture-staging-(\d+)-') { continue }
        $owner = Get-Process -Id ([int]$Matches[1]) -ErrorAction SilentlyContinue   # none is the answer "the run is gone"
        if ($owner) { continue }
        $journal = Join-Path $dir.FullName 'publish.json'
        if (Test-Path -LiteralPath $journal) {
            $record = Get-Content -LiteralPath $journal -Raw | ConvertFrom-Json
            if (-not $record.complete) {
                foreach ($entry in $record.files) {
                    $kept = Join-Path $dir.FullName "aside\$($entry.name)"
                    $live = Join-Path $OutDir $entry.name
                    if (Test-Path -LiteralPath $kept) {
                        [System.IO.File]::Move($kept, $live, $true)
                    } elseif (-not $entry.earlier -and (Test-Path -LiteralPath $live) -and -not (Test-Path -LiteralPath (Join-Path $dir.FullName $entry.name))) {
                        Remove-Item -LiteralPath $live -Force
                    }
                }
                $said += "recovered the interrupted publication in $($dir.Name): the earlier files are back"
            }
        }
        Remove-Item -LiteralPath $dir.FullName -Recurse -Force
    }
    return $said
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
    # A window whose thread does not answer: the send returns by its deadline, naming the command.
    $hung = [Hung]::Start(8000)
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    $said = $null
    try { Send-Command $hung 1030 'the theme change' 1000 } catch { $said = $_.Exception.Message }
    $clock.Stop()
    Check 'a command to a window that does not answer returns by its deadline, naming the command' ($clock.ElapsedMilliseconds -lt 3000 -and $said -like '*did not answer command 1030*')
    $hung = [Hung]::Start(8000)
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    $said = $null
    try { Set-Position $hung 40 40 300 200 'positioning' 1000 } catch { $said = $_.Exception.Message }
    $clock.Stop()
    Check 'positioning a window that does not answer returns by its deadline, naming the step' ($clock.ElapsedMilliseconds -lt 3000 -and $said -like '*during positioning*did not take its position*')

    # A set published over an earlier one while one destination sidecar is locked by another handle.
    $root = Join-Path ([System.IO.Path]::GetTempPath()) ("capture-publish-selftest-" + [Guid]::NewGuid().ToString('N'))
    $out = Join-Path $root 'out'; $stage = Join-Path $root 'stage'
    New-Item -ItemType Directory -Path $out, $stage | Out-Null
    try {
        $files = @('a.png', 'a.txt', 'b.png', 'b.txt')
        foreach ($f in $files) { Set-Content -LiteralPath (Join-Path $out $f) -Value "earlier $f"; Set-Content -LiteralPath (Join-Path $stage $f) -Value "new $f" }
        $state = { @(Get-ChildItem -LiteralPath $out -File | Sort-Object Name | ForEach-Object { "$($_.Name) $((Get-FileHash -LiteralPath $_.FullName).Hash)" }) -join ';' }
        $earlier = & $state
        $lock = [System.IO.File]::Open((Join-Path $out 'b.txt'), 'Open', 'Read', 'None')
        $said = $null
        $script:KeepStaging = $false
        try { Publish-Set $stage $out $files } catch { $said = $_.Exception.Message } finally { $lock.Dispose() }
        Check 'a refused publication says nothing was published' ($said -like '*nothing was published*')
        Check 'a refused publication leaves the earlier set byte for byte, with no new or aside file' ((& $state) -eq $earlier -and -not $script:KeepStaging)
        $restage = { foreach ($f in $files) { if (-not (Test-Path -LiteralPath (Join-Path $stage $f))) { Set-Content -LiteralPath (Join-Path $stage $f) -Value "new $f" } } }
        & $restage

        # (b) a published file reads back differently after the new files were moved in.
        $script:PublishHook = { param($dir, $count) if ($count -eq $files.Count) { Set-Content -LiteralPath (Join-Path $dir 'a.txt') -Value 'damaged' } }
        $said = $null
        try { Publish-Set $stage $out $files } catch { $said = $_.Exception.Message } finally { $script:PublishHook = $null }
        Check 'a publication that reads back differently after installing says nothing was published' ($said -like '*nothing was published*a.txt read back differently*')
        Check 'a publication that reads back differently leaves the earlier set byte for byte' ((& $state) -eq $earlier)
        # The caller removes its staging folder after a failure; this case reuses it, so its empty aside folder goes here.
        if (Test-Path -LiteralPath (Join-Path $stage 'aside')) { Remove-Item -LiteralPath (Join-Path $stage 'aside') -Recurse -Force }
        & $restage

        # (c) a publication stopped after two new files were moved in, as a driver ended there would leave it, then recovered as the next start does.
        $dead = Join-Path $out '.capture-staging-999999-selftest'
        New-Item -ItemType Directory -Path $dead | Out-Null
        foreach ($f in $files) { Copy-Item -LiteralPath (Join-Path $stage $f) -Destination $dead }
        $script:PublishHook = { param($dir, $count) if ($count -eq 2) { 'stop' } }
        try { Publish-Set $dead $out $files } finally { $script:PublishHook = $null }
        $cut = & $state
        $recovered = Restore-Interrupted $out
        Check 'a publication cut short is recovered at the next start: the earlier set byte for byte, no staging, aside or journal left' ($cut -ne $earlier -and (& $state) -eq $earlier -and -not (Test-Path -LiteralPath $dead) -and $recovered.Count -eq 1)

        # (d) after installing, another handle holds a new file with no sharing: the readback fails, and so does removing it.
        $held = Join-Path $out '.capture-staging-999998-selftest'
        New-Item -ItemType Directory -Path $held | Out-Null
        foreach ($f in $files) { Copy-Item -LiteralPath (Join-Path $stage $f) -Destination $held }
        $script:Holder = $null
        $script:PublishHook = { param($dir, $count) if ($count -eq $files.Count) { $script:Holder = [System.IO.File]::Open((Join-Path $dir 'a.png'), 'Open', 'Read', 'None') } }
        $said = $null
        $script:KeepStaging = $false
        try { Publish-Set $held $out $files } catch { $said = $_.Exception.Message } finally { $script:PublishHook = $null }
        $asideKept = @(Get-ChildItem -LiteralPath (Join-Path $held 'aside') -File | Sort-Object Name | ForEach-Object { "$($_.Name)=$((Get-Content -LiteralPath $_.FullName -Raw).Trim())" }) -join ';'
        Check 'an undo that cannot remove a held file names it and keeps the staging folder with the earlier file' ($said -like '*the new a.png could not be removed*' -and $script:KeepStaging -and $asideKept -like '*a.png=earlier a.png*')
        $script:Holder.Dispose()
        $null = Restore-Interrupted $out
        Check 'the next start then puts the whole earlier set back' ((& $state) -eq $earlier -and -not (Test-Path -LiteralPath $held))
        $script:KeepStaging = $false

        Publish-Set $stage $out $files
        $now = @(Get-ChildItem -LiteralPath $out -File | Sort-Object Name | ForEach-Object { "$($_.Name)=$((Get-Content -LiteralPath $_.FullName -Raw).Trim())" }) -join ';'
        Check 'a publication over an earlier set leaves only the new set' ($now -eq 'a.png=new a.png;a.txt=new a.txt;b.png=new b.png;b.txt=new b.txt' -and @(Get-ChildItem -LiteralPath $stage -Recurse -File | Where-Object Name -ne 'publish.json').Count -eq 0)
    } finally {
        Remove-Item -LiteralPath $root -Recurse -Force
    }
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
foreach ($line in (Restore-Interrupted $OutDir)) { Write-Host $line -ForegroundColor Yellow }
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
        Set-Position $hwnd 40 40 1600 1000 'positioning'
        Invoke-Drill 'positioning'
        Wait-Checked 500 'positioning'
        # The launcher starts in System appearance; its theme command
        # cycles System, Dark, Light, so one press is dark, two light.
        foreach ($i in 1..$Presses) {
            Send-Command $hwnd 1030 'the theme change'
            Invoke-Drill 'theme'
            Wait-Checked 900 'the theme change'
        }
        Send-Command $hwnd $ViewCmd 'the view change'
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

$script:KeepStaging = $false

$bindFailure = [Lifetime]::Bind()
if ($bindFailure) {
    Write-Host "stood down before launching anything: the processes this run would start could not be bound to its lifetime ($bindFailure)" -ForegroundColor Yellow
    exit 3
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
        Publish-Set $Staging $OutDir @($script:Shots | ForEach-Object { "$_.png"; "$_.txt" })
        Write-Output "published $($script:Shots.Count) shots to $OutDir"
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        if ($script:KeepStaging) {
            Write-Host "every process the driver started was ended; the staging folder $Staging is kept because it holds earlier files" -ForegroundColor Yellow
        } else {
            Write-Host "no further shot was attempted, nothing was published, and every process the driver started was ended" -ForegroundColor Yellow
        }
        $code = 3
    } finally {
        if (-not $script:KeepStaging) { Remove-Item -LiteralPath $Staging -Recurse -Force }
    }
} finally {
    [Watch]::Stop()
}
exit $code
