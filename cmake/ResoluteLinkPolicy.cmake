# The suite's link policy, in one file, included by every entry point that
# configures a binary.
#
# Why this exists rather than `add_link_options` at the root: an extension is a
# standalone CMake project with its own `project()` call, and
# `scripts/build.ps1` configures it directly from inside its own directory.
# The root `CMakeLists.txt` is never read on that path, so anything set only at
# the root does not reach it.
#
# D00 T01 §2 learned this the expensive way. The flags were moved to the root
# and deleted from `extensions/RegStudio`, on the reasoning that the root would
# supply them. For the suite build that was true. For the standalone extension
# build it was not, and the independent review caught it by actually building
# RegStudio that way and finding fresh `libc++.dll` and `libunwind.dll` imports:
# an executable that would not start on a machine without them, which is exactly
# what `AGENTS.md` forbids.
#
# So "set once" has to mean one FILE that every entry point includes, not one
# CMakeLists that only one entry point reads.

if(DEFINED RESOLUTE_LINK_POLICY_APPLIED)
    return()
endif()
set(RESOLUTE_LINK_POLICY_APPLIED TRUE)

# Bake libc++, libunwind and pthreads into every binary, so no llvm-mingw
# runtime DLL ships beside anything. Every tool is distributed on its own and
# may not depend at runtime on a suite-wide file.
add_link_options(-static -static-libgcc -static-libstdc++)

# ThinLTO for Release, stated explicitly rather than inherited from
# CMAKE_INTERPROCEDURAL_OPTIMIZATION. CMake translates that switch to
# -flto=thin for Clang today, which the 2026-11-09 compile databases
# confirm, but the translation is CMake's choice, not this project's:
# a CMake change could silently move a release build to full LTO, whose
# monolithic link is the largest memory consumer in the build. ThinLTO
# parallelises the link backends and keeps the peak down. MSVC is left
# alone: it has no -flto, and its /GL is a separate decision.
if(NOT MSVC)
    add_compile_options($<$<CONFIG:Release>:-flto=thin>)
    add_link_options($<$<CONFIG:Release>:-flto=thin>)
endif()

# Reproducible binaries (D07 T01 §3, decided 2026-11-09): the same
# source must produce the same bytes, so a signed release can be
# independently confirmed against its tag. The PE timestamp is the
# linker-inserted wall clock; embedded absolute source paths are the
# other half. Measured: without these, Resolute.exe differed across
# two consecutive clean relinks at identical size; with them, the
# hashes match. scripts/conformance-check.py --repro-check proves it
# by building twice and comparing.
add_link_options(-Wl,--no-insert-timestamp)
get_filename_component(_resolute_repo_root "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
add_compile_options(-ffile-prefix-map=${_resolute_repo_root}=.)
