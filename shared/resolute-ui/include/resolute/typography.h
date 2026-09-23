#pragma once
// ── ResoluteUI Typography System ─────────────────────────────────

#include <windows.h>
#include <dwrite.h>
#include <dwrite_3.h>
#include <d2d1.h>
#include <wrl/client.h>
#include "export.h"

using Microsoft::WRL::ComPtr;

namespace rui {

// ── Type Ramp ──────────────────────────────────────────────
enum class TypeStyle : int {
    Caption  = 0,  // 11px — small labels, metadata
    Body     = 1,  // 13px — default content text
    Subtitle = 2,  // 16px — section headers
    Title    = 3,  // 20px — page/panel titles
    Display  = 4,  // 28px — hero/display text
};

// Base sizes in pixels (pre-DPI scaling)
inline constexpr float kTypeSizes[] = { 11.0f, 13.0f, 16.0f, 20.0f, 28.0f };
inline constexpr int   kTypeStyleCount = 5;

// Letter spacing (em units) per style — positive = looser, negative = tighter
inline constexpr float kTypeSpacing[] = { 0.4f, 0.1f, 0.0f, -0.2f, -0.5f };

// ── Font Weights ───────────────────────────────────────────
enum class FontWeight : int {
    Regular  = 400,
    Medium   = 500,
    SemiBold = 600,
    Bold     = 700,
};

// ── Typography Manager ─────────────────────────────────────
class RESUI_API Typography {
public:
    /// Create a text format from the type ramp.
    /// @param style   Type ramp entry (Caption, Body, etc.)
    /// @param weight  Font weight
    /// @param dpi     Current DPI for scaling
    static ComPtr<IDWriteTextFormat> Format(
        TypeStyle style,
        FontWeight weight = FontWeight::Regular,
        int dpi = 96);

    /// Load custom font files (.ttf, .otf) from a directory.
    /// @param fontDir  Path to directory containing font files
    /// @return true if at least one font was loaded
    static bool LoadFonts(const wchar_t* fontDir);

    /// Apply ClearType rendering to a render target.
    /// Sets DWRITE_RENDERING_MODE_NATURAL_SYMMETRIC and
    /// D2D1_TEXT_ANTIALIAS_MODE_CLEARTYPE.
    static void ApplyRendering(ID2D1RenderTarget* rt);

    /// Get the custom font collection (may be null if none loaded).
    static IDWriteFontCollection* FontCollection();

    /// Create a text layout with letter spacing applied.
    /// @param text     Text to lay out
    /// @param len      Text length
    /// @param style    Type ramp entry
    /// @param weight   Font weight
    /// @param maxW     Max layout width
    /// @param maxH     Max layout height
    /// @param dpi      Current DPI
    static ComPtr<IDWriteTextLayout> Layout(
        const wchar_t* text, UINT32 len,
        TypeStyle style,
        FontWeight weight,
        float maxW, float maxH,
        int dpi = 96);

private:
    static ComPtr<IDWriteFontCollection> s_fontCollection;
};

} // namespace rui
