------ commonly used extensions for tables

if Table then return end Table = {}
local table = table or {}
local operand = {}

--[[
    this function gives any tables common operator overloads:
    
    ### | (__bor) -> piping
    Feed the left side operand table into a right side operand function

    __({1, 2, 3, 4}) | __slice(2, 3) | __reverse()
]]
function __(subject)
    if subject.is__ then return subject end
    if type(subject) == "table" then
        return table.inherit2(subject, operand)
    end
    return subject
end

--[[
    indicates that table can be used as a common operand
]]
function operand.is__() return true end

function operand.__bor(subject, value)
    return value(subject)
end

function __clear() return function (subject)
    return __(table.clear(subject))
end end

-- get array max integer key for lua5.4
function __maxn() return function (subject)
    return table.maxn(subject)
end end

-- join all objects and tables to self
function __join2(...)
    local args = {...}
    return function (subject)
        return __(table.join2(subject, table.unpack(args)))
    end
end

-- shallow join all objects, it will not expand all table values
function __shallow_join2(...)
    local args = {...}
    return function (subject)
        return __(table.shallow_join2(subject, table.unpack(args)))
    end
end

-- swap items in array
function __swap(i, j) return function (subject)
    return __(table.swap(subject, i, j))
end end

-- append all objects to array
function __append(...)
    local args = {...}
    return function (subject)
        return __(table.append(subject, table.unpack(args)))
    end
end

-- clone table
--
-- @param depth   e.g. shallow: 1, deep: -1
--
function __clone(depth) return function (subject)
    return __(table.clone(subject, depth))
end end

-- copy the table to self
function __copy2(copied) return function (subject)
    return __(table.copy2(subject, copied))
end end

-- inherit interfaces from the given class
function __inherit2(...)
    local args = {...}
    return function (subject)
        return __(table.inherit2(subject, table.unpack(args)))
    end
end

-- slice table array
function __slice(first, last, step) return function (subject)
    return __(table.slice(subject, first, last, step))
end end

function __is_array() return function (subject)
    return table.is_array(subject)
end end

function __is_dictionary() return function (subject)
    return table.is_dictionary(subject)
end end

function __contains(arg1, arg2, ...)
    local args = {...}
    return function (subject)
        return table.contains(subject, arg1, arg2, table.unpack(args))
    end
end

-- unwrap array if it has only one value
function __unwrap() return function (subject)
    return table.unwrap(subject)
end end

-- remove repeat from the given array
function __unique(barrier) return function (subject)
    return __(table.unique(subject, barrier))
end end

-- reverse to remove repeat from the given array
function __reverse_unique(barrier) return function (subject)
    return __(table.reverse_unique(subject, barrier))
end end

-- table.unpack table values
-- polyfill of lua 5.2, @see https://www.lua.org/manual/5.2/manual.html#pdf-unpack
function __unpack() return function (subject)
    return table.unpack(subject)
end end

function __keys() return function (subject)
    return __(table.keys(subject))
end end

function __orderkeys(callback) return function (subject)
    return __(table.orderkeys(subject, callback))
end end

function __orderpairs(callback) return function (subject)
    return __(table.orderpairs(subject, callback))
end end

function __values() return function (subject)
    return __(table.values(subject))
end end

function __map(mapper) return function (subject)
    return __(table.map(subject, mapper))
end end

function __imap(mapper) return function (subject)
    return __(table.imap(subject, mapper))
end end

function __reverse() return function (subject)
    return __(table.reverse(subject))
end end

function __remove(i) return function (subject)
    return __(table.remove(subject, i))
end end

function __remove_if(pred) return function (subject)
    return __(table.remove_if(subject, pred))
end end

function __keep_if(pred) return function (subject)
    return __(table.remove_if(subject, function (...) return not pred(...) end))
end end

__filter = __keep_if

-- is empty table?
function __empty() return function (subject)
    return table.empty(subject)
end end

-- return indices or keys for the given value
function __find(value) return function (subject)
    return __(table.find(subject, value))
end end

-- return indices or keys if predicate is matched
function __find_if(pred) return function (subject)
    return __(table.find_if(subject, pred))
end end

-- return first index for the given value
function __find_first(value) return function (subject)
    return table.find_first(subject, value)
end end

-- return first index if predicate is matched
function __find_first_if(pred) return function (subject)
    return table.find_first_if(subject, pred)
end end

function __skip(n) return function (subject)
    return __(table.slice(subject, 1, #subject - n))
end end

function __take(n) return function (subject)
    return __(table.slice(subject, 1, n))
end end

-- drop items until the first value is matched
function __skip_from(v, offset) return function (subject)
    local splitAt = table.find_first(subject, v) + (offset or 0)
    return __(table.slice(subject, splitAt))
end end

-- drop items after the first value is matched
function __take_until(v, offset) return function (subject)
    local splitAt = table.find_first(subject, v)
    return splitAt and table.slice(subject, 1, splitAt + (offset or 0)) or subject
end end

function __array_to_string(separator, default) return function (subject)
    default = default or ""
    if table.empty(subject) then return default end

    local result = subject[1]
    for i = 2, #subject, 1 do
        result = result .. separator .. subject[i]
    end
    return result
end end