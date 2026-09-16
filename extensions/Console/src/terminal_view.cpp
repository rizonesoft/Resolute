#include "terminal_view.h"
#include <windowsx.h>
#include <string>
#include <cmath>

#pragma comment(lib, "d2d1.lib")
#pragma comment(lib, "dwrite.lib")

// Custom repaint message (used for thread-safe invalidation)
#define WM_TERM_REPAINT (WM_USER + 100)

// ── Create ──────────────────────────────────────────────────
void TerminalView::Create(HWND parent, HINSTANCE hInst,
                          TerminalEmulator* emu, PtySession* pty) {
    m_parent = parent;
    m_emu = emu;
    m_pty = pty;
    m_dpi = GetDpiForWindow(parent);

    // Register window class
    WNDCLASSEXW wc{};
    wc.cbSize = sizeof(wc);
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = WndProc;
    wc.hInstance = hInst;
    wc.hCursor = LoadCursorW(nullptr, IDC_IBEAM);  // text cursor
    wc.lpszClassName = L"ExoTerminalView";
    RegisterClassExW(&wc);

    m_hwnd = CreateWindowExW(0, L"ExoTerminalView", nullptr,
        WS_CHILD | WS_VISIBLE,
        0, 0, 400, 400, parent,
        nullptr, hInst, this);

    // D2D + DWrite factories
    D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED, m_d2dFactory.GetAddressOf());
    DWriteCreateFactory(DWRITE_FACTORY_TYPE_SHARED,
        __uuidof(IDWriteFactory),
        reinterpret_cast<IUnknown**>(m_dwriteFactory.GetAddressOf()));

    CreateTextFormat();
    CreateRenderTarget();

    // DPI-scaled padding
    m_padding = 8.0f * m_dpi / 96.0f;

    // Start cursor blink timer (530ms — same as Windows default)
    SetTimer(m_hwnd, m_blinkTimer, 530, nullptr);
}

// ── Text Format & Cell Metrics ──────────────────────────────
void TerminalView::CreateTextFormat() {
    if (!m_dwriteFactory) return;

    float fontSize = 10.0f * m_dpi / 96.0f;

    // Try Cascadia Mono (Win11), fall back to Consolas
    m_dwriteFactory->CreateTextFormat(
        L"Cascadia Mono", nullptr,
        DWRITE_FONT_WEIGHT_REGULAR,
        DWRITE_FONT_STYLE_NORMAL,
        DWRITE_FONT_STRETCH_NORMAL,
        fontSize, L"en-US", m_textFormat.GetAddressOf());

    if (!m_textFormat) {
        m_dwriteFactory->CreateTextFormat(
            L"Consolas", nullptr,
            DWRITE_FONT_WEIGHT_REGULAR,
            DWRITE_FONT_STYLE_NORMAL,
            DWRITE_FONT_STRETCH_NORMAL,
            fontSize, L"en-US", m_textFormat.GetAddressOf());
    }

    if (!m_textFormat) return;

    m_textFormat->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);

    // Measure cell size using a reference character
    ComPtr<IDWriteTextLayout> layout;
    m_dwriteFactory->CreateTextLayout(L"M", 1, m_textFormat.Get(),
        1000.0f, 1000.0f, layout.GetAddressOf());

    if (layout) {
        DWRITE_TEXT_METRICS metrics{};
        layout->GetMetrics(&metrics);
        m_cellW = std::ceil(metrics.width);
        m_cellH = std::ceil(metrics.height);
    }
}

// ── Render Target ───────────────────────────────────────────
void TerminalView::CreateRenderTarget() {
    if (!m_d2dFactory || !m_hwnd) return;
    m_rt.Reset();

    RECT rc;
    GetClientRect(m_hwnd, &rc);

    D2D1_SIZE_U size = D2D1::SizeU(rc.right, rc.bottom);

    // Use default 96 DPI — we handle DPI scaling manually via font size.
    // Setting monitor DPI here would double-scale everything.
    m_d2dFactory->CreateHwndRenderTarget(
        D2D1::RenderTargetProperties(),
        D2D1::HwndRenderTargetProperties(m_hwnd, size),
        m_rt.GetAddressOf());
}

