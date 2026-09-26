// The fenced headful cases. D00 T02 §10.
//
// Each case here needs the desktop: a modal popup that takes the foreground,
// the toolbar's overflow menu, or a window capture. They carry `[headful]`,
// which the default test presets exclude, open with the fence's gate, and
// declare where their windows go in a `[place:...]` tag the focus guard
// checks. tests/focus-audit.md gives each one's placement reason.

#include <catch2/catch_test_macros.hpp>

#include <resolute/controls/popupmenu.h>
#include <resolute/controls/toolbar.h>
#include <resolute/dpi.h>

#include "fence.h"
#include "focus_guard.h"
#include "ui_host.h"

#include <atomic>
#include <cstdio>
#include <filesystem>
#include <string>
#include <thread>
#include <vector>

namespace {

// What the driving timer does once the popup or menu it waits for exists.
struct Script {
    WPARAM         keys[4]     = {};
    int            keyCount    = 0;
    HWND           destroy     = nullptr;  // tear this window down instead
    int            ticks       = 0;
    bool           acted       = false;
};
Script g_script;

// This process's visible window of class `cls`, never one another process
// (the operator's own launcher, say) has open.
HWND OwnWindow(const wchar_t* cls) {
    static const wchar_t* wanted = nullptr;
    static HWND           found  = nullptr;
    wanted = cls;
    found  = nullptr;
    EnumWindows(
        [](HWND hwnd, LPARAM) -> BOOL {
            DWORD owner = 0;
            GetWindowThreadProcessId(hwnd, &owner);
            wchar_t name[64] = {};
            GetClassNameW(hwnd, name, 64);
            if (owner != GetCurrentProcessId() || std::wstring(name) != wanted || !IsWindowVisible(hwnd)) return TRUE;
            found = hwnd;
            return FALSE;
        },
        0);
    return found;
}

// A thread timer, dispatched by whichever modal loop is running: it waits
// for the popup, then plays the script into it. It gives up after 5 s so a
// popup that never appears fails the case instead of waiting for ctest.
void CALLBACK Drive(HWND, UINT, UINT_PTR id, DWORD) {
    HWND popup = OwnWindow(L"ResolutePopupMenu");
    if (fence::InputResumed() && popup) {
        PostMessageW(popup, WM_KEYDOWN, VK_ESCAPE, 0);  // the operator is back: stand down
        KillTimer(nullptr, id);
        return;
    }
    if (!popup) {
        if (++g_script.ticks > 100) {
            KillTimer(nullptr, id);
            PostQuitMessage(9);
        }
        return;
    }
    KillTimer(nullptr, id);
    g_script.acted = true;
    if (g_script.destroy) {
        DestroyWindow(g_script.destroy);
        return;
    }
    for (int i = 0; i < g_script.keyCount; ++i) PostMessageW(popup, WM_KEYDOWN, g_script.keys[i], 0);
}

const rui::DropdownChoice kChoices[] = {
    {4101, L"First", nullptr},
    {4102, L"Second", nullptr},
    {4103, L"Third", nullptr},
};

// A point well inside the primary monitor's work area.
std::vector<WORD> g_toolbarCommands;

LRESULT CALLBACK ToolbarHost(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    if (msg == WM_COMMAND) g_toolbarCommands.push_back(LOWORD(wp));
    return DefWindowProcW(hwnd, msg, wp, lp);
}

POINT OnPrimary() {
    MONITORINFO mi{};
    mi.cbSize = sizeof(mi);
    GetMonitorInfoW(MonitorFromPoint(POINT{0, 0}, MONITOR_DEFAULTTOPRIMARY), &mi);
    return POINT{mi.rcWork.left + 200, mi.rcWork.top + 200};
}

WORD ShowScripted(HWND owner, Script script) {
    g_script = script;
    SetTimer(nullptr, 0, 50, Drive);
    const WORD chosen = rui::PopupMenu::Show(owner, OnPrimary(), kChoices, 3, 96);
    // A quit the driver posted when the popup never came is not the suite's.
    MSG msg;
    PeekMessageW(&msg, nullptr, WM_QUIT, WM_QUIT, PM_REMOVE);
    return chosen;
}

}  // namespace

