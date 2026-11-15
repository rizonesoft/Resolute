<#
.SYNOPSIS
    Steps 1 to 3 of the app split for one app: move its files out of Resolute, make its repository, install the kits.

.DESCRIPTION
    docs/plans/2026-11-15-app-split.md is the tracker and says what each step is. This script does the parts that
    are the same for every app, so they are done the same way every time:

      1  Create D:\Resolute_Bin\<Name>. For each AutoIt tool named in -Au3, copy its tracked files into
         reference\au3\ (one subfolder per tool when there are several), check every copy by hash, write
         MOVED-FROM.tsv, move its untracked builds, executables and logs into reference\au3\local, and
         `git rm` the tracked files in Resolute. Nothing is deleted that is not in git.
      2  LICENSE (GPL v3, copied from Resolute), .gitattributes, .gitignore, sdk.json at the SDK's pushed head,
         `git init`, and a private GitHub repository rizonesoft/<Name>.
      3  The Conclave kits (base, todo, reviewer, toolchain-cpp, lsp), the campaign launcher, its icon renderer,
         sdk.ps1, and .conclave/campaign.json with the shortcuts folder.

    What it leaves to the session, because it differs per app: the README, reference\au3\README.md, the Moved
    markers and claims in Resolute's plan, the README gallery row, and Resolute's commit.

.EXAMPLE
    & tools\app-split\new-app.ps1 -Name ComIntRep -Au3 ComIntRep -Goal "..." -Acceptance "..." -Description "..."
#>
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z][A-Za-z0-9]{1,40}$')][string]$Name,
    [string[]]$Au3 = @(),
    [Parameter(Mandatory)][string]$Goal,
    [Parameter(Mandatory)][string]$Acceptance,
    [Parameter(Mandatory)][string]$Description,
    [string]$Bin = 'D:\Resolute_Bin',
    [string]$Sdk = 'D:\Resolute-SDK',
    [string]$Conclave = 'D:\Conclave-SDK',
    [string]$ShortcutDir = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Resolute Bin')
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Resolute = Split-Path (Split-Path $PSScriptRoot)
foreach ($folder in $Bin, $Sdk, $Conclave, $ShortcutDir) { if (-not [IO.Path]::IsPathRooted($folder)) { throw "'$folder' is not a full path. Pass -Au3 as a list from PowerShell (& tools\app-split\new-app.ps1 -Au3 A,B): through 'pwsh -File' a list spills into the next parameters." } }
$App = Join-Path $Bin $Name
if (Test-Path $App) { throw "$App already exists: this app has been started. Continue it by hand from the tracker." }
foreach ($need in $Sdk, $Conclave) { if (-not (Test-Path $need)) { throw "$need is not there" } }
$dirty = @(& git -C $Sdk status --porcelain)
if ($dirty.Count) { throw "the SDK checkout has uncommitted changes: an app must pin a pushed commit" }
$sdkHead = (& git -C $Sdk rev-parse HEAD).Trim()
if ((& git -C $Sdk rev-parse '@{u}').Trim() -ne $sdkHead) { throw 'the SDK checkout is ahead of its remote: push it first' }

