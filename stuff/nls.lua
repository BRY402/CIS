-- this is a dumpster fire
local http = game:GetService("HttpService")
local function createConnections(t: table)
  local Connections = {}
  function t:Connect(func)
    local ft = typeof(func)
    assert(ft == "function","Attempt to connect with "..ft)
    table.insert(Connections,v)
  end
  return Connections
end
local function callConnections(c: table,...)
  for i,v in pairs(c) do
    task.spawn(v,...)
  end
end
local __Locals = {}
local onls = NLS
local id = 0
local addons = {}
local adr = Instance.new("BindableEvent",script)
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
adr.Event:Connect(function(typ,name,nad)
  local typ = string.lower(typ)
  if typ == "add" then
    if addons[name] ~= nil then
      warn("Addon "..name.." overwritten") 
    end
    addons[name] = tostring(nad)
  elseif typ == "remove" then
    addons[name] = nil
  end
end)
local function format(str,name)
  local sct = {Loaded = false,
  src = str or "",
  Name = name or script.Name or "NLS|ID:"..id}
  return sct
end
local function NLS(src,parent,Data)
  local Data = Data or {}
  local scriptd = {SourceGrant = {},
  SourceDeny = {},
  Loaded = {}}
  local onload = createConnections(scriptd.Loaded)
  local ongrant = createConnections(scriptd.SourceGrant)
  local ondeny = createConnections(scriptd.SourceDeny)
  local screalload = false
  assert(typeof(Data) == "table","NLS was rejected, reason: "..reasons[1])
  id = id + 1
  local sct = format(src,Data.Name or nil)
  sct.Script = onls("",parent)
  if parent:FindFirstAncestorOfClass("Model") then
    sct.Player = game:GetService("Players"):GetPlayerFromCharacter(parent:FindFirstAncestorOfClass("Model"))
  elseif parent:FindFirstAncestorOfClass("Player") then
    sct.Player = parent:FindFirstAncestorOfClass("Player")
  end
  sct.Script.Name = sct.Name
  if sct.Script:IsA("LocalScript") and sct.Script:FindFirstChild("Source") and not sct.Loaded then
    sct.Loaded = true
    -- actions remote
    local ar = Instance.new("RemoteFunction",sct.Script)
    ar.Name = "ActionsRemote"
    ar.OnServerInvoke = function(plr,at,data)
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
          if not screalload then
            screalload = true
            callConnections(onload,sct.Script)
          end
          return Data.Rscript or script
        end
      end
    end
    -- execution for nls
    coroutine.resume(coroutine.create(function()
      while task.wait() do
        sct.Script:FindFirstChild("Source").OnServerInvoke = function(plr)
          if plr == sct.Player then
            callConnections(ongrant,plr)
            return extrasrc..(table.concat(addons,"\n") or "").."\n"..src
          else
            callConnections(ondeny,plr)
            return "No tampering pls"
          end
        end
      end
    end))
  end
  table.insert(__Locals,sct)
  return sct.Script,scriptd
end
return NLS, adr, __Locals
