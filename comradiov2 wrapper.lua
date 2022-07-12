--[[The basics of using this wrapper:
more about comradiov2 can be found in the github account fofl12 or in the (not created yet) file "what is comradiov2.md"
the variable that defines the connection can be found at the bottom of this file
you can also change your settings at the settings table
this wrapper is made to be used in consoles but you can put it anywhere you want
i also recommend you don't use my log system as its garbage if you have your own
you can better this if you want i don't really care i'm not watching you anyway

connection commands you can use:
Connection:Roster() sends a roster request on the current channel
Connection:SetChannel(channel name) changes your connections channel
Connection:SetStatus(status) changes your status text
Connection:SetNickname(nickname) changes your displayable nickname
Connection:Chat(message) makes your connection chat the message (if you want to ping someone your message has to start with @ and their name or a short version of their name)

connection commands you can use but i don't recommend as they are used by the wrapper itself:
Connection:SendWelcome() sends a message saying that you joined the channel
Connection:Encode() encodes lua table to json
Connection:Decode() deconds json to lua table
Connection:Respond() responds to roster requests
]]
local settings = {maximumlogamount = 10,
  nickname = "",
  id = owner.UserId, -- this is only if you're creating a connection on startup
  textsize = 30,
  font = Enum.Font.Code,
  fontsize = 12.75
  }

