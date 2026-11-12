# tools/elevated-smoke.ps1 -- unattended elevated smoke via one consented task (D07 T01 S7)
#
# Usage:
#   pwsh tools/elevated-smoke.ps1 -Register [-Replace]  register \Resolute\ElevatedSmoke (one UAC prompt)
#   pwsh tools/elevated-smoke.ps1 -Run                  start it, wait, and validate the fresh report (no prompt)
#   pwsh tools/elevated-smoke.ps1 -Remove               stop if running, unregister, prove absence
#   pwsh tools/elevated-smoke.ps1 -SelfTest             windowless contract tests; registers nothing
#   pwsh tools/elevated-smoke.ps1 -Check                would -Run be refused? starts nothing, changes nothing
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
    [switch]$RegisterElevated,   # internal: elevated copy of this script, run by -Register
    [string]$OperatorSid = '',   # internal: the account that asked for the registration
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
$KnownEntries = @('trusted-hashes.txt', 'python', 'python.new', 'python.old', 'run')
$AdminsSid = 'S-1-5-32-544'
$SystemSid = 'S-1-5-18'
$DriverFiles = @('scripts\smoke-run.py', 'scripts\conformance-check.py')
$AckTimeoutSec = 60
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

function Switch-Runtime([string]$New, [string]$Live, [scriptblock]$Move = { param($from, $to) Move-Item -LiteralPath $from -Destination $to }) {
    # Puts the new runtime in place of the live one and keeps the old one
    # until the new one is there and has its python.exe: a failure on the
    # way puts the old one back, so the task is never left without a runtime.
    $old = "$Live.old"
    if (Test-Path -LiteralPath $old) { Remove-Item -LiteralPath $old -Recurse -Force }
    $hadLive = Test-Path -LiteralPath $Live
    if ($hadLive) { & $Move $Live $old }
    try {
        & $Move $New $Live
        if (-not (Test-Path -LiteralPath (Join-Path $Live 'python.exe'))) { throw "the runtime at $Live has no python.exe after the swap" }
    } catch {
        if (Test-Path -LiteralPath $Live) { Remove-Item -LiteralPath $Live -Recurse -Force }
        if ($hadLive) { & $Move $old $Live }
        throw
    }
    if ($hadLive) { Remove-Item -LiteralPath $old -Recurse -Force }
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
    $failures = @()
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

        # The runtime swap keeps the old runtime until the new one is in place.
        $live = Join-Path $td 'python'; $new = Join-Path $td 'python.new'
        New-Item -ItemType Directory -Path $live, $new | Out-Null
        Set-Content (Join-Path $live 'python.exe') 'old'; Set-Content (Join-Path $new 'python.exe') 'new'
        $threw = $false
        try {
            Switch-Runtime $new $live { param($from, $to) if ($from -eq $new) { throw 'the disk refused the rename' }; Move-Item -LiteralPath $from -Destination $to }
        } catch { $threw = $true }
        Check 'a failed runtime swap puts the old runtime back' ($threw -and (Get-Content (Join-Path $live 'python.exe')) -eq 'old' -and -not (Test-Path "$live.old"))
        Switch-Runtime $new $live
        Check 'a runtime swap that succeeds leaves the new runtime and no old copy' ((Get-Content (Join-Path $live 'python.exe')) -eq 'new' -and -not (Test-Path "$live.old") -and -not (Test-Path $new))

        # Ownership is part of the boundary: only Administrators or SYSTEM may own the directory.
        Check 'Administrators and SYSTEM are trusted owners, an ordinary account is not' (
            (Test-TrustedOwner $AdminsSid) -and (Test-TrustedOwner $SystemSid) -and -not (Test-TrustedOwner 'S-1-5-21-1-2-3-1001'))
        # A checkout path with an apostrophe still gives an action that parses.
        $quoted = Get-ExpectedAction "D:\Derick's Projects\Resolute"
        $source = $quoted.Argument.Substring($quoted.Argument.IndexOf('"') + 1).TrimEnd('"')
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput($source, [ref]$null, [ref]$parseErrors)
        Check 'a checkout path with an apostrophe gives an action that parses' ($parseErrors.Count -eq 0 -and $source.Contains("'D:\Derick''s Projects\Resolute'"))

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
    if ($failures.Count) {
        Write-Host ("self-test: FAIL " + ($failures -join ', '))
        return 1
    }
    Write-Host 'self-test: all pass'
    return 0
}

