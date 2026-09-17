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
