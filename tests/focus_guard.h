// The focus guard: continuous observation and the window census. D00 T02 §10.
//
// WinEvent hooks for foreground changes and window shows see a transient
// activation when it happens rather than missing it between polls: in
// context for this process, so a window is judged as it was when shown, and
// on a dedicated thread for the processes a case adopts, where every show is
// kept and measured at delivery; the adopted processes' threads are
// snapshotted every 100 ms, so a show whose raising thread has exited by
// delivery still resolves. The one limit: a thread born and gone inside one
// 100 ms gap, having shown a window, cannot be attributed. At the end of every case the
// guard takes a census of the windows the suite owns (this process and any
// process a case adopts, such as the launcher it starts) and checks it:
//
//   default tier   no window shown, no foreground taken, no mouse capture
//                  held, and no window left behind
//   headful tier   every window shown sits on the monitor and DPI the case
//                  declares in its `[place:...]` tag, and nothing is left
//                  behind either
//
// A violation prints `FOCUS-VIOLATION <case>: <what>` and fails the run
// (tests/main.cpp). Each case's census is written under RESOLUTE_CENSUS_DIR.

#pragma once

#include <windows.h>

#include <cstdint>
#include <string>
#include <vector>

namespace focusguard {

struct WindowRecord {
    HWND         hwnd    = nullptr;
    DWORD        pid     = 0;
    std::wstring cls;
    bool         visible = false;
    bool         iconic  = false;
    RECT         rect{};
    std::wstring monitor;  // the monitor's device name, e.g. \\.\DISPLAY1
    UINT         dpi     = 0;  // that monitor's effective DPI
};

struct Event {
    enum class Kind : std::uint8_t { Foreground, Shown } kind = Kind::Shown;
    WindowRecord window;
};

void Start();
void Stop();

// Windows of `pid` count as the suite's from now until the case ends.
void AdoptProcess(DWORD pid);

// The events observed since the last drain, after the observer has caught up.
std::vector<Event> Drain();

// The top-level windows the suite owns right now.
std::vector<WindowRecord> Census();

WindowRecord Describe(HWND hwnd);

// The monitor whose effective DPI is `dpi`, or nullptr when none is attached.
HMONITOR MonitorWithDpi(UINT dpi);
UINT     MonitorDpi(HMONITOR monitor);

// Violations recorded so far in this process.
int Violations();

// Checks one case's events and census against its tier. Returns the
// violation lines (empty when clean); the listener prints and counts them.
std::vector<std::string> Check(const std::string& testName, bool headful, const std::string& placeTag,
                               const std::vector<HWND>& before, const std::vector<Event>& events,
                               const std::vector<WindowRecord>& census, HWND capture);

}  // namespace focusguard
