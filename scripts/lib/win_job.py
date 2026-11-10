"""A Windows job object that ends a process's children with it.

    import win_job
    win_job.end_children_with_this_process()

Windows does not end a child when its parent ends. A process that calls this joins a job object marked
kill-on-close and keeps the only handle to it: every process it starts afterwards is born inside the job, and the
operating system ends them all when this process ends, however that happens (a normal exit, a crash, a kill).
Calling it before starting the child leaves no gap in which the child, or anything the child starts, is outside
the job. Used by scripts/lsp-launch.py (a language server never outlives its launcher) and scripts/review-dispatch.py
(a reviewer never outlives its dispatcher, so the dispatcher's in-flight marker is true for the whole review).
Does nothing off Windows, where the callers end a process group instead. Stdlib only.
"""

from __future__ import annotations

import os

_JOB = None  # kept for the life of the process: closing this handle is what ends the children


def end_children_with_this_process() -> None:
    """Join a kill-on-close job object. Raises OSError when Windows refuses, so the caller starts nothing."""
    global _JOB
    if _JOB is not None or os.name != "nt":
        return
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
