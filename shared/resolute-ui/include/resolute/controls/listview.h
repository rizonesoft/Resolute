#pragma once
// ── ResoluteUI Custom D2D ListView Control ───────────────────────
// Full Direct2D-rendered list view with virtual scrolling,
// multi-view modes, animated selection, column headers with
// sort indicators, drag-resize, inline editing, and row striping.

#include <windows.h>
#include <wrl/client.h>
#include <d2d1.h>
#include <dwrite.h>
#include <string>
#include <vector>
#include <functional>
#include "../export.h"
#include "../dpi.h"
#include "../theme.h"
#include "../render.h"
#include "../animation.h"
#include <unordered_map>

using Microsoft::WRL::ComPtr;

namespace rui {

// ── View Modes ──────────────────────────────────────────────
enum class ViewMode { LargeIcons, SmallIcons, List, Details };

// ── Sort Direction ──────────────────────────────────────────
enum class SortDir { None, Ascending, Descending };

// ── Command IDs ─────────────────────────────────────────────
inline constexpr int IDC_LISTVIEW_SELECT = 3001;
inline constexpr int IDC_LISTVIEW_DBLCLK = 3002;
inline constexpr int IDC_LISTVIEW_EDITED = 3003;
inline constexpr int IDC_LISTVIEW_SORT   = 3004;

// ── Data Structures ─────────────────────────────────────────
struct ListColumn {
    std::wstring label;
    float        width     = 120.0f;    // unscaled pixels
    bool         sortable  = true;
    DWRITE_TEXT_ALIGNMENT align = DWRITE_TEXT_ALIGNMENT_LEADING;
};

struct ListItem {
    std::vector<std::wstring> cells;
    HICON icon = nullptr;     // Win32 icon (shell, app, file type)
    std::wstring category;    // EXOEXT category for sidebar filtering
};

// ── Item Provider Callback ──────────────────────────────────
using ItemProvider = std::function<const ListItem&(int index)>;

// ═══════════════════════════════════════════════════════════
class RESUI_API ListView {
public:
    // ── Layout Constants (unscaled) ─────────────────────────
    static constexpr int BASE_ROW_HEIGHT       = 28;
    static constexpr int BASE_HEADER_HEIGHT    = 32;
    static constexpr int BASE_ICON_LARGE       = 32;
    static constexpr int BASE_ICON_SMALL       = 16;
    static constexpr int BASE_FONT_SIZE        = 13;
    static constexpr int BASE_HEADER_FONT      = 12;
    static constexpr int BASE_PADDING_X        = 8;
    static constexpr int BASE_LARGE_CELL_W     = 96;
    static constexpr int BASE_LARGE_CELL_H     = 80;
    static constexpr int BASE_SCROLLBAR_W      = 6;
    static constexpr int RESIZE_ZONE           = 4;   // px each side of column edge

    // ── Public API ──────────────────────────────────────────
    void Create(HWND parent, HINSTANCE hInst, int id);
    HWND Handle() const;
    void Resize(int x, int y, int w, int h);
    void Repaint();
    void UpdateDpi(int dpi);

    // ── Data ────────────────────────────────────────────────
    void SetItemCount(int count);
    void SetItemProvider(ItemProvider fn);
    int  ItemCount() const;

    // ── Columns (Details mode) ──────────────────────────────
    void AddColumn(const wchar_t* label, float width,
                   bool sortable = true,
                   DWRITE_TEXT_ALIGNMENT align = DWRITE_TEXT_ALIGNMENT_LEADING);
    void ClearColumns();
    int  ColumnCount() const;

    // ── View Mode ───────────────────────────────────────────
    void     SetViewMode(ViewMode mode);
    ViewMode GetViewMode() const;

    // ── Selection ───────────────────────────────────────────
    int  SelectedIndex() const;
    void Select(int index);

    // ── Sorting ─────────────────────────────────────────────
    void    SetSortColumn(int colIdx, bool ascending);
    int     SortColumn() const;
    SortDir SortDirection() const;

    // ── Inline Editing ──────────────────────────────────────
    void BeginEdit(int itemIdx, int colIdx = 0);
    void EndEdit(bool commit);
    bool IsEditing() const;

    // ── Scroll ──────────────────────────────────────────────
    void ScrollToItem(int index);
    void EnsureVisible(int index);

    // ── Fallback Icon ───────────────────────────────────────
    void SetFallbackIcon(HICON icon);

private:
    HWND m_hwnd     = nullptr;
    HWND m_parent   = nullptr;
    int  m_id       = 0;
    int  m_dpi      = 96;
    ComPtr<ID2D1HwndRenderTarget> m_rt;

    // ── Icon Bitmap Cache (HICON → D2D1Bitmap) ──────────────
    std::unordered_map<HICON, ComPtr<ID2D1Bitmap>> m_iconCache;
    HICON m_fallbackIcon = nullptr;
    ID2D1Bitmap* GetIconBitmap(HICON hIcon);

