local HttpService = game:GetService("HttpService")
local lib = loadstring(HttpService:GetAsync("https://github.com/BRY402/random-scripts/raw/main/stuff/lib.lua",true))()
local function getResponse(url, data)
	local response = HttpService:RequestAsync({
		Url = url,
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode(data)
	})
	assert(response.Success, "Response fail: "..response.StatusCode..", "..response.StatusMessage)
	return HttpService:JSONDecode(response.Body)
end
local bots = {}
local carter = {new = function(api_key, version_)
	local storage = {
		key = "",
		CanChat = true,
		ids = {}
	}
	local ChatterEvent = lib.Utilities.newEvent("ChatterAdded", "AddChatter")
	local BotChatted = lib.Utilities.newEvent("Chatted")
	local bot = {
		ChatterAdded = ChatterEvent.ChatterAdded,
		Chatted = BotChatted.Chatted
	}
	function bot:Exit()
		storage.CanChat = false
	end
	local Versions = {
		V0 = function()
			warn("V0 is still available but it is highly recommended to use V1 as the AI is better, the decision is up to you.")
			storage.scene = "Normal"
			function bot:Send(msg, player)
				assert(storage.CanChat,"Bot#"..tostring(table.find(bots, bot)).." is disabled")
				local id = player and player.UserId or ""
				if player and not table.find(storage.ids, id) then
					table.insert(storage.ids, id)
					ChatterEvent:AddChatter(player)
				end
				local outputData = getResponse("https://api.carterapi.com/v0/chat", {
					api_key = storage.key,
					query = msg,
					uuid = global and "" or id,
					scene = storage.scene
				})
				local outputText = outputData.output.text
				outputData.Player = player
				BotChatted:Fire(outputText, outputData)
				return outputText, outputData
			end
			function bot:SetScene(scene)
				assert(scene, "Missing scene argument for SetScene")
				storage.scene = tostring(scene)
			end
		end,
		V1 = function()
			function bot:Send(msg, player)
				assert(storage.CanChat,"Bot#"..tostring(table.find(bots, bot)).." is disabled")
				local id = player and player.UserId or ""
				if player and not table.find(storage.ids, id) then
					table.insert(storage.ids,id)
					ChatterEvent:AddChatter(player)
				end
				local outputData = getResponse("https://api.carterlabs.ai/chat", {
					key = storage.key,
					text = msg,
					playerId = id,
				})
				local outputText = outputData.output.text
				outputData.Player = player
				BotChatted:Fire(outputText, outputData)
				return outputText, outputData
			end
		end
	}
	assert(version_ and typeof(version_) == "string", "Expected version")
	local botVersion = Versions[version_]
	assert(botVersion, "Invalid version")
	storage.key = tostring(api_key)
	bot.Version = version_
	botVersion()
	table.insert(bots, bot)
	return bot
end}
return carter
