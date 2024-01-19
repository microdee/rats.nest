add_rules("mode.debug", "mode.release")

local ns = NS.use()
local ns_core = NS.use("rats.core")

Rats.target(ns)
    set_kind("shared")
    add_files("src/**.cppm")
    add_deps(ns_core:n("imgui"))
    set_languages("c++23")
    add_rules("utils.symbols.export_all", {export_classes = true})