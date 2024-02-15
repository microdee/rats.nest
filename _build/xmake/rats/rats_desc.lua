------ common rats specific compiler/build utils

if Rats then return end Rats = rats_globals

includes("namespaces.lua")
local ns_cpp = NS.use("rats.xmake.cpp")

function Rats.target(ns, name, options)
    name = name or NS.this_pack_name();
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

function Rats.target_cpp(ns, name, options)
    options = options or {}
    name = name or NS.this_pack_name();
    Rats.target(ns, name, options)
        set_languages("c++23")
        set_runtimes(ns_cpp.scope.windows.linkage.mode)
        set_defaultarchs(
            "windows|x86_64",
            "linux|x86_64",
            "macosx|arm64",
            "android|arm64"
        )

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
            add_includedirs("$(buildir)/rats_includes/" .. ns:n(name), {public = true})
            if not options.manual_files then
                add_files("src/private/**.cpp")
            end
            on_config(function (target)
                import("rats.rats_os")
                import("rats.tt")

                local dstdir = "$(buildir)/rats_includes/" .. target:name()
                
                try { function() os.mkdir(dstdir) end }

                local public_dir = target:scriptdir() .. "/src/public"
                for _, public_header in ipairs(os.files(public_dir .. "/**.h")) do
                    local header_name = tt(path.split(path.relative(public_header, public_dir)))
                        | tt.array_to_string(".")

                    local full_name = target:name() .. "." .. header_name
                    full_name = full_name:replace("._.", ".", {plain = true});
                    rats_os.ln(
                        public_header,
                        dstdir .. "/" .. full_name
                    )
                end
            end)
        end
end

