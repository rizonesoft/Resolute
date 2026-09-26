# Stop hook for the Claude process-plan campaign (D00 T04 section 32, ported
# from ScratchPad's 0da6bd2). Blocks the campaign session's end of turn
# while its run is open, and lets go when the run is finished, parked,
# out of runnable work, or stalled. Only the session named in the guard
# file is ever blocked. Fail open: a bad payload, a missing guard, or a
# thrown error allows the stop.
#
# Files (all under build/, gitignored):
#   claude-campaign-guard.json  written by the runner at run start:
#     { runner, workspace, phase, run_file, session_id, cron_id }
#     Deleting it is how an operator stop sticks.
#   claude-campaign-state.json  owned by this hook: progress
#     fingerprint, blocks without progress, stall trips, the run it
#     belongs to (run_id, session, generation), and the fingerprint's
#     coverage. A state carrying another run's id is read as a fresh
#     breaker (D00 T04 section 38).
#   claude-campaign-hook-errors/  one JSON file per thrown error, each
#     with a unique id and the session, run id, and generation it was
#     raised under (empty when the hook failed before reading them),
#     published by atomic rename; the heartbeat reports and acknowledges
#     each by its id (D00 T04 section 38).
$ErrorActionPreference = "Stop"
$MaxBlocksWithoutProgress = 3
# Untracked content is hashed file by file, bounded so a huge scratch
# tree cannot stall the hook: past these limits a file counts by its
# size and write time instead, and past the metadata bound by its name
# alone, so no untracked path ever drops out (D00 T04 section 34).
# The bounds read from the environment when set, so fixtures can pin the
# boundaries without thousands of files (D00 T04 section 36).
function EnvInt($name, $default) {
    $v = [Environment]::GetEnvironmentVariable($name)
    if ($v -match '^\d+$') { return [int64]$v } else { return $default }
}
$MaxHashedFiles = EnvInt 'CAMPAIGN_HASH_FILES' 500
$MaxHashedBytes = EnvInt 'CAMPAIGN_HASH_BYTES' 4MB
$MaxStatFiles = EnvInt 'CAMPAIGN_STAT_FILES' 5000
$LockWaitMs = EnvInt 'CAMPAIGN_LOCK_WAIT_MS' 5000
$root = $null
$guardPath = $null
$owner = $null
$guard = $null
# Windows PowerShell 5.1 decodes native output in the console codepage and
# writes stdout in it too: plan rows carry section marks, so both sides run
# UTF-8 or the block payload stops being valid JSON (D00 T04 section 32
# self-test). This file stays ASCII for the same reason.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

function Allow { exit 0 }

# The guard lock campaign_guard.py takes (msvcrt.locking on one byte):
# FileStream.Lock is the same Win32 byte-range lock, so the hook's state
# read and write never interleave with a handover, an end, or a reset
# (D00 T04 section 36).
function Enter-GuardLock($root, $waitMs) {
    $path = Join-Path $root "build\claude-campaign-guard.lock"
    $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::OpenOrCreate,
                                 [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite)
    $deadline = [DateTime]::UtcNow.AddMilliseconds($waitMs)
    while ($true) {
        try { $fs.Lock(0, 1); return $fs }
        catch [System.IO.IOException] {
            if ([DateTime]::UtcNow -ge $deadline) { $fs.Dispose(); throw "the guard lock stayed held for $($waitMs)ms" }
            Start-Sleep -Milliseconds 50
        }
    }
}

function Exit-GuardLock($fs) {
    if ($fs) { try { $fs.Unlock(0, 1) } catch { } ; $fs.Dispose() }
}

function Write-State($path, $state) {
    $tmp = "$path.tmp"
    $state | ConvertTo-Json -Compress | Set-Content -LiteralPath $tmp -Encoding UTF8
    Move-Item -LiteralPath $tmp -Destination $path -Force
}

