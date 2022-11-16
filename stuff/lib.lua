local deb = game:GetService("Debris")
local rs = game:GetService("RunService")
local mce = "Unable to create \"%s\""
local nilinstances = {}
local created = {}
local function create(Class,Parent,Properties)
	local ri
	local cci = created[Class]
	if not cci then
		inst = Instance.new(Class)
		created[Class] = inst
		inst.Archivable = true
		ri = script.Clone(inst)
		ri.Parent = Parent
	else
		cci.Archivable = true
		ri = script.Clone(cci)
		ri.Parent = Parent
	end
	ri:SetAttribute("Creator",typeof(script) == "Instance" and script:GetFullName() or "nil")
	if ri ~= nil then
		coroutine.resume(coroutine.create(function()		
			for i,v in pairs(Properties) do
				ri[i] = v or ri[i]
			end
		end))
		ri:GetPropertyChangedSignal("Parent"):Connect(function()
			if ri.Parent == nil then
				table.insert(nilinstances,ri)
			else
				table.remove(nilinstances,table.find(nilinstances,ri))
			end
		end)
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
		local ninst = script.Clone(inst)
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
