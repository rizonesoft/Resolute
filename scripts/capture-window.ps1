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
    [string]$Out,

    # Read a pair and say whether its sidecar is the one for its image (D00 T02 section 13).
    [string]$Verify = '',
    [string]$Describes = '',

    # The appearance the captured window shows. An application can override
    # the system setting, so matrix captures state it; without it the
    # sidecar records the system setting, labelled as such (D00 T02 §9).
    [ValidateSet('', 'light', 'dark')]
    [string]$Appearance = '',
    [int]$WaitSeconds = 5,
    [switch]$KeepOpen,

    # The fixture and launch arguments the sidecar must record so a second
    # operator can recreate the comparison from the sidecar alone
    # (D00 T02 section 12, item 5 schema).
    [string]$Fixture = '',
    [string]$LaunchArgs = '',

    # The exact launch context and fixture inventory, recorded verbatim so
    # a second operator can recreate the capture from the sidecar alone
    # (D00 T02 section 12).
    [string]$LaunchContext = '',
    [string]$FixtureFiles = '',

    # Check the pair writer and the covered-window rule without a desktop (D00 T02 sections 13 and 14).
    [switch]$SelfTest,

    # A drill (D00 T02 section 14): an always-on-top window of another
    # process laid over the target before the first check, or between the
    # first check and the copy, so each check is proven as it runs.
    # 'hide' hides the target between the checks instead, as a target that closes or minimizes
    # mid-capture would, and shows it again: this script never ends a process it did not start.
    [ValidateSet('', 'before', 'between', 'hide')][string]$DrillCoverAt = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ---- covered windows (D00 T02 section 14) -----------------------------------
# Owning the foreground does not mean nothing covers the target: an
# always-on-top window of another application can lie over it. Before the
# copy and again after it, the windows above the target in z-order are read,
# and any that could show in the target's frame refuses the capture.

if (-not ('ZOrder' -as [type])) {
    Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class ZOrder {
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] static extern IntPtr GetWindow(IntPtr h, uint cmd);
    [DllImport("user32.dll")] static extern bool IsWindow(IntPtr h);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
    [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowTextW(IntPtr h, StringBuilder s, int n);
    [DllImport("dwmapi.dll")] static extern int DwmGetWindowAttribute(IntPtr h, int a, out RECT r, int size);
    [DllImport("dwmapi.dll")] static extern int DwmGetWindowAttribute(IntPtr h, int a, out int v, int size);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern IntPtr FindWindowW(string cls, string title);
    // Every window above this one in z-order, nearest first.
    public static IntPtr[] Above(IntPtr target) {
        var list = new System.Collections.Generic.List<IntPtr>();
        for (IntPtr h = GetWindow(target, 3); h != IntPtr.Zero && list.Count < 100000; h = GetWindow(h, 3)) list.Add(h);   // GW_HWNDPREV
        return list.ToArray();
    }
    public class Info { public bool Visible; public bool Cloaked; public RECT Frame; public uint Pid; public string Title; }
    // What the walk needs of one window, or null when it cannot be read.
    public static Info Inspect(IntPtr h) {
        if (!IsWindow(h)) return null;
        var info = new Info();
        info.Visible = IsWindowVisible(h) && !IsIconic(h);
        GetWindowThreadProcessId(h, out info.Pid);
        var t = new StringBuilder(256); GetWindowTextW(h, t, 256); info.Title = t.ToString();
        if (!info.Visible) return info;
        int cloaked;
        if (DwmGetWindowAttribute(h, 14, out cloaked, 4) != 0) return null;   // DWMWA_CLOAKED
        info.Cloaked = cloaked != 0;
        if (DwmGetWindowAttribute(h, 9, out info.Frame, 16) != 0 && !GetWindowRect(h, out info.Frame)) return null;   // DWMWA_EXTENDED_FRAME_BOUNDS, then the window rectangle
        if (!IsWindow(h)) return null;   // gone while it was read
        return info;
    }
}
'@
}

function Test-Overlap([int[]]$A, [int[]]$B) {
    # Left, top, right, bottom each; true when the two share any pixel.
    return ($A[0] -lt $B[2] -and $B[0] -lt $A[2] -and $A[1] -lt $B[3] -and $B[1] -lt $A[3])
}

