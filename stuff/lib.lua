local deb = game:GetService("Debris")
local rs = game:GetService("RunService")
local clonable = Instance.new("Script")
local nilinstances = {}
local cache = {}
clonable.Disabled = true
local function isnilparent(target)
	target:GetPropertyChangedSignal("Parent"):Connect(function()
		if target.Parent == nil then
			table.insert(nilinstances,target)
		else
			table.remove(nilinstances,table.find(nilinstances,target))
		end
	end)
end
local function setproperty(target,index,value)
	if tonumber(index) then
		value.Parent = target
		isnilparent(value)
	else
		target[index] = value
	end
end
local function create(Class,Parent,Properties)
	local Properties = Properties or {}
	local ri
	local cci = cache[Class]
	if not cci then
		local inst = Instance.new(Class)
		cache[Class] = inst
		inst.Archivable = true
		ri = clonable.Clone(inst)
	else
		cci.Archivable = true
		ri = clonable.Clone(cci)
	end
	if ri ~= nil then
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
				setfenv(selfFunc,env)(ri)
			end)
		end
		if Properties.CanPropertyYield then
			Properties.CanPropertyYield = nil
			for i,v in pairs(Properties) do
				setproperty(ri,i,v)
				task.wait()
			end
		else
			table.foreach(Properties,function(i,v)
				setproperty(ri,i,v)
			end)
		end
		isnilparent(ri)
	end
	ri.Parent = Parent
	return ri
end
local lib = {Create = create,
Random = function(min,max,seed)
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
Destroy = function(ins,delay)
	deb:AddItem(ins,tonumber(delay) or 0)
end,
GetNil = function()
	return nilinstances
end,
Clone = function(inst)
	if inst then
		local arch = inst.Archivable
		inst.Archivable = true
		local ninst = clonable.Clone(inst)
		inst.Archivable = arch
		return ninst
	end
end}
local remote = lib.Create("BindableEvent")
lib.fastSpawn = function(func,...)
	remote.Event:Once(func)
	remote:Fire(...)
end
return lib
