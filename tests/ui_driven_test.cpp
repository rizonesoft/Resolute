// Driven UI completion tests. D00 T02 §7.
//
// ui_test.cpp covers what headless can reach; what it cannot is the
// animation manager's timer (every transition's endpoint) and interaction
// that needs a real window. Here a host window is created, never shown, and
// the manager's real timer is pumped through a message loop until each
// transition settles. A pump that outlives its deadline fails the case by
// name instead of hanging the run.
//
// The windows are real but hidden: messages reach them through
// SendMessageW, so nothing is painted on the desktop and no window is
// activated.

#include <catch2/catch_test_macros.hpp>

#include <resolute/animation.h>
#include <resolute/controls/contentview.h>
#include <resolute/controls/listview.h>
#include <resolute/controls/sidebar.h>
#include <resolute/dpi.h>
#include <resolute/icons.h>
#include <resolute/render.h>
#include <resolute/theme.h>

#include <windowsx.h>

#include <cstring>
#include <memory>

namespace {

using rui::AnimationManager;

// WM_SIZE messages the host has received: the sidebar's collapse animation
// sends one to its parent every frame, so a count that stops growing is a
// callback that stopped running.
int g_hostSizes = 0;

LRESULT CALLBACK HostProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    if (msg == WM_SIZE) ++g_hostSizes;
    return DefWindowProcW(hwnd, msg, wp, lp);
}

// A hidden top-level window that owns the manager's timer for one case.
struct DrivenHost {
    HWND hwnd  = nullptr;
    bool ready = false;

    DrivenHost() {
        // What the launcher initializes before any control exists, once per
        // process: RenderContext::Init is not idempotent.
        static const bool rendered = rui::RenderContext::Init() && rui::LucideIcons::Load();
        ready = rendered;
        WNDCLASSW wc{};
        wc.lpfnWndProc   = HostProc;
        wc.hInstance     = GetModuleHandleW(nullptr);
        wc.lpszClassName = L"ResoluteDrivenHost";
        RegisterClassW(&wc);  // a second registration fails harmlessly
        hwnd = CreateWindowExW(0, wc.lpszClassName, L"driven", WS_OVERLAPPEDWINDOW, 0, 0, 800, 600, nullptr,
                               nullptr, wc.hInstance, nullptr);
        AnimationManager::Instance().Start(hwnd);
    }
    ~DrivenHost() {
        AnimationManager::Instance().Stop();
        DestroyWindow(hwnd);
    }
    DrivenHost(const DrivenHost&)            = delete;
    DrivenHost& operator=(const DrivenHost&) = delete;
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

bool Settled() { return !AnimationManager::Instance().IsAnimating(); }

// Pumps for a fixed time, whatever the manager holds: what must NOT happen
// in that window is asserted afterwards.
void PumpFor(DWORD ms) {
    const ULONGLONG start = GetTickCount64();
    PumpUntil([start, ms] { return GetTickCount64() - start >= ms; }, ms + 1000);
}

bool SamePalette(const rui::ColorPalette& a, const rui::ColorPalette& b) {
    return std::memcmp(&a, &b, sizeof(rui::ColorPalette)) == 0;
}

void Click(HWND hwnd, int x, int y) {
    SendMessageW(hwnd, WM_LBUTTONDOWN, MK_LBUTTON, MAKELPARAM(x, y));
    SendMessageW(hwnd, WM_LBUTTONUP, 0, MAKELPARAM(x, y));
}

}  // namespace

TEST_CASE("Theme toggle crossfade settles on the target palette", "[ui][driven]") {
    DrivenHost host;
    REQUIRE(host.ready);
    // Read the target independently: one instant Toggle shows the palette
    // the crossfade must end on, and two more complete the three-mode cycle.
    const rui::Theme::Mode start = rui::Theme::GetMode();
    rui::Theme::Toggle();
    const rui::ColorPalette target = rui::Theme::Colors();
    const bool targetDark = rui::Theme::IsDark();
    rui::Theme::Toggle();
    rui::Theme::Toggle();
    REQUIRE(rui::Theme::GetMode() == start);

    rui::Theme::AnimateToggle(120.0f);
    CHECK(rui::Theme::IsTransitioning());
    INFO("transition: the theme crossfade");
    REQUIRE(PumpUntil([] { return !rui::Theme::IsTransitioning() && Settled(); }));
    CHECK(rui::Theme::IsDark() == targetDark);
    CHECK(SamePalette(rui::Theme::Colors(), target));

    // Back to the mode the suite started in.
    rui::Theme::Toggle();
    rui::Theme::Toggle();
    CHECK(rui::Theme::GetMode() == start);
}