// ── Layout ──────────────────────────────────────────────────
void TerminalView::Resize(int x, int y, int w, int h) {
    if (m_hwnd) MoveWindow(m_hwnd, x, y, w, h, TRUE);
    if (m_rt) {
        D2D1_SIZE_U size = D2D1::SizeU(w, h);
        m_rt->Resize(size);
    }
}

void TerminalView::Invalidate() {
    if (m_hwnd) PostMessageW(m_hwnd, WM_TERM_REPAINT, 0, 0);
}

int TerminalView::ColsForWidth(int pw) const {
    // Convert physical pixels to D2D logical coordinates
    float scale = m_dpi / 96.0f;
    float logical = pw / scale;
    float usable = logical - m_padding * 2;
    return (m_cellW > 0 && usable > 0) ? static_cast<int>(usable / m_cellW) : 80;
}
int TerminalView::RowsForHeight(int ph) const {
    // Convert physical pixels to D2D logical coordinates
    float scale = m_dpi / 96.0f;
    float logical = ph / scale;
    float usable = logical - m_padding * 2;
    return (m_cellH > 0 && usable > 0) ? static_cast<int>(usable / m_cellH) : 24;
}

// ── Selection Helpers ──────────────────────────────────────────
TerminalView::CellPos TerminalView::HitTest(int px, int py) const {
    // Convert physical mouse coordinates to D2D logical coordinates
    float scale = m_dpi / 96.0f;
    float lx = px / scale;
    float ly = py / scale;
    int col = static_cast<int>((lx - m_padding) / m_cellW);
    int row = static_cast<int>((ly - m_padding) / m_cellH);
    if (col < 0) col = 0;
    if (row < 0) row = 0;
    return {row, col};
}

bool TerminalView::IsCellSelected(int row, int col) const {
    if (!HasSelection()) return false;
    // Normalize start/end so start <= end
    int r0 = m_selAnchor.row, c0 = m_selAnchor.col;
    int r1 = m_selActive.row,  c1 = m_selActive.col;
    if (r0 > r1 || (r0 == r1 && c0 > c1)) {
        std::swap(r0, r1); std::swap(c0, c1);
    }
    if (row < r0 || row > r1) return false;
    if (row == r0 && row == r1) return col >= c0 && col <= c1;
    if (row == r0) return col >= c0;
    if (row == r1) return col <= c1;
    return true;  // full row between start and end
}

void TerminalView::CopySelection() {
    if (!HasSelection() || !m_emu) return;

    int r0 = m_selAnchor.row, c0 = m_selAnchor.col;
    int r1 = m_selActive.row,  c1 = m_selActive.col;
    if (r0 > r1 || (r0 == r1 && c0 > c1)) {
        std::swap(r0, r1); std::swap(c0, c1);
    }

    m_emu->Lock();
    int cols = m_emu->Cols();
    int sbCount = m_emu->ScrollbackCount();
    std::wstring text;

    for (int r = r0; r <= r1; r++) {
        int startC = (r == r0) ? c0 : 0;
        int endC   = (r == r1) ? c1 : cols - 1;
        for (int c = startC; c <= endC; c++) {
            int virtualLine = r - m_scrollOffset;
            TermCell cell;
            if (virtualLine < 0) {
                cell = m_emu->GetScrollbackCell(sbCount + virtualLine, c);
            } else {
                cell = m_emu->GetCell(virtualLine, c);
            }
            text += cell.ch;
        }
        if (r < r1) text += L'\n';
    }
    m_emu->Unlock();

    // Trim trailing spaces from each line
    // (terminal lines are padded with spaces)
    std::wstring trimmed;
    size_t pos = 0;
    while (pos < text.size()) {
        size_t nl = text.find(L'\n', pos);
        size_t end = (nl == std::wstring::npos) ? text.size() : nl;
        std::wstring line = text.substr(pos, end - pos);
        // Trim trailing spaces
        while (!line.empty() && line.back() == L' ') line.pop_back();
        trimmed += line;
        if (nl != std::wstring::npos) trimmed += L'\n';
        pos = end + 1;
    }

    // Copy to clipboard
    if (OpenClipboard(m_hwnd)) {
        EmptyClipboard();
        HGLOBAL hMem = GlobalAlloc(GMEM_MOVEABLE, (trimmed.size() + 1) * sizeof(wchar_t));
        if (hMem) {
            auto* dst = static_cast<wchar_t*>(GlobalLock(hMem));
            memcpy(dst, trimmed.c_str(), (trimmed.size() + 1) * sizeof(wchar_t));
            GlobalUnlock(hMem);
            SetClipboardData(CF_UNICODETEXT, hMem);
        }
        CloseClipboard();
    }
}

