add_rules("mode.release", "mode.debug")

set_project("libntfslink")
set_version("1.0.0")

set_languages("c++17")
set_defaultarchs(
    "windows|x64",
    "linux|x86_64",
    "macosx|arm64",
    "android|arm64"
)

set_runtimes("MT")

add_requires("lua 5.4.6")

add_defines("UNICODE", "_UNICODE")

target("libntfslink")
    set_kind("shared")
    add_files("dll/**.cpp")
    add_packages("lua")

target("libntfslink_test")
    add_deps("libntfslink")
    set_kind("binary")
    add_files("test/**.cpp")
    add_includedirs("dll")
    add_defines("LIBNTFSLINKS_IMPORT=1")