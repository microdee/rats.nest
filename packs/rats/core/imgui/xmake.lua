add_rules("mode.debug", "mode.release")

local ns = NS.use()
local ns_cpp = NS.use("rats.xmake.cpp")

add_requires("imgui v1.90.2-docking", {
    configs = {
        shared = true,
        vulkan = true,
        freetype = true,
        runtimes = ns_cpp.scope.windows.linkage.mode,
        debug = is_config("debug")
    }
})

Rats.target_cpp(ns)
    add_packages("imgui", {public = true})