// Rendered-output regression tests. D00 T02 §9.
//
// Unit tests prove the constants and the parity driver proves system
// effects; neither proves what the user sees. Here every shared control is
// painted offscreen, through the same paint path its window uses
// (RenderTo), into a software WIC bitmap at 96 DIPs per inch with grayscale
// text, in light and dark at 100 and 150 percent, and pixel-diffed against
// a committed golden under tests/golden/. A failure names the control,
// counts the differing pixels, and writes the actual image and a diff image
// under the build tree.
//
// Goldens are restaked by running with RESOLUTE_UPDATE_GOLDENS=1, in the
// same commit as the layout change that moves them. They are pinned to this
// suite's host: the software rasterizer is deterministic, but the fonts and
// the GDI popup's ClearType text come from the machine (recorded in
// tests/golden/README.md).

#include <catch2/catch_test_macros.hpp>

#include <resolute/animation.h>
#include <resolute/controls/contentview.h>
#include <resolute/controls/listview.h>
#include <resolute/controls/popupmenu.h>
#include <resolute/controls/sidebar.h>
#include <resolute/controls/statusbar.h>
#include <resolute/controls/toolbar.h>
#include <resolute/dpi.h>
#include <resolute/icons.h>
#include <resolute/render.h>
#include <resolute/theme.h>

#include <d2d1.h>
#include <wincodec.h>
#include <wrl/client.h>

#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <functional>
#include <memory>
#include <string>
#include <vector>

using Microsoft::WRL::ComPtr;

namespace {

// Two renders of the same state on the same host match exactly; the
// tolerance only absorbs anti-aliasing coverage rounding (a few levels per
// channel) should the D2D software rasterizer change between Windows
// builds. A one-pixel shift moves edges by tens to hundreds of levels, far
// past it, so shifts still fail.
constexpr int kChannelTolerance = 8;

struct Image {
    UINT                  w = 0;
    UINT                  h = 0;
    std::vector<uint32_t> px;  // BGRA, top-down, opaque
};

IWICImagingFactory* Wic() {
    static ComPtr<IWICImagingFactory> factory = [] {
        CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
        ComPtr<IWICImagingFactory> f;
        CoCreateInstance(CLSID_WICImagingFactory, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&f));
        return f;
    }();
    return factory.Get();
}

bool SavePng(const std::filesystem::path& path, const Image& img) {
    std::filesystem::create_directories(path.parent_path());
    ComPtr<IWICStream> stream;
    ComPtr<IWICBitmapEncoder> enc;
    ComPtr<IWICBitmapFrameEncode> frame;
    if (FAILED(Wic()->CreateStream(&stream)) || FAILED(stream->InitializeFromFilename(path.c_str(), GENERIC_WRITE)) ||
        FAILED(Wic()->CreateEncoder(GUID_ContainerFormatPng, nullptr, &enc)) ||
        FAILED(enc->Initialize(stream.Get(), WICBitmapEncoderNoCache)) ||
        FAILED(enc->CreateNewFrame(&frame, nullptr)) || FAILED(frame->Initialize(nullptr)) ||
        FAILED(frame->SetSize(img.w, img.h)))
        return false;
    WICPixelFormatGUID fmt = GUID_WICPixelFormat32bppBGRA;
    if (FAILED(frame->SetPixelFormat(&fmt)) || fmt != GUID_WICPixelFormat32bppBGRA) return false;
    const UINT stride = img.w * 4;
    if (FAILED(frame->WritePixels(img.h, stride, stride * img.h,
                                  reinterpret_cast<BYTE*>(const_cast<uint32_t*>(img.px.data())))))
        return false;
    return SUCCEEDED(frame->Commit()) && SUCCEEDED(enc->Commit());
}

bool LoadPng(const std::filesystem::path& path, Image& img) {
    ComPtr<IWICBitmapDecoder> dec;
    ComPtr<IWICBitmapFrameDecode> frame;
    ComPtr<IWICFormatConverter> conv;
    if (FAILED(Wic()->CreateDecoderFromFilename(path.c_str(), nullptr, GENERIC_READ, WICDecodeMetadataCacheOnDemand,
                                                &dec)) ||
        FAILED(dec->GetFrame(0, &frame)) || FAILED(Wic()->CreateFormatConverter(&conv)) ||
        FAILED(conv->Initialize(frame.Get(), GUID_WICPixelFormat32bppBGRA, WICBitmapDitherTypeNone, nullptr, 0.0,
                                WICBitmapPaletteTypeCustom)))
        return false;
    conv->GetSize(&img.w, &img.h);
    img.px.assign(static_cast<size_t>(img.w) * img.h, 0);
    return SUCCEEDED(conv->CopyPixels(nullptr, img.w * 4, img.w * img.h * 4, reinterpret_cast<BYTE*>(img.px.data())));
}

