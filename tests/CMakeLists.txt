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

add_executable(resolute_tests ${RESOLUTE_TEST_SOURCES})

# Ours, so it answers to the warning policy. Catch2 does not: it is a
# FetchContent dependency and nothing applies the policy to it.
resolute_set_warnings(resolute_tests)

target_link_libraries(resolute_tests PRIVATE
    Catch2::Catch2WithMain
    ResoluteUI_static
    Lucide_static
)

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
catch_discover_tests(resolute_tests ADD_TAGS_AS_LABELS)