local deb = game:GetService("Debris")
local function newlog(text,sg)
coroutine.resume(coroutine.create(function()
if #sg:GetChildren() <= settings.maximumlogamount then
for i,v in pairs(sg:GetChildren()) do
if v:IsA("TextBox") then
v.Position += UDim2.new(0,0,.1,0)
end
end
else
for i,v in pairs(sg:GetChildren()) do
if v:IsA("TextBox") then
v.Position += UDim2.new(0,0,.1,0)
end
end
deb:AddItem(sg:GetChildren()[1],0)
if #sg:GetChildren() >= 60 then
sg:ClearAllChildren()
end
end
log = Instance.new("TextBox",sg)
log.BackgroundTransparency = 1
log.TextColor3 = Color3.new(1,1,1)
log.TextSize = settings.textsize
log.TextYAlignment = Enum.TextYAlignment.Top
log.TextXAlignment = Enum.TextXAlignment.Left
log.Font = settings.font
log.FontSize = settings.fontsize
log.Text = text
log.Size = UDim2.new(1,0,.1,0)
y += .1
game:GetService("RunService").Stepped:Wait()
end))
return log
end
local cr = {}
function cr:MakeConnection(userid,nick)
local plrs = game:GetService("Players")
local ms = game:GetService("MessagingService")
local http = game:GetService("HttpService")
local ts = game:GetService("TextService")
local function filter(stf)
local stf = string.gsub(stf,string.char(0),"[NULL]")
local stf = string.gsub(stf,string.char(127),"[NULL]")
local stf = string.gsub(stf,string.char(10),"[WS]")
return ts:FilterStringAsync(stf,owner.UserId,Enum.TextFilterContext.PublicChat):GetChatForUserAsync(owner.UserId)
end
local function gn(n,id)
if n and n ~= "" then
return filter(n).." ("..plrs:GetNameFromUserIdAsync(id)..")"
else
return plrs:GetNameFromUserIdAsync(id)
end
end
local function getplrfromping(m)
local m = string.sub(m,2,#m)
local cca = 0
local cc = ""
local pplr = ""
repeat
cca += 1
cc = string.sub(m,cca,cca)
pplr ..= cc
task.wait()
until cc == " " or cca == #m
if cc == " " then
pplr = string.sub(pplr,0,#pplr - 1)
end
for i,v in pairs(plrs:GetPlayers()) do
if string.sub(string.lower(v.Name),0,#pplr) == string.lower(pplr) then
return v.UserId
end
end
end
local rosters = {checking = false}
local connection = {id = userid,
channel = "",
nick = nick,
cc = ms:SubscribeAsync("comradio:",function(msg)
pcall(function()
local mr = http:JSONDecode(msg.Data)
if mr.Type == "text" then
local name = gn(mr.Nickname,mr.Author)
newlog("["..name.."]: "..filter(mr.Content),crgui)
elseif mr.Type == "sound" or mr.Type == "image" then
local name = gn(mr.Nickname,mr.Author)
newlog("["..name.."]: "..filter(mr.Comment).." (Id: "..string.sub(mr.Content,#"rbxassetid://" + 1,#mr.Content)..")",crgui)
elseif mr.Type == "welcome" then
local name = gn(mr.Nickname,mr.Author)
newlog(name.." has joined the channel. ()",crgui)
elseif mr.Type == "status" then
local name = gn(mr.Nickname,mr.Author)
newlog(name.." has changed their status: "..filter(mr.Comment),crgui)
elseif mr.Type == "ping" then
local name = gn(mr.Nickname,mr.Author)
local log = newlog("["..name.." (Ping)]: "..filter(mr.Comment),crgui)
if mr.Content == userid then
log.BackgroundTransparency = .6
log.BackgroundColor3 = Color3.new(1,1,0)
end
elseif mr.Type == "rosterRequest" then
if mr.Author == userid then
rosters.checking = true
task.delay(5,function()
rosters.checking = false
end)
else
rosters.checking = false
end
local name = gn(mr.Nickname,mr.Author)
newlog("Roster request from "..name,crgui)
ms:PublishAsync("comradio:",http:JSONEncode({
	Type = "rosterResponse",
	Content = owner.Name,
	Author = owner.UserId}))
elseif mr.Type == "rosterResponse" and rosters.checking then
local name = gn(mr.Nickname,mr.Author)
newlog("Roster response: "..name,crgui)
end
end)
end)}
function connection:Encode(t)
return http:JSONEncode(t)
end
function connection:Decode(str)
return http:JSONDecode(str)
end
function connection:SendWelcome()
local mi = self:Encode({
	Type = "welcome",
	Content = "",
	Comment = "",
	Author = self.id
})
ms:PublishAsync("comradio:"..self.channel,mi)
end
function connection:Respond()
local r = self:Encode({
	Type = "rosterResponse",
	Content = owner.Name,
	Author = owner.UserId
})
ms:PublishAsync("comradio:"..self.channel,r)
end
function connection:Roster()
local r = self:Encode({
	Type = "rosterRequest",
	Content = "Request from "..owner.Name,
	Author = owner.UserId
})
ms:PublishAsync("comradio:"..self.channel,r)
end
connection:SendWelcome()
function connection:SetChannel(name)
if name ~= nil and typeof(name) == "string" then
self.channel = name
self.cc:Disconnect()
self.cc = game:GetService("MessagingService"):SubscribeAsync("comradio:"..name,function(msg)
pcall(function()
local mr = game:GetService("HttpService"):JSONDecode(msg.Data)
if mr.Type == "text" then
local name = gn(mr.Nickname,mr.Author)
newlog("["..name.."]: "..filter(mr.Content),crgui)
elseif mr.Type == "sound" or mr.Type == "image" then
local name = gn(mr.Nickname,mr.Author)
newlog("["..name.."]: "..filter(mr.Comment).." (Id: "..string.sub(mr.Content,#"rbxassetid://" + 1,#mr.Content)..")",crgui)
elseif mr.Type == "welcome" then
local name = gn(mr.Nickname,mr.Author)
newlog(name.." has joined the channel. ("..self.channel..")",crgui)
elseif mr.Type == "status" then
local name = gn(mr.Nickname,mr.Author)
newlog(name.." has changed their status: "..filter(mr.Comment),crgui)
elseif mr.Type == "ping" then
local name = gn(mr.Nickname,mr.Author)
local log = newlog("["..name.." (Ping)]: "..filter(mr.Comment),crgui)
if mr.Content == self.id then
log.BackgroundTransparency = .6
log.BackgroundColor3 = Color3.new(1,1,0)
end
elseif mr.Type == "rosterRequest" then
if mr.Author == self.id then
rosters.checking = true
task.delay(5,function()
rosters.checking = false
end)
else
rosters.checking = false
end
local name = gn(mr.Nickname,mr.Author)
newlog("Roster request from "..name,crgui)
connection:Respond()
elseif mr.Type == "rosterResponse" and rosters.checking then
local name = gn(mr.Nickname,mr.Author)
newlog("Roster response: "..name,crgui)
end
end)
end)
self:SendWelcome()
else
self.channel = ""
self.cc:Disconnect()
self.cc = ms:SubscribeAsync("comradio:",function(msg)
pcall(function()
local mr = self:Decode(msg.Data)
if mr.Type == "text" then
local name = gn(mr.Nickname,mr.Author)
newlog("["..name.."]: "..filter(mr.Content),crgui)
elseif mr.Type == "sound" or mr.Type == "image" then
local name = gn(mr.Nickname,mr.Author)
newlog("["..name.."]: "..filter(mr.Comment).." (Id: "..string.sub(mr.Content,#"rbxassetid://" + 1,#mr.Content)..")",crgui)
elseif mr.Type == "welcome" then
local name = gn(mr.Nickname,mr.Author)
newlog(name.." has joined the channel. ("..self.channel..")",crgui)
elseif mr.Type == "status" then
local name = gn(mr.Nickname,mr.Author)
newlog(name.." has changed their status: "..filter(mr.Comment),crgui)
elseif mr.Type == "ping" then
local name = gn(mr.Nickname,mr.Author)
local log = newlog("["..name.." (Ping)]: "..filter(mr.Comment),crgui)
if mr.Content == self.id then
log.BackgroundTransparency = .6
log.BackgroundColor3 = Color3.new(1,1,0)
end
elseif mr.Type == "rosterRequest" then
if mr.Author == self.id then
rosters.checking = true
task.delay(5,function()
rosters.checking = false
end)
else
rosters.checking = false
end
local name = gn(mr.Nickname,mr.Author)
newlog("Roster request from "..name,crgui)
connection:Respond()
elseif mr.Type == "rosterResponse" and rosters.checking then
local name = gn(mr.Nickname,mr.Author)
newlog("Roster response: "..name,crgui)
end
end)
end)
self:SendWelcome()
end
end
function connection:Chat(rawmsg,type)
if type == nil then
type = "text"
end
if type == "text" and string.sub(rawmsg,0,1) == "@" then
type = "ping"
end
if type ~= "ping" then
mi = self:Encode({
	Type = type,
	Content = rawmsg,
	Comment = "",
	Author = self.id,
	Nickname = self.nick
})
else
mi = self:Encode({
	Type = "ping",
	Content = getplrfromping(rawmsg),
	Comment = rawmsg,
	Author = self.id
})
end
ms:PublishAsync("comradio:"..self.channel,mi)
end
function connection:SetStatus(rawst)
local s = self:Encode({
	Type = "status",
	Content = "",
	Comment = rawst,
	Author = self.id,
})
ms:PublishAsync("comradio:"..self.channel,s)
end
function connection:SetNickname(nn)
self.nick = nn
end
return connection
end
newlog("Made connection as "..game:GetService("Players"):GetNameFromUserIdAsync(settings.id)..". (variable: User)",crgui)
local User = cr:MakeConnection(settings.id,settings.nickname)
