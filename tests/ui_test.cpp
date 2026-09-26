// Tests for the inherited UI library (rui::). D00 T02 §5.
//
// The library arrived as a unit, and every tool renders through it, so its
// seams are covered where they are observable without a window: theme tokens
// and the dark/light cycle, easing endpoints and the animation tick, icon
// resolution including the unknown-name path, and the HWND-free state of the
// controls (selection, sort, badges, collapse, empty states, scaled sizes).
// Anything that needs pixels, a message loop, or a D2D device stays out;
// the section records that surface as uncovered with its reason.

#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_floating_point.hpp>

#include <cstring>
#include <cwchar>
#include <string>

#include <windows.h>

#include <resolute/animation.h>
#include <resolute/controls/contentview.h>
#include <resolute/controls/listview.h>
#include <resolute/controls/sidebar.h>
#include <resolute/controls/statusbar.h>
#include <resolute/controls/toolbar.h>
#include <resolute/dpi.h>
#include <resolute/icons.h>
#include <resolute/theme.h>

using Catch::Matchers::WithinAbs;
using rui::Theme;

// ── Theme ─────────────────────────────────────────────────────────────

// The cycle is the whole mode contract: Dark -> Light -> System -> Dark.
// Driven from whatever mode the statics hold (a three-toggle loop always
// returns), then walked explicitly from System for the exact sequence.
TEST_CASE("Theme toggle cycles Dark Light System", "[ui][theme]") {
    Theme::Mode start = Theme::GetMode();
    Theme::Toggle();
    Theme::Toggle();
    Theme::Toggle();
    CHECK(Theme::GetMode() == start);

    while (Theme::GetMode() != Theme::Mode::System)
        Theme::Toggle();
    Theme::Toggle();
    CHECK(Theme::GetMode() == Theme::Mode::Dark);
    CHECK(Theme::IsDark());
    Theme::Toggle();
    CHECK(Theme::GetMode() == Theme::Mode::Light);
    CHECK_FALSE(Theme::IsDark());
    Theme::Toggle();
    CHECK(Theme::GetMode() == Theme::Mode::System);
}

// Colors() follows the dark flag while no transition runs. Background and
// text are pinned because nothing ever rewrites them (ReadSystemAccent only
// touches the accent family), so these values are the contract, not a copy.
TEST_CASE("Theme colors follow the dark flag", "[ui][theme]") {
    Theme::SetDark(true);
    CHECK_FALSE(Theme::IsTransitioning());
    CHECK(Theme::Colors().background == RGB(30, 30, 30));
    CHECK(Theme::Colors().text == RGB(230, 230, 230));
    Theme::SetDark(false);
    CHECK(Theme::Colors().background == RGB(243, 243, 243));
    CHECK(Theme::Colors().text == RGB(25, 25, 25));
    Theme::SetDark(true);
}

TEST_CASE("Scrim opacity differs by mode", "[ui][theme]") {
    Theme::SetDark(true);
    CHECK_THAT(Theme::ScrimOpacity(), WithinAbs(0.5f, 0.0001f));
    Theme::SetDark(false);
    CHECK_THAT(Theme::ScrimOpacity(), WithinAbs(0.3f, 0.0001f));
    Theme::SetDark(true);
}

// Icon colors pack the live text tokens as 0xRRGGBB. The dark values are
// pinned end to end (token plus packing); the accent test restores the
// palettes it rewrites, so the compiled default stands here under any order.
TEST_CASE("Icon colors pack the text tokens", "[ui][theme]") {
    Theme::SetDark(true);
    CHECK(Theme::IconColor() == 0xE6E6E6u);
    CHECK(Theme::SecondaryIconColor() == 0xA0A0A0u);
    CHECK(Theme::AccentIconColor() == 0x0078D4u);
}

// The palette field count strides the bulk crossfade: every COLORREF in the
// struct lerps, so the count IS the struct shape. Adding a field must move
// this number, which is the point of pinning it.
TEST_CASE("Palette field count matches the struct", "[ui][theme]") {
    CHECK(rui::kPaletteFieldCount == 23);
    CHECK(rui::kPaletteFieldCount * static_cast<int>(sizeof(COLORREF)) == static_cast<int>(sizeof(rui::ColorPalette)));
}

