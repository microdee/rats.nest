------ commonly used extensions for tables

if Table then return end Table = {}
local table = table or {}

function table.skip(self, n)
    return table.slice(self, 1, #self - n)
end

function table.take(self, n)
    return table.slice(self, 1, n)
end

-- drop items until the first value is matched
function table.skip_from(self, v, offset)
    local splitAt = table.find_first(self, v) + (offset or 0)
    return table.slice(self, splitAt)
end

-- drop items after the first value is matched
function table.take_until(self, v, offset)
    local splitAt = table.find_first(self, v)
    return splitAt and table.slice(self, 1, splitAt + (offset or 0)) or self
end

function string.join(self, separator, default)
    default = default or ""
    if table.empty(self) then return default end

    local result = self[1]
    for i = 2, #self, 1 do
        result = result .. separator .. self[i]
    end
    return result
end