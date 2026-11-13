<#
.SYNOPSIS
    The private, authoring-only MySQL server for reference data (D00 T06 section 1).

.DESCRIPTION
    -Install   download the pinned server named in server.json, verify its SHA-256, and unpack it into reskit/mysql
    -Start     start the private server on 127.0.0.1 (initializing its data on first use)
    -Status    say whether the private server this script started is running
    -Stop      stop the private server this script started

    Its data lives in %LOCALAPPDATA%\Resolute\refdata\server, outside the repository and outside build/, which is
    derived and may be wiped. On first start the root account gets a generated password, written only to
    %LOCALAPPDATA%\Resolute\refdata\local.cnf, a MySQL option file readable by this account alone; clients read it with
    --defaults-extra-file and no password is ever an argument or printed. An author who uses a shared server writes
    client.cnf beside it instead; this script never writes or reads client.cnf.

    -Start, -Status and -Stop act only on the process this script recorded when it started it (its id and image
    path), so a MySQL server that belongs to something else is never touched.

    Nothing here runs on CI or on a user's machine.
#>
param(
    [switch]$Install,
    [switch]$Start,
    [switch]$Stop,
    [switch]$Status,
    [int]$Port = 33061,
    [string]$Manifest = (Join-Path $PSScriptRoot 'server.json'),
    [string]$From = '',   # with -Install: a local copy of the archive, verified against the pin like a download
    [int]$StartTimeoutSeconds = 90,
    # Where the server's data and option files live; a drill points this at a folder of its own.
    [string]$HomeDir = (Join-Path $env:LOCALAPPDATA 'Resolute\refdata'),
    # A drill: a first start stops after the server answers and before root's password is set, as an
    # interrupted start would, so the next -Start is shown to finish the credentials.
    [switch]$DrillStopAfterInit,
    # A drill: a first start ends initialization part way, as a closed window or a power cut would, so the next
    # -Start is shown to discard what it left and initialize cleanly.
    [switch]$DrillStopDuringInit,
    # Check the option-file writer without a server.
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$InstallDir = Join-Path $RepoRoot 'reskit\mysql'
$Home_ = $HomeDir
$ServerDir = Join-Path $Home_ 'server'
$DataDir = Join-Path $ServerDir 'data'
# Initialization runs into the staging folder, and the mark is written before the staging folder becomes the data
# folder, so a data folder beside the mark is always one whose initialization finished. A cut-short initialization
# leaves only the staging folder, which the next start discards.
$Staging = Join-Path $ServerDir 'data.staging'
$Initialized = Join-Path $ServerDir 'data.initialized'
$StateFile = Join-Path $ServerDir 'state.json'
$IniFile = Join-Path $ServerDir 'my.ini'
$LocalCnf = Join-Path $Home_ 'local.cnf'
# Root's credentials are set in steps a start can be cut between: the marker
# exists from before the data is initialized until the generated password is
# set and local.cnf holds it, and the password is written to the pending
# option file before it is set, so it is never lost.
$Pending = Join-Path $ServerDir 'credentials.pending'
$PendingCnf = "$LocalCnf.pending"
$Mysqld = Join-Path $InstallDir 'bin\mysqld.exe'
$Admin = Join-Path $InstallDir 'bin\mysqladmin.exe'
$Client = Join-Path $InstallDir 'bin\mysql.exe'

function Say([string]$Text) { Write-Host "server: $Text" }

# The server outlives this script, so it must hold nothing of the caller's:
# Process.Start passes every inheritable handle on, the pipes a caller reads
# this script's output through included, and a server holding them keeps the
# caller waiting for an end of output that never comes. CreateProcess with
# handle inheritance off, and no console window.
Add-Type @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
public static class Daemon {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct STARTUPINFO { public int cb; public string reserved, desktop, title; public int x, y, w, h, xc, yc, fill, flags; public short show, r2; public IntPtr r3, stdin, stdout, stderr; }
    [StructLayout(LayoutKind.Sequential)] struct PROCESS_INFORMATION { public IntPtr process, thread; public int pid, tid; }
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern bool CreateProcessW(string app, System.Text.StringBuilder cmd, IntPtr pa, IntPtr ta, bool inherit, uint flags, IntPtr env, string dir, ref STARTUPINFO si, out PROCESS_INFORMATION pi);
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
    public static int Start(string app, string commandLine) {
        var si = new STARTUPINFO(); si.cb = Marshal.SizeOf(si);
        PROCESS_INFORMATION pi;
        const uint CREATE_NO_WINDOW = 0x08000000;
        if (!CreateProcessW(app, new System.Text.StringBuilder(commandLine), IntPtr.Zero, IntPtr.Zero, false, CREATE_NO_WINDOW, IntPtr.Zero, null, ref si, out pi))
            throw new Win32Exception(Marshal.GetLastWin32Error());
        CloseHandle(pi.thread); CloseHandle(pi.process);
        return pi.pid;
    }
}
'@

function Read-Pin {
    $pin = Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json
    foreach ($field in 'version', 'url', 'sha256', 'archiveFolder', 'probe', 'versionMatch') {
        if (-not $pin.$field) { throw "the manifest $Manifest has no '$field'" }
    }
    return $pin
}

function Get-InstalledVersion {
    if (-not (Test-Path -LiteralPath $Mysqld)) { return $null }
    $said = (& $Mysqld --version 2>&1 | Out-String).Trim()
    return $said
}

function Protect-Home {
    # The folder that holds the option files and the data: this account and SYSTEM only.
    New-Item -ItemType Directory -Force -Path $Home_ | Out-Null
    $acl = New-Object Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    $me = [Security.Principal.WindowsIdentity]::GetCurrent().User
    foreach ($sid in $me, (New-Object Security.Principal.SecurityIdentifier('S-1-5-18'))) {
        $acl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule($sid, 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow')))
    }
    # Only the access list is written: Set-Acl writes the whole descriptor,
    # audit list included, which needs SeSecurityPrivilege once the folder exists.
    [System.IO.FileSystemAclExtensions]::SetAccessControl([System.IO.DirectoryInfo]::new($Home_), $acl)
}

function Invoke-Install {
    $pin = Read-Pin
    $have = Get-InstalledVersion
    if ($have -and $have -match $pin.versionMatch) { Say "already pinned: $have"; return 0 }
    $work = Join-Path ([IO.Path]::GetTempPath()) ("resolute-refdata-" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $work | Out-Null
    try {
        $zip = Join-Path $work 'server.zip'
        if ($From) {
            Say "installing MySQL $($pin.version) from $From"
            Copy-Item -LiteralPath $From -Destination $zip
        } else {
            # The system's curl: MySQL's download redirector answers PowerShell's web client with an error page.
            Say "downloading MySQL $($pin.version) ($($pin.bytes) bytes)"
            & (Join-Path $env:SystemRoot 'System32\curl.exe') -sSfL -o $zip $pin.url
            if ($LASTEXITCODE -ne 0) { Say "refused: the download from $($pin.url) failed (curl exit $LASTEXITCODE); nothing was installed"; return 2 }
        }
        $got = (Get-FileHash -Algorithm SHA256 -LiteralPath $zip).Hash.ToLowerInvariant()
        if ($got -ne $pin.sha256.ToLowerInvariant()) {
            Say "refused: the download's SHA-256 is $got, the pin says $($pin.sha256); nothing was installed"
            return 2
        }
        Say 'hash verified; unpacking'
        $unpacked = Join-Path $work 'unpacked'
        Expand-Archive -LiteralPath $zip -DestinationPath $unpacked
        $inner = Join-Path $unpacked $pin.archiveFolder
        if (-not (Test-Path -LiteralPath (Join-Path $inner $pin.probe))) { Say "refused: the archive has no $($pin.archiveFolder)/$($pin.probe); nothing was installed"; return 2 }
        $staged = "$InstallDir.new"
        if (Test-Path -LiteralPath $staged) { Remove-Item -LiteralPath $staged -Recurse -Force }
        Move-Item -LiteralPath $inner -Destination $staged
        if (Test-Path -LiteralPath $InstallDir) { Remove-Item -LiteralPath $InstallDir -Recurse -Force }
        Move-Item -LiteralPath $staged -Destination $InstallDir
        $have = Get-InstalledVersion
        if (-not ($have -match $pin.versionMatch)) { Say "refused: the installed server reports '$have', not $($pin.version)"; return 2 }
        Say "installed: $have"
        return 0
    } finally {
        Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue  # a temporary download folder; leftovers are only disk space
    }
}

function Read-State {
    if (-not (Test-Path -LiteralPath $StateFile -PathType Leaf)) { return $null }
    return (Get-Content -LiteralPath $StateFile -Raw | ConvertFrom-Json)
}

function Get-OwnedProcess {
    # The process this script started, if it is still that process: same id and the same image path.
    $state = Read-State
    if (-not $state) { return $null }
    $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $([int]$state.pid)" -ErrorAction SilentlyContinue  # none is the answer "not running"
    if (-not $proc) { return $null }
    if ($proc.ExecutablePath -ne $state.path) { return $null }
    return $proc
}

function Test-Answers([int]$OnPort) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    # The port is given here, ahead of the option file's, so a start on a new port is checked before the file changes.
    Push-Location -LiteralPath (Split-Path $LocalCnf)
    try { & $Admin "--defaults-extra-file=$(Split-Path $LocalCnf -Leaf)" "--port=$OnPort" --connect-timeout=2 ping 2>&1 | Out-Null } finally { Pop-Location }
    $ok = ($LASTEXITCODE -eq 0)
    $ErrorActionPreference = $prev
    return $ok
}

function Test-PortFree([int]$OnPort) {
    # Whether the server could bind 127.0.0.1:$OnPort: asked by binding it
    # exclusively and letting go at once. The connection table is no answer:
    # Get-NetTCPConnection listed nothing for a listener that held the port
    # (measured 2026-11-13).
    $probe = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $OnPort)
    $probe.ExclusiveAddressUse = $true
    try { $probe.Start(); return $true } catch [System.Net.Sockets.SocketException] { return $false } finally { $probe.Stop() }
}

function New-Password {
    $bytes = New-Object byte[] 24
    [Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    return ([Convert]::ToBase64String($bytes) -replace '[+/=]', 'x')
}

function Write-Ini([int]$OnPort) {
    $base = $InstallDir.Replace('\', '/')
    $data = $DataDir.Replace('\', '/')
    $log = (Join-Path $ServerDir 'mysqld.log').Replace('\', '/')
    Write-OptionFile $IniFile @(
        '[mysqld]', "basedir=$base", "datadir=$data", "port=$OnPort", 'bind-address=127.0.0.1', 'mysqlx=OFF', "log-error=$log"
    )
}

$script:BeforeReplace = $null   # the self-test's stand-in for a write cut short before the replace

function Get-OptionEncoding {
    # The system ANSI code page (GetACP), strict: an unmappable character throws instead of becoming '?'.
    if (-not ('AnsiCodePage' -as [type])) {
        Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public static class AnsiCodePage { [DllImport("kernel32.dll")] public static extern uint GetACP(); }'
    }
    [System.Text.Encoding]::RegisterProvider([System.Text.CodePagesEncodingProvider]::Instance)
    return [System.Text.Encoding]::GetEncoding([int][AnsiCodePage]::GetACP(), [System.Text.EncoderFallback]::ExceptionFallback, [System.Text.DecoderFallback]::ExceptionFallback)
}

function Write-OptionFile([string]$Path, [string[]]$Lines) {
    # A file that may hold the only copy of root's password is never
    # truncated in place: the new text goes to a sibling file, is read back,
    # and replaces the old one in one step. Cut short anywhere, the old file
    # is whole.
    $temp = "$Path.writing"
    # In the system's ANSI code page, which is how mysqld and mysql read an option file on Windows (measured
    # 2026-11-13: ASCII turned R:\...\Référence into R?f?rence, and UTF-8 bytes were read as RÃ©fÃ©rence; either way
    # initialization failed). A line the code page cannot hold is refused by name rather than written wrong.
    $text = ($Lines -join "`r`n") + "`r`n"
    $encoding = Get-OptionEncoding
    try {
        $bytes = $encoding.GetBytes($text)
    } catch [System.Text.EncoderFallbackException] {
        throw "$Path would hold characters the system code page ($($encoding.CodePage)) cannot, and MySQL reads its option files in that code page; choose a -HomeDir whose path it can hold"
    }
    try {
        [System.IO.File]::WriteAllBytes($temp, $bytes)
        if (-not [System.Linq.Enumerable]::SequenceEqual([System.IO.File]::ReadAllBytes($temp), $bytes)) { throw "$temp read back differently from what was written" }
        if ($script:BeforeReplace) { & $script:BeforeReplace }
        [System.IO.File]::Move($temp, $Path, $true)
    } finally {
        if (Test-Path -LiteralPath $temp) { [System.IO.File]::Delete($temp) }
    }
}

function Invoke-SelfTest {
    $failed = @()
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("refdata-server-selftest-" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $dir | Out-Null
    try {
        $file = Join-Path $dir 'local.cnf'
        Write-OptionFile $file @('[client]', 'password=first')
        $ok = (Get-Content -LiteralPath $file) -contains 'password=first'
        Write-Host "$(if ($ok) { 'PASS' } else { 'FAIL' }) an option file is written whole"; if (-not $ok) { $failed += 'written' }
        $script:BeforeReplace = { throw 'cut short before the replace' }
        try { Write-OptionFile $file @('[client]', 'password=second') } catch { $null = $_ } finally { $script:BeforeReplace = $null }
        $ok = ((Get-Content -LiteralPath $file) -contains 'password=first') -and -not (Test-Path -LiteralPath "$file.writing")
        Write-Host "$(if ($ok) { 'PASS' } else { 'FAIL' }) a write cut short leaves the old file whole, and no partial file"; if (-not $ok) { $failed += 'cut short' }
        Write-OptionFile $file @('[client]', 'password=third')
        $ok = ((Get-Content -LiteralPath $file) -contains 'password=third') -and -not (Test-Path -LiteralPath "$file.writing")
        Write-Host "$(if ($ok) { 'PASS' } else { 'FAIL' }) a replacing write leaves only the new file"; if (-not $ok) { $failed += 'replace' }
    } finally {
        Remove-Item -LiteralPath $dir -Recurse -Force
    }
    if ($failed) { Write-Host "self-test: FAIL $($failed -join ', ')"; return 1 }
    Write-Host 'self-test: all pass'
    return 0
}

function Write-LocalCnf([int]$OnPort, [string]$Password) {
    # Written once, readable by this account alone (the folder's ACL), and never printed.
    Write-OptionFile $LocalCnf @('[client]', 'user=root', "password=$Password", 'host=127.0.0.1', "port=$OnPort")
}

function Invoke-Sql([string]$Options, [string]$Sql, [string[]]$Extra = @()) {
    # Exit code of the client running $Sql; nothing it prints is shown, so no secret can be.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    # The option file by its name from its own folder: the mysql client could not open a --defaults-extra-file path
    # holding a character such as é (measured 2026-11-13), and a Windows profile folder may hold one.
    Push-Location -LiteralPath (Split-Path $Options)
    try { $Sql | & $Client "--defaults-extra-file=$(Split-Path $Options -Leaf)" --connect-timeout=5 --batch @Extra 2>&1 | Out-Null } finally { Pop-Location }
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    return $code
}

function Test-RootOpen([int]$OnPort) {
    # True when root logs in with no password at all: the state no start may report as running.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    'SELECT 1;' | & $Client --no-defaults --user=root --host=127.0.0.1 "--port=$OnPort" --skip-password --connect-timeout=5 --batch 2>&1 | Out-Null
    $open = ($LASTEXITCODE -eq 0)
    $ErrorActionPreference = $prev
    return $open
}

function Complete-Credentials([int]$OnPort) {
    # Finishes what the marker says is unfinished; returns $null or the refusal.
    if (-not (Test-Path -LiteralPath $Pending)) { return $null }
    if (-not (Test-Path -LiteralPath $PendingCnf)) {
        Write-OptionFile $PendingCnf @('[client]', 'user=root', "password=$(New-Password)", 'host=127.0.0.1', "port=$OnPort")
    }
    if ((Invoke-Sql $PendingCnf 'SELECT 1;' @("--port=$OnPort")) -ne 0) {
        # Not set yet: set it, as the passwordless root the marker says it still is.
        $password = ((Get-Content -LiteralPath $PendingCnf | Where-Object { $_ -like 'password=*' }) -replace '^password=', '')
        if ((Invoke-Sql $LocalCnf "ALTER USER 'root'@'localhost' IDENTIFIED BY '$password';" @("--port=$OnPort")) -ne 0) {
            return 'the generated password could not be set: root accepts neither no password nor the pending one'
        }
    }
    [System.IO.File]::Move($PendingCnf, $LocalCnf, $true)
    Remove-Item -LiteralPath $Pending -Force
    Say "a generated root password was written to $LocalCnf (not shown)"
    return $null
}

function Stop-Started([System.Diagnostics.Process]$Proc) {
    # Ends the server this start launched and forgets it. A server an earlier
    # start launched ($Proc is $null) is left running and its record kept, so
    # -Status and -Stop still find it.
    if (-not $Proc) { return }
    if (-not $Proc.HasExited) { $Proc.Kill($true); $null = $Proc.WaitForExit(10000) }
    if ($Proc.HasExited -and (Test-Path -LiteralPath $StateFile)) { Remove-Item -LiteralPath $StateFile -Force }
}

function Invoke-Start {
    if (-not (Test-Path -LiteralPath $Mysqld)) { Say 'refused: the server is not installed (run tools/refdata/server.ps1 -Install)'; return 2 }
    # Before anything is made: every path the option files will hold must survive the code page MySQL reads them in.
    try { $null = (Get-OptionEncoding).GetBytes("$Home_|$InstallDir") } catch [System.Text.EncoderFallbackException] {
        Say "refused: $Home_ holds characters the system code page ($((Get-OptionEncoding).CodePage)) cannot, and MySQL reads its option files in that code page; choose a -HomeDir whose path it can hold. Nothing was created"
        return 2
    }
    $owned = Get-OwnedProcess
    $proc = $null
    if ($owned) {
        $port = [int](Read-State).port
    } else {
        $port = $Port
        if (-not (Test-PortFree $port)) { Say "refused: port $port on 127.0.0.1 is held by another listener; it was left alone. Choose another with -Port"; return 2 }
        Protect-Home
        New-Item -ItemType Directory -Force -Path $ServerDir | Out-Null
        Write-Ini $port
        $adopt = $false
        if (-not (Test-Path -LiteralPath $DataDir)) {
            if (Test-Path -LiteralPath $Staging) {
                # Only an initialization that did not finish leaves this; it never held data.
                Say 'discarding an initialization that did not finish'
                Remove-Item -LiteralPath $Staging -Recurse -Force
            }
            # The marker first: from here until the password is set, any start finishes the credentials.
            Set-Content -LiteralPath $Pending -Encoding ascii -Value 'root has no password yet'
            Say 'initializing the data directory'
            $init = [System.Diagnostics.ProcessStartInfo]::new($Mysqld)
            foreach ($a in "--defaults-file=$IniFile", "--datadir=$Staging", '--initialize-insecure') { $init.ArgumentList.Add($a) }
            $init.UseShellExecute = $false
            $init.CreateNoWindow = $true
            $initProc = [System.Diagnostics.Process]::Start($init)
            if ($DrillStopDuringInit) {
                Start-Sleep -Milliseconds 1500
                if (-not $initProc.HasExited) { $initProc.Kill($true) }
                $null = $initProc.WaitForExit(30000)
                Say 'drill: initialization was ended part way'
                return 3
            }
            $initProc.WaitForExit()
            if ($initProc.ExitCode -ne 0) { Say "refused: initialization failed (exit $($initProc.ExitCode); see $(Join-Path $ServerDir 'mysqld.log')); the next -Start begins it again"; return 2 }
            Set-Content -LiteralPath $Initialized -Encoding ascii -Value "initialized $((Get-Date).ToUniversalTime().ToString('o'))"
            Move-Item -LiteralPath $Staging -Destination $DataDir
            # Until the generated password is set, root has none: a client file without one reaches it.
            Write-OptionFile $LocalCnf @('[client]', 'user=root', 'host=127.0.0.1', "port=$port")
        } elseif (-not (Test-Path -LiteralPath $Initialized)) {
            # A data folder an earlier version of this script made, initializing in place: it wrote the credentials
            # marker before initializing and the client file only once initialization had finished. With the marker
            # and no client file, initialization may have been cut short, and nothing can tell a whole folder from a
            # partial one without starting a server on it, which could change it.
            if ((Test-Path -LiteralPath $Pending) -and -not (Test-Path -LiteralPath $LocalCnf)) {
                Say "refused: $DataDir was left by an initialization that may not have finished (an earlier version of this script made it, and its first start never wrote $LocalCnf); nothing was changed or deleted. Move the folder aside and -Start initializes a new one"
                return 2
            }
            $adopt = $true
        }
        $proc = Get-Process -Id ([Daemon]::Start($Mysqld, "`"$Mysqld`" `"--defaults-file=$IniFile`""))
        try {
            @{ pid = $proc.Id; path = $Mysqld; port = $port; started = (Get-Date).ToUniversalTime().ToString('o') } | ConvertTo-Json | Set-Content -LiteralPath $StateFile -Encoding utf8
        } catch {
            # Without the record no -Stop or -Status can find this server, so it is not left running.
            if (-not $proc.HasExited) { $proc.Kill($true); $null = $proc.WaitForExit(10000) }
            Say "refused: the process record $StateFile could not be written ($($_.Exception.Message)); the server this start launched was ended"
            return 2
        }
        $deadline = (Get-Date).AddSeconds($StartTimeoutSeconds)
        while (-not (Test-Answers $port)) {
            if ($proc.HasExited -or (Get-Date) -gt $deadline) {
                $why = if ($proc.HasExited) { "the server exited as it started (exit $($proc.ExitCode))" } else { "the server did not answer within ${StartTimeoutSeconds}s and was ended" }
                Stop-Started $proc
                Say "refused: $why (see $(Join-Path $ServerDir 'mysqld.log'))"
                return 2
            }
            Start-Sleep -Milliseconds 500
        }
        if ($adopt) {
            Set-Content -LiteralPath $Initialized -Encoding ascii -Value "adopted $((Get-Date).ToUniversalTime().ToString('o')): made by an earlier version of this script"
            Say "adopted $DataDir, which an earlier version of this script initialized"
        }
    }
    if ($DrillStopAfterInit -and (Test-Path -LiteralPath $Pending)) {
        Say 'drill: stopped after the server answered and before root''s password was set'
        return 3
    }
    $unfinished = Complete-Credentials $port
    if ($unfinished) { Stop-Started $proc; Say "refused: $unfinished; the server was not left running for it"; return 2 }
    if (-not $owned) {
        # The server answers on this port, so clients are pointed at it now, not before.
        $lines = @(Get-Content -LiteralPath $LocalCnf) | ForEach-Object { if ($_ -match '^port=') { "port=$port" } else { $_ } }
        Write-OptionFile $LocalCnf $lines
    }
    # Every start, already running or not, ends only on a server that refuses a passwordless root and accepts local.cnf.
    if (Test-RootOpen $port) {
        Stop-Started $proc
        Say "refused: root on 127.0.0.1:$port accepts no password; $(if ($proc) { 'the server was stopped' } else { 'stop it with -Stop and start it again to set one' })"
        return 2
    }
    if ((Invoke-Sql $LocalCnf 'SELECT 1;' @("--port=$port")) -ne 0) {
        Stop-Started $proc
        Say "refused: $LocalCnf does not authenticate to 127.0.0.1:$port"
        return 2
    }
    if ($owned) { Say "already running: pid $($owned.ProcessId) on 127.0.0.1:$port, root needs its password"; return 0 }
    Say "running: pid $($proc.Id) on 127.0.0.1:$port, root needs its password"
    return 0
}

function Invoke-Status {
    $owned = Get-OwnedProcess
    if (-not $owned) { Say 'not running'; return 1 }
    $port = (Read-State).port
    if (Test-Answers $port) { Say "running: pid $($owned.ProcessId) on 127.0.0.1:$port, answering"; return 0 }
    Say "running: pid $($owned.ProcessId), but not answering on 127.0.0.1:$port"
    return 2
}

function Invoke-Stop {
    $owned = Get-OwnedProcess
    if (-not $owned) {
        Remove-Item -LiteralPath $StateFile -Force -ErrorAction SilentlyContinue  # a record of a process that is not ours or not there
        Say 'was not running'
        return 0
    }
    Push-Location -LiteralPath (Split-Path $LocalCnf)
    try { & $Admin "--defaults-extra-file=$(Split-Path $LocalCnf -Leaf)" shutdown 2>&1 | Out-Null } finally { Pop-Location }
    $proc = Get-Process -Id $owned.ProcessId -ErrorAction SilentlyContinue  # gone already is the outcome wanted
    if ($proc -and -not $proc.WaitForExit(30000)) { $proc.Kill($true); $null = $proc.WaitForExit(10000) }
    Remove-Item -LiteralPath $StateFile -Force
    Say "stopped: pid $($owned.ProcessId)"
    return 0
}

if ($SelfTest) { exit (Invoke-SelfTest) }
$modes = @($Install, $Start, $Stop, $Status) | Where-Object { $_ }
if ($modes.Count -ne 1) { Write-Host 'usage: server.ps1 -Install | -Start | -Status | -Stop [-Port N]'; exit 2 }
if ($Install) { exit (Invoke-Install) }
if ($Start) { exit (Invoke-Start) }
if ($Status) { exit (Invoke-Status) }
if ($Stop) { exit (Invoke-Stop) }
