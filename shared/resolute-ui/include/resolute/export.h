#pragma once
// ── ResoluteUI Export Macro ──────────────────────────────────────

#if defined(RESOLUTEUI_STATIC)
    #define RESUI_API
#elif defined(RESOLUTEUI_BUILD)
    #define RESUI_API __declspec(dllexport)
#else
    #define RESUI_API __declspec(dllimport)
#endif

// ── Custom Messages ────────────────────────────────────────
// Controls send WM_EXOTAB to parent to request Tab focus cycling.
// wp = child HWND requesting, lp = 1 for Shift+Tab (backward), 0 for forward
constexpr unsigned int WM_EXOTAB = 0x8000 + 1;  // WM_APP + 1