TEST_CASE("Content view hide and error settle", "[ui][driven]") {
    DrivenHost host;
    REQUIRE(host.ready);
    auto cv = std::make_unique<rui::ContentView>();
    cv->Create(host.hwnd, GetModuleHandleW(nullptr), 101);
    HWND hwnd = cv->Handle();
    REQUIRE(hwnd != nullptr);
    // WS_EX_TRANSPARENT is the overlay's settled idle state: it returns
    // only when a hide or dismiss animation completes.
    auto clickThrough = [hwnd] {
        return (static_cast<ULONG_PTR>(GetWindowLongPtrW(hwnd, GWL_EXSTYLE)) & static_cast<ULONG_PTR>(WS_EX_TRANSPARENT)) != 0;
    };
    CHECK(clickThrough());

    cv->ShowEmpty();
    CHECK(cv->IsEmpty());
    CHECK_FALSE(clickThrough());
    {
        INFO("transition: the empty state fading in");
        REQUIRE(PumpUntil(Settled));
    }
    cv->HideEmpty();
    CHECK(cv->IsEmpty());  // still shown until its fade completes
    {
        INFO("transition: the empty state fading out");
        REQUIRE(PumpUntil([&] { return !cv->IsEmpty() && Settled(); }));
    }
    CHECK(clickThrough());

    // An error slides in, its auto-dismiss timer fires, and it fades out.
    cv->ShowError(L"driven error", 0.05f);
    CHECK_FALSE(clickThrough());
    {
        INFO("transition: the error banner in, its auto-dismiss, and its fade");
        REQUIRE(PumpUntil([&] { return clickThrough() && Settled(); }));
    }

    DestroyWindow(hwnd);
    cv.reset();
}

TEST_CASE("Sidebar collapse widths settle both ways", "[ui][driven]") {
    DrivenHost host;
    REQUIRE(host.ready);
    auto bar = std::make_unique<rui::Sidebar>();
    bar->UpdateDpi(96);
    const int full     = rui::Dpi::Scale(rui::Sidebar::BASE_WIDTH, 96);
    const int iconOnly = rui::Dpi::Scale(rui::Sidebar::BASE_ICON_SIZE + rui::Sidebar::BASE_PADDING_X * 2, 96);
    CHECK(bar->ScaledWidth() == full);

    bar->SetCollapsed(true);
    {
        INFO("transition: the sidebar collapsing");
        REQUIRE(PumpUntil(Settled));
    }
    CHECK(bar->ScaledWidth() == iconOnly);

    bar->SetCollapsed(false);
    {
        INFO("transition: the sidebar expanding");
        REQUIRE(PumpUntil(Settled));
    }
    CHECK(bar->ScaledWidth() == full);
}

TEST_CASE("List view hit-tests scrolls and resizes columns in a real window", "[ui][driven]") {
    DrivenHost host;
    REQUIRE(host.ready);
    rui::ListItem item;  // outlives the view that borrows it
    item.cells = {L"alpha", L"beta"};
    auto lv = std::make_unique<rui::ListView>();
    lv->Create(host.hwnd, GetModuleHandleW(nullptr), 103);
    HWND hwnd = lv->Handle();
    REQUIRE(hwnd != nullptr);
    lv->UpdateDpi(96);
    lv->Resize(0, 0, 400, 300);
    lv->AddColumn(L"Name", 160.0f);
    lv->AddColumn(L"Size", 100.0f);
    lv->SetItemCount(100);
    lv->SetItemProvider([&item](int) -> const rui::ListItem& { return item; });

    const int header = rui::ListView::BASE_HEADER_HEIGHT;
    const int row    = rui::ListView::BASE_ROW_HEIGHT;
    auto rowY = [&](int visibleRow) { return header + visibleRow * row + row / 2; };

    // Hit-testing: a click in the fifth visible row selects index 4.
    Click(hwnd, 50, rowY(4));
    CHECK(lv->SelectedIndex() == 4);

    // Scrolling: one wheel notch down moves three rows, so the same first
    // visible row now holds index 3.
    SendMessageW(hwnd, WM_MOUSEWHEEL, MAKEWPARAM(0, static_cast<WORD>(-WHEEL_DELTA)), MAKELPARAM(0, 0));
    {
        INFO("transition: the wheel scroll");
        REQUIRE(PumpUntil(Settled));
    }
    Click(hwnd, 50, rowY(0));
    CHECK(lv->SelectedIndex() == 3);

    // Column resize: x = 180 sits in the second column until the first
    // column's edge is dragged from 160 to 200, after which a header click
    // at the same x sorts the first column.
    Click(hwnd, 180, header / 2);
    CHECK(lv->SortColumn() == 1);
    SendMessageW(hwnd, WM_LBUTTONDOWN, MK_LBUTTON, MAKELPARAM(160, header / 2));
    SendMessageW(hwnd, WM_MOUSEMOVE, MK_LBUTTON, MAKELPARAM(200, header / 2));
    SendMessageW(hwnd, WM_LBUTTONUP, 0, MAKELPARAM(200, header / 2));
    Click(hwnd, 180, header / 2);
    CHECK(lv->SortColumn() == 0);

    {
        INFO("transition: the list view's selection, sort, and hover animations");
        REQUIRE(PumpUntil(Settled));
    }
    DestroyWindow(hwnd);
    lv.reset();
}

