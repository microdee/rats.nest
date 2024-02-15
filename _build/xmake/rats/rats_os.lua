-- extend built in module os

windows = "windows"
linux = "linux"
-- TODO: other OS's

-- only consider symlink errors on windows if the dst really doesn't exist.
function ln(src, dst, opt)
    if os.is_host(windows) then
        try {
            function ()
                return os.ln(src, dst, opt)
            end
        }
        if os.exists(dst) then return else
            os.raise(string.format("cannot link %s to %s, %s", src, dst, os.strerror()))
        end
    else
        os.ln(src, dst, opt)
    end
end