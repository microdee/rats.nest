
includes("_build/xmake/rats/rp.lua")

rats_globals = {

    paths = {
        root = rp(),
        packs = rp() / "packs",
        intermediate = rp() / ".intermediate",

        xmake = {
            modules = rp() / "_build" / "xmake",
            buildir = rp() / ".intermediate" / "build",

            vcpkg = rp() / "_build" / "tools" / "vcpkg",
        }
    },

    windows = {
        linkage = "MD",
        sdk = "10.0.19041.0",
        vs = "2019"
    },

    catch2 = {
        version = "v3.5.3"
    }
}

-- XMake
add_moduledirs(-rats_globals.paths.xmake.modules)
set_config("buildir", -rats_globals.paths.xmake.buildir)
set_config("vcpkg", -rats_globals.paths.xmake.vcpkg)

-- Windows
set_config("vs_sdkver", rats_globals.windows.sdk)
set_config("vs", rats_globals.windows.vs)

set_defaultarchs(
    "windows|x64",
    "linux|x86_64",
    "macosx|arm64",
    "android|arm64"
)