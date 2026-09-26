# The Catch2 suite. D00 T02 §1.
#
# Catch2 arrives the way D00 T01 §2 settled every dependency: FetchContent,
# pinned to a COMMIT rather than a tag, and no package manager. A tag can be
# repointed at different code while the version string stays the same, and a
# FetchContent build follows it without anything appearing to change.
#
# v3.16.0 is an ANNOTATED tag, so the tag object (fd79eadb) is not the commit.
# The commit below is what that tag resolves to, read from the API rather than
# assumed, because pinning the tag object would fetch nothing usable.

include(FetchContent)

FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        317ac1ed4c0bb6e6b91eafc817e05c488feffcb3  # v3.16.0
    # GIT_SHALLOW off for the same reason lunasvg has it off: a shallow clone
    # fetches a branch tip, and an arbitrary commit need not be reachable from
    # one.
    GIT_SHALLOW    FALSE
)
FetchContent_MakeAvailable(Catch2)

file(GLOB RESOLUTE_TEST_SOURCES CONFIGURE_DEPENDS "*_test.cpp")

add_executable(resolute_tests
    ${RESOLUTE_TEST_SOURCES}
    fixtures/fixtures.cpp
    fixtures/suite_teardown.cpp
    parity/parity.cpp
    # The focus guard, the headful fence, and the entry point that runs the
    # guard around Catch2's session (D00 T02 §10).
    focus_guard.cpp
    fence.cpp
    main.cpp
)

# The disposable fixture store lives under the build directory. CMake
# supplies the path so no absolute path is written into a tracked build
# file, which is what D00 T01 §4 requires. D00 T02 §2.
target_compile_definitions(resolute_tests PRIVATE
    RESOLUTE_FIXTURE_ROOT="${CMAKE_BINARY_DIR}/fixtures"
    # The house-style contract the test asserts against the constants.
    # Supplied by CMake so no absolute path enters a tracked build file.
    RESOLUTE_CONTRACT_PATH="${CMAKE_SOURCE_DIR}/docs/captures/house-style/contract.md"
    # The icon manifest and the root its referrers are relative to.
    # D00 T02 §8.
    RESOLUTE_ICON_MANIFEST="${CMAKE_CURRENT_SOURCE_DIR}/icon_manifest.txt"
    RESOLUTE_SOURCE_ROOT="${CMAKE_SOURCE_DIR}"
    # The rendered-output goldens, and where a failing render writes its
    # actual and diff images. D00 T02 §9.
    RESOLUTE_GOLDEN_DIR="${CMAKE_CURRENT_SOURCE_DIR}/golden"
    RESOLUTE_RENDER_OUT="${CMAKE_BINARY_DIR}/render-out"
    # Each case's window census, the foreground log the gate quotes, and the
    # launcher the headful captures start (D00 T02 §10).
    RESOLUTE_CENSUS_DIR="${CMAKE_BINARY_DIR}/focus-census"
    # Captures land in build scratch, never in the tracked evidence under
    # docs/captures/runs/: publishing one there is a deliberate copy.
    RESOLUTE_CAPTURE_DIR="${CMAKE_BINARY_DIR}/captures"
    RESOLUTE_LAUNCHER="$<TARGET_FILE:Resolute>"
)
target_include_directories(resolute_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Ours, so it answers to the warning policy. Catch2 does not: it is a
# FetchContent dependency and nothing applies the policy to it.
resolute_set_warnings(resolute_tests)

target_link_libraries(resolute_tests PRIVATE
    # Catch2 without its main: tests/main.cpp runs the session inside the
    # focus guard (D00 T02 §10).
    Catch2::Catch2
    ResoluteUI_static
    Lucide_static
    # WIC and COM, for the offscreen renders and their PNG goldens (D00 T02 §9).
    windowscodecs
    ole32
    # GetDpiForMonitor, for the census's per-monitor DPI (D00 T02 §10).
    shcore
)
# The headful captures start the launcher, so a test build carries it.
add_dependencies(resolute_tests Resolute)

# -municode, and NOT -mwindows.
#
# ResoluteUI_static defines UNICODE and _UNICODE PUBLICLY, so Catch2 compiles
# its entry point as `wmain` rather than `main`. Without -municode the CRT
# looks for main or WinMain, finds neither, and pulls mingw's GUI startup stub
# crtexewin.o, which fails with "undefined symbol: WinMain" on a console test
# binary. The launcher sets the same flag at src/CMakeLists.txt for the same
# reason.
#
# -mwindows is deliberately absent: a test runner is a console program and
# needs its output on a console.
target_link_options(resolute_tests PRIVATE -municode)

# Catch2's own CMake helpers, which register each TEST_CASE with ctest
# individually so a failure names the case rather than the executable.
list(APPEND CMAKE_MODULE_PATH ${catch2_SOURCE_DIR}/extras)
include(Catch)
# ADD_TAGS_AS_LABELS carries each TEST_CASE's tags through to ctest as labels,
# so a failure is attributable to a tool without re-running anything:
#   ctest --preset debug -L ui        runs only the UI library's tests
# Catch2's own failure output already carries the expected and actual values;
# this is what makes the TAG visible too, which tests/README.md requires.
#
# SKIP_RETURN_CODE 4 is Catch2's all-skipped exit code, so a headful case the
# fence skips reports as skipped in ctest rather than passed or failed
# (D00 T02 §10).
catch_discover_tests(resolute_tests ADD_TAGS_AS_LABELS PROPERTIES SKIP_RETURN_CODE 4)
