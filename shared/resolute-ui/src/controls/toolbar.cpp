#include <resolute/controls/toolbar.h>
#include <resolute/controls/popupmenu.h>
#include <resolute/typography.h>
#include <windowsx.h>  // GET_X_LPARAM, GET_Y_LPARAM
#include <cmath>
#include <algorithm>

namespace rui {

Toolbar::~Toolbar() { AnimationManager::Instance().CancelOwner(this); }

// ── Accessors ───────────────────────────────────────────────
int  Toolbar::ScaledHeight() const { return Dpi::Scale(BASE_HEIGHT, m_dpi); }
HWND Toolbar::Handle() const { return m_hwnd; }
int  Toolbar::ItemWidth(int idx) const {
    // In compact mode, labeled buttons shrink to icon-only width
    if (m_compact && kItems[idx].label && kItems[idx].label[0]
        && kItems[idx].kind != ItemKind::Separator) {
        return Dpi::Scale(36, m_dpi);
    }
    return Dpi::Scale(kItems[idx].baseWidth, m_dpi);
}
int  Toolbar::Pad() const { return Dpi::Scale(4, m_dpi); }
int  Toolbar::Margin() const { return Dpi::Scale(8, m_dpi); }
int  Toolbar::Height() const { return Dpi::Scale(BASE_HEIGHT, m_dpi); }
int  Toolbar::IconSize() const { return Dpi::Scale(BASE_ICON_SIZE, m_dpi); }

const char* Toolbar::CurrentThemeIcon() const {
    switch (Theme::GetMode()) {
    case Theme::Mode::Light:  return "theme-light";
    case Theme::Mode::Dark:   return "theme-dark";
    case Theme::Mode::System: return "theme-system";
    }
    return "theme-dark";
}

// ── Create ──────────────────────────────────────────────────
void Toolbar::Create(HWND parent, HINSTANCE hInst, int id) {
    m_parent = parent;

    for (int i = 0; i < kItemCount; i++) {
        m_hoverAlpha[i] = 0.0f;
        m_pressScale[i] = 1.0f;
    }

    WNDCLASSEXW wc{};
    wc.cbSize        = sizeof(wc);
    wc.style         = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc   = ToolbarProc;
    wc.hInstance     = hInst;
    wc.hCursor       = LoadCursorW(nullptr, IDC_HAND);
    wc.lpszClassName = L"ResoluteToolbar";
    RegisterClassExW(&wc);

    m_hwnd = CreateWindowExW(
        0, L"ResoluteToolbar", nullptr,
        WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_TABSTOP,
        0, 0, 800, BASE_HEIGHT,
        parent, reinterpret_cast<HMENU>(static_cast<INT_PTR>(id)),
        hInst, this
    );

    m_dpi = Dpi::Get(m_hwnd);
    CreateRenderTarget();
    RebuildIconCache();

}

void Toolbar::Resize(int x, int y, int w, int h) {
    MoveWindow(m_hwnd, x, y, w, h, TRUE);
    if (m_rt) m_rt->Resize(D2D1::SizeU(w, h));
}

void Toolbar::Repaint() { InvalidateRect(m_hwnd, nullptr, FALSE); }

void Toolbar::UpdateDpi(int dpi) {
    m_dpi = dpi;
    m_cachedIconSize = 0;
    Repaint();
}

// ── D2D Setup ───────────────────────────────────────────────
void Toolbar::CreateRenderTarget() {
    m_rt = RenderContext::CreateHwndTarget(m_hwnd);
    m_cachedIconSize = 0;
}

void Toolbar::RebuildIconCache() {
    if (!m_rt) return;
    int sz = IconSize();
    uint32_t color = Theme::IconColor();
    uint32_t accentColor = Theme::AccentIconColor();

    bool needsRebuild = (sz != m_cachedIconSize) ||
                        (color != m_cachedIconColor) ||
                        (accentColor != m_cachedAccentColor);
    if (!needsRebuild) return;

    for (int i = 0; i < kItemCount; i++) {
        // Skip separators — no icons
        if (kItems[i].kind != ItemKind::Button &&
            kItems[i].kind != ItemKind::Dropdown) continue;

        const char* name = kItems[i].iconName;
        // For theme button, use current theme icon
        if (kItems[i].id == IDC_TB_THEME)
            name = CurrentThemeIcon();

        m_iconBitmaps[i].Reset();
        auto* rgba = LucideIcons::Render(name, sz, color);
        if (rgba) {
            m_iconBitmaps[i] = RenderContext::CreateBitmapFromRGBA(
                m_rt.Get(), rgba, sz, sz);
            LucideIcons::Free(rgba);
        }

        m_accentIconBitmaps[i].Reset();
        rgba = LucideIcons::Render(name, sz, accentColor);
        if (rgba) {
            m_accentIconBitmaps[i] = RenderContext::CreateBitmapFromRGBA(
                m_rt.Get(), rgba, sz, sz);
            LucideIcons::Free(rgba);
        }
    }
    m_cachedIconSize = sz;
    m_cachedIconColor = color;
    m_cachedAccentColor = accentColor;
}

// ── Layout ──────────────────────────────────────────────────
D2D1_RECT_F Toolbar::ItemRect(int idx, float totalWidth) const {
    float pad    = static_cast<float>(Pad());
    float margin = static_cast<float>(Margin());
    float h      = static_cast<float>(Height());
    float x      = margin;
    float rightX = totalWidth - margin;

    float rightBtns[kItemCount];
    for (int i = kItemCount - 1; i >= 0; i--) {
        if (kItems[i].rightAlign) {
            rightX -= static_cast<float>(ItemWidth(i)) + pad;
            rightBtns[i] = rightX;
        } else {
            rightBtns[i] = -1;
        }
    }

    if (kItems[idx].rightAlign) {
        float bx = rightBtns[idx];
        return D2D1::RectF(bx, pad, bx + static_cast<float>(ItemWidth(idx)), h - pad);
    }

    for (int i = 0; i < idx; i++) {
        if (!kItems[i].rightAlign)
            x += static_cast<float>(ItemWidth(i)) + pad;
    }


    return D2D1::RectF(x, pad, x + static_cast<float>(ItemWidth(idx)), h - pad);
}

int Toolbar::HitTest(int mx, int my, float totalWidth) {
    for (int i = 0; i < kItemCount; i++) {
        // Separators are not clickable
        if (kItems[i].kind == ItemKind::Separator) continue;
        // Skip overflowed items
        if (m_overflowStart >= 0 && !kItems[i].rightAlign && i >= m_overflowStart)
            continue;
        auto r = ItemRect(i, totalWidth);
        if (mx >= r.left && mx <= r.right && my >= r.top && my <= r.bottom)
            return i;
    }
    // Check overflow button
    if (m_overflowStart >= 0 && m_overflowStart > 0) {
        auto lastRc = ItemRect(m_overflowStart - 1, totalWidth);
        float overW = Dpi::ScaleF(36.0f, m_dpi);
        float padF  = static_cast<float>(Pad());
        float hF    = static_cast<float>(Height());
        D2D1_RECT_F overRc = D2D1::RectF(
            lastRc.right + padF, padF,
            lastRc.right + padF + overW, hF - padF);
        if (mx >= overRc.left && mx <= overRc.right &&
            my >= overRc.top && my <= overRc.bottom)
            return -2;  // special: overflow button
    }
    return -1;
}

// ── Animation Triggers ──────────────────────────────────────
void Toolbar::AnimateHover(int idx, bool entering) {
    auto& mgr = AnimationManager::Instance();
    if (m_hoverAnimId[idx]) mgr.Cancel(m_hoverAnimId[idx]);

    float from = m_hoverAlpha[idx];
    float to   = entering ? 1.0f : 0.0f;
    m_hoverAnimId[idx] = mgr.AnimateFor(this, 
        from, to, entering ? 150.0f : 250.0f,
        entering ? ease::OutQuart : ease::InQuad,
        [this, idx](float v, const Animation&) {
            m_hoverAlpha[idx] = v;
            Repaint();
        }
    );
}

void Toolbar::AnimateIndicator(int btnIdx, float totalWidth) {
    auto& mgr = AnimationManager::Instance();
    if (m_indicatorAnimId) mgr.Cancel(m_indicatorAnimId);

    auto targetRc = ItemRect(btnIdx, totalWidth);
    float targetX = targetRc.left;
    float targetW = targetRc.right - targetRc.left;
    float fromX = m_indicatorX;
    float fromW = m_indicatorW;

    m_indicatorAnimId = mgr.AnimateFor(this, 
        0.0f, 1.0f, 300.0f,
        ease::OutQuart,
        [this, fromX, fromW, targetX, targetW](float t, const Animation&) {
            m_indicatorX = fromX + (targetX - fromX) * t;
            m_indicatorW = fromW + (targetW - fromW) * t;
            Repaint();
        }
    );
}

void Toolbar::AnimateRefreshSpin() {
    auto& mgr = AnimationManager::Instance();
    if (m_refreshAnimId) mgr.Cancel(m_refreshAnimId);

    m_refreshAngle = 0.0f;
    m_refreshAnimId = mgr.AnimateFor(this, 
        0.0f, -360.0f, 600.0f,
        ease::InOutCubic,
        [this](float v, const Animation&) {
            m_refreshAngle = v;
            Repaint();
        }
    );
}

void Toolbar::ShowTooltip(int idx) {
    m_tooltipIdx = idx;
    if (m_tooltipTimer) KillTimer(m_hwnd, m_tooltipTimer);
    m_tooltipTimer = SetTimer(m_hwnd, 0xAA01, 500, nullptr);
}

void Toolbar::HideTooltip() {
    if (m_tooltipTimer) {
        KillTimer(m_hwnd, m_tooltipTimer);
        m_tooltipTimer = 0;
    }
    m_tooltipIdx = -1;
    m_tooltipAlpha = 0.0f;
}


// ── Paint ───────────────────────────────────────────────────
void Toolbar::OnPaint() {
    if (!m_rt) { CreateRenderTarget(); if (!m_rt) return; }
    RebuildIconCache();

    auto& c = Theme::Colors();
    int iconSz = IconSize();

    m_rt->BeginDraw();
    m_rt->Clear(ToD2DColor(c.toolbar));

    auto size = m_rt->GetSize();

    // ── Compact mode + overflow calculation ─────────────────
    {
        // Calculate right-aligned items total width
        float rightTotal = 0;
        int pad = Pad();
        int margin = Margin();
        for (int i = 0; i < kItemCount; i++) {
            if (kItems[i].rightAlign)
                rightTotal += static_cast<float>(Dpi::Scale(kItems[i].baseWidth, m_dpi) + pad);
        }
        float avail = size.width - static_cast<float>(margin * 2) - rightTotal;

        // First try normal widths
        float leftTotal = 0;
        for (int i = 0; i < kItemCount; i++) {
            if (!kItems[i].rightAlign)
                leftTotal += static_cast<float>(Dpi::Scale(kItems[i].baseWidth, m_dpi) + pad);
        }

        if (leftTotal > avail) {
            m_compact = true;
            // Recalculate with compact widths
            leftTotal = 0;
            for (int i = 0; i < kItemCount; i++) {
                if (!kItems[i].rightAlign) {
                    int w = (kItems[i].label && kItems[i].label[0] &&
                             kItems[i].kind != ItemKind::Separator)
                        ? Dpi::Scale(36, m_dpi) : Dpi::Scale(kItems[i].baseWidth, m_dpi);
                    leftTotal += static_cast<float>(w + pad);
                }
            }
            if (leftTotal > avail) {
                // Still overflowing — find overflow start
                float overflowBtnW = static_cast<float>(Dpi::Scale(36, m_dpi) + pad);
                float budget = avail - overflowBtnW;
                float accum = 0;
                m_overflowStart = -1;
                for (int i = 0; i < kItemCount; i++) {
                    if (kItems[i].rightAlign) continue;
                    int w = (kItems[i].label && kItems[i].label[0] &&
                             kItems[i].kind != ItemKind::Separator)
                        ? Dpi::Scale(36, m_dpi) : Dpi::Scale(kItems[i].baseWidth, m_dpi);
                    accum += static_cast<float>(w + pad);
                    if (accum > budget) {
                        m_overflowStart = i;
                        break;
                    }
                }
            } else {
                m_overflowStart = -1;
            }
        } else {
            m_compact = false;
            m_overflowStart = -1;
        }
    }

    // Bottom border
    ComPtr<ID2D1SolidColorBrush> borderBrush;
    m_rt->CreateSolidColorBrush(ToD2DColor(c.border), &borderBrush);
    m_rt->DrawLine(
        D2D1::Point2F(0, size.height - 0.5f),
        D2D1::Point2F(size.width, size.height - 0.5f),
        borderBrush.Get(), 1.0f
    );

    auto textFmt = Typography::Format(TypeStyle::Body, FontWeight::Regular, m_dpi);
    if (textFmt) {
        textFmt->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
        textFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
    }

    ComPtr<ID2D1SolidColorBrush> textBrush, accentBrush, hoverBgBrush, activeBrush;
    m_rt->CreateSolidColorBrush(ToD2DColor(c.text), &textBrush);
    m_rt->CreateSolidColorBrush(ToD2DColor(c.accent), &accentBrush);
    m_rt->CreateSolidColorBrush(ToD2DColor(c.surfaceHover), &hoverBgBrush);

    // Active button text: white in dark mode, dark in light mode
    D2D1_COLOR_F activeColor = Theme::IsDark()
        ? D2D1::ColorF(1.0f, 1.0f, 1.0f)
        : D2D1::ColorF(0.1f, 0.1f, 0.1f);
    m_rt->CreateSolidColorBrush(activeColor, &activeBrush);

    // ── Items ───────────────────────────────────────────────
    for (int i = 0; i < kItemCount; i++) {
        // Skip overflowed items (they go in the overflow menu)
        if (m_overflowStart >= 0 && !kItems[i].rightAlign && i >= m_overflowStart)
            continue;

        auto itemRc = ItemRect(i, size.width);

        // ── Separator ───────────────────────────────────────
        if (kItems[i].kind == ItemKind::Separator) {
            float sepX = (itemRc.left + itemRc.right) * 0.5f;
            float sepInset = Dpi::ScaleF(6.0f, m_dpi);
            auto sepColor = ToD2DColor(c.border);
            sepColor.a = 0.35f;
            ComPtr<ID2D1SolidColorBrush> sepBrush;
            m_rt->CreateSolidColorBrush(sepColor, &sepBrush);
            m_rt->DrawLine(
                D2D1::Point2F(sepX, itemRc.top + sepInset),
                D2D1::Point2F(sepX, itemRc.bottom - sepInset),
                sepBrush.Get(), 1.0f);
            continue;
        }

        // ── Button / Dropdown ───────────────────────────────
        bool active = false;  // No toggle items in current layout

        D2D1_RECT_F btnRc = itemRc;

        // Apply press scale (shrink inward) — skip for dropdowns to avoid content shift
        float scale = m_pressScale[i];
        if (scale < 1.0f && kItems[i].kind != ItemKind::Dropdown) {
            float cx = (btnRc.left + btnRc.right) * 0.5f;
            float cy = (btnRc.top + btnRc.bottom) * 0.5f;
            float hw = (btnRc.right - btnRc.left) * 0.5f * scale;
            float hh = (btnRc.bottom - btnRc.top) * 0.5f * scale;
            btnRc = D2D1::RectF(cx - hw, cy - hh, cx + hw, cy + hh);
        }

        // Active button filled background
        if (active) {
            auto accentColor = ToD2DColor(c.accent);
            accentColor.a = Theme::IsDark() ? 0.85f : 0.90f;
            ComPtr<ID2D1SolidColorBrush> activeBgBrush;
            m_rt->CreateSolidColorBrush(accentColor, &activeBgBrush);
            m_rt->FillRoundedRectangle(
                D2D1::RoundedRect(btnRc, 4.0f, 4.0f), activeBgBrush.Get());
        }

        // Hover glow background
        if (m_hoverAlpha[i] > 0.001f) {
            auto hoverColor = active
                ? D2D1::ColorF(1.0f, 1.0f, 1.0f, m_hoverAlpha[i] * 0.1f)
                : ToD2DColor(c.surfaceHover);
            if (!active) hoverColor.a = m_hoverAlpha[i];
            ComPtr<ID2D1SolidColorBrush> animHoverBrush;
            m_rt->CreateSolidColorBrush(hoverColor, &animHoverBrush);
            m_rt->FillRoundedRectangle(
                D2D1::RoundedRect(btnRc, 4.0f, 4.0f), animHoverBrush.Get());

            if (!active) {
                // Subtle border on hover (non-active only)
                auto borderColor = ToD2DColor(c.border);
                borderColor.a = m_hoverAlpha[i] * 0.5f;
                ComPtr<ID2D1SolidColorBrush> animBorderBrush;
                m_rt->CreateSolidColorBrush(borderColor, &animBorderBrush);
                m_rt->DrawRoundedRectangle(
                    D2D1::RoundedRect(btnRc, 4.0f, 4.0f), animBorderBrush.Get(), 1.0f);
            }
        }

        // Icon + label layout
        bool hasLabel = !m_compact && kItems[i].label && kItems[i].label[0];
        float fIconSz = static_cast<float>(iconSz);
        float gap = Dpi::ScaleF(4.0f, m_dpi);

        // Choose correct icon name (theme button uses current mode icon)
        const char* iconName = kItems[i].iconName;
        if (kItems[i].id == IDC_TB_THEME)
            iconName = CurrentThemeIcon();

        uint32_t iconColor = active
            ? (Theme::IsDark() ? 0xFFFFFF : 0x191919)
            : Theme::IconColor();

        if (hasLabel) {
            // Icon + text side by side with horizontal padding
            float padH = Dpi::ScaleF(8.0f, m_dpi);
            float iconY = (btnRc.top + btnRc.bottom - fIconSz) * 0.5f;
            float iconX = btnRc.left + padH;

            // Draw icon
            D2D1_RECT_F iconRc = D2D1::RectF(
                iconX, iconY, iconX + fIconSz, iconY + fIconSz);
            float iconOp = active ? 1.0f : 0.8f;

            if (!RenderContext::DrawSvgIcon(m_rt.Get(), iconName,
                                             iconRc, iconColor, iconOp)) {
                auto& bmp = active ? m_accentIconBitmaps[i] : m_iconBitmaps[i];
                if (bmp) m_rt->DrawBitmap(bmp.Get(), iconRc, iconOp);
            }

            // Draw text — use DrawText with PARAGRAPH_ALIGNMENT_CENTER
            // for proper optical centering alongside icon
            auto* brush = active ? activeBrush.Get() : textBrush.Get();
            auto labelFmt = Typography::Format(TypeStyle::Body,
                active ? FontWeight::SemiBold : FontWeight::Regular, m_dpi);
            float textEndX = iconX + fIconSz + gap; // fallback
            if (labelFmt) {
                labelFmt->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_LEADING);
                labelFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
                labelFmt->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
                D2D1_RECT_F labelRc = D2D1::RectF(
                    iconX + fIconSz + gap, btnRc.top,
                    btnRc.right - padH, btnRc.bottom);
                m_rt->DrawText(kItems[i].label,
                    static_cast<UINT32>(wcslen(kItems[i].label)),
                    labelFmt.Get(), labelRc, brush);

                // Measure actual text width for chevron positioning
                if (kItems[i].kind == ItemKind::Dropdown) {
                    auto dw = RenderContext::DWrite();
                    if (dw) {
                        ComPtr<IDWriteTextLayout> tl;
                        UINT32 labelLen = static_cast<UINT32>(wcslen(kItems[i].label));
                        dw->CreateTextLayout(kItems[i].label, labelLen,
                            labelFmt.Get(), 500.0f, 100.0f, &tl);
                        if (tl) {
                            DWRITE_TEXT_METRICS tm{};
                            tl->GetMetrics(&tm);
                            textEndX = iconX + fIconSz + gap + tm.width;
                        }
                    }
                }
            }

            // Dropdown chevron-down icon — positioned after label text
            if (kItems[i].kind == ItemKind::Dropdown) {
                float chevSz = Dpi::ScaleF(14.0f, m_dpi);
                float chevGap = Dpi::ScaleF(4.0f, m_dpi);
                float chevX = textEndX + chevGap;
                float chevY = (btnRc.top + btnRc.bottom - chevSz) * 0.5f;
                D2D1_RECT_F chevRc = D2D1::RectF(
                    chevX, chevY, chevX + chevSz, chevY + chevSz);
                RenderContext::DrawSvgIcon(m_rt.Get(), "chevron-down",
                    chevRc, iconColor, 0.6f);
            }
        } else {
            // Icon only (centered)
            float iconX = (btnRc.left + btnRc.right - fIconSz) * 0.5f;
            float iconY = (btnRc.top + btnRc.bottom - fIconSz) * 0.5f;
            D2D1_RECT_F iconRc = D2D1::RectF(
                iconX, iconY, iconX + fIconSz, iconY + fIconSz);

            // Handle refresh spin
            if (kItems[i].id == IDC_TB_REFRESH && std::abs(m_refreshAngle) > 0.01f) {
                float cx = iconX + fIconSz * 0.5f;
                float cy = iconY + fIconSz * 0.5f;
                D2D1_MATRIX_3X2_F oldXform;
                m_rt->GetTransform(&oldXform);
                m_rt->SetTransform(
                    D2D1::Matrix3x2F::Rotation(m_refreshAngle, D2D1::Point2F(cx, cy))
                    * oldXform
                );

                if (!RenderContext::DrawSvgIcon(m_rt.Get(), iconName,
                                                 iconRc, iconColor, 0.8f)) {
                    auto& bmp = m_iconBitmaps[i];
                    if (bmp) m_rt->DrawBitmap(bmp.Get(), iconRc, 0.8f);
                }
                m_rt->SetTransform(oldXform);
            } else {
                if (!RenderContext::DrawSvgIcon(m_rt.Get(), iconName,
                                                 iconRc, iconColor, 0.8f)) {
                    auto& bmp = m_iconBitmaps[i];
                    if (bmp) m_rt->DrawBitmap(bmp.Get(), iconRc, 0.8f);
                }
            }
        }
    }

