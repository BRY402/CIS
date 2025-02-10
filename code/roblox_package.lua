local pack, unpack, remove, concat, split, format, ipairs, setmetatable, require = table.pack, table.unpack, table.remove, table.concat, string.split, string.format, ipairs, setmetatable, require

local preload = {}

local function parseTemp(config, template, name)
    local tempSep = config:sub(1, 1)
    local tempSub = config:sub(2, 2)
    template = tenplate:gsub(tempSub, name)
    local exp = split(template, tempSep)
    
    return exp
end

local function parsePath(config, path, from)
    local dirSep = config:sub(3, 3)
    local dirPar = config:sub(4, 4)
    local currentInstance = from or script
    path = path..'/'
    
    for i = 1, #path do
        local char = path:sub(i, i)
        
        if char:match(format('^%s', dirPar)) then
            currentInstance = currentInstance.Parent or currentInstance
        end
        
        local dir = path:sub(i, #path):match(format('^%s(.-)%s', dirSep, dirSep))
        
        if not dir or not currentInstance then
            return currentInstance and currentInstance:IsA('ModuleScript'), (not currentInstance or not currentInstance:IsA('ModuleScript')) and format('no module %s', path)
        end
        
        currentInstance = currentInstance:FindFirstChild(dir)
    end
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
    config = ';?/.',
    path = './?;./?/init',
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
            local mod = package.searchpath(modname, package.path)
            if not mod then
                return false
            end
            local args = {require(mod)}
            package.loaded[modname] = args
            return true, unpack(args)
        end
    },

    searchpath = function(modname, template)
        local paths = parseTemp(package.config, template, modname)
        local checked = {}
        for i, path in ipairs(paths) do
            local mod, err = parsePath(package.config, path, script)
            if mod then
                return mod
            end
            checked[i] = err
        end
        return nil, concat(checked, '\n')
    end
}

return package, loadmod
