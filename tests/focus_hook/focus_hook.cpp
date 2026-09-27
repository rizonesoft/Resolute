// The focus guard's in-context hook for adopted processes. D00 T02 §11.
//
// The guard (tests/focus_guard.cpp) loads this DLL and installs its callback
// as an in-context WinEvent hook scoped to a process a case adopts, such as
// the launcher. The system maps the DLL into that process, so the callback
// runs on the thread that raised the event, before the call that raised it
// returns: the window is described where it is shown, not where it has
// moved by the time an out-of-process hook would hear of it (the gap panel
// round 4 of the D00 T02 §10 review found). The record goes back to the
// guard's message-only sink window through WM_COPYDATA.
//
// Plain Win32 only: the DLL runs inside another program and must not bring
// a runtime of its own into it.

#include "focus_hook.h"

#include <shellscalingapi.h>

extern "C" __declspec(dllexport) void CALLBACK ResoluteFocusHook(HWINEVENTHOOK, DWORD event, HWND hwnd, LONG idObject,
                                                                 LONG idChild, DWORD, DWORD) {
    if (!hwnd || idObject != OBJID_WINDOW || idChild != CHILDID_SELF) return;
    FocusHookRecord rec{};
    rec.kind    = event;
    rec.hwnd    = reinterpret_cast<ULONG_PTR>(hwnd);
    rec.pid     = GetCurrentProcessId();
    rec.visible = IsWindowVisible(hwnd);
    // A child shown under a hidden parent is not on the desktop.
    if (event == EVENT_OBJECT_SHOW && !rec.visible) return;
    rec.iconic = IsIconic(hwnd);
    GetClassNameW(hwnd, rec.cls, static_cast<int>(sizeof(rec.cls) / sizeof(rec.cls[0])));
    GetWindowRect(hwnd, &rec.rect);
    HMONITOR monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
    MONITORINFOEXW mi{};
    mi.cbSize = sizeof(mi);
    if (GetMonitorInfoW(monitor, &mi)) lstrcpynW(rec.monitor, mi.szDevice, 32);
    UINT x = 0, y = 0;
    if (SUCCEEDED(GetDpiForMonitor(monitor, MDT_EFFECTIVE_DPI, &x, &y))) rec.dpi = x;

    // The sink of the guard that adopted this process, from the mapping it
    // published under this process's id.
    wchar_t name[96];
    wsprintfW(name, L"%s%lu", kFocusHookSinkMapping, GetCurrentProcessId());
    // The guard publishes this before the process runs, so a missing mapping
    // means no guard adopted it and there is nobody to tell.
    HANDLE mapping = OpenFileMappingW(FILE_MAP_READ | FILE_MAP_WRITE, FALSE, name);
    if (!mapping) return;
    auto* block = static_cast<FocusHookSinkBlock*>(
        MapViewOfFile(mapping, FILE_MAP_READ | FILE_MAP_WRITE, 0, 0, sizeof(FocusHookSinkBlock)));
    if (block) {
        HWND sink = reinterpret_cast<HWND>(block->sink);  // NOLINT(performance-no-int-to-ptr): a handle published as data
        COPYDATASTRUCT cds{};
        cds.dwData = kFocusHookMagic;
        cds.cbData = sizeof(rec);
        cds.lpData = &rec;
        DWORD_PTR ignored = 0;
        // A record that cannot be delivered is counted, never dropped silently:
        // the guard fails the case when any was lost.
        if (!sink || !SendMessageTimeoutW(sink, WM_COPYDATA, 0, reinterpret_cast<LPARAM>(&cds), SMTO_BLOCK, 2000,
                                          &ignored))
            InterlockedIncrement(&block->lost);
        UnmapViewOfFile(block);
    }
    CloseHandle(mapping);
}
