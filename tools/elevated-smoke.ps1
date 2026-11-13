# tools/elevated-smoke.ps1 -- unattended elevated smoke via one consented task (D07 T01 S7)
#
# Usage:
#   pwsh tools/elevated-smoke.ps1 -Register [-Replace]  register \Resolute\ElevatedSmoke (one UAC prompt)
#   pwsh tools/elevated-smoke.ps1 -Run                  start it, wait, and validate the fresh report (no prompt)
#   pwsh tools/elevated-smoke.ps1 -Remove               stop if running, unregister, prove absence
#   pwsh tools/elevated-smoke.ps1 -SelfTest             windowless contract tests; touches no task but a throwaway of its own
#   pwsh tools/elevated-smoke.ps1 -Check                would -Run be refused? starts nothing, changes nothing
#   pwsh tools/elevated-smoke.ps1 -Readback             print what the trust boundary rests on, as it is now
#
# Trust boundary: nothing the task runs elevated is read from a place another
# account can write.
#   * The whole of C:\ProgramData\Resolute\ElevatedSmoke is written only by
#     Administrators and SYSTEM. Registration sets that on the directory
#     itself, because ProgramData lets ordinary users create files in a new
#     folder, and removes anything it did not put there.
#   * The drivers (scripts/smoke-run.py, scripts/conformance-check.py) are
#     pinned by SHA-256 at registration, staged into that directory before
#     each run, verified there, and run from there.
#   * Python is the repository's pinned runtime (reskit/python), copied into
#     that directory at registration. The machine's own python may sit in a
#     folder any signed-in account can modify, so it is never used.
#   * The tool executables change with every build, so -Run, as the operator,
#     records their SHA-256 under HKCU (the operator's own hive), and the
#     elevated driver stages each one into that directory, verifies the copy
#     and launches the copy.
# Editing a driver after registration buys a named refusal and a
# re-registration prompt, never silent elevated execution of new code.
# The task action is fixed at registration and takes no caller arguments.

