#include <resolute/controls/statusbar.h>
#include <resolute/typography.h>
#include <windowsx.h>
#include <cmath>
#include <algorithm>

namespace rui {

StatusBar::~StatusBar() { AnimationManager::Instance().CancelOwner(this); }

// ── Accessors ───────────────────────────────────────────────
int  StatusBar::ScaledHeight() const { return Dpi::Scale(BASE_HEIGHT, m_dpi); }
HWND StatusBar::Handle() const { return m_hwnd; }

// ── Create ──────────────────────────────────────────────────
void StatusBar::Create(HWND parent, HINSTANCE hInst, int id) {
    m_parent = parent;

    // Initialize default segment text
    m_segments[0].text = L"Ready";
    m_segments[0].fadeIn = 1.0f;
    m_segments[1].fadeIn = 1.0f;
    m_segments[2].fadeIn = 1.0f;

    // Default command IDs
    m_segments[0].cmdId = IDC_SB_LEFT;
    m_segments[1].cmdId = IDC_SB_CENTER;
    m_segments[2].cmdId = IDC_SB_RIGHT;

    WNDCLASSEXW wc{};
    wc.cbSize        = sizeof(wc);
    wc.style         = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc   = StatusProc;
    wc.hInstance     = hInst;
    wc.hCursor       = LoadCursorW(nullptr, IDC_ARROW);
    wc.lpszClassName = L"ResoluteStatusBar";
    RegisterClassExW(&wc);

    m_hwnd = CreateWindowExW(
        0, L"ResoluteStatusBar", nullptr,
        WS_CHILD | WS_VISIBLE,
        0, 0, 800, BASE_HEIGHT,
        parent, reinterpret_cast<HMENU>(static_cast<INT_PTR>(id)),
        hInst, this
    );

    m_dpi = Dpi::Get(m_hwnd);
    CreateRenderTarget();
}

void StatusBar::CreateRenderTarget() {
    m_hwndRt = RenderContext::CreateHwndTarget(m_hwnd);
    m_rt     = m_hwndRt;
}

void StatusBar::Resize(int x, int y, int w, int h) {
    MoveWindow(m_hwnd, x, y, w, h, TRUE);
    if (m_hwndRt) m_hwndRt->Resize(D2D1::SizeU(w, h));
}

void StatusBar::Repaint() { InvalidateRect(m_hwnd, nullptr, FALSE); }

void StatusBar::UpdateDpi(int dpi) {
    m_dpi = dpi;
    Repaint();
}

// ── Segment Rectangles ──────────────────────────────────────
D2D1_RECT_F StatusBar::SegmentRect(Segment seg, float totalW, float totalH) const {

    // Notification icon area width (right side)
    float iconSlotW = Dpi::ScaleF(static_cast<float>(BASE_ICON_SIZE + 6), m_dpi);
    float notifyAreaW = m_notifyIcons.empty() ? 0.0f
        : static_cast<float>(m_notifyIcons.size()) * iconSlotW + Dpi::ScaleF(8.0f, m_dpi);

    // Zone widths: left 40%, center 20%, right 40% (-notifyIcons)
    float leftW   = totalW * 0.40f;
    float centerW = totalW * 0.20f;
    float rightW  = totalW * 0.40f - notifyAreaW;

    float y0 = 1.0f;  // below top border (progress bar overlays, doesn't shift)
    float y1 = totalH;

    switch (seg) {
    case Segment::Left:
        return D2D1::RectF(0, y0, leftW, y1);
    case Segment::Center:
        return D2D1::RectF(leftW, y0, leftW + centerW, y1);
    case Segment::Right:
        return D2D1::RectF(leftW + centerW, y0, leftW + centerW + rightW, y1);
    default:
        return D2D1::RectF(0, 0, 0, 0);
    }
}

int StatusBar::HitTestSegment(int mx, int my) const {
    RECT rc;
    GetClientRect(m_hwnd, &rc);
    float w = static_cast<float>(rc.right);
    float h = static_cast<float>(rc.bottom);

    for (int i = 0; i < 3; i++) {
        auto r = SegmentRect(static_cast<Segment>(i), w, h);
        if (mx >= r.left && mx <= r.right && my >= r.top && my <= r.bottom)
            return i;
    }
    return -1;
}

// ── Segment Text ────────────────────────────────────────────
void StatusBar::SetText(const wchar_t* text) { SetLeftText(text); }

void StatusBar::SetLeftText(const wchar_t* text) {
    std::wstring newText = text ? text : L"";
    if (newText == m_segments[0].text) return;
    m_segments[0].oldText  = m_segments[0].text;
    m_segments[0].text     = newText;
    AnimateSegmentText(0);
}

void StatusBar::SetCenterText(const wchar_t* text) {
    std::wstring newText = text ? text : L"";
    if (newText == m_segments[1].text) return;
    m_segments[1].oldText  = m_segments[1].text;
    m_segments[1].text     = newText;
    AnimateSegmentText(1);
}

void StatusBar::SetRightText(const wchar_t* text) {
    std::wstring newText = text ? text : L"";
    if (newText == m_segments[2].text) return;
    m_segments[2].oldText  = m_segments[2].text;
    m_segments[2].text     = newText;
    AnimateSegmentText(2);
}

void StatusBar::SetSegmentCommand(Segment seg, int cmdId) {
    int idx = static_cast<int>(seg);
    if (idx >= 0 && idx < 3)
        m_segments[idx].cmdId = cmdId;
}

void StatusBar::AnimateSegmentText(int idx) {
    auto& s = m_segments[idx];
    auto& mgr = AnimationManager::Instance();
    if (s.fadeAnim) mgr.Cancel(s.fadeAnim);

    s.fadeOut = 1.0f;
    s.fadeIn  = 0.0f;

    s.fadeAnim = mgr.AnimateFor(this, 0.0f, 1.0f, 200.0f, ease::OutQuad,
        [this, idx](float t, const Animation&) {
            m_segments[idx].fadeOut = 1.0f - t;
            m_segments[idx].fadeIn  = t;
            Repaint();
        },
        [this, idx]() {
            m_segments[idx].fadeAnim = 0;
            m_segments[idx].oldText.clear();
            m_segments[idx].fadeIn  = 1.0f;
            m_segments[idx].fadeOut = 0.0f;
        }
    );
}

void StatusBar::AnimateSegmentHover(int idx, bool entering) {
    auto& s = m_segments[idx];
    auto& mgr = AnimationManager::Instance();
    if (s.hoverAnim) mgr.Cancel(s.hoverAnim);

    float from = s.hoverAlpha;
    float to   = entering ? 1.0f : 0.0f;
    s.hoverAnim = mgr.AnimateFor(this, from, to, entering ? 120.0f : 200.0f,
        entering ? ease::OutQuart : ease::InQuad,
        [this, idx](float v, const Animation&) {
            m_segments[idx].hoverAlpha = v;
            Repaint();
        },
        [this, idx]() {
            m_segments[idx].hoverAnim = 0;
        }
    );
}

// ── Progress Bar ────────────────────────────────────────────
void StatusBar::SetProgress(float value) {
    auto& mgr = AnimationManager::Instance();

    if (value < 0.0f) {
        // Indeterminate mode
        m_progressVisible = true;
        m_progressValue   = -1.0f;
        if (!m_progressAnimId)
            StartIndeterminateLoop();
    } else if (value >= 0.0f && value <= 1.0f) {
        // Determinate mode
        m_progressVisible = true;
        m_progressValue   = value;
        if (m_progressAnimId) {
            mgr.Cancel(m_progressAnimId);
            m_progressAnimId = 0;
        }
    }
    Repaint();
}

void StatusBar::HideProgress() {
    auto& mgr = AnimationManager::Instance();
    if (m_progressAnimId) {
        mgr.Cancel(m_progressAnimId);
        m_progressAnimId = 0;
    }
    m_progressVisible = false;
    m_progressValue   = 0.0f;
    m_progressPhase   = 0.0f;
    Repaint();
}

void StatusBar::StartProgress() { SetProgress(-1.0f); }
void StatusBar::StopProgress()  { HideProgress(); }

void StatusBar::StartIndeterminateLoop() {
    struct LoopHelper {
        static void Start(StatusBar* sb) {
            sb->m_progressAnimId = AnimationManager::Instance().AnimateFor(sb, 
                0.0f, 1.0f, 1200.0f, ease::InOutCubic,
                [sb](float v, const Animation&) {
                    sb->m_progressPhase = v;
                    sb->Repaint();
                },
                [sb]() {
                    sb->m_progressAnimId = 0;
                    if (sb->m_progressVisible && sb->m_progressValue < 0.0f)
                        LoopHelper::Start(sb);
                }
            );
        }
    };
    LoopHelper::Start(this);
}

// ── Notification Icons ──────────────────────────────────────
void StatusBar::AddNotifyIcon(int id, NotifyIconKind kind) {
    // Remove existing with same id
    RemoveNotifyIcon(id);

    NotifyIcon ni;
    ni.id   = id;
    ni.kind = kind;
    ni.alpha = 1.0f;

    if (kind == NotifyIconKind::Spinner) {
        // Continuous rotation
        struct SpinLoop {
            static void Start(StatusBar* sb, int iconId) {
                // Find the icon by id
                for (auto& icon : sb->m_notifyIcons) {
                    if (icon.id == iconId) {
                        icon.spinAnim = AnimationManager::Instance().AnimateFor(sb, 
                            0.0f, 360.0f, 1000.0f, ease::Linear,
                            [sb, iconId](float v, const Animation&) {
                                for (auto& ic : sb->m_notifyIcons) {
                                    if (ic.id == iconId) {
                                        ic.angle = v;
                                        break;
                                    }
                                }
                                sb->Repaint();
                            },
                            [sb, iconId]() {
                                for (auto& ic : sb->m_notifyIcons) {
                                    if (ic.id == iconId) {
                                        ic.spinAnim = 0;
                                        if (ic.kind == NotifyIconKind::Spinner)
                                            SpinLoop::Start(sb, iconId);
                                        break;
                                    }
                                }
                            }
                        );
                        break;
                    }
                }
            }
        };
        m_notifyIcons.push_back(ni);
        SpinLoop::Start(this, id);
    } else if (kind == NotifyIconKind::Success) {
        m_notifyIcons.push_back(ni);
        // Auto-dismiss after 3s
        auto timer = SetTimer(m_hwnd, static_cast<UINT_PTR>(0xCC00 + id), 3000, nullptr);
        m_notifyIcons.back().timer = timer;
    } else {
        m_notifyIcons.push_back(ni);
    }

    Repaint();
}

void StatusBar::RemoveNotifyIcon(int id) {
    auto& mgr = AnimationManager::Instance();
    for (auto it = m_notifyIcons.begin(); it != m_notifyIcons.end(); ++it) {
        if (it->id == id) {
            if (it->spinAnim) mgr.Cancel(it->spinAnim);
            if (it->fadeAnim) mgr.Cancel(it->fadeAnim);
            if (it->timer) KillTimer(m_hwnd, it->timer);
            m_notifyIcons.erase(it);
            Repaint();
            return;
        }
    }
}

void StatusBar::ClearNotifyIcons() {
    auto& mgr = AnimationManager::Instance();
    for (auto& ni : m_notifyIcons) {
        if (ni.spinAnim) mgr.Cancel(ni.spinAnim);
        if (ni.fadeAnim) mgr.Cancel(ni.fadeAnim);
        if (ni.timer) KillTimer(m_hwnd, ni.timer);
    }
    m_notifyIcons.clear();
    Repaint();
}

// ── Notification Toast ──────────────────────────────────────
void StatusBar::ShowNotification(const wchar_t* text, COLORREF color, float durationSec) {
    auto& mgr = AnimationManager::Instance();

    if (m_notifySlideId) mgr.Cancel(m_notifySlideId);
    if (m_notifyFadeId)  mgr.Cancel(m_notifyFadeId);
    if (m_notifyTimer)   { KillTimer(m_hwnd, m_notifyTimer); m_notifyTimer = 0; }

    m_notifyText   = text ? text : L"";
    m_notifyColor  = color ? color : Theme::Colors().accent;
    m_notifyOffset = 200.0f;
    m_notifyAlpha  = 1.0f;

    m_notifySlideId = mgr.AnimateFor(this, 200.0f, 0.0f, 250.0f, ease::OutCubic,
        [this](float v, const Animation&) {
            m_notifyOffset = v;
            Repaint();
        },
        [this, durationSec]() {
            m_notifySlideId = 0;
            UINT ms = static_cast<UINT>(durationSec * 1000.0f);
            m_notifyTimer = SetTimer(m_hwnd, 0xBB01, ms, nullptr);
        }
    );
}

// ── Paint ───────────────────────────────────────────────────
void StatusBar::OnPaint() {
    if (!m_rt) { CreateRenderTarget(); if (!m_rt) return; }

    auto& c = Theme::Colors();
    float padX = Dpi::ScaleF(static_cast<float>(BASE_PADDING_X), m_dpi);

    m_rt->BeginDraw();
    m_rt->Clear(ToD2DColor(c.statusBar));

    auto size = m_rt->GetSize();

    // ── Top Border ──────────────────────────────────────────
    ComPtr<ID2D1SolidColorBrush> borderBrush;
    m_rt->CreateSolidColorBrush(ToD2DColor(c.border), &borderBrush);
    m_rt->DrawLine(
        D2D1::Point2F(0, 0.5f),
        D2D1::Point2F(size.width, 0.5f),
        borderBrush.Get(), 1.0f
    );

    // ── Progress Bar (thin accent line at top) ──────────────
    if (m_progressVisible) {
        auto accentColor = ToD2DColor(c.accent);
        ComPtr<ID2D1SolidColorBrush> progressBrush;
        m_rt->CreateSolidColorBrush(accentColor, &progressBrush);

        if (m_progressValue >= 0.0f) {
            // Determinate: fill from left to progressValue
            float fillW = size.width * m_progressValue;
            m_rt->FillRectangle(
                D2D1::RectF(0, 0, fillW, Dpi::ScaleF(static_cast<float>(PROGRESS_HEIGHT), m_dpi)),
                progressBrush.Get()
            );
        } else {
            // Indeterminate: sweeping pulse
            float sweepW = size.width * 0.30f;
            float sweepX = -sweepW + (size.width + sweepW) * m_progressPhase;

            // Leading/trailing fade using multiple segments
            int segments = 6;
            float segW = sweepW / static_cast<float>(segments);
            for (int i = 0; i < segments; i++) {
                float frac = static_cast<float>(i) / static_cast<float>(segments - 1);
                // bell-curve alpha: peak at center
                float alpha = 1.0f - std::abs(frac - 0.5f) * 2.0f;
                alpha = std::max(0.05f, alpha);

                float sx = sweepX - sweepW * 0.5f + static_cast<float>(i) * segW;
                float ex = sx + segW;
                sx = std::max(0.0f, sx);
                ex = std::min(size.width, ex);
                if (sx >= ex) continue;

                D2D1_COLOR_F segColor = accentColor;
                segColor.a = alpha;
                ComPtr<ID2D1SolidColorBrush> segBrush;
                m_rt->CreateSolidColorBrush(segColor, &segBrush);
                m_rt->FillRectangle(
                    D2D1::RectF(sx, 0, ex, Dpi::ScaleF(static_cast<float>(PROGRESS_HEIGHT), m_dpi)),
                    segBrush.Get()
                );
            }
        }
    }

    // ── Text Formats ────────────────────────────────────────
    auto textFmt = Typography::Format(TypeStyle::Caption, FontWeight::Regular, m_dpi);
    auto boldFmt = Typography::Format(TypeStyle::Caption, FontWeight::SemiBold, m_dpi);

    // ── Draw Segments ───────────────────────────────────────
    for (int i = 0; i < 3; i++) {
        auto& seg = m_segments[i];
        auto segRc = SegmentRect(static_cast<Segment>(i), size.width, size.height);

        // Hover highlight
        if (seg.hoverAlpha > 0.001f && seg.cmdId != 0) {
            auto hoverColor = ToD2DColor(c.surfaceHover);
            hoverColor.a = seg.hoverAlpha * 0.5f;
            ComPtr<ID2D1SolidColorBrush> hoverBrush;
            m_rt->CreateSolidColorBrush(hoverColor, &hoverBrush);
            m_rt->FillRectangle(segRc, hoverBrush.Get());
        }

        // Segment separator (thin vertical line between segments)
        if (i > 0) {
            auto sepColor = ToD2DColor(c.border);
            sepColor.a = 0.25f;
            ComPtr<ID2D1SolidColorBrush> sepBrush;
            m_rt->CreateSolidColorBrush(sepColor, &sepBrush);
            float sepInset = Dpi::ScaleF(4.0f, m_dpi);
            m_rt->DrawLine(
                D2D1::Point2F(segRc.left, segRc.top + sepInset),
                D2D1::Point2F(segRc.left, segRc.bottom - sepInset),
                sepBrush.Get(), 1.0f
            );
        }

        // Text alignment per segment
        DWRITE_TEXT_ALIGNMENT align = DWRITE_TEXT_ALIGNMENT_LEADING;
        if (i == 1) align = DWRITE_TEXT_ALIGNMENT_CENTER;
        if (i == 2) align = DWRITE_TEXT_ALIGNMENT_TRAILING;

        auto fmt = (i == 1) ? boldFmt : textFmt;  // center segment is bold
        if (fmt) {
            fmt->SetTextAlignment(align);
            fmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
            fmt->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
        }

        D2D1_RECT_F textRc = D2D1::RectF(
            segRc.left + padX, segRc.top,
            segRc.right - padX, segRc.bottom
        );

        // Old text (fading out)
        if (seg.fadeOut > 0.001f && !seg.oldText.empty()) {
            auto oldColor = ToD2DColor(c.statusBarText);
            oldColor.a = seg.fadeOut;
            ComPtr<ID2D1SolidColorBrush> oldBrush;
            m_rt->CreateSolidColorBrush(oldColor, &oldBrush);
            if (fmt) {
                m_rt->DrawText(seg.oldText.c_str(),
                    static_cast<UINT32>(seg.oldText.length()),
                    fmt.Get(), textRc, oldBrush.Get());
            }
        }

        // Current text (fading in)
        if (!seg.text.empty()) {
            auto textColor = ToD2DColor(c.statusBarText);
            textColor.a = seg.fadeIn;
            ComPtr<ID2D1SolidColorBrush> textBrush;
            m_rt->CreateSolidColorBrush(textColor, &textBrush);
            if (fmt) {
                m_rt->DrawText(seg.text.c_str(),
                    static_cast<UINT32>(seg.text.length()),
                    fmt.Get(), textRc, textBrush.Get());
            }
        }
    }

    // ── Notification Icons (far right) ──────────────────────
    if (!m_notifyIcons.empty()) {
        float iconSz = Dpi::ScaleF(static_cast<float>(BASE_ICON_SIZE), m_dpi);
        float slotW  = Dpi::ScaleF(static_cast<float>(BASE_ICON_SIZE + 6), m_dpi);
        float rightEdge = size.width - Dpi::ScaleF(8.0f, m_dpi);
        float contentTop = 1.0f;  // below top border
        float iconY = contentTop + (size.height - contentTop - iconSz) * 0.5f;

        for (int n = static_cast<int>(m_notifyIcons.size()) - 1; n >= 0; n--) {
            auto& ni = m_notifyIcons[n];
            float iconX = rightEdge - slotW;

            D2D1_RECT_F iconRc = D2D1::RectF(
                iconX, iconY, iconX + iconSz, iconY + iconSz
            );

            const char* iconName = "circle";
            uint32_t iconColor = Theme::IconColor();
            switch (ni.kind) {
            case NotifyIconKind::Spinner:
                iconName = "loader-2";
                iconColor = Theme::AccentIconColor();
                break;
            case NotifyIconKind::Success:
                iconName = "check";
                iconColor = (GetRValue(c.success) << 16) | (GetGValue(c.success) << 8) | GetBValue(c.success);
                break;
            case NotifyIconKind::Warning:
                iconName = "alert-triangle";
                iconColor = (GetRValue(c.warning) << 16) | (GetGValue(c.warning) << 8) | GetBValue(c.warning);
                break;
            }

            // Apply rotation for spinner
            if (ni.kind == NotifyIconKind::Spinner && std::abs(ni.angle) > 0.01f) {
                float cx = iconX + iconSz * 0.5f;
                float cy = iconY + iconSz * 0.5f;
                D2D1_MATRIX_3X2_F oldXform;
                m_rt->GetTransform(&oldXform);
                m_rt->SetTransform(
                    D2D1::Matrix3x2F::Rotation(ni.angle, D2D1::Point2F(cx, cy))
                    * oldXform
                );
                RenderContext::DrawSvgIcon(m_rt.Get(), iconName, iconRc, iconColor, ni.alpha);
                m_rt->SetTransform(oldXform);
            } else {
                RenderContext::DrawSvgIcon(m_rt.Get(), iconName, iconRc, iconColor, ni.alpha);
            }

            rightEdge -= slotW;
        }
    }

    // ── Notification Toast (slide from right) ───────────────
    if (m_notifyAlpha > 0.001f && !m_notifyText.empty()) {
        auto fontSize = Dpi::ScaleF(static_cast<float>(BASE_FONT_SIZE), m_dpi);
        float toastX = size.width * 0.6f + m_notifyOffset;
        float notifyPadX = Dpi::ScaleF(8.0f, m_dpi);
        float notifyPadY = Dpi::ScaleF(3.0f, m_dpi);

        float notifyWidth = static_cast<float>(m_notifyText.length()) *
                            fontSize * 0.55f + notifyPadX * 2.0f;

        D2D1_RECT_F pillRc = D2D1::RectF(
            toastX, notifyPadY,
            toastX + notifyWidth, size.height - notifyPadY
        );

        auto notifyBgColor = ToD2DColor(m_notifyColor);
        notifyBgColor.a = 0.15f * m_notifyAlpha;
        ComPtr<ID2D1SolidColorBrush> notifyBgBrush;
        m_rt->CreateSolidColorBrush(notifyBgColor, &notifyBgBrush);
        m_rt->FillRoundedRectangle(
            D2D1::RoundedRect(pillRc, 3.0f, 3.0f), notifyBgBrush.Get());

        auto notifyTextColor = ToD2DColor(m_notifyColor);
        notifyTextColor.a = m_notifyAlpha;
        ComPtr<ID2D1SolidColorBrush> notifyTextBrush;
        m_rt->CreateSolidColorBrush(notifyTextColor, &notifyTextBrush);

        D2D1_RECT_F notifyTextRc = D2D1::RectF(
            pillRc.left + notifyPadX, pillRc.top,
            pillRc.right - notifyPadX, pillRc.bottom
        );
        auto notifyFmt = Typography::Format(TypeStyle::Caption, FontWeight::SemiBold, m_dpi);
        if (notifyFmt) {
            m_rt->DrawText(m_notifyText.c_str(),
                static_cast<UINT32>(m_notifyText.length()),
                notifyFmt.Get(), notifyTextRc, notifyTextBrush.Get());
        }
    }

    HRESULT hr = m_rt->EndDraw();
    m_paintHr = hr;
    // Only the window's own target is recreated here: an offscreen target
    // RenderTo lent is the caller's, and the window target stays intact
    // (panel round 4 of the D00 T02 §9 review).
    if (hr == D2DERR_RECREATE_TARGET && m_rt.Get() == static_cast<ID2D1RenderTarget*>(m_hwndRt.Get())) {
        m_rt.Reset();
        m_hwndRt.Reset();
    }
}

// ── Window Proc ─────────────────────────────────────────────
LRESULT CALLBACK StatusBar::StatusProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    StatusBar* self = nullptr;
    if (msg == WM_NCCREATE) {
        auto cs = reinterpret_cast<CREATESTRUCTW*>(lp);
        self = static_cast<StatusBar*>(cs->lpCreateParams);
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(self));
        self->m_hwnd = hwnd;
    } else {
        self = reinterpret_cast<StatusBar*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
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
        if (self->m_hwndRt) {
            RECT rc;
            GetClientRect(hwnd, &rc);
            self->m_hwndRt->Resize(D2D1::SizeU(rc.right, rc.bottom));
        }
        return 0;

    case WM_MOUSEMOVE: {
        int seg = self->HitTestSegment(GET_X_LPARAM(lp), GET_Y_LPARAM(lp));

        // Change cursor based on segment clickability
        if (seg >= 0 && self->m_segments[seg].cmdId != 0) {
            SetCursor(LoadCursorW(nullptr, IDC_HAND));
        } else {
            SetCursor(LoadCursorW(nullptr, IDC_ARROW));
        }

        if (seg != self->m_hoveredSeg) {
            int prev = self->m_hoveredSeg;
            self->m_hoveredSeg = seg;

            if (prev >= 0) self->AnimateSegmentHover(prev, false);
            if (seg >= 0 && self->m_segments[seg].cmdId != 0)
                self->AnimateSegmentHover(seg, true);

            TRACKMOUSEEVENT tme{};
            tme.cbSize    = sizeof(tme);
            tme.dwFlags   = TME_LEAVE;
            tme.hwndTrack = hwnd;
            TrackMouseEvent(&tme);
        }
        return 0;
    }

    case WM_MOUSELEAVE:
        if (self->m_hoveredSeg >= 0) {
            self->AnimateSegmentHover(self->m_hoveredSeg, false);
            self->m_hoveredSeg = -1;
        }
        SetCursor(LoadCursorW(nullptr, IDC_ARROW));
        return 0;

    case WM_LBUTTONDOWN: {
        int seg = self->HitTestSegment(GET_X_LPARAM(lp), GET_Y_LPARAM(lp));
        if (seg >= 0 && self->m_segments[seg].cmdId != 0) {
            self->m_pressedSeg = seg;
            SetCapture(hwnd);
        }
        return 0;
    }

    case WM_LBUTTONUP: {
        if (self->m_pressedSeg >= 0) {
            int seg = self->HitTestSegment(GET_X_LPARAM(lp), GET_Y_LPARAM(lp));
            if (seg == self->m_pressedSeg) {
                int cmdId = self->m_segments[seg].cmdId;
                if (cmdId != 0) {
                    SendMessageW(self->m_parent, WM_COMMAND,
                        MAKEWPARAM(cmdId, 0),
                        reinterpret_cast<LPARAM>(hwnd));
                }
            }
            self->m_pressedSeg = -1;
            ReleaseCapture();
        }
        return 0;
    }

    case WM_SETCURSOR:
        // Prevent default cursor reset — we manage it in WM_MOUSEMOVE
        if (LOWORD(lp) == HTCLIENT)
            return TRUE;
        break;

    case WM_TIMER: {
        // Notification toast auto-dismiss
        if (wp == 0xBB01) {
            KillTimer(hwnd, self->m_notifyTimer);
            self->m_notifyTimer = 0;

            auto& mgr = AnimationManager::Instance();
            if (self->m_notifyFadeId) mgr.Cancel(self->m_notifyFadeId);

            self->m_notifyFadeId = mgr.AnimateFor(self, 1.0f, 0.0f, 300.0f, ease::OutQuad,
                [self](float v, const Animation&) {
                    self->m_notifyAlpha = v;
                    self->Repaint();
                },
                [self]() {
                    self->m_notifyFadeId = 0;
                    self->m_notifyText.clear();
                    self->m_notifyAlpha = 0.0f;
                }
            );
            return 0;
        }

        // Notification icon auto-dismiss (Success kind)
        UINT_PTR timerId = wp;
        for (auto it = self->m_notifyIcons.begin(); it != self->m_notifyIcons.end(); ++it) {
            if (it->timer == timerId) {
                KillTimer(hwnd, timerId);
                it->timer = 0;
                int iconId = it->id;

                // Fade out then remove
                auto& mgr = AnimationManager::Instance();
                it->fadeAnim = mgr.AnimateFor(self, 1.0f, 0.0f, 300.0f, ease::OutQuad,
                    [self, iconId](float v, const Animation&) {
                        for (auto& ni : self->m_notifyIcons) {
                            if (ni.id == iconId) {
                                ni.alpha = v;
                                break;
                            }
                        }
                        self->Repaint();
                    },
                    [self, iconId]() {
                        self->RemoveNotifyIcon(iconId);
                    }
                );
                return 0;
            }
        }
        return 0;
    }

    case WM_ERASEBKGND:
        return 1;
    }

    return DefWindowProcW(hwnd, msg, wp, lp);
}

// ── Offscreen rendering (D00 T02 §9) ────────────────────────
void StatusBar::ReleaseDeviceResources() {
}

bool StatusBar::RenderTo(ID2D1RenderTarget* target) {
    if (!target) return false;
    // Device-bound resources belong to one target: release them, and the
    // shared SVG documents, on the way in and on the way out.
    ReleaseDeviceResources();
    RenderContext::ClearSvgCache();
    ComPtr<ID2D1RenderTarget> saved = m_rt;
    m_rt = target;
    // A paint that returns before EndDraw leaves this unset, and fails.
    m_paintHr = E_PENDING;
    OnPaint();
    const bool drew = SUCCEEDED(m_paintHr);
    m_rt = m_hwndRt ? ComPtr<ID2D1RenderTarget>(m_hwndRt) : saved;
    ReleaseDeviceResources();
    RenderContext::ClearSvgCache();
    return drew;
}

} // namespace rui