function Get-Covering([IntPtr[]]$Above, [int[]]$Frame, [uint32]$TargetPid, [scriptblock]$Inspect) {
    # The windows that could show in the target's frame, as "title (process id)"
    # lines; throws, naming the window, when one cannot be read.
    $found = @()
    foreach ($h in $Above) {
        $info = & $Inspect $h
        if ($null -eq $info) { throw "window $h could not be read, so whether it covers the target is unknown" }
        if (-not $info.Visible -or $info.Cloaked -or $info.Pid -eq $TargetPid) { continue }
        $f = @($info.Frame.Left, $info.Frame.Top, $info.Frame.Right, $info.Frame.Bottom)
        if ($f[2] -le $f[0] -or $f[3] -le $f[1]) { continue }
        if (Test-Overlap $f $Frame) {
            $name = try { (Get-Process -Id $info.Pid -ErrorAction Stop).ProcessName } catch { "process $($info.Pid)" }   # a process that has gone is named by its id
            $found += "'$($info.Title)' ($name, pid $($info.Pid))"
        }
    }
    return $found
}

function Test-Target($Info, [int[]]$Frame) {
    # $null when the target is still there, visible, and where it was
    # measured; the refusal otherwise. A target that closed has nothing
    # above it, so the walk alone would call it uncovered.
    if ($null -eq $Info) { return 'the target window is gone' }
    if (-not $Info.Visible -or $Info.Cloaked) { return 'the target window is no longer visible' }
    $now = @($Info.Frame.Left, $Info.Frame.Top, $Info.Frame.Right, $Info.Frame.Bottom)
    if (($now -join ',') -ne ($Frame -join ',')) { return "the target window moved (it was at $($Frame -join ','), it is at $($now -join ','))" }
    return $null
}

function Assert-Uncovered([IntPtr]$Hwnd, [int[]]$Frame, [uint32]$TargetPid, [string]$When) {
    $gone = Test-Target ([ZOrder]::Inspect($Hwnd)) $Frame
    if ($gone) { return "capture-window: refused $When the copy: $gone" }
    try {
        $covering = @(Get-Covering ([ZOrder]::Above($Hwnd)) $Frame $TargetPid { param($h) [ZOrder]::Inspect($h) })
    } catch {
        return "capture-window: refused $When the copy: $($_.Exception.Message)"
    }
    if ($covering.Count) { return "capture-window: refused $When the copy: the target is covered by $($covering -join ', ')" }
    return $null
}

# ---- the pair writer (D00 T02 section 13) -----------------------------------
# A capture is two files that prove each other: the image and the sidecar that
# says what it shows. They are written beside the live pair as *.new, each read
# back against the bytes meant, and only then switched in, the image first and
# the sidecar second, each by File.Replace keeping the old file as *.old. If the
# sidecar's switch fails, the image's is undone, so the live pair is either the
# old one or the new one, never one of each. Whatever fails, the *.new and *.old
# files this call made are removed and the failure is named.

function Test-OutPath([string]$Image) {
    # $null when the image and its sidecar are two files, the refusal otherwise.
    $sidecar = [System.IO.Path]::ChangeExtension($Image, '.txt')
    if ([string]::Equals([System.IO.Path]::GetFullPath($sidecar), [System.IO.Path]::GetFullPath($Image), [System.StringComparison]::OrdinalIgnoreCase)) {
        return "-Out $Image would be its own sidecar ($sidecar): give the image a .png name"
    }
    return $null
}

function Test-PairBinding([string]$Image) {
    # $null when the sidecar beside the image records the image's own SHA-256;
    # the reason otherwise. Two files cannot be replaced at once, so a reader
    # trusts a pair only when this holds.
    $sidecar = [System.IO.Path]::ChangeExtension($Image, '.txt')
    if (-not (Test-Path -LiteralPath $Image -PathType Leaf)) { return "no image at $Image" }
    if (-not (Test-Path -LiteralPath $sidecar -PathType Leaf)) { return "no sidecar at $sidecar" }
    $line = @(Get-Content -LiteralPath $sidecar | Where-Object { $_ -match '^image sha256\s*:' }) | Select-Object -First 1
    if (-not $line) { return "the sidecar $sidecar records no image sha256 (it was written before pairs were bound), so the pair cannot be verified" }
    $recorded = ($line -replace '^image sha256\s*:\s*', '').Trim().ToUpperInvariant()
    $actual = (Get-FileHash -LiteralPath $Image -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($recorded -ne $actual) { return "the image's sha256 is $actual, its sidecar records ${recorded}: they are not one capture" }
    return $null
}

$script:AfterWrite = $null   # the self-test's way to make a write land other bytes
$script:SwitchHook = $null   # the self-test's stand-in for the writer ending between the two switches

function Enter-PairLock([string]$Image, [int]$TimeoutMs = 30000) {
    # One writer per output pair, from recovery to the last switch: two
    # captures to the same path would otherwise share the *.new files and
    # could publish one capture's image with the other's sidecar.
    $key = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($Image.ToLowerInvariant()))).Replace('-', '').Substring(0, 32)
    $mutex = [System.Threading.Mutex]::new($false, "Local\ResoluteCapturePair-$key")
    try {
        if (-not $mutex.WaitOne($TimeoutMs)) { $mutex.Dispose(); throw "another capture is writing $Image" }
    } catch [System.Threading.AbandonedMutexException] {
        # A writer that ended while it held the pair: this one owns it now, and recovery repairs what it left.
    }
    return $mutex
}

