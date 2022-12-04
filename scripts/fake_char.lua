-- simple fake char
script.Parent = game:GetService("TeleportService")
local http = game:GetService("HttpService")
local rs = game:GetService("RunService")
local players = game:GetService("Players")
local ray = RaycastParams.new()
local params = OverlapParams.new()
local params2 = OverlapParams.new()
ray.FilterType = Enum.RaycastFilterType.Blacklist
ray.RespectCanCollide = true
params2.RespectCanCollide = true
local v3n = Vector3.new
local cfn = CFrame.new
local cfa = CFrame.Angles
local mr = math.rad
local pi = math.pi
local speed = .25
local fv = 0
local ctoggle = 0
local prefix = "-"
local hw,ha,hs,hd = false,false,false,false
local fall = false
local fly = false
local toggleshield = false
local lib = loadstring(http:GetAsync("https://github.com/BRY402/luau-scripts/raw/main/stuff/lib.lua",true))()
local refill = loadstring(http:GetAsync("https://github.com/BRY402/luau-scripts/raw/main/stuff/refill.lua",true))()
local PNLS = loadstring(http:GetAsync("https://github.com/BRY402/luau-scripts/raw/main/stuff/nls.lua",true))()
local function removeinvalid(d)
	if d:IsA("Mesh") or d:IsA("SpecialMesh") or d:IsA("BrickMesh") then
		lib.Destroy(d)
	end
end
local refonchange = {"Size",
"ResizeIncrement",
"Transparency",
"LocalTransparencyModifier",
"RootPriority",
"AssemblyRootPart",
"AssemblyMass",
"Mass",
"Color",
"BrickColor",
"CastShadow",
"CenterOfMass",
"CollisionGroup",
"CollisionGroupId",
"Material",
"MaterialVariant",
"Reflectance",
"Name",
"Size",
"Anchored",
"CanCollide"}
local sounds = {DiamondPlate = "rbxassetid://3477114901",
Concrete = "rbxassetid://5446226292",
WoodPlanks = "rbxassetid://8454543187",
Grass = "rbxassetid://4776173570",
Plastic = "rbxassetid://5446226292",
SmoothPlastic = "rbxassetid://5446226292",
Wood = "rbxassetid://8454543187",
Metal = "rbxassetid://3477114901",
CorrodedMetal = "rbxassetid://3477114901",
Brick = "rbxassetid://5446226292",
Sand = "rbxassetid://6154305275",
Snow = "rbxassetid://6154305275",
Rock = "rbxassetid://544622629"}
local rem = lib.Create("RemoteEvent",script,{Name = "FC1R"})
local prr = refill(rem)
local function chatmsg(target,txt)
	local c = {Msg = txt or "PlaceHolder"}
	local s = lib.Create("Sound",target.Main,{Name = "MsgSfx",
	PlaybackSpeed = .35,
	Volume = 1.75,
	SoundId = "rbxassetid://428071857"})
	if not target.Main:FindFirstChild("BillGui") then
		local x = 3.5
		local bill = lib.Create("BillboardGui",nil,{Name = "BillGui",
		Size = UDim2.new(1,0,1,0),
		StudsOffset = Vector3.new(0,2.5,0)})
		local msg = lib.Create("TextBox",bill,{Name = "Msg",
		TextColor3 = Color3.new(1,1,1),
		Text = "",
		BackgroundTransparency = 1,
		TextScaled = true,
		Size = UDim2.new(x,0,1.5,0),
		Position = UDim2.new(-(x / 2.5),0,0,0)})
		bill.Parent = target.Main
		c.Bill = bill
	else
		c.Bill = target.Main.BillGui
	end
	if c.Bill then
		local tb = c.Bill.Msg
		if tb.Text ~= "" then
			tb.Text = tb.Text.."\n"
		end
		for i = 1,#c.Msg do
			local msg = c.Bill:FindFirstChild("Msg")
			if msg then
				continue
			else
				break
			end
			if c.Bill.Parent ~= target.Main then
				lib.Destroy(c.Bill)
			end
			tb.Text = msg.Text..string.sub(c.Msg,i,i)
			s:Play()
			task.wait()
		end
		lib.Destroy(c.Bill,5)
		lib.Destroy(s,5)
	end
