add_rules("mode.debug", "mode.release")

local ns = NS.use()

add_requires("imgui v1.90-docking", {
    debug = true,
    configs = {
        vulkan = true,
        freetype = true,
        vs_runtime = "MT",
        debug = is_config("debug")
    }
})

Rats.target(ns)
    add_packages("imgui", {public = true})
    add_options("rats.xmake.cpp_common")