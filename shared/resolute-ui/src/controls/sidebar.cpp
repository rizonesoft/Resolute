#include <resolute/controls/sidebar.h>
#include <resolute/typography.h>
#include <windowsx.h>  // GET_X_LPARAM, GET_Y_LPARAM
#include <cmath>
#include <cwctype>
#include <algorithm>
#include <utility>

namespace rui {

// ── Accessors ───────────────────────────────────────────────
int Sidebar::ScaledWidth() const {
    int full = Dpi::Scale(BASE_WIDTH, m_dpi);
    return static_cast<int>(full * m_widthFactor);
}
HWND Sidebar::Handle() const { return m_hwnd; }
int  Sidebar::Selected() const { return m_selected; }
int  Sidebar::ItemHeight() const { return Dpi::Scale(BASE_ITEM_HEIGHT, m_dpi); }
int  Sidebar::PaddingX() const { return Dpi::Scale(BASE_PADDING_X, m_dpi); }
int  Sidebar::IconSize() const { return Dpi::Scale(BASE_ICON_SIZE, m_dpi); }

float Sidebar::YStart() const { return Dpi::ScaleF(44.0f, m_dpi); }
float Sidebar::ItemYCenter(int idx) const {
    return YStart() + idx * static_cast<float>(ItemHeight()) +
           static_cast<float>(ItemHeight()) * 0.5f;
}

bool  Sidebar::IsCollapsed() const { return m_collapsed; }
int   Sidebar::TargetWidth() const { return ScaledWidth(); }

void Sidebar::SetBadge(int idx, int count) {
    if (idx >= 0 && idx < kCategoryCount) {
        m_badgeCounts[idx] = count;
        Repaint();
    }
}
int Sidebar::Badge(int idx) const {
    return (idx >= 0 && idx < kCategoryCount) ? m_badgeCounts[idx] : 0;
}

void Sidebar::ApplyFilter() {
    for (int i = 0; i < kCategoryCount; i++) {
        if (m_searchLen == 0) {
            m_searchVisible[i] = true;
            continue;
        }
        // Case-insensitive substring match
        wchar_t lower[64];
        const wchar_t* label = m_items[i].label;
        int len = static_cast<int>(wcslen(label));
        for (int j = 0; j < len && j < 63; j++) lower[j] = towlower(label[j]);
        lower[(std::min)(len, 63)] = 0;

        wchar_t query[64];
        for (int j = 0; j < m_searchLen && j < 63; j++) query[j] = towlower(m_searchText[j]);
        query[(std::min)(m_searchLen, 63)] = 0;

        m_searchVisible[i] = wcsstr(lower, query) != nullptr;
    }
    Repaint();
}

// ── Create ──────────────────────────────────────────────────
void Sidebar::Create(HWND parent, HINSTANCE hInst, int id) {
    m_parent = parent;

    // Copy categories into mutable storage
    for (int i = 0; i < kCategoryCount; i++) {
        m_items[i] = kCategories[i];
    }

    // Init animation state
    for (int i = 0; i < kCategoryCount; i++) {
        m_hoverAlpha[i] = 0.0f;
        m_iconScale[i]  = 1.0f;
        m_enterAlpha[i] = 0.0f;
    }

    WNDCLASSEXW wc{};
    wc.cbSize        = sizeof(wc);
    wc.style         = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc   = SidebarProc;
    wc.hInstance     = hInst;
    wc.hCursor       = LoadCursorW(nullptr, IDC_HAND);
    wc.lpszClassName = L"ResoluteSidebar";
    RegisterClassExW(&wc);

    m_hwnd = CreateWindowExW(
        0, L"ResoluteSidebar", nullptr,
        WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_TABSTOP,
        0, 0, BASE_WIDTH, 400,
        parent, reinterpret_cast<HMENU>(static_cast<INT_PTR>(id)),
        hInst, this
    );

    m_dpi = Dpi::Get(m_hwnd);
    m_selectionY = ItemYCenter(m_selected);
    m_selectionTargetY = m_selectionY;
    CreateRenderTarget();

    // Tooltip for icon-only (collapsed) mode
    m_tooltip = CreateWindowExW(
        WS_EX_TOPMOST, TOOLTIPS_CLASSW, nullptr,
        WS_POPUP | TTS_NOPREFIX | TTS_ALWAYSTIP,
        0, 0, 0, 0, m_hwnd, nullptr, hInst, nullptr);
    if (m_tooltip) {
        SendMessageW(m_tooltip, TTM_ACTIVATE, TRUE, 0);
        SendMessageW(m_tooltip, TTM_SETMAXTIPWIDTH, 0, 300);
        // Add internal padding so rounded corners don't clip content
        RECT margins = {6, 4, 6, 4};
        SendMessageW(m_tooltip, TTM_SETMARGIN, 0, reinterpret_cast<LPARAM>(&margins));
        // Single tracked tool for manual show/hide
        TTTOOLINFOW ti{};
        ti.cbSize   = TTTOOLINFOW_V2_SIZE;
        ti.uFlags   = TTF_TRACK | TTF_ABSOLUTE;
        ti.hwnd     = m_hwnd;
        ti.uId      = 0;
        ti.lpszText = const_cast<wchar_t*>(L"");
        RECT rc; GetClientRect(m_hwnd, &rc);
        ti.rect     = rc;
        SendMessageW(m_tooltip, TTM_ADDTOOLW, 0, reinterpret_cast<LPARAM>(&ti));
    }

    // Trigger staggered entry animation
    AnimateEnter();
}

void Sidebar::Resize(int x, int y, int w, int h) {
    MoveWindow(m_hwnd, x, y, w, h, TRUE);
    if (m_rt) m_rt->Resize(D2D1::SizeU(w, h));
}

void Sidebar::Repaint() { InvalidateRect(m_hwnd, nullptr, FALSE); }

void Sidebar::UpdateDpi(int dpi) {
    m_dpi = dpi;
    m_cachedIconSize = 0;
    m_selectionY = ItemYCenter(m_selected);
    m_selectionTargetY = m_selectionY;
    Repaint();
}

// ── Collapse/Expand ─────────────────────────────────────────
void Sidebar::SetCollapsed(bool collapsed) {
    if (m_collapsed == collapsed) return;
    AnimateCollapse(collapsed);
}

void Sidebar::ToggleCollapsed() {
    SetCollapsed(!m_collapsed);
}

// ── D2D Setup ───────────────────────────────────────────────
void Sidebar::CreateRenderTarget() {
    m_rt = RenderContext::CreateHwndTarget(m_hwnd);
    m_cachedIconSize = 0;
}

void Sidebar::RebuildIconCache() {
    if (!m_rt) return;
    int displaySz = IconSize();
    uint32_t color = Theme::IconColor();
    // White icons for selected state (pure white in dark mode, dark in light mode)
    uint32_t selectedColor = Theme::IsDark() ? 0xFFFFFF : 0x191919;

    bool needsRebuild = (displaySz != m_cachedIconSize) ||
                        (color != m_cachedIconColor) ||
                        (selectedColor != m_cachedAccentColor);
    if (!needsRebuild) return;

    for (int i = 0; i < kCategoryCount; i++) {
        // Normal icons — render at exact display size (1:1 pixel mapping)
        m_iconBitmaps[i].Reset();
        auto* rgba = LucideIcons::Render(kCategories[i].iconName, displaySz, color);
        if (rgba) {
            m_iconBitmaps[i] = RenderContext::CreateBitmapFromRGBA(
                m_rt.Get(), rgba, displaySz, displaySz);
            LucideIcons::Free(rgba);
        }
        // Selected icons (white in dark, dark in light)
        m_accentIconBitmaps[i].Reset();
        rgba = LucideIcons::Render(kCategories[i].iconName, displaySz, selectedColor);
        if (rgba) {
            m_accentIconBitmaps[i] = RenderContext::CreateBitmapFromRGBA(
                m_rt.Get(), rgba, displaySz, displaySz);
            LucideIcons::Free(rgba);
        }
    }
    m_cachedIconSize = displaySz;
    m_cachedIconColor = color;
    m_cachedAccentColor = selectedColor;
}

// ── Animation Triggers ──────────────────────────────────────

void Sidebar::AnimateSelection(int newIdx) {
    auto& mgr = AnimationManager::Instance();
    if (m_selAnimId) mgr.Cancel(m_selAnimId);

    float fromY = m_selectionY;
    float toY   = ItemYCenter(newIdx);
    m_selectionTargetY = toY;

    m_selAnimId = mgr.Animate(fromY, toY, 250.0f, ease::OutCubic,
        [this](float v, const Animation&) {
            m_selectionY = v;
            Repaint();
        },
        [this]() { m_selAnimId = 0; }
    );
}

void Sidebar::AnimateHover(int idx, bool entering) {
    if (idx < 0 || idx >= kCategoryCount) return;
    auto& mgr = AnimationManager::Instance();
    if (m_hoverAnimId[idx]) mgr.Cancel(m_hoverAnimId[idx]);

    float from = m_hoverAlpha[idx];
    float to   = entering ? 1.0f : 0.0f;

    m_hoverAnimId[idx] = mgr.Animate(from, to, 120.0f, ease::OutQuad,
        [this, idx](float v, const Animation&) {
            m_hoverAlpha[idx] = v;
            Repaint();
        },
        [this, idx]() { m_hoverAnimId[idx] = 0; }
    );
}

void Sidebar::AnimateIconPulse(int idx) {
    if (idx < 0 || idx >= kCategoryCount) return;
    auto& mgr = AnimationManager::Instance();

    // Opacity pulse: briefly brighten then settle back
    // (no scaling — scaling a bitmap always blurs)
    mgr.Animate(1.0f, 1.3f, 100.0f, ease::OutQuad,
        [this, idx](float v, const Animation&) {
            m_iconScale[idx] = v;  // repurposed as brightness
            Repaint();
        },
        [this, idx]() {
            AnimationManager::Instance().Animate(
                m_iconScale[idx], 1.0f, 200.0f, ease::OutQuad,
                [this, idx](float v, const Animation&) {
                    m_iconScale[idx] = v;
                    Repaint();
                });
        }
    );
}

void Sidebar::AnimateEnter() {
    if (m_entered) return;
    m_entered = true;

    auto& mgr = AnimationManager::Instance();
    mgr.AnimateStaggered(kCategoryCount, 0.0f, 1.0f, 250.0f, 30.0f,
        ease::OutQuart,
        [this](int i, float v) {
            m_enterAlpha[i] = v;
            Repaint();
        }
    );
}


void Sidebar::AnimateCollapse(bool collapse) {
    auto& mgr = AnimationManager::Instance();
    if (m_collapseAnimId) mgr.Cancel(m_collapseAnimId);

    m_collapsed = collapse;
    m_chevronHovered = false;  // reset hover state
    float from = m_widthFactor;
    float iconOnlyRatio = static_cast<float>(Dpi::Scale(BASE_ICON_SIZE + BASE_PADDING_X * 2, m_dpi))
                        / static_cast<float>(Dpi::Scale(BASE_WIDTH, m_dpi));
    float to = collapse ? iconOnlyRatio : 1.0f;

    m_collapseAnimId = mgr.Animate(from, to, 250.0f, ease::OutCubic,
        [this](float v, const Animation&) {
            m_widthFactor = v;
            SendMessageW(m_parent, WM_SIZE, 0, 0);
        },
        [this]() { m_collapseAnimId = 0; }
    );
}

// ── Paint ───────────────────────────────────────────────────
void Sidebar::OnPaint() {
    if (!m_rt) { CreateRenderTarget(); if (!m_rt) return; }
    RebuildIconCache();

    auto& c = Theme::Colors();
    int itemH   = ItemHeight();
    int padX    = PaddingX();
    int iconSz  = IconSize();
    float fontSize   = Dpi::ScaleF(static_cast<float>(BASE_FONT_SIZE), m_dpi);
    float headerSize = Dpi::ScaleF(static_cast<float>(BASE_HEADER_FONT), m_dpi);

    m_rt->BeginDraw();
    m_rt->Clear(ToD2DColor(c.surface));

    auto size = m_rt->GetSize();

    // Right border
    ComPtr<ID2D1SolidColorBrush> borderBrush;
    m_rt->CreateSolidColorBrush(ToD2DColor(c.border), &borderBrush);
    m_rt->DrawLine(
        D2D1::Point2F(size.width - 0.5f, 0),
        D2D1::Point2F(size.width - 0.5f, size.height),
        borderBrush.Get(), 1.0f
    );

    // Header text (hide when collapsed)
    if (m_widthFactor > 0.6f) {
        float textAlpha = (m_widthFactor - 0.6f) / 0.4f;
        auto headerColor = ToD2DColor(c.textSecondary);
        headerColor.a = textAlpha;
        ComPtr<ID2D1SolidColorBrush> secBrush;
        m_rt->CreateSolidColorBrush(headerColor, &secBrush);
        float headerTop = Dpi::ScaleF(14.0f, m_dpi);
        float headerW = size.width - static_cast<float>(padX) * 2 - Dpi::ScaleF(24.0f, m_dpi);
        float headerH = Dpi::ScaleF(20.0f, m_dpi);
        auto headerLayout = Typography::Layout(
            L"CATEGORIES", 10,
            TypeStyle::Caption, FontWeight::SemiBold,
            headerW, headerH, m_dpi);
        if (headerLayout) {
            m_rt->DrawTextLayout(
                D2D1::Point2F(static_cast<float>(padX), headerTop),
                headerLayout.Get(), secBrush.Get());
        }
    }

    // Collapse/expand button — always visible
    {
        float iconSzF = Dpi::ScaleF(14.0f, m_dpi);
        float headerTop = Dpi::ScaleF(14.0f, m_dpi);
        float headerH = Dpi::ScaleF(20.0f, m_dpi);
        float chevX, chevY;
        const char* chevIcon;

        if (m_widthFactor > 0.6f) {
            // Expanded: right side of header
            chevX = size.width - static_cast<float>(padX) - iconSzF;
            chevIcon = "chevron-left";
        } else {
            // Collapsed: centered
            chevX = (size.width - iconSzF) * 0.5f;
            chevIcon = "chevron-right";
        }
        chevY = headerTop + (headerH - iconSzF) * 0.5f;

        // Hover highlight
        if (m_chevronHovered) {
            float pad = Dpi::ScaleF(4.0f, m_dpi);
            D2D1_RECT_F hoverRc = D2D1::RectF(
                chevX - pad, chevY - pad,
                chevX + iconSzF + pad, chevY + iconSzF + pad);
            auto hoverColor = ToD2DColor(c.surfaceHover);
            ComPtr<ID2D1SolidColorBrush> chevHoverBrush;
            m_rt->CreateSolidColorBrush(hoverColor, &chevHoverBrush);
            m_rt->FillRoundedRectangle(
                D2D1::RoundedRect(hoverRc, 4.0f, 4.0f), chevHoverBrush.Get());
        }

        D2D1_RECT_F chevIconRc = D2D1::RectF(chevX, chevY, chevX + iconSzF, chevY + iconSzF);
        uint32_t chevColor = Theme::IsDark() ? 0x999999 : 0x666666;
        RenderContext::DrawSvgIcon(m_rt.Get(), chevIcon, chevIconRc, chevColor, m_chevronHovered ? 1.0f : 0.7f);
    }

    // Reusable brushes
    auto itemFmt = Typography::Format(TypeStyle::Body, FontWeight::Regular, m_dpi);
    ComPtr<ID2D1SolidColorBrush> textBrush, accentBrush, hoverBrush;
    m_rt->CreateSolidColorBrush(ToD2DColor(c.text), &textBrush);
    m_rt->CreateSolidColorBrush(ToD2DColor(c.accent), &accentBrush);
    m_rt->CreateSolidColorBrush(ToD2DColor(c.surfaceHover), &hoverBrush);

    float yStart = YStart();
    float margin = Dpi::ScaleF(4.0f, m_dpi);
    float inflate = Dpi::ScaleF(2.0f, m_dpi);
    float gap = Dpi::ScaleF(8.0f, m_dpi);

    float contentLeft = margin;

    // ── Items ───────────────────────────────────────────────
    int visIdx = 0;  // visible item counter for layout
    for (int i = 0; i < kCategoryCount; i++) {
        if (!m_searchVisible[i]) continue;
        float alpha = m_enterAlpha[i];
        if (alpha <= 0.0f) { visIdx++; continue; }

        float top = yStart + visIdx * static_cast<float>(itemH);
        float bot = top + static_cast<float>(itemH);
        D2D1_RECT_F itemRc = D2D1::RectF(contentLeft, top + inflate,
                                           size.width - margin - 2, bot - inflate);

        bool isSelected = (i == m_selected);
        bool isPressed  = (i == m_pressed);
        bool isDragItem = (m_dragging && i == m_dragSrc);

        // Skip dragged item in normal rendering (drawn as ghost later)
        if (isDragItem) continue;

        // Hover background (shows on ALL items including selected)
        if (m_hoverAlpha[i] > 0.001f) {
            auto hoverColor = ToD2DColor(c.surfaceHover);
            hoverColor.a = m_hoverAlpha[i] * alpha;
            ComPtr<ID2D1SolidColorBrush> animHoverBrush;
            m_rt->CreateSolidColorBrush(hoverColor, &animHoverBrush);
            m_rt->FillRoundedRectangle(
                D2D1::RoundedRect(itemRc, 4.0f, 4.0f), animHoverBrush.Get());

            // Contrast border on hover (dark in light mode, light in dark mode)
            D2D1_COLOR_F hoverBorderColor = Theme::IsDark()
                ? D2D1::ColorF(1.0f, 1.0f, 1.0f, m_hoverAlpha[i] * 0.15f * alpha)
                : D2D1::ColorF(0.0f, 0.0f, 0.0f, m_hoverAlpha[i] * 0.15f * alpha);
            ComPtr<ID2D1SolidColorBrush> hoverBorderBrush;
            m_rt->CreateSolidColorBrush(hoverBorderColor, &hoverBorderBrush);
            m_rt->DrawRoundedRectangle(
                D2D1::RoundedRect(itemRc, 4.0f, 4.0f),
                hoverBorderBrush.Get(), 1.0f);
        }

        // Selected item background + contrast border
        if (isSelected) {
            D2D1_COLOR_F selColor = D2D1::ColorF(0.0f, 0.0f, 0.0f, 0.2f * alpha);
            ComPtr<ID2D1SolidColorBrush> selBgBrush;
            m_rt->CreateSolidColorBrush(selColor, &selBgBrush);
            m_rt->FillRoundedRectangle(
                D2D1::RoundedRect(itemRc, 4.0f, 4.0f), selBgBrush.Get());

            // Contrast border (dark in light mode, light in dark mode)
            D2D1_COLOR_F selBorderColor = Theme::IsDark()
                ? D2D1::ColorF(1.0f, 1.0f, 1.0f, 0.2f * alpha)
                : D2D1::ColorF(0.0f, 0.0f, 0.0f, 0.2f * alpha);
            ComPtr<ID2D1SolidColorBrush> selBorderBrush;
            m_rt->CreateSolidColorBrush(selBorderColor, &selBorderBrush);
            m_rt->DrawRoundedRectangle(
                D2D1::RoundedRect(itemRc, 4.0f, 4.0f),
                selBorderBrush.Get(), 1.0f);
        }

        // ── Active State Depth (darker on mousedown press) ──────
        if (isPressed) {
            D2D1_COLOR_F pressColor = D2D1::ColorF(0.0f, 0.0f, 0.0f, 0.15f * alpha);
            ComPtr<ID2D1SolidColorBrush> pressBrush;
            m_rt->CreateSolidColorBrush(pressColor, &pressBrush);
            m_rt->FillRoundedRectangle(
                D2D1::RoundedRect(itemRc, 4.0f, 4.0f), pressBrush.Get());
        }

        // Choose brush: accent for selected, normal for others
        ID2D1SolidColorBrush* labelBrush = isSelected ? accentBrush.Get() : textBrush.Get();

        // Icon (center horizontally when collapsed, pad when expanded)
        float fIconSz = static_cast<float>(iconSz);
        float iconX;
        if (m_widthFactor < 0.8f) {
            // Collapsed: center icon within content area (margin to size.width - margin - 2)
            float contentMid = (contentLeft + size.width - margin - 2.0f) * 0.5f;
            iconX = contentMid - fIconSz * 0.5f;
        } else {
            iconX = itemRc.left + static_cast<float>(padX);
        }
        float iconY = (top + bot - fIconSz) * 0.5f;

        // Use selected icon color (white in dark, dark in light) or normal theme icon color
        uint32_t iconColor = isSelected
            ? (Theme::IsDark() ? 0xFFFFFF : 0x191919)
            : Theme::IconColor();

        // m_iconScale repurposed as brightness (1.0 = normal, >1 = bright)
        float brightness = m_iconScale[i];
        float baseOpacity = isSelected ? 1.0f : 0.7f;
        float iconOpacity = (baseOpacity * brightness * alpha);
        if (iconOpacity > 1.0f) iconOpacity = 1.0f;

        D2D1_RECT_F iconRc = D2D1::RectF(
            iconX, iconY, iconX + fIconSz, iconY + fIconSz);

        // Try native D2D SVG rendering, fall back to bitmap
        if (!RenderContext::DrawSvgIcon(m_rt.Get(), m_items[i].iconName,
                                         iconRc, iconColor, iconOpacity)) {
            // Bitmap fallback
            auto& bmp = isSelected ? m_accentIconBitmaps[i] : m_iconBitmaps[i];
            if (bmp) {
                m_rt->DrawBitmap(bmp.Get(), iconRc, iconOpacity);
            }
        }

        // Label (fade with enter alpha, hide when collapsed)
        if (m_widthFactor > 0.6f) {
            float labelAlpha = alpha * ((m_widthFactor - 0.6f) / 0.4f);

            D2D1_COLOR_F textColor;
            if (isSelected) {
                // Pure white text in dark mode, dark text in light mode
                textColor = Theme::IsDark()
                    ? D2D1::ColorF(1.0f, 1.0f, 1.0f, labelAlpha)
                    : D2D1::ColorF(0.1f, 0.1f, 0.1f, labelAlpha);
            } else {
                textColor = ToD2DColor(c.text);
                textColor.a = labelAlpha;
            }

            ComPtr<ID2D1SolidColorBrush> animTextBrush;
            m_rt->CreateSolidColorBrush(textColor, &animTextBrush);

            float labelX = iconX + static_cast<float>(iconSz) + gap;
            D2D1_RECT_F labelRc = D2D1::RectF(labelX, top, size.width - margin - padX, bot);
            m_rt->DrawText(m_items[i].label,
                static_cast<UINT32>(wcslen(m_items[i].label)),
                itemFmt.Get(), labelRc, animTextBrush.Get());

            // Badge pill (right-aligned)
            if (m_badgeCounts[i] > 0) {
                wchar_t badge[16];
                int badgeLen = swprintf(badge, 16, L"%d", m_badgeCounts[i]);
                auto badgeFmt = Typography::Format(TypeStyle::Caption, FontWeight::Medium, m_dpi);

                float pillH = Dpi::ScaleF(18.0f, m_dpi);
                float pillPadX = Dpi::ScaleF(6.0f, m_dpi);
                float pillMinW = Dpi::ScaleF(22.0f, m_dpi);
                float pillR = pillH * 0.5f;

                // Measure badge text width
                ComPtr<IDWriteTextLayout> badgeLayout;
                RenderContext::DWrite()->CreateTextLayout(
                    badge, badgeLen, badgeFmt.Get(), 100.0f, pillH, &badgeLayout);
                DWRITE_TEXT_METRICS badgeMetrics{};
                if (badgeLayout) badgeLayout->GetMetrics(&badgeMetrics);
                float textW = badgeMetrics.width;
                float pillW = (std::max)(pillMinW, textW + pillPadX * 2);

                float pillRight = size.width - margin - Dpi::ScaleF(10.0f, m_dpi);
                float pillLeft = pillRight - pillW;
                float pillTop = (top + bot - pillH) * 0.5f;

                D2D1_RECT_F pillRc = D2D1::RectF(pillLeft, pillTop, pillRight, pillTop + pillH);

                // Background: subtle accent-tinted pill
                auto pillBg = ToD2DColor(c.accent);
                pillBg.a = 0.15f * labelAlpha;
                ComPtr<ID2D1SolidColorBrush> pillBgBrush;
                m_rt->CreateSolidColorBrush(pillBg, &pillBgBrush);
                m_rt->FillRoundedRectangle(
                    D2D1::RoundedRect(pillRc, pillR, pillR), pillBgBrush.Get());

                // Text: accent color
                auto pillTextColor = ToD2DColor(c.accent);
                pillTextColor.a = labelAlpha;
                ComPtr<ID2D1SolidColorBrush> pillTextBrush;
                m_rt->CreateSolidColorBrush(pillTextColor, &pillTextBrush);
                D2D1_RECT_F pillTextRc = D2D1::RectF(
                    pillLeft, pillTop, pillRight, pillTop + pillH);
                // Center text in pill
                badgeFmt->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
                badgeFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
                m_rt->DrawText(badge, badgeLen, badgeFmt.Get(),
                    pillTextRc, pillTextBrush.Get());
            }
        }
        visIdx++;
    }



    // ── Focus Ring (keyboard navigation only, not on click) ──
    if (m_kbFocus && m_focused >= 0 && m_focused < kCategoryCount
        && m_focused != m_selected) {
        float focusTop = yStart + m_focused * static_cast<float>(itemH);
        float focusBotF = focusTop + static_cast<float>(itemH);
        float focusOffset = Dpi::ScaleF(1.0f, m_dpi);
        D2D1_RECT_F focusRc = D2D1::RectF(
            contentLeft - focusOffset, focusTop + inflate - focusOffset,
            size.width - margin - 2 + focusOffset, focusBotF - inflate + focusOffset);

        auto focusColor = ToD2DColor(c.accent);
        focusColor.a = 0.8f;
        ComPtr<ID2D1SolidColorBrush> focusBrush;
        m_rt->CreateSolidColorBrush(focusColor, &focusBrush);
        float focusStroke = Dpi::ScaleF(2.0f, m_dpi);
        m_rt->DrawRoundedRectangle(
            D2D1::RoundedRect(focusRc, 5.0f, 5.0f),
            focusBrush.Get(), focusStroke);
    }

    // ── Drag Ghost Preview ──────────────────────────────────
    if (m_dragging && m_dragSrc >= 0 && m_dragSrc < kCategoryCount) {
        float ghostTop = m_dragY - m_dragOffsetY;
        float ghostBot = ghostTop + static_cast<float>(itemH);
        D2D1_RECT_F ghostRc = D2D1::RectF(
            contentLeft, ghostTop + inflate,
            size.width - margin - 2, ghostBot - inflate);

        // Ghost background
        D2D1_COLOR_F ghostBg = ToD2DColor(c.surfaceHover);
        ghostBg.a = 0.7f;
        ComPtr<ID2D1SolidColorBrush> ghostBgBrush;
        m_rt->CreateSolidColorBrush(ghostBg, &ghostBgBrush);
        m_rt->FillRoundedRectangle(
            D2D1::RoundedRect(ghostRc, 4.0f, 4.0f), ghostBgBrush.Get());

        // Ghost outline
        auto ghostBorder = ToD2DColor(c.accent);
        ghostBorder.a = 0.4f;
        ComPtr<ID2D1SolidColorBrush> ghostBorderBrush;
        m_rt->CreateSolidColorBrush(ghostBorder, &ghostBorderBrush);
        m_rt->DrawRoundedRectangle(
            D2D1::RoundedRect(ghostRc, 4.0f, 4.0f),
            ghostBorderBrush.Get(), 1.0f);

        // Ghost icon
        int di = m_dragSrc;
        float fIconSz = static_cast<float>(iconSz);
        float gIconX = ghostRc.left + static_cast<float>(padX);
        float gIconY = (ghostTop + ghostBot - fIconSz) * 0.5f;
        D2D1_RECT_F gIconRc = D2D1::RectF(gIconX, gIconY, gIconX + fIconSz, gIconY + fIconSz);

        uint32_t ghostIconColor = (di == m_selected)
            ? (Theme::IsDark() ? 0xFFFFFF : 0x191919)
            : Theme::IconColor();

        if (!RenderContext::DrawSvgIcon(m_rt.Get(), m_items[di].iconName,
                                         gIconRc, ghostIconColor, 0.6f)) {
            auto& ghostBmp = (di == m_selected) ? m_accentIconBitmaps[di] : m_iconBitmaps[di];
            if (ghostBmp) {
                m_rt->DrawBitmap(ghostBmp.Get(), gIconRc, 0.6f);
            }
        }

        // Ghost label
        if (m_widthFactor > 0.6f) {
            auto ghostTextColor = ToD2DColor(c.text);
            ghostTextColor.a = 0.6f;
            ComPtr<ID2D1SolidColorBrush> ghostTextBrush;
            m_rt->CreateSolidColorBrush(ghostTextColor, &ghostTextBrush);
            float gLabelX = ghostRc.left + static_cast<float>(padX) +
                            static_cast<float>(iconSz) + gap;
            D2D1_RECT_F gLabelRc = D2D1::RectF(gLabelX, ghostTop, size.width, ghostBot);
            m_rt->DrawText(m_items[di].label,
                static_cast<UINT32>(wcslen(m_items[di].label)),
                itemFmt.Get(), gLabelRc, ghostTextBrush.Get());
        }

        // Drop target indicator line
        if (m_dragTarget >= 0 && m_dragTarget < kCategoryCount && m_dragTarget != m_dragSrc) {
            float lineY = yStart + m_dragTarget * static_cast<float>(itemH);
            auto lineColor = ToD2DColor(c.accent);
            ComPtr<ID2D1SolidColorBrush> lineBrush;
            m_rt->CreateSolidColorBrush(lineColor, &lineBrush);
            m_rt->DrawLine(
                D2D1::Point2F(contentLeft, lineY),
                D2D1::Point2F(size.width - margin - 2, lineY),
                lineBrush.Get(), Dpi::ScaleF(2.0f, m_dpi));
        }
    }

    HRESULT hr = m_rt->EndDraw();
    if (hr == D2DERR_RECREATE_TARGET) m_rt.Reset();


}

// ── Hit Test ────────────────────────────────────────────────
// Maps a Y coordinate to an item index, accounting for filtered items
int Sidebar::HitTest(int y) {
    int yStartI = static_cast<int>(YStart());
    if (y < yStartI) return -1;  // click is in header area
    int itemH  = ItemHeight();
    int slot = (y - yStartI) / itemH;

    int vis = 0;
    for (int i = 0; i < kCategoryCount; i++) {
        if (!m_searchVisible[i]) continue;
        if (vis == slot) return i;
        vis++;
    }
    return -1;
}

// ── Window Proc ─────────────────────────────────────────────
LRESULT CALLBACK Sidebar::SidebarProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    Sidebar* self = nullptr;
    if (msg == WM_NCCREATE) {
        auto cs = reinterpret_cast<CREATESTRUCTW*>(lp);
        self = static_cast<Sidebar*>(cs->lpCreateParams);
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(self));
        self->m_hwnd = hwnd;
    } else {
        self = reinterpret_cast<Sidebar*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
    }
    if (!self) return DefWindowProcW(hwnd, msg, wp, lp);

    switch (msg) {
    case WM_NOTIFY: {
        auto* nmhdr = reinterpret_cast<NMHDR*>(lp);
        if (nmhdr->hwndFrom == self->m_tooltip && nmhdr->code == TTN_SHOW) {
            // Use DWM rounded corners (Windows 11+) — preserves the border
            constexpr DWORD DWMWA_WINDOW_CORNER_PREFERENCE_VAL = 33;
            DWORD pref = 3;  // DWMWCP_ROUNDSMALL (~4px corners)
            DwmSetWindowAttribute(self->m_tooltip,
                DWMWA_WINDOW_CORNER_PREFERENCE_VAL, &pref, sizeof(pref));
        }
        break;
    }
    case WM_PAINT: {
        PAINTSTRUCT ps;
        BeginPaint(hwnd, &ps);
        self->OnPaint();
        EndPaint(hwnd, &ps);
        return 0;
    }

    case WM_SIZE:
        if (self->m_rt) {
            RECT rc;
            GetClientRect(hwnd, &rc);
            self->m_rt->Resize(D2D1::SizeU(rc.right, rc.bottom));
        }
        return 0;

    case WM_LBUTTONDOWN: {
        float clickX = static_cast<float>(GET_X_LPARAM(lp));
        float clickY = static_cast<float>(GET_Y_LPARAM(lp));

        // Chevron click detection (header area, works in both states)
        {
            float chevTop = Dpi::ScaleF(14.0f, self->m_dpi);
            float chevH = Dpi::ScaleF(20.0f, self->m_dpi);
            float iconSzF = Dpi::ScaleF(14.0f, self->m_dpi);
            float pad = Dpi::ScaleF(4.0f, self->m_dpi);
            RECT rc;
            GetClientRect(hwnd, &rc);
            float chevX;
            if (self->m_widthFactor > 0.6f) {
                chevX = static_cast<float>(rc.right) - Dpi::ScaleF(16.0f, self->m_dpi) - iconSzF;
            } else {
                chevX = (static_cast<float>(rc.right) - iconSzF) * 0.5f;
            }
            if (clickX >= chevX - pad && clickX <= chevX + iconSzF + pad &&
                clickY >= chevTop - pad && clickY <= chevTop + chevH + pad) {
                self->ToggleCollapsed();
                SendMessageW(self->m_parent, WM_SIZE, 0, 0);
                return 0;
            }
        }

        int idx = self->HitTest(static_cast<int>(clickY));

        if (idx >= 0) {
            // Active depth press
            self->m_pressed = idx;

            // Start drag tracking
            self->m_dragSrc = idx;
            self->m_dragY = clickY;
            float yStartF = self->YStart();
            self->m_dragOffsetY = clickY - (yStartF + idx * static_cast<float>(self->ItemHeight()));

            SetCapture(hwnd);
            InvalidateRect(hwnd, nullptr, FALSE);
        }

        if (idx >= 0 && idx != self->m_selected) {
            self->AnimateSelection(idx);
            self->m_selected = idx;
            SendMessageW(self->m_parent, WM_COMMAND,
                MAKEWPARAM(GetDlgCtrlID(hwnd), idx),
                reinterpret_cast<LPARAM>(hwnd));
        }

        // Set keyboard focus but don't show focus ring for mouse clicks
        SetFocus(hwnd);
        self->m_kbFocus = false;  // mouse click, not keyboard nav
        self->m_focused = idx >= 0 ? idx : self->m_focused;
        return 0;
    }

    case WM_LBUTTONUP: {
        self->m_pressed = -1;

        if (self->m_dragging && self->m_dragSrc >= 0 && self->m_dragTarget >= 0
            && self->m_dragTarget != self->m_dragSrc) {
            int src = self->m_dragSrc;
            int dst = self->m_dragTarget;

            // Save the source item data
            SidebarItem tmpItem = self->m_items[src];
            int tmpBadge = self->m_badgeCounts[src];
            bool tmpVis = self->m_searchVisible[src];
            auto tmpIcon = std::move(self->m_iconBitmaps[src]);
            auto tmpAccent = std::move(self->m_accentIconBitmaps[src]);

            // Shift elements
            if (src < dst) {
                for (int j = src; j < dst; j++) {
                    self->m_items[j] = self->m_items[j + 1];
                    self->m_badgeCounts[j] = self->m_badgeCounts[j + 1];
                    self->m_searchVisible[j] = self->m_searchVisible[j + 1];
                    self->m_iconBitmaps[j] = std::move(self->m_iconBitmaps[j + 1]);
                    self->m_accentIconBitmaps[j] = std::move(self->m_accentIconBitmaps[j + 1]);
                }
            } else {
                for (int j = src; j > dst; j--) {
                    self->m_items[j] = self->m_items[j - 1];
                    self->m_badgeCounts[j] = self->m_badgeCounts[j - 1];
                    self->m_searchVisible[j] = self->m_searchVisible[j - 1];
                    self->m_iconBitmaps[j] = std::move(self->m_iconBitmaps[j - 1]);
                    self->m_accentIconBitmaps[j] = std::move(self->m_accentIconBitmaps[j - 1]);
                }
            }
            self->m_items[dst] = tmpItem;
            self->m_badgeCounts[dst] = tmpBadge;
            self->m_searchVisible[dst] = tmpVis;
            self->m_iconBitmaps[dst] = std::move(tmpIcon);
            self->m_accentIconBitmaps[dst] = std::move(tmpAccent);

            // Track selection to follow the moved item
            if (self->m_selected == src) {
                self->m_selected = dst;
            } else if (src < dst && self->m_selected > src && self->m_selected <= dst) {
                self->m_selected--;
            } else if (src > dst && self->m_selected >= dst && self->m_selected < src) {
                self->m_selected++;
            }
            self->m_selectionY = self->ItemYCenter(self->m_selected);
            self->m_selectionTargetY = self->m_selectionY;
        }

        if (self->m_dragging) {
            self->m_dragging = false;
            SetCursor(LoadCursorW(nullptr, IDC_ARROW));
        }
        self->m_dragSrc = -1;
        self->m_dragTarget = -1;
        ReleaseCapture();
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;
    }

    case WM_RBUTTONUP: {
        int mouseY = GET_Y_LPARAM(lp);
        int idx = self->HitTest(mouseY);
        if (idx < 0) return 0;

        HMENU popup = CreatePopupMenu();
        constexpr UINT IDM_CTX_MOVEUP   = 9001;
        constexpr UINT IDM_CTX_MOVEDOWN = 9002;

        if (idx > 0)
            AppendMenuW(popup, MF_STRING, IDM_CTX_MOVEUP,   L"Move Up");
        if (idx < kCategoryCount - 1)
            AppendMenuW(popup, MF_STRING, IDM_CTX_MOVEDOWN, L"Move Down");

        POINT pt;
        GetCursorPos(&pt);
        UINT cmd = TrackPopupMenu(popup, TPM_RETURNCMD | TPM_RIGHTBUTTON,
            pt.x, pt.y, 0, hwnd, nullptr);
        DestroyMenu(popup);

        if (cmd == IDM_CTX_MOVEUP && idx > 0) {
            // Swap with item above
            std::swap(self->m_items[idx], self->m_items[idx - 1]);
            std::swap(self->m_badgeCounts[idx], self->m_badgeCounts[idx - 1]);
            std::swap(self->m_searchVisible[idx], self->m_searchVisible[idx - 1]);
            std::swap(self->m_iconBitmaps[idx], self->m_iconBitmaps[idx - 1]);
            std::swap(self->m_accentIconBitmaps[idx], self->m_accentIconBitmaps[idx - 1]);
            if (self->m_selected == idx) self->m_selected = idx - 1;
            else if (self->m_selected == idx - 1) self->m_selected = idx;
            self->m_selectionY = self->ItemYCenter(self->m_selected);
            self->m_selectionTargetY = self->m_selectionY;
        } else if (cmd == IDM_CTX_MOVEDOWN && idx < kCategoryCount - 1) {
            std::swap(self->m_items[idx], self->m_items[idx + 1]);
            std::swap(self->m_badgeCounts[idx], self->m_badgeCounts[idx + 1]);
            std::swap(self->m_searchVisible[idx], self->m_searchVisible[idx + 1]);
            std::swap(self->m_iconBitmaps[idx], self->m_iconBitmaps[idx + 1]);
            std::swap(self->m_accentIconBitmaps[idx], self->m_accentIconBitmaps[idx + 1]);
            if (self->m_selected == idx) self->m_selected = idx + 1;
            else if (self->m_selected == idx + 1) self->m_selected = idx;
            self->m_selectionY = self->ItemYCenter(self->m_selected);
            self->m_selectionTargetY = self->m_selectionY;
        }
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;
    }

    case WM_MOUSEMOVE: {
        int mouseY = GET_Y_LPARAM(lp);
        int mouseX = GET_X_LPARAM(lp);

        // Relay mouse event to tooltip
        if (self->m_tooltip) {
            MSG relayMsg{};
            relayMsg.hwnd    = hwnd;
            relayMsg.message = msg;
            relayMsg.wParam  = wp;
            relayMsg.lParam  = lp;
            relayMsg.time    = GetMessageTime();
            DWORD pos = GetMessagePos();
            relayMsg.pt = {GET_X_LPARAM(pos), GET_Y_LPARAM(pos)};
            SendMessageW(self->m_tooltip, TTM_RELAYEVENT, 0,
                reinterpret_cast<LPARAM>(&relayMsg));
        }

        // Drag detection: if mouse moved > 5px while button held
        if (self->m_dragSrc >= 0 && !self->m_dragging) {
            float dist = static_cast<float>(mouseY) - self->m_dragY;
            if (dist > 5.0f || dist < -5.0f) {
                self->m_dragging = true;
                SetCursor(LoadCursorW(nullptr, IDC_SIZEALL));
            }
        }

        if (self->m_dragging) {
            self->m_dragY = static_cast<float>(mouseY);
            int target = self->HitTest(mouseY);
            if (target >= 0) self->m_dragTarget = target;
            InvalidateRect(hwnd, nullptr, FALSE);
            return 0;
        }

        // Chevron hover tracking
        {
            float chevTop = Dpi::ScaleF(14.0f, self->m_dpi);
            float chevH = Dpi::ScaleF(20.0f, self->m_dpi);
            float iconSzF = Dpi::ScaleF(14.0f, self->m_dpi);
            float pad = Dpi::ScaleF(4.0f, self->m_dpi);
            RECT rc;
            GetClientRect(hwnd, &rc);
            float chevX;
            if (self->m_widthFactor > 0.6f) {
                chevX = static_cast<float>(rc.right) - Dpi::ScaleF(16.0f, self->m_dpi) - iconSzF;
            } else {
                chevX = (static_cast<float>(rc.right) - iconSzF) * 0.5f;
            }
            bool wasHovered = self->m_chevronHovered;
            self->m_chevronHovered = (
                static_cast<float>(mouseX) >= chevX - pad &&
                static_cast<float>(mouseX) <= chevX + iconSzF + pad &&
                static_cast<float>(mouseY) >= chevTop - pad &&
                static_cast<float>(mouseY) <= chevTop + chevH + pad);
            if (self->m_chevronHovered != wasHovered) {
                InvalidateRect(hwnd, nullptr, FALSE);
            }
        }

        int idx = self->HitTest(mouseY);
        if (idx != self->m_hovered) {
            int prev = self->m_hovered;
            self->m_hovered = idx;

            // Fade out + reset scale on previous
            if (prev >= 0) {
                self->AnimateHover(prev, false);
                self->m_iconScale[prev] = 1.0f;  // snap reset
            }
            // Fade in + pulse on new
            if (idx >= 0) {
                self->AnimateHover(idx, true);
                self->AnimateIconPulse(idx);
            }

            TRACKMOUSEEVENT tme{};
            tme.cbSize    = sizeof(tme);
            tme.dwFlags   = TME_LEAVE;
            tme.hwndTrack = hwnd;
            TrackMouseEvent(&tme);
        }

        // Manual tooltip: show when collapsed and hovering an item
        if (self->m_tooltip) {
            int hovIdx = self->HitTest(mouseY);
            if (self->m_widthFactor < 0.8f && hovIdx >= 0 && hovIdx < kCategoryCount) {
                // Update tooltip text
                TTTOOLINFOW ti{};
                ti.cbSize   = TTTOOLINFOW_V2_SIZE;
                ti.hwnd     = self->m_hwnd;
                ti.uId      = 0;
                ti.lpszText = const_cast<wchar_t*>(self->m_items[hovIdx].label);
                SendMessageW(self->m_tooltip, TTM_UPDATETIPTEXTW, 0,
                    reinterpret_cast<LPARAM>(&ti));

                // Position at right edge of sidebar, vertically centered on item
                RECT rc;
                GetClientRect(hwnd, &rc);
                POINT screenPt = {rc.right, static_cast<int>(self->YStart()) +
                    hovIdx * self->ItemHeight() + self->ItemHeight() / 2};
                ClientToScreen(hwnd, &screenPt);
                SendMessageW(self->m_tooltip, TTM_TRACKPOSITION, 0,
                    MAKELPARAM(screenPt.x + 4, screenPt.y - 10));

                // Set theme colors
                COLORREF tipBg   = Theme::IsDark() ? RGB(50, 50, 55)   : RGB(255, 255, 255);
                COLORREF tipText = Theme::IsDark() ? RGB(230, 230, 230) : RGB(30, 30, 30);
                SendMessageW(self->m_tooltip, TTM_SETTIPBKCOLOR, tipBg, 0);
                SendMessageW(self->m_tooltip, TTM_SETTIPTEXTCOLOR, tipText, 0);

                // Activate
                ti.lpszText = nullptr;
                SendMessageW(self->m_tooltip, TTM_TRACKACTIVATE, TRUE,
                    reinterpret_cast<LPARAM>(&ti));
            } else {
                TTTOOLINFOW ti{};
                ti.cbSize = TTTOOLINFOW_V2_SIZE;
                ti.hwnd   = self->m_hwnd;
                ti.uId    = 0;
                SendMessageW(self->m_tooltip, TTM_TRACKACTIVATE, FALSE,
                    reinterpret_cast<LPARAM>(&ti));
            }
        }

        return 0;
    }

    case WM_MOUSELEAVE:
        if (self->m_hovered >= 0) {
            self->AnimateHover(self->m_hovered, false);
            self->m_iconScale[self->m_hovered] = 1.0f;
            self->m_hovered = -1;
        }
        // Hide tooltip on mouse leave
        if (self->m_tooltip) {
            TTTOOLINFOW ti{};
            ti.cbSize = TTTOOLINFOW_V2_SIZE;
            ti.hwnd   = self->m_hwnd;
            ti.uId    = 0;
            SendMessageW(self->m_tooltip, TTM_TRACKACTIVATE, FALSE,
                reinterpret_cast<LPARAM>(&ti));
        }
        self->m_chevronHovered = false;
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;

    case WM_SETFOCUS:
        // Only show focus ring if gained via keyboard (Tab), not mouse
        // m_kbFocus is set explicitly in WM_KEYDOWN
        if (self->m_focused < 0) self->m_focused = self->m_selected;
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;

    case WM_KILLFOCUS:
        self->m_kbFocus = false;
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;

    case WM_KEYDOWN:
        switch (wp) {
        case VK_UP:
            self->m_kbFocus = true;
            if (self->m_focused > 0) {
                self->m_focused--;
            }
            InvalidateRect(hwnd, nullptr, FALSE);
            return 0;
        case VK_DOWN:
            self->m_kbFocus = true;
            if (self->m_focused < kCategoryCount - 1) {
                self->m_focused++;
            }
            InvalidateRect(hwnd, nullptr, FALSE);
            return 0;
        case VK_RETURN:
        case VK_SPACE:
            if (self->m_focused >= 0 && self->m_focused != self->m_selected) {
                self->AnimateSelection(self->m_focused);
                self->m_selected = self->m_focused;
                SendMessageW(self->m_parent, WM_COMMAND,
                    MAKEWPARAM(GetDlgCtrlID(hwnd), self->m_selected),
                    reinterpret_cast<LPARAM>(hwnd));
            }
            return 0;
        case VK_ESCAPE:
            [[fallthrough]];
        case VK_TAB: {
            LPARAM shift = (wp == VK_TAB && (GetKeyState(VK_SHIFT) & 0x8000)) ? 1 : 0;
            SendMessageW(self->m_parent, WM_RESUI_TAB,
                reinterpret_cast<WPARAM>(hwnd), shift);
            return 0;
        }
        }
        break;


    case WM_GETDLGCODE: {
        LRESULT code = DLGC_WANTARROWS | DLGC_WANTTAB | DLGC_WANTCHARS;
        auto* pmsg = reinterpret_cast<MSG*>(lp);
        if (pmsg && (pmsg->message == WM_KEYDOWN || pmsg->message == WM_KEYUP)) {
            if (pmsg->wParam == VK_RETURN || pmsg->wParam == VK_SPACE ||
                pmsg->wParam == VK_ESCAPE || pmsg->wParam == VK_BACK)
                code |= DLGC_WANTMESSAGE;
        }
        return code;
    }

    case WM_ERASEBKGND:
        return 1;
    }

    return DefWindowProcW(hwnd, msg, wp, lp);
}

} // namespace rui