// Paints through `paint` into a fresh software D2D target of w x h pixels.
Image RenderD2D(UINT w, UINT h, const std::function<bool(ID2D1RenderTarget*)>& paint) {
    Image img{w, h, {}};
    ComPtr<IWICBitmap> bmp;
    REQUIRE(SUCCEEDED(Wic()->CreateBitmap(w, h, GUID_WICPixelFormat32bppPBGRA, WICBitmapCacheOnLoad, &bmp)));
    auto props = D2D1::RenderTargetProperties(
        D2D1_RENDER_TARGET_TYPE_SOFTWARE,
        D2D1::PixelFormat(DXGI_FORMAT_B8G8R8A8_UNORM, D2D1_ALPHA_MODE_PREMULTIPLIED), 96.0f, 96.0f);
    ComPtr<ID2D1RenderTarget> rt;
    REQUIRE(SUCCEEDED(rui::RenderContext::D2D()->CreateWicBitmapRenderTarget(bmp.Get(), props, &rt)));
    rt->SetTextAntialiasMode(D2D1_TEXT_ANTIALIAS_MODE_GRAYSCALE);
    REQUIRE(paint(rt.Get()));
    rt.Reset();
    img.px.assign(static_cast<size_t>(w) * h, 0);
    REQUIRE(SUCCEEDED(bmp->CopyPixels(nullptr, w * 4, w * h * 4, reinterpret_cast<BYTE*>(img.px.data()))));
    for (auto& p : img.px) p |= 0xFF000000u;  // every control clears opaque; make the file say so
    return img;
}

// Paints through the GDI popup's own path into a 32-bit DIB.
Image RenderGdi(UINT w, UINT h, const std::function<void(HDC)>& paint) {
    Image img{w, h, {}};
    BITMAPINFO bi{};
    bi.bmiHeader.biSize        = sizeof(bi.bmiHeader);
    bi.bmiHeader.biWidth       = static_cast<LONG>(w);
    bi.bmiHeader.biHeight      = -static_cast<LONG>(h);  // top-down
    bi.bmiHeader.biPlanes      = 1;
    bi.bmiHeader.biBitCount    = 32;
    bi.bmiHeader.biCompression = BI_RGB;
    void* bits = nullptr;
    HDC dc = CreateCompatibleDC(nullptr);
    HBITMAP dib = CreateDIBSection(dc, &bi, DIB_RGB_COLORS, &bits, nullptr, 0);
    REQUIRE(dib != nullptr);
    HGDIOBJ old = SelectObject(dc, dib);
    paint(dc);
    GdiFlush();
    img.px.assign(static_cast<const uint32_t*>(bits), static_cast<const uint32_t*>(bits) + static_cast<size_t>(w) * h);
    for (auto& p : img.px) p |= 0xFF000000u;  // GDI leaves alpha unset
    SelectObject(dc, old);
    DeleteObject(dib);
    DeleteDC(dc);
    return img;
}

