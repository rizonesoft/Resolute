#pragma once
// ── ExoUI Custom Popup Menu (Pure GDI) ──────────────────────
// Custom popup menu with themed GDI rendering.
// No D2D — pure Win32 GDI for reliable short-lived windows.

#include <windows.h>
#include <cstdint>
#include "../export.h"

namespace exo {

// Forward declaration — defined in toolbar.h
struct DropdownChoice;

class EXOUI_API PopupMenu {
public:
    // Instance data stored on the popup window
    struct PopupData {
        const DropdownChoice* choices  = nullptr;
        int         count              = 0;
        int         dpi                = 96;
        int         hovered            = -1;
        WORD        result             = 0;
        bool        dismissed          = false;
        bool        ready              = false;
    };

    /// Show a blocking popup menu and return the selected command ID.
    static WORD Show(HWND parent, POINT screenPt,
                     const DropdownChoice* choices, int count, int dpi);

private:
    static LRESULT CALLBACK PopupProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp);
    static bool s_classRegistered;
};

} // namespace exo
