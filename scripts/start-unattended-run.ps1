#Requires -Version 7.0
<#
.SYNOPSIS
    Starts Resolute's unattended plan run (the campaign) in Claude Code or Google Antigravity, with its goal set.

.DESCRIPTION
    The Desktop shortcuts "Resolute Claude campaign" (-Runner claude, the default) and "Resolute Carbon campaign"
    (-Runner agy, Google Antigravity on Gemini 4 Carbon) run this file. It checks the machine and the tree, takes
    the run through the run guard's one admission, and starts one interactive session with permission prompts off
    and the session goal below. Setting the goal starts the work: the goal's text is the first directive, and the
    runner checks it after every turn.

    A RUN STARTS ONLY WHEN YOU START IT (operator decision 2026-11-12). This file starts one session and no other.
    Closing this window stops the run and everything it started: the session runs inside a job object that ends
    with the window (scripts/run-guard.py session). A crash or a reboot ends the run too. Nothing starts or resumes
    a session that is dead: there is no scheduled task, no watchdog and no restart loop. When the session ends, this
    file records how and says so; `python scripts/run-guard.py status` says the same afterwards.

    What keeps a live Claude Code session working inside its open window is the run guard (scripts/run-guard.py):
    the Stop hook sends a turn back while runnable rows remain, and the heartbeat inside the session wakes it when
    it sits idle, after a usage limit included. Those are Claude Code hooks: an Antigravity session is kept working
    by its goal alone, and the guard only reserves the tree for it, so no second writer starts beside it.

    It heals what it can instead of refusing: a missing toolchain is bootstrapped. Low memory, a dirty tree and
    the record of an earlier run are printed, not refused: the process-plan audit decides about each.

    SIGN-IN. Claude Code signs in with the one-year token kept in 1Password (vault Conclave, item
    "Claude Code OAuth token (1 year, setup-token)", field credential), handed to claude.exe as
    CLAUDE_CODE_OAUTH_TOKEN in this process's environment only: never printed or passed as an argument. A start
    that reads it leaves one copy encrypted by Windows for this account (DPAPI, under %LOCALAPPDATA%\Resolute), used
    at a later start when 1Password cannot be read. With neither, the launcher says so and starts on the stored
    Claude Code login. Antigravity signs in with its own account on this PC and is never handed Claude's token.

    STOPPING. Type `stop` in the session, leave it normally (/exit), or close this window: each ends the run, and
    nothing starts it again. `-Stop` ends it from another window, and says so when Windows would not end the session.
    Closing the window is what ends every process the session started, at once. One exception stands until
    D07 T01 S10 is built: an elevated smoke test already running through the \Resolute\ElevatedSmoke task belongs to
    Task Scheduler, and finishes by itself.

.PARAMETER Runner
    The session's runner: Claude Code (`claude`, the project's writer and the default) or Google Antigravity on
    Gemini 4 Carbon (`agy`).

.PARAMETER PrintOnly
    Run the checks and print the command and the goal. Starts nothing, changes nothing.

.PARAMETER InstallShortcut
    Write both Desktop shortcuts for this clone, each with the suite icon and its runner's badge. Run it again
    after moving the clone.

.PARAMETER Stop
    End the active run from outside the session: an operator halt, and the session's process is ended. Work the
    session had not committed stays in the tree for the next run's audit.

.EXAMPLE
    pwsh scripts/start-unattended-run.ps1
    pwsh scripts/start-unattended-run.ps1 -Runner agy
    pwsh scripts/start-unattended-run.ps1 -PrintOnly
    pwsh scripts/start-unattended-run.ps1 -InstallShortcut
    pwsh scripts/start-unattended-run.ps1 -Stop
