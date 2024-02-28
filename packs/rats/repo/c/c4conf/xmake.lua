package("c4conf")
    set_homepage("https://github.com/biojppm/c4conf")
    set_description("YAML-based configuration data trees, with override facilities including command line arguments.")
    set_license("MIT")

    set_urls("https://github.com/biojppm/c4conf.git")
    add_versions("2023.02.03", "f32a239509d46adc864c838e0d5e5244321adb9e")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)