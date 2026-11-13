"""A Windows job object that ends a process's children with it.

    import win_job
    win_job.end_children_with_this_process()

Windows does not end a child when its parent ends. A process that calls this joins a job object marked
kill-on-close and keeps the only handle to it: every process it starts afterwards is born inside the job, and the
operating system ends them all when this process ends, however that happens (a normal exit, a crash, a kill).
Calling it before starting the child leaves no gap in which the child, or anything the child starts, is outside
the job. Used by scripts/lsp-launch.py (a language server never outlives its launcher) and scripts/review-dispatch.py
(a reviewer never outlives its dispatcher, so the dispatcher's in-flight marker is true for the whole review).
`end_children_with(pid)` does the same for a process that is already running (a Claude Code session the operator
typed `process plan` into): the job's only handle is left in that process, so what it starts from then on ends
with it. Does nothing off Windows, where the callers end a process group instead. Stdlib only.
"""

from __future__ import annotations

import os

_JOB = None  # kept for the life of the process: closing this handle is what ends the children


def _kernel():
    import ctypes
    from ctypes import wintypes

    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel.CreateJobObjectW.restype = wintypes.HANDLE
    kernel.CreateJobObjectW.argtypes = (ctypes.c_void_p, wintypes.LPCWSTR)
    kernel.SetInformationJobObject.argtypes = (wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.DWORD)
    kernel.AssignProcessToJobObject.argtypes = (wintypes.HANDLE, wintypes.HANDLE)
    kernel.GetCurrentProcess.restype = wintypes.HANDLE
    kernel.OpenProcess.restype = wintypes.HANDLE
    kernel.OpenProcess.argtypes = (wintypes.DWORD, wintypes.BOOL, wintypes.DWORD)
    kernel.DuplicateHandle.argtypes = (wintypes.HANDLE, wintypes.HANDLE, wintypes.HANDLE, ctypes.POINTER(wintypes.HANDLE),
                                       wintypes.DWORD, wintypes.BOOL, wintypes.DWORD)
    kernel.CloseHandle.argtypes = (wintypes.HANDLE,)
    return kernel


def _kill_on_close_job(kernel):
    """A new job object marked kill-on-close, or None when Windows refuses."""
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

    info = Extended()
    info.Basic.LimitFlags = 0x2000  # JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
    job = kernel.CreateJobObjectW(None, None)
    if job and not kernel.SetInformationJobObject(job, 9, ctypes.byref(info), ctypes.sizeof(info)):
        kernel.CloseHandle(job)
        return None
    return job or None


def end_children_with_this_process() -> None:
    """Join a kill-on-close job object. Raises OSError when Windows refuses, so the caller starts nothing."""
    global _JOB
    if _JOB is not None or os.name != "nt":
        return
    import ctypes

    kernel = _kernel()
    job = _kill_on_close_job(kernel)
    if not job or not kernel.AssignProcessToJobObject(job, kernel.GetCurrentProcess()):
        raise OSError(f"could not join a kill-on-close job object (error {ctypes.get_last_error()})")
    _JOB = job


def end_children_with(pid: int) -> None:
    """Put the running process `pid` in a kill-on-close job object whose only handle that process holds: every
    process it starts from now on is born inside the job, and Windows ends them all when it ends. What it started
    before stays outside. Raises OSError when Windows refuses; the process is then left exactly as it was.

    The handle is given to the process before the process joins the job, and this process's own handle is closed
    last: at no point is this process's exit, or a failure here, the closing of the job with `pid` inside it."""
    if os.name != "nt":
        return
    import ctypes
    from ctypes import wintypes

    kernel = _kernel()
    process = kernel.OpenProcess(0x0100 | 0x0001 | 0x0040, False, pid)  # SET_QUOTA, TERMINATE (to join a job), DUP_HANDLE
    if not process:
        raise OSError(f"could not open process {pid} (error {ctypes.get_last_error()})")
    job = None
    try:
        job = _kill_on_close_job(kernel)
        theirs = wintypes.HANDLE()
        if (not job or not kernel.DuplicateHandle(kernel.GetCurrentProcess(), job, process, ctypes.byref(theirs), 0, False, 0x2)  # SAME_ACCESS
                or not kernel.AssignProcessToJobObject(job, process)):
            raise OSError(f"could not put process {pid} in a kill-on-close job object (error {ctypes.get_last_error()})")
    finally:
        if job:
            kernel.CloseHandle(job)
        kernel.CloseHandle(process)


class OwnedJob:
    """A kill-on-close job object for one child this process starts and wants to end, with everything the child
    starts, at a moment it chooses and not only at its own exit.

        job = OwnedJob()                 # raises OSError when Windows refuses, so the caller starts nothing
        child = subprocess.Popen(...)
        job.take(child)                  # the child and everything it starts from now on are in the job
        ...
        left = job.end()                 # ends every process still in the job; returns how many there were

    Used by scripts/quickstart.py: a build, a compile cache or a test the session started is gone when the run
    returns, whether the session finished, failed or timed out. Windows only."""

    def __init__(self) -> None:
        import ctypes

        self._kernel = _kernel()
        self._job = _kill_on_close_job(self._kernel)
        if not self._job:
            raise OSError(f"could not create a kill-on-close job object (error {ctypes.get_last_error()})")

    def take(self, child) -> None:
        import ctypes
        from ctypes import wintypes

        if not self._kernel.AssignProcessToJobObject(self._job, wintypes.HANDLE(int(child._handle))):
            raise OSError(f"could not put process {child.pid} in the job object (error {ctypes.get_last_error()})")

    def members(self) -> int:
        """How many processes are in the job now."""
        import ctypes
        from ctypes import wintypes

        class Accounting(ctypes.Structure):
            _fields_ = [("TotalUserTime", ctypes.c_longlong), ("TotalKernelTime", ctypes.c_longlong),
                        ("ThisPeriodTotalUserTime", ctypes.c_longlong), ("ThisPeriodTotalKernelTime", ctypes.c_longlong),
                        ("TotalPageFaultCount", wintypes.DWORD), ("TotalProcesses", wintypes.DWORD),
                        ("ActiveProcesses", wintypes.DWORD), ("TotalTerminatedProcesses", wintypes.DWORD)]

        info = Accounting()
        self._kernel.QueryInformationJobObject.argtypes = (wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.DWORD, ctypes.c_void_p)
        if not self._kernel.QueryInformationJobObject(self._job, 1, ctypes.byref(info), ctypes.sizeof(info), None):
            raise OSError(f"could not read the job object (error {ctypes.get_last_error()})")
        return int(info.ActiveProcesses)

    def end(self) -> int:
        """Ends every process still in the job and closes it. Returns how many were still running. Safe to call twice."""
        from ctypes import wintypes

        if not self._job:
            return 0
        left = self.members()
        self._kernel.TerminateJobObject.argtypes = (wintypes.HANDLE, wintypes.UINT)
        self._kernel.TerminateJobObject(self._job, 1)
        self._kernel.CloseHandle(self._job)
        self._job = None
        return left
