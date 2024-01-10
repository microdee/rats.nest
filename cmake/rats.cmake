#[[
    Includes all functionalities for building with the rats ecosystem
]]#

set(RATS_VERSION 0.0.1 CACHE STRING "Semantic version of rats")

set(
    RATS_MIN_CMAKE_VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION}
    CACHE INTERNAL "Permanently stored minimum CMake version required by rats" FORCE
)

include(${CMAKE_CURRENT_LIST_DIR}/rats.environment.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rats.packs.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rats.vcpkg.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rats.cpm.cmake)