// Pixels where any channel differs by more than the tolerance, over the
// union of both sizes: a pixel exactly one image has always differs (one in
// neither is skipped), so a size
// change fails with a count and a diff like any other change, and no pixel
// is read out of bounds. `diff`, when given, receives the differing pixels
// in red over a dimmed actual (black where the actual has no pixel).
int DiffCount(const Image& actual, const Image& want, Image* diff = nullptr) {
    const UINT w = std::max(actual.w, want.w), h = std::max(actual.h, want.h);
    if (actual.px.size() != size_t{actual.w} * actual.h || want.px.size() != size_t{want.w} * want.h) return -1;
    if (diff) *diff = Image{w, h, std::vector<uint32_t>(size_t{w} * h, 0xFF000000u)};
    int differing = 0;
    for (UINT y = 0; y < h; ++y) {
        for (UINT x = 0; x < w; ++x) {
            const bool inA = x < actual.w && y < actual.h, inB = x < want.w && y < want.h;
            if (!inA && !inB) continue;  // in neither image: nothing to compare
            // Blue, green, red: the bytes of a BGRA pixel, alpha (always opaque) aside.
            const auto* a = inA ? reinterpret_cast<const uint8_t*>(&actual.px[size_t{y} * actual.w + x]) : nullptr;
            const auto* b = inB ? reinterpret_cast<const uint8_t*>(&want.px[size_t{y} * want.w + x]) : nullptr;
            bool differs = !(a && b);
            for (int ch = 0; a && b && ch < 3; ++ch)
                if (std::abs(static_cast<int>(a[ch]) - static_cast<int>(b[ch])) > kChannelTolerance) differs = true;
            if (differs) ++differing;
            if (diff) {
                auto* d = reinterpret_cast<uint8_t*>(&diff->px[size_t{y} * w + x]);
                for (int ch = 0; ch < 3; ++ch)
                    d[ch] = differs ? (ch == 2 ? 255 : 0) : static_cast<uint8_t>(a[ch] / 2);
                d[3] = 255;
            }
        }
    }
    return differing;
}

bool Updating() {
    const char* v = std::getenv("RESOLUTE_UPDATE_GOLDENS");
    return v && std::string(v) == "1";
}

// Compares `actual` with tests/golden/<name>.png; on a difference writes
// the actual and a diff image (differing pixels red over a dimmed actual)
// under the build tree. Restakes instead when RESOLUTE_UPDATE_GOLDENS=1.
void CheckGolden(const std::string& name, const Image& actual) {
    const std::filesystem::path golden = std::filesystem::path(RESOLUTE_GOLDEN_DIR) / (name + ".png");
    CAPTURE(name);
    if (Updating()) {
        REQUIRE(SavePng(golden, actual));
        return;
    }
    Image want;
    INFO("golden missing or unreadable: " << golden.string());
    REQUIRE(LoadPng(golden, want));
    // A size change is a failure with its artifacts, never an abort without
    // them (panel round 3 of the D00 T02 §9 review).
    INFO("size: actual " << actual.w << "x" << actual.h << ", golden " << want.w << "x" << want.h);
    CHECK(want.w == actual.w);
    CHECK(want.h == actual.h);
    Image diff;
    const int differing = DiffCount(actual, want, &diff);
    if (differing) {
        const std::filesystem::path out = std::filesystem::path(RESOLUTE_RENDER_OUT);
        SavePng(out / (name + "-actual.png"), actual);
        SavePng(out / (name + "-diff.png"), diff);
    }
    INFO("differing pixels: " << differing << " (tolerance " << kChannelTolerance << " per channel); actual and diff in "
                              << RESOLUTE_RENDER_OUT);
    CHECK(differing == 0);
}

// A hidden top-level window the controls are created in; never shown.
struct Host {
    HWND hwnd = nullptr;
    Host() {
        static const bool ready = rui::RenderContext::Init() && rui::LucideIcons::Load();
        REQUIRE(ready);
        WNDCLASSW wc{};
        wc.lpfnWndProc   = DefWindowProcW;
        wc.hInstance     = GetModuleHandleW(nullptr);
        wc.lpszClassName = L"ResoluteRenderHost";
        RegisterClassW(&wc);
        hwnd = CreateWindowExW(0, wc.lpszClassName, L"render", WS_OVERLAPPEDWINDOW, 0, 0, 1200, 800, nullptr, nullptr,
                               wc.hInstance, nullptr);
        REQUIRE(hwnd != nullptr);
    }
    ~Host() {
        rui::AnimationManager::Instance().CancelAll();
        DestroyWindow(hwnd);
    }
    Host(const Host&)            = delete;
    Host& operator=(const Host&) = delete;
};

// Every golden variant: appearance by DPI, and the theme restored after.
template <class Fn>
void ForEachVariant(Fn fn) {
    const bool wasDark = rui::Theme::IsDark();
    for (bool dark : {false, true}) {
        for (int dpi : {96, 144}) {
            rui::Theme::SetDark(dark);
            fn(std::string(dark ? "dark" : "light") + "-" + std::to_string(dpi), dpi);
        }
    }
    rui::Theme::SetDark(wasDark);
}

