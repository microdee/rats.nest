------ Common software engineering utilities

add_requires("stringzilla v3.4.1")

local ns = NS.use();

Rats.target_cpp(ns)
    -- add_packages("ryml", {public = true})
    -- add_packages("c4core", {public = true})
    add_packages("stringzilla", {public = true})