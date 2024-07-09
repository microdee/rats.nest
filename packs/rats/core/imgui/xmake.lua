------ Use ImGui and provide common utilities (such as RAII widget stack wrappers)

add_rules("mode.debug", "mode.release")

local ns = NS.use()
local ns_cpp = NS.use("rats.xmake.cpp")

--[[ yaml
third-party:
    name: Dear ImGui
    source: https://github.com/ocornut/imgui
    project: https://dearimgui.com
    authors:
        - "Omar Cornut (https://github.com/ocornut, https://www.miracleworld.net)"
    license: MIT License (https://github.com/ocornut/imgui/blob/master/LICENSE.txt)
    reasoning: The best ever tools UI library.
]]
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