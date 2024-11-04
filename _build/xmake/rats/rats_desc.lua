------ common rats specific compiler/build utils

if Rats then return end Rats = rats_globals;

includes("namespaces.lua")

local ns_cpp = NS.use("rats.xmake.cpp")

function Rats.private_parse_args(arg1, arg2)
    if type(arg1) == "table" then
        local options = arg1
        local name = options.name or NS.this_pack_name()
        return name, options
    end
    if type(arg1) == "string" then
        local options = arg2 or {}
        local name = arg1
        return name, options
    end
    return NS.this_pack_name(), {}
end

function Rats.private_default_options(options, default_in)
    options = type(options) ~= "table" and {} or options
    return tt(options) | default(default_in)
end

function Rats.private_cpp_common()
    set_languages(Rats.cpp.version)
    set_runtimes(ns_cpp.scope.windows.linkage.mode)
    add_cxxflags("cl::/diagnostics:caret")
end

--[[
    Set up a common language agnostic target playing "nice" in the rats project model.
    By default the folder name of the target is used, but optionally this can be overridden either with

    Rats.target(ns, "mystuff")

    or with

    Rats.target(ns, { name = "mystuff" })

    The full name of the target will include the namespace e.g.: "rats.core.mytopic.mystuff"

    Use the implicit first index table element for the options which will be passed to xmake target

    Rats.target(ns, {
        { kind = "binary" },
        name = "mystuff"
    })

    or

    Rats.target(ns, "mystuff", {{ kind = "binary" }} )
]]
function Rats.target(ns, arg1, arg2)
    local name, options = Rats.private_parse_args(arg1, arg2)
    options = Rats.private_default_options(options, { default = false })
    target(ns:n(name), options[1])
        set_group(array_to_string("/")(ns._stack))
        set_enabled(ns:enabled())
end

--[[
    Set up common rats targets for C++. Simplest use case scenario:

    -- inside pack/rats/core/imgui/xmake.lua

    -- use namespace "rats.core"
    local ns = NS.use()
    -- create a target called "rats.core.imgui"
    Rats.target_cpp(ns)

    Control the kind via the second argument (options) so rats can do more magic for you. Default
    behavior (options unspecified) is creating a shared library. For executables, use

    Rats.target_cpp(ns, {{ kind = "binary" }} )

    Notice how it's a table inside another table. The reason is that the table at [1] is the options
    table which will be fed to xmake targets and the rest is not. This is done because of a design
    decision in xmake, that unknown elements in the scope options are fatal. So options controlling
    rats targets had to be separated.

    You can also specify an explicit target name:
    
    Rats.target_cpp(ns, "MyTarget", {{ kind = "binary" }} )
    -- OR
    Rats.target_cpp(ns, { {kind = "binary"}, name = "MyTarget" })

    It automatically includes files from "src" directory. In case of a traditional C++ library
    (not yet compiled with modules) "src/**.cpp" is used. If you don't want this use
    
    Rats.target_cpp(ns, { no_files = true })

    For C++ modules use

    Rats.target_cpp(ns, { modules = true })

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
    
    Rats.target_cpp(ns, { no_virtual_headers = true })

    One header (by default main.h or _.h) can be made the main/default header for the target and therefore
    can be included in other targets as:

    pack/rats/core/imgui/src/public/_.h
    #include "rats.core.imgui.h"

    (this is expunged-virtual-header or default-header)
    To change which header names are virtualized this way use

    Rats.target_cpp(ns, { virtual_headers = { expunge = {"foo", "bar"} } })

    Full options:
    {
        {
            kind = "binary",
            <rest of target options ... >
        },
        no_files = true,
        modules = true,
        no_virtual_headers = true,
        header_only = true,
        virtual_headers = {
            expunge = {...}
        }
    }
]]
function Rats.target_cpp(ns, arg1, arg2)

    local name, options = Rats.private_parse_args(arg1, arg2)
    options = Rats.private_default_options(options, {
        { kind = "shared" },
        virtual_headers = {
            expunge = { "_", "main" }
        }
    })
    
    local is_library = options[1].kind == "shared" or options[1].kind == "static"

    Rats.target(ns, name, options)
        Rats.private_cpp_common()

        if options[1].kind == "shared" then
            add_rules("utils.symbols.export_all", {export_classes = true})
        end

        if options.modules then
            add_files("src/**.cppm")
        else
            add_includedirs("src/public")
            if not options.header_only then
                add_includedirs("src/private")
            end
            if not options.no_files then
                if not options.header_only then
                    add_files("src/**.cpp")
                end
                add_headerfiles("src/**.h", {install = false})
            end
            if is_library and not options.no_virtual_headers then
                
                add_includedirs("$(buildir)/rats_includes/" .. ns:n(name), {public = true})
                add_headerfiles("$(buildir)/rats_includes/" .. ns:n(name) .. "/**.h", {install = false})

                on_config(function (target)
                    import("rats.rats_os")
                    import("rats.tt")
                    import("rats.rp")
    
                    local dstdir = rp("$(buildir)") / "rats_includes" / target:name()
                    
                    try { function() os.mkdir(-dstdir) end }
    
                    local public_dir = rp(target:scriptdir()) / "src" / "public"
                    for _, public_header in ipairs(os.files("" .. public_dir / "**.h")) do
                        local header_rel = path.relative(public_header, -public_dir)
                        local header_name = tt(path.split(header_rel)) | tt.array_to_string(".")
    
                        local full_name = (target:name() .. "." .. header_name)
                        for _, e in ipairs(options.virtual_headers.expunge) do
                            full_name = full_name:replace("." .. e .. ".h", ".h", {plain = true})
                        end
                        rats_os.ln(
                            public_header,
                            -(dstdir / full_name)
                        )
                    end
                end)
            end
        end
end

function Rats.target_cpp_tests(ns, arg1, arg2)
    
    local name, options = Rats.private_parse_args(arg1, arg2)

    Rats.target(ns, name .. "_tests", options)
        Rats.private_cpp_common()
        set_kind("binary")
        set_default(false)
        add_deps(ns:n(name))
        add_packages("catch2")
        add_files("tests/**.cpp")
        add_headerfiles("tests/**.h", {install = false})
        add_tests("default")
end