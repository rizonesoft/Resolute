#include <resolute/controls/listview.h>
#include <resolute/typography.h>
#include <resolute/render.h>
#include <resolute/icons.h>
#include <windowsx.h>
#include <cmath>
#include <algorithm>

namespace rui {

// ── Accessors ───────────────────────────────────────────────
HWND ListView::Handle() const { return m_hwnd; }
int  ListView::ItemCount() const { return m_itemCount; }
int  ListView::ColumnCount() const { return static_cast<int>(m_columns.size()); }
ViewMode ListView::GetViewMode() const { return m_viewMode; }
int  ListView::SelectedIndex() const { return m_selected; }
int  ListView::SortColumn() const { return m_sortCol; }
bool ListView::IsEditing() const { return m_editActive; }
SortDir ListView::SortDirection() const {
    if (m_sortCol < 0) return SortDir::None;
    return m_sortAscending ? SortDir::Ascending : SortDir::Descending;
}

// ── Scaled helpers ──────────────────────────────────────────
float ListView::RowHeight() const { return Dpi::ScaleF(static_cast<float>(BASE_ROW_HEIGHT), m_dpi); }
float ListView::HeaderHeight() const { return Dpi::ScaleF(static_cast<float>(BASE_HEADER_HEIGHT), m_dpi); }
float ListView::ContentTop() const { return (m_viewMode == ViewMode::Details) ? HeaderHeight() : 0.0f; }
float ListView::CellWidth() const { return Dpi::ScaleF(static_cast<float>(BASE_LARGE_CELL_W), m_dpi); }
float ListView::CellHeight() const { return Dpi::ScaleF(static_cast<float>(BASE_LARGE_CELL_H), m_dpi); }

float ListView::TotalContentHeight() const {
    switch (m_viewMode) {
    case ViewMode::Details: return static_cast<float>(m_itemCount) * RowHeight();
    case ViewMode::LargeIcons:
    case ViewMode::SmallIcons: {
        int cols = GridCols();
        if (cols < 1) cols = 1;
        int rows = (m_itemCount + cols - 1) / cols;
        return static_cast<float>(rows) * CellHeight();
    }
    case ViewMode::List: return static_cast<float>(m_itemCount) * RowHeight();
    }
    return 0.0f;
}

float ListView::MaxScrollY() const {
    RECT rc; GetClientRect(m_hwnd, &rc);
    float viewH = static_cast<float>(rc.bottom) - ContentTop();
    float total = TotalContentHeight();
    return (std::max)(0.0f, total - viewH);
}

float ListView::ColumnX(int colIdx) const {
    float x = 0.0f;
    for (int i = 0; i < colIdx && i < static_cast<int>(m_columns.size()); i++)
        x += Dpi::ScaleF(m_columns[i].width, m_dpi);
    return x;
}

float ListView::TotalColumnsWidth() const {
    float w = 0.0f;
    for (auto& col : m_columns) w += Dpi::ScaleF(col.width, m_dpi);
    return w;
}

int ListView::GridCols() const {
    RECT rc; GetClientRect(m_hwnd, &rc);
    float cw = (m_viewMode == ViewMode::SmallIcons) ? CellWidth() * 1.8f : CellWidth();
    int cols = static_cast<int>(static_cast<float>(rc.right) / cw);
    return (std::max)(1, cols);
}

int ListView::GridRows() const {
    int cols = GridCols();
    return (m_itemCount + cols - 1) / cols;
}

// ── Create ──────────────────────────────────────────────────
void ListView::Create(HWND parent, HINSTANCE hInst, int id) {
    m_parent = parent;
    m_id = id;

    WNDCLASSEXW wc{};
    wc.cbSize = sizeof(wc);
    wc.style = CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS;
    wc.lpfnWndProc = ListViewProc;
    wc.hInstance = hInst;
    wc.hCursor = LoadCursorW(nullptr, IDC_ARROW);
    wc.lpszClassName = L"ResoluteListView";
    RegisterClassExW(&wc);

    m_hwnd = CreateWindowExW(0, L"ResoluteListView", nullptr,
        WS_CHILD | WS_VISIBLE | WS_TABSTOP,
        0, 0, 400, 400, parent,
        reinterpret_cast<HMENU>(static_cast<INT_PTR>(id)),
        hInst, this);

    m_dpi = Dpi::Get(m_hwnd);
    CreateRenderTarget();
}

void ListView::CreateRenderTarget() {
    m_rt = RenderContext::CreateHwndTarget(m_hwnd);
    m_iconCache.clear();  // Bitmaps are device-dependent — invalidate on RT change
}

// ── HICON → D2D1Bitmap Converter ────────────────────────────
ID2D1Bitmap* ListView::GetIconBitmap(HICON hIcon) {
    if (!hIcon || !m_rt) return nullptr;

    auto it = m_iconCache.find(hIcon);
    if (it != m_iconCache.end()) return it->second.Get();

    // Get icon info
    ICONINFO ii{};
    if (!GetIconInfo(hIcon, &ii)) return nullptr;

    BITMAP bm{};
    GetObject(ii.hbmColor ? ii.hbmColor : ii.hbmMask, sizeof(bm), &bm);
    int w = bm.bmWidth;
    int h = bm.bmHeight;
    if (w <= 0 || h <= 0) {
        if (ii.hbmColor) DeleteObject(ii.hbmColor);
        if (ii.hbmMask) DeleteObject(ii.hbmMask);
        return nullptr;
    }

    // Extract BGRA pixels via GetDIBits
    HDC hdc = GetDC(nullptr);
    BITMAPINFO bmi{};
    bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bmi.bmiHeader.biWidth = w;
    bmi.bmiHeader.biHeight = -h;  // top-down
    bmi.bmiHeader.biPlanes = 1;
    bmi.bmiHeader.biBitCount = 32;
    bmi.bmiHeader.biCompression = BI_RGB;

    std::vector<uint8_t> pixels(w * h * 4);
    if (ii.hbmColor) {
        GetDIBits(hdc, ii.hbmColor, 0, h, pixels.data(), &bmi, DIB_RGB_COLORS);
    }
    ReleaseDC(nullptr, hdc);
    if (ii.hbmColor) DeleteObject(ii.hbmColor);
    if (ii.hbmMask) DeleteObject(ii.hbmMask);

    // Detect if icon has a real alpha channel:
    // Scan all pixels — if ANY has non-zero alpha, alpha channel is valid.
    // Legacy 24-bit icons have all alpha bytes = 0.
    bool hasAlpha = false;
    for (int i = 0; i < w * h; i++) {
        if (pixels[i * 4 + 3] != 0) { hasAlpha = true; break; }
    }

    // Convert BGRA → premultiplied RGBA
    for (int i = 0; i < w * h; i++) {
        uint8_t b = pixels[i * 4 + 0];
        uint8_t g = pixels[i * 4 + 1];
        uint8_t r = pixels[i * 4 + 2];
        uint8_t a = hasAlpha ? pixels[i * 4 + 3] : 255;
        pixels[i * 4 + 0] = static_cast<uint8_t>(r * a / 255);
        pixels[i * 4 + 1] = static_cast<uint8_t>(g * a / 255);
        pixels[i * 4 + 2] = static_cast<uint8_t>(b * a / 255);
        pixels[i * 4 + 3] = a;
    }

    // Create D2D bitmap
    D2D1_BITMAP_PROPERTIES bmpProps = D2D1::BitmapProperties(
        D2D1::PixelFormat(DXGI_FORMAT_R8G8B8A8_UNORM, D2D1_ALPHA_MODE_PREMULTIPLIED)
    );
    bmpProps.dpiX = 96.0f;
    bmpProps.dpiY = 96.0f;

    ComPtr<ID2D1Bitmap> bitmap;
    m_rt->CreateBitmap(D2D1::SizeU(w, h), pixels.data(), w * 4, bmpProps, &bitmap);

    if (bitmap) {
        m_iconCache[hIcon] = bitmap;
        return bitmap.Get();
    }
    return nullptr;
}

void ListView::Resize(int x, int y, int w, int h) {
    MoveWindow(m_hwnd, x, y, w, h, TRUE);
    if (m_rt) m_rt->Resize(D2D1::SizeU(w, h));
    // Clamp scroll
    float maxS = MaxScrollY();
    if (m_scrollY > maxS) { m_scrollY = maxS; m_scrollTargetY = maxS; }
    m_scrollbarVisible = TotalContentHeight() > static_cast<float>(h) - ContentTop();
}

void ListView::Repaint() { InvalidateRect(m_hwnd, nullptr, FALSE); }

void ListView::UpdateDpi(int dpi) {
    m_dpi = dpi;
    // Recalculate DPI-dependent cached positions
    if (m_selected >= 0) {
        float rh = RowHeight();
        m_selHighlightY = static_cast<float>(m_selected) * rh + ContentTop();
    }
    Repaint();
}

void ListView::SetFallbackIcon(HICON icon) { m_fallbackIcon = icon; }

// ── Data ────────────────────────────────────────────────────
void ListView::SetItemCount(int count) { m_itemCount = count; m_scrollbarVisible = true; Repaint(); }
void ListView::SetItemProvider(ItemProvider fn) { m_provider = std::move(fn); Repaint(); }

// ── Columns ─────────────────────────────────────────────────
void ListView::AddColumn(const wchar_t* label, float width, bool sortable, DWRITE_TEXT_ALIGNMENT align) {
    m_columns.push_back({label ? label : L"", width, sortable, align});
    Repaint();
}

void ListView::ClearColumns() { m_columns.clear(); Repaint(); }

// ── View Mode ───────────────────────────────────────────────
void ListView::SetViewMode(ViewMode mode) {
    if (mode == m_viewMode) return;
    m_viewMode = mode;
    m_scrollY = 0.0f; m_scrollTargetY = 0.0f;
    if (m_selected >= 0) {
        float rh = RowHeight();
        m_selHighlightY = static_cast<float>(m_selected) * rh + ContentTop();
    }
    Repaint();
}

// ── Selection ───────────────────────────────────────────────
void ListView::Select(int index) {
    if (index < 0 || index >= m_itemCount) return;
    if (index == m_selected) return;
    AnimateSelection(index);
}

void ListView::AnimateSelection(int newIdx) {
    int oldIdx = m_selected;
    m_selected = newIdx;
    auto& mgr = AnimationManager::Instance();
    float rh = RowHeight();
    float newY = static_cast<float>(newIdx) * rh + ContentTop();

    if (oldIdx < 0) {
        m_selHighlightY = newY;
        if (m_selFadeId) mgr.Cancel(m_selFadeId);
        m_selFadeId = mgr.Animate(0.0f, 1.0f, 150.0f, ease::OutQuad,
            [this](float v, const Animation&) { m_selAlpha = v; Repaint(); },
            [this]() { m_selFadeId = 0; });
        return;
    }

    if (m_selAnimId) mgr.Cancel(m_selAnimId);
    float fromY = m_selHighlightY;
    m_selAnimId = mgr.Animate(fromY, newY, 180.0f, ease::OutQuart,
        [this](float v, const Animation&) { m_selHighlightY = v; Repaint(); },
        [this]() { m_selAnimId = 0; });
    m_selAlpha = 1.0f;
}

void ListView::AnimateHover(int newIdx) {
    if (newIdx == m_hovered) return;
    m_hovered = newIdx;
    auto& mgr = AnimationManager::Instance();
    if (m_hoverAnimId) mgr.Cancel(m_hoverAnimId);

    if (newIdx >= 0) {
        m_hoverAnimId = mgr.Animate(m_hoverAlpha, 1.0f, 100.0f, ease::OutQuad,
            [this](float v, const Animation&) { m_hoverAlpha = v; Repaint(); },
            [this]() { m_hoverAnimId = 0; });
    } else {
        m_hoverAnimId = mgr.Animate(m_hoverAlpha, 0.0f, 150.0f, ease::InQuad,
            [this](float v, const Animation&) { m_hoverAlpha = v; Repaint(); },
            [this]() { m_hoverAnimId = 0; });
    }
}

// ── Sorting ─────────────────────────────────────────────────
void ListView::SetSortColumn(int colIdx, bool ascending) {
    auto& mgr = AnimationManager::Instance();
    bool sameCol = (colIdx == m_sortCol);
    m_sortCol = colIdx;
    m_sortAscending = ascending;

    if (m_sortAnimId) mgr.Cancel(m_sortAnimId);
    float targetAngle = ascending ? 0.0f : 180.0f;
    float fromAngle = m_sortChevronAngle;
    if (!sameCol) fromAngle = targetAngle; // no rotation on new column

    m_sortAnimId = mgr.Animate(fromAngle, targetAngle, 200.0f, ease::OutCubic,
        [this](float v, const Animation&) { m_sortChevronAngle = v; Repaint(); },
        [this]() { m_sortAnimId = 0; });

    SendMessageW(m_parent, WM_COMMAND, MAKEWPARAM(IDC_LISTVIEW_SORT, 0),
        reinterpret_cast<LPARAM>(m_hwnd));
}

// ── Scroll ──────────────────────────────────────────────────
void ListView::AnimateScrollTo(float targetY) {
    targetY = std::clamp(targetY, 0.0f, MaxScrollY());
    m_scrollTargetY = targetY;
    auto& mgr = AnimationManager::Instance();
    if (m_scrollAnimId) mgr.Cancel(m_scrollAnimId);

    m_scrollAnimId = mgr.Animate(m_scrollY, targetY, 250.0f, ease::OutQuart,
        [this](float v, const Animation&) { m_scrollY = v; Repaint(); },
        [this]() { m_scrollAnimId = 0; });

    ShowScrollbar();
}

void ListView::ScrollToItem(int index) {
    float rh = RowHeight();
    AnimateScrollTo(static_cast<float>(index) * rh);
}

void ListView::EnsureVisible(int index) {
    if (index < 0) return;
    RECT rc; GetClientRect(m_hwnd, &rc);
    float viewH = static_cast<float>(rc.bottom) - ContentTop();
    float rh = RowHeight();
    float itemTop = static_cast<float>(index) * rh;
    float itemBot = itemTop + rh;

    if (itemTop < m_scrollTargetY)
        AnimateScrollTo(itemTop);
    else if (itemBot > m_scrollTargetY + viewH)
        AnimateScrollTo(itemBot - viewH);
}

// ── Scrollbar ───────────────────────────────────────────────
D2D1_RECT_F ListView::ScrollbarTrackRect() const {
    RECT rc; GetClientRect(m_hwnd, &rc);
    float w = Dpi::ScaleF(static_cast<float>(BASE_SCROLLBAR_W), m_dpi);
    float top = ContentTop();
    return D2D1::RectF(static_cast<float>(rc.right) - w - 2.0f, top + 2.0f,
                       static_cast<float>(rc.right) - 2.0f, static_cast<float>(rc.bottom) - 2.0f);
}

D2D1_RECT_F ListView::ScrollbarThumbRect() const {
    auto track = ScrollbarTrackRect();
    float trackH = track.bottom - track.top;
    float total = TotalContentHeight();
    if (total <= 0.001f) return track;
    RECT rc; GetClientRect(m_hwnd, &rc);
    float viewH = static_cast<float>(rc.bottom) - ContentTop();
    float thumbH = (std::max)(20.0f, trackH * (viewH / total));
    float thumbTop = track.top + (trackH - thumbH) * (m_scrollY / (std::max)(1.0f, total - viewH));
    return D2D1::RectF(track.left, thumbTop, track.right, thumbTop + thumbH);
}

bool ListView::HitTestScrollbar(int mx, int my) const {
    auto track = ScrollbarTrackRect();
    float fmx = static_cast<float>(mx), fmy = static_cast<float>(my);
    return fmx >= track.left - 4 && fmx <= track.right + 4 &&
           fmy >= track.top && fmy <= track.bottom;
}

void ListView::ShowScrollbar() {
    auto& mgr = AnimationManager::Instance();
    if (m_scrollbarFadeId) mgr.Cancel(m_scrollbarFadeId);
    m_scrollbarAlpha = 1.0f;
    ScheduleScrollbarHide();
    Repaint();
}

void ListView::ScheduleScrollbarHide() {
    if (m_scrollbarTimer) KillTimer(m_hwnd, m_scrollbarTimer);
    if (!m_scrollbarHovered && !m_scrollbarDragging)
        m_scrollbarTimer = SetTimer(m_hwnd, 0xAA01, 1200, nullptr);
}

// ── Hit Testing ─────────────────────────────────────────────
int ListView::HitTestRow(int my) const {
    float fmy = static_cast<float>(my);
    if (fmy < ContentTop()) return -1;
    float rowIdx = (fmy - ContentTop() + m_scrollY) / RowHeight();
    int idx = static_cast<int>(rowIdx);
    return (idx >= 0 && idx < m_itemCount) ? idx : -1;
}

int ListView::HitTestColumn(int mx) const {
    float fmx = static_cast<float>(mx);
    float x = 0.0f;
    for (int i = 0; i < static_cast<int>(m_columns.size()); i++) {
        float w = Dpi::ScaleF(m_columns[i].width, m_dpi);
        if (fmx >= x && fmx < x + w) return i;
        x += w;
    }
    return -1;
}

int ListView::HitTestColumnEdge(int mx) const {
    float fmx = static_cast<float>(mx);
    float x = 0.0f;
    float zone = Dpi::ScaleF(static_cast<float>(RESIZE_ZONE), m_dpi);
    for (int i = 0; i < static_cast<int>(m_columns.size()); i++) {
        x += Dpi::ScaleF(m_columns[i].width, m_dpi);
        if (std::abs(fmx - x) <= zone) return i;
    }
    return -1;
}

D2D1_RECT_F ListView::GridCellRect(int index) const {
    int cols = GridCols();
    int row = index / cols;
    int col = index % cols;
    float cw = (m_viewMode == ViewMode::SmallIcons) ? CellWidth() * 1.8f : CellWidth();
    float ch = CellHeight();
    float x = static_cast<float>(col) * cw;
    float y = static_cast<float>(row) * ch - m_scrollY + ContentTop();
    return D2D1::RectF(x, y, x + cw, y + ch);
}

int ListView::GridHitTest(int mx, int my) const {
    float fmy = static_cast<float>(my);
    if (fmy < ContentTop()) return -1;
    int cols = GridCols();
    float cw = (m_viewMode == ViewMode::SmallIcons) ? CellWidth() * 1.8f : CellWidth();
    float ch = CellHeight();
    int col = static_cast<int>(static_cast<float>(mx) / cw);
    int row = static_cast<int>((fmy - ContentTop() + m_scrollY) / ch);
    if (col < 0 || col >= cols) return -1;
    int idx = row * cols + col;
    return (idx >= 0 && idx < m_itemCount) ? idx : -1;
}

// ── Inline Editing ──────────────────────────────────────────
void ListView::BeginEdit(int itemIdx, int colIdx) {
    if (!m_provider || itemIdx < 0 || itemIdx >= m_itemCount) return;
    auto& item = m_provider(itemIdx);
    if (colIdx >= static_cast<int>(item.cells.size())) return;

    m_editActive = true;
    m_editItemIdx = itemIdx;
    m_editColIdx = colIdx;
    m_editText = item.cells[colIdx];
    m_editCursorPos = static_cast<int>(m_editText.length());

    auto& mgr = AnimationManager::Instance();
    if (m_cursorAnimId) mgr.Cancel(m_cursorAnimId);

    struct BlinkLoop {
        static void Start(ListView* lv) {
            lv->m_cursorAnimId = AnimationManager::Instance().Animate(
                0.0f, 1.0f, 1000.0f, ease::Linear,
                [lv](float v, const Animation&) { lv->m_cursorBlinkPhase = v; lv->Repaint(); },
                [lv]() { lv->m_cursorAnimId = 0; BlinkLoop::Start(lv); });
        }
    };
    BlinkLoop::Start(this);
    Repaint();
}

void ListView::EndEdit(bool commit) {
    if (!m_editActive) return;
    auto& mgr = AnimationManager::Instance();
    if (m_cursorAnimId) { mgr.Cancel(m_cursorAnimId); m_cursorAnimId = 0; }
    m_editActive = false;

    if (commit) {
        SendMessageW(m_parent, WM_COMMAND, MAKEWPARAM(IDC_LISTVIEW_EDITED, 0),
            reinterpret_cast<LPARAM>(m_hwnd));
    }
    Repaint();
}

// ── Paint ───────────────────────────────────────────────────
// PERF: A single reusable brush is created once per OnPaint and shared
// across all sub-routines via SetColor(). This avoids dozens of
// CreateSolidColorBrush COM allocations per frame.

void ListView::OnPaint() {
    if (!m_rt) { CreateRenderTarget(); if (!m_rt) return; }
    auto& c = Theme::Colors();
    m_rt->BeginDraw();
    m_rt->Clear(ToD2DColor(c.background));
    auto size = m_rt->GetSize();

    // Single reusable brush for the entire paint cycle
    ComPtr<ID2D1SolidColorBrush> brush;
    m_rt->CreateSolidColorBrush(D2D1::ColorF(0, 0), &brush);
    if (!brush) { m_rt->EndDraw(); return; }

    switch (m_viewMode) {
    case ViewMode::Details:   PaintDetails(size, brush.Get()); break;
    case ViewMode::LargeIcons: PaintIcons(size, true, brush.Get()); break;
    case ViewMode::SmallIcons: PaintIcons(size, false, brush.Get()); break;
    case ViewMode::List:      PaintList(size, brush.Get()); break;
    }

    if (m_scrollbarVisible && m_scrollbarAlpha > 0.001f)
        PaintScrollbar(size, brush.Get());

    HRESULT hr = m_rt->EndDraw();
    if (hr == D2DERR_RECREATE_TARGET) m_rt.Reset();
}

void ListView::PaintHeader(const D2D1_SIZE_F& size, ID2D1SolidColorBrush* br) {
    auto& c = Theme::Colors();
    float hdrH = HeaderHeight();
    float padX = Dpi::ScaleF(static_cast<float>(BASE_PADDING_X), m_dpi);

    // Header background
    br->SetColor(ToD2DColor(c.surface));
    m_rt->FillRectangle(D2D1::RectF(0, 0, size.width, hdrH), br);

    // Header bottom border
    br->SetColor(ToD2DColor(c.border));
    m_rt->DrawLine(D2D1::Point2F(0, hdrH - 0.5f), D2D1::Point2F(size.width, hdrH - 0.5f), br, 1.0f);

    auto textFmt = Typography::Format(TypeStyle::Caption, FontWeight::SemiBold, m_dpi);
    if (textFmt) {
        textFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
        textFmt->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
    }

    float x = 0.0f;
    for (int i = 0; i < static_cast<int>(m_columns.size()); i++) {
        float colW = Dpi::ScaleF(m_columns[i].width, m_dpi);

        // Hover highlight
        if (i == m_headerHovered && m_headerHoverAlpha > 0.001f) {
            auto hvCol = ToD2DColor(c.surfaceHover);
            hvCol.a = m_headerHoverAlpha * 0.5f;
            br->SetColor(hvCol);
            m_rt->FillRectangle(D2D1::RectF(x, 0, x + colW, hdrH), br);
        }

        // Label
        if (textFmt) {
            textFmt->SetTextAlignment(m_columns[i].align);
            br->SetColor(ToD2DColor(c.text));
            float sortSpace = (i == m_sortCol) ? Dpi::ScaleF(16.0f, m_dpi) : 0.0f;
            D2D1_RECT_F textRc = D2D1::RectF(x + padX, 0, x + colW - padX - sortSpace, hdrH);
            m_rt->DrawText(m_columns[i].label.c_str(),
                static_cast<UINT32>(m_columns[i].label.length()),
                textFmt.Get(), textRc, br);
        }

        // Sort chevron
        if (i == m_sortCol) {
            float iconSz = Dpi::ScaleF(12.0f, m_dpi);
            float iconX = x + colW - padX - iconSz;
            float iconY = (hdrH - iconSz) * 0.5f;
            D2D1_RECT_F iconRc = D2D1::RectF(iconX, iconY, iconX + iconSz, iconY + iconSz);
            float cx = iconX + iconSz * 0.5f, cy = iconY + iconSz * 0.5f;
            D2D1_MATRIX_3X2_F old;
            m_rt->GetTransform(&old);
            m_rt->SetTransform(D2D1::Matrix3x2F::Rotation(m_sortChevronAngle, D2D1::Point2F(cx, cy)) * old);
            RenderContext::DrawSvgIcon(m_rt.Get(), "chevron-up", iconRc, Theme::AccentIconColor(), 1.0f);
            m_rt->SetTransform(old);
        }

        // Column separator
        auto sepCol = ToD2DColor(c.border); sepCol.a = 0.3f;
        br->SetColor(sepCol);
        m_rt->DrawLine(D2D1::Point2F(x + colW, 4), D2D1::Point2F(x + colW, hdrH - 4), br, 1.0f);
        x += colW;
    }
}

void ListView::PaintDetails(const D2D1_SIZE_F& size, ID2D1SolidColorBrush* br) {
    if (m_columns.empty() || !m_provider) return;
    auto& c = Theme::Colors();
    float rh = RowHeight();
    float hdrH = HeaderHeight();
    float padX = Dpi::ScaleF(static_cast<float>(BASE_PADDING_X), m_dpi);
    float iconSz = Dpi::ScaleF(static_cast<float>(BASE_ICON_SMALL), m_dpi);

    PaintHeader(size, br);

    // Clip content below header
    m_rt->PushAxisAlignedClip(D2D1::RectF(0, hdrH, size.width, size.height),
        D2D1_ANTIALIAS_MODE_PER_PRIMITIVE);

    int firstVis = static_cast<int>(m_scrollY / rh);
    int lastVis = static_cast<int>((m_scrollY + size.height - hdrH) / rh) + 1;
    firstVis = (std::max)(0, firstVis);
    lastVis = (std::min)(m_itemCount - 1, lastVis);

    auto textFmt = Typography::Format(TypeStyle::Body, FontWeight::Regular, m_dpi);
    if (textFmt) {
        textFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
        textFmt->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
        // Ellipsis trimming — truncate with "..." when text exceeds cell width
        ComPtr<IDWriteInlineObject> trimmingSign;
        RenderContext::DWrite()->CreateEllipsisTrimmingSign(textFmt.Get(), &trimmingSign);
        DWRITE_TRIMMING trimming{DWRITE_TRIMMING_GRANULARITY_CHARACTER, 0, 0};
        textFmt->SetTrimming(&trimming, trimmingSign.Get());
    }

    // Pre-compute stripe/hover/text colors
    auto stripeCol = ToD2DColor(c.surface); stripeCol.a = 0.4f;
    auto textCol   = ToD2DColor(c.text);

    for (int i = firstVis; i <= lastVis; i++) {
        float rowTop = hdrH + static_cast<float>(i) * rh - m_scrollY;
        float rowBot = rowTop + rh;
        if (rowBot < hdrH || rowTop > size.height) continue;

        // Row striping
        if (i % 2 == 1) {
            br->SetColor(stripeCol);
            m_rt->FillRectangle(D2D1::RectF(0, rowTop, size.width, rowBot), br);
        }

        // Hover highlight
        if (i == m_hovered && m_hoverAlpha > 0.001f) {
            auto hvCol = ToD2DColor(c.surfaceHover);
            hvCol.a = m_hoverAlpha * 0.08f;
            br->SetColor(hvCol);
            m_rt->FillRectangle(D2D1::RectF(0, rowTop, size.width, rowBot), br);
        }

        // Cell text
        auto& item = m_provider(i);
        float x = 0.0f;
        for (int col = 0; col < static_cast<int>(m_columns.size()); col++) {
            float colW = Dpi::ScaleF(m_columns[col].width, m_dpi);
            if (col < static_cast<int>(item.cells.size())) {
                float textLeft = x + padX;
                // Icon in first column
                if (col == 0) {
                    HICON hIco = item.icon ? item.icon : m_fallbackIcon;
                    if (auto* bmp = GetIconBitmap(hIco)) {
                        float iy = rowTop + (rh - iconSz) * 0.5f;
                        D2D1_RECT_F iconRc = D2D1::RectF(textLeft, iy, textLeft + iconSz, iy + iconSz);
                        m_rt->DrawBitmap(bmp, iconRc, 1.0f, D2D1_BITMAP_INTERPOLATION_MODE_LINEAR);
                    }
                    textLeft += iconSz + Dpi::ScaleF(6.0f, m_dpi);
                }

                // Inline edit check
                if (m_editActive && m_editItemIdx == i && m_editColIdx == col) {
                    D2D1_RECT_F cellRc = D2D1::RectF(textLeft, rowTop, x + colW - padX, rowBot);
                    PaintInlineEdit(cellRc, br);
                } else {
                    if (textFmt) textFmt->SetTextAlignment(m_columns[col].align);
                    br->SetColor(textCol);
                    D2D1_RECT_F cellRc = D2D1::RectF(textLeft, rowTop, x + colW - padX, rowBot);
                    m_rt->DrawText(item.cells[col].c_str(),
                        static_cast<UINT32>(item.cells[col].length()),
                        textFmt.Get(), cellRc, br);
                }
            }
            x += colW;
        }
    }

    // Selection overlay (drawn on top of rows)
    if (m_selected >= 0 && m_selAlpha > 0.001f) {
        auto accentCol = ToD2DColor(c.accent);
        accentCol.a = 0.12f * m_selAlpha;
        br->SetColor(accentCol);
        float selTop = m_selHighlightY - m_scrollY;
        m_rt->FillRectangle(D2D1::RectF(0, selTop, size.width, selTop + rh), br);

        // Left accent bar
        auto accentSolid = ToD2DColor(c.accent);
        accentSolid.a = m_selAlpha * 0.7f;
        br->SetColor(accentSolid);
        m_rt->FillRectangle(D2D1::RectF(0, selTop + 2, 3.0f, selTop + rh - 2), br);
    }

    m_rt->PopAxisAlignedClip();
}

void ListView::PaintIcons(const D2D1_SIZE_F& size, bool large, ID2D1SolidColorBrush* br) {
    if (!m_provider) return;
    auto& c = Theme::Colors();
    float iconSz = Dpi::ScaleF(static_cast<float>(large ? BASE_ICON_LARGE : BASE_ICON_SMALL), m_dpi);
    float padX = Dpi::ScaleF(static_cast<float>(BASE_PADDING_X), m_dpi);

    auto textFmt = Typography::Format(TypeStyle::Caption, FontWeight::Regular, m_dpi);
    if (textFmt) {
        textFmt->SetTextAlignment(large ? DWRITE_TEXT_ALIGNMENT_CENTER : DWRITE_TEXT_ALIGNMENT_LEADING);
        textFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_NEAR);
        textFmt->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
    }