// ── Paint ───────────────────────────────────────────────────
void TerminalView::OnPaint() {
    if (!m_rt || !m_emu || !m_textFormat) return;

    m_rt->BeginDraw();

    // Dark background
    D2D1_COLOR_F termBg = D2D1::ColorF(0.07f, 0.07f, 0.10f);
    D2D1_COLOR_F termFg = D2D1::ColorF(0x18 / 255.0f, 0xFF / 255.0f, 0xFF / 255.0f);  // #18FFFF
    m_rt->Clear(termBg);

    ComPtr<ID2D1SolidColorBrush> brush;
    m_rt->CreateSolidColorBrush(D2D1::ColorF(D2D1::ColorF::White), brush.GetAddressOf());
    if (!brush) { m_rt->EndDraw(); return; }

    m_emu->Lock();

    int rows = m_emu->Rows();
    int cols = m_emu->Cols();
    int sbCount = m_emu->ScrollbackCount();

    // Calculate how many rows physically fit in the window
    // Use render target logical size (DPI-aware), not physical GetClientRect
    D2D1_SIZE_F rtLogical = m_rt->GetSize();
    int visibleRows = static_cast<int>((rtLogical.height - m_padding * 2) / m_cellH);
    if (visibleRows < 1) visibleRows = 1;

    // Viewport offset: always keep the cursor row visible by
    // shifting the view when the grid has more rows than fit.
    int viewportOffset = 0;
    if (m_scrollOffset == 0) {
        int cr = m_emu->CursorRow();
        if (cr >= visibleRows)
            viewportOffset = cr - visibleRows + 1;
    }
    int paintRows = (rows < visibleRows) ? rows : visibleRows;

    // DEBUG: Show dimensions in title bar
    wchar_t dbg[256];
    swprintf_s(dbg, L"Console [grid:%dx%d vis:%d vp:%d cur:%d cellH:%.1f logH:%.1f dpi:%d]",
        cols, rows, visibleRows, viewportOffset,
        m_emu->CursorRow(), m_cellH, rtLogical.height, m_dpi);
    SetWindowTextW(GetParent(m_hwnd), dbg);

    for (int r = 0; r < paintRows; r++) {
        // Which virtual line does this screen row correspond to?
        int virtualLine = r + viewportOffset - m_scrollOffset;
        // virtualLine < 0 → we're in the scrollback buffer
        // virtualLine >= 0 → we're in the live screen

        for (int c = 0; c < cols; c++) {
            TermCell cell;
            if (virtualLine < 0) {
                // Scrollback: index from end (newest = sbCount-1)
                int sbLine = sbCount + virtualLine;  // sbCount - scrollOffset + r
                cell = m_emu->GetScrollbackCell(sbLine, c);
            } else {
                cell = m_emu->GetCell(virtualLine, c);
            }

            float x = m_padding + c * m_cellW;
            float y = m_padding + r * m_cellH;
            D2D1_RECT_F cellRect = D2D1::RectF(x, y, x + m_cellW, y + m_cellH);

            // Background (if not default)
            D2D1_COLOR_F bg = cell.reverse ? cell.fg : cell.bg;
            D2D1_COLOR_F fg = cell.reverse ? cell.bg : cell.fg;

            // Override default fg (white) with terminal accent color
            if (fg.r > 0.99f && fg.g > 0.99f && fg.b > 0.99f)
                fg = termFg;

            if (bg.a > 0.01f) {
                brush->SetColor(bg);
                m_rt->FillRectangle(cellRect, brush.Get());
            }

            // Foreground character
            if (cell.ch > L' ') {
                if (cell.reverse && fg.a < 0.01f) {
                    fg = termBg;
                }
                brush->SetColor(fg);
                wchar_t ch = cell.ch;
                m_rt->DrawText(&ch, 1, m_textFormat.Get(), cellRect, brush.Get());
            }

            // Selection highlight
            if (IsCellSelected(r, c)) {
                brush->SetColor(D2D1::ColorF(termFg.r, termFg.g, termFg.b, 0.25f));
                m_rt->FillRectangle(cellRect, brush.Get());
            }
        }
    }

    if (m_scrollOffset == 0 && m_emu->CursorVisible() && m_cursorOn) {
        int cr = m_emu->CursorRow();
        int cc = m_emu->CursorCol();
        int screenRow = cr - viewportOffset;
        if (screenRow >= 0 && screenRow < paintRows) {
            float cx = m_padding + cc * m_cellW;
            float cy = m_padding + screenRow * m_cellH;

            brush->SetColor(D2D1::ColorF(termFg.r, termFg.g, termFg.b, 0.85f));
            m_rt->FillRectangle(D2D1::RectF(cx, cy, cx + m_cellW, cy + m_cellH), brush.Get());

            TermCell cursorCell = m_emu->GetCell(cr, cc);
            if (cursorCell.ch > L' ') {
                brush->SetColor(termBg);
                wchar_t ch = cursorCell.ch;
                D2D1_RECT_F cellRect = D2D1::RectF(cx, cy, cx + m_cellW, cy + m_cellH);
                m_rt->DrawText(&ch, 1, m_textFormat.Get(), cellRect, brush.Get());
            }
        }
    }

    m_emu->Unlock();
    m_rt->EndDraw();
}

