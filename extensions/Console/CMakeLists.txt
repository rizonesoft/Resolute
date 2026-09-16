cmake_minimum_required(VERSION 3.25)
project(Console LANGUAGES C CXX RC)

# Output to System/ subfolder alongside ExoUI.dll
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_SOURCE_DIR}/Bin/Release/System")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_SOURCE_DIR}/Bin/Debug/System")

# ── libvterm (vendored, static) ──────────────────────────────
set(LIBVTERM_DIR "${CMAKE_SOURCE_DIR}/deps/libvterm")
add_library(vterm STATIC
    ${LIBVTERM_DIR}/src/encoding.c
    ${LIBVTERM_DIR}/src/keyboard.c
    ${LIBVTERM_DIR}/src/mouse.c
    ${LIBVTERM_DIR}/src/parser.c
    ${LIBVTERM_DIR}/src/pen.c
    ${LIBVTERM_DIR}/src/screen.c
    ${LIBVTERM_DIR}/src/state.c
    ${LIBVTERM_DIR}/src/unicode.c
    ${LIBVTERM_DIR}/src/vterm.c
)
target_include_directories(vterm PUBLIC ${LIBVTERM_DIR}/include)
target_include_directories(vterm PRIVATE ${LIBVTERM_DIR}/src)
# Suppress C warnings in vendored code
target_compile_options(vterm PRIVATE -w)

# ── Console executable ───────────────────────────────────────
add_executable(Console WIN32
    src/main.cpp
    src/pty_session.cpp
    src/terminal_emulator.cpp
    src/terminal_view.cpp
    resources/resource.rc
)

target_compile_options(Console PRIVATE -municode)
target_link_options(Console PRIVATE -municode -mwindows -static)

target_link_libraries(Console PRIVATE
    vterm
    d2d1
    dwrite
    comctl32
    dwmapi
    uxtheme
)

# ── ExoShell — lightweight shell (no cooked-read ConPTY bug) ─
add_executable(ExoShell
    src/exoshell.cpp
)
target_link_options(ExoShell PRIVATE -static)
