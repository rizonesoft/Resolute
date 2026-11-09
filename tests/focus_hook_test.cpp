// The focus hook's failure channel. D00 T02 section 12.
//
// The in-context hook used to drop a record silently when it could not
// open or map the guard's sink mapping, so a transient adopted window
// could escape the placement check. Now the guard marks adoption intent
// (environment plus a per-process intent file) and the hook writes a
// per-process failure marker the guard checks at case end. These drills
// call the hook in this process with each failure arranged, and read the
// marker through the guard's own check.

#include <catch2/catch_test_macros.hpp>
#include <windows.h>

#include <filesystem>
#include <string>
#include <vector>

#include "focus_guard.h"
#include "focus_hook/focus_hook.h"
#include "ui_host.h"

namespace {

using HookProc = void(CALLBACK*)(HWINEVENTHOOK, DWORD, HWND, LONG, LONG, DWORD, DWORD);

HookProc LoadHook() {
    wchar_t exe[MAX_PATH];
    GetModuleFileNameW(nullptr, exe, MAX_PATH);
    const std::filesystem::path dll = std::filesystem::path(exe).parent_path() / "resolute_focus_hook.dll";
    HMODULE mod = LoadLibraryW(dll.c_str());
    if (!mod) return nullptr;
    return reinterpret_cast<HookProc>(GetProcAddress(mod, "ResoluteFocusHook"));  // NOLINT
}

std::wstring MarkerPath() {
    wchar_t dir[MAX_PATH];
    GetTempPathW(MAX_PATH, dir);
    return std::wstring(dir) + kFocusHookFailPrefix + std::to_wstring(GetCurrentProcessId()) + L".txt";
}

void ClearMarker() { DeleteFileW(MarkerPath().c_str()); }

bool MarkerNames(const std::string& kind) {
    const auto failures = focusguard::HookFailures({GetCurrentProcessId()});
    return failures.size() == 1 && failures[0].find(kind) != std::string::npos;
}

}  // namespace

TEST_CASE("A hook that cannot open the mapping marks the failure", "[focus-hook]") {
    HookProc hook = LoadHook();
    REQUIRE(hook != nullptr);
    // The guard marks intent in its own process; a child started after
    // adoption inherits it. No mapping exists for this process.
    SetEnvironmentVariableW(kFocusHookAdoptEnv, L"1");
    ClearMarker();
    uitest::HiddenHost host(L"FocusHookDrill");
    REQUIRE(host.hwnd != nullptr);
    hook(nullptr, EVENT_SYSTEM_FOREGROUND, host.hwnd, OBJID_WINDOW, CHILDID_SELF, 0, 0);
    const bool marked = MarkerNames("open");
    ClearMarker();
    SetEnvironmentVariableW(kFocusHookAdoptEnv, nullptr);
    CHECK(marked);
}

TEST_CASE("A hook that cannot map the sink marks the failure", "[focus-hook]") {
    HookProc hook = LoadHook();
    REQUIRE(hook != nullptr);
    SetEnvironmentVariableW(kFocusHookAdoptEnv, L"1");
    ClearMarker();
    // A read-only mapping: open succeeds, but a read-write view of it
    // cannot be mapped, so the hook's MapViewOfFile fails.
    const std::wstring name = std::wstring(kFocusHookSinkMapping) + std::to_wstring(GetCurrentProcessId());
    HANDLE mapping = CreateFileMappingW(INVALID_HANDLE_VALUE, nullptr, PAGE_READONLY, 0, sizeof(FocusHookSinkBlock),
                                        name.c_str());
    REQUIRE(mapping != nullptr);
    uitest::HiddenHost host(L"FocusHookDrill");
    REQUIRE(host.hwnd != nullptr);
    hook(nullptr, EVENT_SYSTEM_FOREGROUND, host.hwnd, OBJID_WINDOW, CHILDID_SELF, 0, 0);
    CloseHandle(mapping);
    const bool marked = MarkerNames("map");
    ClearMarker();
    SetEnvironmentVariableW(kFocusHookAdoptEnv, nullptr);
    CHECK(marked);
}