    auto textCol = ToD2DColor(c.text);
    float cornerR = Dpi::ScaleF(4.0f, m_dpi);

    for (int i = 0; i < m_itemCount; i++) {
        auto cellRc = GridCellRect(i);
        if (cellRc.bottom < 0 || cellRc.top > size.height) continue;

        // Selection
        if (i == m_selected && m_selAlpha > 0.001f) {
            auto acCol = ToD2DColor(c.accent); acCol.a = 0.12f * m_selAlpha;
            br->SetColor(acCol);
            m_rt->FillRoundedRectangle(D2D1::RoundedRect(cellRc, cornerR, cornerR), br);
        }

        // Hover
        if (i == m_hovered && m_hoverAlpha > 0.001f) {
            auto hvCol = ToD2DColor(c.surfaceHover); hvCol.a = m_hoverAlpha * 0.08f;
            br->SetColor(hvCol);
            m_rt->FillRoundedRectangle(D2D1::RoundedRect(cellRc, cornerR, cornerR), br);
        }

        auto& item = m_provider(i);
        if (large) {
            float iconX = cellRc.left + ((cellRc.right - cellRc.left) - iconSz) * 0.5f;
            float iconY = cellRc.top + Dpi::ScaleF(8.0f, m_dpi);
            D2D1_RECT_F iconRc = D2D1::RectF(iconX, iconY, iconX + iconSz, iconY + iconSz);
            HICON hIco = item.icon ? item.icon : m_fallbackIcon;
            if (auto* bmp = GetIconBitmap(hIco))
                m_rt->DrawBitmap(bmp, iconRc, 1.0f, D2D1_BITMAP_INTERPOLATION_MODE_LINEAR);

            if (!item.cells.empty() && textFmt) {
                D2D1_RECT_F labelRc = D2D1::RectF(cellRc.left + 4, iconY + iconSz + 4,
                    cellRc.right - 4, cellRc.bottom - 4);
                br->SetColor(textCol);
                m_rt->DrawText(item.cells[0].c_str(),
                    static_cast<UINT32>(item.cells[0].length()),
                    textFmt.Get(), labelRc, br);
            }
        } else {
            float iconY = cellRc.top + ((cellRc.bottom - cellRc.top) - iconSz) * 0.5f;
            D2D1_RECT_F iconRc = D2D1::RectF(cellRc.left + padX, iconY,
                cellRc.left + padX + iconSz, iconY + iconSz);
            HICON hIco = item.icon ? item.icon : m_fallbackIcon;
            if (auto* bmp = GetIconBitmap(hIco))
                m_rt->DrawBitmap(bmp, iconRc, 1.0f, D2D1_BITMAP_INTERPOLATION_MODE_LINEAR);

            if (!item.cells.empty() && textFmt) {
                D2D1_RECT_F labelRc = D2D1::RectF(cellRc.left + padX + iconSz + 6,
                    cellRc.top, cellRc.right - padX, cellRc.bottom);
                textFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
                br->SetColor(textCol);
                m_rt->DrawText(item.cells[0].c_str(),
                    static_cast<UINT32>(item.cells[0].length()),
                    textFmt.Get(), labelRc, br);
            }
        }
    }
}