function Undo-Switch([string]$Image, [string]$Sidecar) {
    # Puts the earlier image back, or removes a lone new one, after the
    # image switched and the sidecar did not. Restartable: the sidecar's
    # *.new is first renamed to a marker that records which of the two this
    # undo is, so an undo cut short is finished the same way next time.
    $imageOld = "$Image.old"
    $restore = "$Sidecar.undo-restore"; $remove = "$Sidecar.undo-remove"
    if (-not (Test-Path -LiteralPath $restore) -and -not (Test-Path -LiteralPath $remove)) {
        $marker = if (Test-Path -LiteralPath $imageOld) { $restore } else { $remove }
        if (Test-Path -LiteralPath "$Sidecar.new") { [System.IO.File]::Move("$Sidecar.new", $marker) } else { [System.IO.File]::WriteAllBytes($marker, [byte[]]@()) }
    }
    if (Test-Path -LiteralPath $restore) {
        if (Test-Path -LiteralPath $imageOld) { [System.IO.File]::Move($imageOld, $Image, $true) }
        [System.IO.File]::Delete($restore)
    }
    if (Test-Path -LiteralPath $remove) {
        if (Test-Path -LiteralPath $Image) { [System.IO.File]::Delete($Image) }
        [System.IO.File]::Delete($remove)
    }
}

function Restore-Pair([string]$Image, [string]$Sidecar) {
    # A writer that ended between the switches, or inside an undo, left a
    # state the files alone describe. Returns what it found, or $null.
    $imageNew = "$Image.new"; $sidecarNew = "$Sidecar.new"; $imageOld = "$Image.old"; $sidecarOld = "$Sidecar.old"
    $said = $null
    if ((Test-Path -LiteralPath "$Sidecar.undo-restore") -or (Test-Path -LiteralPath "$Sidecar.undo-remove")) {
        Undo-Switch $Image $Sidecar
        $said = 'an undo cut short was finished; the earlier pair is back'
    } elseif (Test-Path -LiteralPath $imageNew) {
        # The switch never began: the live pair is untouched.
        foreach ($f in $imageNew, $sidecarNew) { if (Test-Path -LiteralPath $f) { [System.IO.File]::Delete($f) } }
        $said = 'a capture that never switched in was removed'
    } elseif (Test-Path -LiteralPath $sidecarNew) {
        # The image switched and the sidecar did not.
        Undo-Switch $Image $Sidecar
        $said = 'a capture cut short between its switches was undone; the earlier pair is back'
    }
    foreach ($f in $imageOld, $sidecarOld) {
        if (Test-Path -LiteralPath $f) { [System.IO.File]::Delete($f); if (-not $said) { $said = 'a finished capture''s backups were removed' } }
    }
    return $said
}

function Write-Verified([string]$Path, [byte[]]$Bytes, [string]$What) {
    [System.IO.File]::WriteAllBytes($Path, $Bytes)
    if ($script:AfterWrite) { & $script:AfterWrite $Path }
    $back = [System.IO.File]::ReadAllBytes($Path)
    if (-not [System.Linq.Enumerable]::SequenceEqual($back, $Bytes)) {
        throw "the $What read back differently from what was written ($($back.Length) bytes against $($Bytes.Length))"
    }
}

function Switch-In([string]$New, [string]$Live) {
    # Returns the backup of the file it replaced, or $null when there was none.
    if (Test-Path -LiteralPath $Live) {
        $old = "$Live.old"
        [System.IO.File]::Replace($New, $Live, $old)
        return $old
    }
    [System.IO.File]::Move($New, $Live)
    return $null
}

