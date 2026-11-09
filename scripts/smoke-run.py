#!/usr/bin/env python3
"""Standing smoke run over the shipped suite (D07 T01 S4).

Drives every shipped tool through start, main surface, About, preferences,
and exit, by Win32 messages only (no synthetic input, no foreground
requirement), captures each main surface with PrintWindow, and writes one
report to build/smoke/smoke-report.md.

The tool inventory is imported from scripts/conformance-check.py's TOOLS
registry, never re-listed. A step a tool does not ship is reported `absent`
by name, never passed and never a failure; a surface the per-tool step
table expects that does not appear is a `fail`.

Admission follows the desktop fence in docs/testing.md: `--visible` when
the operator asks, collecting when RESOLUTE_IDLE_COLLECT=1 or inside
02:00-06:50 local, otherwise the run refuses by name and launches nothing.
A collecting run stands down when operator input resumes.

Usage:
  python scripts/smoke-run.py [--visible] [--drill] [--tools A,B]
  python scripts/smoke-run.py --elevate --visible --tools RegStudio
  python scripts/smoke-run.py --self-test

`--elevate` relaunches this driver through the shell's `runas` consent
prompt when it is not already elevated, then exits with the child's code.
A declined prompt records `blocked` naming the decline and exits 2; the
consent prompt is never bypassed or suppressed.

Exit codes: 0 clean, 1 a tool or step failed, 2 refused or stood down.
Stdlib only, like every TODO tool.
"""

import argparse
import ctypes
import hashlib
import importlib.util
import json
import os
import struct
import subprocess
import sys
import time
import zlib
from ctypes import wintypes
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SMOKE_DIR = ROOT / "build" / "smoke"
PREV_DIR = SMOKE_DIR / "prev"

sys.path.insert(0, str(ROOT / "tests"))
sys.path.insert(0, str(ROOT / "scripts"))

# Per-tool expected surfaces beyond start/main/exit, as shipped today.
# Preferences ships for neither tool yet (D01 T03 S2 owns the shell); About
# ships only in RegStudio (Help > About). The step activates for a tool
# when its surface ships: flipping a value here is the whole change.
ABOUT_IDM = 4001  # RegStudio IDM_HELP_ABOUT; the launcher has no menu.
EXPECTED = {
    "Resolute": {"about": False, "preferences": False},
    "RegStudio": {"about": True, "preferences": False},
}
DEFAULT_EXPECTED = {"about": False, "preferences": False}
EXPECTED["SmokeDrillDeaf"] = {"about": True, "preferences": False}

STEPS = ("start", "main", "about", "preferences", "exit")
TIMEOUTS = {"launch": 20.0, "window": 15.0, "message": 10.0, "dialog": 10.0, "exit": 10.0}


def load_tools():
    """The shipped-tool inventory, consumed from the conformance registry."""
    path = ROOT / "scripts" / "conformance-check.py"
    spec = importlib.util.spec_from_file_location("conformance_check", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.TOOLS


def expected_for(name):
    return EXPECTED.get(name, DEFAULT_EXPECTED)


def step_table(name):
    """(step, expected) pairs: an unshipped surface is absent, not a pass."""
    exp = expected_for(name)
    return [
        ("start", True),
        ("main", True),
        ("about", exp["about"]),
        ("preferences", exp["preferences"]),
        ("exit", True),
    ]


# ---------------------------------------------------------------- pixels

def pixel_variance(bgra: bytes) -> float:
    """Mean absolute deviation of luminance over a BGRA buffer."""
    if not bgra:
        return 0.0
    total = 0
    n = 0
    for i in range(0, len(bgra) - 3, 4):
        total += (bgra[i] + bgra[i + 1] + bgra[i + 2]) // 3
        n += 1
    if n == 0:
        return 0.0
    mean = total / n
    dev = 0.0
    for i in range(0, len(bgra) - 3, 4):
        dev += abs((bgra[i] + bgra[i + 1] + bgra[i + 2]) // 3 - mean)
    return dev / n


def is_blank(bgra: bytes) -> bool:
    return pixel_variance(bgra) < 1.0


def pixels_digest(bgra: bytes) -> str:
    return hashlib.sha256(bgra).hexdigest()


def compare_captures(previous: bytes | None, current: bytes) -> str:
    if previous is None:
        return "first-run"
    return "unchanged" if pixels_digest(previous) == pixels_digest(current) else "changed"


def png_encode(width: int, height: int, bgra: bytes) -> bytes:
    """Encode a BGRA top-down buffer as an RGB PNG (stdlib zlib)."""
    stride = width * 4
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        row = bgra[y * stride:(y + 1) * stride]
        for x in range(width):
            i = x * 4
            raw += bytes((row[i + 2], row[i + 1], row[i]))
    def chunk(kind: bytes, data: bytes) -> bytes:
        c = kind + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr)
            + chunk(b"IDAT", zlib.compress(bytes(raw), 6)) + chunk(b"IEND", b""))


# ---------------------------------------------------------------- report

def render_report(rows, verdict, notes):
    lines = ["# Smoke report", ""]
    for note in notes:
        lines.append(note)
    if notes:
        lines.append("")
    lines.append("| Tool | Step | Result | Detail |")
    lines.append("| --- | --- | --- | --- |")
    for tool, step, result, detail in rows:
        lines.append(f"| {tool} | {step} | {result} | {detail} |")
    lines.append("")
    lines.append(f"Suite verdict: **{verdict}**")
    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------- fence

def admission(visible: bool, now: datetime, env) -> tuple[bool, str, bool]:
    """(admitted, mode, collecting). Collecting runs stand down on input."""
    if visible:
        return True, "visible (operator asked)", False
    if env.get("RESOLUTE_IDLE_COLLECT") == "1":
        return True, "collecting (RESOLUTE_IDLE_COLLECT=1)", True
    minute = now.hour * 60 + now.minute
    if 120 <= minute < 410:
        return True, "collecting (night window 02:00-06:50)", True
    return False, "refused: desktop fence (not visible, not collecting, outside 02:00-06:50)", False


# ---------------------------------------------------------------- elevation

ELEVATE_WAIT_TIMEOUT = 3600.0
TERMINATE_CONFIRM_MS = 5000  # bound for confirming a terminated child exited
ERROR_CANCELLED = 1223  # consent declined at the runas prompt
TOKEN_QUERY_ACCESS = 0x0008
TOKEN_ELEVATION_CLASS = 20
SEE_MASK_NOCLOSEPROCESS = 0x00000040
SW_SHOWNORMAL = 1
WAIT_OBJECT_0 = 0
WAIT_TIMEOUT = 0x00000102
WAIT_FAILED = 0xFFFFFFFF


class ElevationDeclined(Exception):
    """The operator declined the shell's elevation consent prompt."""


class ElevationFailed(Exception):
    """The elevated relaunch failed by name (shell, handle, wait, exit).

    `launched` is True when the elevated child was launched before the
    failure, so the caller never reports that nothing was launched.
    """

    def __init__(self, message, launched=False):
        super().__init__(message)
        # False: no child launched. True: child launched. None: the
        # shell call succeeded but returned no handle, so whether a
        # child launched cannot be verified.
        self.launched = launched


def is_elevated():
    """True when this process holds an elevated token, False when not.

    None when the token query itself fails: the caller refuses by name
    rather than guessing at the privilege it holds.
    """
    token = wintypes.HANDLE()
    if not advapi32.OpenProcessToken(kernel32.GetCurrentProcess(),
                                     TOKEN_QUERY_ACCESS, ctypes.byref(token)):
        return None
    try:
        elevation = wintypes.DWORD()
        size = wintypes.DWORD()
        if not advapi32.GetTokenInformation(token, TOKEN_ELEVATION_CLASS,
                                            ctypes.byref(elevation),
                                            ctypes.sizeof(elevation),
                                            ctypes.byref(size)):
            return None
        return elevation.value != 0
    finally:
        kernel32.CloseHandle(token)


def elevated_child_args(argv):
    """The same driver invocation, marked as the elevated child.

    Drops --elevate (the child is already elevated, or refuses) and adds
    --elevated-child so a child that arrives unelevated refuses by name
    instead of prompting again. Every other argument is kept identical.
    """
    child = [a for a in argv if a != "--elevate"]
    if "--elevated-child" not in child:
        child.append("--elevated-child")
    return child


class _ShellExecuteInfoW(ctypes.Structure):
    _fields_ = [("cbSize", wintypes.DWORD), ("fMask", wintypes.ULONG),
                ("hwnd", wintypes.HWND), ("lpVerb", wintypes.LPCWSTR),
                ("lpFile", wintypes.LPCWSTR), ("lpParameters", wintypes.LPCWSTR),
                ("lpDirectory", wintypes.LPCWSTR), ("nShow", ctypes.c_int),
                ("hInstApp", wintypes.HINSTANCE), ("lpIDList", ctypes.c_void_p),
                ("lpClass", wintypes.LPCWSTR), ("hkeyClass", wintypes.HKEY),
                ("dwHotKey", wintypes.DWORD), ("hIcon", wintypes.HANDLE),
                ("hProcess", wintypes.HANDLE)]


def _shell_execute_runas(child_argv):
    """Launch sys.executable elevated via the runas verb; return its handle."""
    info = _ShellExecuteInfoW()
    info.cbSize = ctypes.sizeof(info)
    info.fMask = SEE_MASK_NOCLOSEPROCESS
    info.lpVerb = "runas"
    info.lpFile = sys.executable
    info.lpParameters = subprocess.list2cmdline(
        [str(Path(__file__).resolve())] + list(child_argv))
    info.lpDirectory = str(ROOT)
    info.nShow = SW_SHOWNORMAL
    if not shell32.ShellExecuteExW(ctypes.byref(info)):
        err = ctypes.get_last_error()
        if err == ERROR_CANCELLED:
            raise ElevationDeclined(
                "elevation consent declined at the runas prompt")
        raise ElevationFailed(f"ShellExecuteExW failed (Win32 error {err})")
    return info.hProcess


def _wait_process(handle, timeout_ms):
    """WAIT_OBJECT_0, WAIT_TIMEOUT or WAIT_FAILED for the handle."""
    return kernel32.WaitForSingleObject(handle, timeout_ms)


def _process_exit_code(handle):
    code = wintypes.DWORD()
    if not kernel32.GetExitCodeProcess(handle, ctypes.byref(code)):
        return None
    return int(code.value)


def _close_handle(handle):
    if handle:
        kernel32.CloseHandle(handle)


def _terminate_process(handle):
    if handle:
        return bool(kernel32.TerminateProcess(handle, 2))
    return False


def _terminate_and_confirm(handle):
    """Terminate the owned child and confirm it exited; return a note.

    Termination is asynchronous, so the note says plainly when exit
    could not be confirmed rather than claiming the child is gone.
    """
    if not _terminate_process(handle):
        return "TerminateProcess failed; child termination not confirmed"
    try:
        waited = _wait_process(handle, TERMINATE_CONFIRM_MS)
    except KeyboardInterrupt:
        return "interrupted again while confirming; child termination not confirmed"
    if waited != WAIT_OBJECT_0:
        return f"child termination not confirmed (wait 0x{waited & 0xFFFFFFFF:08x})"
    return "terminated and confirmed exited"


def relaunch_elevated(argv, timeout=ELEVATE_WAIT_TIMEOUT):
    """Relaunch this driver elevated and return the child's exit code.

    Bounded and interruptible: a timeout or keyboard interrupt terminates
    the child and raises ElevationFailed, so an elevated run is never
    abandoned silently. The process handle is freed on every path.
    """
    handle = _shell_execute_runas(elevated_child_args(list(argv)))
    if not handle:
        raise ElevationFailed("ShellExecuteExW returned no process handle", launched=None)
    try:
        deadline = time.monotonic() + timeout
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                note = _terminate_and_confirm(handle)
                raise ElevationFailed(
                    f"elevated child did not finish within {timeout:.0f}s; {note}",
                    launched=True)
            waited = _wait_process(handle, min(100, int(remaining * 1000)))
            if waited == WAIT_OBJECT_0:
                break
            if waited == WAIT_TIMEOUT:
                continue
            note = _terminate_and_confirm(handle)
            raise ElevationFailed(
                f"WaitForSingleObject failed (0x{waited & 0xFFFFFFFF:08x}); {note}",
                launched=True)
        code = _process_exit_code(handle)
        if code is None:
            raise ElevationFailed("GetExitCodeProcess failed for the elevated child",
                                  launched=True)
        return code
    except KeyboardInterrupt:
        note = _terminate_and_confirm(handle)
        raise ElevationFailed(
            f"interrupted while the elevated child was owned; {note}",
            launched=True)
    finally:
        _close_handle(handle)


# ---------------------------------------------------------------- win32

user32 = ctypes.WinDLL("user32", use_last_error=True)
shell32 = ctypes.WinDLL("shell32", use_last_error=True)
advapi32 = ctypes.WinDLL("advapi32", use_last_error=True)
gdi32 = ctypes.WinDLL("gdi32", use_last_error=True)
kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)

WM_CLOSE = 0x0010
WM_COMMAND = 0x0111
IDOK = 1
PW_RENDERFULLCONTENT = 0x00000002
ABORTED = "aborted"  # wait_window result when the stand-down abort fires


class LASTINPUTINFO(ctypes.Structure):
    _fields_ = [("cbSize", wintypes.UINT), ("dwTime", wintypes.DWORD)]


