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
#     fingerprint, blocks without progress, stall trips, and the last
#     thrown error (hook_error), which the heartbeat reports (D00 T04
#     section 34).
$ErrorActionPreference = "Stop"
$MaxBlocksWithoutProgress = 3
# Untracked content is hashed file by file, bounded so a huge scratch
# tree cannot stall the hook: past these limits a file counts by its
# size and write time instead (D00 T04 section 34).
$MaxUntrackedFiles = 500
$MaxHashedBytes = 4MB
$root = $null
# Windows PowerShell 5.1 decodes native output in the console codepage and
# writes stdout in it too: plan rows carry section marks, so both sides run
# UTF-8 or the block payload stops being valid JSON (D00 T04 section 32
# self-test). This file stays ASCII for the same reason.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

function Allow { exit 0 }

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
    if ($text -match "(?m)^## Closeout\b") { Allow }
    if ($text -match "(?m)^PARKED\b") { Allow }

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
        $paths = @(& git ls-files --others --exclude-standard 2>$null |
                   Where-Object { $_ -and $_ -ne $runPath } | Select-Object -First $MaxUntrackedFiles)
        $small = @()
        $large = @()
        foreach ($path in $paths) {
            $item = Get-Item -LiteralPath (Join-Path $root $path) -ErrorAction SilentlyContinue
            if ($item -and $item.Length -le $MaxHashedBytes) { $small += $path }
            elseif ($item) { $large += "$path $($item.Length) $($item.LastWriteTimeUtc.Ticks)" }
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

    $work = [regex]::Replace($text, '(?ms)^## Critical events\b.*?(?=^## |\z)', '')
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes("$head`n$diff`n$untracked`n$work")
    $fingerprint = [System.BitConverter]::ToString($sha.ComputeHash($bytes)).Replace("-", "")

    $statePath = Join-Path $root "build\claude-campaign-state.json"
    $state = [ordered]@{ fingerprint = ""; blocks = 0; trips = 0; stalled = $false }
    if (Test-Path -LiteralPath $statePath) {
        $old = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
        $state.fingerprint = [string]$old.fingerprint
        $state.blocks = [int]$old.blocks
        $state.trips = [int]$old.trips
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
        [Console]::Error.WriteLine("campaign-stop: stall breaker tripped ($($state.trips)) after $MaxBlocksWithoutProgress blocks with no tree change")
        Allow
    }

    $state.blocks = $state.blocks + 1
    $state.stalled = $false
    Write-State $statePath $state

    $message = "Campaign run is still open ($relative). Do not end the turn. Finish the open section's checklist, run the review panel and stamp it, then the next section, then the next phase. A commit, a green suite, a red CI (repair it: D00 T04 section 31), or a status report is not a stop."
    if ($next) { $message += " Next ready row: $($next.Trim())." }
    $message += " Finished means a '## Closeout' heading or a column-0 'PARKED' line in the run file. Escalating to the operator (an exhausted repair bound, an unverifiable CI, a cause the tree cannot fix) ends the run first: write a column-0 'PARKED <UTC> escalation: <cause>' line and run 'python scripts/campaign_guard.py end --reason escalation', then report. The breaker allows the stop after $MaxBlocksWithoutProgress pushes with no tree change (this is push $($state.blocks))."
    $payload = @{ decision = "block"; reason = $message } | ConvertTo-Json -Compress
    [Console]::Out.WriteLine($payload)
    exit 0
}
catch {
    $reason = $_.Exception.Message
    [Console]::Error.WriteLine("campaign-stop: $reason")
    # Still fail open, but never silently: record the error where the
    # heartbeat reads it (D00 T04 section 34). Best effort only.
    try {
        if ($root) {
            $statePath = Join-Path $root "build\claude-campaign-state.json"
            $state = [ordered]@{ fingerprint = ""; blocks = 0; trips = 0; stalled = $false }
            if (Test-Path -LiteralPath $statePath) {
                try {
                    $old = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
                    $state.fingerprint = [string]$old.fingerprint
                    $state.blocks = [int]$old.blocks
                    $state.trips = [int]$old.trips
                } catch { }
            }
            $state.hook_error = $reason
            $state.hook_error_at = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
            Write-State $statePath $state
        }
    } catch { }
    exit 0
}