namespace {
// ReadSystemAccent rewrites the shared palettes; restore them on unwind so a
// live accent never leaks into the pinned defaults, even on a REQUIRE failure.
struct RestorePalettes {
    rui::ColorPalette dark = rui::DarkPalette;
    rui::ColorPalette light = rui::LightPalette;
    ~RestorePalettes() {
        rui::DarkPalette = dark;
        rui::LightPalette = light;
    }
};
}  // namespace

TEST_CASE("System accent derivation wires the registry value", "[ui][theme]") {
    // The assertion pins the wiring (registry value lands on both palettes'
    // accent, or the compiled default when the key is absent); the lightness
    // math inside stays interior. The guard restores the compiled defaults on
    // unwind, and the trailing checks prove the restore ran.
    rui::ColorPalette darkBefore = rui::DarkPalette;
    rui::ColorPalette lightBefore = rui::LightPalette;
    {
        RestorePalettes saved;
        DWORD abgr = 0;
        DWORD size = sizeof(abgr);
        LSTATUS status = RegGetValueW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\DWM",
                                      L"AccentColor", RRF_RT_DWORD, nullptr, &abgr, &size);
        COLORREF expected = (status == ERROR_SUCCESS) ? (abgr & 0x00FFFFFFu) : RGB(0, 120, 212);
        Theme::ReadSystemAccent();
        CHECK(rui::DarkPalette.accent == expected);
        CHECK(rui::LightPalette.accent == expected);
        CHECK(rui::DarkPalette.surfaceActive == expected);
    }
    CHECK(rui::DarkPalette.accent == darkBefore.accent);
    CHECK(rui::LightPalette.accent == lightBefore.accent);
}

TEST_CASE("IsHighContrast agrees with the system call", "[ui][theme]") {
    HIGHCONTRASTW hc{};
    hc.cbSize = sizeof(hc);
    SystemParametersInfoW(SPI_GETHIGHCONTRAST, sizeof(hc), &hc, 0);
    CHECK(Theme::IsHighContrast() == ((hc.dwFlags & HCF_HIGHCONTRASTON) != 0));
}

// IsDarkMode reads the live OS setting. The test re-reads the same value
// key independently: it pins the path (HKCU Personalize AppsUseLightTheme,
// 0 means dark), not the user's current choice.
TEST_CASE("IsDarkMode agrees with the registry value", "[ui][theme]") {
    DWORD value = 1;
    DWORD size = sizeof(value);
    RegGetValueW(HKEY_CURRENT_USER,
                 L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
                 L"AppsUseLightTheme", RRF_RT_DWORD, nullptr, &value, &size);
    CHECK(Theme::IsDarkMode() == (value == 0));
}

// AnimateToggle is deliberately uncovered: it opens a transition that only the
// manager's timer can complete, so running it would poison Colors() for every
// later case in the process under any execution order. The blend math itself
// is LerpColor, covered at both endpoints and the midpoint below.

// ── Animation ─────────────────────────────────────────────────────────

// Every easing starts at 0 and lands on 1, except Spring, which overshoots
// and settles: the comment on the easing namespace promises exactly this.
TEST_CASE("Easings start at 0 and land on 1", "[ui][anim]") {
    using rui::ease::InCubic;
    using rui::ease::InOutCubic;
    using rui::ease::InOutQuad;
    using rui::ease::InOutQuart;
    using rui::ease::InQuad;
    using rui::ease::InQuart;
    using rui::ease::Linear;
    using rui::ease::OutBack;
    using rui::ease::OutCubic;
    using rui::ease::OutElastic;
    using rui::ease::OutQuad;
    using rui::ease::OutQuart;
    for (auto fn : {Linear, InQuad, OutQuad, InOutQuad, InCubic, OutCubic, InOutCubic,
                    InQuart, OutQuart, InOutQuart, OutBack, OutElastic}) {
        CHECK_THAT(fn(0.0f), WithinAbs(0.0f, 0.00001f));
        CHECK_THAT(fn(1.0f), WithinAbs(1.0f, 0.00001f));
    }
}

