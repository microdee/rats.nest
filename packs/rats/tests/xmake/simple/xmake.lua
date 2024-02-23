local ns = NS.use { withPack = true }

ns:push("reflect_on")
if ns:enabled() then
    print(ns:get("test_text"))
end

    Rats.target(ns, {"path"})
        set_kind("phony")
        on_config(function (t)
            print("--------------------- " .. t:get("group"))
            print("--------------------- path")
            for k, v in pairs(path) do
                print(k)
            end
        end)

    Rats.target(ns, {"string"})
        set_kind("phony")
        on_config(function (t)
            print("--------------------- " .. t:get("group"))
            print("--------------------- string")
            for k, v in pairs(string) do
                print(k)
            end
        end)

    Rats.target(ns, {"table"})
        set_kind("phony")
        on_config(function (t)
            print("--------------------- " .. t:get("group"))
            print("--------------------- table")
            for k, v in pairs(table) do
                print(k)
            end
        end)

    Rats.target(ns, {"target"})
        set_kind("phony")
        on_config(function (t)
            import("rats.tt")
            print("--------------------- " .. t:get("group"))
            print("--------------------- target")
            local keys = tt(t) | tt.orderkeys()

            for _, k in pairs(keys) do
                print(k)
            end
        end)
ns:pop()

ns:push("fs")
    Rats.target(ns, {"symlink"})
        set_kind("phony")
        on_load(function (t)
            import("rats.rats_os")
            rats_os.ln(
                path.join(os.scriptdir(), "linktest"),
                path.join(os.projectdir(), "_build", "linktest")
            )
        end)
ns:pop()