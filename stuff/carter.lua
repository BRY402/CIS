local HttpService = game:GetService("HttpService")
local lib = loadstring(HttpService:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/lib.lua",true))()
local url = "https://api.carterapi.com/v0/chat"
local bots = {}
local carter = {new = function(api_key,scene)
	local storage = {key = "",
		scene = "Normal",
		CanChat = true,
		ids = {}}
	storage.key = tostring(api_key)
	if scene then
		storage.scene = tostring(scene)
	end
	local ChatterEvent = lib.newEvent("ChatterAdded","AddChatter")
	local BotChatted = lib.newEvent("Chatted","Chat")
	local bot = {ChatterAdded = ChatterEvent.ChatterAdded,
		Chatted = BotChatted.Chatted}
	function bot:Send(msg,player)
		assert(storage.CanChat,"Bot#"..tostring(table.find(bots,bot)).." disabled")
		local id = player.UserId
		if not table.find(storage.ids,id) then
			table.insert(storage.ids,id)
			ChatterEvent:AddChatter(player)
		end
		local response = HttpService:RequestAsync({Url = url,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({api_key = storage.key,
				query = msg,
				uuid = id,
				scene = storage.scene})})
		assert(response.Success,"Response fail: "..response.StatusCode..", "..response.StatusMessage)
		local reply = HttpService:JSONDecode(response.Body)
			local outputData = {Player = player,
			  Time_Taken = reply.time_taken,
			  Credits_Used = reply.credits_used}
	local outputText = reply.output.text
		BotChatted:Chat(outputText,outputData)
		return outputText,outputData
	end
	function bot:Exit()
		storage.CanChat = false
	end
	function bot:SetScene(scene)
		assert(scene,"Missing scene argument for SetScene")
		storage.scene = tostring(scene)
	end
	table.insert(bots,bot)
	return bot
end}
return carter
