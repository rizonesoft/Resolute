// Shared hosting for the UI suites. D00 T02 §10.
//
// Every UI case runs in the background-safe tier unless it is fenced as
// headful (tests/fence.h): its windows are real but never shown, and input
// reaches them through SendMessageW, so no window is painted on the desktop
// and none takes the foreground. The helpers below are the one place that
// creates such a host and pumps its messages; tests/focus-audit.md lists
// every site that uses them.

#pragma once

#include <resolute/animation.h>
#include <resolute/icons.h>
#include <resolute/render.h>

#include <windows.h>

namespace uitest {

// What the launcher initializes before any control exists, once per
// process: RenderContext::Init is not idempotent.
inline bool EnsureUi() {
    static const bool ready = rui::RenderContext::Init() && rui::LucideIcons::Load();
    return ready;
}

// A hidden top-level window: created without WS_VISIBLE and never shown.
// With `animate`, it owns the animation manager's timer for its lifetime.
struct HiddenHost {
    HWND hwnd  = nullptr;
    bool ready = false;
    bool animating = false;

    explicit HiddenHost(const wchar_t* className, WNDPROC proc = DefWindowProcW, bool animate = false, int w = 1200,
                        int h = 800) {
        ready = EnsureUi();
        WNDCLASSW wc{};
        wc.lpfnWndProc   = proc;
        wc.hInstance     = GetModuleHandleW(nullptr);
        wc.lpszClassName = className;
        RegisterClassW(&wc);  // a second registration fails harmlessly
        hwnd = CreateWindowExW(0, className, className, WS_OVERLAPPEDWINDOW, 0, 0, w, h, nullptr, nullptr,
                               wc.hInstance, nullptr);
        ready = ready && hwnd != nullptr;
        // Disabled, so nothing inside it can activate it: a control that calls
        // SetFocus on a click would otherwise make this hidden window the
        // foreground and take the operator's keyboard (the guard's first run
        // caught exactly that). Messages still reach the controls.
        EnableWindow(hwnd, FALSE);
        if (animate) {
            rui::AnimationManager::Instance().Start(hwnd);
            animating = true;
        }
    }
    ~HiddenHost() {
        if (animating) rui::AnimationManager::Instance().Stop();
        rui::AnimationManager::Instance().CancelAll();
        if (IsWindow(hwnd)) DestroyWindow(hwnd);
    }
    HiddenHost(const HiddenHost&)            = delete;
    HiddenHost& operator=(const HiddenHost&) = delete;
};

// Pumps the thread's messages until `done()` holds or `deadlineMs` passes.
// False means the transition never settled: the caller REQUIREs it, so a
// stuck animation fails the named case instead of hanging ctest.
template <class Done>
bool PumpUntil(Done done, DWORD deadlineMs = 3000) {
    const ULONGLONG end = GetTickCount64() + deadlineMs;
    MSG msg;
    while (!done()) {
        if (GetTickCount64() > end) return false;
        while (PeekMessageW(&msg, nullptr, 0, 0, PM_REMOVE)) {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
        MsgWaitForMultipleObjects(0, nullptr, FALSE, 10, QS_ALLINPUT);
    }
    return true;
}

// Pumps for a fixed time, whatever the manager holds: what must NOT happen
// in that window is asserted afterwards.
inline void PumpFor(DWORD ms) {
    const ULONGLONG start = GetTickCount64();
    PumpUntil([start, ms] { return GetTickCount64() - start >= ms; }, ms + 1000);
}

inline bool Settled() { return !rui::AnimationManager::Instance().IsAnimating(); }

inline void Click(HWND hwnd, int x, int y) {
    SendMessageW(hwnd, WM_LBUTTONDOWN, MK_LBUTTON, MAKELPARAM(x, y));
    SendMessageW(hwnd, WM_LBUTTONUP, 0, MAKELPARAM(x, y));
}

}  // namespace uitest