// ── Window Procedure ────────────────────────────────────────
LRESULT CALLBACK TerminalView::WndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    TerminalView* self = nullptr;

    if (msg == WM_NCCREATE) {
        auto cs = reinterpret_cast<CREATESTRUCTW*>(lp);
        self = static_cast<TerminalView*>(cs->lpCreateParams);
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(self));
    } else {
        self = reinterpret_cast<TerminalView*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
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

    case WM_TERM_REPAINT:
        // New output arrived — auto-scroll to bottom
        self->m_scrollOffset = 0;
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;

    case WM_ERASEBKGND:
        return 1;

    case WM_SIZE:
        if (self->m_rt) {
            RECT rc;
            GetClientRect(hwnd, &rc);
            self->m_rt->Resize(D2D1::SizeU(rc.right, rc.bottom));
        }
        return 0;

    case WM_TIMER:
        if (wp == self->m_blinkTimer) {
            self->m_cursorOn = !self->m_cursorOn;
            InvalidateRect(hwnd, nullptr, FALSE);
        }
        return 0;

    case WM_SETFOCUS:
        self->m_cursorOn = true;
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;

    // ── Mouse Selection ───────────────────────────────────
    case WM_LBUTTONDOWN: {
        self->ClearSelection();
        auto pos = self->HitTest(GET_X_LPARAM(lp), GET_Y_LPARAM(lp));
        self->m_selAnchor = pos;
        self->m_selActive = pos;
        self->m_selecting = true;
        SetCapture(hwnd);
        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;
    }
    case WM_MOUSEMOVE:
        if (self->m_selecting) {
            self->m_selActive = self->HitTest(GET_X_LPARAM(lp), GET_Y_LPARAM(lp));
            InvalidateRect(hwnd, nullptr, FALSE);
        }
        return 0;
    case WM_LBUTTONUP:
        if (self->m_selecting) {
            self->m_selActive = self->HitTest(GET_X_LPARAM(lp), GET_Y_LPARAM(lp));
            self->m_selecting = false;
            ReleaseCapture();
            if (self->m_selAnchor.row == self->m_selActive.row &&
                self->m_selAnchor.col == self->m_selActive.col)
                self->ClearSelection();
            InvalidateRect(hwnd, nullptr, FALSE);
        }
        return 0;

    case WM_MOUSEWHEEL: {
        int delta = GET_WHEEL_DELTA_WPARAM(wp);
        int lines = delta / WHEEL_DELTA * 3;  // 3 lines per notch
        if (self->m_emu) {
            self->m_emu->Lock();
            int maxScroll = self->m_emu->ScrollbackCount();
            self->m_emu->Unlock();
            self->m_scrollOffset += lines;
            if (self->m_scrollOffset < 0) self->m_scrollOffset = 0;
            if (self->m_scrollOffset > maxScroll) self->m_scrollOffset = maxScroll;
            InvalidateRect(hwnd, nullptr, FALSE);
        }
        return 0;
    }

    // ── Keyboard Input ──────────────────────────────────────
    case WM_CHAR: {
        // Ctrl+C: copy selection if present, else send ^C to shell
        wchar_t wc = static_cast<wchar_t>(wp);
        if (wc == 3 /* Ctrl+C */ && self->HasSelection()) {
            self->CopySelection();
            self->ClearSelection();
            InvalidateRect(hwnd, nullptr, FALSE);
            return 0;
        }
        // Ctrl+V: paste from clipboard
        if (wc == 22 /* Ctrl+V */ && self->m_pty) {
            if (OpenClipboard(hwnd)) {
                HANDLE hData = GetClipboardData(CF_UNICODETEXT);
                if (hData) {
                    auto* text = static_cast<wchar_t*>(GlobalLock(hData));
                    if (text) {
                        int len = WideCharToMultiByte(CP_UTF8, 0, text, -1, nullptr, 0, nullptr, nullptr);
                        if (len > 0) {
                            std::string utf8(len, '\0');
                            WideCharToMultiByte(CP_UTF8, 0, text, -1, utf8.data(), len, nullptr, nullptr);
                            self->m_pty->Write(utf8.data(), utf8.size() - 1);  // exclude null
                        }
                        GlobalUnlock(hData);
                    }
                }
                CloseClipboard();
            }
            return 0;
        }
        // Clear selection on any typing
        if (self->HasSelection()) {
            self->ClearSelection();
            InvalidateRect(hwnd, nullptr, FALSE);
        }
        // Regular character input → write UTF-8 to PTY
        char utf8[4];
        int len = WideCharToMultiByte(CP_UTF8, 0, &wc, 1, utf8, sizeof(utf8), nullptr, nullptr);
        if (len > 0 && self->m_pty)
            self->m_pty->Write(utf8, len);
        return 0;
    }

    case WM_KEYDOWN: {
        // Special keys → VT escape sequences
        const char* seq = nullptr;
        switch (wp) {
        case VK_UP:     seq = "\x1b[A"; break;
        case VK_DOWN:   seq = "\x1b[B"; break;
        case VK_RIGHT:  seq = "\x1b[C"; break;
        case VK_LEFT:   seq = "\x1b[D"; break;
        case VK_HOME:   seq = "\x1b[H"; break;
        case VK_END:    seq = "\x1b[F"; break;
        case VK_INSERT: seq = "\x1b[2~"; break;
        case VK_DELETE: seq = "\x1b[3~"; break;
        case VK_PRIOR:  seq = "\x1b[5~"; break;  // Page Up
        case VK_NEXT:   seq = "\x1b[6~"; break;  // Page Down
        case VK_F1:     seq = "\x1bOP"; break;
        case VK_F2:     seq = "\x1bOQ"; break;
        case VK_F3:     seq = "\x1bOR"; break;
        case VK_F4:     seq = "\x1bOS"; break;
        case VK_F5:     seq = "\x1b[15~"; break;
        case VK_F6:     seq = "\x1b[17~"; break;
        case VK_F7:     seq = "\x1b[18~"; break;
        case VK_F8:     seq = "\x1b[19~"; break;
        case VK_F9:     seq = "\x1b[20~"; break;
        case VK_F10:    seq = "\x1b[21~"; break;
        case VK_F11:    seq = "\x1b[23~"; break;
        case VK_F12:    {
            // DEBUG DUMP — capture full render state
            if (self->m_emu && self->m_rt) {
                FILE* f;
                if (fopen_s(&f, "grid_dump.txt", "w") == 0) {
                    self->m_emu->Lock();

                    // Render target size
                    D2D1_SIZE_F rtSize = self->m_rt->GetSize();
                    D2D1_SIZE_U rtPixels = self->m_rt->GetPixelSize();
                    FLOAT dpiX, dpiY;
                    self->m_rt->GetDpi(&dpiX, &dpiY);

                    // Client rect
                    RECT wrc;
                    GetClientRect(self->m_hwnd, &wrc);

                    // Cell metrics
                    float cellW = self->m_cellW;
                    float cellH = self->m_cellH;
                    float padding = self->m_padding;
                    int dpi = self->m_dpi;

                    // Computed values
                    int visibleRows = static_cast<int>((wrc.bottom - padding * 2) / cellH);
                    int visibleCols = static_cast<int>((wrc.right - padding * 2) / cellW);
                    int gridRows = self->m_emu->Rows();
                    int gridCols = self->m_emu->Cols();
                    int curRow = self->m_emu->CursorRow();
                    int curCol = self->m_emu->CursorCol();

                    fprintf(f, "=== CONSOLE DEBUG DUMP ===\n");
                    fprintf(f, "DPI: member=%d, RT_dpiX=%.1f RT_dpiY=%.1f\n", dpi, dpiX, dpiY);
                    fprintf(f, "ClientRect: %ld x %ld\n", wrc.right, wrc.bottom);
                    fprintf(f, "RenderTarget: size=%.1f x %.1f  pixels=%u x %u\n",
                        rtSize.width, rtSize.height, rtPixels.width, rtPixels.height);
                    fprintf(f, "CellMetrics: W=%.2f H=%.2f  Padding=%.2f\n", cellW, cellH, padding);
                    fprintf(f, "VisibleRows=%d  VisibleCols=%d\n", visibleRows, visibleCols);
                    fprintf(f, "GridRows=%d  GridCols=%d\n", gridRows, gridCols);
                    fprintf(f, "CursorRow=%d  CursorCol=%d\n", curRow, curCol);
                    fprintf(f, "ScrollOffset=%d  ScrollbackCount=%d\n",
                        self->m_scrollOffset, self->m_emu->ScrollbackCount());
                    fprintf(f, "LastRowTop=%.1f  LastRowBottom=%.1f  (clientBottom=%ld)\n",
                        padding + (gridRows - 1) * cellH,
                        padding + gridRows * cellH,
                        wrc.bottom);
                    fprintf(f, "\n--- GRID ---\n");

                    for (int r = 0; r < gridRows; r++) {
                        fprintf(f, "%02d: ", r);
                        for (int c = 0; c < gridCols; c++) {
                            TermCell cell = self->m_emu->GetCell(r, c);
                            fputc(cell.ch > L' ' ? (char)cell.ch : ' ', f);
                        }
                        fputc('\n', f);
                    }

                    self->m_emu->Unlock();
                    fclose(f);
                }
            }
            break;
        }
        case VK_BACK:   seq = "\x7f"; break;      // Backspace
        case VK_TAB:    seq = "\t"; break;
        case VK_ESCAPE: seq = "\x1b"; break;
        case VK_RETURN: seq = "\r"; break;
        default: return 0;  // Let WM_CHAR handle regular keys
        }
        if (seq && self->m_pty)
            self->m_pty->Write(seq, strlen(seq));
        return 0;
    }

    case WM_DPICHANGED_AFTERPARENT: {
        UINT newDpi = GetDpiForWindow(hwnd);
        if (newDpi == 0) newDpi = 96;
        self->m_dpi = newDpi;
        self->m_padding = 8.0f * newDpi / 96.0f;

        // Recreate text format with updated font size for new DPI
        self->m_textFormat.Reset();
        self->CreateTextFormat();

        // Recreate render target for the new DPI
        self->CreateRenderTarget();
        if (self->m_rt) {
            // Set the render target DPI so logical<->physical mapping is correct
            self->m_rt->SetDpi(static_cast<FLOAT>(newDpi), static_cast<FLOAT>(newDpi));
        }

        // Trigger parent WM_SIZE so emulator/ConPTY gets resized
        // with corrected DPI-aware row/col calculations
        HWND parent = GetParent(hwnd);
        if (parent) {
            RECT prc;
            GetClientRect(parent, &prc);
            PostMessageW(parent, WM_SIZE, SIZE_RESTORED,
                MAKELPARAM(prc.right, prc.bottom));
        }

        InvalidateRect(hwnd, nullptr, FALSE);
        return 0;
    }
    }

    return DefWindowProcW(hwnd, msg, wp, lp);
}
