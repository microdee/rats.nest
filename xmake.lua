set_project("rats")

rats = {
    paths = {
        root = path.absolute("."),
        packs = path.join(path.absolute("."), "packs")
    }
}

set_version("0.0.1")

includes("build/xmake/**.lua")
includes("packs/**/xmake.lua")