function Write-CapturePair([string]$Image, [byte[]]$ImageBytes, [string]$Sidecar, [byte[]]$SidecarBytes) {
    $imageNew = "$Image.new"
    $sidecarNew = "$Sidecar.new"
    $made = [System.Collections.Generic.List[string]]::new()
    $imageOld = $null
    $imageSwitched = $false
    try {
        $made.Add($imageNew)
        Write-Verified $imageNew $ImageBytes 'image'
        $made.Add($sidecarNew)
        Write-Verified $sidecarNew $SidecarBytes 'sidecar'
        $imageOld = Switch-In $imageNew $Image
        $imageSwitched = $true
        if ($imageOld) { $made.Add($imageOld) }
        if ($script:SwitchHook -and (& $script:SwitchHook) -eq 'stop') { return }
        $sidecarOld = Switch-In $sidecarNew $Sidecar
        if ($sidecarOld) { $made.Add($sidecarOld) }
    } catch {
        $why = $_.Exception.Message
        try {
            # The new image is live beside the old sidecar: put the old image back, or remove the lone new one.
            if ($imageSwitched) { Undo-Switch $Image $Sidecar }
        } catch {
            throw "the capture pair was not written, and the previous image could not be put back ($($_.Exception.Message)); it is at ${imageOld}: $why"
        } finally {
            foreach ($f in $made) { if ($f -ne $imageOld -and (Test-Path -LiteralPath $f -PathType Leaf)) { [System.IO.File]::Delete($f) } }
        }
        throw "the capture pair was not written, and the previous pair is unchanged: $why"
    }
    foreach ($f in $made) { if (Test-Path -LiteralPath $f -PathType Leaf) { Remove-Item -LiteralPath $f -Force } }
}

