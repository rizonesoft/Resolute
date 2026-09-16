// ── ExoSuite Console Extension ──────────────────────────────
// Single-tab terminal emulator: ConPTY + libvterm + Direct2D
#define _WIN32_WINNT 0x0A00
#include <windows.h>
#include <commctrl.h>
#include <dwmapi.h>

#include "pty_session.h"
#include "terminal_emulator.h"
#include "terminal_view.h"

#pragma comment(lib, "comctl32.lib")
#pragma comment(lib, "dwmapi.lib")

// ── Globals ─────────────────────────────────────────────────
static PtySession        g_pty;
static TerminalEmulator  g_emu;
static TerminalView      g_view;
static bool              g_initialized = false;

// ── Dark Title Bar ──────────────────────────────────────────
static void ApplyDarkMode(HWND hwnd) {
    BOOL dark = TRUE;
    DwmSetWindowAttribute(hwnd, 20 /*DWMWA_USE_IMMERSIVE_DARK_MODE*/,
                          &dark, sizeof(dark));
}

// ── Deferred Init (called on first WM_SIZE with real dimensions) ──
static void InitTerminal(int cols, int rows) {
    if (g_initialized) return;
    g_initialized = true;

    g_emu.Init(cols, rows);

    // Wire ConPTY output → emulator → view repaint
    // Includes stream-level dedup: ConPTY's screen diff sends
    // prompt<CR><LF>prompt — detect and strip the first copy.
    g_pty.OnOutput = [](const char* data, size_t len) {
        // Find the LAST CR+LF in the chunk
        int lastCRLF = -1;
        for (int i = (int)len - 2; i >= 0; i--) {
            if (data[i] == '\r' && data[i + 1] == '\n') {
                lastCRLF = i;
                break;
            }
        }

        if (lastCRLF >= 0) {
            // Text after the last CR+LF
            const char* afterCRLF = data + lastCRLF + 2;
            int afterLen = (int)len - lastCRLF - 2;

            // Find the CR+LF before this one (to get the line before)
            int prevCRLF = -1;
            for (int i = lastCRLF - 1; i >= 0; i--) {
                if (data[i] == '\r' && data[i + 1] == '\n') {
                    prevCRLF = i;
                    break;
                }
            }

            // The line between prevCRLF and lastCRLF
            int lineStart = (prevCRLF >= 0) ? prevCRLF + 2 : 0;
            const char* beforeLine = data + lineStart;
            int beforeLen = lastCRLF - lineStart;

            // Compare: strip ANSI escape sequences and compare visible text
            // Simple approach: extract printable chars from both lines
            auto extractText = [](const char* s, int n) -> std::string {
                std::string out;
                int i = 0;
                while (i < n) {
                    if (s[i] == '\x1b' && i + 1 < n && s[i + 1] == '[') {
                        // Skip CSI sequence
                        i += 2;
                        while (i < n && !((s[i] >= 'A' && s[i] <= 'Z') ||
                               (s[i] >= 'a' && s[i] <= 'z'))) i++;
                        if (i < n) i++;  // skip final byte
                    } else if (s[i] >= ' ') {
                        out += s[i++];
                    } else {
                        i++;
                    }
                }
                return out;
            };

            std::string textBefore = extractText(beforeLine, beforeLen);
            std::string textAfter  = extractText(afterCRLF, afterLen);

            // If both lines have the same visible text and it's non-empty,
            // feed everything except the first (duplicate) line + CR+LF
            if (!textBefore.empty() && textBefore == textAfter) {
                // Feed data before the duplicate line
                if (lineStart > 0) g_emu.Feed(data, lineStart);
                // Feed data from the second copy onward (skip CR+LF)
                g_emu.Feed(afterCRLF, afterLen);
                g_view.Invalidate();
                return;
            }
        }

        // No dedup needed — feed normally
        g_emu.Feed(data, len);
        g_view.Invalidate();
    };

    g_pty.OnExit = []() {
        PostMessageW(GetParent(g_view.Handle()), WM_CLOSE, 0, 0);
    };

    // Start the shell with the exact visible dimensions
    g_pty.Start(cols, rows);
}

// ── Window Procedure ────────────────────────────────────────
static LRESULT CALLBACK MainWndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    switch (msg) {
    case WM_CREATE: {
        ApplyDarkMode(hwnd);
        HINSTANCE hInst = reinterpret_cast<CREATESTRUCTW*>(lp)->hInstance;

        // Create the terminal view (for cell metrics), but DON'T
        // start the emulator/PTY yet — wait for first WM_SIZE.
        g_view.Create(hwnd, hInst, &g_emu, &g_pty);
        return 0;
    }

    case WM_SIZE: {
        int w = LOWORD(lp);
        int h = HIWORD(lp);
        if (w == 0 || h == 0) return 0;  // minimized

        g_view.Resize(0, 0, w, h);

        int cols = g_view.ColsForWidth(w);
        int rows = g_view.RowsForHeight(h);
        if (cols < 1) cols = 80;
        if (rows < 1) rows = 24;

        if (!g_initialized) {
            // First real WM_SIZE — now we know the exact visible area
            InitTerminal(cols, rows);
            SetFocus(g_view.Handle());
        } else {
            // Only resize emulator/ConPTY when grid dimensions actually change.
            // Redundant ResizePseudoConsole calls cause ConPTY to redraw its
            // entire buffer, duplicating content like the command prompt.
            static int lastCols = 0, lastRows = 0;
            if (cols != lastCols || rows != lastRows) {
                lastCols = cols;
                lastRows = rows;
                g_emu.Resize(cols, rows);
                g_pty.Resize(cols, rows);
            }
        }
        return 0;
    }

    case WM_SETFOCUS:
        SetFocus(g_view.Handle());
        return 0;

    case WM_DPICHANGED: {
        // When the window moves to a monitor with different DPI,
        // use the suggested rect to resize properly
        auto* suggested = reinterpret_cast<const RECT*>(lp);
        SetWindowPos(hwnd, nullptr,
            suggested->left, suggested->top,
            suggested->right - suggested->left,
            suggested->bottom - suggested->top,
            SWP_NOZORDER | SWP_NOACTIVATE);
        return 0;
    }

    case WM_DESTROY:
        g_pty.Close();
        g_emu.Destroy();
        PostQuitMessage(0);
        return 0;
    }

    return DefWindowProcW(hwnd, msg, wp, lp);
}

// ── Entry Point ─────────────────────────────────────────────
int WINAPI wWinMain(HINSTANCE hInst, HINSTANCE, LPWSTR, int nShow) {
    SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);

    INITCOMMONCONTROLSEX icc{sizeof(icc), ICC_STANDARD_CLASSES};
    InitCommonControlsEx(&icc);

    WNDCLASSEXW wc{};
    wc.cbSize = sizeof(wc);
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = MainWndProc;
    wc.hInstance = hInst;
    wc.hCursor = LoadCursorW(nullptr, IDC_ARROW);
    wc.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1);
    wc.lpszClassName = L"ExoConsole";
    wc.hIcon = LoadIconW(hInst, MAKEINTRESOURCEW(101));
    RegisterClassExW(&wc);

    HWND hwnd = CreateWindowExW(0, L"ExoConsole", L"Console",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 980, 560,
        nullptr, nullptr, hInst, nullptr);

    if (!hwnd) return 1;

    ShowWindow(hwnd, nShow);
    UpdateWindow(hwnd);

    MSG msg;
    while (GetMessageW(&msg, nullptr, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }

    return static_cast<int>(msg.wParam);
}