TEST_CASE("Spring leaves 0 and settles near 1", "[ui][anim]") {
    CHECK_THAT(rui::ease::Spring(0.0f), WithinAbs(0.0f, 0.00001f));
    CHECK_THAT(rui::ease::Spring(1.0f), WithinAbs(1.0f, 0.01f));
}

TEST_CASE("Known easing values pin the curves", "[ui][anim]") {
    CHECK_THAT(rui::ease::Linear(0.7f), WithinAbs(0.7f, 0.00001f));
    CHECK_THAT(rui::ease::InQuad(0.5f), WithinAbs(0.25f, 0.00001f));
    CHECK_THAT(rui::ease::OutQuad(0.5f), WithinAbs(0.75f, 0.00001f));
    // InOutQuad is symmetric about the midpoint.
    CHECK_THAT(rui::ease::InOutQuad(0.25f) + rui::ease::InOutQuad(0.75f), WithinAbs(1.0f, 0.00001f));
    // OutBack overshoots: the header promises values past 1 mid-flight.
    CHECK(rui::ease::OutBack(0.7f) > 1.0f);
}

TEST_CASE("Every easing pins its midpoint", "[ui][anim]") {
    // Exact powers of two where the curve is polynomial; looser where it is
    // transcendental (the value below is the computed constant, verified by
    // running, not derived by hand). InQuad and OutQuad midpoints are pinned
    // in the Known test; with the three below every easing has one.
    CHECK_THAT(rui::ease::Linear(0.5f), WithinAbs(0.5f, 0.00001f));
    CHECK_THAT(rui::ease::InOutQuad(0.5f), WithinAbs(0.5f, 0.00001f));
    CHECK_THAT(rui::ease::OutBack(0.5f), WithinAbs(1.0876975f, 0.00001f));
    CHECK_THAT(rui::ease::InCubic(0.5f), WithinAbs(0.125f, 0.00001f));
    CHECK_THAT(rui::ease::OutCubic(0.5f), WithinAbs(0.875f, 0.00001f));
    CHECK_THAT(rui::ease::InOutCubic(0.5f), WithinAbs(0.5f, 0.00001f));
    CHECK_THAT(rui::ease::InQuart(0.5f), WithinAbs(0.0625f, 0.00001f));
    CHECK_THAT(rui::ease::OutQuart(0.5f), WithinAbs(0.9375f, 0.00001f));
    CHECK_THAT(rui::ease::InOutQuart(0.5f), WithinAbs(0.5f, 0.00001f));
    CHECK_THAT(rui::ease::OutElastic(0.5f), WithinAbs(1.015625f, 0.0001f));
    CHECK_THAT(rui::ease::Spring(0.5f), WithinAbs(0.96245f, 0.001f));
}

TEST_CASE("Animation ticks to finished exactly once", "[ui][anim]") {
    rui::Animation anim;
    anim.from = 0.0f;
    anim.to = 10.0f;
    anim.duration = 200.0f;
    int updates = 0;
    int completes = 0;
    anim.onUpdate = [&](float, const rui::Animation&) { ++updates; };
    anim.onComplete = [&]() { ++completes; };

    CHECK(anim.Tick(100.0f));  // half time: still active
    CHECK_FALSE(anim.finished);
    CHECK_THAT(anim.progress, WithinAbs(0.5f, 0.00001f));
    CHECK_FALSE(anim.Tick(100.0f));  // full time: done, returns false
    CHECK(anim.finished);
    CHECK_THAT(anim.current, WithinAbs(10.0f, 0.0001f));
    CHECK_FALSE(anim.Tick(100.0f));  // a finished animation stays finished
    CHECK(updates == 2);
    CHECK(completes == 1);
}

TEST_CASE("Animation honors its delay before starting", "[ui][anim]") {
    rui::Animation anim;
    anim.duration = 100.0f;
    anim.delay = 100.0f;
    CHECK(anim.Tick(50.0f));
    CHECK_FALSE(anim.started);
    CHECK(anim.Tick(60.0f));
    CHECK(anim.started);
}

