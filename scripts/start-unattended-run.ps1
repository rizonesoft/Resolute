#Requires -Version 7.0
<#
.SYNOPSIS
    Starts Resolute's unattended plan run in Claude Code, with its goal set.

.DESCRIPTION
    The Desktop shortcut "Resolute - Process Plan (Unattended)" runs this file. It checks the machine and the tree,
    switches the run guard on, and starts an interactive Claude Code session with permission prompts off and the
    session goal below. Setting the goal starts the work: the goal's text is the first directive, and Claude Code
    checks it after every turn, beside the run guard (scripts/run-guard.py: the Stop hook, the heartbeat and the
    watchdog task).

    It heals what it can instead of refusing. A missing toolchain is bootstrapped, the watchdog task is registered
    again for where this clone now is, and a session that dies while the run is still active is replaced by a new one
    after 30 seconds. While this window is open the launcher owns those restarts and the watchdog leaves the run to
    it; with the window gone (a reboot, a closed terminal) the watchdog resumes the run headless. Low memory, a dirty
    tree and a guard left by an earlier run are printed, not refused: the process-plan audit decides about each.

    SIGN-IN. The session signs in with the one-year Claude Code token kept in 1Password (vault Conclave, item
    "Claude Code OAuth token (1 year, setup-token)", field credential), handed to claude.exe as
    CLAUDE_CODE_OAUTH_TOKEN in this process's environment only: never printed, written to disk or passed as an
    argument. When 1Password cannot be read, or nobody approves its prompt in time, the launcher says so and starts
    on the stored Claude Code login. The launcher also leaves the watchdog a copy encrypted by Windows for this
    account (DPAPI, under %LOCALAPPDATA%\Resolute), because a run resumed after a reboot finds 1Password locked.

    STOPPING. Type `stop` in the session, or leave Claude Code normally (/exit): both end the run. Closing the
    window is treated as a crash, and the watchdog resumes the run within ten minutes; `-Stop` ends it from outside.

.PARAMETER PrintOnly
    Run the checks and print the command and the goal. Starts nothing, changes nothing.

.PARAMETER InstallShortcut
    Write the Desktop shortcut for this clone. Run it again after moving the clone.

.PARAMETER Stop
    End the active run from outside the session (an operator halt), so nothing resumes it.

.EXAMPLE
    pwsh scripts/start-unattended-run.ps1
    pwsh scripts/start-unattended-run.ps1 -PrintOnly
    pwsh scripts/start-unattended-run.ps1 -InstallShortcut
    pwsh scripts/start-unattended-run.ps1 -Stop
