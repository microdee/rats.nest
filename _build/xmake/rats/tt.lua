------ commonly used extensions for tables

if Table then return end Table = {}
local table = table or {}
local operand = {}

--[[
    this function gives any tables common operator overloads:
    
    ### | (__bor) -> piping
    Feed the left side operand table into a right side operand function (mimmicking UFCS)

    In Description scope:
    includes("rats/tt.lua")
    tt({1, 2, 3, 4}) | slice(2, 3) | reverse()

    In Script scope:
    import("rats.tt")
    tt({1, 2, 3, 4}) | tt.slice(2, 3) | tt.reverse()
]]
function tt(subject)
    if type(subject) == "nil" then
        subject = {}
    end
    if subject.is_tt then return subject end
    if type(subject) == "table" then
        return table.inherit2(subject, operand)
    end
    return subject
end

function main(subject)
    return tt(subject)
end

--[[
    indicates that table can be used as a common operand
]]
function operand.is_tt() return true end

function operand.__bor(subject, value)
    return value(subject)
end

function clear() return function (subject)
    return tt(table.clear(subject))
end end

-- get array max integer key for lua5.4
function maxn() return function (subject)
    return table.maxn(subject)
end end

-- join all objects and tables to self
function join2(...)
    local args = {...}
    return function (subject)
        return tt(table.join2(subject, table.unpack(args)))
    end
end

-- shallow join all objects, it will not expand all table values
function shallow_join2(...)
    local args = {...}
    return function (subject)
        return tt(table.shallow_join2(subject, table.unpack(args)))
    end
end

-- swap items in array
function swap(i, j) return function (subject)
    return tt(table.swap(subject, i, j))
end end

-- append all objects to array
function append(...)
    local args = {...}
    return function (subject)
        return tt(table.append(subject, table.unpack(args)))
    end
end

-- clone table
--
-- @param depth   e.g. shallow: 1, deep: -1
--
function clone(depth) return function (subject)
    return tt(table.clone(subject, depth))
end end

-- copy the table to self
function copy2(copied) return function (subject)
    return tt(table.copy2(subject, copied))
end end

-- inherit interfaces from the given class
function inherit2(...)
    local args = {...}
    return function (subject)
        return tt(table.inherit2(subject, table.unpack(args)))
    end
end

-- slice table array
function slice(first, last, step) return function (subject)
    return tt(table.slice(subject, first, last, step))
end end

function is_array() return function (subject)
    return table.is_array(subject)
end end

function is_dictionary() return function (subject)
    return table.is_dictionary(subject)
end end

function contains(arg1, arg2, ...)
    local args = {...}
    return function (subject)
        return table.contains(subject, arg1, arg2, table.unpack(args))
    end
end

-- unwrap array if it has only one value
function unwrap() return function (subject)
    return table.unwrap(subject)
end end

-- remove repeat from the given array
function unique(barrier) return function (subject)
    return tt(table.unique(subject, barrier))
end end

-- reverse to remove repeat from the given array
function reverse_unique(barrier) return function (subject)
    return tt(table.reverse_unique(subject, barrier))
end end

-- table.unpack table values
-- polyfill of lua 5.2, @see https://www.lua.org/manual/5.2/manual.html#pdf-unpack
function unpack() return function (subject)
    return table.unpack(subject)
end end

-- get keys of a table
function keys() return function (subject)
    return tt(table.keys(subject))
end end

-- get ordered keys of a table
function orderkeys(callback) return function (subject)
    return tt(table.orderkeys(subject, callback))
end end

-- ordered key/value iterator
function orderpairs(callback) return function (subject)
    return tt(table.orderpairs(subject, callback))
end end

-- get values of a table
function values() return function (subject)
    return tt(table.values(subject))
end end

-- map values to a new table
function map(mapper) return function (subject)
    return tt(table.map(subject, mapper))
end end

function imap(mapper) return function (subject)
    return tt(table.imap(subject, mapper))
end end

function reverse() return function (subject)
    return tt(table.reverse(subject))
end end

function remove(i) return function (subject)
    return tt(table.remove(subject, i))
end end

function remove_if(pred) return function (subject)
    return tt(table.remove_if(subject, pred))
end end

function keep_if(pred) return function (subject)
    return tt(table.remove_if(subject, function (...) return not pred(...) end))
end end

filter = keep_if

-- is empty table?
function empty() return function (subject)
    return table.empty(subject)
end end

-- return indices or keys for the given value
function find(value) return function (subject)
    return tt(table.find(subject, value))
end end

-- return indices or keys if predicate is matched
function find_if(pred) return function (subject)
    return tt(table.find_if(subject, pred))
end end

-- return first index for the given value
function find_first(value) return function (subject)
    return table.find_first(subject, value)
end end

-- return first index if predicate is matched
function find_first_if(pred) return function (subject)
    return table.find_first_if(subject, pred)
end end

function skip(n) return function (subject)
    return tt(table.slice(subject, 1, #subject - n))
end end

function take(n) return function (subject)
    return tt(table.slice(subject, 1, n))
end end

-- drop items until the first value is matched
function skip_from(v, offset) return function (subject)
    local splitAt = table.find_first(subject, v) + (offset or 0)
    return tt(table.slice(subject, splitAt))
end end

-- drop items after the first value is matched
function take_until(v, offset) return function (subject)
    local splitAt = table.find_first(subject, v)
    return splitAt and table.slice(subject, 1, splitAt + (offset or 0)) or subject
end end

function array_to_string(separator, default) return function (subject)
    default = default or ""
    if table.empty(subject) then return default end

    local result = subject[1]
    for i = 2, #subject, 1 do
        result = result .. separator .. subject[i]
    end
    return result
end end

function table.default_from(subject, from)
    subject = subject or {}
    for k, v in pairs(from) do
        if type(subject[k]) == "table" and type(v) == "table" then
            table.default_from(subject[k], v)
        elseif type(subject[k]) == "nil" then
            subject[k] = v
        end
    end
    return subject
end

function default(from) return function (subject)
    return table.default_from(subject, from)
end end

function table.merge_from(subject, from)
    subject = subject or {}
    for k, v in pairs(from) do
        if type(subject[k]) == "table" and type(v) == "table" then
            table.merge_from(subject[k], v)
        else
            subject[k] = v
        end
    end
    return subject
end

function merge(from) return function (subject)
    return table.merge_from(subject, from)
end end