TEST_CASE("Animation defaults to OutCubic", "[ui][anim]") {
    rui::Animation anim;
    CHECK(anim.easing == &rui::ease::OutCubic);
}

// The manager is the shared clock: subscribers register, Count reports them.
// Add/Cancel/CancelAll touch only the vector, so the count is observable
// without starting the timer (which needs a window and a message loop).
TEST_CASE("Animation manager counts its subscribers", "[ui][anim]") {
    auto& mgr = rui::AnimationManager::Instance();
    mgr.CancelAll();
    CHECK(mgr.Count() == 0);
    CHECK_FALSE(mgr.IsAnimating());
    uint32_t first =
        mgr.Animate(0.0f, 1.0f, 200.0f, rui::ease::Linear, [](float, const rui::Animation&) {});
    mgr.Animate(0.0f, 1.0f, 200.0f, rui::ease::Linear, [](float, const rui::Animation&) {});
    CHECK(mgr.Count() == 2);
    CHECK(mgr.IsAnimating());
    mgr.Cancel(first);  // single-cancel routes by id: one left, still animating
    CHECK(mgr.Count() == 1);
    CHECK(mgr.IsAnimating());
    mgr.CancelAll();
    CHECK(mgr.Count() == 0);
    CHECK_FALSE(mgr.IsAnimating());
}

TEST_CASE("Lerp hits both ends and the midpoint", "[ui][anim]") {
    CHECK_THAT(rui::Lerp(2.0f, 8.0f, 0.0f), WithinAbs(2.0f, 0.00001f));
    CHECK_THAT(rui::Lerp(2.0f, 8.0f, 1.0f), WithinAbs(8.0f, 0.00001f));
    CHECK_THAT(rui::Lerp(2.0f, 8.0f, 0.5f), WithinAbs(5.0f, 0.00001f));
    CHECK(rui::LerpColor(RGB(0, 0, 0), RGB(255, 255, 255), 0.0f) == RGB(0, 0, 0));
    CHECK(rui::LerpColor(RGB(0, 0, 0), RGB(255, 255, 255), 1.0f) == RGB(255, 255, 255));
    // Midpoint truncates toward zero on the BYTE cast: 127, not 128.
    CHECK(rui::LerpColor(RGB(0, 0, 0), RGB(255, 255, 255), 0.5f) == RGB(127, 127, 127));
}

// ── Icons ─────────────────────────────────────────────────────────────

// The pre-Load fail-closed guards are deliberately uncovered: Load() is sticky
// with no reset seam, so no execution order can guarantee a pre-Load state.
TEST_CASE("Lucide loads statically with a non-empty set", "[ui][icons]") {
    REQUIRE(rui::LucideIcons::Load());
    CHECK(rui::LucideIcons::Load());  // second load is a no-op true
    int count = rui::LucideIcons::GetCount();
    CHECK(count > 0);
    const char* first = rui::LucideIcons::GetName(0);
    REQUIRE(first != nullptr);
    CHECK(std::strlen(first) > 0);
    CHECK(rui::LucideIcons::GetName(-1) == nullptr);
    CHECK(rui::LucideIcons::GetName(count) == nullptr);
}

TEST_CASE("A catalog icon renders and exposes its SVG", "[ui][icons]") {
    REQUIRE(rui::LucideIcons::Load());
    const char* name = rui::LucideIcons::GetName(0);
    REQUIRE(name != nullptr);
    const char* svg = rui::LucideIcons::GetSvgData(name);
    REQUIRE(svg != nullptr);
    CHECK(std::strncmp(svg, "<svg", 4) == 0);
    uint8_t* px = rui::LucideIcons::Render(name, 16, 0xFFFFFFu);
    REQUIRE(px != nullptr);
    rui::LucideIcons::Free(px);
    HBITMAP bmp = rui::LucideIcons::CreateBitmap(name, 16, 0xFFFFFFu);
    CHECK(bmp != nullptr);
    if (bmp)
        DeleteObject(bmp);
}