int S(int v, int dpi) { return rui::Dpi::Scale(v, dpi); }

// Every icon name the case's controls drew resolved: an unknown one (a
// malformed name, whatever its spelling) fails here, named.
void CheckNoUnknownIcons() {
    const std::vector<std::string> unknown = rui::LucideIcons::UnknownNames();
    CAPTURE(unknown);
    CHECK(unknown.empty());
}

template <class Control>
Image Render(Control& c, int w, int h) {
    rui::AnimationManager::Instance().Flush();
    return RenderD2D(static_cast<UINT>(w), static_cast<UINT>(h),
                     [&c](ID2D1RenderTarget* rt) { return c.RenderTo(rt); });
}

}  // namespace

TEST_CASE("Content view renders its states as the goldens", "[ui][render]") {
    rui::LucideIcons::ClearUnknownNames();
    ForEachVariant([](const std::string& v, int dpi) {
        struct State {
            const char* name;
            std::function<void(rui::ContentView&)> set;
        };
        const State states[] = {
            {"empty", [](rui::ContentView& c) { c.ShowEmpty(); }},
            {"empty-inbox", [](rui::ContentView& c) { c.ShowEmpty(L"Nothing here", L"", nullptr); }},
            {"error", [](rui::ContentView& c) { c.ShowError(L"The operation failed", 60.0f); }},
            {"success", [](rui::ContentView& c) { c.ShowSuccess(L"Saved", 60.0f); }},
        };
        for (const auto& st : states) {
            Host host;
            rui::ContentView cv;
            cv.Create(host.hwnd, GetModuleHandleW(nullptr), 201);
            cv.UpdateDpi(dpi);
            const int w = S(480, dpi), h = S(300, dpi);
            cv.Resize(0, 0, w, h);
            st.set(cv);
            CheckGolden(std::string("contentview-") + st.name + "-" + v, Render(cv, w, h));
            DestroyWindow(cv.Handle());
        }
    });
    CheckNoUnknownIcons();
}

TEST_CASE("List view renders as the golden", "[ui][render]") {
    rui::LucideIcons::ClearUnknownNames();
    ForEachVariant([](const std::string& v, int dpi) {
        Host host;
        rui::ListItem item;
        item.cells = {L"Resolute.exe", L"4.2 MB", L"Application"};
        rui::ListView lv;
        lv.Create(host.hwnd, GetModuleHandleW(nullptr), 202);
        lv.UpdateDpi(dpi);
        const int w = S(480, dpi), h = S(300, dpi);
        lv.Resize(0, 0, w, h);
        lv.AddColumn(L"Name", 200.0f);
        lv.AddColumn(L"Size", 100.0f);
        lv.AddColumn(L"Type", 120.0f);
        lv.SetItemCount(20);
        lv.SetItemProvider([&item](int) -> const rui::ListItem& { return item; });
        lv.Select(2);
        CheckGolden("listview-" + v, Render(lv, w, h));
        DestroyWindow(lv.Handle());
    });
    CheckNoUnknownIcons();
}

TEST_CASE("Sidebar renders expanded and collapsed as the goldens", "[ui][render]") {
    rui::LucideIcons::ClearUnknownNames();
    ForEachVariant([](const std::string& v, int dpi) {
        for (bool collapsed : {false, true}) {
            Host host;
            rui::Sidebar bar;
            bar.Create(host.hwnd, GetModuleHandleW(nullptr), 203);
            bar.UpdateDpi(dpi);
            if (collapsed) bar.SetCollapsed(true);
            rui::AnimationManager::Instance().Flush();
            const int w = bar.ScaledWidth(), h = S(320, dpi);
            bar.Resize(0, 0, w, h);
            CheckGolden(std::string(collapsed ? "sidebar-collapsed-" : "sidebar-") + v, Render(bar, w, h));
            DestroyWindow(bar.Handle());
        }
    });
    CheckNoUnknownIcons();
}

