------ common rats specific compiler/build utils

if Rats then return end Rats = rats_globals

includes("namespaces.lua")
local ns_cpp = NS.use("rats.xmake.cpp")

--[[
    Set up a common language agnostic target playing "nice" in the rats project model.
    By default the folder name of the target is used, but optionally this can be overridden either with

    Rats.target(ns, { "mystuff" })

    or with

    Rats.target(ns, { name = "mystuff" })

    The full name of the target will include the namespace e.g.: "rats.core.mytopic.mystuff"
]]
function Rats.target(ns, options)
    options = options or {}
    local name = options[1] or options.name or NS.this_pack_name()
    if type(name) ~= "string" then
        name = NS.this_pack_name()
    end
    target(ns:n(name), options)
        set_group(array_to_string("/")(ns._stack))
        set_enabled(ns:enabled())
end

ns_cpp.scope.windows = {
    linkage = {
        mode_plain = rats_globals.windows.linkage,
        mode = is_config("debug") and rats_globals.windows.linkage .. "d" or rats_globals.windows.linkage
    }
}

--[[--
    Set up common rats targets for C++23 . Simplest use case scenario:

    -- inside pack/rats/core/imgui/xmake.lua

    -- use namespace "rats.core"
    local ns = NS.use()
    -- create a target called "rats.core.imgui"
    Rats.target_cpp(ns)

    Control the kind via the second argument (options) so rats can do more magic for you. Default
    behavior (options unspecified) is creating a shared library. Use

    Rats.target_cpp(ns, { exe = 1 })

    You can still combine it with an explicit target name
    
    Rats.target_cpp(ns, { "MyTarget", exe = 1 })
    -- OR
    Rats.target_cpp(ns, { name = "MyTarget", exe = 1 })

    It automatically includes files from "src" directory. In case of a traditional C++ library
    (not yet compiled with modules) "src/private/**.cpp" is used. If you don't want this use
    
    Rats.target_cpp(ns, { no_files = 1 })

    For C++ modules use

    Rats.target_cpp(ns, { modules = 1 })

    the rest of this documentation considers traditional C++ sources (not modules)

    One can expose headers for other libraries from "src/public" folder, but only the owning target
    can use it directly. For other packs header virtualization is used, where header files are
    symlinked to an intermediate folder, and other packs can use the includes by their full
    namespaced name. This is done to avoid SmurfNaming anti-pattern on source locations, and avoid
    the situation where two targets expose a header with the same name. e.g.:

                   Target (xmake.lua is in this folder)
                   V
    pack/rats/core/imgui/src/public/widgets.h

    can be used with #include "widgets.h" in imgui but everywhere else it should be used with

    #include "rats.core.imgui.widgets.h"

    This is obviously a non-problem with properly namespaced C++ modules, but the industry hasn't
    quite moved to it yet. If you don't want header virtualization this way, and you want your own
    way for other rats packs to consume your headers, then use
    
    Rats.target_cpp(ns, { no_virtual_headers = 1 })

    One header (by default main.h or _.h) can be made the main header for the module and therefore
    can be included in other targets as (this is expunged-virtual-header or default-header)

    pack/rats/core/imgui/src/public/_.h
    #include "rats.core.imgui.h"

    To change which header names are virtualized this way use

    Rats.target_cpp(ns, { virtual_headers = { expunge = {"foo", "bar"} } })

    Full options:
    {
        exe = 1,
        no_files = 1,
        modules = 1,
        no_virtual_headers = 1,
        virtual_headers = {
            expunge = {...}
        },
        <target options ... >
    }
]]
function Rats.target_cpp(ns, options)
    options = options or {}
    local name = options[1] or options.name or NS.this_pack_name()
    if type(name) ~= "string" then
        name = NS.this_pack_name()
    end

    set_defaultarchs(
        "windows|x86_64",
        "linux|x86_64",
        "macosx|arm64",
        "android|arm64"
    )

    Rats.target(ns, name, options)
        set_languages("c++23")
        set_runtimes(ns_cpp.scope.windows.linkage.mode)

        if options.exe then
            set_kind("binary")
        else
            set_kind("shared")
            add_rules("utils.symbols.export_all", {export_classes = true})
        end

        if options.modules then
            add_files("src/**.cppm")
        else
            add_includedirs("src/public")
            add_includedirs("src/private")
            if not options.no_files then
                add_files("src/private/**.cpp")
            end
            if not options.exe and not options.no_virtual_headers then
                options.virtual_headers = options.virtual_headers or {}
                options.virtual_headers.expunge = options.virtual_headers.expunge or { "_", "main" }
                
                add_includedirs("$(buildir)/rats_includes/" .. ns:n(name), {public = true})

                on_config(function (target)
                    import("rats.rats_os")
                    import("rats.tt")
    
                    local dstdir = "$(buildir)/rats_includes/" .. target:name()
                    
                    try { function() os.mkdir(dstdir) end }
    
                    local public_dir = target:scriptdir() .. "/src/public"
                    for _, public_header in ipairs(os.files(public_dir .. "/**.h")) do
                        local header_name = tt(path.split(path.relative(public_header, public_dir)))
                            | tt.array_to_string(".")
    
                        local full_name = (target:name() .. "." .. header_name)
                        for _, e in ipairs(options.virtual_headers.expunge) do
                            full_name = full_name:replace("." .. e .. ".h", ".h", {plain = true})
                        end
                        rats_os.ln(
                            public_header,
                            dstdir .. "/" .. full_name
                        )
                    end
                end)
            end
        end
end

