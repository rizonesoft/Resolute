<#
.SYNOPSIS
    Turn a kept check-all output into the failure summary a CI run shows.

.DESCRIPTION
    The gates workflow keeps what scripts/check-all.ps1 printed and, when the
    run fails, calls this to put on the run page what a person needs first:
    the gate table as check-all printed it, then each failed gate under its
    own heading with the last lines of that gate's own log.

    A tail of the combined output is not that: check-all shows 25 lines per
    failed gate, and several failures push the table and the earlier ones
    out of any fixed tail (D00 T01 section 10, completion review gap 2).

    It reads two things check-all already writes, and adds no format of its
    own: the table rows, and the line that names each failed gate's log
    ("--- <gate>: last 25 lines of <log> ---").

.PARAMETER Output
    The file holding check-all's output.

.PARAMETER LogDir
    The directory holding the per-gate logs. Default: build/logs.

.PARAMETER Lines
    How many lines of each failed gate's log to show. Default: 80.

.EXAMPLE
    pwsh scripts/ci-gate-summary.ps1 -Output build/logs/check-all-output.txt >> $env:GITHUB_STEP_SUMMARY
#>
param(
    [Parameter(Mandatory)][string]$Output,
    [string]$LogDir = 'build/logs',
    [int]$Lines = 80
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Output)) {
    'The run failed before check-all wrote anything: see the step that failed.'
    exit 0
}

$text = @(Get-Content -LiteralPath $Output)
$rows = @($text | Where-Object { $_ -match '^\s{2}\S.*?\s(ok|FAILED|not present|current|behind|unknown)\s+[0-9.]+s' })
$failed = @($text | ForEach-Object { if ($_ -match '^\s*--- (.+): last \d+ lines of (\S+) ---\s*$') { [pscustomobject]@{ Gate = $Matches[1]; Log = $Matches[2] } } })

'### check-all: the gates'
''
'```'
if ($rows) { $rows } else { 'check-all printed no gate table: it stopped before its summary.' }
'```'

foreach ($gate in $failed) {
    ''
    "### Failed: $($gate.Gate)"
    ''
    $log = Join-Path $LogDir $gate.Log
    if (Test-Path -LiteralPath $log) {
        "The last $Lines lines of ``$($gate.Log)``:"
        ''
        '```'
        Get-Content -LiteralPath $log -Tail $Lines
        '```'
    } else {
        "``$($gate.Log)`` is not in $LogDir, so there is nothing to show for this gate."
    }
}

if (-not $failed) {
    ''
    'check-all named no failed gate. If the run still failed, the cause is in the step that failed.'
}