#>
[CmdletBinding()]
param(
    [switch]$PrintOnly,
    [switch]$InstallShortcut,
    [switch]$Stop,
    [int]$TokenTimeoutSeconds = 120
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root

# The writer model. scripts/review-dispatch.py records it on every review (--writer-model), so it is an exact id.
$model = 'claude-fable-5-2'
$shortcutName = 'Resolute - Process Plan (Unattended).lnk'
$tokenVault = 'Conclave'
$tokenItem = 'Claude Code OAuth token (1 year, setup-token)'
$lowMemoryMb = 3000

if ($InstallShortcut) {
    # Every path comes from where this clone, PowerShell and the Desktop are on this machine; none is written here.
    $icon = Join-Path $root 'resources\icons\Resolute.ico'
    if (-not (Test-Path -LiteralPath $icon)) { throw "the shortcut's icon is missing: $icon" }
    $link = Join-Path ([Environment]::GetFolderPath('Desktop')) $shortcutName
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($link)
    $shortcut.TargetPath = (Get-Command pwsh).Source
    $shortcut.Arguments = "-NoLogo -NoExit -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $shortcut.WorkingDirectory = $root
    $shortcut.IconLocation = "$icon,0"
    $shortcut.Description = 'Start the unattended Resolute plan run in Claude Code: finish the implementation plan to 100 percent, at excellence standard.'
    $shortcut.WindowStyle = 1
    $shortcut.Save()
    Write-Host "Shortcut written: $link"
    exit 0
}

if ($Stop) {
    python scripts/run-guard.py halt --ground operator --reason 'stopped from the launcher (-Stop)'
    exit $LASTEXITCODE
}

# One line, no double quotes: it is passed to claude.exe as a single argument. /goal allows 4,000 characters.
$goal = @'
/goal Resolute's implementation plan (todo/implementation-plan.md in {ROOT}) is 100 percent complete: `python scripts/todo-graph.py query stats` shows every section done, each one built, proven by its checkpoint from a real run, reviewed by the pinned reviewer (GPT-6 Astra, through scripts/review-dispatch.py) and stamped through the review-todo-section skill, with no partial ships and `pwsh scripts/check-all.ps1` green. The goal is also met when the run has ended the way the process-plan skill allows while rows are still open: `python scripts/run-guard.py status` no longer prints active, every remaining row is blocked here (an unmet dependency, a waiting Need, a host this session cannot reach, or a section its last completion review left with gaps), and the last message lists each leftover row with what blocks it and what the owner must do to release it. Nothing else counts as done: not an audit, not a status report, not a finished phase while another phase has a ready row. The work: process the plan through the process-plan skill, starting now, unattended, on main and nowhere else. Follow AGENTS.md, DESIGN.md and the skills exactly. Never ask the operator a question: where the answer can be worked out, work it out; otherwise take the industry-standard option, record it with its cost of reversing, and carry on. Act with full autonomy, as the owner would and better: improve the plan, the skills, the agents, the tools and the methods whenever they could be better, repair the run's own failures at their cause, and keep going. Aim for excellence in every section. Resolute must end as the best Windows system utility suite in its class, the one users choose over Sysinternals, PowerToys, CCleaner and every other rival: before building a surface or a feature, look at how the best competitor does it and make Resolute faster, with fewer steps, smarter defaults, better recovery from errors and better accessibility, proven with measurements. Nothing is impossible here: never plan less because something is hard or because no competitor has done it, and never call a row blocked that effort can unblock. No shortcuts, no workarounds, no weakened tests. Frozen behavior stays frozen and proven by parity. Hand fetching and routine checking to the Sonnet delegates as AGENTS.md says, and keep every decision and every write. This machine is shared with other work: run full builds and full test suites through `bosun run --`, one heavy job at a time.
'@
$goal = $goal.Trim().Replace('{ROOT}', $root)
if ($goal.Contains('"') -or $goal.Contains("`n")) { throw 'the goal must be one line with no double quote' }
if ($goal.Length -gt 4000) { throw "the goal is $($goal.Length) characters; /goal allows 4,000" }

$Host.UI.RawUI.WindowTitle = 'Resolute - Process Plan (Unattended)'
Write-Host "Resolute unattended run: $root" -ForegroundColor Cyan

# ── What must be there ───────────────────────────────────────
$missing = @('claude', 'python', 'git') | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) }
if ($missing) {
    Write-Host "Not started: not on PATH: $($missing -join ', ')" -ForegroundColor Red
    exit 2
}
$claude = (Get-Command claude).Source

