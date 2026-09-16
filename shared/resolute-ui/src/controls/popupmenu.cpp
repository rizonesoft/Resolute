// ── ResoluteUI Custom Popup Menu (Pure GDI) ──────────────────────
// No D2D. Uses plain Win32 GDI for 100% reliable rendering.
// Icons via LucideIcons::CreateBitmap + AlphaBlend.

#include <resolute/controls/popupmenu.h>
#include <resolute/controls/toolbar.h>
#include <resolute/theme.h>
#include <resolute/dpi.h>
#include <resolute/icons.h>
#include <windowsx.h>
#include <algorithm>

namespace rui {

bool PopupMenu::s_classRegistered = false;

// ── Layout (base pixels, scaled by DPI) ─────────────────────
static constexpr int kPadH    = 12;
static constexpr int kItemH   = 30;
static constexpr int kIconSz  = 16;
static constexpr int kGap     = 10;
static constexpr int kMenuPad = 4;

// ── Helpers ─────────────────────────────────────────────────
static int ItemAtY(int y, int count, int dpi) {
    int pad   = Dpi::Scale(kMenuPad, dpi);
    int itemH = Dpi::Scale(kItemH, dpi);
    int fy    = y - pad;
    if (fy < 0) return -1;
    int idx = fy / itemH;
    return (idx >= 0 && idx < count) ? idx : -1;
}

static RECT ItemRect(int idx, int totalW, int dpi) {
    int pad   = Dpi::Scale(kMenuPad, dpi);
    int itemH = Dpi::Scale(kItemH, dpi);
    int y     = pad + idx * itemH;
    return { 0, y, totalW, y + itemH };
}

static SIZE MeasureMenu(const DropdownChoice* ch, int count, int dpi, HFONT font) {
    // Measure text widths with the actual font
    int maxW = 0;
    HDC hdc = GetDC(nullptr);
    HFONT old = static_cast<HFONT>(SelectObject(hdc, font));
    for (int i = 0; i < count; i++) {
        SIZE sz{};
        int len = static_cast<int>(wcslen(ch[i].label));
        GetTextExtentPoint32W(hdc, ch[i].label, len, &sz);
        if (sz.cx > maxW) maxW = sz.cx;
    }
    SelectObject(hdc, old);
    ReleaseDC(nullptr, hdc);

    int padH  = Dpi::Scale(kPadH, dpi);
    int icon  = Dpi::Scale(kIconSz, dpi);
    int gap   = Dpi::Scale(kGap, dpi);
    int itemH = Dpi::Scale(kItemH, dpi);
    int mPad  = Dpi::Scale(kMenuPad, dpi);

    int w = padH + icon + gap + maxW + padH * 2;
    int h = mPad * 2 + itemH * count;
    return { (std::max)(w, Dpi::Scale(160, dpi)), h };
}

static HFONT CreateMenuFont(int dpi) {
    return CreateFontW(
        -Dpi::Scale(13, dpi), 0, 0, 0, FW_NORMAL,
        FALSE, FALSE, FALSE, DEFAULT_CHARSET,
        OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
        CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_SWISS,
        L"Segoe UI");
}

// ── Window Procedure ────────────────────────────────────────
LRESULT CALLBACK PopupMenu::PopupProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    auto* d = reinterpret_cast<PopupData*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));

    switch (msg) {
    case WM_CREATE: {
        auto* cs = reinterpret_cast<CREATESTRUCTW*>(lp);
        SetWindowLongPtrW(hwnd, GWLP_USERDATA,
            reinterpret_cast<LONG_PTR>(cs->lpCreateParams));
        return 0;
    }

    case WM_ERASEBKGND:
        return 1;

    case WM_PAINT: {
        if (!d) break;
        PAINTSTRUCT ps;
        HDC hdc = BeginPaint(hwnd, &ps);

        auto& c = Theme::Colors();
        int dpi = d->dpi;
        RECT rc; GetClientRect(hwnd, &rc);
        int w = rc.right, h = rc.bottom;

        // ── Double buffer: draw to off-screen bitmap, then BitBlt once ──
        HDC memDC = CreateCompatibleDC(hdc);
        HBITMAP memBmp = CreateCompatibleBitmap(hdc, w, h);
        HBITMAP oldMemBmp = static_cast<HBITMAP>(SelectObject(memDC, memBmp));

        // Solid background
        HBRUSH bgBr = CreateSolidBrush(c.surface);
        FillRect(memDC, &rc, bgBr);
        DeleteObject(bgBr);

        // 1px border
        HBRUSH bdrBr = CreateSolidBrush(c.border);
        FrameRect(memDC, &rc, bdrBr);
        DeleteObject(bdrBr);

        // Font
        HFONT font = CreateMenuFont(dpi);
        HFONT oldFont = static_cast<HFONT>(SelectObject(memDC, font));
        SetBkMode(memDC, TRANSPARENT);
        SetTextColor(memDC, c.text);

        int padH   = Dpi::Scale(kPadH, dpi);
        int iconSz = Dpi::Scale(kIconSz, dpi);
        int gap    = Dpi::Scale(kGap, dpi);
        uint32_t iconClr = Theme::IconColor();

        for (int i = 0; i < d->count; i++) {
            RECT ir = ItemRect(i, rc.right, dpi);

            // Hover highlight
            if (i == d->hovered) {
                int ins = Dpi::Scale(4, dpi);
                RECT hr = { ir.left + ins, ir.top + 1, ir.right - ins, ir.bottom - 1 };
                HBRUSH hovBr = CreateSolidBrush(c.surfaceHover);
                FillRect(memDC, &hr, hovBr);
                DeleteObject(hovBr);
            }

            // Icon
            int ix = ir.left + padH;
            int iy = ir.top + (ir.bottom - ir.top - iconSz) / 2;
            if (d->choices[i].iconName && d->choices[i].iconName[0]) {
                HBITMAP hbm = LucideIcons::CreateBitmap(
                    d->choices[i].iconName, iconSz, iconClr);
                if (hbm) {
                    HDC iconDC = CreateCompatibleDC(memDC);
                    HBITMAP oldBmp = static_cast<HBITMAP>(SelectObject(iconDC, hbm));
                    BLENDFUNCTION bf{};
                    bf.BlendOp = AC_SRC_OVER;
                    bf.SourceConstantAlpha = (i == d->hovered) ? 255 : 180;
                    bf.AlphaFormat = AC_SRC_ALPHA;
                    AlphaBlend(memDC, ix, iy, iconSz, iconSz,
                               iconDC, 0, 0, iconSz, iconSz, bf);
                    SelectObject(iconDC, oldBmp);
                    DeleteDC(iconDC);
                    DeleteObject(hbm);
                }
            }

            // Text
            int tx = ix + iconSz + gap;
            RECT tr = { tx, ir.top, ir.right - padH, ir.bottom };
            DrawTextW(memDC, d->choices[i].label, -1, &tr,
                      DT_LEFT | DT_VCENTER | DT_SINGLELINE | DT_NOPREFIX);
        }

        SelectObject(memDC, oldFont);
        DeleteObject(font);

        // ── Single blit to window ──
        BitBlt(hdc, 0, 0, w, h, memDC, 0, 0, SRCCOPY);
        SelectObject(memDC, oldMemBmp);
        DeleteObject(memBmp);
        DeleteDC(memDC);

        EndPaint(hwnd, &ps);
        return 0;
    }

    // ── Mouse ───────────────────────────────────────────────
    case WM_MOUSEMOVE: {
        if (!d) break;
        int newH = ItemAtY(GET_Y_LPARAM(lp), d->count, d->dpi);
        if (newH != d->hovered) {
            d->hovered = newH;
            InvalidateRect(hwnd, nullptr, FALSE);
        }
        TRACKMOUSEEVENT tme{ sizeof(tme), TME_LEAVE, hwnd, 0 };
        TrackMouseEvent(&tme);
        return 0;
    }

    case WM_MOUSELEAVE:
        if (d && d->hovered >= 0) {
            d->hovered = -1;
            InvalidateRect(hwnd, nullptr, FALSE);
        }
        return 0;

    case WM_LBUTTONDOWN: {
        if (!d) break;
        int idx = ItemAtY(GET_Y_LPARAM(lp), d->count, d->dpi);
        if (idx >= 0) d->result = d->choices[idx].id;
        d->dismissed = true;
        return 0;
    }

    // ── Keyboard ────────────────────────────────────────────
    case WM_KEYDOWN:
        if (!d) break;
        switch (wp) {
        case VK_ESCAPE: d->dismissed = true; break;
        case VK_UP:
            d->hovered = (d->hovered > 0) ? d->hovered - 1 : d->count - 1;
            InvalidateRect(hwnd, nullptr, FALSE); break;
        case VK_DOWN:
            d->hovered = (d->hovered < d->count - 1) ? d->hovered + 1 : 0;
            InvalidateRect(hwnd, nullptr, FALSE); break;
        case VK_RETURN: case VK_SPACE:
            if (d->hovered >= 0) d->result = d->choices[d->hovered].id;
            d->dismissed = true; break;
        }
        return 0;

    // ── Dismiss on deactivation ─────────────────────────────
    case WM_ACTIVATE:
        if (LOWORD(wp) == WA_INACTIVE && d && d->ready)
            d->dismissed = true;
        return 0;
    }

    return DefWindowProcW(hwnd, msg, wp, lp);
}

