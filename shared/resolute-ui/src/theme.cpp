#include <resolute/theme.h>
#include <resolute/animation.h>
#include <algorithm>
#include <cmath>

namespace rui {

// ── HSL helpers ─────────────────────────────────────────────
struct HSL { float h, s, l; };

static HSL RGBtoHSL(COLORREF c) {
    float r = GetRValue(c) / 255.0f;
    float g = GetGValue(c) / 255.0f;
    float b = GetBValue(c) / 255.0f;
    float mx = (std::max)({r, g, b});
    float mn = (std::min)({r, g, b});
    float d = mx - mn;
    HSL hsl{};
    hsl.l = (mx + mn) * 0.5f;
    if (d < 0.001f) { hsl.h = hsl.s = 0.0f; return hsl; }
    hsl.s = hsl.l > 0.5f ? d / (2.0f - mx - mn) : d / (mx + mn);
    if (mx == r) hsl.h = (g - b) / d + (g < b ? 6.0f : 0.0f);
    else if (mx == g) hsl.h = (b - r) / d + 2.0f;
    else hsl.h = (r - g) / d + 4.0f;
    hsl.h /= 6.0f;
    return hsl;
}

static float HueToRGB(float p, float q, float t) {
    if (t < 0.0f) t += 1.0f;
    if (t > 1.0f) t -= 1.0f;
    if (t < 1.0f/6.0f) return p + (q - p) * 6.0f * t;
    if (t < 0.5f) return q;
    if (t < 2.0f/3.0f) return p + (q - p) * (2.0f/3.0f - t) * 6.0f;
    return p;
}

static COLORREF HSLtoRGB(HSL hsl) {
    if (hsl.s < 0.001f) {
        BYTE v = static_cast<BYTE>(hsl.l * 255.0f);
        return RGB(v, v, v);
    }
    float q = hsl.l < 0.5f ? hsl.l * (1.0f + hsl.s)
                            : hsl.l + hsl.s - hsl.l * hsl.s;
    float p = 2.0f * hsl.l - q;
    BYTE r = static_cast<BYTE>(HueToRGB(p, q, hsl.h + 1.0f/3.0f) * 255.0f);
    BYTE g = static_cast<BYTE>(HueToRGB(p, q, hsl.h) * 255.0f);
    BYTE b = static_cast<BYTE>(HueToRGB(p, q, hsl.h - 1.0f/3.0f) * 255.0f);
    return RGB(r, g, b);
}

static COLORREF AdjustLightness(COLORREF c, float delta) {
    auto hsl = RGBtoHSL(c);
    hsl.l = (std::max)(0.0f, (std::min)(1.0f, hsl.l + delta));
    return HSLtoRGB(hsl);
}

static COLORREF BlendColor(COLORREF fg, COLORREF bg, float alpha) {
    BYTE r = static_cast<BYTE>(GetRValue(fg) * alpha + GetRValue(bg) * (1.0f - alpha));
    BYTE g = static_cast<BYTE>(GetGValue(fg) * alpha + GetGValue(bg) * (1.0f - alpha));
    BYTE b = static_cast<BYTE>(GetBValue(fg) * alpha + GetBValue(bg) * (1.0f - alpha));
    return RGB(r, g, b);
}

// ── Default Palettes ────────────────────────────────────────
ColorPalette DarkPalette {
    RGB(30,  30,  30),   // background
    RGB(40,  40,  40),   // surface
    RGB(55,  55,  55),   // surfaceHover
    RGB(0,   120, 212),  // surfaceActive
    RGB(45,  45,  45),   // toolbar
    RGB(230, 230, 230),  // text
    RGB(160, 160, 160),  // textSecondary
    RGB(60,  60,  60),   // border
    RGB(0,   120, 212),  // accent
    RGB(35,  35,  35),   // statusBar
    RGB(160, 160, 160),  // statusBarText

    RGB(30,  140, 230),  // accentHover
    RGB(0,   90,  170),  // accentPressed
    RGB(0,   120, 212),  // accentSubtle

    RGB(76,  175, 80),   // success
    RGB(255, 183, 77),   // warning
    RGB(239, 83,  80),   // error
    RGB(66,  165, 245),  // info

    RGB(20,  20,  20),   // surfaceBase
    RGB(28,  28,  28),   // surfaceLow
    RGB(36,  36,  36),   // surfaceMid
    RGB(48,  48,  48),   // surfaceHigh

    RGB(0,   0,   0),    // scrim
};

ColorPalette LightPalette {
    RGB(243, 243, 243),  // background
    RGB(235, 235, 235),  // surface
    RGB(220, 220, 220),  // surfaceHover
    RGB(0,   120, 212),  // surfaceActive
    RGB(249, 249, 249),  // toolbar
    RGB(25,  25,  25),   // text
    RGB(100, 100, 100),  // textSecondary
    RGB(210, 210, 210),  // border
    RGB(0,   120, 212),  // accent
    RGB(230, 230, 230),  // statusBar
    RGB(100, 100, 100),  // statusBarText

    RGB(30,  140, 230),  // accentHover
    RGB(0,   90,  170),  // accentPressed
    RGB(0,   120, 212),  // accentSubtle

    RGB(56,  142, 60),   // success
    RGB(245, 124, 0),    // warning
    RGB(211, 47,  47),   // error
    RGB(25,  118, 210),  // info

    RGB(255, 255, 255),  // surfaceBase
    RGB(249, 249, 249),  // surfaceLow
    RGB(243, 243, 243),  // surfaceMid
    RGB(235, 235, 235),  // surfaceHigh

    RGB(0,   0,   0),    // scrim
};

// ── Static State ────────────────────────────────────────────
bool Theme::s_dark = true;
Theme::Mode Theme::s_mode = Theme::Mode::System;
ColorPalette Theme::s_fromPalette{};
ColorPalette Theme::s_toPalette{};
ColorPalette Theme::s_blendedPalette{};
float        Theme::s_transitionT = -1.0f;
uint32_t     Theme::s_transitionAnimId = 0;
Theme::RepaintFn Theme::s_repaintFn = nullptr;

// ── Core ────────────────────────────────────────────────────
bool Theme::IsDarkMode() {
    DWORD value = 1;
    DWORD size  = sizeof(value);
    RegGetValueW(
        HKEY_CURRENT_USER,
        L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
        L"AppsUseLightTheme",
        RRF_RT_DWORD, nullptr, &value, &size
    );
    return value == 0;
}

const ColorPalette& Theme::Colors() {
    if (s_transitionT >= 0.0f && s_transitionT <= 1.0f)
        return s_blendedPalette;
    return s_dark ? DarkPalette : LightPalette;
}

bool Theme::IsDark() { return s_dark; }
Theme::Mode Theme::GetMode() { return s_mode; }

// ── Undocumented uxtheme dark mode APIs ─────────────────────
// Same approach used by Windows Explorer, Notepad, etc.
// Must call SetPreferredAppMode BEFORE any windows are created.
using FnSetPreferredAppMode = int (WINAPI*)(int);   // ordinal 135
using FnFlushMenuThemes     = void (WINAPI*)();     // ordinal 136
using FnAllowDarkModeForWindow = bool (WINAPI*)(HWND, bool); // ordinal 133

static FnSetPreferredAppMode   s_pSetAppMode  = nullptr;
static FnFlushMenuThemes       s_pFlushMenus  = nullptr;
static FnAllowDarkModeForWindow s_pAllowDark  = nullptr;

static void LoadDarkModeAPIs() {
    static bool loaded = false;
    if (loaded) return;
    loaded = true;
    HMODULE hUx = LoadLibraryW(L"uxtheme.dll");
    if (!hUx) return;
    s_pSetAppMode = reinterpret_cast<FnSetPreferredAppMode>(
        GetProcAddress(hUx, MAKEINTRESOURCEA(135)));
    s_pFlushMenus = reinterpret_cast<FnFlushMenuThemes>(
        GetProcAddress(hUx, MAKEINTRESOURCEA(136)));
    s_pAllowDark = reinterpret_cast<FnAllowDarkModeForWindow>(
        GetProcAddress(hUx, MAKEINTRESOURCEA(133)));
}

void Theme::Init() {
    s_mode = Mode::System;
    s_dark = IsDarkMode();
    ReadSystemAccent();

    // Must be called before any window is created
    LoadDarkModeAPIs();
    // 0=Default, 1=AllowDark, 2=ForceDark, 3=ForceLight
    if (s_pSetAppMode) s_pSetAppMode(s_dark ? 2 : 0);
}

void Theme::Toggle() {
    switch (s_mode) {
    case Mode::Dark:   s_mode = Mode::Light;  s_dark = false;         break;
    case Mode::Light:  s_mode = Mode::System; s_dark = IsDarkMode();  break;
    case Mode::System: s_mode = Mode::Dark;   s_dark = true;          break;
    }
}

void Theme::SetDark(bool dark) { s_dark = dark; }

void Theme::ApplyToWindow(HWND hwnd) {
    BOOL dark = s_dark ? TRUE : FALSE;
    DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark, sizeof(dark));