void ListView::PaintList(const D2D1_SIZE_F& size, ID2D1SolidColorBrush* br) {
    if (!m_provider) return;
    auto& c = Theme::Colors();
    float rh = RowHeight();
    float padX = Dpi::ScaleF(static_cast<float>(BASE_PADDING_X), m_dpi);
    float iconSz = Dpi::ScaleF(static_cast<float>(BASE_ICON_SMALL), m_dpi);

    auto textFmt = Typography::Format(TypeStyle::Body, FontWeight::Regular, m_dpi);
    if (textFmt) {
        textFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
        textFmt->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
    }

    int firstVis = static_cast<int>(m_scrollY / rh);
    int lastVis = static_cast<int>((m_scrollY + size.height) / rh) + 1;
    firstVis = (std::max)(0, firstVis);
    lastVis = (std::min)(m_itemCount - 1, lastVis);

    auto stripeCol = ToD2DColor(c.surface); stripeCol.a = 0.4f;
    auto textCol   = ToD2DColor(c.text);

    for (int i = firstVis; i <= lastVis; i++) {
        float rowTop = static_cast<float>(i) * rh - m_scrollY;
        float rowBot = rowTop + rh;

        if (i % 2 == 1) {
            br->SetColor(stripeCol);
            m_rt->FillRectangle(D2D1::RectF(0, rowTop, size.width, rowBot), br);
        }

        if (i == m_selected && m_selAlpha > 0.001f) {
            auto ac = ToD2DColor(c.accent); ac.a = 0.12f * m_selAlpha;
            br->SetColor(ac);
            m_rt->FillRectangle(D2D1::RectF(0, rowTop, size.width, rowBot), br);
        }

        if (i == m_hovered && m_hoverAlpha > 0.001f) {
            auto hc = ToD2DColor(c.surfaceHover); hc.a = m_hoverAlpha * 0.08f;
            br->SetColor(hc);
            m_rt->FillRectangle(D2D1::RectF(0, rowTop, size.width, rowBot), br);
        }

        auto& item = m_provider(i);
        float textLeft = padX;
        HICON hIco = item.icon ? item.icon : m_fallbackIcon;
        if (auto* bmp = GetIconBitmap(hIco)) {
            float iy = rowTop + (rh - iconSz) * 0.5f;
            D2D1_RECT_F iconRc = D2D1::RectF(padX, iy, padX + iconSz, iy + iconSz);
            m_rt->DrawBitmap(bmp, iconRc, 1.0f, D2D1_BITMAP_INTERPOLATION_MODE_LINEAR);
            textLeft = padX + iconSz + 6.0f;
        }

        if (!item.cells.empty() && textFmt) {
            br->SetColor(textCol);
            D2D1_RECT_F textRc = D2D1::RectF(textLeft, rowTop, size.width - padX, rowBot);
            m_rt->DrawText(item.cells[0].c_str(),
                static_cast<UINT32>(item.cells[0].length()),
                textFmt.Get(), textRc, br);
        }
    }
}

