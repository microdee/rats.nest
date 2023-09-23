cmake_minimum_required(VERSION 3.25)

set(RATS_INITIALIZED FALSE CACHE BOOL "Don't set this manually" FORCE)
include(${CMAKE_SOURCE_DIR}/cmake/rats.cmake)

project(rats VERSION 0.0.1 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 23)

include(${CMAKE_SOURCE_DIR}/MainPacks.cmake)