cmake_minimum_required(VERSION ${RATS_MIN_CMAKE_VERSION})

set(IMGUI_VERSION 1.89.9)

project(imgui VERSION ${IMGUI_VERSION} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 23)

set(IMGUI_ROOT ${CMAKE_CURRENT_LIST_DIR}/repo)
set(IMGUI_MISC_CPP ${IMGUI_ROOT}/misc/cpp)
set(IMGUI_MISC_FONTS ${IMGUI_ROOT}/misc/fonts)
set(IMGUI_MISC_FREETYPE ${IMGUI_ROOT}/misc/freetype)

add_packs(PACKS freetype)

add_library(
    imgui ${RATS_PACK_TYPE}
    ${IMGUI_ROOT}/imgui.cpp
    ${IMGUI_ROOT}/imgui_demo.cpp
    ${IMGUI_ROOT}/imgui_draw.cpp
    ${IMGUI_ROOT}/imgui_tables.cpp
    ${IMGUI_ROOT}/imgui_widgets.cpp
    ${IMGUI_MISC_CPP}/imgui_stdlib.cpp
    ${IMGUI_MISC_FONTS}/binary_to_compressed_c.cpp
    ${IMGUI_MISC_FREETYPE}/imgui_freetype.cpp
)