# ── The machine and the tree, printed and not refused ────────
$freeMb = [int](Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue
Write-Host ('Free memory: {0:N0} MB' -f $freeMb)
if ($freeMb -lt $lowMemoryMb) {
    Write-Warning "Under $lowMemoryMb MB free: builds queue behind other work in bosun. Largest processes:"
    Get-Process | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 5 | ForEach-Object {
        Write-Host ('  {0,-28} {1,7:N0} MB' -f $_.Name, ($_.PrivateMemorySize64 / 1MB))
    }
}
Write-Host ('Branch: ' + (git status -sb | Select-Object -First 1))
$dirty = @(git status --short)
if ($dirty.Count -gt 0) { Write-Warning "$($dirty.Count) uncommitted file(s) in the tree; the run's audit reads them before it writes." }
if (-not (Get-Command bosun -ErrorAction SilentlyContinue)) { Write-Warning 'bosun is not installed: heavy jobs run without the shared queue.' }

# The reviewer: without its CLI no section can be stamped, so the run would build and park everything.
$pin = python scripts/review-dispatch.py --check-pin --json | Out-String | ConvertFrom-Json
if (-not $pin.ok) {
    Write-Warning "The reviewer pin is refused: $($pin.error). No review can run until .conclave/reviewers.toml loads."
} else {
    $reviewer = $pin.reviewers.($pin.routes.claude[0])
    if ($pin.clis.($reviewer.cli)) {
        Write-Host "Reviewer: $($reviewer.model) through $($reviewer.cli), effort capped at medium."
    } else {
        Write-Warning "The reviewer CLI '$($reviewer.cli)' is not on PATH: sections will build but none can be stamped."
    }
}

# ── Healed, not refused ──────────────────────────────────────
if (-not (Test-Path -LiteralPath (Join-Path $root 'reskit\llvm-mingw\bin\clang++.exe'))) {
    if ($PrintOnly) {
        Write-Warning 'The pinned toolchain is not installed; a real start runs scripts/bootstrap.ps1 first.'
    } else {
        Write-Host 'The pinned toolchain is not installed: running scripts/bootstrap.ps1.' -ForegroundColor Yellow
        & pwsh -NoProfile -File (Join-Path $root 'scripts\bootstrap.ps1')
        if ($LASTEXITCODE -ne 0) { Write-Warning 'bootstrap.ps1 failed; the session will see the same failure at its first build and repair it there.' }
    }
}

$status = @(python scripts/run-guard.py status)
Write-Host "Run guard: $($status[0])"
$detail = if ($status.Count -gt 1) { $status[1] | ConvertFrom-Json } else { $null }
if ($detail -and $detail.why) { Write-Host "  last run: $($detail.why)" -ForegroundColor DarkGray }
# One tree takes one writer. A Claude Code session already open in this clone may be writing, so the operator, who
# is at the keyboard when this starts, says whether to go on. A restart further down never asks.
$open = @(if ($detail) { $detail.live_here })
if ($open.Count -gt 0) {
    Write-Warning "$($open.Count) Claude Code session(s) already open in this clone: $($open -join ', ')."
    Write-Host 'If one of them is still working here, close THIS window: two writers on one tree corrupt each other''s work.'
    if (-not $PrintOnly) { Read-Host 'Press Enter to start the run anyway' | Out-Null }
}

# ── Sign-in ──────────────────────────────────────────────────
# The token goes from 1Password into claude.exe's environment and nowhere else. 1Password may ask the operator to
# approve the read; with nobody there it is stopped after $TokenTimeoutSeconds and the run starts regardless.
function Read-ClaudeToken {
    $op = (Get-Command op -ErrorAction SilentlyContinue).Source
    if (-not $op) { return $null }
    $info = [System.Diagnostics.ProcessStartInfo]::new($op)
    foreach ($a in @('item', 'get', $tokenItem, '--vault', $tokenVault, '--fields', 'label=credential', '--reveal')) {
        $info.ArgumentList.Add($a)
    }
    $info.UseShellExecute = $false
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $read = [System.Diagnostics.Process]::Start($info)
    try {
        $out = $read.StandardOutput.ReadToEndAsync()
        $null = $read.StandardError.ReadToEndAsync()
        if (-not $read.WaitForExit($TokenTimeoutSeconds * 1000)) {
            $read.Kill($true)
            Write-Warning "1Password did not answer within $TokenTimeoutSeconds seconds; its read was stopped."
            return $null
        }
        if ($read.ExitCode -ne 0) { return $null }
        $value = $out.Result.Trim()
        # The shape of a setup-token, so a wrong field or an error page is never handed over as a credential.
        if ($value -cmatch '^sk-ant-oat[0-9]{2}-[A-Za-z0-9_-]{40,}$') { return $value }
        Write-Warning '1Password answered, but the value does not have the shape of a Claude Code OAuth token.'
        return $null
    } finally {
        $read.Dispose()
    }
}

$token = Read-ClaudeToken
if ($token) {
    Write-Host 'Sign-in: the one-year token from 1Password.'
} else {
    Write-Warning "Sign-in: 1Password did not give the token ($tokenItem, vault $tokenVault); starting on the stored Claude Code login."
}
Write-Host "Model: $model, permission prompts off, questions off, goal of $($goal.Length) characters."

if ($PrintOnly) {
    Write-Host ''
    Write-Host "Would run: $claude --dangerously-skip-permissions --disallowedTools AskUserQuestion --session-id <new id> --model $model <goal>"
    Write-Host $goal
    exit 0
}

# A copy for the watchdog, which resumes the run after a reboot when 1Password is locked and nobody is there to
# unlock it: encrypted by Windows for this account (DPAPI), passed on stdin so it is never an argument.
if ($token) {
    $cached = $token | python scripts/run-guard.py cache-token
    if ($LASTEXITCODE -ne 0) { Write-Warning "The token was not cached for the watchdog ($cached): a run resumed after a reboot uses the stored login." }
}

# The watchdog task holds this clone's absolute path, so it is registered again on every start: a clone that moved
# (this one did, from R:\GitHub\Resolute) otherwise keeps a watchdog that runs a script which is no longer there.
python scripts/run-guard.py install | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Warning 'The watchdog task could not be registered: a reboot would end this run. Run `python scripts/run-guard.py install` to see why.' }

