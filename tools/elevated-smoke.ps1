# tools/elevated-smoke.ps1 -- unattended elevated smoke via one consented task (D07 T01 S7)
#
# Usage:
#   pwsh tools/elevated-smoke.ps1 -Register [-Replace]  register \Resolute\ElevatedSmoke (one UAC prompt)
#   pwsh tools/elevated-smoke.ps1 -Run                  start it, wait, and validate the fresh report (no prompt)
#   pwsh tools/elevated-smoke.ps1 -Remove               stop if running, unregister, prove absence
#   pwsh tools/elevated-smoke.ps1 -SelfTest             windowless contract tests; registers nothing
#
# Trust boundary: registration pins the SHA-256 of scripts/smoke-run.py and
# scripts/conformance-check.py in C:\ProgramData\Resolute\ElevatedSmoke\
# trusted-hashes.txt (write: Administrators and SYSTEM only). The task
# wrapper and -Run verify both hashes before anything launches elevated, so
# editing a driver file after registration buys a named refusal and a
# re-registration prompt, never silent elevated execution of new code.
# The task action is fixed at registration and takes no caller arguments.

param(
    [switch]$Register,
    [switch]$Replace,
    [switch]$Run,
    [switch]$Remove,
    [switch]$SelfTest,
    [switch]$RegisterElevated,   # internal: elevated copy of this script, run by -Register
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$TaskPath = '\Resolute\'
$TaskName = 'ElevatedSmoke'
$HashDir = 'C:\ProgramData\Resolute\ElevatedSmoke'
$HashFile = Join-Path $HashDir 'trusted-hashes.txt'
$DriverFiles = @('scripts\smoke-run.py', 'scripts\conformance-check.py')
$AckTimeoutSec = 60
$RunTimeoutSec = 900
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
    $python = (Get-Command python -ErrorAction Stop).Source
    $driver = Join-Path $Base 'scripts\smoke-run.py'
    $envFile = Join-Path $Base 'build\smoke\elevated-smoke-env.txt'
    $smokeDir = Join-Path $Base 'build\smoke'
    $inner = "`$v = if (`$env:__COMPAT_LAYER -or [Environment]::GetEnvironmentVariable('__COMPAT_LAYER','User') -or [Environment]::GetEnvironmentVariable('__COMPAT_LAYER','Machine')) { 'contaminated: __COMPAT_LAYER present' } else { 'clean' }; " +
        "New-Item -ItemType Directory -Force -Path '$smokeDir' | Out-Null; " +
        "Set-Content -Path '$envFile' -Value `$v; " +
        "if (`$v -ne 'clean') { exit 2 }; " +
        "`$pinned = @{}; foreach (`$line in Get-Content '$HashFile') { if (`$line -match '^([0-9A-Fa-f]{64})  (.+)$') { `$pinned[`$Matches[2]] = `$Matches[1].ToUpper() } }; " +
        "foreach (`$rel in @('scripts\smoke-run.py','scripts\conformance-check.py')) { `$h = (Get-FileHash -Algorithm SHA256 -Path (Join-Path '$Base' `$rel)).Hash; if (`$pinned[`$rel] -ne `$h) { Set-Content -Path '$envFile' -Value 'refused: driver changed since registration'; exit 2 } }; " +
        "`$env:RESOLUTE_IDLE_COLLECT = '1'; & '$python' '$driver'; exit `$LASTEXITCODE"
    return @{
        Execute = 'powershell.exe'
        Argument = "-NoProfile -NonInteractive -Command ""& { $inner }"""
        WorkingDirectory = $Base
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
    return $refusals
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

function Stop-OwnedTask {
    # Stops the task and confirms it, and this checkout's driver processes,
    # are gone. Returns $true only when both are confirmed.
    Stop-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue
    $stopped = Wait-TaskStopped { (Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName).State } $StopTimeoutSec
    if (-not $stopped) { return $false }
    $driver = Join-Path $Root 'scripts\smoke-run.py'
    $procs = Get-CimInstance Win32_Process -Filter "Name = 'python.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -and $_.CommandLine.Contains($driver) }
    return (-not $procs)
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
            Principal = [pscustomobject]@{ RunLevel = 'Highest'; LogonType = 'Interactive' }
        }
        Check 'definition match accepted' ((Test-DefinitionMatch $good $Root).Count -eq 0)
        $bad = [pscustomobject]@{
            Actions = @([pscustomobject]@{ Execute = $expected.Execute; Arguments = '-visible'; WorkingDirectory = $expected.WorkingDirectory })
            Principal = [pscustomobject]@{ RunLevel = 'Highest'; LogonType = 'Interactive' }
        }
        Check 'definition mismatch refused by name' ((Test-DefinitionMatch $bad $Root) -match 'arguments differ').Count -ge 1

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

        # Unconfirmed stop: a getter that never leaves Running fails the wait.
        Check 'unconfirmed stop fails inside its bound' (-not (Wait-TaskStopped { 'Running' } 1))
        Check 'confirmed stop passes' (Wait-TaskStopped { 'Ready' } 1)
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
    # Runs elevated (one consent prompt from -Register). Registers the task
    # and writes the protected pinned-hashes file. Exit code says the outcome.
    if (-not (Test-IsElevated)) { Write-Host 'refused: the registration copy is not elevated'; return 2 }
    $trustRefusals = Test-PinnedHashes $Root $HashFile  # informational before first registration
    Remove-Variable trustRefusals -ErrorAction SilentlyContinue
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
    $expected = Get-ExpectedAction $Root
    $action = New-ScheduledTaskAction -Execute $expected.Execute -Argument $expected.Argument -WorkingDirectory $expected.WorkingDirectory
    Register-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Action $action -Principal $principal `
        -Description 'Resolute unattended elevated smoke (D07 T01 S7). Fixed action, hash-pinned driver; remove with tools/elevated-smoke.ps1 -Remove.' -Force | Out-Null
    New-Item -ItemType Directory -Force -Path $HashDir | Out-Null
    $lines = foreach ($rel in $DriverFiles) {
        '{0}  {1}' -f (Get-FileHash -Algorithm SHA256 -Path (Join-Path $Root $rel)).Hash, $rel
    }
    Set-Content -Path $HashFile -Value $lines
    # Hashes file: write for Administrators and SYSTEM only, read for Users.
    $acl = New-Object Security.AccessControl.FileSecurity
    $acl.SetAccessRuleProtection($true, $false)
    $admins = New-Object Security.Principal.SecurityIdentifier('S-1-5-32-544')
    $system = New-Object Security.Principal.SecurityIdentifier('S-1-5-18')
    $users = New-Object Security.Principal.SecurityIdentifier('S-1-5-32-545')
    foreach ($sid in $admins, $system) {
        $acl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule($sid, 'FullControl', 'Allow')))
    }
    $acl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule($users, 'ReadAndExecute', 'Allow')))
    Set-Acl -Path $HashFile -AclObject $acl
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
    if (Test-IsElevated) {
        return Invoke-RegisterElevated
    }
    Write-Host 'registration needs one consent prompt; approving it registers the task and pins the driver hashes'
    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -RegisterElevated -Root `"$Root`""
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

function Invoke-Run {
    $hashRefusals = Test-PinnedHashes $Root $HashFile
    if ($hashRefusals) {
        Write-Host ("refused: " + ($hashRefusals -join '; '))
        return 2
    }
    $task = Get-TaskOrNull
    if (-not $task) { Write-Host 'refused: task not registered (run tools/elevated-smoke.ps1 -Register first)'; return 2 }
    if ($task.State -eq 'Running') { Write-Host 'refused: the elevated smoke task is already Running'; return 2 }
    $diffs = Test-DefinitionMatch $task $Root
    if ($diffs) { Write-Host ("refused: registered task differs from this registration: " + ($diffs -join '; ')); return 2 }

    $reportPath = Join-Path $Root 'build\smoke\smoke-report.md'
    $envPath = Join-Path $Root 'build\smoke\elevated-smoke-env.txt'
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
            if ($t -and $t.State -eq 'Running') {
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
    if ($task.State -eq 'Running') {
        if (-not (Stop-OwnedTask)) {
            Write-Host 'refused: cleanup unconfirmed; the running task was not removed'
            return 2
        }
        Write-Host 'stopped: running task confirmed stopped before removal'
    }
    Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false
    if (Get-TaskOrNull) { Write-Host 'refused: task still present after removal'; return 2 }
    Write-Host 'removed: ElevatedSmoke task unregistered and readback finds nothing'
    return 0
}

$modes = @($Register, $Run, $Remove, $SelfTest, $RegisterElevated) | Where-Object { $_ }
if ($modes.Count -ne 1) {
    Write-Host 'usage: elevated-smoke.ps1 -Register [-Replace] | -Run | -Remove | -SelfTest'
    exit 2
}
if ($SelfTest) { $modeCode = Invoke-SelfTest; exit $modeCode }
if ($RegisterElevated) { $modeCode = Invoke-RegisterElevated; exit $modeCode }
if ($Register) { $modeCode = Invoke-Register; exit $modeCode }
if ($Run) { $modeCode = Invoke-Run; exit $modeCode }
if ($Remove) { $modeCode = Invoke-Remove; exit $modeCode }

