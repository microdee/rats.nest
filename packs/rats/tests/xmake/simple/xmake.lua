local enable = true

local ns = NS.use { withPack = true }

ns:push("reflect_on")

if ns:enabled() then
    print(ns:get("test_text"))
end

Rats.target(ns, "path")
    set_kind("phony")
    set_enabled(enable)
    on_config(function (t)
        print("--------------------- " .. t:get("group"))
        print("--------------------- path")
        for k, v in pairs(path) do
            print(k)
        end
    end)

Rats.target(ns, "string")
    set_kind("phony")
    set_enabled(enable)
    on_config(function (t)
        print("--------------------- " .. t:get("group"))
        print("--------------------- string")
        for k, v in pairs(string) do
            print(k)
        end
    end)

Rats.target(ns, "table")
    set_kind("phony")
    set_enabled(enable)
    on_config(function (t)
        print("--------------------- " .. t:get("group"))
        print("--------------------- table")
        for k, v in pairs(table) do
            print(k)
        end
    end)
ns:pop()