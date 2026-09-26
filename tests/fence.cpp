// The headful fence. D00 T02 §10; the contract is in fence.h.

#include "fence.h"

#include <windows.h>

#include <cstdio>
#include <cstdlib>

namespace fence {

namespace {

Mode  g_mode     = Mode::Skip;
bool  g_open     = false;
DWORD g_baseline = 0;

std::string Env(const char* name) {
    const char* v = std::getenv(name);
    return v ? v : "";
}

DWORD LastInput() {
    LASTINPUTINFO li{};
    li.cbSize = sizeof(li);
    return GetLastInputInfo(&li) ? li.dwTime : 0;
}

std::string Clock(int minuteOfDay) {
    char buf[8];
    std::snprintf(buf, sizeof(buf), "%02d:%02d", minuteOfDay / 60, minuteOfDay % 60);
    return buf;
}

}  // namespace

bool InQuietHours(int minuteOfDay) { return minuteOfDay >= kQuietStart && minuteOfDay < kQuietEnd; }

Verdict Decide(const std::string& headfulEnv, const std::string& idleCollectEnv, int minuteOfDay,
               unsigned long idleMs) {
    if (headfulEnv == "visible") return {Mode::Visible, "visible run requested (RESOLUTE_HEADFUL=visible)"};
    const bool collecting = idleCollectEnv == "1" || InQuietHours(minuteOfDay);
    if (!collecting)
        return {Mode::Skip, "headful: outside the quiet-hours window 02:00-06:50 local (now " + Clock(minuteOfDay) +
                                "); RESOLUTE_HEADFUL=visible runs it on demand"};
    if (idleMs < kCollectIdleMs)
        return {Mode::Skip, "headful: the operator is active (last input " + std::to_string(idleMs / 1000) +
                                " s ago, under the " + std::to_string(kCollectIdleMs / 1000) +
                                " s a collecting case needs); re-queued"};
    if (idleCollectEnv == "1") return {Mode::Collect, "idle collection (RESOLUTE_IDLE_COLLECT=1)"};
    return {Mode::Collect, "quiet hours " + Clock(minuteOfDay)};
}

Verdict Now() {
    SYSTEMTIME st{};
    GetLocalTime(&st);
    const unsigned long idle = GetTickCount() - LastInput();
    return Decide(Env("RESOLUTE_HEADFUL"), Env("RESOLUTE_IDLE_COLLECT"), st.wHour * 60 + st.wMinute, idle);
}

void Open(Mode mode) {
    g_mode     = mode;
    g_open     = mode != Mode::Skip;
    g_baseline = LastInput();
}

void Close() {
    g_mode = Mode::Skip;
    g_open = false;
}

bool Headful() { return g_open; }

bool InputResumed() { return g_open && g_mode == Mode::Collect && LastInput() != g_baseline; }

}  // namespace fence