TEST_CASE("The popup menu returns the command the keyboard chooses", "[ui][headful][place:primary]") {
    RESOLUTE_HEADFUL_GATE();
    uitest::HiddenHost host(L"ResoluteHeadfulHost");
    REQUIRE(host.ready);
    Script s;
    s.keys[0]  = VK_DOWN;  // First
    s.keys[1]  = VK_DOWN;  // Second
    s.keys[2]  = VK_RETURN;
    s.keyCount = 3;
    const WORD chosen = ShowScripted(host.hwnd, s);
    RESOLUTE_HEADFUL_CHECK_INPUT();
    REQUIRE(g_script.acted);
    CHECK(chosen == 4102);
    CHECK(OwnWindow(L"ResolutePopupMenu") == nullptr);
}

TEST_CASE("The popup menu dismissed with Escape returns no command", "[ui][headful][place:primary]") {
    RESOLUTE_HEADFUL_GATE();
    uitest::HiddenHost host(L"ResoluteHeadfulHost");
    REQUIRE(host.ready);
    Script s;
    s.keys[0]  = VK_DOWN;
    s.keys[1]  = VK_ESCAPE;
    s.keyCount = 2;
    const WORD chosen = ShowScripted(host.hwnd, s);
    RESOLUTE_HEADFUL_CHECK_INPUT();
    REQUIRE(g_script.acted);
    CHECK(chosen == 0);
    CHECK(OwnWindow(L"ResolutePopupMenu") == nullptr);
}

TEST_CASE("The popup menu ends when its owner is torn down under it", "[ui][headful][place:primary]") {
    // Before D00 T02 §10 the popup's loop waited for a message that never
    // came once its window died with its owner, which hung the caller.
    RESOLUTE_HEADFUL_GATE();
    HWND owner = CreateWindowExW(0, L"STATIC", L"owner", WS_POPUP, 0, 0, 10, 10, nullptr, nullptr,
                                 GetModuleHandleW(nullptr), nullptr);
    REQUIRE(owner != nullptr);
    Script s;
    s.destroy = owner;
    const WORD chosen = ShowScripted(owner, s);
    RESOLUTE_HEADFUL_CHECK_INPUT();
    REQUIRE(g_script.acted);
    CHECK(chosen == 0);
    CHECK_FALSE(IsWindow(owner));
    CHECK(OwnWindow(L"ResolutePopupMenu") == nullptr);
}

TEST_CASE("The toolbar's overflow button offers the hidden commands", "[ui][headful][place:primary]") {
    // Through the real button and its modal menu: the narrow toolbar's
    // overflow button opens the system menu, and choosing Refresh in it
    // reaches the parent as exactly that command.
    RESOLUTE_HEADFUL_GATE();
    g_toolbarCommands.clear();
    uitest::HiddenHost host(L"ResoluteHeadfulToolbarHost", ToolbarHost);
    REQUIRE(host.ready);
    // A disabled owner cannot host a modal menu: this case enables its
    // (still hidden) host.
    EnableWindow(host.hwnd, TRUE);
    rui::Toolbar tb;
    tb.Create(host.hwnd, GetModuleHandleW(nullptr), 401);
    tb.UpdateDpi(96);
    // Narrow enough that every left-hand item overflows (as D00 T02 §9's
    // overflow golden shows).
    const int w = rui::Dpi::Scale(140, 96), h = tb.ScaledHeight();
    tb.Resize(0, 0, w, h);
    UpdateWindow(tb.Handle());
    SendMessageW(tb.Handle(), WM_PAINT, 0, 0);  // layout runs in paint

    // Refresh's place among the menu's selectable items, from the same
    // builder the button uses: the keyboard skips separators.
    HMENU expect = tb.BuildOverflowMenu();
    REQUIRE(expect != nullptr);
    int downs = 0;
    bool found = false;
    for (int i = 0; i < GetMenuItemCount(expect) && !found; ++i) {
        if (GetMenuState(expect, static_cast<UINT>(i), MF_BYPOSITION) & MF_SEPARATOR) continue;
        ++downs;
        found = GetMenuItemID(expect, i) == rui::IDC_TB_REFRESH;
    }
    DestroyMenu(expect);
    REQUIRE(found);

    // The menu runs its own modal loop on this thread, which dispatches no
    // thread timer, so a worker plays the keys into it: it waits for this
    // process's menu window, never another one on the desktop, and stands
    // down with Escape when the operator returns.
    std::atomic<bool> acted{false};
    std::thread driver([&] {
        for (int tick = 0; tick < 100; ++tick) {
            HWND menu = OwnWindow(L"#32768");
            if (!menu) {
                Sleep(50);
                continue;
            }
            if (fence::InputResumed()) {
                PostMessageW(menu, WM_KEYDOWN, VK_ESCAPE, 0);
                return;
            }
            for (int i = 0; i < downs; ++i) PostMessageW(menu, WM_KEYDOWN, VK_DOWN, 0);
            PostMessageW(menu, WM_KEYDOWN, VK_RETURN, 0);
            acted = true;
            return;
        }
    });
    const D2D1_RECT_F button = tb.OverflowRect(static_cast<float>(w));
    const int x = static_cast<int>((button.left + button.right) / 2.0f);
    const int y = static_cast<int>((button.top + button.bottom) / 2.0f);
    SendMessageW(tb.Handle(), WM_LBUTTONDOWN, MK_LBUTTON, MAKELPARAM(x, y));
    SendMessageW(tb.Handle(), WM_LBUTTONUP, 0, MAKELPARAM(x, y));
    driver.join();
    RESOLUTE_HEADFUL_CHECK_INPUT();
    REQUIRE(acted);
    CHECK(g_toolbarCommands == std::vector<WORD>{rui::IDC_TB_REFRESH});
    CHECK(OwnWindow(L"#32768") == nullptr);
    DestroyWindow(tb.Handle());
}

