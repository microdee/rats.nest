if NS then return end NS = { nsScopes = {} }

includes("table.lua")

local ns = ns or {}

function NS.this_pack_name()
    return path.filename(path.absolute("."):trim("/"))
end

function ns:current()
    return self._stack
        :__clone()
        :__array_to_string(".")
end

function ns:push(name)
    table.append(self._stack, name or NS.this_pack_name())
end

function ns:pop()
    table.remove(self._stack, #self._stack)
end

function ns:n(name)
    self.scope._names[name] = true
    return self:current() .. "." .. name
end

function NS.get_from_all_scopes(namespace, predicate, getter, default)
    local levels = {}
    if     type(namespace) == "string" then levels = namespace:split(".", {plain = true})
    elseif type(namespace) == "table"  then levels = namespace
    end

    local currentNs = levels:__array_to_string(".");
    local currentNsScope = NS.nsScopes[currentNs];
    if currentNsScope and predicate(currentNs, currentNsScope) then
        return getter(currentNs, currentNsScope)
    end

    return #levels > 1 and NS.get_from_all_scopes(levels:__skip(1), predicate, getter, default) or default
end

function NS.get_fullname(namespace, name)
    return NS.get_from_all_scopes(
        namespace,
        function (currentNs, currentNsScope) return currentNsScope._names[name] end,
        function (currentNs, currentNsScope) return currentNs .. "." .. name end
    )
end

function ns:full(name)
    return NS.get_fullname(self._stack, name)
end

function NS.get_scope_value(namespace, name)
    return NS.get_from_all_scopes(
        namespace,
        function (currentNs, currentNsScope) return currentNsScope[name] end,
        function (currentNs, currentNsScope) return currentNsScope[name] end
    )
end

function ns:get(name)
    return NS.get_scope_value(self._stack, name)
end

function ns:enabled()
    return ns:get("enabled") or true
end

function NS.use(args)
    local options = {}
    if type(args) == "string" then
        options.ns = args
    elseif type(args) == "table" then
        options = args
    end

    local basis = options.withPack and path.absolute(".") or path.directory(path.absolute("."))
    local autoNs = basis
        :replace(rats_globals.paths.packs, "")
        :replace("\\", ".", {plain = true})
        :replace("/", ".", {plain = true})
        :trim(".")

    local namespace = options.ns or autoNs;
    local result = table.inherit(ns);
    NS.nsScopes[namespace] = NS.nsScopes[namespace] or {
        _names = {}
    }
    result._stack = namespace
        :split(".", {plain = true})

    result.scope = NS.nsScopes[namespace]
    return result
end