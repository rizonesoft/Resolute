#pragma once
// ── ResoluteUI Toolbar Control ───────────────────────────────────
// Animated toolbar with icons, hover glow, press effect,
// active indicator, tooltips, and theme toggle.

#include <windows.h>
#include <wrl/client.h>
#include <d2d1.h>
#include "../export.h"
#include "../dpi.h"
#include "../theme.h"
#include "../render.h"
#include "../icons.h"
#include "../animation.h"

using Microsoft::WRL::ComPtr;

namespace rui {

enum ToolbarCmd : WORD {
    IDC_TB_VIEW_LARGE   = 1001,
    IDC_TB_VIEW_SMALL   = 1002,
    IDC_TB_VIEW_LIST    = 1003,
    IDC_TB_VIEW_DETAILS = 1004,
    IDC_TB_VIEW         = 1005,  // dropdown parent
    IDC_TB_REFRESH      = 1010,

    IDC_TB_SETTINGS     = 1020,
    IDC_TB_THEME        = 1030,
};

// Shared dropdown choice data used by Toolbar and PopupMenu
struct DropdownChoice {
    WORD            id;
    const wchar_t*  label;
    const char*     iconName;   // Lucide icon name (optional)
};

class RESUI_API Toolbar {
public:
    // Cancels every animation whose callbacks reach this control, so
    // none runs against it after teardown (D00 T02 §7).
    ~Toolbar();
    static constexpr int BASE_HEIGHT    = 40;
    static constexpr int BASE_FONT_SIZE = 13;
    static constexpr int BASE_ICON_SIZE = 16;

    int  ScaledHeight() const;
    void Create(HWND parent, HINSTANCE hInst, int id);
    HWND Handle() const;
    void Resize(int x, int y, int w, int h);
    void Repaint();
    void UpdateDpi(int dpi);

private:
    // ── Item Model ──────────────────────────────────────────
    enum class ItemKind : uint8_t {
        Button,       // regular clickable button (icon ± label)
        Separator,    // thin vertical divider between groups
        Dropdown,     // button with chevron-down opening popup
    };

    struct ToolbarItem {
        ItemKind              kind;
        WORD                  id;
        const wchar_t*        label;       // text (can be empty for icon-only)
        const wchar_t*        tooltip;     // tooltip text
        const char*           iconName;    // Lucide icon name
        int                   baseWidth;
        bool                  rightAlign;
        const DropdownChoice* choices;     // dropdown choices (nullptr for non-dropdown)
        int                   choiceCount; // number of choices
    };

    // Dropdown choices for View button
    static constexpr DropdownChoice kViewChoices[] = {
        { IDC_TB_VIEW_LARGE,   L"Large Icons",  "view-large-icons" },
        { IDC_TB_VIEW_SMALL,   L"Small Icons",  "view-small-icons" },
        { IDC_TB_VIEW_LIST,    L"List View",    "view-list" },
        { IDC_TB_VIEW_DETAILS, L"Details View", "view-details" },
    };

    static constexpr ToolbarItem kItems[] = {
        { ItemKind::Dropdown,  IDC_TB_VIEW,         L"View",    L"View Mode",    "view-list",          86, false, kViewChoices, 4 },
        { ItemKind::Separator, 0,                   nullptr,    nullptr,         nullptr,               9, false, nullptr, 0 },
        { ItemKind::Button,    IDC_TB_REFRESH,      L"",        L"Refresh",      "refresh",            36, false, nullptr, 0 },
        { ItemKind::Separator, 0,                   nullptr,    nullptr,         nullptr,               9, true,  nullptr, 0 },
        { ItemKind::Button,    IDC_TB_SETTINGS,     L"",        L"Settings",     "settings",           36, true,  nullptr, 0 },
        { ItemKind::Button,    IDC_TB_THEME,        L"",        L"Toggle Theme", "theme-dark",         36, true,  nullptr, 0 },
    };
    static constexpr int kItemCount = _countof(kItems);

    HWND  m_hwnd       = nullptr;
    HWND  m_parent     = nullptr;
    int   m_hovered    = -1;
    int   m_pressed    = -1;     // currently pressed button index
    int   m_focused    = -1;     // keyboard-focused button index
    bool  m_kbFocus    = false;  // true when focus from keyboard (show ring)
    int   m_dpi        = 96;
    bool  m_compact    = false;  // true = icon-only mode (labels hidden)
    int   m_overflowStart = -1; // index of first overflowed left-aligned item (-1 = none)
    ComPtr<ID2D1HwndRenderTarget> m_rt;

    // Icon bitmaps
    ComPtr<ID2D1Bitmap> m_iconBitmaps[kItemCount];
    ComPtr<ID2D1Bitmap> m_accentIconBitmaps[kItemCount];
    int      m_cachedIconSize    = 0;
    uint32_t m_cachedIconColor   = 0;
    uint32_t m_cachedAccentColor = 0;

    // ── Animation State ─────────────────────────────────────
    // Hover glow (per-item opacity 0..1)
    float    m_hoverAlpha[kItemCount] = {};
    uint32_t m_hoverAnimId[kItemCount] = {};

    // Button press scale (1.0 = normal, 0.96 = pressed)
    float    m_pressScale[kItemCount] = {};

    // Active indicator position (animated X of underline)
    float    m_indicatorX     = 0.0f;
    float    m_indicatorW     = 0.0f;
    uint32_t m_indicatorAnimId = 0;

    // Tooltip
    int      m_tooltipIdx   = -1;
    UINT_PTR m_tooltipTimer = 0;
    float    m_tooltipAlpha = 0.0f;

    // Refresh rotation
    float    m_refreshAngle   = 0.0f;
    uint32_t m_refreshAnimId  = 0;



    // ── Helpers ─────────────────────────────────────────────
    int  ItemWidth(int idx) const;
    int  Pad() const;
    int  Margin() const;
    int  Height() const;
    int  IconSize() const;
    void CreateRenderTarget();
    void RebuildIconCache();
    D2D1_RECT_F ItemRect(int idx, float totalWidth) const;
    int  HitTest(int mx, int my, float totalWidth);
    void OnPaint();

    void AnimateHover(int idx, bool entering);
    void AnimateIndicator(int btnIdx, float totalWidth);
    void AnimateRefreshSpin();
    void ShowTooltip(int idx);
    void HideTooltip();

    const char* CurrentThemeIcon() const;



    static LRESULT CALLBACK ToolbarProc(HWND, UINT, WPARAM, LPARAM);
};

} // namespace rui
