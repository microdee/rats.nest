--[[ yaml
third-party:
    name: Stringzilla
    source: https://github.com/ashvardanian/Stringzilla
    project: https://ashvardanian.com/posts/stringzilla/
    authors:
        - "Ash Vardanian (https://github.com/ashvardanian, https://ashvardanian.com)"
    license: Apache License 2.0 (https://github.com/ashvardanian/StringZilla/blob/main/LICENSE)
    reasoning: Fast string manipulation.
]]

add_rules("mode.debug", "mode.release")

target("stringzilla")
    set_kind("headeronly")
    set_languages("c++23")
    add_headerfiles("sz/include/**.h", "sz/include/**.hpp")
    add_includedirs("sz/include", {public = true})