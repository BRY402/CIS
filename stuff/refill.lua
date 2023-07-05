local HttpService = game:GetService("HttpService")
local lib = loadstring(HttpService:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/lib.lua", true), "lib")()
local protect
local function ondeletion(data)
	if not data.Storage.destroyed then
		data.Storage.destroyed = true
		task.defer(function()
			local newcf = data.CFrame or data.Current:IsA("BasePart") and data.Current.CFrame or CFrame.identity
			local cloneinst = lib.Clone(data.Clone)
			lib.Destroy(data.Current)
			if cloneinst then
				if data.ChangedValue then
					cloneinst[data.ChangedValue] = data.OldValue
				end
				data.Event:CallOnDestroy(cloneinst, data.Current)
				if cloneinst:IsA("BasePart") then
					cloneinst.CFrame = newcf
				end
				cloneinst.Parent = data.Parent
				local newEvent = protect(cloneinst, data.ChangeList)
				newEvent.CallOnDestroy = data.Event.CallOnDestroy
			end
		end)
	end
end
function protect(inst: Instance, changelist)
	if inst then
		local event = lib.Utilities.newEvent("OnDestroy","CallOnDestroy")
		local oldclone = lib.Clone(inst)
		local oldparent = inst.Parent
		local storage = {
			destroyed = false,
			connections = {}
		}
		function event:Disconnect()
			lib.Loops.read(storage.connections, function(i, connection)
				connection:Disconnect()
			end)
		end
		if oldclone:IsA("BasePart") then
			local direction = 0 / 0
			oldclone.Position = Vector3.new(-direction, -direction, -direction)
		end
		table.insert(storage.connections, inst.Destroying:Once(function()
			local cf = inst:IsA("BasePart") and inst.CFrame
			ondeletion({Event = event,
				CFrame = cf,
				Current = inst,
				Clone = oldclone,
				Parent = oldparent,
				Storage = storage,
				ChangeList = changelist})
		end))
		table.insert(storage.connections, inst:GetPropertyChangedSignal("Parent"):Once(function()
			local cf = inst:IsA("BasePart") and inst.CFrame
			ondeletion({Event = event,
				CFrame = cf,
				Current = inst,
				Clone = oldclone,
				Parent = oldparent,
				Storage = storage,
				ChangeList = changelist})
		end))
		if changelist then
			lib.Loops.read(changelist,function(i,v,yielding)
				local lastValue = inst[v]
				table.insert(storage.connections, inst:GetPropertyChangedSignal(v):Once(function()
					local cf = inst:IsA("BasePart") and inst.CFrame
					ondeletion({Event = event,
						CFrame = cf,
						Current = inst,
						Clone = oldclone,
						Parent = oldparent,
						Storage = storage,
						ChangeList = changelist,
						ChangedValue = v,
						OldValue = lastValue
					})
				end))
			end)
		end
		if inst:IsA("BasePart") then
			table.insert(storage.connections, inst:GetPropertyChangedSignal("CFrame"):Once(function()
				if inst.Position.Y <= -50 and not inst.Anchored then
					ondeletion({Event = event,
						CFrame = CFrame.identity,
						Current = inst,
						Clone = oldclone,
						Parent = oldparent,
						Storage = storage,
						ChangeList = changelist})
				end
			end))
		end
		return event
	end
end
local function createProtect(...)
	local event = protect(...)
	if event then
		return {
			OnDestroy = event.OnDestroy,
			Disconnect = event.Disconnect,
			disconnect = event.Disconnect
		}
	end
end
return createProtect