New-Item -ItemType Directory -Path $App | Out-Null
Push-Location $Resolute
try {
    # ── 1. The AutoIt tool's files ───────────────────────────
    $map = [System.Collections.Generic.List[object]]::new()
    $several = $Au3.Count -gt 1
    foreach ($tool in $Au3) {
        $base = if ($several) { "reference/au3/$tool" } else { 'reference/au3' }
        $t = [regex]::Escape($tool)
        foreach ($f in @(& git ls-files)) {
            $dst = switch -Regex ($f) {
                "^resolute_au3/SDK/Concrete/$t/(.+)$"                 { "$base/src/$($Matches[1])"; break }
                "^resolute_au3/Resolute/($t\.[^/]+)$"                  { "$base/shipped/$($Matches[1])"; break }
                "^resolute_au3/Resolute/(Docs|Language)/$t/(.+)$"      { "$base/shipped/$($Matches[1])/$tool/$($Matches[2])"; break }
                "^resolute_au3/SDK/Resources/Icons/((?:[^/]+/)?${t}H?\.ico)$" { "$base/icons/$($Matches[1])"; break }
                "^resolute_au3/SDK/www/update/($t\.[^/]+)$"            { "$base/update/$($Matches[1])"; break }
                "^resolute_au3/samples/Resources/($t-icon\.png)$"      { "$base/icons/$($Matches[1])"; break }
                "^docs/readme/icons/$t\.png$"                          { "$base/icons/$tool-readme.png"; break }
                default { $null }
            }
            if ($dst) { $map.Add([pscustomobject]@{ Src = $f; Dst = $dst }) }
        }
    }
    foreach ($m in $map) {
        $to = Join-Path $App $m.Dst
        New-Item -ItemType Directory -Force (Split-Path $to) | Out-Null
        Copy-Item -LiteralPath (Join-Path $Resolute $m.Src) -Destination $to
        if ((Get-FileHash -LiteralPath (Join-Path $Resolute $m.Src)).Hash -ne (Get-FileHash -LiteralPath $to).Hash) { throw "copy of $($m.Src) differs" }
    }
    if ($map.Count) {
        $map | ForEach-Object { "$($_.Src)`t$($_.Dst)" } | Set-Content (Join-Path $App 'reference\au3\MOVED-FROM.tsv')
        # Untracked, local-only material moves with the tool: old distribution builds, loose executables, run logs.
        foreach ($tool in $Au3) {
            $local = Join-Path $App ($(if ($several) { "reference\au3\$tool\local" } else { 'reference\au3\local' }))
            $moves = @(
                @{ From = "resolute_au3\SDK\Concrete\$tool\Distribution"; To = 'Distribution' },
                @{ From = "resolute_au3\Resolute\$tool.exe"; To = "$tool.exe" },
                @{ From = "resolute_au3\Resolute\${tool}_X64.exe"; To = "${tool}_X64.exe" },
                @{ From = "resolute_au3\Resolute\Logging\$tool"; To = "Logging\$tool" })
            foreach ($mv in $moves) {
                $from = Join-Path $Resolute $mv.From
                if (Test-Path -LiteralPath $from) {
                    $dest = Join-Path $local $mv.To
                    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
                    Move-Item -LiteralPath $from -Destination $dest
                }
            }
            # Whatever untracked is left in the tool's source folder after its tracked files go (a build log, a run log).
            $rest = Join-Path $Resolute "resolute_au3\SDK\Concrete\$tool"
            if (Test-Path -LiteralPath $rest) {
                $dest = Join-Path $local 'source-folder-untracked'
                New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
                Move-Item -LiteralPath $rest -Destination $dest
            }
            # The last distribution zip is the parity baseline, so it is tracked in the app.
            $dist = Join-Path $local 'Distribution'
            if (Test-Path $dist) {
                $zip = Get-ChildItem $dist -Recurse -Filter '*.zip' | Sort-Object { [int]($_.BaseName -replace '\D', '') } | Select-Object -Last 1
                if ($zip) {
                    $keep = Join-Path (Split-Path $local) 'dist'
                    New-Item -ItemType Directory -Force $keep | Out-Null
                    Copy-Item $zip.FullName $keep
                }
            }
        }
        & git rm -q -- @($map.Src)
        if ($LASTEXITCODE -ne 0) { throw 'git rm failed in Resolute' }
    }
    "step 1: $($map.Count) tracked file(s) moved to $App"
}
finally { Pop-Location }

# ── 2. The repository ────────────────────────────────────────
Copy-Item (Join-Path $Resolute 'LICENSE') (Join-Path $App 'LICENSE')
Copy-Item (Join-Path $Sdk '.gitattributes') (Join-Path $App '.gitattributes')
Copy-Item (Join-Path $PSScriptRoot 'app.gitignore') (Join-Path $App '.gitignore')
Set-Content (Join-Path $App 'sdk.json') -Encoding utf8 -Value ("{`n  `"about`": `"The Resolute-SDK commit this repository builds against. scripts/sdk.ps1 puts it at sdk/. Bump the commit to take a newer SDK.`",`n  `"repository`": `"https://github.com/rizonesoft/Resolute-SDK.git`",`n  `"commit`": `"$sdkHead`"`n}")
& git -C $App init -q -b main

# ── 3. The kits and the launcher ─────────────────────────────
Push-Location $Conclave
try {
    $out = & python forge.py init $App --kit todo --kit reviewer --kit toolchain-cpp --kit lsp --goal $Goal --acceptance $Acceptance 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0 -or $out -notmatch '"goal_applied": true') { throw "forge init failed:`n$out" }
}
finally { Pop-Location }
foreach ($f in 'start-run.ps1', 'campaign-icon.py') { Copy-Item (Join-Path $PSScriptRoot $f) (Join-Path $App "scripts\$f") }
Copy-Item (Join-Path $Resolute 'scripts\sdk.ps1') (Join-Path $App 'scripts\sdk.ps1')
$campaign = [ordered]@{ name = $Name; icon = "brand/$($Name.ToLowerInvariant()).ico"; shortcut_dir = $ShortcutDir }
Set-Content (Join-Path $App '.conclave\campaign.json') -Encoding utf8 -Value ($campaign | ConvertTo-Json)
"step 3: kits installed, launcher in place"

Push-Location $App
try {
    & gh repo create "rizonesoft/$Name" --private --description $Description | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "gh repo create rizonesoft/$Name failed" }
    & git remote add origin "https://github.com/rizonesoft/$Name.git"
    "step 2: https://github.com/rizonesoft/$Name (private), sdk.json at $sdkHead"
}
finally { Pop-Location }
