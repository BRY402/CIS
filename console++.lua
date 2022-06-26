local importable = {addtofired = [[string.gsub(tab[1],"end","<font color='rgb(255,0,0)'> end </font>
string.gsub(tab[1],"local","<font color='rgb(255,0,0)'> local </font>
string.gsub(tab[1],"function","<font color='rgb(255,0,0)'> function </font>")]]}
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

return "Console++",importable