def _bind():
    """Pointer-safe signatures: handles must not truncate on 64-bit Python."""
    u, g, k = user32, gdi32, kernel32
    u.GetWindowDC.restype = wintypes.HDC
    u.GetWindowDC.argtypes = [wintypes.HWND]
    u.ReleaseDC.restype = ctypes.c_int
    u.ReleaseDC.argtypes = [wintypes.HWND, wintypes.HDC]
    u.PrintWindow.restype = wintypes.BOOL
    u.PrintWindow.argtypes = [wintypes.HWND, wintypes.HDC, wintypes.UINT]
    u.EnumWindows.restype = wintypes.BOOL
    u.GetWindowRect.restype = wintypes.BOOL
    u.GetWindowRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]
    u.PostMessageW.restype = wintypes.BOOL
    u.PostMessageW.argtypes = [wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM]
    u.GetLastInputInfo.restype = wintypes.BOOL
    u.GetLastInputInfo.argtypes = [ctypes.POINTER(LASTINPUTINFO)]
    g.CreateCompatibleDC.restype = wintypes.HDC
    g.CreateCompatibleDC.argtypes = [wintypes.HDC]
    g.CreateCompatibleBitmap.restype = wintypes.HBITMAP
    g.CreateCompatibleBitmap.argtypes = [wintypes.HDC, ctypes.c_int, ctypes.c_int]
    g.SelectObject.restype = wintypes.HGDIOBJ
    g.SelectObject.argtypes = [wintypes.HDC, wintypes.HGDIOBJ]
    g.DeleteObject.restype = wintypes.BOOL
    g.DeleteObject.argtypes = [wintypes.HGDIOBJ]
    g.DeleteDC.restype = wintypes.BOOL
    g.DeleteDC.argtypes = [wintypes.HDC]
    g.GetDIBits.restype = ctypes.c_int
    g.GetDIBits.argtypes = [wintypes.HDC, wintypes.HBITMAP, wintypes.UINT, wintypes.UINT,
                            ctypes.c_void_p, ctypes.c_void_p, wintypes.UINT]
    k.CreateJobObjectW.restype = wintypes.HANDLE
    k.CreateJobObjectW.argtypes = [ctypes.c_void_p, wintypes.LPCWSTR]
    k.SetInformationJobObject.restype = wintypes.BOOL
    k.SetInformationJobObject.argtypes = [wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.DWORD]
    k.AssignProcessToJobObject.restype = wintypes.BOOL
    k.AssignProcessToJobObject.argtypes = [wintypes.HANDLE, wintypes.HANDLE]
    k.CloseHandle.restype = wintypes.BOOL
    k.CloseHandle.argtypes = [wintypes.HANDLE]
    k.GetTickCount.restype = wintypes.DWORD
    k.GetCurrentProcess.restype = wintypes.HANDLE
    advapi32.OpenProcessToken.restype = wintypes.BOOL
    advapi32.OpenProcessToken.argtypes = [wintypes.HANDLE, wintypes.DWORD, ctypes.POINTER(wintypes.HANDLE)]
    advapi32.GetTokenInformation.restype = wintypes.BOOL
    advapi32.GetTokenInformation.argtypes = [wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p,
                                      wintypes.DWORD, ctypes.POINTER(wintypes.DWORD)]
    k.WaitForSingleObject.restype = wintypes.DWORD
    k.WaitForSingleObject.argtypes = [wintypes.HANDLE, wintypes.DWORD]
    k.GetExitCodeProcess.restype = wintypes.BOOL
    k.GetExitCodeProcess.argtypes = [wintypes.HANDLE, ctypes.POINTER(wintypes.DWORD)]
    k.TerminateProcess.restype = wintypes.BOOL
    k.TerminateProcess.argtypes = [wintypes.HANDLE, wintypes.UINT]
    shell32.ShellExecuteExW.restype = wintypes.BOOL
    shell32.ShellExecuteExW.argtypes = [ctypes.c_void_p]
    ntdll = ctypes.windll.ntdll
    ntdll.NtResumeProcess.restype = ctypes.c_long
    ntdll.NtResumeProcess.argtypes = [wintypes.HANDLE]


_bind()


def last_input_tick() -> int:
    info = LASTINPUTINFO()
    info.cbSize = ctypes.sizeof(info)
    if not user32.GetLastInputInfo(ctypes.byref(info)):
        return -1
    return int(info.dwTime)


def idle_seconds() -> float:
    tick = last_input_tick()
    if tick < 0:
        return 0.0
    return (kernel32.GetTickCount() - tick) / 1000.0


def tick_resumed(baseline_tick: int, current_tick: int) -> bool:
    """Input happened when the last-input tick advanced past the baseline.

    Ticks are 32-bit milliseconds and wrap: a small positive modular delta
    is new input. A failed query stands a collecting run down (fail closed)
    rather than silently continuing to drive windows.
    """
    if baseline_tick < 0:
        return False
    if current_tick < 0:
        return True
    delta = (current_tick - baseline_tick) & 0xFFFFFFFF
    return 0 < delta < 0x80000000


def pid_windows(pid: int):
    """Visible top-level windows owned by pid: [(hwnd, class, title)]."""
    found = []

    @ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    def cb(hwnd, _):
        owner = wintypes.DWORD()
        user32.GetWindowThreadProcessId(hwnd, ctypes.byref(owner))
        if owner.value == pid and user32.IsWindowVisible(hwnd):
            cls = ctypes.create_unicode_buffer(64)
            user32.GetClassNameW(hwnd, cls, 64)
            title = ctypes.create_unicode_buffer(256)
            user32.GetWindowTextW(hwnd, title, 256)
            found.append((hwnd, cls.value, title.value))
        return True

    user32.EnumWindows(cb, 0)
    return found


def wait_window(pid: int, timeout: float, want_dialog: bool = False, abort=None):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if abort is not None and abort():
            return ABORTED
        for hwnd, cls, title in pid_windows(pid):
            if want_dialog and cls == "#32770":
                return hwnd
            if not want_dialog and cls != "#32770":
                return hwnd
        time.sleep(0.1)
    return None


class _CaptureNoImage(Exception):
    """PrintWindow produced no image; release failures still aggregate."""


def capture_window(hwnd) -> tuple[int, int, bytes] | None:
    """PrintWindow into a DIB; returns (width, height, BGRA top-down).

    Every acquired GDI object is released independently, the original
    bitmap is restored before deletion, and a failed release raises so the
    step fails by name instead of leaking silently.
    """
    rect = wintypes.RECT()
    if not user32.GetWindowRect(hwnd, ctypes.byref(rect)):
        return None
    width, height = rect.right - rect.left, rect.bottom - rect.top
    if width <= 0 or height <= 0:
        return None
    hdc = user32.GetWindowDC(hwnd)
    if not hdc:
        return None
    mem = bmp = old = None
    failures = []
    primary = None
    result = None
    try:
        mem = gdi32.CreateCompatibleDC(hdc)
        if not mem:
            raise RuntimeError("CreateCompatibleDC failed")
        bmp = gdi32.CreateCompatibleBitmap(hdc, width, height)
        if not bmp:
            raise RuntimeError("CreateCompatibleBitmap failed")
        old = gdi32.SelectObject(mem, bmp)
        if not old:
            raise RuntimeError("SelectObject failed")
        if not user32.PrintWindow(hwnd, mem, PW_RENDERFULLCONTENT):
            result = None
            raise _CaptureNoImage(result)

        class BITMAPINFOHEADER(ctypes.Structure):
            _fields_ = [("biSize", wintypes.DWORD), ("biWidth", wintypes.LONG),
                        ("biHeight", wintypes.LONG), ("biPlanes", wintypes.WORD),
                        ("biBitCount", wintypes.WORD), ("biCompression", wintypes.DWORD),
                        ("biSizeImage", wintypes.DWORD), ("biXPelsPerMeter", wintypes.LONG),
                        ("biYPelsPerMeter", wintypes.LONG), ("biClrUsed", wintypes.DWORD),
                        ("biClrImportant", wintypes.DWORD)]

        info = BITMAPINFOHEADER()
        info.biSize = ctypes.sizeof(info)
        info.biWidth, info.biHeight = width, -height
        info.biPlanes, info.biBitCount = 1, 32
        buf = ctypes.create_string_buffer(width * height * 4)
        if not gdi32.GetDIBits(mem, bmp, 0, height, buf, ctypes.byref(info), 0):
            raise _CaptureNoImage()
        result = (width, height, buf.raw)
    except BaseException as exc:
        primary = exc
    finally:
        if mem and old:
            try:
                if not gdi32.SelectObject(mem, old):
                    failures.append(OSError("SelectObject(restore) failed"))
            except Exception as exc:
                failures.append(exc)
        if bmp:
            try:
                if not gdi32.DeleteObject(bmp):
                    failures.append(OSError("DeleteObject(bitmap) failed"))
            except Exception as exc:
                failures.append(exc)
        if mem:
            try:
                if not gdi32.DeleteDC(mem):
                    failures.append(OSError("DeleteDC failed"))
            except Exception as exc:
                failures.append(exc)
        try:
            if not user32.ReleaseDC(hwnd, hdc):
                failures.append(OSError("ReleaseDC failed"))
        except Exception as exc:
            failures.append(exc)
    if isinstance(primary, _CaptureNoImage):
        if failures:
            raise RuntimeError("capture produced no image; also release failed: "
                               + "; ".join(repr(f) for f in failures)) from primary
        return None
    if primary is not None:
        if failures:
            raise RuntimeError(f"{primary!r}; also release failed: "
                               + "; ".join(repr(f) for f in failures)) from primary
        raise primary
    if failures:
        raise RuntimeError("; ".join(repr(f) for f in failures))
    return result


def post(hwnd, msg, wparam=0):
    user32.PostMessageW(hwnd, msg, wparam, 0)


def capture_window_bounded(hwnd, timeout: float = 10.0, abort=None, pending=None):
    """PrintWindow on a worker thread: a hung UI thread must not hang the run.

    The worker is a daemon: if it outlives its bound it dies with the driver,
    and the tool it was capturing is terminated by cleanup either way.
    """
    import threading
    box = {}

    def work():
        try:
            box["shot"] = capture_window(hwnd)
        except Exception as exc:  # a capture failure is a step failure, not a crash
            box["error"] = exc

    worker = threading.Thread(target=work, daemon=True)
    box["thread"] = worker
    worker.start()
    deadline = time.monotonic() + timeout
    while worker.is_alive() and time.monotonic() < deadline:
        if abort is not None and abort():
            if pending is not None:
                pending.append(box)  # late diagnostics are collected, not lost
            return ABORTED
        worker.join(0.05)
    if worker.is_alive():
        if pending is not None:
            pending.append(box)
        return None
    if "error" in box:
        raise box["error"]
    return box.get("shot")


def collect_late_capture_diagnostics(runs, notes, join_timeout: float = 10.0, abort=None) -> bool:
    """Drain abandoned capture workers into the report before the verdict.

    A worker that finished with a failure names it; a worker still blocked
    is reported as unverified. Either way the run fails: silent loss of a
    release diagnostic is exactly what this prevents. The drain itself
    stands down when operator input resumes: it stops joining, reports the
    worker unverified, and returns True so the verdict can stand down while
    collected failures keep exit 1.
    """
    stood_down = False
    for run in runs:
        for box in getattr(run, "pending_captures", []):
            deadline = time.monotonic() + join_timeout
            while box["thread"].is_alive() and time.monotonic() < deadline:
                if abort is not None and abort():
                    stood_down = True
                    break
                box["thread"].join(timeout=0.05)
            if box["thread"].is_alive():
                notes.append(f"{run.name}: capture cleanup unverified (worker still blocked)")
                run.failed = True
            elif "error" in box:
                notes.append(f"{run.name}: late capture failure: {box['error']!r}")
                run.failed = True
            if abort is not None and abort():
                stood_down = True
    if stood_down:
        notes.append("Operator input resumed during capture drain; the run stood down.")
    return stood_down


def exit_result(returncode) -> tuple[str, str]:
    """Only a clean self-exit passes; a crash status fails by name."""
    if returncode == 0:
        return "pass", "process exited (0)"
    return "fail", f"process exited with crash status 0x{returncode & 0xFFFFFFFF:08x}"


def input_resumed(collecting: bool, idle_now: float) -> bool:
    """Collecting runs stand down the moment operator input resumes."""
    return bool(collecting and idle_now < 2.0)


COLLECT_MIN_IDLE = 120.0  # docs/testing.md: no input for 120 s at a collecting start


def collecting_gate(baseline_tick: int, idle_now: float) -> str | None:
    """Why a collecting run must refuse, or None when it may start."""
    if baseline_tick < 0:
        return "refused: the last-input query failed, so a collecting run cannot prove the operator is away"
    if idle_now < COLLECT_MIN_IDLE:
        return (f"refused: collecting runs need {COLLECT_MIN_IDLE:.0f}s without "
                "operator input at their start (docs/testing.md fence)")
    return None