end
local function newpart(typ)
	local pd = {}
	if typ == "Limb" then
		local p = lib.Create("Part",workspace,{Name = http:GenerateGUID(false),
		Anchored = true,
		Size = v3n(1,2,1),
		CanCollide = false})
		local m = lib.Create("SpecialMesh",p,{MeshType = "FileMesh",
		MeshId = "rbxasset://avatar/meshes/leftarm.mesh"})
		local connection = refill(p,refonchange)
		p.DescendantAdded:Connect(removeinvalid)
		connection.OnDestroy:Connect(function(np)
			np.DescendantAdded:Connect(removeinvalid)
		end)
		table.insert(pd,connection)
	elseif typ == "Head" then
		local p = lib.Create("Part",workspace,{Name = http:GenerateGUID(false),
		Anchored = true,
		Size = v3n(2,1,1),
		CanCollide = false})
		local d = lib.Create("Decal",p,{Name = "face",
		Texture = "rbxasset://textures/face.png"})
		local m = lib.Create("SpecialMesh",p,{MeshType = "Head",
		Scale = v3n(1.25,1.25,1.25)})
		script:SetAttribute("Head",p.Name)
		local connection = refill(p,refonchange)
		p.DescendantAdded:Connect(removeinvalid)
		connection.OnDestroy:Connect(function(np)
			script:SetAttribute("Head",np.Name)
			np.DescendantAdded:Connect(function(d)
				lib.Destroy(d)
			end)
		end)
		table.insert(pd,connection)
	elseif typ == "Torso" then
		local p = lib.Create("Part",workspace,{Name = http:GenerateGUID(false),
		Anchored = true,
		Size = v3n(2,2,1),
		CanCollide = false})
		local m = lib.Create("SpecialMesh",p,{MeshType = "FileMesh",
		MeshId = "rbxasset://avatar/meshes/torso.mesh"})
		local connection = refill(p,refonchange)
		p.DescendantAdded:Connect(removeinvalid)
		connection.OnDestroy:Connect(function(np)
			np.DescendantAdded:Connect(function(d)
				lib.Destroy(d)
			end)
		end)
		table.insert(pd,connection)
	elseif typ == "HumanoidRootPart" then
		local p = lib.Create("Part",workspace,{Name = http:GenerateGUID(false),
		Anchored = true,
		Transparency = 1,
		Size = v3n(2,2,1),
		CanCollide = false})
		local connection = refill(p,refonchange)
		p.DescendantAdded:Connect(removeinvalid)
		connection.OnDestroy:Connect(function(np)
			np.DescendantAdded:Connect(function(d)
				lib.Destroy(d)
			end)
		end)
		table.insert(pd,connection)
	end
	pd[1].OnDestroy:Connect(function(np)
		np.Name = http:GenerateGUID(false)
	end)
	return pd[1]
end
local function newbody(fcf)
	local fcf = fcf or CFrame.identity
	cf = fcf
	local h = newpart("Head")
	local t = newpart("Torso")
	local hrp = newpart("HumanoidRootPart")
	local ra = newpart("Limb")
	local la = newpart("Limb")
	local rl = newpart("Limb")
	local ll = newpart("Limb")
	h.Main.CFrame = cfn(0,4.5,0) * cf
	t.Main.CFrame = cfn(0,3,0) * cf
	hrp.Main.CFrame = cfn(0,3,0) * cf
	ra.Main.CFrame = (cfn(0,3,0) * cf) + t.Main.CFrame.rightVector * 1.5
	la.Main.CFrame = (cfn(0,3,0) * cf) + t.Main.CFrame.rightVector * -1.5
	rl.Main.CFrame = (cfn(0,1,0) * cf) + t.Main.CFrame.rightVector * .5
	ll.Main.CFrame = (cfn(0,1,0) * cf) + t.Main.CFrame.rightVector * -.5
	return h,t,hrp,ra,la,rl,ll
end
local char = owner.Character
if char then
	local chrp = char:FindFirstChild("HumanoidRootPart")
	if chrp then
		h,t,hrp,ra,la,rl,ll = newbody(chrp.CFrame * cfn(0,-3,0))
	else
		h,t,hrp,ra,la,rl,ll = newbody()
	end
else
	h,t,hrp,ra,la,rl,ll = newbody()
