# The suite's warning policy, in one file, included by every entry point that
# configures a binary.
#
# Why a function rather than `add_compile_options` at the root: a dependency
# fetched by `FetchContent` is added as an ordinary subdirectory of this same
# build, so anything set at the root reaches it too. lunasvg carries 93
# warnings of its own and is not ours to fix, and a policy that has to list its
# exemptions is a policy that goes stale the first time somebody adds a
# dependency without reading this file.
#
# So the policy is applied per target, by name, to OUR targets only. A
# dependency is exempt because nothing applied it, which is a property of the
# construction rather than of somebody remembering.
#
# Why a FILE rather than a macro at the root: an extension is a standalone
# CMake project with its own `project()` call, and `reskit/Build-Extension.ps1`
# configures it directly with `cmake ..`. The root is never read on that path.
# `cmake/ResoluteLinkPolicy.cmake` carries the same reasoning and D00 T01 §2
# learned it the expensive way.

if(DEFINED RESOLUTE_WARNINGS_POLICY_APPLIED)
    return()
endif()
set(RESOLUTE_WARNINGS_POLICY_APPLIED TRUE)

# Off for a one-off local build that needs to get past an unrelated warning.
# On everywhere that matters, which is what makes it a gate.
option(RESOLUTE_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" ON)

# The level is `-Wall -Wextra`, and that is a measured choice rather than a
# default. D00 T01 §3 measured the tree at this level: 13 warnings in our code,
# all fixed in the same commit, so the gate went on with nothing suppressed.
# Raising it further is a decision that owes its own measurement, because a
# level nobody can reach is a level somebody turns off.
function(resolute_set_warnings target)
    if(NOT TARGET ${target})
        message(FATAL_ERROR "resolute_set_warnings: no such target '${target}'")
    endif()

    if(MSVC)
        set(_flags /W4)
        set(_werror /WX)
    else()
        set(_flags -Wall -Wextra)
        set(_werror -Werror)
    endif()

    if(RESOLUTE_WARNINGS_AS_ERRORS)
        list(APPEND _flags ${_werror})
    endif()

    # PRIVATE: the policy governs how a target compiles its own sources, and
    # must not ride a link dependency into something that did not ask for it.
    target_compile_options(${target} PRIVATE ${_flags})

    # The receipt the completeness check below reads.
    set_property(TARGET ${target} PROPERTY RESOLUTE_WARNINGS_APPLIED TRUE)
endfunction()

# ── Completeness ─────────────────────────────────────────────
#
# Applying the policy per target buys the dependency exemption, and costs the
# thing an `add_compile_options` at the root would have given for free: a new
# target does not inherit the level, so a target added without the call is
# compiled with no warnings at all, silently.
#
# D00 T01 §3 asked for inheritance. This is the stronger property instead: a
# target the project owns cannot MISS the level without the configure failing
# and naming it. Inheritance can be defeated by a target that sets its own
# options; an audit of what actually got applied cannot.
#
# Anything under `_deps` is skipped, which is the same by-construction
# exemption stated once more: a dependency is not ours, so it is neither
# policed nor audited.

function(_resolute_collect_targets dir out_var)
    get_property(_subs DIRECTORY "${dir}" PROPERTY SUBDIRECTORIES)
    get_property(_here DIRECTORY "${dir}" PROPERTY BUILDSYSTEM_TARGETS)
    set(_acc ${_here})
    foreach(_sub IN LISTS _subs)
        # A FetchContent dependency is materialised under the build tree and is
        # not ours to police.
        if(NOT _sub MATCHES "/_deps/")
            _resolute_collect_targets("${_sub}" _sub_targets)
            list(APPEND _acc ${_sub_targets})
        endif()
    endforeach()
    set(${out_var} "${_acc}" PARENT_SCOPE)
endfunction()

function(resolute_assert_warnings_complete)
    _resolute_collect_targets("${CMAKE_CURRENT_SOURCE_DIR}" _targets)

    set(_missing "")
    foreach(_t IN LISTS _targets)
        get_target_property(_type ${_t} TYPE)
        # Only things that compile our sources can carry a warning level.
        if(_type STREQUAL "EXECUTABLE"
           OR _type STREQUAL "STATIC_LIBRARY"
           OR _type STREQUAL "SHARED_LIBRARY"
           OR _type STREQUAL "MODULE_LIBRARY"
           OR _type STREQUAL "OBJECT_LIBRARY")
            get_target_property(_applied ${_t} RESOLUTE_WARNINGS_APPLIED)
            if(NOT _applied)
                list(APPEND _missing ${_t})
            endif()
        endif()
    endforeach()

    if(_missing)
        list(JOIN _missing ", " _names)
        message(FATAL_ERROR
            "resolute_set_warnings() was never called for: ${_names}
"
            "Every target this project owns answers to the warning policy. "
            "Add `resolute_set_warnings(<target>)` beside its add_executable "
            "or add_library. See cmake/ResoluteWarnings.cmake.")
    endif()
endfunction()