try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { Allow }
    $event = $raw | ConvertFrom-Json

    $root = $env:CLAUDE_PROJECT_DIR
    if (-not $root) { $root = [string]$event.cwd }
    if (-not $root) { Allow }

    $guardPath = Join-Path $root "build\claude-campaign-guard.json"
    if (-not (Test-Path -LiteralPath $guardPath)) { Allow }
    $guard = Get-Content -LiteralPath $guardPath -Raw -Encoding UTF8 | ConvertFrom-Json

    # Only the campaign session. A second Claude session in this
    # workspace (a question, a review) ends its turns normally.
    $owner = [string]$guard.session_id
    if (-not $owner -or $owner -ne [string]$event.session_id) { Allow }

    $relative = [string]$guard.run_file
    if (-not $relative -or [System.IO.Path]::IsPathRooted($relative)) { Allow }
    $fullRun = [System.IO.Path]::GetFullPath((Join-Path $root $relative))
    $fullRoot = [System.IO.Path]::GetFullPath($root).TrimEnd('\')
    if (-not $fullRun.StartsWith($fullRoot + '\', [System.StringComparison]::OrdinalIgnoreCase)) { Allow }
    if (-not (Test-Path -LiteralPath $fullRun)) { Allow }

    $text = Get-Content -LiteralPath $fullRun -Raw -Encoding UTF8
    if ($null -eq $text) { $text = "" }
    # A marker ends the run only when it carries this run's id (run=<id>),
    # wherever it sits in the file, so a reused run file's old closeout or
    # PARKED line never ends a new run (D00 T04 section 36). A guard with
    # no run id predates the rule, and any marker counts.
    $runId = ""
    if ($guard.PSObject.Properties.Name -contains 'run_id') { $runId = [string]$guard.run_id }
    foreach ($ml in ($text -split "`r?`n")) {
        if ($ml -match '^(## Closeout\b|PARKED\b)') {
            if (-not $runId -or $ml -match ('\brun=' + [regex]::Escape($runId) + '\b')) { Allow }
        }
    }

    Push-Location -LiteralPath $root
    # Windows PowerShell turns native stderr (git CRLF warnings) into
    # terminating errors under Stop; native calls run under Continue.
    $ErrorActionPreference = "Continue"
    try {
        # Genuine halt: nothing runnable here. The runner still owes the
        # PARKED line, but blocking cannot produce work that does not exist.
        $ready = & python scripts/todo-graph.py query ready 2>$null
        $summary = $ready | Select-String -Pattern '(\d+) runnable now' | Select-Object -Last 1
        if ($summary -and [int]$summary.Matches[0].Groups[1].Value -eq 0) { Allow }
        $next = ($ready | Where-Object { $_ -match '\S' -and $_ -notmatch 'runnable now' } | Select-Object -First 1)

        # Progress fingerprint: HEAD, the working-tree diff, the untracked
        # files' contents, and the run file without its bookkeeping. The
        # run file leaves the diff and the untracked set and is hashed on
        # its own below, so a heartbeat or retry line in its Critical
        # events cannot pass for progress (D00 T04 section 34).
        $runPath = $relative.Replace('\', '/')
        $head = (& git rev-parse HEAD 2>$null) -join ""
        $diff = (& git diff HEAD -- . ":(exclude)$runPath" 2>$null) -join "`n"
        # NUL-delimited, so git never quotes or escapes a name (a path
        # like cafe with an accent would otherwise arrive octal-escaped and
        # name no file).
        $listed = (& git ls-files -z --others --exclude-standard 2>$null) -join ""
        $paths = @($listed.Split([char]0) | Where-Object { $_ -and $_ -ne $runPath })
        $small = @()
        $large = @()
        $index = 0
        # How each untracked path counted, so the degraded coverage is
        # visible when it bites (D00 T04 section 38).
        $named = 0
        $statted = 0
        foreach ($path in $paths) {
            $index++
            if ($index -gt $MaxHashedFiles + $MaxStatFiles) { $large += $path; $named++; continue }
            $item = Get-Item -LiteralPath (Join-Path $root $path) -ErrorAction SilentlyContinue
            if ($item -and $index -le $MaxHashedFiles -and $item.Length -le $MaxHashedBytes) { $small += $path }
            elseif ($item) { $large += "$path $($item.Length) $($item.LastWriteTimeUtc.Ticks)"; $statted++ }
            else { $large += "$path missing"; $named++ }
        }
        $hashes = @()
        # Paths ride the argument list, in chunks, never a pipe: a pipe into
        # a native command can carry a BOM depending on the parent shell
        # (a pwsh 7 parent prefixes one even under a BOM-free encoder), and
        # the first path then names no file (D00 T04 section 34 gates).
        for ($i = 0; $i -lt $small.Count; $i += 50) {
            $chunk = @($small[$i..([Math]::Min($i + 49, $small.Count - 1))])
            $hashes += @(& git hash-object -- @chunk 2>$null)
        }
        $untracked = (@($small) + @($hashes) + @($large)) -join "`n"
    }
    finally {
        Pop-Location
        $ErrorActionPreference = "Stop"
    }

    # Only lines marked as bookkeeping leave the fingerprint: a heartbeat
    # or retry note is `- bookkeeping: ...`, and a substantive Critical
    # events line still counts as progress (D00 T04 section 36).
    $work = [regex]::Replace($text, '(?m)^- bookkeeping:.*(\r?\n)?', '')
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes("$head`n$diff`n$untracked`n$work")
    $fingerprint = [System.BitConverter]::ToString($sha.ComputeHash($bytes)).Replace("-", "")

    $statePath = Join-Path $root "build\claude-campaign-state.json"
    $lock = Enter-GuardLock $root $LockWaitMs
    try {
    # Re-read the guard under the lock: a handover or an end that landed
    # while this hook waited means the state is no longer this run's, and
    # nothing is written (D00 T04 section 36 panel round 1).
    $still = $null
    if (Test-Path -LiteralPath $guardPath) {
        try { $still = Get-Content -LiteralPath $guardPath -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $still = $null }
    }
    $sameRun = $still -and ([string]$still.session_id -eq $owner) -and ([string]$still.run_file -eq $relative)
    if ($sameRun -and ($guard.PSObject.Properties.Name -contains 'run_id')) {
        $sameRun = ([string]$still.run_id -eq [string]$guard.run_id)
    }
    if (-not $sameRun) {
        Exit-GuardLock $lock
        $lock = $null
        [Console]::Error.WriteLine("campaign-stop: the guard changed while this hook waited; nothing written")
        Allow
    }
    $generation = ""
    if ($guard.PSObject.Properties.Name -contains 'generation') { $generation = [string]$guard.generation }
    $coverage = [ordered]@{ hashed = $small.Count; statted = $statted; named = $named }
    $state = [ordered]@{ fingerprint = ""; blocks = 0; trips = 0; stalled = $false;
                         run_id = $runId; session = $owner; generation = $generation; coverage = $coverage }
    if (Test-Path -LiteralPath $statePath) {
        $old = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
        # Another run's state is not this run's breaker: a crash between
        # acquire's guard publish and its state reset leaves one behind,
        # and it reads as a fresh start (D00 T04 section 38). A handover
        # keeps the run id, so its blocks and trips carry over.
        $oldRun = ""
        if ($old.PSObject.Properties.Name -contains 'run_id') { $oldRun = [string]$old.run_id }
        if (-not $oldRun -or $oldRun -eq $runId) {
            $state.fingerprint = [string]$old.fingerprint
            $state.blocks = [int]$old.blocks
            $state.trips = [int]$old.trips
            if ($old.PSObject.Properties.Name -contains 'hook_error') {
                $state.hook_error = [string]$old.hook_error
                $state.hook_error_at = [string]$old.hook_error_at
            }
        }
    }

    if ($state.fingerprint -ne $fingerprint) {
        # The tree moved since the last stop: real progress resets the breaker.
        $state.fingerprint = $fingerprint
        $state.blocks = 0
        $state.trips = 0
    }

    if ($state.blocks -ge $MaxBlocksWithoutProgress) {
        # Stall breaker: repeated pushes with no change to the tree mean the
        # session is stuck, not idle. Let it stop and say so.
        $state.blocks = 0
        $state.trips = $state.trips + 1
        $state.stalled = $true
        $state.stalled_at = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
        Write-State $statePath $state
        Exit-GuardLock $lock
        $lock = $null
        [Console]::Error.WriteLine("campaign-stop: stall breaker tripped ($($state.trips)) after $MaxBlocksWithoutProgress blocks with no tree change")
        Allow
    }

    $state.blocks = $state.blocks + 1
    $state.stalled = $false
    Write-State $statePath $state
    }
    finally { Exit-GuardLock $lock }

    $message = "Campaign run is still open ($relative). Do not end the turn. Finish the open section's checklist, run the review panel and stamp it, then the next section, then the next phase. A commit, a green suite, a red CI (repair it: D00 T04 section 31), or a status report is not a stop."
    if ($next) { $message += " Next ready row: $($next.Trim())." }
    $message += " Fingerprint coverage: $($coverage.hashed) untracked path(s) hashed, $($coverage.statted) by size and write time, $($coverage.named) by name only."
    $message += " Finished means a '## Closeout run=$runId' heading or a column-0 'PARKED <UTC> run=$runId <reason>' line in the run file. Escalating to the operator (an exhausted repair bound, an unverifiable CI, a cause the tree cannot fix) ends the run first: write a column-0 'PARKED <UTC> run=$runId escalation: <cause>' line, run 'python scripts/campaign_guard.py end --session $owner --reason escalation --generation $generation --cron-id $([string]$guard.cron_id)', CronDelete the heartbeat it names, then report. The breaker allows the stop after $MaxBlocksWithoutProgress pushes with no tree change (this is push $($state.blocks))."
    $payload = @{ decision = "block"; reason = $message } | ConvertTo-Json -Compress
    [Console]::Out.WriteLine($payload)
    exit 0
}
catch {
    $reason = $_.Exception.Message
    [Console]::Error.WriteLine("campaign-stop: $reason")
    # Still fail open, but never silently: every error lands in a file of
    # its own under build/claude-campaign-hook-errors/, never in the state
    # (D00 T04 section 38). It needs no lock, because no writer shares a
    # file, and it is published by atomic rename, so a reader never meets
    # half a record. It carries a unique id and the identity the hook had
    # captured when it failed: an error raised before the owner was read
    # carries none, and so can never be written into a run's state.
    try {
        if ($root) {
            $at = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
            $id = [guid]::NewGuid().ToString("N").Substring(0, 12)
            $errSession = ""; $errRun = ""; $errGen = ""
            if ($owner) {
                $errSession = [string]$owner
                try { $errRun = [string]$guard.run_id; $errGen = [string]$guard.generation } catch { }
            }
            $dir = Join-Path $root "build\claude-campaign-hook-errors"
            [void][System.IO.Directory]::CreateDirectory($dir)
            $name = "{0:D20}-{1}-{2}" -f [DateTime]::UtcNow.Ticks, $PID, $id
            $doc = [ordered]@{ id = $id; at = $at; reason = $reason; session = $errSession;
                               run_id = $errRun; generation = $errGen } | ConvertTo-Json -Compress
            $tmp = Join-Path $dir "$name.tmp"
            [System.IO.File]::WriteAllText($tmp, $doc)
            [System.IO.File]::Move($tmp, (Join-Path $dir "$name.json"))
        }
    } catch { }
    exit 0
}
