#pragma once
// ── ExoUI Export Macro ──────────────────────────────────────

#if defined(EXOUI_STATIC)
    #define EXOUI_API
#elif defined(EXOUI_BUILD)
    #define EXOUI_API __declspec(dllexport)
#else
    #define EXOUI_API __declspec(dllimport)
#endif

// ── Custom Messages ────────────────────────────────────────
// Controls send WM_EXOTAB to parent to request Tab focus cycling.
// wp = child HWND requesting, lp = 1 for Shift+Tab (backward), 0 for forward
constexpr unsigned int WM_EXOTAB = 0x8000 + 1;  // WM_APP + 1