void ListView::PaintInlineEdit(const D2D1_RECT_F& cellRect, ID2D1SolidColorBrush* br) {
    auto& c = Theme::Colors();

    // Edit background
    br->SetColor(ToD2DColor(c.background));
    m_rt->FillRectangle(cellRect, br);

    // Edit border
    br->SetColor(ToD2DColor(c.accent));
    m_rt->DrawRectangle(cellRect, br, 1.0f);

    // Text
    auto textFmt = Typography::Format(TypeStyle::Body, FontWeight::Regular, m_dpi);
    if (textFmt) {
        textFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
        textFmt->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
    }
    br->SetColor(ToD2DColor(c.text));
    float padX = Dpi::ScaleF(4.0f, m_dpi);
    D2D1_RECT_F textRc = D2D1::RectF(cellRect.left + padX, cellRect.top,
        cellRect.right - padX, cellRect.bottom);
    if (textFmt) {
        m_rt->DrawText(m_editText.c_str(), static_cast<UINT32>(m_editText.length()),
            textFmt.Get(), textRc, br);
    }

    // Blinking cursor
    bool cursorVisible = (m_cursorBlinkPhase < 0.5f);
    if (cursorVisible && textFmt) {
        ComPtr<IDWriteTextLayout> layout;
        RenderContext::DWrite()->CreateTextLayout(
            m_editText.c_str(), static_cast<UINT32>(m_editCursorPos),
            textFmt.Get(), cellRect.right - cellRect.left, cellRect.bottom - cellRect.top, &layout);
        if (layout) {
            DWRITE_TEXT_METRICS metrics;
            layout->GetMetrics(&metrics);
            float cursorX = cellRect.left + padX + metrics.width;
            float cursorTop = cellRect.top + 3.0f;
            float cursorBot = cellRect.bottom - 3.0f;

            br->SetColor(ToD2DColor(c.accent));
            m_rt->DrawLine(D2D1::Point2F(cursorX, cursorTop),
                D2D1::Point2F(cursorX, cursorBot), br, 1.5f);
        }
    }
}

