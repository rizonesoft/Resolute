#pragma once
// ── DPI Scaling Helpers ─────────────────────────────────────

#include <windows.h>
#include "export.h"

namespace exo {

class EXOUI_API Dpi {
public:
    static int Get(HWND hwnd) {
        return static_cast<int>(GetDpiForWindow(hwnd));
    }
    static int Scale(int value, int dpi) {
        return MulDiv(value, dpi, 96);
    }
    static float ScaleF(float value, int dpi) {
        return value * static_cast<float>(dpi) / 96.0f;
    }
};

} // namespace exo