class JobBox:
    """Kill-on-close job: launched tools die with the driver, even on a kill.

    Every API result is checked: containment that could not be established
    is a named failure, never a silent hope.
    """

    def __init__(self):
        self.handle = kernel32.CreateJobObjectW(None, None)
        self.error = None
        if not self.handle:
            self.error = f"CreateJobObject failed ({ctypes.get_last_error()})"
            return

        class LIMITS(ctypes.Structure):
            _fields_ = [("PerProcessUserTimeLimit", ctypes.c_int64),
                        ("PerJobUserTimeLimit", ctypes.c_int64),
                        ("LimitFlags", wintypes.DWORD),
                        ("MinimumWorkingSetSize", ctypes.c_size_t),
                        ("MaximumWorkingSetSize", ctypes.c_size_t),
                        ("ActiveProcessLimit", wintypes.DWORD),
                        ("Affinity", ctypes.c_size_t),
                        ("PriorityClass", wintypes.DWORD),
                        ("SchedulingClass", wintypes.DWORD)]

        class IO_COUNTERS(ctypes.Structure):
            _fields_ = [(name, ctypes.c_uint64) for name in (
                "ReadOperationCount", "WriteOperationCount", "OtherOperationCount",
                "ReadTransferCount", "WriteTransferCount", "OtherTransferCount")]

        class EXTENDED(ctypes.Structure):
            _fields_ = [("BasicLimitInformation", LIMITS),
                        ("IoInfo", IO_COUNTERS),
                        ("ProcessMemoryLimit", ctypes.c_size_t),
                        ("JobMemoryLimit", ctypes.c_size_t),
                        ("PeakProcessMemoryUsed", ctypes.c_size_t),
                        ("PeakJobMemoryUsed", ctypes.c_size_t)]

        info = EXTENDED()
        info.BasicLimitInformation.LimitFlags = 0x00002000  # JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
        if not kernel32.SetInformationJobObject(self.handle, 9, ctypes.byref(info), ctypes.sizeof(info)):
            self.error = f"SetInformationJobObject failed ({ctypes.get_last_error()})"

    def assign(self, proc) -> bool:
        if not self.handle or self.error:
            return False
        if not kernel32.AssignProcessToJobObject(self.handle, wintypes.HANDLE(int(proc._handle))):
            self.error = f"AssignProcessToJobObject failed ({ctypes.get_last_error()})"
            return False
        return True

    def close(self):
        if self.handle:
            if not kernel32.CloseHandle(self.handle):
                self.error = f"CloseHandle(job) failed ({ctypes.get_last_error()})"
            self.handle = None


def ensure_rows(run: "ToolRun", result: str, detail: str):
    """Every selected tool ends with exactly the five step rows."""
    have = {row[1] for row in run.rows}
    for step, _expected in step_table(run.name):
        if step not in have:
            run.record(step, result, detail)


def validate_tools(only, known):
    """Unknown selections fail by name; they never pass as an empty suite."""
    if not only:
        return []
    return sorted(name for name in only if name not in known)


# ---------------------------------------------------------------- driver

class ToolRun:
    def __init__(self, name, exe: Path, args=(), start_timeout=None):
        self.name = name
        self.exe = exe
        self.args = list(args)
        self.start_timeout = start_timeout or TIMEOUTS["launch"]
        self.proc = None
        self.pending_captures = []
        self.job = None
        self.hwnd = None
        self.rows = []
        self.failed = False

    def record(self, step, result, detail=""):
        self.rows.append((self.name, step, result, detail))
        if result == "fail":
            self.failed = True

    def cleanup(self):
        """Terminate only the process this run launched, then release it.

        The handle release is attempted even when termination raises; the
        cleanup wait also stops waiting (not cleaning up) when the operator
        returns, because closing the job reaps the child regardless.
        """
        if self.job is None:
            self.job = JobBox()
        primary = None
        try:
            if self.proc and self.proc.poll() is None:
                self.proc.terminate()
                deadline = time.monotonic() + 5
                while self.proc.poll() is None and time.monotonic() < deadline:
                    resumed = getattr(self, "resumed", None)
                    if resumed is not None and resumed():
                        self.stood_down_during_cleanup = True
                        break
                    time.sleep(0.05)
                # Any resumed observation in cleanup sets the flag, including
                # the one that suppresses the kill at the deadline.
                resumed = getattr(self, "resumed", None)
                if self.proc.poll() is None:
                    if resumed is not None and resumed():
                        self.stood_down_during_cleanup = True
                    else:
                        self.proc.kill()
        except BaseException as exc:
            primary = exc
        finally:
            if isinstance(self.proc, WinProc):
                try:
                    self.proc.close()
                except Exception as close_exc:
                    if primary is not None:
                        raise RuntimeError(f"{primary!r}; also release failed: {close_exc!r}") from primary
                    raise
            if primary is not None:
                raise primary


class WinProc:
    """A process created inside its job, with the Popen surface we use."""

    def __init__(self, handle, thread, pid):
        self._handle = handle
        self._thread = thread
        self.pid = pid
        self.returncode = None

    def poll(self):
        if self.returncode is not None:
            return self.returncode
        code = wintypes.DWORD()
        if kernel32.GetExitCodeProcess(wintypes.HANDLE(self._handle), ctypes.byref(code)):
            if code.value != 259:  # STILL_ACTIVE
                self.returncode = ctypes.c_long(code.value).value
                return self.returncode
        return None

    def wait(self, timeout=None):
        deadline = None if timeout is None else time.monotonic() + timeout
        while True:
            rc = self.poll()
            if rc is not None:
                return rc
            if deadline is not None and time.monotonic() >= deadline:
                raise subprocess.TimeoutExpired("tool", timeout)
            time.sleep(0.05)

    def terminate(self):
        if not kernel32.TerminateProcess(wintypes.HANDLE(self._handle), 1):
            raise OSError(f"TerminateProcess failed ({ctypes.get_last_error()})")

    def kill(self):
        self.terminate()

    def close(self):
        """Release the process handle; called once the process is reaped."""
        if getattr(self, "_closed", False):
            return
        self._closed = True
        if not kernel32.CloseHandle(wintypes.HANDLE(self._handle)):
            raise OSError(f"CloseHandle(process) failed ({ctypes.get_last_error()})")


def spawn_contained(run: "ToolRun"):
    """Create the child already inside the kill-on-close job, then resume it.

    The job rides the PROC_THREAD_ATTRIBUTE_JOB_LIST startup attribute, so
    containment is atomic with creation: there is no instant in which the
    child exists outside the job, and a driver killed at any point takes
    the child with it. The child starts suspended and is resumed only
    after creation succeeds.
    """
    if run.job.error:
        return  # configuration failed: fail closed, never create the process
    job = run.job.handle
    if not job:
        run.job.error = run.job.error or "no job handle"
        return

    class STARTUPINFO(ctypes.Structure):
        _fields_ = [("cb", wintypes.DWORD), ("lpReserved", wintypes.LPWSTR),
                    ("lpDesktop", wintypes.LPWSTR), ("lpTitle", wintypes.LPWSTR),
                    ("dwX", wintypes.DWORD), ("dwY", wintypes.DWORD),
                    ("dwXSize", wintypes.DWORD), ("dwYSize", wintypes.DWORD),
                    ("dwXCountChars", wintypes.DWORD), ("dwYCountChars", wintypes.DWORD),
                    ("dwFillAttribute", wintypes.DWORD), ("dwFlags", wintypes.DWORD),
                    ("wShowWindow", wintypes.WORD), ("cbReserved2", wintypes.WORD),
                    ("lpReserved2", ctypes.c_void_p), ("hStdInput", wintypes.HANDLE),
                    ("hStdOutput", wintypes.HANDLE), ("hStdError", wintypes.HANDLE)]

    class STARTUPINFOEX(ctypes.Structure):
        _fields_ = [("StartupInfo", STARTUPINFO), ("lpAttributeList", ctypes.c_void_p)]

    class PROCESS_INFORMATION(ctypes.Structure):
        _fields_ = [("hProcess", wintypes.HANDLE), ("hThread", wintypes.HANDLE),
                    ("dwProcessId", wintypes.DWORD), ("dwThreadId", wintypes.DWORD)]

    k = kernel32
    k.CreateProcessW.restype = wintypes.BOOL
    k.CreateProcessW.argtypes = [wintypes.LPCWSTR, wintypes.LPWSTR, ctypes.c_void_p,
                                 ctypes.c_void_p, wintypes.BOOL, wintypes.DWORD,
                                 ctypes.c_void_p, wintypes.LPCWSTR, ctypes.c_void_p,
                                 ctypes.c_void_p]
    k.GetExitCodeProcess.restype = wintypes.BOOL
    k.GetExitCodeProcess.argtypes = [wintypes.HANDLE, ctypes.POINTER(wintypes.DWORD)]
    k.TerminateProcess.restype = wintypes.BOOL
    k.TerminateProcess.argtypes = [wintypes.HANDLE, wintypes.UINT]
    k.InitializeProcThreadAttributeList.restype = wintypes.BOOL
    k.InitializeProcThreadAttributeList.argtypes = [ctypes.c_void_p, wintypes.DWORD,
                                                    wintypes.DWORD, ctypes.POINTER(ctypes.c_size_t)]
    k.UpdateProcThreadAttribute.restype = wintypes.BOOL
    k.UpdateProcThreadAttribute.argtypes = [ctypes.c_void_p, wintypes.DWORD, ctypes.c_size_t,
                                            ctypes.c_void_p, ctypes.c_size_t,
                                            ctypes.c_void_p, ctypes.c_void_p]
    k.ResumeThread.restype = wintypes.DWORD
    k.ResumeThread.argtypes = [wintypes.HANDLE]
    k.DeleteProcThreadAttributeList.restype = None
    k.DeleteProcThreadAttributeList.argtypes = [ctypes.c_void_p]

    cmdline = subprocess.list2cmdline([str(run.exe), *run.args])
    jobs = (wintypes.HANDLE * 1)(job)
    size = ctypes.c_size_t(0)
    k.InitializeProcThreadAttributeList(None, 1, 0, ctypes.byref(size))
    attr_buf = ctypes.create_string_buffer(size.value)
    six = STARTUPINFOEX()
    six.StartupInfo.cb = ctypes.sizeof(six)
    six.lpAttributeList = ctypes.cast(attr_buf, ctypes.c_void_p)
    proc_info = PROCESS_INFORMATION()
    created = False
    initialized = bool(k.InitializeProcThreadAttributeList(six.lpAttributeList, 1, 0, ctypes.byref(size)))
    if initialized:
        # 0x2000D = PROC_THREAD_ATTRIBUTE_JOB_LIST
        if k.UpdateProcThreadAttribute(six.lpAttributeList, 0, ctypes.c_size_t(0x2000D),
                                       ctypes.cast(jobs, ctypes.c_void_p), ctypes.sizeof(jobs), None, None):
            created = bool(k.CreateProcessW(
                str(run.exe), ctypes.create_unicode_buffer(cmdline), None, None, False,
                0x00000004 | 0x00080000,  # CREATE_SUSPENDED | EXTENDED_STARTUPINFO_PRESENT
                None, None, ctypes.byref(six), ctypes.byref(proc_info)))
    if initialized:
        k.DeleteProcThreadAttributeList(six.lpAttributeList)
    if not created:
        run.job.error = f"CreateProcess with job list failed ({ctypes.get_last_error()})"
        return
    run.proc = WinProc(int(proc_info.hProcess), int(proc_info.hThread), int(proc_info.dwProcessId))
    try:
        if k.ResumeThread(wintypes.HANDLE(int(proc_info.hThread))) == 0xFFFFFFFF:
            run.job.error = "ResumeThread failed"
            run.proc.terminate()
    finally:
        if not kernel32.CloseHandle(wintypes.HANDLE(int(proc_info.hThread))):
            note = f"CloseHandle(thread) failed ({ctypes.get_last_error()})"
            run.job.error = f"{run.job.error}; {note}" if run.job.error else note


def launch_block_text() -> str:
    return ("launching this tool requires elevation "
            "(run the smoke driver elevated; elevated pass owned by D07 T01 S5)")


def launch_block(exc: OSError) -> str | None:
    """A named refusal at launch, or None when the launch simply failed."""
    if getattr(exc, "winerror", None) == 740:  # ERROR_ELEVATION_REQUIRED
        return launch_block_text()
    return None


