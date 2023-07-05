local env = getfenv()
local storage = {}
local created = {}
local metaMethods = {
	"__index",
	"__newindex",
	"__call",
	"__concat",
	"__unm",
	"__add",
	"__sub",
	"__mul",
	"__div",
	"__mod",
	"__pow",
	"__tostring",
	"__metatable",
	"__eq",
	"__lt",
	"__le",
	"__mode",
	"__gc",
	"__len",
	"__return",
	"__readonly"
}
local function packtuple(...)
	local packed = table.pack(...)
	packed.n = nil
	return packed
end
local function range(min, max, add, func)
	local storage = {}
	for i = min, max, add do
		local yield = i % (10 * add) == 0
		if yield then
			storage.args = packtuple(func(i, yield, task.wait()))
			if storage.args[1] then
				break
			end
		else
			storage.args = packtuple(func(i, yield, 0))
			if storage.args[1] then
				break
			end
		end
	end
	return table.unpack(storage.args or table.create(0))
end
local function read(list, func)
	local storage = {n = 0}
	for i,v in pairs(list) do
		local n = storage.n
		storage.n = n + 1
		local yield = (n + 1) % 10 == 0
		if yield then
			storage.args = packtuple(func(i, v, yield, task.wait()))
			if storage.args[1] then
				break
			end
		else
			storage.args = packtuple(func(i, v, yield, 0))
			if storage.args[1] then
				break
			end
		end
	end
	return table.unpack(storage.args or table.create(0))
end
local function forever(func)
	local storage = {n = 0}
	while true do
		local n = storage.n
		storage.n = n + 1
		local yield = (n + 1) % 10 == 0
		if yield then
			storage.args = packtuple(func(n, yield, task.wait()))
			if storage.args[1] then
				break
			end
		else
			storage.args = packtuple(func(n, yield, 0))
			if storage.args[1] then
				break
			end
		end
	end
	return table.unpack(storage.args or table.create(0))
end
local function setproperty(target, index, value)
	if tonumber(index) then
		value.Parent = target
	else
		target[index] = value
	end
end
local function setproperties(Properties, inst)
	if Properties then
		local selfFunc = Properties.__self
		if selfFunc then
			Properties.__self = nil
			assert(typeof(selfFunc) == "function","__self index is expected to be a function")
			task.spawn(function()
				local env = setmetatable({self = Properties},{__index = function(self,i)
						return rawget(self, i) or env[i]
					end,
					__newindex = function(self,i,v)
						rawset(self,i,v)
					end})
				setfenv(selfFunc,env)(inst)
			end)
		end
		if Properties.CanPropertyYield then
			Properties.CanPropertyYield = nil
			read(Properties,function(i,v)
				setproperty(inst,i,v)
			end)
		else
			task.spawn(function()
				read(Properties,function(i,v)
					setproperty(inst,i,v)
				end)
			end)
		end
	end
end
local function clone(inst)
	if not storage.clonable then
		storage.clonable = Instance.new("Script")
	end
	if inst then
		local archivable = inst.Archivable
		inst.Archivable = true
		local newInst = storage.clonable.Clone(inst)
		inst.Archivable = archivable
		return newInst
	end
end
local function create(Class, Parent, Properties)
	if not storage.cache then
		storage.cache = {}
	end
	local realInst
	local createdClonableInst = storage.cache[Class]
	if not createdClonableInst then
		local inst = Instance.new(Class)
		storage.cache[Class] = inst
		realInst = clone(inst)
	else
		realInst = clone(createdClonableInst)
	end
	if realInst ~= nil then
		if Properties and Properties ~= true then
			setproperties(Properties,realInst)
		elseif Properties == true then
			return function(Properties)
				setproperties(Properties,realInst)
				realInst.Parent = Parent
				return realInst
			end
		end
		if Parent then
			realInst.Parent = Parent
		end
	end
	table.insert(created, realInst)
	return realInst
end
local function checkMetamethod(toWritte, index, value)
	if table.find(metaMethods, index) then
		toWritte[index] = value
	end
