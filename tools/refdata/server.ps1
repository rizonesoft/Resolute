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
    [int]$StartTimeoutSeconds = 90
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$InstallDir = Join-Path $RepoRoot 'reskit\mysql'
$Home_ = Join-Path $env:LOCALAPPDATA 'Resolute\refdata'
$ServerDir = Join-Path $Home_ 'server'
$DataDir = Join-Path $ServerDir 'data'
$StateFile = Join-Path $ServerDir 'state.json'
$IniFile = Join-Path $ServerDir 'my.ini'
$LocalCnf = Join-Path $Home_ 'local.cnf'
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
    if (-not (Test-Path -LiteralPath $StateFile)) { return $null }
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
    & $Admin "--defaults-extra-file=$LocalCnf" "--port=$OnPort" --connect-timeout=2 ping 2>&1 | Out-Null
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
    Set-Content -LiteralPath $IniFile -Encoding ascii -Value @(
        '[mysqld]', "basedir=$base", "datadir=$data", "port=$OnPort", 'bind-address=127.0.0.1', 'mysqlx=OFF', "log-error=$log"
    )
}

function Write-LocalCnf([int]$OnPort, [string]$Password) {
    # Written once, readable by this account alone (the folder's ACL), and never printed.
    Set-Content -LiteralPath $LocalCnf -Encoding ascii -Value @('[client]', 'user=root', "password=$Password", 'host=127.0.0.1', "port=$OnPort")
}

function Invoke-Start {
    if (-not (Test-Path -LiteralPath $Mysqld)) { Say 'refused: the server is not installed (run tools/refdata/server.ps1 -Install)'; return 2 }
    $owned = Get-OwnedProcess
    if ($owned) { Say "already running: pid $($owned.ProcessId) on 127.0.0.1:$((Read-State).port)"; return 0 }
    if (-not (Test-PortFree $Port)) { Say "refused: port $Port on 127.0.0.1 is held by another listener; it was left alone. Choose another with -Port"; return 2 }
    Protect-Home
    New-Item -ItemType Directory -Force -Path $ServerDir | Out-Null
    Write-Ini $Port
    $fresh = -not (Test-Path -LiteralPath $DataDir)
    if ($fresh) {
        Say 'initializing the data directory'
        & $Mysqld "--defaults-file=$IniFile" --initialize-insecure 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { Say "refused: initialization failed (see $(Join-Path $ServerDir 'mysqld.log'))"; return 2 }
    }
    $proc = Get-Process -Id ([Daemon]::Start($Mysqld, "`"$Mysqld`" `"--defaults-file=$IniFile`""))
    @{ pid = $proc.Id; path = $Mysqld; port = $Port; started = (Get-Date).ToUniversalTime().ToString('o') } | ConvertTo-Json | Set-Content -LiteralPath $StateFile -Encoding utf8
    if ($fresh) {
        # Until the generated password is set, root has none: a client file without one reaches it.
        Set-Content -LiteralPath $LocalCnf -Encoding ascii -Value @('[client]', 'user=root', 'host=127.0.0.1', "port=$Port")
    }
    $deadline = (Get-Date).AddSeconds($StartTimeoutSeconds)
    while (-not (Test-Answers $Port)) {
        if ($proc.HasExited -or (Get-Date) -gt $deadline) {
            $why = if ($proc.HasExited) { "the server exited as it started (exit $($proc.ExitCode))" } else { $proc.Kill($true); "the server did not answer within ${StartTimeoutSeconds}s and was ended" }
            Remove-Item -LiteralPath $StateFile -Force
            Say "refused: $why (see $(Join-Path $ServerDir 'mysqld.log'))"
            return 2
        }
        Start-Sleep -Milliseconds 500
    }
    if ($fresh) {
        $password = New-Password
        "ALTER USER 'root'@'localhost' IDENTIFIED BY '$password';" | & $Client "--defaults-extra-file=$LocalCnf" --batch 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { Say 'refused: the generated password could not be set'; return 2 }
        Write-LocalCnf $Port $password
        Say "a generated root password was written to $LocalCnf (not shown)"
    } else {
        # The server answers on this port, so clients are pointed at it now, not before.
        $lines = @(Get-Content -LiteralPath $LocalCnf) | ForEach-Object { if ($_ -match '^port=') { "port=$Port" } else { $_ } }
        Set-Content -LiteralPath $LocalCnf -Encoding ascii -Value $lines
    }
    Say "running: pid $($proc.Id) on 127.0.0.1:$Port"
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
    & $Admin "--defaults-extra-file=$LocalCnf" shutdown 2>&1 | Out-Null
    $proc = Get-Process -Id $owned.ProcessId -ErrorAction SilentlyContinue  # gone already is the outcome wanted
    if ($proc -and -not $proc.WaitForExit(30000)) { $proc.Kill($true); $null = $proc.WaitForExit(10000) }
    Remove-Item -LiteralPath $StateFile -Force
    Say "stopped: pid $($owned.ProcessId)"
    return 0
}

$modes = @($Install, $Start, $Stop, $Status) | Where-Object { $_ }
if ($modes.Count -ne 1) { Write-Host 'usage: server.ps1 -Install | -Start | -Status | -Stop [-Port N]'; exit 2 }
if ($Install) { exit (Invoke-Install) }
if ($Start) { exit (Invoke-Start) }
if ($Status) { exit (Invoke-Status) }
if ($Stop) { exit (Invoke-Stop) }