TEST_CASE("Status bar renders with its notification icons as the golden", "[ui][render]") {
    rui::LucideIcons::ClearUnknownNames();
    ForEachVariant([](const std::string& v, int dpi) {
        Host host;
        rui::StatusBar sb;
        sb.Create(host.hwnd, GetModuleHandleW(nullptr), 204);
        sb.UpdateDpi(dpi);
        const int w = S(640, dpi), h = S(rui::StatusBar::BASE_HEIGHT, dpi);
        sb.Resize(0, 0, w, h);
        sb.SetLeftText(L"20 items");
        sb.SetCenterText(L"Ready");
        sb.SetRightText(L"Details");
        sb.AddNotifyIcon(1, rui::NotifyIconKind::Spinner);
        sb.AddNotifyIcon(2, rui::NotifyIconKind::Success);
        sb.AddNotifyIcon(3, rui::NotifyIconKind::Warning);
        CheckGolden("statusbar-" + v, Render(sb, w, h));
        DestroyWindow(sb.Handle());
    });
    CheckNoUnknownIcons();
}

TEST_CASE("Toolbar renders full and overflowed as the goldens", "[ui][render]") {
    rui::LucideIcons::ClearUnknownNames();
    ForEachVariant([](const std::string& v, int dpi) {
        for (int base : {640, 140}) {
            Host host;
            rui::Toolbar tb;
            tb.Create(host.hwnd, GetModuleHandleW(nullptr), 205);
            tb.UpdateDpi(dpi);
            const int w = S(base, dpi), h = tb.ScaledHeight();
            tb.Resize(0, 0, w, h);
            CheckGolden(std::string(base == 640 ? "toolbar-" : "toolbar-overflow-") + v, Render(tb, w, h));
            DestroyWindow(tb.Handle());
        }
    });
    CheckNoUnknownIcons();
}

// The toolbar's View choices, as it passes them to the popup (its own
// table is private to the toolbar).
const rui::DropdownChoice kViewChoices[] = {
    {rui::IDC_TB_VIEW_LARGE, L"Large Icons", "view-large-icons"},
    {rui::IDC_TB_VIEW_SMALL, L"Small Icons", "view-small-icons"},
    {rui::IDC_TB_VIEW_LIST, L"List View", "view-list"},
    {rui::IDC_TB_VIEW_DETAILS, L"Details View", "view-details"},
};

TEST_CASE("Popup menu renders as the golden", "[ui][render]") {
    rui::LucideIcons::ClearUnknownNames();
    REQUIRE(rui::LucideIcons::Load());
    ForEachVariant([](const std::string& v, int dpi) {
        const SIZE sz = rui::PopupMenu::Measure(kViewChoices, 4, dpi);
        REQUIRE(sz.cx > 0);
        const Image img = RenderGdi(static_cast<UINT>(sz.cx), static_cast<UINT>(sz.cy), [dpi](HDC dc) {
            rui::PopupMenu::RenderTo(dc, kViewChoices, 4, dpi, 1);
        });
        CheckGolden("popupmenu-" + v, img);
    });
    CheckNoUnknownIcons();
}

TEST_CASE("The restored glyphs render at their real size as the golden", "[ui][render]") {
    // The seven names D00 T02 §8 restored, and the fallback, drawn through
    // the path every control uses, so each is visible in both appearances.
    rui::LucideIcons::ClearUnknownNames();
    Host host;
    const char* names[] = {"inbox", "alert-triangle", "check-circle", "circle", "loader-2", "check", "ellipsis",
                           "square-dashed"};
    ForEachVariant([&names](const std::string& v, int dpi) {
        const int icon = S(16, dpi), pad = S(8, dpi);
        const int n = static_cast<int>(sizeof(names) / sizeof(names[0]));
        const UINT w = static_cast<UINT>(pad + n * (icon + pad)), h = static_cast<UINT>(icon + 2 * pad);
        const Image img = RenderD2D(w, h, [&](ID2D1RenderTarget* rt) {
            const COLORREF bg = rui::Theme::Colors().surface;
            rt->BeginDraw();
            rt->Clear(D2D1::ColorF(GetRValue(bg) / 255.0f, GetGValue(bg) / 255.0f, GetBValue(bg) / 255.0f));
            bool all = true;
            for (int i = 0; i < n; ++i) {
                const float x = static_cast<float>(pad + i * (icon + pad));
                const D2D1_RECT_F rc = D2D1::RectF(x, static_cast<float>(pad), x + static_cast<float>(icon),
                                                   static_cast<float>(pad + icon));
                all = rui::RenderContext::DrawSvgIcon(rt, names[i], rc, rui::Theme::IconColor()) && all;
            }
            return SUCCEEDED(rt->EndDraw()) && all;
        });
        CheckGolden("glyphs-" + v, img);
    });
    CheckNoUnknownIcons();
}

