// The focus guard. D00 T02 §10; the contract is in focus_guard.h.

#include "focus_guard.h"

#include "fence.h"

#include <catch2/catch_test_case_info.hpp>
#include <catch2/reporters/catch_reporter_event_listener.hpp>
#include <catch2/reporters/catch_reporter_registrars.hpp>

#include <shellscalingapi.h>
#include <tlhelp32.h>

#include <algorithm>
#include <cctype>
#include <cstdio>
#include <filesystem>
#include <fstream>
#include <map>
#include <mutex>
#include <set>
#include <thread>

namespace focusguard {

namespace {

constexpr UINT kFlush = WM_APP + 1;

std::mutex          g_lock;
std::vector<Event>  g_events;
std::set<DWORD>     g_pids;
DWORD               g_threadId = 0;
HANDLE              g_thread   = nullptr;
HANDLE              g_ready    = nullptr;
HANDLE              g_flushed  = nullptr;  // set by the observer at each flush marker
int                 g_violations = 0;

// Windows the system creates for a thread or for COM, not for a test: they
// outlive any case by design and are never shown.
bool SystemClass(const std::wstring& cls) {
    static const wchar_t* const kSystem[] = {L"IME", L"MSCTFIME UI", L"OleMainThreadWndClass", L"CicMarshalWndClass"};
    return std::any_of(std::begin(kSystem), std::end(kSystem), [&](const wchar_t* c) { return cls == c; });
}

HWINEVENTHOOK g_ownForeground = nullptr;
HWINEVENTHOOK g_ownShow       = nullptr;
bool          g_adoptedHooks  = false;  // the observer thread's hooks installed

bool Owned(HWND hwnd) {
    DWORD pid = 0;
    GetWindowThreadProcessId(hwnd, &pid);
    std::lock_guard<std::mutex> hold(g_lock);
    return g_pids.count(pid) != 0;
}

void Record(DWORD event, WindowRecord window) {
    Event e;
    e.kind   = event == EVENT_SYSTEM_FOREGROUND ? Event::Kind::Foreground : Event::Kind::Shown;
    e.window = std::move(window);
    // A child shown under a hidden parent is not on the desktop.
    if (e.kind == Event::Kind::Shown && !e.window.visible) return;
    std::lock_guard<std::mutex> hold(g_lock);
    g_events.push_back(std::move(e));
}

// This process's windows, in context: the hook runs on the thread raising
// the event, before the call that raised it returns, so a window shown and
// hidden or destroyed at once is judged as it was, not as it is later.
void CALLBACK OnOwnEvent(HWINEVENTHOOK, DWORD event, HWND hwnd, LONG idObject, LONG idChild, DWORD, DWORD) {
    if (!hwnd || idObject != OBJID_WINDOW || idChild != CHILDID_SELF) return;
    Record(event, Describe(hwnd));
}

// The adopted processes' threads, as last seen: a thread that raised a show
// and exited before the show was delivered still resolves to its process.
std::map<DWORD, DWORD> g_threadOwner;

// Records every thread of every adopted process. Taken when a process is
// adopted, at every drain, and every 100 ms on the observer thread while any
// process is adopted, so only a thread born and gone inside one such gap,
// having shown a window, escapes attribution.
void SnapshotThreads() {
    std::set<DWORD> pids;
    {
        std::lock_guard<std::mutex> hold(g_lock);
        pids = g_pids;
    }
    pids.erase(GetCurrentProcessId());
    if (pids.empty()) return;
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
    if (snap == INVALID_HANDLE_VALUE) return;
    THREADENTRY32 te{};
    te.dwSize = sizeof(te);
    for (BOOL ok = Thread32First(snap, &te); ok; ok = Thread32Next(snap, &te)) {
        if (pids.count(te.th32OwnerProcessID) == 0) continue;
        std::lock_guard<std::mutex> hold(g_lock);
        g_threadOwner[te.th32ThreadID] = te.th32OwnerProcessID;
    }
    CloseHandle(snap);
}

DWORD PidOfThread(DWORD threadId) {
    HANDLE thread = OpenThread(THREAD_QUERY_LIMITED_INFORMATION, FALSE, threadId);
    if (thread) {
        const DWORD pid = GetProcessIdOfThread(thread);
        CloseHandle(thread);
        if (pid) return pid;
    }
    std::lock_guard<std::mutex> hold(g_lock);
    const auto it = g_threadOwner.find(threadId);
    return it == g_threadOwner.end() ? 0 : it->second;
}

// An adopted process's windows (the launcher a case starts), out of
// context: ownership comes from the thread that raised the event, which
// outlives its windows, and a window gone before delivery is still
// recorded, as shown somewhere nobody measured.
void CALLBACK OnAdoptedEvent(HWINEVENTHOOK, DWORD event, HWND hwnd, LONG idObject, LONG idChild, DWORD threadId,
                             DWORD) {
    if (!hwnd || idObject != OBJID_WINDOW || idChild != CHILDID_SELF) return;
    const DWORD pid = PidOfThread(threadId);
    if (pid == 0 || pid == GetCurrentProcessId()) return;  // the in-context hook has this process
    {
        std::lock_guard<std::mutex> hold(g_lock);
        if (g_pids.count(pid) == 0) return;
    }
    // Every show is kept, whatever the window's visibility by delivery: a
    // window shown and hidden again still went on the desktop, and its
    // rectangle still says where. One gone altogether cannot be measured,
    // and is kept as that.
    WindowRecord w;
    if (IsWindow(hwnd)) {
        w = Describe(hwnd);
    } else {
        w.hwnd = hwnd;
        w.pid  = pid;
        w.cls  = L"(gone before it was measured)";
    }
    w.visible = true;
    Record(event, std::move(w));
}

DWORD WINAPI Observe(LPVOID) {
    MSG msg;
    PeekMessageW(&msg, nullptr, WM_USER, WM_USER, PM_NOREMOVE);  // make the queue
    HWINEVENTHOOK fg   = SetWinEventHook(EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND, nullptr, OnAdoptedEvent, 0,
                                         0, WINEVENT_OUTOFCONTEXT);
    HWINEVENTHOOK show = SetWinEventHook(EVENT_OBJECT_SHOW, EVENT_OBJECT_SHOW, nullptr, OnAdoptedEvent, 0, 0,
                                         WINEVENT_OUTOFCONTEXT);
    g_adoptedHooks = fg != nullptr && show != nullptr;
    const UINT_PTR snapshots = SetTimer(nullptr, 0, 100, nullptr);
    SetEvent(g_ready);
    while (GetMessageW(&msg, nullptr, 0, 0) > 0) {
        if (msg.message == kFlush) SetEvent(g_flushed);
        if (msg.message == WM_TIMER && msg.wParam == snapshots) SnapshotThreads();
        DispatchMessageW(&msg);
    }
    KillTimer(nullptr, snapshots);
    if (fg) UnhookWinEvent(fg);
    if (show) UnhookWinEvent(show);
    return 0;
}

std::string Narrow(const std::wstring& w) {
    std::string s;
    for (wchar_t c : w) s += (c < 128) ? static_cast<char>(c) : '?';
    return s;
}

std::string Line(const WindowRecord& r) {
    char buf[320];
    std::snprintf(buf, sizeof(buf), "hwnd=%p pid=%lu class=%s visible=%d iconic=%d rect=%ld,%ld,%ld,%ld monitor=%s dpi=%u",
                  static_cast<void*>(r.hwnd), r.pid, Narrow(r.cls).c_str(), r.visible ? 1 : 0, r.iconic ? 1 : 0,
                  r.rect.left, r.rect.top, r.rect.right, r.rect.bottom, Narrow(r.monitor).c_str(), r.dpi);
    return buf;
}

std::vector<WindowRecord>* g_collecting = nullptr;  // the census being taken

BOOL CALLBACK Collect(HWND hwnd, LPARAM) {
    if (Owned(hwnd)) g_collecting->push_back(Describe(hwnd));
    return TRUE;
}

std::wstring PrimaryName() {
    HMONITOR primary = MonitorFromPoint(POINT{0, 0}, MONITOR_DEFAULTTOPRIMARY);
    MONITORINFOEXW mi{};
    mi.cbSize = sizeof(mi);
    GetMonitorInfoW(primary, &mi);
    return mi.szDevice;
}

// Whether a shown window honours the case's placement intent.
bool Placed(const WindowRecord& r, const std::string& place) {
    if (place == "place:primary") return r.monitor == PrimaryName();
    if (place.rfind("place:dpi", 0) == 0) return std::to_string(r.dpi) == place.substr(9);
    return false;
}

}  // namespace

WindowRecord Describe(HWND hwnd) {
    WindowRecord r;
    r.hwnd = hwnd;
    GetWindowThreadProcessId(hwnd, &r.pid);
    wchar_t cls[128] = {};
    GetClassNameW(hwnd, cls, 128);
    r.cls     = cls;
    r.visible = IsWindowVisible(hwnd) != FALSE;
    r.iconic  = IsIconic(hwnd) != FALSE;
    GetWindowRect(hwnd, &r.rect);
    HMONITOR hm = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
    MONITORINFOEXW mi{};
    mi.cbSize = sizeof(mi);
    if (GetMonitorInfoW(hm, &mi)) r.monitor = mi.szDevice;
    r.dpi = MonitorDpi(hm);
    return r;
}

UINT MonitorDpi(HMONITOR monitor) {
    UINT x = 0, y = 0;
    return SUCCEEDED(GetDpiForMonitor(monitor, MDT_EFFECTIVE_DPI, &x, &y)) ? x : 0;
}

HMONITOR MonitorWithDpi(UINT dpi) {
    static UINT     wanted = 0;
    static HMONITOR found  = nullptr;
    wanted = dpi;
    found  = nullptr;
    EnumDisplayMonitors(
        nullptr, nullptr,
        [](HMONITOR hm, HDC, LPRECT, LPARAM) -> BOOL {
            if (MonitorDpi(hm) != wanted) return TRUE;
            found = hm;
            return FALSE;
        },
        0);
    return found;
}

void Start() {
    if (g_thread) return;
    {
        std::lock_guard<std::mutex> hold(g_lock);
        g_pids.insert(GetCurrentProcessId());
    }
    g_ready   = CreateEventW(nullptr, TRUE, FALSE, nullptr);
    g_flushed = CreateEventW(nullptr, TRUE, FALSE, nullptr);
    g_thread = CreateThread(nullptr, 0, Observe, nullptr, 0, &g_threadId);
    WaitForSingleObject(g_ready, 5000);
    const DWORD self = GetCurrentProcessId();
    // In-context hooks need a module even when, as here, the callback lives
    // in the executable and only this process raises the events.
    HMODULE module = GetModuleHandleW(nullptr);
    g_ownForeground  = SetWinEventHook(EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND, module, OnOwnEvent, self, 0,
                                       WINEVENT_INCONTEXT);
    g_ownShow = SetWinEventHook(EVENT_OBJECT_SHOW, EVENT_OBJECT_SHOW, module, OnOwnEvent, self, 0, WINEVENT_INCONTEXT);
    // A guard without its hooks sees nothing and would pass every case: that
    // fails the run instead (the first in-context attempt, without a module,
    // installed nothing and said nothing).
    if (!g_ownForeground || !g_ownShow || !g_adoptedHooks) {
        std::printf("FOCUS-VIOLATION the focus guard could not install its hooks (error %lu)\n", GetLastError());
        std::fflush(stdout);
        ++g_violations;
    }
}

void Stop() {
    if (g_ownForeground) UnhookWinEvent(g_ownForeground);
    if (g_ownShow) UnhookWinEvent(g_ownShow);
    g_ownForeground = g_ownShow = nullptr;
    if (!g_thread) return;
    PostThreadMessageW(g_threadId, WM_QUIT, 0, 0);
    WaitForSingleObject(g_thread, 5000);
    CloseHandle(g_thread);
    CloseHandle(g_ready);
    CloseHandle(g_flushed);
    g_thread = nullptr;
}

void AdoptProcess(DWORD pid) {
    {
        std::lock_guard<std::mutex> hold(g_lock);
        g_pids.insert(pid);
    }
    SnapshotThreads();
}

std::vector<Event> Drain() {
    SnapshotThreads();
    if (g_thread) {
        // Out-of-context events reach the observer's queue asynchronously:
        // give them a moment, then post a marker behind them and wait for it.
        Sleep(50);
        ResetEvent(g_flushed);
        if (PostThreadMessageW(g_threadId, kFlush, 0, 0)) WaitForSingleObject(g_flushed, 2000);
    }
    std::lock_guard<std::mutex> hold(g_lock);
    std::vector<Event> out;
    out.swap(g_events);
    return out;
}

std::vector<WindowRecord> Census() {
    std::vector<WindowRecord> out;
    g_collecting = &out;
    EnumWindows(Collect, 0);
    g_collecting = nullptr;
    return out;
}

int Violations() { return g_violations; }

std::vector<std::string> Check(const std::string& testName, bool headful, const std::string& placeTag,
                               const std::vector<HWND>& before, const std::vector<Event>& events,
                               const std::vector<WindowRecord>& census, HWND capture) {
    std::vector<std::string> bad;
    auto say = [&](const std::string& what) { bad.push_back("FOCUS-VIOLATION " + testName + ": " + what); };
    if (headful && placeTag.empty()) say("a headful case declares no [place:...] intent");
    for (const Event& e : events) {
        if (!headful) {
            say(std::string(e.kind == Event::Kind::Foreground ? "took the foreground " : "showed a window ") +
                Line(e.window));
        } else if (e.kind == Event::Kind::Shown && !placeTag.empty() && !Placed(e.window, placeTag)) {
            say("a window is not where [" + placeTag + "] declares: " + Line(e.window));
        }
    }
    for (const WindowRecord& r : census) {
        if (!headful && r.visible) say("a window is visible at the case's end " + Line(r));
        const bool old = std::find(before.begin(), before.end(), r.hwnd) != before.end();
        if (!old && !SystemClass(r.cls)) say("a window was left behind " + Line(r));
    }
    if (capture) say("the mouse capture is still held");
    return bad;
}

namespace {

std::string Sanitize(const std::string& name) {
    std::string s;
    for (char c : name) s += (std::isalnum(static_cast<unsigned char>(c)) ? c : '-');
    return s.substr(0, 120);
}

class Listener : public Catch::EventListenerBase {
public:
    using Catch::EventListenerBase::EventListenerBase;

