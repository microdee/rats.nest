--[[
    Path extensions for Rats
]]

if RatsPath then return end RatsPath = {}
local rpath = {}

function fixpath(p)
    return path.normalize(path.absolute(path.translate(vformat(p))))
end

--[[
    Start a chain of paths from either "." or an input path, Usage:

    local mypath = rp() / "foo" / "bar" / "etc"
    -- then convert to string with unary minus operator
    print(-mypath)               --> "/abs/scriptdir/path/foo/bar/etc"
    -- or
    print("" .. mypath / "more") --> "/abs/scriptdir/path/foo/bar/etc/more"
    
    `-mypath` === `"" .. mypath`
    OR
    `-(mypath/ "more")` === `"" .. mypath / "more"`
    The only difference is that because .. has lower precedence than / (unlike the unary -) it can
    be used to append more path items in-place without wrapping parenthesis. Furthermore this allows
    rp() to be used in string concatenation chain like

    print("buildir=" .. mypath / "more" .. ";") --> "buildir=/abs/scriptdir/path/foo/bar/etc/more;"

    This also means `mypath /  myvar .. ".txt"  / "yo"` won't compile,
    but             `mypath / (myvar .. ".txt") / "yo"` is ok (result is rp).
    but then        `mypath /  myvar .. ".txt"`         is also ok (result is string)
    but then again  `mypath / (myvar .. ".txt")`        is also ok (result is rp)

    Paths composed this way are always normalized which means

    print("" .. mypath / "..")          --> "/abs/scriptdir/path/foo/bar"
    print("" .. mypath / ".." / "more") --> "/abs/scriptdir/path/foo/bar/more"
]]
function rp(subject)
    local result = {}
    result.p = subject and fixpath(subject) or path.absolute(".")
    return table.inherit2(result, rpath)
end

function main(subject)
    return rp(subject)
end

function rpath.__div(self, next)
    local result = table.inherit2(table.clone(self), rpath)
    result.p = path.normalize(path.join(self.p, next))
    return result
end

function rpath.__unm(self)
    return self.p
end

function rpath.__concat(lh, rh)
    if type(lh) == "string" then
        return lh .. rh.p
    end
    return lh.p .. rh
end