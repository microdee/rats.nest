--[[
    Add namespacing utilities with certain rules for mapping a folder structure to a namespace
]]

if NS then return end NS = { nsScopes = {} }

includes("tt.lua")

local ns = ns or {}

-- Get a name based on the top level folder
function NS.this_pack_name()
    return path.filename(path.absolute("."):trim("/"))
end

-- get the current namespace this object represents
function ns:current()
    return array_to_string(".")(self._stack)
end

-- push a sub-namespace
function ns:push(name)
    append(name or NS.this_pack_name())(self._stack)
end

-- pop a sub-namespace
function ns:pop()
    remove(#self._stack)(self._stack)
end

--[[
    Convert a top level name to its namespaced version, e.g.:

    local ns = NS.use("foo.bar")
    ns:n("my_stuff")
    -- returns "foo.bar.my_stuff"
]]
function ns:n(name)
    if name then
        self.scope._names[name] = true
        return self:current() .. "." .. name
    else
        return self:current()
    end
end

function NS.get_from_all_scopes(namespace, predicate, getter, default)
    local levels = {}
    if     type(namespace) == "string" then levels = namespace:split(".", {plain = true})
    elseif type(namespace) == "table"  then levels = namespace
    end

    local currentNs = array_to_string(".")(levels);
    local currentNsScope = NS.nsScopes[currentNs];
    if currentNsScope and predicate(currentNs, currentNsScope) then
        return getter(currentNs, currentNsScope)
    end

    return #levels > 1 and NS.get_from_all_scopes(skip(1)(levels), predicate, getter, default) or default
end

function NS.get_fullname(namespace, name)
    return NS.get_from_all_scopes(
        namespace,
        function (currentNs, currentNsScope) return currentNsScope._names[name] end,
        function (currentNs, currentNsScope) return currentNs .. "." .. name end
    )
end

-- Search current or parent namespaces to get a fully namespaced name from a top level name
function ns:full(name)
    return NS.get_fullname(self._stack, name)
end

function NS.get_scope_value(namespace, name)
    return NS.get_from_all_scopes(
        namespace,
        function (currentNs, currentNsScope) return currentNsScope[name] ~= nil end,
        function (currentNs, currentNsScope) return currentNsScope[name] end
    )
end

--[[
    Get an arbitrary property from current or parent namespace scopes
    Set these with

    local ns = NS.use()
    ns.scope.mystuff = "foobar"

    ns.push("deeper")
        ns:get("mystuff")
        -- returns "foobar"
]]
function ns:get(name)
    return NS.get_scope_value(self._stack, name)
end

--[[
    Shorthand for ns:get(...) for unified way of enabling / disabling a scope. The default state is
    always enabled, even when that's not set explicitly anywhere.
    Set these with

    local ns = NS.use()
    ns.scope.enabled = {false}
    
    ns.push("deeper")
        ns:enabled()
        -- returns "false"

    note the boolean is wrapped in a table, this is intentional to distinguish `false` from `nil`
    in if conditions
]]
function ns:enabled()
    local result = self:get("enabled")
    if result == nil then return true end
    return result[1]
end

--[[
    Create or reference an already created namespace scope. Arguments are optional.
    If empty the namespace is inferred from the folder structure the invoking script is inside the
    following way:

    * Root namespace folder is "/packs", it can be changed in `rats_globals` object
    * The actual namespace ends at the grand-parent folder of the script.
      Except if withPack is provided as option via `NS.use { withPack = true }` in which case the
      parent folder is used.
    * Folders with a single letter will be ignored from the stack of namespaces.
      This is done for XRepo support
    * Any folders after and including `_build` will be ignored.

    Example mappings:

    /packs/rats/core/imgui/xmake.lua                  --> rats.core
    /packs/rats/core/imgui/xmake.lua                  --> rats.core.imgui { withPack = true }
    /packs/rats/core/_build/config.lua                --> rats.core
    /packs/rats/core/_build/subfolder/elaborate.lua   --> rats.core
    /packs/rats/core/v/vulkan/u/utils/xmake.lua       --> rats.core.vulkan
]]
function NS.use(args)
    local options = {}
    if type(args) == "string" then
        options.ns = args
    elseif type(args) == "table" then
        options = args
    end

    local basis = options.withPack and path.absolute(".") or path.directory(path.absolute("."))
    local autoNs = basis
        :replace(-rats_globals.paths.packs, "", {plain = true})
        :replace("\\", ".", {plain = true})
        :replace("/", ".", {plain = true})
        :trim(".")

    local namespace = options.ns or autoNs;
    local result = table.inherit(ns);
    NS.nsScopes[namespace] = NS.nsScopes[namespace] or {
        _names = {}
    }
    result._stack = tt(namespace:split(".", {plain = true}))
        | take_until("_build")
        | remove_if(function (i, item) return #item <= 1 end)

    result.scope = NS.nsScopes[namespace]
    return result
end