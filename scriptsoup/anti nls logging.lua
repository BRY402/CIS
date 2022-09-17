c/-- this is very simple and probably bypasseable (with out of sandbox code) so if you for some reason use it and find a bypass to this script pls tell me i beg u
local http = game:GetService("HttpService")
local __Locals = {}
local onls = NLS
local id = 0
local extrasrc = [==[local ar = script:WaitForChild("ActionsRemote")
local http = game:GetService("HttpService")
local function getbans()
local banlist = http:JSONDecode(ar:InvokeServer("GetBans"))
return banlist
end
local rscript = ar:InvokeServer("Rscript")
local ar = nil
local http = nil]==]
local reasons = {"Invalid Data type, table or nil expected"}
local function format(str,name)
local sct = {Loaded = false,
src = str or "",
Name = name or script.Name or "NLS|ID:"..id}
return sct
end
local function NLS(src,parent,Data)
local Data = Data or {}
assert(typeof(Data) == "table","NLS was rejected, reason: "..reasons[1])
id = id + 1
local sct = format(src,Data.Name or nil)
sct.Script = onls("",parent)
sct.Script.Name = sct.Name
if sct.Script:IsA("LocalScript") and sct.Script:FindFirstChild("Source") and not sct.Loaded then
sct.Loaded = true
-- actions remote
local ar = Instance.new("RemoteFunction",sct.Script)
ar.Name = "ActionsRemote"
ar.OnServerInvoke = function(plr,at)
if plr == owner then
if at == "GetBans" then
local list = game:GetBans()
for i,v in pairs(list) do
if typeof(v) ~= "table" then
list[i] = tostring(v)
end
end
return http:JSONEncode(list)
elseif at == "Rscript" then
return Data.Rscript or script
end
end
end
-- execution for nls
coroutine.resume(coroutine.create(function()
while task.wait() do
sct.Script:FindFirstChild("Source").OnServerInvoke = function(plr)
if plr == owner then
return extrasrc.."\n"..src
else
print(plr.." attempted to log you")
return "No tampering pls"
end
end
end
end))
end
table.insert(__Locals,sct)
return sct.Script
end