def drive_tool(run: ToolRun, out_dir: Path, prev_dir: Path, collecting: bool,
               input_mark: float, resumed=None) -> bool:
    """Drive one tool through the five steps. Returns stood_down."""
    run.resumed = resumed
    table = dict(step_table(run.name))
    run.job = JobBox()
    try:
        spawn_contained(run)
        if run.job.error:
            if "(740)" in run.job.error:  # elevation refusal at CreateProcess
                for step, expected in step_table(run.name):
                    run.record(step, "blocked" if expected else "absent",
                               launch_block_text() if expected else "surface not shipped")
            else:
                for step, expected in step_table(run.name):
                    run.record(step, "fail" if expected else "absent",
                               f"containment could not be established: {run.job.error}"
                               if expected else "surface not shipped")
            cleanup_safely(run)
            return False
    except OSError as exc:
        blocked = launch_block(exc)
        for step, expected in step_table(run.name):
            if blocked and expected:
                run.record(step, "blocked", blocked)
            elif blocked:
                run.record(step, "absent", "surface not shipped")
            else:
                detail = f"launch failed for {run.exe}: {exc}"
                if run.job is not None and run.job.error and run.job.error not in detail:
                    detail += f"; containment: {run.job.error}"
                run.record(step, "fail" if expected else "absent",
                           detail if expected else "surface not shipped")
        cleanup_safely(run)
        return False
    try:
        # start: observe the main window inside the launch bound.
        run.hwnd = wait_window(run.proc.pid, run.start_timeout, abort=resumed)
        if run.hwnd == ABORTED:
            run.record("start", "stood-down", "operator input resumed during launch wait")
            ensure_rows(run, "stood-down", "operator input resumed; tool dismissed")
            return True
        if run.hwnd is None:
            run.record("start", "fail",
                       f"no window within {run.start_timeout:.0f}s (capture: none, no window)")
            for step in ("main", "about", "preferences", "exit"):
                expected = table[step]
                run.record(step, "fail" if step == "exit" and False else ("absent" if not expected else "fail"),
                           "not reached: start failed" if expected else "surface not shipped")
            # The process showed nothing; exit cannot be observed either.
            run.rows[-1] = (run.name, "exit", "fail", "not reached: start failed; process cleaned up")
            return False
        run.record("start", "pass", f"window 0x{run.hwnd:x} pid {run.proc.pid}")

        def stood_down_here(next_steps) -> bool:
            if resumed is None or not resumed():
                return False
            post(run.hwnd, WM_CLOSE)
            for step in next_steps:
                run.record(step, "stood-down", "operator input resumed; tool dismissed")
            return True

        if stood_down_here(("main", "about", "preferences", "exit")):
            return True

        # main: capture the surface; a blank capture fails by name.
        try:
            shot = capture_window_bounded(run.hwnd, abort=resumed, pending=run.pending_captures)
        except Exception as exc:
            run.record("main", "fail", f"capture failed: {exc!r}")
            shot = "handled"
        if shot == "handled":
            pass  # the failure row is recorded; the remaining steps still run
        elif shot == ABORTED:
            post(run.hwnd, WM_CLOSE)
            run.record("main", "stood-down", "operator input resumed; tool dismissed")
            ensure_rows(run, "stood-down", "operator input resumed; tool dismissed")
            return True
        elif shot is None:
            run.record("main", "fail", "PrintWindow produced no capture")
        else:
            width, height, bgra = shot
            out_dir.mkdir(parents=True, exist_ok=True)
            prev_dir.mkdir(parents=True, exist_ok=True)
            prev_png = prev_dir / f"{run.name}-main.png"
            previous = None
            prev_raw = prev_dir / f"{run.name}-main.raw"
            if prev_raw.exists():
                previous = prev_raw.read_bytes()
            change = compare_captures(previous, bgra)
            (out_dir / f"{run.name}-main.png").write_bytes(png_encode(width, height, bgra))
            prev_raw.write_bytes(bgra)
            prev_png.write_bytes(png_encode(width, height, bgra))
            if is_blank(bgra):
                run.record("main", "fail",
                           f"blank capture {width}x{height} (variance {pixel_variance(bgra):.2f})")
            else:
                run.record("main", "pass",
                           f"capture build/smoke/{run.name}-main.png {width}x{height}, {change} vs previous")

        # about: expected only where the step table says the tool ships it.
        if not table["about"]:
            run.record("about", "absent", "no About surface shipped for this tool")
        else:
            post(run.hwnd, WM_COMMAND, ABOUT_IDM)
            dialog = wait_window(run.proc.pid, TIMEOUTS["dialog"], want_dialog=True, abort=resumed)
            if dialog == ABORTED:
                post(run.hwnd, WM_CLOSE)
                run.record("about", "stood-down", "operator input resumed; tool dismissed")
                ensure_rows(run, "stood-down", "operator input resumed; tool dismissed")
                return True
            if dialog is None:
                run.record("about", "fail",
                           "About dialog did not appear (command ignored or no dialog); "
                           + failure_capture(run, "about", out_dir, abort=resumed))
            else:
                post(dialog, WM_COMMAND, IDOK)
                deadline = time.monotonic() + TIMEOUTS["message"]
                gone = False
                while time.monotonic() < deadline:
                    if resumed is not None and resumed():
                        post(dialog, WM_COMMAND, IDOK)
                        post(run.hwnd, WM_CLOSE)
                        run.record("about", "stood-down", "operator input resumed; tool dismissed")
                        run.record("preferences", "stood-down", "operator input resumed; tool dismissed")
                        run.record("exit", "stood-down", "operator input resumed; tool dismissed")
                        return True
                    if not any(h == dialog for h, _, _ in pid_windows(run.proc.pid)):
                        gone = True
                        break
                    time.sleep(0.1)
                run.record("about", "pass" if gone else "fail",
                           "About dialog observed and dismissed" if gone
                           else "About dialog did not dismiss; " + failure_capture(run, "about", out_dir, abort=resumed))

        # preferences: absent until the framework shell ships (D01 T03 S2).
        if not table["preferences"]:
            run.record("preferences", "absent",
                       "preferences surface not shipped (framework shell D01 T03 S2)")

        # exit: WM_CLOSE, then observe the process terminated.  (evidence
        # for an unexpected exception is captured in the except below)
        post(run.hwnd, WM_CLOSE)
        deadline = time.monotonic() + TIMEOUTS["exit"]
        while True:
            if resumed is not None and resumed():
                run.record("exit", "stood-down", "operator input resumed; tool dismissed")
                return True
            try:
                run.proc.wait(timeout=0.1)
                break
            except subprocess.TimeoutExpired:
                if time.monotonic() >= deadline:
                    evidence = failure_capture(run, "exit", out_dir, abort=resumed)
                    if resumed is not None and resumed():
                        run.record("exit", "stood-down",
                                   "operator input resumed; tool dismissed (" + evidence + ")")
                        return True
                    run.record("exit", "fail",
                               f"process still running {TIMEOUTS['exit']:.0f}s after WM_CLOSE; "
                               + evidence + "; cleaned up")
                    return False
        result, detail = exit_result(run.proc.returncode)
        if result == "fail":
            detail += "; capture unavailable: the process has exited"
        run.record("exit", result, detail)
        return False
    except Exception:
        run._evidence = (failure_capture(run, "error", out_dir, abort=resumed)
                         if run.hwnd else "capture unavailable: no window")
        raise
    finally:
        cleanup_safely(run)


def note_cleanup_failure(run: "ToolRun", detail: str):
    """Cleanup failure rides the exit row: five step rows, never a pass."""
    run.failed = True
    for i, (tool, step, result, old) in enumerate(run.rows):
        if step == "exit":
            run.rows[i] = (tool, step, "fail", f"{old}; cleanup failed: {detail}")
            return
    run.rows.append((run.name, "exit", "fail", f"cleanup failed: {detail}"))


def cleanup_safely(run: "ToolRun"):
    """Cleanup failure is named on the exit row, never a silent pass; the
    job closes independently of whether process cleanup succeeds."""
    try:
        run.cleanup()
    except Exception as exc:
        note_cleanup_failure(run, repr(exc))
    try:
        if run.job is not None:
            before = run.job.error
            run.job.close()
            if run.job.error and run.job.error != before:
                note_cleanup_failure(run, run.job.error)
    except Exception as exc:
        note_cleanup_failure(run, repr(exc))


def failure_capture(run: ToolRun, step: str, out_dir: Path, abort=None) -> str:
    """Capture the surface at failure, or say why none exists."""
    if run.hwnd is None:
        return "capture unavailable: no window"
    if abort is not None and abort():
        run.interrupted = True
        return "capture unavailable: operator input resumed during capture"
    try:
        shot = capture_window_bounded(run.hwnd, abort=abort, pending=run.pending_captures)
    except Exception as exc:
        return f"capture unavailable: {exc!r}"
    if shot == ABORTED:
        run.interrupted = True
        return "capture unavailable: operator input resumed during capture"
    if shot is None:
        return "capture unavailable: PrintWindow produced nothing within its bound"
    width, height, bgra = shot
    try:
        out_dir.mkdir(parents=True, exist_ok=True)
        (out_dir / f"{run.name}-{step}.png").write_bytes(png_encode(width, height, bgra))
        return f"capture build/smoke/{run.name}-{step}.png"
    except OSError as exc:
        return f"capture unavailable: {exc}"


def drill_tools():
    """Fixture inventory entries for --drill; real tools still run."""
    fixture = ROOT / "scripts" / "smoke_fixture.py"
    return [
        ToolRun("SmokeDrillBroken", Path(sys.executable), [str(fixture), "nowindow"], start_timeout=3.0),
        ToolRun("SmokeDrillHung", Path(sys.executable), [str(fixture), "hung"], start_timeout=15.0),
        ToolRun("SmokeDrillDeaf", Path(sys.executable), [str(fixture), "deaf"], start_timeout=15.0),
    ]


def real_tools(only=None, flavor="Release"):
    runs = []
    for name, spec in load_tools().items():
        if only and name not in only:
            continue
        exe = spec["exe"]
        if flavor != "Release":
            exe = exe.replace("Bin/Release", f"Bin/{flavor}", 1)
        runs.append(ToolRun(name, ROOT / exe))
    return runs



def emit_report(rows, verdict, notes) -> bool:
    """Write build/smoke/smoke-report.md; on failure print it instead."""
    report = render_report(rows, verdict, notes)
    try:
        SMOKE_DIR.mkdir(parents=True, exist_ok=True)
        (SMOKE_DIR / "smoke-report.md").write_text(report, encoding="utf-8")
        return True
    except OSError as exc:
        print(f"smoke: could not write build/smoke/smoke-report.md: {exc}")
        print(report)
        return False


def elevation_rows(only, result, detail):
    """One row per step per selected tool for an elevation outcome."""
    names = sorted(only) if only else sorted(load_tools())
    rows = []
    for name in names:
        for step, expected in step_table(name):
            rows.append((name, step, result if expected else "absent", detail))
    return rows


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter,
                                 epilog="Elevated RegStudio pass:\n"
                                        "  python scripts/smoke-run.py --elevate --visible --tools RegStudio")
    ap.add_argument("--visible", action="store_true", help="operator asked: run visibly now")
    ap.add_argument("--drill", action="store_true", help="add the broken-tool fixture entries")
    ap.add_argument("--tools", default="", help="comma-separated subset of registered tools")
    ap.add_argument("--flavor", default="Release", choices=("Release", "Debug"),
                    help="build flavor whose Bin/<flavor> executables to drive (nightly builds Debug)")
    ap.add_argument("--self-test", action="store_true", help="windowless logic tests")
    ap.add_argument("--elevate", action="store_true",
                    help="relaunch elevated through the runas consent prompt when not elevated")
    ap.add_argument("--elevated-child", action="store_true", help=argparse.SUPPRESS)
    args = ap.parse_args(argv)
    if args.self_test:
        return self_test()

    only = {t.strip() for t in args.tools.split(",") if t.strip()} or None
    unknown = validate_tools(only, load_tools())
    if unknown:
        print(f"smoke: unknown tool selection(s): {', '.join(unknown)} "
              f"(registered: {', '.join(sorted(load_tools()))}); nothing launched")
        return 2

    if args.elevated_child or args.elevate:
        elevated = is_elevated()
        call_argv = list(argv) if argv is not None else sys.argv[1:]
        if elevated is None:
            detail = "elevation could not be verified (token query failed); nothing launched"
            emit_report(elevation_rows(only, "refused", detail), "refused",
                        [f"Admission: {detail}.", "No tool was launched."])
            print(f"smoke: {detail}; report at build/smoke/smoke-report.md")
            return 2
        if args.elevated_child and not elevated:
            detail = ("elevated child launched without elevation; "
                      "refusing to relaunch, nothing launched")
            emit_report(elevation_rows(only, "refused", detail), "refused",
                        [f"Admission: {detail}.", "No tool was launched."])
            print(f"smoke: {detail}; report at build/smoke/smoke-report.md")
            return 2
        if args.elevate and not elevated:
            try:
                return relaunch_elevated(call_argv)
            except ElevationDeclined as exc:
                detail = f"blocked: {exc}; the selected tool steps were not observed"
                emit_report(elevation_rows(only, "blocked", detail), "blocked",
                            [f"Admission: {detail}.", "No tool was launched."])
                print(f"smoke: {detail}; report at build/smoke/smoke-report.md")
                return 2
            except ElevationFailed as exc:
                if exc.launched is None:
                    detail = (f"blocked: elevated launch could not be verified: {exc}; "
                              "whether a tool launched is unknown")
                    notes = [f"Admission: {detail}.",
                             "No process handle was returned, so launch and termination "
                             "are unverified."]
                elif exc.launched:
                    detail = (f"blocked: elevated child was launched, then failed: {exc}; "
                              "steps in this run were not reliably observed")
                    notes = [f"Admission: {detail}.",
                             "The elevated child was launched. Captures it produced "
                             "under build/smoke/ are retained."]
                else:
                    detail = f"blocked: elevated relaunch failed: {exc}"
                    notes = [f"Admission: {detail}.", "No tool was launched."]
                emit_report(elevation_rows(only, "blocked", detail), "blocked", notes)
                print(f"smoke: {detail}; report at build/smoke/smoke-report.md")
                return 2

    admitted, mode, collecting = admission(args.visible, datetime.now(), os.environ)
    baseline_tick = last_input_tick()
    if admitted and collecting:
        gate = collecting_gate(baseline_tick, idle_seconds())
        if gate:
            admitted, mode = False, gate
    notes = [f"Admission: {mode}."]
    if not admitted:
        refused_rows = [(name, step, "refused", mode)
                        for name in (only or sorted(load_tools()))
                        for step, _ in step_table(name)]
        try:
            SMOKE_DIR.mkdir(parents=True, exist_ok=True)
            (SMOKE_DIR / "smoke-report.md").write_text(
                render_report(refused_rows, "refused", notes + ["No tool was launched."]), encoding="utf-8")
        except OSError as exc:
            print(f"smoke: could not write the refusal report: {exc}")
            print(render_report(refused_rows, "refused", notes + ["No tool was launched."]))
        print(f"smoke: {mode}; report at build/smoke/smoke-report.md")
        return 2

    runs = real_tools(only, args.flavor)
    if args.drill:
        runs += drill_tools()
    rows = []
    stood_down = False
    base_idle = idle_seconds()

    def resumed() -> bool:
        return collecting and tick_resumed(baseline_tick, last_input_tick())

    for run in runs:
        if stood_down or resumed():
            stood_down = True
            ensure_rows(run, "stood-down", "operator input resumed; not launched")
            rows += run.rows
            continue
        try:
            if drive_tool(run, SMOKE_DIR, PREV_DIR, collecting, base_idle, resumed=resumed):
                stood_down = True
            if getattr(run, "stood_down_during_cleanup", False):
                stood_down = True
            if getattr(run, "interrupted", False):
                stood_down = True
                notes.append(f"Operator input resumed during {run.name}; the run stood down.")
            ensure_rows(run, "stood-down" if stood_down else "fail",
                        "operator input resumed; tool dismissed" if stood_down else "not reached")
        except Exception as exc:  # one tool's crash never stops the run or loses the report
            evidence = getattr(run, "_evidence", "capture unavailable: no window")
            ensure_rows(run, "fail", f"driver error: {exc!r}; {evidence}")
            cleanup_safely(run)
            if getattr(run, "stood_down_during_cleanup", False):
                stood_down = True
                notes.append(f"Operator input resumed during {run.name} cleanup; "
                             "the run stood down after recording its failure.")
            if getattr(run, "interrupted", False):
                stood_down = True
                notes.append(f"Operator input resumed during {run.name}; the run stood down.")
        rows += run.rows
    if collect_late_capture_diagnostics(runs, notes, abort=resumed):
        stood_down = True
    if resumed():
        stood_down = True
    failed = any(r[2] == "fail" for r in rows) or any(r.failed for r in runs)
    blocked = any(r[2] == "blocked" for r in rows)
    verdict = "stood-down" if stood_down else ("fail" if failed else ("blocked" if blocked else "pass"))
    notes.append(f"Tools: {', '.join(r.name for r in runs)}.")
    report = render_report(rows, verdict, notes)
    try:
        SMOKE_DIR.mkdir(parents=True, exist_ok=True)
        (SMOKE_DIR / "smoke-report.md").write_text(report, encoding="utf-8")
    except OSError as exc:
        print(f"smoke: could not write build/smoke/smoke-report.md: {exc}")
        print(report)
        return 1
    print(report)
    if failed:
        return 1
    if stood_down or blocked:
        return 2
    return 0


