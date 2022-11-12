local deb = game:GetService("Debris")
local rs = game:GetService("RunService")
local mce = "Unable to create \"%s\""
local function create(Class,Parent,Properties)
	coroutine.resume(coroutine.create(function()
		local ri
		xpcall(function()
			ri = Instance.new(Class,Parent)
			ri:SetAttribute("Creator",typeof(script) == "Instance" and script:GetFullName() or "nil")
		end,function(f)
			if f == string.format(mce,Class) then
				task.wait()
				create(Class,Parent)
				coroutine.yield()
			end
		end)
		if ri ~= nil then
			for i,v in pairs(Properties) do
				ri[i] = v
				task.wait()
			end
			ri:GetPropertyChangedSignal("Parent"):Connect(function()
				if ri.Parent == nil then
					table.insert(nilinstances,ri)
				else
					table.remove(nilinstances,table.find(nilinstances,ri))
				end
			end)
			return ri
		end
	end))
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
end,}
lib.fastSpawn = function(func,...)
	local r = lib.Create("BindableEvent")
	r.Event:Connect(func)
	r:Fire(...)
	lib.Destroy(r)
end
return lib
