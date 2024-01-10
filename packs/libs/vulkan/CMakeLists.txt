cmake_minimum_required(VERSION ${RATS_MIN_CMAKE_VERSION})

set(USE_VULKAN_VERSION 1.3.261.1 CACHE STRING "Desired Vulkan SDK version")

project(use.vulkan VERSION ${USE_VULKAN_VERSION} LANGUAGES NONE)

CPMAddPackage("gh:KhronosGroup/Vulkan-Headers#sdk-${USE_VULKAN_VERSION}")
CPMAddPackage("gh:zeux/volk#sdk-${USE_VULKAN_VERSION}")