#[[
    Collection of utilities for working with the rats project model, which is
    basically a bunch of CMake projects organized into a specific folder structure.

    The main feature is the ability to refer to these CMake projects solely by their
    name. So given the following projects:

    packs/core/rats.math
    packs/core/rats.app
    packs/libs/imgui

    another project in this model may link them immediately via

    add_packs(
        TARGET MyTarget
        PACKS_PRIVATE
            rats.math
            rats.app
        PACKS_PUBLIC
            imgui
    )

    given these projects define library targets with their own name. If they don't or
    more advanced manual linking is preferred one may just specify the packs alone

    add_packs(
        PACKS
        rats.math
        rats.app
        imgui
    )

    target_link_libraries(
        MyTarget
        PRIVATE rats.math
        PRIVATE rats.app
        PUBLIC imgui
    )
]]#

### options

option(PACKS_AS_STATIC "When ON, compile rats pack libraries STATIC" ON)
option(PACKS_AS_SHARED "When ON, compile rats pack libraries SHARED" OFF)

if(${PACKS_AS_STATIC} AND ${PACKS_AS_SHARED})
    message(WARNING "Both PACKS_AS_STATIC and PACKS_AS_SHARED are set to true. Using STATIC")
    set(PACKS_AS_STATIC ON)
    set(PACKS_AS_SHARED OFF)
endif()

if(${PACKS_AS_STATIC})
    set(RATS_PACK_TYPE "STATIC" CACHE INTERNAL "" FORCE)
elseif(${PACKS_AS_SHARED})
    set(RATS_PACK_TYPE "SHARED" CACHE INTERNAL "" FORCE)
endif()

### project model preparation

function(get_rats_root currentDir)
    cmake_path(IS_ABSOLUTE currentDir __absCurrDir)
    if(${__absCurrDir} STREQUAL "")
        message(FATAL_ERROR "Cannot find rats root from relative path ${currentDir}")
        return()
    endif()

    cmake_path(GET currentDir ROOT_PATH __currDirRoot)
    if(${currentDir} STREQUAL ${__currDirRoot})
        message(FATAL_ERROR "Cannot find rats root. Rats packs need a common project root")
        return()
    endif()

    set(RATS_TEMP ${currentDir}/.rats CACHE INTERNAL ".rats temporary folder" FORCE)
    if(EXISTS ${RATS_TEMP})
        set(RATS_ROOT ${currentDir} CACHE INTERNAL "rats project root folder" FORCE)
    else()
        cmake_path(GET currentDir PARENT_PATH __nextParentDir)
        get_rats_root(${__nextParentDir})
    endif()
endfunction()

if(NOT ${RATS_INITIALIZED})

    message(STATUS "Looking for rats project root.")
    get_rats_root(${CMAKE_CURRENT_SOURCE_DIR})
    set(RATS_INTERMEDIATE ${RATS_ROOT}/intermediate CACHE INTERNAL "" FORCE)
    set(RATS_CMAKE_BIN ${RATS_INTERMEDIATE}/cmake/bin CACHE INTERNAL "" FORCE)
    set(RATS_BIN ${RATS_ROOT}/bin CACHE INTERNAL "" FORCE)
    message(STATUS "    root folder is            ${RATS_ROOT}")
    message(STATUS "    intermediate folder is    ${RATS_INTERMEDIATE}")
    message(STATUS "    cmake binaries folder is  ${RATS_CMAKE_BIN}")
    message(STATUS "    output binaries folder is ${RATS_BIN}")

    message(STATUS "\nSearching for rats packs\n")

    # Look for all CMake projects in the packs folder
    file(
        GLOB_RECURSE RATS_PACKS
        FOLLOW_SYMLINKS
        LIST_DIRECTORIES false
        CONFIGURE_DEPENDS
        ${RATS_ROOT}/packs/*CMakeLists.txt
    )

    foreach(__ratsPack ${RATS_PACKS})
        cmake_path(GET __ratsPack PARENT_PATH __ratsPackDir)
        cmake_path(GET __ratsPackDir FILENAME __ratsPackName)

        # Ignore current CMake project if it's already inside the subtree of another one.
        # assuming that other one brings that in already, or that it is privately dependent
        # on the current one.
        set(__isInternalListFile FALSE)
        cmake_path(GET __ratsPackDir PARENT_PATH __internalityCheckDir)
        while(NOT ${__internalityCheckDir} STREQUAL ${RATS_ROOT}/packs)
            if (EXISTS ${__internalityCheckDir}/CMakeLists.txt)
                message(DEBUG "Ignoring ${__ratsPack} as it's already in the subtree of other CMake project (${__internalityCheckDir})")
                set(__isInternalListFile TRUE)
                break()
            endif()
            cmake_path(GET __internalityCheckDir PARENT_PATH __internalityCheckDir)
        endwhile()
        if(${__isInternalListFile})
            continue()
        endif()

        # Create variables associated with a unique pack name
        message(DEBUG "Found pack: ${__ratsPackName} (at ${__ratsPackDir})")
        if(${RATS_PACK_${__ratsPackName}_NAME})
            if (NOT ${RATS_PACK_${__ratsPackName}_DIR} STREQUAL ${__ratsPackDir})
                message(WARNING "Conflicting rats packs: ${RATS_PACK_${__ratsPackName}_DIR} vs ${__ratsPackDir}, last one will be used.")
            endif()
        endif()
        set(RATS_PACK_${__ratsPackName}_DIR ${__ratsPackDir} CACHE INTERNAL "" FORCE)
        set(RATS_PACK_${__ratsPackName}_NAME ${__ratsPackName} CACHE INTERNAL "" FORCE)
    endforeach()
endif()
set(RATS_INITIALIZED TRUE CACHE BOOL "Don't set this manually" FORCE)

### Public API

function(add_packs)
    cmake_parse_arguments(PARSE_ARGV 0
        __args
        ""
        "TARGET"
        "PACKS;PACKS_PUBLIC;PACKS_PRIVATE;PACKS_INTERFACE"
    )
    
    function(boilerplate)
        cmake_parse_arguments(PARSE_ARGV 0
            __boilerplate
            ""
            "ACTION"
            "PACKS"
        )
        foreach(__ratsPackName ${__boilerplate_PACKS})
            message(STATUS ${__ratsPackName})
            if(NOT DEFINED RATS_PACK_${__ratsPackName}_NAME)
                message(FATAL_ERROR "Specified rats pack: ${__ratsPackName} doesn't exist")
                return()
            endif()
            add_subdirectory(${RATS_PACK_${__ratsPackName}_DIR} ${RATS_CMAKE_BIN}/${__ratsPackName})
            if(NOT ${__boilerplate_ACTION} STREQUAL "")
                cmake_language(EVAL CODE ${__boilerplate_ACTION})
            endif()
        endforeach()
    endfunction()
    boilerplate(PACKS ${__args_PACKS})
    if(NOT ${__args_TARGET} STREQUAL "")
        boilerplate(
            PACKS ${__args_PACKS_PUBLIC}
            ACTION "target_link_libraries(${__args_TARGET} PUBLIC \${__ratsPackName})"
        )
        boilerplate(
            PACKS ${__args_PACKS_PRIVATE}
            ACTION "target_link_libraries(${__args_TARGET} PRIVATE \${__ratsPackName})"
        )
        boilerplate(
            PACKS ${__args_PACKS_INTERFACE}
            ACTION "target_link_libraries(${__args_TARGET} INTERFACE \${__ratsPackName})"
        )
    endif()
endfunction()