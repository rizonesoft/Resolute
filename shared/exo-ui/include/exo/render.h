#pragma once
// ── ExoUI Rendering Context ─────────────────────────────────

#include <windows.h>
#include <d2d1.h>
#include <d2d1_3.h>
#include <d2d1svg.h>
#include <dwrite.h>
#include <wrl/client.h>
#include <cstdint>
#include <string>
#include <unordered_map>
#include "export.h"

using Microsoft::WRL::ComPtr;

namespace exo {

// D2D color from COLORREF
inline D2D1_COLOR_F ToD2DColor(COLORREF cr, float alpha = 1.0f) {
    return D2D1::ColorF(
        GetRValue(cr) / 255.0f,
        GetGValue(cr) / 255.0f,
        GetBValue(cr) / 255.0f,
        alpha
    );
}

class EXOUI_API RenderContext {
public:
    static bool Init();
    static ID2D1Factory* D2D();
    static IDWriteFactory* DWrite();

    static ComPtr<ID2D1HwndRenderTarget> CreateHwndTarget(HWND hwnd);

    static ComPtr<ID2D1Bitmap> CreateBitmapFromRGBA(
        ID2D1RenderTarget* rt, const uint8_t* rgba, int width, int height);

    static ComPtr<IDWriteTextFormat> CreateTextFormat(
        const wchar_t* fontFamily, float size,
        DWRITE_FONT_WEIGHT weight = DWRITE_FONT_WEIGHT_REGULAR);

    /// Draw a Lucide SVG icon using native D2D SVG rendering.
    /// @param rt       The render target (must support ID2D1DeviceContext5)
    /// @param name     Icon name (e.g. "settings")
    /// @param rect     Target rectangle to draw into
    /// @param color    Icon stroke color as 0xRRGGBB
    /// @param opacity  Icon opacity (0.0 - 1.0)
    /// @return         true if drawn via SVG, false if fallback needed
    static bool DrawSvgIcon(ID2D1RenderTarget* rt, const char* name,
                            const D2D1_RECT_F& rect, uint32_t color,
                            float opacity = 1.0f);

    /// Check if native D2D SVG rendering is available
    static bool SvgSupported();

    /// Clear cached SVG documents (call on theme change or render target recreation)
    static void ClearSvgCache();

private:
    static ComPtr<ID2D1Factory> s_d2dFactory;
    static ComPtr<IDWriteFactory> s_dwriteFactory;
    static bool s_svgChecked;
    static bool s_svgSupported;
    static std::unordered_map<std::string, ComPtr<ID2D1SvgDocument>> s_svgCache;
};

} // namespace exo
