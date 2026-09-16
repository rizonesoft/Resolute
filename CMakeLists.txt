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

# ── Standards ────────────────────────────────────────────────
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

# ── Platform Requirements ────────────────────────────────────
# Windows 10+ only (build 10240 = version 1507)
add_compile_definitions(
    WINVER=0x0A00
    _WIN32_WINNT=0x0A00
    UNICODE
    _UNICODE
    NOMINMAX
    WIN32_LEAN_AND_MEAN
)

# ── Output Configuration ────────────────────────────────────
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_SOURCE_DIR}/Bin/Debug")

# ── Static C++ Runtime ───────────────────────────────────────
# Bake libc++, libunwind, pthreads into every binary so no
# LLVM-MinGW runtime DLLs need to ship alongside the app.
add_link_options(-static)

# ── Subdirectories ───────────────────────────────────────────
add_subdirectory(shared/resolute-ui)
add_subdirectory(shared/lucide)
add_subdirectory(src)

# Extensions
# Console retired by D00 T03 §1: off-mission for a repair suite, and the only
# consumer of the deps/libvterm submodule. Source preserved in history at ac97ed7.
# add_subdirectory(extensions/RegStudio)
