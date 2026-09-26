#pragma once
// ── ResoluteUI Custom Popup Menu (Pure GDI) ──────────────────────
// Custom popup menu with themed GDI rendering.
// No D2D — pure Win32 GDI for reliable short-lived windows.

#include <windows.h>
#include <cstdint>
#include "../export.h"

namespace rui {

// Forward declaration — defined in toolbar.h
struct DropdownChoice;

class RESUI_API PopupMenu {
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

    /// The menu's size at `dpi`, and its items painted into `hdc` (a memory
    /// DC with a bitmap of that size selected) with `hovered` highlighted,
    /// through the same path the window paints with. D00 T02 §9.
    static SIZE Measure(const DropdownChoice* choices, int count, int dpi);
    static void RenderTo(HDC hdc, const DropdownChoice* choices, int count, int dpi, int hovered = -1);

private:
    static LRESULT CALLBACK PopupProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp);
    static bool s_classRegistered;
};

} // namespace rui
