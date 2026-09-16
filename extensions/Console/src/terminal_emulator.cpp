#include "terminal_emulator.h"
#include <cstring>

// ── Color Conversion ────────────────────────────────────────
D2D1_COLOR_F TerminalEmulator::VTermColorToD2D(VTermColor c) {
    // Ensure color is RGB (convert indexed → RGB if needed)
    // Note: vterm_screen_convert_color_to_rgb requires the screen,
    // but we handle it in GetCell where screen is available.
    if (VTERM_COLOR_IS_RGB(&c)) {
        return D2D1::ColorF(
            c.rgb.red / 255.0f,
            c.rgb.green / 255.0f,
            c.rgb.blue / 255.0f,
            1.0f);
    }
    // Fallback: white for fg, transparent for bg
    return D2D1::ColorF(1.0f, 1.0f, 1.0f, 1.0f);
}

// ── Init ────────────────────────────────────────────────────
bool TerminalEmulator::Init(int cols, int rows) {
    m_cols = cols;
    m_rows = rows;

    m_vt = vterm_new(rows, cols);
    if (!m_vt) return false;

    vterm_set_utf8(m_vt, 1);

    // Get the screen layer
    m_screen = vterm_obtain_screen(m_vt);

    // Set up screen callbacks for damage tracking
    static VTermScreenCallbacks cbs{};
    cbs.damage      = OnDamageCallback;
    cbs.moverect    = OnMoveRectCallback;
    cbs.movecursor  = OnMoveCursorCallback;
    cbs.settermprop = OnSetTermPropCallback;
    cbs.sb_pushline = OnSbPushLine;
    cbs.sb_popline  = OnSbPopLine;
    vterm_screen_set_callbacks(m_screen, &cbs, this);

    // Enable alternate screen (for vim, htop, etc.)
    vterm_screen_enable_altscreen(m_screen, 1);

    // Reset the screen state
    vterm_screen_reset(m_screen, 1);

    return true;
}

// ── Destroy ─────────────────────────────────────────────────
void TerminalEmulator::Destroy() {
    if (m_vt) {
        vterm_free(m_vt);
        m_vt = nullptr;
        m_screen = nullptr;
    }
}

// ── Feed (thread-safe) ──────────────────────────────────────
void TerminalEmulator::Feed(const char* data, size_t len) {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_vt) return;
    vterm_input_write(m_vt, data, len);
}

// ── GetCell ─────────────────────────────────────────────────
TermCell TerminalEmulator::GetCell(int row, int col) const {
    TermCell cell{};
    if (!m_screen || row < 0 || row >= m_rows || col < 0 || col >= m_cols)
        return cell;

    VTermPos pos{row, col};
    VTermScreenCell vcell{};
    vterm_screen_get_cell(m_screen, pos, &vcell);

    // Character — take first codepoint
    if (vcell.chars[0] != 0) {
        // Convert UCS-4 to wchar_t (BMP only for now)
        cell.ch = static_cast<wchar_t>(vcell.chars[0]);
    }

    // Convert indexed colors to RGB
    VTermColor fg = vcell.fg, bg = vcell.bg;
    vterm_screen_convert_color_to_rgb(m_screen, &fg);
    vterm_screen_convert_color_to_rgb(m_screen, &bg);

    cell.fg = VTermColorToD2D(fg);

    // Only set bg if it's not the default (alpha 0 = use default bg)
    if (VTERM_COLOR_IS_DEFAULT_BG(&vcell.bg)) {
        cell.bg = D2D1::ColorF(0, 0, 0, 0);
    } else {
        cell.bg = VTermColorToD2D(bg);
    }

    // Attributes
    cell.bold      = (vcell.attrs.bold != 0);
    cell.italic    = (vcell.attrs.italic != 0);
    cell.underline = (vcell.attrs.underline != 0);
    cell.reverse   = (vcell.attrs.reverse != 0);

    return cell;
}

// ── Resize ──────────────────────────────────────────────────
void TerminalEmulator::Resize(int cols, int rows) {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_vt) return;
    m_cols = cols;
    m_rows = rows;
    vterm_set_size(m_vt, rows, cols);
}

