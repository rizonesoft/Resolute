#!/usr/bin/env python3
"""Starts a language server for Claude Code, on the toolchain this repository pins.

    python scripts/lsp-launch.py clangd     C and C++: the clangd in reskit/llvm-mingw, beside the compiler the build uses
    python scripts/lsp-launch.py pyright    Python: pyright-langserver from PATH (npm install -g pyright)

The plugin in tools/claude-plugins/resolute-lsp names this file as each server's command. The server talks to Claude
Code over this process's own stdin and stdout, which it inherits; this process only finds it and waits. clangd reads
the debug preset's compile database (build/debug/compile_commands.json, written by `pwsh scripts/build.ps1 Resolute
-Config Debug`), so its diagnostics are what that build compiles, and runs clang-tidy with the repository's
.clang-tidy, so a tidy finding shows at the edit instead of at the ratchet. It is the pinned clangd rather than the
one on PATH because the tree targets MinGW-w64 with llvm-mingw's own headers: another clangd resolves different
ones. Both servers are bounded for a machine that runs several sessions: clangd indexes on 4 threads and keeps
preambles on disk, and pyrightconfig.json limits pyright to the tracked script folders.

On Windows this process puts itself in a kill-on-close job object before it starts the server, so the server and
anything it starts end when this process ends, however that happens. It also watches the process that started it
(Claude Code) and ends itself when that one goes, because Windows does not end a child with its parent. So neither
a killed launcher nor a killed session leaves a language server behind. Stdlib only.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
COMPILE_DB = os.path.join(REPO, "build", "debug")
CLANGD = os.path.join(REPO, "reskit", "llvm-mingw", "bin", "clangd.exe")

_JOB = None  # kept for the life of the process: closing this handle is what ends the server


class LaunchError(Exception):
    """Why the server cannot start; printed to stderr, where Claude Code's plugin errors show it."""


def clangd() -> list[str]:
    if not os.path.isfile(CLANGD):
        raise LaunchError(f"{CLANGD} is missing; install the pinned toolchain with: pwsh scripts/bootstrap.ps1")
    if not os.path.isfile(os.path.join(COMPILE_DB, "compile_commands.json")):
        print("lsp-launch: no compile database yet; run `pwsh scripts/build.ps1 Resolute -Config Debug` for exact diagnostics", file=sys.stderr)
    # --query-driver lets clangd ask the pinned compiler for its own include paths, which the database does not list.
    driver = os.path.join(REPO, "reskit", "llvm-mingw", "bin", "*").replace("\\", "/")
    return [CLANGD, f"--compile-commands-dir={COMPILE_DB}", f"--query-driver={driver}", "--background-index", "-j=4",
            "--pch-storage=disk", "--clang-tidy", "--header-insertion=never", "--log=error"]


def pyright() -> list[str]:
    server = shutil.which("pyright-langserver")
    if not server:
        raise LaunchError("pyright-langserver is not on PATH; install it with: npm install -g pyright")
    return [server, "--stdio"]


def end_children_with_this_process() -> None:
    """Join a kill-on-close job object. Every process started afterwards is born inside it, and Windows ends them all
    when this process ends. Raises OSError when Windows refuses, so nothing is started outside a job."""
    global _JOB
    import ctypes
    from ctypes import wintypes

    class Basic(ctypes.Structure):
        _fields_ = [("PerProcessUserTimeLimit", ctypes.c_longlong), ("PerJobUserTimeLimit", ctypes.c_longlong),
                    ("LimitFlags", wintypes.DWORD), ("MinimumWorkingSetSize", ctypes.c_size_t),
                    ("MaximumWorkingSetSize", ctypes.c_size_t), ("ActiveProcessLimit", wintypes.DWORD),
                    ("Affinity", ctypes.c_size_t), ("PriorityClass", wintypes.DWORD), ("SchedulingClass", wintypes.DWORD)]

    class Extended(ctypes.Structure):
        _fields_ = [("Basic", Basic), ("IoInfo", ctypes.c_ulonglong * 6), ("ProcessMemoryLimit", ctypes.c_size_t),
                    ("JobMemoryLimit", ctypes.c_size_t), ("PeakProcessMemoryUsed", ctypes.c_size_t),
                    ("PeakJobMemoryUsed", ctypes.c_size_t)]

    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel.CreateJobObjectW.restype = wintypes.HANDLE
    kernel.CreateJobObjectW.argtypes = (ctypes.c_void_p, wintypes.LPCWSTR)
    kernel.SetInformationJobObject.argtypes = (wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.DWORD)
    kernel.AssignProcessToJobObject.argtypes = (wintypes.HANDLE, wintypes.HANDLE)
    kernel.GetCurrentProcess.restype = wintypes.HANDLE
    info = Extended()
    info.Basic.LimitFlags = 0x2000  # JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
    job = kernel.CreateJobObjectW(None, None)
    if (not job or not kernel.SetInformationJobObject(job, 9, ctypes.byref(info), ctypes.sizeof(info))
            or not kernel.AssignProcessToJobObject(job, kernel.GetCurrentProcess())):
        raise OSError(f"could not join a kill-on-close job object (error {ctypes.get_last_error()})")
    _JOB = job


def end_with_parent() -> None:
    """Exit when the process that started this one ends: a thread waits on the parent's handle, and exiting closes
    the job object, which ends the server.

    The handle is checked to be the real parent: a parent starts before its child, so a process under the parent's id
    that started after this one is a stranger that took the id of a parent already gone, and nothing is started."""
    import ctypes
    import threading
    from ctypes import wintypes

    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel.OpenProcess.restype = wintypes.HANDLE
    kernel.OpenProcess.argtypes = (wintypes.DWORD, wintypes.BOOL, wintypes.DWORD)
    kernel.GetCurrentProcess.restype = wintypes.HANDLE
    kernel.GetProcessTimes.argtypes = (wintypes.HANDLE, *[ctypes.POINTER(wintypes.FILETIME)] * 4)
    kernel.WaitForSingleObject.argtypes = (wintypes.HANDLE, wintypes.DWORD)

    def started(handle) -> int:
        times = [wintypes.FILETIME() for _ in range(4)]
        if not kernel.GetProcessTimes(handle, *[ctypes.byref(t) for t in times]):
            raise LaunchError(f"could not read a process start time (error {ctypes.get_last_error()})")
        return (times[0].dwHighDateTime << 32) | times[0].dwLowDateTime

    # SYNCHRONIZE to wait on it, PROCESS_QUERY_LIMITED_INFORMATION to read when it started
    parent = kernel.OpenProcess(0x00100000 | 0x1000, False, os.getppid())
    if not parent:
        raise LaunchError(f"the process that started this launcher is gone (error {ctypes.get_last_error()})")
    if started(parent) > started(kernel.GetCurrentProcess()):
        raise LaunchError("the process that started this launcher is gone (its id belongs to a newer process)")

    def wait() -> None:
        kernel.WaitForSingleObject(parent, 0xFFFFFFFF)
        os._exit(1)

    threading.Thread(target=wait, daemon=True).start()


def main(argv: list[str]) -> int:
    servers = {"clangd": clangd, "pyright": pyright}
    if len(argv) != 1 or argv[0] not in servers:
        print((__doc__ or "").split("\n\n")[1], file=sys.stderr)
        return 2
    try:
        if os.name == "nt":
            end_with_parent()
            end_children_with_this_process()
        child = subprocess.Popen(servers[argv[0]](), cwd=REPO)
    except (LaunchError, OSError) as error:
        print(f"lsp-launch: {error}", file=sys.stderr)
        return 1
    return child.wait()


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