TEST_CASE("Unknown icon names draw the fallback, never crash", "[ui][icons]") {
    // Corrected by D00 T02 §9: the draw calls resolve an unknown or null name
    // to the fallback glyph instead of returning null, and the SVG lookup
    // stays strict.
    REQUIRE(rui::LucideIcons::Load());
    CHECK(rui::LucideIcons::GetSvgData("no-such-icon-xyz") == nullptr);
    CHECK(rui::LucideIcons::GetSvgData(nullptr) == nullptr);
    for (const char* name : {"no-such-icon-xyz", static_cast<const char*>(nullptr)}) {
        uint8_t* px = rui::LucideIcons::Render(name, 16, 0xFFFFFFu);
        CHECK(px != nullptr);
        rui::LucideIcons::Free(px);
    }
    CHECK(rui::LucideIcons::Render(rui::LucideIcons::GetName(0), 0, 0xFFFFFFu) == nullptr);
    HBITMAP bmp = rui::LucideIcons::CreateBitmap("no-such-icon-xyz", 16, 0xFFFFFFu);
    CHECK(bmp != nullptr);
    if (bmp)
        DeleteObject(bmp);
    rui::LucideIcons::ClearUnknownNames();
}

// ── Controls: ListView ────────────────────────────────────────────────

// Ordinary control calls arm manager-held [this] lambdas (Select, sort,
// collapse, empty/error), and the singleton manager outlives the stack
// control. Headless the timer never fires, which makes the dangling latency
// invisible, not absent: every case below drains the manager before its
// control unwinds. Declared after the control so it runs first, and RAII so
// a REQUIRE failure still drains.
namespace {
struct DrainAnimations {
    ~DrainAnimations() { rui::AnimationManager::Instance().CancelAll(); }
};
}  // namespace

TEST_CASE("ListView starts empty and unselected", "[ui][controls]") {
    rui::ListView lv;
    DrainAnimations drain;
    CHECK(lv.ItemCount() == 0);
    CHECK(lv.SelectedIndex() == -1);
    CHECK(lv.SortColumn() == -1);
    CHECK(lv.SortDirection() == rui::SortDir::None);
    CHECK(lv.GetViewMode() == rui::ViewMode::Details);
    CHECK(lv.ColumnCount() == 0);
    CHECK_FALSE(lv.IsEditing());
}

TEST_CASE("ListView selection clamps to the item range", "[ui][controls]") {
    rui::ListView lv;
    DrainAnimations drain;
    lv.SetItemCount(10);
    CHECK(lv.ItemCount() == 10);
    lv.Select(3);
    CHECK(lv.SelectedIndex() == 3);
    lv.Select(99);  // out of range: ignored, selection stands
    CHECK(lv.SelectedIndex() == 3);
    lv.Select(-1);  // negative: ignored the same way
    CHECK(lv.SelectedIndex() == 3);
}

TEST_CASE("ListView sort state round-trips", "[ui][controls]") {
    rui::ListView lv;
    DrainAnimations drain;
    lv.SetSortColumn(1, true);
    CHECK(lv.SortColumn() == 1);
    CHECK(lv.SortDirection() == rui::SortDir::Ascending);
    lv.SetSortColumn(1, false);
    CHECK(lv.SortDirection() == rui::SortDir::Descending);
}

TEST_CASE("ListView columns add and clear", "[ui][controls]") {
    rui::ListView lv;
    DrainAnimations drain;
    lv.AddColumn(L"Name", 160.0f);
    lv.AddColumn(nullptr, 80.0f);  // null label stores empty, never crashes
    CHECK(lv.ColumnCount() == 2);
    lv.ClearColumns();
    CHECK(lv.ColumnCount() == 0);
}

TEST_CASE("ListView edit sessions open and close", "[ui][controls]") {
    rui::ListItem item;  // declared first: the provider borrows it, so it must outlive the view
    rui::ListView lv;
    DrainAnimations drain;
    item.cells = {L"alpha", L"beta"};
    lv.SetItemCount(4);
    lv.SetItemProvider([&item](int) -> const rui::ListItem& { return item; });
    lv.BeginEdit(2, 1);
    CHECK(lv.IsEditing());
    lv.EndEdit(false);
    CHECK_FALSE(lv.IsEditing());
    lv.BeginEdit(99);  // outside the item range: refused
    CHECK_FALSE(lv.IsEditing());
    lv.BeginEdit(1, 9);  // outside the cell range: refused
    CHECK_FALSE(lv.IsEditing());
}

