------ common rats specific compiler/build utils

if Rats then return end Rats = rats_globals

includes("namespaces.lua")

function Rats.target(ns, name)
    name = name or NS.this_pack_name();
    target(ns:n(name))
        set_group(ns._stack:__array_to_string("/"))
        set_enabled(ns:enabled())
end