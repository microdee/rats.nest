local enable = true

local ns = NS.use()

ns:push("reflect_on")
    target(ns:n("path"))
        set_kind("phony")
        set_enabled(enable)
        on_config(function (t)
            print("--------------------- path")
            for k, v in pairs(path) do
                print(k)
            end
        end)

    target(ns:n("string"))
        set_kind("phony")
        set_enabled(enable)
        on_config(function (t)
            print("--------------------- string")
            for k, v in pairs(string) do
                print(k)
            end
        end)

    target(ns:n("table"))
        set_kind("phony")
        set_enabled(enable)
        on_config(function (t)
            print("--------------------- table")
            for k, v in pairs(table) do
                print(k)
            end
        end)
ns:pop()