function Invoke-SelfTest {
    $failed = [System.Collections.Generic.List[string]]::new()
    function Check([string]$Name, [bool]$Ok) {
        if ($Ok) { Write-Host "PASS $Name" } else { Write-Host "FAIL $Name"; $failed.Add($Name) }
    }
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("capture-pair-selftest-" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $dir | Out-Null
    try {
        $png = Join-Path $dir 'shot.png'
        $txt = Join-Path $dir 'shot.txt'
        $enc = [System.Text.UTF8Encoding]::new($false)
        $oldPng = [byte[]](1..64); $oldTxt = $enc.GetBytes("old sidecar`n")
        $newPng = [byte[]](65..160); $newTxt = $enc.GetBytes("new sidecar`n")
        function Hash([string]$f) { (Get-FileHash -LiteralPath $f).Hash }
        function Leftovers { @(Get-ChildItem -LiteralPath $dir -File | Where-Object { $_.Name -like '*.new' -or $_.Name -like '*.old' }).Count }

        Write-CapturePair $png $oldPng $txt $oldTxt
        Check 'a first write leaves a matching pair and no *.new or *.old' ((Leftovers) -eq 0 -and [System.Linq.Enumerable]::SequenceEqual([System.IO.File]::ReadAllBytes($png), $oldPng) -and [System.Linq.Enumerable]::SequenceEqual([System.IO.File]::ReadAllBytes($txt), $oldTxt))
        $before = "$(Hash $png) $(Hash $txt)"

        # A locked sidecar: another process holds the live sidecar open with no sharing.
        $lock = [System.IO.File]::Open($txt, 'Open', 'Read', 'None')
        $threw = $null
        try { Write-CapturePair $png $newPng $txt $newTxt } catch { $threw = $_.Exception.Message } finally { $lock.Dispose() }
        Check 'a refused sidecar write is named' ($threw -like '*was not written*')
        Check 'a refused sidecar write leaves the previous pair byte for byte' ("$(Hash $png) $(Hash $txt)" -eq $before)
        Check 'a refused sidecar write leaves no *.new or *.old' ((Leftovers) -eq 0)

        # A write that lands other bytes: only the readback can see it.
        $script:AfterWrite = { param($f) if ($f -like '*.txt.new') { [System.IO.File]::WriteAllText($f, 'damaged') } }
        $threw = $null
        try { Write-CapturePair $png $newPng $txt $newTxt } catch { $threw = $_.Exception.Message } finally { $script:AfterWrite = $null }
        Check 'a sidecar that reads back differently is refused by name' ($threw -like '*sidecar read back differently*')
        Check 'a sidecar that reads back differently leaves the previous pair byte for byte' ("$(Hash $png) $(Hash $txt)" -eq $before)

        # (c) a writer stopped between the switches, over the previous pair and over none, then recovered as its next start does.
        $script:SwitchHook = { 'stop' }
        try { Write-CapturePair $png $newPng $txt $newTxt } finally { $script:SwitchHook = $null }
        $mixed = "$(Hash $png) $(Hash $txt)" -ne $before
        $found = Restore-Pair $png $txt
        Check 'a writer stopped between the switches is recovered to the previous pair byte for byte' ($mixed -and $found -like '*undone*' -and "$(Hash $png) $(Hash $txt)" -eq $before -and (Leftovers) -eq 0)
        $lonePng = Join-Path $dir 'first.png'; $loneTxt = Join-Path $dir 'first.txt'
        $script:SwitchHook = { 'stop' }
        try { Write-CapturePair $lonePng $newPng $loneTxt $newTxt } finally { $script:SwitchHook = $null }
        $null = Restore-Pair $lonePng $loneTxt
        Check 'a first capture stopped between the switches is recovered to no files' (-not (Test-Path -LiteralPath $lonePng) -and -not (Test-Path -LiteralPath $loneTxt) -and (Leftovers) -eq 0)

        # An undo cut short after the earlier image came back: finished the same way, the earlier image kept.
        $script:SwitchHook = { 'stop' }
        try { Write-CapturePair $png $newPng $txt $newTxt } finally { $script:SwitchHook = $null }
        [System.IO.File]::Move("$txt.new", "$txt.undo-restore")
        [System.IO.File]::Move("$png.old", $png, $true)
        $null = Restore-Pair $png $txt
        Check 'an undo cut short is finished at the next start, keeping the earlier image' ("$(Hash $png) $(Hash $txt)" -eq $before -and @(Get-ChildItem -LiteralPath $dir -File).Count -eq 2)

        # Two writers to one pair: the second waits for the first and is refused by name when it does not finish in time.
        $holderInfo = [System.Diagnostics.ProcessStartInfo]::new((Get-Process -Id $PID).Path, @('-NoProfile', '-Command', "`$m = [System.Threading.Mutex]::new(`$false, 'Local\ResoluteCapturePair-' + [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes('$($png.ToLowerInvariant())'))).Replace('-', '').Substring(0, 32)); [void]`$m.WaitOne(); [Console]::Out.WriteLine('held'); Start-Sleep -Seconds 20"))
        $holderInfo.RedirectStandardOutput = $true
        $holderInfo.CreateNoWindow = $true
        $holder = [System.Diagnostics.Process]::Start($holderInfo)
        try {
            Start-Sleep -Seconds 3
            $said = $null
            try { $lock = Enter-PairLock $png 500; $lock.ReleaseMutex(); $lock.Dispose() } catch { $said = $_.Exception.Message }
            Check 'a second writer to the same pair is refused by name while the first holds it' ($said -like '*another capture is writing*')
        } finally {
            & taskkill.exe /T /F /PID $holder.Id 2>&1 | Out-Null
            $null = $holder.WaitForExit(10000)
        }
        $lock = Enter-PairLock $png 5000
        Check 'a writer that ended while holding the pair does not block the next' ($null -ne $lock)
        $lock.ReleaseMutex(); $lock.Dispose()

        # A pair proves itself: the sidecar records its image's hash, and a mixed pair is refused.
        $bound = { param($bytes, $label) $enc.GetBytes("capture : $label`nimage sha256  : $([System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([byte[]]$bytes)))`n") }
        Write-CapturePair $png $oldPng $txt (& $bound $oldPng 'old')
        Check 'a written pair verifies' ($null -eq (Test-PairBinding $png))
        $script:SwitchHook = { 'stop' }
        try { Write-CapturePair $png $newPng $txt (& $bound $newPng 'new') } finally { $script:SwitchHook = $null }
        $mixed = Test-PairBinding $png
        Check 'a new image beside the earlier sidecar is refused, naming both hashes' ($mixed -like '*they are not one capture*' -and $mixed -like "*$([System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([byte[]]$newPng)))*")
        $null = Restore-Pair $png $txt
        $before = "$(Hash $png) $(Hash $txt)"
        Check 'an output that is its own sidecar is refused, a .png is not' ((Test-OutPath (Join-Path $dir 'shot.txt')) -like '*would be its own sidecar*' -and $null -eq (Test-OutPath (Join-Path $dir 'shot.png')))
        Set-Content -LiteralPath $txt -Value 'capture : legacy' -NoNewline
        Check 'a sidecar written before pairs were bound is refused as unverifiable' ((Test-PairBinding $png) -like '*records no image sha256*cannot be verified*')
        Write-CapturePair $png $oldPng $txt $oldTxt
        $before = "$(Hash $png) $(Hash $txt)"

        # Through the script itself: -Out shot.txt beside a pair and a recovery leftover touches nothing.
        $clashDir = Join-Path $dir 'clash'
        New-Item -ItemType Directory -Path $clashDir | Out-Null
        foreach ($f in 'shot.png', 'shot.txt', 'shot.txt.new', 'shot.txt.old') { [System.IO.File]::WriteAllBytes((Join-Path $clashDir $f), $enc.GetBytes("kept $f")) }
        $clashState = { @(Get-ChildItem -LiteralPath $clashDir -File | Sort-Object Name | ForEach-Object { "$($_.Name) $(Hash $_.FullName)" }) -join ';' }
        $clashBefore = & $clashState
        $said = & (Get-Process -Id $PID).Path -NoProfile -File $PSCommandPath -ProcessId 999999 -Out (Join-Path $clashDir 'shot.txt') 2>&1 | Out-String
        $clashCode = $LASTEXITCODE
        Check 'the script refuses -Out shot.txt with exit 2 and touches no file, leftovers included' ($clashCode -eq 2 -and $said -like '*would be its own sidecar*' -and (& $clashState) -eq $clashBefore)

        Write-CapturePair $png $newPng $txt $newTxt
        Check 'a replacing write leaves the new pair and no *.new or *.old' ((Leftovers) -eq 0 -and [System.Linq.Enumerable]::SequenceEqual([System.IO.File]::ReadAllBytes($png), $newPng) -and [System.Linq.Enumerable]::SequenceEqual([System.IO.File]::ReadAllBytes($txt), $newTxt))
    } finally {
        Remove-Item -LiteralPath $dir -Recurse -Force
    }

    # The covered-window rule, over window records given to it.
    $frame = @(100, 100, 900, 700)
    $record = { param($l, $t, $r, $b, $procId) [pscustomobject]@{ Visible = $true; Cloaked = $false; Frame = [pscustomobject]@{ Left = $l; Top = $t; Right = $r; Bottom = $b }; Pid = [uint32]$procId; Title = "w$l" } }
    $over = & $record 800 600 1000 800 4242
    $beside = & $record 900 100 1100 700 4242
    $own = & $record 200 200 400 400 7
    $flat = & $record 300 300 300 500 4242
    $table = @{ 1 = $over; 2 = $beside; 3 = $own; 4 = $flat }
    $covering = @(Get-Covering @([IntPtr]1) $frame 7 { param($h) $table[[int]$h] })
    Check 'a window that overlaps the target refuses it, named' ($covering.Count -eq 1 -and $covering[0] -like "*'w800'*pid 4242*")
    Check 'a window beside the target, of no area, or of the target''s own process does not' (@(Get-Covering @([IntPtr]2, [IntPtr]3, [IntPtr]4) $frame 7 { param($h) $table[[int]$h] }).Count -eq 0)
    $said = $null
    try { $null = Get-Covering @([IntPtr]2, [IntPtr]9) $frame 7 { param($h) $table[[int]$h] } } catch { $said = $_.Exception.Message }
    Check 'a window that cannot be read refuses the capture, named' ($said -like '*window 9 could not be read*')
    $here = & $record 100 100 900 700 7
    $hidden = & $record 100 100 900 700 7; $hidden.Visible = $false
    $moved = & $record 140 100 940 700 7
    Check 'a target that is gone, hidden or moved is refused, and one where it was is not' ((Test-Target $null $frame) -like '*gone*' -and (Test-Target $hidden $frame) -like '*no longer visible*' -and (Test-Target $moved $frame) -like '*moved*' -and $null -eq (Test-Target $here $frame))

    # The pair lock is released however the script ends, even run in this process, where exit does not end the thread.
    $lockDir = Join-Path ([System.IO.Path]::GetTempPath()) ("capture-lock-selftest-" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $lockDir | Out-Null
    try {
        $lockPng = Join-Path $lockDir 'lock.png'
        $null = & $PSCommandPath -ProcessId 2147483647 -Out $lockPng *>&1
        $key = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($lockPng.ToLowerInvariant()))).Replace('-', '').Substring(0, 32)
        $probe = [System.Diagnostics.ProcessStartInfo]::new((Get-Process -Id $PID).Path)
        foreach ($a in '-NoProfile', '-Command', "`$m = [System.Threading.Mutex]::new(`$false, 'Local\ResoluteCapturePair-$key'); if (`$m.WaitOne(1000)) { 'free' } else { 'held' }") { $probe.ArgumentList.Add($a) }
        $probe.RedirectStandardOutput = $true
        $probe.CreateNoWindow = $true
        $child = [System.Diagnostics.Process]::Start($probe)
        $answer = $child.StandardOutput.ReadToEnd().Trim()
        $null = $child.WaitForExit(15000)
        Check 'a capture that ended, run in this process, leaves the pair free for another' ($answer -eq 'free')
    } finally {
        Remove-Item -LiteralPath $lockDir -Recurse -Force
    }

    if ($failed.Count) { Write-Host ("self-test: FAIL " + ($failed -join '; ')); return 1 }
    Write-Host 'self-test: all pass'
    return 0
}

