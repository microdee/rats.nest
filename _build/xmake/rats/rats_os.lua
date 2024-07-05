-- extend built in module os

-- only consider script scope
if import then

import("rats.rp")

-- use custom linking on Windows
function ln(src, dst, opt)
    if os.is_host("windows") then
        import("rats.ntfs_link", { always_build = true })
        
        local srcfix = rp.fixpath(src)
        local dstfix = rp.fixpath(dst)
        if os.exists(dstfix) then
            if ntfs_link.IsSymlink(dstfix) then
                ntfs_link.DeleteSymlink(dstfix)
            elseif ntfs_link.IsJunction(dstfix) then
                ntfs_link.DeleteJunction(dstfix)
            else
                local linkCount, result = ntfs_link.GetHardlinkCount(dstfix)
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
            success, result = ntfs_link.CreateSymlink(dstfix, srcfix)
        end

        if not success then
            if not _g.windows_symlinks_unsupported then
                print(vformat("Cannot create Symlinks on this system (HRESULT %08X). Using NTFS Hardlinks and Junctions instead.", result))
                _g.windows_symlinks_unsupported = true
            end
            if os.isfile(srcfix) then
                success, result = ntfs_link.CreateHardlink(dstfix, srcfix);
            else
                success, result = ntfs_link.CreateJunction(dstfix, srcfix);
            end
        end
        assert(success, vformat("Failed to create link at %s targeting %s (HRESULT %08X)", dstfix, srcfix, result))
    else
        os.ln(src, dst, opt)
    end
end

end
