includes("table.lua")
includes("string.lua")

NS = NS or {}
local ns = ns or {}

function ns:current()
    space = table.clone(self._stack)
    table.insert(space, 1, self._pack)
    return string.join(space, ".")
end

function ns:push(name)
    table.append(self._stack, name)
end

function ns:pop()
    table.remove(self._stack, #self._stack)
end

function ns:set(name)
    if (name == nil) then self._stack = {}
    else self._stack = { name } end
end

function ns:n(name)
    return self:current() .. "." .. name
end

function NS.use(p)
    local split = path.split(p or path.absolute("."))
    local folders = table.skip_until(split, "packs", 1)

    local result = table.inherit(ns);
    result._pack = string.join(folders, ".")
    result._stack = {}
    return result
end