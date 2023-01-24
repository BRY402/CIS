local HttpService = game:GetService("HttpService")
local lib = loadstring(HttpService:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/lib.lua",true))()
local blacklist = {"Explosions"}
local protect
local function ondeletion(data)
	if not data.Destroyed[1] then
		data.Destroyed[1] = true
		local newcf = data.CFrame or data.Current:IsA("BasePart") and data.Current.CFrame or CFrame.identity
		local cloneinst = lib.Clone(data.Clone)
		lib.Destroy(data.Current)
		if cloneinst then
			if cloneinst:IsA("BasePart") then
				cloneinst.CFrame = newcf
			end
			pcall(function()
				cloneinst.Parent = data.Parent
			end)
			data.Event:CallOnDestroy(cloneinst,data.Current)
			task.wait()
			local newEvent = protect(cloneinst)
			newEvent.CallOnDestroy = data.Event.CallOnDestroy
		end
	end
end
function protect(inst: Instance,changelist)
	if inst then
		if table.find(blacklist,inst.ClassName) then
			warn("Blacklisted instance type")
			return
		end
		local event = lib.Utilities.newEvent("OnDestroy","CallOnDestroy")
		local oldclone = lib.Clone(inst)
		local oldparent = inst.Parent
		local destroyed = {false}
		inst.Destroying:Once(function()
			ondeletion({Event = event,
				CFrame = inst.CFrame,
				Current = inst,
				Clone = oldclone,
				Parent = oldparent,
				Destroyed = destroyed})
		end)
		inst:GetPropertyChangedSignal("Parent"):Once(function()
			ondeletion({Event = event,
				CFrame = inst.CFrame,
				Current = inst,
				Clone = oldclone,
				Parent = oldparent,
				Destroyed = destroyed})
		end)
		print(changelist)
		if changelist then
			lib.Loops.read(changelist,function(i,v,yielding)
				inst:GetPropertyChangedSignal(v):Once(function()
					ondeletion({Event = event,
						CFrame = inst.CFrame,
						Current = inst,
						Clone = oldclone,
						Parent = oldparent,
						Destroyed = destroyed})
				end)
			end)
		end
		if inst:IsA("BasePart") then
			inst:GetPropertyChangedSignal("CFrame"):Once(function()
				if inst.Position.Y <= -50 then
					ondeletion({Event = event,
						CFrame = CFrame.identity,
						Current = inst,
						Clone = oldclone,
						Parent = oldparent,
						Destroyed = destroyed})
				end
			end)
		end
		return event
	end
end
local function createProtect(...)
	local event = protect(...)
	return {OnDestroy = event.OnDestroy}
end
return createProtect