    // ── Overflow ⋯ Button ─────────────────────────────────────
    if (m_overflowStart > 0) {
        // Position: right after the last visible left-aligned item
        auto lastRc = ItemRect(m_overflowStart - 1, size.width);
        float overW = Dpi::ScaleF(36.0f, m_dpi);
        float padF  = static_cast<float>(Pad());
        D2D1_RECT_F overRc = D2D1::RectF(
            lastRc.right + padF, padF,
            lastRc.right + padF + overW,
            static_cast<float>(Height()) - padF);

        // Hover highlight
        if (m_hovered == -2) {
            auto hoverColor = ToD2DColor(c.surfaceHover);
            hoverColor.a = 1.0f;
            ComPtr<ID2D1SolidColorBrush> hoverBr;
            m_rt->CreateSolidColorBrush(hoverColor, &hoverBr);
            m_rt->FillRoundedRectangle(
                D2D1::RoundedRect(overRc, 4.0f, 4.0f), hoverBr.Get());
        }

        // Draw ⋯ icon
        float fIconSz = static_cast<float>(iconSz);
        float oIconX = (overRc.left + overRc.right - fIconSz) * 0.5f;
        float oIconY = (overRc.top + overRc.bottom - fIconSz) * 0.5f;
        D2D1_RECT_F oIconRc = D2D1::RectF(
            oIconX, oIconY, oIconX + fIconSz, oIconY + fIconSz);
        RenderContext::DrawSvgIcon(m_rt.Get(), "ellipsis",
            oIconRc, Theme::IconColor(), 0.7f);
    }



