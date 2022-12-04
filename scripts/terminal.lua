local http = game:GetService("HttpService")
local deb = game:GetService("Debris")
local plrs = game:GetService("Players")
local display
local imports = {Core = 0,
Addons = {}}
local rts = tostring
local function tts(t,n,iit)
	if iit then
		local nn = tonumber(n)
		if nn then
			n = "["..n.."]"
		else
			n = "[\""..tostring(n).."\"]"
		end
	end
	local str = n.." = {\n"
	for i,v in pairs(t) do
		if typeof(v) == "table" then
			str = i ~= #t and str..tts(v,i,true)..",\n" or str..tts(v,i,true)
		elseif typeof(v) == "Instance" then
			str = i ~= #t and str..v:GetFullName()..",\n" or str..v:GetFullName()
		else
			str = i ~= #t and str..tostring(v)..",\n" or str..tostring(v)
		end
	end
	return str.."\n}"
	-- not the best table displayer
end
local function tostring(arg)
	if typeof(arg) == "table" then
		return tts(arg,rts(arg),false)
	else
		return rts(arg)
	end
end
local function import(name)
	local r = {loadstring(http:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/"..name..".lua",true))()}
	imports.Core = imports.Core + 1
	return unpack(r)
end
local rts = nil
local env = getfenv()
env.ThreadMng = {}
env.ThreadMng.Threads = {}
env.tostring = tostring
env.ImportStuff = import
local lib = import("lib")
local rem = lib.Create("RemoteEvent",owner,{Name = http:GenerateGUID(false)})
local function newwin(size,pos,ori)
	local win = lib.Create("Part",script,{Name = "Window",
	Material = "Air",
	CanCollide = false,
	Massless = true,
	CanTouch = false,
	Size = size,
	Color = Color3.new(0,0,0),
	Transparency = .65,
	CFrame = owner.Character:FindFirstChild("HumanoidRootPart").CFrame})
	local mesh = lib.Create("SpecialMesh",win,{MeshType = "FileMesh",
	MeshId = "rbxasset://avatar/meshes/torso.mesh",
	Scale = size - Vector3.new(4.25,3.6,0)})
	win:SetNetworkOwner(owner)
	local surfg = lib.Create("SurfaceGui",owner,{Name = "TerminalGui",
	Adornee = win})
	local cmdbar = lib.Create("TextBox",surfg,{Name = "CmdBar",
	Size = UDim2.new(1,0,.05,0),
	Position = UDim2.new(0,0,.95,0),
	BackgroundTransparency = 1,
	TextXAlignment = "Left",
	TextYAlignment = "Top",
	PlaceholderText = "Click here to run a command",
	Text = "",
	ClearTextOnFocus = false,
	TextSize = 15,
	TextColor3 = Color3.new(1,1,1)})
	local maing = lib.Create("ScrollingFrame",surfg,{Name = "MainScroll",
	Size = UDim2.new(1,0,.95,0),
	CanvasSize = UDim2.new(0,0,0,0),
	AutomaticCanvasSize = Enum.AutomaticSize.XY,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 6})
	local listl = lib.Create("UIListLayout",maing)
	local at0 = lib.Create("Attachment",win,{Position = -pos,
	Orientation = Vector3.new(180,0,180) + ori})
	local at1 = lib.Create("Attachment",owner.Character:FindFirstChild("HumanoidRootPart"))
	local ap = lib.Create("AlignPosition",win,{Attachment0 = at0,
	Attachment1 = at1,
	RigidityEnabled = true})
	local ao = lib.Create("AlignOrientation",win,{Attachment0 = at0,
	Attachment1 = at1,
	RigidityEnabled = true})
	surfg.Parent = win
	return win,surfg,maing,cmdbar
end
local win,surfg,maing,cmdbar = newwin(Vector3.new(9,7.5,0),Vector3.new(0,1.5,4),Vector3.zero)
local function outputmsg(msg: string,color: Color3)
	local text = lib.Create("TextBox",nil,{Name = "OutputText",
	Size = UDim2.new(1,0,.05,0),
	BackgroundTransparency = 1,
	TextXAlignment = "Left",
	AutomaticSize = "Y",
	Text = tostring(msg),
	TextWrapped = true,
	ClearTextOnFocus = false,
	TextEditable = false,
	TextSize = 15,
	TextColor3 = color})
	maing.Parent = owner
	text.Parent = maing
	maing.Parent = surfg
	return text
end
env.tprint = function(...)
	local args = {}
	for i,v in pairs({...}) do
		xpcall(function()
			table.insert(args,tostring(v))
		end,function()
			table.insert(args,v)
		end)
	end
	outputmsg("> "..table.concat(args," "),Color3.new(1,1,1))
end
env.twarn = function(...)
	local args = {}
	for i,v in pairs({...}) do
		xpcall(function()
			table.insert(args,tostring(v))
		end,function()
			table.insert(args,v)
		end)
	end
	outputmsg(os.date("%X").. " - "..table.concat(args," "),Color3.fromRGB(255,150,0))
end
env.terror = function(f)
	outputmsg(os.date("%X").. " - "..f,Color3.new(1,0,0))
end
env.display = function(...)
	local args = {}
	for i,v in pairs({...}) do
		xpcall(function()
			local ts = tostring(v)
			if typeof(v) == "Vector2" or typeof(v) == "Vector3" or typeof(v) == "CFrame" then
				table.insert(args,"("..ts..")")
			else
				table.insert(args,ts)
			end
		end,function()
			table.insert(args,v)
		end)
	end
	outputmsg("> "..table.concat(args,", "),Color3.new(1,1,1))
end
local ls = import("loadstring")
local PNLS = import("nls")
env.exec = ls
env.PNLS = PNLS
env.lib = lib
env.newwin = newwin
env.newlog = outputmsg
env.Clear = function()
	for i,v in pairs(maing:GetChildren()) do
		if v:IsA("TextBox") then
			deb:AddItem(v,0)
			task.wait()
		end
	end
end
env.ThreadMng.Kill = function()
	for i,v in pairs(env.ThreadMng.Threads) do
		if v ~= coroutine.running() then
			coroutine.yield(v)
			task.cancel(v)
			table.remove(env.ThreadMng.Threads,i)
			task.wait()
		end
	end
	coroutine.yield()
end
PNLS([==[local rem = owner:FindFirstChild("]==]..rem.Name..[==[")
local gui = rscript.Window:FindFirstChild("TerminalGui")
local tb = gui.CmdBar
local ntb = tb:Clone()
tb:Destroy()
ntb.Parent = gui
ntb:GetPropertyChangedSignal("Text"):Connect(function()
	local code = ntb.Text
	rem:FireServer("SyncText",code)
end)
ntb.FocusLost:Connect(function(pe)
	if pe then
		rem:FireServer("RunText",ntb.Text)
	end
end)]==],owner.PlayerGui)
rem.OnServerEvent:Connect(function(plr,at,...)
	if plr == owner then
		if at == "SyncText" then
			cmdbar.Text = ...
		elseif at == "RunText" then
			local rc = ...
			outputmsg(owner.Name.."> "..rc,Color3.new(1,1,1))
			local nt = coroutine.create(function()
				xpcall(function()
					local args = {ls(rc,env)()}
					if #args > 0 then
						env.display(unpack(args))
					end
				end,env.terror)
			end)
				coroutine.resume(nt)
				table.insert(env.ThreadMng.Threads,nt)
		end
	end
end)
outputmsg(os.date("%X").." - Loaded terminal",Color3.new(0,1,0))
outputmsg(os.date("%X").." - "..imports.Core.." Core packages loaded",Color3.new(0,1,0))
plrs.PlayerAdded:Connect(function(plr)
	outputmsg(os.date("%X").." - "..plr.Name.." has joined the server",Color3.new(0,1,0))
end)
plrs.PlayerRemoving:Connect(function(plr)
	outputmsg(os.date("%X").." - "..plr.Name.." has left the server",Color3.new(0,1,0))
end)
