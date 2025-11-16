
includes("_build/xmake/rats/rp.lua")
includes("_build/xmake/rats/tt.lua")
includes("_build/xmake/rats/namespaces.lua")

---- Global config start

rats_globals = {}
rats_globals.paths = {
    root = rp(),
    packs = rp() / "packs",
    intermediate = rp() / ".intermediate"
}

rats_globals.paths.xmake = {
    modules = rp() / "_build/xmake",
    builddir = rats_globals.paths.intermediate / "build",
    vcpkg = rp() / "_build/tools/vcpkg",
}

rats_globals.cpp = {
    version = "c++23"
}

rats_globals.windows = {
    runtime_mode = "MD",
    runtime = "MD" .. (is_config("debug") and "d" or ""),
    sdk = "10.0.22621.0",
    vs = "2022"
}

rats_globals.catch2 = {
    version = "v3.5.3"
}

rats_globals.requires = tt({
    debug = is_config("debug"),
    shared = true,
    vs_runtime = rats_globals.windows.runtime
})

---- Global config end

-- XMake
add_moduledirs(-rats_globals.paths.xmake.modules)
set_config("builddir", -rats_globals.paths.xmake.builddir)
set_config("vcpkg", -rats_globals.paths.xmake.vcpkg)

-- C++
set_config("cpp", rats_globals.cpp.version)

-- Windows
set_config("vs_sdkver", rats_globals.windows.sdk)
set_config("vs", rats_globals.windows.vs)

set_defaultarchs(
    "windows|x64",
    "linux|x86_64",
    "macosx|arm64",
    "android|arm64"
)

add_requires("catch2 " .. rats_globals.catch2.version, {
    configs = {
        vs_runtime = rats_globals.windows.runtime,
    }
})