------ commonly used extensions for tables

if Table then return end Table = {}
local table = table or {}

function table:__join(...)
    return table.join(self, ...)
end

function table:__shallow_join(...)
    return table.shallow_join(self, ...)
end

function table:__swap(i, j)
    return table.swap(self, i, j)
end

function table:__append(...)
    return table.append(self, ...)
end

function table:__clone(depth)
    return table.clone(self, depth)
end

function table:__copy()
    return table.copy(self)
end

function table:__inherit(...)
    return table.inherit(self, ...)
end

function table:__slice(first, last, step)
    return table.slice(self, first, last, step)
end

function table:__is_array()
    return table.is_array(self)
end

function table:__is_dictionary()
    return table.is_dictionary(self)
end

function table:__contains(arg1, arg2, ...)
    return table.contains(self, arg1, arg2, ...)
end

function table:__unwrap()
    return table.unwrap(self)
end

function table:__unique(barrier)
    return table.unique(self, barrier)
end

function table:__reverse_unique(barrier)
    return table.reverse_unique(self, barrier)
end

function table:__keys()
    return table.keys(tbl)
end

function table:__orderkeys(callback)
    return table.orderkeys(self, callback)
end

function table:__orderpairs(callback)
    return table.orderpairs(self, callback)
end

function table:__values()
    return table.values(self)
end

function table:__map(mapper)
    return table.map(self, mapper)
end

function table:__imap(mapper)
    return table.imap(self, mapper)
end

function table:__reverse()
    return table.reverse(self)
end

function table:__remove_if(pred)
    return table.remove_if(self, pred)
end

function table:__empty()
    return table.empty(self)
end

function table:__find(value)
    return table.find(self, value)
end

function table:__find_if(pred)
    return table.find_if(self, pred)
end

function table:__find_first(value)
    return table.find_first(self, value)
end

function table:__find_first_if(pred)
    return table.find_first_if(self, pred)
end

function table:__skip(n)
    return self:__slice(1, #self - n)
end

function table:__take(n)
    return self:__slice(1, n)
end

-- drop items until the first value is matched
function table:__skip_from(v, offset)
    local splitAt = self:__find_first(v) + (offset or 0)
    return self:__slice(splitAt)
end

-- drop items after the first value is matched
function table:__take_until(v, offset)
    local splitAt = self:__find_first(v) + (offset or 0)
    return self:__slice(1, splitAt)
end

function table:__array_to_string(separator, default)
    default = default or ""
    if self:__empty() then return default end

    local result = self[1]
    for i = 2, #self, 1 do
        result = result .. separator .. self[i]
    end
    return result
end