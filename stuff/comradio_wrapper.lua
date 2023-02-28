local comradio = import("comradio_wrapper")
local user = comradio:NewUser(owner.UserId, "bry")
local storage = {CurrentUsers = {user.Radio:GetName()}}
local function newmsg(text)
	return terminal.newlog("Comradio/> "..text, Color3.new(0, 1, 1))
end
local function findPlr(name)
	local storage_1 = {Id = nil}
	lib.Loops.read(Services.Players:GetPlayers(), function(i, v)
		if string.lower(string.sub(v.Name, 1, #name)) == string.lower(name) then
			storage_1.Id = v.UserId
		end
	end)
	if not storage_1.Id then
		lib.Loops.read(storage.CurrentUsers, function(i, v)
			if string.lower(string.sub(v, 1, #name)) == string.lower(name) then
				storage_1.Id = user.Radio:GetIdFromName(v)
			end
		end)
	end
	if not storage_1.Id then
		storage_1.Id = user.Radio:GetIdFromName(name)
	end
	return storage_1.Id
end
user.Events.Chatted:Connect(function(type_, ...)
	if type_ == "text" then
		local name, msg, displayname = ...
		newmsg("["..displayname.." (@"..name..")]: "..msg)
	elseif type_ == "ping" then
		local name, msg, target, displayname = ...
		local msg_log = newmsg("["..displayname.." (@"..name..")]: "..msg)
		if target == user.Radio:GetName() then
			msg_log.BackgroundTransparency = .3
			msg_log.BackgroundColor3 = Color3.new(.8 , .8, 0)
		end
	end
end)
user.Events.UserAdded:Connect(function(name)
	if not table.find(storage.CurrentUsers, name) then
		table.insert(storage.CurrentUsers, name)
	end
	newmsg("[System]: Welcome to '"..user.Channel.."', "..name..".")
end)
owner.Chatted:Connect(function(msg)
	local split_msg = string.split(msg, " ")
	if split_msg[1] == "/e" or split_msg[1] == "/emote" then
		table.remove(split_msg, 1)
	end
	local msg_table = table.clone(split_msg)
	table.remove(msg_table, 1)
	if split_msg[1] == "-chat" then
		local isPing = string.sub(smsg[2], 1, 1) == "@"
		if not isPing then
			user:SendMessage(table.concat(msg_table, " "))
		else
			table.remove(msg_table, 1)
			user:SendPing(findPlr[smsg[2]], table.concat(msg_table, " "))
		end
	elseif split_msg[1] == "-channel" then
		user:SetChannel(table.concat(msg_table, " "))
		table.clear(storage.CurrentUsers)
	elseif split_msg[1] == "-roster" then
		user:RequestRoster()
		newmsg("Requesting roster (usually takes around 1 second)...")
		task.wait(1)
		local responses = user.Radio:GetRosterResponses()
		storage.CurrentUsers = responses
		if #responses > 0 then
			newmsg("Roster responses: "..table.concat(responses, "\n"))
		else
			newmsg("There were no roster responses.")
		end
	end
end)
