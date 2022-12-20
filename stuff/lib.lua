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
local function create(Class,Parent,Properties)
	local ri
	local cci = cache[Class]
	if not cci then
		local inst = Instance.new(Class)
		cache[Class] = inst
		inst.Archivable = true
		ri = clonable.Clone(inst)
		ri.Parent = Parent
	else
		cci.Archivable = true
		ri = clonable.Clone(cci)
		ri.Parent = Parent
	end
	if ri ~= nil then
		table.foreach(Properties or {},function(i,v)
			if tonumber(i) then
				v.Parent = ri
				isnilparent(v)
			else
				ri[i] = v
			end
		end)
		isnilparent(ri)
	end
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
lib.fastSpawn = function(func,...)
	local r = lib.Create("BindableEvent")
	r.Event:Connect(func)
	r:Fire(...)
	lib.Destroy(r)
end
return lib
