------ Common software engineering utilities

add_rules("mode.debug", "mode.release")

local ns = NS.use();

Rats.target_cpp(ns)
    -- add_packages("ryml", {public = true})
    -- add_packages("c4core", {public = true})
    add_deps("stringzilla", {public = true})