# ── The run, and its restarts ────────────────────────────────
Write-Host ''
Write-Host 'To stop: type stop in the session, or leave Claude Code with /exit. Closing this window counts as a crash and the watchdog resumes the run.' -ForegroundColor DarkGray
$before = $env:CLAUDE_CODE_OAUTH_TOKEN
$started = [System.Collections.Generic.List[datetime]]::new()
$code = 0
try {
    if ($token) { $env:CLAUDE_CODE_OAUTH_TOKEN = $token }
    $token = $null
    while ($true) {
        # A new session each time, named to the guard before it starts, so the Stop hook holds it from its first
        # turn. The guard refuses when another live session owns the run: one tree takes one writer.
        $session = [guid]::NewGuid().ToString()
        $refusal = python scripts/run-guard.py start --session $session --permission-mode bypassPermissions --launcher-pid $PID
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Not started: $refusal" -ForegroundColor Red
            $code = 1
            break
        }
        $started.Add((Get-Date))
        # --disallowedTools takes a list, so options follow it and the goal stays the last, positional argument.
        & $claude --dangerously-skip-permissions --disallowedTools AskUserQuestion --session-id $session --model $model $goal
        $code = $LASTEXITCODE

        $status = @(python scripts/run-guard.py status)
        if ($status[0] -ne 'active') {
            Write-Host ''
            Write-Host "The run ended: $($status[0])." -ForegroundColor Cyan
            if ($status.Count -gt 1) { Write-Host "  $($status[1])" -ForegroundColor DarkGray }
            Write-Host 'Run this shortcut to start it again.'
            break
        }
        if (@($started | Where-Object { $_ -gt (Get-Date).AddHours(-1) }).Count -ge 5) {
            Write-Host ''
            Write-Host 'Stopped: five sessions ended inside an hour with the run still active. Read the last one before starting again.' -ForegroundColor Red
            python scripts/run-guard.py halt --ground operator --reason 'the launcher stopped restarting: five sessions ended inside an hour' | Out-Null
            $code = 1
            break
        }
        Write-Host ''
        Write-Host 'The session ended with the run still active. A new session starts in 30 seconds. To end the run instead: pwsh scripts/start-unattended-run.ps1 -Stop' -ForegroundColor Yellow
        Start-Sleep -Seconds 30
    }
} finally {
    $env:CLAUDE_CODE_OAUTH_TOKEN = $before
}
exit $code