TEST_CASE("A control torn down mid-animation leaves no callback behind", "[ui][driven]") {
    DrivenHost host;
    REQUIRE(host.ready);
    auto& mgr = AnimationManager::Instance();

    // Teardown cancels what the control started: a real sidebar's collapse
    // reaches the host every frame, and after teardown the host hears
    // nothing more while the manager is pumped past the collapse's 250 ms.
    auto bar = std::make_unique<rui::Sidebar>();
    bar->Create(host.hwnd, GetModuleHandleW(nullptr), 102);
    REQUIRE(bar->Handle() != nullptr);
    g_hostSizes = 0;
    bar->SetCollapsed(true);
    {
        INFO("transition: the collapse reaching the host");
        REQUIRE(PumpUntil([] { return g_hostSizes > 0; }));
    }
    REQUIRE(mgr.Count() > 0);
    DestroyWindow(bar->Handle());
    bar.reset();
    CHECK(mgr.Count() == 0);
    const int sizesAtTeardown = g_hostSizes;
    PumpFor(400);
    CHECK(g_hostSizes == sizesAtTeardown);
    CHECK(mgr.Count() == 0);

    // A teardown from inside another animation's callback skips the torn
    // down owner's callbacks in the same frame: the probe never runs.
    int probeRuns = 0;
    int probeOwner = 0;
    mgr.Animate(0.0f, 1.0f, 10.0f, rui::ease::Linear,
                [&](float, const rui::Animation&) { mgr.CancelOwner(&probeOwner); });
    mgr.AnimateFor(&probeOwner, 0.0f, 1.0f, 10.0f, rui::ease::Linear,
                   [&](float, const rui::Animation&) { ++probeRuns; });
    {
        INFO("transition: the owner cancelled mid-frame");
        REQUIRE(PumpUntil(Settled));
    }
    CHECK(probeRuns == 0);

    // An animation that ticked earlier in the frame is still dropped when a
    // later callback cancels its owner: it never runs on a later frame.
    int earlyRuns = 0;
    int earlyOwner = 0;
    mgr.AnimateFor(&earlyOwner, 0.0f, 1.0f, 2000.0f, rui::ease::Linear,
                   [&](float, const rui::Animation&) { ++earlyRuns; });
    mgr.Animate(0.0f, 1.0f, 10.0f, rui::ease::Linear,
                [&](float, const rui::Animation&) { mgr.CancelOwner(&earlyOwner); });
    {
        INFO("transition: an earlier owner cancelled later in the frame");
        REQUIRE(PumpUntil(Settled));
    }
    CHECK(earlyRuns == 1);

    // An owner torn down by its animation's own final update never sees
    // that animation's completion.
    int completeRuns = 0;
    int selfOwner = 0;
    mgr.AnimateFor(&selfOwner, 0.0f, 1.0f, 10.0f, rui::ease::Linear,
                   [&](float v, const rui::Animation&) {
                       if (v >= 1.0f) mgr.CancelOwner(&selfOwner);
                   },
                   [&] { ++completeRuns; });
    {
        INFO("transition: an owner cancelled by its own final update");
        REQUIRE(PumpUntil(Settled));
    }
    CHECK(completeRuns == 0);

    // A callback that cancels an owner and then pumps a nested message loop
    // (a modal dialog, say) cannot let a nested tick undo that cancellation.
    int nestedRuns = 0;
    int nestedOwner = 0;
    mgr.AnimateFor(&nestedOwner, 0.0f, 1.0f, 2000.0f, rui::ease::Linear,
                   [&](float, const rui::Animation&) { ++nestedRuns; });
    bool pumped = false;
    mgr.Animate(0.0f, 1.0f, 10.0f, rui::ease::Linear, [&](float, const rui::Animation&) {
        mgr.CancelOwner(&nestedOwner);
        if (!pumped) {
            pumped = true;
            // A pending animation gives the nested tick something to run,
            // as a real callback's follow-up animation would.
            mgr.Animate(0.0f, 1.0f, 10.0f, rui::ease::Linear, nullptr);
            PumpFor(60);
        }
    });
    {
        INFO("transition: a cancellation followed by a nested message loop");
        REQUIRE(PumpUntil(Settled));
    }
    CHECK(pumped);
    CHECK(nestedRuns == 1);

    // A callback that starts a new animation mid-frame is safe, and the new
    // one runs to completion after the frame.
    bool followUpDone = false;
    mgr.Animate(0.0f, 1.0f, 10.0f, rui::ease::Linear, nullptr, [&] {
        mgr.Animate(0.0f, 1.0f, 10.0f, rui::ease::Linear, nullptr, [&] { followUpDone = true; });
    });
    {
        INFO("transition: an animation started from a completion callback");
        REQUIRE(PumpUntil(Settled));
    }
    CHECK(followUpDone);
}
