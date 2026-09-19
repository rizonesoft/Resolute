#!/usr/bin/env bash
#
# Run one of this repository's PowerShell scripts on the Windows side, from WSL.
#
# The pinned toolchain under reskit/ is Windows binaries, and Windows CMake
# cannot read WSL paths, so the .ps1 scripts cannot run under Linux pwsh.
# This wrapper translates the script path with wslpath and re-invokes it
# under Windows PowerShell, where every path the scripts then derive
# (RepoRoot, reskit/, build/) is a native Windows path.
#
# Usage:
#   scripts/wsl.sh <script.ps1> [args...]
#   scripts/wsl.sh build.ps1 -All -Config Release
#   scripts/wsl.sh check-all.ps1
#
# The script name is resolved under scripts/ (a bare name) or taken as a
# repo-relative path. Remaining arguments pass through verbatim. The
# repository scripts take no path arguments, only switches and names, so
# no argument translation is needed.
#
# Requires the checkout on a Windows-visible drive (/mnt/<letter>) and
# Windows PowerShell 7. Override the interpreter with WSL_PWSH.

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname -- "$SCRIPT_DIR")"

usage() {
    echo "usage: scripts/wsl.sh <script.ps1> [args...]" >&2
    echo "  runs a repository PowerShell script on the Windows side, from WSL" >&2
    echo "  example: scripts/wsl.sh build.ps1 -All -Config Release" >&2
}

# Outside WSL this wrapper has no job: the .ps1 runs directly.
if ! command -v wslpath >/dev/null 2>&1; then
    echo "wsl.sh: not running under WSL (wslpath not found)" >&2
    echo "  fix: run the script directly: pwsh scripts/<name>.ps1" >&2
    exit 2
fi

if (($# == 0)); then
    usage
    exit 2
fi

name="$1"
shift

case "$name" in
    *.ps1) ;;
    *)
        echo "wsl.sh: not a .ps1 script: '$name'" >&2
        usage
        exit 2
        ;;
esac

case "$name" in
    */*) candidate="$REPO_ROOT/$name" ;;
    *)   candidate="$SCRIPT_DIR/$name" ;;
esac

if [[ ! -f "$candidate" ]]; then
    echo "wsl.sh: unknown script '$name'" >&2
    echo "  known: $(ls "$SCRIPT_DIR"/*.ps1 2>/dev/null | xargs -n1 basename | tr '\n' ' ')" >&2
    exit 2
fi

# A destructive script outside the repo must never run through here by
# accident. realpath -m canonicalises without requiring existence.
resolved="$(realpath -m "$candidate")"
case "$resolved" in
    "$REPO_ROOT"/*) ;;
    *)
        echo "wsl.sh: refusing a script outside the repository: $resolved" >&2
        exit 2
        ;;
esac

WIN_REPO="$(wslpath -w "$REPO_ROOT")"
case "$WIN_REPO" in
    '\\\\'*)
        echo "wsl.sh: warning: the checkout is not on a Windows drive ($WIN_REPO)" >&2
        echo "  Windows tools reach it over the WSL network share, which is slow" >&2
        echo "  and fragile for builds. Prefer a checkout under /mnt/<letter>." >&2
        ;;
esac
WIN_SCRIPT="$(wslpath -w "$resolved")"

# Windows PowerShell 7 first; the repository scripts target pwsh per README.
# Windows PowerShell 5.1 is a fallback with a warning, not a silent default.
PWSH="${WSL_PWSH:-}"
if [[ -z "$PWSH" ]]; then
    if [[ -f "/mnt/c/Program Files/PowerShell/7/pwsh.exe" ]]; then
        PWSH="/mnt/c/Program Files/PowerShell/7/pwsh.exe"
    elif [[ -f "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" ]]; then
        PWSH="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
        echo "wsl.sh: warning: Windows PowerShell 7 not found, using 5.1" >&2
    else
        echo "wsl.sh: no Windows PowerShell found" >&2
        echo "  looked for: /mnt/c/Program Files/PowerShell/7/pwsh.exe" >&2
        echo "  looked for: /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" >&2
        echo "  fix: install PowerShell 7 on the Windows side, or set WSL_PWSH" >&2
        exit 1
    fi
fi

if (($# > 0)); then
    exec "$PWSH" -NoProfile -File "$WIN_SCRIPT" "$@"
else
    exec "$PWSH" -NoProfile -File "$WIN_SCRIPT"
fi
