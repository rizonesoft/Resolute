// Driven coverage the D00 T02 §7 cases left. D00 T02 §10.
//
// Every case here is in the background-safe tier: its windows are hidden
// and disabled (tests/ui_host.h), input arrives through SendMessageW, and
// the focus guard checks each case's census. What needs the desktop (a
// modal popup, the toolbar's overflow menu) is fenced in
// ui_headful_test.cpp instead.

#include <catch2/catch_test_macros.hpp>

#include <resolute/animation.h>
#include <resolute/controls/contentview.h>
#include <resolute/controls/listview.h>
#include <resolute/controls/sidebar.h>
#include <resolute/controls/statusbar.h>
#include <resolute/controls/toolbar.h>
#include <resolute/dpi.h>
#include <resolute/theme.h>

#include "ui_host.h"

#include <algorithm>
#include <cstring>
#include <functional>
#include <memory>
#include <set>
#include <vector>

namespace {

using rui::AnimationManager;
using uitest::Click;
using uitest::PumpFor;
using uitest::PumpUntil;
using uitest::Settled;

// Commands the host received from its controls, in order.
std::vector<WORD> g_commands;

LRESULT CALLBACK CommandHost(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    if (msg == WM_COMMAND) g_commands.push_back(LOWORD(wp));
    return DefWindowProcW(hwnd, msg, wp, lp);
}

struct Host : uitest::HiddenHost {
    Host() : HiddenHost(L"ResoluteCoverageHost", CommandHost, true) { g_commands.clear(); }
};

// Every scale the launcher supports a monitor at: 100, 125, 150, and 200 percent.
constexpr int kDpis[] = {96, 120, 144, 192};

int S(int v, int dpi) { return rui::Dpi::Scale(v, dpi); }

bool ClickThrough(HWND hwnd) {
    return (static_cast<ULONG_PTR>(GetWindowLongPtrW(hwnd, GWL_EXSTYLE)) &
            static_cast<ULONG_PTR>(WS_EX_TRANSPARENT)) != 0;
}

// Moves the pointer across a control until one of its hover animations
// starts: the teardown cases need a control with animations pending.
bool HoverUntilAnimating(HWND hwnd, int w, int y) {
    for (int x = 2; x < w; x += 6) {
        SendMessageW(hwnd, WM_MOUSEMOVE, 0, MAKELPARAM(x, y));
        if (AnimationManager::Instance().Count() > 0) return true;
    }
    return false;
}

}  // namespace

TEST_CASE("Every animated control torn down mid-animation cancels its animations", "[ui][driven]") {
    // The Sidebar case in ui_driven_test.cpp proves it for one control; each
    // of the other four is torn down here with its animations pending, and
    // the manager must hold none of them afterwards, pumped past their length
    // (plan review PR4 of the D00 T02 §7 review).
    Host host;
    REQUIRE(host.ready);
    auto& mgr = AnimationManager::Instance();
    HINSTANCE inst = GetModuleHandleW(nullptr);

    struct Case {
        const char*                        name;
        std::function<HWND()>              start;  // creates, animates, returns the window
        std::function<void()>              destroy;
    };
    auto cv = std::make_unique<rui::ContentView>();
    auto lv = std::make_unique<rui::ListView>();
    auto sb = std::make_unique<rui::StatusBar>();
    auto tb = std::make_unique<rui::Toolbar>();
    rui::ListItem item;
    item.cells = {L"alpha"};
    const Case cases[] = {
        {"ContentView",
         [&] {
             cv->Create(host.hwnd, inst, 301);
             cv->ShowEmpty();
             return cv->Handle();
         },
         [&] {
             DestroyWindow(cv->Handle());
             cv.reset();
         }},
        {"ListView",
         [&] {
             lv->Create(host.hwnd, inst, 302);
             lv->UpdateDpi(96);
             lv->Resize(0, 0, 400, 300);
             lv->AddColumn(L"Name", 160.0f);
             lv->SetItemCount(20);
             lv->SetItemProvider([&item](int) -> const rui::ListItem& { return item; });
             Click(lv->Handle(), 50, rui::ListView::BASE_HEADER_HEIGHT + rui::ListView::BASE_ROW_HEIGHT * 2);
             return lv->Handle();
         },
         [&] {
             DestroyWindow(lv->Handle());
             lv.reset();
         }},
        {"StatusBar",
         [&] {
             sb->Create(host.hwnd, inst, 303);
             sb->UpdateDpi(96);
             sb->Resize(0, 0, 800, sb->ScaledHeight());
             sb->ShowNotification(L"pending", 0, 5.0f);
             return sb->Handle();
         },
         [&] {
             DestroyWindow(sb->Handle());
             sb.reset();
         }},
        {"Toolbar",
         [&] {
             tb->Create(host.hwnd, inst, 304);
             tb->UpdateDpi(96);
             tb->Resize(0, 0, 900, tb->ScaledHeight());
             HoverUntilAnimating(tb->Handle(), 900, tb->ScaledHeight() / 2);
             return tb->Handle();
         },
         [&] {
             DestroyWindow(tb->Handle());
             tb.reset();
         }},
    };
    for (const Case& c : cases) {
        CAPTURE(c.name);
        mgr.CancelAll();
        REQUIRE(c.start() != nullptr);
        REQUIRE(mgr.Count() > 0);
        c.destroy();
        CHECK(mgr.Count() == 0);
        PumpFor(400);
        CHECK(mgr.Count() == 0);
    }
}

