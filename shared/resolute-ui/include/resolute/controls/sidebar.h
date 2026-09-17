#pragma once
// ── ResoluteUI Sidebar Control ───────────────────────────────────
// Animated sidebar with selection slide, hover fade, icon pulse,
// collapse/expand, staggered entry, and ripple effects.

#include <windows.h>
#include <wrl/client.h>
#include <d2d1.h>
#include <commctrl.h>
#include "../export.h"
#include "../dpi.h"
#include "../theme.h"
#include "../render.h"
#include "../icons.h"
#include "../animation.h"

using Microsoft::WRL::ComPtr;

namespace rui {

struct SidebarItem {
    const wchar_t* label;
    const char*    iconName;
};

inline constexpr SidebarItem kCategories[] = {
    { L"All",        "view-list"  },
    { L"System",     "system"     },
    { L"Network",    "network"    },
    { L"Security",   "security"   },
    { L"Display",    "display"    },
    { L"Programs",   "programs"   },
};
inline constexpr int kCategoryCount = _countof(kCategories);

class RESUI_API Sidebar {
public:
    static constexpr int BASE_WIDTH       = 200;
    static constexpr int BASE_ITEM_HEIGHT = 40;
    static constexpr int BASE_PADDING_X   = 16;
    static constexpr int BASE_FONT_SIZE   = 14;
    static constexpr int BASE_HEADER_FONT = 11;
    static constexpr int BASE_ICON_SIZE   = 18;

    int  ScaledWidth() const;
    void Create(HWND parent, HINSTANCE hInst, int id);
    HWND Handle() const;
    int  Selected() const;
    void Resize(int x, int y, int w, int h);
    void Repaint();
    void UpdateDpi(int dpi);

    // Badge counts
    void SetBadge(int idx, int count);
    int  Badge(int idx) const;

    // Collapse/expand
    bool IsCollapsed() const;
    void SetCollapsed(bool collapsed);
    void ToggleCollapsed();
    int  TargetWidth() const;  // current animated width target

private:
    HWND m_hwnd     = nullptr;
    HWND m_parent   = nullptr;
    HWND m_tooltip   = nullptr;
    SidebarItem m_items[kCategoryCount] = {};  // mutable copy for reorder
    int  m_selected = 0;
    int  m_hovered  = -1;
    int  m_focused  = -1;     // keyboard focus index
    bool m_kbFocus  = false;  // true when control has keyboard focus
    int  m_pressed  = -1;     // currently pressed item (mousedown)
    int  m_dpi      = 96;
    int  m_badgeCounts[kCategoryCount] = {};

    // Search/filter state
    wchar_t m_searchText[64] = {};
    int     m_searchLen = 0;
    bool    m_searchVisible[kCategoryCount] = {true,true,true,true,true,true};
    void    ApplyFilter();
    ComPtr<ID2D1HwndRenderTarget> m_rt;
    ComPtr<ID2D1Bitmap> m_iconBitmaps[kCategoryCount];       // normal color
    ComPtr<ID2D1Bitmap> m_accentIconBitmaps[kCategoryCount]; // accent color
    int      m_cachedIconSize    = 0;
    uint32_t m_cachedIconColor   = 0;
    uint32_t m_cachedAccentColor = 0;

    // ── Animation State ─────────────────────────────────────
    // Selection slide (animated Y position of accent bar)
    float m_selectionY   = 0.0f;  // current animated Y
    float m_selectionTargetY = 0.0f;
    uint32_t m_selAnimId = 0;

    // Hover fade (per-item opacity 0..1)
    float m_hoverAlpha[kCategoryCount] = {};
    uint32_t m_hoverAnimId[kCategoryCount] = {};

    // Icon pulse (per-item scale, 1.0 = normal)
    float m_iconScale[kCategoryCount] = {};

    // Staggered item enter (per-item opacity 0..1)
    float m_enterAlpha[kCategoryCount] = {};
    bool  m_entered = false;



    // Collapse/expand
    bool  m_collapsed    = false;
    float m_widthFactor  = 1.0f;   // 1.0 = full, icon-only fraction when collapsed
    uint32_t m_collapseAnimId = 0;

    // Drag reorder
    bool  m_dragging     = false;
    int   m_dragSrc      = -1;     // source item index
    int   m_dragTarget   = -1;     // current drop target
    float m_dragOffsetY  = 0.0f;   // mouse offset within item
    float m_dragY        = 0.0f;   // current mouse Y
    bool  m_chevronHovered = false;  // chevron hover state

    // ── Helpers ─────────────────────────────────────────────
    int   ItemHeight() const;
    int   PaddingX() const;
    int   IconSize() const;
    float YStart() const;
    float ItemYCenter(int idx) const;
    void  CreateRenderTarget();
    void  RebuildIconCache();
    void  OnPaint();
    int   HitTest(int y);

    void  AnimateSelection(int newIdx);
    void  AnimateHover(int idx, bool entering);
    void  AnimateIconPulse(int idx);
    void  AnimateEnter();
    void  AnimateCollapse(bool collapse);

    static LRESULT CALLBACK SidebarProc(HWND, UINT, WPARAM, LPARAM);
};

} // namespace rui
