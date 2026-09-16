#pragma once
// ── Terminal Emulator ───────────────────────────────────────
// Wraps libvterm to parse VT escape sequences into a cell grid.
// Provides read-only access to cell state for the renderer.

#include <vterm.h>
#include <windows.h>
#include <d2d1.h>
#include <mutex>
#include <functional>
#include <vector>
#include <deque>

struct TermCell {
    wchar_t ch = L' ';
    D2D1_COLOR_F fg = {1.0f, 1.0f, 1.0f, 1.0f};
    D2D1_COLOR_F bg = {0.0f, 0.0f, 0.0f, 0.0f};  // alpha 0 = default bg
    bool bold      = false;
    bool italic    = false;
    bool underline = false;
    bool reverse   = false;
};

class TerminalEmulator {
public:
    ~TerminalEmulator() { Destroy(); }

    bool Init(int cols, int rows);
    void Destroy();

    // Feed raw bytes from ConPTY (thread-safe — locks internally)
    void Feed(const char* data, size_t len);

    // Read cell state for rendering (lock externally via Lock/Unlock)
    TermCell GetCell(int row, int col) const;
    int Cols() const { return m_cols; }
    int Rows() const { return m_rows; }

    // Cursor position
    int CursorRow() const { return m_cursorRow; }
    int CursorCol() const { return m_cursorCol; }
    bool CursorVisible() const { return m_cursorVisible; }

    // Resize the terminal grid
    void Resize(int cols, int rows);

    // Threading: lock for batch cell reads during paint
    void Lock()   { m_mutex.lock(); }
    void Unlock() { m_mutex.unlock(); }

    // Scrollback
    int ScrollbackCount() const { return static_cast<int>(m_scrollback.size()); }
    TermCell GetScrollbackCell(int lineFromTop, int col) const;

    // Callback: fired when screen content changes (called under lock)
    std::function<void()> OnDamage;

    // Callback: forward libvterm's VT responses (e.g. DSR) back to ConPTY
    std::function<void(const char*, size_t)> OnOutput;

private:
    VTerm*       m_vt     = nullptr;
    VTermScreen* m_screen = nullptr;
    int m_cols = 80;
    int m_rows = 24;
    int m_cursorRow = 0;
    int m_cursorCol = 0;
    bool m_cursorVisible = true;

    mutable std::mutex m_mutex;

    // Scrollback buffer (newest at back)
    static constexpr int MAX_SCROLLBACK = 5000;
    struct ScrollLine { std::vector<TermCell> cells; };
    std::deque<ScrollLine> m_scrollback;

    // libvterm callbacks
    static int OnDamageCallback(VTermRect rect, void* user);
    static int OnMoveRectCallback(VTermRect dest, VTermRect src, void* user);
    static int OnMoveCursorCallback(VTermPos pos, VTermPos oldpos, int visible, void* user);
    static int OnSetTermPropCallback(VTermProp prop, VTermValue* val, void* user);
    static int OnSbPushLine(int cols, const VTermScreenCell* cells, void* user);
    static int OnSbPopLine(int cols, VTermScreenCell* cells, void* user);

    static D2D1_COLOR_F VTermColorToD2D(VTermColor c);
};
