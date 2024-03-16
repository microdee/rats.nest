add_rules("mode.debug", "mode.release")

target("stringzilla")
    set_kind("headeronly")
    set_languages("c++23")
    add_headerfiles("sz/include/**.h", "sz/include/**.hpp")
    add_includedirs("sz/include", {public = true})