end
local lib = {
	Utilities = {
		newEvent = function(eventName, callerName, methodOrFunction)
			local methodOrFunction = methodOrFunction and methodOrFunction or "Method"
			local storage = {
				event = create("BindableEvent"),
				Connections = {}
			}
			local returned = {
				[eventName] = setmetatable({}, {
					__index = function(self, i)
						return rawget(self, i) or storage.event[i]
					end,
					__metatable = "This metatable is locked."
				}),
				Enabled = true,
				Disabled = false
			}
			setmetatable(returned, {
				__newindex = function(self, i, v)
					if i == "Enabled" then
						rawset(self, "Disabled", not v)
					elseif i == "Disabled" then
						rawset(self, "Enabled", not v)
					else
						rawset(self, i, v)
					end
				end,
				__metatable = "This metatable is locked."
			})
			local event = returned[eventName]
			function returned:GetConnections()
				return storage.Connections
			end
			function returned:DisconnectAll()
				read(storage.Connections, function(i, connection)
					connection:Disconnect()
				end)
			end
			returned[callerName or "Fire"] = function(self, ...)
				if methodOrFunction == "Method" then
					storage.args = packtuple(...)
					storage.event:Fire()
				else
					storage.args = packtuple(self, ...)
					storage.event:Fire()
				end
			end
			function event:Connect(func)
				assert(returned.Enabled and not returned.Disabled, "This signal is disabled.")
				local connection = storage.event.Event:Connect(function()
					func(table.unpack(storage.args))
				end)
				table.insert(storage.Connections, connection)
				return connection
			end
			function event:ConnectParallel(func)
				assert(returned.Enabled and not returned.Disabled, "This signal is disabled.")
				local connection = storage.event.Event:ConnectParallel(function()
					func(table.unpack(storage.args))
				end)
				table.insert(storage.Connections, connection)
				return connection
			end
			function event:Once(func)
				assert(returned.Enabled and not returned.Disabled, "This signal is disabled.")
				local connection = storage.event.Event:Once(function()
					func(table.unpack(storage.args))
				end)
				table.insert(storage.Connections, connection)
				return connection
			end
			function event:Wait(waittime, silent)
				assert(returned.Enabled and not returned.Disabled, "This signal is disabled.")
				local waittime = tonumber(waittime) or math.huge
				local waitStorage = {
					CurrentWaitTime = 0,
					Warned = false
				}
				task.spawn(function()
					storage.event.Event:Wait()
					waitStorage.args = storage.args
				end)
				repeat
					waitStorage.CurrentWaitTime = waitStorage.CurrentWaitTime + task.wait()
					if not waitStorage.Warned and waitStorage.CurrentWaitTime >= 5 and waittime > 5 then
						waitStorage.Warned = true
						warn("Infinite yield possible on event '"..eventName.."'")
					end
					if waitStorage.CurrentWaitTime >= waittime then
						assert(silent, "Hit wait deadline.")
						break
					end
				until waitStorage.args
				return table.unpack(waitStorage.args or table.create(0))
			end
			event.connect = event.Connect
			event.connectparallel = event.ConnectParallel
			event.once = event.Once
			event.wait = event.Wait
			return returned
		end,
		Random = function(min, max, seed)
			local newRandomSeed = Random.new(seed)
			if min and max then
				int = newRandomSeed:NextInteger(min,max)
				num = newRandomSeed:NextNumber(min,max)
			else
				int = 0
				num = newRandomSeed:NextNumber()
			end
			local unit = newRandomSeed:NextUnitVector()
			local rt = {Unit = unit,Integer = int,Number = num,Generator = newRandomSeed}
			return rt
		end,
		Pack = packtuple
		},
	Destroy = function(target, delay)
		if target then
			task.delay(tonumber(delay) or 0, game.Destroy, target)
		end
	end,
	Clone = clone,
	Loops = {
		range = range,
		read = read,
		forever = forever
	}
}
lib.Create = create
lib.Utilities.newMetatable = function(public)
	local publicMeta = getmetatable(public)
	local publicStorage = typeof(public) == "userdata" and typeof(publicMeta) == "table" and {} or nil
	local hidden = publicStorage and typeof(publicMeta) == "table" and publicMeta or {}
	lib.Loops.read(publicStorage or public, function(index, value)
		checkMetamethod(hidden, index, value)
	end)
	if publicStorage then
		lib.Loops.read(publicMeta, function(index, value)
			publicStorage[index] = value
		end)
	end
	local function Copy(...)
		if typeof(public) == "table" then
			local newPublic = {}
			lib.Loops.read(public, function(index, value)
				if not table.find(metaMethods, index) then
					newPublic[index] = value
				end
			end)
			local newHidden = table.clone(hidden)
			newHidden.__metatable = newPublic
			setmetatable(newPublic, newHidden)
			if rawget(public, "__readonly") then
				local readonly_type = typeof(rawget(public, "__readonly"))
				assert(readonly_type == "boolean", "Expected 'boolean' not '"..readonly_type.."') for metamethod __readonly")
				local readonly = newproxy(true)
				local readonlymeta = getmetatable(readonly)
				readonlymeta.__metatable = "This metatable is locked."
				readonlymeta.__index = function(self, index)
					if not table.find(metaMethods, index) then
						return newPublic[index]
					end
				end
				readonlymeta.__newindex = function(self, index, value)
					error("Unable to set index '"..index.."' table in read-only")
				end
				return readonly, ...
			else
				return newPublic, ...
			end
		elseif typeof(public) == "userdata" then
			local newPublic = {}
			lib.Loops.read(publicStorage, function(index, value)
				if not table.find(metaMethods, index) then
					newPublic[index] = value
				end
			end)
			local newHidden = table.clone(hidden)
			newHidden.__metatable = newPublic
			setmetatable(newPublic, newHidden)
			if publicStorage.__readonly then
				local readonly_type = typeof(publicStorage.__readonly)
				assert(readonly_type == "boolean", "Expected 'boolean' not '"..readonly_type.."') for metamethod __readonly")
				local readonly = newproxy(true)
				local readonlymeta = getmetatable(readonly)
				readonlymeta.__metatable = "This metatable is locked."
				readonlymeta.__index = function(self, index)
					if not table.find(metaMethods, index) then
						return newPublic[index]
					end
				end
				readonlymeta.__newindex = function(self, index, value)
					error("Unable to set index '"..index.."' table in read-only")
				end
				return readonly, ...
			else
				return newPublic, ...
			end
		end
	end
	hidden.__call = function(self, ...)
		if publicStorage then
			if publicStorage.__call then
				local Arguments = lib.Utilities.Pack(publicStorage.__call(self, ...))
				return Copy(table.unpack(Arguments), publicStorage.__return and typeof(publicStorage.__return) == "table" and table.unpack(publicStorage.__return) or publicStorage.__return)
			end
			return Copy(publicStorage.__return and typeof(publicStorage.__return) == "table" and table.unpack(publicStorage.__return) or publicStorage.__return)
		else
			if rawget(public, "__call") then
				local Arguments = lib.Utilities.Pack(rawget(public, "__call")(self, ...))
				return Copy(table.unpack(Arguments), rawget(public, "__return") and typeof(rawget(public, "__return")) == "table" and table.unpack(rawget(public, "__return")) or rawget(public, "__return"))
			end
			return Copy(rawget(public, "__return") and typeof(rawget(public, "__return")) == "table" and table.unpack(rawget(public, "__return")) or rawget(public, "__return"))
		end
	end
	if publicStorage then
		hidden.__index = function(self, index)
			local value = publicStorage[index]
			if publicStorage.__index and string.sub(index, 1, 2) ~= "__" then
				return publicStorage:__index(index)
			end
			if value and typeof(value) == "table" then
				if value.__TableValue then
					return value.__TableValue
				end
			end
			return value
		end
		hidden.__newindex = function(self, index, value)
			if publicStorage.__newindex then
				publicStorage.__newindex(self, index, value)
			else
				local oldValue = publicStorage[index]
				if oldValue and typeof(oldValue) == "table" then
					if oldValue.__TableReadOnly then
						local readonly_type = typeof(oldValue.__TableReadOnly)
						assert(readonly_type == "boolean", "Expected 'boolean' not '"..readonly_type.."') for table method __TableReadOnly")
						error("Attempt to set read-only value")
					end
				end
				publicStorage[index] = value
			end
			checkMetamethod(hidden, index, value)
		end
	else
		hidden.__index = function(self, index)
			local value = rawget(public, index)
			local __index = rawget(public, "__index")
			if __index and string.sub(index, 1, 2) ~= "__" then
				return __index(self, index)
			end
			if value and typeof(value) == "table" then
				if value.__TableValue then
					return value.__TableValue
				end
			end
			return value
		end
		hidden.__newindex = function(self, index, value)
			local __newindex = rawget(public, "__newindex")
			if __newindex then
				__newindex(self, index, value)
			else
				local oldValue = rawget(public, index)
				if oldValue and typeof(oldValue) == "table" then
					if oldValue.__TableReadOnly then
						local readonly_type = typeof(oldValue.__TableReadOnly)
						assert(readonly_type == "boolean", "Expected 'boolean' not '"..readonly_type.."') for table method __TableReadOnly")
						error("Attempt to set read-only value")
					end
				end
				rawset(public, index, value)
			end
			checkMetamethod(hidden, index, value)
		end
	end
	if typeof(public) == "table" then
		setmetatable(public, hidden)
	else
		lib.Loops.read(hidden, function(index, value)
			checkMetamethod(publicMeta, index, value)
		end)
	end
	return publicStorage or public