TEST_CASE("A dropped event among delivered ones still marks the failure", "[focus-hook]") {
    HookProc hook = LoadHook();
    REQUIRE(hook != nullptr);
    SetEnvironmentVariableW(kFocusHookAdoptEnv, L"1");
    ClearMarker();
    const std::wstring name = std::wstring(kFocusHookSinkMapping) + std::to_wstring(GetCurrentProcessId());
    HANDLE mapping = CreateFileMappingW(INVALID_HANDLE_VALUE, nullptr, PAGE_READWRITE, 0, sizeof(FocusHookSinkBlock),
                                        name.c_str());
    REQUIRE(mapping != nullptr);
    auto* block = static_cast<FocusHookSinkBlock*>(
        MapViewOfFile(mapping, FILE_MAP_READ | FILE_MAP_WRITE, 0, 0, sizeof(FocusHookSinkBlock)));
    REQUIRE(block != nullptr);
    block->sink = 0;  // delivery will fail and count as lost, not as a marker
    block->lost = 0;
    uitest::HiddenHost host(L"FocusHookDrill");
    REQUIRE(host.hwnd != nullptr);
    hook(nullptr, EVENT_SYSTEM_FOREGROUND, host.hwnd, OBJID_WINDOW, CHILDID_SELF, 0, 0);
    const LONG deliveredOrLost = block->lost;
    UnmapViewOfFile(block);
    CloseHandle(mapping);
    // Now the transient failure, after a delivered-or-counted event.
    hook(nullptr, EVENT_SYSTEM_FOREGROUND, host.hwnd, OBJID_WINDOW, CHILDID_SELF, 0, 0);
    const bool marked = MarkerNames("open");
    const auto failures = focusguard::HookFailures({GetCurrentProcessId()});
    ClearMarker();
    SetEnvironmentVariableW(kFocusHookAdoptEnv, nullptr);
    CHECK(deliveredOrLost == 1);
    REQUIRE(marked);
    CHECK(failures.size() == 1);
}

TEST_CASE("When both marker files are blocked the mutex carries the failure", "[focus-hook]") {
    HookProc hook = LoadHook();
    REQUIRE(hook != nullptr);
    using ReleaseProc = void (*)();
    ReleaseProc release = nullptr;
    {
        wchar_t exe[MAX_PATH];
        GetModuleFileNameW(nullptr, exe, MAX_PATH);
        const std::filesystem::path dll = std::filesystem::path(exe).parent_path() / "resolute_focus_hook.dll";
        release = reinterpret_cast<ReleaseProc>(GetProcAddress(LoadLibraryW(dll.c_str()), "ResoluteFocusHookReleaseFailureMutex"));
    }
    REQUIRE(release != nullptr);
    SetEnvironmentVariableW(kFocusHookAdoptEnv, L"1");
    ClearMarker();
    // Block the temp destination and the current-directory destination with
    // directories of the marker's name: neither file can be created.
    const std::filesystem::path tempBlock = MarkerPath();
    wchar_t cwd[MAX_PATH];
    GetCurrentDirectoryW(MAX_PATH, cwd);
    const std::filesystem::path cwdBlock =
        std::filesystem::path(cwd) / (std::wstring(kFocusHookFailPrefix) + std::to_wstring(GetCurrentProcessId()) + L".txt");
    std::filesystem::create_directory(tempBlock);
    std::filesystem::create_directory(cwdBlock);
    uitest::HiddenHost host(L"FocusHookDrill");
    REQUIRE(host.hwnd != nullptr);
    hook(nullptr, EVENT_SYSTEM_FOREGROUND, host.hwnd, OBJID_WINDOW, CHILDID_SELF, 0, 0);
    const auto failures = focusguard::HookFailures({GetCurrentProcessId()});
    release();
    std::filesystem::remove(tempBlock);
    std::filesystem::remove(cwdBlock);
    SetEnvironmentVariableW(kFocusHookAdoptEnv, nullptr);
    REQUIRE(failures.size() == 1);
    CHECK(failures[0].find("mutex") != std::string::npos);
}
