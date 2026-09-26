// The fence and the focus guard, pinned. D00 T02 §10.

#include <catch2/catch_test_macros.hpp>

#include "fence.h"
#include "focus_guard.h"
#include "ui_host.h"

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

namespace {

// A stand-in handle: the rules compare handles, never dereference them.
int g_fakeWindow = 0;
int g_fakeCapture = 0;

focusguard::WindowRecord Window(const wchar_t* cls, bool visible, UINT dpi, const wchar_t* monitor = L"\\\\.\\DISPLAY1") {
    focusguard::WindowRecord r;
    r.hwnd    = reinterpret_cast<HWND>(&g_fakeWindow);
    r.cls     = cls;
    r.visible = visible;
    r.dpi     = dpi;
    r.monitor = monitor;
    return r;
}

bool Mentions(const std::vector<std::string>& lines, const std::string& what) {
    return std::any_of(lines.begin(), lines.end(), [&](const std::string& l) { return l.find(what) != std::string::npos; });
}

}  // namespace

TEST_CASE("The quiet-hours window opens at 02:00 and closes at 06:50", "[fence]") {
    CHECK_FALSE(fence::InQuietHours(0));
    CHECK_FALSE(fence::InQuietHours(119));   // 01:59
    CHECK(fence::InQuietHours(120));         // 02:00
    CHECK(fence::InQuietHours(409));         // 06:49
    CHECK_FALSE(fence::InQuietHours(410));   // 06:50
    CHECK_FALSE(fence::InQuietHours(19 * 60));
    CHECK_FALSE(fence::InQuietHours(1439));  // 23:59
}

TEST_CASE("The fence decides from its overrides and the clock", "[fence]") {
    constexpr unsigned long away = 600000;  // the operator gone ten minutes
    // Outside the window with no override: skip, naming the window and the
    // way to run it on demand.
    const fence::Verdict day = fence::Decide("", "", 19 * 60 + 5, away);
    CHECK(day.mode == fence::Mode::Skip);
    CHECK(day.reason.find("02:00-06:50") != std::string::npos);
    CHECK(day.reason.find("now 19:05") != std::string::npos);
    CHECK(day.reason.find("RESOLUTE_HEADFUL=visible") != std::string::npos);
    // Inside the window: collect, stopping on input.
    CHECK(fence::Decide("", "", 3 * 60, away).mode == fence::Mode::Collect);
    // The night runner's idle signal: collect by day.
    CHECK(fence::Decide("", "1", 14 * 60, away).mode == fence::Mode::Collect);
    CHECK(fence::Decide("", "yes", 14 * 60, away).mode == fence::Mode::Skip);
    // The operator's visible run wins over everything, and only "visible" asks.
    CHECK(fence::Decide("visible", "1", 3 * 60, 0).mode == fence::Mode::Visible);
    CHECK(fence::Decide("1", "", 14 * 60, away).mode == fence::Mode::Skip);
    // A collecting case needs the operator away at its own start, so a
    // return mid-run stands every later case down (panel round 1 of the
    // D00 T02 §10 review): 119 s is too soon, 120 s is enough.
    const fence::Verdict back = fence::Decide("", "1", 14 * 60, 119999);
    CHECK(back.mode == fence::Mode::Skip);
    CHECK(back.reason.find("the operator is active (last input 119 s ago") != std::string::npos);
    CHECK(back.reason.find("re-queued") != std::string::npos);
    CHECK(fence::Decide("", "1", 14 * 60, 120000).mode == fence::Mode::Collect);
    CHECK(fence::Decide("", "", 3 * 60, 5000).mode == fence::Mode::Skip);
}

TEST_CASE("A visible run never stops on input and a skipped case never counts as headful", "[fence]") {
    fence::Open(fence::Mode::Visible);
    CHECK(fence::Headful());
    CHECK_FALSE(fence::InputResumed());
    fence::Close();
    CHECK_FALSE(fence::Headful());
    fence::Open(fence::Mode::Skip);
    CHECK_FALSE(fence::Headful());
    fence::Close();
}