    // Update dark mode preference and flush menu themes on toggle
    if (s_pSetAppMode) s_pSetAppMode(s_dark ? 2 : 0);
    if (s_pAllowDark) s_pAllowDark(hwnd, s_dark);
    if (s_pFlushMenus) s_pFlushMenus();
}

uint32_t Theme::IconColor() {
    auto& c = Colors();
    return (GetRValue(c.text) << 16) | (GetGValue(c.text) << 8) | GetBValue(c.text);
}

uint32_t Theme::SecondaryIconColor() {
    auto& c = Colors();
    return (GetRValue(c.textSecondary) << 16) | (GetGValue(c.textSecondary) << 8) | GetBValue(c.textSecondary);
}

uint32_t Theme::AccentIconColor() {
    auto& c = Colors();
    return (GetRValue(c.accent) << 16) | (GetGValue(c.accent) << 8) | GetBValue(c.accent);
}

// ── System Accent ───────────────────────────────────────────
void Theme::ReadSystemAccent() {
    DWORD abgr = 0;
    DWORD size = sizeof(abgr);
    LSTATUS status = RegGetValueW(
        HKEY_CURRENT_USER,
        L"Software\\Microsoft\\Windows\\DWM",
        L"AccentColor",
        RRF_RT_DWORD, nullptr, &abgr, &size
    );

    COLORREF accent;
    if (status == ERROR_SUCCESS) {
        accent = abgr & 0x00FFFFFF;
    } else {
        accent = RGB(0, 120, 212);
    }

    COLORREF accentHover   = AdjustLightness(accent, 0.10f);
    COLORREF accentPressed = AdjustLightness(accent, -0.12f);

    DarkPalette.accent        = accent;
    DarkPalette.surfaceActive = accent;
    DarkPalette.accentHover   = accentHover;
    DarkPalette.accentPressed = accentPressed;
    DarkPalette.accentSubtle  = BlendColor(accent, RGB(30, 30, 30), 0.12f);

    LightPalette.accent        = accent;
    LightPalette.surfaceActive = accent;
    LightPalette.accentHover   = accentHover;
    LightPalette.accentPressed = accentPressed;
    LightPalette.accentSubtle  = BlendColor(accent, RGB(243, 243, 243), 0.10f);
}