#>
[CmdletBinding()]
param(
    [ValidateSet('claude', 'agy')][string]$Runner = 'claude',
    [switch]$PrintOnly,
    [switch]$InstallShortcut,
    [switch]$Stop,
    [int]$TokenTimeoutSeconds = 120
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root

# The writer models. scripts/review-dispatch.py records the writer's on every review (--writer-model), so each is an
# exact id. Claude Code runs on the latest Opus at medium effort (operator decision 2026-11-12); a newer Opus is a
# change to this line. Antigravity's model name carries its effort.
$model = 'claude-opus-5-5'
$effort = 'medium'
$carbon = 'gemini-4-carbon-medium'
$tokenVault = 'Conclave'
$tokenItem = 'Claude Code OAuth token (1 year, setup-token)'
$lowMemoryMb = 3000
$runnerName = @{ claude = 'Claude Code'; agy = 'Google Antigravity (Gemini 4 Carbon)' }[$Runner]
$windowTitle = @{ claude = 'Resolute Claude campaign'; agy = 'Resolute Carbon campaign' }[$Runner]

if ($InstallShortcut) {
    # Every path comes from where this clone, PowerShell and the Desktop are on this machine; none is written here.
    # One shortcut for each runner, named and badged like the other repositories' campaign launchers on this
    # machine: the suite icon with its runner's badge in the corner, rendered for this machine by
    # scripts/campaign-icon.py into the user's own application data folder. A runner's mark is its company's
    # trademark and is not kept in this repository: when marks\<name>.svg exists in that folder it is drawn in the
    # badge, and without it the badge carries the runner's colour alone.
    $plain = Join-Path $root 'resources\icons\Resolute.ico'
    if (-not (Test-Path -LiteralPath $plain)) { throw "the shortcut's icon is missing: $plain" }
    $desktop = [Environment]::GetFolderPath('Desktop')
    $local = Join-Path $env:LOCALAPPDATA 'Resolute'
    New-Item -ItemType Directory -Force -Path $local | Out-Null
    $shortcuts = @(
        @{ Runner = 'claude'; Name = 'Resolute Claude campaign'; Icon = 'resolute-campaign-claude.ico'; Fill = '#D97757'; Mark = 'claude.svg'
           Description = 'Start the unattended Resolute campaign in Claude Code' },
        @{ Runner = 'agy'; Name = 'Resolute Carbon campaign'; Icon = 'resolute-campaign-carbon.ico'; Fill = '#4C8DF6'; Mark = 'gemini.svg'
           Description = 'Start the unattended Resolute campaign in Google Antigravity on Gemini 4 Carbon' }
    )
    foreach ($s in $shortcuts) {
        $icon = Join-Path $local $s.Icon
        python (Join-Path $PSScriptRoot 'campaign-icon.py') $icon $s.Fill (Join-Path $local "marks\$($s.Mark)")
        if ($LASTEXITCODE -ne 0) {
            Write-Host "The badged icon for '$($s.Name)' could not be rendered (it needs Pillow, and resvg_py for the mark: python -m pip install Pillow resvg_py, then this again); the shortcut carries the plain suite icon." -ForegroundColor Yellow
            $icon = $plain
        }
        $link = Join-Path $desktop "$($s.Name).lnk"
        $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($link)
        $shortcut.TargetPath = (Get-Process -Id $PID).Path
        $shortcut.Arguments = "-NoLogo -NoExit -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Runner $($s.Runner)"
        $shortcut.WorkingDirectory = $root
        $shortcut.IconLocation = "$icon,0"
        $shortcut.Description = $s.Description
        $shortcut.WindowStyle = 1  # a normal window
        $shortcut.Save()
        Write-Host "Shortcut written: $link"
    }
    # The one shortcut this file wrote before the runners had one each started Claude Code without saying so.
    $old = Join-Path $desktop 'Resolute - Process Plan (Unattended).lnk'
    if (Test-Path -LiteralPath $old) {
        Remove-Item -LiteralPath $old
        Write-Host "Removed the earlier shortcut: $old"
    }
    exit 0
}

if ($Stop) {
    # A stop from outside the session: the guard is halted, and the session's process is ended, because a session
    # with a goal set would otherwise carry on working.
    python scripts/run-guard.py halt --ground operator --reason 'stopped from the launcher (-Stop)' --end-session
    exit $LASTEXITCODE
}

# One line, no double quotes: it is passed to the runner as a single argument. /goal allows 4,000 characters.
$goal = @'
/goal Resolute's implementation plan (todo/implementation-plan.md in {ROOT}) is 100 percent complete: `python scripts/todo-graph.py query stats` shows every section done, each one built, proven by its checkpoint from a real run, reviewed by the pinned reviewer (GPT-6 Astra, through scripts/review-dispatch.py) and stamped through the review-todo-section skill, with no partial ships and `pwsh scripts/check-all.ps1` green. The goal is also met when the run has ended the way the process-plan skill allows while rows are still open: `python scripts/run-guard.py status` no longer prints active, every remaining row is blocked here (an unmet dependency, a waiting Need, a host this session cannot reach, or a section its last completion review left with gaps), and the last message lists each leftover row with what blocks it and what the owner must do to release it. The goal is met at once when the operator stops the run (the same command prints stopped or halted): end what you started in the background and do nothing more. Nothing else counts as done: not an audit, not a status report, not a finished phase while another phase has a ready row. The work: process the plan through the process-plan skill, starting now, unattended, on main and nowhere else. Follow AGENTS.md, DESIGN.md and the skills exactly. Never ask the operator a question: where the answer can be worked out, work it out; otherwise take the industry-standard option, record it with its cost of reversing, and carry on. Act with full autonomy, as the owner would and better: improve the plan, the skills, the agents, the tools and the methods whenever they could be better, repair the run's own failures at their cause, and keep going. Aim for excellence in every section. Resolute must end as the best Windows system utility suite in its class, the one users choose over Sysinternals, PowerToys, CCleaner and every other rival: before building a surface or a feature, look at how the best competitor does it and make Resolute faster, with fewer steps, smarter defaults, better recovery from errors and better accessibility, proven with measurements. Nothing is impossible here: never plan less because something is hard or because no competitor has done it, and never call a row blocked that effort can unblock. No shortcuts, no workarounds, no weakened tests. Frozen behavior stays frozen and proven by parity. Hand fetching and routine checking to {DELEGATES}, and keep every decision and every write. This machine is shared with other work: run full builds and full test suites through `bosun run --`, one heavy job at a time.
'@
$delegates = @{ claude = 'the Sonnet delegates as AGENTS.md says'; agy = 'read-only subagents under the rules AGENTS.md sets for them' }[$Runner]
$goal = $goal.Trim().Replace('{ROOT}', $root).Replace('{DELEGATES}', $delegates)
if ($goal.Contains('"') -or $goal.Contains("`n")) { throw 'the goal must be one line with no double quote' }
if ($goal.Length -gt 4000) { throw "the goal is $($goal.Length) characters; /goal allows 4,000" }

$Host.UI.RawUI.WindowTitle = $windowTitle
Write-Host "${windowTitle}: $root" -ForegroundColor Cyan

# ── What must be there ───────────────────────────────────────
$missing = @($Runner, 'python', 'git') | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) }
if ($missing) {
    Write-Host "Not started: not on PATH: $($missing -join ', ')" -ForegroundColor Red
    exit 2
}
$cli = (Get-Command $Runner).Source

