// The record the in-context hook sends back to the focus guard. D00 T02 §11.

#pragma once

#include <windows.h>

// The guard's message-only window that receives the records.
inline constexpr const wchar_t* kFocusHookSinkClass = L"ResoluteFocusGuardSink";
// The named mapping, suffixed with the adopted process's id, that holds the
// adopting guard's sink window: the hook reads its own process's entry, so
// two test processes running at once never receive each other's records.
inline constexpr const wchar_t* kFocusHookSinkMapping = L"Local\\ResoluteFocusGuardSink-";
// The mapping's layout: the sink window, then how many records the hook
// could not deliver, which the guard reads when it releases the process.
struct FocusHookSinkBlock {
    ULONG_PTR     sink;
    volatile LONG lost;
};
// The failure channel, independent of the mapping it reports on
// (D00 T02 section 12). The guard marks adoption intent twice: this
// environment variable in its own process, which a child started after
// adoption inherits, and a per-process intent file in the temp directory,
// which covers a child created suspended before adoption. When the hook
// cannot open or map the guard's mapping and intent is marked, it writes a
// per-process failure marker naming the failure ("open" or "map"); the
// guard reads markers at case end and any marker voids the case's proof,
// because a record that never arrived cannot be judged.
inline constexpr const wchar_t* kFocusHookAdoptEnv = L"RESOLUTE_FOCUS_HOOK_ADOPTED";
inline constexpr const wchar_t* kFocusHookIntentPrefix = L"ResoluteFocusHookIntent-";
inline constexpr const wchar_t* kFocusHookFailPrefix = L"ResoluteFocusHookFail-";
inline constexpr const wchar_t* kFocusHookFailMutex = L"Local\\ResoluteFocusHookFail-";

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
