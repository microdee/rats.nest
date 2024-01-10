
if(WIN32)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    set(CMAKE_COLOR_MAKEFILE OFF CACHE BOOL "Disable Windows color Makefile by Force" FORCE)
endif()