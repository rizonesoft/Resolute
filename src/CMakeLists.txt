# The copyright year is generated at configure time rather than typed, so a
# binary states the year it was built. Re-run CMake to pick up a new year.
string(TIMESTAMP RESOLUTE_COPYRIGHT_YEAR "%Y")
set(RESOLUTE_RESOURCE_DIR "${CMAKE_SOURCE_DIR}/resources/icons")
set(RESOLUTE_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/Resolute.rc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/Resolute.rc"
    @ONLY
)

add_executable(Resolute WIN32
    main.cpp
    "${CMAKE_CURRENT_BINARY_DIR}/Resolute.rc"
)

# Re-run the resource compile when the manifest changes; the .rc includes it by
# path, so CMake cannot see the dependency on its own.
set_property(SOURCE "${CMAKE_CURRENT_BINARY_DIR}/Resolute.rc"
             APPEND PROPERTY OBJECT_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/Resolute.manifest")

# The generated .rc includes resource.h, which lives beside the source.
target_include_directories(Resolute PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")

target_compile_options(Resolute PRIVATE -municode)
target_link_options(Resolute PRIVATE -municode -mwindows)

resolute_set_warnings(Resolute)

target_link_libraries(Resolute PRIVATE
    ResoluteUI_static
    Lucide_static
    comctl32
    dwmapi
    uxtheme
    shlwapi
    shell32   # was a #pragma comment(lib) in main.cpp, which clang ignores
)