function Invoke-RegisterElevated {
    # Runs elevated (one consent prompt from -Register). Protects the
    # directory, copies the pinned Python in, writes the pinned hashes and
    # registers the task. Exit code says the outcome.
    if (-not (Test-IsElevated)) { Write-Host 'refused: the registration copy is not elevated'; return 2 }
    if ($OperatorSid -and $OperatorSid -ne (Get-CurrentSid)) {
        # Consent given with another administrator's credentials: this copy
        # runs as that administrator, so the task and the HKCU it reads would
        # be theirs, and the operator's -Run could never feed it.
        Write-Host "refused: the consent was given as another account ($([Security.Principal.WindowsIdentity]::GetCurrent().Name)); the task must run as the account that asked for it. Sign in as an administrator, or give this account administrator rights, and register again"
        return 2
    }
    $pinnedPython = Join-Path $Root 'reskit\python'
    if (-not (Test-Path (Join-Path $pinnedPython 'python.exe'))) {
        Write-Host "refused: the pinned Python is not installed at $pinnedPython (run pwsh scripts/bootstrap.ps1)"
        return 2
    }
    $prior = Get-TaskOrNull
    if ($prior -and (Test-TaskNeedsStop $prior.State)) {
        Write-Host 'refused: the elevated smoke task is running or queued; let it finish or run -Remove first'
        return 2
    }
    $priorXml = $null
    if ($prior) { $priorXml = Export-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName }
    $priorHash = if (Test-Path $HashFile) { Get-Content $HashFile -Raw } else { $null }
    $hadHashDir = Test-Path $HashDir
    $newPython = Join-Path $HashDir 'python.new'
    try {
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
        $expected = Get-ExpectedAction $Root
        $action = New-ScheduledTaskAction -Execute $expected.Execute -Argument $expected.Argument -WorkingDirectory $expected.WorkingDirectory
        New-Item -ItemType Directory -Force -Path $HashDir | Out-Null
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
        # the ACL just set. The folder that holds it gets the same owner.
        $dacl.SetOwner((New-Object Security.Principal.SecurityIdentifier($AdminsSid)))
        Set-Acl -Path $HashDir -AclObject $dacl
        $parentDir = Split-Path $HashDir -Parent
        $parentAcl = Get-Acl -LiteralPath $parentDir
        $parentAcl.SetOwner((New-Object Security.Principal.SecurityIdentifier($AdminsSid)))
        Set-Acl -LiteralPath $parentDir -AclObject $parentAcl
        & icacls.exe $HashDir /setowner "*$AdminsSid" /T /C /Q | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "icacls could not give Administrators ownership of everything under $HashDir (exit $LASTEXITCODE)" }
        # Whatever is here that registration did not put here was put by
        # someone else while the folder was open to them: it goes.
        foreach ($entry in Get-ChildItem -LiteralPath $HashDir -Force) {
            if ($KnownEntries -notcontains $entry.Name) {
                Write-Host "removed an unexpected entry from ${HashDir}: $($entry.Name)"
                Remove-Item -LiteralPath $entry.FullName -Recurse -Force
            }
        }
        # The run directory is rebuilt, so nothing staged before the folder
        # was protected is still there, and it takes the inherited ACL.
        $runDir = Split-Path $SnapshotDir -Parent
        if (Test-Path $runDir) { Remove-Item -LiteralPath $runDir -Recurse -Force }
        New-Item -ItemType Directory -Force -Path $SnapshotDir | Out-Null
        # The pinned Python, copied beside the old copy and swapped in last.
        if (Test-Path $newPython) { Remove-Item -LiteralPath $newPython -Recurse -Force }
        Copy-Item -LiteralPath $pinnedPython -Destination $newPython -Recurse
        $lines = foreach ($rel in $DriverFiles) {
            '{0}  {1}' -f (Get-FileHash -Algorithm SHA256 -Path (Join-Path $Root $rel)).Hash, $rel
        }
        if (Test-Path $HashFile) { Remove-Item -LiteralPath $HashFile -Force }  # a new file takes the inherited ACL
        Set-Content -Path $HashFile -Value $lines
        Register-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Action $action -Principal $principal `
            -Description 'Resolute unattended elevated smoke (D07 T01 S7). Fixed action, hash-pinned driver; remove with tools/elevated-smoke.ps1 -Remove.' -Force | Out-Null
        Switch-Runtime $newPython $PythonDir
        $untrusted = @(Get-DirectoryRefusals)
        if ($untrusted) { throw ("the directory is not protected after registration: " + ($untrusted -join '; ')) }
        Write-Host "python: $((Get-FileHash -Algorithm SHA256 -Path (Join-Path $PythonDir 'python.exe')).Hash) $(Join-Path $PythonDir 'python.exe')"
        foreach ($line in $lines) { Write-Host "pinned: $line" }
    } catch {
        # Roll back: a failed registration leaves neither a half-registered
        # task nor new pinned hashes behind. Every step runs whatever the
        # others do, what this run created is removed, and a step that
        # fails is said beside the original error.
        $cause = $_
        $notRestored = Invoke-RollbackSteps @(
            {
                if ($priorXml) {
                    Register-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -XmlText $priorXml -Force -ErrorAction Stop | Out-Null
                } elseif (Get-TaskOrNull) {
                    Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false -ErrorAction Stop
                }
            },
            {
                if ($priorHash) { Set-Content -Path $HashFile -Value $priorHash -ErrorAction Stop }
                elseif (Test-Path $HashFile) { Remove-Item $HashFile -ErrorAction Stop }
            },
            {
                if (Test-Path $newPython) { Remove-Item -LiteralPath $newPython -Recurse -Force -ErrorAction Stop }
                if (-not $hadHashDir -and (Test-Path $HashDir)) { Remove-Item $HashDir -Recurse -Force -ErrorAction Stop }
            }
        )
        if ($notRestored.Count) {
            Write-Host ("rollback incomplete, restore by hand: " + ($notRestored -join '; '))
        }
        throw $cause
    }
    return 0
}

function Invoke-Register {
    $existing = Get-TaskOrNull
    if ($existing -and -not $Replace) {
        $diffs = Test-DefinitionMatch $existing $Root
        $hashRefusals = Test-PinnedHashes $Root $HashFile
        if (-not $diffs -and -not $hashRefusals) {
            Write-Host 'already registered: definition and pinned hashes match'
            return 0
        }
        Write-Host ("refused: an existing task differs and is preserved: " + (($diffs + $hashRefusals) -join '; '))
        Write-Host 're-run with -Register -Replace to consent to overwriting it'
        return 2
    }
    # Before any prompt: a pin taken over bytes git would not write breaks
    # by itself later, so it is refused here, by name.
    $drift = @(Get-DriftRefusals $Root)
    if ($drift) { Write-Host ("refused: " + ($drift -join '; ')); return 2 }
    if (Test-IsElevated) {
        return Invoke-RegisterElevated
    }
    Write-Host 'registration needs one consent prompt; approving it registers the task and pins the driver hashes'
    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -RegisterElevated -OperatorSid $(Get-CurrentSid) -Root `"$Root`""
    try {
        $proc = Start-Process powershell.exe -Verb RunAs -ArgumentList $args -Wait -PassThru -ErrorAction Stop
    } catch {
        Write-Host "blocked: elevation consent declined or the elevated registration could not start: $($_.Exception.Message)"
        return 2
    }
    if ($proc.ExitCode -ne 0) {
        Write-Host "refused: elevated registration failed with exit code $($proc.ExitCode); nothing is registered by this run"
        return 2
    }
    $task = Get-TaskOrNull
    if (-not $task) { Write-Host 'refused: registration reported success but the task readback finds nothing'; return 2 }
    $diffs = Test-DefinitionMatch $task $Root
    if ($diffs) { Write-Host ("refused: registered task readback differs: " + ($diffs -join '; ')); return 2 }
    Write-Host 'registered: definition readback matches; pinned hashes recorded'
    return 0
}

