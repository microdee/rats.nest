add_rules("mode.release", "mode.debug")

--[[ yaml
third-party:
    name: libntfslinks
    source: https://github.com/caskater4/libntfslinks
    project: https://github.com/caskater4/libntfslinks
    authors:
        - "Jean-Philippe Steinmetz (https://github.com/caskater4)"
    license: BSD 2-Clause "Simplified" License (https://github.com/caskater4/libntfslinks/blob/master/LICENSE)
    reasoning: |
        Symlinks on Windows need admin permissions, but lower level NTFS linking mechanisms don't.
        This library is mainly used for falling back to Junctions and Hardlinks if the user running
        the build doesn't have the required privileges.
    notes: |
        Sources have been modified so they're buildable via XMake (original repo uses MSBuild) and
        the resulting DLL is usable as a Lua module. Original tests are omitted. For better
        readibility this library is referred to in Rats as `ntfs_link`.
]]

target("ntfs_link")
    set_languages("c++17")
    add_rules("module.shared")
    add_files("dll/**.cpp")
    add_defines("UNICODE", "_UNICODE")
    set_runtimes("MT")