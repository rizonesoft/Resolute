// The record the in-context hook sends back to the focus guard. D00 T02 §11.

#pragma once

#include <windows.h>

// The guard's message-only window that receives the records.
inline constexpr const wchar_t* kFocusHookSinkClass = L"ResoluteFocusGuardSink";
// The named mapping, suffixed with the adopted process's id, that holds the
// adopting guard's sink window: the hook reads its own process's entry, so
// two test processes running at once never receive each other's records.
inline constexpr const wchar_t* kFocusHookSinkMapping = L"Local\\ResoluteFocusGuardSink-";
// WM_COPYDATA's dwData, so the sink accepts nothing else.
inline constexpr ULONG_PTR kFocusHookMagic = 0x52465347;  // "RFSG"

struct FocusHookRecord {
    DWORD     kind;          // EVENT_SYSTEM_FOREGROUND or EVENT_OBJECT_SHOW
    ULONG_PTR hwnd;
    DWORD     pid;
    BOOL      visible;
    BOOL      iconic;
    RECT      rect;
    UINT      dpi;
    wchar_t   cls[64];
    wchar_t   monitor[32];
};