function Invoke-Check {
    # The refusals -Run would give before it starts anything, so a launcher can ask for a new registration while
    # the operator is still at the keyboard to consent (scripts/start-unattended-run.ps1). Read-only.
    $refusals = @(Test-PinnedHashes $Root $HashFile)
    $task = Get-TaskOrNull
    if (-not $task) { $refusals += 'task not registered' }
    else { $refusals += @(Test-DefinitionMatch $task $Root) }
    if (-not (Test-Path (Join-Path $PythonDir 'python.exe'))) { $refusals += "the task's Python is missing from $PythonDir (register again)" }
    $refusals += @(Get-DirectoryRefusals)
    if ($refusals) { Write-Host ("not ready: " + ($refusals -join '; ')); return 2 }
    Write-Host 'ready: the task is registered for this checkout and the pinned driver hashes match'
    return 0
}

function Invoke-Run {
    $hashRefusals = Test-PinnedHashes $Root $HashFile
    if ($hashRefusals) {
        Write-Host ("refused: " + ($hashRefusals -join '; '))
        return 2
    }
    $task = Get-TaskOrNull
    if (-not $task) { Write-Host 'refused: task not registered (run tools/elevated-smoke.ps1 -Register first)'; return 2 }
    if (Test-TaskNeedsStop $task.State) { Write-Host "refused: the elevated smoke task is already $($task.State)"; return 2 }
    $untrusted = @(Get-DirectoryRefusals)
    if ($untrusted) { Write-Host ("refused: " + ($untrusted -join '; ')); return 2 }
    $diffs = Test-DefinitionMatch $task $Root
    if ($diffs) { Write-Host ("refused: registered task differs from this registration: " + ($diffs -join '; ')); return 2 }

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

$modes = @($Register, $Run, $Remove, $SelfTest, $Check, $RegisterElevated) | Where-Object { $_ }
if ($modes.Count -ne 1) {
    Write-Host 'usage: elevated-smoke.ps1 -Register [-Replace] | -Run | -Remove | -SelfTest | -Check'
    exit 2
}
if ($SelfTest) { $modeCode = Invoke-SelfTest; exit $modeCode }
if ($Check) { $modeCode = Invoke-Check; exit $modeCode }
if ($RegisterElevated) { $modeCode = Invoke-RegisterElevated; exit $modeCode }
if ($Register) { $modeCode = Invoke-Register; exit $modeCode }
if ($Run) { $modeCode = Invoke-Run; exit $modeCode }
if ($Remove) { $modeCode = Invoke-Remove; exit $modeCode }