param(
    [switch]$Register,
    [switch]$Replace,
    [switch]$Run,
    [switch]$Remove,
    [switch]$SelfTest,
    [switch]$Check,
    [switch]$Readback,
    [switch]$RegisterElevated,   # internal: elevated copy of this script, run by -Register
    [string]$OperatorSid = '',   # internal: the account that asked for the registration
    [switch]$ProveRollback,      # with -Register: first fail a registration on purpose and read the previous state back
    [string]$FailAfterStep = '', # internal: the step after which the elevated copy fails on purpose (it can only make a registration fail)
    [string]$AbandonAfterStep = '', # internal, self-test only: leave after this step without the rollback, as a killed process would
    [int]$RunTimeoutSec = 900,   # how long -Run waits for the task before it stops it and cleans up
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$TaskPath = '\Resolute\'
$TaskName = 'ElevatedSmoke'
$HashDir = 'C:\ProgramData\Resolute\ElevatedSmoke'
$HashFile = Join-Path $HashDir 'trusted-hashes.txt'
$SnapshotDir = Join-Path $HashDir 'run\scripts'
$PythonDir = Join-Path $HashDir 'python'
$EnvFile = Join-Path $HashDir 'run\elevated-smoke-env.txt'
$ManifestKey = 'HKCU:\Software\Resolute\ElevatedSmoke\Manifest'
$ManifestName = 'HKCU\Software\Resolute\ElevatedSmoke\Manifest'   # as the driver's winreg reads it
$KnownEntries = @('trusted-hashes.txt', 'trusted-hashes.txt.new', 'trusted-hashes.txt.old', 'python', 'python.new', 'python.old', 'run', 'register-log.txt', 'registration.journal')
$RegisterLog = Join-Path $HashDir 'register-log.txt'
$JournalFile = Join-Path $HashDir 'registration.journal'
# One registration or recovery at a time, machine-wide. A mutex and not a file: the system releases it when its
# holder dies, which is exactly when the journal it leaves is abandoned and may be recovered.
$RegistrationLockName = 'Global\Resolute-ElevatedSmoke-Registration'
# The refusals the elevated registration copy can give before its directory
# exists, each with its own exit code: that copy's console closes when it
# exits, the log it keeps lives in the directory, and a file the operator's
# own process could read would be a path an ordinary account chose for an
# elevated process to write. The code carries the reason instead.
$RefusalCodes = @{   # a plain hashtable: an ordered one reads an integer key as a position
    10 = 'refused: the registration copy is not elevated'
    11 = 'refused: the consent was given as another account; the task must run as the account that asked for it. Sign in as an administrator, or give this account administrator rights, and register again'
    12 = 'refused: the pinned Python is not installed in reskit\python (run pwsh scripts/bootstrap.ps1)'
    13 = 'refused: the elevated smoke task is running or queued; let it finish or run -Remove first'
    14 = 'refused: registering the elevated smoke task is not possible now: another elevated smoke operation (a registration, a recovery, a run or a removal) holds the lock; try again when it has finished'
}
$AdminsSid = 'S-1-5-32-544'
$SystemSid = 'S-1-5-18'
$DriverFiles = @('scripts\smoke-run.py', 'scripts\conformance-check.py')
$AckTimeoutSec = 60
# How a registration is carried out. The real one is elevated, registers at
# highest privilege, protects its directory and takes the pinned Python; the
# self-test swaps this for a sandbox (a throwaway limited task, a temporary
# directory, no protection) so the whole transaction and its rollback run for
# real without a consent prompt.
$Registration = [pscustomobject]@{
    RequireElevation = $true
    RunLevel = 'Highest'
    Protect = $true
    Source = { Join-Path $Root 'reskit\python' }
    Action = $null
    Readiness = { Get-TransactionRefusals }
    JournalTrusted = { Test-JournalTrusted @(Get-DirectoryRefusals) (Get-JournalOwner) }
    # Whether -Register can register in this process, and how it starts the
    # consented copy when it cannot; the self-test replaces the launch.
    IsElevated = { Test-IsElevated }
    Launch = { param([string]$Arguments) Start-Process powershell.exe -Verb RunAs -ArgumentList $Arguments -Wait -PassThru -ErrorAction Stop }
}
$StopTimeoutSec = 30

function Test-IsElevated {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-DriverHashes([string]$Base) {
    $map = @{}
    foreach ($rel in $DriverFiles) {
        $map[$rel] = (Get-FileHash -Algorithm SHA256 -Path (Join-Path $Base $rel)).Hash
    }
    return $map
}

function Test-PinnedHashes([string]$Base, [string]$PinnedFile) {
    # Returns a list of refusal strings; empty means every pinned hash matches.
    $refusals = @()
    if (-not (Test-Path $PinnedFile)) {
        return @("pinned hashes file missing: $PinnedFile (register first)")
    }
    $pinned = @{}
    foreach ($line in Get-Content $PinnedFile) {
        if ($line -match '^([0-9A-Fa-f]{64})  (.+)$') { $pinned[$Matches[2]] = $Matches[1].ToUpper() }
    }
    $current = Get-DriverHashes $Base
    foreach ($rel in $DriverFiles) {
        if (-not $pinned.ContainsKey($rel)) {
            $refusals += "no pinned hash for $rel (re-register)"
        } elseif ($pinned[$rel] -ne $current[$rel]) {
            $refusals += "driver changed since registration: $rel (hash mismatch; re-register to consent to the new bytes)"
        }
    }
    return $refusals
}

function Get-EnvVerdict {
    # 'clean', or a named contamination. Checks all three scopes so a
    # user-level __COMPAT_LAYER cannot smuggle a RunAsInvoker launch in.
    foreach ($scope in 'Process', 'User', 'Machine') {
        $v = [Environment]::GetEnvironmentVariable('__COMPAT_LAYER', $scope)
        if ($v) { return "contaminated: __COMPAT_LAYER present in $scope environment ($v)" }
    }
    return 'clean'
}

function Test-Report([string]$ReportPath, [datetime]$After, [int]$LastResult, [string]$EnvVerdict) {
    # Named refusals for a run's evidence; empty means the run is proven.
    $refusals = @()
    if (-not (Test-Path $ReportPath)) { return @("smoke report missing: $ReportPath") }
    $info = Get-Item $ReportPath
    if ($info.LastWriteTime -le $After) {
        $refusals += "smoke report is stale (written $($info.LastWriteTime), not after $($After))"
    }
    $text = Get-Content $ReportPath -Raw
    if ($text -notmatch 'Suite verdict: \*\*pass\*\*') {
        $refusals += 'smoke report suite verdict is not pass'
    }
    if ($LastResult -ne 0) { $refusals += "task LastTaskResult is $LastResult, not 0" }
    if ($EnvVerdict -ne 'clean') { $refusals += "environment verdict is not clean: $EnvVerdict" }
    return $refusals
}

function Get-TaskOrNull {
    try {
        return Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction Stop
    } catch {
        if ($_.Exception.Message -match 'No matching|0x80070002|does not exist') { return $null }
        throw
    }
}

function Get-ExpectedAction([string]$Base) {
    # Everything the action executes lives under $HashDir: Windows PowerShell
    # by its full path, the staged drivers, and the pinned Python copied in
    # at registration. The checkout appears only as data: the files to stage
    # and verify, and the root of the tree under test.
    # The action is PowerShell source, and every path in it sits inside single
    # quotes: an apostrophe in a path (D:\Derick's Projects\Resolute) is
    # doubled, or it would end the string and the action would not parse.
    $q = { param([string]$text) $text.Replace("'", "''") }
    $python = & $q (Join-Path $PythonDir 'python.exe')
    $base = & $q $Base
    $envFile = & $q $EnvFile
    $hashFile = & $q $HashFile
    $snapshotDir = & $q $SnapshotDir
    $manifestName = & $q $ManifestName
    $inner = "`$v = if (`$env:__COMPAT_LAYER -or [Environment]::GetEnvironmentVariable('__COMPAT_LAYER','User') -or [Environment]::GetEnvironmentVariable('__COMPAT_LAYER','Machine')) { 'contaminated: __COMPAT_LAYER present' } else { 'clean' }; " +
        "Set-Content -Path '$envFile' -Value `$v; " +
        "if (`$v -ne 'clean') { exit 2 }; " +
        "`$pinned = @{}; foreach (`$line in Get-Content '$hashFile') { if (`$line -match '^([0-9A-Fa-f]{64})  (.+)$') { `$pinned[`$Matches[2]] = `$Matches[1].ToUpper() } }; " +
        "foreach (`$rel in @('scripts\smoke-run.py','scripts\conformance-check.py')) { `$h = (Get-FileHash -Algorithm SHA256 -Path (Join-Path '$base' `$rel)).Hash; if (`$pinned[`$rel] -ne `$h) { Set-Content -Path '$envFile' -Value 'refused: driver changed since registration'; exit 2 } }; " +
        "`$snap = '$snapshotDir'; New-Item -ItemType Directory -Force -Path `$snap | Out-Null; " +
        "foreach (`$rel in @('scripts\smoke-run.py','scripts\conformance-check.py')) { `$leaf = Split-Path `$rel -Leaf; Copy-Item -Path (Join-Path '$base' `$rel) -Destination (Join-Path `$snap `$leaf) -Force; `$h2 = (Get-FileHash -Algorithm SHA256 -Path (Join-Path `$snap `$leaf)).Hash; if (`$pinned[`$rel] -ne `$h2) { Set-Content -Path '$envFile' -Value 'refused: snapshot hash mismatch'; exit 2 } }; " +
        "`$env:RESOLUTE_SMOKE_ROOT = '$base'; `$env:RESOLUTE_SMOKE_MANIFEST = '$manifestName'; `$env:RESOLUTE_IDLE_COLLECT = '1'; & '$python' -I (Join-Path `$snap 'smoke-run.py'); exit `$LASTEXITCODE"
    return @{
        Execute = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
        Argument = "-NoProfile -NonInteractive -Command ""& { $inner }"""
        WorkingDirectory = $HashDir
    }
}

function Test-TrustedOwner([string]$OwnerSid) {
    # An owner can always rewrite an object's ACL, so a protected ACL means
    # nothing while an ordinary account owns the directory.
    return ($OwnerSid -eq $AdminsSid -or $OwnerSid -eq $SystemSid)
}

function Get-DirectoryRefusals {
    # Why the task's directory, or the folder that holds it, cannot be
    # trusted; empty when both can. The directory: a trusted owner and no
    # writer beyond Administrators and SYSTEM. Its parent: a trusted owner
    # and nobody else able to delete or re-permission what is inside it,
    # because whoever can replace the directory owns everything in it.
    $refusals = @()
    $parent = Split-Path $HashDir -Parent
    $checks = @(
        @{ Path = $HashDir; Mask = [Security.AccessControl.FileSystemRights]'Write, Delete, DeleteSubdirectoriesAndFiles, ChangePermissions, TakeOwnership'; What = 'written' },
        @{ Path = $parent; Mask = [Security.AccessControl.FileSystemRights]'DeleteSubdirectoriesAndFiles, ChangePermissions, TakeOwnership'; What = 'replaced' }
    )
    foreach ($check in $checks) {
        if (-not (Test-Path -LiteralPath $check.Path)) { $refusals += "$($check.Path) is missing (register again)"; continue }
        $acl = Get-Acl -LiteralPath $check.Path
        $owner = $acl.GetOwner([Security.Principal.SecurityIdentifier]).Value
        if (-not (Test-TrustedOwner $owner)) { $refusals += "$($check.Path) is owned by $($acl.Owner), who can rewrite its permissions (register again)" }
        $mask = $check.Mask
        $extra = Get-ExtraWriters @(ConvertTo-WriteRules $acl.Access { param($ace) ($ace.FileSystemRights -band $mask) -ne 0 }) @($AdminsSid, $SystemSid)
        if ($extra.Count) { $refusals += "$($check.Path) can be $($check.What) by $($extra -join ', ')" }
    }
    return $refusals
}

function Get-SddlExtraWriters([string]$Sddl, [string[]]$AllowedSids) {
    # The principals a security descriptor lets change the object, beyond
    # the allowed ones. Used on the scheduled task: whoever can rewrite the
    # task can point it at anything.
    $write = 0x10000000 -bor 0x40000000 -bor 0x00010000 -bor 0x00040000 -bor 0x00080000 -bor 0x2 -bor 0x4 -bor 0x10 -bor 0x100
    $descriptor = New-Object Security.AccessControl.RawSecurityDescriptor($Sddl)
    $extra = @()
    foreach ($ace in $descriptor.DiscretionaryAcl) {
        if ($ace.AceType -ne 'AccessAllowed') { continue }
        if (($ace.AccessMask -band $write) -eq 0) { continue }
        $sid = $ace.SecurityIdentifier.Value
        if ($AllowedSids -notcontains $sid) { $extra += $sid }
    }
    return ,@($extra | Select-Object -Unique)
}

function Get-TaskSddl {
    $service = New-Object -ComObject Schedule.Service
    $service.Connect()
    return $service.GetFolder($TaskPath.TrimEnd('\')).GetTask($TaskName).GetSecurityDescriptor(0x7)  # owner, group, DACL
}

function Get-TaskSecurityRefusals {
    try { $sddl = Get-TaskSddl } catch { return @("the task's security descriptor could not be read ($($_.Exception.Message))") }
    $extra = Get-SddlExtraWriters $sddl @((Get-CurrentSid), $AdminsSid, $SystemSid)
    if ($extra.Count) { return @("the task can be changed by another principal: " + ($extra -join ', ')) }
    return @()
}

function Get-DriverWriters([string]$Base) {
    # Who can write each pinned driver file in the checkout. They can break
    # the pin (a refusal, and a new consent), never run code through it.
    $mask = [Security.AccessControl.FileSystemRights]'Write, Delete, ChangePermissions, TakeOwnership'
    foreach ($rel in $DriverFiles) {
        $rules = @(ConvertTo-WriteRules (Get-Acl -LiteralPath (Join-Path $Base $rel)).Access { param($ace) ($ace.FileSystemRights -band $mask) -ne 0 })
        "$rel can be written by: " + ((@($rules | Where-Object Writes | ForEach-Object Name) | Select-Object -Unique) -join ', ')
    }
}

function Invoke-Readback {
    # Read-only: what the trust boundary rests on, as it is now.
    $task = Get-TaskOrNull
    if (-not $task) { Write-Host 'no ElevatedSmoke task is registered'; return 2 }
    Write-Host "task principal: $($task.Principal.UserId), $($task.Principal.RunLevel), $($task.Principal.LogonType)"
    Write-Host "task action: $(@($task.Actions)[0].Execute) in $(@($task.Actions)[0].WorkingDirectory)"
    try { Write-Host "task security descriptor: $(Get-TaskSddl)" } catch { Write-Host "task security descriptor: could not be read ($($_.Exception.Message))" }
    foreach ($line in Get-DriverWriters $Root) { Write-Host "driver: $line" }
    foreach ($dir in (Split-Path $HashDir -Parent), $HashDir) {
        if (Test-Path -LiteralPath $dir) { Write-Host "directory: $dir owner $((Get-Acl -LiteralPath $dir).Owner)" }
    }
    $refusals = @(Get-TaskSecurityRefusals) + @(Get-DirectoryRefusals) + @(Test-DefinitionMatch $task $Root) + @(Test-PinnedHashes $Root $HashFile)
    if ($refusals) { Write-Host ("not trusted: " + ($refusals -join '; ')); return 2 }
    Write-Host 'trusted: the task, its directory and its pinned drivers are as registered'
    return 0
}

function Get-ExtraWriters($Rules, [string[]]$AllowedSids) {
    # The principals that can write and are not among the allowed ones.
    # $Rules is a list of { Sid; Name; Writes } so the rule is testable
    # without a real descriptor; Get-FileWriteRules and Get-KeyWriteRules
    # build it from one.
    $extra = @()
    foreach ($rule in @($Rules)) {
        if ($rule.Writes -and ($AllowedSids -notcontains $rule.Sid)) { $extra += "$($rule.Name) ($($rule.Sid))" }
    }
    return ,@($extra | Select-Object -Unique)
}

function ConvertTo-WriteRules($Access, [scriptblock]$Writes) {
    foreach ($ace in @($Access)) {
        if ($ace.AccessControlType -ne 'Allow') { continue }
        $sid = try { $ace.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value } catch { "$($ace.IdentityReference)" }
        [pscustomobject]@{ Sid = $sid; Name = "$($ace.IdentityReference)"; Writes = [bool](& $Writes $ace) }
    }
}

function Get-KeyWriteRules([string]$KeyPath) {
    $mask = [Security.AccessControl.RegistryRights]'SetValue, CreateSubKey, Delete, ChangePermissions, TakeOwnership'
    return @(ConvertTo-WriteRules (Get-Acl -Path $KeyPath).Access { param($ace) ($ace.RegistryRights -band $mask) -ne 0 })
}

function Test-LineEndingDrift([byte[]]$Disk, [byte[]]$Blob) {
    # True when the file on disk is the committed blob with CRLF where the
    # blob has LF: bytes git would never write for an eol=lf path, so a pin
    # taken over them breaks the next time git rewrites the file.
    if ($null -eq $Blob -or $Disk.Length -eq $Blob.Length) { return $false }
    $text = [Text.Encoding]::GetEncoding(28591)
    return ($text.GetString($Disk).Replace("`r`n", "`n") -ceq $text.GetString($Blob))
}

function Get-HeadBlob([string]$Base, [string]$Rel) {
    # The committed bytes of a path, or $null when git cannot say.
    $info = [Diagnostics.ProcessStartInfo]::new('git')
    foreach ($a in @('-C', $Base, 'cat-file', 'blob', ('HEAD:' + $Rel.Replace('\', '/')))) { $info.ArgumentList.Add($a) }
    $info.UseShellExecute = $false
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.CreateNoWindow = $true
    try { $git = [Diagnostics.Process]::Start($info) } catch { return $null }
    try {
        $null = $git.StandardError.ReadToEndAsync()
        $buffer = [IO.MemoryStream]::new()
        $git.StandardOutput.BaseStream.CopyTo($buffer)
        $git.WaitForExit()
        if ($git.ExitCode -ne 0) { return $null }
        return ,$buffer.ToArray()
    } finally {
        $git.Dispose()
    }
}

function Get-DriftRefusals([string]$Base) {
    $refusals = @()
    foreach ($rel in $DriverFiles) {
        $disk = [IO.File]::ReadAllBytes((Join-Path $Base $rel))
        if (Test-LineEndingDrift $disk (Get-HeadBlob $Base $rel)) {
            $refusals += "$rel is on disk with CRLF line endings, which git does not write for it: restore it (git checkout -- $($rel.Replace('\','/'))) and register again"
        }
    }
    return $refusals
}

function Get-CurrentSid {
    return [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
}

function Resolve-PrincipalSid([string]$UserId) {
    # A task principal as its SID, or $null when Windows cannot say whose it is.
    if (-not $UserId) { return $null }
    try {
        if ($UserId -match '^S-1-') { return (New-Object Security.Principal.SecurityIdentifier($UserId)).Value }
        return (New-Object Security.Principal.NTAccount($UserId)).Translate([Security.Principal.SecurityIdentifier]).Value
    } catch {
        return $null
    }
}

function Test-DefinitionMatch($Task, [string]$Base) {
    # Refusals when an existing task differs from the expected definition.
    $refusals = @()
    $expected = Get-ExpectedAction $Base
    $action = @($Task.Actions)[0]
    if ($action.Execute -ne $expected.Execute) { $refusals += "action execute differs: $($action.Execute)" }
    if ($action.Arguments -ne $expected.Argument) { $refusals += 'action arguments differ from the fixed registration' }
    if ($action.WorkingDirectory -ne $expected.WorkingDirectory) { $refusals += "working directory differs: $($action.WorkingDirectory)" }
    if ($Task.Principal.RunLevel -ne 'Highest') { $refusals += "run level is $($Task.Principal.RunLevel), not Highest" }
    if ($Task.Principal.LogonType -ne 'Interactive') { $refusals += "logon type is $($Task.Principal.LogonType), not Interactive" }
    # The task runs as its principal and reads that account's HKCU for the
    # run manifest, so it must be the account that runs -Run and writes it.
    # A consent given with another administrator's credentials registers
    # that administrator, whose hive this account never writes.
    if ((Resolve-PrincipalSid $Task.Principal.UserId) -ne (Get-CurrentSid)) {
        $refusals += "task principal is $($Task.Principal.UserId), not this account"
    }
    return $refusals
}

function Restore-Task([string]$Path, [string]$Name, [string]$Xml) {
    # Puts a task back from its exported definition. The parameter is -Xml:
    # the rollback used -XmlText until 2026-11-13, which the cmdlet does not
    # have, so every restoration failed at parameter binding. The self-test
    # runs this on a throwaway task for that reason.
    Register-ScheduledTask -TaskPath $Path -TaskName $Name -Xml $Xml -Force -ErrorAction Stop | Out-Null
}

function Invoke-StepPoint([string]$Name) {
    # A named point in a registration. Only ever makes one end early: with a
    # failure (the rollback proof's fault) or, in the self-test, by leaving
    # without the rollback, which is what a killed process or a reboot does.
    if (-not $Name) { return }
    if ($script:FailAfterStep -eq $Name) { throw "injected failure after step '$Name'" }
    if ($script:AbandonAfterStep -eq $Name) { throw "abandoned after step '$Name'" }
}

function Switch-Path([string]$New, [string]$Live, [scriptblock]$Move = { param($from, $to) Move-Item -LiteralPath $from -Destination $to }, [string]$Label = '') {
    # Puts $New in place of $Live, a file or a directory, and keeps what was
    # there beside it as "$Live.old". Both moves are renames inside one
    # directory. The kept copy is what a rollback puts back, so it stays
    # until the registration has passed its readiness checks.
    # A kept copy already there is never removed here: it is either the
    # previous registration a journal still points at, or a committed
    # registration's leftover, which the next registration removes when it
    # starts and has no journal (D07 T01 section 11).
    $old = "$Live.old"
    if (Test-Path -LiteralPath $old) { throw "a kept copy is already at ${old}: it was not cleared before the switch" }
    if (Test-Path -LiteralPath $Live) { & $Move $Live $old }
    if ($Label) { Invoke-StepPoint "$Label aside" }
    try {
        & $Move $New $Live
    } catch {
        # The second rename was refused with the live copy already moved
        # aside: it goes straight back, so the live path is never left empty.
        if (Test-Path -LiteralPath $old) { & $Move $old $Live }
        throw
    }
    if ($Label) { Invoke-StepPoint "$Label in" }
}

function Test-JournalTrusted([string[]]$DirectoryRefusals, [string]$OwnerSid) {
    # A journal tells an elevated process which task definition to register,
    # so it is read only where nobody but Administrators and SYSTEM could
    # have written it: in a directory that passes its own checks, and owned
    # by one of the two. Registration protects the directory before it
    # writes a journal, so one that fails this was not written by it.
    return ((@($DirectoryRefusals | Where-Object { $_ })).Count -eq 0 -and (Test-TrustedOwner $OwnerSid))
}

function Get-JournalOwner {
    try { return (Get-Acl -LiteralPath $JournalFile).GetOwner([Security.Principal.SecurityIdentifier]).Value } catch { return '' }
}

function Read-Journal {
    return (Get-Content -LiteralPath $JournalFile -Raw | ConvertFrom-Json)
}

function Write-Journal($State, [bool]$Protect) {
    # Written once, before the first change it covers, and never updated:
    # it says only what was there before. A temporary file renamed into
    # place, so a journal is either whole or absent.
    $tmp = "$JournalFile.tmp"
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }
    Set-Content -LiteralPath $tmp -Value ($State | ConvertTo-Json -Depth 3) -Encoding utf8
    if ($Protect) {
        $acl = Get-Acl -LiteralPath $tmp
        $acl.SetOwner((New-Object Security.Principal.SecurityIdentifier($AdminsSid)))
        Set-Acl -LiteralPath $tmp -AclObject $acl
    }
    $back = Get-Content -LiteralPath $tmp -Raw | ConvertFrom-Json
    if ($back.HashesText -ne $State.HashesText -or $back.TaskXml -ne $State.TaskXml) { throw "the journal written to $tmp did not read back as written" }
    Move-Item -LiteralPath $tmp -Destination $JournalFile
}

function Get-StateOnDisk {
    # The same fields a journal records, read from the disk and the scheduler.
    $task = Get-TaskOrNull
    return [pscustomobject]@{
        HadTask = [bool]$task
        TaskXml = if ($task) { (Export-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName) -replace '\s+', ' ' } else { '' }
        HadHashes = Test-Path -LiteralPath $HashFile
        HashesText = if (Test-Path -LiteralPath $HashFile) { (Get-Content -LiteralPath $HashFile -Raw).Trim() } else { '' }
        HadRuntime = Test-Path -LiteralPath $PythonDir
        RuntimeHash = if (Test-Path -LiteralPath (Join-Path $PythonDir 'python.exe')) { (Get-FileHash -LiteralPath (Join-Path $PythonDir 'python.exe')).Hash } else { '' }
    }
}

function Restore-Kept([string]$Live, [bool]$HadLive) {
    # One live path back to what a journal says was there, from the disk:
    # a kept copy means the live path was switched or emptied, so the copy
    # goes back; no kept copy and nothing there before means what is live
    # is new and goes. Safe to repeat: each call starts from what it finds.
    $old = "$Live.old"
    if (Test-Path -LiteralPath $old) {
        if (Test-Path -LiteralPath $Live) { Remove-Item -LiteralPath $Live -Recurse -Force }
        Move-Item -LiteralPath $old -Destination $Live
    } elseif (-not $HadLive -and (Test-Path -LiteralPath $Live)) {
        Remove-Item -LiteralPath $Live -Recurse -Force
    }
    if (Test-Path -LiteralPath "$Live.new") { Remove-Item -LiteralPath "$Live.new" -Recurse -Force }
}

function Invoke-RegistrationRecovery {
    # Returns a registration that never reached its commit, by a kill or a
    # reboot, to what its journal says was there before, and reads that
    # back before the journal goes. A recovery that cannot finish throws,
    # naming what it could not do, and leaves the journal and the kept
    # copies for the next attempt; each step starts from what is on disk.
    $journal = Read-Journal
    Restore-Kept $HashFile ([bool]$journal.HadHashes)
    Restore-Kept $PythonDir ([bool]$journal.HadRuntime)
    if ($journal.HadTask) {
        Restore-Task $TaskPath $TaskName $journal.TaskXmlRaw
    } elseif (Get-TaskOrNull) {
        Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false -ErrorAction Stop
    }
    $now = Get-StateOnDisk
    $differs = @(foreach ($name in 'HadTask', 'TaskXml', 'HadHashes', 'HashesText', 'HadRuntime', 'RuntimeHash') {
        if ("$($now.$name)" -ne "$($journal.$name)") { $name }
    })
    if ($differs) { throw ("the interrupted registration was not fully recovered (" + ($differs -join ', ') + " differ); the journal and the kept copies are left for another attempt") }
    if ($journal.HadDir) {
        Remove-Item -LiteralPath $JournalFile -Force
    } else {
        Remove-Item -LiteralPath $HashDir -Recurse -Force
    }
}

function Resolve-Journal {
    # Before a registration: a journal it can trust is recovered; one it
    # cannot is removed unread, since what it would have it register cannot
    # be told apart from what someone else wrote.
    if (-not (Test-Path -LiteralPath $JournalFile)) { return }
    if (& $script:Registration.JournalTrusted) {
        Write-Registration "an interrupted registration was found: recovering it before this one"
        Invoke-RegistrationRecovery
        Write-Registration "the interrupted registration was recovered"
    } else {
        Write-Host "removed an untrusted journal, unread: $JournalFile"
        Remove-Item -LiteralPath $JournalFile -Force
    }
}

function Undo-Switch([string]$Live, [bool]$HadLive) {
    # Reverses a Switch-Path: the kept copy goes back, or, when nothing was
    # there before, what the switch put there is removed.
    $old = "$Live.old"
    if (Test-Path -LiteralPath $old) {
        if (Test-Path -LiteralPath $Live) { Remove-Item -LiteralPath $Live -Recurse -Force }
        Move-Item -LiteralPath $old -Destination $Live
    } elseif (-not $HadLive -and (Test-Path -LiteralPath $Live)) {
        Remove-Item -LiteralPath $Live -Recurse -Force
    }
}

function Remove-Kept([string]$Live, [scriptblock]$Discard = { param($path) Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop }) {
    # After the registration has committed: the kept copy is no longer
    # needed. One that cannot be removed is a note, never a failure, because
    # nothing after the commit may undo it.
    $old = "$Live.old"
    if (-not (Test-Path -LiteralPath $old)) { return '' }
    try { & $Discard $old; return '' } catch { return "the previous copy could not be removed from $old ($($_.Exception.Message)); the next registration removes it" }
}

function Wait-TaskStopped([scriptblock]$GetState, [int]$TimeoutSec) {
    # True when the getter reports a stopped state inside the bound.
    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSec)
    while ([DateTime]::UtcNow -lt $deadline) {
        if ((& $GetState) -ne 'Running') { return $true }
        Start-Sleep -Milliseconds 500
    }
    return ((& $GetState) -ne 'Running')
}

function Test-DriverProcessesGone($Procs, [bool]$InventoryOk, [string]$DriverPath, [string[]]$ToolNames = @(), [string]$StageRoot = '') {
    # Gone is proven only by a readable inventory in which nothing of the
    # run is left: no python process carrying the driver, and no process of
    # a tool the run staged. A tool process counts as the run's when it runs
    # from the staging directory, and also when its path cannot be read,
    # because an elevated process hides its path from this unelevated
    # caller and the run's tools are elevated. The same tool started by the
    # operator from Bin\ has a readable path elsewhere and is left alone.
    # A failed query proves nothing and returns $false.
    if (-not $InventoryOk) { return $false }
    foreach ($proc in @($Procs)) {
        $name = "$($proc.Name)"
        if ($ToolNames -contains $name) {
            if (-not $proc.ExecutablePath) { return $false }
            if ($StageRoot -and $proc.ExecutablePath.StartsWith($StageRoot, [StringComparison]::OrdinalIgnoreCase)) { return $false }
            continue
        }
        if (-not $proc.CommandLine) { return $false }
        if ($proc.CommandLine.Contains($DriverPath) -or $proc.CommandLine.Contains('smoke-run.py')) { return $false }
    }
    return $true
}

function Test-TaskNeedsStop([string]$State) {
    # A queued instance has been asked to start and will, so it is stopped
    # like a running one: by -Run's cleanup and by -Remove alike.
    return ($State -eq 'Running' -or $State -eq 'Queued')
}

function Invoke-RollbackSteps([scriptblock[]]$Steps) {
    # Runs every restore step even when an earlier one throws, and returns
    # what failed, so one failed restore never hides the rest or the error
    # that started the rollback.
    $failed = @()
    foreach ($step in $Steps) {
        try { & $step } catch { $failed += $_.Exception.Message }
    }
    return ,$failed
}

function Stop-OwnedTask {
    # Stops the task (running or queued) and confirms it, and this
    # checkout's driver processes, are gone. Returns $true only when
    # both are confirmed; an unreadable inventory is not confirmation.
    $stageRoot = Join-Path $HashDir 'run\bin'
    $toolNames = @()
    if (Test-Path -LiteralPath $stageRoot) {
        $toolNames = @(Get-ChildItem -LiteralPath $stageRoot -Recurse -File -Filter '*.exe' | ForEach-Object Name | Select-Object -Unique)
    }
    # What is alive before the stop is said, so "confirmed gone" afterwards
    # is a statement about processes that were there.
    $aliveNow = try {
        $alive = @(Get-CimInstance Win32_Process -ErrorAction Stop | Where-Object {
            ($toolNames -contains $_.Name) -and (-not $_.ExecutablePath -or $_.ExecutablePath.StartsWith($stageRoot, [StringComparison]::OrdinalIgnoreCase)) })
        if ($alive) { ($alive | ForEach-Object { "$($_.Name) (pid $($_.ProcessId))" }) -join ', ' } else { 'none' }
    } catch {
        "could not be listed ($($_.Exception.Message))"
    }
    Write-Host "cleanup: stopping the task; tool processes of the run alive now: $aliveNow"
    # A stop that finds nothing to stop is not a failure here: what counts is
    # the confirmation below that the task and its processes are gone.
    Stop-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue
    $stopped = Wait-TaskStopped {
        $s = (Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName).State
        if ($s -eq 'Running' -or $s -eq 'Queued') { 'Running' } else { 'Ready' }
    } $StopTimeoutSec
    if (-not $stopped) { return $false }
    # Stopping the task ends its process tree: the wrapper, the driver, and
    # through the driver's kill-on-close job the tools it launched. That is
    # checked, not assumed: the driver and every staged tool must be gone.
    $driver = Join-Path $Root 'scripts\smoke-run.py'
    $wanted = @('python.exe') + $toolNames
    $deadline = [DateTime]::UtcNow.AddSeconds($StopTimeoutSec)
    do {
        $inventoryOk = $true
        try {
            $procs = @(Get-CimInstance Win32_Process -ErrorAction Stop | Where-Object { $wanted -contains $_.Name })
        } catch {
            $procs = @()
            $inventoryOk = $false
        }
        if (Test-DriverProcessesGone $procs $inventoryOk $driver $toolNames $stageRoot) { return $true }
        Start-Sleep -Milliseconds 500
    } while ([DateTime]::UtcNow -lt $deadline)
    return $false
}

function Invoke-SelfTest {
    # One list, in script scope, for the nested Check to add to and for the
    # verdict below to read. A function-local list here would stay empty
    # whatever failed, and the command would say "all pass" over FAIL lines.
    $script:failures = @()
    function Check([string]$Name, [bool]$Ok) {
        if ($Ok) { Write-Host "PASS $Name" } else { Write-Host "FAIL $Name"; $script:failures += $Name }
    }
    $td = Join-Path ([IO.Path]::GetTempPath()) ("elevated-smoke-test-" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $td | Out-Null
    try {
        # Definition comparison against synthetic task shapes.
        $expected = Get-ExpectedAction $Root
        $good = [pscustomobject]@{
            Actions = @([pscustomobject]@{ Execute = $expected.Execute; Arguments = $expected.Argument; WorkingDirectory = $expected.WorkingDirectory })
            Principal = [pscustomobject]@{ RunLevel = 'Highest'; LogonType = 'Interactive'; UserId = (Get-CurrentSid) }
        }
        Check 'definition match accepted' ((Test-DefinitionMatch $good $Root).Count -eq 0)
        $bad = [pscustomobject]@{
            Actions = @([pscustomobject]@{ Execute = $expected.Execute; Arguments = '-visible'; WorkingDirectory = $expected.WorkingDirectory })
            Principal = [pscustomobject]@{ RunLevel = 'Highest'; LogonType = 'Interactive'; UserId = (Get-CurrentSid) }
        }
        Check 'definition mismatch refused by name' ((Test-DefinitionMatch $bad $Root) -match 'arguments differ').Count -ge 1
        Check 'action path keys match the pinned relative paths' ($expected.Argument.Contains("@('scripts\smoke-run.py','scripts\conformance-check.py')") -and -not $expected.Argument.Contains('scripts\\smoke-run.py'))

        # Report validation: fresh pass accepted; stale, non-pass, nonzero refused.
        $report = Join-Path $td 'smoke-report.md'
        Set-Content -Path $report -Value "# Smoke report`r`n`r`nSuite verdict: **pass**"
        $now = Get-Date
        Check 'fresh pass report accepted' ((Test-Report $report $now.AddMinutes(-1) 0 'clean').Count -eq 0)
        Check 'stale report refused' ((Test-Report $report $now.AddMinutes(1) 0 'clean') -match 'stale').Count -ge 1
        Set-Content -Path $report -Value "# Smoke report`r`n`r`nSuite verdict: **blocked**"
        Check 'non-pass report refused' ((Test-Report $report $now.AddMinutes(-1) 0 'clean') -match 'not pass').Count -ge 1
        Set-Content -Path $report -Value "# Smoke report`r`n`r`nSuite verdict: **pass**"
        Check 'nonzero task result refused' ((Test-Report $report $now.AddMinutes(-1) 2 'clean') -match 'LastTaskResult').Count -ge 1
        Check 'contaminated environment refused' ((Test-Report $report $now.AddMinutes(-1) 0 'contaminated: x') -match 'environment').Count -ge 1

        # Environment verdict parsing.
        Check 'environment verdict clean on this shell' ((Get-EnvVerdict) -eq 'clean' -or (Get-EnvVerdict) -match 'contaminated')
        $savedLayer = $env:__COMPAT_LAYER
        $env:__COMPAT_LAYER = 'RunAsInvoker'
        try { Check 'contaminated environment named' ((Get-EnvVerdict) -match 'contaminated.*Process') } finally {
            if ($null -eq $savedLayer) { Remove-Item Env:__COMPAT_LAYER -ErrorAction SilentlyContinue } else { $env:__COMPAT_LAYER = $savedLayer }
        }

        # Hash verification: registered bytes accepted, one byte changed refused.
        $hashBase = Join-Path $td 'checkout'
        New-Item -ItemType Directory -Path (Join-Path $hashBase 'scripts') -Force | Out-Null
        foreach ($rel in $DriverFiles) {
            Set-Content -Path (Join-Path $hashBase $rel) -Value "fixture $rel" -NoNewline
        }
        $pinnedFile = Join-Path $td 'trusted-hashes.txt'
        $lines = foreach ($rel in $DriverFiles) { '{0}  {1}' -f (Get-FileHash -Algorithm SHA256 -Path (Join-Path $hashBase $rel)).Hash, $rel }
        Set-Content -Path $pinnedFile -Value $lines
        Check 'registered bytes accepted' ((Test-PinnedHashes $hashBase $pinnedFile).Count -eq 0)
        Add-Content -Path (Join-Path $hashBase 'scripts\smoke-run.py') -Value 'x' -NoNewline
        Check 'one-byte change refused by name' ((Test-PinnedHashes $hashBase $pinnedFile) -match 'driver changed.*smoke-run').Count -ge 1

        # Process-inventory verdicts: absence must be proven, never assumed.
        $fakeDriver = 'R:\\x\\scripts\\smoke-run.py'
        Check 'unreadable inventory proves nothing' (-not (Test-DriverProcessesGone @() $false $fakeDriver))
        Check 'unrelated readable process is gone' (Test-DriverProcessesGone @([pscustomobject]@{ CommandLine = 'python other.py' }) $true $fakeDriver)
        Check 'driver process present is not gone' (-not (Test-DriverProcessesGone @([pscustomobject]@{ CommandLine = "python $fakeDriver" }) $true $fakeDriver))
        Check 'unreadable process is not gone' (-not (Test-DriverProcessesGone @([pscustomobject]@{ CommandLine = $null }) $true $fakeDriver))

        # Unconfirmed stop: a getter that never leaves Running fails the wait.
        Check 'unconfirmed stop fails inside its bound' (-not (Wait-TaskStopped { 'Running' } 1))
        Check 'confirmed stop passes' (Wait-TaskStopped { 'Ready' } 1)

        # The action runs nothing by a bare name and nothing from the checkout.
        Check 'the action runs Windows PowerShell by its full path from the protected directory' (
            $expected.Execute -eq (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe') -and
            $expected.WorkingDirectory -eq $HashDir -and $expected.Argument.Contains("& '$PythonDir\python.exe' -I"))
        $bare = [pscustomobject]@{
            Actions = @([pscustomobject]@{ Execute = 'powershell.exe'; Arguments = $expected.Argument; WorkingDirectory = $Root })
            Principal = [pscustomobject]@{ RunLevel = 'Highest'; LogonType = 'Interactive'; UserId = (Get-CurrentSid) }
        }
        Check 'the earlier bare powershell.exe definition is refused by name' (
            ((Test-DefinitionMatch $bare $Root) -join '; ') -match 'action execute differs: powershell\.exe.*working directory differs')

        # The task must be this account's: its HKCU holds the run manifest.
        $other = [pscustomobject]@{
            Actions = @([pscustomobject]@{ Execute = $expected.Execute; Arguments = $expected.Argument; WorkingDirectory = $expected.WorkingDirectory })
            Principal = [pscustomobject]@{ RunLevel = 'Highest'; LogonType = 'Interactive'; UserId = 'S-1-5-18' }
        }
        Check 'a task registered as another account is refused by name' (((Test-DefinitionMatch $other $Root) -join '; ') -match 'task principal is S-1-5-18, not this account')

        # Cleanup counts the tools the run staged, not only the driver.
        $stage = 'C:\ProgramData\Resolute\ElevatedSmoke\run\bin'
        $staged = [pscustomobject]@{ Name = 'RegStudio.exe'; CommandLine = $null; ExecutablePath = "$stage\RegStudio\RegStudio.exe" }
        $hidden = [pscustomobject]@{ Name = 'RegStudio.exe'; CommandLine = $null; ExecutablePath = $null }
        $mine = [pscustomobject]@{ Name = 'RegStudio.exe'; CommandLine = 'RegStudio.exe'; ExecutablePath = 'D:\Resolute\Bin\Release\System\RegStudio.exe' }
        Check 'a staged tool still running, or one whose path is hidden, is not gone; the operator''s own copy is left alone' (
            -not (Test-DriverProcessesGone @($staged) $true $fakeDriver @('RegStudio.exe') $stage) -and
            -not (Test-DriverProcessesGone @($hidden) $true $fakeDriver @('RegStudio.exe') $stage) -and
            (Test-DriverProcessesGone @($mine) $true $fakeDriver @('RegStudio.exe') $stage))

        # Ownership is part of the boundary: only Administrators or SYSTEM may own the directory.
        Check 'Administrators and SYSTEM are trusted owners, an ordinary account is not' (
            (Test-TrustedOwner $AdminsSid) -and (Test-TrustedOwner $SystemSid) -and -not (Test-TrustedOwner 'S-1-5-21-1-2-3-1001'))
        # A checkout path with an apostrophe still gives an action that parses.
        $quoted = Get-ExpectedAction "D:\Derick's Projects\Resolute"
        $source = $quoted.Argument.Substring($quoted.Argument.IndexOf('"') + 1).TrimEnd('"')
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput($source, [ref]$null, [ref]$parseErrors)
        Check 'a checkout path with an apostrophe gives an action that parses' ($parseErrors.Count -eq 0 -and $source.Contains("'D:\Derick''s Projects\Resolute'"))

        # -Check and -Run refuse on the same list: a reason any check gives stops a run.
        $ready = Get-RunRefusals $good @({ @() }, { $null })
        $held = Get-RunRefusals $good @({ @() }, { 'the task can be changed by another principal: S-1-5-11' })
        Check 'a run is refused on any reason the shared list gives, and only then' ($ready.Count -eq 0 -and $held.Count -eq 1 -and $held[0] -match 'another principal')
        $runSource = (Get-Command Invoke-RunUnderLock).ScriptBlock.ToString()  # the launch path, which Invoke-Run calls under the lock
        $checkSource = (Get-Command Invoke-Check).ScriptBlock.ToString()
        Check 'the launch path and the readiness answer both read the shared list' ($runSource.Contains('Get-RunRefusals') -and $checkSource.Contains('Get-RunRefusals'))
        $defaults = (Get-Command Get-RunRefusals).ScriptBlock.ToString()
        Check 'the shared list holds the task security, directory, definition and pin checks' (
            @('Get-TaskSecurityRefusals', 'Get-DirectoryRefusals', 'Test-DefinitionMatch', 'Test-PinnedHashes' | Where-Object { -not $defaults.Contains($_) }).Count -eq 0)

        # Both ways into an elevated registration go through the same entry, which holds the rollback proof.
        $entry = (Get-Command Invoke-ElevatedRegistration).ScriptBlock.ToString()
        Check 'an elevated shell and the consented copy register through the one entry that carries the rollback proof' (
            $entry.Contains('Invoke-ProveRollback') -and (Get-Command Invoke-Register).ScriptBlock.ToString().Contains('$code = Invoke-ElevatedRegistration'))

        # Every path through -Register ends in the readiness list: a reason on it is not a registration.
        Check 'a registration with a reason left on the readiness list is refused, one with none is not judged here' (
            (Confirm-Registration @('the task can be changed by another principal: S-1-5-11') 6>$null) -eq 2)
        $registerSource = (Get-Command Invoke-Register).ScriptBlock.ToString()
        Check 'every success of -Register goes through the readiness list' (
            ([regex]::Matches($registerSource, 'return 0')).Count -eq 0 -and ([regex]::Matches($registerSource, 'Confirm-Registration')).Count -eq 2)

        # A rename refused between moving the live copy aside and putting the new one in its place.
        $switchLive = Join-Path $td 'switch'
        $switchNew = "$switchLive.new"
        New-Item -ItemType Directory -Path $switchLive, $switchNew | Out-Null
        Set-Content (Join-Path $switchLive 'python.exe') 'old'; Set-Content (Join-Path $switchNew 'python.exe') 'new'
        $threw = $false
        try {
            Switch-Path $switchNew $switchLive { param($from, $to) if ($from -eq $switchNew) { throw 'the disk refused the rename' }; Move-Item -LiteralPath $from -Destination $to }
        } catch { $threw = $true }
        Check 'a switch whose second rename is refused puts the previous copy back and leaves the live path filled' (
            $threw -and (Test-Path (Join-Path $switchLive 'python.exe')) -and (Get-Content (Join-Path $switchLive 'python.exe')) -eq 'old' -and
            -not (Test-Path "$switchLive.old") -and (Test-Path $switchNew))

        # After the commit a kept copy that cannot be removed is a note, never a failure.
        $keptLive = Join-Path $td 'kept'
        New-Item -ItemType Directory -Path $keptLive, "$keptLive.old" | Out-Null
        Check 'a kept copy that cannot be removed after the commit is a note' (
            (Remove-Kept $keptLive { param($path) throw 'the old copy is held open' }) -match 'could not be removed' -and (Remove-Kept $keptLive) -eq '' -and -not (Test-Path "$keptLive.old"))

        # The registration transaction itself, run for real in a sandbox: a throwaway task of this account at
        # limited privilege whose action only exits, and a temporary directory in place of the protected one.
        # The same function registers, fails where it is told to, and rolls back; nothing here is a stand-in for it.
        $saved = @{ TaskPath = $TaskPath; TaskName = $TaskName; HashDir = $HashDir; HashFile = $HashFile; SnapshotDir = $SnapshotDir
                    PythonDir = $PythonDir; EnvFile = $EnvFile; RegisterLog = $RegisterLog; JournalFile = $JournalFile; Registration = $script:Registration
                    FailAfterStep = $script:FailAfterStep; AbandonAfterStep = $script:AbandonAfterStep; RegistrationLockName = $script:RegistrationLockName; RunProbe = $script:RunProbe }
        $box = Join-Path $td 'registration'
        $source = Join-Path $td 'runtime-source'
        New-Item -ItemType Directory -Path $source | Out-Null
        Set-Content (Join-Path $source 'python.exe') 'runtime one'
        $verdict = @{ Refusals = @() }
        $trust = @{ Value = $true }
        function Register-InSandbox([string]$FailAfter = '', [string]$AbandonAfter = '') {
            # 'ok', or the failure's message. What the registration prints is not part of the self-test's output.
            $script:FailAfterStep = $FailAfter
            $script:AbandonAfterStep = $AbandonAfter
            try { $code = Invoke-RegisterElevated 6>$null; if ($code -eq 0) { return 'ok' }; return "exit $code" }
            catch { return $_.Exception.Message }
            finally { $script:FailAfterStep = ''; $script:AbandonAfterStep = '' }
        }
        function Recover-InSandbox {
            # 'ok', or the refusal's message.
            try { Invoke-RegistrationRecovery 6>$null; return 'ok' } catch { return $_.Exception.Message }
        }
        function Get-Leftovers { @(Get-ChildItem -LiteralPath $box -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '\.(new|old)$' } | ForEach-Object Name) }
        try {
            $script:TaskPath = '\'
            $script:TaskName = 'ResoluteSelfTest-' + [Guid]::NewGuid().ToString('N')
            $script:HashDir = $box
            $script:HashFile = Join-Path $box 'trusted-hashes.txt'
            $script:SnapshotDir = Join-Path $box 'run\scripts'
            $script:PythonDir = Join-Path $box 'python'
            $script:EnvFile = Join-Path $box 'run\elevated-smoke-env.txt'
            $script:RegisterLog = Join-Path $box 'register-log.txt'
            $script:JournalFile = Join-Path $box 'registration.journal'
            $script:RegistrationLockName = 'Local\ResoluteSelfTest-' + [Guid]::NewGuid().ToString('N')
            $script:Registration = [pscustomobject]@{
                RequireElevation = $false; RunLevel = 'Limited'; Protect = $false
                Source = { $source }
                Action = (New-ScheduledTaskAction -Execute (Join-Path $env:SystemRoot 'System32\cmd.exe') -Argument '/c exit 0')
                Readiness = { Get-TransactionRefusals @({ $verdict.Refusals }) }
                JournalTrusted = { $trust.Value }
                IsElevated = { $false }
                Launch = { param([string]$Arguments) [pscustomobject]@{ ExitCode = 12 } }
            }

            # A first registration refused before its directory exists says why in its exit code, and writes nothing.
            $missing = $script:Registration.Source
            $script:Registration.Source = { Join-Path $td 'no-runtime-here' }
            $code = Invoke-RegisterElevated 6>$null
            $script:Registration.Source = $missing
            Check 'a first registration refused before its directory exists returns the code that names the refusal, and writes nothing' (
                $code -eq 12 -and (Get-RefusalForExitCode $code) -match 'pinned Python is not installed' -and -not (Test-Path -LiteralPath $box) -and -not (Get-TaskOrNull))

            # -Register itself, with the consented copy exiting 12 having logged nothing: the operator's window shows
            # why, -Register fails, and it does not go on to confirm a registration that did not happen.
            $savedReplace = $script:Replace
            $script:Replace = $true
            try {
                $shown = @(Invoke-Register 6>&1)
            } finally {
                $script:Replace = $savedReplace
            }
            $answer = @($shown | Where-Object { $_ -is [int] })
            $text = ($shown | Where-Object { $_ -isnot [int] } | ForEach-Object { "$_" }) -join "`n"
            # The same with a log that cannot be read: the exit code's refusal is still shown.
            $savedLog = $script:RegisterLog
            $script:Replace = $true
            try {
                New-Item -ItemType Directory -Path $box -Force | Out-Null
                $script:RegisterLog = $box   # a directory: reading it fails, as a denied or locked file would
                $unreadable = @(Invoke-Register 6>&1)
            } catch {
                $unreadable = @("threw: $($_.Exception.Message)")
            } finally {
                $script:Replace = $savedReplace
                $script:RegisterLog = $savedLog
                if (Test-Path -LiteralPath $box) { Remove-Item -LiteralPath $box -Recurse -Force }
            }
            $uAnswer = @($unreadable | Where-Object { $_ -is [int] })
            $uText = ($unreadable | Where-Object { $_ -isnot [int] } | ForEach-Object { "$_" }) -join "`n"
            Check '-Register with a log it cannot read still shows the refusal the exit code names, and fails' (
                $uText.Contains("elevated: $(Get-RefusalForExitCode 12)") -and $uAnswer.Count -eq 1 -and $uAnswer[0] -ne 0)
            Check '-Register shows a refusal the consented copy gave only in its exit code, fails, and confirms nothing' (
                $text.Contains("elevated: $(Get-RefusalForExitCode 12)") -and $answer.Count -eq 1 -and $answer[0] -ne 0 -and
                -not $text.Contains('readiness checks') -and -not $text.Contains('registered:'))

            # A log that cannot be written does not change a refusal's exit code, or what the operator is shown.
            $savedLog = $script:RegisterLog
            $missing = $script:Registration.Source
            try {
                New-Item -ItemType Directory -Path $box -Force | Out-Null
                $script:RegisterLog = $box   # a directory: appending to it fails, as a full disk or a denied file would
                $script:Registration.Source = { Join-Path $td 'no-runtime-here' }
                try { $code = Invoke-RegisterElevated 6>$null } catch { $code = "threw: $($_.Exception.Message)" }
                $script:RegisterLog = Join-Path $td 'no-log-at-all.txt'
                $text = if ($code -is [int]) { ((Write-ElevatedOutcome $code 0 6>&1) | Where-Object { $_ -isnot [int] } | ForEach-Object { "$_" }) -join "`n" } else { '' }
            } finally {
                $script:RegisterLog = $savedLog
                $script:Registration.Source = $missing
                if (Test-Path -LiteralPath $box) { Remove-Item -LiteralPath $box -Recurse -Force }
            }
            Check 'a refusal whose log cannot be written still returns its code, and the operator is still shown why' (
                $code -eq 12 -and $text.Contains("elevated: $(Get-RefusalForExitCode 12)"))

            # A first registration abandoned after its switch is recovered to nothing: no task, no directory.
            $said = Register-InSandbox -AbandonAfter 'commit'
            $abandoned = (Test-Path -LiteralPath $script:JournalFile) -and [bool](Get-TaskOrNull)
            $said2 = Recover-InSandbox
            Check 'a first registration abandoned after its switch is recovered to no task and no directory' (
                $said -match "abandoned after step 'commit'" -and $abandoned -and $said2 -eq 'ok' -and -not (Get-TaskOrNull) -and -not (Test-Path -LiteralPath $box))

            # A first registration that fails after the switch leaves nothing: no task, no directory.
            $said = Register-InSandbox 'commit'
            Check 'a first registration that fails after the switch leaves no task and no directory' (
                $said -match "injected failure after step 'commit'" -and -not (Get-TaskOrNull) -and -not (Test-Path -LiteralPath $box))

            $said = Register-InSandbox
            $registered = Get-RegistrationState
            Check 'a registration in the sandbox registers the task, the pinned hashes and the runtime, and keeps no spare copy' (
                $said -eq 'ok' -and (Get-TaskOrNull) -and @(Get-Content -LiteralPath $script:HashFile).Count -eq 2 -and
                (Get-Content (Join-Path $script:PythonDir 'python.exe')) -eq 'runtime one' -and (Get-Leftovers).Count -eq 0)

            # From here every failed replacement must leave exactly that registration.
            Set-Content (Join-Path $source 'python.exe') 'runtime two'
            foreach ($step in 'directory', 'hashes', 'task', 'commit', 'report') {
                $said = Register-InSandbox $step
                $differs = Compare-RegistrationState $registered (Get-RegistrationState)
                Check "a replacement that fails after '$step' leaves the previous task, hashes and runtime, and no spare copy" (
                    $said -match "injected failure after step '$step'" -and $differs.Count -eq 0 -and (Get-Leftovers).Count -eq 0)
            }
            $verdict.Refusals = @('the task can be changed by another principal: S-1-5-11')
            $said = Register-InSandbox
            $differs = Compare-RegistrationState $registered (Get-RegistrationState)
            Check 'a replacement its readiness checks refuse is rolled back like any other failure' (
                $said -match 'does not pass its readiness checks: the task can be changed by another principal' -and $differs.Count -eq 0 -and (Get-Leftovers).Count -eq 0)
            $verdict.Refusals = @()

            # A replacement abandoned at any point, as a killed process leaves it, is recovered from the disk to
            # exactly the registration before it, with no journal and no spare copy left.
            foreach ($step in 'hashes', 'task', 'hashes aside', 'hashes in', 'runtime aside', 'runtime in', 'commit', 'report') {
                $said = Register-InSandbox -AbandonAfter $step
                $journalThere = Test-Path -LiteralPath $script:JournalFile
                $said2 = Recover-InSandbox
                $differs = Compare-RegistrationState $registered (Get-RegistrationState)
                Check "a replacement abandoned after '$step' is recovered to the registration before it" (
                    $said -match "abandoned after step '$step'" -and $journalThere -and $said2 -eq 'ok' -and $differs.Count -eq 0 -and
                    -not (Test-Path -LiteralPath $script:JournalFile) -and (Get-Leftovers).Count -eq 0)
            }

            # A registration started on an abandoned state recovers it first and ends as a complete new registration.
            $null = Register-InSandbox -AbandonAfter 'runtime aside'
            $emptied = -not (Test-Path -LiteralPath $script:PythonDir)
            $said = Register-InSandbox
            Check 'a registration started where the live runtime was left moved aside recovers first and ends complete' (
                $emptied -and $said -eq 'ok' -and (Get-Content (Join-Path $script:PythonDir 'python.exe')) -eq 'runtime two' -and
                -not (Test-Path -LiteralPath $script:JournalFile) -and (Get-Leftovers).Count -eq 0)
            Set-Content (Join-Path $source 'python.exe') 'runtime one'
            $null = Register-InSandbox
            $registered = Get-RegistrationState
            Set-Content (Join-Path $source 'python.exe') 'runtime two'

            # A recovery that cannot finish says so, keeps what it needs, and finishes when run again.
            $null = Register-InSandbox -AbandonAfter 'runtime in'
            $held = [IO.File]::Open((Join-Path $script:PythonDir 'python.exe'), 'Open', 'Read', 'None')
            try { $first = Recover-InSandbox } finally { $held.Dispose() }
            $kept = (Test-Path -LiteralPath $script:JournalFile) -and (Test-Path -LiteralPath "$($script:PythonDir).old")
            $second = Recover-InSandbox
            $differs = Compare-RegistrationState $registered (Get-RegistrationState)
            Check 'a recovery stopped by a held file refuses, keeps the journal and the kept copy, and finishes on the next attempt' (
                $first -ne 'ok' -and $kept -and $second -eq 'ok' -and $differs.Count -eq 0 -and (Get-Leftovers).Count -eq 0)

            # An untrusted journal is never read; the same journal trusted is (so the case can tell the two apart).
            function Set-AlteredJournal {
                $null = Register-InSandbox -AbandonAfter 'task'
                $j = Read-Journal
                $j.TaskXmlRaw = $j.TaskXmlRaw -replace '/c exit 0', '/c exit 7'
                $j.TaskXml = $j.TaskXml -replace '/c exit 0', '/c exit 7'
                Set-Content -LiteralPath $script:JournalFile -Value ($j | ConvertTo-Json -Depth 3) -Encoding utf8
            }
            $actionOf = { @((Get-ScheduledTask -TaskPath $script:TaskPath -TaskName $script:TaskName).Actions)[0].Arguments }
            Set-AlteredJournal
            $trust.Value = $false
            Resolve-Journal 6>$null
            $untrustedAction = & $actionOf
            $journalGone = -not (Test-Path -LiteralPath $script:JournalFile)
            Restore-Kept $script:HashFile $true; Restore-Kept $script:PythonDir $true
            $trust.Value = $true
            Set-AlteredJournal
            Resolve-Journal 6>$null
            $trustedAction = & $actionOf
            Check 'an untrusted journal is removed unread, and the same journal trusted is the one that is restored' (
                $journalGone -and $untrustedAction -eq '/c exit 0' -and $trustedAction -eq '/c exit 7')
            $null = Register-InSandbox
            $registered = Get-RegistrationState

            # While a journal is there, the outside callers refuse and start nothing; the transaction does not refuse itself.
            $null = Register-InSandbox -AbandonAfter 'task'
            $lastRun = (Get-ScheduledTaskInfo -TaskPath $script:TaskPath -TaskName $script:TaskName).LastRunTime
            $checkSaid = (Invoke-Check 6>&1 | Out-String)
            $runSaid = (Invoke-Run 6>&1 | Out-String)
            $notStarted = (Get-ScheduledTaskInfo -TaskPath $script:TaskPath -TaskName $script:TaskName).LastRunTime -eq $lastRun
            Check '-Check and -Run refuse while an interrupted registration is there, naming it, and start nothing' (
                $checkSaid -match 'an interrupted registration was found' -and $runSaid -match 'an interrupted registration was found' -and $notStarted)
            $null = Recover-InSandbox
            $plain = $script:Registration.Readiness
            $script:Registration.Readiness = { Get-RunRefusals $null @({ $verdict.Refusals }) }
            $said = Register-InSandbox
            $differs = Compare-RegistrationState $registered (Get-RegistrationState)
            $script:Registration.Readiness = $plain
            Check 'a registration whose readiness counts its own journal refuses itself and rolls back' (
                $said -match 'does not pass its readiness checks: an interrupted registration was found' -and $differs.Count -eq 0 -and
                -not (Test-Path -LiteralPath $script:JournalFile))

            # A second registration while one holds the lock is refused and touches nothing; a lock whose holder
            # died is taken, since that is the abandoned registration a journal records.
            $holder = [powershell]::Create()
            $ready = New-Object Threading.ManualResetEventSlim($false)
            $release = New-Object Threading.ManualResetEventSlim($false)
            $null = $holder.AddScript({
                param($name, $ready, $release)
                $m = New-Object Threading.Mutex($false, $name)
                $null = $m.WaitOne()
                $ready.Set()
                $null = $release.Wait(30000)
                $m.ReleaseMutex(); $m.Dispose()
            }).AddArgument($script:RegistrationLockName).AddArgument($ready).AddArgument($release)
            $running = $holder.BeginInvoke()
            try {
                $null = $ready.Wait(10000)
                $logFrom = @(Read-RegistrationLog 0).Count
                $null = Register-InSandbox -AbandonAfter 'task'
                $journalBefore = if (Test-Path -LiteralPath $script:JournalFile) { Get-Content -LiteralPath $script:JournalFile -Raw } else { $null }
                $parentRead = @(Read-RegistrationLog $logFrom)
            } finally {
                $release.Set()
                $null = $holder.EndInvoke($running)
                $holder.Dispose()
            }
            Check 'a registration started while another holds the lock is refused before it touches anything' (
                $journalBefore -eq $null -and (Compare-RegistrationState $registered (Get-RegistrationState)).Count -eq 0)
            Check 'the busy refusal of a registration reaches -Register through the log it reads' (
                $parentRead -contains (Get-BusyRefusal 'registering the elevated smoke task'))
            # The same lock keeps a run out while a registration holds it, and a run is refused before it starts anything.
            $holder = [powershell]::Create()
            $ready = New-Object Threading.ManualResetEventSlim($false)
            $release = New-Object Threading.ManualResetEventSlim($false)
            $null = $holder.AddScript({
                param($name, $ready, $release)
                $m = New-Object Threading.Mutex($false, $name)
                $null = $m.WaitOne()
                $ready.Set()
                $null = $release.Wait(30000)
                $m.ReleaseMutex(); $m.Dispose()
            }).AddArgument($script:RegistrationLockName).AddArgument($ready).AddArgument($release)
            $running = $holder.BeginInvoke()
            try {
                $null = $ready.Wait(10000)
                $lastRun = (Get-ScheduledTaskInfo -TaskPath $script:TaskPath -TaskName $script:TaskName).LastRunTime
                $runSaid = (Invoke-Run 6>&1 | Out-String)
                $notStarted = (Get-ScheduledTaskInfo -TaskPath $script:TaskPath -TaskName $script:TaskName).LastRunTime -eq $lastRun
            } finally {
                $release.Set()
                $null = $holder.EndInvoke($running)
                $holder.Dispose()
            }
            Check 'a run started while a registration holds the lock is refused, naming it, and starts nothing' (
                $runSaid.Contains((Get-BusyRefusal 'running the elevated smoke')) -and $notStarted)
            # Inside an admitted run the lock is held; when the run has returned it is free again.
            $seen = @{}
            $peek = {
                param($name)
                $m = New-Object Threading.Mutex($false, $name)
                try { $got = $m.WaitOne(0) } catch [Threading.AbandonedMutexException] { $got = $true }
                if ($got) { $m.ReleaseMutex() }
                $m.Dispose()
                return $got
            }
            function Test-LockFree([string]$Name) {
                $other = [powershell]::Create()
                try { return [bool]($other.AddScript($peek).AddArgument($Name).Invoke() | Select-Object -Last 1) } finally { $other.Dispose() }
            }
            $script:RunProbe = { $seen.Inside = Test-LockFree $script:RegistrationLockName }
            try { $null = Invoke-Run 6>$null } finally { $script:RunProbe = $null }
            $seen.After = Test-LockFree $script:RegistrationLockName
            Check 'inside an admitted run the lock is held, and when the run has returned it is free' ($seen.Inside -eq $false -and $seen.After -eq $true)

            # -Remove takes the same lock: with it held elsewhere it refuses and leaves the task in place.
            $holder = [powershell]::Create()
            $ready = New-Object Threading.ManualResetEventSlim($false)
            $release = New-Object Threading.ManualResetEventSlim($false)
            $null = $holder.AddScript({
                param($name, $ready, $release)
                $m = New-Object Threading.Mutex($false, $name)
                $null = $m.WaitOne()
                $ready.Set()
                $null = $release.Wait(30000)
                $m.ReleaseMutex(); $m.Dispose()
            }).AddArgument($script:RegistrationLockName).AddArgument($ready).AddArgument($release)
            $running = $holder.BeginInvoke()
            try {
                $null = $ready.Wait(10000)
                $removeSaid = (Invoke-Remove 6>&1 | Out-String)
                $stillThere = [bool](Get-TaskOrNull)
            } finally {
                $release.Set()
                $null = $holder.EndInvoke($running)
                $holder.Dispose()
            }
            Check '-Remove with the lock held elsewhere refuses by name and leaves the task in place' (
                $removeSaid.Contains((Get-BusyRefusal 'removing the elevated smoke task')) -and $stillThere)

            Check 'the busy refusal names the action refused and says another operation holds the lock' (
                (@('registering the elevated smoke task', 'running the elevated smoke', 'removing the elevated smoke task' | Where-Object {
                    -not ((Get-BusyRefusal $_) -match "^refused: $([regex]::Escape($_)) is not possible now: another elevated smoke operation \(a registration, a recovery, a run or a removal\) holds the lock; try again when it has finished$") })).Count -eq 0)

            Check 'a lock this process may not open counts as held' (
                $null -eq (Enter-RegistrationLock $script:RegistrationLockName { param($n) throw [UnauthorizedAccessException]::new('Access to the path is denied.') }))
            $orphan = [powershell]::Create()
            $null = $orphan.AddScript({ param($name) $m = New-Object Threading.Mutex($false, $name); $null = $m.WaitOne() }).AddArgument($script:RegistrationLockName)
            $null = $orphan.Invoke()
            $orphan.Dispose()
            $taken = Enter-RegistrationLock $script:RegistrationLockName
            Check 'a lock whose holder ended without releasing it is taken' ($null -ne $taken)
            if ($taken) { $taken.ReleaseMutex(); $taken.Dispose() }

            # A committed registration's leftover does not stop the next one.
            New-Item -ItemType Directory -Path "$($script:PythonDir).old" | Out-Null
            Set-Content (Join-Path "$($script:PythonDir).old" 'python.exe') 'left behind'
            $said = Register-InSandbox
            Check 'a replacement that passes takes the new runtime and keeps no spare copy, a committed leftover included' (
                $said -eq 'ok' -and (Get-Content (Join-Path $script:PythonDir 'python.exe')) -eq 'runtime two' -and (Get-Leftovers).Count -eq 0 -and
                -not (Test-Path -LiteralPath $script:JournalFile))
        } finally {
            if (Get-TaskOrNull) { Unregister-ScheduledTask -TaskPath $script:TaskPath -TaskName $script:TaskName -Confirm:$false }
            foreach ($name in $saved.Keys) { Set-Variable -Scope Script -Name $name -Value $saved[$name] }
        }
        Check 'the sandbox task is gone and the real task was never touched' (
            -not (Get-ScheduledTask -TaskName 'ResoluteSelfTest-*' -ErrorAction SilentlyContinue) -and $TaskName -eq 'ElevatedSmoke' -and $HashDir -eq 'C:\ProgramData\Resolute\ElevatedSmoke')

        # Every refusal the elevated copy can give before its directory exists has a code -Register can read.
        Check 'each early refusal of the elevated copy has its own exit code and message, and other codes have none' (
            (@(10, 11, 12, 13, 14 | Where-Object { -not ((Get-RefusalForExitCode $_) -match '^refused: ') })).Count -eq 0 -and
            (Get-RefusalForExitCode 2) -eq '' -and (Get-RefusalForExitCode 0) -eq '' -and
            (Get-RefusalForExitCode 14) -eq (Get-BusyRefusal 'registering the elevated smoke task'))
        # What the operator's window shows, read from the output itself.
        $savedLog = $script:RegisterLog
        try {
            $script:RegisterLog = Join-Path $td 'no-log-here.txt'
            $shown = @(Write-ElevatedOutcome 12 0 6>&1)
            $answer = @($shown | Where-Object { $_ -is [int] })
            $text = ($shown | Where-Object { $_ -isnot [int] } | ForEach-Object { "$_" }) -join "`n"
            Check '-Register shows the refusal its exit code names when the elevated copy left no log, and fails' (
                $text.Contains("elevated: $(Get-RefusalForExitCode 12)") -and $answer.Count -eq 1 -and $answer[0] -eq 12)
            $script:RegisterLog = Join-Path $td 'a-log.txt'
            Set-Content -LiteralPath $script:RegisterLog -Value 'refused: what the elevated copy said itself'
            $shown = @(Write-ElevatedOutcome 12 0 6>&1)
            $text = ($shown | Where-Object { $_ -isnot [int] } | ForEach-Object { "$_" }) -join "`n"
            Check '-Register shows what the elevated copy logged, and not the exit code''s refusal on top of it' (
                $text.Contains('elevated: refused: what the elevated copy said itself') -and -not $text.Contains((Get-RefusalForExitCode 12)))
        } finally {
            $script:RegisterLog = $savedLog
        }

        # -Register answers from an existing task only when no interrupted registration is waiting for it.
        Check '-Register goes on to recover an interrupted registration even when a task is there and -Replace is not given' (
            (Test-KeepsExistingTask $true $false $false) -and -not (Test-KeepsExistingTask $true $false $true) -and
            -not (Test-KeepsExistingTask $true $true $false) -and -not (Test-KeepsExistingTask $false $false $false))

        # A journal is trusted only in a directory that passes its checks and owned by Administrators or SYSTEM.
        Check 'a journal is trusted only in a protected directory and owned by Administrators or SYSTEM' (
            (Test-JournalTrusted @() $AdminsSid) -and (Test-JournalTrusted @() $SystemSid) -and
            -not (Test-JournalTrusted @() 'S-1-5-21-1-2-3-1001') -and -not (Test-JournalTrusted @('C:\x is owned by someone') $AdminsSid))

        # The task restoration the rollback relies on, run for real on a throwaway task of this account
        # (limited privilege, an action that only exits, no trigger), which is removed before the case ends.
        $scratchName = 'ResoluteSelfTest-' + [Guid]::NewGuid().ToString('N')
        $restored = $false
        try {
            $one = New-ScheduledTaskAction -Execute (Join-Path $env:SystemRoot 'System32\cmd.exe') -Argument '/c exit 0'
            $two = New-ScheduledTaskAction -Execute (Join-Path $env:SystemRoot 'System32\cmd.exe') -Argument '/c exit 1'
            Register-ScheduledTask -TaskPath '\' -TaskName $scratchName -Action $one -RunLevel Limited -ErrorAction Stop | Out-Null
            $priorScratch = Export-ScheduledTask -TaskPath '\' -TaskName $scratchName
            Register-ScheduledTask -TaskPath '\' -TaskName $scratchName -Action $two -RunLevel Limited -Force -ErrorAction Stop | Out-Null
            $changed = @((Get-ScheduledTask -TaskPath '\' -TaskName $scratchName).Actions)[0].Arguments
            Restore-Task '\' $scratchName $priorScratch
            $back = @((Get-ScheduledTask -TaskPath '\' -TaskName $scratchName).Actions)[0].Arguments
            $restored = ($changed -eq '/c exit 1' -and $back -eq '/c exit 0')
        } catch {
            Write-Host "the throwaway task could not be used: $($_.Exception.Message)"
        } finally {
            Unregister-ScheduledTask -TaskPath '\' -TaskName $scratchName -Confirm:$false -ErrorAction SilentlyContinue
        }
        Check 'a replaced task is put back from its exported definition, on a real throwaway task' $restored
        Check 'the throwaway task is gone' (-not (Get-ScheduledTask -TaskName $scratchName -ErrorAction SilentlyContinue))

        # A rollback is judged by reading the state back, field by field.
        $was = [pscustomobject]@{ Task = 'xml'; Hashes = 'h'; Python = 'p'; DirectorySddl = 'd' }
        $now = [pscustomobject]@{ Task = 'xml'; Hashes = 'other'; Python = 'p'; DirectorySddl = 'd' }
        Check 'a rollback that left the pinned hashes changed is named, an exact restoration is not' (
            ((Compare-RegistrationState $was $now) -join ',') -eq 'Hashes' -and (Compare-RegistrationState $was $was).Count -eq 0)

        # Who may change the task: a descriptor that lets another principal write is refused, a reader is not.
        Check 'a task descriptor that lets Authenticated Users write names them, one that lets them read does not' (
            ((Get-SddlExtraWriters 'D:(A;;FA;;;BA)(A;;FA;;;SY)(A;;FA;;;AU)' @($AdminsSid, $SystemSid)) -join ',') -eq 'S-1-5-11' -and
            (Get-SddlExtraWriters 'D:(A;;FA;;;BA)(A;;FA;;;SY)(A;;FR;;;AU)' @($AdminsSid, $SystemSid)).Count -eq 0)

        # Who may write: a principal beyond the allowed ones is named.
        $rules = @(
            [pscustomobject]@{ Sid = $AdminsSid; Name = 'BUILTIN\Administrators'; Writes = $true },
            [pscustomobject]@{ Sid = 'S-1-5-11'; Name = 'NT AUTHORITY\Authenticated Users'; Writes = $true },
            [pscustomobject]@{ Sid = 'S-1-5-32-545'; Name = 'BUILTIN\Users'; Writes = $false }
        )
        $extra = Get-ExtraWriters $rules @($AdminsSid, $SystemSid)
        Check 'a writer beyond the allowed principals is named, a reader is not' ($extra.Count -eq 1 -and $extra[0] -match 'Authenticated Users \(S-1-5-11\)')
        Check 'allowed writers alone pass' ((Get-ExtraWriters $rules[0, 2] @($AdminsSid, $SystemSid)).Count -eq 0)

        # Line endings: a CRLF copy of the committed bytes is drift, the bytes themselves are not.
        $blob = [Text.Encoding]::ASCII.GetBytes("one`ntwo`n")
        Check 'a CRLF copy of the committed driver is refused, the committed bytes are accepted' (
            (Test-LineEndingDrift ([Text.Encoding]::ASCII.GetBytes("one`r`ntwo`r`n")) $blob) -and
            -not (Test-LineEndingDrift $blob $blob) -and
            -not (Test-LineEndingDrift ([Text.Encoding]::ASCII.GetBytes("one`nthree`n")) $blob))

        # A queued instance is stopped like a running one; a ready task is left.
        Check 'running and queued need a stop, ready does not' ((Test-TaskNeedsStop 'Running') -and (Test-TaskNeedsStop 'Queued') -and -not (Test-TaskNeedsStop 'Ready'))

        # Rollback: a step that throws does not stop the next, and is named.
        $ran = @()
        $notRestored = Invoke-RollbackSteps @({ throw 'task restore failed' }, { $script:ran += 'hashes' })
        Check 'rollback runs every step and names the one that failed' (($script:ran -join ',') -eq 'hashes' -and $notRestored.Count -eq 1 -and $notRestored[0] -match 'task restore failed')
    } finally {
        Remove-Item $td -Recurse -Force -ErrorAction SilentlyContinue
    }
    if ($script:failures.Count) {
        Write-Host ("self-test: FAIL " + ($script:failures -join ', '))
        return 1
    }
    Write-Host 'self-test: all pass'
    return 0
}

function Write-ElevatedOutcome([int]$ExitCode, [int]$LogFrom) {
    # What the operator's window shows once the elevated copy has exited:
    # what that copy said, from the log it keeps; when that log has nothing
    # new, the refusal its exit code names (a refusal given before the
    # directory existed); and the failure. Returns the copy's exit code.
    $said = @(Read-RegistrationLog $LogFrom)
    $said | ForEach-Object { Write-Host "elevated: $_" }
    $reason = Get-RefusalForExitCode $ExitCode
    if ($reason -and -not $said) { Write-Host "elevated: $reason" }
    if ($ExitCode -ne 0) { Write-Host "refused: elevated registration failed with exit code $ExitCode; nothing is registered by this run" }
    return $ExitCode
}

function Read-RegistrationLog([int]$From) {
    # What the elevated copy said since line $From, for -Register to print:
    # that copy runs in a console of its own, which closes when it exits.
    # A log that cannot be read is said, and read as empty, so the exit
    # code's refusal is what the operator sees: the log never decides.
    if (-not (Test-Path -LiteralPath $RegisterLog)) { return @() }
    try {
        return @(@(Get-Content -LiteralPath $RegisterLog -ErrorAction Stop) | Select-Object -Skip $From)
    } catch {
        Write-Host "the registration log could not be read ($($_.Exception.Message)); the exit code still says the outcome"
        return @()
    }
}

function Write-Registration([string]$Line) {
    # The elevated copy runs in a window of its own, so what it says is
    # also kept in the protected directory for -Register to print.
    Write-Host $Line
    if (-not (Test-Path -LiteralPath $HashDir)) { return }
    try {
        Add-Content -LiteralPath $RegisterLog -Value $Line
    } catch {
        # The log is a second copy for -Register to read; the exit code is the
        # answer. A log that cannot be written is said here, and the caller
        # returns what it was going to return.
        Write-Host "the registration log could not be written ($($_.Exception.Message)); the exit code still says the outcome"
    }
}

function Get-RegistrationState {
    # What a rollback must put back, in a form two readings can compare.
    $task = Get-TaskOrNull
    return [pscustomobject]@{
        Task = if ($task) { (Export-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName) -replace '\s+', ' ' } else { '' }
        Hashes = if (Test-Path -LiteralPath $HashFile) { (Get-Content -LiteralPath $HashFile -Raw).Trim() } else { '' }
        Python = if (Test-Path -LiteralPath (Join-Path $PythonDir 'python.exe')) { (Get-FileHash -LiteralPath (Join-Path $PythonDir 'python.exe')).Hash } else { '' }
        DirectorySddl = if (Test-Path -LiteralPath $HashDir) { (Get-Acl -LiteralPath $HashDir).Sddl } else { '' }
    }
}

function Compare-RegistrationState($Before, $After) {
    # The names of what differs; empty when a rollback restored everything.
    $differs = @()
    foreach ($name in 'Task', 'Hashes', 'Python', 'DirectorySddl') {
        if ($Before.$name -ne $After.$name) { $differs += $name }
    }
    return ,$differs
}

function Invoke-ProveRollback {
    # Elevated. Fails a registration on purpose after it has registered the
    # task and switched the new hashes and runtime in, the furthest point a
    # rollback has to come back from, and reads back that the previous
    # task, hashes, runtime and directory permissions are what they were.
    $before = Get-RegistrationState
    $failed = $false
    try {
        $script:FailAfterStep = 'commit'
        [void](Invoke-RegisterElevated)
    } catch {
        $failed = $true
        Write-Registration "rollback proof: the registration failed as injected ($($_.Exception.Message))"
    } finally {
        $script:FailAfterStep = ''
    }
    if (-not $failed) { Write-Registration 'rollback proof: REFUSED, the injected failure did not fail the registration'; return 2 }
    $differs = Compare-RegistrationState $before (Get-RegistrationState)
    if ($differs.Count) { Write-Registration ("rollback proof: REFUSED, not restored: " + ($differs -join ', ')); return 2 }
    Write-Registration 'rollback proof: the previous task, pinned hashes, runtime and directory permissions were read back unchanged'
    return 0
}

function Invoke-ElevatedRegistration {
    # The elevated registration as both entries reach it: the copy -Register
    # starts through the consent prompt, and -Register run from a shell that
    # is elevated already. The rollback proof, when asked for, comes first
    # on both, and a registration is not attempted when the proof refuses.
    if ($ProveRollback) {
        $proofCode = Invoke-ProveRollback
        if ($proofCode -ne 0) { return $proofCode }
    }
    try {
        return (Invoke-RegisterElevated)
    } catch {
        Write-Registration "registration failed: $($_.Exception.Message)"
        return 2
    }
}

function Get-RefusalForExitCode([int]$Code) {
    # What the elevated copy refused, from its exit code alone; nothing for a
    # code it does not give.
    if ($RefusalCodes.Contains($Code)) { return $RefusalCodes[$Code] }
    return ''
}

function Get-BusyRefusal([string]$Action) {
    # The one refusal every holder of the lock gives: it says what was refused
    # and what holds the lock, which is one of four operations and is not
    # worth a subsystem to name exactly.
    return "refused: $Action is not possible now: another elevated smoke operation (a registration, a recovery, a run or a removal) holds the lock; try again when it has finished"
}

function Enter-RegistrationLock([string]$Name, [scriptblock]$Open = { param($n) New-Object Threading.Mutex($false, $n) }) {
    # The lock, taken at once or not at all. A mutex whose holder died is
    # taken too: that is the abandoned registration a journal records. One
    # this process may not even open is held by an elevated registration
    # (a named mutex exists only while something holds it), so it is busy.
    try {
        $mutex = & $Open $Name
    } catch [UnauthorizedAccessException] {
        return $null
    } catch {
        if ($_.Exception.InnerException -is [UnauthorizedAccessException]) { return $null }
        throw
    }
    try {
        if ($mutex.WaitOne(0)) { return $mutex }
    } catch [Threading.AbandonedMutexException] {
        return $mutex
    }
    $mutex.Dispose()
    return $null
}

function Invoke-RegisterElevated {
    # The registration transaction, run under the machine-wide lock: a
    # second registration started meanwhile is refused instead of taking
    # the first one's journal for an abandoned one and undoing it.
    $lock = Enter-RegistrationLock $script:RegistrationLockName
    if (-not $lock) { Write-Registration (Get-BusyRefusal 'registering the elevated smoke task'); return 14 }
    try {
        return (Invoke-RegistrationTransaction)
    } finally {
        $lock.ReleaseMutex()
        $lock.Dispose()
    }
}

function Invoke-RegistrationTransaction {
    # One transaction. It prepares everything beside what is live (the new
    # Python, the new pinned hashes), registers the task, switches the new
    # files in while keeping the previous ones, and then asks the same
    # readiness list a run is refused on. Only when that passes are the kept
    # copies dropped. A failure anywhere before that, the readiness refusal
    # included, puts back the previous task, hashes, runtime and directory
    # permissions. Exit code says the outcome.
    $mode = $script:Registration
    if ($mode.RequireElevation -and -not (Test-IsElevated)) { Write-Registration 'refused: the registration copy is not elevated'; return 10 }
    function Step([string]$Name) { Invoke-StepPoint $Name }
    if ($OperatorSid -and $OperatorSid -ne (Get-CurrentSid)) {
        # Consent given with another administrator's credentials: this copy
        # runs as that administrator, so the task and the HKCU it reads would
        # be theirs, and the operator's -Run could never feed it.
        Write-Registration "refused: the consent was given as another account ($([Security.Principal.WindowsIdentity]::GetCurrent().Name)); the task must run as the account that asked for it. Sign in as an administrator, or give this account administrator rights, and register again"
        return 11
    }
    $pinnedPython = & $mode.Source
    if (-not (Test-Path (Join-Path $pinnedPython 'python.exe'))) {
        Write-Registration "refused: the pinned Python is not installed at $pinnedPython (run pwsh scripts/bootstrap.ps1)"
        return 12
    }
    $prior = Get-TaskOrNull
    if ($prior -and (Test-TaskNeedsStop $prior.State)) {
        Write-Registration 'refused: the elevated smoke task is running or queued; let it finish or run -Remove first'
        return 13
    }
    # An earlier registration that never reached its commit comes first.
    Resolve-Journal
    # With no journal, kept copies are a committed registration's leftovers.
    foreach ($leftover in "$HashFile.old", "$PythonDir.old") {
        if (Test-Path -LiteralPath $leftover) {
            Remove-Item -LiteralPath $leftover -Recurse -Force
            Write-Registration "removed a committed registration's leftover: $leftover"
        }
    }
    $prior = Get-TaskOrNull
    $priorXml = $null
    if ($prior) { $priorXml = Export-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName }
    $hadHashDir = Test-Path -LiteralPath $HashDir
    $hadHashes = Test-Path -LiteralPath $HashFile
    $hadRuntime = Test-Path -LiteralPath $PythonDir
    $priorDirSddl = if ($hadHashDir) { (Get-Acl -LiteralPath $HashDir).Sddl } else { $null }
    $parentDir = Split-Path $HashDir -Parent
    $priorParentOwner = if (Test-Path -LiteralPath $parentDir) { (Get-Acl -LiteralPath $parentDir).GetOwner([Security.Principal.SecurityIdentifier]).Value } else { $null }
    $removedEntries = @()
    $newPython = "$PythonDir.new"
    $newHashes = "$HashFile.new"
    $switchedHashes = $false
    $switchedRuntime = $false
    try {
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel $mode.RunLevel
        if ($mode.Action) {
            $action = $mode.Action
        } else {
            $expected = Get-ExpectedAction $Root
            $action = New-ScheduledTaskAction -Execute $expected.Execute -Argument $expected.Argument -WorkingDirectory $expected.WorkingDirectory
        }
        New-Item -ItemType Directory -Force -Path $HashDir | Out-Null
        if ($mode.Protect) {
            # The directory itself: Administrators and SYSTEM write, Users read,
            # inherited by everything under it and nothing inherited from
            # ProgramData, which lets ordinary users create files in a new folder.
            $dacl = New-Object Security.AccessControl.DirectorySecurity
            $dacl.SetAccessRuleProtection($true, $false)
            foreach ($sid in $AdminsSid, $SystemSid) {
                $dacl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule(
                    (New-Object Security.Principal.SecurityIdentifier($sid)), 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow')))
            }
            $dacl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule(
                (New-Object Security.Principal.SecurityIdentifier('S-1-5-32-545')), 'ReadAndExecute', 'ContainerInherit, ObjectInherit', 'None', 'Allow')))
            # Administrators own it and everything in it: an ordinary account that
            # created this folder first would otherwise keep the right to rewrite
            # the ACL just set. The folder that holds it gets the same owner
            # when its own is not already Administrators or SYSTEM.
            $dacl.SetOwner((New-Object Security.Principal.SecurityIdentifier($AdminsSid)))
            Set-Acl -Path $HashDir -AclObject $dacl
            if (-not (Test-TrustedOwner (Get-Acl -LiteralPath $parentDir).GetOwner([Security.Principal.SecurityIdentifier]).Value)) {
                $parentAcl = Get-Acl -LiteralPath $parentDir
                $parentAcl.SetOwner((New-Object Security.Principal.SecurityIdentifier($AdminsSid)))
                Set-Acl -LiteralPath $parentDir -AclObject $parentAcl
            }
            & icacls.exe $HashDir /setowner "*$AdminsSid" /T /C /Q | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "icacls could not give Administrators ownership of everything under $HashDir (exit $LASTEXITCODE)" }
        }
        # Whatever is here that registration did not put here was put by
        # someone else while the folder was open to them: it goes.
        foreach ($entry in Get-ChildItem -LiteralPath $HashDir -Force) {
            if ($KnownEntries -notcontains $entry.Name) {
                Write-Registration "removed an unexpected entry from ${HashDir}: $($entry.Name)"
                $removedEntries += $entry.Name
                Remove-Item -LiteralPath $entry.FullName -Recurse -Force
            }
        }
        # The run directory is rebuilt, so nothing staged before the folder
        # was protected is still there, and it takes the inherited ACL.
        $runDir = Split-Path $SnapshotDir -Parent
        if (Test-Path $runDir) { Remove-Item -LiteralPath $runDir -Recurse -Force }
        New-Item -ItemType Directory -Force -Path $SnapshotDir | Out-Null
        Step 'directory'
        # What was here before, written before anything it describes changes.
        Write-Journal ([pscustomobject]@{
            HadDir = $hadHashDir
            HadTask = [bool]$priorXml
            TaskXml = if ($priorXml) { $priorXml -replace '\s+', ' ' } else { '' }
            TaskXmlRaw = if ($priorXml) { $priorXml } else { '' }
            HadHashes = $hadHashes
            HashesText = if ($hadHashes) { (Get-Content -LiteralPath $HashFile -Raw).Trim() } else { '' }
            HadRuntime = $hadRuntime
            RuntimeHash = if (Test-Path -LiteralPath (Join-Path $PythonDir 'python.exe')) { (Get-FileHash -LiteralPath (Join-Path $PythonDir 'python.exe')).Hash } else { '' }
        }) $mode.Protect
        # The new runtime and the new pinned hashes are written beside the
        # live ones, which are not touched until the switch below. The
        # hashes are read back before anything depends on them.
        if (Test-Path -LiteralPath $newPython) { Remove-Item -LiteralPath $newPython -Recurse -Force }
        Copy-Item -LiteralPath $pinnedPython -Destination $newPython -Recurse
        if (-not (Test-Path -LiteralPath (Join-Path $newPython 'python.exe'))) { throw "the copy of the runtime at $newPython has no python.exe" }
        $lines = @(foreach ($rel in $DriverFiles) {
            '{0}  {1}' -f (Get-FileHash -Algorithm SHA256 -Path (Join-Path $Root $rel)).Hash, $rel
        })
        if (Test-Path -LiteralPath $newHashes) { Remove-Item -LiteralPath $newHashes -Force }
        Set-Content -LiteralPath $newHashes -Value $lines
        if ((@(Get-Content -LiteralPath $newHashes) -join "`n") -ne ($lines -join "`n")) { throw "the pinned hashes written to $newHashes did not read back as written" }
        Step 'hashes'
        Register-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Action $action -Principal $principal `
            -Description 'Resolute unattended elevated smoke (D07 T01 S7). Fixed action, hash-pinned driver; remove with tools/elevated-smoke.ps1 -Remove.' -Force | Out-Null
        Step 'task'
        # The switch. The previous hashes and runtime are kept as *.old. Each
        # flag is set before its switch, because Undo-Switch is right from
        # any point inside one.
        $switchedHashes = $true
        Switch-Path $newHashes $HashFile -Label 'hashes'
        $switchedRuntime = $true
        Switch-Path $newPython $PythonDir -Label 'runtime'
        Step 'commit'
        # The same list a run is refused on. A registration that would not
        # be allowed to run is not a registration: it is rolled back.
        # Flattened: a readiness check may hand back its list as one array.
        $refusals = @(& $mode.Readiness | ForEach-Object { $_ } | Where-Object { $_ })
        if ($refusals) { throw ("the registration does not pass its readiness checks: " + ($refusals -join '; ')) }
        Write-Registration "python: $((Get-FileHash -Algorithm SHA256 -Path (Join-Path $PythonDir 'python.exe')).Hash) $(Join-Path $PythonDir 'python.exe')"
        foreach ($line in $lines) { Write-Registration "pinned: $line" }
        Step 'report'
        # The commit: with the journal gone, what is live is the registration.
        Remove-Item -LiteralPath $JournalFile -Force
    } catch {
        # The self-test's stand-in for a killed process leaves as one would:
        # without the rollback, so the next registration has to recover.
        if ($_.Exception.Message -like "abandoned after step '*'") { throw }
        # Roll back. Every step runs whatever the others do, and a step that
        # fails is said beside the original error.
        $cause = $_
        $notRestored = Invoke-RollbackSteps @(
            {
                if ($priorXml) {
                    Restore-Task $TaskPath $TaskName $priorXml
                } elseif (Get-TaskOrNull) {
                    Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false -ErrorAction Stop
                }
            },
            {
                if ($switchedHashes) { Undo-Switch $HashFile $hadHashes }
                if (Test-Path -LiteralPath $newHashes) { Remove-Item -LiteralPath $newHashes -Force -ErrorAction Stop }
            },
            {
                if ($switchedRuntime) { Undo-Switch $PythonDir $hadRuntime }
                if (Test-Path -LiteralPath $newPython) { Remove-Item -LiteralPath $newPython -Recurse -Force -ErrorAction Stop }
            },
            {
                # The directory's owner and permissions as they were, and the
                # owner of the folder that holds it when this run changed it.
                if ($mode.Protect -and $priorDirSddl -and (Test-Path -LiteralPath $HashDir)) {
                    $was = Get-Acl -LiteralPath $HashDir
                    $was.SetSecurityDescriptorSddlForm($priorDirSddl)
                    Set-Acl -LiteralPath $HashDir -AclObject $was -ErrorAction Stop
                }
                if ($mode.Protect -and $priorParentOwner -and (Test-Path -LiteralPath $parentDir) -and
                    (Get-Acl -LiteralPath $parentDir).GetOwner([Security.Principal.SecurityIdentifier]).Value -ne $priorParentOwner) {
                    $was = Get-Acl -LiteralPath $parentDir
                    $was.SetOwner((New-Object Security.Principal.SecurityIdentifier($priorParentOwner)))
                    Set-Acl -LiteralPath $parentDir -AclObject $was -ErrorAction Stop
                }
                if (-not $hadHashDir -and (Test-Path -LiteralPath $HashDir)) { Remove-Item -LiteralPath $HashDir -Recurse -Force -ErrorAction Stop }
            }
        )
        if ($notRestored.Count) {
            Write-Host ("rollback incomplete: " + ($notRestored -join '; ') + "; the journal is left, so the next registration recovers what this one could not")
        } elseif (Test-Path -LiteralPath $JournalFile) {
            Remove-Item -LiteralPath $JournalFile -Force
        }
        # What a rollback does not undo, said so nobody has to find it.
        if ($hadHashDir) {
            $kept = "not restored by the rollback: the run directory's staged copies (the next run stages them again), and Administrators' ownership of the files inside $HashDir"
            if ($removedEntries) { $kept += "; and the entries removed as unexpected, which are gone: " + ($removedEntries -join ', ') }
            try { Write-Registration $kept } catch { Write-Host $kept }
        }
        throw $cause
    }
    # Committed. The kept copies go; one that cannot be removed is a note.
    foreach ($live in $HashFile, $PythonDir) {
        $note = Remove-Kept $live
        if ($note) { try { Write-Registration $note } catch { Write-Host $note } }
    }
    return 0
}

function Confirm-Registration([string[]]$Refusals) {
    # The one way a registration is reported as done: the same list of
    # reasons a run would be refused on must be empty. Every path through
    # -Register ends here, so none can report success on less.
    if ($Refusals) { Write-Host ("refused: the registration does not pass its own readiness checks: " + ($Refusals -join '; ')); return 2 }
    foreach ($line in Get-DriverWriters $Root) { Write-Host "driver: $line" }
    Write-Host "task security descriptor: $(Get-TaskSddl)"
    Write-Host 'registered: the task, its directory, its security and its pinned hashes pass the readiness checks'
    return 0
}

function Test-KeepsExistingTask([bool]$TaskExists, [bool]$Replace, [bool]$Interrupted) {
    # Whether -Register may answer from the task that is there. Not when an
    # interrupted registration is waiting: only a registration recovers it,
    # and the refusal -Check and -Run give says to run -Register.
    return ($TaskExists -and -not $Replace -and -not $Interrupted)
}

function Invoke-Register {
    $existing = Get-TaskOrNull
    if (Test-KeepsExistingTask ([bool]$existing) ([bool]$Replace) (Test-Path -LiteralPath $JournalFile)) {
        $refusals = Get-RunRefusals $existing
        if (-not $refusals) { return (Confirm-Registration @()) }
        Write-Host ("refused: an existing task differs and is preserved: " + ($refusals -join '; '))
        Write-Host 're-run with -Register -Replace to consent to overwriting it'
        return 2
    }
    # Before any prompt: a pin taken over bytes git would not write breaks
    # by itself later, so it is refused here, by name.
    $drift = @(Get-DriftRefusals $Root)
    if ($drift) { Write-Host ("refused: " + ($drift -join '; ')); return 2 }
    if (& $script:Registration.IsElevated) {
        $code = Invoke-ElevatedRegistration
        if ($code -ne 0) { return $code }
    } else {
        Write-Host 'registration needs one consent prompt; approving it registers the task and pins the driver hashes'
        $args = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -RegisterElevated -OperatorSid $(Get-CurrentSid) -Root `"$Root`""
        if ($ProveRollback) { $args += ' -ProveRollback' }
        $logFrom = @(Read-RegistrationLog 0).Count
        try {
            $proc = & $script:Registration.Launch $args
        } catch {
            Write-Host "blocked: elevation consent declined or the elevated registration could not start: $($_.Exception.Message)"
            return 2
        }
        # What the elevated copy said, from the log it keeps in the protected directory.
        if ((Write-ElevatedOutcome $proc.ExitCode $logFrom) -ne 0) { return 2 }
    }
    return (Confirm-Registration (Get-RunRefusals (Get-TaskOrNull)))
}

function Get-TransactionRefusals([scriptblock[]]$Checks = $null) {
    # The readiness a registration asks itself, while its own journal is
    # still there: every reason a run may not start, but that one.
    return (Get-RunRefusals (Get-TaskOrNull) $Checks -InTransaction)
}

function Get-RunRefusals($Task, [scriptblock[]]$Checks = $null, [switch]$InTransaction) {
    # Every reason the task may not be started, in one place. -Check reports
    # this list and -Run refuses on it, so the launch path cannot be missing
    # a check the readiness answer has.
    if (-not $Checks) {
        $Checks = @(
            { Test-PinnedHashes $Root $HashFile },
            { if (-not $Task) { 'task not registered (run tools/elevated-smoke.ps1 -Register first)' } },
            { if ($Task) { Test-DefinitionMatch $Task $Root } },
            { if (-not (Test-Path (Join-Path $PythonDir 'python.exe'))) { "the task's Python is missing from $PythonDir (register again)" } },
            { Get-DirectoryRefusals },
            { if ($Task) { Get-TaskSecurityRefusals } }
        )
    }
    $refusals = @()
    foreach ($check in $Checks) { $refusals += @(& $check) }
    if (-not $InTransaction -and (Test-Path -LiteralPath $JournalFile)) {
        $refusals += "an interrupted registration was found ($JournalFile): run tools/elevated-smoke.ps1 -Register to recover it"
    }
    return ,@($refusals | Where-Object { $_ })
}

function Invoke-Check {
    # The refusals -Run would give before it starts anything, so a launcher can ask for a new registration while
    # the operator is still at the keyboard to consent (scripts/start-unattended-run.ps1). Read-only.
    $refusals = Get-RunRefusals (Get-TaskOrNull)
    if ($refusals) { Write-Host ("not ready: " + ($refusals -join '; ')); return 2 }
    Write-Host 'ready: the task is registered for this checkout and the pinned driver hashes match'
    return 0
}

function Invoke-Run {
    # The whole run, from its readiness check to its end, under the lock a
    # registration takes: neither can begin while the other is under way.
    $lock = Enter-RegistrationLock $script:RegistrationLockName
    if (-not $lock) { Write-Host (Get-BusyRefusal 'running the elevated smoke'); return 2 }
    try {
        return (Invoke-RunUnderLock)
    } finally {
        $lock.ReleaseMutex()
        $lock.Dispose()
    }
}

function Invoke-RunUnderLock {
    # The self-test's look at the lock from inside a run; nothing else sets it.
    if ($script:RunProbe) { & $script:RunProbe }
    $task = Get-TaskOrNull
    $refusals = Get-RunRefusals $task
    if ($refusals) { Write-Host ("refused: " + ($refusals -join '; ')); return 2 }
    if (Test-TaskNeedsStop $task.State) { Write-Host "refused: the elevated smoke task is already $($task.State)"; return 2 }

    # The run manifest: what this run may launch elevated, recorded by the
    # operator's own account in the operator's own hive. The elevated driver
    # stages each executable, verifies the copy against this, and runs the copy.
    $listed = @(& python (Join-Path $Root 'scripts\smoke-run.py') --list-tools)
    if ($LASTEXITCODE -ne 0 -or -not $listed) { Write-Host 'refused: the smoke driver could not list its tools'; return 2 }
    New-Item -Path $ManifestKey -Force | Out-Null
    $writers = Get-ExtraWriters (Get-KeyWriteRules $ManifestKey) @(
        [Security.Principal.WindowsIdentity]::GetCurrent().User.Value, $AdminsSid, $SystemSid)
    if ($writers.Count) {
        Write-Host ("refused: the run manifest key can be written by another principal: " + ($writers -join ', '))
        return 2
    }
    foreach ($name in @((Get-Item $ManifestKey).GetValueNames())) { Remove-ItemProperty -Path $ManifestKey -Name $name }
    foreach ($line in $listed) {
        $name, $exe = $line -split "`t", 2
        if (-not (Test-Path -LiteralPath $exe)) { Write-Host "refused: $name is not built ($exe)"; return 2 }
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $exe).Hash
        Set-ItemProperty -Path $ManifestKey -Name $name -Value $hash
        Write-Host "manifest: $hash  $name"
    }

    $reportPath = Join-Path $Root 'build\smoke\smoke-report.md'
    $envPath = $EnvFile
    $started = Get-Date
    $completed = $false
    try {
        Start-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
        $ackDeadline = [DateTime]::UtcNow.AddSeconds($AckTimeoutSec)
        $acked = $false
        while ([DateTime]::UtcNow -lt $ackDeadline) {
            $t = Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
            $info = Get-ScheduledTaskInfo -TaskPath $TaskPath -TaskName $TaskName
            if ($t.State -eq 'Running' -or $info.LastRunTime -ge $started.AddSeconds(-2)) { $acked = $true; break }
            Start-Sleep -Milliseconds 500
        }
        if (-not $acked) { Write-Host "blocked: task start not acknowledged within ${AckTimeoutSec}s"; return 2 }

        $runDeadline = [DateTime]::UtcNow.AddSeconds($RunTimeoutSec)
        while ([DateTime]::UtcNow -lt $runDeadline) {
            $t = Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
            if ($t.State -ne 'Running') { $completed = $true; break }
            Start-Sleep -Seconds 2
        }
        if (-not $completed) {
            Write-Host "blocked: task did not finish within ${RunTimeoutSec}s; cleanup follows"
            return 2
        }
        $info = Get-ScheduledTaskInfo -TaskPath $TaskPath -TaskName $TaskName
        $envVerdict = if (Test-Path $envPath) { (Get-Content $envPath -Raw).Trim() } else { 'missing environment verdict file' }
        $refusals = Test-Report $reportPath $started $info.LastTaskResult $envVerdict
        if ($refusals) {
            Write-Host ("blocked: " + ($refusals -join '; '))
            Get-Content $reportPath -ErrorAction SilentlyContinue | Write-Host
            return 2
        }
        Write-Host "LastTaskResult: $($info.LastTaskResult)"
        Write-Host "environment verdict: $envVerdict"
        Write-Host 'pinned hashes: match'
        Get-Content $reportPath | Write-Host
        return 0
    } finally {
        if (-not $completed) {
            $t = Get-TaskOrNull
            if ($t -and (Test-TaskNeedsStop $t.State)) {
                if (Stop-OwnedTask) {
                    Write-Host 'cleanup: task stopped and confirmed'
                } else {
                    Write-Host 'cleanup unconfirmed: the task or its driver processes may still be running'
                }
            }
        }
    }
}

function Invoke-Remove {
    # Under the same lock: a removal between a registration's readiness check
    # and its commit would leave that registration reporting a task that is gone.
    $lock = Enter-RegistrationLock $script:RegistrationLockName
    if (-not $lock) { Write-Host (Get-BusyRefusal 'removing the elevated smoke task'); return 2 }
    try {
        return (Invoke-RemoveUnderLock)
    } finally {
        $lock.ReleaseMutex()
        $lock.Dispose()
    }
}

function Invoke-RemoveUnderLock {
    $task = $null
    try {
        $task = Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction Stop
    } catch {
        if ($_.Exception.Message -match 'No matching|0x80070002|does not exist') {
            Write-Host 'already absent: no ElevatedSmoke task is registered'
            return 0
        }
        if ($_.Exception.Message -match 'Access is denied|0x80070005') {
            Write-Host "refused: access denied reading the task: $($_.Exception.Message)"
            return 2
        }
        Write-Host "refused: scheduler readback failed: $($_.Exception.Message)"
        return 2
    }
    if (Test-TaskNeedsStop $task.State) {
        if (-not (Stop-OwnedTask)) {
            Write-Host 'refused: cleanup unconfirmed; the running or queued task was not removed'
            return 2
        }
        Write-Host 'stopped: running or queued task confirmed stopped before removal'
    }
    Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false
    if (Get-TaskOrNull) { Write-Host 'refused: task still present after removal'; return 2 }
    Write-Host 'removed: ElevatedSmoke task unregistered and readback finds nothing'
    return 0
}

$modes = @($Register, $Run, $Remove, $SelfTest, $Check, $Readback, $RegisterElevated) | Where-Object { $_ }
if ($modes.Count -ne 1) {
    Write-Host 'usage: elevated-smoke.ps1 -Register [-Replace] | -Run | -Remove | -SelfTest | -Check | -Readback'
    exit 2
}
function Exit-WithCode($Result) {
    # A mode answers with one integer. Anything else a function let fall
    # into its output must not decide the exit code: `exit` on an array
    # exits 0, which is how a failed self-test once reported success. With
    # no integer at all the answer is unknown, and that is exit 2.
    $codes = @(@($Result) | Where-Object { $_ -is [int] })
    if ($codes.Count -ne 1) { exit 2 }
    exit $codes[0]
}

if ($SelfTest) { Exit-WithCode (Invoke-SelfTest) }
if ($Check) { Exit-WithCode (Invoke-Check) }
if ($Readback) { Exit-WithCode (Invoke-Readback) }
if ($RegisterElevated) { Exit-WithCode (Invoke-ElevatedRegistration) }
if ($Register) { Exit-WithCode (Invoke-Register) }
if ($Run) { Exit-WithCode (Invoke-Run) }
if ($Remove) { Exit-WithCode (Invoke-Remove) }
