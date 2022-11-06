local deb = game:GetService("Debris")
local rs = game:GetService("RunService")
local function create(Class,Parent,Properties)
	coroutine.resume(coroutine.create(function()
		local ri
		xpcall(function()
			ri = Instance.new(Class,Parent)
			ri:SetAttribute("Creator",typeof(script) == "Instance" and script:GetFullName() or "nil")
		end,function(f)
			task.wait()
			create(Class,Parent)
			coroutine.yield()
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
end,
Encode = function(data,key)
	local rdata = string.gsub(data,".",function(cc)
		local tb = math.round(string.byte(cc) * key + (key ^ math.pi) / (key ^ string.byte(cc)))
		return tb.."|"
	end)
	return string.sub(rdata,0,#rdata - 1)
end,
Decode = function(data,key)
	local rdata = ""
	table.foreach(string.split(data,"|"),function(i,cc)
		local tb = math.round(cc / key - (key % math.pi) * (key % cc))
		rdata = rdata..string.char(tb)
	end)
	return rdata
end}
lib.fastSpawn = function(func,...)
	local r = lib.Create("BindableEvent")
	r.Event:Connect(func)
	r:Fire(...)
	lib.Destroy(r)
end
return lib