// ── Callbacks ───────────────────────────────────────────────
int TerminalEmulator::OnDamageCallback(VTermRect, void* user) {
    auto* self = static_cast<TerminalEmulator*>(user);
    if (self->OnDamage) self->OnDamage();
    return 0;
}

int TerminalEmulator::OnMoveRectCallback(VTermRect, VTermRect, void* user) {
    auto* self = static_cast<TerminalEmulator*>(user);
    if (self->OnDamage) self->OnDamage();
    return 0;
}

int TerminalEmulator::OnMoveCursorCallback(VTermPos pos, VTermPos, int visible, void* user) {
    auto* self = static_cast<TerminalEmulator*>(user);
    self->m_cursorRow = pos.row;
    self->m_cursorCol = pos.col;
    // Note: 'visible' is a scroll hint (should terminal scroll to show cursor?),
    // NOT cursor visibility. Visibility is managed by OnSetTermPropCallback.
    (void)visible;
    if (self->OnDamage) self->OnDamage();
    return 0;
}

int TerminalEmulator::OnSetTermPropCallback(VTermProp prop, VTermValue* val, void* user) {
    auto* self = static_cast<TerminalEmulator*>(user);
    if (prop == VTERM_PROP_CURSORVISIBLE) {
        self->m_cursorVisible = val->boolean;
        if (self->OnDamage) self->OnDamage();
    }
    return 0;
}

// ── Scrollback ──────────────────────────────────────────────
int TerminalEmulator::OnSbPushLine(int cols, const VTermScreenCell* cells, void* user) {
    auto* self = static_cast<TerminalEmulator*>(user);
    ScrollLine line;
    line.cells.resize(cols);
    for (int c = 0; c < cols; c++) {
        TermCell& out = line.cells[c];
        out.ch = (cells[c].chars[0] != 0) ? static_cast<wchar_t>(cells[c].chars[0]) : L' ';

        VTermColor fg = cells[c].fg, bg = cells[c].bg;
        if (self->m_screen) {
            vterm_screen_convert_color_to_rgb(self->m_screen, &fg);
            vterm_screen_convert_color_to_rgb(self->m_screen, &bg);
        }
        out.fg = VTermColorToD2D(fg);
        out.bg = VTERM_COLOR_IS_DEFAULT_BG(&cells[c].bg)
            ? D2D1::ColorF(0, 0, 0, 0) : VTermColorToD2D(bg);
        out.bold      = (cells[c].attrs.bold != 0);
        out.italic    = (cells[c].attrs.italic != 0);
        out.underline = (cells[c].attrs.underline != 0);
        out.reverse   = (cells[c].attrs.reverse != 0);
    }
    self->m_scrollback.push_back(std::move(line));
    if (static_cast<int>(self->m_scrollback.size()) > MAX_SCROLLBACK)
        self->m_scrollback.pop_front();
    return 1;
}

int TerminalEmulator::OnSbPopLine(int cols, VTermScreenCell* cells, void* user) {
    auto* self = static_cast<TerminalEmulator*>(user);
    if (self->m_scrollback.empty()) return 0;
    // Pop the most recent scrollback line
    auto& line = self->m_scrollback.back();
    for (int c = 0; c < cols; c++) {
        memset(&cells[c], 0, sizeof(VTermScreenCell));
        if (c < static_cast<int>(line.cells.size())) {
            cells[c].chars[0] = line.cells[c].ch;
            cells[c].width = 1;
        }
    }
    self->m_scrollback.pop_back();
    return 1;
}

TermCell TerminalEmulator::GetScrollbackCell(int lineFromTop, int col) const {
    TermCell cell{};
    if (lineFromTop < 0 || lineFromTop >= static_cast<int>(m_scrollback.size()))
        return cell;
    auto& line = m_scrollback[lineFromTop];
    if (col < 0 || col >= static_cast<int>(line.cells.size()))
        return cell;
    return line.cells[col];
}
