-- this is a dumpster fire
local http = game:GetService("HttpService")
local __Locals = {}
local onls = NLS
local id = 0
local addons = {}
local adr = Instance.new("BindableEvent",script)
local extrasrc = [==[local ar = script:WaitForChild("ActionsRemote")
local http = game:GetService("HttpService")
local loadstring = (function()
]==]..http:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/loadstring.lua",true)..[==[
end)()
local function getbans()
  local banlist = http:JSONDecode(ar:InvokeServer("GetBans"))
  return banlist
end
local function gethttp(url)
  local data = ar:InvokeServer("HttpRequest",{url})
  return data
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
          return Data.Rscript or script
        elseif at == "HttpRequest" then
          return http:GetAsync(data[1],true)
        end
      end
    end
    -- execution for nls
    coroutine.resume(coroutine.create(function()
      while task.wait() do
        sct.Script:FindFirstChild("Source").OnServerInvoke = function(plr)
          if plr == sct.Player then
            return extrasrc..(table.concat(addons,"\n") or "").."\n"..src
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
return NLS, adr, __Locals
