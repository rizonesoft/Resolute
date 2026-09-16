#include <resolute/controls/contentview.h>
#include <resolute/typography.h>
#include <cmath>

namespace rui {

// ── Accessors ───────────────────────────────────────────────
HWND ContentView::Handle() const { return m_hwnd; }
bool ContentView::IsEmpty() const { return m_emptyVisible; }

// ── Create ──────────────────────────────────────────────────
void ContentView::Create(HWND parent, HINSTANCE hInst, int id) {
    m_parent = parent;

    WNDCLASSEXW wc{};
    wc.cbSize        = sizeof(wc);
    wc.style         = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc   = ContentProc;
    wc.hInstance      = hInst;
    wc.hCursor        = LoadCursorW(nullptr, IDC_ARROW);
    wc.lpszClassName  = L"ResoluteContentView";
    RegisterClassExW(&wc);

    m_hwnd = CreateWindowExW(
        WS_EX_TRANSPARENT,  // click-through when nothing visible
        L"ResoluteContentView", nullptr,
        WS_CHILD | WS_VISIBLE,
        0, 0, 400, 400,
        parent, reinterpret_cast<HMENU>(static_cast<INT_PTR>(id)),
        hInst, this
    );

    m_dpi = Dpi::Get(m_hwnd);
    CreateRenderTarget();
}

void ContentView::CreateRenderTarget() {
    m_rt = RenderContext::CreateHwndTarget(m_hwnd);
}

void ContentView::Resize(int x, int y, int w, int h) {
    MoveWindow(m_hwnd, x, y, w, h, TRUE);
    if (m_rt) m_rt->Resize(D2D1::SizeU(w, h));
}

void ContentView::Repaint() { InvalidateRect(m_hwnd, nullptr, FALSE); }

void ContentView::UpdateDpi(int dpi) {
    m_dpi = dpi;
    Repaint();
}

// ── Empty State ─────────────────────────────────────────────
void ContentView::ShowEmpty(const wchar_t* title, const wchar_t* subtitle,
                             const char* iconName) {
    m_emptyTitle    = title ? title : L"No items";
    m_emptySubtitle = subtitle ? subtitle : L"";
    m_emptyIcon     = iconName ? iconName : "inbox";
    m_emptyVisible  = true;

    // Remove click-through so overlay is solid
    SetWindowLongPtrW(m_hwnd, GWL_EXSTYLE,
        GetWindowLongPtrW(m_hwnd, GWL_EXSTYLE) & ~WS_EX_TRANSPARENT);

    auto& mgr = AnimationManager::Instance();
    if (m_emptyAnimId) mgr.Cancel(m_emptyAnimId);

    m_emptyAnimId = mgr.Animate(m_emptyAlpha, 1.0f, 300.0f, ease::OutQuad,
        [this](float v, const Animation&) {
            m_emptyAlpha = v;
            Repaint();
        },
        [this]() { m_emptyAnimId = 0; }
    );
}

void ContentView::HideEmpty() {
    if (!m_emptyVisible) return;

    auto& mgr = AnimationManager::Instance();
    if (m_emptyAnimId) mgr.Cancel(m_emptyAnimId);

    m_emptyAnimId = mgr.Animate(m_emptyAlpha, 0.0f, 200.0f, ease::OutQuad,
        [this](float v, const Animation&) {
            m_emptyAlpha = v;
            Repaint();
        },
        [this]() {
            m_emptyAnimId  = 0;
            m_emptyVisible = false;
            m_emptyAlpha   = 0.0f;
            // Restore click-through
            SetWindowLongPtrW(m_hwnd, GWL_EXSTYLE,
                GetWindowLongPtrW(m_hwnd, GWL_EXSTYLE) | WS_EX_TRANSPARENT);
            Repaint();
        }
    );
}

// ── Error Banner ────────────────────────────────────────────
void ContentView::ShowError(const wchar_t* message, float durationSec) {
    auto& mgr = AnimationManager::Instance();
    if (m_errorAnimId) mgr.Cancel(m_errorAnimId);
    if (m_errorTimer) { KillTimer(m_hwnd, m_errorTimer); m_errorTimer = 0; }

    m_errorText   = message ? message : L"An error occurred";
    m_errorAlpha  = 1.0f;
    m_errorSlideY = -1.0f;

    // Remove click-through
    SetWindowLongPtrW(m_hwnd, GWL_EXSTYLE,
        GetWindowLongPtrW(m_hwnd, GWL_EXSTYLE) & ~WS_EX_TRANSPARENT);

    // Slide down from top
    m_errorAnimId = mgr.Animate(-1.0f, 0.0f, 300.0f, ease::OutCubic,
        [this](float v, const Animation&) {
            m_errorSlideY = v;
            Repaint();
        },
        [this, durationSec]() {
            m_errorAnimId = 0;
            // Auto-dismiss timer
            UINT ms = static_cast<UINT>(durationSec * 1000.0f);
            m_errorTimer = SetTimer(m_hwnd, 0xCC01, ms, nullptr);
        }
    );
}

void ContentView::DismissError() {
    if (m_errorTimer) { KillTimer(m_hwnd, m_errorTimer); m_errorTimer = 0; }

    auto& mgr = AnimationManager::Instance();
    if (m_errorAnimId) mgr.Cancel(m_errorAnimId);

    m_errorAnimId = mgr.Animate(1.0f, 0.0f, 250.0f, ease::OutQuad,
        [this](float v, const Animation&) {
            m_errorAlpha = v;
            Repaint();
        },
        [this]() {
            m_errorAnimId = 0;
            m_errorText.clear();
            m_errorAlpha  = 0.0f;
            m_errorSlideY = -1.0f;
            // Restore click-through if nothing else visible
            if (!m_emptyVisible && m_successAlpha < 0.01f) {
                SetWindowLongPtrW(m_hwnd, GWL_EXSTYLE,
                    GetWindowLongPtrW(m_hwnd, GWL_EXSTYLE) | WS_EX_TRANSPARENT);
            }
        }
    );
}

// ── Success Flash ───────────────────────────────────────────
void ContentView::ShowSuccess(const wchar_t* message, float durationSec) {
    auto& mgr = AnimationManager::Instance();
    if (m_successAnimId) mgr.Cancel(m_successAnimId);

    m_successText  = message ? message : L"Success";
    m_successAlpha = 0.0f;

    // Remove click-through
    SetWindowLongPtrW(m_hwnd, GWL_EXSTYLE,
        GetWindowLongPtrW(m_hwnd, GWL_EXSTYLE) & ~WS_EX_TRANSPARENT);

    // Phase 1: Fade in (150ms)
    m_successAnimId = mgr.Animate(0.0f, 1.0f, 150.0f, ease::OutQuad,
        [this](float v, const Animation&) {
            m_successAlpha = v;
            Repaint();
        },
        [this, durationSec]() {
            m_successAnimId = 0;
            // Hold, then start Phase 2: fade out
            UINT holdMs = static_cast<UINT>((durationSec - 0.45f) * 1000.0f);
            if (holdMs < 100) holdMs = 100;
            SetTimer(m_hwnd, 0xCC02, holdMs, nullptr);
        }
    );
}

// ── Paint ───────────────────────────────────────────────────
void ContentView::OnPaint() {
    if (!m_rt) { CreateRenderTarget(); if (!m_rt) return; }

    auto& c = Theme::Colors();
    auto size = m_rt->GetSize();

    bool hasContent = (m_emptyAlpha > 0.001f) ||
                      (m_errorAlpha > 0.001f) ||
                      (m_successAlpha > 0.001f);

    m_rt->BeginDraw();
    m_rt->Clear(hasContent ? ToD2DColor(c.background) : D2D1::ColorF(0, 0));

    if (!hasContent) {
        m_rt->EndDraw();
        return;
    }

    // ── Empty State (centered icon + text) ──────────────────
    if (m_emptyAlpha > 0.001f) {
        float iconSz = Dpi::ScaleF(48.0f, m_dpi);
        float gap = Dpi::ScaleF(16.0f, m_dpi);
        float titleFontSz = Dpi::ScaleF(18.0f, m_dpi);
        float subFontSz = Dpi::ScaleF(13.0f, m_dpi);

        // Vertical center: icon + gap + title + gap/2 + subtitle
        float blockH = iconSz + gap + titleFontSz + gap * 0.5f + subFontSz;
        float startY = (size.height - blockH) * 0.5f;
        float cx = size.width * 0.5f;

        // Icon
        D2D1_RECT_F iconRc = D2D1::RectF(
            cx - iconSz * 0.5f, startY,
            cx + iconSz * 0.5f, startY + iconSz);

        uint32_t iconColor = Theme::IsDark() ? 0x666666 : 0x999999;
        RenderContext::DrawSvgIcon(m_rt.Get(), m_emptyIcon.c_str(),
                                    iconRc, iconColor, m_emptyAlpha * 0.6f);

        // Title
        auto titleFmt = Typography::Format(TypeStyle::Title, FontWeight::SemiBold, m_dpi);
        if (titleFmt) {
            titleFmt->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
            titleFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_NEAR);
        }

        auto titleColor = ToD2DColor(c.text);
        titleColor.a = m_emptyAlpha * 0.8f;
        ComPtr<ID2D1SolidColorBrush> titleBrush;
        m_rt->CreateSolidColorBrush(titleColor, &titleBrush);

        D2D1_RECT_F titleRc = D2D1::RectF(
            0, startY + iconSz + gap,
            size.width, startY + iconSz + gap + titleFontSz * 1.5f);
        m_rt->DrawText(m_emptyTitle.c_str(),
            static_cast<UINT32>(m_emptyTitle.length()),
            titleFmt.Get(), titleRc, titleBrush.Get());

        // Subtitle
        if (!m_emptySubtitle.empty()) {
            auto subFmt = Typography::Format(TypeStyle::Body, FontWeight::Regular, m_dpi);
            if (subFmt) {
                subFmt->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
                subFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_NEAR);
            }

            auto subColor = ToD2DColor(c.text);
            subColor.a = m_emptyAlpha * 0.45f;
            ComPtr<ID2D1SolidColorBrush> subBrush;
            m_rt->CreateSolidColorBrush(subColor, &subBrush);

            D2D1_RECT_F subRc = D2D1::RectF(
                0, titleRc.bottom + gap * 0.25f,
                size.width, titleRc.bottom + gap * 0.25f + subFontSz * 2.0f);
            m_rt->DrawText(m_emptySubtitle.c_str(),
                static_cast<UINT32>(m_emptySubtitle.length()),
                subFmt.Get(), subRc, subBrush.Get());
        }
    }

    // ── Error Banner ────────────────────────────────────────
    if (m_errorAlpha > 0.001f && !m_errorText.empty()) {
        float bannerH = Dpi::ScaleF(40.0f, m_dpi);
        float padX = Dpi::ScaleF(12.0f, m_dpi);
        float iconSz = Dpi::ScaleF(16.0f, m_dpi);
        float gap = Dpi::ScaleF(8.0f, m_dpi);
        float margin = Dpi::ScaleF(12.0f, m_dpi);
        float radius = Dpi::ScaleF(6.0f, m_dpi);
        float fontSize = Dpi::ScaleF(13.0f, m_dpi);

        // Slide position
        float slideOffset = m_errorSlideY * (bannerH + margin);
        float bannerTop = margin + slideOffset;

        D2D1_RECT_F bannerRc = D2D1::RectF(
            margin, bannerTop,
            size.width - margin, bannerTop + bannerH);

        // Error background
        D2D1_COLOR_F errBg = ToD2DColor(c.error, 0.15f * m_errorAlpha);
        ComPtr<ID2D1SolidColorBrush> errBgBrush;
        m_rt->CreateSolidColorBrush(errBg, &errBgBrush);
        m_rt->FillRoundedRectangle(
            D2D1::RoundedRect(bannerRc, radius, radius), errBgBrush.Get());

        // Error border
        D2D1_COLOR_F errBorder = ToD2DColor(c.error, 0.3f * m_errorAlpha);
        ComPtr<ID2D1SolidColorBrush> errBorderBrush;
        m_rt->CreateSolidColorBrush(errBorder, &errBorderBrush);
        m_rt->DrawRoundedRectangle(
            D2D1::RoundedRect(bannerRc, radius, radius),
            errBorderBrush.Get(), 1.0f);

        // Error icon
        float iconY = bannerTop + (bannerH - iconSz) * 0.5f;
        D2D1_RECT_F iconRc = D2D1::RectF(
            bannerRc.left + padX, iconY,
            bannerRc.left + padX + iconSz, iconY + iconSz);
        uint32_t errIcon = (GetRValue(c.error) << 16) | (GetGValue(c.error) << 8) | GetBValue(c.error);
        RenderContext::DrawSvgIcon(m_rt.Get(), "alert-triangle",
            iconRc, errIcon, m_errorAlpha);

        // Error text
        auto textFmt = Typography::Format(TypeStyle::Body, FontWeight::SemiBold, m_dpi);
        if (textFmt) {
            textFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
            textFmt->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
        }

        D2D1_COLOR_F textColor = D2D1::ColorF(0.827f, 0.184f, 0.184f,
            m_errorAlpha);
        ComPtr<ID2D1SolidColorBrush> textBrush;
        m_rt->CreateSolidColorBrush(textColor, &textBrush);

        D2D1_RECT_F textRc = D2D1::RectF(
            bannerRc.left + padX + iconSz + gap, bannerRc.top,
            bannerRc.right - padX, bannerRc.bottom);
        m_rt->DrawText(m_errorText.c_str(),
            static_cast<UINT32>(m_errorText.length()),
            textFmt.Get(), textRc, textBrush.Get());
    }

    // ── Success Flash ───────────────────────────────────────
    if (m_successAlpha > 0.001f && !m_successText.empty()) {
        float bannerH = Dpi::ScaleF(40.0f, m_dpi);
        float padX = Dpi::ScaleF(12.0f, m_dpi);
        float iconSz = Dpi::ScaleF(16.0f, m_dpi);
        float gap = Dpi::ScaleF(8.0f, m_dpi);
        float margin = Dpi::ScaleF(12.0f, m_dpi);
        float radius = Dpi::ScaleF(6.0f, m_dpi);
        float fontSize = Dpi::ScaleF(13.0f, m_dpi);

        // Position below error banner if visible, otherwise at top
        float topOffset = (m_errorAlpha > 0.001f) ? bannerH + margin * 2 : margin;

        D2D1_RECT_F bannerRc = D2D1::RectF(
            margin, topOffset,
            size.width - margin, topOffset + bannerH);

        // Success background
        D2D1_COLOR_F okBg = ToD2DColor(c.success, 0.15f * m_successAlpha);
        ComPtr<ID2D1SolidColorBrush> okBgBrush;
        m_rt->CreateSolidColorBrush(okBg, &okBgBrush);
        m_rt->FillRoundedRectangle(
            D2D1::RoundedRect(bannerRc, radius, radius), okBgBrush.Get());

        // Success border
        D2D1_COLOR_F okBorder = ToD2DColor(c.success, 0.3f * m_successAlpha);
        ComPtr<ID2D1SolidColorBrush> okBorderBrush;
        m_rt->CreateSolidColorBrush(okBorder, &okBorderBrush);
        m_rt->DrawRoundedRectangle(
            D2D1::RoundedRect(bannerRc, radius, radius),
            okBorderBrush.Get(), 1.0f);

        // Check icon
        float iconY = topOffset + (bannerH - iconSz) * 0.5f;
        D2D1_RECT_F iconRc = D2D1::RectF(
            bannerRc.left + padX, iconY,
            bannerRc.left + padX + iconSz, iconY + iconSz);
        uint32_t okIcon = (GetRValue(c.success) << 16) | (GetGValue(c.success) << 8) | GetBValue(c.success);
        RenderContext::DrawSvgIcon(m_rt.Get(), "check-circle",
            iconRc, okIcon, m_successAlpha);

        // Success text
        auto textFmt = Typography::Format(TypeStyle::Body, FontWeight::SemiBold, m_dpi);
        if (textFmt) {
            textFmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
            textFmt->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
        }

        D2D1_COLOR_F textColor = D2D1::ColorF(0.22f, 0.557f, 0.235f,
            m_successAlpha);
        ComPtr<ID2D1SolidColorBrush> textBrush;
        m_rt->CreateSolidColorBrush(textColor, &textBrush);

        D2D1_RECT_F textRc = D2D1::RectF(
            bannerRc.left + padX + iconSz + gap, bannerRc.top,
            bannerRc.right - padX, bannerRc.bottom);
        m_rt->DrawText(m_successText.c_str(),
            static_cast<UINT32>(m_successText.length()),
            textFmt.Get(), textRc, textBrush.Get());
    }

    HRESULT hr = m_rt->EndDraw();
    if (hr == D2DERR_RECREATE_TARGET) m_rt.Reset();
}

