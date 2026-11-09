# Ninja job pools, sized from the machine rather than left at Ninja's
# default of logical cores + 2.
#
# Why pools, and why these numbers: an uncapped Ninja runs every compile
# it can at once, and on a many-core, low-memory machine that is how a
# build dies by paging instead of by error. A compile job here is
# budgeted at roughly 2 GB, which is generous for these translation
# units, so the compile pool is min(cores, RAM / 2 GB). The link pool
# stays at 1 or 2 because a ThinLTO link is the single largest memory
# consumer in the build and two of them at once is the peak that hurts.
#
# One file, included by every entry point (the root and each standalone
# extension), for the reason ResoluteLinkPolicy.cmake records: a pool
# set only at the root never reaches an extension configured directly.
#
# RESOLUTE_COMPILE_JOBS and RESOLUTE_LINK_JOBS in the environment
# override the computed values, because the right cap on a CI runner is
# a fact about that runner, not about this file.

if(DEFINED RESOLUTE_JOB_POOLS_APPLIED)
    return()
endif()
set(RESOLUTE_JOB_POOLS_APPLIED TRUE)

if(NOT DEFINED CMAKE_JOB_POOLS)
    cmake_host_system_information(RESULT _resolute_cores QUERY NUMBER_OF_LOGICAL_CORES)
    cmake_host_system_information(RESULT _resolute_ram_mb QUERY TOTAL_PHYSICAL_MEMORY)
    if(NOT _resolute_cores OR _resolute_cores LESS 1)
        set(_resolute_cores 4)
    endif()
    if(NOT _resolute_ram_mb OR _resolute_ram_mb LESS 1)
        set(_resolute_ram_mb 16384)
    endif()

    math(EXPR _resolute_compile "${_resolute_ram_mb} / 2048")
    if(_resolute_compile LESS 1)
        set(_resolute_compile 1)
    endif()
    if(_resolute_compile GREATER _resolute_cores)
        set(_resolute_compile ${_resolute_cores})
    endif()
    if(DEFINED ENV{RESOLUTE_COMPILE_JOBS} AND NOT "$ENV{RESOLUTE_COMPILE_JOBS}" STREQUAL "")
        set(_resolute_compile "$ENV{RESOLUTE_COMPILE_JOBS}")
    endif()

    if(_resolute_ram_mb GREATER_EQUAL 16384)
        set(_resolute_link 2)
    else()
        set(_resolute_link 1)
    endif()
    if(DEFINED ENV{RESOLUTE_LINK_JOBS} AND NOT "$ENV{RESOLUTE_LINK_JOBS}" STREQUAL "")
        set(_resolute_link "$ENV{RESOLUTE_LINK_JOBS}")
    endif()

    set(CMAKE_JOB_POOLS "compile=${_resolute_compile};link=${_resolute_link}" CACHE STRING "Ninja job pools (ResoluteJobPools)")
    set(CMAKE_JOB_POOL_COMPILE compile CACHE STRING "Ninja compile job pool (ResoluteJobPools)")
    set(CMAKE_JOB_POOL_LINK link CACHE STRING "Ninja link job pool (ResoluteJobPools)")
    message(STATUS "Resolute job pools: compile=${_resolute_compile} link=${_resolute_link} (cores=${_resolute_cores}, RAM=${_resolute_ram_mb} MB)")
endif()
