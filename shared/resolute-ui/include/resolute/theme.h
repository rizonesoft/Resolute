#pragma once
// ── ResoluteUI Theme System ──────────────────────────────────────

#include <windows.h>
#include <dwmapi.h>
#include <cstdint>
#include "export.h"

namespace rui {

struct ColorPalette {
    // ── Core
    COLORREF background;
    COLORREF surface;
    COLORREF surfaceHover;
    COLORREF surfaceActive;
    COLORREF toolbar;
    COLORREF text;
    COLORREF textSecondary;
    COLORREF border;
    COLORREF accent;
    COLORREF statusBar;
    COLORREF statusBarText;

    // ── Accent Variants
    COLORREF accentHover;
    COLORREF accentPressed;
    COLORREF accentSubtle;

    // ── Semantic Colors
    COLORREF success;
    COLORREF warning;
    COLORREF error;
    COLORREF info;

    // ── Surface Elevation
    COLORREF surfaceBase;     // level 0 — deepest
    COLORREF surfaceLow;      // level 1
    COLORREF surfaceMid;      // level 2
    COLORREF surfaceHigh;     // level 3 — most elevated

    // ── Overlay
    COLORREF scrim;
};

// Number of COLORREF fields in ColorPalette (for bulk lerping)
inline constexpr int kPaletteFieldCount =
    sizeof(ColorPalette) / sizeof(COLORREF);

RESUI_API extern ColorPalette DarkPalette;
RESUI_API extern ColorPalette LightPalette;

class RESUI_API Theme {
public:
    enum class Mode { Dark, Light, System };

    static bool IsDarkMode();
    static const ColorPalette& Colors();
    static bool IsDark();
    static Mode GetMode();
    static void Init();
    static void Toggle();           // instant: cycles Dark → Light → System
    static void AnimateToggle(float durationMs = 300.0f);  // smooth crossfade
    static void SetDark(bool dark);
    static void ApplyToWindow(HWND hwnd);
    static uint32_t IconColor();
    static uint32_t SecondaryIconColor();
    static uint32_t AccentIconColor();

    /// Read system accent color from DWM registry and derive variants.
    static void ReadSystemAccent();

    /// Check if Windows High Contrast mode is active.
    static bool IsHighContrast();

    /// Scrim overlay opacity (0.5 dark, 0.3 light).
    static float ScrimOpacity();

    /// Is a theme transition currently running?
    static bool IsTransitioning();

    /// Apply system backdrop material (Mica Alt). Win11 22H2+ only.
    static void ApplyBackdrop(HWND hwnd);

    /// Set the repaint callback invoked on each transition frame.
    using RepaintFn = void(*)();
    static void SetRepaintCallback(RepaintFn fn);

private:
    static Mode s_mode;
    static bool s_dark;

    // Transition state
    static ColorPalette s_fromPalette;
    static ColorPalette s_toPalette;
    static ColorPalette s_blendedPalette;
    static float        s_transitionT;
    static uint32_t     s_transitionAnimId;
    static RepaintFn    s_repaintFn;

    static void BlendPalettes(float t);
};

} // namespace rui
