cmake_minimum_required(VERSION 3.25)
project(RegStudio LANGUAGES CXX RC)

# The suite's link policy. Included by path rather than inherited, because this
# is a standalone project: scripts/build.ps1 configures it directly in this
# directory and never reads the root CMakeLists.txt.
# Removing the flags from here on the assumption the root supplied them added
# libc++.dll and libunwind.dll imports to the standalone build, caught by the
# independent review of 6062ecb.
include("${CMAKE_CURRENT_LIST_DIR}/../../cmake/ResoluteLinkPolicy.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../../cmake/ResoluteWarnings.cmake")

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# CURRENT_BINARY_DIR, so the executable lands in the build tree that produced
# it. Two separate bugs live in the alternatives, and D00 T01 §4 hit both.
#
# CMAKE_SOURCE_DIR is the repository root when this is built from the root
# rather than standalone, which writes the executable into the repository.
#
# CMAKE_CURRENT_SOURCE_DIR fixes that and leaves a worse one: it is the SAME
# directory for every configuration, so a Debug build and a Release build write
# to one path. The independent review reproduced the consequence: build Release,
# build Debug, build Release again, and the Release build is up to date, so the
# Debug executable is still sitting there and gets deployed as Release. The
# binaries were byte-identical.
#
# The build tree is already per-configuration, so deriving the output from it
# makes cross-configuration contamination impossible rather than unlikely.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

# Source files
file(GLOB_RECURSE SOURCES "src/*.cpp")
set(RESOURCES "resources/resource.rc")

add_executable(RegStudio WIN32 ${SOURCES} ${RESOURCES})
resolute_set_warnings(RegStudio)

# Compiler-specific flags
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # MinGW GCC
    target_compile_options(RegStudio PRIVATE -municode -O3)
    # Static flags come from the root CMakeLists.txt, set once for every target.
    target_link_options(RegStudio PRIVATE -municode)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # Clang/LLVM-MinGW
    target_compile_options(RegStudio PRIVATE -O3)
    target_link_options(RegStudio PRIVATE -municode)
    # Define UNICODE for wWinMain entry point
    target_compile_definitions(RegStudio PRIVATE UNICODE _UNICODE)
elseif(MSVC)
    # Visual Studio
    target_compile_options(RegStudio PRIVATE /O2 /W4)
    target_compile_definitions(RegStudio PRIVATE UNICODE _UNICODE)
endif()

# Link Windows System Libraries
target_link_libraries(RegStudio PRIVATE 
    comctl32    # TreeView, ListView
    shlwapi     # Path helpers
    dwmapi      # Dark Mode API
    uxtheme     # Visual Styles (Explorer look)
    advapi32    # Registry API
)

# Standalone project: the root is never read on this path, so the completeness
# check runs here too. D00 T01 §3.
resolute_assert_warnings_complete()
