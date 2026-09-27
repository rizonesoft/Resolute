<#
.SYNOPSIS
    The nightly regression run and night-debt collector. D00 T02 §11.

.DESCRIPTION
    One governed run of the whole suite while the operator is away, with its
    evidence where the next morning finds it. docs/testing.md states the
    procedure; this script is it.

      -Register     create the \Resolute\Nightly scheduled task (daily 02:05,
                    and on idle), running this script as the signed-in user
      -Unregister   remove that task
      (no switch)   run once: -Mode Auto (the default) runs as Night inside
                    02:00-06:50, as Collect when the session is unlocked and
                    idle past -IdleMinutes, and otherwise exits

    A run never touches the working tree the writer uses: it builds each
    commit it tests in its own git worktree under build/nightly/wt/, holds an
    exclusive lock so no two runs overlap, and writes only ignored scratch
    under build/nightly/. Tracked changes (Night-verified lines, findings) are
    listed in the morning report for Claude Code to make.

.EXAMPLE
    pwsh tools/nightly.ps1 -Register
    pwsh tools/nightly.ps1 -Mode Manual
#>
[CmdletBinding()]
param(
    [ValidateSet('Auto', 'Night', 'Collect', 'Manual')]
    [string]$Mode = 'Auto',
    [int]$IdleMinutes = 10,
    [switch]$Register,
    [switch]$Unregister,
    # Test hook: run the halves against this commit instead of master's head.
    [string]$Commit = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
# Python and this script agree on UTF-8, or a section mark reads back garbled.
$env:PYTHONIOENCODING = 'utf-8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$NightDir = Join-Path $Root 'build\nightly'
$TaskPath = '\Resolute\'
$TaskName = 'Nightly'

if ($Register -or $Unregister) {
    if ($Unregister) {
        if (Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false
            Write-Host "nightly: removed $TaskPath$TaskName"
        } else {
            Write-Host "nightly: $TaskPath$TaskName is not registered"
        }
        exit 0
    }
    $pwsh = (Get-Command pwsh).Source
    $action = New-ScheduledTaskAction -Execute $pwsh -WorkingDirectory $Root `
        -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Mode Auto"
    $daily = New-ScheduledTaskTrigger -Daily -At '02:05'
    $idleClass = Get-CimClass -Namespace 'Root/Microsoft/Windows/TaskScheduler' -ClassName 'MSFT_TaskIdleTrigger'
    $idle = New-CimInstance -CimClass $idleClass -ClientOnly
    $settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Hours 4) `
        -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd `
        -IdleDuration (New-TimeSpan -Minutes $IdleMinutes) -IdleWaitTimeout (New-TimeSpan -Hours 1)
    # Interactive: the run needs the signed-in desktop, and runs only while
    # the user is signed in, as that user, with no stored password.
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited
    Register-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Action $action -Trigger @($daily, $idle) `
        -Settings $settings -Principal $principal -Force `
        -Description 'Resolute nightly regression run and night-debt collector (D00 T02 section 11). Remove with tools/nightly.ps1 -Unregister.' | Out-Null
    $t = Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
    Write-Host "nightly: registered $TaskPath$TaskName, triggers: $(($t.Triggers | ForEach-Object { $_.CimClass.CimClassName }) -join ', '), state $($t.State)"
    exit 0
}

Add-Type @'
using System; using System.Runtime.InteropServices;
public static class NightProbe {
  [StructLayout(LayoutKind.Sequential)] public struct LII { public uint cbSize; public uint dwTime; }
  [DllImport("user32.dll")] public static extern bool GetLastInputInfo(ref LII p);
  [DllImport("user32.dll")] public static extern IntPtr OpenInputDesktop(uint f, bool i, uint a);
  [DllImport("user32.dll")] public static extern bool CloseDesktop(IntPtr h);
  [DllImport("user32.dll")] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr c);
  public delegate bool MonitorEnum(IntPtr m, IntPtr dc, IntPtr r, IntPtr d);
  [DllImport("user32.dll")] public static extern bool EnumDisplayMonitors(IntPtr dc, IntPtr clip, MonitorEnum f, IntPtr d);
  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)] public struct MI { public int cbSize; public int l, t, r, b; public int wl, wt, wr, wb; public uint flags; [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dev; }
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern bool GetMonitorInfoW(IntPtr m, ref MI i);
  [DllImport("shcore.dll")] public static extern int GetDpiForMonitor(IntPtr m, int t, out uint x, out uint y);
  public static uint IdleSeconds() { var l = new LII(); l.cbSize = 8; GetLastInputInfo(ref l); return ((uint)Environment.TickCount - l.dwTime) / 1000; }
  public static bool Unlocked() { var h = OpenInputDesktop(0, false, 0x0100); if (h == IntPtr.Zero) return false; CloseDesktop(h); return true; }
  public static string Monitors() {
    // Per-monitor aware first: unaware, every DPI reads 96 (docs/testing.md).
    SetThreadDpiAwarenessContext(new IntPtr(-4));
    var sb = new System.Text.StringBuilder();
    EnumDisplayMonitors(IntPtr.Zero, IntPtr.Zero, (m, dc, r, d) => {
      var i = new MI(); i.cbSize = Marshal.SizeOf(typeof(MI)); GetMonitorInfoW(m, ref i);
      uint x, y; GetDpiForMonitor(m, 0, out x, out y);
      sb.AppendFormat("monitor {0} {1}x{2} dpi {3}{4}; ", i.dev, i.r - i.l, i.b - i.t, x, (i.flags & 1) != 0 ? " primary" : "");
      return true; }, IntPtr.Zero);
    return sb.ToString().TrimEnd(' ', ';');
  }
}
'@

$now = Get-Date
$minute = $now.Hour * 60 + $now.Minute
$inWindow = $minute -ge 120 -and $minute -lt 410
$idle = [NightProbe]::IdleSeconds()
$unlocked = [NightProbe]::Unlocked()
if ($Mode -eq 'Auto') {
    $Mode = if ($inWindow) { 'Night' } elseif ($unlocked -and $idle -ge $IdleMinutes * 60) { 'Collect' } else { '' }
    if (-not $Mode) { exit 0 }   # not night, and the operator is here: nothing to do
}

New-Item -ItemType Directory -Force -Path $NightDir | Out-Null
$lockPath = Join-Path $NightDir '.lock'
try {
    $lock = [System.IO.File]::Open($lockPath, 'OpenOrCreate', 'ReadWrite', 'None')
} catch {
    exit 0   # another run holds the lock: one run at a time
}

$Id = $now.ToString('yyyyMMdd-HHmmss')
$RunDir = Join-Path $NightDir $Id
New-Item -ItemType Directory -Force -Path $RunDir | Out-Null
$Report = [System.Collections.Generic.List[string]]::new()
function Note([string]$line) { $Report.Add($line); Add-Content -Path (Join-Path $RunDir 'run.log') -Value $line }

$env:PATH = "$Root\reskit\cmake\bin;$Root\reskit\ninja;$Root\reskit\llvm-mingw\bin;$env:PATH"
$Python = (Get-Command python).Source

# The commit to build, checked out into its own worktree with the toolchain
# linked in (reskit/ is ignored, so a worktree does not carry it).
function Get-Worktree([string]$sha) {
    $wt = Join-Path $NightDir "wt\$($sha.Substring(0, 12))"
    if (-not (Test-Path (Join-Path $wt '.git'))) {
        & git -C $Root worktree add --detach $wt $sha 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "worktree add $sha failed" }
    }
    # reskit/ itself is tracked (its scripts); the toolchain inside it is not.
    foreach ($tool in 'cmake', 'ninja', 'llvm-mingw') {
        $link = Join-Path $wt "reskit\$tool"
        if (-not (Test-Path $link)) {
            New-Item -ItemType Junction -Path $link -Target (Join-Path $Root "reskit\$tool") | Out-Null
        }
    }
    return $wt
}

function Build-At([string]$wt, [string]$log) {
    Push-Location $wt
    try {
        & cmake --preset debug *> "$log.configure" ; if ($LASTEXITCODE -ne 0) { return $false }
        & cmake --build (Join-Path $wt 'build\debug') *> "$log.build"; return $LASTEXITCODE -eq 0
    } finally { Pop-Location }
}

# How many tests ctest says it ran ("... out of N"), or -1 when it never said.
function Read-Total([string]$log) {
    $m = Select-String -Path $log -Pattern 'tests passed.* out of (\d+)' | Select-Object -Last 1
    if ($m) { return [int]$m.Matches[0].Groups[1].Value }
    return -1
}

# A half is complete when ctest finished, named as many results as it ran,
# and exited 0 or named a failing test for its nonzero exit.
function Check-Half([string]$half, [System.Collections.IDictionary]$r, [string]$log, [int]$exit) {
    $total = Read-Total $log
    if ($r.Count -eq 0 -or $total -lt 0 -or $r.Count -ne $total) {
        $failures.Add("${half}: incomplete ($($r.Count) results of $total, ctest exit $exit)")
    } elseif ($exit -ne 0 -and @($r.Values | Where-Object { $_ -notin 'Passed', 'Skipped' }).Count -eq 0) {
        $failures.Add("${half}: ctest exit $exit with no failing test named")
    }
}

# ctest's per-test results: name -> Passed, Skipped, Failed, Timeout, Exception, Not Run.
function Read-Results([string]$log) {
    $r = [ordered]@{}
    foreach ($line in Get-Content $log) {
        if ($line -match 'Test\s+#\d+:\s+(.+?)\s+\.+\s*\**(Passed|Skipped|Failed|Timeout|Not Run|Exception)') { $r[$Matches[1]] = $Matches[2] }
    }
    return $r
}

function Count-Line([System.Collections.IDictionary]$r, [string]$log) {
    $passed = @($r.Values | Where-Object { $_ -eq 'Passed' }).Count
    $skipped = @($r.Values | Where-Object { $_ -eq 'Skipped' }).Count
    $failed = $r.Count - $passed - $skipped
    $violations = @(Select-String -Path $log -Pattern 'FOCUS-VIOLATION' -SimpleMatch).Count
    return "passed $passed, failed $failed, skipped-with-reason $skipped, focus violations $violations"
}

$head = if ($Commit) { $Commit } else { (& git -C $Root rev-parse master).Trim() }
Note "# Nightly report $Id"
Note ''
Note "mode $Mode; master $head; started $($now.ToString('yyyy-MM-dd HH:mm:ss')); idle ${idle}s; session $(if ($unlocked) { 'unlocked' } else { 'LOCKED' })"
Note "probe: $([NightProbe]::Monitors())"
Note ''
$failures = [System.Collections.Generic.List[string]]::new()

try {
    if ($Mode -ne 'Collect') {
        $wt = Get-Worktree $head
        $built = Build-At $wt (Join-Path $RunDir 'build')
        Note "## Halves at $($head.Substring(0, 12))"
        if (-not $built) {
            Note 'build FAILED: see the build log; neither half ran'
            $failures.Add("the build of $head failed")
        } else {
            Push-Location $wt
            & ctest --preset debug -V *> (Join-Path $RunDir 'default.log')
            $ctestExit = $LASTEXITCODE
            $d = Read-Results (Join-Path $RunDir 'default.log')
            Note "default half: $(Count-Line $d (Join-Path $RunDir 'default.log'))"
            # A half with no results never ran: ctest failed before any test
            # (a bad preset, an empty inventory), which is a failure, not a pass.
            Check-Half 'default' $d (Join-Path $RunDir 'default.log') $ctestExit
            foreach ($k in $d.Keys) { if ($d[$k] -notin 'Passed', 'Skipped') { $failures.Add("default: $k ($($d[$k]))") } }
            # The lock state now, not as it was before the build.
            $unlocked = [NightProbe]::Unlocked()
            if (-not $unlocked) {
                Note 'fenced half: skipped, the session is locked (a locked desktop cannot show windows); the debt stays owed'
            } else {
                if ($Mode -eq 'Collect') { $env:RESOLUTE_IDLE_COLLECT = '1' }
                & ctest --preset headful -V *> (Join-Path $RunDir 'full.log')
                $ctestExit = $LASTEXITCODE
                Remove-Item Env:RESOLUTE_IDLE_COLLECT -ErrorAction SilentlyContinue
                $f = Read-Results (Join-Path $RunDir 'full.log')
                Check-Half 'fenced' $f (Join-Path $RunDir 'full.log') $ctestExit
                Note "fenced half: $(Count-Line $f (Join-Path $RunDir 'full.log'))"
                foreach ($line in Select-String -Path (Join-Path $RunDir 'full.log') -Pattern '^\d+: SKIP "' ) { Note "  $($line.Line -replace '^\d+: ', '')" }
                foreach ($k in $f.Keys) { if ($f[$k] -notin 'Passed', 'Skipped') { $failures.Add("fenced: $k ($($f[$k]))") } }
            }
            Pop-Location
        }
        Note ''
    }

    # Night debt: each owed case run at the candidate it was reviewed at.
    $debtJson = & $Python (Join-Path $Root 'scripts\todo-graph.py') query night-debt --json 2> (Join-Path $RunDir 'night-debt.err')
    if ($LASTEXITCODE -ne 0) {
        $failures.Add("query night-debt failed (exit $LASTEXITCODE): $((Get-Content (Join-Path $RunDir 'night-debt.err')) -join ' ')")
    }
    $debt = @($debtJson | ConvertFrom-Json)
    Note "## Night debt: $($debt.Count) open before this run"
    $verified = [System.Collections.Generic.List[string]]::new()
    if ($debt.Count -gt 0 -and -not $unlocked) {
        Note 'collection skipped: the session is locked; every entry stays owed'
    } elseif ($debt.Count -gt 0) {
        foreach ($group in ($debt | Group-Object candidate)) {
            $sha = $group.Name
            $wt = Get-Worktree $sha
            if (-not (Build-At $wt (Join-Path $RunDir "debt-$($sha.Substring(0, 8))"))) {
                Note "candidate $($sha.Substring(0, 8)): build FAILED; its debt stays owed"
                $failures.Add("the build of candidate $sha failed")
                continue
            }
            $cases = @($group.Group | ForEach-Object { $_.case } | Select-Object -Unique)
            $results = @{}
            $reds = @{}     # how many executed attempts each case was red in
            $run = $cases   # attempt 1 runs every owed case
            foreach ($attempt in 1, 2) {
                if ($run.Count -eq 0) { break }
                if (-not [NightProbe]::Unlocked()) {
                    Note "candidate $($sha.Substring(0, 8)) attempt ${attempt}: not run, the session locked; the debt stays owed"
                    break
                }
                $regex = '^(' + (($run | ForEach-Object { [regex]::Escape($_) -replace '\\ ', ' ' }) -join '|') + ')$'
                $log = Join-Path $RunDir "debt-$($sha.Substring(0, 8))-a$attempt.log"
                Push-Location $wt
                if ($Mode -eq 'Collect') { $env:RESOLUTE_IDLE_COLLECT = '1' }
                & ctest --preset headful -R $regex -V *> $log
                $attemptExit = $LASTEXITCODE
                Remove-Item Env:RESOLUTE_IDLE_COLLECT -ErrorAction SilentlyContinue
                Pop-Location
                $r = Read-Results $log
                # An attempt ctest did not finish proves nothing either way:
                # its cases stay owed, verified by nothing and reopened by nothing.
                $total = Read-Total $log
                $named = @($r.Values | Where-Object { $_ -notin 'Passed', 'Skipped' }).Count
                if ($r.Count -eq 0 -or $total -lt 0 -or $r.Count -ne $total -or ($attemptExit -ne 0 -and $named -eq 0)) {
                    foreach ($c in $run) { $results[$c] = 'Incomplete' }
                    $failures.Add("candidate $($sha.Substring(0, 8)) attempt ${attempt}: incomplete ($($r.Count) results of $total, ctest exit $attemptExit); its debt stays owed")
                    Note "candidate $($sha.Substring(0, 8)) attempt ${attempt}: incomplete, ctest exit $attemptExit; the debt stays owed"
                    break
                }
                # Every case this attempt ran takes its result, a pass included.
                foreach ($c in $run) {
                    $results[$c] = if ($r.Contains($c)) { $r[$c] } else { 'Not Run' }
                    if ($results[$c] -notin 'Passed', 'Skipped') { $reds[$c] = 1 + [int]$reds[$c] }
                }
                $summary = @($run | ForEach-Object { '"' + $_ + '" ' + $results[$_] }) -join '; '
                Note "candidate $($sha.Substring(0, 8)) attempt ${attempt}: $summary"
                # Only red retries: a pass is done, and a skip (the gate, input,
                # a lock, hardware absent) stays owed without a retry.
                $run = @($run | Where-Object { $results[$_] -notin 'Passed', 'Skipped', 'Incomplete' })
            }
            foreach ($section in ($group.Group | Group-Object section)) {
                $green = @($section.Group | Where-Object { $results[$_.case] -eq 'Passed' } | ForEach-Object { "`"$($_.case)`"" })
                if ($green.Count -gt 0) {
                    $verified.Add("$($section.Name): > **Night-verified:** $($now.ToString('yyyy-MM-dd')) | candidate $sha | run $Id | $($green -join '; ')")
                }
                foreach ($e in $section.Group) {
                    $state = $results[$e.case]
                    # Only red in two executed attempts reopens; an attempt a
                    # lock or input prevented leaves the debt owed.
                    if ([int]$reds[$e.case] -ge 2) {
                        $failures.Add("REOPEN $($section.Name) through audit stance: `"$($e.case)`" red twice at candidate $sha ($state)")
                    } elseif ([int]$reds[$e.case] -eq 1) {
                        Note "  `"$($e.case)`" red once, its retry not run: stays owed"
                    }
                }
            }
        }
    }
    Note ''
    Note '## For Claude Code to record'
    if ($verified.Count -eq 0 -and $failures.Count -eq 0) { Note 'nothing: no debt cleared and no failure' }
    foreach ($v in $verified) { Note "- append to $v" }
    foreach ($f in $failures) { Note "- file as a finding in the owning TODO: $f" }
    $still = @(& $Python (Join-Path $Root 'scripts\todo-graph.py') query night-debt)
    Note ''
    Note '## Open debt (before the lines above are recorded)'
    foreach ($line in $still) { Note "    $line" }
} catch {
    Note "run ERROR: $($_.Exception.Message)"
    $failures.Add("the run itself failed: $($_.Exception.Message)")
} finally {
    Note ''
    Note "finished $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')); logs in build/nightly/$Id/"
    $Report | Set-Content -Path (Join-Path $RunDir 'report.md') -Encoding utf8
    $Report | Set-Content -Path (Join-Path $NightDir 'morning-report.md') -Encoding utf8
    Set-Content -Path (Join-Path $NightDir 'latest.txt') -Value $Id -Encoding utf8
    $lock.Dispose()
}
exit 0
