cmake_minimum_required(VERSION ${RATS_MIN_CMAKE_VERSION})

project(rats.cmake_tests VERSION ${RATS_VERSION} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 23)

include(${CMAKE_CURRENT_SOURCE_DIR}/check_directories/directories.cmake)