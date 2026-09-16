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
    GIT_TAG        v3.5.0
    GIT_SHALLOW    TRUE
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

# ── Build DLL ────────────────────────────────────────────────
add_library(Lucide SHARED
    src/lucide.cpp
)

target_include_directories(Lucide
    PUBLIC  include
    PRIVATE ${GENERATED_DIR}
            ${lunasvg_SOURCE_DIR}/include
)

target_link_libraries(Lucide PRIVATE lunasvg)

target_compile_definitions(Lucide PRIVATE LUCIDE_BUILD)

# Output to Bin/Release/System/ or Bin/Debug/System/
set_target_properties(Lucide PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release/System"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_SOURCE_DIR}/Bin/Debug/System"
    LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release/System"
    LIBRARY_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_SOURCE_DIR}/Bin/Debug/System"
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release/System"
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_SOURCE_DIR}/Bin/Debug/System"
    PREFIX ""
)
