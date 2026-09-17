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
# CURRENT_SOURCE_DIR, not SOURCE_DIR. This extension is built two ways: as a
# standalone project, where the two are the same, and potentially from the root,
# where CMAKE_SOURCE_DIR is the repository root and this would write the
# executable into the repository itself. D00 T01 §4.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)

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