    // ── Data Model ──────────────────────────────────────────
    int          m_itemCount = 0;
    ItemProvider m_provider;
    std::vector<ListColumn> m_columns;

    // ── View ────────────────────────────────────────────────
    ViewMode m_viewMode = ViewMode::Details;

    // ── Scroll State ────────────────────────────────────────
    float    m_scrollY       = 0.0f;
    float    m_scrollTargetY = 0.0f;
    uint32_t m_scrollAnimId  = 0;

    // Scrollbar
    bool  m_scrollbarVisible   = false;
    bool  m_scrollbarHovered   = false;
    bool  m_scrollbarDragging  = false;
    float m_scrollbarDragStart = 0.0f;
    float m_scrollDragStartY   = 0.0f;
    float m_scrollbarAlpha     = 0.0f;
    uint32_t m_scrollbarFadeId = 0;
    UINT_PTR m_scrollbarTimer  = 0;

    // ── Selection ───────────────────────────────────────────
    int      m_selected       = -1;
    float    m_selHighlightY  = 0.0f;    // animated Y of selection rect
    uint32_t m_selAnimId      = 0;
    float    m_selAlpha       = 0.0f;
    uint32_t m_selFadeId      = 0;

    // ── Hover ───────────────────────────────────────────────
    int      m_hovered        = -1;
    float    m_hoverAlpha     = 0.0f;
    uint32_t m_hoverAnimId    = 0;

    // ── Sort ────────────────────────────────────────────────
    int      m_sortCol        = -1;
    bool     m_sortAscending  = true;
    float    m_sortChevronAngle = 0.0f;
    uint32_t m_sortAnimId     = 0;

    // ── Column Resize ───────────────────────────────────────
    int   m_resizingCol    = -1;
    float m_resizeStartX   = 0.0f;
    float m_resizeOrigW    = 0.0f;

    // ── Inline Edit ─────────────────────────────────────────
    bool         m_editActive     = false;
    int          m_editItemIdx    = -1;
    int          m_editColIdx     = 0;
    std::wstring m_editText;
    int          m_editCursorPos  = 0;
    float        m_cursorBlinkPhase = 0.0f;
    uint32_t     m_cursorAnimId   = 0;
    UINT_PTR     m_editClickTimer = 0;    // slow double-click detection
    int          m_lastClickIdx   = -1;

    // ── Header Hover ────────────────────────────────────────
    int      m_headerHovered  = -1;
    float    m_headerHoverAlpha = 0.0f;
    uint32_t m_headerHoverAnimId = 0;

    // ── Internal Methods ────────────────────────────────────
    void CreateRenderTarget();
    void OnPaint();

    // Layout helpers
    float RowHeight() const;
    float HeaderHeight() const;
    float ContentTop() const;          // below header in Details mode
    float TotalContentHeight() const;
    float MaxScrollY() const;
    float ColumnX(int colIdx) const;   // left edge of column
    float TotalColumnsWidth() const;

    // Hit-testing
    int  HitTestRow(int my) const;
    int  HitTestColumn(int mx) const;
    int  HitTestColumnEdge(int mx) const;  // returns col index whose right edge is near mx, or -1
    bool HitTestScrollbar(int mx, int my) const;

    // Grid layout (icon modes)
    int  GridCols() const;
    int  GridRows() const;
    float CellWidth() const;
    float CellHeight() const;
    int  GridHitTest(int mx, int my) const;
    D2D1_RECT_F GridCellRect(int index) const;

    // Scrollbar
    D2D1_RECT_F ScrollbarTrackRect() const;
    D2D1_RECT_F ScrollbarThumbRect() const;
    void ShowScrollbar();
    void ScheduleScrollbarHide();
    void AnimateScrollTo(float targetY);

    // Selection animation
    void AnimateSelection(int newIdx);
    void AnimateHover(int newIdx);

    // Painting sub-routines (all share a single reusable brush)
    void PaintDetails(const D2D1_SIZE_F& size, ID2D1SolidColorBrush* br);
    void PaintIcons(const D2D1_SIZE_F& size, bool large, ID2D1SolidColorBrush* br);
    void PaintList(const D2D1_SIZE_F& size, ID2D1SolidColorBrush* br);
    void PaintHeader(const D2D1_SIZE_F& size, ID2D1SolidColorBrush* br);
    void PaintScrollbar(const D2D1_SIZE_F& size, ID2D1SolidColorBrush* br);
    void PaintInlineEdit(const D2D1_RECT_F& cellRect, ID2D1SolidColorBrush* br);

    static LRESULT CALLBACK ListViewProc(HWND, UINT, WPARAM, LPARAM);
};

} // namespace rui
