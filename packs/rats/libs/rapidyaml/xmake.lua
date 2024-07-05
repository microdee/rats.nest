--[[ yaml
third-party:
    name: Rapid YAML
    source: https://github.com/biojppm/rapidyaml
    project: https://github.com/biojppm/rapidyaml
    authors:
        - "jpmag (https://github.com/biojppm)"
    license: MIT License (https://github.com/biojppm/rapidyaml/blob/master/LICENSE.txt)
    reasoning: |
        Fast YAML and JSON parsing. In rats apps YAML is a preferred serialization method having a
        modern/fast C++ parser helps a lot.
]]

package("ryml")
    add_deps("cmake")
    set_sourcedir("" .. rp() / "ryml")
    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {target = "ryml"})
    end)
    on_test(function (package)
        assert(package:has_cxxincludes("ryml.hpp"))
    end)

--[[ yaml
third-party:
    name: C4 Core
    source: https://github.com/biojppm/c4core
    project: https://github.com/biojppm/c4core
    authors:
        - "jpmag (https://github.com/biojppm)"
    license: MIT License (https://github.com/biojppm/c4core/blob/master/LICENSE.txt)
    reasoning: Has some useful utilities, and comes included with Rapid YAML.
]]

package("c4core")
    add_deps("cmake")
    set_sourcedir("" .. rp() / "ryml" / "ext" / "c4core")
    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {target = "c4core"})
    end)
    -- TODO: test