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
  python scripts/smoke-run.py --self-test

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


# ---------------------------------------------------------------- win32

user32 = ctypes.windll.user32
gdi32 = ctypes.windll.gdi32
kernel32 = ctypes.windll.kernel32

WM_CLOSE = 0x0010
WM_COMMAND = 0x0111
IDOK = 1
PW_RENDERFULLCONTENT = 0x00000002


class LASTINPUTINFO(ctypes.Structure):
    _fields_ = [("cbSize", wintypes.UINT), ("dwTime", wintypes.DWORD)]


def idle_seconds() -> float:
    info = LASTINPUTINFO()
    info.cbSize = ctypes.sizeof(info)
    if not user32.GetLastInputInfo(ctypes.byref(info)):
        return 0.0
    return (kernel32.GetTickCount() - info.dwTime) / 1000.0


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


def wait_window(pid: int, timeout: float, want_dialog: bool = False):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        for hwnd, cls, title in pid_windows(pid):
            if want_dialog and cls == "#32770":
                return hwnd
            if not want_dialog and cls != "#32770":
                return hwnd
        time.sleep(0.1)
    return None


def capture_window(hwnd) -> tuple[int, int, bytes] | None:
    """PrintWindow into a DIB; returns (width, height, BGRA top-down)."""
    rect = wintypes.RECT()
    if not user32.GetWindowRect(hwnd, ctypes.byref(rect)):
        return None
    width, height = rect.right - rect.left, rect.bottom - rect.top
    if width <= 0 or height <= 0:
        return None
    hdc = user32.GetWindowDC(hwnd)
    mem = gdi32.CreateCompatibleDC(hdc)
    bmp = gdi32.CreateCompatibleBitmap(hdc, width, height)
    gdi32.SelectObject(mem, bmp)
    try:
        if not user32.PrintWindow(hwnd, mem, PW_RENDERFULLCONTENT):
            return None

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
            return None
        return width, height, buf.raw
    finally:
        gdi32.DeleteObject(bmp)
        gdi32.DeleteDC(mem)
        user32.ReleaseDC(hwnd, hdc)


def post(hwnd, msg, wparam=0):
    user32.PostMessageW(hwnd, msg, wparam, 0)


def capture_window_bounded(hwnd, timeout: float = 10.0):
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
    worker.start()
    worker.join(timeout)
    if worker.is_alive():
        return None
    return box.get("shot")


def exit_result(returncode) -> tuple[str, str]:
    """Only a clean self-exit passes; a crash status fails by name."""
    if returncode == 0:
        return "pass", "process exited (0)"
    return "fail", f"process exited with crash status 0x{returncode & 0xFFFFFFFF:08x}"


def input_resumed(collecting: bool, idle_now: float) -> bool:
    """Collecting runs stand down the moment operator input resumes."""
    return bool(collecting and idle_now < 2.0)


COLLECT_MIN_IDLE = 120.0  # docs/testing.md: no input for 120 s at a collecting start


class JobBox:
    """Kill-on-close job: launched tools die with the driver, even on a kill."""

    def __init__(self):
        self.handle = kernel32.CreateJobObjectW(None, None)
        if self.handle:
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

            class EXTENDED(ctypes.Structure):
                _fields_ = [("BasicLimitInformation", LIMITS),
                            ("IoInfo", ctypes.c_void_p * 6),
                            ("ProcessMemoryLimit", ctypes.c_size_t),
                            ("JobMemoryLimit", ctypes.c_size_t),
                            ("PeakProcessMemoryUsed", ctypes.c_size_t),
                            ("PeakJobMemoryUsed", ctypes.c_size_t)]

            info = EXTENDED()
            info.BasicLimitInformation.LimitFlags = 0x00002000  # JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
            kernel32.SetInformationJobObject(self.handle, 9, ctypes.byref(info), ctypes.sizeof(info))

    def assign(self, proc):
        if self.handle and proc is not None:
            kernel32.AssignProcessToJobObject(self.handle, int(proc._handle))

    def close(self):
        if self.handle:
            kernel32.CloseHandle(self.handle)
            self.handle = None


# ---------------------------------------------------------------- driver

class ToolRun:
    def __init__(self, name, exe: Path, args=(), start_timeout=None):
        self.name = name
        self.exe = exe
        self.args = list(args)
        self.start_timeout = start_timeout or TIMEOUTS["launch"]
        self.proc = None
        self.job = None
        self.hwnd = None
        self.rows = []
        self.failed = False

    def record(self, step, result, detail=""):
        self.rows.append((self.name, step, result, detail))
        if result == "fail":
            self.failed = True

    def cleanup(self):
        """Terminate only the process this run launched."""
        if self.job is None:
            self.job = JobBox()
        if self.proc and self.proc.poll() is None:
            self.proc.terminate()
            try:
                self.proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.proc.kill()


def launch_block(exc: OSError) -> str | None:
    """A named refusal at launch, or None when the launch simply failed."""
    if getattr(exc, "winerror", None) == 740:  # ERROR_ELEVATION_REQUIRED
        return ("launching this tool requires elevation "
                "(run the smoke driver elevated; elevated pass owned by D07 T01 S5)")
    return None


