local importable = {r = Instance.new("RemoteEvent",script.Window1)}
importable.r.Name = "Entries"

NLS([==[local r = owner.Character.CCONS.Window1.Entries
local entries = script.Parent.SB_OutputGUI.Main.Output.Entries
entries.ChildAdded:Connect(function(c)
task.wait()
if not string.find(c.Text,"joined") or not string.find(c.Text,"left") then
r:FireServer({c.Text,c.TextColor3},owner)
end
end)]==],owner.PlayerGui)

function importable.gp(name)
for i,v in pairs(game.Players:GetPlayers()) do
if string.lower(string.sub(v.Name,0,#name)) == string.lower(name) then
return v
end
end
end

function importable:gpa(name)
local plr = importable.gp(name)
return (plr.AccountAge / 30) / 12
end

function importable:bring(name)
local plr = importable.gp(name)
if plr.Character then
plr.Character:MoveTo(owner.Character.HumanoidRootPart.Position)
end
end

importable.r.OnServerEvent:Connect(function(plr,txt)
local s,f = pcall(function()
txt[1] = string.gsub(txt[1],"\n",", ").." <font color='rgb(110,110,110)'> - Output</font>"
if string.sub(txt[1],0,2) == "> " then
log = newlog(txt[1],gui)
else
log = newlog("> "..txt[1],gui)
end
log.TextColor3 = txt[2]
end)
end)

return "Console++",importable