    // ── Keyboard Focus Ring ─────────────────────────────────
    if (m_kbFocus && m_focused >= 0 && m_focused < kItemCount) {
        auto focusRc = ItemRect(m_focused, size.width);
        auto focusColor = ToD2DColor(c.accent);
        focusColor.a = 0.8f;
        ComPtr<ID2D1SolidColorBrush> focusBrush;
        m_rt->CreateSolidColorBrush(focusColor, &focusBrush);
        float focusStroke = Dpi::ScaleF(2.0f, m_dpi);
        m_rt->DrawRoundedRectangle(
            D2D1::RoundedRect(focusRc, 4.0f, 4.0f),
            focusBrush.Get(), focusStroke);
    }

    HRESULT hr = m_rt->EndDraw();
    if (hr == D2DERR_RECREATE_TARGET) m_rt.Reset();
}

// ── Window Proc ─────────────────────────────────────────────
LRESULT CALLBACK Toolbar::ToolbarProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    Toolbar* self = nullptr;
    if (msg == WM_NCCREATE) {
        auto cs = reinterpret_cast<CREATESTRUCTW*>(lp);
        self = static_cast<Toolbar*>(cs->lpCreateParams);
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(self));
        self->m_hwnd = hwnd;
    } else {
        self = reinterpret_cast<Toolbar*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
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
            RECT rc;
            GetClientRect(hwnd, &rc);
            self->m_rt->Resize(D2D1::SizeU(rc.right, rc.bottom));


        }
        return 0;

    case WM_LBUTTONDOWN: {
        RECT rc;
        GetClientRect(hwnd, &rc);
        int idx = self->HitTest(GET_X_LPARAM(lp), GET_Y_LPARAM(lp), static_cast<float>(rc.right));
        if (idx >= 0 || idx == -2) {
            self->m_pressed = idx;
            if (idx >= 0) self->m_pressScale[idx] = 0.96f;
            InvalidateRect(hwnd, nullptr, FALSE);
            SetCapture(hwnd);
        }
        return 0;
    }

    case WM_LBUTTONUP: {
        if (self->m_pressed >= 0 || self->m_pressed == -2) {
            int pressedIdx = self->m_pressed;

            // Overflow button: show popup with hidden items
            if (pressedIdx == -2 && self->m_overflowStart >= 0) {
                RECT rc;
                GetClientRect(hwnd, &rc);
                HMENU hMenu = CreatePopupMenu();
                for (int i = self->m_overflowStart; i < kItemCount; i++) {
                    if (kItems[i].rightAlign) continue;
                    if (kItems[i].kind == ItemKind::Separator) {
                        AppendMenuW(hMenu, MF_SEPARATOR, 0, nullptr);
                        continue;
                    }
                    const wchar_t* label = kItems[i].label && kItems[i].label[0]
                        ? kItems[i].label : kItems[i].tooltip;
                    AppendMenuW(hMenu, MF_STRING, kItems[i].id, label);
                }
                auto lastRc = self->ItemRect(self->m_overflowStart - 1,
                    static_cast<float>(rc.right));
                POINT pt = { static_cast<LONG>(lastRc.right + self->Pad()),
                    static_cast<LONG>(static_cast<float>(self->Height())) };
                ClientToScreen(hwnd, &pt);
                WORD choiceId = static_cast<WORD>(TrackPopupMenu(hMenu,
                    TPM_RETURNCMD | TPM_NONOTIFY | TPM_LEFTALIGN | TPM_TOPALIGN,
                    pt.x, pt.y, 0, hwnd, nullptr));
                DestroyMenu(hMenu);
                if (choiceId) {
                    SendMessageW(self->m_parent, WM_COMMAND,
                        MAKEWPARAM(choiceId, 0), reinterpret_cast<LPARAM>(hwnd));
                }
                self->m_pressed = -1;
                ReleaseCapture();
                InvalidateRect(hwnd, nullptr, FALSE);
                return 0;
            }
            // Spring back
            auto& mgr = AnimationManager::Instance();
            mgr.AnimateFor(self, 0.96f, 1.0f, 200.0f, ease::Spring,
                [self, pressedIdx](float v, const Animation&) {
                    self->m_pressScale[pressedIdx] = v;
                    self->Repaint();
                });

            RECT rc;
            GetClientRect(hwnd, &rc);
            int idx = self->HitTest(GET_X_LPARAM(lp), GET_Y_LPARAM(lp), static_cast<float>(rc.right));

            if (idx == pressedIdx) {
                const auto& item = kItems[idx];

                // Dropdown: open custom popup menu
                if (item.kind == ItemKind::Dropdown && item.choices && item.choiceCount > 0) {
                    auto btnRc = self->ItemRect(idx, static_cast<float>(rc.right));
                    POINT pt = { static_cast<LONG>(btnRc.left), static_cast<LONG>(btnRc.bottom) };
                    ClientToScreen(hwnd, &pt);
                    ReleaseCapture();  // must release BEFORE popup — otherwise toolbar eats mouse
                    WORD choiceId = PopupMenu::Show(hwnd, pt,
                        item.choices, item.choiceCount, self->m_dpi);
                    if (choiceId) {
                        SendMessageW(self->m_parent, WM_COMMAND,
                            MAKEWPARAM(choiceId, 0), reinterpret_cast<LPARAM>(hwnd));
                    }
                } else {
                    if (item.id == IDC_TB_REFRESH) {
                        self->AnimateRefreshSpin();
                    }

                    if (item.id == IDC_TB_THEME) {
                        Theme::Toggle();
                        self->m_cachedIconSize = 0;  // force icon rebuild
                        RenderContext::ClearSvgCache();  // clear SVG cache for new colors
                        Theme::ApplyToWindow(self->m_parent);
                        // Repaint everything
                        InvalidateRect(self->m_parent, nullptr, TRUE);
                        SendMessageW(self->m_parent, WM_COMMAND,
                            MAKEWPARAM(item.id, 0), reinterpret_cast<LPARAM>(hwnd));
                    } else {
                        SendMessageW(self->m_parent, WM_COMMAND,
                            MAKEWPARAM(item.id, 0), reinterpret_cast<LPARAM>(hwnd));
                    }
                }
            }

            self->m_pressed = -1;
            ReleaseCapture();
            InvalidateRect(hwnd, nullptr, FALSE);
        }
        return 0;
    }

    case WM_MOUSEMOVE: {
        RECT rc;
        GetClientRect(hwnd, &rc);
        int idx = self->HitTest(GET_X_LPARAM(lp), GET_Y_LPARAM(lp), static_cast<float>(rc.right));
        if (idx != self->m_hovered) {
            int prev = self->m_hovered;
            self->m_hovered = idx;

            if (prev >= 0) self->AnimateHover(prev, false);
            if (idx >= 0)  self->AnimateHover(idx, true);
            // Overflow button lacks animated alpha — just repaint
            if (prev == -2 || idx == -2) self->Repaint();

            // Tooltip management
            self->HideTooltip();
            if (idx >= 0) self->ShowTooltip(idx);

            TRACKMOUSEEVENT tme{};
            tme.cbSize    = sizeof(tme);
            tme.dwFlags   = TME_LEAVE;
            tme.hwndTrack = hwnd;
            TrackMouseEvent(&tme);
        }

        return 0;
    }

    case WM_MOUSELEAVE:
        if (self->m_hovered >= 0) {
            self->AnimateHover(self->m_hovered, false);
            self->m_hovered = -1;
        }
        self->HideTooltip();
        return 0;

    case WM_TIMER:
        if (wp == 0xAA01 && self->m_tooltipIdx >= 0) {
            KillTimer(hwnd, self->m_tooltipTimer);
            self->m_tooltipTimer = 0;
            // Show native tooltip
            // (tooltip rendering handled by future tooltip control)
        }
        return 0;

    case WM_SETFOCUS:
        // Focus first non-separator item
        self->m_focused = -1;
        if (self->m_focused < 0) {
            // Find first non-separator item
            for (int i = 0; i < kItemCount; i++) {
                if (kItems[i].kind != ItemKind::Separator) {
                    self->m_focused = i;
                    break;
                }
            }
        }
        // Only show focus ring if gained via keyboard (Tab)
        // m_kbFocus is set in WM_KEYDOWN for explicit arrow keys
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;

    case WM_KILLFOCUS:
        self->m_kbFocus = false;
        self->m_focused = -1;
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;

    case WM_KEYDOWN:
        switch (wp) {
        case VK_LEFT:
            self->m_kbFocus = true;
            // Skip separators when navigating left
            if (self->m_focused > 0) {
                int next = self->m_focused - 1;
                while (next > 0 && kItems[next].kind == ItemKind::Separator)
                    next--;
                if (kItems[next].kind != ItemKind::Separator)
                    self->m_focused = next;
            }
            InvalidateRect(hwnd, nullptr, FALSE);
            return 0;
        case VK_RIGHT:
            self->m_kbFocus = true;
            // Skip separators when navigating right
            if (self->m_focused < kItemCount - 1) {
                int next = self->m_focused + 1;
                while (next < kItemCount - 1 && kItems[next].kind == ItemKind::Separator)
                    next++;
                if (kItems[next].kind != ItemKind::Separator)
                    self->m_focused = next;
            }
            InvalidateRect(hwnd, nullptr, FALSE);
            return 0;
        case VK_RETURN:
        case VK_SPACE:
            if (self->m_focused >= 0 && self->m_focused < kItemCount &&
                kItems[self->m_focused].kind != ItemKind::Separator) {
                const auto& item = kItems[self->m_focused];

                SendMessageW(self->m_parent, WM_COMMAND,
                    MAKEWPARAM(item.id, 0), reinterpret_cast<LPARAM>(hwnd));
                InvalidateRect(hwnd, nullptr, FALSE);
            }
            return 0;
        case VK_ESCAPE:
        case VK_TAB: {
            LPARAM shift = (wp == VK_TAB && (GetKeyState(VK_SHIFT) & 0x8000)) ? 1 : 0;
            SendMessageW(self->m_parent, WM_RESUI_TAB,
                reinterpret_cast<WPARAM>(hwnd), shift);
            return 0;
        }
        }
        break;

    case WM_GETDLGCODE: {
        LRESULT code = DLGC_WANTARROWS | DLGC_WANTTAB;
        auto* pmsg = reinterpret_cast<MSG*>(lp);
        if (pmsg && (pmsg->message == WM_KEYDOWN || pmsg->message == WM_KEYUP)) {
            if (pmsg->wParam == VK_RETURN || pmsg->wParam == VK_SPACE ||
                pmsg->wParam == VK_ESCAPE)
                code |= DLGC_WANTMESSAGE;
        }
        return code;
    }

    // WM_MEASUREITEM / WM_DRAWITEM no longer needed — custom PopupMenu renders via D2D

    case WM_ERASEBKGND:
        return 1;
    }

    return DefWindowProcW(hwnd, msg, wp, lp);
}

} // namespace rui