    void testCaseStarting(const Catch::TestCaseInfo& info) override {
        Drain();
        m_before.clear();
        for (const WindowRecord& r : Census()) m_before.push_back(r.hwnd);
        m_place.clear();
        for (const auto& tag : info.tags) {
            const std::string t(tag.original.data(), tag.original.size());
            if (t.rfind("place:", 0) == 0) m_place = t;
        }
    }

    void testCaseEnded(const Catch::TestCaseStats& stats) override {
        const std::string name = stats.testInfo->name;
        const bool headful = fence::Headful();
        const std::vector<Event> events = Drain();
        const std::vector<WindowRecord> census = Census();
        const std::vector<std::string> bad =
            Check(name, headful, m_place, m_before, events, census, GetCapture());
        fence::Close();
        {
        std::lock_guard<std::mutex> hold(g_lock);
        g_pids.clear();
        g_pids.insert(GetCurrentProcessId());
        g_threadOwner.clear();
        }
        int visible = 0, foreground = 0;
        for (const Event& e : events) (e.kind == Event::Kind::Foreground ? foreground : visible)++;
        const std::filesystem::path dir(RESOLUTE_CENSUS_DIR);
        std::error_code ec;
        std::filesystem::create_directories(dir, ec);
        std::ofstream log(dir / (Sanitize(name) + ".log"), std::ios::trunc);
        log << "CASE " << name << " tier=" << (headful ? "headful" : "default") << " place=" << m_place << "\n";
        for (const Event& e : events)
            log << (e.kind == Event::Kind::Foreground ? "FOREGROUND " : "SHOWN ") << Line(e.window) << "\n";
        for (const WindowRecord& r : census) log << "CENSUS " << Line(r) << "\n";
        for (const std::string& b : bad) log << b << "\n";
        std::printf("CENSUS %s tier=%s shown=%d foreground=%d windows=%zu violations=%zu\n", name.c_str(),
                    headful ? "headful" : "default", visible, foreground, census.size(), bad.size());
        for (const std::string& b : bad) std::printf("%s\n", b.c_str());
        std::fflush(stdout);
        g_violations += static_cast<int>(bad.size());
    }

private:
    std::vector<HWND> m_before;
    std::string       m_place;
};

}  // namespace

}  // namespace focusguard

// Catch2's registrar is a static by design; it runs before main, where an
// exception would end the run anyway.
CATCH_REGISTER_LISTENER(focusguard::Listener)  // NOLINT(bugprone-throwing-static-initialization)
