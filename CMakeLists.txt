cmake_minimum_required(VERSION 3.25)

# Default build type (must be set before project() for CMake 4.x Ninja rules)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

project(Resolute
    VERSION 0.1.0
    DESCRIPTION "Resolute Power Tools — Native Windows system utilities"
    LANGUAGES CXX
)

# ── The SDK ──────────────────────────────────────────────────
# The language standard, the Windows 10 1809 floor, the static-runtime and
# reproducible-build link policy, the job pools, the warning policy, the UI
# library and the icon set all come from Resolute-SDK, which sits at sdk/ at
# the commit sdk.json pins (scripts/sdk.ps1 puts it there, and
# scripts/bootstrap.ps1 runs that first). They lived in this file and under
# shared/ and cmake/ until 2026-11-15, when every tool left for its own
# repository and the shared code went to one all of them pin
# (docs/plans/2026-11-15-app-split.md). src/Resolute.manifest declares the
# same Windows floor to the loader that the SDK sets for the compiler.
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/sdk/cmake/ResoluteSdk.cmake")
    message(FATAL_ERROR "sdk/ is not present. Run: pwsh scripts/bootstrap.ps1")
endif()
include("${CMAKE_SOURCE_DIR}/sdk/cmake/ResoluteSdk.cmake")

# ── Output Configuration ────────────────────────────────────
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_SOURCE_DIR}/Bin/Debug")

# Reference data embedded per tool (D00 T06 §2).
include("${CMAKE_CURRENT_LIST_DIR}/cmake/ResoluteRefdata.cmake")

# ── Subdirectories ───────────────────────────────────────────
resolute_sdk_add_libraries()
add_subdirectory(src)

# ── Tests ────────────────────────────────────────────────────
# D00 T02 §1. On by default: a suite nobody builds is a suite nobody runs, and
# `check-all.ps1` needs it present to gate on it.
option(RESOLUTE_BUILD_TESTS "Build the Catch2 test suite" ON)
if(RESOLUTE_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Last, so every subdirectory has declared its targets: fail the configure if
# any target this project owns never got the warning policy. D00 T01 §3.
resolute_assert_warnings_complete()
