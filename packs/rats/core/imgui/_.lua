------ Use ImGui and provide common utilities (such as RAII widget stack wrappers)

add_rules("mode.debug", "mode.release")

local ns = NS.use()

add_requires("imgui v1.90.2-docking", {
    configs = Rats.requires // {
        vulkan = true,
        freetype = true,
    }
})

Rats.target_cpp(ns)
    add_packages("imgui", {public = true})