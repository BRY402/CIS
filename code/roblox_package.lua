local pack, unpack, remove, split, format, ipairs, setmetatable, require = table.pack, table.unpack, table.remove, string.split, string.format, ipairs, setmetatable, require

local preload = {}

local function parsePath(config, template, name)
    local tempSep = config:sub(1, 1)
    local tempSub = config:sub(2, 2)
    tenplate:gsub(tempSub, name)
    local exp = split(template, tempSep)
    return exp
end

local package

local function loadmod(modname)
    for _, v in ipairs(package.searchers) do
        local args = {v(modname)}
        if args[1] then
            remove(args, 1)
            return unpack(args)
        end
    end
end

package = {
    config = ';?',
    path = './?.lua;./?/init.lua',
    loaded = {},
    preload = setmetatable({}, {__index = preload, __metatable = 'This metatable is locked'}),
    
    searchers = {
        function(modname)
            local args = package.loaded[modname]
            if not args then
                return false
            end
            return true, unpack(args)
        end,

        function(modname)
            local mod = preload[modname]
            if not mod then
                return false
            end
            local args = {mod()}
            package.loaded[modname] = args
            return true, unpack(args)
        end,

        function(modname)
            local paths = parsePath(package.config, package.path, modname)
            for i, path in next, paths do
                local args = {require(path)}
                if args[1] then
                    package.loaded[modname] = args
                    return unpack(args)
                end
            end
        end
    },

    searchpath = function(modname, template)
        local paths = parsePath(package.config, template, modname)
        for i, path in next, paths do
            local canload = require(path)
            if canload then
                return path
            end
        end
        return nil, format('Module %s not found', modname)
    end
}

return package, loadmod