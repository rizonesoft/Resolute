// A window shown on one monitor and moved to another at once. D00 T02 §11.
//
// The adopted-process proof for the focus guard: shown on the primary
// monitor, then moved to the first monitor that is not the primary before
// anything outside this process could look, then closed. A guard that
// measured it where it was delivered, not where it was shown, would miss the
// primary monitor altogether.

#include <windows.h>

namespace {

HMONITOR g_other = nullptr;

BOOL CALLBACK FindOther(HMONITOR monitor, HDC, LPRECT, LPARAM) {
    MONITORINFO mi{};
    mi.cbSize = sizeof(mi);
    GetMonitorInfoW(monitor, &mi);
    if ((mi.dwFlags & MONITORINFOF_PRIMARY) != 0) return TRUE;
    g_other = monitor;
    return FALSE;
}

}  // namespace

int WINAPI wWinMain(HINSTANCE inst, HINSTANCE, PWSTR, int) {
    SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
    EnumDisplayMonitors(nullptr, nullptr, FindOther, 0);
    WNDCLASSW wc{};
    wc.lpfnWndProc   = DefWindowProcW;
    wc.hInstance     = inst;
    wc.lpszClassName = L"ResoluteFlasher";
    wc.hbrBackground = static_cast<HBRUSH>(GetStockObject(GRAY_BRUSH));
    RegisterClassW(&wc);
    MONITORINFO primary{};
    primary.cbSize = sizeof(primary);
    GetMonitorInfoW(MonitorFromPoint(POINT{0, 0}, MONITOR_DEFAULTTOPRIMARY), &primary);
    HWND hwnd = CreateWindowExW(WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE, wc.lpszClassName, L"flasher", WS_POPUP,
                                primary.rcWork.left + 60, primary.rcWork.top + 60, 120, 80, nullptr, nullptr, inst,
                                nullptr);
    if (!hwnd) return 1;
    ShowWindow(hwnd, SW_SHOWNOACTIVATE);
    if (g_other) {
        MONITORINFO other{};
        other.cbSize = sizeof(other);
        GetMonitorInfoW(g_other, &other);
        SetWindowPos(hwnd, nullptr, other.rcWork.left + 60, other.rcWork.top + 60, 0, 0,
                     SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
    }
    Sleep(300);
    DestroyWindow(hwnd);
    return g_other ? 0 : 2;
}
