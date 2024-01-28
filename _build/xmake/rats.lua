------ common rats specific compiler/build utils

if Rats then return end Rats = rats_globals

includes("namespaces.lua")

function Rats.target(ns, name)
    name = name or NS.this_pack_name();
    target(ns:n(name))
        set_group(__array_to_string("/")(ns._stack))
        set_enabled(ns:enabled())
end

option("rats.xmake.cpp_common")
    set_languages("c++23")
    add_files("src/**/*.cppm")
    set_kind("shared")
    set_defaultarchs(
        "windows|x86_64",
        "linux|x86_64",
        "macosx|arm64",
        "android|arm64"
    )
    add_rules("utils.symbols.export_all", {export_classes = true})
option_end()