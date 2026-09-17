cmake_minimum_required(VERSION 3.25)
project(ResoluteUI VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

# ── Sources (shared between static + DLL) ────────────────────
set(RESOLUTEUI_SOURCES
    src/theme.cpp
    src/render.cpp
    src/typography.cpp
    src/icons.cpp
    src/animation.cpp
    src/controls/sidebar.cpp
    src/controls/toolbar.cpp
    src/controls/popupmenu.cpp
    src/controls/statusbar.cpp
    src/controls/contentview.cpp
    src/controls/listview.cpp
)

set(RESOLUTEUI_LIBS comctl32 dwmapi d2d1 dwrite ole32 msimg32)

# ── Static lib (for Resolute.exe — no DLL dependency) ────────
add_library(ResoluteUI_static STATIC ${RESOLUTEUI_SOURCES})
target_include_directories(ResoluteUI_static PUBLIC include)
target_compile_definitions(ResoluteUI_static PUBLIC RESOLUTEUI_STATIC)
# The static UI library is what the single-file launcher links, so its icon
# loader must bind Lucide directly rather than reach for a DLL at runtime.
target_compile_definitions(ResoluteUI_static PUBLIC LUCIDE_STATIC)
target_link_libraries(ResoluteUI_static PUBLIC Lucide_static)
target_link_libraries(ResoluteUI_static PUBLIC ${RESOLUTEUI_LIBS})

# ── Shared DLL (for extensions in System/) ───────────────────
# The SHARED ResoluteUI target was removed 2026-09-17 by D00 T01 §2.
#
# It had no consumer. The launcher links ResoluteUI_static and extensions/
# RegStudio links only Win32 libraries, checked by search. It could not gain
# one either: AGENTS.md states a tool may never depend at runtime on another
# tool, on the launcher, or on a suite-wide file, which is exactly what a
# shared ResoluteUI.dll would be. Building and shipping it was 898,048 bytes
# of the release set that nothing loaded.
#
# Reversing this is cheap: git history has the target, and export.h keeps its
# dllexport/dllimport branches so a future DLL build needs no source change.
