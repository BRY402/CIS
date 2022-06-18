local importable = {}
function importable.gp(name)
for i,v in pairs(game.Players:GetPlayers()) do
if string.lower(string.sub(v.Name,0,#name)) == string.lower(name) then
return v
else
return nil
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

return "Console++",importable