TEST_CASE("The census sees the windows the suite owns", "[fence]") {
    // A census that never sees a window would pass every case: this one
    // must find a hidden host while it lives and lose it once destroyed.
    HWND seen = nullptr;
    {
        uitest::HiddenHost host(L"ResoluteCensusProbe");
        REQUIRE(host.ready);
        seen = host.hwnd;
        const auto census = focusguard::Census();
        const auto it = std::find_if(census.begin(), census.end(),
                                     [&](const focusguard::WindowRecord& r) { return r.hwnd == host.hwnd; });
        REQUIRE(it != census.end());
        CHECK(it->cls == L"ResoluteCensusProbe");
        CHECK_FALSE(it->visible);
        CHECK(it->pid == GetCurrentProcessId());
        CHECK_FALSE(it->monitor.empty());
        CHECK(it->dpi >= 96);
    }
    const auto after = focusguard::Census();
    CHECK(std::none_of(after.begin(), after.end(), [&](const focusguard::WindowRecord& r) { return r.hwnd == seen; }));
}

TEST_CASE("The guard's rules name each violation", "[fence]") {
    using focusguard::Event;
    const std::vector<HWND> none;
    const std::vector<Event> quiet;
    const std::vector<focusguard::WindowRecord> empty;

    SECTION("a clean default case") {
        CHECK(focusguard::Check("t", false, "", none, quiet, empty, nullptr).empty());
    }
    SECTION("the default tier: foreground, shown, visible, left behind, capture") {
        Event fg;
        fg.kind   = Event::Kind::Foreground;
        fg.window = Window(L"Host", false, 144);
        Event shown;
        shown.kind   = Event::Kind::Shown;
        shown.window = Window(L"Popup", true, 144);
        const auto lines = focusguard::Check("case A", false, "", none, {fg, shown}, {Window(L"Stray", true, 144)},
                                             reinterpret_cast<HWND>(&g_fakeCapture));
        CHECK(Mentions(lines, "FOCUS-VIOLATION case A: took the foreground"));
        CHECK(Mentions(lines, "showed a window"));
        CHECK(Mentions(lines, "visible at the case's end"));
        CHECK(Mentions(lines, "left behind"));
        CHECK(Mentions(lines, "mouse capture is still held"));
    }
    SECTION("windows the system keeps, or that existed before the case, are not left behind") {
        const auto rec = Window(L"OleMainThreadWndClass", false, 96);
        CHECK(focusguard::Check("t", false, "", none, quiet, {rec}, nullptr).empty());
        const auto own = Window(L"Mine", false, 96);
        CHECK(focusguard::Check("t", false, "", {own.hwnd}, quiet, {own}, nullptr).empty());
    }
    SECTION("the headful tier checks placement against the declared intent") {
        Event shown;
        shown.kind   = Event::Kind::Shown;
        shown.window = Window(L"ResoluteMain", true, 96);
        CHECK(focusguard::Check("t", true, "place:dpi96", none, {shown}, empty, nullptr).empty());
        const auto misplaced = focusguard::Check("case B", true, "place:dpi144", none, {shown}, empty, nullptr);
        CHECK(Mentions(misplaced, "FOCUS-VIOLATION case B: a window is not where [place:dpi144] declares"));
        CHECK(Mentions(focusguard::Check("t", true, "", none, quiet, empty, nullptr), "declares no [place:...] intent"));
        // A headful case may take the foreground: that is its point.
        Event fg;
        fg.kind   = Event::Kind::Foreground;
        fg.window = Window(L"ResoluteMain", true, 96);
        CHECK(focusguard::Check("t", true, "place:dpi96", none, {fg}, empty, nullptr).empty());
    }
}

TEST_CASE("A window shown and gone at once is still seen", "[fence]") {
    // The guard judges a show when it happens: a window shown, hidden, and
    // destroyed before anything could look at it afterwards is recorded all
    // the same (the independent review of D00 T02 §10). The window is 1 x 1
    // and off every monitor, so nothing reaches the operator's screen, and
    // the case drains its own events so the show it made on purpose is not
    // held against it.
    focusguard::Drain();
    HWND flash = CreateWindowExW(WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW, L"STATIC", L"transient", WS_POPUP, -32000,
                                 -32000, 1, 1, nullptr, nullptr, GetModuleHandleW(nullptr), nullptr);
    REQUIRE(flash != nullptr);
    ShowWindow(flash, SW_SHOWNOACTIVATE);
    ShowWindow(flash, SW_HIDE);
    DestroyWindow(flash);
    const auto events = focusguard::Drain();
    CHECK(std::any_of(events.begin(), events.end(), [&](const focusguard::Event& e) {
        return e.kind == focusguard::Event::Kind::Shown && e.window.hwnd == flash && e.window.cls == L"Static";
    }));
}