void ListView::PaintScrollbar(const D2D1_SIZE_F&, ID2D1SolidColorBrush* br) {
    auto& c = Theme::Colors();
    auto thumb = ScrollbarThumbRect();
    float alpha = m_scrollbarAlpha * (m_scrollbarHovered || m_scrollbarDragging ? 0.7f : 0.35f);
    auto thumbCol = ToD2DColor(c.text);
    thumbCol.a = alpha;
    br->SetColor(thumbCol);
    float r = (thumb.right - thumb.left) * 0.5f;
    m_rt->FillRoundedRectangle(D2D1::RoundedRect(thumb, r, r), br);
}

// ── Window Procedure ────────────────────────────────────────
LRESULT CALLBACK ListView::ListViewProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    ListView* self = nullptr;
    if (msg == WM_NCCREATE) {
        auto cs = reinterpret_cast<CREATESTRUCTW*>(lp);
        self = static_cast<ListView*>(cs->lpCreateParams);
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(self));
        self->m_hwnd = hwnd;
    } else {
        self = reinterpret_cast<ListView*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
    }
    if (!self) return DefWindowProcW(hwnd, msg, wp, lp);

    switch (msg) {
    case WM_PAINT: {
        PAINTSTRUCT ps;
        BeginPaint(hwnd, &ps);
        self->OnPaint();
        EndPaint(hwnd, &ps);
        return 0;
    }

    case WM_SIZE:
        if (self->m_rt) {
            RECT rc; GetClientRect(hwnd, &rc);
            self->m_rt->Resize(D2D1::SizeU(rc.right, rc.bottom));
        }
        return 0;

    case WM_MOUSEWHEEL: {
        int delta = GET_WHEEL_DELTA_WPARAM(wp);
        float step = self->RowHeight() * 3.0f;
        float target = self->m_scrollTargetY - static_cast<float>(delta) / WHEEL_DELTA * step;
        self->AnimateScrollTo(target);
        return 0;
    }

    case WM_MOUSEMOVE: {
        int mx = GET_X_LPARAM(lp), my = GET_Y_LPARAM(lp);

        // Column resize drag
        if (self->m_resizingCol >= 0) {
            float diff = static_cast<float>(mx) - self->m_resizeStartX;
            float scaledOrig = Dpi::ScaleF(self->m_resizeOrigW, self->m_dpi);
            float scaledNew = (std::max)(Dpi::ScaleF(40.0f, self->m_dpi), scaledOrig + diff);
            float newW = scaledNew * 96.0f / static_cast<float>(self->m_dpi);
            self->m_columns[self->m_resizingCol].width = newW;
            self->Repaint();
            return 0;
        }

        // Scrollbar drag
        if (self->m_scrollbarDragging) {
            auto track = self->ScrollbarTrackRect();
            float trackH = track.bottom - track.top;
            float maxS = self->MaxScrollY();
            float dy = static_cast<float>(my) - self->m_scrollbarDragStart;
            float newScroll = self->m_scrollDragStartY + dy * (maxS / trackH);
            self->m_scrollY = std::clamp(newScroll, 0.0f, maxS);
            self->m_scrollTargetY = self->m_scrollY;
            self->Repaint();
            return 0;
        }

        // Header hover / resize cursor
        if (self->m_viewMode == ViewMode::Details && static_cast<float>(my) < self->HeaderHeight()) {
            int edge = self->HitTestColumnEdge(mx);
            SetCursor(LoadCursorW(nullptr, edge >= 0 ? IDC_SIZEWE : IDC_ARROW));
            int col = self->HitTestColumn(mx);
            if (col != self->m_headerHovered) {
                self->m_headerHovered = col;
                auto& mgr = AnimationManager::Instance();
                if (self->m_headerHoverAnimId) mgr.Cancel(self->m_headerHoverAnimId);
                float target = (col >= 0) ? 1.0f : 0.0f;
                self->m_headerHoverAnimId = mgr.Animate(self->m_headerHoverAlpha, target, 100.0f, ease::OutQuad,
                    [self](float v, const Animation&) { self->m_headerHoverAlpha = v; self->Repaint(); },
                    [self]() { self->m_headerHoverAnimId = 0; });
            }
        } else {
            SetCursor(LoadCursorW(nullptr, IDC_ARROW));
            if (self->m_headerHovered >= 0) {
                self->m_headerHovered = -1;
                self->m_headerHoverAlpha = 0.0f;
                self->Repaint();
            }
        }

        // Row hover
        int hitRow = -1;
        if (self->m_viewMode == ViewMode::Details || self->m_viewMode == ViewMode::List)
            hitRow = self->HitTestRow(my);
        else
            hitRow = self->GridHitTest(mx, my);
        self->AnimateHover(hitRow);

        // Scrollbar hover
        bool sbHit = self->HitTestScrollbar(mx, my);
        if (sbHit != self->m_scrollbarHovered) {
            self->m_scrollbarHovered = sbHit;
            if (sbHit) self->ShowScrollbar();
            else self->ScheduleScrollbarHide();
            self->Repaint();
        }

        TRACKMOUSEEVENT tme{};
        tme.cbSize = sizeof(tme);
        tme.dwFlags = TME_LEAVE;
        tme.hwndTrack = hwnd;
        TrackMouseEvent(&tme);
        return 0;
    }

    case WM_MOUSELEAVE:
        self->AnimateHover(-1);
        self->m_headerHovered = -1;
        self->m_scrollbarHovered = false;
        self->ScheduleScrollbarHide();
        self->Repaint();
        return 0;

    case WM_LBUTTONDOWN: {
        SetFocus(hwnd);
        int mx = GET_X_LPARAM(lp), my = GET_Y_LPARAM(lp);

        // Scrollbar drag start
        if (self->HitTestScrollbar(mx, my)) {
            self->m_scrollbarDragging = true;
            self->m_scrollbarDragStart = static_cast<float>(my);
            self->m_scrollDragStartY = self->m_scrollY;
            SetCapture(hwnd);
            return 0;
        }

        // Column resize start
        if (self->m_viewMode == ViewMode::Details && static_cast<float>(my) < self->HeaderHeight()) {
            int edge = self->HitTestColumnEdge(mx);
            if (edge >= 0) {
                self->m_resizingCol = edge;
                self->m_resizeStartX = static_cast<float>(mx);
                self->m_resizeOrigW = self->m_columns[edge].width;
                SetCapture(hwnd);
                return 0;
            }
            // Column header click for sorting
            int col = self->HitTestColumn(mx);
            if (col >= 0 && self->m_columns[col].sortable) {
                bool asc = (col == self->m_sortCol) ? !self->m_sortAscending : true;
                self->SetSortColumn(col, asc);
            }
            return 0;
        }

        // Row selection
        int hitRow = -1;
        if (self->m_viewMode == ViewMode::Details || self->m_viewMode == ViewMode::List)
            hitRow = self->HitTestRow(my);
        else
            hitRow = self->GridHitTest(mx, my);

        if (hitRow >= 0) {
            // End any active edit
            if (self->m_editActive) self->EndEdit(true);

            // Slow double-click detection for inline edit
            if (hitRow == self->m_lastClickIdx && self->m_editClickTimer) {
                KillTimer(hwnd, self->m_editClickTimer);
                self->m_editClickTimer = 0;
                self->BeginEdit(hitRow, 0);
                return 0;
            }

            self->Select(hitRow);
            self->m_lastClickIdx = hitRow;
            SendMessageW(self->m_parent, WM_COMMAND,
                MAKEWPARAM(self->m_id, IDC_LISTVIEW_SELECT),
                reinterpret_cast<LPARAM>(hwnd));

            // Start slow double-click timer (500ms)
            self->m_editClickTimer = SetTimer(hwnd, 0xAA02, 500, nullptr);
        } else {
            if (self->m_editActive) self->EndEdit(true);
        }
        return 0;
    }

    case WM_LBUTTONUP:
        if (self->m_resizingCol >= 0) {
            self->m_resizingCol = -1;
            ReleaseCapture();
        }
        if (self->m_scrollbarDragging) {
            self->m_scrollbarDragging = false;
            ReleaseCapture();
            self->ScheduleScrollbarHide();
        }
        return 0;

    case WM_LBUTTONDBLCLK: {
        int mx = GET_X_LPARAM(lp), my = GET_Y_LPARAM(lp);
        int hitRow = -1;
        if (self->m_viewMode == ViewMode::Details || self->m_viewMode == ViewMode::List)
            hitRow = self->HitTestRow(my);
        else
            hitRow = self->GridHitTest(mx, my);
        if (hitRow >= 0) {
            if (self->m_editClickTimer) { KillTimer(hwnd, self->m_editClickTimer); self->m_editClickTimer = 0; }
            self->m_lastClickIdx = -1;
            SendMessageW(self->m_parent, WM_COMMAND,
                MAKEWPARAM(self->m_id, IDC_LISTVIEW_DBLCLK),
                reinterpret_cast<LPARAM>(hwnd));
        }
        return 0;
    }

    case WM_KEYDOWN:
        switch (wp) {
        case VK_UP:
            if (self->m_selected > 0) {
                self->Select(self->m_selected - 1);
                self->EnsureVisible(self->m_selected);
                SendMessageW(self->m_parent, WM_COMMAND,
                    MAKEWPARAM(self->m_id, IDC_LISTVIEW_SELECT),
                    reinterpret_cast<LPARAM>(hwnd));
            }
            return 0;
        case VK_DOWN:
            if (self->m_selected < self->m_itemCount - 1) {
                self->Select(self->m_selected + 1);
                self->EnsureVisible(self->m_selected);
                SendMessageW(self->m_parent, WM_COMMAND,
                    MAKEWPARAM(self->m_id, IDC_LISTVIEW_SELECT),
                    reinterpret_cast<LPARAM>(hwnd));
            }
            return 0;
        case VK_F2:
            if (self->m_selected >= 0) self->BeginEdit(self->m_selected, 0);
            return 0;
        case VK_ESCAPE:
            if (self->m_editActive) { self->EndEdit(false); return 0; }
            break;
        case VK_RETURN:
            if (self->m_editActive) { self->EndEdit(true); return 0; }
            break;
        }
        break;

    case WM_CHAR:
        if (self->m_editActive) {
            wchar_t ch = static_cast<wchar_t>(wp);
            if (ch == VK_RETURN || ch == VK_ESCAPE || ch < 0x20) break;
            self->m_editText.insert(self->m_editCursorPos, 1, ch);
            self->m_editCursorPos++;
            self->m_cursorBlinkPhase = 0.0f;
            self->Repaint();
            return 0;
        }
        break;

    case WM_SETCURSOR:
        if (LOWORD(lp) == HTCLIENT) return TRUE;
        break;

    case WM_TIMER:
        if (wp == 0xAA01) {
            // Scrollbar auto-hide
            KillTimer(hwnd, 0xAA01);
            self->m_scrollbarTimer = 0;
            auto& mgr = AnimationManager::Instance();
            if (self->m_scrollbarFadeId) mgr.Cancel(self->m_scrollbarFadeId);
            self->m_scrollbarFadeId = mgr.Animate(self->m_scrollbarAlpha, 0.0f, 400.0f, ease::OutQuad,
                [self](float v, const Animation&) { self->m_scrollbarAlpha = v; self->Repaint(); },
                [self]() { self->m_scrollbarFadeId = 0; });
        }
        if (wp == 0xAA02) {
            // Slow double-click expired
            KillTimer(hwnd, 0xAA02);
            self->m_editClickTimer = 0;
            self->m_lastClickIdx = -1;
        }
        return 0;

    case WM_ERASEBKGND:
        return 1;
    }

    return DefWindowProcW(hwnd, msg, wp, lp);
}

} // namespace rui
