local http = game:GetService("HttpService")
local deb = game:GetService("Debris")
local blacklist = {"Explosions"}
local lib = loadstring(http:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/lib.lua",true))()
local protect
local function createProtectConnection(inst: Instance, list: table)
		local Connection = {Connections = {},
		OnDestroy = {},
		OnModifyList = list or {},
		Main = inst}
		function Connection.OnDestroy:Connect(func)
			local at = typeof(func)
			assert(at == "function","Attempt to connect with type "..at)
			table.insert(Connection.Connections,func)
		end
		Connection.Protector = {OnDestroy = Connection.OnDestroy,
		Main = inst}
	return Connection
end
local function protectInstance(Connection: table)
	local inst = Connection.Main
	if inst then
		if table.find(blacklist,inst.ClassName) then
			warn("Blacklisted instance type")
			return
		end
		local destroyed = {false}
		local oc = lib.Clone(inst)
		local op = inst.Parent
		local function ondeletion(ncf)
			local ncf = ncf or inst.CFrame
			if not destroyed[1] then
				destroyed[1] = true
				local clinst = lib.Clone(oc)
				if clinst then
					deb:AddItem(inst,0)
					if clinst:IsA("BasePart") then
						clinst.CFrame = ncf
					end
					pcall(function()
						clinst.Parent = op
					end)
					table.foreach(Connection.Connections,function(x,y)
						task.spawn(y,clinst)
					end)
					protect(clinst,Connection)
				end
			end
		end
		inst.Destroying:Connect(ondeletion)
		if inst:IsA("BasePart") then
			inst:GetPropertyChangedSignal("CFrame"):Connect(function()
				if inst.Position.Y <= -50 then
					ondeletion(CFrame.identity)
				end
			end)
		end
		inst:GetPropertyChangedSignal("Parent"):Connect(ondeletion)
		table.foreach(Connection.OnModifyList,function(i,v)
			inst:GetPropertyChangedSignal(tostring(v)):Connect(ondeletion)
		end)
		return Connection.Protector
	end
end
local function createProtect(inst: Instance, list: table)
	local Connection = createProtectConnection(inst,list)
	local Protector = protectInstance(Connection)
	return Protector
end
function protect(ninst: Instance, Connection: table)
	Connection.Main = ninst
	Connection.Protector.Main = ninst
	protectInstance(Connection)
end
return createProtect
