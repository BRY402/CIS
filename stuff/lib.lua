local deb = game:GetService("Debris")
local rs = game:GetService("RunService")
local storage = {}
local nilinstances = {}
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
local function range(min, max, add, func)
	for i = min, max, add do
		local yield = i % (10 * add) == 0
		if yield then
			func(i, yield, task.wait())
		else
			func(i, yield, 0)
		end
	end
end
local function read(list, func)
	local number = {0}
	for i,v in pairs(list) do
		local n = number[1]
		number[1] = n + 1
		local yield = (n + 1) % 10 == 0
		if yield then
			func(i, v, yield, task.wait())
		else
			func(i, v, yield, 0)
		end
	end
end
local function forever(func)
	local number = {0}
	while true do
		local n = number[1]
		number[1] = n + 1
		local yield = (n + 1) % 10 == 0
		if yield then
			func(n, yield, task.wait())
		else
			func(n, yield, 0)
		end
	end
end
local function isnilparent(target)
		if target.Parent == nil then
			table.insert(nilinstances,target)
		else
			table.remove(nilinstances,table.find(nilinstances,target))
		end
	target:GetPropertyChangedSignal("Parent"):Connect(function()
		if target.Parent == nil then
			table.insert(nilinstances,target)
		else
			table.remove(nilinstances,table.find(nilinstances,target))
		end
	end)
end
local function setproperty(target, index, value)
	if tonumber(index) then
		value.Parent = target
		isnilparent(value)
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
				local env = setmetatable({self = Properties,
					Parent = Parent},{__index = function(self,i)
						return rawget(self,i) or getfenv()[i]
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
			table.foreach(Properties,function(i,v)
				setproperty(inst,i,v)
			end)
		end
	end
end
local function packtuple(...)
	local packed = table.pack(...)
	packed.n = nil
	return packed
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
			local Connections = {}
			local returned = {[eventName] = {}}
			function returned:GetConnections()
				return Connections
			end
			returned[callerName] = function(self,...)
				if methodOrFunction == "Method" then
					local args = packtuple(...)
					read(Connections,function(i,Connection)
						Connection:Call(unpack(args))
						if Connection.Type == "Once" or Connection.Type == "Wait" then
							table.remove(Connections,Connection)
						end
					end)
				else
					local args = packtuple(self,...)
					read(Connections,function(i,Connection)
						Connection:Call(unpack(args))
						if Connection.Type == "Once" or Connection.Type == "Wait" then
							table.remove(Connections,Connection)
						end
					end)
				end
			end
			local event = returned[eventName]
			function event:Connect(func)
				local calledConnection = {Type = "Connect"}
				function calledConnection:Call(...)
					task.spawn(func,...)
				end
				table.insert(Connections,calledConnection)
				local Connection = {}
				function Connection:Disconnect()
					assert(table.find(Connections,func),"Connection was already disconnected")
					table.remove(Connections,func)
				end
				Connection.disconnect = Connection.Disconnect
				return Connection
			end
			function event:ConnectParallel(func)
				assert(script:GetActor(),"Script must have an actor")
				local calledConnection = {Type = "ConnectParellel"}
				function calledConnection:Call(...)
					task.desynchronize()
					task.spawn(func,...)
				end
				table.insert(Connections,calledConnection)
				local Connection = {}
				function Connection:Disconnect()
					assert(table.find(Connections,func),"Connection was already disconnected")
					table.remove(Connections,func)
				end
				Connection.disconnect = Connection.Disconnect
				return Connection
			end
			function event:Once(func)
				local calledConnection = {Type = "Once"}
				function calledConnection:Call(...)
					task.spawn(func,...)
				end
				table.insert(Connections,calledConnection)
				local Connection = {Connected = true}
				function Connection:Disconnect()
				    assert(table.find(Connections,func),"Connection was already disconnected")
						Connection.Connected = false
				    table.remove(Connections,func)
				end
				Connection.disconnect = Connection.Disconnect
				return Connection
			end
			function event:Wait()
				local calledConnection = {Type = "Wait"}
				function calledConnection:Call(...)
					self.Arguments = packtuple(...)
				end
				table.insert(Connections,calledConnection)
				repeat
					task.wait()
				until calledConnection.Arguments
				return table.unpack(calledConnection.Arguments)
			end
			event.connect = event.Connect
			event.connectparallel = event.ConnectParallel
			event.once = event.Once
			event.wait = event.Wait
			return returned
		end,
		Random = function(min, max, seed)
			local nrs = Random.new(seed or os.clock())
			if min and max then
				int = nrs:NextInteger(min,max)
				num = nrs:NextNumber(min,max)
			else
				int = 0
				num = nrs:NextNumber()
			end
			local unit = nrs:NextUnitVector()
			local rt = {Unit = unit,Integer = int,Number = num,Generator = nrs}
			return rt
		end,
		GetNil = function()
			return nilinstances
		end,
		Pack = packtuple
		},
	Destroy = function(ins,delay)
		if ins then
			deb:AddItem(ins,tonumber(delay) or 0)
		end
	end,
	Clone = function(inst)
		if not storage.clonable then
			storage.clonable = Instance.new("Script")
			storage.clonable.Disabled = true
		end
		if inst then
			local archivable = inst.Archivable
			inst.Archivable = true
			local newInst = storage.clonable.Clone(inst)
			inst.Archivable = archivable
			return newInst
		end
	end,
	Loops = {
		range = range,
		read = read,
		forever = forever
	}
}
lib.Create = function(Class, Parent, Properties)
	if not storage.cache then
		storage.cache = {}
	end
	local realInst
	local createdClonableInst = storage.cache[Class]
	if not createdClonableInst then
		local inst = Instance.new(Class)
		storage.cache[Class] = inst
		realInst = lib.Clone(inst)
	else
		realInst = lib.Clone(createdClonableInst)
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
		realInst.Parent = Parent
	end
	table.insert(created, realInst)
	return realInst
end
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
			if public.__readonly then
				local readonly_type = typeof(public.__readonly)
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
			if public.__call then
				local Arguments = lib.Utilities.Pack(public.__call(self, ...))
				return Copy(table.unpack(Arguments), public.__return and typeof(public.__return) == "table" and table.unpack(public.__return) or public.__return)
			end
			return Copy(public.__return and typeof(public.__return) == "table" and table.unpack(public.__return) or public.__return)
		end
	end
	if publicStorage then
		hidden.__index = function(self, index)
			local value = publicStorage[index]
			if publicStorage.__index then
				return publicStorage[index]
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
			if __index then
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
lib.Utilities.fastSpawn = function(func, ...)
	if not storage.fastSpawnRemote then
		storage.fastSpawnRemote = lib.Create("BindableEvent")
	end
	storage.fastSpawnRemote.Event:Once(func)
	storage.fastSpawnRemote:Fire(...)
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
lib.Utilities.GetCreatedByName = function(name, getnil)
	local found = {}
	lib.Loops.read(created, function(i, v)
		if v.Name == name then
			if getnil then
				table.insert(found, v)
			elseif v.Parent ~= nil then
				table.insert(found, v)
			end
		end
	end)
	return found
end
game.DescendantRemoving:Connect(function(descendant)
	pcall(isnilparent,descendant)
end)
return lib