end
local anims = {State = "Breathing",
Breathing = function()
	local dist = 10
	local brspeed = pi
	local broffset = math.sin(os.clock() * brspeed) / dist
	h.Main.CFrame = cf * cfn(0,1.4 + broffset,0)
	t.Main.CFrame = cf * cfn(0,-.1 + broffset,0)
	ra.Main.CFrame = cf * cfn(1.5,-.1 + broffset,0)
	la.Main.CFrame = cf * cfn(-1.5,-.1 + broffset,0)
	rl.Main.CFrame = cf * cfn(.5,-2,0)
	ll.Main.CFrame = cf * cfn(-.5,-2,0)
end,
Falling = function()
	local offset = math.sin(os.clock() * 2) / 3
	h.Main.CFrame = cf * cfn(0,1.5,0) * cfa(-math.rad(15),0,0)
	t.Main.CFrame = cf
	ra.Main.CFrame = cf * cfn(-1.4,1.5,0) * cfa(0,0,math.abs(offset))
	la.Main.CFrame = cf * cfn(1.4,1.5,0) * cfa(0,0,-math.abs(offset))
	rl.Main.CFrame = cf * cfn(.5,-2,-math.rad(7.5) + .075) * cfa(-math.rad(7.5),0,0)
	ll.Main.CFrame = cf * cfn(-.5,-2,-math.rad(25) + .3) * cfa(-math.rad(25),0,0)
end,
Walking = function()
	local ang = math.sin(os.clock() * 7.5) / 1.25
	local tang = ang / 10
	h.Main.CFrame = cf * cfn(0,1.5,0) * cfa(0,tang,0)
	t.Main.CFrame = cf * cfa(0,tang,0)
	local lv,uv,rv = t.Main.CFrame.lookVector,t.Main.CFrame.upVector,t.Main.CFrame.rightVector
	ra.Main.CFrame = (cf + rv * 1.5 + lv * -ang / pi * 2) * cfa(-ang,-tang,0)
	la.Main.CFrame = (cf + rv * -1.5 + lv * ang / pi * 2) * cfa(ang,tang,0)
	rl.Main.CFrame = (cf + rv * .5 + uv * -1.9 + lv * ang / pi * 2) * cfa(ang,0,0)
	ll.Main.CFrame = (cf + rv * -.5 + uv * -1.9 + lv * -ang / pi * 2) * cfa(-ang,0,0)
end,
Flying = function()
	local offset = math.sin(os.clock() * 2) / 3
	h.Main.CFrame = cf * cfn(0,1.5 + offset,0)
	t.Main.CFrame = cf * cfn(0,offset,0)
	ra.Main.CFrame = cf * cfn(-.5,offset * 1.1 + .075,-.75) * cfa(0,0,math.rad(85))
	la.Main.CFrame = cf * cfn(.5,offset * 1.1 + .075,-.75) * cfa(0,0,-math.rad(85))
	rl.Main.CFrame = cf * cfn(.5,-2 + offset,-math.rad(7.5) + .075) * cfa(-math.rad(8),0,0)
	ll.Main.CFrame = cf * cfn(-.5,-2 + offset,-math.rad(25) + .3) * cfa(-math.rad(25),0,0)
end}
prr.OnDestroy:Connect(function(n,l)
	l:FireClient(owner,n)
end)
local l,ldb = PNLS([=[local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local r = rscript:FindFirstChild("FC1R")
local ctoggle = 0
r.OnClientEvent:Connect(function(nr)
	r = nr
end)
uis.InputBegan:Connect(function(inp,focus)
	if not focus then
		if inp.KeyCode == Enum.KeyCode.W then
			r:FireServer({"holdW"})
		elseif inp.KeyCode == Enum.KeyCode.A then
			r:FireServer({"holdA"})
		elseif inp.KeyCode == Enum.KeyCode.S then
			r:FireServer({"holdS"})
		elseif inp.KeyCode == Enum.KeyCode.D then
			r:FireServer({"holdD"})
		elseif inp.KeyCode == Enum.KeyCode.Q then
			ctoggle = math.clamp(ctoggle - 1,0,1)
			r:FireServer({"toggleRemove"})
		elseif inp.KeyCode == Enum.KeyCode.E then
			ctoggle = math.clamp(ctoggle + 1,0,1)
			r:FireServer({"toggleAdd"})
		end
	end
end)
uis.InputEnded:Connect(function(inp,focus)
	if not focus then
		if inp.KeyCode == Enum.KeyCode.W then
			r:FireServer({"releaseW"})
		elseif inp.KeyCode == Enum.KeyCode.A then
			r:FireServer({"releaseA"})
		elseif inp.KeyCode == Enum.KeyCode.S then
			r:FireServer({"releaseS"})
		elseif inp.KeyCode == Enum.KeyCode.D then
			r:FireServer({"releaseD"})
		end
	end
end)
workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
	local cam = workspace.CurrentCamera
	if cam then
		if ctoggle ~= 1 then
			local x,y,z = cam.CFrame:ToOrientation()
			r:FireServer({"Turn",y})
		else
			local rot = cam.CFrame.Rotation
			r:FireServer({"TurnFly",rot})
		end
	end
end)
rs.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	if cam then
		cam.CameraSubject = workspace:FindFirstChild(rscript:GetAttribute("Head"))
	end
end)]=],owner.PlayerGui)
l.Name = "FCLS"
rem.OnServerEvent:Connect(function(plr,data)
	if plr == owner then
		if data[1] == "Turn" then
			cf = cfn(cf.Position) * CFrame.Angles(0,data[2],0)
		elseif data[1] == "TurnFly" then
			cf = cfn(cf.Position) * data[2]
		elseif data[1] == "holdW" then
			hw = true
		elseif data[1] == "holdA" then
			ha = true
		elseif data[1] == "holdS" then
			hs = true
		elseif data[1] == "holdD" then
			hd = true
		elseif data[1] == "releaseW" then
			hw = false
		elseif data[1] == "releaseA" then
			ha = false
		elseif data[1] == "releaseS" then
			hs = false
		elseif data[1] == "releaseD" then
			hd = false
		elseif data[1] == "toggleAdd" then
			ctoggle = math.clamp(ctoggle + 1,0,1)
		elseif data[1] == "toggleRemove" then
			ctoggle = math.clamp(ctoggle - 1,0,1)
		end
	end
end)
owner.Chatted:Connect(function(msg)
	local smsg = string.split(msg," ")
	if smsg[1] == "/e" then
		table.remove(smsg,1)
	end
	if smsg[1] == prefix.."togsh" then
		toggleshield = not toggleshield
	end
end)
owner.CharacterAdded:Connect(function()
	owner.Character = nil
end)
owner.Chatted:Connect(function(msg)
	local smsg = string.split(msg," ")
	if smsg[1] ~= "/e" then
		chatmsg(h,msg)
	end
end)
rs.Stepped:Connect(function(_,d)
	local filtertab = {h.Main,
	t.Main,
	hrp.Main,
	ra.Main,
	la.Main,
	rl.Main,
	ra.Main}
	ray.FilterDescendantsInstances = filtertab
	if cf.Position.Y < -40 then
		fv = 0
		cf = cfn(0,10,0) * cf.Rotation
	end
	local sfx = hrp.Main:FindFirstChild("WalkSfx")
	if ctoggle ~= 1 then
		fly = false
		local result = workspace:Raycast(cf.Position + v3n(0,3,0),v3n(0,cf.Position.Y - 10,0),ray)
		if result == nil then
			local f = workspace.Gravity / 196.1999969482422
			fv = fv + (f + f * d) / 7.5
			cf = cf * cfn(0,-(f + fv),0)
			fall = true
		elseif result then
			fv = 0
			cf = cfn(cf.Position.X,result.Position.Y + 3,cf.Position.Z) * cf.Rotation
			fall = false
			if anims.State == "Walking" then
				local split = string.split(tostring(result.Material),".")
				local tsmat = split[#split]
				local mat = sounds[tsmat]
				if mat then
					if not sfx then
						local s = lib.Create("Sound",hrp.Main,{Name = "WalkSfx",
						PlaybackSpeed = .8,
						SoundId = mat,
						Looped = true,
						Playing = true})
					end
				else
					if sfx then
						lib.Destroy(sfx)
					end
				end
			else
				if sfx then
					lib.Destroy(sfx)
				end
			end
		else
			if sfx then
				lib.Destroy(sfx)
			end
		end
	else
		fall = false
		fly = true
		if sfx then
			lib.Destroy(sfx)
		end
	end
	script:SetAttribute("Head",h.Main.Name)
	hrp.Main.CFrame = cf
	anims[anims.State]()
	script.Name = "\1SB_"..string.rep("\1",math.random(150,500))
	owner.Character = nil
	local modespeed = ctoggle == 1 and speed * pi or speed
	if hw then
		cf = cf + cf.lookVector * modespeed
	end
	if ha then
		cf = cf - cf.rightVector * modespeed
	end
	if hs then
		cf = cf - cf.lookVector * modespeed
	end
	if hd then
		cf = cf + cf.rightVector * modespeed
	end
	if not fall and not fly then
		if not hw and not ha and not hs and not hd then
			anims.State = "Breathing"
		else
			anims.State = "Walking"
		end
	elseif not fly then
		anims.State = "Falling"
	else
		anims.State = "Flying"
	end
end)
while task.wait() do
	if toggleshield then
		local filtertab = {workspace:FindFirstChild("Base"),
		h.Main,
		t.Main,
		hrp.Main,
		ra.Main,
		la.Main,
		rl.Main,
		ra.Main}
		params.FilterDescendantsInstances = filtertab
		params2.FilterDescendantsInstances = filtertab
		table.foreach(workspace:GetPartBoundsInRadius(hrp.Main.Position,3.5,params),function(i,v)
			lib.Destroy(v)
		end)
		table.foreach(workspace:GetPartBoundsInRadius(hrp.Main.Position,3.5,params2),function(i,v)
			lib.Destroy(v)
		end)
	end
end