TEST_CASE("ListView view mode round-trips", "[ui][controls]") {
    rui::ListView lv;
    DrainAnimations drain;
    for (auto mode : {rui::ViewMode::LargeIcons, rui::ViewMode::SmallIcons, rui::ViewMode::List,
                      rui::ViewMode::Details}) {
        lv.SetViewMode(mode);
        CHECK(lv.GetViewMode() == mode);
    }
}

// ── Controls: Sidebar ─────────────────────────────────────────────────

TEST_CASE("Sidebar starts unselected badges at zero width", "[ui][controls]") {
    rui::Sidebar bar;
    DrainAnimations drain;
    CHECK(bar.Selected() == 0);
    CHECK(bar.Badge(0) == 0);
    CHECK(bar.Badge(-1) == 0);
    CHECK(bar.Badge(rui::kCategoryCount) == 0);
    CHECK_FALSE(bar.IsCollapsed());
    CHECK(bar.ScaledWidth() == 200);  // BASE_WIDTH at the default 96 DPI
}

TEST_CASE("Sidebar badges set in range and ignore the rest", "[ui][controls]") {
    rui::Sidebar bar;
    DrainAnimations drain;
    bar.SetBadge(2, 5);
    CHECK(bar.Badge(2) == 5);
    bar.SetBadge(-1, 9);
    bar.SetBadge(rui::kCategoryCount, 9);
    CHECK(bar.Badge(0) == 0);
    CHECK(bar.Badge(2) == 5);
}

TEST_CASE("Sidebar collapse toggles both ways", "[ui][controls]") {
    rui::Sidebar bar;
    DrainAnimations drain;
    bar.SetCollapsed(true);
    CHECK(bar.IsCollapsed());
    bar.ToggleCollapsed();
    CHECK_FALSE(bar.IsCollapsed());
    bar.ToggleCollapsed();
    CHECK(bar.IsCollapsed());
}

TEST_CASE("Sidebar category table keeps its shape", "[ui][controls]") {
    CHECK(rui::kCategoryCount == 6);
    CHECK(std::wcscmp(rui::kCategories[0].label, L"All") == 0);
}

// ── Controls: Toolbar, StatusBar, ContentView ─────────────────────────

TEST_CASE("Toolbar and StatusBar scale their heights", "[ui][controls]") {
    rui::Toolbar tb;
    rui::StatusBar sb;
    DrainAnimations drain;
    CHECK(tb.ScaledHeight() == 40);  // BASE_HEIGHT at the default 96 DPI
    CHECK(sb.ScaledHeight() == 26);  // BASE_HEIGHT at the default 96 DPI
}

TEST_CASE("Command IDs stay pinned", "[ui][controls]") {
    // Other code switches on these IDs; renumbering breaks the message map.
    CHECK(static_cast<int>(rui::IDC_TB_VIEW_LARGE) == 1001);
    CHECK(static_cast<int>(rui::IDC_TB_REFRESH) == 1010);
    CHECK(static_cast<int>(rui::IDC_TB_SETTINGS) == 1020);
    CHECK(static_cast<int>(rui::IDC_TB_THEME) == 1030);
    CHECK(rui::IDC_SB_LEFT == 2001);
    CHECK(rui::IDC_SB_CENTER == 2002);
    CHECK(rui::IDC_SB_RIGHT == 2003);
    CHECK(rui::IDC_LISTVIEW_SELECT == 3001);
    CHECK(rui::IDC_LISTVIEW_SORT == 3004);
}

TEST_CASE("ContentView empty state shows and hides", "[ui][controls]") {
    rui::ContentView cv;
    DrainAnimations drain;
    CHECK_FALSE(cv.IsEmpty());
    cv.HideEmpty();  // hiding while hidden is a no-op, never a crash
    CHECK_FALSE(cv.IsEmpty());
    cv.ShowEmpty();
    CHECK(cv.IsEmpty());
    cv.ShowError(L"boom");  // headless: must not crash without a window
    cv.DismissError();
}
