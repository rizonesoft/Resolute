// The suite's entry point. D00 T02 §10.
//
// Catch2's own main, plus the two things the focus guard needs around the
// run: per-monitor DPI awareness before any window exists, so the census
// reads each monitor's real DPI, and the observer thread started before the
// first case. A run with a focus violation fails even when every assertion
// passed (exit 5), because a green run that took the operator's desktop is
// not green.

#include "focus_guard.h"

#include <catch2/catch_session.hpp>

#include <windows.h>

// The process entry point: external by definition.
int wmain(int argc, wchar_t* argv[]) {  // NOLINT(misc-use-internal-linkage)
    SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
    focusguard::Start();
    int rc = Catch::Session().run(argc, argv);
    focusguard::Stop();
    // 4 is Catch2's all-skipped code; a violation outranks it and a pass.
    if (focusguard::Violations() > 0 && (rc == 0 || rc == 4)) rc = 5;
    return rc;
}
