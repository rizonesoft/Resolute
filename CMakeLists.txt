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
# The runtime floor is Windows 10 1809 (build 17763), set in ONE place and
# inherited by every target. D00 T01 §1 records why 1809 and not older: dark
# mode, per-monitor DPI v2 as the suite uses it, and Direct2D SVG rendering.
#
# WINVER and _WIN32_WINNT carry only "Windows 10" (0x0A00); the RELEASE is
# carried by NTDDI_VERSION, which was absent until 2026-09-17, so 1809 was
# nowhere expressed. src/Resolute.manifest declares the same floor to the
# loader. Both have to agree or one of them is a comment rather than a contract.
add_compile_definitions(
    WINVER=0x0A00
    _WIN32_WINNT=0x0A00
    NTDDI_VERSION=0x0A000006
    UNICODE
    _UNICODE
    NOMINMAX
    WIN32_LEAN_AND_MEAN
)

# ── Output Configuration ────────────────────────────────────
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_SOURCE_DIR}/Bin/Debug")

# ── Static C++ Runtime ───────────────────────────────────────
# Bake libc++, libunwind, pthreads into every binary so no LLVM-MinGW runtime
# DLLs need to ship alongside the app. Set ONCE here and inherited by every
# target, so no per-tool CMakeLists.txt has to remember: a flag repeated per
# tool is the fourteen-copies failure arriving one tool at a time.
#
# D00 T01 §2, 2026-09-17: only -static was set, and the other two appeared
# solely inside extensions/RegStudio. The import table was already clean, so
# this makes the prescription match what was already true rather than changing
# the output.
add_link_options(-static -static-libgcc -static-libstdc++)

# ── Subdirectories ───────────────────────────────────────────
add_subdirectory(shared/resolute-ui)
add_subdirectory(shared/lucide)
add_subdirectory(src)

# Extensions
# Console retired by D00 T03 §1: off-mission for a repair suite, and the only
# consumer of the deps/libvterm submodule. Source preserved in history at ac97ed7.
# add_subdirectory(extensions/RegStudio)
