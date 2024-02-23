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

    rp() "foo" "bar" "etc" ()
    this is exploiting optional parenthesis in  equivalent to 
]]
function rp(subject)
    local result = {}
    result.p = subject and fixpath(subject) or path.absolute(".")
    return table.inherit2(result, rpath)
end

function main(subject)
    return rp(subject)
end

function rpath.__call(self, next)
    if type(next) == "string" and next ~= "." and next ~= "" then
        local result = table.inherit2(table.clone(self), rpath)
        result.p = path.normalize(path.join(self.p, next))
        return result
    end
    return self.p
end