# ── Who holds the tree, said before anything else is done ────
# The guard's admission further down is what decides, under its lock. What is already known is said here, before
# the toolchain, the elevated task and 1Password are asked for anything.
$status = @(python scripts/run-guard.py status)
Write-Host "Run guard: $($status[0])"
$detail = if ($status.Count -gt 1) { $status[1] | ConvertFrom-Json } else { $null }
if ($detail -and -not $PrintOnly) {
    if ($status[0] -eq 'active') {
        Write-Host "Not started: a run is already active here (session $($detail.session_id)). End it first: pwsh scripts/start-unattended-run.ps1 -Stop" -ForegroundColor Red
        exit 1
    }
    if ($detail.review_in_flight) {
        Write-Host 'Not started: a review is in flight, and a review runs alone. Start again when it has returned.' -ForegroundColor Red
        exit 1
    }
}
if ($detail -and $detail.why) { Write-Host "  last run: $($detail.why)" -ForegroundColor DarkGray }
# One tree takes one writer. A Claude Code session already open in this clone may be writing, so the operator, who
# is at the keyboard when this starts, says whether to go on.
$open = @(if ($detail) { $detail.live_here })
if ($open.Count -gt 0) {
    Write-Warning "$($open.Count) Claude Code session(s) already open in this clone: $($open -join ', ')."
    Write-Host 'If one of them is still working here, close THIS window: two writers on one tree corrupt each other''s work.'
    if (-not $PrintOnly) { Read-Host 'Press Enter to start the run anyway' | Out-Null }
}
$openAccepted = $open.Count -gt 0

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

