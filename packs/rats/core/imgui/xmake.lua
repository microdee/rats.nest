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
    set_kind("shared")
    add_files("src/**.cppm")
    add_packages("imgui")
    set_languages("c++23")