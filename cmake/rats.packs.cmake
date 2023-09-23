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

### project model preparation

function(get_rats_root CURRENT_DIR)
    cmake_path(IS_ABSOLUTE CURRENT_DIR CURRENT_DIR_ABSOLUTE)
    if(NOT ${CURRENT_DIR_ABSOLUTE})
        message(FATAL_ERROR "Cannot find rats root from relative path ${CURRENT_DIR}")
        return()
    endif()

    cmake_path(GET CURRENT_DIR ROOT_PATH CURRENT_DIR_ROOT)
    if(${CURRENT_DIR} STREQUAL ${CURRENT_DIR_ROOT})
        message(FATAL_ERROR "Cannot find rats root. Rats packs need a common project root")
        return()
    endif()

    set(RATS_TEMP ${CURRENT_DIR}/.rats CACHE INTERNAL ".rats temporary folder" FORCE)
    if(EXISTS ${RATS_TEMP})
        set(RATS_ROOT ${CURRENT_DIR} CACHE INTERNAL "rats project root folder" FORCE)
    else()
        cmake_path(GET CURRENT_DIR PARENT_PATH NEXT_PARENT_DIR)
        get_rats_root(${NEXT_PARENT_DIR})
    endif()
endfunction()

if(NOT ${RATS_ROOT})
    message(STATUS "Looking for rats project root.")
    get_rats_root(${CMAKE_CURRENT_LIST_DIR})
    set(RATS_INTERMEDIATE ${RATS_ROOT}/intermediate CACHE INTERNAL "" FORCE)
    set(RATS_CMAKE_BIN ${RATS_INTERMEDIATE}/cmake/bin CACHE INTERNAL "" FORCE)
    set(RATS_BIN ${RATS_ROOT}/bin CACHE INTERNAL "" FORCE)
    message(STATUS "    root folder is            ${RATS_ROOT}")
    message(STATUS "    intermediate folder is    ${RATS_INTERMEDIATE}")
    message(STATUS "    cmake binaries folder is  ${RATS_CMAKE_BIN}")
    message(STATUS "    output binaries folder is ${RATS_BIN}")
endif()

if(NOT ${RATS_PACKS_DISCOVERED})
    message(STATUS "\nSearching for rats packs\n")

    # Look for all CMake projects in the packs folder
    file(
        GLOB_RECURSE RATS_PACKS
        FOLLOW_SYMLINKS
        LIST_DIRECTORIES false
        CONFIGURE_DEPENDS
        ${RATS_ROOT}/packs/*CMakeLists.txt
    )

    foreach(RATS_PACK ${RATS_PACKS})
        cmake_path(GET ${RATS_PACK} PARENT_PATH RATS_PACK_DIR)
        cmake_path(GET ${RATS_PACK_DIR} FILENAME RATS_PACK_NAME)

        # Ignore current CMake project if it's already inside the subtree of another one.
        # assuming that other one brings that in already, or that it is privately dependent
        # on the current one.
        set(IS_INTERNAL_LISTFILE FALSE)
        cmake_path(GET ${RATS_PACK_DIR} PARENT_PATH CURRENT_INTERNALITY_CHECK_DIR)
        while(NOT ${CURRENT_INTERNALITY_CHECK_DIR} STREQUAL ${RATS_ROOT}/packs)
            if (EXISTS ${CURRENT_INTERNALITY_CHECK_DIR}/CMakeLists.txt)
                message(DEBUG "Ignoring ${RATS_PACK} as it's already in the subtree of other CMake project (${CURRENT_INTERNALITY_CHECK_DIR})")
                set(IS_INTERNAL_LISTFILE TRUE PARENT_SCOPE)
                break()
            endif()
            cmake_path(GET ${CURRENT_INTERNALITY_CHECK_DIR} PARENT_PATH CURRENT_INTERNALITY_CHECK_DIR)
        endwhile()
        if(${IS_INTERNAL_LISTFILE})
            continue()
        endif()

        # Create variables associated with a unique pack name
        if(${RATS_PACK_DIR})
            message(DEBUG "Found pack: ${RATS_PACK_NAME} (at ${RATS_PACK_DIR})")
            if(${RATS_PACK_${RATS_PACK_NAME}_NAME})
                message(FATAL_ERROR "Conflicting rats packs: ${RATS_PACK_${RATS_PACK_NAME}_DIR} vs ${RATS_PACK_DIR}")
                return()
            endif()
            set(RATS_PACK_${RATS_PACK_NAME}_DIR ${RATS_PACK_DIR} CACHE INTERNAL "" FORCE)
            set(RATS_PACK_${RATS_PACK_NAME}_NAME ${RATS_PACK_NAME} CACHE INTERNAL "" FORCE)
        endif()
    endforeach()
endif()

set(RATS_PACKS_DISCOVERED TRUE CACHE BOOL "Don't set this manually" FORCE)

### Public API

function(add_packs)
    cmake_parse_arguments(PARSE_ARGV 0
        ADD_PACKS
        "TARGET"
        "PACKS;PACKS_PUBLIC;PACKS_PRIVATE;PACKS_INTERFACE"
        ${ARGN}
    )
    
    function(boilerplate)
        cmake_parse_arguments(PARSE_ARGV 0
            BOILERPLATE
            "ACTION"
            "PACKS"
            ${ARGN}
        )
        foreach(RATS_PACK_NAME ${BOILERPLATE_PACKS})
            if(NOT ${RATS_PACK_${RATS_PACK_NAME}_NAME})
                message(FATAL_ERROR "Specified rats pack: ${RATS_PACK_NAME} doesn't exist")
                return()
            endif()
            add_subdirectory(${RATS_PACK_${RATS_PACK_NAME}_DIR} ${RATS_CMAKE_BIN}/RATS_PACK_NAME)
            if(${BOILERPLATE_ACTION})
                cmake_language(EVAL CODE ${BOILERPLATE_ACTION})
            endif()
        endforeach()
    endfunction()
    boilerplate(PACKS ${ADD_PACKS_PACKS})
    if(${ADD_PACKS_TARGET})
        boilerplate(
            PACKS ${ADD_PACKS_PACKS_PUBLIC}
            ACTION "target_link_libraries(${ADD_PACKS_TARGET} PUBLIC \${RATS_PACK_NAME})"
        )
        boilerplate(
            PACKS ${ADD_PACKS_PACKS_PRIVATE}
            ACTION "target_link_libraries(${ADD_PACKS_TARGET} PRIVATE \${RATS_PACK_NAME})"
        )
        boilerplate(
            PACKS ${ADD_PACKS_PACKS_INTERFACE}
            ACTION "target_link_libraries(${ADD_PACKS_TARGET} INTERFACE \${RATS_PACK_NAME})"
        )
    endif()
endfunction()