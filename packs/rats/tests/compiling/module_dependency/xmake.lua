add_rules("mode.debug", "mode.release")

local ns = NS.use()
local ns_core = NS.use("rats.core")

Rats.target(ns)
    add_deps(ns_core:n("imgui"))
    add_options("rats.xmake.cpp_common")