if ($SelfTest) { exit (Invoke-SelfTest) }

if ($Verify) {
    $why = Test-PairBinding ([System.IO.Path]::GetFullPath($Verify))
    if ($why) { Write-Host "capture-window: $Verify is not a verified pair: $why" -ForegroundColor Red; exit 1 }
    Write-Host "capture-window: $Verify and its sidecar are one capture" -ForegroundColor Green
    exit 0
}

if (-not $Out) {
    Write-Host "capture-window: give -Out, the PNG to write." -ForegroundColor Red
    exit 2
}
$clash = Test-OutPath $Out
if ($clash) {
    Write-Host "capture-window: refused: $clash" -ForegroundColor Red
    exit 2
}
try {
    $script:PairLock = Enter-PairLock ([System.IO.Path]::GetFullPath($Out))
} catch {
    Write-Host "capture-window: refused: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
function Exit-Capture([int]$Code) {
    # Every way out from here releases the pair: run with & in a shell that
    # stays open, exit does not end the thread that owns the mutex.
    if ($script:PairLock) { $script:PairLock.ReleaseMutex(); $script:PairLock.Dispose(); $script:PairLock = $null }
    exit $Code
}
trap {
    Write-Host "capture-window: $($_.Exception.Message)" -ForegroundColor Red
    Exit-Capture 1
}
$recovered = Restore-Pair ([System.IO.Path]::GetFullPath($Out)) ([System.IO.Path]::ChangeExtension([System.IO.Path]::GetFullPath($Out), '.txt'))
if ($recovered) { Write-Host "capture-window: $recovered ($Out)" -ForegroundColor Yellow }

# Neither given means "enumerate every window and take the first", which can
# foreground and save an unrelated application. Refused before anything is
# enumerated.
if (-not $Path -and -not $WindowTitle -and -not $ProcessId) {
    Write-Host "capture-window: give -Path, -WindowTitle, -ProcessId, or a combination." -ForegroundColor Red
    Write-Host "  Without a target this would capture whichever window came first." -ForegroundColor Red
    Exit-Capture 2
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
    if ($LaunchArgs) { $startArgs['ArgumentList'] = $LaunchArgs }
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
            Exit-Capture 1
        }
    }
}
else {
    $target = Get-Matching -Stem $null | Select-Object -First 1
}