# Elevated tests (RegStudio's manifest is requireAdministrator) run through the one consented task of D07 T01 S7,
# \Resolute\ElevatedSmoke, because nobody is there to answer a UAC prompt during the run. The task holds this clone's
# path, and only an operator at the keyboard can consent to registering it, so this is the moment to ask.
$smokeScript = Join-Path $root 'tools\elevated-smoke.ps1'
if (Test-Path -LiteralPath $smokeScript) {
    # The script's own answer to "would -Run be refused": the task's definition for this clone AND the pinned
    # driver hashes, so a driver that changed since the last consent is caught here and not three hours in.
    $smokeSaid = (& pwsh -NoProfile -File $smokeScript -Check | Out-String).Trim()
    if ($LASTEXITCODE -eq 0) {
        Write-Host 'Elevated tests: ready (the ElevatedSmoke task matches this clone and its pinned drivers; no UAC prompt during the run).'
    } else {
        Write-Warning "Elevated tests: $smokeSaid. Tests that need administrator rights cannot run unattended until it is registered again, and their sections will be left for you."
        if (-not $PrintOnly) {
            $answer = Read-Host 'Press Enter to register it now (one UAC prompt), or type s to skip'
            if ($answer.Trim() -ne 's') {
                & pwsh -NoProfile -File $smokeScript -Register -Replace
                if ($LASTEXITCODE -eq 0) { Write-Host 'Elevated tests: registered for this clone.' }
                else { Write-Warning 'Elevated tests: the registration did not complete (declined or refused); the run starts without it.' }
            }
        }
    }
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

# The copy an earlier start left (scripts/lib/run_guard.py TOKEN_CACHE), encrypted by Windows for this account: the
# fallback when 1Password cannot be read. With the stored login expired too, it is the only way in.
function Read-CachedToken {
    $cache = Join-Path $env:LOCALAPPDATA 'Resolute\claude-token.dpapi'
    if (-not (Test-Path -LiteralPath $cache)) { return $null }
    try {
        $plain = [System.Security.Cryptography.ProtectedData]::Unprotect([IO.File]::ReadAllBytes($cache), $null, 'CurrentUser')
        $value = [Text.Encoding]::UTF8.GetString($plain).Trim()
    } catch {
        # Whatever the reason (held open by a backup or a scanner, no access, not this account's): a cache that
        # cannot be read is the same as no cache, as it is for the guard (run_guard.cached_token), and the start
        # goes on to the stored login. Only the kind of failure is said, never anything read.
        Write-Warning "The cached token could not be read ($($_.Exception.GetType().Name)); it is ignored."
        return $null
    }
    if ($value -cmatch '^sk-ant-oat[0-9]{2}-[A-Za-z0-9_-]{40,}$') { return $value }
    return $null
}

$token = $null
$fromVault = $false
if ($Runner -eq 'claude') {
    $fromVault = $true
    $token = Read-ClaudeToken
    if (-not $token) { $fromVault = $false; $token = Read-CachedToken }
    if ($token -and $fromVault) {
        Write-Host 'Sign-in: the one-year token from 1Password.'
    } elseif ($token) {
        Write-Warning "Sign-in: 1Password did not give the token, so the copy cached for this account is used. If the token was replaced in 1Password since, unlock 1Password and start again."
    } else {
        Write-Warning "Sign-in: neither 1Password ($tokenItem, vault $tokenVault) nor the cache gave the token; starting on the stored Claude Code login."
    }
    Write-Host "Model: $model at $effort effort, permission prompts off, questions off, goal of $($goal.Length) characters."
} else {
    Write-Host "Sign-in: $runnerName's own account on this PC."
    Write-Host "Model: $carbon, permission prompts off, goal of $($goal.Length) characters."
    Write-Host 'The run guard reserves the tree for this session. Its Stop hook and heartbeat are Claude Code''s: this session is kept working by its goal alone.' -ForegroundColor DarkGray
}

# A new session, named to the guard before it starts, so the Stop hook holds a Claude Code session from its first
# turn. Antigravity takes no session id, so its run is held under a name of the launcher's own.
$session = if ($Runner -eq 'claude') { [guid]::NewGuid().ToString() } else { "agy-$([guid]::NewGuid())" }
# --name keeps the window's title: Claude Code replaces the host title with its own session topic otherwise.
# --disallowedTools takes a list, so options follow it and the goal stays the last, positional argument. -i runs
# the opening prompt and keeps the conversation open, as Claude Code does with its prompt argument.
$command = if ($Runner -eq 'claude') {
    @($cli, '--dangerously-skip-permissions', '--disallowedTools', 'AskUserQuestion', '--session-id', $session, '--name', $windowTitle, '--model', $model, '--effort', $effort, $goal)
} else {
    @($cli, '--model', $carbon, '--dangerously-skip-permissions', '-i', $goal)
}

if ($PrintOnly) {
    Write-Host ''
    Write-Host "Would run: $($command[0..($command.Count - 2)] -join ' ') <goal>"
    Write-Host $goal
    exit 0
}

# A copy for a later start at which 1Password cannot be read: encrypted by Windows for this account (DPAPI), passed
# on stdin so it is never an argument.
if ($token -and $fromVault) {
    $cached = $token | python scripts/run-guard.py cache-token
    if ($LASTEXITCODE -ne 0) { Write-Warning "The token was not cached ($cached): a start with 1Password locked uses the stored login." }
}

# ── The run: one session, started here and never again ───────
Write-Host ''
Write-Host 'To stop: type stop in the session, leave it with /exit, or close this window. Each ends the run, and nothing starts it again. Closing the window is the one that ends every process the session started, at once.' -ForegroundColor DarkGray
Write-Host 'One exception until D07 T01 S10 is built: an elevated smoke test already running through the ElevatedSmoke task finishes by itself.' -ForegroundColor DarkGray

$before = $env:CLAUDE_CODE_OAUTH_TOKEN
$code = 0
$admitted = $false
try {
    if ($token) { $env:CLAUDE_CODE_OAUTH_TOKEN = $token }
    $token = $null
    # The one admission: the guard refuses when another session, another launcher or a review holds the tree.
    $admit = @('scripts/run-guard.py', 'start', '--session', $session, '--launcher-pid', $PID)
    if ($openAccepted) { $admit += '--open-ok' }
    $refusal = python @admit
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Not started: $refusal" -ForegroundColor Red
        exit 1
    }
    $admitted = $true
    # The session runs inside a job object held by this call (run_guard.run_session): when it ends, or this window
    # is closed, Windows ends everything the session started.
    python scripts/run-guard.py session '--' @command
    $code = $LASTEXITCODE
} finally {
    if ($admitted) {
        # Said by the launcher, because a run its session, the plan or the operator did not end is over all the same:
        # nothing starts another session. A run already ended keeps its own ending.
        python scripts/run-guard.py ended --session $session --reason "its session ended (exit $code) with the run still open; nothing starts another: start the run again yourself" | Out-Null
    }
    $env:CLAUDE_CODE_OAUTH_TOKEN = $before
}

$status = @(python scripts/run-guard.py status)
Write-Host ''
Write-Host "The run ended: $($status[0])." -ForegroundColor Cyan
$why = if ($status.Count -gt 1) { ($status[1] | ConvertFrom-Json).why } else { $null }
if ($why) { Write-Host "  $why" -ForegroundColor DarkGray }
Write-Host 'Nothing starts it again. Run this shortcut when you want it started.'
exit $code
