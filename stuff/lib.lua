local deb = game:GetService("Debris")
local rs = game:GetService("RunService")
local storage = {}
local nilinstances = {}
local function range(min, max, add, func)
	for i = min, max, add do
		local yield = i % (10 * add) == 0
		func(i, yield)
		if yield then
			task.wait()
		end
	end
end
local function read(list, func)
	local number = {0}
	for i,v in pairs(list) do
		local n = number[1]
		number[1] = n + 1
		local yield = (n + 1) % 10 == 0
		func(i , v, yield)
		if yield then
			task.wait()	
		end
	end
end
local function forever(func)
	local number = {0}
	while true do
		local n = number[1]
		number[1] = n + 1
		local yield = (n + 1) % 10 == 0
		func(n, yield)
		if yield then
			task.wait()
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
local lib = {
	Utilities = {
		newEvent = function(eventName, callerName, methodOrFunction)
		    local methodOrFunction = methodOrFunction and methodOrFunction or "Method"
		    local Connections = {}
		    local returned = {[eventName] = {}}
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
		deb:AddItem(ins,tonumber(delay) or 0)
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
		return realInst
	end
local remote = lib.Create("BindableEvent")
lib.Utilities.fastSpawn = function(func, ...)
	remote.Event:Once(func)
	remote:Fire(...)
end
game.DescendantRemoving:Connect(isnilparent)
return lib