if (-not $target) {
    Write-Host "capture-window: no window found" -ForegroundColor Red
    if ($WindowTitle) { Write-Host "  title filter: '$WindowTitle'" -ForegroundColor Red }
    Exit-Capture 1
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
    Exit-Capture 3
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
    Exit-Capture 1
}
$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top
if ($width -le 0 -or $height -le 0) {
    Write-Host "capture-window: the window has no area ($width x $height)" -ForegroundColor Red
    Stop-Ours
    Exit-Capture 1
}

$targetFrame = @($rect.Left, $rect.Top, $rect.Right, $rect.Bottom)
$targetPid = [uint32]$target.Id
$cover = $null
$script:hidden = $false
function Start-Cover {
    # The drill's covering window: another process's always-on-top window over the target's lower right quarter.
    $l = $rect.Left + [int]($width / 2); $t = $rect.Top + [int]($height / 2)
    # Shown without activation (SWP_NOACTIVATE), so the target keeps the foreground, as an always-on-top overlay does.
    $code = "Add-Type -AssemblyName System.Windows.Forms; Add-Type 'using System; using System.Runtime.InteropServices; public class P { [DllImport(`"user32.dll`")] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int w, int hh, uint f); }'; `$f = New-Object System.Windows.Forms.Form; `$f.Text = 'Resolute capture drill cover'; `$f.ShowInTaskbar = `$false; `$f.FormBorderStyle = 'None'; `$f.BackColor = 'Magenta'; [void][P]::SetWindowPos(`$f.Handle, [IntPtr](-1), $l, $t, $([int]($width / 3)), $([int]($height / 3)), 0x0050); `$end = (Get-Date).AddSeconds(60); while ((Get-Date) -lt `$end) { [System.Windows.Forms.Application]::DoEvents(); Start-Sleep -Milliseconds 50 }"
    $info = [System.Diagnostics.ProcessStartInfo]::new((Get-Process -Id $PID).Path)
    foreach ($a in '-NoProfile', '-Command', $code) { $info.ArgumentList.Add($a) }
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $proc = [System.Diagnostics.Process]::Start($info)
    $deadline = (Get-Date).AddSeconds(20)
    while ((Get-Date) -lt $deadline -and [ZOrder]::FindWindowW($null, 'Resolute capture drill cover') -eq [IntPtr]::Zero) { Start-Sleep -Milliseconds 100 }
    Start-Sleep -Milliseconds 300
    Write-Host "drill: a covering window of process $($proc.Id) is over the target ($DrillCoverAt)"
    return $proc
}
function Stop-Cover { if ($script:cover -and -not $script:cover.HasExited) { & taskkill.exe /T /F /PID $script:cover.Id 2>&1 | Out-Null; $null = $script:cover.WaitForExit(10000) } }
if ($DrillCoverAt -eq 'before') { $script:cover = Start-Cover }
try {
    $refusal = Assert-Uncovered $hwnd $targetFrame $targetPid 'before'
    if ($refusal) { Write-Host $refusal -ForegroundColor Red; Stop-Ours; Exit-Capture 3 }
    if ($DrillCoverAt -eq 'between') { $script:cover = Start-Cover }
    if ($DrillCoverAt -eq 'hide') { [void][Win32Capture]::ShowWindow($hwnd, 0); $script:hidden = $true; Start-Sleep -Milliseconds 700; Write-Host 'drill: the target was hidden between the checks' }
    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
    $graphics.Dispose()
    # A window that arrived while the copy was made is in the copy: checked again before anything is written.
    $refusal = Assert-Uncovered $hwnd $targetFrame $targetPid 'after'
    if ($refusal) { $bitmap.Dispose(); Write-Host $refusal -ForegroundColor Red; Stop-Ours; Exit-Capture 3 }
} finally {
    Stop-Cover
    if ($script:hidden) { [void][Win32Capture]::ShowWindow($hwnd, 5) }   # the drill's hidden target is shown again
}