// ── Window Proc ─────────────────────────────────────────────
LRESULT CALLBACK ContentView::ContentProc(HWND hwnd, UINT msg,
                                           WPARAM wp, LPARAM lp) {
    ContentView* self = nullptr;
    if (msg == WM_NCCREATE) {
        auto cs = reinterpret_cast<CREATESTRUCTW*>(lp);
        self = static_cast<ContentView*>(cs->lpCreateParams);
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(self));
        self->m_hwnd = hwnd;
    } else {
        self = reinterpret_cast<ContentView*>(
            GetWindowLongPtrW(hwnd, GWLP_USERDATA));
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

    case WM_LBUTTONDOWN:
        // Click to dismiss error banner
        if (self->m_errorAlpha > 0.5f) {
            self->DismissError();
            return 0;
        }
        break;

    case WM_TIMER:
        if (wp == 0xCC01) {
            // Error auto-dismiss
            KillTimer(hwnd, 0xCC01);
            self->m_errorTimer = 0;
            self->DismissError();
        }
        if (wp == 0xCC02) {
            // Success fade-out
            KillTimer(hwnd, 0xCC02);
            auto& mgr = AnimationManager::Instance();
            if (self->m_successAnimId) mgr.Cancel(self->m_successAnimId);

            self->m_successAnimId = mgr.Animate(
                self->m_successAlpha, 0.0f, 300.0f, ease::OutQuad,
                [self](float v, const Animation&) {
                    self->m_successAlpha = v;
                    self->Repaint();
                },
                [self]() {
                    self->m_successAnimId = 0;
                    self->m_successText.clear();
                    self->m_successAlpha = 0.0f;
                    // Restore click-through if nothing visible
                    if (!self->m_emptyVisible && self->m_errorAlpha < 0.01f) {
                        SetWindowLongPtrW(self->m_hwnd, GWL_EXSTYLE,
                            GetWindowLongPtrW(self->m_hwnd, GWL_EXSTYLE) |
                            WS_EX_TRANSPARENT);
                    }
                }
            );
        }
        return 0;

    case WM_ERASEBKGND:
        return 1;
    }

    return DefWindowProcW(hwnd, msg, wp, lp);
}

} // namespace rui