// ── Public API ──────────────────────────────────────────────
WORD PopupMenu::Show(HWND parent, POINT screenPt,
                     const DropdownChoice* choices, int count, int dpi)
{
    if (!choices || count <= 0) return 0;

    if (!s_classRegistered) {
        WNDCLASSEXW wc{};
        wc.cbSize        = sizeof(wc);
        wc.style         = CS_HREDRAW | CS_VREDRAW | CS_DROPSHADOW;
        wc.lpfnWndProc   = PopupProc;
        wc.hInstance      = GetModuleHandleW(nullptr);
        wc.hCursor       = LoadCursorW(nullptr, IDC_ARROW);
        wc.hbrBackground = CreateSolidBrush(RGB(30, 30, 30));
        wc.lpszClassName = L"ResolutePopupMenu";
        RegisterClassExW(&wc);
        s_classRegistered = true;
    }

    HFONT font = CreateMenuFont(dpi);
    SIZE sz = MeasureMenu(choices, count, dpi, font);
    DeleteObject(font);

    // Keep on screen
    HMONITOR hm = MonitorFromPoint(screenPt, MONITOR_DEFAULTTONEAREST);
    MONITORINFO mi{ sizeof(mi) };
    GetMonitorInfoW(hm, &mi);
    if (screenPt.x + sz.cx > mi.rcWork.right)
        screenPt.x = mi.rcWork.right - sz.cx;
    if (screenPt.y + sz.cy > mi.rcWork.bottom)
        screenPt.y -= sz.cy;

    PopupData data{};
    data.choices = choices;
    data.count   = count;
    data.dpi     = dpi;

    HWND popup = CreateWindowExW(
        WS_EX_TOOLWINDOW | WS_EX_TOPMOST,
        L"ResolutePopupMenu", nullptr, WS_POPUP,
        screenPt.x, screenPt.y, sz.cx, sz.cy,
        parent, nullptr, GetModuleHandleW(nullptr), &data);
    if (!popup) return 0;

    // Show, then force foreground + focus so hover works immediately
    ShowWindow(popup, SW_SHOW);
    SetForegroundWindow(popup);
    SetFocus(popup);
    data.ready = true;

    // Simple blocking loop
    MSG msg;
    while (!data.dismissed && GetMessageW(&msg, nullptr, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }

    SetWindowLongPtrW(popup, GWLP_USERDATA, 0);
    DestroyWindow(popup);

    return data.result;
}

} // namespace rui