def drive_tool(run: ToolRun, out_dir: Path, prev_dir: Path, collecting: bool,
               input_mark: float) -> bool:
    """Drive one tool through the five steps. Returns stood_down."""
    table = dict(step_table(run.name))
    run.job = JobBox()
    try:
        run.proc = subprocess.Popen([str(run.exe), *run.args])
        run.job.assign(run.proc)
    except OSError as exc:
        blocked = launch_block(exc)
        for step, expected in step_table(run.name):
            if blocked and expected:
                run.record(step, "blocked", blocked)
            elif blocked:
                run.record(step, "absent", "surface not shipped")
            else:
                run.record(step, "fail" if expected else "absent",
                           f"launch failed for {run.exe}: {exc}" if expected else "surface not shipped")
        return False
    try:
        # start: observe the main window inside the launch bound.
        run.hwnd = wait_window(run.proc.pid, run.start_timeout)
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
            if not (collecting and input_resumed(collecting, idle_seconds())):
                return False
            post(run.hwnd, WM_CLOSE)
            for step in next_steps:
                run.record(step, "stood-down", "operator input resumed; tool dismissed")
            return True

        if stood_down_here(("main", "about", "preferences", "exit")):
            return True

        # main: capture the surface; a blank capture fails by name.
        shot = capture_window_bounded(run.hwnd)
        if shot is None:
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
            dialog = wait_window(run.proc.pid, TIMEOUTS["dialog"], want_dialog=True)
            if dialog is None:
                run.record("about", "fail", "About dialog did not appear (command ignored or no dialog)")
            else:
                post(dialog, WM_COMMAND, IDOK)
                deadline = time.monotonic() + TIMEOUTS["message"]
                gone = False
                while time.monotonic() < deadline:
                    if collecting and input_resumed(collecting, idle_seconds()):
                        post(dialog, WM_COMMAND, IDOK)
                        post(run.hwnd, WM_CLOSE)
                        run.record("preferences", "stood-down", "operator input resumed; tool dismissed")
                        run.record("exit", "stood-down", "operator input resumed; tool dismissed")
                        return True
                    if not any(h == dialog for h, _, _ in pid_windows(run.proc.pid)):
                        gone = True
                        break
                    time.sleep(0.1)
                run.record("about", "pass" if gone else "fail",
                           "About dialog observed and dismissed" if gone else "About dialog did not dismiss")

        # preferences: absent until the framework shell ships (D01 T03 S2).
        if not table["preferences"]:
            run.record("preferences", "absent",
                       "preferences surface not shipped (framework shell D01 T03 S2)")

        # exit: WM_CLOSE, then observe the process terminated.
        post(run.hwnd, WM_CLOSE)
        try:
            run.proc.wait(timeout=TIMEOUTS["exit"])
            result, detail = exit_result(run.proc.returncode)
            run.record("exit", result, detail)
        except subprocess.TimeoutExpired:
            run.record("exit", "fail",
                       f"process still running {TIMEOUTS['exit']:.0f}s after WM_CLOSE; cleaned up")
        return False
    finally:
        run.cleanup()
        run.job.close()


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


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--visible", action="store_true", help="operator asked: run visibly now")
    ap.add_argument("--drill", action="store_true", help="add the broken-tool fixture entries")
    ap.add_argument("--tools", default="", help="comma-separated subset of registered tools")
    ap.add_argument("--flavor", default="Release", choices=("Release", "Debug"),
                    help="build flavor whose Bin/<flavor> executables to drive (nightly builds Debug)")
    ap.add_argument("--self-test", action="store_true", help="windowless logic tests")
    args = ap.parse_args(argv)
    if args.self_test:
        return self_test()

    admitted, mode, collecting = admission(args.visible, datetime.now(), os.environ)
    if admitted and collecting and idle_seconds() < COLLECT_MIN_IDLE:
        admitted, mode = False, (f"refused: collecting runs need {COLLECT_MIN_IDLE:.0f}s without "
                                 "operator input at their start (docs/testing.md fence)")
    notes = [f"Admission: {mode}."]
    if not admitted:
        SMOKE_DIR.mkdir(parents=True, exist_ok=True)
        (SMOKE_DIR / "smoke-report.md").write_text(
            render_report([], "refused", notes + ["No tool was launched."]), encoding="utf-8")
        print(f"smoke: {mode}; report at build/smoke/smoke-report.md")
        return 2

    only = {t.strip() for t in args.tools.split(",") if t.strip()} or None
    runs = real_tools(only, args.flavor)
    if args.drill:
        runs += drill_tools()
    rows = []
    stood_down = False
    base_idle = idle_seconds()
    for run in runs:
        if collecting and input_resumed(collecting, idle_seconds()):
            rows.append((run.name, "start", "stood-down", "operator input resumed; dismissed and not launched"))
            stood_down = True
            continue
        if stood_down:
            rows.append((run.name, "start", "stood-down", "operator input resumed; not launched"))
            continue
        if drive_tool(run, SMOKE_DIR, PREV_DIR, collecting, base_idle):
            stood_down = True
        rows += run.rows
    failed = any(r[2] == "fail" for r in rows)
    blocked = any(r[2] == "blocked" for r in rows)
    verdict = "stood-down" if stood_down else ("fail" if failed else ("blocked" if blocked else "pass"))
    notes.append(f"Tools: {', '.join(r.name for r in runs)}.")
    SMOKE_DIR.mkdir(parents=True, exist_ok=True)
    report = render_report(rows, verdict, notes)
    (SMOKE_DIR / "smoke-report.md").write_text(report, encoding="utf-8")
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

    # Report renders every row and the verdict.
    text = render_report([("T", "start", "pass", "ok")], "pass", ["Admission: visible."])
    check("report names tool, step, verdict", "| T | start | pass | ok |" in text and "Suite verdict: **pass**" in text)

    print(f"self-test: {'FAIL ' + ', '.join(failures) if failures else 'all pass'}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())