TEST_CASE("An unknown icon name draws the fallback and is reported once", "[ui][render]") {
    rui::LucideIcons::ClearUnknownNames();
    REQUIRE(rui::LucideIcons::Load());
    CHECK(std::string(rui::LucideIcons::Resolve("chevron-up")) == "chevron-up");
    CHECK(std::string(rui::LucideIcons::Resolve("chevron--up")) == rui::LucideIcons::kFallbackIcon);
    CHECK(std::string(rui::LucideIcons::Resolve("chevron--up")) == rui::LucideIcons::kFallbackIcon);
    CHECK(std::string(rui::LucideIcons::Resolve(nullptr)) == rui::LucideIcons::kFallbackIcon);
    const auto unknown = rui::LucideIcons::UnknownNames();
    CHECK(unknown == std::vector<std::string>{"(null)", "chevron--up"});
    // The fallback itself resolves, so a missing icon is drawn, not blank.
    CHECK(rui::LucideIcons::GetSvgData(rui::LucideIcons::kFallbackIcon) != nullptr);
    rui::LucideIcons::ClearUnknownNames();
}

TEST_CASE("The golden diff catches a one-pixel shift", "[ui][render]") {
    // The comparator must not be blind: the sidebar's light 100 percent
    // render, moved one pixel left, differs from its own golden, and the
    // count is printed (D00 T02 §9).
    if (Updating()) return;
    Host host;
    const bool wasDark = rui::Theme::IsDark();
    rui::Theme::SetDark(false);
    rui::Sidebar bar;
    bar.Create(host.hwnd, GetModuleHandleW(nullptr), 206);
    bar.UpdateDpi(96);
    rui::AnimationManager::Instance().Flush();
    const int w = bar.ScaledWidth(), h = S(320, 96);
    bar.Resize(0, 0, w, h);
    const Image actual = Render(bar, w, h);
    DestroyWindow(bar.Handle());
    rui::Theme::SetDark(wasDark);

    Image want;
    REQUIRE(LoadPng(std::filesystem::path(RESOLUTE_GOLDEN_DIR) / "sidebar-light-96.png", want));
    REQUIRE(want.w == actual.w);
    REQUIRE(want.h == actual.h);
    REQUIRE(DiffCount(actual, want) == 0);
    Image shifted = actual;
    for (UINT y = 0; y < shifted.h; ++y)
        for (UINT x = 0; x + 1 < shifted.w; ++x) shifted.px[y * shifted.w + x] = actual.px[y * actual.w + x + 1];
    const int moved = DiffCount(shifted, want);
    INFO("differing pixels after a one-pixel shift: " << moved);
    CHECK(moved > 100);
}

TEST_CASE("An overflowed toolbar offers every hidden command", "[ui][render]") {
    // Too narrow for even its first item, the toolbar overflows everything
    // on its left, the View dropdown included, which the overflow menu must
    // offer as its choices, not as a command nothing handles (independent
    // review of D00 T02 §9).
    Host host;
    rui::Toolbar tb;
    tb.Create(host.hwnd, GetModuleHandleW(nullptr), 207);
    tb.UpdateDpi(96);
    const int w = S(140, 96), h = tb.ScaledHeight();
    tb.Resize(0, 0, w, h);
    Render(tb, w, h);  // lays the toolbar out
    HMENU menu = tb.BuildOverflowMenu();
    REQUIRE(menu != nullptr);
    HMENU view = GetSubMenu(menu, 0);
    REQUIRE(view != nullptr);
    CHECK(GetMenuItemCount(view) == 4);
    CHECK(GetMenuItemID(view, 0) == rui::IDC_TB_VIEW_LARGE);
    CHECK(GetMenuItemID(view, 3) == rui::IDC_TB_VIEW_DETAILS);
    bool refresh = false;
    for (int i = 0; i < GetMenuItemCount(menu); ++i)
        if (GetMenuItemID(menu, i) == rui::IDC_TB_REFRESH) refresh = true;
    CHECK(refresh);
    DestroyMenu(menu);
    DestroyWindow(tb.Handle());
}

