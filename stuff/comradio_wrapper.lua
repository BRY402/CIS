local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lib = loadstring(HttpService:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/lib.lua",true), "lib")()
local comradio = {}
local function validateId(id)
	return math.clamp(tonumber(id) or 1, 1, math.huge)
end
local function getPlayer(id)
	local success, user = pcall(function()
		return Players:GetNameFromUserIdAsync(validateId(id))
	end)
	if not success then
		return "Unknown"
	else
		return user
	end
end
local function getPlayerId(name)
	local success, id = pcall(function()
		return Players:GetUserIdFromNameAsync(tostring(name))
	end)
	if not success then
		return 1
	else
		return id
	end
end
function comradio:NewUser(id, nickname)
	local id = validateId(id)
	local name = getPlayer(id)
	local chattedEvent = lib.Utilities.newEvent("Chatted")
	local rosterEvent = lib.Utilities.newEvent("RosterRequested")
	local channelEvent = lib.Utilities.newEvent("ChangedChannel")
	local statusEvent = lib.Utilities.newEvent("ChangedStatus")
	local userEvent = lib.Utilities.newEvent("UserAdded")
	local storage = {
		RequestingRoster = false,
		Responses = {}
	}
	local connection = {
		Channel = "general",
		Events = {
			Chatted = chattedEvent.Chatted,
			RosterRequested = rosterEvent.RosterRequested,
			ChangedChannel = channelEvent.ChangedChannel,
			ChangedStatus = statusEvent.ChangedStatus,
			UserAdded = userEvent.UserAdded
		},
		Radio = {}
	}
	local function newConnection()
		return MessagingService:SubscribeAsync("comradio:"..connection.Channel, function(data)
			local data = HttpService:JSONDecode(data) or table.create(0)
			if data.Type == "text" then
				chattedEvent:Fire(data.Type, getPlayer(data.Author), tostring(data.Content), tostring(data.Nickname))
			elseif data.Type == "sound" or data.Type == "image" then
				chattedEvent:Fire(data.Type, getPlayer(data.Author), tostring(data.Comment), tostring(data.Content), tostring(data.Nickname))
			elseif data.Type == "ping" then
				chattedEvent:Fire(data.Type, getPlayer(data.Author), tostring(data.Comment), getPlayer(data.Content), tostring(data.Nickname))
			elseif data.Type == "status" then
				statusEvent:Fire(getPlayer(data.Author), tostring(data.Comment))
			elseif data.Type == "rosterRequest" then
				connection:RespondToRoster()
				rosterEvent:Fire(getPlayer(data.Author), "Request")
			elseif data.Type == "rosterResponse" then
				if storage.RequestingRoster and data.Author ~= id then
					table.insert(storage.Responses, getPlayer(data.Author))
					rosterEvent:Fire(getPlayer(data.Author), "Response")
				end
			elseif data.Type == "welcome" then
				userEvent:Fire(getPlayer(data.Author))
			end
		end)
	end
	function connection.Radio:GetRosterResponses()
		return table.clone(storage.Responses)
	end
	function connection.Radio:GetNameFromId(id)
		return getPlayer(id)
	end
	function connection.Radio:GetIdFromName(name)
		return getPlayerId(name)
	end
	function connection.Radio:GetId()
		return id
	end
	function connection.Radio:GetName()
		return name
	end
	function connection:SetChannel(channel)
		self.Channel = tostring(channel)
		channelEvent:Fire(tostring(channel))
	end
	function connection:SendMessage(msg)
		MessagingService:PublishAsync("comradio:"..self.Channel, HttpService:JSONEncode({
			Type = "text",
			Content = tostring(msg),
			Author = id,
			Nickname = nickname
		}))
		chattedEvent:Fire("text", getPlayer(id), tostring(msg), nickname)
	end
	function connection:SendSound(content, msg)
		MessagingService:PublishAsync("comradio:"..self.Channel, HttpService:JSONEncode({
			Type = "sound",
			Content = tostring(content),
			Comment = tostring(msg),
			Author = id,
			Nickname = nickname
		}))
		chattedEvent:Fire("sound", getPlayer(id), tostring(msg), tostring(content), nickname)
	end
	function connection:SendImage(content, msg)
		MessagingService:PublishAsync("comradio:"..self.Channel, HttpService:JSONEncode({
			Type = "image",
			Content = tostring(content),
			Comment = tostring(msg),
			Author = id,
			Nickname = nickname
		}))
		chattedEvent:Fire("image", getPlayer(id), tostring(msg), tostring(content), nickname)
	end
	function connection:SendPing(user, msg)
		MessagingService:PublishAsync("comradio:"..self.Channel, HttpService:JSONEncode({
			Type = "ping",
			Content = tostring(validateId(user)),
			Comment = tostring(msg),
			Author = id,
			Nickname = nickname
		}))
		chattedEvent:Fire("ping", getPlayer(id), tostring(msg), getPlayer(user), tostring(nickname))
	end
	function connection:ChangeStatus(new_status)
		MessagingService:PublishAsync("comradio:"..self.Channel, HttpService:JSONEncode({
			Type = "status",
			Content = "",
			Comment = tostring(new_status),
			Author = id
		}))
		statusEvent:Fire(getPlayer(id), tostring(new_status))
	end
	function connection:RequestRoster()
		MessagingService:PublishAsync("comradio:"..self.Channel, HttpService:JSONEncode({
			Type = "rosterRequest",
			Content = "",
			Author = id
		}))
		table.clear(storage.Responses)
		storage.RequestingRoster = true
		rosterEvent:Fire(getPlayer(id), "Request")
		task.delay(1, function()
			storage.RequestingRoster = false
		end)
	end
	function connection:RespondToRoster()
		MessagingService:PublishAsync("comradio:"..self.Channel, HttpService:JSONEncode({
			Type = "rosterResponse",
			Content = "",
			Author = id
		}))
	end
	function connection:SendWelcome()
		MessagingService:PublishAsync("comradio:"..self.Channel, HttpService:JSONEncode({
			Type = "welcome",
			Content = "",
			Comment = "",
			Author = id,
			Nickname = nickname
		}))
		userEvent:Fire(getPlayer(id))
	end
	storage.CurrentConnection = newConnection(connection.Channel)
	channelEvent.ChangedChannel:Connect(function(channel)
		storage.CurrentConnection:Disconnect()
		storage.CurrentConnection = newConnection(channel)
		connection:SendWelcome()
	end)
	connection:SendWelcome()
	return connection
end
return comradio
