-- extend built in module os

-- only consider script scope
if import then

import("lib.lua.package")
import("rats.rp")

function _get_build_tool(name)
    _g.build_tools = _g.build_tools or {}
    if not _g.build_tools[name] then
        -- TODO: make it cross platform
        local dllPath = rp("$(buildir)") / "tools" / name / "windows" / "x64" / "release" / name .. ".dll"
        if not os.exists(dllPath) then
            local dllSrc = rp("$(projectdir)") / "_build" / "tools" / name
            print("Building tool: " .. name)
            os.execv("xmake.exe",
                {
                    "config",
                    "-P", ".", "-y",
                    "--mode=release",
                    "--buildir=".. rp("$(buildir)") / "tools" / name,
                },
                { curdir = -dllSrc }
            )
            os.execv("xmake.exe",
                {
                    "build",
                    "-P", ".", "-y",
                    name
                },
                { curdir = -dllSrc }
            )
        end
        assert(os.exists(dllPath), "couldn't compile " .. name)
        _g.build_tools[name] = package.loadlib(dllPath, "luaopen_" .. name)()
    end
    return _g.build_tools[name]
end

-- use custom linking on Windows
function ln(src, dst, opt)
    if os.is_host("windows") then
        local libntfslink = _get_build_tool("libntfslink")
        local srcfix = rp.fixpath(src)
        local dstfix = rp.fixpath(dst)
        if os.exists(dstfix) then
            if libntfslink.IsSymlink(dstfix) then
                libntfslink.DeleteSymlink(dstfix)
            elseif libntfslink.IsJunction(dstfix) then
                libntfslink.DeleteJunction(dstfix)
            else
                local linkCount, result = libntfslink.GetHardlinkCount(dstfix)
                if linkCount > 1 then
                    os.rm(dstfix)
                else
                    print(vformat("Hard link count: %d (HRESULT %08X)", linkCount, result))
                    assert(false, dstfix .. " is existing and it wasn't a link. Overwriting it would potentially erase real data")
                end
            end
        end

        local success = false
        local result = 1
        if not _g.windows_symlinks_unsupported then
            success, result = libntfslink.CreateSymlink(dstfix, srcfix)
        end

        if not success then
            if not _g.windows_symlinks_unsupported then
                print(vformat("Cannot create Symlinks on this system (HRESULT %08X). Using NTFS Hardlinks and Junctions instead.", result))
                _g.windows_symlinks_unsupported = true
            end
            if os.isfile(srcfix) then
                success, result = libntfslink.CreateHardlink(dstfix, srcfix);
            else
                success, result = libntfslink.CreateJunction(dstfix, srcfix);
            end
        end
        assert(success, vformat("Failed to create link at %s targeting %s (HRESULT %08X)", dstfix, srcfix, result))
    else
        os.ln(src, dst, opt)
    end
end

end
