cmake_minimum_required(VERSION 3.25)
project(Lucide VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

# ── Fetch lunasvg ────────────────────────────────────────────
include(FetchContent)
FetchContent_Declare(
    lunasvg
    GIT_REPOSITORY https://github.com/sammycage/lunasvg.git
    # Pinned by COMMIT, not by tag. D00 T01 §2, 2026-09-17: a tag is a movable
    # reference, so `v3.5.0` can be repointed at different code without the
    # version appearing to change, and a FetchContent build would silently
    # follow it. This is the commit v3.5.0 resolved to when it was pinned.
    GIT_TAG        83c58df8103dc7dca423dfd824992af94d49bed6   # v3.5.0
    # GIT_SHALLOW cannot be used with a commit hash: a shallow clone fetches
    # only the tip of a branch, and an arbitrary commit may not be reachable
    # from it.
    GIT_SHALLOW    FALSE
)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(LUNASVG_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(lunasvg)

# ── Generate embedded icon data ──────────────────────────────
set(ICON_DIR "${CMAKE_CURRENT_SOURCE_DIR}/icons")
set(GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY ${GENERATED_DIR})

file(GLOB SVG_FILES "${ICON_DIR}/*.svg")

# Generate icons_data.h with all SVG content embedded
set(ICON_ENTRIES "")
set(ICON_COUNT 0)
foreach(SVG_FILE ${SVG_FILES})
    get_filename_component(ICON_NAME ${SVG_FILE} NAME_WE)
    file(READ ${SVG_FILE} SVG_CONTENT)
    # Escape for C string
    string(REPLACE "\\" "\\\\" SVG_CONTENT "${SVG_CONTENT}")
    string(REPLACE "\"" "\\\"" SVG_CONTENT "${SVG_CONTENT}")
    string(REPLACE "\n" "\\n" SVG_CONTENT "${SVG_CONTENT}")
    string(REPLACE "\r" "" SVG_CONTENT "${SVG_CONTENT}")
    string(APPEND ICON_ENTRIES "    { \"${ICON_NAME}\", \"${SVG_CONTENT}\" },\n")
    math(EXPR ICON_COUNT "${ICON_COUNT} + 1")
endforeach()

file(WRITE "${GENERATED_DIR}/icons_data.h"
"#pragma once\n"
"// Auto-generated — do not edit\n"
"#include <cstdint>\n\n"
"struct IconEntry {\n"
"    const char* name;\n"
"    const char* svg;\n"
"};\n\n"
"inline constexpr int kIconCount = ${ICON_COUNT};\n\n"
"inline constexpr IconEntry kIcons[] = {\n"
"${ICON_ENTRIES}"
"};\n"
)

# ── Static library ───────────────────────────────────────────
# The launcher links this, so the icons are inside the executable and there is
# no DLL to find at runtime. D00 T01 §2: the LoadLibraryW in the icon loader was
# the last thing standing between this build and a single shipped file.
add_library(Lucide_static STATIC
    src/lucide.cpp
)

target_include_directories(Lucide_static
    PUBLIC  include
    PRIVATE ${GENERATED_DIR}
            ${lunasvg_SOURCE_DIR}/include
)

target_link_libraries(Lucide_static PUBLIC lunasvg)

# PUBLIC so every consumer sees the undecorated declarations. PRIVATE here would
# let the library build with no decoration while its callers still saw
# dllimport, which links against an import stub that does not exist.
target_compile_definitions(Lucide_static PUBLIC LUCIDE_STATIC)

# The SHARED Lucide target was removed 2026-09-17 by D00 T01 §2.
#
# Nothing linked it and nothing loaded it once the launcher bound
# Lucide_static directly. It was 1,717,760 bytes of the release set, and the
# LoadLibraryW that reached for it was the single thing keeping this build
# from shipping as one file.
#
# lucide.h keeps its dllexport/dllimport branches, so restoring a DLL build
# is a CMake change with no source change.
