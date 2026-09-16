#pragma once
// ── Terminal View ───────────────────────────────────────────
// Direct2D monospace cell renderer for the terminal emulator.
// Handles paint, resize, cursor blink, and keyboard input.

#include <windows.h>
#include <d2d1.h>
#include <dwrite.h>
#include <wrl/client.h>
#include "terminal_emulator.h"
#include "pty_session.h"

using Microsoft::WRL::ComPtr;

class TerminalView {
public:
    // Create the terminal view window as a child of parent
    void Create(HWND parent, HINSTANCE hInst, TerminalEmulator* emu, PtySession* pty);

    HWND Handle() const { return m_hwnd; }

    // Layout
    void Resize(int x, int y, int w, int h);

    // Trigger repaint (safe to call from any thread via PostMessage)
    void Invalidate();

    // Cell metrics
    int  ColsForWidth(int pixelWidth) const;
    int  RowsForHeight(int pixelHeight) const;
    float CellWidth()  const { return m_cellW; }
    float CellHeight() const { return m_cellH; }

private:
    HWND m_hwnd   = nullptr;
    HWND m_parent = nullptr;
    TerminalEmulator* m_emu = nullptr;
    PtySession*       m_pty = nullptr;

    // Render target
    ComPtr<ID2D1Factory>          m_d2dFactory;
    ComPtr<ID2D1HwndRenderTarget> m_rt;
    ComPtr<IDWriteFactory>        m_dwriteFactory;
    ComPtr<IDWriteTextFormat>     m_textFormat;

    // Cell metrics (computed from font)
    float m_cellW = 8.0f;
    float m_cellH = 16.0f;
    int   m_dpi = 96;

    // Padding (DPI-scaled)
    float m_padding = 8.0f;
    float Padding() const { return m_padding; }

    // Scroll offset (0 = live view, positive = scrolled up into history)
    int m_scrollOffset = 0;

    // Text selection
    struct CellPos { int row = -1, col = -1; };
    CellPos m_selAnchor;   // where mouse-down started
    CellPos m_selActive;   // where mouse currently is (or was released)
    bool m_selecting = false;
    bool HasSelection() const { return m_selAnchor.row >= 0 && m_selActive.row >= 0; }
    bool IsCellSelected(int row, int col) const;
    void CopySelection();
    void ClearSelection() { m_selAnchor = m_selActive = {-1, -1}; }
    CellPos HitTest(int px, int py) const;

    // Cursor blink
    bool  m_cursorOn = true;
    UINT_PTR m_blinkTimer = 1;

    // Rendering
    void CreateRenderTarget();
    void CreateTextFormat();
    void OnPaint();

    static LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
};
