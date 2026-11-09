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

namespace {

// Whether the guard marked adoption intent for this process: the inherited
// environment variable, or the intent file the guard wrote for a child it
// adopted after creation.
bool AdoptionIntentMarked() {
    wchar_t value[2];
    if (GetEnvironmentVariableW(kFocusHookAdoptEnv, value, 2) > 0) return true;
    wchar_t path[MAX_PATH];
    if (!GetTempPathW(MAX_PATH, path)) return false;
    wchar_t name[96];
    wsprintfW(name, L"%s%lu.txt", kFocusHookIntentPrefix, GetCurrentProcessId());
    lstrcatW(path, name);
    return GetFileAttributesW(path) != INVALID_FILE_ATTRIBUTES;
}

// The failure marker: a small file in the temp directory naming which step
// failed, so the guard can void the case's proof by name at its end. When
// the temp file cannot be written, a current-directory file is tried, and
// when that fails too, a named mutex the guard probes: three destinations,
// so no single filesystem failure silences the channel. Every write checks
// its byte count; a short write moves to the next destination.
HANDLE g_failMutex = nullptr;

bool WriteMarkerFile(const wchar_t* dir, const wchar_t* kind) {
    wchar_t path[MAX_PATH];
    lstrcpynW(path, dir, MAX_PATH);
    wchar_t name[96];
    wsprintfW(name, L"%s%lu.txt", kFocusHookFailPrefix, GetCurrentProcessId());
    lstrcatW(path, name);
    HANDLE file = CreateFileW(path, GENERIC_WRITE, FILE_SHARE_READ, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (file == INVALID_HANDLE_VALUE) return false;
    char buf[16];
    int n = 0;
    for (const wchar_t* c = kind; *c; ++c) buf[n++] = static_cast<char>(*c);
    buf[n++] = '\n';
    DWORD written = 0;
    const bool ok = WriteFile(file, buf, static_cast<DWORD>(n), &written, nullptr) && written == static_cast<DWORD>(n);
    CloseHandle(file);
    return ok;
}

void WriteFailureMarker(const wchar_t* kind) {
    wchar_t dir[MAX_PATH];
    if (GetTempPathW(MAX_PATH, dir) && WriteMarkerFile(dir, kind)) return;
    if (GetCurrentDirectoryW(MAX_PATH, dir)) {
        lstrcatW(dir, L"\\");
        if (WriteMarkerFile(dir, kind)) return;
    }
    // Third destination: the named event the guard created at adoption
    // (or creates here when it did not), signalled and held so the guard
    // can probe it at case end even after this process has exited: the
    // guard's own handle keeps the event alive through child teardown.
    wchar_t name[96];
    wsprintfW(name, L"%s%lu", kFocusHookFailEvent, GetCurrentProcessId());
    g_failMutex = OpenEventW(EVENT_MODIFY_STATE, FALSE, name);
    if (!g_failMutex) g_failMutex = CreateEventW(nullptr, TRUE, FALSE, name);
    if (g_failMutex) SetEvent(g_failMutex);
}

}  // namespace

// Test support: releases the failure event so a drill that forced the
// third destination can clean up inside its own case.
extern "C" __declspec(dllexport) void ResoluteFocusHookReleaseFailureMutex() {
    if (g_failMutex) {
        CloseHandle(g_failMutex);
        g_failMutex = nullptr;
    }
}

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
    if (!mapping) {
        // Nobody to tell through the mapping; the marker is the channel
        // that does not depend on it.
        if (AdoptionIntentMarked()) WriteFailureMarker(L"open");
        return;
    }
    auto* block = static_cast<FocusHookSinkBlock*>(
        MapViewOfFile(mapping, FILE_MAP_READ | FILE_MAP_WRITE, 0, 0, sizeof(FocusHookSinkBlock)));
    if (!block && AdoptionIntentMarked()) WriteFailureMarker(L"map");
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
