// The headful fence. D00 T02 §10.
//
// A case whose point is a visible window (a modal popup, a capture, a window
// placed on a monitor to prove its DPI) carries the `[headful]` tag and
// opens with RESOLUTE_HEADFUL_GATE(). The tag keeps it out of the default
// run (the test presets exclude the label); the gate is the one decision of
// whether it may take the desktop now:
//
//   RESOLUTE_HEADFUL=visible   the operator asked for a visible run: run
//   RESOLUTE_IDLE_COLLECT=1    the night runner saw the session unlocked and
//                              idle past its threshold: run, and abort on input
//   02:00 to 06:50 local       the quiet-hours window: run, and abort on input
//   otherwise                  skip, printing one `SKIP "<test>" <reason>` line
//
// The SKIP lines are the debt list a stamp records as `Night-owed:`, taken
// from the run's output rather than typed by hand. docs/testing.md states
// the window, the overrides, and the commands.

#pragma once

#include <catch2/catch_test_macros.hpp>
#include <catch2/interfaces/catch_interfaces_capture.hpp>

#include <cstdint>
#include <cstdio>
#include <string>

namespace fence {

// First minute inside the window and first minute after it, local time.
constexpr int kQuietStart = 2 * 60;        // 02:00
constexpr int kQuietEnd   = 6 * 60 + 50;   // 06:50

// Whether a minute of the local day (0..1439) is inside the window.
bool InQuietHours(int minuteOfDay);

enum class Mode : std::uint8_t { Skip, Visible, Collect };

struct Verdict {
    Mode        mode = Mode::Skip;
    std::string reason;  // why it runs, or why it skips
};

// The decision from its inputs, so boundary fixtures can pin it: the two
// override variables' values (empty when unset) and the local minute.
Verdict Decide(const std::string& headfulEnv, const std::string& idleCollectEnv, int minuteOfDay);

// The decision for this process now.
Verdict Now();

// Whether operator input arrived since the gate opened a collecting case
// (Mode::Collect): such a case stops and is re-queued. Always false for a
// visible run the operator asked for, and outside a headful case.
bool InputResumed();

// Called by the gate: records the case's mode and the input baseline.
void Open(Mode mode);
// Called by the focus guard when a case ends.
void Close();
// Whether the running case passed the gate as headful.
bool Headful();

}  // namespace fence

// Opens a headful case, or skips it with its machine-readable SKIP line.
#define RESOLUTE_HEADFUL_GATE()                                                                                  \
    do {                                                                                                         \
        const ::fence::Verdict fenceVerdict_ = ::fence::Now();                                                   \
        if (fenceVerdict_.mode == ::fence::Mode::Skip) {                                                         \
            const std::string fenceLine_ = "SKIP \"" + Catch::getResultCapture().getCurrentTestName() + "\" " +       \
                                           fenceVerdict_.reason;                                                 \
            std::fputs((fenceLine_ + "\n").c_str(), stdout);                                                     \
            std::fflush(stdout);                                                                                 \
            SKIP(fenceVerdict_.reason);                                                                          \
        }                                                                                                        \
        ::fence::Open(fenceVerdict_.mode);                                                                       \
    } while (false)

// Inside a collecting headful case: stop at once when the operator returns,
// leaving the case to be collected again.
#define RESOLUTE_HEADFUL_CHECK_INPUT()                                                                           \
    do {                                                                                                         \
        if (::fence::InputResumed()) {                                                                           \
            std::fputs(("SKIP \"" + Catch::getResultCapture().getCurrentTestName() +                               \
                        "\" operator input resumed; re-queued\n").c_str(), stdout);                               \
            std::fflush(stdout);                                                                                 \
            SKIP("operator input resumed; re-queued");                                                          \
        }                                                                                                        \
    } while (false)
