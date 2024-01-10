#[[
    Include for communal C++ module support.
    Hopefully this will be unnecessary with coming versions.

    Related literature:
    https://www.kitware.com/import-cmake-c20-modules/
    https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2022/p1689r5.html
]]#

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.26)
    set(CMAKE_EXPERIMENTAL_CXX_MODULE_CMAKE_API "2182bf5c-ef0d-489a-91da-49dbc3090d2a")
else()
    set(CMAKE_EXPERIMENTAL_CXX_MODULE_CMAKE_API "3c375311-a3c9-4396-a187-3227ef642046")
endif()

set(CMAKE_EXPERIMENTAL_CXX_MODULE_DYNDEP 1)

if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    # TODO: Module support in GCC
endif()

if(${CMAKE_CXX_COMPILER_ID} STREQUAL "CLang")
    # TODO: Module support in CLang
endif()

#[[
    QoL function for adding a library or executable with modules support
    usage:
    add_(library rats.myThing AUTO)
    )
]]#
function(add_ target name)
    cmake_parse_arguments(PARSE_ARGV 2
        __args
        "AUTO"
        "TYPE;ROOT"
        "PUBLIC;PRIVATE"
    )
    if(__args_TYPE)
        set(__libType ${__args_TYPE})
    else()
        set(__libType ${RATS_PACK_TYPE})
    endif()

    if(__args_TYPE_ROOT)
        set(__root ${__args_TYPE_ROOT})
    else()
        set(__root ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    cmake_language(EVAL CODE "add_${target}(${name} ${__libType})")

    if(__args_AUTO)
        file(
            GLOB_RECURSE __privateFiles
            FOLLOW_SYMLINKS
            LIST_DIRECTORIES false
            CONFIGURE_DEPENDS
            ${__root}/src/private/*.ixx
        )
        file(
            GLOB_RECURSE __publicFiles
            FOLLOW_SYMLINKS
            LIST_DIRECTORIES false
            CONFIGURE_DEPENDS
            ${__root}/src/public/*.ixx
        )

    endif()

    target_sources(${name} )
endfunction()