TEST_CASE("Rapid reversals settle on the last request", "[ui][driven]") {
    // A request made while the previous one still animates wins, and the
    // earlier one's completion never overrides it (plan review PR6 of the
    // D00 T02 §7 review).
    Host host;
    REQUIRE(host.ready);

    SECTION("theme toggled twice mid-crossfade") {
        const rui::Theme::Mode start = rui::Theme::GetMode();
        rui::Theme::Toggle();
        rui::Theme::Toggle();
        const rui::ColorPalette target = rui::Theme::Colors();
        const rui::Theme::Mode  targetMode = rui::Theme::GetMode();
        rui::Theme::Toggle();  // back to start: three toggles cycle the modes
        REQUIRE(rui::Theme::GetMode() == start);

        rui::Theme::AnimateToggle(200.0f);
        PumpFor(40);
        rui::Theme::AnimateToggle(200.0f);
        REQUIRE(PumpUntil([] { return !rui::Theme::IsTransitioning() && Settled(); }));
        CHECK(rui::Theme::GetMode() == targetMode);
        CHECK(std::memcmp(&rui::Theme::Colors(), &target, sizeof(target)) == 0);
        rui::Theme::Toggle();
        CHECK(rui::Theme::GetMode() == start);
    }

    SECTION("sidebar collapse reversed three times mid-animation") {
        auto bar = std::make_unique<rui::Sidebar>();
        bar->Create(host.hwnd, GetModuleHandleW(nullptr), 305);
        bar->UpdateDpi(96);
        const int full = rui::Dpi::Scale(rui::Sidebar::BASE_WIDTH, 96);
        for (int i = 0; i < 3; ++i) {
            bar->SetCollapsed(true);
            PumpFor(40);
            bar->SetCollapsed(false);
            PumpFor(20);
        }
        REQUIRE(PumpUntil(Settled));
        CHECK_FALSE(bar->IsCollapsed());
        CHECK(bar->ScaledWidth() == full);
        DestroyWindow(bar->Handle());
    }

    SECTION("an error replaced before its auto-dismiss") {
        auto cv = std::make_unique<rui::ContentView>();
        cv->Create(host.hwnd, GetModuleHandleW(nullptr), 306);
        // The second arrives while the first still slides in, and late
        // enough that the first's 50 ms dismissal, armed when its slide-in
        // completes, would fire before the second's completes: it must not
        // take the second down.
        cv->ShowError(L"first", 0.05f);
        PumpFor(150);
        cv->ShowError(L"second", 10.0f);
        PumpFor(900);
        CHECK_FALSE(ClickThrough(cv->Handle()));
        cv->DismissError();
        REQUIRE(PumpUntil([&] { return ClickThrough(cv->Handle()) && Settled(); }));
        DestroyWindow(cv->Handle());
    }
}

