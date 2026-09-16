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
target_link_libraries(ResoluteUI_static PUBLIC ${RESOLUTEUI_LIBS})

# ── Shared DLL (for extensions in System/) ───────────────────
add_library(ResoluteUI SHARED ${RESOLUTEUI_SOURCES})
target_include_directories(ResoluteUI PUBLIC include)
target_compile_definitions(ResoluteUI PRIVATE RESOLUTEUI_BUILD)
target_link_libraries(ResoluteUI PRIVATE ${RESOLUTEUI_LIBS})

set_target_properties(ResoluteUI PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release/System"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_SOURCE_DIR}/Bin/Debug/System"
    LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release/System"
    LIBRARY_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_SOURCE_DIR}/Bin/Debug/System"
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release/System"
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_SOURCE_DIR}/Bin/Debug/System"
    PREFIX ""
)