TEST_CASE("A name passed straight to the icon API is reported too", "[ui][render]") {
    // The draw calls draw the fallback glyph for an unknown name, pixel for
    // pixel, and the strict SVG lookup returns null; all three record the
    // name, so no path around Resolve is silent or blank (panel rounds 1 and
    // 2 of the D00 T02 §9 review).
    REQUIRE(rui::LucideIcons::Load());
    rui::LucideIcons::ClearUnknownNames();
    CHECK(rui::LucideIcons::GetSvgData("chevron up") == nullptr);
    uint8_t* bad = rui::LucideIcons::Render("chevron__up", 16, 0xFFFFFFu);
    uint8_t* fallback = rui::LucideIcons::Render(rui::LucideIcons::kFallbackIcon, 16, 0xFFFFFFu);
    REQUIRE(bad != nullptr);
    REQUIRE(fallback != nullptr);
    CHECK(std::memcmp(bad, fallback, 16 * 16 * 4) == 0);
    rui::LucideIcons::Free(bad);
    rui::LucideIcons::Free(fallback);
    HBITMAP bmp = rui::LucideIcons::CreateBitmap("Chevron-Up", 16, 0xFFFFFFu);
    CHECK(bmp != nullptr);
    if (bmp)
        DeleteObject(bmp);
    CHECK(rui::LucideIcons::UnknownNames() == std::vector<std::string>{"Chevron-Up", "chevron up", "chevron__up"});
    rui::LucideIcons::ClearUnknownNames();
}

TEST_CASE("RenderTo reports the drawing's own result", "[ui][render]") {
    // A target whose drawing fails makes RenderTo false although the paint
    // ran to EndDraw: a DC render target never bound to a DC fails its
    // EndDraw, which the old pointer-based result reported as drawn (panel
    // rounds 1 and 3 of the D00 T02 §9 review). Success is asserted on a
    // real target, and a null target is refused.
    Host host;
    rui::Sidebar bar;
    bar.Create(host.hwnd, GetModuleHandleW(nullptr), 208);
    bar.UpdateDpi(96);
    rui::AnimationManager::Instance().Flush();
    const Image ok = Render(bar, bar.ScaledWidth(), S(320, 96));
    CHECK(ok.w > 0);
    const D2D1_RENDER_TARGET_PROPERTIES props = D2D1::RenderTargetProperties(
        D2D1_RENDER_TARGET_TYPE_SOFTWARE, D2D1::PixelFormat(DXGI_FORMAT_B8G8R8A8_UNORM, D2D1_ALPHA_MODE_PREMULTIPLIED));
    Microsoft::WRL::ComPtr<ID2D1DCRenderTarget> unbound;
    REQUIRE(SUCCEEDED(rui::RenderContext::D2D()->CreateDCRenderTarget(&props, &unbound)));
    CHECK_FALSE(bar.RenderTo(unbound.Get()));
    CHECK_FALSE(bar.RenderTo(nullptr));
    DestroyWindow(bar.Handle());
}

TEST_CASE("A golden of another size fails with a count and a diff", "[ui][render]") {
    // A size change is compared over the union of both sizes, so it fails
    // like any other change, with the pixels only one image has counted and
    // a diff to save (panel round 3 of the D00 T02 §9 review).
    const Image a{2, 2, std::vector<uint32_t>(4, 0xFFFFFFFFu)};
    const Image b{2, 3, std::vector<uint32_t>(6, 0xFFFFFFFFu)};
    Image diff;
    CHECK(DiffCount(a, b, &diff) == 2);
    CHECK(diff.w == 2);
    CHECK(diff.h == 3);
    CHECK(DiffCount(a, a) == 0);
    // Crossed sizes: 2x3 against 3x2 share four pixels, and each has two the
    // other lacks; the corner neither has is not a difference (panel round 4).
    const Image tall{2, 3, std::vector<uint32_t>(6, 0xFFFFFFFFu)};
    const Image wide{3, 2, std::vector<uint32_t>(6, 0xFFFFFFFFu)};
    CHECK(DiffCount(tall, wide) == 4);
    const Image torn{2, 2, std::vector<uint32_t>(3, 0xFFFFFFFFu)};
    CHECK(DiffCount(torn, a) == -1);
}