TEST_CASE("Hit targets and resize boundaries hold at every DPI scale", "[ui][driven]") {
    // The D00 T02 §7 case clicks at 96 only; the same targets are derived
    // from the DPI here, at each supported scale (plan review PR10 of the
    // D00 T02 §7 review).
    Host host;
    REQUIRE(host.ready);
    rui::ListItem item;
    item.cells = {L"alpha", L"beta"};
    for (int dpi : kDpis) {
        CAPTURE(dpi);
        {
            auto lv = std::make_unique<rui::ListView>();
            lv->Create(host.hwnd, GetModuleHandleW(nullptr), 307);
            HWND hwnd = lv->Handle();
            lv->UpdateDpi(dpi);
            lv->Resize(0, 0, S(400, dpi), S(300, dpi));
            lv->AddColumn(L"Name", 160.0f);
            lv->AddColumn(L"Size", 100.0f);
            lv->SetItemCount(100);
            lv->SetItemProvider([&item](int) -> const rui::ListItem& { return item; });
            const float header = rui::Dpi::ScaleF(static_cast<float>(rui::ListView::BASE_HEADER_HEIGHT), dpi);
            const float row    = rui::Dpi::ScaleF(static_cast<float>(rui::ListView::BASE_ROW_HEIGHT), dpi);
            auto rowY = [&](int r) { return static_cast<int>(header + row * static_cast<float>(r) + row / 2.0f); };

            Click(hwnd, S(50, dpi), rowY(4));
            CHECK(lv->SelectedIndex() == 4);
            Click(hwnd, S(50, dpi), rowY(7));
            CHECK(lv->SelectedIndex() == 7);

            // The first column's edge sits at 160 DIPs: a header click at
            // 180 DIPs sorts the second column until the edge is dragged to
            // 200 DIPs, after which the same click sorts the first.
            const int hy = static_cast<int>(header / 2.0f);
            Click(hwnd, S(180, dpi), hy);
            CHECK(lv->SortColumn() == 1);
            SendMessageW(hwnd, WM_LBUTTONDOWN, MK_LBUTTON, MAKELPARAM(S(160, dpi), hy));
            SendMessageW(hwnd, WM_MOUSEMOVE, MK_LBUTTON, MAKELPARAM(S(200, dpi), hy));
            SendMessageW(hwnd, WM_LBUTTONUP, 0, MAKELPARAM(S(200, dpi), hy));
            Click(hwnd, S(180, dpi), hy);
            CHECK(lv->SortColumn() == 0);
            REQUIRE(PumpUntil(Settled));
            DestroyWindow(hwnd);
        }
        {
            auto bar = std::make_unique<rui::Sidebar>();
            bar->Create(host.hwnd, GetModuleHandleW(nullptr), 308);
            bar->UpdateDpi(dpi);
            bar->Resize(0, 0, bar->ScaledWidth(), S(600, dpi));
            // Items start 44 DIPs down and are BASE_ITEM_HEIGHT DIPs tall.
            for (int k : {1, 4, 0}) {
                CAPTURE(k);
                const float y = rui::Dpi::ScaleF(44.0f, dpi) +
                                rui::Dpi::ScaleF(static_cast<float>(rui::Sidebar::BASE_ITEM_HEIGHT), dpi) *
                                    (static_cast<float>(k) + 0.5f);
                Click(bar->Handle(), bar->ScaledWidth() / 2, static_cast<int>(y));
                CHECK(bar->Selected() == k);
            }
            REQUIRE(PumpUntil(Settled));
            DestroyWindow(bar->Handle());
        }
    }
}

TEST_CASE("Toolbar overflow hides commands in order and the keyboard still reaches them", "[ui][driven]") {
    // The overflow's observable effects without its modal menu, which is
    // fenced: as the toolbar narrows the overflow menu offers a growing set
    // of commands, none at full width; and the keyboard path sends a command
    // to the parent (plan review PR3 of the D00 T02 §7 review).
    Host host;
    REQUIRE(host.ready);
    auto tb = std::make_unique<rui::Toolbar>();
    tb->Create(host.hwnd, GetModuleHandleW(nullptr), 309);
    tb->UpdateDpi(96);
    HWND hwnd = tb->Handle();
    const int h = tb->ScaledHeight();

    auto commands = [&](int w) {
        tb->Resize(0, 0, w, h);
        UpdateWindow(hwnd);
        SendMessageW(hwnd, WM_PAINT, 0, 0);  // layout runs in paint
        std::set<UINT> ids;
        if (HMENU menu = tb->BuildOverflowMenu()) {
            for (int i = 0; i < GetMenuItemCount(menu); ++i) {
                if (HMENU sub = GetSubMenu(menu, i)) {
                    for (int k = 0; k < GetMenuItemCount(sub); ++k) ids.insert(GetMenuItemID(sub, k));
                } else if (GetMenuItemID(menu, i) != 0) {
                    ids.insert(GetMenuItemID(menu, i));
                }
            }
            DestroyMenu(menu);
        }
        return ids;
    };

    CHECK(commands(1600).empty());
    std::set<UINT> previous;
    for (int w = 1600; w >= 140; w -= 60) {
        CAPTURE(w);
        const std::set<UINT> now = commands(w);
        for (UINT id : previous) CHECK(now.count(id) == 1);  // narrower never un-hides one
        previous = now;
    }
    CHECK(previous.count(rui::IDC_TB_REFRESH) == 1);

    // The keyboard path: focus lands on the first item, and moving right to
    // Refresh and pressing Enter sends it to the parent.
    tb->Resize(0, 0, 1600, h);
    SendMessageW(hwnd, WM_SETFOCUS, 0, 0);
    g_commands.clear();
    for (int i = 0; i < 12 && std::find(g_commands.begin(), g_commands.end(), rui::IDC_TB_REFRESH) == g_commands.end();
         ++i) {
        SendMessageW(hwnd, WM_KEYDOWN, VK_RIGHT, 0);
        SendMessageW(hwnd, WM_KEYDOWN, VK_RETURN, 0);
    }
    CHECK(std::find(g_commands.begin(), g_commands.end(), rui::IDC_TB_REFRESH) != g_commands.end());
    REQUIRE(PumpUntil(Settled));
    DestroyWindow(hwnd);
}