// ── High Contrast ───────────────────────────────────────────
bool Theme::IsHighContrast() {
    HIGHCONTRASTW hc{};
    hc.cbSize = sizeof(hc);
    SystemParametersInfoW(SPI_GETHIGHCONTRAST, sizeof(hc), &hc, 0);
    return (hc.dwFlags & HCF_HIGHCONTRASTON) != 0;
}

float Theme::ScrimOpacity() {
    return s_dark ? 0.5f : 0.3f;
}

// ── Animated Theme Transition ───────────────────────────────
void Theme::SetRepaintCallback(RepaintFn fn) {
    s_repaintFn = fn;
}

bool Theme::IsTransitioning() {
    return s_transitionT >= 0.0f && s_transitionT < 1.0f;
}

void Theme::BlendPalettes(float t) {
    const auto* from = reinterpret_cast<const COLORREF*>(&s_fromPalette);
    const auto* to   = reinterpret_cast<const COLORREF*>(&s_toPalette);
    auto*       out  = reinterpret_cast<COLORREF*>(&s_blendedPalette);

    for (int i = 0; i < kPaletteFieldCount; i++) {
        out[i] = LerpColor(from[i], to[i], t);
    }
}

void Theme::AnimateToggle(float durationMs) {
    // Cancel any existing transition
    if (s_transitionAnimId) {
        AnimationManager::Instance().Cancel(s_transitionAnimId);
        s_transitionAnimId = 0;
    }

    // Snapshot current colors as the "from" palette
    const auto& current = Colors();
    s_fromPalette = current;

    // Switch to the new mode
    Toggle();

    // New target palette
    s_toPalette = s_dark ? DarkPalette : LightPalette;

    // Initialize blend
    s_transitionT = 0.0f;
    s_blendedPalette = s_fromPalette;

    // Animate
    s_transitionAnimId = AnimationManager::Instance().Animate(
        0.0f, 1.0f, durationMs, ease::OutCubic,
        [](float val, const Animation&) {
            s_transitionT = val;
            BlendPalettes(val);
            if (s_repaintFn) s_repaintFn();
        },
        []() {
            // Transition complete — reset state
            s_transitionT = -1.0f;
            s_transitionAnimId = 0;
            if (s_repaintFn) s_repaintFn();
        }
    );
}

// ── Backdrop (Mica Alt) ─────────────────────────────────────
void Theme::ApplyBackdrop(HWND hwnd) {
    // DWMWA_SYSTEMBACKDROP_TYPE = 38 (Win11 22H2+ Build 22621)
    // Values: 0=Auto, 1=None, 2=Mica, 3=Acrylic, 4=Mica Alt (Tabbed)
    constexpr DWORD DWMWA_SYSTEMBACKDROP = 38;
    DWORD backdropType = 4; // Mica Alt
    HRESULT hr = DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP,
        &backdropType, sizeof(backdropType));

    if (SUCCEEDED(hr)) {
        // Extend frame into entire client area for Mica to show through
        MARGINS margins = { -1, -1, -1, -1 };
        DwmExtendFrameIntoClientArea(hwnd, &margins);
    }
}

} // namespace rui
