------ common rats specific compiler/build utils

if Rats then return end Rats = rats_globals

includes("namespaces.lua")

function Rats.target(ns, name)
    name = name or NS.this_pack_name();
    target(ns:n(name))
        set_group(string.join(ns._stack, "/"))
        set_enabled(ns:enabled())
end