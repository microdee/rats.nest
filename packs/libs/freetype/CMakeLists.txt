cmake_minimum_required(VERSION ${RATS_MIN_CMAKE_VERSION})

set(USE_FREETYPE_VERSION 2.13.2 CACHE STRING "Desired Vulkan SDK version")

project(use.freetype VERSION ${USE_FREETYPE_VERSION} LANGUAGES NONE)

string(REPLACE . - __tagCompatibleVersion ${USE_FREETYPE_VERSION})

if(${PACKS_AS_SHARED})
    set(__buildSharedOption "BUILD_SHARED_LIBS ON")
else()
    set(__buildSharedOption "BUILD_SHARED_LIBS OFF")
endif()

CPMAddPackage(
    NAME freetype
    GIT_REPOSITORY https://gitlab.freedesktop.org/freetype/freetype.git
    GIT_TAG VER-${__tagCompatibleVersion}
    OPTIONS
        "BUILD_SHARED_LIBS OFF"
        "FT_REQUIRE_ZLIB ON"
        "FT_REQUIRE_BZIP2 ON"
        "FT_REQUIRE_PNG ON"
        "FT_REQUIRE_HARFBUZZ ON"
        "FT_REQUIRE_BROTLI ON"
        "FT_ENABLE_ERROR_STRINGS ON"
        "SKIP_INSTALL_ALL ON"
)