$outDir = Split-Path $Out -Parent
if ($outDir -and -not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
$encoded = [System.IO.MemoryStream]::new()
$bitmap.Save($encoded, [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()
$imageBytes = $encoded.ToArray()
$encoded.Dispose()

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
$sidecarLines = @(
    "capture       : $(Split-Path $Out -Leaf)"
    "image sha256  : $([System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($imageBytes)))"
    "describes     : $Describes"
    "window title  : $($target.MainWindowTitle)"
    "target process: $($target.Id) $(if ($target.Path) { $target.Path } else { '(path unavailable)' })"
    "attached      : $(if ($ours) { 'started by this invocation' } else { 'attached to a process the caller started and owns' })"
    "source binary : $sourcePath"
    "file version  : $(if ($sourcePath -and (Test-Path $sourcePath)) { (Get-Item $sourcePath).VersionInfo.FileVersion } else { 'unknown' })"
    "size          : $width x $height px"
    "monitor dpi   : $monX  ($([math]::Round($monX / 96.0 * 100))% scaling) -- what the image was rendered at"
    "window dpi    : $windowDpi  (logical dpi the process sees)"
    "dpi aware     : $dpiAware$(if (-not $dpiAware) { '  -- Windows bitmap-scales this window' })"
    "appearance    : $appearanceLine"
    "fixture       : $(if ($Fixture) { $Fixture } else { 'none stated' })"
    "launch context: $(if ($LaunchContext) { $LaunchContext } else { '(not stated)' })"
    "fixture files : $(if ($FixtureFiles) { $FixtureFiles } else { '(not stated)' })"
    "launch args   : $(if ($LaunchArgs) { $LaunchArgs } elseif ($Path) { '(none)' } else { 'attached to a running process' })"
    "working dir   : $(if ($WorkingDirectory) { $WorkingDirectory } else { '(default)' })"
    "locale        : $((Get-Culture).Name) / UI $((Get-UICulture).Name)"
    "geometry      : $($rect.Left),$($rect.Top) ${width}x${height}"
    "exe sha256    : $(if ($sourcePath -and (Test-Path $sourcePath)) { (Get-FileHash $sourcePath -Algorithm SHA256).Hash } else { 'unknown' })"
    "source revision: $(try { (git -C (Split-Path $PSScriptRoot -Parent) rev-parse HEAD 2>$null) } catch { 'unknown' })"
    "windows build : $([System.Environment]::OSVersion.Version.ToString())"
    "captured      : $(Get-Date -Format 'yyyy-MM-dd')"
    ""
    "Reproduce with scripts/capture-window.ps1. Where this capture and"
    "DESIGN.md disagree, the contract wins and this capture is restaked."
)
# The same bytes Set-Content -Encoding UTF8 wrote before: UTF-8 without a BOM, CRLF line ends, one after the last line.
$sidecarBytes = [System.Text.UTF8Encoding]::new($false).GetBytes((($sidecarLines | ForEach-Object { "$_" }) -join "`r`n") + "`r`n")
try {
    Write-CapturePair ([System.IO.Path]::GetFullPath($Out)) $imageBytes ([System.IO.Path]::GetFullPath($sidecar)) $sidecarBytes
} catch {
    Write-Host "capture-window: $($_.Exception.Message)" -ForegroundColor Red
    Stop-Ours
    Exit-Capture 1
}

Write-Host ("captured {0}  {1}x{2}  monitor {3} dpi, window {4} dpi, aware={5}" -f `
    (Split-Path $Out -Leaf), $width, $height, $monX, $windowDpi, $dpiAware) -ForegroundColor Green

Stop-Ours
Exit-Capture 0
