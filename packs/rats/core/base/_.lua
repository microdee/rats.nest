------ Common software engineering utilities

add_rules("mode.debug", "mode.release")

local ns = NS.use()

add_requires("reflect-cpp v0.20.0", {
    configs = Rats.requires // {
        yaml = true,
        msgpack = true,
        toml = true,
        xml = true,
        capnproto = true
    }
})

Rats.target_cpp(ns)
    add_packages("reflect-cpp", { public = true })