end
lib.Utilities.RandomString = function(length, seed, start, end_)
	local storage = {result = ""}
	if tonumber(length) and length > 1 then
		for i = 1, length do
			storage.result = storage.result..utf8.char(lib.Utilities.Random(start or 0, end_ or 1114111, seed).Integer)
		end
	else
		return utf8.char(lib.Utilities.Random(start or 0, end_ or 1114111, seed).Integer)
	end
	return storage.result
end
lib.Utilities.fastSpawn = function(func, ...)
	local thread_ = {passedArgs = lib.Utilities.Pack(...)}
	if not storage.fastSpawnRemote then
		storage.fastSpawnRemote = lib.Create("BindableEvent")
	end
	storage.fastSpawnRemote.Event:Once(function()
		thread_.thread = coroutine.running()
		if typeof(func) == "function" then
			thread_.args = lib.Utilities.Pack(func(table.unpack(thread_.passedArgs)))
		elseif typeof(func) == "thread" then
			thread._args = lib.Utilities.Pack(coroutine.resume(func, table.unpack(thread_.passedArgs)))
		end
	end)
	storage.fastSpawnRemote:Fire()
	return thread_.thread, table.unpack(thread_.args or table.create(0))
end
lib.Utilities.GetCreated = function(getnil)
	local found = {}
	if getnil then
		return created
	else
		lib.Loops.read(created, function(i,v)
			if v.Parent ~= nil then
				table.insert(found, v)
			end
		end)
		return found
	end
end
return lib
