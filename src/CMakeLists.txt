add_executable(ExoSuite WIN32
    main.cpp
    ExoSuite.rc
)

target_compile_options(ExoSuite PRIVATE -municode)
target_link_options(ExoSuite PRIVATE -municode -mwindows)

target_link_libraries(ExoSuite PRIVATE
    ExoUI_static
    comctl32
    dwmapi
    uxtheme
    shlwapi
)