namespace {

// The launcher's main window in process `pid`, never another instance the
// operator may have open.
HWND MainWindowOf(DWORD pid) {
    static DWORD wanted = 0;
    static HWND  found  = nullptr;
    wanted = pid;
    found  = nullptr;
    EnumWindows(
        [](HWND hwnd, LPARAM) -> BOOL {
            DWORD owner = 0;
            GetWindowThreadProcessId(hwnd, &owner);
            wchar_t cls[32] = {};
            GetClassNameW(hwnd, cls, 32);
            if (owner != wanted || std::wstring(cls) != L"ResoluteMain") return TRUE;
            found = hwnd;
            return FALSE;
        },
        0);
    return found;
}

// The launcher a case started: closed when the case ends, however it ends,
// so a failed assertion never leaves a window on the operator's desktop.
struct Launched {
    PROCESS_INFORMATION pi{};
    ~Launched() {
        if (!pi.hProcess) return;
        if (WaitForSingleObject(pi.hProcess, 0) == WAIT_TIMEOUT) {
            if (HWND w = MainWindowOf(pi.dwProcessId)) PostMessageW(w, WM_CLOSE, 0, 0);
            if (WaitForSingleObject(pi.hProcess, 5000) == WAIT_TIMEOUT) TerminateProcess(pi.hProcess, 1);
            WaitForSingleObject(pi.hProcess, 5000);
        }
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
    }
};

// Brings `hwnd` to the foreground from a background process: a thread whose
// input is attached to the current foreground thread may pass it on.
bool TakeForeground(HWND hwnd) {
    const HWND  current = GetForegroundWindow();
    const DWORD theirs  = current ? GetWindowThreadProcessId(current, nullptr) : 0;
    const DWORD mine    = GetCurrentThreadId();
    const bool  attach  = theirs && theirs != mine && AttachThreadInput(mine, theirs, TRUE);
    SetForegroundWindow(hwnd);
    BringWindowToTop(hwnd);
    if (attach) AttachThreadInput(mine, theirs, FALSE);
    return GetForegroundWindow() == hwnd;
}

// Starts the launcher, puts it on the monitor at `dpi` in the appearance
// asked for, and captures it with scripts/capture-window.ps1 into the
// appearance-by-DPI matrix (D00 T02 §9's convention, first instance).
void CaptureLauncher(const char* mode, UINT dpi) {
    HMONITOR monitor = focusguard::MonitorWithDpi(dpi);
    if (!monitor) {
        const std::string why = "hardware absent: no monitor at " + std::to_string(dpi) + " DPI; re-probed each night";
        std::printf("SKIP \"%s\" %s\n", Catch::getResultCapture().getCurrentTestName().c_str(), why.c_str());
        std::fflush(stdout);
        SKIP(why);
    }
    MONITORINFO mi{};
    mi.cbSize = sizeof(mi);
    GetMonitorInfoW(monitor, &mi);
    // The launcher creates its window at CW_USEDEFAULT, which takes this
    // position: the window first appears on the declared monitor rather than
    // being moved there after showing elsewhere.
    STARTUPINFOW si{};
    si.cb      = sizeof(si);
    si.dwFlags = STARTF_USEPOSITION;
    si.dwX     = static_cast<DWORD>(mi.rcWork.left + 40);
    si.dwY     = static_cast<DWORD>(mi.rcWork.top + 40);
    Launched launched;
    PROCESS_INFORMATION& pi = launched.pi;
    std::wstring cmd = L"\"" + std::filesystem::path(RESOLUTE_LAUNCHER).wstring() + L"\"";
    REQUIRE(CreateProcessW(nullptr, cmd.data(), nullptr, nullptr, FALSE, 0, nullptr, nullptr, &si, &pi));
    focusguard::AdoptProcess(pi.dwProcessId);
    WaitForInputIdle(pi.hProcess, 10000);
    HWND main = nullptr;
    uitest::PumpUntil([&] { return (main = MainWindowOf(pi.dwProcessId)) != nullptr; }, 10000);
    REQUIRE(main != nullptr);

    // The launcher starts in System mode; its theme command cycles System,
    // Dark, Light, so one press is dark and two are light.
    const int presses = std::string(mode) == "dark" ? 1 : 2;
    for (int i = 0; i < presses; ++i) {
        SendMessageW(main, WM_COMMAND, MAKEWPARAM(rui::IDC_TB_THEME, 0), 0);
        uitest::PumpFor(600);
    }
    const bool foreground = TakeForeground(main);
    uitest::PumpFor(500);
    RESOLUTE_HEADFUL_CHECK_INPUT();
    INFO("capture-window.ps1 fails closed unless the launcher owns the foreground");
    REQUIRE(foreground);
    REQUIRE(GetForegroundWindow() == main);

    SYSTEMTIME st{};
    GetLocalTime(&st);
    char date[16];
    std::snprintf(date, sizeof(date), "%04u-%02u-%02u", st.wYear, st.wMonth, st.wDay);
    const int pct = static_cast<int>(dpi * 100 / 96);
    const std::filesystem::path out = std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "docs" / "captures" / "runs" /
                                      (std::string(date) + "-D00-T02-s10-launcher-" + mode + "-" +
                                       std::to_string(pct) + ".png");
    // The capture script, started directly rather than through a shell.
    const std::filesystem::path script = std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "scripts" / "capture-window.ps1";
    std::wstring ps = L"pwsh -NoProfile -File \"" + script.wstring() + L"\" -ProcessId " +
                      std::to_wstring(pi.dwProcessId) + L" -Appearance " + std::filesystem::path(mode).wstring() +
                      L" -Out \"" + out.wstring() + L"\" -Describes \"the launcher at startup, " +
                      std::filesystem::path(mode).wstring() + L", " + std::to_wstring(pct) +
                      L" percent (D00 T02 section 10)\"";
    STARTUPINFOW psi{};
    psi.cb = sizeof(psi);
    PROCESS_INFORMATION ppi{};
    REQUIRE(CreateProcessW(nullptr, ps.data(), nullptr, nullptr, FALSE, 0, nullptr, nullptr, &psi, &ppi));
    WaitForSingleObject(ppi.hProcess, 60000);
    DWORD rc = 1;
    GetExitCodeProcess(ppi.hProcess, &rc);
    CloseHandle(ppi.hThread);
    CloseHandle(ppi.hProcess);
    CHECK(rc == 0);
    CHECK(std::filesystem::exists(out));

}

}  // namespace

TEST_CASE("Launcher capture, light at 100 percent", "[ui][headful][place:dpi96]") {
    RESOLUTE_HEADFUL_GATE();
    CaptureLauncher("light", 96);
}

TEST_CASE("Launcher capture, dark at 100 percent", "[ui][headful][place:dpi96]") {
    RESOLUTE_HEADFUL_GATE();
    CaptureLauncher("dark", 96);
}

TEST_CASE("Launcher capture, light at 150 percent", "[ui][headful][place:dpi144]") {
    RESOLUTE_HEADFUL_GATE();
    CaptureLauncher("light", 144);
}

TEST_CASE("Launcher capture, dark at 150 percent", "[ui][headful][place:dpi144]") {
    RESOLUTE_HEADFUL_GATE();
    CaptureLauncher("dark", 144);
}