# ---------------------------------------------------------------- tests

def self_test() -> int:
    failures = []

    def check(name, cond):
        print(f"{'PASS' if cond else 'FAIL'} {name}")
        if not cond:
            failures.append(name)

    # Inventory comes from the conformance registry, unlisted here.
    tools = load_tools()
    check("inventory enumerates the conformance tools", set(tools) == {"Resolute", "RegStudio"})
    check("Resolute step table", step_table("Resolute") == [
        ("start", True), ("main", True), ("about", False), ("preferences", False), ("exit", True)])
    check("RegStudio expects About", dict(step_table("RegStudio"))["about"] is True)
    check("unknown tool defaults absent", dict(step_table("Nope"))["about"] is False)

    # Pixel logic, no window needed.
    uniform = bytes([10, 20, 30, 255]) * 64
    varied = bytes(range(256)) * 4
    check("uniform capture is blank", is_blank(uniform))
    check("varied capture is not blank", not is_blank(varied))
    check("identical captures unchanged", compare_captures(varied, varied) == "unchanged")
    other = bytearray(varied)
    other[0] ^= 0xFF
    check("one changed pixel is changed", compare_captures(varied, bytes(other)) == "changed")
    check("no previous capture is first-run", compare_captures(None, varied) == "first-run")

    # PNG encoder produces a readable header and stable bytes.
    png = png_encode(2, 2, bytes([0, 0, 255, 255]) * 4)
    check("png signature", png[:8] == b"\x89PNG\r\n\x1a\n" and len(png) > 40)

    # Fence admission: all three admissions and the refusal.
    day = datetime(2026, 11, 9, 12, 0)
    night = datetime(2026, 11, 9, 3, 0)
    check("visible admits", admission(True, day, {})[0] is True)
    check("idle-collect admits", admission(False, day, {"RESOLUTE_IDLE_COLLECT": "1"})[0] is True)
    check("night admits collecting", admission(False, night, {}) == (True, "collecting (night window 02:00-06:50)", True))
    check("plain daytime refused", admission(False, day, {})[0] is False)

    # Flavor maps the registry's release paths onto the built flavor.
    debug_exes = {r.name: str(r.exe) for r in real_tools(flavor="Debug")}
    check("debug flavor drives Bin/Debug", debug_exes["Resolute"].endswith("Bin\\Debug\\Resolute.exe")
          and debug_exes["RegStudio"].endswith("Bin\\Debug\\System\\RegStudio.exe"))
    check("release flavor drives Bin/Release",
          str(real_tools()[0].exe).endswith("Bin\\Release\\Resolute.exe"))

    # Elevation refusal is a named block, not a failure.
    exc = OSError("requires elevation")
    exc.winerror = 740
    check("740 launch refusal is blocked", launch_block(exc) is not None and "elevation" in launch_block(exc))
    check("other launch errors are not blocked", launch_block(OSError("missing exe")) is None)

    check("crash status fails exit", exit_result(-1073741819)[0] == "fail"
          and "0xc0000005" in exit_result(-1073741819)[1])
    check("clean exit passes", exit_result(0) == ("pass", "process exited (0)"))
    check("input resumes only when collecting", input_resumed(True, 0.5) and not input_resumed(False, 0.5)
          and not input_resumed(True, 30.0))

    check("last-input tick advance means resumed", tick_resumed(100, 101) and not tick_resumed(100, 100)
          and not tick_resumed(-1, 500))
    check("unknown selections named", validate_tools({"Typo", "Resolute"}, load_tools()) == ["Typo"]
          and validate_tools({"Resolute"}, load_tools()) == [] and validate_tools(None, load_tools()) == [])
    probe = ToolRun("Resolute", Path("x"))
    ensure_rows(probe, "stood-down", "test")
    check("ensure_rows completes five rows", [r[1] for r in probe.rows] == list(STEPS)
          and all(r[2] == "stood-down" for r in probe.rows))
    check("ensure_rows keeps recorded rows", (ensure_rows(probe, "fail", "y") or len(probe.rows)) == 5)

    # Failure injection: containment refusal never resumes the child.
    class _FakeProc:
        _handle = 0
        def __init__(self): self.terminated = False
        def terminate(self): self.terminated = True
    _probe = ToolRun("Resolute", Path("x"))
    _probe.job = JobBox()
    _real_assign = JobBox.assign
    JobBox.assign = lambda self, proc: False
    try:
        _fake = _FakeProc()
        _contained_ok = _probe.job.assign(_fake)
    finally:
        JobBox.assign = _real_assign
    check("containment refusal is named", _contained_ok is False)
    check("interrupted wait reports abort", wait_window(0, 5.0, abort=lambda: True) == ABORTED)
    _cprobe = ToolRun("Resolute", Path("x"))
    class _BadProc:
        def poll(self): return None
        def terminate(self): raise RuntimeError("boom")
        def wait(self, timeout=None): return None
        def kill(self): pass
    _cprobe.proc = _BadProc()
    _cprobe.job = JobBox()
    try:
        _cprobe.cleanup()
        _cleanup_recorded = True
    except RuntimeError:
        _cleanup_recorded = False
    _sprobe = ToolRun("Resolute", Path("x"))
    _sprobe.proc = _BadProc()
    _sprobe.job = JobBox()
    cleanup_safely(_sprobe)
    check("cleanup failure surfaces on the exit row, never silently",
          _sprobe.failed and any(r[1] == "exit" and r[2] == "fail" for r in _sprobe.rows))
    check("tick rollover still detects input", tick_resumed(0xFFFFFFF0, 20)
          and not tick_resumed(20, 0xFFFFFFF0))
    check("failed input query stands collecting down", tick_resumed(100, -1))

    # Production launch path: a job that failed configuration creates no
    # process at all, and a good job spawns, contains, and cleans up.
    fixture = ROOT / "scripts" / "smoke_fixture.py"
    broken = ToolRun("SmokeDrillBroken", Path(sys.executable), [str(fixture), "nowindow"])
    broken.job = JobBox()
    broken.job.error = "injected configuration failure"
    spawn_contained(broken)
    check("failed job configuration creates no process", broken.proc is None)
    live = ToolRun("SmokeDrillBroken", Path(sys.executable), [str(fixture), "nowindow"])
    live.job = JobBox()
    spawn_contained(live)
    spawned = live.proc is not None and live.proc.poll() is None
    if live.proc is not None:
        live.cleanup()
    check("contained spawn runs and cleans up", spawned and live.proc.poll() is not None)
    check("collecting gate refuses a failed baseline query",
          collecting_gate(-1, 9999.0) is not None and collecting_gate(100, 9999.0) is None
          and collecting_gate(100, 3.0) is not None)
    # Kill-on-close proof on the production path: closing the job, with no
    # terminate call, reaps the contained child.
    live2 = ToolRun("SmokeDrillBroken", Path(sys.executable), [str(fixture), "nowindow"])
    live2.job = JobBox()
    spawn_contained(live2)
    running = live2.proc is not None and live2.proc.poll() is None
    if live2.proc is not None:
        live2.job.close()
        try:
            live2.proc.wait(timeout=5)
            reaped = live2.proc.poll() is not None
        except Exception:
            reaped = False
        live2.cleanup()
    else:
        reaped = False
    check("closing the job reaps the contained child", running and reaped)
    check("process handle released by cleanup", isinstance(live2.proc, WinProc) and live2.proc._closed)
    nightly_text = (ROOT / "tools" / "nightly.ps1").read_text(encoding="utf-8", errors="replace")
    check("nightly parses verdicts with hyphens and names the report path",
          "[\\w-]+" in nightly_text and nightly_text.count("$smokeReportPath") >= 4)
    check("nightly verdict words all parse", all(
        __import__("re").match(r"Suite verdict: \*\*([\w-]+)\*\*",
                               f"Suite verdict: **{v}**").group(1) == v
        for v in ("pass", "fail", "blocked", "refused", "stood-down")))

    # main() itself, deterministically: stub admission, the input query and
    # the tool list, so no real tool can launch in any of these cases.
    import io, tempfile
    from contextlib import redirect_stdout
    _saved = {k: globals()[k] for k in ("SMOKE_DIR", "PREV_DIR", "last_input_tick", "admission", "real_tools")}
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["SMOKE_DIR"] = Path(td) / "smoke"
            globals()["PREV_DIR"] = Path(td) / "smoke" / "prev"
            globals()["real_tools"] = lambda only=None, flavor="Release": []
            globals()["last_input_tick"] = lambda: -1
            globals()["admission"] = lambda v, n, e: (True, "collecting (test)", True)
            os.environ["RESOLUTE_IDLE_COLLECT"] = "1"
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            check("main refuses a collecting run whose baseline query failed",
                  rc == 2 and "refused" in buf.getvalue())
            # Refusal with an unwritable report directory: five rows on stdout.
            globals()["last_input_tick"] = lambda: 100
            globals()["admission"] = lambda v, n, e: (False, "refused: test fence", False)
            blocker = Path(td) / "blocker"
            blocker.write_text("x")
            globals()["SMOKE_DIR"] = blocker / "smoke"
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            check("unwritable refusal report falls back to stdout with rows",
                  rc == 2 and "Suite verdict" in buf.getvalue() and "| Resolute |" in buf.getvalue())
            # Admitted run whose report cannot be written: report on stdout.
            globals()["admission"] = lambda v, n, e: (True, "visible (test)", False)
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            check("unwritable run report falls back to stdout",
                  rc == 1 and "Suite verdict" in buf.getvalue())
    finally:
        globals().update(_saved)
        os.environ.pop("RESOLUTE_IDLE_COLLECT", None)
    # Nightly's own verdict line, extracted from tools/nightly.ps1 and run
    # by PowerShell against a fabricated report for every verdict.
    nightly_src = (ROOT / "tools" / "nightly.ps1").read_text(encoding="utf-8", errors="replace")
    ps_line = next((l.strip() for l in nightly_src.splitlines() if "Select-String -Path $smokeReportPath" in l), "")
    import tempfile as _tf
    verdicts_ok = bool(ps_line)
    if verdicts_ok:
        for verdict in ("pass", "fail", "blocked", "refused", "stood-down"):
            with _tf.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as fh:
                fh.write(f"Suite verdict: **{verdict}**\n")
                report_file = fh.name
            snippet = (f"$smokeReportPath = '{report_file}'; " + ps_line +
                       "; if ($m) { $m.Matches[0].Groups[1].Value }")
            ps = subprocess.run(["pwsh", "-NoProfile", "-Command", snippet],
                                capture_output=True, text=True, timeout=60)
            verdicts_ok = verdicts_ok and ps.returncode == 0 and ps.stdout.strip() == verdict
            Path(report_file).unlink(missing_ok=True)
    check("nightly's production verdict line parses every verdict", verdicts_ok)

    # Exceptional release: termination and process-handle release are both
    # attempted, and both failures survive in one named error.
    _calls = []
    _real_term, _real_close = kernel32.TerminateProcess, kernel32.CloseHandle
    try:
        kernel32.TerminateProcess = lambda h, code: (_calls.append("terminate"), 0)[1]
        kernel32.CloseHandle = lambda h: (_calls.append(f"close-{h}"), 0)[1]
        _wp = WinProc(111, 222, 333)
        _wrun = ToolRun("Resolute", Path("x"))
        _wrun.proc = _wp
        _wrun.job = JobBox()
        try:
            _wrun.cleanup()
            _both = False
        except RuntimeError as exc:
            _both = "also release failed" in str(exc)
        check("termination failure preserves the release failure too",
              _both and any(str(c).startswith("close-") for c in _calls))
    finally:
        kernel32.TerminateProcess, kernel32.CloseHandle = _real_term, _real_close
    # main() fallback with a real (stub-driven) tool: five rows on stdout.
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["SMOKE_DIR"] = Path(td) / "blocker" / "smoke"
            (Path(td) / "blocker").write_text("x")
            globals()["PREV_DIR"] = Path(td) / "smoke" / "prev"
            globals()["admission"] = lambda v, n, e: (True, "visible (test)", False)
            globals()["real_tools"] = lambda only=None, flavor="Release": [ToolRun("Resolute", Path("x"))]
            def _fake_drive(run, out_dir, prev_dir, collecting, mark, resumed=None):
                for step, _e in step_table(run.name):
                    run.record(step, "pass", "stub")
                return False
            _real_drive = globals()["drive_tool"]
            globals()["drive_tool"] = _fake_drive
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            globals()["drive_tool"] = _real_drive
            out = buf.getvalue()
            check("admitted report-write failure prints five rows on stdout",
                  rc == 1 and out.count("| Resolute |") == 5 and "Suite verdict" in out)
    finally:
        globals().update(_saved)
        os.environ.pop("RESOLUTE_IDLE_COLLECT", None)
    # Nightly's production reporting block, executed for every exit class.
    block_lines = []
    in_block = False
    for line in nightly_src.splitlines():
        if "$smokeReportPath = " in line:
            in_block = True
        if in_block:
            block_lines.append(line)
        if in_block and "smoke run failed at $head" in line:
            break
    block = "\n".join(block_lines)
    nightly_ok = bool(block_lines)
    if nightly_ok:
        for exit_code, verdict in ((0, "pass"), (2, "blocked"), (2, "refused"), (2, "stood-down"), (1, "fail"), (-1, "fail")):
            with tempfile.TemporaryDirectory() as td:
                wt = Path(td) / "wt"
                (wt / "build" / "smoke").mkdir(parents=True)
                (wt / "build" / "smoke" / "smoke-report.md").write_text(f"Suite verdict: **{verdict}**\n")
                snippet = (
                    "function Note([string]$l) { $script:notes += $l }; $script:notes = @(); "
                    "$failures = [System.Collections.Generic.List[string]]::new(); "
                    f"$wt = '{wt}'; $smokeExit = {exit_code}; $head = 'abc123'; " + block +
                    "; $script:notes -join '|'; 'FAILURES=' + $failures.Count")
                ps = subprocess.run(["pwsh", "-NoProfile", "-Command", snippet],
                                    capture_output=True, text=True, timeout=60)
                want_fail = "FAILURES=1" if exit_code in (1, -1) else "FAILURES=0"
                nightly_ok = nightly_ok and ps.returncode == 0 and verdict in ps.stdout and want_fail in ps.stdout and str(wt) in ps.stdout.replace("/", "\\")
    check("nightly reporting block names verdict, path, and failures per exit class", nightly_ok)

    # Capture release failures aggregate even when there is no image.
    _u, _g = user32, gdi32
    class _FakeUser:
        def __getattr__(self, name): return getattr(_u, name)
    try:
        def _rect(hwnd, rect_ptr):
            rect = ctypes.cast(rect_ptr, ctypes.POINTER(wintypes.RECT)).contents
            rect.left, rect.top, rect.right, rect.bottom = 0, 0, 8, 8
            return True
        _saved_apis = (user32.GetWindowRect, user32.GetWindowDC, user32.PrintWindow,
                       user32.ReleaseDC, gdi32.CreateCompatibleDC, gdi32.CreateCompatibleBitmap,
                       gdi32.SelectObject, gdi32.DeleteObject, gdi32.DeleteDC)
        user32.GetWindowRect = _rect
        user32.GetWindowDC = lambda h: 11
        user32.PrintWindow = lambda h, dc, f: 0
        user32.ReleaseDC = lambda h, dc: 0
        gdi32.CreateCompatibleDC = lambda dc: 22
        gdi32.CreateCompatibleBitmap = lambda dc, w, h: 33
        gdi32.SelectObject = lambda dc, obj: 44
        gdi32.DeleteObject = lambda obj: 0
        gdi32.DeleteDC = lambda dc: 0
        try:
            capture_window(99)
            _agg = False
        except RuntimeError as exc:
            _agg = "release failed" in str(exc)
        check("no-image capture still aggregates release failures", _agg)
    finally:
        (user32.GetWindowRect, user32.GetWindowDC, user32.PrintWindow, user32.ReleaseDC,
         gdi32.CreateCompatibleDC, gdi32.CreateCompatibleBitmap, gdi32.SelectObject,
         gdi32.DeleteObject, gdi32.DeleteDC) = _saved_apis
    # Cleanup-time interruption sets the stand-down flag on the production path.
    _iproc = ToolRun("Resolute", Path("x"))
    class _SlowProc:
        def __init__(self): self.calls = 0
        def poll(self):
            self.calls += 1
            return None if self.calls < 3 else 0
        def terminate(self): pass
        def kill(self): pass
    _iproc.proc = _SlowProc()
    _iproc.job = JobBox()
    _iproc.resumed = lambda: True
    _iproc.cleanup()
    check("cleanup interruption sets the stand-down flag",
          getattr(_iproc, "stood_down_during_cleanup", False) is True)
    # Resume failure is named and the suspended child is terminated.
    _rproc = ToolRun("SmokeDrillBroken", Path(sys.executable),
                     [str(ROOT / "scripts" / "smoke_fixture.py"), "nowindow"])
    _rproc.job = JobBox()
    _real_resume = kernel32.ResumeThread
    kernel32.ResumeThread = lambda h: 0xFFFFFFFF
    try:
        spawn_contained(_rproc)
    finally:
        kernel32.ResumeThread = _real_resume
    check("resume failure names itself and terminates the child",
          _rproc.job.error == "ResumeThread failed" and _rproc.proc.poll() is not None)
    _rproc.cleanup()
    # Report-write failure after the directory exists: report still on stdout.
    try:
        with tempfile.TemporaryDirectory() as td:
            _dir = Path(td) / "smoke"
            (_dir / "smoke-report.md").mkdir(parents=True)
            globals()["SMOKE_DIR"] = _dir
            globals()["PREV_DIR"] = _dir / "prev"
            globals()["admission"] = lambda v, n, e: (True, "visible (test)", False)
            globals()["real_tools"] = lambda only=None, flavor="Release": [ToolRun("Resolute", Path("x"))]
            def _fake_drive2(run, out_dir, prev_dir, collecting, mark, resumed=None):
                for step, _e in step_table(run.name):
                    run.record(step, "pass", "stub")
                return False
            _rd = globals()["drive_tool"]
            globals()["drive_tool"] = _fake_drive2
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            globals()["drive_tool"] = _rd
            check("report-write failure after mkdir falls back to stdout",
                  rc == 1 and "could not write" in buf.getvalue() and "Suite verdict" in buf.getvalue())
    finally:
        globals().update(_saved)
        os.environ.pop("RESOLUTE_IDLE_COLLECT", None)

    user32.GetWindowRect = _rect
    user32.GetWindowDC = lambda h: 11
    user32.PrintWindow = lambda h, dc, f: 0
    user32.ReleaseDC = lambda h, dc: 0
    gdi32.CreateCompatibleDC = lambda dc: 22
    gdi32.CreateCompatibleBitmap = lambda dc, w, h: 33
    gdi32.SelectObject = lambda dc, obj: 44
    gdi32.DeleteObject = lambda obj: 0
    gdi32.DeleteDC = lambda dc: 0
    try:
        capture_window(99)
        _agg_all = False
    except RuntimeError as exc:
        _msg = str(exc)
        _agg_all = all(name in _msg for name in ("DeleteObject", "DeleteDC", "ReleaseDC"))
    finally:
        (user32.GetWindowRect, user32.GetWindowDC, user32.PrintWindow, user32.ReleaseDC,
         gdi32.CreateCompatibleDC, gdi32.CreateCompatibleBitmap, gdi32.SelectObject,
         gdi32.DeleteObject, gdi32.DeleteDC) = _saved_apis
    check("every capture release failure is named in the aggregate", _agg_all)
    # Final-tool stand-down reaches the verdict on normal and exception paths.
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["SMOKE_DIR"] = Path(td) / "smoke"
            globals()["PREV_DIR"] = Path(td) / "smoke" / "prev"
            globals()["admission"] = lambda v, n, e: (True, "visible (test)", False)
            globals()["real_tools"] = lambda only=None, flavor="Release": [ToolRun("Resolute", Path("x"))]
            def _drive_sd(run, out_dir, prev_dir, collecting, mark, resumed=None):
                for step, _e in step_table(run.name):
                    run.record(step, "pass", "stub")
                run.stood_down_during_cleanup = True
                return False
            _rd2 = globals()["drive_tool"]
            globals()["drive_tool"] = _drive_sd
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            check("final-tool cleanup stand-down reaches the verdict",
                  rc == 2 and "stood-down" in buf.getvalue())
            def _drive_exc(run, out_dir, prev_dir, collecting, mark, resumed=None):
                run.record("start", "pass", "stub")
                run.interrupted = True
                raise RuntimeError("stub drive failure")
            globals()["drive_tool"] = _drive_exc
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            globals()["drive_tool"] = _rd2
            out = buf.getvalue()
            check("final-tool exception keeps failure exit and names stand-down",
                  rc == 1 and "stood down" in out and out.count("| Resolute |") == 5)
    finally:
        globals().update(_saved)
        os.environ.pop("RESOLUTE_IDLE_COLLECT", None)

    # Production capture interruption: failure_capture itself sets the flag,
    # and a final-tool main() run turns it into the stood-down verdict.
    _crun = ToolRun("Resolute", Path("x"))
    _crun.hwnd = 99
    _ctext = failure_capture(_crun, "about", SMOKE_DIR, abort=lambda: True)
    check("failure_capture interruption sets the flag and names itself",
          getattr(_crun, "interrupted", False) is True and "operator input resumed" in _ctext)
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["SMOKE_DIR"] = Path(td) / "smoke"
            globals()["PREV_DIR"] = Path(td) / "smoke" / "prev"
            globals()["admission"] = lambda v, n, e: (True, "visible (test)", False)
            globals()["real_tools"] = lambda only=None, flavor="Release": [ToolRun("Resolute", Path("x"))]
            def _drive_cap(run, out_dir, prev_dir, collecting, mark, resumed=None):
                run.hwnd = 99
                failure_capture(run, "about", out_dir, abort=lambda: True)
                for step, _e in step_table(run.name):
                    run.record(step, "pass", "stub")
                return False
            _rd3 = globals()["drive_tool"]
            globals()["drive_tool"] = _drive_cap
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            check("capture interruption on the final tool yields stood-down",
                  rc == 2 and "Suite verdict: **stood-down**" in buf.getvalue())
            def _drive_clean_sd(run, out_dir, prev_dir, collecting, mark, resumed=None):
                run.proc = _SlowProc()
                run.job = JobBox()
                run.resumed = lambda: True
                cleanup_safely(run)
                for step, _e in step_table(run.name):
                    run.record(step, "pass", "stub")
                return False
            globals()["drive_tool"] = _drive_clean_sd
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            globals()["drive_tool"] = _rd3
            check("cleanup stand-down on the final tool yields stood-down",
                  rc == 2 and "Suite verdict: **stood-down**" in buf.getvalue())
    finally:
        globals().update(_saved)
        os.environ.pop("RESOLUTE_IDLE_COLLECT", None)
    # Combined launch diagnostics through the production drive path.
    _lrun = ToolRun("Resolute", Path("x"))
    _real_spawn = globals()["spawn_contained"]
    def _bad_spawn(run):
        run.job.error = "ResumeThread failed; CloseHandle(thread) failed (5)"
        raise OSError("TerminateProcess failed (5)")
    globals()["spawn_contained"] = _bad_spawn
    try:
        drive_tool(_lrun, SMOKE_DIR, PREV_DIR, False, 0.0)
    finally:
        globals()["spawn_contained"] = _real_spawn
    _start_row = next((r for r in _lrun.rows if r[1] == "start"), None)
    check("combined launch diagnostics survive into the start row",
          _start_row is not None and _start_row[2] == "fail"
          and "TerminateProcess failed" in _start_row[3] and "ResumeThread failed" in _start_row[3])

    # The ABORTED branch itself: interruption arriving after capture begins.
    _calls = {"n": 0}
    def _late_abort():
        _calls["n"] += 1
        return _calls["n"] > 1
    _arun = ToolRun("Resolute", Path("x"))
    _arun.hwnd = 99
    _real_cap2 = globals()["capture_window"]
    import threading as _th
    _release = _th.Event()
    globals()["capture_window"] = lambda hwnd: (_release.wait(30), None)[1]
    try:
        _atext = failure_capture(_arun, "about", SMOKE_DIR, abort=_late_abort)
    finally:
        _release.set()
        globals()["capture_window"] = _real_cap2
    check("interruption inside the capture wait sets the flag",
          getattr(_arun, "interrupted", False) is True and "operator input resumed" in _atext)
    # Cleanup deadline branch: the child never exits, input arrives at expiry.
    _drun = ToolRun("Resolute", Path("x"))
    class _NeverProc:
        def poll(self): return None
        def terminate(self): pass
        def kill(self): raise AssertionError("kill must be suppressed by resumed input")
    _drun.proc = _NeverProc()
    _drun.job = JobBox()
    _clock = {"t": 1000.0, "calls": 0}
    _real_mono = time.monotonic
    def _fake_mono():
        _clock["t"] += 2.0
        return _clock["t"]
    _drun.resumed = lambda: _clock["t"] >= 1008.0
    time.monotonic = _fake_mono
    try:
        _drun.cleanup()
    finally:
        time.monotonic = _real_mono
    check("cleanup deadline observation sets the stand-down flag",
          getattr(_drun, "stood_down_during_cleanup", False) is True)
    # Exceptional final tool: capture interruption plus a drive failure keeps
    # exit 1, the fail verdict, and names the stand-down in the report.
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["SMOKE_DIR"] = Path(td) / "smoke"
            globals()["PREV_DIR"] = Path(td) / "smoke" / "prev"
            globals()["admission"] = lambda v, n, e: (True, "visible (test)", False)
            globals()["real_tools"] = lambda only=None, flavor="Release": [ToolRun("Resolute", Path("x"))]
            _real_cap = globals()["capture_window"]
            import threading as _th2
            _release2 = _th2.Event()
            globals()["capture_window"] = lambda hwnd: (_release2.wait(30), None)[1]
            def _drive_exc2(run, out_dir, prev_dir, collecting, mark, resumed=None):
                run.hwnd = 99
                _n = {"n": 0}
                def _ab():
                    _n["n"] += 1
                    return _n["n"] > 1
                failure_capture(run, "error", out_dir, abort=_ab)
                run.record("start", "pass", "stub")
                raise RuntimeError("stub drive failure")
            _rd4 = globals()["drive_tool"]
            globals()["drive_tool"] = _drive_exc2
            buf = io.StringIO()
            with redirect_stdout(buf):
                rc = main([])
            globals()["drive_tool"] = _rd4
            _release2.set()
            globals()["capture_window"] = _real_cap
            out = buf.getvalue()
            check("exceptional capture interruption: stood-down verdict, failure exit kept",
                  rc == 1 and "Suite verdict: **stood-down**" in out and "driver error" in out
                  and out.count("| Resolute |") == 5)
    finally:
        globals().update(_saved)
        os.environ.pop("RESOLUTE_IDLE_COLLECT", None)
    # Combined diagnostics beneath production spawn: resume and thread-close
    # failures both survive in job.error.
    _sp = ToolRun("SmokeDrillBroken", Path(sys.executable),
                  [str(ROOT / "scripts" / "smoke_fixture.py"), "nowindow"])
    _sp.job = JobBox()
    _real_resume2, _real_close2 = kernel32.ResumeThread, kernel32.CloseHandle
    kernel32.ResumeThread = lambda h: 0xFFFFFFFF
    kernel32.CloseHandle = lambda h: 0
    try:
        spawn_contained(_sp)
    finally:
        kernel32.ResumeThread, kernel32.CloseHandle = _real_resume2, _real_close2
    check("resume and thread-release failures both survive in job.error",
          _sp.job.error is not None and "ResumeThread failed" in _sp.job.error
          and "CloseHandle(thread) failed" in _sp.job.error)
    if _sp.proc is not None:
        try:
            _sp.proc.kill()
        except Exception:
            pass

    # Real drive_tool, windowless: window enumeration and capture are
    # injected fakes, the fixture process shows no window, and interruption
    # is triggered by phase, never by wall time. About raises; the driver's
    # own exception handler captures the interruption, then re-raises.
    _fixture = ROOT / "scripts" / "smoke_fixture.py"
    _erun = ToolRun("SmokeDrillDeaf", Path(sys.executable), [str(_fixture), "nowindow"],
                    start_timeout=15.0)
    _phase = {"capture": False}
    _saved_drive_apis = {k: globals()[k] for k in ("post", "pid_windows", "capture_window")}
    def _fake_windows(pid):
        return [(4242, "TkTopLevel", "fixture")] if _erun.proc and pid == _erun.proc.pid else []
    def _fake_post(hwnd, msg, wparam=0):
        if msg == WM_COMMAND and wparam == ABOUT_IDM:
            _phase["capture"] = True
            raise RuntimeError("about post failed")
    globals()["pid_windows"] = _fake_windows
    globals()["post"] = _fake_post
    globals()["capture_window"] = lambda hwnd: (64, 64, bytes([7, 9, 11, 255]) * 4096)
    try:
        drive_tool(_erun, SMOKE_DIR, PREV_DIR, True, 0.0,
                   resumed=lambda: _phase["capture"])
        _evidence_ok = False
    except RuntimeError:
        _evidence_ok = (getattr(_erun, "interrupted", False) is True
                        and "operator input resumed" in getattr(_erun, "_evidence", ""))
    finally:
        globals().update(_saved_drive_apis)
    check("real driver exception handler captures the interruption as evidence", _evidence_ok)
    # Combined diagnostics in the report rows: termination, resume, thread
    # and job-close failures all survive production drive and cleanup.
    _jrun = ToolRun("Resolute", Path("x"))
    _real_spawn2 = globals()["spawn_contained"]
    _real_close3 = kernel32.CloseHandle
    def _bad_spawn2(run):
        run.job.error = "ResumeThread failed; CloseHandle(thread) failed (5)"
        raise OSError("TerminateProcess failed (5)")
    globals()["spawn_contained"] = _bad_spawn2
    kernel32.CloseHandle = lambda h: 0
    try:
        drive_tool(_jrun, SMOKE_DIR, PREV_DIR, False, 0.0)
    finally:
        globals()["spawn_contained"] = _real_spawn2
        kernel32.CloseHandle = _real_close3
    _srow = next((r for r in _jrun.rows if r[1] == "start"), None)
    _xrow = next((r for r in _jrun.rows if r[1] == "exit"), None)
    check("combined diagnostics survive into start and exit rows",
          _srow is not None and "TerminateProcess failed" in _srow[3] and "ResumeThread failed" in _srow[3]
          and _xrow is not None and "CloseHandle(job) failed" in _xrow[3]
          and len(_jrun.rows) == 5 and _jrun.failed)

    # Production launch and cleanup failures, combined in one main() report.
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["SMOKE_DIR"] = Path(td) / "smoke"
            globals()["PREV_DIR"] = Path(td) / "smoke" / "prev"
            globals()["admission"] = lambda v, n, e: (True, "visible (test)", False)
            _fixture_run = ToolRun("SmokeDrillBroken", Path(sys.executable),
                                   [str(ROOT / "scripts" / "smoke_fixture.py"), "nowindow"])
            globals()["real_tools"] = lambda only=None, flavor="Release": [_fixture_run]
            _rr, _rc, _rt = kernel32.ResumeThread, kernel32.CloseHandle, kernel32.TerminateProcess
            kernel32.ResumeThread = lambda h: 0xFFFFFFFF
            kernel32.CloseHandle = lambda h: 0
            kernel32.TerminateProcess = lambda h, code: 0
            buf = io.StringIO()
            try:
                with redirect_stdout(buf):
                    rc = main([])
            finally:
                kernel32.ResumeThread, kernel32.CloseHandle, kernel32.TerminateProcess = _rr, _rc, _rt
            out = buf.getvalue()
            _need = ("ResumeThread failed", "TerminateProcess failed", "CloseHandle(thread) failed",
                     "CloseHandle(process) failed", "CloseHandle(job) failed")
            check("combined launch and release diagnostics reach the report with exit 1",
                  rc == 1 and all(n in out for n in _need)
                  and out.count("| SmokeDrillBroken |") == 5)
    finally:
        globals().update(_saved)
        os.environ.pop("RESOLUTE_IDLE_COLLECT", None)

    # Late capture diagnostics: a worker abandoned at its bound finishes
    # afterwards, and its release failure is collected, not discarded.
    import threading as _th3
    _rel3 = _th3.Event()
    _lrun2 = ToolRun("Resolute", Path("x"))
    _real_cap4 = globals()["capture_window"]
    def _late_fail(hwnd):
        _rel3.wait(30)
        raise RuntimeError("ReleaseDC failed")
    globals()["capture_window"] = _late_fail
    try:
        _shot = capture_window_bounded(99, timeout=0.5, pending=_lrun2.pending_captures)
    finally:
        _rel3.set()
        globals()["capture_window"] = _real_cap4
    _notes3 = []
    collect_late_capture_diagnostics([_lrun2], _notes3)
    check("late capture release failure reaches the report and fails the run",
          _shot is None and _lrun2.failed and any("ReleaseDC failed" in n for n in _notes3))

    # The drain stands down on input while its worker is still blocked.
    import threading as _th4
    _rel4 = _th4.Event()
    _drain_run = ToolRun("Resolute", Path("x"))
    _real_cap5 = globals()["capture_window"]
    globals()["capture_window"] = lambda hwnd: (_rel4.wait(30), None)[1]
    try:
        capture_window_bounded(99, timeout=0.5, pending=_drain_run.pending_captures)
        _notes4 = []
        _sd = collect_late_capture_diagnostics([_drain_run], _notes4, join_timeout=5.0,
                                               abort=lambda: True)
    finally:
        _rel4.set()
        globals()["capture_window"] = _real_cap5
    check("drain stands down on input and reports the worker unverified",
          _sd is True and any("stood down" in n for n in _notes4)
          and any("unverified" in n for n in _notes4) and _drain_run.failed)

    # Input during the drain join, through main(): stood-down verdict,
    # retained diagnostics, failure exit kept.
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["SMOKE_DIR"] = Path(td) / "smoke"
            globals()["PREV_DIR"] = Path(td) / "smoke" / "prev"
            globals()["admission"] = lambda v, n, e: (True, "collecting (test)", True)
            globals()["last_input_tick"] = lambda: 100
            import threading as _th5
            _rel5 = _th5.Event()
            def _drive_pending(run, out_dir, prev_dir, collecting, mark, resumed=None):
                globals()["capture_window"] = lambda hwnd: (_rel5.wait(30), None)[1]
                capture_window_bounded(99, timeout=0.5, pending=run.pending_captures)
                globals()["capture_window"] = _real_cap5
                for step, _e in step_table(run.name):
                    run.record(step, "pass", "stub")
                return False
            _real_cap5 = globals()["capture_window"]
            globals()["real_tools"] = lambda only=None, flavor="Release": [ToolRun("Resolute", Path("x"))]
            _rd5 = globals()["drive_tool"]
            globals()["drive_tool"] = _drive_pending
            # resumed() in main reads ticks: baseline 100, input (200) arrives
            # only once the drain is joining.
            _ticks = {"n": 0}
            def _tick():
                _ticks["n"] += 1
                return 100 if _ticks["n"] < 8 else 200
            globals()["last_input_tick"] = _tick
            buf = io.StringIO()
            try:
                with redirect_stdout(buf):
                    rc = main([])
            finally:
                _rel5.set()
                globals()["drive_tool"] = _rd5
                globals()["capture_window"] = _real_cap5
            out = buf.getvalue()
            check("input during the drain join stands the verdict down, exit kept",
                  rc == 1 and "Suite verdict: **stood-down**" in out and "unverified" in out)
    finally:
        globals().update(_saved)
        os.environ.pop("RESOLUTE_IDLE_COLLECT", None)

    # Elevation admission (D07 T01 S5): argument mapping, failure outcomes
    # at the parent-child boundary, and main() branch behaviour, all with
    # the shell and wait APIs stubbed so no prompt and no window appears.
    check("elevated child args drop --elevate and mark the child",
          elevated_child_args(["--elevate", "--visible", "--tools", "RegStudio"])
          == ["--visible", "--tools", "RegStudio", "--elevated-child"])
    check("elevated child args keep an existing marker",
          elevated_child_args(["--elevated-child"]) == ["--elevated-child"])
    _elev_saved = {k: globals()[k] for k in
                   ("_shell_execute_runas", "_wait_process", "_process_exit_code",
                    "_close_handle", "_terminate_process", "is_elevated",
                    "relaunch_elevated", "SMOKE_DIR", "PREV_DIR",
                    "last_input_tick", "admission", "real_tools")}
    try:
        _closed, _terminated = [], []

        def _relaunch_case(shell, wait, code):
            globals()["_shell_execute_runas"] = shell
            globals()["_wait_process"] = wait
            globals()["_process_exit_code"] = code
            globals()["_close_handle"] = lambda h: _closed.append(h)
            globals()["_terminate_process"] = lambda h: (_terminated.append(h), True)[1]
            try:
                return ("rc", relaunch_elevated(["--elevate", "--visible"]))
            except (ElevationDeclined, ElevationFailed) as exc:
                return (type(exc).__name__, str(exc))

        _closed.clear(); _terminated.clear()
        kind, val = _relaunch_case(lambda a: 777, lambda h, ms: WAIT_OBJECT_0, lambda h: 3)
        check("elevated relaunch returns the child exit code and closes the handle",
              kind == "rc" and val == 3 and _closed == [777] and not _terminated)
        kind, val = _relaunch_case(
            lambda a: (_ for _ in ()).throw(ElevationDeclined("declined")), None, None)
        check("declined consent is a named ElevationDeclined", kind == "ElevationDeclined")
        kind, val = _relaunch_case(
            lambda a: (_ for _ in ()).throw(ElevationFailed("ShellExecuteExW failed (Win32 error 5)")),
            None, None)
        check("other shell errors are named ElevationFailed",
              kind == "ElevationFailed" and "Win32 error 5" in val)
        _closed.clear()
        kind, val = _relaunch_case(lambda a: None, lambda h, ms: WAIT_OBJECT_0, lambda h: 0)
        check("a missing process handle fails by name",
              kind == "ElevationFailed" and "no process handle" in val and _closed == [])
        _closed.clear(); _terminated.clear()
        kind, val = _relaunch_case(lambda a: 42, lambda h, ms: WAIT_FAILED, lambda h: 0)
        check("a wait failure terminates, closes, and fails by name",
              kind == "ElevationFailed" and _terminated == [42] and _closed == [42])
        _closed.clear(); _terminated.clear()
        globals()["_shell_execute_runas"] = lambda a: 43
        globals()["_wait_process"] = lambda h, ms: WAIT_TIMEOUT
        globals()["_process_exit_code"] = lambda h: 0
        globals()["_close_handle"] = lambda h: _closed.append(h)
        globals()["_terminate_process"] = lambda h: (_terminated.append(h), True)[1]
        # timeout=0 expires the bound before any wait, so the stubbed WAIT_TIMEOUT loop cannot spin for the real bound.
        try:
            kind, val = ("rc", relaunch_elevated(["--visible"], timeout=0.0))
        except ElevationFailed as exc:
            kind, val = ("ElevationFailed", str(exc))
        check("an expired wait terminates, closes, and fails by name",
              kind == "ElevationFailed" and "did not finish" in val
              and _terminated == [43] and _closed == [43])

        def _interrupt(h, ms):
            raise KeyboardInterrupt
        _closed.clear(); _terminated.clear()
        globals()["_shell_execute_runas"] = lambda a: 44
        globals()["_wait_process"] = _interrupt
        globals()["_close_handle"] = lambda h: _closed.append(h)
        globals()["_terminate_process"] = lambda h: (_terminated.append(h), True)[1]
        try:
            relaunch_elevated(["--visible"])
            kind = "rc"
        except ElevationFailed:
            kind = "ElevationFailed"
        check("an interrupted wait terminates, closes, and fails by name",
              kind == "ElevationFailed" and _terminated == [44] and _closed == [44])
        kind, val = _relaunch_case(lambda a: 45, lambda h, ms: WAIT_OBJECT_0, lambda h: None)
        check("an exit-code failure fails by name",
              kind == "ElevationFailed" and "GetExitCodeProcess" in val)
        # Termination that the API refuses is reported unconfirmed, never as done.
        _closed.clear(); _terminated.clear()
        globals()["_shell_execute_runas"] = lambda a: 46
        globals()["_wait_process"] = lambda h, ms: WAIT_OBJECT_0
        globals()["_process_exit_code"] = lambda h: 0
        globals()["_close_handle"] = lambda h: _closed.append(h)
        globals()["_terminate_process"] = lambda h: False
        try:
            relaunch_elevated(["--visible"], timeout=0.0)
            kind, val = "rc", ""
        except ElevationFailed as exc:
            kind, val = ("ElevationFailed", str(exc))
        check("a refused termination is named unconfirmed and the handle closes",
              kind == "ElevationFailed" and "not confirmed" in val and _closed == [46])
        # An interrupt anywhere in the owned lifetime, not only inside the wait.
        _closed.clear(); _terminated.clear()
        globals()["_shell_execute_runas"] = lambda a: 47
        globals()["_wait_process"] = lambda h, ms: WAIT_OBJECT_0
        globals()["_terminate_process"] = lambda h: (_terminated.append(h), True)[1]
        _real_monotonic = time.monotonic
        _mono_calls = []
        def _flaky_monotonic():
            _mono_calls.append(1)
            if len(_mono_calls) > 1:
                raise KeyboardInterrupt
            return 0.0
        time.monotonic = _flaky_monotonic
        try:
            relaunch_elevated(["--visible"])
            kind = "rc"
        except ElevationFailed:
            kind = "ElevationFailed"
        finally:
            time.monotonic = _real_monotonic
        check("an interrupt outside the wait still terminates, closes, and names blocked",
              kind == "ElevationFailed" and _terminated == [47] and _closed == [47])

        # Win32 boundary: production is_elevated and _shell_execute_runas
        # with only the API functions and last-error source stubbed.
        _api_saved = (advapi32.OpenProcessToken, advapi32.GetTokenInformation,
                      shell32.ShellExecuteExW, ctypes.get_last_error, kernel32.CloseHandle)
        _closed_tokens = []
        kernel32.CloseHandle = lambda h: _closed_tokens.append(int(h.value) if hasattr(h, "value") else h) or True
        try:
            advapi32.OpenProcessToken = lambda proc, access, tok: False
            check("token open failure at the API boundary returns None", is_elevated() is None)
            def _open_ok(proc, access, tok_ptr):
                tok_ptr._obj.value = 99
                return True
            def _get_fail(tok, cls, buf, size, out):
                return False
            advapi32.OpenProcessToken = _open_ok
            advapi32.GetTokenInformation = _get_fail
            check("token info failure at the API boundary returns None", is_elevated() is None)
            def _get_zero(tok, cls, buf, size, out):
                buf._obj.value = 0
                return True
            advapi32.GetTokenInformation = _get_zero
            check("unelevated token at the API boundary returns False", is_elevated() is False)
            check("each acquired synthetic token is closed exactly once, never via the real API",
                  _closed_tokens == [99, 99])
            def _get_one(tok, cls, buf, size, out):
                buf._obj.value = 1
                return True
            advapi32.GetTokenInformation = _get_one
            check("elevated token at the API boundary returns True", is_elevated() is True)
            check("the elevated synthetic token also closes exactly once",
                  _closed_tokens == [99, 99, 99])
            shell32.ShellExecuteExW = lambda info_ptr: 0
            ctypes.get_last_error = lambda: 1223
            try:
                _elev_saved["_shell_execute_runas"](["--visible"])
                _shell_kind = "rc"
            except ElevationDeclined:
                _shell_kind = "declined"
            except ElevationFailed:
                _shell_kind = "failed"
            check("shell error 1223 at the API boundary maps to declined", _shell_kind == "declined")
            ctypes.get_last_error = lambda: 5
            try:
                _elev_saved["_shell_execute_runas"](["--visible"])
                _shell_kind, _shell_msg = "rc", ""
            except ElevationFailed as exc:
                _shell_kind, _shell_msg = "failed", str(exc)
            check("shell error 5 at the API boundary names its Win32 error",
                  _shell_kind == "failed" and "Win32 error 5" in _shell_msg)
            def _shell_ok(info_ptr):
                ctypes.cast(info_ptr, ctypes.POINTER(_ShellExecuteInfoW)).contents.hProcess = 777
                return 1
            shell32.ShellExecuteExW = _shell_ok
            check("shell success at the API boundary returns the process handle",
                  _elev_saved["_shell_execute_runas"](["--visible"]) == 777)
        finally:
            (advapi32.OpenProcessToken, advapi32.GetTokenInformation,
             shell32.ShellExecuteExW, ctypes.get_last_error, kernel32.CloseHandle) = _api_saved
        # Termination confirmation has distinct asserted outcomes.
        for _seq, _want, _label in (
                ([WAIT_FAILED, WAIT_OBJECT_0], "terminated and confirmed exited", "confirmed"),
                ([WAIT_FAILED, WAIT_TIMEOUT], "not confirmed", "unconfirmed")):
            _closed.clear(); _terminated.clear()
            _waits = iter(_seq)
            globals()["_shell_execute_runas"] = lambda a: 48
            globals()["_wait_process"] = lambda h, ms: next(_waits)
            globals()["_process_exit_code"] = lambda h: 0
            globals()["_close_handle"] = lambda h: _closed.append(h)
            globals()["_terminate_process"] = lambda h: (_terminated.append(h), True)[1]
            try:
                relaunch_elevated(["--visible"])
                _kind, _val = "rc", ""
            except ElevationFailed as exc:
                _kind, _val = "ElevationFailed", str(exc)
            check(f"termination {_label} outcome is asserted by name",
                  _kind == "ElevationFailed" and _want in _val
                  and _terminated == [48] and _closed == [48])

        # main() branches through the production entry point.
        import io as _io
        from contextlib import redirect_stdout as _redir
        globals()["last_input_tick"] = lambda: 100
        globals()["admission"] = lambda v, n, e: (True, "visible (test)", False)
        with tempfile.TemporaryDirectory() as td:
            globals()["SMOKE_DIR"] = Path(td) / "smoke"
            globals()["PREV_DIR"] = Path(td) / "smoke" / "prev"
            launched = []
            globals()["real_tools"] = lambda only=None, flavor="Release": launched.append(1) or []
            globals()["is_elevated"] = lambda: False
            buf = _io.StringIO()
            with _redir(buf):
                rc = main(["--elevated-child", "--tools", "RegStudio"])
            report = (Path(td) / "smoke" / "smoke-report.md").read_text(encoding="utf-8")
            check("unelevated child refuses by name, launches nothing, exits 2",
                  rc == 2 and not launched and "without elevation" in report
                  and report.count("| RegStudio |") == 5)
            globals()["is_elevated"] = lambda: None
            buf = _io.StringIO()
            with _redir(buf):
                rc = main(["--elevate", "--tools", "RegStudio"])
            check("an unverifiable token refuses by name and exits 2",
                  rc == 2 and "could not be verified" in buf.getvalue())
            # Exit-code forwarding preserves the child's report byte-for-byte.
            globals()["is_elevated"] = lambda: False
            sentinel = Path(td) / "smoke" / "smoke-report.md"
            sentinel.parent.mkdir(parents=True, exist_ok=True)
            sentinel.write_text("child report sentinel", encoding="utf-8")
            for want in (0, 1, 2):
                globals()["relaunch_elevated"] = (lambda w: lambda argv: w)(want)
                buf = _io.StringIO()
                with _redir(buf):
                    rc = main(["--elevate", "--visible", "--tools", "RegStudio"])
                if not (rc == want and sentinel.read_text(encoding="utf-8") == "child report sentinel"):
                    break
            check("child exit codes 0, 1, 2 forward and preserve its report",
                  rc == 2 and sentinel.read_text(encoding="utf-8") == "child report sentinel")
            # Declined consent through main(): blocked rows, exit 2.
            def _decline(argv):
                raise ElevationDeclined("elevation consent declined at the runas prompt")
            globals()["relaunch_elevated"] = _decline
            buf = _io.StringIO()
            with _redir(buf):
                rc = main(["--elevate", "--visible", "--tools", "RegStudio"])
            report = sentinel.read_text(encoding="utf-8")
            check("declined consent records blocked naming the decline, exit 2",
                  rc == 2 and "consent declined" in report and "| RegStudio | start | blocked |" in report)
            # A failure after launch never claims nothing was launched.
            def _launched_fail(argv):
                raise ElevationFailed("interrupted while the elevated child was owned; "
                                      "terminated and confirmed exited", launched=True)
            globals()["relaunch_elevated"] = _launched_fail
            buf = _io.StringIO()
            with _redir(buf):
                rc = main(["--elevate", "--visible", "--tools", "RegStudio"])
            report = sentinel.read_text(encoding="utf-8")
            check("a post-launch failure records the launch, never a false no-launch",
                  rc == 2 and "child was launched" in report
                  and "No tool was launched" not in report)
            # Missing handle through production relaunch_elevated and main:
            # launch state is unverified, never a false no-launch claim.
            globals()["relaunch_elevated"] = _elev_saved["relaunch_elevated"]
            globals()["_shell_execute_runas"] = lambda a: None
            globals()["is_elevated"] = lambda: False
            buf = _io.StringIO()
            with _redir(buf):
                rc = main(["--elevate", "--visible", "--tools", "RegStudio"])
            report = sentinel.read_text(encoding="utf-8")
            check("a missing handle through main reports launch unverified, exit 2",
                  rc == 2 and "could not be verified" in report
                  and "launch and termination" in report and "unverified" in report
                  and "No tool was launched" not in report)
            # Declined with no selection reports every registered tool.
            globals()["relaunch_elevated"] = _decline
            buf = _io.StringIO()
            with _redir(buf):
                rc = main(["--elevate", "--visible"])
            report = sentinel.read_text(encoding="utf-8")
            check("declined with default selection reports all registered tools",
                  rc == 2 and report.count("| RegStudio |") == 5
                  and report.count("| Resolute |") == 5)
            # Report-write failure on the elevation path prints the report.
            _blocker = Path(td) / "blocker"
            _blocker.write_text("x", encoding="utf-8")
            globals()["SMOKE_DIR"] = _blocker / "smoke"
            buf = _io.StringIO()
            with _redir(buf):
                rc = main(["--elevate", "--visible", "--tools", "RegStudio"])
            _out = buf.getvalue()
            globals()["SMOKE_DIR"] = Path(td) / "smoke"
            check("elevation report-write failure prints diagnostic and report",
                  rc == 2 and "could not write" in _out
                  and "| RegStudio | start | blocked |" in _out)
            # Already elevated: no relaunch, the normal driver path completes.
            globals()["is_elevated"] = lambda: True
            globals()["relaunch_elevated"] = lambda argv: 99
            buf = _io.StringIO()
            with _redir(buf):
                rc = main(["--elevate", "--visible", "--tools", "RegStudio"])
            check("already-elevated runs the driver inline without relaunching",
                  rc == 0 and "Suite verdict" in (Path(td) / "smoke" / "smoke-report.md").read_text(encoding="utf-8"))
    finally:
        globals().update(_elev_saved)

    # --help names the documented elevated command (D07 T01 S5 build order).
    import io as _help_io
    from contextlib import redirect_stdout as _help_redir
    _help_buf = _help_io.StringIO()
    _help_code = None
    try:
        with _help_redir(_help_buf):
            main(["--help"])
    except SystemExit as _help_exc:
        _help_code = _help_exc.code
    check("--help names the elevated RegStudio command",
          _help_code == 0 and "python scripts/smoke-run.py --elevate --visible --tools RegStudio" in _help_buf.getvalue())

    # Report renders every row and the verdict.
    text = render_report([("T", "start", "pass", "ok")], "pass", ["Admission: visible."])
    check("report names tool, step, verdict", "| T | start | pass | ok |" in text and "Suite verdict: **pass**" in text)

    print(f"self-test: {'FAIL ' + ', '.join(failures) if failures else 'all pass'}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())


