cmake_minimum_required(VERSION ${RATS_MIN_CMAKE_VERSION})

project(rats.imgui VERSION ${RATS_VERSION} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 23)

add_library(rats.imgui "" ${RATS_PACK_TYPE})
target_sources(rats.imgui
    PUBLIC
        FILE_SET cxx_modules TYPE CXX_MODULES FILES
        src/rats.imgui.ixx
)

add_packs(PACKS vulkan)

target_link_libraries(rats.imgui
    PRIVATE Vulkan::Headers
    PRIVATE volk::volk
)